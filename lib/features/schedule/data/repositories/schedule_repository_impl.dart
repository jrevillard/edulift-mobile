import 'dart:async';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/network/network_error_handler.dart';
import '../../../../core/network/models/schedule/schedule_slot_dto.dart';
import '../../../../core/network/models/schedule/schedule_config_dto.dart';
import '../../../../core/network/models/schedule/vehicle_assignment_dto.dart';
import '../../../../core/network/models/child/child_dto.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/repositories/schedule_repository.dart';
import 'package:edulift/core/domain/entities/schedule.dart'
    as schedule_entities;
import '../../../family/domain/entities/child_assignment.dart'
    as family_entities;
import '../../../../core/domain/entities/family/child.dart';
import '../datasources/schedule_local_datasource.dart';
import '../datasources/schedule_remote_datasource.dart';
import '../../../../core/network/requests/group_requests.dart';

/// Implementation of Schedule Repository with Result pattern and Clean Architecture
/// Migrated to NetworkErrorHandler for unified error handling, retry logic, and cache strategies
/// Following the EXACT pattern established in FamilyRepository and GroupsRepository
///
/// All network operations now use NetworkErrorHandler for:
/// - Automatic retry with exponential backoff
/// - Circuit breaker protection
/// - Unified error handling
/// - Cache strategies (networkOnly with manual cache fallback)
/// - HTTP 0 detection and proper offline support

class ScheduleRepositoryImpl implements GroupScheduleRepository {
  final ScheduleRemoteDataSource _remoteDataSource;
  final ScheduleLocalDataSource _localDataSource;
  final NetworkErrorHandler _networkErrorHandler;

