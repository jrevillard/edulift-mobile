import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/domain/usecases/usecase.dart';
import '../repositories/family_repository.dart';

/// Parameters for removing a family member
class RemoveMemberParams {
  final String familyId;
  final String memberId;

  const RemoveMemberParams({required this.familyId, required this.memberId});
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RemoveMemberParams &&
        other.familyId == familyId &&
        other.memberId == memberId;
  }

  @override
  int get hashCode => familyId.hashCode ^ memberId.hashCode;
}

/// Use case for removing a member from a family
///
/// Business Logic:
/// 1. Validates that the member exists in the family
/// 2. Ensures business rules (cannot remove last admin, etc.)
/// 3. Removes the member from the family
///
/// Possible failures:
/// - ApiFailure.badRequest() - Invalid member ID or business rule violation
/// - ApiFailure.notFound() - Member not found in family
/// - ApiFailure.serverError() - Backend processing error
class RemoveMemberUsecase implements UseCase<void, RemoveMemberParams> {
  final FamilyRepository _familyRepository;

  RemoveMemberUsecase(this._familyRepository);
  @override
  Future<Result<void, Failure>> call(RemoveMemberParams params) async {
    final result = await _familyRepository.removeMember(
        familyId: params.familyId,
        memberId: params.memberId);

    if (result.isOk) {
      return const Result.ok(null);
    } else {
      return Result.err(result.error!);
    }
  }
}
