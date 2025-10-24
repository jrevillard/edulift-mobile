// EduLift Mobile - Groups Repository Implementation
// Migrated to NetworkErrorHandler for unified error handling, retry logic, and cache strategies
// Following the EXACT pattern established in FamilyRepository

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/network/network_error_handler.dart';
import '../../../../core/network/group_api_client.dart';
import '../../../../core/network/models/group/group_dto.dart';
import '../../domain/repositories/group_repository.dart' as domain;
import '../../../../core/domain/entities/groups/group.dart';
import '../../../../core/domain/entities/groups/group_family.dart';
import '../datasources/group_remote_datasource.dart';
import '../datasources/group_local_datasource.dart';

/// Groups Repository Implementation using NetworkErrorHandler Pattern
///
/// All network operations now use NetworkErrorHandler for:
/// - Automatic retry with exponential backoff
/// - Circuit breaker protection
/// - Unified error handling
/// - Cache strategies (networkOnly, networkFirst, staleWhileRevalidate)
/// - HTTP 0 detection and proper offline support
class GroupsRepositoryImpl implements domain.GroupRepository {
  final GroupRemoteDataSource _remoteDataSource;
  final GroupLocalDataSource _localDataSource;
  final NetworkErrorHandler _networkErrorHandler;

  GroupsRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkErrorHandler,
  );

  // ========================================
  // READ OPERATIONS - staleWhileRevalidate
  // ========================================

  @override
  Future<Result<List<Group>, ApiFailure>> getGroups() async {
    // Use NetworkErrorHandler with networkOnly strategy + manual cache fallback
    final result = await _networkErrorHandler
        .executeRepositoryOperation<List<Map<String, dynamic>>>(
          () => _remoteDataSource.getMyGroups(),
          operationName: 'groups.getGroups',
          strategy: CacheStrategy.networkOnly,
          serviceName: 'groups',
          config: RetryConfig.quick,
          onSuccess: (groupDtos) async {
            final groups = groupDtos
                .map((dto) => GroupDto.fromJson(dto).toDomain())
                .toList();
            await _localDataSource.cacheUserGroups(groups);
            AppLogger.info(
              '[GROUPS] User groups cached successfully after network success',
            );
          },
          context: {
            'feature': 'groups_management',
            'operation_type': 'read',
            'cache_strategy': 'network_only_with_manual_cache_fallback',
          },
        );

    return result.when(
      ok: (groupDtos) {
        final groups = groupDtos
            .map((dto) => GroupDto.fromJson(dto).toDomain())
            .toList();
        return Result.ok(groups);
      },
      err: (failure) async {
        // BUSINESS LOGIC: 404 means user has no groups - this is a valid state
        if (failure.statusCode == 404 || failure.code == 'api.not_found') {
          AppLogger.info('[GROUPS] User has no groups (404) - valid state');
          try {
            await _localDataSource.clearUserGroups();
          } catch (e) {
            AppLogger.warning('[GROUPS] Failed to clear groups cache', e);
          }
          return const Result.ok([]);
        }

        // HTTP 0 / Network error: fallback to cache (Principe 0)
        if (failure.statusCode == 0 || failure.statusCode == 503) {
          try {
            final cachedGroups = await _localDataSource.getUserGroups();
            if (cachedGroups != null && cachedGroups.isNotEmpty) {
              AppLogger.info(
                '[GROUPS] Network error - returning cached groups (Principe 0)',
              );
              return Result.ok(cachedGroups);
            }
          } catch (cacheError) {
            AppLogger.warning(
              '[GROUPS] Failed to retrieve cache after network error',
              cacheError,
            );
          }
        }

        return Result.err(failure);
      },
    );
  }

  @override
  Future<Result<Group, ApiFailure>> getGroup(String groupId) async {
    // Use NetworkErrorHandler with networkOnly strategy + manual cache fallback
    final result = await _networkErrorHandler
        .executeRepositoryOperation<Map<String, dynamic>>(
          () => _remoteDataSource.getGroup(groupId),
          operationName: 'groups.getGroup',
          strategy: CacheStrategy.networkOnly,
          serviceName: 'groups',
          config: RetryConfig.quick,
          onSuccess: (groupDto) async {
            final group = GroupDto.fromJson(groupDto).toDomain();
            await _localDataSource.cacheGroup(group);
            AppLogger.info(
              '[GROUPS] Group cached successfully after network success',
            );
          },
          context: {
            'feature': 'groups_management',
            'operation_type': 'read',
            'cache_strategy': 'network_only_with_manual_cache_fallback',
            'groupId': groupId,
          },
        );

    return result.when(
      ok: (groupDto) {
        final group = GroupDto.fromJson(groupDto).toDomain();
        return Result.ok(group);
      },
      err: (failure) async {
        // BUSINESS LOGIC: 404 means group doesn't exist or was deleted
        if (failure.statusCode == 404 || failure.code == 'api.not_found') {
          AppLogger.info(
            '[GROUPS] Group not found (404) - removing from cache',
          );
          try {
            await _localDataSource.removeGroup(groupId);
          } catch (e) {
            AppLogger.warning('[GROUPS] Failed to remove group from cache', e);
          }
          return Result.err(ApiFailure.notFound(resource: 'Group'));
        }

        // HTTP 0 / Network error: fallback to cache (Principe 0)
        if (failure.statusCode == 0 || failure.statusCode == 503) {
          try {
            final cachedGroup = await _localDataSource.getGroup(groupId);
            if (cachedGroup != null) {
              AppLogger.info(
                '[GROUPS] Network error - returning cached group (Principe 0)',
              );
              return Result.ok(cachedGroup);
            }
          } catch (cacheError) {
            AppLogger.warning(
              '[GROUPS] Failed to retrieve cache after network error',
              cacheError,
            );
          }
        }

        return Result.err(failure);
      },
    );
  }

  // ========================================
  // WRITE OPERATIONS - networkOnly
  // ========================================

  @override
  Future<Result<Group, ApiFailure>> createGroup(
    CreateGroupCommand command,
  ) async {
    // Convert command to raw data for datasource
    final groupData = {
      'name': command.name,
      'description': command.description,
      if (command.settings != null)
        'settings': {
          'allowAutoAssignment': command.settings!.allowAutoAssignment,
          'requireParentalApproval': command.settings!.requireParentalApproval,
          'groupColor': command.settings!.groupColor,
          'enableNotifications': command.settings!.enableNotifications,
          'privacyLevel': command.settings!.privacyLevel.name,
        },
    };

    // Use NetworkErrorHandler for automatic retry, circuit breaker, and proper error handling
    final result = await _networkErrorHandler
        .executeRepositoryOperation<Map<String, dynamic>>(
          () => _remoteDataSource.createGroup(groupData),
          operationName: 'groups.createGroup',
          strategy: CacheStrategy.networkOnly, // Write operation = network-only
          serviceName: 'groups',
          config: RetryConfig.quick,
          onSuccess: (groupDto) async {
            // CACHE AUTO-UPDATE: Update cache automatically on network success
            final group = GroupDto.fromJson(groupDto).toDomain();
            await _localDataSource.cacheGroup(group);
            AppLogger.info('Group created and cached successfully', {
              'groupId': group.id,
              'name': command.name,
            });
          },
          context: {
            'feature': 'groups_management',
            'operation_type': 'create',
            'name': command.name,
          },
        );

    return result.when(
      ok: (groupDto) => Result.ok(GroupDto.fromJson(groupDto).toDomain()),
      err: (failure) => Result.err(failure),
    );
  }

  @override
  Future<Result<Group, ApiFailure>> joinGroup(String invitationCode) async {
    // Use NetworkErrorHandler for automatic retry, circuit breaker, and proper error handling
    final result = await _networkErrorHandler
        .executeRepositoryOperation<Map<String, dynamic>>(
          () => _remoteDataSource.joinGroup(invitationCode),
          operationName: 'groups.joinGroup',
          strategy: CacheStrategy.networkOnly, // Write operation = network-only
          serviceName: 'groups',
          config: RetryConfig.quick,
          onSuccess: (groupDto) async {
            // CACHE AUTO-UPDATE: Update cache automatically on network success
            final group = GroupDto.fromJson(groupDto).toDomain();
            await _localDataSource.cacheGroup(group);
            AppLogger.info('Joined group and cached successfully', {
              'groupId': group.id,
              'invitationCode': invitationCode,
            });
          },
          context: {
            'feature': 'groups_management',
            'operation_type': 'create',
            'invitationCode': invitationCode,
          },
        );

    return result.when(
      ok: (groupDto) => Result.ok(GroupDto.fromJson(groupDto).toDomain()),
      err: (failure) => Result.err(failure),
    );
  }

  @override
  Future<Result<void, ApiFailure>> leaveGroup(String groupId) async {
    // Use NetworkErrorHandler for automatic retry, circuit breaker, and proper error handling
    final result = await _networkErrorHandler.executeRepositoryOperation<void>(
      () => _remoteDataSource.leaveGroup(groupId),
      operationName: 'groups.leaveGroup',
      strategy: CacheStrategy.networkOnly, // Write operation = network-only
      serviceName: 'groups',
      config: RetryConfig.quick,
      onSuccess: (_) async {
        // CACHE AUTO-UPDATE: Remove the group from cache on successful leave
        await _localDataSource.removeGroup(groupId);
        await _localDataSource.clearGroupFamilies(groupId);
        AppLogger.info('Left group and cache cleared successfully', {
          'groupId': groupId,
        });
      },
      context: {
        'feature': 'groups_management',
        'operation_type': 'delete',
        'groupId': groupId,
      },
    );

    return result;
  }

  @override
  Future<Result<Group, ApiFailure>> updateGroup(
    String groupId,
    Map<String, dynamic> updates,
  ) async {
    // Use NetworkErrorHandler for automatic retry, circuit breaker, and proper error handling
    final result = await _networkErrorHandler
        .executeRepositoryOperation<Map<String, dynamic>>(
          () => _remoteDataSource.updateGroup(groupId, updates),
          operationName: 'groups.updateGroup',
          strategy: CacheStrategy.networkOnly, // Write operation = network-only
          serviceName: 'groups',
          config: RetryConfig.quick,
          onSuccess: (groupDto) async {
            // CACHE AUTO-UPDATE: Update cache automatically on network success
            final group = GroupDto.fromJson(groupDto).toDomain();
            await _localDataSource.cacheGroup(group);
            AppLogger.info('Group updated and cached successfully', {
              'groupId': groupId,
              'updates': updates,
            });
          },
          context: {
            'feature': 'groups_management',
            'operation_type': 'update',
            'groupId': groupId,
            'updates': updates,
          },
        );

    return result.when(
      ok: (groupDto) => Result.ok(GroupDto.fromJson(groupDto).toDomain()),
      err: (failure) => Result.err(failure),
    );
  }

  @override
  Future<Result<void, ApiFailure>> deleteGroup(String groupId) async {
    // Use NetworkErrorHandler for automatic retry, circuit breaker, and proper error handling
    final result = await _networkErrorHandler.executeRepositoryOperation<void>(
      () => _remoteDataSource.deleteGroup(groupId),
      operationName: 'groups.deleteGroup',
      strategy: CacheStrategy.networkOnly, // Write operation = network-only
      serviceName: 'groups',
      config: RetryConfig.quick,
      onSuccess: (_) async {
        // CACHE AUTO-UPDATE: Remove the group from cache on successful delete
        await _localDataSource.removeGroup(groupId);
        await _localDataSource.clearGroupFamilies(groupId);
        AppLogger.info('Group deleted and cache cleared successfully', {
          'groupId': groupId,
        });
      },
      context: {
        'feature': 'groups_management',
        'operation_type': 'delete',
        'groupId': groupId,
      },
    );

    return result;
  }

  @override
  Future<Result<GroupInvitationValidationData, ApiFailure>> validateInvitation(
    String code,
  ) async {
    // Use NetworkErrorHandler for automatic retry, circuit breaker, and proper error handling
    final result = await _networkErrorHandler
        .executeRepositoryOperation<GroupInvitationValidationData>(
          () => _remoteDataSource.validateGroupInvitation(code),
          operationName: 'groups.validateInvitation',
          strategy:
              CacheStrategy.networkOnly, // Validation must be fresh from server
          serviceName: 'groups',
          config: RetryConfig.quick,
          context: {
            'feature': 'groups_management',
            'operation_type': 'read',
            'invitationCode': code,
          },
        );

    return result.when(
      ok: (validationDto) => Result.ok(validationDto),
      err: (failure) => Result.err(failure),
    );
  }

  @override
  Future<Result<List<GroupFamily>, ApiFailure>> getGroupFamilies(
    String groupId,
  ) async {
    // Use NetworkErrorHandler with networkOnly strategy + manual cache fallback
    final result = await _networkErrorHandler
        .executeRepositoryOperation<List<GroupFamilyData>>(
          () => _remoteDataSource.getGroupFamilies(groupId),
          operationName: 'groups.getGroupFamilies',
          strategy: CacheStrategy.networkOnly,
          serviceName: 'groups',
          config: RetryConfig.quick,
          onSuccess: (familyDtos) async {
            final families = familyDtos
                .map((dto) => GroupFamily.fromDto(dto))
                .toList();
            await _localDataSource.cacheGroupFamilies(groupId, families);
            AppLogger.info(
              '[GROUPS] Group families cached successfully after network success',
            );
          },
          context: {
            'feature': 'groups_management',
            'operation_type': 'read',
            'cache_strategy': 'network_only_with_manual_cache_fallback',
            'groupId': groupId,
          },
        );

    return result.when(
      ok: (familyDtos) {
        final families = familyDtos
            .map((dto) => GroupFamily.fromDto(dto))
            .toList();
        return Result.ok(families);
      },
      err: (failure) async {
        // BUSINESS LOGIC: 404 means no families in group - this is a valid state
        if (failure.statusCode == 404 || failure.code == 'api.not_found') {
          AppLogger.info('[GROUPS] No families in group (404) - valid state');
          try {
            await _localDataSource.clearGroupFamilies(groupId);
          } catch (e) {
            AppLogger.warning(
              '[GROUPS] Failed to clear group families cache',
              e,
            );
          }
          return const Result.ok([]);
        }

        // HTTP 0 / Network error: fallback to cache (Principe 0)
        if (failure.statusCode == 0 || failure.statusCode == 503) {
          try {
            final cachedFamilies = await _localDataSource.getGroupFamilies(
              groupId,
            );
            if (cachedFamilies != null && cachedFamilies.isNotEmpty) {
              AppLogger.info(
                '[GROUPS] Network error - returning cached families (Principe 0)',
              );
              return Result.ok(cachedFamilies);
            }
          } catch (cacheError) {
            AppLogger.warning(
              '[GROUPS] Failed to retrieve cache after network error',
              cacheError,
            );
          }
        }

        return Result.err(failure);
      },
    );
  }

  // ========================================
  // FAMILY MANAGEMENT OPERATIONS
  // ========================================

  @override
  Future<Result<GroupFamily, ApiFailure>> updateFamilyRole(
    String groupId,
    String familyId,
    Map<String, dynamic> updates,
  ) async {
    // Use NetworkErrorHandler for automatic retry, circuit breaker, and proper error handling
    final result = await _networkErrorHandler
        .executeRepositoryOperation<GroupFamilyData>(
          () => _remoteDataSource.updateFamilyRole(groupId, familyId, updates),
          operationName: 'groups.updateFamilyRole',
          strategy: CacheStrategy.networkOnly, // Write operation = network-only
          serviceName: 'groups',
          config: RetryConfig.quick,
          onSuccess: (familyDto) async {
            // CACHE AUTO-UPDATE: Refresh the group families cache after role update
            try {
              final familiesResult = await getGroupFamilies(groupId);
              if (familiesResult.isOk) {
                await _localDataSource.cacheGroupFamilies(
                  groupId,
                  familiesResult.value!,
                );
              }
            } catch (e) {
              AppLogger.warning(
                '[GROUPS] Failed to refresh families cache after role update',
                e,
              );
              // Don't fail the operation if cache refresh fails
            }
            AppLogger.info(
              'Family role updated and cache refreshed successfully',
              {'groupId': groupId, 'familyId': familyId, 'updates': updates},
            );
          },
          context: {
            'feature': 'groups_management',
            'operation_type': 'update',
            'groupId': groupId,
            'familyId': familyId,
            'updates': updates,
          },
        );

    return result.when(
      ok: (familyDto) => Result.ok(GroupFamily.fromDto(familyDto)),
      err: (failure) => Result.err(failure),
    );
  }

  @override
  Future<Result<void, ApiFailure>> removeFamilyFromGroup(
    String groupId,
    String familyId,
  ) async {
    // Use NetworkErrorHandler for automatic retry, circuit breaker, and proper error handling
    final result = await _networkErrorHandler.executeRepositoryOperation<void>(
      () => _remoteDataSource.removeFamilyFromGroup(groupId, familyId),
      operationName: 'groups.removeFamilyFromGroup',
      strategy: CacheStrategy.networkOnly, // Write operation = network-only
      serviceName: 'groups',
      config: RetryConfig.quick,
      onSuccess: (_) async {
        // CACHE AUTO-UPDATE: Refresh the group families cache after removal
        try {
          final familiesResult = await getGroupFamilies(groupId);
          if (familiesResult.isOk) {
            await _localDataSource.cacheGroupFamilies(
              groupId,
              familiesResult.value!,
            );
          }
        } catch (e) {
          AppLogger.warning(
            '[GROUPS] Failed to refresh families cache after family removal',
            e,
          );
          // Don't fail the operation if cache refresh fails
        }
        AppLogger.info(
          'Family removed from group and cache refreshed successfully',
          {'groupId': groupId, 'familyId': familyId},
        );
      },
      context: {
        'feature': 'groups_management',
        'operation_type': 'delete',
        'groupId': groupId,
        'familyId': familyId,
      },
    );

    return result;
  }

  @override
  Future<Result<void, ApiFailure>> cancelInvitation(
    String groupId,
    String invitationId,
  ) async {
    // Use NetworkErrorHandler for automatic retry, circuit breaker, and proper error handling
    final result = await _networkErrorHandler.executeRepositoryOperation<void>(
      () => _remoteDataSource.cancelInvitation(groupId, invitationId),
      operationName: 'groups.cancelInvitation',
      strategy: CacheStrategy.networkOnly, // Write operation = network-only
      serviceName: 'groups',
      config: RetryConfig.quick,
      context: {
        'feature': 'groups_management',
        'operation_type': 'delete',
        'groupId': groupId,
        'invitationId': invitationId,
      },
    );

    if (result.isOk) {
      AppLogger.info('Invitation cancelled successfully', {
        'groupId': groupId,
        'invitationId': invitationId,
      });
    }

    return result;
  }

  @override
  Future<Result<List<FamilySearchResult>, ApiFailure>>
  searchFamiliesForInvitation(String groupId, String? query, int? limit) async {
    // Use NetworkErrorHandler for automatic retry, circuit breaker, and proper error handling
    final result = await _networkErrorHandler
        .executeRepositoryOperation<List<Map<String, dynamic>>>(
          () => _remoteDataSource.searchFamiliesForInvitation(
            groupId,
            query,
            limit,
          ),
          operationName: 'groups.searchFamiliesForInvitation',
          strategy:
              CacheStrategy.networkOnly, // Search always requires fresh data
          serviceName: 'groups',
          config: RetryConfig.quick,
          context: {
            'feature': 'groups_management',
            'operation_type': 'read',
            'groupId': groupId,
            'query': query,
            'limit': limit,
          },
        );

    return result.when(
      ok: (resultsJson) {
        final results = resultsJson
            .map((json) => FamilySearchResult.fromJson(json))
            .toList();
        AppLogger.info('Family search completed successfully', {
          'groupId': groupId,
          'query': query,
          'count': results.length,
        });
        return Result.ok(results);
      },
      err: (failure) => Result.err(failure),
    );
  }

  @override
  Future<Result<void, ApiFailure>> inviteFamilyToGroup(
    String groupId,
    String familyId,
    String? role,
    String? message,
  ) async {
    // Use NetworkErrorHandler for automatic retry, circuit breaker, and proper error handling
    final result = await _networkErrorHandler.executeRepositoryOperation<void>(
      () => _remoteDataSource.inviteFamilyToGroup(
        groupId,
        familyId,
        role,
        message,
      ),
      operationName: 'groups.inviteFamilyToGroup',
      strategy: CacheStrategy.networkOnly, // Write operation = network-only
      serviceName: 'groups',
      config: RetryConfig.quick,
      onSuccess: (_) async {
        // CACHE AUTO-UPDATE: Refresh the group families cache after invitation
        try {
          final familiesResult = await getGroupFamilies(groupId);
          if (familiesResult.isOk) {
            await _localDataSource.cacheGroupFamilies(
              groupId,
              familiesResult.value!,
            );
          }
        } catch (e) {
          AppLogger.warning(
            '[GROUPS] Failed to refresh families cache after invitation',
            e,
          );
          // Don't fail the operation if cache refresh fails
        }
        AppLogger.info(
          'Family invited to group and cache refreshed successfully',
          {'groupId': groupId, 'familyId': familyId, 'role': role},
        );
      },
      context: {
        'feature': 'groups_management',
        'operation_type': 'create',
        'groupId': groupId,
        'familyId': familyId,
        'role': role,
      },
    );

    return result;
  }
}
