// EduLift Mobile - Schedule Domain Schedule Errors
// Clean Architecture domain-specific error definitions for schedules

/// Domain-specific schedule errors following clean architecture principles
/// These errors represent business rule violations in the schedule domain
enum ScheduleError {
  // Schedule slot validation errors
  slotIdRequired,
  slotNotFound,
  slotAlreadyExists,
  slotCreationFailed,
  slotUpdateFailed,
  slotDeletionFailed,

  // Vehicle assignment errors
  vehicleIdRequired,
  vehicleNotFound,
  vehicleAlreadyAssigned,
  vehicleCapacityExceeded,
  vehicleAssignmentFailed,
  vehicleAssignmentNotFound,

  // Child assignment errors
  childIdRequired,
  childNotFound,
  childAlreadyAssigned,
  childAssignmentFailed,
  childAssignmentNotFound,

  // Schedule configuration errors
  scheduleConfigNotFound,
  scheduleConfigUpdateFailed,
  scheduleConfigResetFailed,

  // Time slot errors
  timeSlotRequired,
  timeSlotInvalid,

  // Validation errors
  dayOfWeekRequired,
  timeOfDayRequired,
  weekRequired,
  groupIdRequired,

  // Business logic errors
  cannotAssignToPastSlot,

  // System errors
  scheduleOperationFailed,
  loadScheduleFailed,
  saveScheduleFailed,
  validateScheduleFailed,

  // Network and server errors
  networkError,
  serverError,
  timeoutError,
}

/// Extension to provide localization keys for schedule errors
extension ScheduleErrorLocalization on ScheduleError {
  String get localizationKey {
    switch (this) {
      case ScheduleError.slotIdRequired:
        return 'errorValidation';
      case ScheduleError.slotNotFound:
        return 'errorServerMessage';
      case ScheduleError.slotAlreadyExists:
        return 'errorServerMessage';
      case ScheduleError.slotCreationFailed:
        return 'errorServerMessage';
      case ScheduleError.slotUpdateFailed:
        return 'errorServerMessage';
      case ScheduleError.slotDeletionFailed:
        return 'errorServerMessage';
      case ScheduleError.vehicleIdRequired:
        return 'errorValidation';
      case ScheduleError.vehicleNotFound:
        return 'errorServerMessage';
      case ScheduleError.vehicleAlreadyAssigned:
        return 'errorServerMessage';
      case ScheduleError.vehicleCapacityExceeded:
        return 'errorServerMessage';
      case ScheduleError.vehicleAssignmentFailed:
        return 'errorServerMessage';
      case ScheduleError.vehicleAssignmentNotFound:
        return 'errorServerMessage';
      case ScheduleError.childIdRequired:
        return 'errorValidation';
      case ScheduleError.childNotFound:
        return 'errorServerMessage';
      case ScheduleError.childAlreadyAssigned:
        return 'errorServerMessage';
      case ScheduleError.childAssignmentFailed:
        return 'errorServerMessage';
      case ScheduleError.childAssignmentNotFound:
        return 'errorServerMessage';
      case ScheduleError.scheduleConfigNotFound:
        return 'errorServerMessage';
      case ScheduleError.scheduleConfigUpdateFailed:
        return 'errorServerMessage';
      case ScheduleError.scheduleConfigResetFailed:
        return 'errorServerMessage';
      case ScheduleError.timeSlotRequired:
        return 'errorValidation';
      case ScheduleError.timeSlotInvalid:
        return 'errorValidation';
      case ScheduleError.dayOfWeekRequired:
        return 'errorValidation';
      case ScheduleError.timeOfDayRequired:
        return 'errorValidation';
      case ScheduleError.weekRequired:
        return 'errorValidation';
      case ScheduleError.groupIdRequired:
        return 'errorValidation';
      case ScheduleError.cannotAssignToPastSlot:
        return 'errorValidation';
      case ScheduleError.scheduleOperationFailed:
        return 'errorServerMessage';
      case ScheduleError.loadScheduleFailed:
        return 'errorServerMessage';
      case ScheduleError.saveScheduleFailed:
        return 'errorServerMessage';
      case ScheduleError.validateScheduleFailed:
        return 'errorValidation';
      case ScheduleError.networkError:
        return 'errorNetworkMessage';
      case ScheduleError.serverError:
        return 'errorServerMessage';
      case ScheduleError.timeoutError:
        return 'errorNetworkMessage';
    }
  }
}
