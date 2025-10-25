import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/domain/entities/groups/group.dart';
import '../../../../core/domain/entities/groups/group_family.dart';
import '../../../../core/network/group_api_client.dart';

abstract class GroupRepository {
  /// Create a new group
  Future<Result<Group, ApiFailure>> createGroup(CreateGroupCommand command);

  /// Update group details
  Future<Result<Group, ApiFailure>> updateGroup(
    String groupId,
    Map<String, dynamic> updates,
  );

  /// Get a specific group by ID
  Future<Result<Group, ApiFailure>> getGroup(String groupId);

  /// Get groups for the current user
  Future<Result<List<Group>, ApiFailure>> getGroups();

  /// Delete a group
  Future<Result<void, ApiFailure>> deleteGroup(String groupId);

  /// Join a group with invite code
  Future<Result<Group, ApiFailure>> joinGroup(String inviteCode);

  /// Leave a group
  Future<Result<void, ApiFailure>> leaveGroup(String groupId);

  /// Validate group invitation code
  Future<Result<GroupInvitationValidationData, ApiFailure>> validateInvitation(
    String code,
  );

  /// Get families in a group
  Future<Result<List<GroupFamily>, ApiFailure>> getGroupFamilies(
    String groupId,
  );

  /// Update family role in a group (admin only)
  Future<Result<GroupFamily, ApiFailure>> updateFamilyRole(
    String groupId,
    String familyId,
    Map<String, dynamic> updates,
  );

  /// Remove family from a group (admin only)
  Future<Result<void, ApiFailure>> removeFamilyFromGroup(
    String groupId,
    String familyId,
  );

  /// Cancel a pending invitation (admin only)
  Future<Result<void, ApiFailure>> cancelInvitation(
    String groupId,
    String invitationId,
  );

  /// Search families for invitation (cache-first pattern)
  Future<Result<List<FamilySearchResult>, ApiFailure>>
      searchFamiliesForInvitation(String groupId, String? query, int? limit);

  /// Invite a family to the group (server-first pattern)
  Future<Result<void, ApiFailure>> inviteFamilyToGroup(
    String groupId,
    String familyId,
    String? role,
    String? message,
  );
}
