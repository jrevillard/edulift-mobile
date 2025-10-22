// EduLift Mobile - Family Domain Invitation Errors
// Clean Architecture domain-specific error definitions for invitations

/// Domain-specific invitation errors following clean architecture principles
/// These errors represent business rule violations in the invitation domain
enum InvitationError {
  // Email validation errors
  emailRequired,
  emailInvalid,
  emailAlreadyExists,
  emailMismatch,

  // Role validation errors
  roleRequired,
  roleInvalid,

  // Invitation validation errors
  invitationIdRequired,
  invitationCodeRequired,
  invitationCodeInvalid,
  invitationExpired,
  invitationNotFound,

  // ID validation errors
  familyIdRequired,
  groupIdRequired,

  // Message validation errors
  messageTooLong,

  // Business logic errors
  pendingInvitationExists,
  memberAlreadyExists,
  memberNotFound,
  insufficientPermissions,

  // System errors
  inviteOperationFailed,
  acceptOperationFailed,
  cancelOperationFailed,
  validateOperationFailed}

/// Extension to provide localization keys for invitation errors
extension InvitationErrorLocalization on InvitationError {
  String get localizationKey {
    switch (this) {
      case InvitationError.emailRequired:
        return 'errorEmailRequired';
      case InvitationError.emailInvalid:
        return 'errorEmailInvalid';
      case InvitationError.emailAlreadyExists:
        return 'errorEmailAlreadyExists';
      case InvitationError.emailMismatch:
        return 'errorInvitationEmailMismatch';
      case InvitationError.roleRequired:
        return 'errorRoleRequired';
      case InvitationError.roleInvalid:
        return 'errorRoleInvalid';
      case InvitationError.invitationIdRequired:
        return 'errorInvitationIdRequired';
      case InvitationError.invitationCodeRequired:
        return 'errorInvitationCodeRequired';
      case InvitationError.invitationCodeInvalid:
        return 'errorInvitationCodeInvalid';
      case InvitationError.invitationExpired:
        return 'errorInvitationExpired';
      case InvitationError.invitationNotFound:
        return 'errorInvitationNotFound';
      case InvitationError.familyIdRequired:
        return 'errorFamilyIdRequired';
      case InvitationError.groupIdRequired:
        return 'errorGroupIdRequired';
      case InvitationError.messageTooLong:
        return 'errorMessageTooLong';
      case InvitationError.pendingInvitationExists:
        return 'errorPendingInvitationExists';
      case InvitationError.memberAlreadyExists:
        return 'errorMemberAlreadyExists';
      case InvitationError.memberNotFound:
        return 'errorMemberNotFound';
      case InvitationError.insufficientPermissions:
        return 'errorInsufficientPermissions';
      case InvitationError.inviteOperationFailed:
        return 'errorInviteOperationFailed';
      case InvitationError.acceptOperationFailed:
        return 'errorAcceptOperationFailed';
      case InvitationError.cancelOperationFailed:
        return 'errorCancelOperationFailed';
      case InvitationError.validateOperationFailed:
        return 'errorValidateOperationFailed';}
  }
}