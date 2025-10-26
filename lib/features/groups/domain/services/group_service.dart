import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/domain/entities/groups/group.dart';

/// Domain service for group business logic and validation
/// Provides centralized group operations with extracted validation logic
abstract class GroupService {
  /// Get all groups for the current user
  Future<Result<List<Group>, ApiFailure>> getAll();

  /// Get a specific group by ID
  Future<Result<Group, ApiFailure>> getById(String id);

  /// Create a new group with validation
  Future<Result<Group, ApiFailure>> create(CreateGroupCommand command);

  /// Update group with specified changes
  Future<Result<Group, ApiFailure>> update(
    String id,
    Map<String, dynamic> updates,
  );

  /// Delete a group
  Future<Result<void, ApiFailure>> delete(String id);
}
