import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/services/auth_service.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/app_logger.dart';
import '../../../../core/services/app_state_provider.dart';
import '../../network/error_handler_service.dart';

/// State for magic link operations
class MagicLinkState {
  final bool isLoading;
  final String? error;
  final bool requiresName;
  final String? welcomeMessage;

  const MagicLinkState({
    this.isLoading = false,
    this.error,
    this.requiresName = false,
    this.welcomeMessage,
  });

  MagicLinkState copyWith({
    bool? isLoading,
    String? error,
    bool? requiresName,
    String? welcomeMessage,
    bool clearError = false,
    bool clearWelcomeMessage = false,
  }) {
    return MagicLinkState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      requiresName: requiresName ?? this.requiresName,
      welcomeMessage: clearWelcomeMessage
          ? null
          : (welcomeMessage ?? this.welcomeMessage),
    );
  }
}

/// Focused service for magic link operations
/// Following Single Responsibility Principle - only handles magic link sending
class MagicLinkService extends StateNotifier<MagicLinkState> {
  final AuthService _authService;
  final AppStateNotifier _appStateNotifier;
  final ErrorHandlerService _errorHandlerService;

  MagicLinkService(
    this._authService,
    this._appStateNotifier,
    this._errorHandlerService,
  ) : super(const MagicLinkState());

  /// Send magic link for authentication
  Future<bool> sendMagicLink(
    String email, {
    String? name,
    String? inviteCode,
  }) async {
    try {
      AppLogger.info('📧 MagicLink: Sending magic link for email: $email');
      state = state.copyWith(isLoading: true, clearError: true);
      _appStateNotifier.setLoading(true);
      final result = await _authService.sendMagicLink(
        email,
        name: name,
        inviteCode: inviteCode,
      );

      if (result.isOk) {
        // Since sendMagicLink returns Result<void, Failure>, we don't have user status info here
        // The requiresName logic should be handled separately via user status check
        state = state.copyWith(
          isLoading: false,
          requiresName: false, // Will be updated by user status check if needed
          clearError: true,
        );
        return true;
      } else {
        final failure = result.error!;
        state = state.copyWith(
          isLoading: false,
          error: _getErrorMessage(failure),
        );
        return false;
      }
    } catch (e) {
      final errorResult = await _errorHandlerService.handleError(
        e,
        ErrorContext.authOperation('send_magic_link'),
      );
      state = state.copyWith(
        isLoading: false,
        error: errorResult.userMessage.messageKey,
      );
      return false;
    } finally {
      _appStateNotifier.setLoading(false);
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(clearError: true, clearWelcomeMessage: true);
  }

  /// Reset state
  void reset() {
    state = const MagicLinkState();
  }

  /// Get user-friendly error message using focused error formatting service
  String _getErrorMessage(Failure failure) {
    // Use ErrorHandlerService for consistent error handling
    return _errorHandlerService.getErrorMessage(failure);
  }
}
