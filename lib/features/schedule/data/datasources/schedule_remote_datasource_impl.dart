// EduLift Mobile - Schedule Remote Data Source Implementation
// Clean Architecture with ScheduleApiClient abstraction
// Returns DTOs instead of domain entities for clean architecture compliance

import '../../../../core/network/schedule_api_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/network/models/schedule/schedule_slot_dto.dart';
import '../../../../core/network/models/schedule/schedule_response_dto.dart';
import '../../../../core/network/models/schedule/vehicle_assignment_dto.dart';
import '../../../../core/network/models/schedule/schedule_config_dto.dart';
import '../../../../core/network/models/child/child_dto.dart';
import '../../../../core/network/models/family/schedule_slot_child_dto.dart';
import '../../../../core/network/requests/schedule_requests.dart';
import '../../../../core/network/requests/group_requests.dart';
import '../../../../core/network/api_response_helper.dart';
import '../../../schedule/domain/services/schedule_datetime_service.dart';
import 'package:edulift/core/utils/date/iso_week_utils.dart';
import 'schedule_remote_datasource.dart';

class ScheduleRemoteDataSourceImpl implements ScheduleRemoteDataSource {
  final ScheduleApiClient _apiClient;
  final ScheduleDateTimeService _dateTimeService;

  // Constructor dependency injection for ScheduleApiClient
  const ScheduleRemoteDataSourceImpl(
    this._apiClient, {
    ScheduleDateTimeService? dateTimeService,
  }) : _dateTimeService = dateTimeService ?? const ScheduleDateTimeService();

  // ========================================
  // BASIC SLOT OPERATIONS
  // ========================================

  @override
  Future<List<ScheduleSlotDto>> getWeeklySchedule(
    String groupId,
    String week,
  ) async {
    AppLogger.debug('[ScheduleRemoteDataSource] getWeeklySchedule() called', {
      'groupId': groupId,
      'week': week,
    });

    // Calculate start and end dates using centralized utils
    final startDate = parseMondayFromISOWeek(week);
    if (startDate == null) {
      throw const ValidationException('Invalid week format');
    }

    // Calculate week end: Monday + 6 days 23:59:59.999
    final endDate = startDate.add(
      const Duration(
        days: 6,
        hours: 23,
        minutes: 59,
        seconds: 59,
        milliseconds: 999,
      ),
    );

    // Convert to ISO string
    final startDateUtc = startDate.toIso8601String();
    final endDateUtc = endDate.toIso8601String();

    final scheduleResponse =
        await ApiResponseHelper.executeAndUnwrap<ScheduleResponseDto>(
          () => _apiClient.getGroupSchedule(groupId, startDateUtc, endDateUtc),
        );

    AppLogger.debug(
      '[ScheduleRemoteDataSource] Successfully fetched ${scheduleResponse.scheduleSlots.length} schedule slots',
    );
    return scheduleResponse.scheduleSlots;
  }

  // ========================================
  // VEHICLE OPERATIONS
  // ========================================

