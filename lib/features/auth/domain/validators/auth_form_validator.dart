/// Validation errors for auth forms
enum AuthValidationError {
  // Email validations
  emailRequired,
  emailInvalid,
  emailTooLong,

  // Name validations (for magic link signup)
  nameRequired,
  nameMinLength,
  nameMaxLength,
  nameInvalidChars,

  // Magic link validations
  magicLinkTokenInvalid,
  magicLinkTokenRequired,

  // Invite code validations
  inviteCodeInvalid,
  inviteCodeExpired,
}

/// Unified validation logic for auth forms
class AuthFormValidator {
  static const int maxEmailLength = 254; // RFC 5321
  static const int minNameLength = 2;
  static const int maxNameLength = 50;

  /// Validate email address
  static AuthValidationError? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AuthValidationError.emailRequired;
    }

    final trimmed = value.trim();

    if (trimmed.length > maxEmailLength) {
      return AuthValidationError.emailTooLong;
    }

    // RFC 5322 compliant email regex (simplified)
    final emailPattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    if (!emailPattern.hasMatch(trimmed)) {
      return AuthValidationError.emailInvalid;
    }

    return null;
  }

  /// Validate name (for magic link signup)
  static AuthValidationError? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AuthValidationError.nameRequired;
    }

    final trimmed = value.trim();

    if (trimmed.length < minNameLength) {
      return AuthValidationError.nameMinLength;
    }

    if (trimmed.length > maxNameLength) {
      return AuthValidationError.nameMaxLength;
    }

    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    final validPattern = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!validPattern.hasMatch(trimmed)) {
      return AuthValidationError.nameInvalidChars;
    }

    return null;
  }

  /// Validate magic link token
  static AuthValidationError? validateMagicLinkToken(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AuthValidationError.magicLinkTokenRequired;
    }

    // Basic validation - token should be non-empty
    // Backend will perform actual validation
    if (value.trim().length < 10) {
      return AuthValidationError.magicLinkTokenInvalid;
    }

    return null;
  }

  /// Validate invite code (optional)
  static AuthValidationError? validateInviteCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Invite code is optional
    }

    final trimmed = value.trim();

    // Invite codes should be at least 6 characters
    if (trimmed.length < 6) {
      return AuthValidationError.inviteCodeInvalid;
    }

    return null;
  }

  /// Validate magic link form (email + optional name)
  static bool isMagicLinkFormValid({
    required String? email,
    String? name,
    String? inviteCode,
  }) {
    return validateEmail(email) == null &&
        (name == null || validateName(name) == null) &&
        validateInviteCode(inviteCode) == null;
  }

  /// Convert validation error to localization key (for state management)
  static String mapErrorToKey(AuthValidationError error) {
    switch (error) {
      case AuthValidationError.emailRequired:
        return 'errorAuthEmailRequired';
      case AuthValidationError.emailInvalid:
        return 'errorAuthEmailInvalid';
      case AuthValidationError.emailTooLong:
        return 'errorAuthEmailTooLong';
      case AuthValidationError.nameRequired:
        return 'errorAuthNameRequired';
      case AuthValidationError.nameMinLength:
        return 'errorAuthNameMinLength';
      case AuthValidationError.nameMaxLength:
        return 'errorAuthNameMaxLength';
      case AuthValidationError.nameInvalidChars:
        return 'errorAuthNameInvalidChars';
      case AuthValidationError.magicLinkTokenInvalid:
        return 'errorAuthMagicLinkTokenInvalid';
      case AuthValidationError.magicLinkTokenRequired:
        return 'errorAuthMagicLinkTokenRequired';
      case AuthValidationError.inviteCodeInvalid:
        return 'errorAuthInviteCodeInvalid';
      case AuthValidationError.inviteCodeExpired:
        return 'errorAuthInviteCodeExpired';
    }
  }
}