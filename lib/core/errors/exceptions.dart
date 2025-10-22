/// Core exceptions for EduLift Mobile Application
/// Following Clean Architecture patterns with proper error handling

abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => 'AppException: $message';
}

/// Exception thrown when server communication fails
class ServerException extends AppException {
  final int? statusCode;
  final String? errorCode;

  const ServerException(String message, {this.statusCode, this.errorCode})
    : super(message);

  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// Exception thrown when local cache operations fail
class CacheException extends AppException {
  final String? operation;

  const CacheException(String message, {this.operation}) : super(message);

  @override
  String toString() =>
      'CacheException: $message${operation != null ? ' (Operation: $operation)' : ''}';
}

/// Exception thrown when network connectivity issues occur
class NetworkException extends AppException {
  const NetworkException(String message) : super(message);

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown when authentication fails
class AuthenticationException extends AppException {
  final String? authCode;

  const AuthenticationException(String message, {this.authCode})
    : super(message);

  @override
  String toString() => 'AuthenticationException: $message';
}

/// Exception thrown when authorization fails
class AuthorizationException extends AppException {
  final String? requiredPermission;

  const AuthorizationException(String message, {this.requiredPermission})
    : super(message);

  @override
  String toString() => 'AuthorizationException: $message';
}

/// Exception thrown when validation fails
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException(String message, {this.fieldErrors})
    : super(message);

  @override
  String toString() => 'ValidationException: $message';
}

/// Exception thrown during synchronization operations
class SyncException extends AppException {
  final String? operation;
  final int? conflictCount;

  const SyncException(String message, {this.operation, this.conflictCount})
    : super(message);

  @override
  String toString() => 'SyncException: $message';
}

/// Exception thrown when storage operations fail
class StorageException extends AppException {
  final String? operation;

  const StorageException(String message, {this.operation}) : super(message);

  @override
  String toString() =>
      'StorageException: $message${operation != null ? ' (Operation: $operation)' : ''}';
}

/// Exception thrown when encryption/decryption operations fail
class CryptographyException extends AppException {
  final String? operation;
  final String? algorithm;

  const CryptographyException(String message, {this.operation, this.algorithm})
    : super(message);

  @override
  String toString() =>
      'CryptographyException: $message${operation != null ? ' (Operation: $operation)' : ''}${algorithm != null ? ' (Algorithm: $algorithm)' : ''}';
}

/// Exception thrown when user is not part of any family (valid state, not an error)
class NoFamilyException extends AppException {
  const NoFamilyException(String message) : super(message);

  @override
  String toString() => 'NoFamilyException: $message';
}

/// Exception thrown when a family invitation operation fails
class InvitationException extends AppException {
  final String? invitationCode;
  final String? errorCode;

  const InvitationException(
    String message, {
    this.invitationCode,
    this.errorCode,
  }) : super(message);

  @override
  String toString() =>
      'InvitationException: $message${errorCode != null ? ' (Code: $errorCode)' : ''}';
}

/// Exception thrown when user is already a member
class UserAlreadyMemberException extends InvitationException {
  const UserAlreadyMemberException(String message, {String? invitationCode})
    : super(
        message,
        invitationCode: invitationCode,
        errorCode: 'USER_ALREADY_MEMBER',
      );
}

/// Exception thrown when invitation is expired
class InvitationExpiredException extends InvitationException {
  const InvitationExpiredException(String message, {String? invitationCode})
    : super(
        message,
        invitationCode: invitationCode,
        errorCode: 'INVITATION_EXPIRED',
      );
}

/// Exception thrown when invitation is invalid
class InvalidInvitationException extends InvitationException {
  const InvalidInvitationException(String message, {String? invitationCode})
    : super(
        message,
        invitationCode: invitationCode,
        errorCode: 'INVALID_INVITATION',
      );
}

/// Alias for AuthenticationException (for backward compatibility)
typedef AuthException = AuthenticationException;
