// Injectable annotation removed for clean architecture migration

import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/schedule_repository.dart';
import 'package:edulift/core/domain/entities/schedule.dart';

class GetScheduleConfig {
  final GroupScheduleRepository repository;

  GetScheduleConfig(this.repository);

  Future<Result<ScheduleConfig, ApiFailure>> call(
    GetScheduleConfigParams params,
  ) {
    return repository.getScheduleConfig(params.groupId);
  }
}

class UpdateScheduleConfig {
  final GroupScheduleRepository repository;

  UpdateScheduleConfig(this.repository);

  Future<Result<ScheduleConfig, ApiFailure>> call(
    UpdateScheduleConfigParams params,
  ) async {
    // Validate the config before updating
    final validationResult = _validateScheduleConfig(params.config);
    if (validationResult case Err(:final error)) {
      return Result.err(error);
    }

    return repository.updateScheduleConfig(params.groupId, params.config);
  }

  Result<void, ApiFailure> _validateScheduleConfig(ScheduleConfig config) {
    // Check that at least one day has time slots
    var hasTimeSlots = false;
    for (final daySlots in config.scheduleHours.values) {
      if (daySlots.isNotEmpty) {
        hasTimeSlots = true;
        break;
      }
    }

    if (!hasTimeSlots) {
      return Result.err(
        ApiFailure.validationError(
          message: 'At least one time slot is required',
        ),
      );
    }

    // maxVehiclesPerSlot validation removed - not part of simplified config

    return const Result.ok(null);
  }
}

class ResetScheduleConfig {
  final GroupScheduleRepository repository;

  ResetScheduleConfig(this.repository);

  Future<Result<ScheduleConfig, ApiFailure>> call(
    ResetScheduleConfigParams params,
  ) {
    return repository.resetScheduleConfig(params.groupId);
  }
}

class GetScheduleConfigParams {
  final String groupId;

  GetScheduleConfigParams({required this.groupId});
}

class UpdateScheduleConfigParams {
  final String groupId;
  final ScheduleConfig config;

  UpdateScheduleConfigParams({required this.groupId, required this.config});
}

class ResetScheduleConfigParams {
  final String groupId;

  ResetScheduleConfigParams({required this.groupId});
}
