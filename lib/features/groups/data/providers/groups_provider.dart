import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/group_repository.dart';
import '../../../../core/domain/entities/groups/group.dart';
import 'package:edulift/core/di/providers/providers.dart';

// Provider for groups repository - this creates a duplicate name
// Use the core repository provider from repository_providers.dart instead

/// Groups state following Family pattern architecture
class GroupsState {
  final List<Group> groups;
  final bool isLoading;
  final String? error; // Error when loading groups list
  final String? joinError; // Error when joining a group (separate from list loading error)
  final String? createError; // Error when creating a group (separate from list loading error)
  final bool isCreateSuccess; // Flag to indicate successful group creation

  const GroupsState({
    this.groups = const [],
    this.isLoading = false,
    this.error,
    this.joinError,
    this.createError,
    this.isCreateSuccess = false,
  });

  GroupsState copyWith({
    List<Group>? groups,
    bool? isLoading,
    String? error,
    String? joinError,
    String? createError,
    bool? isCreateSuccess,
  }) {
    return GroupsState(
      groups: groups ?? this.groups,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      joinError: joinError ?? this.joinError,
      createError: createError ?? this.createError,
      isCreateSuccess: isCreateSuccess ?? this.isCreateSuccess,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GroupsState &&
        other.groups == groups &&
        other.isLoading == isLoading &&
        other.error == error &&
        other.joinError == joinError &&
        other.createError == createError &&
        other.isCreateSuccess == isCreateSuccess;
  }

  @override
  int get hashCode {
    return Object.hash(groups, isLoading, error, joinError, createError, isCreateSuccess);
  }
}

/// Group detail state for individual group loading
class GroupDetailState {
  final dynamic group;
  final bool isLoading;
  final String? error;

  const GroupDetailState({
    this.group,
    this.isLoading = false,
    this.error,
  });

  GroupDetailState copyWith({
    dynamic group,
    bool? isLoading,
    String? error,
  }) {
    return GroupDetailState(
      group: group ?? this.group,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GroupDetailState &&
        other.group == group &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(group, isLoading, error);
  }
}

// Provider for groups state
final groupsProvider =
    StateNotifierProvider<GroupsNotifier, GroupsState>((ref) {
      final repository = ref.watch(groupRepositoryProvider);
      return GroupsNotifier(repository);
    });

// Provider for individual group details - compliant with Family pattern
final groupDetailProvider =
    StateNotifierProvider.family<GroupDetailNotifier, GroupDetailState, String>((ref, groupId) {
      final repository = ref.watch(groupRepositoryProvider);
      return GroupDetailNotifier(repository, groupId);
    });
// Provider for group families/members
final groupFamiliesProvider = FutureProvider.family<List<dynamic>, String>((
  ref,
  groupId,
) async {
  // final repository = ref.watch(groupsRepositoryProvider); // TODO: Use when implementing getGroupFamilies
  // TODO: Implement getGroupFamilies in GroupRepository interface
  // For now, return empty list
  return <dynamic>[];
});
class GroupsNotifier extends StateNotifier<GroupsState> {
  final GroupRepository _repository;

  GroupsNotifier(this._repository) : super(const GroupsState(isLoading: true)) {
    loadUserGroups();
  }

  /// Load user's groups with proper error handling
  Future<void> loadUserGroups() async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.getGroups();

