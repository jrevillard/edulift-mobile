import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/schedule_repository.dart';
import 'package:edulift/core/domain/entities/schedule.dart';

class AssignChildrenToVehicle {
  final GroupScheduleRepository repository;

  AssignChildrenToVehicle(this.repository);

  Future<Result<VehicleAssignment, ApiFailure>> call(
    AssignChildrenToVehicleParams params,
  ) {
    return repository.assignChildrenToVehicle(
      params.groupId,
      params.slotId,
      params.vehicleAssignmentId,
      params.childIds,
    );
  }
}

class AssignChildrenToVehicleParams {
  final String groupId;
  final String slotId;
  final String vehicleAssignmentId;
  final List<String> childIds;
  final String week;
  final String day;
  final String time;

  AssignChildrenToVehicleParams({
    required this.groupId,
    required this.slotId,
    required this.vehicleAssignmentId,
    required this.childIds,
    required this.week,
    required this.day,
    required this.time,
  });
}
