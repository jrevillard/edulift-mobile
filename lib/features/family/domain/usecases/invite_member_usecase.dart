import 'package:edulift/features/family/index.dart';

import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/domain/usecases/usecase.dart';

/// Parameters for inviting a family member
class InviteMemberParams {
  final String familyId;
  final String email;
  final FamilyRole role;
  final String? personalMessage;

  const InviteMemberParams({
    required this.familyId,
    required this.email,
    required this.role,
    this.personalMessage,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InviteMemberParams &&
        other.familyId == familyId &&
        other.email == email &&
        other.role == role &&
        other.personalMessage == personalMessage;
  }

  @override
  int get hashCode => Object.hash(familyId, email, role, personalMessage);
}

/// Use case for inviting a member to the family
///
/// Business Rules (verified from backend):
/// - Only ADMINs can invite members
/// - Email is required and must be valid format
/// - Role is required (defaults to MEMBER if not specified)
/// - Personal message is optional
/// - User must belong to the target family
///
/// Possible failures:
/// - ApiFailure.unauthorized() - User lacks admin permissions
/// - ApiFailure.validationError() - Invalid email or missing required fields
/// - ApiFailure.badRequest() - Invalid role or family not accessible
/// - ApiFailure.serverError() - Backend processing error

class InviteMemberUsecase
    implements UseCase<FamilyInvitation, InviteMemberParams> {
  final InvitationRepository _repository;

  const InviteMemberUsecase(this._repository);
  @override
  Future<Result<FamilyInvitation, Failure>> call(
    InviteMemberParams params,
  ) async {
    // Input validation
    final validationResult = _validateParams(params);
    if (validationResult.isError) {
      return Result.err(validationResult.error!);
    }

    // Call repository using existing sendFamilyInvitation method
    return await _repository.sendFamilyInvitation(
      familyId: params.familyId,
      email: params.email,
      role: params.role.value,
      message: params.personalMessage,
    );
  }

  /// Validate input parameters according to backend rules
  Result<void, ApiFailure> _validateParams(InviteMemberParams params) {
    // Validate family ID
    if (params.familyId.isEmpty) {
      return Result.err(
        ApiFailure.validationError(code: 'validation.family_id_required'),
      );
    }

    // Validate email (required field per backend)
    if (params.email.isEmpty) {
      return Result.err(
        ApiFailure.validationError(code: 'validation.email_required'),
      );
    }

    // Basic email format validation
    if (!_isValidEmail(params.email)) {
      return Result.err(
        ApiFailure.validationError(code: 'validation.email_invalid'),
      );
    }

    // Role validation is implicit - enum ensures valid role

    return const Result.ok(null);
  }

  /// Basic email validation matching backend expectations
  bool _isValidEmail(String email) {
    // Simple email regex matching common backend patterns
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2}$',
    );
    return emailRegex.hasMatch(email);
  }
}
