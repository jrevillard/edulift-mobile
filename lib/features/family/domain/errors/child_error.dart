/// Domain-level errors for child operations
enum ChildError {
  // Validation errors
  nameRequired,
  nameInvalid,
  ageInvalid,
  medicalInfoInvalid,
  specialNeedsInvalid,
  schoolInfoInvalid,
  emergencyContactInvalid,

  // Business logic errors
  childNotFound,
  childAlreadyExists,
  duplicateChildName,
  tooManyChildren,
  childHasActiveSchedules,
  childHasActiveAssignments,

  // Permission errors
  insufficientPermissions,
  cannotModifyChild,
  cannotDeleteChild,

  // System errors
  networkError,
  serverError,
  databaseError,
  unexpectedError}

/// Extension to map ChildError to localization keys
extension ChildErrorMapper on ChildError {
  String toLocalizationKey() {
    switch (this) {
      case ChildError.nameRequired:
        return 'errorChildNameRequired';
      case ChildError.nameInvalid:
        return 'errorChildNameInvalid';
      case ChildError.ageInvalid:
        return 'errorChildAgeInvalid';
      case ChildError.medicalInfoInvalid:
        return 'errorChildMedicalInfoInvalid';
      case ChildError.specialNeedsInvalid:
        return 'errorChildSpecialNeedsInvalid';
      case ChildError.schoolInfoInvalid:
        return 'errorChildSchoolInfoInvalid';
      case ChildError.emergencyContactInvalid:
        return 'errorChildEmergencyContactInvalid';
      case ChildError.childNotFound:
        return 'errorChildNotFound';
      case ChildError.childAlreadyExists:
        return 'errorChildAlreadyExists';
      case ChildError.duplicateChildName:
        return 'errorChildDuplicateName';
      case ChildError.tooManyChildren:
        return 'errorTooManyChildren';
      case ChildError.childHasActiveSchedules:
        return 'errorChildHasActiveSchedules';
      case ChildError.childHasActiveAssignments:
        return 'errorChildHasActiveAssignments';
      case ChildError.insufficientPermissions:
        return 'errorInsufficientPermissions';
      case ChildError.cannotModifyChild:
        return 'errorCannotModifyChild';
      case ChildError.cannotDeleteChild:
        return 'errorCannotDeleteChild';
      case ChildError.networkError:
        return 'errorNetworkGeneral';
      case ChildError.serverError:
        return 'errorServerGeneral';
      case ChildError.databaseError:
        return 'errorDatabaseGeneral';
      case ChildError.unexpectedError:
        return 'errorUnexpectedMessage';}
  }
}