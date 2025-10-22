// EduLift Mobile - Family Domain Invitation Failures
// Clean Architecture domain-specific failure definitions for invitations

import '../../../core/errors/failures.dart';
import '../../../features/family/domain/errors/family_invitation_error.dart';

/// Domain-specific invitation failure
/// Represents business logic violations in the invitation domain
class InvitationFailure extends Failure {
  final InvitationError error;

  const InvitationFailure({
    required this.error,
    String? message,
    Map<String, dynamic>? details,
  }) : super(
          message: message,
          code: 'invitation_error',
          details: details,
        );

  String get localizationKey => error.localizationKey;

  @override
  List<Object?> get props => [error, message, code, details];

  @override
  String toString() => 'InvitationFailure(error: $error, message: $message)';
}