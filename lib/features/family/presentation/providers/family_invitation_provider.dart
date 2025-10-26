// EduLift Mobile - Family Invitation Provider
// Riverpod provider for managing family invitation state

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/core/domain/services/auth_service.dart';
import 'package:edulift/core/domain/failures/invitation_failure.dart';
import 'package:edulift/core/services/user_family_service.dart';
import 'package:edulift/core/services/providers/auth_provider.dart';
import 'package:edulift/core/domain/entities/user.dart';
import 'package:edulift/core/utils/app_logger.dart';
import 'package:edulift/core/di/providers/providers.dart';
import 'package:edulift/core/navigation/navigation_state.dart' as nav;
import 'package:edulift/core/services/invitation_error_mapper.dart';
import 'package:edulift/core/network/models/family/family_invitation_validation_dto.dart';
import 'family_provider.dart';
import '../../domain/usecases/family_invitation_usecase.dart';

/// Family invitation state
class FamilyInvitationState {
  final bool isLoading;
  final bool isValidating;
  final FamilyInvitationValidationDto? validation;
  final String? error;
  final bool isAuthenticated;
  final bool hasFamily;

  const FamilyInvitationState({
    this.isLoading = false,
    this.isValidating = false,
    this.validation,
    this.error,
    this.isAuthenticated = false,
    this.hasFamily = false,
  });
  FamilyInvitationState copyWith({
    bool? isLoading,
    bool? isValidating,
    FamilyInvitationValidationDto? validation,
    String? error,
    bool? isAuthenticated,
    bool? hasFamily,
  }) {
    return FamilyInvitationState(
      isLoading: isLoading ?? this.isLoading,
      isValidating: isValidating ?? this.isValidating,
      validation: validation ?? this.validation,
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      hasFamily: hasFamily ?? this.hasFamily,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FamilyInvitationState &&
        other.isLoading == isLoading &&
        other.isValidating == isValidating &&
        other.validation == validation &&
        other.error == error &&
        other.isAuthenticated == isAuthenticated &&
        other.hasFamily == hasFamily;
  }

  @override
  int get hashCode {
    return Object.hash(
      isLoading,
      isValidating,
      validation,
      error,
      isAuthenticated,
      hasFamily,
    );
  }
}

/// Family invitation provider for managing invitation state and actions
class FamilyInvitationNotifier extends StateNotifier<FamilyInvitationState> {
  final InvitationUseCase _invitationUseCase;
  final AuthService _authService;
  final UserFamilyService _userFamilyService;
  final Ref _ref;

  FamilyInvitationNotifier(
    this._invitationUseCase,
    this._authService,
    this._userFamilyService,
    this._ref,
  ) : super(const FamilyInvitationState()) {
    // ✅ BEST PRACTICE: Set up reactive listener FIRST
    _ref.listen(currentUserProvider, (previous, next) {
      if (next == null && previous != null) {
        // User logged out → clear state automatically
        _onUserLoggedOut();
        AppLogger.info(
          '🔄 [FamilyInvitationNotifier] Auto-cleared state on logout',
        );
      } else if (next != null && previous == null) {
        // User logged in → initialize state
        _onUserLoggedIn(next);
        AppLogger.info(
          '🔄 [FamilyInvitationNotifier] User logged in - initializing state',
        );
      } else if (next != null && previous != null && next.id != previous.id) {
        // Different user logged in → clear and reinitialize
        _onUserLoggedOut();
        _onUserLoggedIn(next);
        AppLogger.info(
          '🔄 [FamilyInvitationNotifier] User switched - reinitializing state',
        );
      }
    });

    // ✅ FIX: Check if user is already logged in (handles initial state)
    // This handles the case where the provider is created while user is already authenticated
    // CRITICAL: Use Future.microtask to defer initialization AFTER constructor completes
    // This prevents circular dependencies during provider construction
    Future.microtask(() {
      if (!mounted) return;
      final currentUser = _ref.read(currentUserProvider);
      if (currentUser != null) {
        _onUserLoggedIn(currentUser);
        AppLogger.info(
          '🔄 [FamilyInvitationNotifier] Provider created with authenticated user - initializing state',
        );
      }
    });
  }

  /// Handle user logout - automatic state clearing
  void _onUserLoggedOut() {
    if (!mounted) return;

    // Clear all invitation-related state immediately
    state = const FamilyInvitationState(); // Reset to empty state
    AppLogger.info(
      '🔄 [FamilyInvitationNotifier] Family invitation state cleared due to user logout',
    );
  }

  /// Handle user login - reinitialize state
  void _onUserLoggedIn(User user) {
    if (!mounted) return;

    // User logged in - reinitialize auth state
    // CRITICAL: Defer async initialization to avoid circular dependency
    Future.microtask(() => _initializeAuthState());
    AppLogger.info('🔄 [FamilyInvitationNotifier] User logged in: ${user.id}');
  }

  void _initializeAuthState() async {
    // Check authentication through current user availability
    final currentUser = _authService.currentUser;
    final isAuthenticated = currentUser != null;

    // Check if user has family using UserFamilyService
    final hasFamily = isAuthenticated
        ? await _userFamilyService.hasFamily(currentUser.id)
        : false;

    if (mounted) {
      state = state.copyWith(
        isAuthenticated: isAuthenticated,
        hasFamily: hasFamily,
      );
    }
  }

