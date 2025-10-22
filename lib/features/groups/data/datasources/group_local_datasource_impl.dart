// EduLift Mobile - Group Local Data Source Implementation
// Production-grade Hive cache for group data using cache-first pattern

import 'dart:async';
import 'dart:convert';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../../../core/domain/entities/groups/group.dart';
import '../../../../core/domain/entities/groups/group_family.dart';
import '../../../../core/network/group_api_client.dart';
import '../../../../core/storage/hive_encryption_manager.dart';
import '../../../../core/utils/error_logger.dart';
import 'group_local_datasource.dart';

/// Cache metadata wrapper for versioning and TTL
class _CacheEntry<T> {
  final T data;
  final DateTime cachedAt;
  final int version;

  const _CacheEntry({
    required this.data,
    required this.cachedAt,
    this.version = 1,
  });

  Map<String, dynamic> toJson() => {
        'data': data,
        'cachedAt': cachedAt.toIso8601String(),
        'version': version,
      };

  static _CacheEntry<T> fromJson<T>(
    Map<String, dynamic> json,
    T Function(dynamic) fromData,
  ) =>
      _CacheEntry(
        data: fromData(json['data']),
        cachedAt: DateTime.parse(json['cachedAt']),
        version: json['version'] ?? 1,
      );

  bool isExpired(Duration ttl) => DateTime.now().difference(cachedAt) > ttl;
}

/// Production-grade Hive cache implementation for groups
class GroupLocalDataSourceImpl implements GroupLocalDataSource {
  // Box names
  static const String _groupsBoxName = 'groups';
  static const String _groupFamiliesBoxName = 'group_families';

  // Cache keys
  static const String _userGroupsKey = 'user_groups';

  // TTL (Time To Live)
  static const _defaultTtl = Duration(hours: 24);

  // Boxes
  late Box _groupsBox;
  late Box _groupFamiliesBox;

  bool _initialized = false;

  // Centralized encryption manager
  final _encryptionManager = HiveEncryptionManager();

