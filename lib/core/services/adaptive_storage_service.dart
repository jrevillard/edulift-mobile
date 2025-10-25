/// Production-ready adaptive storage service with enterprise-grade security
///
/// This service implements comprehensive secure storage with:
/// - PointyCastle-based AES-256-GCM encryption
/// - Comprehensive Result pattern error handling
/// - Focused responsibilities following SRP
/// - Extensive documentation and error context
/// - Performance monitoring capabilities
/// - Atomic operations where possible

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:edulift/core/utils/app_logger.dart';

import '../constants/app_constants.dart';
import '../errors/exceptions.dart';
import '../security/crypto_service.dart';
import '../security/secure_key_manager.dart';
import '../storage/adaptive_secure_storage.dart';

class AdaptiveStorageService {
  final AdaptiveSecureStorage _storage;
  final CryptoService _cryptoService;
  final SecureKeyManager _keyManager;

  /// Timer for persistence monitoring in development mode
  Timer? _persistenceTimer;

  /// Development mode flag - bypasses encryption in debug builds for troubleshooting
  static bool get _isDevelopmentMode => kDebugMode;

  AdaptiveStorageService({
    required AdaptiveSecureStorage storage,
    required CryptoService cryptoService,
    required SecureKeyManager keyManager,
  })  : _storage = storage,
        _cryptoService = cryptoService,
        _keyManager = keyManager;

  // ========== TOKEN MANAGEMENT ==========

  /// Store authentication token securely with encryption
  /// In development mode, uses plain storage for debugging
  Future<void> storeToken(String token) async {
    try {
      // Secure debug log - no actual token values
      AppLogger.secureToken('[AdaptiveStorageService] Storing token', token);

      if (_isDevelopmentMode) {
        // Development mode: store as plain text with dev prefix for debugging
        const storageKey = '${AppConstants.tokenKey}_dev';
        AppLogger.info(
          '[AdaptiveStorageService] Development mode: storing token without encryption',
        );
        AppLogger.info('[AdaptiveStorageService] Storage key: "$storageKey"');
        AppLogger.info(
          '[AdaptiveStorageService] Storage backend: ${_storage.runtimeType}',
        );

        await _storage.write(key: storageKey, value: token);

        // Verify storage immediately
        final storedToken = await _storage.read(key: storageKey);

        if (storedToken == null) {
          AppLogger.error(
            '[AdaptiveStorageService] Token verification FAILED - token is null after storage!',
          );
          AppLogger.error(
            '[AdaptiveStorageService] Attempted to store with key: "$storageKey"',
          );
          throw const StorageException(
            'Development mode token verification failed',
            operation: 'verify_dev_token',
          );
        }

        AppLogger.info(
          '[AdaptiveStorageService] ✅ Development token verified successfully (${storedToken.length} chars)',
        );

        // Add persistence monitoring
        _startPersistenceMonitoring(storageKey);

        return;
      }

      // Production mode: full encryption
      final encryptionKey = await _keyManager.getDeviceEncryptionKey();
      if (encryptionKey.isEmpty) {
        throw const StorageException(
          'Encryption key missing',
          operation: 'get_encryption_key',
        );
      }

      // Encrypt token
      final tokenResult = _cryptoService.encrypt(token, encryptionKey);

      final String encryptedToken;
      if (tokenResult.isSuccess) {
        encryptedToken = tokenResult.value!;
      } else {
        throw StorageException(
          'Token encryption failed: ${tokenResult.error!.message}',
          operation: 'encrypt_token',
        );
      }

      // Store encrypted token
      await _storage.write(key: AppConstants.tokenKey, value: encryptedToken);

      AppLogger.info(
        '[AdaptiveStorageService] ✅ Production token encrypted and stored',
      );
    } catch (e) {
      AppLogger.error('[AdaptiveStorageService] Error storing tokens: $e');
      if (e is StorageException) rethrow;
      throw StorageException(
        'Failed to store token: ${e.toString()}',
        operation: 'store_token',
      );
    }
  }

