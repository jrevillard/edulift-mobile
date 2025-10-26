// EduLift Mobile - Auth Domain Failures
// Clean Architecture domain-specific failure definitions for authentication

import '../../../../core/errors/failures.dart';
import '../errors/auth_error.dart';

/// Domain-specific auth failure
/// Represents business logic violations in the auth domain
class AuthFailure extends Failure {
  final AuthError error;

  const AuthFailure({
    required this.error,
    String? message,
    Map<String, dynamic>? details,
  }) : super(message: message, code: 'auth_error', details: details);

  String get localizationKey => error.localizationKey;

  @override
  List<Object?> get props => [error, message, code, details];

  @override
  String toString() => 'AuthFailure(error: $error, message: $message)';
}
