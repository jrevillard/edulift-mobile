import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/domain/entities/groups/group.dart';
import '../../../../core/network/group_api_client.dart';
import '../repositories/group_repository.dart';
import 'group_service.dart';

/// Implementation of GroupService with extracted validation logic - 2025 Architecture
/// Provides centralized group operations using GroupRepository
///
/// **2025 Migration Notes:**
/// - Enhanced error handling with ApiException support
/// - Improved validation with detailed error messages
/// - Better integration with updated repository layer
/// - Preserves all existing validation logic for backward compatibility

class GroupServiceImpl implements GroupService {
  final GroupRepository _repository;

  GroupServiceImpl(this._repository);

  @override
  Future<Result<List<Group>, ApiFailure>> getAll() async {
    try {
      return await _repository.getGroups();
    } catch (e) {
      // Enhanced error handling for 2025 pattern
      if (e is ApiException) {
        return Result.err(ApiFailure.serverError(code: 'groups.api_error'));
      }
      return Result.err(ApiFailure.serverError(code: 'groups.get_failed'));
    }
  }

  @override
  Future<Result<Group, ApiFailure>> getById(String id) async {
    if (id.trim().isEmpty) {
      return Result.err(ApiFailure.validationError(code: 'groups.id_required'));
    }

    try {
      return await _repository.getGroup(id);
    } catch (e) {
      // Enhanced error handling for 2025 pattern
      if (e is ApiException) {
        return Result.err(ApiFailure.serverError(code: 'groups.api_error'));
      }
      return Result.err(
        ApiFailure.serverError(code: 'groups.get_by_id_failed'),
      );
    }
  }

  @override
  Future<Result<Group, ApiFailure>> create(CreateGroupCommand command) async {
    // Extract and apply validation logic from CreateGroupUsecase
    final validationResult = _validateGroupData(command);
    if (validationResult case Err(:final error)) {
      return Result.err(error);
    }

    try {
      return await _repository.createGroup(command);
    } catch (e) {
      // Enhanced error handling for 2025 pattern
      if (e is ApiException) {
        return Result.err(ApiFailure.serverError(code: 'groups.api_error'));
      }
      return Result.err(ApiFailure.serverError(code: 'groups.create_failed'));
    }
  }

  @override
  Future<Result<Group, ApiFailure>> update(
    String id,
    Map<String, dynamic> updates,
  ) async {
    if (id.trim().isEmpty) {
      return Result.err(ApiFailure.validationError(code: 'groups.id_required'));
    }

    // Validate name if being updated
    if (updates.containsKey('name')) {
      final name = updates['name'] as String?;
      final nameValidation = _validateGroupName(name);
      if (nameValidation case Err(:final error)) {
        return Result.err(error);
      }
    }

    // Validate description if being updated
    if (updates.containsKey('description')) {
      final description = updates['description'] as String?;
      final descriptionValidation = _validateGroupDescription(description);
      if (descriptionValidation case Err(:final error)) {
        return Result.err(error);
      }
    }

    try {
      return await _repository.updateGroup(id, updates);
    } catch (e) {
      // Enhanced error handling for 2025 pattern
      if (e is ApiException) {
        return Result.err(ApiFailure.serverError(code: 'groups.api_error'));
      }
      return Result.err(ApiFailure.serverError(code: 'groups.update_failed'));
    }
  }

  @override
  Future<Result<void, ApiFailure>> delete(String id) async {
    if (id.trim().isEmpty) {
      return Result.err(ApiFailure.validationError(code: 'groups.id_required'));
    }

    try {
      return await _repository.deleteGroup(id);
    } catch (e) {
      // Enhanced error handling for 2025 pattern
      if (e is ApiException) {
        return Result.err(ApiFailure.serverError(code: 'groups.api_error'));
      }
      return Result.err(ApiFailure.serverError(code: 'groups.delete_failed'));
    }
  }

  /// Validation logic extracted from CreateGroupUsecase._validateGroupData
  /// Validates complete group data for creation
  Result<void, ApiFailure> _validateGroupData(CreateGroupCommand command) {
    // Validate group name
    final nameValidation = _validateGroupName(command.name);
    if (nameValidation case Err(:final error)) {
      return Result.err(error);
    }

    // Validate group description
    final descriptionValidation = _validateGroupDescription(
      command.description,
    );
    if (descriptionValidation case Err(:final error)) {
      return Result.err(error);
    }

    return const Result.ok(null);
  }

  /// Validates group name following exact logic from CreateGroupUsecase
  Result<void, ApiFailure> _validateGroupName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return Result.err(
        ApiFailure.validationError(code: 'groups.name_required'),
      );
    }

    if (name.trim().length < 3) {
      return Result.err(
        ApiFailure.validationError(code: 'groups.name_too_short'),
      );
    }

    if (name.length > 100) {
      return Result.err(
        ApiFailure.validationError(code: 'groups.name_too_long'),
      );
    }

    return const Result.ok(null);
  }

  /// Validates group description following exact logic from CreateGroupUsecase
  Result<void, ApiFailure> _validateGroupDescription(String? description) {
    if (description != null && description.length > 500) {
      return Result.err(
        ApiFailure.validationError(code: 'groups.description_too_long'),
      );
    }

    return const Result.ok(null);
  }

  /// Group invitation operations (preserving invitation logic from unified service)
  /// These methods ensure compatibility with family service and maintain invitation workflow

  /// Join a group using invite code (preserving invitation logic)
  Future<Result<Group, ApiFailure>> joinGroup(String inviteCode) async {
    if (inviteCode.trim().isEmpty) {
      return Result.err(
        ApiFailure.validationError(code: 'groups.invite_code_required'),
      );
    }

    try {
      return await _repository.joinGroup(inviteCode);
    } catch (e) {
      if (e is ApiException) {
        return Result.err(ApiFailure.serverError(code: 'groups.api_error'));
      }
      return Result.err(ApiFailure.serverError(code: 'groups.join_failed'));
    }
  }

  /// Leave a group (preserving leave logic)
  Future<Result<void, ApiFailure>> leaveGroup(String groupId) async {
    if (groupId.trim().isEmpty) {
      return Result.err(ApiFailure.validationError(code: 'groups.id_required'));
    }

    try {
      return await _repository.leaveGroup(groupId);
    } catch (e) {
      if (e is ApiException) {
        return Result.err(ApiFailure.serverError(code: 'groups.api_error'));
      }
      return Result.err(ApiFailure.serverError(code: 'groups.leave_failed'));
    }
  }

  /// Validate group invitation code (preserving validation logic)
  Future<Result<GroupInvitationValidationData, ApiFailure>> validateInvitation(
    String code,
  ) async {
    if (code.trim().isEmpty) {
      return Result.err(
        ApiFailure.validationError(code: 'groups.invitation_code_required'),
      );
    }

    try {
      return await _repository.validateInvitation(code);
    } catch (e) {
      if (e is ApiException) {
        return Result.err(ApiFailure.serverError(code: 'groups.api_error'));
      }
      return Result.err(
        ApiFailure.serverError(code: 'groups.invitation_validation_failed'),
      );
    }
  }
}
