import 'dart:async';
import 'package:edulift/core/utils/app_logger.dart';

import '../domain/entities/user.dart';
import '../errors/failures.dart';
import '../utils/result.dart';
import '../network/auth_api_client.dart';
import '../network/api_response_helper.dart';
import '../network/models/common/api_response_wrapper.dart';
import '../network/models/auth/auth_dto.dart';
import '../network/models/user/user_profile_dto.dart';
import '../network/requests/auth_requests.dart';
import '../storage/auth_local_datasource.dart';
import '../utils/secure_date_parser.dart';
import '../utils/pkce_utils.dart';
import 'user_status_service.dart';
import '../domain/services/auth_service.dart';
import '../network/error_handler_service.dart';
import '../errors/api_exception.dart';

class AuthServiceImpl implements AuthService {
  final AuthApiClient _apiClient;
  final IAuthLocalDatasource _authLocalDatasource;
  final UserStatusService _userStatusService;
  final ErrorHandlerService _errorHandlerService;
  User? _currentUser;

  AuthServiceImpl(
    this._apiClient,
    this._authLocalDatasource,
    this._userStatusService,
    this._errorHandlerService,
  );

  @override
  Future<Result<void, Failure>> sendMagicLink(
    String email, {
    String? name,
    String? inviteCode,
  }) async {
    try {
      // Use UserStatusService to validate email format
      if (!_userStatusService.isValidEmail(email)) {
        return const Result.err(ValidationFailure(
            message: 'auth.errors.invalid_email',
            statusCode: 400,
            details: {'field': 'email'}));
      }

      // Generate PKCE pair for security
      AppLogger.info('🔐 PKCE: Generating PKCE pair for magic link request');
      final pkcePair = PKCEUtils.generatePKCEPair();
      final codeVerifier = pkcePair['code_verifier']!;
      final codeChallenge = pkcePair['code_challenge']!;
      final verifierPreview = codeVerifier.length > 20
          ? '${codeVerifier.substring(0, 20)}...'
          : codeVerifier;
      final challengePreview = codeChallenge.length > 20
          ? '${codeChallenge.substring(0, 20)}...'
          : codeChallenge;
      AppLogger.info(
        '🔐 PKCE: Generated code_verifier: $verifierPreview (${codeVerifier.length} chars)',
      );
      AppLogger.info(
        '🔐 PKCE: Generated code_challenge: $challengePreview (${codeChallenge.length} chars)',
      );
      // Store code_verifier locally for later verification
      AppLogger.info('🔐 PKCE: Storing code_verifier securely for later magic link verification');
      await _authLocalDatasource.storePKCEVerifier(codeVerifier);

      // CRITICAL SECURITY FIX: Store the email for magic link verification
      // This prevents cross-user token usage attacks
      AppLogger.info(
        '🔐 SECURITY: Storing original email for magic link security validation',
      );
      await _authLocalDatasource.storeMagicLinkEmail(email);
      final request = MagicLinkRequest(
        email: email,
        name: name,
        inviteCode: inviteCode,
        codeChallenge: codeChallenge,
      );

      // STATE-OF-THE-ART 2025 PATTERN: Explicit API response handling
      final response = await ApiResponseHelper.execute<String>(
        () => _apiClient.sendMagicLink(request),
      );

      // Explicit unwrap - clear, transparent, maintainable
      final result = response.unwrap();
      AppLogger.info('✅ Magic link sent successfully: $result');

      // Success response means magic link sent
      return const Result.ok(null);
    } catch (error, stackTrace) {
      // SURGICAL: Handle 422 magic link errors BEFORE ErrorHandlerService
      if (error is ApiException && error.statusCode == 422) {
        // Extract backend message directly to preserve "name is required for new users"
        final backendMessage = _extractBackendMessage(error);
        AppLogger.info('🔧 AUTH SPECIFIC: 422 error detected - message: $backendMessage');
        // Create ValidationFailure with preserved original message
        final validationFailure = ValidationFailure(
          message: backendMessage,
          statusCode: 422,
          details: {
            'original_message': backendMessage,
            'error_source': 'auth_magic_link',
            'preserve_backend_message': true
          },
        );
        return Result.err(validationFailure);
      }

      // GENERIC: Other errors go through normal ErrorHandlerService
      final context = ErrorContext.authOperation(
        'send_magic_link',
        metadata: {
          'email': email,
          'has_name': name != null,
          'has_invite': inviteCode != null
        },
      );
      final errorResult = await _errorHandlerService.handleError(
        error,
        context,
        stackTrace: stackTrace,
      );
      final failure = _convertToFailure(errorResult, error);
      return Result.err(failure);
    }
  }
  /// Extract original backend message for 422 magic link errors
  String _extractBackendMessage(ApiException apiException) {
    // Priority 1: Direct message from exception
    if (apiException.message.isNotEmpty) {
      return apiException.message;
    }

    // Priority 2: Message in details
    if (apiException.details != null) {
      final responseData = apiException.details!;
      final message = responseData['message'] ?? responseData['error'];
      if (message != null) return message.toString();
    }

    // Fallback
    return 'Validation error occurred';
  }
  /// Create User object from guaranteed backend data (fail-fast approach)
  /// CLEAN ARCHITECTURE: Auth domain only - no family data
  User _createUserFromBackendData(
    Map<String, dynamic> userData, {
    bool? overrideBiometric,
  }) {
    return User(
      // Backend guarantees these fields - fail fast if missing
      id: userData['id'] as String,
      email: userData['email'] as String,
      name: userData['name'] as String? ?? 'auth.errors.unknown_user',
      createdAt: SecureDateParser.safeParseWithFallback(
        userData['createdAt'] as String?
      ),
      updatedAt: SecureDateParser.safeParseWithFallback(
        userData['updatedAt'] as String?
      ),
      timezone: userData['timezone'] as String?,
      isBiometricEnabled:
          overrideBiometric ?? userData['isBiometricEnabled'] as bool? ?? false,
    );
  }

