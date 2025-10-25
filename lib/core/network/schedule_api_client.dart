// EduLift Mobile - Schedule API Client
// SPARC-Driven Development with Neural Coordination
// Agent: FlutterSpecialist - Phase 2C API Client Decomposition

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../core/network/models/schedule/schedule_slot_dto.dart';
import '../../core/network/models/schedule/schedule_slot_with_details_dto.dart';
import '../../core/network/models/schedule/schedule_response_dto.dart';
import '../../core/network/models/schedule/vehicle_assignment_dto.dart';
import '../../core/network/models/schedule/schedule_config_dto.dart';
import 'models/schedule/time_slot_config_dto.dart';
import 'models/schedule/conflict_dto.dart';
import 'models/child/child_dto.dart';
import 'models/family/schedule_slot_child_dto.dart';
import 'requests/schedule_requests.dart';
import 'requests/group_requests.dart';

part 'schedule_api_client.g.dart';

/// Schedule API Client Base - Private Retrofit methods only
/// All public methods implemented in ScheduleApiClient wrapper
@RestApi()
abstract class _ScheduleApiClientBase {
  factory _ScheduleApiClientBase(Dio dio, {String? baseUrl}) =
      __ScheduleApiClientBase;

  // ========================================
  // SCHEDULE CONFIGURATION ENDPOINTS
  // ========================================

  @GET('/groups/schedule-config/default')
  Future<ScheduleConfigDto> getDefaultScheduleConfig();

  @GET('/groups/{groupId}/schedule-config')
  Future<ScheduleConfigDto> getGroupScheduleConfig(
    @Path('groupId') String groupId,
  );

  @GET('/groups/{groupId}/schedule-config/time-slots')
  Future<TimeSlotConfigDto> getGroupTimeSlots(
    @Path('groupId') String groupId,
    @Query('weekday') String weekday,
  );

  @PUT('/groups/{groupId}/schedule-config')
  Future<ScheduleConfigDto> updateGroupScheduleConfigTyped(
    @Path('groupId') String groupId,
    @Body() UpdateScheduleConfigRequest request,
  );

  @POST('/groups/{groupId}/schedule-config/reset')
  Future<ScheduleConfigDto> resetGroupScheduleConfig(
    @Path('groupId') String groupId,
  );

  // ========================================
  // SCHEDULE MANAGEMENT ENDPOINTS
  // ========================================

  @POST('/groups/{groupId}/schedule-slots')
  Future<ScheduleSlotDto> createScheduleSlot(
    @Path('groupId') String groupId,
    @Body() CreateScheduleSlotRequest request,
  );

  @GET('/groups/{groupId}/schedule')
  Future<ScheduleResponseDto> getGroupSchedule(
    @Path('groupId') String groupId,
    @Query('startDate') String? startDate,
    @Query('endDate') String? endDate,
  );

  @GET('/schedule-slots/{slotId}')
  Future<ScheduleSlotDto> getScheduleSlot(@Path('slotId') String slotId);

  @GET('/schedule-slots/{slotId}/details')
  Future<ScheduleSlotWithDetailsDto> getScheduleSlotDetails(
    @Path('slotId') String slotId,
  );

  @POST('/schedule-slots/{slotId}/vehicles')
  Future<VehicleAssignmentDto> assignVehicleToSlotTyped(
    @Path('slotId') String slotId,
    @Body() AssignVehicleRequest request,
  );

  @DELETE('/schedule-slots/{slotId}/vehicles')
  Future<void> removeVehicleFromSlotTyped(
    @Path('slotId') String slotId,
    @Body() RemoveVehicleRequest request,
  );

  @PATCH('/schedule-slots/{slotId}/vehicles/{vehicleId}/driver')
  Future<VehicleAssignmentDto> updateVehicleDriver(
    @Path('slotId') String slotId,
    @Path('vehicleId') String vehicleId,
    @Body() UpdateDriverRequest request,
  );

  // ========================================
  // CHILDREN ASSIGNMENT ENDPOINTS
  // ========================================

  @POST('/schedule-slots/{slotId}/children')
  Future<ScheduleSlotChildDto> assignChildToSlot(
    @Path('slotId') String slotId,
    @Body() AssignChildRequest request,
  );

  @DELETE('/schedule-slots/{slotId}/children/{childId}')
  Future<void> removeChildFromSlot(
    @Path('slotId') String slotId,
    @Path('childId') String childId,
  );

  @GET('/schedule-slots/{slotId}/available-children')
  Future<List<ChildDto>> getAvailableChildren(@Path('slotId') String slotId);

  @GET('/schedule-slots/{slotId}/conflicts')
  Future<List<ConflictDto>> getScheduleConflicts(@Path('slotId') String slotId);

  @PATCH('/vehicle-assignments/{vehicleAssignmentId}/seat-override')
  Future<VehicleAssignmentDto> updateSeatOverride(
    @Path('vehicleAssignmentId') String vehicleAssignmentId,
    @Body() UpdateSeatOverrideRequest request,
  );
}

/// Public Schedule API Client with ApiResponse wrapper pattern
/// This is the class that should be used by data sources
class ScheduleApiClient {
  final _ScheduleApiClientBase _client;

