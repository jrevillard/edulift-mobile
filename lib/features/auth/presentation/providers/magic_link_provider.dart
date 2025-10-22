// EduLift Mobile - Magic Link Provider
// State management for magic link verification process

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import '../../../../core/domain/services/magic_link_service.dart';
import '../../../../core/domain/entities/auth_entities.dart';
import '../../../../core/errors/failures.dart' hide AuthFailure;
import '../../../../core/network/error_handler_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/di/providers/providers.dart';
import '../../../../core/di/providers/service_providers.dart';
import '../../../../core/services/providers/auth_provider.dart';
import '../../../../core/state/reactive_state_coordinator.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/errors/auth_error.dart';

/// State class for magic link verification
@immutable
class MagicLinkState {
  final MagicLinkVerificationStatus status;
  final String? errorMessage;
  final UserErrorMessage? errorInfo;
  final MagicLinkVerificationResult? result;
  final bool canRetry;
  final String? email; // Store email for retry attempts
  final Failure? failure; // Store the actual failure type for proper error display

  const MagicLinkState({
    required this.status,
    this.errorMessage,
    this.errorInfo,
    this.result,
    this.canRetry = false,
    this.email,
    this.failure,
  });

  MagicLinkState copyWith({
    MagicLinkVerificationStatus? status,
    String? errorMessage,
    UserErrorMessage? errorInfo,
    MagicLinkVerificationResult? result,
    bool? canRetry,
    String? email,
    Failure? failure,
  }) {
    return MagicLinkState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      errorInfo: errorInfo ?? this.errorInfo,
      result: result ?? this.result,
      canRetry: canRetry ?? this.canRetry,
      email: email ?? this.email,
      failure: failure ?? this.failure,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MagicLinkState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          errorMessage == other.errorMessage &&
          result == other.result &&
          canRetry == other.canRetry &&
          email == other.email &&
          failure == other.failure;

  @override
  int get hashCode =>
      status.hashCode ^
      errorMessage.hashCode ^
      result.hashCode ^
      canRetry.hashCode ^
      email.hashCode ^
      failure.hashCode;
}

/// Status enum for magic link verification
enum MagicLinkVerificationStatus { initial, verifying, success, error }

/// Notifier for magic link verification state
class MagicLinkNotifier extends StateNotifier<MagicLinkState> with ReactiveStateCoordinator {
  final IMagicLinkService _magicLinkService;
  final Ref _ref;

  MagicLinkNotifier(this._magicLinkService, this._ref)
    : super(const MagicLinkState(status: MagicLinkVerificationStatus.initial));

  /// Store email for retry attempts
  void storeEmail(String email) {
    state = state.copyWith(email: email);
  }