  /// Convert ErrorHandlingResult to appropriate Failure type for clean architecture compliance
  Failure _convertToFailure(
    ErrorHandlingResult errorResult,
    dynamic originalError,
  ) {
    final classification = errorResult.classification;
    final userMessage = errorResult.userMessage.messageKey;

    // Extract status code from original error if available
    int? statusCode;
    if (originalError is ApiFailure) {
      statusCode = originalError.statusCode;
    } else if (originalError is Failure) {
      statusCode = originalError.statusCode;
    }

    // Convert based on error category using proper failure types
    switch (classification.category) {
      case ErrorCategory.validation:
        return ValidationFailure(
          message: userMessage,
          statusCode: statusCode ?? 422,
          details: classification.analysisData,
        );
      case ErrorCategory.authentication:
        return AuthFailure(
          message: userMessage,
          statusCode: statusCode ?? 401,
          details: classification.analysisData,
        );
      case ErrorCategory.network:
        return NetworkFailure(
          message: userMessage,
          statusCode: statusCode ?? 0,
          details: classification.analysisData,
        );
      case ErrorCategory.server:
        return ServerFailure(
          message: userMessage,
          statusCode: statusCode ?? 500,
          details: classification.analysisData,
        );
      case ErrorCategory.authorization:
        return AuthFailure(
          message: userMessage,
          statusCode: statusCode ?? 403,
          details: classification.analysisData,
        );
      case ErrorCategory.storage:
        return StorageFailure(
          userMessage,
          operation: classification.analysisData['operation'] as String?,
          statusCode: statusCode,
          details: classification.analysisData,
        );
      case ErrorCategory.conflict:
        return ConflictFailure(
          message: userMessage,
          statusCode: statusCode ?? 409,
          details: classification.analysisData,
        );
      case ErrorCategory.offline:
        return OfflineFailure(
          message: userMessage,
          statusCode: statusCode ?? 0,
          details: classification.analysisData,
        );
      default:
        return UnexpectedFailure(
          userMessage,
          operation: classification.analysisData['operation'] as String?,
          statusCode: statusCode,
          details: classification.analysisData,
        );
    }
  }

