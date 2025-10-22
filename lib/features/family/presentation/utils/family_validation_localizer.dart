import 'package:edulift/generated/l10n/app_localizations.dart';
import '../../domain/validators/family_form_validator.dart';

/// Clean abstraction for mapping family validation errors to localized messages.
/// Eliminates manual switch statements in UI components.
extension FamilyValidationLocalizer on FamilyValidationError {
  /// Converts validation error directly to localized message.
  ///
  /// This extension method provides a clean way to get localized error
  /// messages without requiring manual switch statements in UI code.
  ///
  /// Usage:
  /// ```dart
  /// final error = FamilyFormValidator.validateFamilyName(value);
  /// if (error != null) {
  ///   return error.toLocalizedMessage(AppLocalizations.of(context));
  /// }
  /// ```
  String toLocalizedMessage(AppLocalizations l10n) {
    switch (this) {
      case FamilyValidationError.nameRequired:
        return l10n.errorFamilyNameRequired;
      case FamilyValidationError.nameMinLength:
        return l10n.errorFamilyNameMinLength;
      case FamilyValidationError.nameMaxLength:
        return l10n.errorFamilyNameMaxLength;
      case FamilyValidationError.nameInvalidChars:
        return l10n.errorFamilyNameInvalidChars;
      case FamilyValidationError.emailRequired:
        return l10n.errorEmailRequired;
      case FamilyValidationError.emailInvalid:
        return l10n.errorEmailInvalid;
      case FamilyValidationError.emailAlreadyExists:
        return l10n.errorEmailAlreadyExists;
      case FamilyValidationError.roleRequired:
        return l10n.errorRoleRequired;
      case FamilyValidationError.roleInvalid:
        return l10n.errorRoleInvalid;
      case FamilyValidationError.invitationCodeRequired:
        return l10n.errorInvitationCodeRequired;
      case FamilyValidationError.invitationCodeInvalid:
        return l10n.errorInvitationCodeInvalid;
      case FamilyValidationError.invitationExpired:
        return l10n.errorInvitationExpired;
      case FamilyValidationError.messageTooLong:
        return l10n.errorMessageTooLong(500);
      case FamilyValidationError.memberAlreadyExists:
        return l10n.errorMemberAlreadyExists;
      case FamilyValidationError.memberNotFound:
        return l10n.errorMemberNotFound;
      case FamilyValidationError.insufficientPermissions:
        return l10n.errorInsufficientPermissions;
    }
  }
}