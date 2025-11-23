/// EduLift Mobile - Tiered Storage Service
/// STATE-OF-THE-ART 2024-2025 Flutter Secure Storage Architecture
///
/// Based on professional security best practices:
/// - Tiered data classification (High/Medium/Low sensitivity)
/// - Hardware-backed encryption via Android Keystore / iOS Keychain
/// - NO custom PBKDF2 for platform-secured storage (redundant)
/// - SharedPreferences for ephemeral, non-sensitive data
///
/// References:
/// - OWASP Mobile Security Testing Guide
/// - Android Keystore Best Practices
/// - Apple Keychain Services Documentation

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

/// Data sensitivity levels for tiered storage
///
/// Each tier uses appropriate storage mechanism based on security requirements:
/// - [high]: Hardware-backed secure storage (Keystore/Keychain)
/// - [medium]: Hardware-backed secure storage (same as high, kept for semantic clarity)
/// - [low]: SharedPreferences (no encryption overhead)
enum DataSensitivity {
  /// HIGH SENSITIVITY - Maximum protection
  ///
  /// Use for:
  /// - Refresh tokens (long-lived, can mint new access tokens)
  /// - Master encryption keys
  /// - Biometric credentials
  /// - API keys
  ///
  /// Storage: flutter_secure_storage (Keystore/Keychain)
  /// Performance: 10-50ms read/write
  high,

  /// MEDIUM SENSITIVITY - Standard protection
  ///
  /// Use for:
  /// - Access tokens (short-lived)
  /// - User preferences containing PII
  /// - Session identifiers
  ///
  /// Storage: flutter_secure_storage (same as high)
  /// Performance: 10-50ms read/write
  medium,

  /// LOW SENSITIVITY - No encryption needed
  ///
  /// Use for:
  /// - PKCE code verifiers (ephemeral, single-use, cryptographically random)
  /// - OAuth state parameters (CSRF tokens, not secrets)
  /// - Magic link validation emails (temporary)
  /// - Non-PII app state
  /// - UI preferences
  ///
  /// Storage: SharedPreferences (no encryption)
  /// Performance: ~1ms read/write
  low,
}

/// Professional tiered storage service for Flutter applications
///
/// This service implements the industry-standard approach to mobile data storage:
/// 1. Delegates key management to platform security (Keystore/Keychain)
/// 2. Uses appropriate storage tier based on data sensitivity
/// 3. Avoids redundant application-level encryption for platform-secured data
///
/// Example usage:
/// ```dart
/// // Via Riverpod provider (recommended)
/// final storage = ref.watch(tieredStorageServiceProvider);
/// await storage.initialize();
///
/// // Store refresh token (high sensitivity)
/// await storage.store('refresh_token', token, DataSensitivity.high);
///
/// // Store PKCE verifier (low sensitivity - ephemeral)
/// await storage.store('pkce_verifier', verifier, DataSensitivity.low);
/// ```
class TieredStorageService {
  /// Hardware-backed secure storage (Android Keystore / iOS Keychain)
  late final FlutterSecureStorage _secureStorage;

  /// Standard preferences for non-sensitive data
  SharedPreferences? _sharedPrefs;

  /// Initialization state
  bool _isInitialized = false;

  /// Public constructor for dependency injection
  ///
  /// Creates a new instance with proper secure storage configuration.
  /// Use via Riverpod provider for proper DI management.
  TieredStorageService() {
    _secureStorage = const FlutterSecureStorage(
      // STATE-OF-THE-ART: flutter_secure_storage uses EncryptedSharedPreferences
      // by default on Android (hardware-backed Keystore) - NO custom PBKDF2 needed!
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    );
  }

  /// Initialize the storage service
  ///
  /// Must be called before using the service. Safe to call multiple times.
  Future<void> initialize() async {
    if (_isInitialized) return;

    _sharedPrefs = await SharedPreferences.getInstance();
    _isInitialized = true;

    AppLogger.info(
      '🔐 TieredStorageService initialized - '
      'Hardware-backed secure storage + SharedPreferences ready',
    );
  }