  @override
  Future<Result<AuthResult, Failure>> authenticateWithVerifiedData({
    required String token,
    required String refreshToken,
    required int expiresIn,
    required Map<String, dynamic> userData,
  }) async {
    try {
      // PHASE 2: Store access token, refresh token, and expiration together
      final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
      final storeTokensResult = await _authLocalDatasource.storeTokens(
        accessToken: token,
        refreshToken: refreshToken,
        expiresAt: expiresAt,
      );
      if (storeTokensResult.isErr) {
        AppLogger.warning('⚠️ Warning: Failed to store authentication tokens locally: ${storeTokensResult.error}');
      } else {
        AppLogger.info('✅ Stored access token, refresh token (expires at: $expiresAt)');
      }

      // CLEAN ARCHITECTURE: Auth domain only handles authentication
      // Family data will be fetched by router/family domain after auth success
      final user = _createUserFromBackendData(userData);

      // Store user data
      final storeUserResult = await _authLocalDatasource.storeUserData(user);
      if (storeUserResult.isError) {
        AppLogger.warning('Warning: Failed to store user data locally: ${storeUserResult.error}');
      }

      _currentUser = user;
      AppLogger.info('✅ User authenticated successfully: ${user.email}');
      return Result.ok(AuthResult(user: user, token: token));
    } catch (error, stackTrace) {
      // PROPER ERROR HANDLING: Use ErrorHandlerService with auth context
      final context = ErrorContext.authOperation(
        'authenticate_with_verified_data',
        metadata: {
          'user_id': userData['id']?.toString(),
          'user_email': userData['email']?.toString(),
        },
      );
      final errorResult = await _errorHandlerService.handleError(
        error,
        context,
        stackTrace: stackTrace,
      );
      // Convert ErrorHandlingResult to appropriate Failure type
      final failure = _convertToFailure(errorResult, error);
      return Result.err(failure);
    }
  }

