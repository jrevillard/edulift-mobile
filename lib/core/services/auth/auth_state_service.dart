import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import '../../../core/domain/entities/user.dart';
import '../../../core/domain/services/auth_service.dart';
import '../../../core/security/tiered_storage_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../network/error_handler_service.dart';

/// Authentication state that tracks the current user
@immutable
class AuthenticationState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isInitialized;

  const AuthenticationState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isInitialized = false,
  });
  AuthenticationState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isInitialized,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthenticationState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  bool get isAuthenticated => user != null;
  bool get canUseBiometric => user?.isBiometricEnabled ?? false;
}

/// Focused service for authentication state management
/// Following Single Responsibility Principle - only handles auth state
class AuthStateService extends StateNotifier<AuthenticationState> {
  final AuthService _authService;
  final TieredStorageService _storageService;
  final ErrorHandlerService _errorHandlerService;

  AuthStateService(
    this._authService,
    this._storageService,
    this._errorHandlerService,
  ) : super(const AuthenticationState()) {
    _initializeAuth();
  }

  /// Initialize authentication by checking stored tokens
  Future<void> _initializeAuth() async {
    try {
      state = state.copyWith(isLoading: true);
      final token = await _storageService.getAccessToken();
      if (token != null) {
        final result = await _authService.getCurrentUser();
        if (result.isErr) {
          await _clearAuthData();
          state = state.copyWith(
            isLoading: false,
            isInitialized: true,
            clearUser: true,
          );
        } else {
          final user = result.value!;
          state = state.copyWith(
            user: user,
            isLoading: false,
            isInitialized: true,
          );
        }
      } else {
        state = state.copyWith(isLoading: false, isInitialized: true);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        error: e.toString(),
      );
    }
  }

  /// Set user as authenticated
  void setUser(User user) {
    state = state.copyWith(user: user, isLoading: false, clearError: true);
  }

  /// Clear authentication data
  Future<void> clearAuth() async {
    try {
      if (state.isAuthenticated) {
        await _authService.logout();
      }
      await _clearAuthData();
      state = state.copyWith(
        clearUser: true,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      await _clearAuthData();
      final errorResult = await _errorHandlerService.handleError(
        e,
        ErrorContext.authOperation('logout'),
      );
      state = state.copyWith(
        clearUser: true,
        isLoading: false,
        error: errorResult.userMessage.messageKey,
      );
    }
  }

  /// Set loading state
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  /// Set error state
  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Validate stored token
  Future<void> validateToken() async {
    try {
      final hasToken = await _storageService.containsKey(
        'access_token',
        DataSensitivity.medium,
      );
      if (!hasToken) {
        AppLogger.warning('No token found, clearing auth state');
        await clearAuth();
        return;
      }
      AppLogger.info('Token validation passed');
    } catch (e) {
      AppLogger.error('Token validation failed: $e');
      await clearAuth();
    }
  }

  Future<void> _clearAuthData() async {
    await _storageService.delete('access_token', DataSensitivity.medium);
    await _storageService.delete('user_data', DataSensitivity.medium);
  }
}
