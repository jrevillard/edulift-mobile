import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/services/providers/auth_provider.dart';
import 'family_permission_provider.dart';

/// State for family member actions (promote, demote, remove)
class FamilyMemberActionsState extends Equatable {
  const FamilyMemberActionsState({
    this.isProcessing = false,
    this.processingMemberId,
    this.lastAction,
    this.error,
  });

  /// Whether an action is currently being processed
  final bool isProcessing;

  /// ID of the member currently being processed
  final String? processingMemberId;

  /// Last successful action performed
  final MemberAction? lastAction;

  /// Error message if action failed
  final String? error;

  FamilyMemberActionsState copyWith({
    bool? isProcessing,
    String? processingMemberId,
    MemberAction? lastAction,
    String? error,
  }) {
    return FamilyMemberActionsState(
      isProcessing: isProcessing ?? this.isProcessing,
      processingMemberId: processingMemberId,
      lastAction: lastAction ?? this.lastAction,
      error: error,
    );
  }

  FamilyMemberActionsState clearError() {
    return copyWith();
  }

  bool isProcessingMember(String memberId) {
    return isProcessing && processingMemberId == memberId;
  }

  @override
  List<Object?> get props => [
        isProcessing,
        processingMemberId,
        lastAction,
        error,
      ];
}

/// Enumeration of possible member actions
enum MemberActionType { promote, demote, remove }

/// Represents a completed member action
class MemberAction extends Equatable {
  const MemberAction({
    required this.type,
    required this.memberId,
    required this.memberName,
    required this.timestamp,
  });
  final MemberActionType type;
  final String memberId;
  final String memberName;
  final DateTime timestamp;

  @override
  List<Object?> get props => [type, memberId, memberName, timestamp];
}

/// Notifier for managing family member actions
class FamilyMemberActionsNotifier
    extends StateNotifier<FamilyMemberActionsState> {
  final Ref _ref;

  FamilyMemberActionsNotifier(this._ref)
      : super(const FamilyMemberActionsState()) {
    // CRITICAL: Listen to auth changes continuously for TRUE reactive architecture
    _ref.listen(currentUserProvider, (previous, next) {
      if (next == null && previous != null) {
        // User logged out → clear state automatically
        _onUserLoggedOut();
      } else if (next != null && previous == null) {
        // User logged in → optionally reload data
        _onUserLoggedIn(next);
      } else if (next != null && previous != null && next.id != previous.id) {
        // Different user logged in → clear and reinitialize
        _onUserLoggedOut();
        _onUserLoggedIn(next);
      }
    });
  }

  // final FamilyMembersRepository _familyMembersRepository; // Removed unused field

  /// Promote member to admin (state tracking only - delegates to family provider)
  Future<bool> promoteMemberToAdmin({
    required String memberId,
    required String memberName,
    required Future<void> Function() repositoryAction,
  }) async {
    return _performMemberAction(
      memberId: memberId,
      memberName: memberName,
      actionType: MemberActionType.promote,
      action: repositoryAction,
    );
  }

  /// Demote admin to member (state tracking only - delegates to family provider)
  Future<bool> demoteMemberToMember({
    required String memberId,
    required String memberName,
    required Future<void> Function() repositoryAction,
  }) async {
    return _performMemberAction(
      memberId: memberId,
      memberName: memberName,
      actionType: MemberActionType.demote,
      action: repositoryAction,
    );
  }

  /// Remove member from family (state tracking only - delegates to family provider)
  Future<bool> removeMember({
    required String memberId,
    required String memberName,
    required Future<void> Function() repositoryAction,
  }) async {
    return _performMemberAction(
      memberId: memberId,
      memberName: memberName,
      actionType: MemberActionType.remove,
      action: repositoryAction,
    );
  }

  /// Generic method to perform member actions with consistent error handling
  Future<bool> _performMemberAction({
    required String memberId,
    required String memberName,
    required MemberActionType actionType,
    required Future<void> Function() action,
  }) async {
    try {
      state = state.copyWith(isProcessing: true, processingMemberId: memberId);
      await action();
      state = state.copyWith(
        isProcessing: false,
        lastAction: MemberAction(
          type: actionType,
          memberId: memberId,
          memberName: memberName,
          timestamp: DateTime.now(),
        ),
      );
      return true;
    } catch (error) {
      final errorMessage = error.toString();
      state = state.copyWith(isProcessing: false, error: errorMessage);
      return false;
    }
  }

  /// Clear current error
  void clearError() {
    state = state.copyWith();
  }

  /// Handle user logout - automatic state clearing
  void _onUserLoggedOut() {
    if (!mounted) return;
    // Clear all state immediately
    state = const FamilyMemberActionsState();
  }

  /// Handle user login - optional data reloading
  void _onUserLoggedIn(dynamic user) {
    if (!mounted) return;
    // User logged in - action state doesn't need reloading
  }

  // REMOVED: reset() method - no longer needed with pure invalidation strategy
  // Provider invalidation automatically recreates fresh state on next access
}

/// Provider for family member actions
final familyMemberActionsProvider = StateNotifierProvider<
    FamilyMemberActionsNotifier, FamilyMemberActionsState>((ref) {
  return FamilyMemberActionsNotifier(ref);
});

/// Provider to check if a specific member is being processed
final isMemberBeingProcessedProvider = Provider.family<bool, String>((
  ref,
  memberId,
) {
  final actionsState = ref.watch(familyMemberActionsProvider);
  return actionsState.isProcessingMember(memberId);
});

/// Provider for the last completed action
final lastMemberActionProvider = Provider<MemberAction?>((ref) {
  final actionsState = ref.watch(familyMemberActionsProvider);
  return actionsState.lastAction;
});

/// Provider that combines permissions and actions for UI components
final memberActionCapabilitiesProvider =
    Provider.family<MemberActionCapabilities, String>((ref, memberId) {
  final actionsState = ref.watch(familyMemberActionsProvider);
  final memberPermissions = ref.watch(memberPermissionsProvider(memberId));
  return MemberActionCapabilities(
    canPromote: memberPermissions.canPromote,
    canDemote: memberPermissions.canDemote,
    canRemove: memberPermissions.canRemove,
    isProcessing: actionsState.isProcessingMember(memberId),
    hasError: actionsState.error != null,
    errorMessage: actionsState.error,
  );
});

/// Helper class combining permission checks and action states for UI
class MemberActionCapabilities extends Equatable {
  const MemberActionCapabilities({
    required this.canPromote,
    required this.canDemote,
    required this.canRemove,
    required this.isProcessing,
    required this.hasError,
    this.errorMessage,
  });
  final bool canPromote;
  final bool canDemote;
  final bool canRemove;
  final bool isProcessing;
  final bool hasError;
  final String? errorMessage;

  bool get hasAnyAction => canPromote || canDemote || canRemove;

  @override
  List<Object?> get props => [
        canPromote,
        canDemote,
        canRemove,
        isProcessing,
        hasError,
        errorMessage,
      ];
}
