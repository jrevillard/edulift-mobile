import '../utils/result.dart';
import '../errors/failures.dart';
import '../services/adaptive_storage_service.dart';
import '../utils/app_logger.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Authentication entity for user profile storage
class AuthUserProfile {
  final String id;
  final String email;
  final String name;
  final String? familyId;
  final String role;
  final DateTime lastUpdated;
  final String? timezone;

  const AuthUserProfile({
    required this.id,
    required this.email,
    required this.name,
    this.familyId,
    required this.role,
    required this.lastUpdated,
    this.timezone,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'familyId': familyId,
    'role': role,
    'lastUpdated': lastUpdated.toIso8601String(),
    'timezone': timezone,
  };

  factory AuthUserProfile.fromJson(Map<String, dynamic> json) =>
      AuthUserProfile(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String,
        familyId: json['familyId'] as String?,
        role: json['role'] as String,
        lastUpdated: DateTime.parse(json['lastUpdated'] as String),
        timezone: json['timezone'] as String?,
      );
}

/// Authentication state for session management
class AuthState {
  final bool isAuthenticated;
  final bool biometricEnabled;
  final DateTime? lastAuthTime;
  final String? sessionId;

  const AuthState({
    required this.isAuthenticated,
    required this.biometricEnabled,
    this.lastAuthTime,
    this.sessionId,
  });

  Map<String, dynamic> toJson() => {
    'isAuthenticated': isAuthenticated,
    'biometricEnabled': biometricEnabled,
    'lastAuthTime': lastAuthTime?.toIso8601String(),
    'sessionId': sessionId,
  };

  factory AuthState.fromJson(Map<String, dynamic> json) => AuthState(
    isAuthenticated: json['isAuthenticated'],
    biometricEnabled: json['biometricEnabled'],
    lastAuthTime: json['lastAuthTime'] != null
        ? DateTime.parse(json['lastAuthTime'])
        : null,
    sessionId: json['sessionId'],
  );
}

/// Interface for authentication local data source operations
///
/// Provides secure storage for authentication tokens, user profiles, and session state.
/// Uses Result pattern for type-safe error handling without throwing exceptions.
abstract class IAuthLocalDatasource {
  // Token Management (Single Token Architecture)
  Future<Result<void, ApiFailure>> saveToken(String token);
  Future<Result<String?, ApiFailure>> getToken();

  // User Profile Management
  Future<Result<void, ApiFailure>> saveUserProfile(AuthUserProfile profile);
  Future<Result<AuthUserProfile?, ApiFailure>> getUserProfile();

  // Session & State Management
  Future<Result<void, ApiFailure>> saveAuthState(AuthState state);
  Future<Result<AuthState?, ApiFailure>> getAuthState();
  Future<Result<void, ApiFailure>> clearSession();

  // Maintenance Operations
  Future<Result<void, ApiFailure>> cleanupExpiredTokens();
  Future<Result<bool, ApiFailure>> isStorageHealthy();

  // Convenience methods for AuthService compatibility
  Future<Result<void, ApiFailure>> storeToken(String token);
  Future<Result<void, ApiFailure>> storeUserData(dynamic user);

  // PHASE 2: Refresh Token Support
  Future<Result<void, ApiFailure>> storeTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  });
  Future<Result<String?, ApiFailure>> getRefreshToken();
  Future<Result<DateTime?, ApiFailure>> getTokenExpiry();
  Future<Result<void, ApiFailure>> clearTokens();

  // PKCE Support for Magic Link Security
  Future<Result<void, ApiFailure>> storePKCEVerifier(String codeVerifier);
  Future<Result<String?, ApiFailure>> getPKCEVerifier();
  Future<Result<void, ApiFailure>> clearPKCEVerifier();

  // CRITICAL SECURITY: Magic Link Email Validation Support
  // Prevents cross-user token usage attacks
  Future<Result<void, ApiFailure>> storeMagicLinkEmail(String email);
  Future<Result<String?, ApiFailure>> getMagicLinkEmail();
  Future<Result<void, ApiFailure>> clearMagicLinkEmail();

  Future<Result<void, ApiFailure>> clearToken();
  Future<Result<void, ApiFailure>> clearUserData();
}