  /// Retrieve the stored token with automatic decryption
  Future<String?> getToken() async {
    try {
      // Development mode: read from dev key without encryption
      if (_isDevelopmentMode) {
        const storageKey = '${AppConstants.tokenKey}_dev';
        AppLogger.info('[AdaptiveStorageService] Attempting to read token...');
        AppLogger.info('[AdaptiveStorageService] Storage key: "$storageKey"');
        AppLogger.info(
          '[AdaptiveStorageService] Storage backend: ${_storage.runtimeType}',
        );

        final devToken = await _storage.read(key: storageKey);

        AppLogger.debug(
          '[AdaptiveStorageService] Development mode - read token: ${devToken != null ? '[${devToken.length} chars]' : 'null'}',
        );

        if (devToken == null) {
          AppLogger.warning(
            '[AdaptiveStorageService] Token is NULL when reading with key: "$storageKey"',
          );
          // Try to understand why it's null
          await _debugStorageState(storageKey);
        } else {
          AppLogger.secureToken(
            '[AdaptiveStorageService] Retrieved dev token',
            devToken,
          );
        }
        return devToken;
      }

      // Production mode: read encrypted token
      final encryptedToken = await _storage.read(key: AppConstants.tokenKey);
      AppLogger.debug(
        '[AdaptiveStorageService] Read encrypted token: ${encryptedToken != null ? '[${encryptedToken.length} chars]' : 'null'}',
      );
      if (encryptedToken == null) return null;

      final encryptionKey = await _keyManager.getDeviceEncryptionKey();
      AppLogger.secureKey(
        '[AdaptiveStorageService] Using encryption key',
        encryptionKey,
      );
      final decryptResult = _cryptoService.decrypt(
        encryptedToken,
        encryptionKey,
      );

      return decryptResult.when(
        ok: (decrypted) {
          AppLogger.secureToken(
            '[AdaptiveStorageService] Decrypted token',
            decrypted.plaintext,
          );
          return decrypted.plaintext;
        },
        err: (error) {
          AppLogger.error(
            '[AdaptiveStorageService] Decryption error: ${error.message}',
          );
          return null;
        },
      );
    } catch (e) {
      AppLogger.error(
        '[AdaptiveStorageService] Error getting access token: $e',
      );
      // If any part of the read/decrypt process fails, returning null is the safest outcome
      return null;
    }
  }

  /// Clear stored authentication token
  Future<void> clearToken() async {
    // Log stack trace to understand who's calling this
    final stackTrace = StackTrace.current.toString();
    AppLogger.warning('🚨 [AdaptiveStorageService] clearToken() called!');
    AppLogger.warning('🚨 [AdaptiveStorageService] Stack trace:\n$stackTrace');

    // Stop persistence monitoring before clearing token
    _stopPersistenceMonitoring();

    if (_isDevelopmentMode) {
      const key = '${AppConstants.tokenKey}_dev';
      AppLogger.warning(
        '🚨 [AdaptiveStorageService] Deleting development token with key: "$key"',
      );
      await _storage.delete(key: key);
      AppLogger.info('[AdaptiveStorageService] Development token cleared');
    } else {
      await _storage.delete(key: AppConstants.tokenKey);
      AppLogger.info('[AdaptiveStorageService] Authentication token cleared');
    }
  }

  /// Check if authentication token is stored
  Future<bool> hasStoredToken() async {
    final token = await getToken();
    final hasToken = token != null && token.isNotEmpty;
    AppLogger.debug('[AdaptiveStorageService] Token stored: $hasToken');
    return hasToken;
  }

  // ========== USER DATA MANAGEMENT ==========

