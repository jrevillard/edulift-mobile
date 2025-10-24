import 'package:edulift/core/utils/app_logger.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';

import 'package:edulift/core/domain/entities/family.dart';
import '../../../../core/services/providers/auth_provider.dart';
import 'family_permission_provider.dart';
import 'family_member_actions_provider.dart';
import 'family_provider.dart';

/// Orchestrated state combining all family permission aspects
class FamilyPermissionOrchestratedState extends Equatable {
  const FamilyPermissionOrchestratedState({
    required this.permissions,
    required this.actions,
    this.lastSyncedAt,
  });

  final AsyncValue<FamilyPermissionState> permissions;
  final FamilyMemberActionsState actions;
  final DateTime? lastSyncedAt;

  /// Helper getters for UI convenience
  bool get isLoading => permissions.isLoading || actions.isProcessing;
  bool get hasError => permissions.hasError || actions.error != null;
  String? get errorMessage =>
      permissions.hasError ? permissions.error.toString() : actions.error;

  /// Get current user role safely
  FamilyRole? get currentUserRole => permissions.valueOrNull?.currentUserRole;

  /// Get family members safely
  List<FamilyMember> get familyMembers =>
      permissions.valueOrNull?.familyMembers ?? [];

  /// Check if current user is admin
  bool get isCurrentUserAdmin {
    final isAdmin = currentUserRole == FamilyRole.admin;
    AppLogger.debug(
      'FamilyPermissionOrchestratedState: currentUserRole=$currentUserRole, isCurrentUserAdmin=$isAdmin',
    );
    return isAdmin;
  }