  Future<void> verifyMagicLink(String token, {String? inviteCode, String? email}) async {
    AppLogger.info(
      '🔗 DEBUG: Magic link verification started - token: ${token.substring(0, 10)}..., inviteCode: ${inviteCode ?? "NULL"}, email: ${email ?? "NULL"}',
    );

    // PHASE 5: Clear old invitation result when starting new verification
    final authState = _ref.read(authStateProvider);
    if (authState.invitationResult != null) {
      AppLogger.info('🧹 Clearing stale invitation result before new verification');
      _ref.read(authStateProvider.notifier).clearInvitationResult();
    }

    AppLogger.info('🔗 DEBUG: Setting state to VERIFYING');
    state = state.copyWith(
      status: MagicLinkVerificationStatus.verifying,
      canRetry: false,
      email: email ?? state.email, // Store email for retry attempts
    );

    AppLogger.info('🔗 DEBUG: State after setting VERIFYING - status: ${state.status}');

    try {
      AppLogger.info('🔗 DEBUG: About to call _magicLinkService.verifyMagicLink()');
      final result = await _magicLinkService.verifyMagicLink(token, inviteCode: inviteCode);

      AppLogger.info(
        '🔗 DEBUG: _magicLinkService.verifyMagicLink() completed - result type: ${result.runtimeType}',
      );

      await result.fold(
        (failure) async {
          AppLogger.error('❌ Magic link verification failed: ${failure.message}');

          // STATE-OF-THE-ART: Use reactive state coordinator for critical state updates
          // Store BOTH the failure type and message for proper UI error display
          state = state.copyWith(
            status: MagicLinkVerificationStatus.error,
            errorMessage: failure.message,
            failure: failure, // Store failure type for UI to determine correct localized message
            canRetry: _canRetryFromFailure(failure),
          );
        },
        (verificationResult) async {
          AppLogger.info(
            '✅ DEBUG: Magic link verification SUCCESSFUL - result type: ${verificationResult.runtimeType}',
          );
          AppLogger.info('✅ Magic link verification successful');

          // CRITICAL FIX: Check invitation status BEFORE declaring success
          // The MagicLinkProvider success state should represent "entire process succeeded"
          // not just "token is technically valid"
          if (verificationResult.hasInvitation && !verificationResult.invitationProcessed) {
            // BUSINESS LOGIC FAILURE: Token valid but invitation failed
            // Handle ALL types of invitation errors consistently

            // Create appropriate failure type for invitation error
            // Use domain-specific AuthFailure with proper error enum
            final Failure invitationFailure;
            if (verificationResult.hasCurrentFamily && !verificationResult.canLeaveCurrentFamily) {
              // Family conflict case - use domain error enum
              invitationFailure = AuthFailure(
                error: AuthError.userAlreadyInFamily,
                message: 'User is already member of another family',
                details: {
                  'currentFamilyName': verificationResult.currentFamilyName,
                  'currentUserRole': verificationResult.currentUserRole,
                  'cannotLeaveReason': verificationResult.cannotLeaveReason,
                },
              );
            } else {
              // Regular invitation error - use generic server error
              invitationFailure = ServerFailure(
                message:
                    verificationResult.invitationError ?? 'This invitation could not be processed',
              );
            }

            AppLogger.warning(
              '❌ Invitation processing failed in verification result: ${invitationFailure.message}',
            );

            // Simplified error handling for invitation failures
            // Store BOTH failure type and message
            state = state.copyWith(
              status: MagicLinkVerificationStatus.error,
              errorMessage: invitationFailure.message,
              failure: invitationFailure, // Store for proper UI error display
              canRetry: true,
            );

            return; // Stop here - don't proceed to success logic
          }

          // GLOBAL SUCCESS: Token valid AND (no invitation OR invitation processed successfully)
          AppLogger.info('✅ Magic link verification - entire process successful');

          // Set success state
          state = state.copyWith(
            status: MagicLinkVerificationStatus.success,
            result: verificationResult,
            canRetry: false,
          );

          // CRITICAL FIX: Directly update auth state immediately after successful verification
          try {
            AppLogger.info('🔐 Updating auth state immediately after magic link success');

            // Get the auth notifier to update state directly
            final authNotifier = _ref.read(authStateProvider.notifier);

            // CRITICAL FIX: Use user data from verification result directly
            final userData = verificationResult.user;
            final token = verificationResult.token;

            // Extract all required data from verification result
            final refreshToken = verificationResult.refreshToken;
            final expiresIn = verificationResult.expiresIn;

            AppLogger.info('🔍 DEBUG: Using verification result user data:');
            AppLogger.info('   - User ID from verification: ${userData['id'] ?? 'null'}');
            AppLogger.info('   - User email from verification: ${userData['email'] ?? 'null'}');

            AppLogger.info('🔐 Storing tokens - access token + refresh token');
            AppLogger.debug('   - Access token length: ${token.length}');
            AppLogger.debug('   - Refresh token length: ${refreshToken.length}');
            AppLogger.debug('   - Expires in: ${expiresIn}s');

            // Call the auth service to properly process the verified data and set up user session
            try {
              final authResult = await authNotifier.authService.authenticateWithVerifiedData(
                token: token,
                refreshToken: refreshToken,
                expiresIn: expiresIn,
                userData: userData,
              );

              await authResult.when(
                ok: (result) {
                  AppLogger.info('✅ Auth service processed verified data successfully');
                  AppLogger.info('   - Final user ID: ${result.user.id}');
                  AppLogger.info(
                    '   - CLEAN ARCHITECTURE: Family data will be fetched by router after auth',
                  );

                  // PHASE 2: Store invitation result if present
                  if (result.invitationResult != null) {
                    AppLogger.info('📨 Magic link contains invitation result');
                    AppLogger.info('   - Processed: ${result.invitationResult!.processed}');
                    AppLogger.info('   - Type: ${result.invitationResult!.invitationType}');
                    AppLogger.info('   - Redirect: ${result.invitationResult!.redirectUrl}');

                    _ref
                        .read(authStateProvider.notifier)
                        .setInvitationResult(result.invitationResult!);
                    AppLogger.info('📨 Stored invitation result in AuthState');
                  }

                  // Now update the auth provider state with the fully processed user
                  _ref.read(authStateProvider.notifier).login(result.user);

                  AppLogger.info('🔍 DEBUG: Auth state updated after magic link verification');
                },
                err: (error) {
                  AppLogger.error('❌ Failed to process verified data: ${error.message}');
                  throw error;
                },
              );
            } catch (authError) {
              AppLogger.error('❌ Auth processing failed: $authError');
              rethrow;
            }

            // Small delay for invitation scenarios to allow page processing
            if (inviteCode != null) {
              AppLogger.info('🎫 Invitation detected - adding small delay for page processing');
              await Future.delayed(const Duration(milliseconds: 100));
            }
          } catch (e) {
            AppLogger.error('❌ Failed to update auth state after magic link verification', e);
            // CRITICAL: Don't fail the entire authentication if we can't get fresh user data
            // Instead, try one more time to get cached user data from auth service
            // Fallback error state - create a ServerFailure for consistent error handling
            const fallbackFailure = ServerFailure(
              message:
                  'Authentication completed but user data could not be loaded. Please refresh the page.',
            );
            state = state.copyWith(
              status: MagicLinkVerificationStatus.error,
              errorMessage: fallbackFailure.message,
              failure: fallbackFailure,
              canRetry: true,
            );
            return;
          }

          // STATE-OF-THE-ART: Success state is already coordinated by the mixin
          AppLogger.info(
            '🔗 DEBUG: State after setting SUCCESS - status: ${state.status}, result: ${state.result?.runtimeType}',
          );
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        '💥 DEBUG: Exception during magic link verification - type: ${e.runtimeType}, message: $e',
        e,
        stackTrace,
      );

      AppLogger.info('🔗 DEBUG: Setting state to ERROR (exception case)');
      // Create an UnexpectedFailure for consistent error handling
      const unexpectedFailure = UnexpectedFailure(
        'An unexpected error occurred. Please try again.',
      );
      state = state.copyWith(
        status: MagicLinkVerificationStatus.error,
        errorMessage: unexpectedFailure.message,
        failure: unexpectedFailure,
        canRetry: true,
      );

      AppLogger.info(
        '🔗 DEBUG: State after exception ERROR - status: ${state.status}, errorMessage: ${state.errorMessage}',
      );
    }
  }

  /// Reset the state to initial
  void reset() {
    final previousState = state;
    AppLogger.info(
      '🔄 MAGIC_LINK_RESET: reset() called\n'
      '   - Reset at: ${DateTime.now().toIso8601String()}\n'
      '   - Previous status: ${previousState.status}\n'
      '   - Previous error: ${previousState.errorMessage}\n'
      '   - Previous hashCode: ${previousState.hashCode}\n'
      '   - About to reset to initial state...',
    );

    state = const MagicLinkState(status: MagicLinkVerificationStatus.initial);

    AppLogger.info(
      '🔄 MAGIC_LINK_RESET: State reset completed\n'
      '   - New status: ${state.status}\n'
      '   - New error: ${state.errorMessage}\n'
      '   - New hashCode: ${state.hashCode}',
    );
  }

  /// PHASE 4: Set error state for invitation processing failures
  /// Called when backend successfully verified the magic link but failed to process the invitation
  void setInvitationError(String errorMessage) {
    AppLogger.error(
      '❌ MAGIC_LINK_INVITATION_ERROR: Setting invitation processing error\n'
      '   - Error message: $errorMessage\n'
      '   - Current status: ${state.status}\n'
      '   - Converting to error state for UI display',
    );

    state = state.copyWith(
      status: MagicLinkVerificationStatus.error,
      errorMessage: errorMessage,
      failure: ServerFailure(message: errorMessage),
      canRetry: false, // Can't retry - need new invitation
    );

    AppLogger.error(
      '❌ MAGIC_LINK_INVITATION_ERROR: Error state set\n'
      '   - New status: ${state.status}\n'
      '   - Error message: ${state.errorMessage}\n'
      '   - Can retry: ${state.canRetry}',
    );
  }

  /// Determine if we can retry based on the failure type
  bool _canRetryFromFailure(Failure failure) {
    // Network failures can be retried
    if (failure is NetworkFailure) {
      return true;
    }

    // Server failures that might be temporary
    if (failure is ServerFailure) {
      // CRITICAL FIX: Allow retry for invalid/expired tokens for better UX
      // Users should be able to retry and request a new link
      // Only block retry for validation failures (handled separately)
      return true;
    }

    // Don't retry validation failures
    return false;
  }
}

/// Provider for magic link state management
final magicLinkProvider = StateNotifierProvider<MagicLinkNotifier, MagicLinkState>((ref) {
  // Get the magic link service from dependency injection
  try {
    AppLogger.info(
      '🔗 DEBUG: Creating MagicLinkProvider - about to read magicLinkServiceDIProvider',
    );
    final magicLinkService = ref.read(magicLinkServiceDIProvider);
    AppLogger.info('🔗 DEBUG: MagicLinkService created - type: ${magicLinkService.runtimeType}');
    return MagicLinkNotifier(magicLinkService, ref);
  } catch (e, stack) {
    AppLogger.error('💥 DEBUG: Failed to create MagicLinkProvider', e, stack);
    rethrow;
  }
});

/// Dependency injection provider for IMagicLinkService
/// Connected to Riverpod providers
final magicLinkServiceDIProvider = Provider<IMagicLinkService>((ref) {
  try {
    AppLogger.info(
      '🔗 DEBUG: Creating MagicLinkServiceDI - about to read magicLinkServiceProvider',
    );
    final service = ref.watch(magicLinkServiceProvider);
    AppLogger.info('🔗 DEBUG: MagicLinkServiceProvider resolved - type: ${service.runtimeType}');
    return service;
  } catch (e, stack) {
    AppLogger.error('💥 DEBUG: Failed to create MagicLinkServiceDI', e, stack);
    rethrow;
  }
});

// Removed dependency injection provider to simplify compilation

/// Convenience providers for specific state aspects
final magicLinkStatusProvider = Provider<MagicLinkVerificationStatus>((ref) {
  return ref.watch(magicLinkProvider).status;
});

final magicLinkErrorProvider = Provider<String?>((ref) {
  return ref.watch(magicLinkProvider).errorMessage;
});

final magicLinkResultProvider = Provider<MagicLinkVerificationResult?>((ref) {
  return ref.watch(magicLinkProvider).result;
});

final magicLinkCanRetryProvider = Provider<bool>((ref) {
  return ref.watch(magicLinkProvider).canRetry;
});
