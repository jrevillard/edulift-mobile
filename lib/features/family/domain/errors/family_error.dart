// EduLift Mobile - Family Domain Family Errors
// Clean Architecture domain-specific error definitions for families

/// Domain-specific family errors following clean architecture principles
/// These errors represent business rule violations in the family domain
enum FamilyError {
  // Family name validation errors
  nameRequired,
  nameInvalid,
  nameTooShort,
  nameTooLong,
  nameAlreadyExists,

  // Family description validation errors
  descriptionTooLong,

  // Family member validation errors
  memberIdRequired,
  memberNotFound,
  memberAlreadyExists,
  insufficientPermissions,

  // Family ID validation errors
  familyIdRequired,
  familyIdInvalid,

  // Family creation/update errors
  familyNotFound,
  familyAlreadyExists,
  familyCreationFailed,
  familyUpdateFailed,
  familyDeletionFailed,

  // Family membership errors
  joinFamilyFailed,
  leaveFamilyFailed,
  removeMemberFailed,
  updateMemberFailed,

  // Family permissions errors
  permissionRequired,
  permissionInvalid,
  permissionDenied,
  roleRequired,
  roleInvalid,

  // Business logic errors
  cannotLeaveAsOwner,
  cannotRemoveOwner,
  maxMembersReached,
  familyNotActive,

  // System errors
  familyOperationFailed,
  loadFamilyFailed,
  saveFamilyFailed,
  validateFamilyFailed}

/// Extension to provide localization keys for family errors
extension FamilyErrorLocalization on FamilyError {
  String get localizationKey {
    switch (this) {
      case FamilyError.nameRequired:
        return 'errorFamilyNameRequired';
      case FamilyError.nameInvalid:
        return 'errorFamilyNameInvalid';
      case FamilyError.nameTooShort:
        return 'errorFamilyNameTooShort';
      case FamilyError.nameTooLong:
        return 'errorFamilyNameTooLong';
      case FamilyError.nameAlreadyExists:
        return 'errorFamilyNameAlreadyExists';
      case FamilyError.descriptionTooLong:
        return 'errorFamilyDescriptionTooLong';
      case FamilyError.memberIdRequired:
        return 'errorMemberIdRequired';
      case FamilyError.memberNotFound:
        return 'errorMemberNotFound';
      case FamilyError.memberAlreadyExists:
        return 'errorMemberAlreadyExists';
      case FamilyError.insufficientPermissions:
        return 'errorInsufficientPermissions';
      case FamilyError.familyIdRequired:
        return 'errorFamilyIdRequired';
      case FamilyError.familyIdInvalid:
        return 'errorFamilyIdInvalid';
      case FamilyError.familyNotFound:
        return 'errorFamilyNotFound';
      case FamilyError.familyAlreadyExists:
        return 'errorFamilyAlreadyExists';
      case FamilyError.familyCreationFailed:
        return 'errorFamilyCreationFailed';
      case FamilyError.familyUpdateFailed:
        return 'errorFamilyUpdateFailed';
      case FamilyError.familyDeletionFailed:
        return 'errorFamilyDeletionFailed';
      case FamilyError.joinFamilyFailed:
        return 'errorJoinFamilyFailed';
      case FamilyError.leaveFamilyFailed:
        return 'errorLeaveFamilyFailed';
      case FamilyError.removeMemberFailed:
        return 'errorRemoveMemberFailed';
      case FamilyError.updateMemberFailed:
        return 'errorUpdateMemberFailed';
      case FamilyError.permissionRequired:
        return 'errorPermissionRequired';
      case FamilyError.permissionInvalid:
        return 'errorPermissionInvalid';
      case FamilyError.permissionDenied:
        return 'errorPermissionDenied';
      case FamilyError.roleRequired:
        return 'errorRoleRequired';
      case FamilyError.roleInvalid:
        return 'errorRoleInvalid';
      case FamilyError.cannotLeaveAsOwner:
        return 'errorCannotLeaveAsOwner';
      case FamilyError.cannotRemoveOwner:
        return 'errorCannotRemoveOwner';
      case FamilyError.maxMembersReached:
        return 'errorMaxMembersReached';
      case FamilyError.familyNotActive:
        return 'errorFamilyNotActive';
      case FamilyError.familyOperationFailed:
        return 'errorFamilyOperationFailed';
      case FamilyError.loadFamilyFailed:
        return 'errorLoadFamilyFailed';
      case FamilyError.saveFamilyFailed:
        return 'errorSaveFamilyFailed';
      case FamilyError.validateFamilyFailed:
        return 'errorValidateFamilyFailed';}
  }
}