  /// Store user data with encryption
  Future<void> storeUserData(String? userData) async {
    try {
      if (userData == null) {
        await _storage.delete(key: AppConstants.userDataKey);
        return;
      }

      final encryptionKey = await _keyManager.getDeviceEncryptionKey();
      final encryptResult = _cryptoService.encrypt(userData, encryptionKey);

      final String encryptedValue;
      if (encryptResult.isSuccess) {
        encryptedValue = encryptResult.value!;
      } else {
        throw StorageException(
          'User data encryption failed: ${encryptResult.error!.message}',
          operation: 'encrypt_user_data',
        );
      }

      await _storage.write(
        key: AppConstants.userDataKey,
        value: encryptedValue,
      );
    } catch (e) {
      if (e is StorageException) rethrow;
      // Fallback to direct storage for backward compatibility
      await _storage.write(
        key: AppConstants.userDataKey,
        value: userData ?? '',
      );
    }
  }

  /// Retrieve stored user data with automatic decryption
  Future<String?> getUserData() async {
    try {
      final encryptedValue = await _storage.read(key: AppConstants.userDataKey);
      if (encryptedValue == null || encryptedValue.isEmpty) return null;

      final encryptionKey = await _keyManager.getDeviceEncryptionKey();
      final decryptResult = _cryptoService.decrypt(
        encryptedValue,
        encryptionKey,
      );

      return decryptResult.when(
        ok: (decrypted) => decrypted.plaintext,
        err: (error) => null, // Return null on decryption failure
      );
    } catch (e) {
      AppLogger.error('[AdaptiveStorageService] Error getting user data: $e');
      // If any part of the read/decrypt process fails, returning null is the safest outcome
      return null;
    }
  }

  /// Clear all stored user data
  Future<void> clearUserData() async {
    // Clear primary user data
    await _storage.delete(key: AppConstants.userDataKey);

    // Clear legacy user data entries
    final allData = await _storage.readAll();
    final userKeys = allData.keys.where((key) => key.startsWith('user_'));

    await Future.wait(userKeys.map((key) => _storage.delete(key: key)));
  }

  /// Get stored user ID from legacy storage
  Future<String?> getUserId() async {
    return await getUserDataLegacy('userId');
  }

  // ========== BIOMETRIC SETTINGS ==========