/// Implementation of authentication local data source using secure storage
///
/// Provides isolated auth domain storage following the Strangler Fig pattern.
/// Uses encrypted secure storage for sensitive authentication data.

class AuthLocalDatasource implements IAuthLocalDatasource {
  final AdaptiveStorageService _secureStorage;

  // Storage keys for auth data - MUST match AdaptiveStorageService keys!
  // Token key reserved for future use
  // static const String _tokenKey = AppConstants.tokenKey;
  // REFRESH TOKEN SUPPORT: Separate keys for access and refresh tokens
  static const String _refreshTokenKey = 'refresh_token_key';
  static const String _refreshTokenKeyDev = 'refresh_token_key_dev';
  static const String _tokenExpiresAtKey = 'token_expires_at';
  static const String _userProfileKey = 'auth_user_profile';
  static const String _authStateKey = 'auth_state';
  static const String _tokenTimestampKey = 'auth_token_timestamp';
  static const String _healthCheckKey = 'auth_health_check';
  static const String _pkceVerifierKey = 'pkce_code_verifier';
  static const String _magicLinkEmailKey = 'magic_link_email';

  AuthLocalDatasource(this._secureStorage);

  @override
  Future<Result<void, ApiFailure>> saveToken(String token) async {
    // CRITICAL: Never store empty tokens
    if (token.trim().isEmpty) {
      AppLogger.error('❌ Attempted to store empty token');
      return Result.err(
        ApiFailure.validationError(message: 'Cannot store empty access token'),
      );
    }

    final preview = token.length <= 20 ? token : '${token.substring(0, 20)}...';
    AppLogger.debug('💾 Storing token: $preview (${token.length} chars)');

    try {
      // Use storeToken method which handles dev suffix properly!
      await _secureStorage.storeToken(token);
      // Store timestamp for expiration tracking
      await _secureStorage.write(
        _tokenTimestampKey,
        DateTime.now().millisecondsSinceEpoch.toString(),
      );
      return const Result.ok(null);
    } catch (e) {
      return Result.err(
        ApiFailure.cacheError(message: 'Failed to save access token: $e'),
      );
    }
  }

  @override
  Future<Result<String?, ApiFailure>> getToken() async {
    try {
      // Use getToken method which handles dev suffix properly!
      final token = await _secureStorage.getToken();
      return Result.ok(token);
    } catch (e) {
      return Result.err(
        ApiFailure.cacheError(message: 'Failed to retrieve token: $e'),
      );
    }
  }

  // ========== REFRESH TOKEN SUPPORT (Phase 2) ==========

