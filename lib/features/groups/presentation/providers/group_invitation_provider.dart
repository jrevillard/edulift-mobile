// EduLift Mobile - Group Invitation Provider
// Riverpod provider for managing group invitation state
// Follows the exact pattern from FamilyInvitationProvider

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/core/domain/services/auth_service.dart';
import 'package:edulift/core/domain/failures/invitation_failure.dart';
import 'package:edulift/core/services/providers/auth_provider.dart';
import 'package:edulift/core/domain/entities/user.dart';
import 'package:edulift/core/utils/app_logger.dart';
import 'package:edulift/core/di/providers/providers.dart';
import 'package:edulift/core/services/invitation_error_mapper.dart';
import 'package:edulift/core/services/user_family_service.dart';
import 'package:edulift/core/network/group_api_client.dart';
import '../../domain/repositories/group_repository.dart';

/// Group invitation state
class GroupInvitationState {
  final bool isLoading;
  final bool isValidating;
  final GroupInvitationValidationData? validation;
  final String?
      validatedCode; // Store the validated invitation code for manual entry flow
  final String? error;
  final bool isAuthenticated;
  final bool hasFamily; // Group invitations require user to have a family

  const GroupInvitationState({
    this.isLoading = false,
    this.isValidating = false,
    this.validation,
    this.validatedCode,
    this.error,
    this.isAuthenticated = false,
    this.hasFamily = false,
  });

  GroupInvitationState copyWith({
    bool? isLoading,
    bool? isValidating,
    GroupInvitationValidationData? validation,
    String? validatedCode,
    String? error,
    bool? isAuthenticated,
    bool? hasFamily,
  }) {
    return GroupInvitationState(
      isLoading: isLoading ?? this.isLoading,
      isValidating: isValidating ?? this.isValidating,
      validation: validation ?? this.validation,
      validatedCode: validatedCode ?? this.validatedCode,
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      hasFamily: hasFamily ?? this.hasFamily,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GroupInvitationState &&
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

/// Group invitation provider for managing invitation state and actions
class GroupInvitationNotifier extends StateNotifier<GroupInvitationState> {
  final GroupRepository _groupRepository;
  final AuthService _authService;
  final UserFamilyService _userFamilyService;
  final Ref _ref;

  GroupInvitationNotifier(
    this._groupRepository,
    this._authService,
    this._userFamilyService,
    this._ref,
  ) : super(const GroupInvitationState()) {
    // ✅ BEST PRACTICE: Set up reactive listener FIRST
    _ref.listen(currentUserProvider, (previous, next) {
      if (next == null && previous != null) {
        // User logged out → clear state automatically
        _onUserLoggedOut();
        AppLogger.info(
          '🔄 [GroupInvitationNotifier] Auto-cleared state on logout',
        );
      } else if (next != null && previous == null) {
        // User logged in → initialize state
        _onUserLoggedIn(next);
        AppLogger.info(
          '🔄 [GroupInvitationNotifier] User logged in - initializing state',
        );
      } else if (next != null && previous != null && next.id != previous.id) {
        // Different user logged in → clear and reinitialize
        _onUserLoggedOut();
        _onUserLoggedIn(next);
        AppLogger.info(
          '🔄 [GroupInvitationNotifier] User switched - reinitializing state',
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
          '🔄 [GroupInvitationNotifier] Provider created with authenticated user - initializing state',
        );
      }
    });
  }

  /// Handle user logout - automatic state clearing
  void _onUserLoggedOut() {
    if (!mounted) return;

    // Clear all invitation-related state immediately
    state = const GroupInvitationState(); // Reset to empty state
    AppLogger.info(
      '🔄 [GroupInvitationNotifier] Group invitation state cleared due to user logout',
    );
  }

  /// Handle user login - reinitialize state
  void _onUserLoggedIn(User user) {
    if (!mounted) return;

    // User logged in - reinitialize auth state
    _initializeAuthState();
    AppLogger.info('🔄 [GroupInvitationNotifier] User logged in: ${user.id}');
  }

  void _initializeAuthState() async {
    // Check authentication through current user availability
    final currentUser = _authService.currentUser;
    final isAuthenticated = currentUser != null;

    // For group invitations, we need to check if user has a family
    // This is because groups are comprised of families, not individual users
    final hasFamily =
        isAuthenticated ? await _checkIfUserHasFamily(currentUser.id) : false;

    if (mounted) {
      state = state.copyWith(
        isAuthenticated: isAuthenticated,
        hasFamily: hasFamily,
      );
    }
  }

  /// Check if user has a family (required for group invitations)
  Future<bool> _checkIfUserHasFamily(String userId) async {
    return await _userFamilyService.hasFamily(userId);
  }

  /// Validate an invitation code
  Future<void> validateInvitation(String inviteCode) async {
    // Clear previous error and validation before validating
    state = GroupInvitationState(
      isValidating: true,
      isAuthenticated: state.isAuthenticated,
      hasFamily: state.hasFamily,
    );
    final result = await _groupRepository.validateInvitation(inviteCode);

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
          // Clear validation when there's an error
          state = GroupInvitationState(
            error: errorKey,
            isAuthenticated: state.isAuthenticated,
            hasFamily: state.hasFamily,
          );
        } else {
          // Validation succeeded - set validation data and store the code
          state = state.copyWith(
            isValidating: false,
            validation: validation,
            validatedCode: inviteCode, // Store code for manual entry flow
          );
        }
      },
    );
  }

  /// Map validation response errorCode to localization key
  /// REFACTORED: Delegates to shared InvitationErrorMapper
  String _mapValidationErrorToKey(GroupInvitationValidationData validation) {
    return InvitationErrorMapper.mapValidationErrorToKey(validation.errorCode);
  }

  /// Accept group invitation by invite code
  Future<bool> acceptGroupInvitationByCode(String inviteCode) async {
    state = state.copyWith(isLoading: true);
    final result = await _groupRepository.joinGroup(inviteCode);

    return result.fold(
      (failure) {
        var errorMessage = failure.message ?? 'errorUnexpected';

        // Handle specific error cases
        if (failure is ServerFailure) {
          switch (failure.statusCode) {
            case 409:
              errorMessage = failure.message ??
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
      (group) {
        state = state.copyWith(isLoading: false);
        // Refresh auth state after successful join
        _initializeAuthState();

        AppLogger.info(
          '✅ [GroupInvitationNotifier] Successfully joined group: ${group.name}',
        );
        return true;
      },
    );
  }

  /// Clear error state
  void clearError() {
    // Clear error and validation to return to manual input
    state = GroupInvitationState(
      isAuthenticated: state.isAuthenticated,
      hasFamily: state.hasFamily,
    );
  }

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

/// Provider for the group invitation notifier
final groupInvitationProvider = StateNotifierProvider.autoDispose<
    GroupInvitationNotifier, GroupInvitationState>((ref) {
  final groupRepository = ref.watch(groupRepositoryProvider);
  final authService = ref.watch(authServiceProvider);
  final userFamilyService = ref.watch(userFamilyServiceProvider);
  return GroupInvitationNotifier(
    groupRepository,
    authService,
    userFamilyService,
    ref,
  );
});
