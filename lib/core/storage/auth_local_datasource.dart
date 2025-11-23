import '../utils/result.dart';
import '../errors/failures.dart';
import '../security/tiered_storage_service.dart';
import '../utils/app_logger.dart';
import 'dart:convert';

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
  final TieredStorageService _storage;

  // Storage keys for auth data (only custom keys, TieredStorageService handles built-in keys)
  static const String _tokenExpiresAtKey = 'token_expires_at';
  static const String _userProfileKey = 'auth_user_profile';
  static const String _authStateKey = 'auth_state';
  static const String _tokenTimestampKey = 'auth_token_timestamp';
  static const String _healthCheckKey = 'auth_health_check';

  AuthLocalDatasource(this._storage);

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
      // Store access token with MEDIUM sensitivity (short-lived)
      await _storage.storeAccessToken(token);
      // Store timestamp for expiration tracking with LOW sensitivity (metadata)
      await _storage.store(
        _tokenTimestampKey,
        DateTime.now().millisecondsSinceEpoch.toString(),
        DataSensitivity.low,
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
      // Retrieve access token with MEDIUM sensitivity
      final token = await _storage.getAccessToken();
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
      // 1. Store access token with MEDIUM sensitivity (short-lived)
      await _storage.storeAccessToken(accessToken);

      // 2. Store refresh token with HIGH sensitivity (long-lived, can mint new tokens)
      await _storage.storeRefreshToken(refreshToken);
      AppLogger.info('🔒 Stored refresh token with HIGH sensitivity');

      // 3. Store expiration time with LOW sensitivity (metadata)
      await _storage.store(
        _tokenExpiresAtKey,
        expiresAt.toIso8601String(),
        DataSensitivity.low,
      );

      AppLogger.info(
        '✅ Successfully stored access token, refresh token, and expiration',
      );
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
      // Retrieve refresh token with HIGH sensitivity
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken != null) {
        AppLogger.info(
          '🔒 Retrieved refresh token with HIGH sensitivity from secure storage',
        );
      }
      return Result.ok(refreshToken);
    } catch (e) {
      AppLogger.error('❌ Failed to retrieve refresh token: $e');
      return Result.err(
        ApiFailure.cacheError(message: 'Failed to retrieve refresh token: $e'),
      );
    }
  }

  /// Get the token expiration time
  @override
  Future<Result<DateTime?, ApiFailure>> getTokenExpiry() async {
    try {
      // Retrieve expiration time with LOW sensitivity (metadata)
      final expiryStr = await _storage.read(
        _tokenExpiresAtKey,
        DataSensitivity.low,
      );

      if (expiryStr == null) {
        return const Result.ok(null);
      }

      final expiresAt = DateTime.parse(expiryStr);
      return Result.ok(expiresAt);
    } catch (e) {
      AppLogger.error('❌ Failed to parse token expiry: $e');
      return Result.err(
        ApiFailure.parseError(details: 'Failed to parse token expiry: $e'),
      );
    }
  }

  /// Clear all tokens (access token, refresh token, and expiration)
  /// This should be called during logout or when tokens are invalid
  @override
  Future<Result<void, ApiFailure>> clearTokens() async {
    try {
      // Use the convenience method to clear all auth data at once
      await _storage.clearAuthData();

      // Also clear our custom metadata keys
      await _storage.delete(_tokenExpiresAtKey, DataSensitivity.low);
      await _storage.delete(_tokenTimestampKey, DataSensitivity.low);

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
      // Store user profile with MEDIUM sensitivity (contains PII)
      await _storage.store(
        _userProfileKey,
        profileJson,
        DataSensitivity.medium,
      );
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
      // Retrieve user profile with MEDIUM sensitivity (contains PII)
      final profileJson = await _storage.read(
        _userProfileKey,
        DataSensitivity.medium,
      );
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
      // Store auth state with MEDIUM sensitivity (session data)
      await _storage.store(_authStateKey, stateJson, DataSensitivity.medium);
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
      // Retrieve auth state with MEDIUM sensitivity (session data)
      final stateJson = await _storage.read(
        _authStateKey,
        DataSensitivity.medium,
      );
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
      // Clear all authentication-related data
      await _storage.clearAuthData();

      // Clear additional session data with appropriate sensitivity levels
      await Future.wait([
        _storage.delete(_userProfileKey, DataSensitivity.medium),
        _storage.delete(_authStateKey, DataSensitivity.medium),
        _storage.delete(_tokenTimestampKey, DataSensitivity.low),
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
      // Retrieve timestamp with LOW sensitivity (metadata)
      final timestampStr = await _storage.read(
        _tokenTimestampKey,
        DataSensitivity.low,
      );
      if (timestampStr == null) {
        return const Result.ok(null);
      }

      final timestamp = int.parse(timestampStr);
      final tokenTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();

      // Clear tokens older than 24 hours
      if (now.difference(tokenTime).inHours > 24) {
        await _storage.clearAuthData();
        await _storage.delete(_tokenTimestampKey, DataSensitivity.low);
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

      // Test write operation with LOW sensitivity (temporary test data)
      await _storage.store(_healthCheckKey, testValue, DataSensitivity.low);

      // Test read operation with LOW sensitivity
      final readValue = await _storage.read(
        _healthCheckKey,
        DataSensitivity.low,
      );

      // Test delete operation with LOW sensitivity
      await _storage.delete(_healthCheckKey, DataSensitivity.low);

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
      // Clear access token using convenience method
      await _storage.delete('access_token', DataSensitivity.medium);
      // Clear timestamp metadata
      await _storage.delete(_tokenTimestampKey, DataSensitivity.low);
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
          email:
              user.email ??
              '', // CRITICAL FIX: Use empty string instead of hardcoded email
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
  Future<Result<void, ApiFailure>> storePKCEVerifier(
    String codeVerifier,
  ) async {
    try {
      AppLogger.info(
        '🔐 PKCE: Storing code_verifier with LOW sensitivity (ephemeral)',
      );
      // Store PKCE verifier with LOW sensitivity (temporary, single-use, no encryption needed)
      await _storage.storePkceVerifier(codeVerifier);
      return const Result.ok(null);
    } catch (error) {
      AppLogger.error('❌ PKCE: Failed to store code_verifier: $error');
      return Result.err(
        ApiFailure(
          message: 'Failed to store PKCE verifier',
          statusCode: 500,
          details: {'error': error.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<String?, ApiFailure>> getPKCEVerifier() async {
    try {
      // Retrieve PKCE verifier with LOW sensitivity (ephemeral)
      final codeVerifier = await _storage.getPkceVerifier();
      if (codeVerifier != null) {
        AppLogger.info(
          '🔐 PKCE: Retrieved code_verifier from storage (LOW sensitivity)',
        );
      }
      return Result.ok(codeVerifier);
    } catch (error) {
      AppLogger.error('❌ PKCE: Failed to retrieve code_verifier: $error');
      return Result.err(
        ApiFailure(
          message: 'Failed to retrieve PKCE verifier',
          statusCode: 500,
          details: {'error': error.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<void, ApiFailure>> clearPKCEVerifier() async {
    try {
      AppLogger.info(
        '🔐 PKCE: Clearing code_verifier from storage (LOW sensitivity)',
      );
      // Use convenience method to clear PKCE verifier
      await _storage.clearPkceVerifier();
      return const Result.ok(null);
    } catch (error) {
      AppLogger.error('❌ PKCE: Failed to clear code_verifier: $error');
      return Result.err(
        ApiFailure(
          message: 'Failed to clear PKCE verifier',
          statusCode: 500,
          details: {'error': error.toString()},
        ),
      );
    }
  }

  // ========== CRITICAL SECURITY: Magic Link Email Validation ==========

  @override
  Future<Result<void, ApiFailure>> storeMagicLinkEmail(String email) async {
    try {
      AppLogger.info(
        '🔐 SECURITY: Storing magic link original email with LOW sensitivity (temporary)',
      );
      // Store magic link email with LOW sensitivity (temporary validation data)
      await _storage.storeMagicLinkEmail(email);
      return const Result.ok(null);
    } catch (error) {
      AppLogger.error('❌ SECURITY: Failed to store magic link email: $error');
      return Result.err(
        ApiFailure(
          message: 'Failed to store magic link email',
          statusCode: 500,
          details: {'error': error.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<String?, ApiFailure>> getMagicLinkEmail() async {
    try {
      // Retrieve magic link email with LOW sensitivity (temporary validation data)
      final email = await _storage.getMagicLinkEmail();
      if (email != null) {
        AppLogger.info(
          '🔐 SECURITY: Retrieved magic link original email from storage (LOW sensitivity)',
        );
      }
      return Result.ok(email);
    } catch (error) {
      AppLogger.error(
        '❌ SECURITY: Failed to retrieve magic link email: $error',
      );
      return Result.err(
        ApiFailure(
          message: 'Failed to retrieve magic link email',
          statusCode: 500,
          details: {'error': error.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<void, ApiFailure>> clearMagicLinkEmail() async {
    try {
      AppLogger.info(
        '🔐 SECURITY: Clearing magic link email from storage (LOW sensitivity)',
      );
      // Use convenience method to clear magic link email
      await _storage.clearMagicLinkEmail();
      return const Result.ok(null);
    } catch (error) {
      AppLogger.error('❌ SECURITY: Failed to clear magic link email: $error');
      return Result.err(
        ApiFailure(
          message: 'Failed to clear magic link email',
          statusCode: 500,
          details: {'error': error.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<void, ApiFailure>> clearUserData() async {
    try {
      await Future.wait([
        _storage.delete(_userProfileKey, DataSensitivity.medium),
        _storage.delete(_authStateKey, DataSensitivity.medium),
        // CRITICAL SECURITY: Also clear magic link email on user data clear
        _storage.clearMagicLinkEmail(),
      ]);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(
        ApiFailure.cacheError(message: 'Failed to clear user data: $e'),
      );
    }
  }
}
