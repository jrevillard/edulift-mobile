import '../../../../core/errors/failures.dart';
import '../errors/schedule_error.dart';

/// Domain-specific schedule failure
/// Represents business logic violations in the schedule domain
class ScheduleFailure extends Failure {
  final ScheduleError error;

  const ScheduleFailure({
    required this.error,
    String? message,
    Map<String, dynamic>? details,
    String? code,
  }) : super(
         message: message,
         code: code ?? 'schedule_error',
         details: details,
       );

  String get localizationKey => error.localizationKey;

  @override
  List<Object?> get props => [error, message, code, details];

  @override
  String toString() => 'ScheduleFailure(error: $error, message: $message)';

  // Factory methods for common schedule errors
  factory ScheduleFailure.slotNotFound({
    String? slotId,
    String? message,
    Map<String, dynamic>? details,
  }) => ScheduleFailure(
    error: ScheduleError.slotNotFound,
    message: message,
    details: {...?details, if (slotId != null) 'slotId': slotId},
  );

  factory ScheduleFailure.vehicleCapacityExceeded({
    required int capacity,
    required int assigned,
    String? vehicleId,
    String? message,
    Map<String, dynamic>? details,
  }) => ScheduleFailure(
    error: ScheduleError.vehicleCapacityExceeded,
    message: message,
    code: 'schedule.capacity_exceeded',
    details: {
      ...?details,
      'capacity': capacity,
      'assigned': assigned,
      'available': capacity - assigned,
      if (vehicleId != null) 'vehicleId': vehicleId,
    },
  );

  factory ScheduleFailure.childAlreadyAssigned({
    required String childId,
    required String childName,
    String? message,
    Map<String, dynamic>? details,
  }) => ScheduleFailure(
    error: ScheduleError.childAlreadyAssigned,
    message: message,
    details: {...?details, 'childId': childId, 'childName': childName},
  );

  factory ScheduleFailure.vehicleAssignmentFailed({
    String? vehicleId,
    String? slotId,
    String? message,
    Map<String, dynamic>? details,
  }) => ScheduleFailure(
    error: ScheduleError.vehicleAssignmentFailed,
    message: message,
    details: {
      ...?details,
      if (vehicleId != null) 'vehicleId': vehicleId,
      if (slotId != null) 'slotId': slotId,
    },
  );

  factory ScheduleFailure.validationError({
    required String message,
    Map<String, dynamic>? details,
  }) => ScheduleFailure(
    error: ScheduleError.timeSlotInvalid,
    message: message,
    details: details,
  );

  factory ScheduleFailure.networkError({
    String? message,
    Map<String, dynamic>? details,
  }) => ScheduleFailure(
    error: ScheduleError.networkError,
    message: message,
    details: details,
  );

  factory ScheduleFailure.serverError({
    String? message,
    Map<String, dynamic>? details,
  }) => ScheduleFailure(
    error: ScheduleError.serverError,
    message: message,
    details: details,
  );
}
