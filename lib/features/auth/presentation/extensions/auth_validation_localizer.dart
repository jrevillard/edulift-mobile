import '../../../../generated/l10n/app_localizations.dart';
import '../../domain/validators/auth_form_validator.dart';

/// Extension for direct localization of auth validation errors in UI
/// This is Layer 2 of the two-layer validation pattern
extension AuthValidationLocalizer on AuthValidationError {
  String toLocalizedMessage(AppLocalizations l10n) {
    switch (this) {
      case AuthValidationError.emailRequired:
        return l10n.errorAuthEmailRequired;
      case AuthValidationError.emailInvalid:
        return l10n.errorAuthEmailInvalid;
      case AuthValidationError.emailTooLong:
        return l10n.errorAuthEmailTooLong;
      case AuthValidationError.nameRequired:
        return l10n.errorAuthNameRequired;
      case AuthValidationError.nameMinLength:
        return l10n.errorAuthNameMinLength;
      case AuthValidationError.nameMaxLength:
        return l10n.errorAuthNameMaxLength;
      case AuthValidationError.nameInvalidChars:
        return l10n.errorAuthNameInvalidChars;
      case AuthValidationError.magicLinkTokenInvalid:
        return l10n.errorAuthMagicLinkTokenInvalid;
      case AuthValidationError.magicLinkTokenRequired:
        return l10n.errorAuthMagicLinkTokenRequired;
      case AuthValidationError.inviteCodeInvalid:
        return l10n.errorAuthInviteCodeInvalid;
      case AuthValidationError.inviteCodeExpired:
        return l10n.errorAuthInviteCodeExpired;
    }
  }
}