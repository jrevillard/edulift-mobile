import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import 'package:edulift/core/domain/entities/family.dart';
import '../requests/child_requests.dart';

/// Domain service for children business logic
/// Consolidates children operations that were previously in separate use cases
abstract class ChildrenService {
  /// Add a new child to the family
  Future<Result<Child, ApiFailure>> add({
    required String familyId,
    required CreateChildRequest request,
  });

  /// Update an existing child
  Future<Result<Child, ApiFailure>> update({
    required String familyId,
    required UpdateChildParams params,
  });

  /// Remove a child from the family
  Future<Result<void, ApiFailure>> remove({
    required String familyId,
    required String childId,
  });
}