  @override
  Future<Result<AuthResult, Failure>> authenticateWithMagicLink(
    String token, {
    String? inviteCode,
  }) async {
    try {
      // CRITICAL SECURITY FIX: Retrieve the email that was used for magic link request
      // This prevents cross-user token usage vulnerability
      AppLogger.info('🔐 SECURITY: Starting magic link verification with cross-user protection');
      final storedEmailResult = await _authLocalDatasource.getMagicLinkEmail();
      String? originalEmail;
      if (storedEmailResult.isOk) {
        originalEmail = storedEmailResult.value;
        AppLogger.info('🔐 SECURITY: Retrieved original email: ${originalEmail?.substring(0, 3)}***');
      } else {
        AppLogger.warning('⚠️ SECURITY: No original email found - this could indicate token reuse or storage failure');
      }
      AppLogger.error(
        '❌ SECURITY: This will cause magic link verification to fail for security',
      );
      // Retrieve stored PKCE code_verifier for security validation
      AppLogger.info(
        '🔐 PKCE: Starting magic link verification - retrieving stored code_verifier',
      );
      final pkceResult = await _authLocalDatasource.getPKCEVerifier();
      String? codeVerifier;
      if (pkceResult.isOk) {
        codeVerifier = pkceResult.value;
        if (codeVerifier != null) {
          final preview = codeVerifier.length > 20
              ? '${codeVerifier.substring(0, 20)}...'
              : codeVerifier;
          AppLogger.info(
            '🔐 PKCE: Successfully retrieved code_verifier: $preview (${codeVerifier.length} chars)',
          );
        } else {
          AppLogger.warning('⚠️ PKCE: Retrieved code_verifier is NULL - this will cause backend validation failure');
        }
      }
      final request = VerifyTokenRequest(
        token: token,
        codeVerifier: codeVerifier,
        originalEmail: originalEmail,
      );

      if (codeVerifier != null) {
        AppLogger.info('🔐 PKCE: Sending magic link verification WITH code_verifier');
      } else {
        AppLogger.warning(
          '⚠️ PKCE: Sending magic link verification WITHOUT code_verifier',
        );
        AppLogger.warning('⚠️ PKCE: This could happen if:');
        AppLogger.warning(
          '⚠️ PKCE:   1. PKCE verifier was already cleared after successful use',
        );
        AppLogger.warning(
          '⚠️ PKCE:   2. PKCE verifier failed to store during magic link request',
        );
        AppLogger.warning(
          '⚠️ PKCE:   3. Magic link is being reused (security violation)',
        );
        AppLogger.warning('⚠️ PKCE:   4. Storage error occurred during retrieval');
        AppLogger.warning('⚠️ PKCE: Backend will likely reject this request');
      }

      if (originalEmail == null) {
        AppLogger.error('❌ SECURITY: Magic link verification blocked - no original email for validation');
        return Result.err(
          ApiFailure.badRequest(
            message:
                'Magic link security validation failed. Please request a new magic link.',
          ),
        );
      }

      // STATE-OF-THE-ART 2025 PATTERN: Explicit API response handling
      // CRITICAL: Pass inviteCode as query parameter to allow backend to process invitations
      final response = await ApiResponseHelper.execute<AuthDto>(() async {
        final result = await _apiClient.verifyMagicLink(request, inviteCode);
        return result;
      });

      // Explicit unwrap - clear, transparent, maintainable
      final authDto = response.unwrap();
      final authToken = authDto.accessToken;
      final userMap = authDto.user;
      final userData = {
        'id': userMap.id,
        'email': userMap.email,
        'name': userMap.name,
        'createdAt': userMap.createdAt,
        'updatedAt': userMap.updatedAt,
        'isBiometricEnabled': userMap.isBiometricEnabled,
      };

      // Map invitation result from DTO to domain model
      InvitationResult? invitationResult;
      if (authDto.invitationResult != null) {
        final dto = authDto.invitationResult!;
        invitationResult = InvitationResult(
          processed: dto.processed,
          invitationType: dto.invitationType,
          redirectUrl: dto.redirectUrl,
          requiresFamilyOnboarding: dto.requiresFamilyOnboarding,
          reason: dto.reason,
        );
        AppLogger.info('📨 Invitation result received from backend:');
        AppLogger.info('   - Processed: ${dto.processed}');
        AppLogger.info('   - Type: ${dto.invitationType}');
        AppLogger.info('   - Redirect: ${dto.redirectUrl}');
      }

      // CRITICAL SECURITY VALIDATION: Ensure the authenticated user email matches the original request
      final authenticatedEmail = userMap.email;
      if (authenticatedEmail.toLowerCase() != originalEmail.toLowerCase()) {
        AppLogger.error('❌ SECURITY VIOLATION: Cross-user magic link attack detected!');
        AppLogger.error(
          '❌ SECURITY: Original email: ${originalEmail.substring(0, 3)}***',
        );
        AppLogger.error(
          '❌ SECURITY: Authenticated email: ${authenticatedEmail.substring(0, 3)}***',
        );
        AppLogger.error('❌ SECURITY: Blocking authentication to prevent account takeover');
        // Clear all auth data and block the authentication
        await _authLocalDatasource.clearMagicLinkEmail();
        await _authLocalDatasource.clearPKCEVerifier();
        return Result.err(
          ApiFailure.badRequest(
            message:
                'Security validation failed: Token does not match original request. Please request a new magic link.',
          ),
        );
      }

      AppLogger.info('✅ SECURITY: Magic link email validation passed - original and authenticated emails match');
      AppLogger.info('✅ SECURITY: User authenticated successfully: ${authenticatedEmail.substring(0, 3)}***');
      // Clear the used PKCE verifier and magic link email for security
      AppLogger.info('🔐 SECURITY: Magic link verification successful - clearing used security data from storage');
      await _authLocalDatasource.clearPKCEVerifier();
      await _authLocalDatasource.clearMagicLinkEmail();
      AppLogger.info(
        '🔐 SECURITY: Successfully cleared used code_verifier and magic link email from storage',
      );

      // PHASE 2: Store access token, refresh token, and expiration together
      final expiresAt = DateTime.now().add(Duration(seconds: authDto.expiresIn));
      final storeTokensResult = await _authLocalDatasource.storeTokens(
        accessToken: authToken,
        refreshToken: authDto.refreshToken,
        expiresAt: expiresAt,
      );
      if (storeTokensResult.isErr) {
        AppLogger.warning('⚠️ Warning: Failed to store authentication tokens locally: ${storeTokensResult.error}');
      } else {
        AppLogger.info('✅ Stored access token, refresh token (expires at: $expiresAt)');
      }

      // CLEAN ARCHITECTURE: Auth domain only handles authentication
      // Family data will be fetched by router/family domain after auth success
      final user = _createUserFromBackendData(userData);

      // Store user data
      final storeUserResult = await _authLocalDatasource.storeUserData(user);
      if (storeUserResult.isError) {
        AppLogger.warning('Warning: Failed to store user data locally');
      }

      _currentUser = user;
      AppLogger.info('🔐 Magic link auth success - User: ${user.email}');
      return Result.ok(AuthResult(
        user: user,
        token: authToken,
        invitationResult: invitationResult,
      ));
    } catch (error, stackTrace) {
      // PROPER ERROR HANDLING: Use ErrorHandlerService with auth context
      final context = ErrorContext.authOperation(
        'authenticate_with_magic_link',
        metadata: {
          'has_invite_code': inviteCode != null,
          'token_length': token.length,
        },
      );
      final errorResult = await _errorHandlerService.handleError(
        error,
        context,
        stackTrace: stackTrace,
      );
      // Convert ErrorHandlingResult to appropriate Failure type
      final failure = _convertToFailure(errorResult, error);
      return Result.err(failure);
    }
  }

