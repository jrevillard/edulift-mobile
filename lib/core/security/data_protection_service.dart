/// Data Protection Service - Production-grade orchestrator
///
/// This service orchestrates secure data protection by coordinating:
/// - CryptoService for production-grade AES-256-GCM encryption
/// - SecureStorageService for secure key management
/// - Proper error handling with standardized exceptions
///
/// Replaces the demo-level EncryptionService with enterprise architecture

import 'dart:convert';
import 'dart:typed_data';
import '../../core/services/adaptive_storage_service.dart';
import '../../core/security/crypto_service.dart';
import '../../core/utils/result.dart';
import '../../core/errors/exceptions.dart';

/// Key identifier for the master encryption keys in secure storage
const _masterKeysStorageKey = 'master_encryption_keys';

/// Versioned key storage structure
class _KeyStorage {
  final int currentKeyId;
  final Map<int, String> keys; // keyId -> base64 encoded key

  _KeyStorage({required this.currentKeyId, required this.keys});

  Map<String, dynamic> toJson() => {
    'currentKeyId': currentKeyId,
    'keys': keys.map((k, v) => MapEntry(k.toString(), v)),
  };

  factory _KeyStorage.fromJson(Map<String, dynamic> json) => _KeyStorage(
    currentKeyId: json['currentKeyId'] as int,
    keys: (json['keys'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(int.parse(k), v as String),
    ),
  );
}

/// Production-grade data protection service
///
/// Provides encrypted data storage by orchestrating cryptographic operations
/// and secure key management with proper separation of concerns.
///
/// Features:
/// - Non-destructive key rotation with versioned keys
/// - Session-based key caching for performance (OWASP 600k iterations)
/// - Secure memory management
class DataProtectionService {
  final CryptoService _cryptoService;
  final AdaptiveStorageService _secureStorageService;

  // Session-based key caching to avoid PBKDF2 on every operation
  Uint8List? _cachedDerivedKey;
  int? _cachedKeyId;
  _KeyStorage? _cachedKeyStorage;

  DataProtectionService(this._cryptoService, this._secureStorageService);

  /// Encrypts plaintext data using the current master key
  ///
  /// Handles master key generation and storage on first run.
  /// Uses production-grade AES-256-GCM encryption with authentication.
  /// Implements session-based key caching for performance with OWASP 600k iterations.
  ///
  /// CRITICAL ANR FIX: Uses encryptAsync() to run PBKDF2 in background isolate.
  Future<Result<String, CryptographyException>> encrypt(
    String plaintext,
  ) async {
    try {
      final keyData = await _getCurrentKeyData();
      // CRITICAL: Use async to prevent ANR from PBKDF2 blocking main thread
      final result = await _cryptoService.encrypt(
        plaintext,
        keyData.masterKey,
        keyData.keyId,
      );

      return result;
    } on StorageException catch (e) {
      return Result.err(
        CryptographyException(
          'Failed to retrieve master key from storage: ${e.message}',
          operation: 'encrypt',
          algorithm: 'AES-256-GCM',
        ),
      );
    } catch (e) {
      return Result.err(
        CryptographyException(
          'An unexpected error occurred during encryption: ${e.toString()}',
          operation: 'encrypt',
          algorithm: 'AES-256-GCM',
        ),
      );
    }
  }

  /// Decrypts ciphertext using the appropriate versioned key
  ///
  /// Uses production-grade AES-256-GCM decryption with authentication verification.
  /// Automatically selects the correct key based on the key ID in the ciphertext.
  Future<Result<String, CryptographyException>> decrypt(
    String ciphertext,
  ) async {
    try {
      // First decrypt to get the key ID
      final keyStorage = await _getKeyStorage();

      // Try to determine key ID from ciphertext (we need any key to start)
      final anyKey = await _getMasterKeyById(
        keyStorage.currentKeyId,
        keyStorage,
      );
      // CRITICAL: Use async to prevent ANR from PBKDF2 blocking main thread
      final decryptResult = await _cryptoService.decrypt(ciphertext, anyKey);

      if (decryptResult.isSuccess) {
        final result = decryptResult.value!;
        // If we used the wrong key, get the correct one and retry
        if (result.keyId != keyStorage.currentKeyId) {
          return await _decryptWithSpecificKey(
            ciphertext,
            result.keyId,
            keyStorage,
          );
        }
        return Result.ok(result.plaintext);
      } else {
        // If decryption failed, try all available keys
        return await _tryDecryptWithAllKeys(ciphertext, keyStorage);
      }
    } on StorageException catch (e) {
      return Result.err(
        CryptographyException(
          'Failed to retrieve master key for decryption: ${e.message}',
          operation: 'decrypt',
          algorithm: 'AES-256-GCM',
        ),
      );
    } catch (e) {
      return Result.err(
        CryptographyException(
          'An unexpected error occurred during decryption: ${e.toString()}',
          operation: 'decrypt',
          algorithm: 'AES-256-GCM',
        ),
      );
    }
  }

  /// Gets the current key data with session-based caching
  Future<({Uint8List masterKey, int keyId})> _getCurrentKeyData() async {
    final keyStorage = await _getKeyStorage();
    final currentKeyId = keyStorage.currentKeyId;

    // Use cached key if available and matches current key ID
    if (_cachedDerivedKey != null && _cachedKeyId == currentKeyId) {
      return (masterKey: _cachedDerivedKey!, keyId: currentKeyId);
    }

    // Cache miss - get the key and cache it
    final masterKey = await _getMasterKeyById(currentKeyId, keyStorage);

    // Clear old cached key and cache the new one
    _clearCachedKey();
    _cachedDerivedKey = Uint8List.fromList(masterKey);
    _cachedKeyId = currentKeyId;

    return (masterKey: masterKey, keyId: currentKeyId);
  }

