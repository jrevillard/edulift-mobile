import '../../../../core/utils/result.dart';
import 'package:edulift/core/domain/entities/schedule.dart';
import '../failures/schedule_failure.dart';

/// Parameters for ValidateChildAssignmentUseCase
class ValidateChildAssignmentParams {
  final VehicleAssignment vehicleAssignment;
  final String childId;
  final List<String> currentlyAssignedChildIds;

  const ValidateChildAssignmentParams({
    required this.vehicleAssignment,
    required this.childId,
    required this.currentlyAssignedChildIds,
  });
}

/// Use case for client-side validation of child assignments
/// Prevents capacity violations and duplicate assignments BEFORE server call
/// This is the "proactive prevention" layer described in the migration plan
class ValidateChildAssignmentUseCase {
  const ValidateChildAssignmentUseCase();

  /// Validates if a child can be assigned to a vehicle
  /// Returns ok if valid, error with specific ScheduleFailure if invalid
  Future<Result<void, ScheduleFailure>> call(
    ValidateChildAssignmentParams params,
  ) async {
    // 1. Check if child already assigned to THIS vehicle (allow toggle off)
    final isAlreadyAssignedToThisVehicle = params.currentlyAssignedChildIds
        .contains(params.childId);

    if (isAlreadyAssignedToThisVehicle) {
      return const Result.ok(null); // OK to unassign (toggle off)
    }

    // 2. Count current assignments for THIS vehicle
    final assignedCount = params.currentlyAssignedChildIds.length;
    final capacity = params.vehicleAssignment.effectiveCapacity;

    // 3. Check capacity - BLOCK if at or over capacity
    if (assignedCount >= capacity) {
      return Result.err(
        ScheduleFailure.capacityExceeded(
          capacity: capacity,
          assigned: assignedCount,
          details:
              'Cannot assign child. Vehicle is at full capacity ($assignedCount/$capacity seats).',
        ),
      );
    }

    // 4. All checks passed - assignment is valid
    return const Result.ok(null);
  }
}
