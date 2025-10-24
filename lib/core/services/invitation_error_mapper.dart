// EduLift Mobile - Invitation Error Mapper
// Shared error mapping logic for both family and group invitations
// ARCHITECTURE: Single source of truth for invitation error → localization key mapping

/// Maps invitation validation error codes to localization keys
///
/// This is a pure function that handles the UNIFIED backend error codes
/// used by both family and group invitation validation endpoints.
///
/// Backend returns HTTP 200 for all validations with errorCode in response.
/// This mapper converts those error codes to UI-displayable localization keys.
class InvitationErrorMapper {
  /// Map validation error code to localization key
  ///
  /// Handles standard validation errors:
  /// - EMAIL_MISMATCH: Invitation email doesn't match authenticated user email
  /// - EXPIRED: Invitation has passed its expiration date
  /// - INVALID_CODE: Invitation code doesn't exist, is malformed, or already used
  ///   (backend returns INVALID_CODE for both invalid AND already-used invitations)
  /// - CANCELLED: Invitation was cancelled by sender
  ///
  /// Returns 'errorInvalidData' for unknown error codes
  static String mapValidationErrorToKey(String? errorCode) {
    if (errorCode == null) return 'errorInvalidData';

    switch (errorCode) {
      case 'EMAIL_MISMATCH':
        return 'errorInvitationEmailMismatch';
      case 'EXPIRED':
        return 'errorInvitationExpired';
      case 'INVALID_CODE':
        return 'errorInvitationCodeInvalid';
      case 'CANCELLED':
        return 'errorInvitationCancelled';
      default:
        return 'errorInvalidData';
    }
  }
}