    if (result.isOk) {
      final groups = result.value!;
      state = state.copyWith(isLoading: false, groups: groups);
    } else {
      final apiFailure = result.error!;
      final errorKey = _getErrorMessage(apiFailure);
      state = state.copyWith(isLoading: false, error: errorKey);
    }
  }
  /// Get appropriate error message key based on API failure
  /// Returns localization keys that will be translated by the UI using l10n.translateError()
  String _getErrorMessage(dynamic apiFailure) {
    // Check for specific error messages from backend FIRST (before status code mapping)
    // This allows more specific error messages to override generic status code mappings
    final message = apiFailure?.message as String?;
    if (message != null) {
      // Map backend error messages to i18n keys (case-insensitive)
      final lowerMessage = message.toLowerCase();

      // Check for invitation-specific errors (these can be 400 or 404)
      if (lowerMessage.contains('invalid') &&
          (lowerMessage.contains('invitation') || lowerMessage.contains('code'))) {
        return 'errorInvalidInvitationCode';
      }
      if (lowerMessage.contains('expired') &&
          (lowerMessage.contains('invitation') || lowerMessage.contains('code'))) {
        return 'errorInvalidInvitationCode';
      }

      // Other specific errors
      if (lowerMessage.contains('already has a pending invitation')) {
        return 'errorFamilyAlreadyInvited';
      }
      if (lowerMessage.contains('already a member')) {
        return 'errorFamilyAlreadyMember';
      }
      if (lowerMessage.contains('insufficient permissions') ||
          lowerMessage.contains('not authorized')) {
        return 'errorInsufficientPermissions';
      }
    }

    // Map by status code only if no specific message match was found
    if (apiFailure?.statusCode == 400) {
      return 'errorInvalidData';
    } else if (apiFailure?.statusCode == 401) {
      return 'errorUnauthorized';
    } else if (apiFailure?.statusCode == 403) {
      return 'errorAccessDenied';
    } else if (apiFailure?.statusCode == 404) {
      return 'errorGroupNotFound';
    } else if (apiFailure?.statusCode == 500) {
      return 'errorServerGeneral';
    } else if (apiFailure?.statusCode == 0) {
      // Network error
      return 'errorNetworkGeneral';
    } else {
      // Always return i18n key, never raw message
      return 'errorUnexpected';
    }
  }

  /// Create a new group with proper error handling
  /// Returns true on success, false on failure (error stored in state.createError)
  Future<bool> createGroup(String name) async {
    state = state.copyWith(isLoading: true);
    final command = CreateGroupCommand(name: name);
    final result = await _repository.createGroup(command);

    if (result.isOk) {
      // Use the created group from the REST response (already cached by repository)
      final newGroup = result.value!;

      // Add the new group to the state instead of reloading everything
      final updatedGroups = [...state.groups, newGroup];

      state = state.copyWith(
        groups: updatedGroups,
        isLoading: false,
        isCreateSuccess: true,
      );
      return true;
    } else {
      final apiFailure = result.error!;
      final errorKey = _getErrorMessage(apiFailure);
      state = state.copyWith(isLoading: false, createError: errorKey, isCreateSuccess: false);
      return false;
    }
  }

  /// Join a group with invite code with proper error handling
  /// Returns true on success, false on failure (error stored in state.joinError)
  Future<bool> joinGroup(String inviteCode) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.joinGroup(inviteCode);

    if (result.isOk) {
      // Use the joined group from the REST response (already cached by repository)
      final joinedGroup = result.value!;

      // Add the joined group to the state instead of reloading everything
      final updatedGroups = [...state.groups, joinedGroup];

      state = state.copyWith(
        groups: updatedGroups,
        isLoading: false,
      );
      return true;
    } else {
      final apiFailure = result.error!;
      final errorKey = _getErrorMessage(apiFailure);
      state = state.copyWith(isLoading: false, joinError: errorKey);
      return false;
    }
  }

  /// Leave a group
  /// Returns true on success, false on failure (error stored in state.error)
  Future<bool> leaveGroup(String groupId) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.leaveGroup(groupId);

