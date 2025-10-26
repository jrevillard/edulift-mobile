import 'package:equatable/equatable.dart';

/// Base failure class for the domain layer
/// All domain operations should return Either<Failure, T> instead of throwing exceptions
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

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure({
    super.message,
    super.code,
    super.statusCode,
    super.details,
  });
}

/// Network connectivity failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message,
    super.code,
    super.statusCode,
    super.details,
  });
}

/// Authentication and authorization failures
class AuthFailure extends Failure {
  const AuthFailure({
    super.message,
    super.code,
    super.statusCode,
    super.details,
  });
}

/// Input validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({
    super.message,
    super.code,
    super.statusCode,
    super.details,
  });
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure({
    super.message,
    super.code,
    super.statusCode,
    super.details,
  });
}

/// Resource not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message,
    super.code,
    super.statusCode,
    super.details,
  });
}

/// Resource conflict failures
class ConflictFailure extends Failure {
  const ConflictFailure({
    super.message,
    super.code,
    super.statusCode,
    super.details,
  });
}

/// Permission-related failures
class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message,
    super.code,
    super.statusCode,
    super.details,
  });
}

/// Storage/persistence failures
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

/// Unknown/unexpected failures
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message,
    super.code,
    super.statusCode,
    super.details,
  });
}

/// Unit type for representing no meaningful return value.
/// Used with Result<Unit, Failure> instead of Result<void, Failure>
class Unit extends Equatable {
  const Unit();

  @override
  List<Object?> get props => [];

  @override
  String toString() => 'Unit()';
}
