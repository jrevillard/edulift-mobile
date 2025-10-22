// Groups Remote Data Source Interface
// Clean Architecture data source abstraction for Group domain
// Separated from Family domain for proper Clean Architecture compliance

import '../../../../core/network/group_api_client.dart';

/// Abstract interface for group remote data source
/// Handles ALL group-related remote operations
abstract class GroupRemoteDataSource {
  // ========================================
  // GROUP OPERATIONS - RETURNING DTOs
  // ========================================

  /// Get groups for the current user from server
  Future<List<Map<String, dynamic>>> getMyGroups();

  /// Get specific group by ID from server
  Future<Map<String, dynamic>> getGroup(String groupId);

  /// Create a new group on server
  Future<Map<String, dynamic>> createGroup(Map<String, dynamic> groupData);

  /// Update group details on server
  Future<Map<String, dynamic>> updateGroup(
    String groupId,
    Map<String, dynamic> updates,
  );

  /// Delete group from server
  Future<void> deleteGroup(String groupId);

  /// Join group with invite code
  Future<Map<String, dynamic>> joinGroup(String inviteCode);

  /// Leave group
  Future<void> leaveGroup(String groupId);

  /// Generate group invitation code
  Future<String> generateGroupInvitationCode(String groupId);

  // ========================================
  // GROUP INVITATION OPERATIONS
  // ========================================

  /// Send group invitation via server
  Future<GroupInvitationData> sendGroupInvitation({
    required String groupId,
    required String email,
    String? message,
  });

  /// Validate group invitation code
  Future<GroupInvitationValidationData> validateGroupInvitation(
    String inviteCode,
  );

  /// Get families in a group
  Future<List<GroupFamilyData>> getGroupFamilies(String groupId);

  /// Update family role in a group (admin only)
  Future<GroupFamilyData> updateFamilyRole(
    String groupId,
    String familyId,
    Map<String, dynamic> updates,
  );

  /// Remove family from a group (admin only)
  Future<void> removeFamilyFromGroup(String groupId, String familyId);

  /// Cancel a pending invitation (admin only)
  Future<void> cancelInvitation(String groupId, String invitationId);

  /// Search families for invitation
  Future<List<Map<String, dynamic>>> searchFamiliesForInvitation(
    String groupId,
    String? query,
    int? limit,
  );

  /// Invite family to group
  Future<Map<String, dynamic>> inviteFamilyToGroup(
    String groupId,
    String familyId,
    String? role,
    String? message,
  );

  /// Get pending invitations for a group
  Future<List<Map<String, dynamic>>> getPendingInvitations(String groupId);
}