  @override
  Future<Result<User, Failure>> getCurrentUser({
    bool forceRefresh = false,
    Map<String, dynamic>? userData,
  }) async {
    try {
      // Only use cached user if not forcing refresh and cache exists
      if (!forceRefresh && _currentUser != null) {
        return Result.ok(_currentUser!);
      }

      Map<String, dynamic> userDataToUse;
      // CLEAN ARCHITECTURE: Use provided userData if available (from magic link verification)
      if (userData != null) {
        userDataToUse = userData;
        AppLogger.debug('✅ Using provided user data from magic link verification');
      } else {
        // Fallback: Try to get user from cached data
        final cachedUserResult = await _authLocalDatasource.getUserProfile();
        if (cachedUserResult.isSuccess && cachedUserResult.value != null) {
          final cachedUser = cachedUserResult.value!;
          userDataToUse = {
            'id': cachedUser.id,
            'email': cachedUser.email,
            'name': cachedUser.name,
            'createdAt': cachedUser.lastUpdated.toIso8601String(),
            'updatedAt': cachedUser.lastUpdated.toIso8601String(),
            'timezone': cachedUser.timezone, // Use cached timezone
            'isBiometricEnabled':
                false, // Default value since not stored in cached profile
          };
          AppLogger.debug('✅ Using cached user data');
        } else {
          // No cached user and no provided userData - this shouldn't happen in normal flow
          AppLogger.warning('❌ Missing user data: no cached user and no provided userData.');
          return Result.err(
            ApiFailure.badRequest(
              message: 'Missing user data for authentication',
            ),
          );
        }
      }

      // CLEAN ARCHITECTURE: Auth domain only handles USER authentication
      // Family data is handled separately by family domain
      final user = User(
        id: userDataToUse['id'] as String,
        email: userDataToUse['email'] as String,
        name: userDataToUse['name'] as String? ?? 'auth.errors.unknown_user',
        createdAt: SecureDateParser.safeParseWithFallback(userDataToUse['createdAt'] as String?),
        updatedAt: SecureDateParser.safeParseWithFallback(userDataToUse['updatedAt'] as String?),
        timezone: userDataToUse['timezone'] as String?,
        isBiometricEnabled:
            userDataToUse['isBiometricEnabled'] as bool? ?? false,
      );
      _currentUser = user;
      AppLogger.info('🔍 DEBUG: getCurrentUser() completed - User: ${user.email}');
      return Result.ok(user);
    } catch (error, stackTrace) {
      // PROPER ERROR HANDLING: Use ErrorHandlerService with auth context
      final context = ErrorContext.authOperation('get_current_user',
        metadata: {
          'force_refresh': forceRefresh,
          'has_provided_data': userData != null
        },
      );
      final errorResult = await _errorHandlerService.handleError(
        error,
        context,
        stackTrace: stackTrace,
      );
      // Convert ErrorHandlingResult to appropriate Failure type
      final failure = _convertToFailure(errorResult, error);
      return Result.err(failure);
    }
  }

