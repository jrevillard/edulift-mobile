/// Validation errors for child forms
enum ChildValidationError {
  // Name validation
  nameRequired,
  nameMinLength,
  nameMaxLength,
  nameInvalidChars,

  // Age validation
  ageRequired,
  ageNotNumber,
  ageTooYoung,
  ageTooOld,

  // Medical information
  medicalInfoTooLong,

  // Special needs
  specialNeedsTooLong,

  // School information
  schoolNameTooLong,
  gradeInvalid,

  // Contact information
  emergencyContactRequired,
  emergencyContactInvalid,

  // General validation
  fieldRequired,
}

/// Unified validation logic for child forms
class ChildFormValidator {
  static const int minNameLength = 2;
  static const int maxNameLength = 30;
  static const int minAge = 1;
  static const int maxAge = 25;
  static const int maxMedicalInfoLength = 500;
  static const int maxSpecialNeedsLength = 500;
  static const int maxSchoolNameLength = 100;

  /// Validate child name
  static ChildValidationError? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ChildValidationError.nameRequired;
    }

    final trimmed = value.trim();
    if (trimmed.length < minNameLength) {
      return ChildValidationError.nameMinLength;
    }

    if (trimmed.length > maxNameLength) {
      return ChildValidationError.nameMaxLength;
    }

    // Check for valid characters (letters, spaces, basic punctuation for names)
    final validPattern = RegExp(r'^[a-zA-Z\s\-.]+$');
    if (!validPattern.hasMatch(trimmed)) {
      return ChildValidationError.nameInvalidChars;
    }

    return null;
  }

  /// Validate child age (optional but if provided must be valid)
  static ChildValidationError? validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Age is optional
    }

    final age = int.tryParse(value.trim());
    if (age == null) {
      return ChildValidationError.ageNotNumber;
    }

    if (age < minAge) {
      return ChildValidationError.ageTooYoung;
    }

    if (age > maxAge) {
      return ChildValidationError.ageTooOld;
    }

    return null;
  }

  /// Validate medical information (optional)
  static ChildValidationError? validateMedicalInfo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Medical info is optional
    }

    final trimmed = value.trim();
    if (trimmed.length > maxMedicalInfoLength) {
      return ChildValidationError.medicalInfoTooLong;
    }

    return null;
  }

  /// Validate special needs information (optional)
  static ChildValidationError? validateSpecialNeeds(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Special needs is optional
    }

    final trimmed = value.trim();
    if (trimmed.length > maxSpecialNeedsLength) {
      return ChildValidationError.specialNeedsTooLong;
    }

    return null;
  }

  /// Validate school name (optional)
  static ChildValidationError? validateSchoolName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // School name is optional
    }

    final trimmed = value.trim();
    if (trimmed.length > maxSchoolNameLength) {
      return ChildValidationError.schoolNameTooLong;
    }

    return null;
  }

  /// Validate grade (optional)
  static ChildValidationError? validateGrade(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Grade is optional
    }

    // Valid grades: K, 1-12, or custom text
    final trimmed = value.trim();
    final gradePattern = RegExp(r'^(K|[1-9]|1[0-2]|[a-zA-Z\s\-]+)$');
    if (!gradePattern.hasMatch(trimmed)) {
      return ChildValidationError.gradeInvalid;
    }

    return null;
  }

  /// Validate emergency contact (optional)
  static ChildValidationError? validateEmergencyContact(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Emergency contact is optional
    }

    final trimmed = value.trim();
    // Basic phone number or email validation
    final phonePattern = RegExp(r'^\+?[\d\s\-\(\)]+$');
    final emailPattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!phonePattern.hasMatch(trimmed) && !emailPattern.hasMatch(trimmed)) {
      return ChildValidationError.emergencyContactInvalid;
    }

    return null;
  }

  /// Validate the entire child form
  static bool isFormValid({
    required String? name,
    String? age,
    String? medicalInfo,
    String? specialNeeds,
    String? schoolName,
    String? grade,
    String? emergencyContact,
  }) {
    return validateName(name) == null &&
        validateAge(age) == null &&
        validateMedicalInfo(medicalInfo) == null &&
        validateSpecialNeeds(specialNeeds) == null &&
        validateSchoolName(schoolName) == null &&
        validateGrade(grade) == null &&
        validateEmergencyContact(emergencyContact) == null;
  }

  /// Convert validation error to localization key
  static String mapErrorToKey(ChildValidationError error) {
    switch (error) {
      case ChildValidationError.nameRequired:
        return 'errorChildNameRequired';
      case ChildValidationError.nameMinLength:
        return 'errorChildNameMinLength';
      case ChildValidationError.nameMaxLength:
        return 'errorChildNameMaxLength';
      case ChildValidationError.nameInvalidChars:
        return 'errorChildNameInvalidChars';
      case ChildValidationError.ageRequired:
        return 'errorChildAgeRequired';
      case ChildValidationError.ageNotNumber:
        return 'errorChildAgeNotNumber';
      case ChildValidationError.ageTooYoung:
        return 'errorChildAgeTooYoung';
      case ChildValidationError.ageTooOld:
        return 'errorChildAgeTooOld';
      case ChildValidationError.medicalInfoTooLong:
        return 'errorChildMedicalInfoTooLong';
      case ChildValidationError.specialNeedsTooLong:
        return 'errorChildSpecialNeedsTooLong';
      case ChildValidationError.schoolNameTooLong:
        return 'errorChildSchoolNameTooLong';
      case ChildValidationError.gradeInvalid:
        return 'errorChildGradeInvalid';
      case ChildValidationError.emergencyContactRequired:
        return 'errorChildEmergencyContactRequired';
      case ChildValidationError.emergencyContactInvalid:
        return 'errorChildEmergencyContactInvalid';
      case ChildValidationError.fieldRequired:
        return 'errorFieldRequired';
    }
  }
}
