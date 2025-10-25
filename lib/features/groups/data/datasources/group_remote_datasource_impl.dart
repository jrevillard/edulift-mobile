// Groups Remote Data Source Implementation - 2025 Architecture
// Clean Architecture data source implementation for Group/Schedule domain
// All schedule methods migrated from FamilyRemoteDataSource to fix domain violations
//
// **2025 Migration Notes:**
// - Uses ApiResponseHelper.execute() for consistent error handling
// - API clients now return DTOs directly (not wrapped responses)
// - Enhanced error context and type safety
// - Transparent, maintainable API communication flow

import '../../../../core/network/group_api_client.dart';
import '../../../../core/network/requests/group_requests.dart' as api_client;
import '../../../../core/network/models/common/accept_invitation_response.dart';
import '../../../../core/network/api_response_helper.dart';
import 'group_remote_datasource.dart';

/// Clean Architecture Group Remote DataSource Implementation
/// Handles ALL group and schedule operations that were incorrectly in Family domain
class GroupRemoteDataSourceImpl implements GroupRemoteDataSource {
  final GroupApiClient _apiClient;

  const GroupRemoteDataSourceImpl(this._apiClient);
  // ========================================
  // GROUP OPERATIONS - CLEAN IMPLEMENTATION
  // ========================================

  @override
  Future<List<Map<String, dynamic>>> getMyGroups() async {
    final groups = await ApiResponseHelper.executeAndUnwrap<List<GroupData>>(
      () => _apiClient.getMyGroups(),
    );
    return groups.map((group) => group.toJson()).toList();
  }

  @override
  Future<Map<String, dynamic>> getGroup(String groupId) async {
    final group = await ApiResponseHelper.executeAndUnwrap<GroupData>(
      () => _apiClient.getGroup(groupId),
    );
    return group.toJson();
  }

  @override
  Future<Map<String, dynamic>> createGroup(
    Map<String, dynamic> groupData,
  ) async {
    // Convert to proper DTO using API client's request class
    final request = api_client.CreateGroupRequest(
      name: groupData['name'] as String,
      description: groupData['description'] as String?,
    );
    final group = await ApiResponseHelper.executeAndUnwrap<GroupData>(
      () => _apiClient.createGroup(request),
    );
    return group.toJson();
  }

  @override
  Future<Map<String, dynamic>> updateGroup(
    String groupId,
    Map<String, dynamic> updates,
  ) async {
    // Convert to proper DTO using API client's request class
    final request = api_client.UpdateGroupRequest(
      name: updates['name'] as String?,
      description: updates['description'] as String?,
    );
    final group = await ApiResponseHelper.executeAndUnwrap<GroupData>(
      () => _apiClient.updateGroup(groupId, request),
    );
    return group.toJson();
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    await ApiResponseHelper.executeAndUnwrap<void>(
      () => _apiClient.deleteGroup(groupId),
    );
  }

  @override
  Future<Map<String, dynamic>> joinGroup(String inviteCode) async {
    final request = api_client.JoinGroupRequest(code: inviteCode);
    final group = await ApiResponseHelper.executeAndUnwrap<GroupData>(
      () => _apiClient.joinGroup(request),
    );
    return group.toJson();
  }

  @override
  Future<void> leaveGroup(String groupId) async {
    await ApiResponseHelper.executeAndUnwrap<void>(
      () => _apiClient.leaveGroup(groupId),
    );
  }

  @override
  Future<String> generateGroupInvitationCode(String groupId) async {
    // Cette méthode pourrait nécessiter une API backend spécifique
    // Pour l'instant, on utilise l'invitation validation
    throw UnimplementedError(
      'generateGroupInvitationCode not yet implemented in ApiClient. '
      'Consider using sendGroupInvitation for invitation functionality.',
    );
  }

  /// Validate group invitation code (preserving invitation logic)
  @override
  Future<GroupInvitationValidationData> validateGroupInvitation(
    String code,
  ) async {
    final validation =
        await ApiResponseHelper.executeAndUnwrap<GroupInvitationValidationData>(
      () => _apiClient.validateInviteCode(code),
    );
    return validation;
  }