  @override
  Future<VehicleAssignmentDto> assignVehicleToSlot({
    required String groupId,
    required String day,
    required String time,
    required String week,
    required String vehicleId,
  }) async {
    AppLogger.debug('[ScheduleRemoteDataSource] assignVehicleToSlot() called', {
      'groupId': groupId,
      'day': day,
      'time': time,
      'week': week,
      'vehicleId': vehicleId,
    });

    // Calculate datetime from day, time, and week using domain service
    final datetime = _dateTimeService.calculateDateTimeFromSlot(
      day,
      time,
      week,
    );
    if (datetime == null) {
      throw const ValidationException('Invalid datetime calculation');
    }

    // Keep UTC datetime to ensure consistency with scheduleConfig and API data
    // This prevents timezone mismatch issues in vehicle assignment
    final utcDatetime = datetime;

    // STEP 1: Fetch weekly schedule to check if slot exists
    final scheduleSlots = await getWeeklySchedule(groupId, week);

    // STEP 2: Search for existing slot at this datetime
    ScheduleSlotDto? existingSlot;
    for (final slot in scheduleSlots) {
      // Compare UTC datetimes directly (both are UTC from API)
      final slotDateTime = slot.datetime;

      if (slotDateTime.year == utcDatetime.year &&
          slotDateTime.month == utcDatetime.month &&
          slotDateTime.day == utcDatetime.day &&
          slotDateTime.hour == utcDatetime.hour &&
          slotDateTime.minute == utcDatetime.minute) {
        existingSlot = slot;
        AppLogger.debug(
          '[ScheduleRemoteDataSource] Found existing slot: ${slot.id}',
        );
        break;
      }
    }

    VehicleAssignmentDto vehicleAssignmentDto;

    if (existingSlot == null) {
      // STEP 3a: No slot exists → Create new slot with vehicle
      AppLogger.debug(
        '[ScheduleRemoteDataSource] No existing slot found - creating new slot with vehicle',
      );

      // No need to get timezone - backend uses authenticated user's timezone from DB
      final datetimeString = datetime.toIso8601String();
      final createSlotRequest = CreateScheduleSlotRequest(
        datetime: datetimeString,
        vehicleId: vehicleId,
      );

      AppLogger.debug(
        '[ScheduleRemoteDataSource] Creating slot (timezone from user DB)',
      );

      final scheduleSlotDto =
          await ApiResponseHelper.executeAndUnwrap<ScheduleSlotDto>(
            () => _apiClient.createScheduleSlot(groupId, createSlotRequest),
          );

      // Extract the vehicle assignment from the response
      final vehicleAssignments = scheduleSlotDto.vehicleAssignments;
      if (vehicleAssignments == null || vehicleAssignments.isEmpty) {
        throw const ServerException(
          'No vehicle assignment returned from API',
          statusCode: 500,
        );
      }

      vehicleAssignmentDto = vehicleAssignments.first;
    } else {
      // STEP 3b: Slot exists → Assign vehicle to existing slot
      AppLogger.debug(
        '[ScheduleRemoteDataSource] Existing slot found - assigning vehicle to slot ${existingSlot.id}',
      );

      final assignRequest = AssignVehicleRequest(vehicleId: vehicleId);
      vehicleAssignmentDto =
          await ApiResponseHelper.executeAndUnwrap<VehicleAssignmentDto>(
            () => _apiClient.assignVehicleToSlotTyped(
              existingSlot!.id,
              assignRequest,
            ),
          );
    }

    AppLogger.debug('[ScheduleRemoteDataSource] Successfully assigned vehicle');
    return vehicleAssignmentDto;
  }

  @override
  Future<void> removeVehicleFromSlot({
    required String groupId,
    required String slotId,
    required String vehicleAssignmentId,
  }) async {
    AppLogger.debug(
      '[ScheduleRemoteDataSource] removeVehicleFromSlot() called',
      {
        'groupId': groupId,
        'slotId': slotId,
        'vehicleAssignmentId': vehicleAssignmentId,
      },
    );

    await ApiResponseHelper.executeAndUnwrap<void>(
      () => _apiClient.removeVehicleFromSlotTyped(
        slotId,
        RemoveVehicleRequest(vehicleId: vehicleAssignmentId),
      ),
    );

    AppLogger.debug(
      '[ScheduleRemoteDataSource] Successfully removed vehicle from slot',
    );
  }

  @override
  Future<VehicleAssignmentDto> updateSeatOverride({
    required String vehicleAssignmentId,
    required int? seatOverride,
  }) async {
    AppLogger.debug('[ScheduleRemoteDataSource] updateSeatOverride() called', {
      'vehicleAssignmentId': vehicleAssignmentId,
      'seatOverride': seatOverride,
    });

    final request = UpdateSeatOverrideRequest(seatOverride: seatOverride);
    final vehicleAssignmentDto =
        await ApiResponseHelper.executeAndUnwrap<VehicleAssignmentDto>(
          () => _apiClient.updateSeatOverride(vehicleAssignmentId, request),
        );

    AppLogger.debug(
      '[ScheduleRemoteDataSource] Successfully updated seat override',
    );
    return vehicleAssignmentDto;
  }

  // ========================================
  // CHILD OPERATIONS
  // ========================================

