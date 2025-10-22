// EduLift Mobile - Secure Token Storage Implementation (Infrastructure Layer)
// Concrete implementation of TokenStorage using AdaptiveSecureStorage

import 'package:flutter/foundation.dart';
import '../../core/utils/app_logger.dart';
import '../../core/constants/app_constants.dart';
import '../storage/adaptive_secure_storage.dart';
import '../../core/interfaces/token_storage_interface.dart';

/// Secure token storage implementation using AdaptiveSecureStorage

class SecureTokenStorage implements TokenStorageInterface {
  final AdaptiveSecureStorage _secureStorage;

  /// Development mode flag - matches AdaptiveStorageService behavior
  static bool get _isDevelopmentMode => kDebugMode;

  /// Get storage key with development mode suffix for consistency with AdaptiveStorageService
  static String get _tokenKey => _isDevelopmentMode
      ? '${AppConstants.tokenKey}_dev'
      : AppConstants.tokenKey;

  SecureTokenStorage(this._secureStorage);

  @override
  Future<void> storeToken(String token) async {
    try {
      AppLogger.info('🔐 Storing authentication token securely...');
      AppLogger.info('🔑 Using storage key: "${_tokenKey}"');
      await _secureStorage.write(key: _tokenKey, value: token);
      AppLogger.info('✅ Token stored successfully');
    } catch (e) {
      AppLogger.error('❌ Failed to store token securely: $e');
      throw Exception('Failed to store authentication token: $e');
    }
  }

  /// Retrieve the stored authentication token
  @override
  Future<String?> getToken() async {
    try {
      AppLogger.info('🔍 Retrieving authentication token...');
      AppLogger.info('🔑 Using storage key: "${_tokenKey}"');
      final token = await _secureStorage.read(key: _tokenKey);
      if (token != null) {
        AppLogger.info(
          '✅ Token retrieved successfully (${token.length} chars)',
        );
      } else {
        AppLogger.warning(
          '❌ No token found in storage with key: "${_tokenKey}"',
        );
      }
      return token;
    } catch (e) {
      AppLogger.error('❌ Failed to retrieve token: $e');
      return null;
    }
  }

  /// Remove the stored authentication token
  @override
  Future<void> clearToken() async {
    try {
      AppLogger.info('🗑️ Clearing authentication token...');
      AppLogger.info('🔑 Using storage key: "${_tokenKey}"');
      await _secureStorage.delete(key: _tokenKey);
      AppLogger.info('✅ Token cleared successfully');
    } catch (e) {
      AppLogger.error('❌ Failed to clear token: $e');
      throw Exception('Failed to clear authentication token: $e');
    }
  }

  /// Check if a token exists in storage
  @override
  Future<bool> hasToken() async {
    try {
      AppLogger.info('🔍 Checking if token exists...');
      AppLogger.info('🔑 Using storage key: "${_tokenKey}"');
      final token = await _secureStorage.read(key: _tokenKey);
      final hasToken = token != null && token.isNotEmpty;
      AppLogger.info('${hasToken ? "✅" : "❌"} Token exists: $hasToken');
      return hasToken;
    } catch (e) {
      AppLogger.error('❌ Failed to check token existence: $e');
      return false;
    }
  }
}
