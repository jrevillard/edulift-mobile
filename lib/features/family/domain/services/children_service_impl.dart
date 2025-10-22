import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import 'package:edulift/core/domain/entities/family.dart';
import '../repositories/family_repository.dart';
import '../requests/child_requests.dart';
import 'children_service.dart';

/// Implementation of ChildrenService using FamilyRepository
/// Direct delegation pattern since these are thin repository wrappers

class ChildrenServiceImpl implements ChildrenService {
  final FamilyRepository _repository;

  ChildrenServiceImpl(this._repository);
  @override
  Future<Result<Child, ApiFailure>> add({
    required String familyId,
    required CreateChildRequest request,
  }) async {
    // OPTIMIZATION FIX: Use provided familyId
    return await _repository.addChildFromRequest(familyId, request);
  }

  @override
  Future<Result<Child, ApiFailure>> update({
    required String familyId,
    required UpdateChildParams params,
  }) async {
    // OPTIMIZATION FIX: Use provided familyId
    return await _repository.updateChildFromRequest(
      familyId,
      params.childId,
      params.request,
    );
  }

  @override
  Future<Result<void, ApiFailure>> remove({
    required String familyId,
    required String childId,
  }) async {
    // OPTIMIZATION FIX: Use provided familyId
    return await _repository.deleteChild(familyId: familyId, childId: childId);
  }
}
