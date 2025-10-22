// EduLift Mobile - Family Domain Family Failures
// Clean Architecture domain-specific failure definitions for families

import '../../../../core/errors/failures.dart';
import '../errors/family_error.dart';

/// Domain-specific family failure
/// Represents business logic violations in the family domain
class FamilyFailure extends Failure {
  final FamilyError error;

  const FamilyFailure({
    required this.error,
    String? message,
    Map<String, dynamic>? details,
  }) : super(
          message: message,
          code: 'family_error',
          details: details,
        );

  String get localizationKey => error.localizationKey;

  @override
  List<Object?> get props => [error, message, code, details];

  @override
  String toString() => 'FamilyFailure(error: $error, message: $message)';
}