  /// Initialize all Hive boxes with encryption
  /// NEVER throws - gracefully degrades to disabled cache on failure
  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    try {
      // Get encryption cipher from centralized manager
      final cipher = await _encryptionManager.getCipher();

      // Open boxes with encryption
      _groupsBox = await Hive.openBox(
        _groupsBoxName,
        encryptionCipher: cipher,
      );
      _groupFamiliesBox = await Hive.openBox(
        _groupFamiliesBoxName,
        encryptionCipher: cipher,
      );
      _initialized = true;
    } catch (e, stackTrace) {
      ErrorLogger.logProviderError(
        providerName: 'GroupLocalDataSourceImpl',
        operation: '_ensureInitialized',
        error: 'Failed to initialize encrypted cache',
        stackTrace: stackTrace,
      );

      // Self-healing: Delete corrupted boxes and recreate with encryption
      try {
        await Hive.deleteBoxFromDisk(_groupsBoxName);
        await Hive.deleteBoxFromDisk(_groupFamiliesBoxName);

        final cipher = await _encryptionManager.getCipher();

        _groupsBox = await Hive.openBox(_groupsBoxName, encryptionCipher: cipher);
        _groupFamiliesBox = await Hive.openBox(_groupFamiliesBoxName, encryptionCipher: cipher);

        _initialized = true;
        ErrorLogger.logProviderError(
          providerName: 'GroupLocalDataSourceImpl',
          operation: '_ensureInitialized',
          error: 'Successfully recovered with clean encrypted boxes',
        );
      } catch (recoveryError, recoveryStackTrace) {
        ErrorLogger.logProviderError(
          providerName: 'GroupLocalDataSourceImpl',
          operation: '_ensureInitialized',
          error: 'Cannot recover cache - cache disabled, app will use API only',
          stackTrace: recoveryStackTrace,
        );
        _initialized = false; // Cache disabled - graceful degradation
      }
    }
  }

  // ===========================================
  // INTERFACE IMPLEMENTATION
  // ===========================================

  @override
  Future<List<Group>?> getUserGroups() async {
    await _ensureInitialized();
    if (!_initialized) return null; // Cache disabled - graceful degradation

    try {
      final cached = _groupsBox.get(_userGroupsKey);
      if (cached == null) return null;

      final entry = _CacheEntry.fromJson<String>(
        Map<String, dynamic>.from(cached),
        (data) => data.toString(),
      );

      if (entry.isExpired(_defaultTtl)) {
        await _groupsBox.delete(_userGroupsKey);
        return null;
      }

      // Deserialize: Hive → JSON String → List<Map> → List<GroupData> → List<Group>
      final jsonList = jsonDecode(entry.data) as List<dynamic>;
      final groups = jsonList
          .map((json) => GroupData.fromJson(json as Map<String, dynamic>))
          .map((groupData) => _groupDataToDomain(groupData))
          .toList();

      return groups;
    } catch (e, stackTrace) {
      // Graceful degradation: Log + cleanup + return null
      ErrorLogger.logProviderError(
        providerName: 'GroupLocalDataSourceImpl',
        operation: 'getUserGroups',
        error: 'Cache entry corrupted',
        stackTrace: stackTrace,
      );

      // Self-healing: Remove corrupted entry
      await _groupsBox.delete(_userGroupsKey);

      // Graceful degradation: Return null (fallback to API)
      return null;
    }
  }

  @override
  Future<void> cacheUserGroups(List<Group> groups) async {
    await _ensureInitialized();
    if (!_initialized) return; // Cache disabled - silent fail

    try {
      // Serialize: List<Group> → List<GroupData> → List<Map> → JSON String → Hive
      final groupDataList = groups.map((group) => _domainToGroupData(group)).toList();
      final jsonList = groupDataList.map((data) => data.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      final entry = _CacheEntry(data: jsonString, cachedAt: DateTime.now());
      await _groupsBox.put(_userGroupsKey, entry.toJson());
    } catch (e, stackTrace) {
      ErrorLogger.logProviderError(
        providerName: 'GroupLocalDataSourceImpl',
        operation: 'cacheUserGroups',
        error: 'Failed to cache user groups: $e',
        stackTrace: stackTrace,
        state: {'groupCount': groups.length},
      );
      rethrow;
    }
  }

  @override
  Future<void> clearUserGroups() async {
    await _ensureInitialized();
    if (!_initialized) return; // Cache disabled - silent fail

    try {
      await _groupsBox.delete(_userGroupsKey);
    } catch (e, stackTrace) {
      ErrorLogger.logProviderError(
        providerName: 'GroupLocalDataSourceImpl',
        operation: 'clearUserGroups',
        error: 'Failed to clear user groups: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<Group?> getGroup(String groupId) async {
    await _ensureInitialized();
    if (!_initialized) return null; // Cache disabled - graceful degradation

    try {
      final cached = _groupsBox.get(groupId);
      if (cached == null) return null;

      final entry = _CacheEntry.fromJson<String>(
        Map<String, dynamic>.from(cached),
        (data) => data.toString(),
      );

      if (entry.isExpired(_defaultTtl)) {
        await _groupsBox.delete(groupId);
        return null;
      }

      // Deserialize: Hive → JSON String → Map → GroupData → Group
      final jsonMap = jsonDecode(entry.data) as Map<String, dynamic>;
      final groupData = GroupData.fromJson(jsonMap);
      return _groupDataToDomain(groupData);
    } catch (e, stackTrace) {
      // Graceful degradation: Log + cleanup + return null
      ErrorLogger.logProviderError(
        providerName: 'GroupLocalDataSourceImpl',
        operation: 'getGroup',
        error: 'Cache entry corrupted for group $groupId',
        stackTrace: stackTrace,
      );

      // Self-healing: Remove corrupted entry
      await _groupsBox.delete(groupId);

      // Graceful degradation: Return null (fallback to API)
      return null;
    }
  }

  @override
  Future<void> cacheGroup(Group group) async {
    await _ensureInitialized();
    if (!_initialized) return; // Cache disabled - silent fail

    try {
      // Serialize: Group → GroupData → Map → JSON String → Hive
      final groupData = _domainToGroupData(group);
      final jsonMap = groupData.toJson();
      final jsonString = jsonEncode(jsonMap);

      final entry = _CacheEntry(data: jsonString, cachedAt: DateTime.now());
      await _groupsBox.put(group.id, entry.toJson());
    } catch (e, stackTrace) {
      ErrorLogger.logProviderError(
        providerName: 'GroupLocalDataSourceImpl',
        operation: 'cacheGroup',
        error: 'Failed to cache group ${group.id}: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> removeGroup(String groupId) async {
    await _ensureInitialized();
    if (!_initialized) return; // Cache disabled - silent fail

    try {
      await _groupsBox.delete(groupId);
    } catch (e, stackTrace) {
      ErrorLogger.logProviderError(
        providerName: 'GroupLocalDataSourceImpl',
        operation: 'removeGroup',
        error: 'Failed to remove group $groupId: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<List<GroupFamily>?> getGroupFamilies(String groupId) async {
    await _ensureInitialized();
    if (!_initialized) return null; // Cache disabled - graceful degradation

    try {
      final cached = _groupFamiliesBox.get(groupId);
      if (cached == null) return null;

      final entry = _CacheEntry.fromJson<String>(
        Map<String, dynamic>.from(cached),
        (data) => data.toString(),
      );

      if (entry.isExpired(_defaultTtl)) {
        await _groupFamiliesBox.delete(groupId);
        return null;
      }

      // Deserialize: Hive → JSON String → List<Map> → List<GroupFamilyData> → List<GroupFamily>
      final jsonList = jsonDecode(entry.data) as List<dynamic>;
      final families = jsonList
          .map((json) => GroupFamilyData.fromJson(json as Map<String, dynamic>))
          .map((familyData) => GroupFamily.fromDto(familyData))
          .toList();

      return families;
    } catch (e, stackTrace) {
      // Graceful degradation: Log + cleanup + return null
      ErrorLogger.logProviderError(
        providerName: 'GroupLocalDataSourceImpl',
        operation: 'getGroupFamilies',
        error: 'Cache entry corrupted for group families $groupId',
        stackTrace: stackTrace,
      );

      // Self-healing: Remove corrupted entry
      await _groupFamiliesBox.delete(groupId);

      // Graceful degradation: Return null (fallback to API)
      return null;
    }
  }

  @override
  Future<void> cacheGroupFamilies(
    String groupId,
    List<GroupFamily> families,
  ) async {
    await _ensureInitialized();
    if (!_initialized) return; // Cache disabled - silent fail

    try {
      // Serialize: List<GroupFamily> → List<GroupFamilyData> → List<Map> → JSON String → Hive
      final familyDataList = families.map((family) => _domainToGroupFamilyData(family)).toList();
      final jsonList = familyDataList.map((data) => data.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      final entry = _CacheEntry(data: jsonString, cachedAt: DateTime.now());
      await _groupFamiliesBox.put(groupId, entry.toJson());
    } catch (e, stackTrace) {
      ErrorLogger.logProviderError(
        providerName: 'GroupLocalDataSourceImpl',
        operation: 'cacheGroupFamilies',
        error: 'Failed to cache group families for group $groupId: $e',
        stackTrace: stackTrace,
        state: {'familyCount': families.length},
      );
      rethrow;
    }
  }

  @override
  Future<void> clearGroupFamilies(String groupId) async {
    await _ensureInitialized();
    if (!_initialized) return; // Cache disabled - silent fail

    try {
      await _groupFamiliesBox.delete(groupId);
    } catch (e, stackTrace) {
      ErrorLogger.logProviderError(
        providerName: 'GroupLocalDataSourceImpl',
        operation: 'clearGroupFamilies',
        error: 'Failed to clear group families for group $groupId: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> clearAll() async {
    await _ensureInitialized();
    if (!_initialized) return; // Cache disabled - silent fail

    try {
      await Future.wait([
        _groupsBox.clear(),
        _groupFamiliesBox.clear(),
      ]);
    } catch (e, stackTrace) {
      ErrorLogger.logProviderError(
        providerName: 'GroupLocalDataSourceImpl',
        operation: 'clearAll',
        error: 'Failed to clear all group caches: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> clearExpiredCache() async {
    await _ensureInitialized();
    if (!_initialized) return; // Cache disabled - silent fail

    try {
      // Clean expired groups
      final expiredGroupKeys = <String>[];
      for (final key in _groupsBox.keys) {
        final cached = _groupsBox.get(key);
        if (cached != null) {
          try {
            final entry = _CacheEntry.fromJson<String>(
              Map<String, dynamic>.from(cached),
              (data) => data as String,
            );
            if (entry.isExpired(_defaultTtl)) {
              expiredGroupKeys.add(key);
            }
          } catch (e, stackTrace) {
            // Graceful degradation: Log corrupted entry
            ErrorLogger.logProviderError(
              providerName: 'GroupLocalDataSourceImpl',
              operation: 'clearExpiredCache',
              error: 'Corrupted cache entry during cleanup',
              stackTrace: stackTrace,
              state: {'corruptedKey': key.toString()},
            );

            // Self-healing: Mark corrupted entry for deletion
            expiredGroupKeys.add(key);
          }
        }
      }

      // Clean expired group families
      final expiredFamilyKeys = <String>[];
      for (final key in _groupFamiliesBox.keys) {
        final cached = _groupFamiliesBox.get(key);
        if (cached != null) {
          try {
            final entry = _CacheEntry.fromJson<String>(
              Map<String, dynamic>.from(cached),
              (data) => data as String,
            );
            if (entry.isExpired(_defaultTtl)) {
              expiredFamilyKeys.add(key);
            }
          } catch (e, stackTrace) {
            // Graceful degradation: Log corrupted entry
            ErrorLogger.logProviderError(
              providerName: 'GroupLocalDataSourceImpl',
              operation: 'clearExpiredCache',
              error: 'Corrupted family cache entry during cleanup',
              stackTrace: stackTrace,
              state: {'corruptedKey': key.toString()},
            );

            // Self-healing: Mark corrupted entry for deletion
            expiredFamilyKeys.add(key);
          }
        }
      }

      // Delete all expired/corrupted entries
      for (final key in expiredGroupKeys) {
        await _groupsBox.delete(key);
      }
      for (final key in expiredFamilyKeys) {
        await _groupFamiliesBox.delete(key);
      }
    } catch (e, stackTrace) {
      ErrorLogger.logProviderError(
        providerName: 'GroupLocalDataSourceImpl',
        operation: 'clearExpiredCache',
        error: 'Failed to clear expired cache: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // ===========================================
  // PRIVATE HELPER METHODS - DOMAIN CONVERSIONS
  // ===========================================

  /// Convert GroupData (DTO) to Group (Domain Entity)
  Group _groupDataToDomain(GroupData data) {
    return Group(
      id: data.id,
      name: data.name,
      familyId: data.familyId,
      description: data.description,
      createdAt: DateTime.parse(data.createdAt),
      updatedAt: DateTime.parse(data.updatedAt),
      userRole: data.userRole != null
          ? _parseGroupMemberRole(data.userRole!)
          : null,
      familyCount: data.familyCount ?? 0,
      scheduleCount: data.scheduleCount ?? 0,
    );
  }

  /// Convert Group (Domain Entity) to GroupData (DTO)
  GroupData _domainToGroupData(Group group) {
    return GroupData(
      id: group.id,
      name: group.name,
      familyId: group.familyId,
      description: group.description,
      createdAt: group.createdAt.toIso8601String(),
      updatedAt: group.updatedAt.toIso8601String(),
      userRole: group.userRole?.name.toUpperCase(),
      familyCount: group.familyCount,
      scheduleCount: group.scheduleCount,
    );
  }

  /// Convert GroupFamily (Domain Entity) to GroupFamilyData (DTO)
  GroupFamilyData _domainToGroupFamilyData(GroupFamily family) {
    return GroupFamilyData(
      id: family.id,
      name: family.name,
      role: family.role.name.toUpperCase(),
      isMyFamily: family.isMyFamily,
      canManage: family.canManage,
      admins: family.admins
          .map((admin) => FamilyAdminData(
                name: admin.name,
                email: admin.email,
              ))
          .toList(),
      invitationId: family.invitationId,
      invitedAt: family.invitedAt?.toIso8601String(),
      expiresAt: family.expiresAt?.toIso8601String(),
    );
  }

  /// Parse GroupMemberRole from string
  GroupMemberRole? _parseGroupMemberRole(String role) {
    switch (role.toUpperCase()) {
      case 'OWNER':
        return GroupMemberRole.owner;
      case 'ADMIN':
        return GroupMemberRole.admin;
      case 'MEMBER':
        return GroupMemberRole.member;
      default:
        return null;
    }
  }
}