  ScheduleApiClient._(this._client);

  factory ScheduleApiClient.create(Dio dio, {String? baseUrl}) {
    return ScheduleApiClient._(_ScheduleApiClientBase(dio, baseUrl: baseUrl));
  }

  // ========================================
  // SCHEDULE CONFIGURATION ENDPOINTS
  // ========================================

  /// Get default schedule configuration
  /// GET /api/v1/groups/schedule-config/default
  Future<ScheduleConfigDto> getDefaultScheduleConfig() =>
      _client.getDefaultScheduleConfig();

  /// Get group schedule configuration
  /// GET /api/v1/groups/{groupId}/schedule-config
  Future<ScheduleConfigDto> getGroupScheduleConfig(String groupId) =>
      _client.getGroupScheduleConfig(groupId);

  /// Get group time slots
  /// GET /api/v1/groups/{groupId}/schedule-config/time-slots
  Future<TimeSlotConfigDto> getGroupTimeSlots(String groupId, String weekday) =>
      _client.getGroupTimeSlots(groupId, weekday);

  /// Update group schedule configuration (typed)
  /// PUT /api/v1/groups/{groupId}/schedule-config
  Future<ScheduleConfigDto> updateGroupScheduleConfigTyped(
    String groupId,
    UpdateScheduleConfigRequest request,
  ) =>
      _client.updateGroupScheduleConfigTyped(groupId, request);

  /// Reset group schedule configuration
  /// POST /api/v1/groups/{groupId}/schedule-config/reset
  Future<ScheduleConfigDto> resetGroupScheduleConfig(String groupId) =>
      _client.resetGroupScheduleConfig(groupId);

  // ========================================
  // SCHEDULE MANAGEMENT ENDPOINTS
  // ========================================

  /// Create schedule slot
  /// POST /api/v1/groups/{groupId}/schedule-slots
  Future<ScheduleSlotDto> createScheduleSlot(
    String groupId,
    CreateScheduleSlotRequest request,
  ) =>
      _client.createScheduleSlot(groupId, request);

  /// Get group schedule
  /// GET /api/v1/groups/{groupId}/schedule
  Future<ScheduleResponseDto> getGroupSchedule(
    String groupId,
    String? startDate,
    String? endDate,
  ) =>
      _client.getGroupSchedule(groupId, startDate, endDate);

  /// Get schedule slot
  /// GET /api/v1/schedule-slots/{slotId}
  Future<ScheduleSlotDto> getScheduleSlot(String slotId) =>
      _client.getScheduleSlot(slotId);

  /// Get schedule slot with full details
  /// GET /api/v1/schedule-slots/{slotId}/details
  Future<ScheduleSlotWithDetailsDto> getScheduleSlotDetails(String slotId) =>
      _client.getScheduleSlotDetails(slotId);

  /// Assign vehicle to slot (typed)
  /// POST /api/v1/schedule-slots/{slotId}/vehicles
  Future<VehicleAssignmentDto> assignVehicleToSlotTyped(
    String slotId,
    AssignVehicleRequest request,
  ) =>
      _client.assignVehicleToSlotTyped(slotId, request);

  /// Remove vehicle from slot (typed)
  /// DELETE /api/v1/schedule-slots/{slotId}/vehicles
  Future<void> removeVehicleFromSlotTyped(
    String slotId,
    RemoveVehicleRequest request,
  ) =>
      _client.removeVehicleFromSlotTyped(slotId, request);

  /// Update vehicle driver
  /// PATCH /api/v1/schedule-slots/{slotId}/vehicles/{vehicleId}/driver
  Future<VehicleAssignmentDto> updateVehicleDriver(
    String slotId,
    String vehicleId,
    UpdateDriverRequest request,
  ) =>
      _client.updateVehicleDriver(slotId, vehicleId, request);

  // ========================================
  // CHILDREN ASSIGNMENT ENDPOINTS
  // ========================================

  /// Assign child to slot
  /// POST /api/v1/schedule-slots/{slotId}/children
  Future<ScheduleSlotChildDto> assignChildToSlot(
    String slotId,
    AssignChildRequest request,
  ) =>
      _client.assignChildToSlot(slotId, request);

  /// Remove child from slot
  /// DELETE /api/v1/schedule-slots/{slotId}/children/{childId}
  Future<void> removeChildFromSlot(String slotId, String childId) =>
      _client.removeChildFromSlot(slotId, childId);

  /// Get available children
  /// GET /api/v1/schedule-slots/{slotId}/available-children
  Future<List<ChildDto>> getAvailableChildren(String slotId) =>
      _client.getAvailableChildren(slotId);

  /// Get schedule conflicts
  /// GET /api/v1/schedule-slots/{slotId}/conflicts
  Future<List<ConflictDto>> getScheduleConflicts(String slotId) =>
      _client.getScheduleConflicts(slotId);

  /// Update seat override
  /// PATCH /api/v1/vehicle-assignments/{vehicleAssignmentId}/seat-override
  Future<VehicleAssignmentDto> updateSeatOverride(
    String vehicleAssignmentId,
    UpdateSeatOverrideRequest request,
  ) =>
      _client.updateSeatOverride(vehicleAssignmentId, request);
}
