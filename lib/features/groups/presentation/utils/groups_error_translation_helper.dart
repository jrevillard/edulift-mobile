// EduLift Mobile - Groups Error Translation Helper
// Centralizes error key translation for Groups feature

import '../../../../generated/l10n/app_localizations.dart';

/// Translates error keys to localized messages for Groups feature
/// Follows the same pattern as Family feature for consistency
class GroupsErrorTranslationHelper {
  /// Translate an error key to a localized error message
  /// Returns the translated message or the error key itself if no translation exists
  static String translateError(AppLocalizations l10n, String errorKey) {
    switch (errorKey) {
      case 'errorInvalidInvitationCode':
        return l10n.invalidInvitationCode;
      case 'errorFamilyAlreadyInvited':
        return l10n.familyAlreadyInvited;
      case 'errorFamilyAlreadyMember':
        return l10n.familyAlreadyMember;
      case 'errorInvalidData':
        return l10n.errorInvalidData;
      case 'errorServerGeneral':
        return l10n.errorServerGeneral;
      case 'errorNetworkGeneral':
        return l10n.errorNetworkGeneral;
      case 'errorUnexpected':
        return l10n.errorUnexpected;
      case 'errorUnauthorized':
      case 'errorAccessDenied':
        return l10n.errorAuthAccessDenied;
      case 'errorGroupNotFound':
      case 'errorInvitationNotFound':
        return l10n.familyNotFound;
      case 'errorInsufficientPermissions':
        return l10n.errorAuthAccessDenied;
      default:
        return errorKey;
    }
  }
}
