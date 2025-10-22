import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/user_status_service.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/app_logger.dart';
import '../../network/error_handler_service.dart';

/// State for user status checking operations
class UserStatusCheckState {
  final UserStatus? userStatus;
  final bool isCheckingUserStatus;
  final String? pendingEmail;
  final bool showNameField;
  final String? welcomeMessage;
  final String? error;

  const UserStatusCheckState({
    this.userStatus,
    this.isCheckingUserStatus = false,
    this.pendingEmail,
    this.showNameField = false,
    this.welcomeMessage,
    this.error,
  });
  UserStatusCheckState copyWith({
    UserStatus? userStatus,
    bool? isCheckingUserStatus,
    String? pendingEmail,
    bool? showNameField,
    String? welcomeMessage,
    String? error,
    bool clearUserStatus = false,
    bool clearPendingEmail = false,
    bool clearWelcomeMessage = false,
    bool clearError = false,
  }) {
    return UserStatusCheckState(
      userStatus: clearUserStatus ? null : (userStatus ?? this.userStatus),
      isCheckingUserStatus: isCheckingUserStatus ?? this.isCheckingUserStatus,
      pendingEmail: clearPendingEmail
          ? null
          : (pendingEmail ?? this.pendingEmail),
      showNameField: showNameField ?? this.showNameField,
      welcomeMessage: clearWelcomeMessage
          ? null
          : (welcomeMessage ?? this.welcomeMessage),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Focused service for user status checking operations
/// Following Single Responsibility Principle - only handles user status validation
class UserStatusCheckerService extends StateNotifier<UserStatusCheckState> {
  final UserStatusService _userStatusService;
  final ErrorHandlerService _errorHandlerService;

  UserStatusCheckerService(this._userStatusService, this._errorHandlerService)
    : super(const UserStatusCheckState());
  /// Check user status to determine if name field should be shown
  Future<void> checkUserStatus(String email) async {
    try {
      state = state.copyWith(isCheckingUserStatus: true, clearError: true);
      AppLogger.info('🔍 UserStatusChecker: Checking status for email: $email');
      final result = await _userStatusService.checkUserStatus(email);
      result.fold(
        (failure) {
          AppLogger.warning('❌ UserStatusChecker: Status check failed - ${failure.message}');
          state = state.copyWith(
            isCheckingUserStatus: false,
            error: _getErrorMessage(failure),
          );
        },
        (userStatus) {
          AppLogger.info('✅ UserStatusChecker: Status checked - requiresName: ${userStatus.requiresName}');
          state = state.copyWith(
            isCheckingUserStatus: false,
            userStatus: userStatus,
            pendingEmail: email,
            showNameField: userStatus.requiresName,
          );
        },
      );
    } catch (e) {
      AppLogger.error('UserStatusChecker: Exception during status check: $e');
      final errorResult = await _errorHandlerService.handleError(
        e,
        ErrorContext.authOperation('check_user_status'),
      );
      state = state.copyWith(isCheckingUserStatus: false, error: errorResult.userMessage.messageKey);
    }
  }

  /// Clear user status data
  void clearUserStatus() {
    state = state.copyWith(
      clearUserStatus: true,
      clearPendingEmail: true,
      showNameField: false,
      clearWelcomeMessage: true,
    );
  }

  /// Set whether name field should be shown
  void setShowNameField(bool show) {
    state = state.copyWith(showNameField: show);
  }

  /// Set welcome message for new users
  void setWelcomeMessage(String message) {
    state = state.copyWith(welcomeMessage: message);
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(clearError: true, clearWelcomeMessage: true);
  }

  /// Get user-friendly error message using focused error formatting service
  String _getErrorMessage(Failure failure) {
    // Use ErrorHandlerService for consistent error handling
    return _errorHandlerService.getErrorMessage(failure);
  }
}
