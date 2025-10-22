// EduLift - Centralized Hive Encryption Manager
// Provides a single source of truth for Hive encryption keys across all features

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import '../config/feature_flags.dart';
import '../utils/app_logger.dart';

/// Centralized manager for Hive encryption keys
///
/// This ensures all Hive boxes across the app use the same encryption key,
/// avoiding duplication and ensuring consistency.
///
/// **Development Mode:**
/// - When [FeatureFlags.useSecureStorage] is false (development environment),
///   uses in-memory encryption key instead of FlutterSecureStorage
/// - Avoids Linux keyring unlock issues during development
/// - Data is lost on app restart (acceptable in development)
class HiveEncryptionManager {
  // Singleton pattern
  static final HiveEncryptionManager _instance = HiveEncryptionManager._internal();
  factory HiveEncryptionManager() => _instance;
  HiveEncryptionManager._internal();

  // Encryption key storage
  List<int>? _encryptionKey;
  bool _initialized = false;

  // Secure storage instance (only used when FeatureFlags.useSecureStorage is true)
  static const _secureStorage = FlutterSecureStorage();
  static const _encryptionKeyName = 'hive_master_encryption_key';

  /// Get the encryption cipher for opening Hive boxes
  ///
  /// This method ensures the encryption key is initialized and returns
  /// a cipher that can be used with `Hive.openBox()`.
  ///
  /// Example:
  /// ```dart
  /// final cipher = await HiveEncryptionManager().getCipher();
  /// final box = await Hive.openBox('my_box', encryptionCipher: cipher);
  /// ```
  Future<HiveAesCipher> getCipher() async {
    await _ensureInitialized();
    return HiveAesCipher(_encryptionKey!);
  }

  /// Get the raw encryption key (for advanced use cases)
  Future<List<int>> getEncryptionKey() async {
    await _ensureInitialized();
    return _encryptionKey!;
  }

  /// Initialize or retrieve the encryption key
  Future<void> _ensureInitialized() async {
    if (_initialized && _encryptionKey != null) return;

    // In development mode, use in-memory key to avoid keyring issues
    if (!FeatureFlags.useSecureStorage) {
      AppLogger.warning(
        '🔓 HiveEncryptionManager: Using in-memory encryption key (development mode)',
      );
      _encryptionKey = Hive.generateSecureKey();
      _initialized = true;
      return;
    }

    // Production mode: use secure storage
    try {
      final keyString = await _secureStorage.read(key: _encryptionKeyName);

      if (keyString == null) {
        // Generate new encryption key
        final key = Hive.generateSecureKey();
        await _secureStorage.write(
          key: _encryptionKeyName,
          value: base64Encode(key),
        );
        _encryptionKey = key;
        AppLogger.info('🔐 HiveEncryptionManager: Generated new secure encryption key');
      } else {
        // Use existing key
        _encryptionKey = base64Decode(keyString);
        AppLogger.info('🔐 HiveEncryptionManager: Loaded existing encryption key from secure storage');
      }

      _initialized = true;
    } catch (e) {
      // Fallback to in-memory key if secure storage fails
      AppLogger.error(
        '❌ HiveEncryptionManager: Secure storage failed, falling back to in-memory key: $e',
      );
      _encryptionKey = Hive.generateSecureKey();
      _initialized = true;
    }
  }

  /// Reset the encryption key (for testing or key rotation)
  ///
  /// WARNING: This will make all existing encrypted data unreadable.
  /// Only use this if you're prepared to lose all cached data.
  Future<void> resetEncryptionKey() async {
    if (FeatureFlags.useSecureStorage) {
      await _secureStorage.delete(key: _encryptionKeyName);
    }
    _encryptionKey = null;
    _initialized = false;
    AppLogger.warning('🔄 HiveEncryptionManager: Encryption key reset');
  }

  /// Check if the encryption manager is initialized
  bool get isInitialized => _initialized && _encryptionKey != null;
}
