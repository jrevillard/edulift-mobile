// EduLift Mobile - Invitation Validation Localizer
// PHASE2 Clean Architecture pattern for enum → localized message transformation

import '../../../../generated/l10n/app_localizations.dart';
import '../../domain/errors/family_invitation_error.dart';

/// Extension for enum → localized message transformation
/// Following CLEAN_ERROR_HANDLING_ARCHITECTURE.md pattern - DETERMINISTIC (no default case)
extension InvitationValidationLocalizer on InvitationError {
  String toLocalizedMessage(AppLocalizations l10n) {
    switch (this) {
      // Email validation errors
      case InvitationError.emailRequired:
        return l10n.errorEmailRequired;
      case InvitationError.emailInvalid:
        return l10n.errorEmailInvalid;
      case InvitationError.emailAlreadyExists:
        return l10n.errorEmailAlreadyExists;
      case InvitationError.emailMismatch:
        return l10n.errorInvitationEmailMismatch;

      // Role validation errors
      case InvitationError.roleRequired:
        return l10n.errorRoleRequired;
      case InvitationError.roleInvalid:
        return l10n.errorRoleInvalid;

      // Invitation validation errors
      case InvitationError.invitationIdRequired:
        return l10n.errorInvitationCodeRequired; // Reuse existing key
      case InvitationError.invitationCodeRequired:
        return l10n.errorInvitationCodeRequired;
      case InvitationError.invitationCodeInvalid:
        return l10n.errorInvitationCodeRequired; // Reuse for now
      case InvitationError.invitationExpired:
        return l10n.errorInvitationCodeRequired; // Reuse for now
      case InvitationError.invitationNotFound:
        return l10n.errorInvitationCodeRequired; // Reuse for now

      // ID validation errors
      case InvitationError.familyIdRequired:
        return l10n.errorFamilyNameRequired; // Reuse existing key
      case InvitationError.groupIdRequired:
        return l10n.errorFamilyNameRequired; // Reuse existing key

      // Message validation errors
      case InvitationError.messageTooLong:
        return l10n.errorFamilyNameMaxLength; // Reuse existing key

      // Business logic errors - THESE ARE THE IMPORTANT ONES
      case InvitationError.pendingInvitationExists:
        return l10n.errorPendingInvitationExists;
      case InvitationError.memberAlreadyExists:
        return l10n.errorMemberAlreadyExists;
      case InvitationError.memberNotFound:
        return l10n.errorMemberNotFound;
      case InvitationError.insufficientPermissions:
        return l10n.errorInsufficientPermissions;

      // System errors
      case InvitationError.inviteOperationFailed:
        return l10n.errorEmailRequired; // Reuse for now
      case InvitationError.acceptOperationFailed:
        return l10n.errorEmailRequired; // Reuse for now
      case InvitationError.cancelOperationFailed:
        return l10n.errorEmailRequired; // Reuse for now
      case InvitationError.validateOperationFailed:
        return l10n.errorEmailRequired; // Reuse for now
    }
  }
}