  @override
  Future<Result<void, Failure>> storeToken(String token) async {
    try {
      final result = await _authLocalDatasource.storeToken(token);
      if (result.isOk) {
        return const Result.ok(null);
      } else {
        final failure = result.error!;
        return Result.err(failure);
      }
    } catch (e) {
      return Result.err(ApiFailure.cacheError(message: 'Failed to save access token'));
    }
  }

  @override
  Future<Result<void, Failure>> updateCurrentUser(User user) async {
    try {
      _currentUser = user;
      // Store user data locally using auth local datasource
      final result = await _authLocalDatasource.storeUserData(user);
      if (result.isOk) {
        return const Result.ok(null);
      } else {
        final failure = result.error!;
        return Result.err(failure);
      }
    } catch (e) {
      return Result.err(ApiFailure.cacheError(message: 'auth.errors.failed_update_user'));
    }
  }

  @override
  User? get currentUser => _currentUser;

  @override
  Future<Result<User, Failure>> enableBiometricAuth() async {
    try {
      // STATE-OF-THE-ART 2025 PATTERN: Explicit API response handling
      final response = await ApiResponseHelper.execute<UserProfileDto>(
        () => _apiClient.enableBiometricAuth({}),
      );
      // Explicit unwrap - clear, transparent, maintainable
      final userProfile = response.unwrap();
      final userData = {
        'id': userProfile.id,
        'email': userProfile.email,
        'name': userProfile.name,
        'createdAt': userProfile.createdAt.toIso8601String(),
        'updatedAt': userProfile.updatedAt.toIso8601String(),
        'isBiometricEnabled': true, // enabled
      };

      // CLEAN ARCHITECTURE: Auth domain only - no family logic
      // Create user from guaranteed backend data
      final updatedUser = _createUserFromBackendData(
        userData,
        overrideBiometric: true,
      );
      _currentUser = updatedUser;
      return Result.ok(updatedUser);
    } catch (error, stackTrace) {
      // PROPER ERROR HANDLING: Use ErrorHandlerService with auth context
      final context = ErrorContext.authOperation('enable_biometric_auth',
        metadata: {'user_id': _currentUser?.id},
      );
      final errorResult = await _errorHandlerService.handleError(
        error,
        context,
        stackTrace: stackTrace,
      );
      // Convert ErrorHandlingResult to appropriate Failure type
      final failure = _convertToFailure(errorResult, error);
      return Result.err(failure);
    }
  }

  @override
  Future<Result<User, Failure>> disableBiometricAuth() async {
    try {
      // STATE-OF-THE-ART 2025 PATTERN: Explicit API response handling
      final response = await ApiResponseHelper.execute<UserProfileDto>(
        () => _apiClient.disableBiometricAuth({}),
      );
      // Explicit unwrap - clear, transparent, maintainable
      final userProfile = response.unwrap();
      final userData = {
        'id': userProfile.id,
        'email': userProfile.email,
        'name': userProfile.name,
        'createdAt': userProfile.createdAt.toIso8601String(),
        'updatedAt': userProfile.updatedAt.toIso8601String(),
        'isBiometricEnabled': false, // disabled
      };

      // CLEAN ARCHITECTURE: Auth domain only - no family logic
      // Create user from guaranteed backend data
      final updatedUser = _createUserFromBackendData(
        userData,
        overrideBiometric: false,
      );
      _currentUser = updatedUser;
      return Result.ok(updatedUser);
    } catch (error, stackTrace) {
      // PROPER ERROR HANDLING: Use ErrorHandlerService with auth context
      final context = ErrorContext.authOperation('disable_biometric_auth',
        metadata: {'user_id': _currentUser?.id},
      );
      final errorResult = await _errorHandlerService.handleError(
        error,
        context,
        stackTrace: stackTrace,
      );
      // Convert ErrorHandlingResult to appropriate Failure type
      final failure = _convertToFailure(errorResult, error);
      return Result.err(failure);
    }
  }