  /// Ensure service is initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'TieredStorageService not initialized. Call initialize() first.',
      );
    }
  }

  /// Store data with appropriate security level
  ///
  /// [key] - Storage key
  /// [value] - Value to store
  /// [sensitivity] - Data sensitivity level determining storage mechanism
  ///
  /// Performance:
  /// - High/Medium: 10-50ms (hardware-backed encryption)
  /// - Low: ~1ms (no encryption)
  Future<void> store(
    String key,
    String value,
    DataSensitivity sensitivity,
  ) async {
    _ensureInitialized();

    switch (sensitivity) {
      case DataSensitivity.high:
      case DataSensitivity.medium:
        // Hardware-backed secure storage (Keystore/Keychain)
        // NO additional encryption needed - platform handles it
        await _secureStorage.write(key: key, value: value);
        AppLogger.debug(
          '🔐 Stored [${sensitivity.name}] data: $key (secure storage)',
        );
        break;

      case DataSensitivity.low:
        // Plain SharedPreferences - fast, no encryption overhead
        await _sharedPrefs!.setString(key, value);
        AppLogger.debug(
          '📝 Stored [${sensitivity.name}] data: $key (shared prefs)',
        );
        break;
    }
  }

  /// Read data from appropriate storage tier
  ///
  /// [key] - Storage key
  /// [sensitivity] - Data sensitivity level (must match how it was stored)
  ///
  /// Returns null if key doesn't exist
  Future<String?> read(String key, DataSensitivity sensitivity) async {
    _ensureInitialized();

    switch (sensitivity) {
      case DataSensitivity.high:
      case DataSensitivity.medium:
        return await _secureStorage.read(key: key);

      case DataSensitivity.low:
        return _sharedPrefs!.getString(key);
    }
  }

  /// Delete data from appropriate storage tier
  ///
  /// [key] - Storage key
  /// [sensitivity] - Data sensitivity level (must match how it was stored)
  Future<void> delete(String key, DataSensitivity sensitivity) async {
    _ensureInitialized();

    switch (sensitivity) {
      case DataSensitivity.high:
      case DataSensitivity.medium:
        await _secureStorage.delete(key: key);
        AppLogger.debug('🗑️ Deleted [${sensitivity.name}] data: $key');
        break;

      case DataSensitivity.low:
        await _sharedPrefs!.remove(key);
        AppLogger.debug('🗑️ Deleted [${sensitivity.name}] data: $key');
        break;
    }
  }

  /// Check if a key exists in the appropriate storage tier
  Future<bool> containsKey(String key, DataSensitivity sensitivity) async {
    _ensureInitialized();

    switch (sensitivity) {
      case DataSensitivity.high:
      case DataSensitivity.medium:
        return await _secureStorage.containsKey(key: key);

      case DataSensitivity.low:
        return _sharedPrefs!.containsKey(key);
    }
  }

  /// Clear all data from a specific sensitivity tier
  ///
  /// Use with caution - this deletes ALL data in the tier
  Future<void> clearTier(DataSensitivity sensitivity) async {
    _ensureInitialized();

    switch (sensitivity) {
      case DataSensitivity.high:
      case DataSensitivity.medium:
        await _secureStorage.deleteAll();
        AppLogger.warning('⚠️ Cleared all secure storage data');
        break;

      case DataSensitivity.low:
        await _sharedPrefs!.clear();
        AppLogger.warning('⚠️ Cleared all shared preferences');
        break;
    }
  }

  // ============================================================
  // CONVENIENCE METHODS FOR COMMON DATA TYPES
  // ============================================================

  /// Store refresh token (HIGH sensitivity)
  Future<void> storeRefreshToken(String token) async {
    await store('refresh_token', token, DataSensitivity.high);
  }

  /// Read refresh token
  Future<String?> getRefreshToken() async {
    return await read('refresh_token', DataSensitivity.high);
  }

  /// Store access token (MEDIUM sensitivity - short-lived)
  Future<void> storeAccessToken(String token) async {
    await store('access_token', token, DataSensitivity.medium);
  }

  /// Read access token
  Future<String?> getAccessToken() async {
    return await read('access_token', DataSensitivity.medium);
  }

  /// Store PKCE verifier (LOW sensitivity - ephemeral, single-use)
  Future<void> storePkceVerifier(String verifier) async {
    await store('pkce_verifier', verifier, DataSensitivity.low);
  }

  /// Read PKCE verifier
  Future<String?> getPkceVerifier() async {
    return await read('pkce_verifier', DataSensitivity.low);
  }

  /// Clear PKCE verifier
  Future<void> clearPkceVerifier() async {
    await delete('pkce_verifier', DataSensitivity.low);
  }

  /// Store OAuth state (LOW sensitivity - CSRF token, not a secret)
  Future<void> storeOAuthState(String state) async {
    await store('oauth_state', state, DataSensitivity.low);
  }

  /// Read OAuth state
  Future<String?> getOAuthState() async {
    return await read('oauth_state', DataSensitivity.low);
  }

  /// Store magic link email for validation (LOW sensitivity - temporary)
  Future<void> storeMagicLinkEmail(String email) async {
    await store('magic_link_email', email, DataSensitivity.low);
  }

  /// Read magic link email
  Future<String?> getMagicLinkEmail() async {
    return await read('magic_link_email', DataSensitivity.low);
  }

  /// Clear magic link email
  Future<void> clearMagicLinkEmail() async {
    await delete('magic_link_email', DataSensitivity.low);
  }

  /// Clear all authentication-related data (for logout)
  Future<void> clearAuthData() async {
    await delete('refresh_token', DataSensitivity.high);
    await delete('access_token', DataSensitivity.medium);
    await delete('pkce_verifier', DataSensitivity.low);
    await delete('oauth_state', DataSensitivity.low);
    await delete('magic_link_email', DataSensitivity.low);
    AppLogger.info('🔓 Cleared all authentication data');
  }
}
