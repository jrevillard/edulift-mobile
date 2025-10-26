import '../../../../core/errors/failures.dart';

/// Schedule-specific failure class for domain-level validation
/// Used for client-side validation and business logic errors
class ScheduleFailure extends Failure {
  const ScheduleFailure({
    super.message,
    super.code,
    super.statusCode,
    super.details,
  });

  /// Factory for capacity exceeded errors (pre-validation)
  factory ScheduleFailure.capacityExceeded({
    required int capacity,
    required int assigned,
    String? details,
  }) => ScheduleFailure(
    code: 'schedule.capacity_exceeded',
    message: details ?? 'Vehicle capacity exceeded',
    statusCode: 400,
    details: {
      'capacity': capacity,
      'assigned': assigned,
      'available': capacity - assigned,
    },
  );

  /// Factory for child already assigned errors
  factory ScheduleFailure.childAlreadyAssigned({
    required String childName,
    String? details,
  }) => ScheduleFailure(
    code: 'schedule.child_already_assigned',
    message:
        details ??
        'Child already assigned to another vehicle for this time slot',
    statusCode: 409,
    details: {'childName': childName},
  );

  /// Factory for race condition detection (server state changed while offline)
  factory ScheduleFailure.capacityExceededRace({
    required int capacity,
    required int assigned,
  }) => ScheduleFailure(
    code: 'schedule.capacity_exceeded_race',
    message:
        'Vehicle capacity exceeded. Another parent assigned a child while you were editing.',
    statusCode: 409,
    details: {
      'capacity': capacity,
      'assigned': assigned,
      'type': 'race_condition',
    },
  );

  /// Factory for validation errors
  factory ScheduleFailure.validationError({
    required String message,
    Map<String, dynamic>? details,
  }) => ScheduleFailure(
    code: 'schedule.validation_error',
    message: message,
    statusCode: 400,
    details: details,
  );

  /// Factory for not found errors
  factory ScheduleFailure.notFound({required String resource}) =>
      ScheduleFailure(
        code: 'schedule.not_found',
        message: '$resource not found',
        statusCode: 404,
        details: {'resource': resource},
      );

  /// Factory for network errors
  factory ScheduleFailure.noConnection() => const ScheduleFailure(
    code: 'network.no_connection',
    message: 'No internet connection',
    statusCode: 503,
  );

  /// Factory for server errors
  factory ScheduleFailure.serverError({
    String? message,
    Map<String, dynamic>? details,
  }) => ScheduleFailure(
    code: 'schedule.server_error',
    message: message ?? 'Server error occurred',
    statusCode: 500,
    details: details,
  );
}
