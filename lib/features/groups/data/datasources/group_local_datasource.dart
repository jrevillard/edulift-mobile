// EduLift Mobile - Group Local Data Source Interface
// Clean Architecture local storage abstraction for group management

import '../../../../core/domain/entities/groups/group.dart';
import '../../../../core/domain/entities/groups/group_family.dart';

/// Abstract interface for group local data source
/// Defines all local storage operations for group caching
abstract class GroupLocalDataSource {
  // ===========================================
  // USER GROUPS CACHING
  // ===========================================

  /// Get cached user groups
  Future<List<Group>?> getUserGroups();

  /// Cache user groups
  Future<void> cacheUserGroups(List<Group> groups);

  /// Clear cached user groups
  Future<void> clearUserGroups();

  // ===========================================
  // SINGLE GROUP CACHING
  // ===========================================

  /// Get cached group by ID
  Future<Group?> getGroup(String groupId);

  /// Cache a single group
  Future<void> cacheGroup(Group group);

  /// Remove a cached group
  Future<void> removeGroup(String groupId);

  // ===========================================
  // GROUP FAMILIES CACHING
  // ===========================================

  /// Get cached group families for a specific group
  Future<List<GroupFamily>?> getGroupFamilies(String groupId);

  /// Cache group families for a specific group
  Future<void> cacheGroupFamilies(String groupId, List<GroupFamily> families);

  /// Clear cached group families for a specific group
  Future<void> clearGroupFamilies(String groupId);

  // ===========================================
  // CACHE MANAGEMENT
  // ===========================================

  /// Clear all group caches (groups + families)
  Future<void> clearAll();

  /// Clear expired cache entries
  Future<void> clearExpiredCache();
}
