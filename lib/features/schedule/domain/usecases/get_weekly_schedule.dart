import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/schedule_repository.dart';
import 'package:edulift/core/domain/entities/schedule.dart';

class GetWeeklySchedule {
  final GroupScheduleRepository repository;

  GetWeeklySchedule(this.repository);

  Future<Result<List<ScheduleSlot>, ApiFailure>> call(
    GetWeeklyScheduleParams params
  ) {
    return repository.getWeeklySchedule(params.groupId, params.week);
  }
}

class GetWeeklyScheduleParams {
  final String groupId;
  final String week;

  GetWeeklyScheduleParams({required this.groupId, required this.week});
}