  /// Create a copy with updated properties
  FamilyPermissionOrchestratedState copyWith({
    AsyncValue<FamilyPermissionState>? permissions,
    FamilyMemberActionsState? actions,
    DateTime? lastSyncedAt,
  }) {
    return FamilyPermissionOrchestratedState(
      permissions: permissions ?? this.permissions,
      actions: actions ?? this.actions,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  List<Object?> get props => [permissions, actions, lastSyncedAt];
}

/// Orchestrator notifier managing all family permission aspects
class FamilyPermissionOrchestratorNotifier
    extends StateNotifier<FamilyPermissionOrchestratedState> {
  FamilyPermissionOrchestratorNotifier({
    required this.familyId,
    required this.ref,
  }) : super(
         const FamilyPermissionOrchestratedState(
           permissions: AsyncValue.loading(),
           actions: FamilyMemberActionsState(),
         ),
       ) {
    // CRITICAL: Listen to auth changes continuously for TRUE reactive architecture
    ref.listen(currentUserProvider, (previous, next) {
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

    _initialize();
    // CRITICAL FIX: Initialize permissions immediately to prevent UI timing regression
    _initializeImmediately();
  }

  final String familyId;
  final Ref ref;

  void _initialize() {
    // Listen to permission changes
    ref.listen<FamilyPermissionState>(familyPermissionProvider, (
      previous,
      next,
    ) {
      // CRITICAL FIX: Preserve admin status during loading to prevent UI regression
      state = state.copyWith(permissions: AsyncValue.data(next));
    });

    // Listen to action changes
    ref.listen<FamilyMemberActionsState>(familyMemberActionsProvider, (
      previous,
      next,
    ) {
      state = state.copyWith(actions: next);
      // If an action completed successfully, refresh permissions
      if (previous?.isProcessing == true &&
          !next.isProcessing &&
          next.error == null &&
          next.lastAction != null) {
        _refreshAfterAction();
      }
    });

    // SYNC FIX: Listen to family provider changes to auto-refresh permissions
    ref.listen<FamilyState>(familyProvider, (previous, next) {
      final authState = ref.read(authStateProvider);
      if (authState.user == null || next.family == null) return;

      // Check if family members changed
      final previousMembers = previous?.family?.members ?? [];
      final currentMembers = next.family?.members ?? [];

      // Auto-refresh permissions if members list changed
      if (_membersChanged(previousMembers, currentMembers)) {
        AppLogger.debug(
          'FamilyPermissionOrchestratorNotifier: Family members changed, auto-refreshing permissions',
        );
        final permissionNotifier = ref.read(familyPermissionProvider.notifier);
        permissionNotifier.loadFamilyPermissions(
          currentUserId: authState.user!.id,
          familyMembers: currentMembers,
        );
      }
    });
  }

  /// Helper to check if family members list changed
  bool _membersChanged(
    List<FamilyMember> previous,
    List<FamilyMember> current,
  ) {
    if (previous.length != current.length) return true;

    // Compare member IDs and roles for changes
    for (var i = 0; i < previous.length; i++) {
      final prevMember = previous[i];
      final currMember = current.firstWhere(
        (m) => m.id == prevMember.id,
        orElse: () => FamilyMember(
          id: '',
          userId: '',
          role: FamilyRole.member,
          status: 'ACTIVE',
          joinedAt: DateTime.now(),
          familyId: familyId,
        ),
      );
      // Member removed or role changed
      if (currMember.id.isEmpty || prevMember.role != currMember.role) {
        return true;
      }
    }

    return false;
  }

  /// CRITICAL FIX: Initialize permissions immediately to prevent loading state regression
  void _initializeImmediately() {
    final currentPermissionState = ref.read(familyPermissionProvider);
    // If permissions are already available, use them immediately
    if (currentPermissionState.currentUserRole != null) {
      state = state.copyWith(
        permissions: AsyncValue.data(currentPermissionState),
      );
    } else {
      // Otherwise, trigger initialization
      WidgetsBinding.instance.addPostFrameCallback((_) {
        initializePermissions();
      });
    }
  }

  /// Initialize permissions for the family
  Future<void> initializePermissions() async {
    AppLogger.debug(
      'FamilyPermissionOrchestratorNotifier: Initializing permissions for family $familyId',
    );
    final authState = ref.read(authStateProvider);
    if (authState.user == null) {
      AppLogger.warning(
        'FamilyPermissionOrchestratorNotifier: No authenticated user found',
      );
      return;
    }
    AppLogger.debug(
      'FamilyPermissionOrchestratorNotifier: Current user ID: ${authState.user!.id}',
    );
    final familyState = ref.read(familyProvider);
    if (familyState.family == null) {
      AppLogger.warning(
        'FamilyPermissionOrchestratorNotifier: No family data available',
      );
      return;
    }

    final membersInfo = familyState.family!.members
        .map(
          (m) =>
              '    - ${m.displayNameOrLoading} (${m.userId}) - Role: ${m.role}',
        )
        .join('\n');
    AppLogger.debug(
      '👥 FamilyPermissionOrchestrator: Family loaded:\n'
      '  - Family ID: ${familyState.family!.id}\n'
      '  - Family name: ${familyState.family!.name}\n'
      '  - Total members: ${familyState.family!.members.length}\n'
      '$membersInfo',
    );

    final permissionNotifier = ref.read(familyPermissionProvider.notifier);
    permissionNotifier.loadFamilyPermissions(
      currentUserId: authState.user!.id,
      familyMembers: familyState.family!.members,
    );
    state = state.copyWith(lastSyncedAt: DateTime.now());
    AppLogger.debug(
      'FamilyPermissionOrchestratorNotifier: Permissions initialization completed',
    );
  }

  /// Get the family member actions notifier for delegation
  FamilyMemberActionsNotifier get memberActions =>
      ref.read(familyMemberActionsProvider.notifier);

  /// Refresh permissions manually
  Future<void> refreshPermissions() async {
    final authState = ref.read(authStateProvider);
    if (authState.user == null) return;

    final familyState = ref.read(familyProvider);
    if (familyState.family == null) {
      AppLogger.warning(
        'FamilyPermissionOrchestratorNotifier: No family data available',
      );
      return;
    }

    final permissionNotifier = ref.read(familyPermissionProvider.notifier);
    permissionNotifier.loadFamilyPermissions(
      currentUserId: authState.user!.id,
      familyMembers: familyState.family!.members,
    );
    state = state.copyWith(lastSyncedAt: DateTime.now());
  }

  /// Refresh permissions after an action completes
  Future<void> _refreshAfterAction() async {
    final authState = ref.read(authStateProvider);
    if (authState.user == null) return;

    // Small delay to ensure backend consistency
    await Future.delayed(const Duration(milliseconds: 500));
    final familyState = ref.read(familyProvider);
    if (familyState.family == null) {
      AppLogger.warning(
        'FamilyPermissionOrchestratorNotifier: No family data available',
      );
      return;
    }

    final permissionNotifier = ref.read(familyPermissionProvider.notifier);
    permissionNotifier.loadFamilyPermissions(
      currentUserId: authState.user!.id,
      familyMembers: familyState.family!.members,
    );
    state = state.copyWith(lastSyncedAt: DateTime.now());
  }

  /// Clear all errors
  void clearErrors() {
    ref.read(familyPermissionProvider.notifier).clearError();
    ref.read(familyMemberActionsProvider.notifier).clearError();
  }

  /// Handle user logout - automatic state clearing
  void _onUserLoggedOut() {
    if (!mounted) return;
    // Clear all state immediately
    state = const FamilyPermissionOrchestratedState(
      permissions: AsyncValue.loading(),
      actions: FamilyMemberActionsState(),
    );
  }

  /// Handle user login - optional data reloading
  void _onUserLoggedIn(dynamic user) {
    if (!mounted) return;
    // User logged in - optionally reload permissions
    initializePermissions();
  }
}

/// Main orchestrator provider for family permissions
/// CRITICAL FIX: Use autoDispose with keepAlive to prevent disposal during navigation
final familyPermissionOrchestratorProvider = StateNotifierProvider.family
    .autoDispose<
      FamilyPermissionOrchestratorNotifier,
      FamilyPermissionOrchestratedState,
      String
    >((ref, familyId) {
      // ARCHITECTURE FIX: Keep alive to prevent disposal during tab navigation
      // This prevents re-fetching permissions on every navigation
      ref.keepAlive();
      return FamilyPermissionOrchestratorNotifier(familyId: familyId, ref: ref);
    });

/// Convenience providers for UI components

/// Provider to check if current user can perform any member actions
/// CRITICAL FIX: Use autoDispose to prevent stale cached values after navigation
/// Without autoDispose, the provider caches the result and doesn't recalculate
/// even when the underlying orchestratedState changes, causing FAB to not reopen
final canPerformMemberActionsProvider = Provider.autoDispose.family<bool, String>((
  ref,
  familyId,
) {
  AppLogger.debug(
    'canPerformMemberActionsProvider: Watching permissions for family $familyId',
  );
  final orchestratedState = ref.watch(
    familyPermissionOrchestratorProvider(familyId),
  );
  final isAdmin = orchestratedState.isCurrentUserAdmin;

  AppLogger.debug(
    'canPerformMemberActionsProvider: Returning isAdmin=$isAdmin for family $familyId',
  );
  return isAdmin;
});

/// Helper class for permission sync status
class PermissionSyncStatus extends Equatable {
  const PermissionSyncStatus({
    required this.isLoading,
    required this.hasError,
    this.lastSyncedAt,
  });

  final bool isLoading;
  final DateTime? lastSyncedAt;
  final bool hasError;

  bool get isStale =>
      lastSyncedAt != null &&
      DateTime.now().difference(lastSyncedAt!).inMinutes > 5;

  @override
  List<Object?> get props => [isLoading, lastSyncedAt, hasError];
}

/// Provider for permission sync status
final permissionSyncStatusProvider =
    Provider.family<PermissionSyncStatus, String>((ref, familyId) {
      final orchestratedState = ref.watch(
        familyPermissionOrchestratorProvider(familyId),
      );
      return PermissionSyncStatus(
        isLoading: orchestratedState.isLoading,
        lastSyncedAt: orchestratedState.lastSyncedAt,
        hasError: orchestratedState.hasError,
      );
    });