  /// Retrieves or creates the key storage structure with caching
  Future<_KeyStorage> _getKeyStorage() async {
    // Return cached storage if available
    if (_cachedKeyStorage != null) {
      return _cachedKeyStorage!;
    }

    final storedData = await _secureStorageService.read(_masterKeysStorageKey);
    if (storedData != null) {
      final json = jsonDecode(storedData) as Map<String, dynamic>;
      _cachedKeyStorage = _KeyStorage.fromJson(json);
      return _cachedKeyStorage!;
    } else {
      // Create initial key storage with first key
      final initialKey = _cryptoService.generateMasterKey();
      final keyStorage = _KeyStorage(
        currentKeyId: 1,
        keys: {1: base64Encode(initialKey)},
      );

      await _secureStorageService.write(
        _masterKeysStorageKey,
        jsonEncode(keyStorage.toJson()),
      );

      _cachedKeyStorage = keyStorage;
      return keyStorage;
    }
  }

  /// Gets a specific master key by ID
  Future<Uint8List> _getMasterKeyById(int keyId, _KeyStorage keyStorage) async {
    final keyBase64 = keyStorage.keys[keyId];
    if (keyBase64 == null) {
      throw StorageException(
        'Master key with ID $keyId not found',
        operation: 'read',
      );
    }
    return base64Decode(keyBase64);
  }

  /// Attempts decryption with a specific key ID
  ///
  /// CRITICAL ANR FIX: Uses decryptAsync() to run PBKDF2 in background isolate.
  Future<Result<String, CryptographyException>> _decryptWithSpecificKey(
    String ciphertext,
    int keyId,
    _KeyStorage keyStorage,
  ) async {
    try {
      final masterKey = keyStorage.keys[keyId];
      if (masterKey == null) {
        return Result.err(
          CryptographyException(
            'Master key with ID $keyId not found',
            operation: 'decrypt',
            algorithm: 'AES-256-GCM',
          ),
        );
      }

      final keyBytes = base64Decode(masterKey);
      // CRITICAL: Use async to prevent ANR
      final result = await _cryptoService.decrypt(ciphertext, keyBytes);

      if (result.isSuccess) {
        return Result.ok(result.value!.plaintext);
      } else {
        return Result.err(result.error!);
      }
    } catch (e) {
      return Result.err(
        CryptographyException(
          'Failed to decrypt with key ID $keyId: ${e.toString()}',
          operation: 'decrypt',
          algorithm: 'AES-256-GCM',
        ),
      );
    }
  }

  /// Tries decryption with all available keys (fallback)
  ///
  /// CRITICAL ANR FIX: Uses decryptAsync() to run PBKDF2 in background isolate.
  Future<Result<String, CryptographyException>> _tryDecryptWithAllKeys(
    String ciphertext,
    _KeyStorage keyStorage,
  ) async {
    CryptographyException? lastError;

    for (final entry in keyStorage.keys.entries) {
      try {
        final keyBytes = base64Decode(entry.value);
        // CRITICAL: Use async to prevent ANR
        final result = await _cryptoService.decrypt(ciphertext, keyBytes);

        if (result.isSuccess) {
          return Result.ok(result.value!.plaintext);
        } else {
          lastError = result.error!;
        }
      } catch (e) {
        lastError = CryptographyException(
          'Failed to decrypt with key ID ${entry.key}: ${e.toString()}',
          operation: 'decrypt',
          algorithm: 'AES-256-GCM',
        );
      }
    }

    return Result.err(
      lastError ??
          const CryptographyException(
            'No valid keys found for decryption',
            operation: 'decrypt',
            algorithm: 'AES-256-GCM',
          ),
    );
  }

  /// Rotates the master encryption key (non-destructive)
  ///
  /// Creates a new key for future encryption while preserving
  /// all previous keys for decrypting existing data.
  /// This ensures no data loss during key rotation.
  Future<void> rotateMasterKey() async {
    final keyStorage = await _getKeyStorage();
    final newKeyId = keyStorage.currentKeyId + 1;
    final newKey = _cryptoService.generateMasterKey();

    // Add new key to storage
    keyStorage.keys[newKeyId] = base64Encode(newKey);
    final updatedStorage = _KeyStorage(
      currentKeyId: newKeyId,
      keys: keyStorage.keys,
    );

    await _secureStorageService.write(
      _masterKeysStorageKey,
      jsonEncode(updatedStorage.toJson()),
    );

    // Clear cached key and storage to force refresh
    _clearCachedKey();
    _cachedKeyStorage = null;
  }

  /// Checks if master keys exist in secure storage
  Future<bool> hasMasterKey() async {
    final storedData = await _secureStorageService.read(_masterKeysStorageKey);
    return storedData != null;
  }

  /// Gets the current key ID being used for encryption
  Future<int> getCurrentKeyId() async {
    final keyStorage = await _getKeyStorage();
    return keyStorage.currentKeyId;
  }

  /// Gets all available key IDs
  Future<List<int>> getAvailableKeyIds() async {
    final keyStorage = await _getKeyStorage();
    return keyStorage.keys.keys.toList()..sort();
  }

  /// Clears the cached derived key from memory
  void _clearCachedKey() {
    if (_cachedDerivedKey != null) {
      // Securely zero the cached key
      for (var i = 0; i < _cachedDerivedKey!.length; i++) {
        _cachedDerivedKey![i] = 0;
      }
      _cachedDerivedKey = null;
      _cachedKeyId = null;
    }
  }

  /// Securely disposes of the service, clearing any cached keys
  void dispose() {
    _clearCachedKey();
    _cachedKeyStorage = null;
  }
}
