import 'package:edulift/core/utils/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';

import 'package:edulift/core/domain/entities/family.dart';
import '../../../../core/services/providers/auth_provider.dart';

/// State representing family permissions for the current user
class FamilyPermissionState extends Equatable {
  const FamilyPermissionState({
    this.currentUserRole,
    this.familyMembers = const [],
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  /// Current user's role in the active family
  final FamilyRole? currentUserRole;

  /// List of all family members with their roles
  final List<FamilyMember> familyMembers;

  /// Loading state
  final bool isLoading;

  /// Error state
  final String? error;

  /// When permissions were last updated (for cache invalidation)
  final DateTime? lastUpdated;

  /// Create copy with updated fields
  FamilyPermissionState copyWith({
    FamilyRole? currentUserRole,
    List<FamilyMember>? familyMembers,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return FamilyPermissionState(
      currentUserRole: currentUserRole ?? this.currentUserRole,
      familyMembers: familyMembers ?? this.familyMembers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Clear error state
  FamilyPermissionState clearError() {
    return copyWith();
  }

  /// Check if current user is admin
  bool get isCurrentUserAdmin => currentUserRole == FamilyRole.admin;

  /// Check if current user is member
  bool get isCurrentUserMember => currentUserRole == FamilyRole.member;

  /// Check if current user has permission to manage members
  bool get canManageMembers => isCurrentUserAdmin;

  /// Check if current user can promote members
  bool get canPromoteMembers => isCurrentUserAdmin;

  /// Check if current user can remove members
  bool get canRemoveMembers => isCurrentUserAdmin;

  /// Check if current user can update family settings
  bool get canUpdateFamilySettings => isCurrentUserAdmin;

  /// Get member by user ID
  FamilyMember getMemberByUserId(String userId) {
    // NO FALLBACK: Member not found is a BUG that should be visible!
    return familyMembers.firstWhere((member) => member.userId == userId);
  }

  /// Check if specific user can be promoted by current user
  /// [currentUserId] - ID of the current logged-in user making the request
  bool canPromoteMember(String userId, String currentUserId) {
    if (!canPromoteMembers) return false;

    // NO FALLBACK: Member not found should throw exception to expose bugs!
    try {
      final member = getMemberByUserId(userId);

      // Match web frontend logic: Can promote/demote any member except cannot demote own admin role
      if (member.isAdmin && member.userId == currentUserId) {
        return false; // Cannot demote own admin role (lockout prevention)
      }

      return true;
    } catch (e) {
      // Member not found - this is a bug that should be visible!
      return false;
    }
  }

  /// Check if specific user can be removed by current user
  /// [currentUserId] - ID of the current logged-in user making the request
  bool canRemoveMember(String userId, String currentUserId) {
    if (!canRemoveMembers) return false;

    // NO FALLBACK: Member not found should throw exception to expose bugs!
    try {
      final member = getMemberByUserId(userId);

      // Match web frontend logic: Can remove any member including other admins
      // Current user cannot remove themselves (should use "Leave Family" instead)
      return member.userId != currentUserId;
    } catch (e) {
      // Member not found - this is a bug that should be visible!
      return false;
    }
  }

  @override
  List<Object?> get props => [
    currentUserRole,
    familyMembers,
    isLoading,
    error,
    lastUpdated,
  ];
}

/// Notifier managing family permissions state following existing patterns
/// OPTIMIZATION FIX: Removed _familyRepository dependency
class FamilyPermissionNotifier extends StateNotifier<FamilyPermissionState> {
  final Ref _ref;

  FamilyPermissionNotifier(this._ref) : super(const FamilyPermissionState()) {
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

  /// Load family permissions for current user and family
  /// OPTIMIZATION FIX: Use provided family data
  void loadFamilyPermissions({
    required String currentUserId,
    required List<FamilyMember> familyMembers,
  }) {
    try {
      AppLogger.debug(
        'FamilyPermissionNotifier: Loading permissions for user $currentUserId',
      );
      state = state.copyWith(isLoading: true);
      final members = familyMembers;
      AppLogger.debug(
        'FamilyPermissionNotifier: Got ${members.length} family members',
      );
      final currentUserMember = members.firstWhere(
        (member) => member.userId == currentUserId,
        orElse: () {
          AppLogger.warning(
            'FamilyPermissionNotifier: Current user $currentUserId not found in family members',
          );
          throw Exception('Current user is not a member of this family');
        },
      );
      AppLogger.debug(
        'FamilyPermissionNotifier: Current user role is ${currentUserMember.role}',
      );
      state = state.copyWith(
        currentUserRole: currentUserMember.role,
        familyMembers: members,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
      AppLogger.debug(
        'FamilyPermissionNotifier: Permissions loaded successfully',
      );
    } catch (error) {
      final errorMessage = error.toString();
      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  /// Clear current error
  void clearError() {
    state = state.copyWith();
  }

  /// Invalidate permissions cache and reload
  void invalidateAndReload({
    required String currentUserId,
    required List<FamilyMember> familyMembers,
  }) {
    loadFamilyPermissions(
      currentUserId: currentUserId,
      familyMembers: familyMembers,
    );
  }

  /// Handle user logout - automatic state clearing
  void _onUserLoggedOut() {
    if (!mounted) return;
    // Clear all state immediately
    state = const FamilyPermissionState();
  }

  /// Handle user login - optional data reloading
  void _onUserLoggedIn(dynamic user) {
    if (!mounted) return;
    // User logged in - permissions will be loaded by orchestrator
  }
}

/// Family permission provider following existing provider patterns
final familyPermissionProvider =
    StateNotifierProvider<FamilyPermissionNotifier, FamilyPermissionState>((
      ref,
    ) {
      return FamilyPermissionNotifier(ref);
    });

/// Provider for current user's role in active family
final currentUserFamilyRoleProvider = Provider<FamilyRole?>((ref) {
  final permissionState = ref.watch(familyPermissionProvider);
  return permissionState.currentUserRole;
});

/// Provider checking if current user is admin
final isCurrentUserAdminProvider = Provider<bool>((ref) {
  final permissionState = ref.watch(familyPermissionProvider);
  return permissionState.isCurrentUserAdmin;
});

/// Provider checking if current user can manage members
final canManageMembersProvider = Provider<bool>((ref) {
  final permissionState = ref.watch(familyPermissionProvider);
  return permissionState.canManageMembers;
});

/// Provider for getting specific member permissions
final memberPermissionsProvider = Provider.family<MemberPermissions, String>((
  ref,
  userId,
) {
  final permissionState = ref.watch(familyPermissionProvider);
  final authState = ref.watch(authStateProvider);
  final currentUserId = authState.user?.id ?? '';
  final member = permissionState.getMemberByUserId(userId);
  return MemberPermissions(
    member: member,
    canPromote: permissionState.canPromoteMember(userId, currentUserId),
    canRemove: permissionState.canRemoveMember(userId, currentUserId),
    canDemote: member.isAdmin ? permissionState.canManageMembers : false,
  );
});

/// Helper class for member-specific permissions
class MemberPermissions extends Equatable {
  const MemberPermissions({
    required this.member,
    required this.canPromote,
    required this.canRemove,
    required this.canDemote,
  });

  final FamilyMember? member;
  final bool canPromote;
  final bool canRemove;
  final bool canDemote;

  @override
  List<Object?> get props => [member, canPromote, canRemove, canDemote];
}