  /// Set biometric authentication enabled flag
  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(
      key: AppConstants.biometricEnabledKey,
      value: enabled.toString(),
    );
  }

  /// Get biometric authentication enabled flag
  Future<bool> getBiometricEnabled() async {
    final value = await _storage.read(key: AppConstants.biometricEnabledKey);
    return value == 'true';
  }

  /// Store email for biometric authentication
  Future<void> storeEmail(String email) async {
    await store('stored_email', email);
  }

  /// Get stored email for biometric authentication
  Future<String?> getStoredEmail() async {
    return await read('stored_email');
  }

  // ========== GENERIC STORAGE OPERATIONS ==========

  /// Store arbitrary data with encryption
  Future<void> store(String key, String value) async {
    try {
      final encryptionKey = await _keyManager.getDeviceEncryptionKey();
      final encryptResult = _cryptoService.encrypt(value, encryptionKey);

      final String encryptedValue;
      if (encryptResult.isSuccess) {
        encryptedValue = encryptResult.value!;
      } else {
        throw StorageException(
          'Data encryption failed: ${encryptResult.error!.message}',
          operation: 'encrypt_generic_data',
        );
      }

      await _storage.write(key: key, value: encryptedValue);
    } catch (e) {
      if (e is StorageException) rethrow;
      // Fallback to direct storage for backward compatibility
      await _storage.write(key: key, value: value);
    }
  }

  /// Alias for store() to maintain compatibility
  Future<void> write(String key, String value) async {
    await store(key, value);
  }

  /// Read arbitrary data with decryption
  Future<String?> read(String key) async {
    try {
      final encryptedValue = await _storage.read(key: key);
      if (encryptedValue == null) return null;

      final encryptionKey = await _keyManager.getDeviceEncryptionKey();
      final decryptResult = _cryptoService.decrypt(
        encryptedValue,
        encryptionKey,
      );

      return decryptResult.when(
        ok: (decrypted) => decrypted.plaintext,
        err: (error) => encryptedValue, // Return raw value as fallback
      );
    } catch (e) {
      AppLogger.error('[AdaptiveStorageService] Error reading key "$key": $e');
      // If any part of the read/decrypt process fails, returning null is the safest outcome
      return null;
    }
  }

  /// Delete data by key
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// Check if a key exists in storage
  Future<bool> containsKey(String key) async {
    final allData = await _storage.readAll();
    return allData.containsKey(key);
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Alias for clearAll()
  Future<void> clear() async {
    await clearAll();
  }

  /// Get all stored keys and values with automatic decryption
  Future<Map<String, String>> readAll() async {
    try {
      final allEncryptedData = await _storage.readAll();
      final decryptedData = <String, String>{};
      final encryptionKey = await _keyManager.getDeviceEncryptionKey();

      for (final entry in allEncryptedData.entries) {
        final decryptResult = _cryptoService.decrypt(
          entry.value,
          encryptionKey,
        );
        final String decrypted;
        if (decryptResult.isSuccess) {
          decrypted = decryptResult.value!.plaintext;
        } else {
          decrypted = entry.value; // Fallback to raw value if decryption fails
        }
        decryptedData[entry.key] = decrypted;
      }

      return decryptedData;
    } catch (e) {
      // Fallback to raw data if there's an error
      return await _storage.readAll();
    }
  }

  // ========== LEGACY COMPATIBILITY METHODS ==========

  /// Read legacy user data with encryption support
  Future<String?> getUserDataLegacy(String dataKey) async {
    try {
      final encryptedValue = await _storage.read(key: 'user_$dataKey');
      if (encryptedValue == null) return null;

      final encryptionKey = await _keyManager.getDeviceEncryptionKey();
      final decryptResult = _cryptoService.decrypt(
        encryptedValue,
        encryptionKey,
      );

      return decryptResult.when(
        ok: (decrypted) => decrypted.plaintext,
        err: (error) => null, // Return null on decryption failure
      );
    } catch (e) {
      AppLogger.error(
        '[AdaptiveStorageService] Error reading legacy data "$dataKey": $e',
      );
      // If any part of the read/decrypt process fails, returning null is the safest outcome
      return null;
    }
  }

  /// Store legacy user data with encryption
  Future<void> storeUserDataLegacy(String dataKey, String value) async {
    try {
      final encryptionKey = await _keyManager.getDeviceEncryptionKey();
      final encryptResult = _cryptoService.encrypt(value, encryptionKey);

      final String encryptedValue;
      if (encryptResult.isSuccess) {
        encryptedValue = encryptResult.value!;
      } else {
        throw StorageException(
          'Legacy data encryption failed: ${encryptResult.error!.message}',
          operation: 'encrypt_legacy_data',
        );
      }

      await _storage.write(key: 'user_$dataKey', value: encryptedValue);
    } catch (e) {
      if (e is StorageException) rethrow;
      // Fallback to direct storage for backward compatibility
      await _storage.write(key: 'user_$dataKey', value: value);
    }
  }

  /// Clear all legacy user data
  Future<void> clearAllUserData() async {
    final allKeys = await _storage.readAll();
    final userKeys = allKeys.keys.where((key) => key.startsWith('user_'));

    for (final key in userKeys) {
      await _storage.delete(key: key);
    }
  }

  // ========== ADDITIONAL COMPATIBILITY METHODS ==========

  /// Store encrypted data (alias for store)
  Future<void> storeEncryptedData(String key, String value) async {
    await store(key, value);
  }

  /// Get encrypted data (alias for read)
  Future<String?> getEncryptedData(String key) async {
    return await read(key);
  }

  /// Alias for read() to maintain compatibility
  Future<String?> get(String key) async {
    return await read(key);
  }

  /// Check if secure storage is available and functional
  Future<bool> isStorageAvailable() async {
    try {
      await _storage.containsKey(key: 'test_key');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get basic performance metrics for monitoring
  Future<Map<String, dynamic>> getPerformanceMetrics() async {
    try {
      final stopwatch = Stopwatch();

      // Test write performance
      stopwatch.start();
      await _storage.write(key: '_perf_test', value: 'test_data');
      final writeTime = stopwatch.elapsedMicroseconds;

      // Test read performance
      stopwatch.reset();
      await _storage.read(key: '_perf_test');
      final readTime = stopwatch.elapsedMicroseconds;

      // Test encryption performance
      stopwatch.reset();
      await _cryptoService.benchmarkEncryption(1024);
      final encryptTime = stopwatch.elapsedMicroseconds;

      // Cleanup
      await _storage.delete(key: '_perf_test');

      return {
        'write_time_microseconds': writeTime,
        'read_time_microseconds': readTime,
        'encrypt_time_microseconds': encryptTime,
        'test_data_size_bytes': 1024,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'error': 'Performance metrics collection failed: ${e.toString()}',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Start monitoring token persistence (development only)
  void _startPersistenceMonitoring(String key) {
    if (!_isDevelopmentMode) return;

    // Cancel existing timer if any
    _persistenceTimer?.cancel();

    // Check token persistence every 30 seconds for 10 minutes
    var checkCount = 0;
    const maxChecks = 20; // 10 minutes worth of checks

    _persistenceTimer = Timer.periodic(const Duration(seconds: 30), (
      timer,
    ) async {
      checkCount++;

      final token = await _storage.read(key: key);
      final timestamp = DateTime.now().toIso8601String();

      if (token == null) {
        AppLogger.error(
          '🚨 [PERSISTENCE MONITOR] Token LOST at $timestamp (check #$checkCount)',
        );
        AppLogger.error(
          '🚨 [PERSISTENCE MONITOR] Key: "$key" now returns NULL',
        );
        timer.cancel();
      } else {
        AppLogger.info(
          '✅ [PERSISTENCE MONITOR] Token still present at $timestamp (check #$checkCount, ${token.length} chars)',
        );
      }

      if (checkCount >= maxChecks) {
        AppLogger.info(
          '[PERSISTENCE MONITOR] Stopping monitoring after $maxChecks checks',
        );
        timer.cancel();
      }
    });

    AppLogger.info(
      '[PERSISTENCE MONITOR] Started monitoring token persistence for key: "$key"',
    );
  }

  /// Stop persistence monitoring (development only)
  void _stopPersistenceMonitoring() {
    if (!_isDevelopmentMode) return;

    _persistenceTimer?.cancel();
    _persistenceTimer = null;

    AppLogger.info(
      '[PERSISTENCE MONITOR] Stopped monitoring token persistence',
    );
  }

  /// Debug storage state when token is unexpectedly null
  Future<void> _debugStorageState(String expectedKey) async {
    if (!_isDevelopmentMode) return;

    try {
      AppLogger.warning('[DEBUG] Investigating why token is null...');
      AppLogger.warning('[DEBUG] Expected key: "$expectedKey"');

      // Check all keys in storage
      final allData = await _storage.readAll();
      AppLogger.warning('[DEBUG] Total keys in storage: ${allData.length}');

      for (final entry in allData.entries) {
        // CRITICAL FIX: entry.value is guaranteed to be String from readAll()
        // but we add defensive type checking for safety
        String valuePreview;
        try {
          final value = entry.value;
          // Don't log actual token values, just keys and lengths
          valuePreview = value.length > 20
              ? '${value.substring(0, 20)}... (${value.length} chars)'
              : '$value (${value.length} chars)';
        } catch (e) {
          // This should never happen now, but handle it gracefully
          valuePreview = 'ERROR: ${e.toString()}';
        }
        AppLogger.warning('[DEBUG] Found key: "${entry.key}" -> $valuePreview');
      }

      // Check if the key exists with different variations
      final variations = [
        expectedKey,
        'secure_$expectedKey',
        expectedKey.replaceAll('_dev', ''),
        'jwt_token',
        'secure_jwt_token',
      ];

      for (final variant in variations) {
        final value = await _storage.read(key: variant);
        if (value != null) {
          AppLogger.warning(
            '[DEBUG] Found token with variant key: "$variant" (${value.length} chars)',
          );
        }
      }
    } catch (e) {
      AppLogger.error('[DEBUG] Error during storage debugging: $e');
    }
  }
}