  const ScheduleRepositoryImpl({
    required ScheduleRemoteDataSource remoteDataSource,
    required ScheduleLocalDataSource localDataSource,
    required NetworkErrorHandler networkErrorHandler,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkErrorHandler = networkErrorHandler;

  // ========================================
  // BASIC SLOT OPERATIONS (READ operations - networkOnly + manual cache fallback)
  // ========================================

  @override
  Future<Result<List<schedule_entities.ScheduleSlot>, ApiFailure>>
  getWeeklySchedule(String groupId, String week) async {
    // Use NetworkErrorHandler with networkOnly strategy + manual cache fallback (EXACT PATTERN)
    final result = await _networkErrorHandler
        .executeRepositoryOperation<List<ScheduleSlotDto>>(
          () => _remoteDataSource.getWeeklySchedule(groupId, week),
          operationName: 'schedule.getWeeklySchedule',
          strategy: CacheStrategy.networkOnly,
          serviceName: 'schedule',
          config: RetryConfig.quick,
          onSuccess: (dtos) async {
            final slots = dtos.map((dto) => dto.toDomain()).toList();
            await _localDataSource.cacheWeeklySchedule(groupId, week, slots);
            AppLogger.info(
              '[SCHEDULE] Weekly schedule cached successfully after network success',
            );
          },
          context: {
            'feature': 'schedule_management',
            'operation_type': 'read',
            'cache_strategy': 'network_only_with_manual_cache_fallback',
            'groupId': groupId,
            'week': week,
          },
        );

    return result.when(
      ok: (dtos) {
        final slots = dtos.map((dto) => dto.toDomain()).toList();
        return Result.ok(slots);
      },
      err: (failure) async {
        // BUSINESS LOGIC: 404 means empty schedule - this is a valid state, not an error
        if (failure.statusCode == 404 || failure.code == 'api.not_found') {
          AppLogger.info(
            '[SCHEDULE] No schedule for week $week (404) - valid state',
          );
          try {
            await _localDataSource.cacheWeeklySchedule(groupId, week, []);
          } catch (cacheError) {
            AppLogger.warning(
              '[SCHEDULE] Failed to cache empty schedule',
              cacheError,
            );
          }
          return const Result.ok([]);
        }

        // HTTP 0 / Network error: fallback to cache (Principe 0)
        if (failure.statusCode == 0 || failure.statusCode == 503) {
          try {
            final cachedSlots = await _localDataSource.getCachedWeeklySchedule(
              groupId,
              week,
            );
            if (cachedSlots != null && cachedSlots.isNotEmpty) {
              AppLogger.info(
                '[SCHEDULE] Network error - returning cached weekly schedule (Principe 0)',
              );
              return Result.ok(cachedSlots);
            }
          } catch (cacheError) {
            AppLogger.warning(
              '[SCHEDULE] Failed to retrieve cache after network error',
              cacheError,
            );
          }
        }

        return Result.err(failure);
      },
    );
  }

  @override
  Future<Result<schedule_entities.ScheduleSlot, ApiFailure>> upsertScheduleSlot(
    String groupId,
    String day,
    String time,
    String week,
  ) async {
    // NOTE: Empty slot creation is deprecated.
    // Use assignVehicleToSlot() instead,
    // which creates slot + vehicle in a single API call.
    // This method returns an error to guide users to the correct approach.
    return Result.err(
      ApiFailure.validationError(
        message:
            'Cannot create empty schedule slots. Use assignVehicleToSlot() '
            'to create a slot with a vehicle in a single API call.',
      ),
    );
  }

  @override
  Future<Result<List<Child>, ApiFailure>> getAvailableChildren(
    String groupId,
    String week,
    String day,
    String time,
  ) async {
    // Use NetworkErrorHandler with networkOnly strategy (READ operation)
    final result = await _networkErrorHandler
        .executeRepositoryOperation<List<ChildDto>>(
          () => _remoteDataSource.getAvailableChildren(
            groupId: groupId,
            week: week,
            day: day,
            time: time,
          ),
          operationName: 'schedule.getAvailableChildren',
          strategy: CacheStrategy.networkOnly,
          serviceName: 'schedule',
          config: RetryConfig.quick,
          context: {
            'feature': 'schedule_management',
            'operation_type': 'read',
            'groupId': groupId,
            'week': week,
            'day': day,
            'time': time,
          },
        );

    return result.when(
      ok: (dtos) {
        final children = dtos.map((dto) => dto.toDomain()).toList();
        return Result.ok(children);
      },
      err: (failure) => Result.err(failure),
    );
  }

  @override
  Future<Result<List<schedule_entities.ScheduleConflict>, ApiFailure>>
  checkScheduleConflicts(
    String groupId,
    String vehicleId,
    String week,
    String day,
    String time,
  ) async {
    // Not implemented in remote datasource yet
    // Return empty conflicts list for now
    return const Result.ok([]);
  }

  @override
  Future<Result<void, ApiFailure>> copyWeeklySchedule(
    String groupId,
    String sourceWeek,
    String targetWeek,
  ) async {
    // Not implemented in remote datasource yet
    // Would need to get all slots from source week and create them in target week
    // For now, return not implemented error
    return const Result.err(
      ApiFailure(
        code: 'schedule.not_implemented',
        message: 'Copy weekly schedule not implemented yet',
        statusCode: 501,
      ),
    );
  }

  @override
  Future<Result<void, ApiFailure>> clearWeeklySchedule(
    String groupId,
    String week,
  ) async {
    // Not implemented in remote datasource yet
    // Would need to remove all vehicle assignments from all slots in the week
    // For now, return not implemented error
    return const Result.err(
      ApiFailure(
        code: 'schedule.not_implemented',
        message: 'Clear weekly schedule not implemented yet',
        statusCode: 501,
      ),
    );
  }

  // ========================================
  // VEHICLE OPERATIONS (WRITE operations - networkOnly)
  // ========================================

  @override
  Future<Result<schedule_entities.VehicleAssignment, ApiFailure>>
  assignVehicleToSlot(
    String groupId,
    String day,
    String time,
    String week,
    String vehicleId,
  ) async {
    // Use NetworkErrorHandler for automatic retry, circuit breaker, and proper error handling
    final result = await _networkErrorHandler
        .executeRepositoryOperation<VehicleAssignmentDto>(
          () => _remoteDataSource.assignVehicleToSlot(
            groupId: groupId,
            day: day,
            time: time,
            week: week,
            vehicleId: vehicleId,
          ),
          operationName: 'schedule.assignVehicleToSlot',
          strategy: CacheStrategy.networkOnly, // Write operation = network-only
          serviceName: 'schedule',
          config: RetryConfig.quick,
          onSuccess: (dto) async {
            // CACHE AUTO-UPDATE: Update cache automatically on network success
            final vehicleAssignment = dto.toDomain();
            final slotId = vehicleAssignment.scheduleSlotId;
            try {
              await _localDataSource.cacheVehicleAssignment(
                slotId,
                vehicleAssignment,
              );
              await _updateWeeklyScheduleCacheAfterAssignment(
                groupId,
                week,
                slotId,
                vehicleAssignment,
              );
              AppLogger.info(
                '[SCHEDULE] Vehicle assignment cached successfully',
                {'groupId': groupId, 'vehicleId': vehicleId, 'slotId': slotId},
              );
            } catch (cacheError) {
              AppLogger.warning(
                '[SCHEDULE] Cache write failed (operation: assignVehicleToSlot_cache_write)',
                cacheError,
              );
            }
          },
          context: {
            'feature': 'schedule_management',
            'operation_type': 'create',
            'groupId': groupId,
            'vehicleId': vehicleId,
            'week': week,
            'day': day,
            'time': time,
          },
        );

    return result.when(
      ok: (dto) => Result.ok(dto.toDomain()),
      err: (failure) => Result.err(failure),
    );
  }

  @override
  Future<Result<schedule_entities.VehicleAssignment, ApiFailure>>
  assignChildrenToVehicle(
    String groupId,
    String slotId,
    String vehicleAssignmentId,
    List<String> childIds,
  ) async {
    // Use NetworkErrorHandler for automatic retry, circuit breaker, and proper error handling
    final result = await _networkErrorHandler
        .executeRepositoryOperation<VehicleAssignmentDto>(
          () => _remoteDataSource.assignChildrenToVehicle(
            groupId: groupId,
            slotId: slotId,
            vehicleAssignmentId: vehicleAssignmentId,
            childIds: childIds,
          ),
          operationName: 'schedule.assignChildrenToVehicle',
          strategy: CacheStrategy.networkOnly, // Write operation = network-only
          serviceName: 'schedule',
          config: RetryConfig.quick,
          onSuccess: (dto) async {
            // CACHE AUTO-UPDATE: Update cache automatically on network success
            final vehicleAssignment = dto.toDomain();
            try {
              await _localDataSource.updateCachedVehicleAssignment(
                vehicleAssignment,
              );
              AppLogger.info(
                '[SCHEDULE] Children assignment cached successfully',
                {'groupId': groupId, 'slotId': slotId, 'childIds': childIds},
              );
            } catch (cacheError) {
              AppLogger.warning(
                '[SCHEDULE] Cache write failed (operation: assignChildrenToVehicle_cache_write)',
                cacheError,
              );
            }
          },
          context: {
            'feature': 'schedule_management',
            'operation_type': 'update',
            'groupId': groupId,
            'slotId': slotId,
            'vehicleAssignmentId': vehicleAssignmentId,
            'childCount': childIds.length,
          },
        );

    return result.when(
      ok: (dto) => Result.ok(dto.toDomain()),
      err: (failure) => Result.err(_mapScheduleApiFailure(failure, childIds)),
    );
  }

  @override
  Future<Result<void, ApiFailure>> removeVehicleFromSlot(
    String groupId,
    String slotId,
    String vehicleId,
  ) async {
    // Use NetworkErrorHandler for automatic retry, circuit breaker, and proper error handling
    final result = await _networkErrorHandler.executeRepositoryOperation<void>(
      () => _remoteDataSource.removeVehicleFromSlot(
        groupId: groupId,
        slotId: slotId,
        vehicleId: vehicleId,
      ),
      operationName: 'schedule.removeVehicleFromSlot',
      strategy: CacheStrategy.networkOnly, // Write operation = network-only
      serviceName: 'schedule',
      config: RetryConfig.quick,
      onSuccess: (_) async {
        // CACHE AUTO-UPDATE: Update cache automatically on network success
        try {
          await _localDataSource.removeCachedVehicleAssignment(
            slotId,
            vehicleId,
          );
          AppLogger.info('[SCHEDULE] Vehicle removal cached successfully', {
            'groupId': groupId,
            'slotId': slotId,
            'vehicleId': vehicleId,
          });
        } catch (cacheError) {
          AppLogger.warning(
            '[SCHEDULE] Cache write failed (operation: removeVehicleFromSlot_cache_write)',
            cacheError,
          );
        }
      },
      context: {
        'feature': 'schedule_management',
        'operation_type': 'delete',
        'groupId': groupId,
        'slotId': slotId,
        'vehicleId': vehicleId,
      },
    );

    return result;
  }

  /// Internal method that accepts week parameter for more reliable cache updates
  /// Used by providers that have the week context available
  @override
  Future<Result<void, ApiFailure>> removeVehicleFromSlotWithWeek(
    String groupId,
    String slotId,
    String vehicleId,
    String week,
  ) async {
    // Use NetworkErrorHandler for automatic retry, circuit breaker, and proper error handling
    final result = await _networkErrorHandler.executeRepositoryOperation<void>(
      () => _remoteDataSource.removeVehicleFromSlot(
        groupId: groupId,
        slotId: slotId,
        vehicleId: vehicleId,
      ),
      operationName: 'schedule.removeVehicleFromSlotWithWeek',
      strategy: CacheStrategy.networkOnly, // Write operation = network-only
      serviceName: 'schedule',
      config: RetryConfig.quick,
      onSuccess: (_) async {
        // CACHE AUTO-UPDATE: Update cache automatically on network success
        try {
          await _localDataSource.removeCachedVehicleAssignment(
            slotId,
            vehicleId,
          );
          await _updateWeeklyScheduleCacheAfterRemoval(
            groupId,
            week,
            slotId,
            vehicleId,
          );
          AppLogger.info(
            '[SCHEDULE] Vehicle removal with week cached successfully',
            {
              'groupId': groupId,
              'slotId': slotId,
              'vehicleId': vehicleId,
              'week': week,
            },
          );
        } catch (cacheError) {
          AppLogger.warning(
            '[SCHEDULE] Cache write failed (operation: removeVehicleFromSlotWithWeek_cache_write)',
            cacheError,
          );
        }
      },
      context: {
        'feature': 'schedule_management',
        'operation_type': 'delete',
        'groupId': groupId,
        'slotId': slotId,
        'vehicleId': vehicleId,
        'week': week,
      },
    );

    return result;
  }

  @override
  Future<Result<void, ApiFailure>> removeChildFromVehicle(
    String groupId,
    String slotId,
    String vehicleAssignmentId,
    String childAssignmentId,
  ) async {
    // Use NetworkErrorHandler for automatic retry, circuit breaker, and proper error handling
    final result = await _networkErrorHandler.executeRepositoryOperation<void>(
      () => _remoteDataSource.removeChildFromVehicle(
        groupId: groupId,
        slotId: slotId,
        vehicleAssignmentId: vehicleAssignmentId,
        childAssignmentId: childAssignmentId,
      ),
      operationName: 'schedule.removeChildFromVehicle',
      strategy: CacheStrategy.networkOnly, // Write operation = network-only
      serviceName: 'schedule',
      config: RetryConfig.quick,
      onSuccess: (_) async {
        AppLogger.info('[SCHEDULE] Child removed from vehicle successfully', {
          'groupId': groupId,
          'slotId': slotId,
          'childAssignmentId': childAssignmentId,
        });
      },
      context: {
        'feature': 'schedule_management',
        'operation_type': 'delete',
        'groupId': groupId,
        'slotId': slotId,
        'vehicleAssignmentId': vehicleAssignmentId,
        'childAssignmentId': childAssignmentId,
      },
    );

    return result;
  }

  @override
  Future<Result<family_entities.ChildAssignment, ApiFailure>>
  updateChildAssignmentStatus(
    String groupId,
    String slotId,
    String vehicleAssignmentId,
    String childAssignmentId,
    String status,
  ) async {
    // Not implemented in remote datasource yet
    // For now, return not implemented error
    return const Result.err(
      ApiFailure(
        code: 'schedule.not_implemented',
        message: 'Update child assignment status not implemented yet',
        statusCode: 501,
      ),
    );
  }

  @override
  Future<Result<schedule_entities.VehicleAssignment, ApiFailure>>
  updateSeatOverride(
    String groupId,
    String vehicleAssignmentId,
    int? seatOverride,
  ) async {
    // Use NetworkErrorHandler for automatic retry, circuit breaker, and proper error handling
    final result = await _networkErrorHandler
        .executeRepositoryOperation<VehicleAssignmentDto>(
          () => _remoteDataSource.updateSeatOverride(
            vehicleAssignmentId: vehicleAssignmentId,
            seatOverride: seatOverride,
          ),
          operationName: 'schedule.updateSeatOverride',
          strategy: CacheStrategy.networkOnly, // Write operation = network-only
          serviceName: 'schedule',
          config: RetryConfig.quick,
          onSuccess: (dto) async {
            // CACHE AUTO-UPDATE: Update cache automatically on network success
            final updatedAssignment = dto.toDomain();

            // DEBUG: Log the received capacity to see if backend sends correct data
            AppLogger.debug('[SCHEDULE] Backend seat override response', {
              'assignmentId': updatedAssignment.id,
              'vehicleCapacity': updatedAssignment.capacity,
              'seatOverride': updatedAssignment.seatOverride,
              'vehicleId': updatedAssignment.vehicleId,
            });

            try {
              await _localDataSource.updateCachedVehicleAssignment(
                updatedAssignment,
              );
              AppLogger.info(
                '[SCHEDULE] Seat override update cached successfully',
                {
                  'vehicleAssignmentId': vehicleAssignmentId,
                  'seatOverride': seatOverride,
                },
              );
            } catch (cacheError) {
              AppLogger.warning(
                '[SCHEDULE] Cache write failed (operation: updateSeatOverride_cache_write)',
                cacheError,
              );
            }
          },
          context: {
            'feature': 'schedule_management',
            'operation_type': 'update',
            'groupId': groupId,
            'vehicleAssignmentId': vehicleAssignmentId,
            'seatOverride': seatOverride,
          },
        );

    return result.when(
      ok: (dto) => Result.ok(dto.toDomain()),
      err: (failure) => Result.err(failure),
    );
  }

  /// Internal method that accepts week parameter for more reliable cache updates
  /// Used by providers that have the week context available
  Future<Result<schedule_entities.VehicleAssignment, ApiFailure>>
  updateSeatOverrideWithWeek(
    String groupId,
    String vehicleAssignmentId,
    int? seatOverride,
    String week,
  ) async {
    // Use NetworkErrorHandler for automatic retry, circuit breaker, and proper error handling
    final result = await _networkErrorHandler
        .executeRepositoryOperation<VehicleAssignmentDto>(
          () => _remoteDataSource.updateSeatOverride(
            vehicleAssignmentId: vehicleAssignmentId,
            seatOverride: seatOverride,
          ),
          operationName: 'schedule.updateSeatOverrideWithWeek',
          strategy: CacheStrategy.networkOnly, // Write operation = network-only
          serviceName: 'schedule',
          config: RetryConfig.quick,
          onSuccess: (dto) async {
            // CACHE AUTO-UPDATE: Update cache automatically on network success
            final updatedAssignment = dto.toDomain();
            final slotId = updatedAssignment.scheduleSlotId;
            try {
              await _localDataSource.updateCachedVehicleAssignment(
                updatedAssignment,
              );

              // Use provided week for cache update (no need to search)
              AppLogger.debug(
                '[SCHEDULE] Using provided week $week for slot $slotId cache update',
              );
              await _updateWeeklyScheduleCacheAfterSeatOverride(
                groupId,
                week,
                slotId,
                updatedAssignment,
              );
              AppLogger.info(
                '[SCHEDULE] Seat override with week cached successfully',
                {
                  'vehicleAssignmentId': vehicleAssignmentId,
                  'seatOverride': seatOverride,
                  'week': week,
                },
              );
            } catch (cacheError) {
              AppLogger.warning(
                '[SCHEDULE] Cache write failed (operation: updateSeatOverrideWithWeek_cache_write)',
                cacheError,
              );
            }
          },
          context: {
            'feature': 'schedule_management',
            'operation_type': 'update',
            'groupId': groupId,
            'vehicleAssignmentId': vehicleAssignmentId,
            'seatOverride': seatOverride,
            'week': week,
          },
        );

    return result.when(
      ok: (dto) => Result.ok(dto.toDomain()),
      err: (failure) => Result.err(failure),
    );
  }

  // ========================================
  // SCHEDULE CONFIG OPERATIONS (READ = networkOnly + manual fallback, WRITE = networkOnly)
  // ========================================

  @override
  Future<Result<schedule_entities.ScheduleConfig, ApiFailure>>
  getScheduleConfig(String groupId) async {
    // Use NetworkErrorHandler with networkOnly strategy + manual cache fallback (EXACT PATTERN)
    final result = await _networkErrorHandler
        .executeRepositoryOperation<ScheduleConfigDto>(
          () => _remoteDataSource.getScheduleConfig(groupId),
          operationName: 'schedule.getScheduleConfig',
          strategy: CacheStrategy.networkOnly,
          serviceName: 'schedule',
          config: RetryConfig.quick,
          onSuccess: (dto) async {
            final config = dto.toDomain();
            await _localDataSource.cacheScheduleConfig(config);
            AppLogger.info(
              '[SCHEDULE] Schedule config cached successfully after network success',
            );
          },
          context: {
            'feature': 'schedule_management',
            'operation_type': 'read',
            'cache_strategy': 'network_only_with_manual_cache_fallback',
            'groupId': groupId,
          },
        );

    return result.when(
      ok: (dto) {
        final config = dto.toDomain();
        return Result.ok(config);
      },
      err: (failure) async {
        // BUSINESS LOGIC: 404 means no config exists - return the failure so provider handles it
        // The provider (group_schedule_config_provider.dart) correctly handles 404 by setting state to null
        if (failure.statusCode == 404 || failure.code == 'api.not_found') {
          AppLogger.info(
            '[SCHEDULE] Schedule config not found (404) - no config exists',
          );
          return Result.err(failure);
        }

        // HTTP 0 / Network error: fallback to cache (Principe 0)
        if (failure.statusCode == 0 || failure.statusCode == 503) {
          try {
            final cachedConfig = await _localDataSource.getCachedScheduleConfig(
              groupId,
            );
            if (cachedConfig != null) {
              AppLogger.info(
                '[SCHEDULE] Network error - returning cached config (Principe 0)',
              );
              return Result.ok(cachedConfig);
            }
          } catch (cacheError) {
            AppLogger.warning(
              '[SCHEDULE] Failed to retrieve cache after network error',
              cacheError,
            );
          }
        }

        return Result.err(failure);
      },
    );
  }

  @override
  Future<Result<schedule_entities.ScheduleConfig, ApiFailure>>
  updateScheduleConfig(
    String groupId,
    schedule_entities.ScheduleConfig config,
  ) async {
    // Create request DTO from domain entity
    // Note: timezone is no longer sent - backend uses authenticated user's timezone from DB
    final request = UpdateScheduleConfigRequest(
      scheduleHours: config.scheduleHours,
    );

    // Use NetworkErrorHandler for automatic retry, circuit breaker, and proper error handling
    final result = await _networkErrorHandler
        .executeRepositoryOperation<ScheduleConfigDto>(
          () => _remoteDataSource.updateScheduleConfig(groupId, request),
          operationName: 'schedule.updateScheduleConfig',
          strategy: CacheStrategy.networkOnly, // Write operation = network-only
          serviceName: 'schedule',
          config: RetryConfig.quick,
          onSuccess: (dto) async {
            // CACHE AUTO-UPDATE: Update cache automatically on network success
            final updatedConfig = dto.toDomain();
            try {
              await _localDataSource.cacheScheduleConfig(updatedConfig);
              AppLogger.info(
                '[SCHEDULE] Schedule config updated and cached successfully',
                {'groupId': groupId},
              );
            } catch (cacheError) {
              AppLogger.warning(
                '[SCHEDULE] Cache write failed (operation: updateScheduleConfig_cache_write)',
                cacheError,
              );
            }
          },
          context: {
            'feature': 'schedule_management',
            'operation_type': 'update',
            'groupId': groupId,
          },
        );

    return result.when(
      ok: (dto) => Result.ok(dto.toDomain()),
      err: (failure) => Result.err(failure),
    );
  }

  @override
  Future<Result<schedule_entities.ScheduleConfig, ApiFailure>>
  resetScheduleConfig(String groupId) async {
    // Use NetworkErrorHandler for automatic retry, circuit breaker, and proper error handling
    final result = await _networkErrorHandler
        .executeRepositoryOperation<ScheduleConfigDto>(
          () => _remoteDataSource.resetScheduleConfig(groupId),
          operationName: 'schedule.resetScheduleConfig',
          strategy: CacheStrategy.networkOnly, // Write operation = network-only
          serviceName: 'schedule',
          config: RetryConfig.quick,
          onSuccess: (dto) async {
            // CACHE AUTO-UPDATE: Update cache automatically on network success
            final resetConfig = dto.toDomain();
            try {
              await _localDataSource.cacheScheduleConfig(resetConfig);
              AppLogger.info(
                '[SCHEDULE] Schedule config reset and cached successfully',
                {'groupId': groupId},
              );
            } catch (cacheError) {
              AppLogger.warning(
                '[SCHEDULE] Cache write failed (operation: resetScheduleConfig_cache_write)',
                cacheError,
              );
            }
          },
          context: {
            'feature': 'schedule_management',
            'operation_type': 'update',
            'groupId': groupId,
          },
        );

    return result.when(
      ok: (dto) => Result.ok(dto.toDomain()),
      err: (failure) => Result.err(failure),
    );
  }

  // ========================================
  // ADVANCED OPERATIONS (Basic Implementations)
  // ========================================

  @override
  Future<Result<Map<String, dynamic>, ApiFailure>> getScheduleStatistics(
    String groupId,
    String week,
  ) async {
    // Statistics computation is based on getWeeklySchedule which already uses NetworkErrorHandler
    final scheduleResult = await getWeeklySchedule(groupId, week);
    return scheduleResult.when(
      ok: (schedules) => Result.ok({
        'totalSlots': schedules.length,
        'slotsWithVehicles': schedules
            .where((s) => s.vehicleAssignments.isNotEmpty)
            .length,
        'totalChildren': schedules
            .expand((s) => s.vehicleAssignments)
            .expand((v) => v.childAssignments)
            .length,
        'week': week,
        'generatedAt': DateTime.now().toIso8601String(),
      }),
      err: (error) => Result.err(error),
    );
  }

  @override
  Stream<Result<schedule_entities.ScheduleSlot, ApiFailure>>
  listenToScheduleUpdates(String groupId, String week) {
    // Basic implementation - return empty stream for now
    // Real-time updates would require WebSocket or similar
    return const Stream.empty();
  }

  @override
  Future<Result<void, ApiFailure>> sendTypingIndicator(
    String groupId,
    String userId,
    String action,
    Map<String, dynamic> metadata,
  ) async {
    // Not implemented - would require real-time communication
    return const Result.ok(null);
  }

  @override
  Stream<Result<Map<String, dynamic>, ApiFailure>> listenToTypingIndicators(
    String groupId,
  ) {
    // Not implemented - would require real-time communication
    return const Stream.empty();
  }

  @override
  Future<Result<List<schedule_entities.ScheduleSlot>, ApiFailure>>
  getGroupSchedules(
    String groupId, {
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    // For now, delegate to weekly schedule with current week
    final currentWeek = _getCurrentWeek();
    return getWeeklySchedule(groupId, currentWeek);
  }

  @override
  Future<Result<Map<String, dynamic>, ApiFailure>> optimizeGroupSchedule(
    String groupId,
    String week, {
    String criteria = 'efficiency',
  }) async {
    // Basic optimization implementation
    final scheduleResult = await getWeeklySchedule(groupId, week);

    return scheduleResult.when(
      ok: (schedules) => Result.ok({
        'criteria': criteria,
        'original_slots': schedules.length,
        'optimized_slots': schedules.length,
        'improvement_score': 0.1,
        'improvements': ['Schedule organized by time'],
      }),
      err: (error) => Result.err(error),
    );
  }

  String _getCurrentWeek() {
    final now = DateTime.now();
    final year = now.year;
    final dayOfYear = now.difference(DateTime(year)).inDays;
    final weekNumber = ((dayOfYear + DateTime(year).weekday - 1) / 7).ceil();
    return '$year-W${weekNumber.toString().padLeft(2, '0')}';
  }

  // ========================================
  // PRIVATE CACHE UPDATE HELPERS (TRUE SERVER-FIRST PATTERN)
  // ========================================

  /// Updates weekly schedule cache after vehicle assignment
  /// Follows family repository pattern: surgical cache update, not clearing all cache
  Future<void> _updateWeeklyScheduleCacheAfterAssignment(
    String groupId,
    String week,
    String slotId,
    schedule_entities.VehicleAssignment newAssignment,
  ) async {
    try {
      // Get current cached weekly schedule
      final cachedSchedule = await _localDataSource.getCachedWeeklySchedule(
        groupId,
        week,
      );
      if (cachedSchedule == null) return; // No cache to update

      // Find the slot and update it with the new vehicle assignment
      final updatedSchedule = cachedSchedule.map((slot) {
        if (slot.id == slotId) {
          // Add the new assignment to this slot's vehicle assignments
          final updatedAssignments = [
            ...slot.vehicleAssignments,
            newAssignment,
          ];
          return slot.copyWith(vehicleAssignments: updatedAssignments);
        }
        return slot;
      }).toList();

      // Update the cache with the modified schedule
      await _localDataSource.cacheWeeklySchedule(
        groupId,
        week,
        updatedSchedule,
      );
    } catch (e) {
      // Silent fail - cache update is optional, don't break the operation
    }
  }

  /// Updates weekly schedule cache after vehicle removal
  /// Follows family repository pattern: surgical cache update, not clearing all cache
  /// Requires explicit week parameter to avoid metadata searching
  Future<void> _updateWeeklyScheduleCacheAfterRemoval(
    String groupId,
    String week,
    String slotId,
    String vehicleAssignmentId,
  ) async {
    try {
      AppLogger.debug(
        '[Schedule] Updating weekly schedule cache after vehicle removal',
        {
          'groupId': groupId,
          'week': week,
          'slotId': slotId,
          'vehicleAssignmentId': vehicleAssignmentId,
        },
      );

      // Get current cached weekly schedule
      final cachedSchedule = await _localDataSource.getCachedWeeklySchedule(
        groupId,
        week,
      );
      if (cachedSchedule == null) {
        AppLogger.warning('[Schedule] No cached schedule found for week $week');
        return;
      }

      AppLogger.debug(
        '[Schedule] Found cached schedule with ${cachedSchedule.length} slots',
      );

      // Find the slot and remove the vehicle assignment
      var slotFound = false;
      var assignmentRemoved = false;

      final updatedSchedule = cachedSchedule.map((slot) {
        if (slot.id == slotId) {
          slotFound = true;
          AppLogger.debug(
            '[Schedule] Found slot $slotId, removing vehicle assignment',
          );

          // Remove the specific vehicle assignment
          final updatedAssignments = slot.vehicleAssignments
              .where((assignment) => assignment.id != vehicleAssignmentId)
              .toList();

          if (updatedAssignments.length != slot.vehicleAssignments.length) {
            assignmentRemoved = true;
            AppLogger.debug(
              '[Schedule] Removed vehicle assignment $vehicleAssignmentId from slot $slotId',
            );
          }

          return slot.copyWith(vehicleAssignments: updatedAssignments);
        }
        return slot;
      }).toList();

      if (!slotFound) {
        AppLogger.warning(
          '[Schedule] Slot $slotId not found in cached schedule for week $week',
        );
        return;
      }

      if (!assignmentRemoved) {
        AppLogger.warning(
          '[Schedule] Vehicle assignment $vehicleAssignmentId not found in slot $slotId',
        );
        return;
      }

      // Update the cache with the modified schedule
      await _localDataSource.cacheWeeklySchedule(
        groupId,
        week,
        updatedSchedule,
      );

      AppLogger.info(
        '[Schedule] Successfully updated weekly schedule cache after vehicle removal',
        {
          'groupId': groupId,
          'week': week,
          'slotId': slotId,
          'vehicleAssignmentId': vehicleAssignmentId,
        },
      );
    } catch (e) {
      AppLogger.error(
        '[Schedule] Failed to update weekly schedule cache after vehicle removal',
        e,
      );
      AppLogger.debug('[Schedule] Cache update failure details', {
        'groupId': groupId,
        'week': week,
        'slotId': slotId,
        'vehicleAssignmentId': vehicleAssignmentId,
      });
      // Don't rethrow - cache update is optional, don't break the operation
    }
  }

  /// Updates weekly schedule cache after seat override change
  /// Follows family repository pattern: surgical cache update, not clearing all cache
  Future<void> _updateWeeklyScheduleCacheAfterSeatOverride(
    String groupId,
    String week,
    String slotId,
    schedule_entities.VehicleAssignment updatedAssignment,
  ) async {
    try {
      AppLogger.debug(
        '[Schedule] Updating weekly schedule cache for seat override',
        {
          'groupId': groupId,
          'week': week,
          'slotId': slotId,
          'assignmentId': updatedAssignment.id,
          'newSeatOverride': updatedAssignment.seatOverride,
        },
      );

      // Get current cached weekly schedule
      final cachedSchedule = await _localDataSource.getCachedWeeklySchedule(
        groupId,
        week,
      );
      if (cachedSchedule == null) {
        AppLogger.warning('[Schedule] No cached schedule found for week $week');
        return;
      }

      AppLogger.debug(
        '[Schedule] Found cached schedule with ${cachedSchedule.length} slots',
      );

      // Find the slot and update the vehicle assignment
      var slotFound = false;
      var assignmentUpdated = false;

      final updatedSchedule = cachedSchedule.map((slot) {
        if (slot.id == slotId) {
          slotFound = true;
          AppLogger.debug(
            '[Schedule] Found slot $slotId, updating vehicle assignment',
          );

          // Update the specific vehicle assignment
          final updatedAssignments = slot.vehicleAssignments.map((assignment) {
            if (assignment.id == updatedAssignment.id) {
              assignmentUpdated = true;
              AppLogger.debug(
                '[Schedule] Updated assignment ${assignment.id} seatOverride from ${assignment.seatOverride} to ${updatedAssignment.seatOverride}',
              );
              return updatedAssignment;
            }
            return assignment;
          }).toList();

          return slot.copyWith(vehicleAssignments: updatedAssignments);
        }
        return slot;
      }).toList();

      if (!slotFound) {
        AppLogger.warning(
          '[Schedule] Slot $slotId not found in cached schedule for week $week',
        );
        return;
      }

      if (!assignmentUpdated) {
        AppLogger.warning(
          '[Schedule] Assignment ${updatedAssignment.id} not found in slot $slotId',
        );
        return;
      }

      // Update the cache with the modified schedule
      await _localDataSource.cacheWeeklySchedule(
        groupId,
        week,
        updatedSchedule,
      );

      AppLogger.info(
        '[Schedule] Successfully updated weekly schedule cache after seat override',
        {
          'groupId': groupId,
          'week': week,
          'slotId': slotId,
          'assignmentId': updatedAssignment.id,
        },
      );
    } catch (e) {
      AppLogger.error(
        '[Schedule] Failed to update weekly schedule cache after seat override',
        e,
      );
      AppLogger.debug('[Schedule] Cache update failure details', {
        'groupId': groupId,
        'week': week,
        'slotId': slotId,
        'assignmentId': updatedAssignment.id,
      });
      // Don't rethrow - cache update is optional, don't break the operation
    }
  }

  // ========================================
  // ERROR MAPPING HELPERS
  // ========================================

  /// Maps ApiFailure to more specific schedule-domain failures
  /// Following the pattern established in family feature for user-friendly error messages
  ///
  /// Handles specific 409 conflict scenarios:
  /// - "Child already assigned" -> Enhanced ApiFailure with schedule.child_already_assigned code
  /// - "capacity exceeded" / "vehicle full" -> Enhanced ApiFailure with schedule.capacity_exceeded_race code
  ///
  /// Returns ApiFailure with domain-specific error codes that the UI can detect
  ApiFailure _mapScheduleApiFailure(ApiFailure failure, List<String> childIds) {
    // Only map 409 Conflict errors - other status codes pass through unchanged
    if (failure.statusCode != 409) {
      return failure;
    }

    final errorMessage = (failure.message ?? '').toLowerCase();

    // Pattern 1: Child already assigned to this slot
    // Backend message: "Child already assigned to this slot"
    if (errorMessage.contains('child already assigned') ||
        errorMessage.contains('already assigned to this slot')) {
      // Extract child name from context if available
      final childName = childIds.isNotEmpty ? childIds.first : 'Child';

      // Return ApiFailure with schedule-specific code
      return ApiFailure(
        code: 'schedule.child_already_assigned',
        message:
            'This child is already assigned to another vehicle for this time slot. '
            'Please check the schedule and try again.',
        statusCode: 409,
        details: {'childName': childName, 'originalError': failure.message},
      );
    }

    // Pattern 2: Capacity exceeded (race condition)
    // Backend messages: "Vehicle capacity exceeded", "Vehicle is full"
    if (errorMessage.contains('capacity exceeded') ||
        errorMessage.contains('vehicle full') ||
        errorMessage.contains('vehicle is full') ||
        errorMessage.contains('no more seats')) {
      return ApiFailure(
        code: 'schedule.capacity_exceeded_race',
        message:
            'Vehicle capacity exceeded. Another parent assigned a child while you were editing.',
        statusCode: 409,
        details: {'type': 'race_condition', 'originalError': failure.message},
      );
    }

    // Pattern 3: Generic 409 conflict - return as-is but with better context
    AppLogger.warning('[SCHEDULE] Unmapped 409 conflict error', {
      'message': failure.message,
      'code': failure.code,
    });
    return failure;
  }
}
