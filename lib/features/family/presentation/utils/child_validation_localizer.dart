import 'package:edulift/generated/l10n/app_localizations.dart';
import 'child_form_validator.dart';

/// Clean abstraction for mapping child validation errors to localized messages.
/// Eliminates manual switch statements in UI components.
extension ChildValidationLocalizer on ChildValidationError {
  /// Converts validation error directly to localized message.
  ///
  /// This extension method provides a clean way to get localized error
  /// messages without requiring manual switch statements in UI code.
  ///
  /// Usage:
  /// ```dart
  /// final error = ChildFormValidator.validateName(value);
  /// if (error != null) {
  ///   return error.toLocalizedMessage(AppLocalizations.of(context));
  /// }
  /// ```
  String toLocalizedMessage(AppLocalizations l10n) {
    switch (this) {
      case ChildValidationError.nameRequired:
        return l10n.errorChildNameRequired;
      case ChildValidationError.nameMinLength:
        return l10n.errorChildNameMinLength;
      case ChildValidationError.nameMaxLength:
        return l10n.errorChildNameMaxLength;
      case ChildValidationError.nameInvalidChars:
        return l10n.errorChildNameInvalidChars;
      case ChildValidationError.ageRequired:
        return l10n.errorChildAgeRequired;
      case ChildValidationError.ageNotNumber:
        return l10n.errorChildAgeNotNumber;
      case ChildValidationError.ageTooYoung:
        return l10n.errorChildAgeTooYoung(ChildFormValidator.minAge);
      case ChildValidationError.ageTooOld:
        return l10n.errorChildAgeTooOld(ChildFormValidator.maxAge);
      case ChildValidationError.medicalInfoTooLong:
        return l10n.errorChildMedicalInfoTooLong(
          ChildFormValidator.maxMedicalInfoLength,
        );
      case ChildValidationError.specialNeedsTooLong:
        return l10n.errorChildSpecialNeedsTooLong(
          ChildFormValidator.maxSpecialNeedsLength,
        );
      case ChildValidationError.schoolNameTooLong:
        return l10n.errorChildSchoolNameTooLong(
          ChildFormValidator.maxSchoolNameLength,
        );
      case ChildValidationError.gradeInvalid:
        return l10n.errorChildGradeInvalid;
      case ChildValidationError.emergencyContactRequired:
        return l10n.errorChildEmergencyContactRequired;
      case ChildValidationError.emergencyContactInvalid:
        return l10n.errorChildEmergencyContactInvalid;
      case ChildValidationError.fieldRequired:
        return l10n.errorValidation;
    }
  }
}