  @override
  Future<VehicleAssignmentDto> assignChildrenToVehicle({
    required String groupId,
    required String slotId,
    required String vehicleAssignmentId,
    required List<String> childIds,
  }) async {
    AppLogger.debug(
      '[ScheduleRemoteDataSource] assignChildrenToVehicle() called',
      {
        'groupId': groupId,
        'slotId': slotId,
        'vehicleAssignmentId': vehicleAssignmentId,
        'childCount': childIds.length,
      },
    );

    // Assign children one by one
    for (final childId in childIds) {
      final request = AssignChildRequest(
        childId: childId,
        vehicleAssignmentId: vehicleAssignmentId,
      );

      // API returns ScheduleSlotChildDto but we discard it
      // We'll fetch the updated slot below to get the complete picture
      await ApiResponseHelper.executeAndUnwrap<ScheduleSlotChildDto>(
        () => _apiClient.assignChildToSlot(slotId, request),
      );
    }

    // Fetch the updated vehicle assignment
    final slot = await ApiResponseHelper.executeAndUnwrap<ScheduleSlotDto>(
      () => _apiClient.getScheduleSlot(slotId),
    );

    final vehicleAssignment = slot.vehicleAssignments?.firstWhere(
      (va) => va.id == vehicleAssignmentId,
      orElse: () => throw const ServerException(
        'Vehicle assignment not found',
        statusCode: 404,
      ),
    );

    if (vehicleAssignment == null) {
      throw const ServerException(
        'No vehicle assignments found',
        statusCode: 404,
      );
    }

    AppLogger.debug(
      '[ScheduleRemoteDataSource] Successfully assigned children to vehicle',
    );
    return vehicleAssignment;
  }

  @override
  Future<void> removeChildFromVehicle({
    required String groupId,
    required String slotId,
    required String vehicleAssignmentId,
    required String childAssignmentId,
  }) async {
    AppLogger.debug(
      '[ScheduleRemoteDataSource] removeChildFromVehicle() called',
      {
        'groupId': groupId,
        'slotId': slotId,
        'vehicleAssignmentId': vehicleAssignmentId,
        'childAssignmentId': childAssignmentId,
      },
    );

    await ApiResponseHelper.executeAndUnwrap<void>(
      () => _apiClient.removeChildFromSlot(slotId, childAssignmentId),
    );

    AppLogger.debug(
      '[ScheduleRemoteDataSource] Successfully removed child from vehicle',
    );
  }

  @override
  Future<List<ChildDto>> getAvailableChildren({
    required String groupId,
    required String week,
    required String day,
    required String time,
  }) async {
    AppLogger.debug(
      '[ScheduleRemoteDataSource] getAvailableChildren() called',
      {'groupId': groupId, 'week': week, 'day': day, 'time': time},
    );

    // For now, return empty list until API endpoint is available
    // The API client has getAvailableChildren(slotId) but we need
    // to first find or create the slot based on groupId, week, day, time
    // This is a placeholder implementation
    final availableChildren = <ChildDto>[];

    AppLogger.debug(
      '[ScheduleRemoteDataSource] Successfully fetched available children',
    );
    return availableChildren;
  }

  // ========================================
  // SCHEDULE CONFIG OPERATIONS
  // ========================================

  @override
  Future<ScheduleConfigDto> getScheduleConfig(String groupId) async {
    AppLogger.debug('[ScheduleRemoteDataSource] getScheduleConfig() called', {
      'groupId': groupId,
    });

    final scheduleConfigDto =
        await ApiResponseHelper.executeAndUnwrap<ScheduleConfigDto>(
          () => _apiClient.getGroupScheduleConfig(groupId),
        );

    AppLogger.debug(
      '[ScheduleRemoteDataSource] Successfully fetched schedule config',
    );
    return scheduleConfigDto;
  }

  @override
  Future<ScheduleConfigDto> updateScheduleConfig(
    String groupId,
    UpdateScheduleConfigRequest request,
  ) async {
    AppLogger.debug(
      '[ScheduleRemoteDataSource] updateScheduleConfig() called',
      {'groupId': groupId},
    );

    final scheduleConfigDto =
        await ApiResponseHelper.executeAndUnwrap<ScheduleConfigDto>(
          () => _apiClient.updateGroupScheduleConfigTyped(groupId, request),
        );

    AppLogger.debug(
      '[ScheduleRemoteDataSource] Successfully updated schedule config',
    );
    return scheduleConfigDto;
  }

  @override
  Future<ScheduleConfigDto> resetScheduleConfig(String groupId) async {
    AppLogger.debug('[ScheduleRemoteDataSource] resetScheduleConfig() called', {
      'groupId': groupId,
    });

    final scheduleConfigDto =
        await ApiResponseHelper.executeAndUnwrap<ScheduleConfigDto>(
          () => _apiClient.resetGroupScheduleConfig(groupId),
        );

    AppLogger.debug(
      '[ScheduleRemoteDataSource] Successfully reset schedule config',
    );
    return scheduleConfigDto;
  }
}
