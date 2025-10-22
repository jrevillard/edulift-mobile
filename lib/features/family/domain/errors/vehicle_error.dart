// EduLift Mobile - Family Domain Vehicle Errors
// Clean Architecture domain-specific error definitions for vehicles

/// Domain-specific vehicle errors following clean architecture principles
/// These errors represent business rule violations in the vehicle domain
enum VehicleError {
  // Vehicle name validation errors
  nameRequired,
  nameInvalid,
  nameTooShort,
  nameTooLong,

  // Vehicle type validation errors
  typeRequired,
  typeInvalid,

  // Vehicle brand validation errors
  brandRequired,
  brandInvalid,
  brandTooLong,

  // Vehicle model validation errors
  modelRequired,
  modelInvalid,
  modelTooLong,

  // Vehicle year validation errors
  yearRequired,
  yearInvalid,
  yearTooOld,
  yearTooNew,

  // Vehicle color validation errors
  colorRequired,
  colorInvalid,

  // Vehicle license plate validation errors
  licensePlateRequired,
  licensePlateInvalid,
  licensePlateAlreadyExists,

  // Vehicle capacity validation errors
  capacityRequired,
  capacityInvalid,
  capacityTooLow,
  capacityTooHigh,

  // Vehicle ID validation errors
  vehicleIdRequired,
  vehicleIdInvalid,

  // Family ID validation errors
  familyIdRequired,

  // Vehicle business logic errors
  vehicleNotFound,
  vehicleAlreadyExists,
  vehicleInUse,
  vehicleNotAvailable,
  insufficientPermissions,

  // Vehicle operations errors
  vehicleCreationFailed,
  vehicleUpdateFailed,
  vehicleDeletionFailed,
  vehicleAssignmentFailed,
  vehicleUnassignmentFailed,

  // System errors
  vehicleOperationFailed,
  loadVehicleFailed,
  saveVehicleFailed,
  validateVehicleFailed}

/// Extension to provide localization keys for vehicle errors
extension VehicleErrorLocalization on VehicleError {
  String get localizationKey {
    switch (this) {
      case VehicleError.nameRequired:
        return 'errorVehicleNameRequired';
      case VehicleError.nameInvalid:
        return 'errorVehicleNameInvalid';
      case VehicleError.nameTooShort:
        return 'errorVehicleNameTooShort';
      case VehicleError.nameTooLong:
        return 'errorVehicleNameTooLong';
      case VehicleError.typeRequired:
        return 'errorVehicleTypeRequired';
      case VehicleError.typeInvalid:
        return 'errorVehicleTypeInvalid';
      case VehicleError.brandRequired:
        return 'errorVehicleBrandRequired';
      case VehicleError.brandInvalid:
        return 'errorVehicleBrandInvalid';
      case VehicleError.brandTooLong:
        return 'errorVehicleBrandTooLong';
      case VehicleError.modelRequired:
        return 'errorVehicleModelRequired';
      case VehicleError.modelInvalid:
        return 'errorVehicleModelInvalid';
      case VehicleError.modelTooLong:
        return 'errorVehicleModelTooLong';
      case VehicleError.yearRequired:
        return 'errorVehicleYearRequired';
      case VehicleError.yearInvalid:
        return 'errorVehicleYearInvalid';
      case VehicleError.yearTooOld:
        return 'errorVehicleYearTooOld';
      case VehicleError.yearTooNew:
        return 'errorVehicleYearTooNew';
      case VehicleError.colorRequired:
        return 'errorVehicleColorRequired';
      case VehicleError.colorInvalid:
        return 'errorVehicleColorInvalid';
      case VehicleError.licensePlateRequired:
        return 'errorVehicleLicensePlateRequired';
      case VehicleError.licensePlateInvalid:
        return 'errorVehicleLicensePlateInvalid';
      case VehicleError.licensePlateAlreadyExists:
        return 'errorVehicleLicensePlateAlreadyExists';
      case VehicleError.capacityRequired:
        return 'errorVehicleCapacityRequired';
      case VehicleError.capacityInvalid:
        return 'errorVehicleCapacityInvalid';
      case VehicleError.capacityTooLow:
        return 'errorVehicleCapacityTooLow';
      case VehicleError.capacityTooHigh:
        return 'errorVehicleCapacityTooHigh';
      case VehicleError.vehicleIdRequired:
        return 'errorVehicleIdRequired';
      case VehicleError.vehicleIdInvalid:
        return 'errorVehicleIdInvalid';
      case VehicleError.familyIdRequired:
        return 'errorFamilyIdRequired';
      case VehicleError.vehicleNotFound:
        return 'errorVehicleNotFound';
      case VehicleError.vehicleAlreadyExists:
        return 'errorVehicleAlreadyExists';
      case VehicleError.vehicleInUse:
        return 'errorVehicleInUse';
      case VehicleError.vehicleNotAvailable:
        return 'errorVehicleNotAvailable';
      case VehicleError.insufficientPermissions:
        return 'errorInsufficientPermissions';
      case VehicleError.vehicleCreationFailed:
        return 'errorVehicleCreationFailed';
      case VehicleError.vehicleUpdateFailed:
        return 'errorVehicleUpdateFailed';
      case VehicleError.vehicleDeletionFailed:
        return 'errorVehicleDeletionFailed';
      case VehicleError.vehicleAssignmentFailed:
        return 'errorVehicleAssignmentFailed';
      case VehicleError.vehicleUnassignmentFailed:
        return 'errorVehicleUnassignmentFailed';
      case VehicleError.vehicleOperationFailed:
        return 'errorVehicleOperationFailed';
      case VehicleError.loadVehicleFailed:
        return 'errorLoadVehicleFailed';
      case VehicleError.saveVehicleFailed:
        return 'errorSaveVehicleFailed';
      case VehicleError.validateVehicleFailed:
        return 'errorValidateVehicleFailed';}
  }
}