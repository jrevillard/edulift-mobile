import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/schedule_repository.dart';

class RemoveVehicleFromSlot {
  final GroupScheduleRepository repository;

  RemoveVehicleFromSlot(this.repository);

  Future<Result<void, ApiFailure>> call(
    RemoveVehicleFromSlotParams params
  ) async {
    // Validate input parameters (business rules)
    if (params.groupId.isEmpty || params.slotId.isEmpty || params.vehicleAssignmentId.isEmpty) {
      return Result.err(ApiFailure.validationError(
        message: 'Group ID, slot ID, and vehicle assignment ID cannot be empty',
      ));
    }

    // Delegate to repository
    return repository.removeVehicleFromSlot(
      params.groupId,
      params.slotId,
      params.vehicleAssignmentId,
    );
  }
}

class RemoveVehicleFromSlotParams {
  final String groupId;
  final String slotId;
  final String vehicleAssignmentId;

  RemoveVehicleFromSlotParams({
    required this.groupId,
    required this.slotId,
    required this.vehicleAssignmentId,
  });
}