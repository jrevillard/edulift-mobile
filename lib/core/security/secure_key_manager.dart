// EduLift Mobile - Secure Key Manager
// SECURITY FIX: Implements device-specific secure key generation and storage

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import '../storage/secure_storage.dart';

/// Manages secure encryption keys for the application
/// Replaces hard-coded encryption key with device-specific secure keys
/// PERFORMANCE CRITICAL: Caches encryption key in memory to avoid repeated storage reads

class SecureKeyManager {
  static const String _keyStorageKey = 'edulift_device_encryption_key';
  final SecureStorage _secureStorage;

  /// PERFORMANCE: Cache encryption key in memory to avoid 50+ second storage reads
  Uint8List? _cachedKey;

  /// Constructor requiring SecureStorage dependency
  SecureKeyManager(this._secureStorage);

  /// Get or generate a secure encryption key for this device
  /// Returns a 32-byte key suitable for AES-256 encryption
  /// PERFORMANCE CRITICAL: Uses in-memory cache to eliminate repeated storage reads
  Future<Uint8List> getDeviceEncryptionKey() async {
    // PERFORMANCE: Return cached key instantly if available (eliminates 50+ second delays)
    if (_cachedKey != null) {
      return _cachedKey!;
    }

    try {
      // Only read from storage once per app session
      final existingKey = await _secureStorage.read(key: _keyStorageKey);
      if (existingKey != null) {
        _cachedKey = base64Decode(existingKey);
        return _cachedKey!;
      }

      // Generate new secure key
      final newKey = _generateSecureKey();

      // Store securely in device keystore/keychain
      await _secureStorage.write(
        key: _keyStorageKey,
        value: base64Encode(newKey),
      );

      // Cache the new key for instant future access
      _cachedKey = newKey;
      return newKey;
    } catch (e) {
      // Fallback: generate session key (not persisted)
      // This ensures the app continues to work even if secure storage fails
      final fallbackKey = _generateSecureKey();
      _cachedKey = fallbackKey; // Cache fallback key too
      return fallbackKey;
    }
  }

  /// Generate a cryptographically secure 32-byte key
  Uint8List _generateSecureKey() {
    final random = Random.secure();
    final keyBytes = Uint8List(32); // 256 bits for AES-256

    for (var i = 0; i < keyBytes.length; i++) {
      keyBytes[i] = random.nextInt(256);
    }

    return keyBytes;
  }

  /// Clear the stored encryption key (for logout/reset scenarios)
  /// PERFORMANCE: Also clears cached key to ensure clean state
  Future<void> clearStoredKey() async {
    try {
      await _secureStorage.delete(key: _keyStorageKey);
    } catch (e) {
      // Ignore errors during cleanup
    }
    // PERFORMANCE: Clear cache to ensure consistent state
    _cachedKey = null;
  }

  /// Verify if a secure key exists
  Future<bool> hasStoredKey() async {
    try {
      final key = await _secureStorage.read(key: _keyStorageKey);
      return key != null;
    } catch (e) {
      return false;
    }
  }
}
