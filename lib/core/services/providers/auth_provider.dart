import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:async/async.dart' as async_pkg;

import '../../../core/domain/entities/user.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/result.dart';
import '../../../core/security/biometric_service.dart';
import '../../../core/di/providers/service_providers.dart';
import '../../../core/services/user_status_service.dart';
import '../../../core/domain/services/auth_service.dart';
import '../../../core/services/adaptive_storage_service.dart';
import '../../../core/utils/app_logger.dart';
// REMOVED: Data layer import violation - use composition root instead
// import '../../../features/family/data/providers/family_provider.dart';
import '../../../core/services/app_state_provider.dart';
import '../../network/error_handler_service.dart';
import 'token_expiry_provider.dart';

/// Provider for post-logout target route - used for declarative navigation after logout
// REMOVED: postLogoutTargetRouteProvider - targetRoute approach doesn't work, using direct navigation instead

/// Authentication state that tracks the current user
@immutable
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isInitialized;
  final UserStatus? userStatus;
  final bool isCheckingUserStatus;
  final String? pendingEmail;
  final String? pendingName; // MAGIC LINK FIX: Store name for resends
  final String?
  pendingInviteCode; // INVITATION FIX: Store invite code for resends
  final bool showNameField;
  final String? welcomeMessage;
  final InvitationResult? invitationResult; // PHASE 1: Store invitation result from magic link

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isInitialized = false,
    this.userStatus,
    this.isCheckingUserStatus = false,
    this.pendingEmail,
    this.pendingName, // MAGIC LINK FIX: Store name for resends
    this.pendingInviteCode, // INVITATION FIX: Store invite code for resends
    this.showNameField = false,
    this.welcomeMessage,
    this.invitationResult, // PHASE 1: Store invitation result from magic link
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isInitialized,
    UserStatus? userStatus,
    bool? isCheckingUserStatus,
    String? pendingEmail,
    String? pendingName, // MAGIC LINK FIX: Store name for resends
    String? pendingInviteCode, // INVITATION FIX: Store invite code for resends
    bool? showNameField,
    String? welcomeMessage,
    InvitationResult? invitationResult, // PHASE 1: Add invitationResult parameter
    bool clearUser = false,
    bool clearError = false,
    bool clearUserStatus = false,
    bool clearPendingEmail = false,
    bool clearPendingName = false, // MAGIC LINK FIX: Clear name parameter
    bool clearPendingInviteCode =
        false, // INVITATION FIX: Clear invite code parameter
    bool clearWelcomeMessage = false,
    bool clearInvitationResult = false, // PHASE 1: Clear invitation result parameter
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isInitialized: isInitialized ?? this.isInitialized,
      userStatus: clearUserStatus ? null : (userStatus ?? this.userStatus),
      isCheckingUserStatus: isCheckingUserStatus ?? this.isCheckingUserStatus,
      pendingEmail: clearPendingEmail
          ? null
          : (pendingEmail ?? this.pendingEmail),
      pendingName:
          clearPendingName // MAGIC LINK FIX: Store name for resends
          ? null
          : (pendingName ?? this.pendingName),
      pendingInviteCode:
          clearPendingInviteCode // INVITATION FIX: Store invite code for resends
          ? null
          : (pendingInviteCode ?? this.pendingInviteCode),
      showNameField: showNameField ?? this.showNameField,
      welcomeMessage: clearWelcomeMessage
          ? null
          : (welcomeMessage ?? this.welcomeMessage),
      invitationResult: clearInvitationResult // PHASE 1: Handle invitation result
          ? null
          : (invitationResult ?? this.invitationResult),
    );
  }

  bool get isAuthenticated => user != null;
  bool get canUseBiometric => user?.isBiometricEnabled ?? false;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final AdaptiveStorageService _storageService;
  final BiometricService _biometricService;
  final AppStateNotifier _appStateNotifier;
  final UserStatusService _userStatusService;
  final ErrorHandlerService _errorHandlerService;
  final Ref _ref; // SECURITY: Required for token expiry listener

  // NETWORK FIX: Track pending magic link operation to prevent zombie futures
  async_pkg.CancelableOperation<Result<void, Failure>>?
  _pendingSendMagicLinkOperation;

  AuthNotifier(
    this._authService,
    this._storageService,
    this._biometricService,
    this._appStateNotifier,
    this._userStatusService,
    this._errorHandlerService,
    this._ref, // SECURITY: Required for token expiry listener
  ) : super(const AuthState()) {
    // SURGICAL FIX: Remove addPostFrameCallback to prevent infinite loops during app restart
    // Auth initialization will be triggered when first accessed, not during construction
    // This prevents pumpAndSettle timeout issues in E2E tests

    // Authentication provider focuses purely on auth state, not navigation
    // Navigation is handled by GoRouter redirect logic

    // SECURITY: Setup token expiry listener for automatic logout
    _setupTokenExpiryListener();
  }

  // Track whether initialization has been attempted to prevent double initialization
  bool _hasInitialized = false;

  // Removed static flag to allow independent initialization per container
  /// SECURITY: Setup listener for token expiry events - critical for automatic logout
  void _setupTokenExpiryListener() {
    _ref.listen(tokenExpiredProvider, (previous, next) {
      if (next != null && previous != next) {
        AppLogger.info(
          '🔑 AuthNotifier: Token expiry detected - ${next.statusCode} on ${next.endpoint}',
        );
        // Trigger logout when token expires
        logout()
            .then((_) {
              // Clear the token expiry state after handling
              TokenExpiryNotifier.clearTokenExpiredState(_ref);
              AppLogger.info(
                '🔑 AuthNotifier: Logout completed due to token expiry',
              );
            })
            .catchError((error) {
              AppLogger.error(
                '🔑 AuthNotifier: Failed to logout after token expiry: $error',
              );
              // Still clear the state even if logout fails
              TokenExpiryNotifier.clearTokenExpiredState(_ref);
            });
      }
    });
  }

  /// Public getter for auth service to allow external access for state coordination
  AuthService get authService => _authService;

  /// PROVIDER FIX: Initialize auth state and restore session if available
  /// Called when auth state is first accessed, not during construction
  Future<void> initializeAuth() async {
    // Prevent double initialization within same instance
    if (_hasInitialized) {
      AppLogger.info(
        '🔍 DEBUG: initializeAuth() called but already initialized - skipping',
      );
      return;
    }

    // Mark as initialized to prevent concurrent calls
    _hasInitialized = true;

    AppLogger.info(
      '🔍 DEBUG: initializeAuth() starting - current state authenticated: ${state.isAuthenticated}, isInitialized: ${state.isInitialized}',
    );
    try {
      AppLogger.info('🔍 DEBUG: Setting state.isLoading = true');
      state = state.copyWith(isLoading: true);
      AppLogger.info(
        '🔍 DEBUG: State after isLoading=true - isLoading: ${state.isLoading}, isInitialized: ${state.isInitialized}',
      );
      // Try to restore session from secure storage
      AppLogger.info('🔍 DEBUG: About to call _storageService.getToken()');
      final token = await _storageService.getToken();
      AppLogger.info(
        '🔍 DEBUG: _storageService.getToken() returned - token: ${token != null ? "EXISTS (${token.length} chars)" : "NULL"}',
      );
      if (token != null) {
        AppLogger.info(
          '🔍 DEBUG: Token found, validating user with getCurrentUser()',
        );
        // Validate token and get user info - family data removed from getCurrentUser
        // Family data will be fetched separately after authentication
        final result = await _authService.getCurrentUser(forceRefresh: true);
        AppLogger.info(
          '🔍 DEBUG: getCurrentUser() completed - result type: ${result.runtimeType}',
        );
        if (result.isErr) {
          // Token is invalid, clear storage
          AppLogger.info(
            '🔍 DEBUG: initializeAuth() - token invalid, clearing user - failure: ${result.error!.runtimeType}',
          );
          await _clearAuthData();
          AppLogger.info(
            '🔍 DEBUG: About to set state - isInitialized = TRUE (token invalid)',
          );
          state = state.copyWith(
            isLoading: false,
            clearUser: true,
            isInitialized: true,
          );
          AppLogger.info(
            '🔍 DEBUG: State set after token invalid - isInitialized: ${state.isInitialized}, isAuthenticated: ${state.isAuthenticated}',
          );
        } else {
          final user = result.value!;
          AppLogger.info(
            '🔍 DEBUG: initializeAuth() - restored user: ${user.id}',
          );
          // CLEAN ARCHITECTURE: Family data will be handled by family providers
          // Auth domain only handles authentication state
          AppLogger.info(
            '🔍 DEBUG: About to set state - isInitialized = TRUE (user restored)',
          );
          state = state.copyWith(
            user: user,
            isLoading: false,
            isInitialized: true,
          );
          AppLogger.info(
            '🔍 DEBUG: State set after user restored - isInitialized: ${state.isInitialized}, isAuthenticated: ${state.isAuthenticated}, userID: ${state.user?.id}',
          );
        }
      } else {
        AppLogger.info(
          '🔍 DEBUG: No token found - setting isInitialized = TRUE (no token)',
        );
        state = state.copyWith(isLoading: false, isInitialized: true);
        AppLogger.info(
          '🔍 DEBUG: State set after no token - isInitialized: ${state.isInitialized}, isAuthenticated: ${state.isAuthenticated}',
        );
      }
    } catch (e) {
      AppLogger.info(
        '🔍 DEBUG: Exception in initializeAuth - exception: ${e.runtimeType} - $e',
      );
      AppLogger.info(
        '🔍 DEBUG: About to set state - isInitialized = TRUE (exception case)',
      );
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isInitialized: true,
      );
      AppLogger.info(
        '🔍 DEBUG: State set after exception - isInitialized: ${state.isInitialized}, isAuthenticated: ${state.isAuthenticated}',
      );
      // Instance flag already set, no cleanup needed
    }
    AppLogger.info(
      '🔍 DEBUG: initializeAuth() COMPLETE - Final state: isInitialized=${state.isInitialized}, isAuthenticated=${state.isAuthenticated}, userID=${state.user?.id}',
    );
    // Initialization complete
  }

  /// Check user status to determine if name field should be shown
  Future<void> checkUserStatus(String email) async {
    try {
      state = state.copyWith(
        isCheckingUserStatus: true,
        clearError: true,
        clearWelcomeMessage: true,
      );
      final result = await _userStatusService.checkUserStatus(email);
      result.fold(
        (failure) {
          state = state.copyWith(
            isCheckingUserStatus: false,
            error: _getErrorMessage(failure),
            clearWelcomeMessage:
                true, // CRITICAL FIX: Clear welcome message on error
          );
        },
        (userStatus) {
          state = state.copyWith(
            isCheckingUserStatus: false,
            userStatus: userStatus,
            pendingEmail: email,
            showNameField: userStatus.requiresName,
            clearWelcomeMessage:
                true, // CRITICAL FIX: Clear welcome message on success
          );
        },
      );
    } catch (e) {
      final errorResult = await _errorHandlerService.handleError(
        e,
        ErrorContext.authOperation('check_user_status'),
      );
      state = state.copyWith(
        isCheckingUserStatus: false,
        error: errorResult.userMessage.messageKey,
        clearWelcomeMessage:
            true, // CRITICAL FIX: Clear welcome message on exception
      );
    }
  }

  Future<void> sendMagicLink(
    String email, {
    String? name,
    String? inviteCode,
  }) async {
    // CRITICAL: Cancel any pending operation before starting new one
    await _pendingSendMagicLinkOperation?.cancel();
    try {
      AppLogger.info('📧 Auth Provider: Sending magic link for email: $email');
      state = state.copyWith(isLoading: true, clearError: true);
      _appStateNotifier.setLoading(true);
      // MAGIC LINK FIX: Use stored name for resends if no name provided
      final nameToUse = name ?? state.pendingName;

      // INVITATION FIX: Use stored invite code for resends if no invite code provided
      final inviteCodeToUse = inviteCode ?? state.pendingInviteCode;

      // Store name in state if provided (but don't set pendingEmail yet - only after success)
      if (nameToUse != null && nameToUse.isNotEmpty) {
        state = state.copyWith(pendingName: nameToUse);
        AppLogger.info(
          '📧 Auth Provider: Using name for magic link: $nameToUse',
        );
      } else {
        AppLogger.info(
          '📧 Auth Provider: No name provided - sending magic link without name',
        );
      }

      // INVITATION FIX: Store invite code in state if provided
      if (inviteCodeToUse != null && inviteCodeToUse.isNotEmpty) {
        state = state.copyWith(pendingInviteCode: inviteCodeToUse);
        AppLogger.info(
          '📧 Auth Provider: Using invite code for magic link: $inviteCodeToUse',
        );
      } else {
        AppLogger.info(
          '📧 Auth Provider: No invite code provided - sending magic link without invite code',
        );
      }

      // NETWORK FIX: Wrap the service call in CancelableOperation
      _pendingSendMagicLinkOperation = async_pkg.CancelableOperation.fromFuture(
        _authService.sendMagicLink(
          email,
          name: nameToUse,
          inviteCode: inviteCodeToUse,
        ),
      );
      // Wait for the operation to complete
      final result = await _pendingSendMagicLinkOperation!.value;

      // RACE CONDITION FIX: Check cancellation before processing result
      if (_pendingSendMagicLinkOperation?.isCanceled == true) {
        AppLogger.info(
          '📧 Auth Provider: Operation cancelled before result processing',
        );
        state = state.copyWith(isLoading: false);
        _pendingSendMagicLinkOperation = null;
        return; // Exit early, don't process result
      }

      // Handle the result - result is of type Result<void, Failure>
      if (result.isOk) {
        state = state.copyWith(
          isLoading: false,
          clearError: true,
          clearWelcomeMessage: true,
          pendingEmail: email,
          showNameField: false,
        );
      } else {
        final failure = result.error!;
        if (_errorHandlerService.isNameRequiredError(failure)) {
          AppLogger.info('📝 Auth Provider: Name required for new user');
          if (!state.showNameField) {
            state = state.copyWith(
              isLoading: false,
              showNameField: true,
              welcomeMessage:
                  'Welcome! It looks like this is your first time. Please enter your name.',
              clearError: true,
            );
          } else {
            state = state.copyWith(
              isLoading: false,
              error:
                  'Veuillez saisir votre nom complet pour créer votre compte.',
            );
          }
        } else {
          final errorMessage = _getErrorMessage(failure);
          state = state.copyWith(isLoading: false, error: errorMessage);
        }
      }
      // Clear the operation reference after successful completion
      _pendingSendMagicLinkOperation = null;
    } catch (e) {
      // SURGICAL FIX: Enhanced network error handling for E2E test reliability
      if (_pendingSendMagicLinkOperation?.isCanceled == true) {
        // NETWORK FIX: Operation was cancelled due to network interruption
        AppLogger.info(
          '📧 Auth Provider: Operation cancelled (network interruption)',
        );
        // SURGICAL FIX: Show user-friendly offline error instead of silent failure
        // Use ErrorHandlerService for consistent error messaging
        const networkFailure = NetworkFailure(
          message: 'Network connection interrupted',
          statusCode: 0,
        );
        state = state.copyWith(
          isLoading: false,
          error: _errorHandlerService.getErrorMessage(networkFailure),
        );
      } else {
        // NETWORK FIX: Cancel the pending operation on any error
        await _pendingSendMagicLinkOperation?.cancel();
        _pendingSendMagicLinkOperation = null;

        AppLogger.warning(
          '📧 Auth Provider: Exception during magic link send: $e',
        );
        // Use ErrorHandlerService for consistent error messaging
        final unexpectedFailure = UnexpectedFailure(
          'Failed to send magic link',
          details: {'exception': e.toString()},
        );
        state = state.copyWith(
          isLoading: false,
          error: _errorHandlerService.getErrorMessage(unexpectedFailure),
          clearWelcomeMessage: true,
        );
      }
    } finally {
      _appStateNotifier.setLoading(false);
      // SURGICAL FIX: Guarantee loading state is always cleared to prevent button disappearance
      // This ensures the UI is always responsive after network errors
      if (state.isLoading) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> validateToken() async {
    try {
      // Single token architecture: check if token exists
      final hasToken = await _storageService.hasStoredToken();
      if (!hasToken) {
        AppLogger.warning('No token found, logging out user');
        state = state.copyWith(error: 'errorInvalidToken');
        await logout();
        return;
      }

      // If token exists, try to authenticate with it (magic link token validation)
      final token = await _storageService.getToken();
      if (token != null) {
        final authResult = await _authService.authenticateWithMagicLink(token);
        if (authResult.isOk) {
          final result = authResult.value!;

          // Successfully authenticated with token
          // CLEAN ARCHITECTURE: Use generic welcome message - family status handled elsewhere
          final welcomeMessage = 'Welcome to EduLift, ${result.user.name}!';

          state = state.copyWith(
            user: result.user,
            isLoading: false,
            clearError: true,
            welcomeMessage: welcomeMessage,
          );
          AppLogger.info('Token validation passed');
        } else {
          final failure = authResult.error!;

          // Token is invalid, clear storage and logout
          AppLogger.warning('Token validation failed: ${failure.message}');
          state = state.copyWith(error: 'errorInvalidToken');
          await logout();
        }
      }
    } catch (e) {
      AppLogger.error('Token validation failed: $e');
      state = state.copyWith(error: 'errorTokenValidationFailed');
      await logout();
    }
  }

  Future<void> logout() async {
    try {
      _appStateNotifier.setLoading(true);

      // Call logout API if user is authenticated
      if (state.isAuthenticated) {
        final logoutResult = await _authService.logout();
        if (logoutResult.isOk) {
          // Logout API succeeded
          AppLogger.info('✅ [Auth] API logout succeeded');
        } else {
          // Logout API failed, but continue with local cleanup
          state = state.copyWith(error: 'errorLogoutFailed');
          AppLogger.warning('⚠️ [Auth] API logout failed, continuing with local cleanup');
        }
      }

      // Clear local auth data
      await _clearAuthData();

      // Update auth state → This triggers AUTOMATIC cleanup in all reactive providers!
      state = state.copyWith(
        clearUser: true,
        isLoading: false,
        clearUserStatus: true,
        clearPendingEmail: true,
        clearPendingName: true,
        clearPendingInviteCode: true,
        showNameField: false,
        clearWelcomeMessage: true,
        clearInvitationResult: true, // PHASE 1: Clear invitation result on logout
      );

      AppLogger.info('🔄 [Auth] Logout completed - All providers should auto-cleanup via reactive listening');

    } catch (e, stackTrace) {
      AppLogger.error('❌ [Auth] Logout failed', e, stackTrace);
      state = state.copyWith(isLoading: false, error: 'errorLogoutFailed');
    } finally {
      _appStateNotifier.setLoading(false);
    }
  }

  Future<void> _clearAuthData() async {
    await _storageService.clearToken();
    await _storageService.clearUserData();
    // CRITICAL FIX: Also clear auth-specific data that contains familyId
    // This ensures auth_user_profile key is properly cleared during logout
    await _authService.clearUserData();
    // CLEAN ARCHITECTURE: Family cache clearing will be handled by family providers
    // Auth domain only handles authentication-specific data cleanup
    AppLogger.info(
      '✅ [Auth] Auth data cleared - family data cleanup handled by family providers',
    );
  }

  String _getErrorMessage(Failure failure) {
    // Use ErrorHandlerService for consistent error messaging
    // This ensures centralized error handling and consistent user messages
    return _errorHandlerService.getErrorMessage(failure);
  }

  void clearError() {
    // Only update state if there's actually an error or welcome message to clear
    if (state.error != null || state.welcomeMessage != null) {
      state = state.copyWith(clearError: true, clearWelcomeMessage: true);
    }
  }

  void setError(String errorMessage) {
    // Set error message in auth state
    state = state.copyWith(error: errorMessage);
  }

  void clearUserStatus() {
    // Only update state if there's actually user status to clear
    if (state.userStatus != null ||
        state.pendingEmail != null ||
        state.pendingName !=
            null || // MAGIC LINK FIX: Include pending name in cleanup check
        state.pendingInviteCode !=
            null || // INVITATION FIX: Include pending invite code in cleanup check
        state.showNameField == true) {
      state = state.copyWith(
        clearUserStatus: true,
        clearPendingEmail: true,
        clearPendingName:
            true, // MAGIC LINK FIX: Clear pending name when clearing user status
        clearPendingInviteCode:
            true, // INVITATION FIX: Clear pending invite code when clearing user status
        showNameField: false,
      );
    }
  }

  /// Clear pending email when magic link deep link is received
  void clearPendingEmail() {
    if (state.pendingEmail != null) {
      state = state.copyWith(clearPendingEmail: true);
    }
  }

  void setShowNameField(bool show) {
    state = state.copyWith(showNameField: show);
  }

  /// PHASE 1: Set invitation result in auth state
  /// Will be used in Phase 2 to store result from magic link verification
  void setInvitationResult(InvitationResult result) {
    AppLogger.info('🎫 AuthProvider: Setting invitation result - processed: ${result.processed}, type: ${result.invitationType}');
    state = state.copyWith(invitationResult: result);
  }

  /// PHASE 1: Clear invitation result from auth state
  /// Will be used in Phase 5 after consuming the result
  void clearInvitationResult() {
    if (state.invitationResult != null) {
      AppLogger.info('🎫 AuthProvider: Clearing invitation result');
      state = state.copyWith(clearInvitationResult: true);
    }
  }

  /// Set user as authenticated (for magic link and other auth flows)
  void login(User user) {
    AppLogger.info('🔐 AuthProvider.login() called with user: ${user.id}');
    AppLogger.info('   - User family: [via UserFamilyService]');
    AppLogger.info(
      '   - Before login - current state authenticated: ${state.isAuthenticated}',
    );
    AppLogger.info(
      '   - Before login - current state user: ${state.user?.id ?? 'null'}',
    );
    state = state.copyWith(user: user, isLoading: false, clearError: true);
    // CLEAN ARCHITECTURE: Family data caching handled by family providers
    // Auth domain only handles authentication state
    AppLogger.debug(
      '🔄 AuthProvider: User logged in - family data handled by family providers',
    );
    AppLogger.info(
      '   - After login - current state authenticated: ${state.isAuthenticated}',
    );
    AppLogger.info(
      '   - After login - current state user: ${state.user?.id ?? 'null'}',
    );
    AppLogger.info(
      '   - After login - current state user family: [via UserFamilyService]',
    );
  }

  /// Refresh current user data with fresh information including family data
  Future<void> refreshCurrentUser() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      // Call getCurrentUser with forceRefresh to get latest family information
      final result = await _authService.getCurrentUser(forceRefresh: true);
      if (result.isOk) {
        final user = result.value!;
        state = state.copyWith(user: user, isLoading: false, clearError: true);
      } else {
        final failure = result.error!;
        // CRITICAL FIX: Check if auth service already has user data as fallback
        final cachedUser = _authService.currentUser;
        if (cachedUser != null) {
          AppLogger.info(
            '🔄 Using cached user data as fallback after API failure',
          );
          state = state.copyWith(
            user: cachedUser,
            isLoading: false,
            clearError: true,
          );
        } else {
          // No cached user data available, update state with error
          state = state.copyWith(
            isLoading: false,
            error: _getErrorMessage(failure),
          );
        }
      }
    } catch (e) {
      AppLogger.error('Exception while refreshing current user', e);
      // CRITICAL FIX: Check auth service cache as fallback for exceptions too
      final cachedUser = _authService.currentUser;
      if (cachedUser != null) {
        AppLogger.info('🔄 Using cached user data as fallback after exception');
        state = state.copyWith(
          user: cachedUser,
          isLoading: false,
          clearError: true,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to refresh user data',
        );
      }
    }
  }

  Future<void> authenticateWithBiometric() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // Use biometric service to authenticate
      final biometricResult = await _biometricService.authenticate(
        reason: 'Authenticate to access your account',
      );
      if (biometricResult.isSuccess) {
        // Get stored email from secure storage
        final storedEmail = await _storageService.getStoredEmail();
        if (storedEmail != null) {
          // Authenticate with stored credentials
          final authResult = await _authService.authenticateWithBiometrics(
            storedEmail,
          );
          if (authResult.isOk) {
            final result = authResult.value!;
            state = state.copyWith(
              user: result.user,
              isLoading: false,
              clearError: true,
            );
          } else {
            final failure = authResult.error!;
            state = state.copyWith(
              isLoading: false,
              error: _getErrorMessage(failure),
            );
          }
        } else {
          state = state.copyWith(
            isLoading: false,
            error: 'No stored credentials found for biometric authentication',
          );
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          error: biometricResult.message ?? 'Biometric authentication failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Biometric authentication error: ${e.toString()}',
      );
    }
  }

  /// PROVIDER FIX: Proper disposal to prevent memory leaks
  @override
  void dispose() {
    // NETWORK FIX: Cancel any pending operation on dispose
    _pendingSendMagicLinkOperation?.cancel();
    // Clear sensitive data before disposal
    if (mounted) {
      state = state.copyWith(
        clearUser: true,
        clearError: true,
        isLoading: false,
      );
    }
    super.dispose();
  }
}