    if (result.isOk) {
      // Remove the left group from the state instead of reloading everything
      final updatedGroups = state.groups
          .where((group) => group.id != groupId)
          .toList();

      state = state.copyWith(
        groups: updatedGroups,
        isLoading: false,
      );
      return true;
    } else {
      final apiFailure = result.error!;
      final errorKey = _getErrorMessage(apiFailure);
      state = state.copyWith(isLoading: false, error: errorKey);
      return false;
    }
  }

  /// Update a group
  /// Returns true on success, false on failure (error stored in state.error)
  Future<bool> updateGroup(String groupId, Map<String, dynamic> updates) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.updateGroup(groupId, updates);

    if (result.isOk) {
      // Use the updated group from the REST response (already cached by repository)
      final updatedGroup = result.value!;

      // Update just this group in the state instead of reloading everything
      final updatedGroups = state.groups.map((group) {
        return group.id == groupId ? updatedGroup : group;
      }).toList();

      state = state.copyWith(
        groups: updatedGroups,
        isLoading: false,
      );
      return true;
    } else {
      final apiFailure = result.error!;
      final errorKey = _getErrorMessage(apiFailure);
      state = state.copyWith(isLoading: false, error: errorKey);
      return false;
    }
  }

  /// Delete a group
  /// Returns true on success, false on failure (error stored in state.error)
  Future<bool> deleteGroup(String groupId) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.deleteGroup(groupId);

    if (result.isOk) {
      // Remove the deleted group from the state instead of reloading everything
      final updatedGroups = state.groups
          .where((group) => group.id != groupId)
          .toList();

      state = state.copyWith(
        groups: updatedGroups,
        isLoading: false,
      );
      return true;
    } else {
      final apiFailure = result.error!;
      final errorKey = _getErrorMessage(apiFailure);
      state = state.copyWith(isLoading: false, error: errorKey);
      return false;
    }
  }

  /// Refresh groups data
  Future<void> refresh() async {
    await loadUserGroups();
  }

  /// Clear error state (both list loading error and join error)
  void clearError() {
    state = GroupsState(
      groups: state.groups,
    );
  }

  /// Clear only join error (keep list loading error and create error if any)
  void clearJoinError() {
    state = GroupsState(
      groups: state.groups,
      error: state.error,
      createError: state.createError,
    );
  }

  /// Clear only create error (keep list loading error and join error if any)
  void clearCreateError() {
    state = GroupsState(
      groups: state.groups,
      error: state.error,
      joinError: state.joinError,
      isCreateSuccess: state.isCreateSuccess,
    );
  }

  /// Reset create success flag after navigation
  void resetCreateSuccess() {
    state = state.copyWith(isCreateSuccess: false);
  }

  /// Clear groups state
  void clear() {
    state = const GroupsState();
  }
}

/// Notifier for individual group details following Family pattern
class GroupDetailNotifier extends StateNotifier<GroupDetailState> {
  final GroupRepository _repository;
  final String _groupId;

  GroupDetailNotifier(this._repository, this._groupId)
      : super(const GroupDetailState(isLoading: true)) {
    loadGroup(_groupId);
  }

  /// Load group details with proper error handling
  /// Returns the group data or null on failure (error stored in state.error)
  Future<dynamic> loadGroup(String groupId) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.getGroup(groupId);

    if (result.isOk) {
      final group = result.value!;
      state = GroupDetailState(
        group: group,
      );
      return group;
    } else {
      final apiFailure = result.error!;
      final errorKey = _getErrorMessage(apiFailure);
      state = GroupDetailState(
        group: state.group,
        error: errorKey,
      );
      return null;
    }
  }

  /// Get appropriate error message key based on API failure
  String _getErrorMessage(dynamic apiFailure) {
    final message = apiFailure?.message as String?;
    if (message != null) {
      final lowerMessage = message.toLowerCase();

      if (lowerMessage.contains('invalid') &&
          (lowerMessage.contains('invitation') || lowerMessage.contains('code'))) {
        return 'errorInvalidInvitationCode';
      }
      if (lowerMessage.contains('expired') &&
          (lowerMessage.contains('invitation') || lowerMessage.contains('code'))) {
        return 'errorInvalidInvitationCode';
      }
      if (lowerMessage.contains('already has a pending invitation')) {
        return 'errorFamilyAlreadyInvited';
      }
      if (lowerMessage.contains('already a member')) {
        return 'errorFamilyAlreadyMember';
      }
      if (lowerMessage.contains('insufficient permissions') ||
          lowerMessage.contains('not authorized')) {
        return 'errorInsufficientPermissions';
      }
    }

    if (apiFailure?.statusCode == 400) {
      return 'errorInvalidData';
    } else if (apiFailure?.statusCode == 401) {
      return 'errorUnauthorized';
    } else if (apiFailure?.statusCode == 403) {
      return 'errorAccessDenied';
    } else if (apiFailure?.statusCode == 404) {
      return 'errorGroupNotFound';
    } else if (apiFailure?.statusCode == 500) {
      return 'errorServerGeneral';
    } else if (apiFailure?.statusCode == 0) {
      return 'errorNetworkGeneral';
    } else {
      return 'errorUnexpected';
    }
  }

  /// Clear error state
  void clearError() {
    state = GroupDetailState(
      group: state.group,
    );
  }
}