  @override
  Future<Result<User, Failure>> updateUserTimezone(String timezone) async {
    try {
      // STATE-OF-THE-ART 2025 PATTERN: Explicit API response handling
      final request = UpdateProfileRequest(timezone: timezone);
      final response = await ApiResponseHelper.execute<UserProfileDto>(
        () => _apiClient.updateProfile(request),
      );
      // Explicit unwrap - clear, transparent, maintainable
      final userProfile = response.unwrap();
      final userData = {
        'id': userProfile.id,
        'email': userProfile.email,
        'name': userProfile.name,
        'createdAt': userProfile.createdAt.toIso8601String(),
        'updatedAt': userProfile.updatedAt.toIso8601String(),
        'timezone': userProfile.timezone,
        'isBiometricEnabled': _currentUser?.isBiometricEnabled ?? false,
      };

      // CLEAN ARCHITECTURE: Auth domain only - no family logic
      // Create user from guaranteed backend data
      final updatedUser = _createUserFromBackendData(userData);
      _currentUser = updatedUser;

      // Update cached profile with new timezone
      try {
        final cachedProfileResult = await _authLocalDatasource.getUserProfile();
        if (cachedProfileResult.isSuccess && cachedProfileResult.value != null) {
          final cachedProfile = cachedProfileResult.value!;
          final updatedProfile = AuthUserProfile(
            id: cachedProfile.id,
            email: cachedProfile.email,
            name: cachedProfile.name,
            familyId: cachedProfile.familyId,
            role: cachedProfile.role,
            lastUpdated: DateTime.now(),
            timezone: timezone, // Persist new timezone to cache
          );
          await _authLocalDatasource.saveUserProfile(updatedProfile);
          AppLogger.info('[AUTH] Updated cached profile with new timezone: $timezone');
        }
      } catch (e) {
        AppLogger.warning('[AUTH] Failed to update cached profile timezone', e);
        // Don't fail the whole operation if cache update fails
      }

      return Result.ok(updatedUser);
    } catch (error, stackTrace) {
      // PROPER ERROR HANDLING: Use ErrorHandlerService with auth context
      final context = ErrorContext.authOperation('update_user_timezone',
        metadata: {'user_id': _currentUser?.id, 'timezone': timezone},
      );
      final errorResult = await _errorHandlerService.handleError(
        error,
        context,
        stackTrace: stackTrace,
      );
      // Convert ErrorHandlingResult to appropriate Failure type
      final failure = _convertToFailure(errorResult, error);
      return Result.err(failure);
    }
  }

  /// Public method to handle token expiration - called by network interceptors
  /// This centralizes the token expiry logic and eliminates code duplication
  Future<void> handleTokenExpiry({String? reason}) async {
    AppLogger.warning('🚨 Token expired/invalid: ${reason ?? 'Unknown reason'}');
    AppLogger.info('Clearing all authentication data and triggering logout');
    // Use the existing centralized session clearing method
    await _clearLocalSession();
    AppLogger.info('✅ Token expiry handled - user will be redirected to login');
  }

  /// Private method to clear all local session data
  /// This eliminates code duplication across logout, clearSession, and clearUserData methods
  Future<void> _clearLocalSession({bool clearToken = true}) async {
    _currentUser = null;
    if (clearToken) {
      // PHASE 2: Clear all tokens (access, refresh, and expiration)
      final tokenResult = await _authLocalDatasource.clearTokens();
      // Log error but don't fail - continue with other cleanup
      if (tokenResult.isErr) {
        AppLogger.warning('Failed to clear tokens: ${tokenResult.error}');
      }
    }
    final userDataResult = await _authLocalDatasource.clearUserData();
    // Log error but don't fail - session cleanup should be as complete as possible
    if (userDataResult.isErr) {
      AppLogger.warning('Failed to clear user data: ${userDataResult.error}');
    }
  }

