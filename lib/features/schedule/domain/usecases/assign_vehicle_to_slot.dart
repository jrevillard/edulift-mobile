import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/schedule_repository.dart';
import '../services/schedule_datetime_service.dart';
import 'package:edulift/core/domain/entities/schedule.dart';

class AssignVehicleToSlot {
  final GroupScheduleRepository repository;
  final ScheduleDateTimeService dateTimeService;

  AssignVehicleToSlot(
    this.repository, {
    ScheduleDateTimeService? dateTimeService,
  }) : dateTimeService = dateTimeService ?? const ScheduleDateTimeService();

  Future<Result<VehicleAssignment, ApiFailure>> call(
    AssignVehicleToSlotParams params,
  ) async {
    // Validate input parameters (business rules)
    if (params.groupId.isEmpty ||
        params.day.isEmpty ||
        params.time.isEmpty ||
        params.week.isEmpty ||
        params.vehicleId.isEmpty) {
      return Result.err(
        ApiFailure.validationError(
          message:
              'All parameters (groupId, day, time, week, vehicleId) must be non-empty',
        ),
      );
    }

    // Validate that the datetime can be calculated from the parameters
    final datetime = dateTimeService.calculateDateTimeFromSlot(
      params.day,
      params.time,
      params.week,
    );
    if (datetime == null) {
      return Result.err(
        ApiFailure.validationError(
          message:
              'Invalid datetime calculation: day=${params.day}, time=${params.time}, week=${params.week}',
        ),
      );
    }

    // Delegate to repository
    return repository.assignVehicleToSlot(
      params.groupId,
      params.day,
      params.time,
      params.week,
      params.vehicleId,
    );
  }
}

class AssignVehicleToSlotParams {
  final String groupId;
  final String day;
  final String time;
  final String week;
  final String vehicleId;

  AssignVehicleToSlotParams({
    required this.groupId,
    required this.day,
    required this.time,
    required this.week,
    required this.vehicleId,
  });
}
