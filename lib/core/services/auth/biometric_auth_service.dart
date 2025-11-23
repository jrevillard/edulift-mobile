import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/entities/user.dart';
import '../../../core/security/biometric_service.dart';
import '../../../core/security/tiered_storage_service.dart';
import '../../../core/domain/services/auth_service.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/app_logger.dart';
import '../../network/error_handler_service.dart';

/// State for biometric authentication operations
class BiometricAuthState {
  final bool isLoading;
  final String? error;
  final bool isAvailable;

  const BiometricAuthState({
    this.isLoading = false,
    this.error,
    this.isAvailable = false,
  });

  BiometricAuthState copyWith({
    bool? isLoading,
    String? error,
    bool? isAvailable,
    bool clearError = false,
  }) {
    return BiometricAuthState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

/// Focused service for biometric authentication operations
/// Following Single Responsibility Principle - only handles biometric auth

class BiometricAuthService extends StateNotifier<BiometricAuthState> {
  final BiometricService _biometricService;
  final AuthService _authService;
  final TieredStorageService _storageService;
  final ErrorHandlerService _errorHandlerService;

  BiometricAuthService(
    this._biometricService,
    this._authService,
    this._storageService,
    this._errorHandlerService,
  ) : super(const BiometricAuthState()) {
    _checkBiometricAvailability();
  }

  /// Check if biometric authentication is available
  Future<void> _checkBiometricAvailability() async {
    try {
      final isAvailable = await _biometricService.isAvailable();
      state = state.copyWith(isAvailable: isAvailable);
    } catch (e) {
      AppLogger.error('BiometricAuth: Failed to check availability: $e');
      state = state.copyWith(isAvailable: false);
    }
  }

  /// Authenticate using biometric authentication
  Future<User?> authenticate({String? reason}) async {
    if (!state.isAvailable) {
      state = state.copyWith(
        error: 'Biometric authentication is not available',
      );
      return null;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      AppLogger.info('🔐 BiometricAuth: Starting biometric authentication');

      // Use biometric service to authenticate
      final biometricResult = await _biometricService.authenticate(
        reason: reason ?? 'Authenticate to access your account',
      );

      if (biometricResult.isSuccess) {
        AppLogger.info('✅ BiometricAuth: Biometric authentication successful');

        // Get stored email from secure storage
        final storedEmail = await _storageService.read(
          'stored_email',
          DataSensitivity.medium,
        );
        if (storedEmail != null) {
          AppLogger.info(
            '📧 BiometricAuth: Using stored email for auth: $storedEmail',
          );

          // Authenticate with stored credentials
          final authResult = await _authService.authenticateWithBiometrics(
            storedEmail,
          );

          return authResult.when(
            ok: (result) {
              AppLogger.info(
                '🎉 BiometricAuth: Authentication completed successfully',
              );
              state = state.copyWith(isLoading: false, clearError: true);
              return result.user;
            },
            err: (failure) {
              AppLogger.warning(
                '❌ BiometricAuth: Auth service failed - ${failure.message}',
              );
              state = state.copyWith(
                isLoading: false,
                error: _getErrorMessage(failure),
              );
              return null;
            },
          );
        } else {
          AppLogger.warning('❌ BiometricAuth: No stored credentials found');
          state = state.copyWith(
            isLoading: false,
            error: 'No stored credentials found for biometric authentication',
          );
          return null;
        }
      } else {
        AppLogger.warning(
          '❌ BiometricAuth: Biometric verification failed - ${biometricResult.message}',
        );
        state = state.copyWith(
          isLoading: false,
          error: biometricResult.message ?? 'Biometric authentication failed',
        );
        return null;
      }
    } catch (e) {
      AppLogger.error('BiometricAuth: Exception during authentication: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Biometric authentication error: ${e.toString()}',
      );
      return null;
    }
  }

  /// Check if biometric authentication is enabled for user
  bool canUseBiometric(User? user) {
    return state.isAvailable && (user?.isBiometricEnabled ?? false);
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Get user-friendly error message using focused error formatting service
  String _getErrorMessage(Failure failure) {
    // Use ErrorHandlerService for consistent error handling
    return _errorHandlerService.getErrorMessage(failure);
  }
}
