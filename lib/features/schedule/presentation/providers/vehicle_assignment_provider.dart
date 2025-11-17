import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/domain/entities/schedule/vehicle_assignment.dart';
import '../../domain/failures/schedule_failure.dart';
import '../../domain/errors/schedule_error.dart';
import '../../domain/usecases/assign_vehicle_to_slot.dart';
import '../../providers.dart';

/// Provider for vehicle assignment operations with proper error handling
/// Maps ApiFailure to ScheduleFailure
class VehicleAssignmentNotifier {
  final AssignVehicleToSlot _assignVehicleToSlot;

  VehicleAssignmentNotifier(this._assignVehicleToSlot);

  /// Assign a vehicle to a schedule slot
  /// Returns Result<VehicleAssignment, ScheduleFailure> with domain-specific errors
  Future<Result<VehicleAssignment, ScheduleFailure>> assignVehicleToSlot({
    required String groupId,
    required String day,
    required String time,
    required String week,
    required String vehicleId,
  }) async {
    final params = AssignVehicleToSlotParams(
      groupId: groupId,
      day: day,
      time: time,
      week: week,
      vehicleId: vehicleId,
    );

    final result = await _assignVehicleToSlot(params);

    return result.when(
      ok: (vehicleAssignment) => Result.ok(vehicleAssignment),
      err: (apiFailure) =>
          Result.err(_mapApiFailureToScheduleFailure(apiFailure)),
    );
  }

  /// Map ApiFailure to ScheduleFailure
  ScheduleFailure _mapApiFailureToScheduleFailure(ApiFailure apiFailure) {
    ScheduleError scheduleError;

    switch (apiFailure.code) {
      case 'network.no_connection':
        scheduleError = ScheduleError.networkError;
        break;
      case 'validation_error':
        scheduleError = ScheduleError.timeSlotInvalid;
        break;
      case 'not_found':
        scheduleError = ScheduleError.slotNotFound;
        break;
      case 'server_error':
      default:
        scheduleError = ScheduleError.serverError;
        break;
    }

    return ScheduleFailure(
      error: scheduleError,
      message: apiFailure.message,
      details: apiFailure.details,
    );
  }
}

/// Provider for vehicle assignment operations
final vehicleAssignmentProvider = Provider<VehicleAssignmentNotifier>((ref) {
  final assignVehicleToSlot = ref.watch(assignVehicleToSlotUsecaseProvider);

  return VehicleAssignmentNotifier(assignVehicleToSlot);
});