  /// Accept group invitation by code (preserving invitation logic)
  Future<Map<String, dynamic>> acceptGroupInvitation(String code) async {
    final response =
        await ApiResponseHelper.executeAndUnwrap<AcceptInvitationResponse>(
      () => _apiClient.acceptGroupInvitationByCode(code),
    );
    return {'success': response.success};
  }

  /// Get group families for search and invitation management
  @override
  Future<List<GroupFamilyData>> getGroupFamilies(String groupId) async {
    return await ApiResponseHelper.executeAndUnwrap<List<GroupFamilyData>>(
      () => _apiClient.getFamilies(groupId),
    );
  }

  /// Update family role in a group (admin only)
  @override
  Future<GroupFamilyData> updateFamilyRole(
    String groupId,
    String familyId,
    Map<String, dynamic> updates,
  ) async {
    final request = api_client.UpdateFamilyRoleRequest(
      role: updates['role'] as String,
    );
    return await ApiResponseHelper.executeAndUnwrap<GroupFamilyData>(
      () => _apiClient.updateFamilyRole(groupId, familyId, request),
    );
  }

  /// Remove family from a group (admin only)
  @override
  Future<void> removeFamilyFromGroup(String groupId, String familyId) async {
    await ApiResponseHelper.executeAndUnwrap<void>(
      () => _apiClient.removeFamilyFromGroup(groupId, familyId),
    );
  }

  /// Cancel a pending invitation (admin only)
  @override
  Future<void> cancelInvitation(String groupId, String invitationId) async {
    await ApiResponseHelper.executeAndUnwrap<void>(
      () => _apiClient.cancelInvitation(groupId, invitationId),
    );
  }

  /// Search families for invitation (preserving search logic)
  @override
  Future<List<Map<String, dynamic>>> searchFamiliesForInvitation(
    String groupId,
    String? query,
    int? limit,
  ) async {
    final request = api_client.SearchFamiliesRequest(
      query: query,
      limit: limit,
    );
    final families =
        await ApiResponseHelper.executeAndUnwrap<List<FamilySearchResult>>(
      () => _apiClient.searchFamilies(groupId, request),
    );
    return families.map((family) => family.toJson()).toList();
  }

  /// Invite family to group (preserving family invitation logic)
  @override
  Future<Map<String, dynamic>> inviteFamilyToGroup(
    String groupId,
    String familyId,
    String? role,
    String? message,
  ) async {
    final request = api_client.InviteFamilyToGroupRequest(
      familyId: familyId,
      role: role,
      message: message,
    );
    final invitation =
        await ApiResponseHelper.executeAndUnwrap<GroupInvitationData>(
      () => _apiClient.inviteFamilyToGroup(groupId, request),
    );
    return invitation.toJson();
  }

  /// Get pending invitations for group
  @override
  Future<List<Map<String, dynamic>>> getPendingInvitations(
    String groupId,
  ) async {
    final invitations =
        await ApiResponseHelper.executeAndUnwrap<List<GroupInvitationData>>(
      () => _apiClient.getPendingInvitations(groupId),
    );
    return invitations.map((invitation) => invitation.toJson()).toList();
  }

  /// Cancel group invitation
  Future<void> cancelGroupInvitation(
    String groupId,
    String invitationId,
  ) async {
    await ApiResponseHelper.executeAndUnwrap<void>(
      () => _apiClient.cancelInvitation(groupId, invitationId),
    );
  }

  // ========================================
  // GROUP INVITATION OPERATIONS
  // ========================================

  @override
  Future<GroupInvitationData> sendGroupInvitation({
    required String groupId,
    required String email,
    String? message,
  }) async {
    final request = api_client.CreateGroupInvitationRequest(
      groupId: groupId,
      email: email,
      message: message,
    );
    final invitation =
        await ApiResponseHelper.executeAndUnwrap<GroupInvitationData>(
      () => _apiClient.createGroupInvitation(request),
    );
    return invitation;
  }
}