  /// Validate an invitation code
  Future<void> validateInvitation(String inviteCode) async {
    state = state.copyWith(isValidating: true);
    final result = await _invitationUseCase.validateFamilyInvitation(
      inviteCode: inviteCode,
    );

    result.fold(
      (failure) {
        // FIXED: Store localization key instead of raw failure.message
        final errorKey = _mapFailureToErrorKey(failure);
        state = state.copyWith(isValidating: false, error: errorKey);
      },
      (validation) {
        // Backend returns HTTP 200 for ALL validations (intentional REST design)
        // Check validation.valid to determine if validation succeeded
        if (validation.valid == false) {
          // Validation failed - map errorCode to localized error key
          final errorKey = _mapValidationErrorToKey(validation);
          state = state.copyWith(isValidating: false, error: errorKey);
        } else {
          // Validation succeeded
          state = state.copyWith(isValidating: false, validation: validation);
        }
      },
    );
  }

  /// Map validation response errorCode to localization key
  /// REFACTORED: Delegates to shared InvitationErrorMapper
  String _mapValidationErrorToKey(FamilyInvitationValidationDto validation) {
    return InvitationErrorMapper.mapValidationErrorToKey(validation.errorCode);
  }

  /// Accept family invitation
  Future<bool> acceptInvitation(
    String inviteCode, {
    bool? leaveCurrentFamily,
  }) async {
    state = state.copyWith(isLoading: true);
    final result = await _invitationUseCase.acceptInvitation(
      inviteCode: inviteCode,
    );

    return result.fold(
      (failure) {
        var errorMessage = failure.message ?? 'errorUnexpected';

        // Handle specific error cases
        if (failure is ServerFailure) {
          switch (failure.statusCode) {
            case 409:
              errorMessage =
                  failure.message ??
                  'Conflict occurred'; // Conflict errors are usually descriptive
              break;
            case 403:
              errorMessage = 'errorUnauthorizedAccess';
              break;
            case 404:
              errorMessage = 'errorInvitationNotFound';
              break;
          }
        }

        state = state.copyWith(isLoading: false, error: errorMessage);
        return false;
      },
      (invitation) async {
        // FIX: Don't set hasFamily=true here - causes UI to show "leave family" button
        // before navigation to dashboard. Let router detect family via loadFamily() below.
        state = state.copyWith(isLoading: false);

        // CRITICAL FIX: Reload family provider to update state immediately
        // This ensures router sees family != null without needing to invalidate
        await _ref.read(familyProvider.notifier).loadFamily();

        // Refresh auth state after successful join
        // Note: Don't await - let it run async to avoid blocking navigation
        _initializeAuthState();

        // CRITICAL: Invalidate family providers to refresh router state after join
        // This is necessary because currentUserProvider doesn't change (same User object)
        // but the user's family membership status has changed in the database
        _ref.invalidate(familyRepositoryProvider);

        // CRITICAL FIX: Also invalidate cachedUserFamilyStatusProvider used by router
        // Without this, router continues reading cached "no family" state and blocks navigation
        final currentUser = _ref.read(currentUserProvider);
        if (currentUser != null) {
          _ref.invalidate(cachedUserFamilyStatusProvider(currentUser.id));
        }

        // CRITICAL FIX: Clear pending navigation to prevent deep link loop
        // After successful family join, clear the invitation deep link navigation
        _ref.read(nav.navigationStateProvider.notifier).clearNavigation();

        AppLogger.info(
          '🔄 [FamilyInvitationNotifier] Reloaded family provider and invalidated cache after family join',
        );
        return true;
      },
    );
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith();
  }

  // REMOVED: reset() method - no longer needed with pure invalidation strategy
  // Provider invalidation automatically recreates fresh state on next access

  /// Map HTTP failure to localization key
  /// NOTE: Backend returns 200 for validation results (valid/invalid)
  /// This method only handles TRUE HTTP errors (network, 500, etc.)
  String _mapFailureToErrorKey(Failure failure) {
    if (failure is NetworkFailure) {
      return 'errorNetworkGeneral';
    } else if (failure is ServerFailure) {
      // Only real HTTP errors reach here (500, 404, etc.)
      // Validation errors (EMAIL_MISMATCH, etc.) are handled in validateInvitation()
      if (failure.statusCode == 404) {
        return 'errorInvitationNotFound';
      } else if (failure.statusCode == 401) {
        return 'errorUnauthorized';
      } else {
        return 'errorServerGeneral';
      }
    } else if (failure is InvitationFailure) {
      return failure.localizationKey;
    } else {
      return 'errorUnexpected';
    }
  }
}

/// Provider for the family invitation notifier
final familyInvitationProvider =
    StateNotifierProvider.autoDispose<
      FamilyInvitationNotifier,
      FamilyInvitationState
    >((ref) {
      final invitationUseCase = ref.watch(invitationUsecaseProvider);
      final authService = ref.watch(authServiceProvider);
      final userFamilyService = ref.watch(userFamilyServiceProvider);
      return FamilyInvitationNotifier(
        invitationUseCase,
        authService,
        userFamilyService,
        ref,
      );
    });