  /// Store access token, refresh token, and expiration time together
  /// This is the primary method for storing authentication tokens with refresh support
  @override
  Future<Result<void, ApiFailure>> storeTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) async {
    // CRITICAL: Never store empty tokens
    if (accessToken.trim().isEmpty) {
      AppLogger.error('❌ Attempted to store empty access token');
      return Result.err(
        ApiFailure.validationError(message: 'Cannot store empty access token'),
      );
    }
    if (refreshToken.trim().isEmpty) {
      AppLogger.error('❌ Attempted to store empty refresh token');
      return Result.err(
        ApiFailure.validationError(message: 'Cannot store empty refresh token'),
      );
    }

    try {
      // 1. Store access token using existing method
      await _secureStorage.storeToken(accessToken);

      // 2. Store refresh token separately (with encryption in production)
      if (kReleaseMode) {
        // Production: store encrypted refresh token
        await _secureStorage.store(_refreshTokenKey, refreshToken);
        AppLogger.info('🔒 Stored encrypted refresh token in production mode');
      } else {
        // Development: store plain refresh token for debugging
        await _secureStorage.write(_refreshTokenKeyDev, refreshToken);
        AppLogger.info('🔓 Stored plain refresh token in development mode');
      }

      // 3. Store expiration time
      await _secureStorage.write(
        _tokenExpiresAtKey,
        expiresAt.toIso8601String(),
      );

      AppLogger.info('✅ Successfully stored access token, refresh token, and expiration');
      return const Result.ok(null);
    } catch (e) {
      AppLogger.error('❌ Failed to store tokens: $e');
      return Result.err(
        ApiFailure.cacheError(
          message: 'Failed to store authentication tokens: $e',
        ),
      );
    }
  }

  /// Get the stored refresh token
  @override
  Future<Result<String?, ApiFailure>> getRefreshToken() async {
    try {
      String? refreshToken;

      if (kReleaseMode) {
        // Production: read encrypted refresh token
        refreshToken = await _secureStorage.read(_refreshTokenKey);
        if (refreshToken != null) {
          AppLogger.info('🔒 Retrieved encrypted refresh token from production storage');
        }
      } else {
        // Development: read plain refresh token
        refreshToken = await _secureStorage.read(_refreshTokenKeyDev);
        if (refreshToken != null) {
          AppLogger.info('🔓 Retrieved plain refresh token from development storage');
        }
      }

      return Result.ok(refreshToken);
    } catch (e) {
      AppLogger.error('❌ Failed to retrieve refresh token: $e');
      return Result.err(
        ApiFailure.cacheError(
          message: 'Failed to retrieve refresh token: $e',
        ),
      );
    }
  }

  /// Get the token expiration time
  @override
  Future<Result<DateTime?, ApiFailure>> getTokenExpiry() async {
    try {
      final expiryStr = await _secureStorage.read(_tokenExpiresAtKey);

      if (expiryStr == null) {
        return const Result.ok(null);
      }

      final expiresAt = DateTime.parse(expiryStr);
      return Result.ok(expiresAt);
    } catch (e) {
      AppLogger.error('❌ Failed to parse token expiry: $e');
      return Result.err(
        ApiFailure.parseError(
          details: 'Failed to parse token expiry: $e',
        ),
      );
    }
  }

  /// Clear all tokens (access token, refresh token, and expiration)
  /// This should be called during logout or when tokens are invalid
  @override
  Future<Result<void, ApiFailure>> clearTokens() async {
    try {
      // Clear access token using existing method
      await _secureStorage.clearToken();

      // Clear refresh token (both dev and prod keys to be safe)
      await _secureStorage.delete(_refreshTokenKey);
      await _secureStorage.delete(_refreshTokenKeyDev);

      // Clear expiration
      await _secureStorage.delete(_tokenExpiresAtKey);

      // Also clear the timestamp
      await _secureStorage.delete(_tokenTimestampKey);

      AppLogger.info('✅ Successfully cleared all authentication tokens');
      return const Result.ok(null);
    } catch (e) {
      AppLogger.error('❌ Failed to clear tokens: $e');
      return Result.err(
        ApiFailure.cacheError(
          message: 'Failed to clear authentication tokens: $e',
        ),
      );
    }
  }

  @override
  Future<Result<void, ApiFailure>> saveUserProfile(
    AuthUserProfile profile,
  ) async {
    try {
      final profileJson = jsonEncode(profile.toJson());
      await _secureStorage.write(_userProfileKey, profileJson);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(
        ApiFailure.cacheError(message: 'Failed to save user profile: $e'),
      );
    }
  }

  @override
  Future<Result<AuthUserProfile?, ApiFailure>> getUserProfile() async {
    try {
      final profileJson = await _secureStorage.read(_userProfileKey);
      if (profileJson == null) {
        return const Result.ok(null);
      }

      final profileMap = jsonDecode(profileJson) as Map<String, dynamic>;
      final profile = AuthUserProfile.fromJson(profileMap);
      return Result.ok(profile);
    } catch (e) {
      return Result.err(
        ApiFailure.parseError(details: 'Failed to parse user profile: $e'),
      );
    }
  }

  @override
  Future<Result<void, ApiFailure>> saveAuthState(AuthState state) async {
    try {
      final stateJson = jsonEncode(state.toJson());
      await _secureStorage.write(_authStateKey, stateJson);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(
        ApiFailure.cacheError(message: 'Failed to save auth state: $e'),
      );
    }
  }

  @override
  Future<Result<AuthState?, ApiFailure>> getAuthState() async {
    try {
      final stateJson = await _secureStorage.read(_authStateKey);
      if (stateJson == null) {
        return const Result.ok(null);
      }

      final stateMap = jsonDecode(stateJson) as Map<String, dynamic>;
      final state = AuthState.fromJson(stateMap);
      return Result.ok(state);
    } catch (e) {
      return Result.err(
        ApiFailure.parseError(details: 'Failed to parse auth state: $e'),
      );
    }
  }

  @override
  Future<Result<void, ApiFailure>> clearSession() async {
    try {
      // Use clearToken method to handle dev suffix properly
      await _secureStorage.clearToken();
      await Future.wait([
        _secureStorage.delete(_userProfileKey),
        _secureStorage.delete(_authStateKey),
        _secureStorage.delete(_tokenTimestampKey),
      ]);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(
        ApiFailure.cacheError(message: 'Failed to clear session: $e'),
      );
    }
  }

  @override
  Future<Result<void, ApiFailure>> cleanupExpiredTokens() async {
    try {
      final timestampStr = await _secureStorage.read(_tokenTimestampKey);
      if (timestampStr == null) {
        return const Result.ok(null);
      }

      final timestamp = int.parse(timestampStr);
      final tokenTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();

      // Clear tokens older than 24 hours
      if (now.difference(tokenTime).inHours > 24) {
        await _secureStorage.clearToken();
        await _secureStorage.delete(_tokenTimestampKey);
      }

      return const Result.ok(null);
    } catch (e) {
      return Result.err(
        ApiFailure.cacheError(message: 'Failed to cleanup expired tokens: $e'),
      );
    }
  }

  @override
  Future<Result<bool, ApiFailure>> isStorageHealthy() async {
    try {
      const testValue = 'health_test';

      // Test write operation
      await _secureStorage.write(_healthCheckKey, testValue);

      // Test read operation
      final readValue = await _secureStorage.read(_healthCheckKey);

      // Test delete operation
      await _secureStorage.delete(_healthCheckKey);

      final isHealthy = readValue == testValue;
      return Result.ok(isHealthy);
    } catch (e) {
      return Result.err(
        ApiFailure.cacheError(message: 'Storage health check failed: $e'),
      );
    }
  }

  // AuthService compatibility
  @override
  Future<Result<void, ApiFailure>> storeToken(String token) async {
    return await saveToken(token);
  }

  @override
  Future<Result<void, ApiFailure>> clearToken() async {
    try {
      // Use clearToken method which handles dev suffix properly!
      await _secureStorage.clearToken();
      await _secureStorage.delete(_tokenTimestampKey);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(
        ApiFailure.cacheError(message: 'Failed to clear token: $e'),
      );
    }
  }

  @override
  Future<Result<void, ApiFailure>> storeUserData(dynamic user) async {
    try {
      if (user is AuthUserProfile) {
        return await saveUserProfile(user);
      } else {
        // Convert User entity to AuthUserProfile if needed
        // This is a simplified implementation for compatibility
        final profile = AuthUserProfile(
          id: user.id ?? 'unknown',
          email: user.email ?? '', // CRITICAL FIX: Use empty string instead of hardcoded email
          name: user.name ?? 'Unknown User',
          role: 'user',
          lastUpdated: DateTime.now(),
          timezone: user.timezone, // Persist timezone to cache
        );
        return await saveUserProfile(profile);
      }
    } catch (e) {
      return Result.err(
        ApiFailure.cacheError(message: 'Failed to store user data: $e'),
      );
    }
  }

  // Removed clearTokens - replaced with clearToken

  // ========== PKCE Support for Magic Link Security ==========
  
  @override
  Future<Result<void, ApiFailure>> storePKCEVerifier(String codeVerifier) async {
    try {
      AppLogger.info('🔐 PKCE: Storing code_verifier securely');
      await _secureStorage.write(_pkceVerifierKey, codeVerifier);
      return const Result.ok(null);
    } catch (error) {
      AppLogger.error('❌ PKCE: Failed to store code_verifier: $error');
      return Result.err(ApiFailure(
        message: 'Failed to store PKCE verifier',
        statusCode: 500,
        details: {'error': error.toString()},
      ));
    }
  }

  @override
  Future<Result<String?, ApiFailure>> getPKCEVerifier() async {
    try {
      final codeVerifier = await _secureStorage.read(_pkceVerifierKey);
      if (codeVerifier != null) {
        AppLogger.info('🔐 PKCE: Retrieved code_verifier from secure storage');
      }
      return Result.ok(codeVerifier);
    } catch (error) {
      AppLogger.error('❌ PKCE: Failed to retrieve code_verifier: $error');
      return Result.err(ApiFailure(
        message: 'Failed to retrieve PKCE verifier',
        statusCode: 500,
        details: {'error': error.toString()},
      ));
    }
  }

  @override
  Future<Result<void, ApiFailure>> clearPKCEVerifier() async {
    try {
      AppLogger.info('🔐 PKCE: Clearing code_verifier from secure storage');
      await _secureStorage.delete(_pkceVerifierKey);
      return const Result.ok(null);
    } catch (error) {
      AppLogger.error('❌ PKCE: Failed to clear code_verifier: $error');
      return Result.err(ApiFailure(
        message: 'Failed to clear PKCE verifier',
        statusCode: 500,
        details: {'error': error.toString()},
      ));
    }
  }

  // ========== CRITICAL SECURITY: Magic Link Email Validation ==========

  @override
  Future<Result<void, ApiFailure>> storeMagicLinkEmail(String email) async {
    try {
      AppLogger.info('🔐 SECURITY: Storing magic link original email securely');
      await _secureStorage.write(_magicLinkEmailKey, email);
      return const Result.ok(null);
    } catch (error) {
      AppLogger.error('❌ SECURITY: Failed to store magic link email: $error');
      return Result.err(ApiFailure(
        message: 'Failed to store magic link email',
        statusCode: 500,
        details: {'error': error.toString()},
      ));
    }
  }

  @override
  Future<Result<String?, ApiFailure>> getMagicLinkEmail() async {
    try {
      final email = await _secureStorage.read(_magicLinkEmailKey);
      if (email != null) {
        AppLogger.info('🔐 SECURITY: Retrieved magic link original email from secure storage');
      }
      return Result.ok(email);
    } catch (error) {
      AppLogger.error('❌ SECURITY: Failed to retrieve magic link email: $error');
      return Result.err(ApiFailure(
        message: 'Failed to retrieve magic link email',
        statusCode: 500,
        details: {'error': error.toString()},
      ));
    }
  }

  @override
  Future<Result<void, ApiFailure>> clearMagicLinkEmail() async {
    try {
      AppLogger.info('🔐 SECURITY: Clearing magic link email from secure storage');
      await _secureStorage.delete(_magicLinkEmailKey);
      return const Result.ok(null);
    } catch (error) {
      AppLogger.error('❌ SECURITY: Failed to clear magic link email: $error');
      return Result.err(ApiFailure(
        message: 'Failed to clear magic link email',
        statusCode: 500,
        details: {'error': error.toString()},
      ));
    }
  }

  @override
  Future<Result<void, ApiFailure>> clearUserData() async {
    try {
      await Future.wait([
        _secureStorage.delete(_userProfileKey),
        _secureStorage.delete(_authStateKey),
        // CRITICAL SECURITY: Also clear magic link email on user data clear
        _secureStorage.delete(_magicLinkEmailKey),
      ]);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(
        ApiFailure.cacheError(message: 'Failed to clear user data: $e'),
      );
    }
  }
}
