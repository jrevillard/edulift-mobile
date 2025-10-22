import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/domain/usecases/usecase.dart';
import 'package:edulift/core/domain/entities/family.dart';
import '../repositories/family_repository.dart';

/// Parameters for changing a family member's role
class ChangeMemberRoleParams {
  final String familyId;
  final String memberId;
  final FamilyRole newRole;

  const ChangeMemberRoleParams({
    required this.familyId,
    required this.memberId,
    required this.newRole,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChangeMemberRoleParams &&
        other.familyId == familyId &&
        other.memberId == memberId &&
        other.newRole == newRole;
  }

  @override
  int get hashCode => Object.hash(familyId, memberId, newRole);
}

/// Use case for changing a family member's role
///
/// Business Rules (verified from backend):
/// - Only ADMINs can change member roles
/// - Admin cannot demote themselves
/// - Cannot remove the last admin from family
///
/// Possible failures:
/// - ApiFailure.unauthorized() - User lacks admin permissions
/// - ApiFailure.validationError() - Cannot demote self or last admin
/// - ApiFailure.notFound() - Member not found in family
/// - ApiFailure.serverError() - Backend processing error

class ChangeMemberRoleUsecase
    implements UseCase<FamilyMember, ChangeMemberRoleParams> {
  final FamilyRepository _repository;

  ChangeMemberRoleUsecase(this._repository);

  @override
  Future<Result<FamilyMember, Failure>> call(
    ChangeMemberRoleParams params,
  ) async {
    // Input validation
    final validationResult = _validateParams(params);
    if (validationResult.isError) {
      return Result.err(validationResult.error!);
    }

    // Call repository with validated parameters
    final result = await _repository.updateMemberRole(
      familyId: params.familyId,
      memberId: params.memberId,
      role: params.newRole.value,
    );
    return result.when(
      ok: (member) => Result.ok(member),
      err: (apiFailure) => Result.err(apiFailure),
    );
  }

  /// Validate input parameters according to backend rules
  Result<void, ApiFailure> _validateParams(ChangeMemberRoleParams params) {
    // Validate family ID
    if (params.familyId.isEmpty) {
      return Result.err(
        ApiFailure.validationError(code: 'validation.family_id_required'),
      );
    }

    // Validate member ID
    if (params.memberId.isEmpty) {
      return Result.err(
        ApiFailure.validationError(code: 'validation.member_id_required'),
      );
    }

    // Role validation is implicit - enum ensures valid role
    return const Result.ok(null);
  }
}
