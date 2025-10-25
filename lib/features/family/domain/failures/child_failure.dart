import '../errors/child_error.dart';

/// Domain failure class for child operations
/// Follows clean architecture principles by encapsulating domain errors
class ChildFailure {
  final ChildError error;
  final String message;
  final Map<String, dynamic>? details;

  const ChildFailure({
    required this.error,
    required this.message,
    this.details,
  });

  /// Create a failure from a validation error
  factory ChildFailure.validation({
    required ChildError error,
    String? message,
    Map<String, dynamic>? details,
  }) {
    return ChildFailure(
      error: error,
      message: message ?? 'Validation failed',
      details: details,
    );
  }

  /// Create a failure from a business logic error
  factory ChildFailure.business({
    required ChildError error,
    String? message,
    Map<String, dynamic>? details,
  }) {
    return ChildFailure(
      error: error,
      message: message ?? 'Business logic error',
      details: details,
    );
  }

  /// Create a failure from a permission error
  factory ChildFailure.permission({
    required ChildError error,
    String? message,
    Map<String, dynamic>? details,
  }) {
    return ChildFailure(
      error: error,
      message: message ?? 'Permission denied',
      details: details,
    );
  }

  /// Create a failure from a system error
  factory ChildFailure.system({
    required ChildError error,
    String? message,
    Map<String, dynamic>? details,
  }) {
    return ChildFailure(
      error: error,
      message: message ?? 'System error',
      details: details,
    );
  }

  /// Get the localization key for this failure
  String get localizationKey => error.toLocalizationKey();

  /// Check if this is a validation failure
  bool get isValidationFailure => [
        ChildError.nameRequired,
        ChildError.nameInvalid,
        ChildError.ageInvalid,
        ChildError.medicalInfoInvalid,
        ChildError.specialNeedsInvalid,
        ChildError.schoolInfoInvalid,
        ChildError.emergencyContactInvalid,
      ].contains(error);

  /// Check if this is a business logic failure
  bool get isBusinessFailure => [
        ChildError.childNotFound,
        ChildError.childAlreadyExists,
        ChildError.duplicateChildName,
        ChildError.tooManyChildren,
        ChildError.childHasActiveSchedules,
        ChildError.childHasActiveAssignments,
      ].contains(error);

  /// Check if this is a permission failure
  bool get isPermissionFailure => [
        ChildError.insufficientPermissions,
        ChildError.cannotModifyChild,
        ChildError.cannotDeleteChild,
      ].contains(error);

  /// Check if this is a system failure
  bool get isSystemFailure => [
        ChildError.networkError,
        ChildError.serverError,
        ChildError.databaseError,
        ChildError.unexpectedError,
      ].contains(error);

  @override
  String toString() {
    return 'ChildFailure(error: $error, message: $message, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChildFailure &&
        other.error == error &&
        other.message == message;
  }

  @override
  int get hashCode => error.hashCode ^ message.hashCode;
}