// Provider for auth state
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final adaptiveStorageService = ref.watch(serviceAdaptiveStorageProvider);
  final biometricService = ref.watch(biometricAuthServiceProvider);
  final userStatusService = ref.watch(userStatusServiceProvider);
  final errorHandlerService = ref.watch(coreErrorHandlerServiceProvider);
  final notifier = AuthNotifier(
    authService,
    adaptiveStorageService,
    biometricService,
    ref.read(appStateProvider.notifier),
    userStatusService,
    errorHandlerService,
    ref, // CONSENSUS SOLUTION: Pass ref for postLogoutTargetRoute access
  );
  // SURGICAL FIX: Lazy initialization - auth will be initialized by SplashPage
  // This prevents pumpAndSettle timeout during E2E tests as warned in line 115

  return notifier;
});
// Convenience provider for checking if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider.select((state) => state.isAuthenticated));
});
// Convenience provider for current user
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider.select((state) => state.user));
});
// PHASE 1: Convenience provider for invitation result
final invitationResultProvider = Provider<InvitationResult?>((ref) {
  return ref.watch(authStateProvider.select((state) => state.invitationResult));
});
// Enhanced current user provider with family role information
final currentUserWithFamilyRoleProvider = Provider<User?>((ref) {
  final user = ref.watch(authStateProvider.select((state) => state.user));
  // TODO: Implement family check via UserFamilyService
  // CLEAN ARCHITECTURE: Remove direct familyId access
  // For now, return user as-is
  if (user == null) {
    return user;
  }

  return user;
});
