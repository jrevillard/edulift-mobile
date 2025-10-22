/// Validation errors for family forms
enum FamilyValidationError {
  // Family name validation
  nameRequired,
  nameMinLength,
  nameMaxLength,
  nameInvalidChars,
  // Email validation
  emailRequired,
  emailInvalid,
  emailAlreadyExists,
  // Role validation
  roleRequired,
  roleInvalid,
  // Invitation validation
  invitationCodeRequired,
  invitationCodeInvalid,
  invitationExpired,
  // Message validation
  messageTooLong,
  // Member validation
  memberAlreadyExists,
  memberNotFound,
  insufficientPermissions,
}

/// Unified validation logic for family forms
class FamilyFormValidator {
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int maxMessageLength = 500;

  /// Validate family name
  static FamilyValidationError? validateFamilyName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return FamilyValidationError.nameRequired;
    }

    final trimmed = value.trim();
    if (trimmed.length < minNameLength) {
      return FamilyValidationError.nameMinLength;
    }

    if (trimmed.length > maxNameLength) {
      return FamilyValidationError.nameMaxLength;
    }

    // Check for valid characters (letters, numbers, spaces, basic punctuation)
    final validPattern = RegExp(r'^[a-zA-Z0-9\s\-_.]+$');
    if (!validPattern.hasMatch(trimmed)) {
      return FamilyValidationError.nameInvalidChars;
    }

    return null;
  }


  /// Validate email address
  static FamilyValidationError? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return FamilyValidationError.emailRequired;
    }

    final trimmed = value.trim();
    final emailPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailPattern.hasMatch(trimmed)) {
      return FamilyValidationError.emailInvalid;
    }

    return null;
  }

  /// Validate role selection
  static FamilyValidationError? validateRole(String? value) {
    if (value == null || value.trim().isEmpty) {
      return FamilyValidationError.roleRequired;
    }

    // Valid roles for family members
    const validRoles = ['parent', 'guardian', 'relative', 'driver'];
    if (!validRoles.contains(value.trim().toLowerCase())) {
      return FamilyValidationError.roleInvalid;
    }

    return null;
  }

  /// Validate invitation code
  static FamilyValidationError? validateInvitationCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return FamilyValidationError.invitationCodeRequired;
    }

    final trimmed = value.trim();
    if (trimmed.length < 6) {
      return FamilyValidationError.invitationCodeInvalid;
    }

    return null;
  }

  /// Validate personal message (optional)
  static FamilyValidationError? validatePersonalMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Message is optional
    }

    final trimmed = value.trim();
    if (trimmed.length > maxMessageLength) {
      return FamilyValidationError.messageTooLong;
    }

    return null;
  }

  /// Validate entire family creation form
  static bool isFamilyFormValid({
    required String? name,
  }) {
    return validateFamilyName(name) == null;
  }


  /// Validate entire invitation form
  static bool isInvitationFormValid({
    required String? email,
    String? role,
    String? personalMessage,
  }) {
    return validateEmail(email) == null &&
        (role == null || validateRole(role) == null) &&
        validatePersonalMessage(personalMessage) == null;
  }

  /// Convert validation error to localization key
  static String mapErrorToKey(FamilyValidationError error) {
    switch (error) {
      case FamilyValidationError.nameRequired:
        return 'errorFamilyNameRequired';
      case FamilyValidationError.nameMinLength:
        return 'errorFamilyNameMinLength';
      case FamilyValidationError.nameMaxLength:
        return 'errorFamilyNameMaxLength';
      case FamilyValidationError.nameInvalidChars:
        return 'errorFamilyNameInvalidChars';
      case FamilyValidationError.emailRequired:
        return 'errorEmailRequired';
      case FamilyValidationError.emailInvalid:
        return 'errorEmailInvalid';
      case FamilyValidationError.emailAlreadyExists:
        return 'errorEmailAlreadyExists';
      case FamilyValidationError.roleRequired:
        return 'errorRoleRequired';
      case FamilyValidationError.roleInvalid:
        return 'errorRoleInvalid';
      case FamilyValidationError.invitationCodeRequired:
        return 'errorInvitationCodeRequired';
      case FamilyValidationError.invitationCodeInvalid:
        return 'errorInvitationCodeInvalid';
      case FamilyValidationError.invitationExpired:
        return 'errorInvitationExpired';
      case FamilyValidationError.messageTooLong:
        return 'errorMessageTooLong';
      case FamilyValidationError.memberAlreadyExists:
        return 'errorMemberAlreadyExists';
      case FamilyValidationError.memberNotFound:
        return 'errorMemberNotFound';
      case FamilyValidationError.insufficientPermissions:
        return 'errorInsufficientPermissions';
    }
  }
}