import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/schedule_repository.dart';
import 'package:edulift/core/domain/entities/schedule.dart';

class CopyWeeklySchedule {
  final GroupScheduleRepository repository;

  CopyWeeklySchedule(this.repository);

  Future<Result<void, ApiFailure>> call(CopyWeeklyScheduleParams params) async {
    // Validate that source and target weeks are different
    if (params.sourceWeek == params.targetWeek) {
      return Result.err(ApiFailure.validationError(
        message: 'Source and target weeks must be different',
      ));
    }

    return repository.copyWeeklySchedule(
      params.groupId,
      params.sourceWeek,
      params.targetWeek,
    );
  }
}

class ClearWeeklySchedule {
  final GroupScheduleRepository repository;

  ClearWeeklySchedule(this.repository);

  Future<Result<void, ApiFailure>> call(ClearWeeklyScheduleParams params) {
    return repository.clearWeeklySchedule(params.groupId, params.week);
  }
}

class GetScheduleStatistics {
  final GroupScheduleRepository repository;

  GetScheduleStatistics(this.repository);

  Future<Result<Map<String, dynamic>, ApiFailure>> call(
    GetScheduleStatisticsParams params
  ) {
    return repository.getScheduleStatistics(params.groupId, params.week);
  }
}

class CheckScheduleConflicts {
  final GroupScheduleRepository repository;

  CheckScheduleConflicts(this.repository);

  Future<Result<List<ScheduleConflict>, ApiFailure>> call(
    CheckScheduleConflictsParams params
  ) {
    return repository.checkScheduleConflicts(
      params.groupId,
      params.vehicleId,
      params.week,
      params.day,
      params.time,
    );
  }
}

class CopyWeeklyScheduleParams {
  final String groupId;
  final String sourceWeek;
  final String targetWeek;

  CopyWeeklyScheduleParams({
    required this.groupId,
    required this.sourceWeek,
    required this.targetWeek,
  });
}

class ClearWeeklyScheduleParams {
  final String groupId;
  final String week;

  ClearWeeklyScheduleParams({required this.groupId, required this.week});
}

class GetScheduleStatisticsParams {
  final String groupId;
  final String week;

  GetScheduleStatisticsParams({required this.groupId, required this.week});
}

class CheckScheduleConflictsParams {
  final String groupId;
  final String vehicleId;
  final String week;
  final String day;
  final String time;

  CheckScheduleConflictsParams({
    required this.groupId,
    required this.vehicleId,
    required this.week,
    required this.day,
    required this.time,
  });
}
