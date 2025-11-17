// EduLift Mobile - Schedule Remote Data Source Interface
// Clean Architecture data source abstraction
// Returns DTOs instead of domain entities for clean architecture compliance

import '../../../../core/network/models/schedule/schedule_slot_dto.dart';
import '../../../../core/network/models/schedule/vehicle_assignment_dto.dart';
import '../../../../core/network/models/schedule/schedule_config_dto.dart';
import '../../../../core/network/requests/group_requests.dart';

/// Abstract interface for schedule remote data source
/// Defines all remote data operations without implementation details
/// Returns DTOs instead of domain entities for clean architecture compliance
abstract class ScheduleRemoteDataSource {
  // ========================================
  // BASIC SLOT OPERATIONS - RETURNING DTOs
  // ========================================

  /// Get weekly schedule from server
  Future<List<ScheduleSlotDto>> getWeeklySchedule(String groupId, String week);

  // ========================================
  // VEHICLE OPERATIONS - RETURNING DTOs
  // ========================================

  /// Assign vehicle to slot on server
  Future<VehicleAssignmentDto> assignVehicleToSlot({
    required String groupId,
    required String day,
    required String time,
    required String week,
    required String vehicleId,
  });

  /// Remove vehicle from slot on server
  Future<void> removeVehicleFromSlot({
    required String groupId,
    required String slotId,
    required String vehicleId,
  });

  /// Update seat override for vehicle assignment on server
  Future<VehicleAssignmentDto> updateSeatOverride({
    required String vehicleAssignmentId,
    required int? seatOverride,
  });

  // ========================================
  // CHILD OPERATIONS - RETURNING DTOs
  // ========================================

  /// Assign children to vehicle on server
  Future<VehicleAssignmentDto> assignChildrenToVehicle({
    required String groupId,
    required String slotId,
    required String vehicleAssignmentId,
    required List<String> childIds,
  });

  /// Remove child from vehicle on server
  Future<void> removeChildFromVehicle({
    required String groupId,
    required String slotId,
    required String vehicleAssignmentId,
    required String childAssignmentId,
  });

  // ========================================
  // SCHEDULE CONFIG OPERATIONS - RETURNING DTOs
  // ========================================

  /// Get schedule configuration for group from server
  Future<ScheduleConfigDto> getScheduleConfig(String groupId);

  /// Update schedule configuration for group on server
  Future<ScheduleConfigDto> updateScheduleConfig(
    String groupId,
    UpdateScheduleConfigRequest request,
  );

  /// Reset schedule configuration for group on server
  Future<ScheduleConfigDto> resetScheduleConfig(String groupId);
}
