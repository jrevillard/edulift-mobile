import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import 'package:edulift/core/domain/entities/schedule.dart'
    as schedule_entities;
import '../../../family/domain/entities/child_assignment.dart'
    as family_entities;
import '../../../../core/domain/entities/family/child.dart';

abstract class GroupScheduleRepository {
  /// Get weekly schedule for a group
  Future<Result<List<schedule_entities.ScheduleSlot>, ApiFailure>>
  getWeeklySchedule(String groupId, String week);

  /// Get schedule configuration for a group
  Future<Result<schedule_entities.ScheduleConfig, ApiFailure>>
  getScheduleConfig(String groupId);

  /// Create or update a schedule slot
  Future<Result<schedule_entities.ScheduleSlot, ApiFailure>> upsertScheduleSlot(
    String groupId,
    String day,
    String time,
    String week,
  );

  /// Assign a vehicle to a schedule slot
  Future<Result<schedule_entities.VehicleAssignment, ApiFailure>>
  assignVehicleToSlot(
    String groupId,
    String day,
    String time,
    String week,
    String vehicleId,
  );

  /// Remove a vehicle from a schedule slot
  Future<Result<void, ApiFailure>> removeVehicleFromSlot(
    String groupId,
    String slotId,
    String vehicleAssignmentId,
  );

  /// Remove a vehicle from a schedule slot with explicit week parameter
  /// Used by providers that have the week context available for cleaner cache updates
  Future<Result<void, ApiFailure>> removeVehicleFromSlotWithWeek(
    String groupId,
    String slotId,
    String vehicleAssignmentId,
    String week,
  );

  /// Assign children to a vehicle
  Future<Result<schedule_entities.VehicleAssignment, ApiFailure>>
  assignChildrenToVehicle(
    String groupId,
    String slotId,
    String vehicleAssignmentId,
    List<String> childIds,
  );

  /// Remove a child from a vehicle
  Future<Result<void, ApiFailure>> removeChildFromVehicle(
    String groupId,
    String slotId,
    String vehicleAssignmentId,
    String childAssignmentId,
  );

  /// Update child assignment status
  Future<Result<family_entities.ChildAssignment, ApiFailure>>
  updateChildAssignmentStatus(
    String groupId,
    String slotId,
    String vehicleAssignmentId,
    String childAssignmentId,
    String status,
  );

  /// Update seat override for a vehicle assignment
  Future<Result<schedule_entities.VehicleAssignment, ApiFailure>>
  updateSeatOverride(
    String groupId,
    String vehicleAssignmentId,
    int? seatOverride,
  );

  /// Get available children for assignment
  Future<Result<List<Child>, ApiFailure>> getAvailableChildren(
    String groupId,
    String week,
    String day,
    String time,
  );

  /// Check for schedule conflicts
  Future<Result<List<schedule_entities.ScheduleConflict>, ApiFailure>>
  checkScheduleConflicts(
    String groupId,
    String vehicleId,
    String week,
    String day,
    String time,
  );

  /// Update schedule configuration
  Future<Result<schedule_entities.ScheduleConfig, ApiFailure>>
  updateScheduleConfig(String groupId, schedule_entities.ScheduleConfig config);

  /// Reset schedule configuration to defaults
  Future<Result<schedule_entities.ScheduleConfig, ApiFailure>>
  resetScheduleConfig(String groupId);

  /// Copy weekly schedule
  Future<Result<void, ApiFailure>> copyWeeklySchedule(
    String groupId,
    String sourceWeek,
    String targetWeek,
  );

  /// Clear weekly schedule
  Future<Result<void, ApiFailure>> clearWeeklySchedule(
    String groupId,
    String week,
  );

  /// Get schedule statistics
  Future<Result<Map<String, dynamic>, ApiFailure>> getScheduleStatistics(
    String groupId,
    String week,
  );

  /// Listen to real-time schedule updates
  Stream<Result<schedule_entities.ScheduleSlot, ApiFailure>>
  listenToScheduleUpdates(String groupId, String week);

  /// Send typing indicator for collaborative editing
  Future<Result<void, ApiFailure>> sendTypingIndicator(
    String groupId,
    String userId,
    String action,
    Map<String, dynamic> metadata,
  );

  /// Listen to typing indicators
  Stream<Result<Map<String, dynamic>, ApiFailure>> listenToTypingIndicators(
    String groupId,
  );

  /// Get all schedules for a group with optional date filtering
  Future<Result<List<schedule_entities.ScheduleSlot>, ApiFailure>>
  getGroupSchedules(String groupId, {DateTime? fromDate, DateTime? toDate});

  /// Optimize schedule for a group
  Future<Result<Map<String, dynamic>, ApiFailure>> optimizeGroupSchedule(
    String groupId,
    String week, {
    String criteria = 'efficiency',
  });
}
