import 'package:equatable/equatable.dart';

/// Unit type for representing no meaningful return value.
/// Used with Result<Unit, Failure> instead of Result<void, Failure>
/// to work properly with mock generation and sealed classes.
class Unit extends Equatable {
  const Unit();

  @override
  List<Object?> get props => [];

  @override
  String toString() => 'Unit()';
}

abstract class Failure extends Equatable implements Exception {
  final String? message;
  final String? code;
  final int? statusCode;
  final Map<String, dynamic>? details;

  const Failure({this.message, this.code, this.statusCode, this.details});

  @override
  List<Object?> get props => [message, code, statusCode, details];

  @override
  String toString() =>
      '$runtimeType(message: $message, code: $code, statusCode: $statusCode)';
}

class ServerFailure extends Failure {
  const ServerFailure({
    super.message,
    super.code,
    super.statusCode,
    super.details,
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message,
    super.code,
    super.statusCode,
    super.details,
  });
}

class AuthFailure extends Failure {
  const AuthFailure({
    super.message,
    super.code,
    super.statusCode,
    super.details,
  });
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    super.message,
    super.code,
    super.statusCode,
    super.details,
  });
}

class CacheFailure extends Failure {
  const CacheFailure({
    super.message,
    super.code,
    super.statusCode,
    super.details,
  });
}

class BiometricFailure extends Failure {
  const BiometricFailure({
    super.message,
    super.code,
    super.statusCode,
    super.details,
  });
}

class ConflictFailure extends Failure {
  const ConflictFailure({
    super.message,
    super.code,
    super.statusCode,
    super.details,
  });
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message,
    super.code,
    super.statusCode,
    super.details,
  });
}

class OfflineFailure extends Failure {
  const OfflineFailure({
    super.message,
    super.code,
    super.statusCode,
    super.details,
  });
}

class NoConnectionFailure extends Failure {
  const NoConnectionFailure({
    super.message,
    super.code,
    super.statusCode,
    super.details,
  });
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message,
    super.code,
    super.statusCode,
    super.details,
  });
}

class StorageFailure extends Failure {
  final String? operation;

  const StorageFailure(
    String message, {
    this.operation,
    super.code,
    super.statusCode,
    super.details,
  }) : super(message: message);

  @override
  List<Object?> get props => [...super.props, operation];

  @override
  String toString() =>
      'StorageFailure(message: $message, operation: $operation)';
}

class UnexpectedFailure extends Failure {
  final String? operation;

  const UnexpectedFailure(
    String message, {
    this.operation,
    super.code,
    super.statusCode,
    super.details,
  }) : super(message: message);

  @override
  List<Object?> get props => [...super.props, operation];

  @override
  String toString() =>
      'UnexpectedFailure(message: $message, operation: $operation)';
}

class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message,
    super.code,
    super.statusCode,
    super.details,
  });
}

/// Specific failure class for API operations in the Result pattern.
///
/// This provides common factory methods for typical API failure scenarios,
/// replacing the broken ApiResponse.map() pattern with structured errors.
class ApiFailure extends Failure {
  const ApiFailure({
    super.message,
    super.code,
    super.statusCode,
    super.details,
    this.requestUrl,
    this.requestMethod,
  });

  /// The URL that was requested when the failure occurred.
  final String? requestUrl;

  /// The HTTP method used in the failed request.
  final String? requestMethod;

  /// Create an ApiFailure from a network timeout.
  factory ApiFailure.timeout({String? url}) => ApiFailure(
    code: 'api.timeout',
    statusCode: 408,
    requestUrl: url,
    details: const {'type': 'timeout'},
  );

  /// Create an ApiFailure from a network connectivity issue.
  factory ApiFailure.noConnection() => const ApiFailure(
    code: 'api.no_connection',
    statusCode: 0,
    details: {'type': 'no_connection'},
  );

  /// Create an ApiFailure from a bad request response.
  factory ApiFailure.badRequest({String? message, String? code}) => ApiFailure(
    message: message,
    code: code ?? 'api.bad_request',
    statusCode: 400,
    details: const {'type': 'bad_request'},
  );

  /// Create an ApiFailure from an unauthorized response.
  factory ApiFailure.unauthorized() => const ApiFailure(
    code: 'api.unauthorized',
    statusCode: 401,
    details: {'type': 'unauthorized'},
  );

  /// Create an ApiFailure from a not found response.
  factory ApiFailure.notFound({String? resource}) => ApiFailure(
    code: 'api.not_found',
    statusCode: 404,
    details: {'type': 'not_found', 'resource': resource},
  );

  /// Create an ApiFailure from a server error.
  factory ApiFailure.serverError({String? message, String? code}) => ApiFailure(
    message: message,
    code: code ?? 'api.server_error',
    statusCode: 500,
    details: const {'type': 'server_error'},
  );

  /// Create an ApiFailure from JSON parsing errors.
  factory ApiFailure.parseError({String? details}) => ApiFailure(
    code: 'api.parse_error',
    statusCode: 200,
    details: {'type': 'parse_error', 'parse_details': details},
  );

  /// Create an ApiFailure from validation errors.
  factory ApiFailure.validationError({String? message, String? code}) =>
      ApiFailure(
        message: message,
        code: code ?? 'api.validation_error',
        statusCode: 422,
        details: const {'type': 'validation_error'},
      );

  /// Create an ApiFailure from cache errors.
  factory ApiFailure.cacheError({String? message, String? code}) => ApiFailure(
    message: message,
    code: code ?? 'api.cache_error',
    statusCode: 0,
    details: const {'type': 'cache_error'},
  );

  /// Create an ApiFailure from network errors.
  factory ApiFailure.network({String? message, String? code}) => ApiFailure(
    message: message,
    code: code ?? 'api.network_error',
    statusCode: 0,
    details: const {'type': 'network_error'},
  );

  /// Determine if this error is retryable based on the status code and type.
  /// Network errors and 5xx server errors are retryable.
  /// 4xx client errors are generally not retryable.
  bool get isRetryable {
    // Network-related errors are always retryable
    if (statusCode == 0 || statusCode == 408) return true;

    // Server errors (5xx) are retryable
    if (statusCode != null && statusCode! >= 500 && statusCode! < 600) {
      return true;
    }

    // Rate limiting is retryable
    if (statusCode == 429) return true;

    // Client errors (4xx) are generally not retryable
    // This includes 400 Bad Request, 401 Unauthorized, 403 Forbidden, 404 Not Found, etc.
    return false;
  }

  @override
  List<Object?> get props => [...super.props, requestUrl, requestMethod];

  @override
  String toString() =>
      'ApiFailure('
      'message: $message, '
      'statusCode: $statusCode, '
      'requestUrl: $requestUrl, '
      'requestMethod: $requestMethod'
      ')';
}