  @override
  Future<Result<void, Failure>> logout() async {
    try {
      // PHASE 2: Try to revoke tokens on backend first (with timeout)
      // This ensures refresh tokens are properly invalidated server-side
      try {
        final response = await ApiResponseHelper.execute<void>(
          () => _apiClient.logout(),
        ).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            AppLogger.warning('⚠️ [Auth] Backend logout timed out after 5s');
            throw TimeoutException('Backend logout timeout');
          },
        );
        response.unwrap();
        AppLogger.info('✅ [Auth] Backend tokens revoked successfully');
      } catch (e) {
        // Log but continue - local clear is more important for UX
        AppLogger.warning('⚠️ [Auth] Backend logout failed: $e');
        // Offline or network error: local logout still succeeds
      }

      // SECURITY-FIRST: Always clear local session regardless of backend result
      await _clearLocalSession();
      AppLogger.info('🔒 [Auth] Local session cleared successfully');

      return const Result.ok(null);
    } catch (e) {
      // Even if everything fails, try to clear local session
      try {
        await _clearLocalSession();
      } catch (clearError) {
        AppLogger.error('❌ [Auth] Failed to clear local session: $clearError');
      }
      return const Result.ok(null); // Always succeed for UX
    }
  }

  @override
  Future<Result<AuthResult, Failure>> authenticateWithBiometrics(
    String email,
  ) async {
    try {
      // Biometric authentication temporarily disabled during DI migration
      return const Result.err(AuthFailure(
          message: 'Biometric auth temporarily disabled during DI migration',
        ));
    } catch (e) {
      AppLogger.error('Biometric authentication failed: $e');
      return const Result.err(AuthFailure(message: 'auth.errors.biometric_auth_failed'));
    }
  }

  @override
  Future<Result<AuthUserProfile?, Failure>> getUserProfile() async {
    final result = await _authLocalDatasource.getUserProfile();
    if (result.isOk) {
      final profile = result.value;
      return Result.ok(profile);
    } else {
      final failure = result.error!;
      return Result.err(failure);
    }
  }

  @override
  Future<Result<void, Failure>> saveAuthState(AuthState state) async {
    final result = await _authLocalDatasource.saveAuthState(state);
    if (result.isOk) {
      return const Result.ok(null);
    } else {
      final failure = result.error!;
      return Result.err(failure);
    }
  }

  @override
  Future<Result<AuthState?, Failure>> getAuthState() async {
    final result = await _authLocalDatasource.getAuthState();
    if (result.isOk) {
      final state = result.value;
      return Result.ok(state);
    } else {
      final failure = result.error!;
      return Result.err(failure);
    }
  }

  @override
  Future<Result<bool, Failure>> isAuthenticated() async {
    try {
      final tokenResult = await _authLocalDatasource.getToken();
      if (tokenResult.isOk) {
        final token = tokenResult.value;
        return Result.ok(token != null);
      } else {
        final failure = tokenResult.error!;
        return Result.err(failure);
      }
    } catch (e) {
      return Result.err(ApiFailure.cacheError(message: 'Failed to check authentication status'));
    }
  }

  @override
  Future<Result<void, Failure>> clearSession() async {
    try {
      await _clearLocalSession();
      return const Result.ok(null);
    } catch (e) {
      return Result.err(ApiFailure.cacheError(message: 'Failed to clear session'));
    }
  }

  @override
  Future<Result<void, Failure>> cleanupExpiredTokens() async {
    try {
      final result = await _authLocalDatasource.cleanupExpiredTokens();
      if (result.isOk) {
        return const Result.ok(null);
      } else {
        final failure = result.error!;
        return Result.err(failure);
      }
    } catch (e) {
      return Result.err(ApiFailure.cacheError(message: 'Failed to cleanup expired tokens'));
    }
  }

  @override
  Future<Result<bool, Failure>> isStorageHealthy() async {
    try {
      final result = await _authLocalDatasource.isStorageHealthy();
      if (result.isOk) {
        final healthy = result.value!;
        return Result.ok(healthy);
      } else {
        final failure = result.error!;
        return Result.err(failure);
      }
    } catch (e) {
      return Result.err(ApiFailure.cacheError(message: 'Failed to check storage health'));
    }
  }

  @override
  Future<Result<void, Failure>> clearUserData() async {
    try {
      await _clearLocalSession(clearToken: false);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(ApiFailure.cacheError(message: 'Failed to clear user data'));
    }
  }
}
