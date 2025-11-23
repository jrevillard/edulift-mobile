import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart' hide ParseErrorLogger;
import '../utils/error_logger.dart'; // Override Retrofit's ParseErrorLogger
import 'package:json_annotation/json_annotation.dart';
import 'models/schedule/schedule_config_dto.dart';
import 'models/schedule/time_slot_config_dto.dart';
import 'models/common/accept_invitation_response.dart';
import 'requests/group_requests.dart';

// Re-export request classes for backward compatibility with datasources
export 'requests/group_requests.dart';

part 'group_api_client.g.dart';

/// Group API Client - State-of-the-Art 2025 Architecture
///
/// **Key Changes from Legacy Pattern:**
/// - API clients return DTOs as before (Retrofit requirement)
/// - Interceptor ensures responses are wrapped in proper JSON structure
/// - Repositories parse responses into ApiResponse<T> and use .unwrap() for error handling
/// - Transparent, maintainable API communication flow
///
/// Backend routes: /api/v1/groups/{validate-invite (public), create, join, my-groups, search-families (POST), etc.}
@RestApi()
abstract class GroupApiClient {
  factory GroupApiClient.create(Dio dio, {String? baseUrl}) = _GroupApiClient;

  /// Validate invitation code (public route)
  /// GET /api/v1/invitations/group/:code/validate
  ///
  /// **Architecture Note**: Returns DTO directly (Retrofit requirement)
  /// **Repository Pattern**: Repository will parse response into ApiResponse<GroupInvitationValidationData> and call .unwrap()
  @GET('/invitations/group/{code}/validate')
  Future<GroupInvitationValidationData> validateInviteCode(
    @Path('code') String code,
  );

  /// Create new group
  /// POST /api/v1/groups
  ///
  /// **Architecture Note**: Returns DTO directly (Retrofit requirement)
  /// **Repository Pattern**: Repository will parse response into ApiResponse<GroupData> and call .unwrap()
  @POST('/groups')
  Future<GroupData> createGroup(@Body() CreateGroupRequest request);

  /// Join group by invite code
  /// POST /api/v1/groups/join
  ///
  /// **Architecture Note**: Returns DTO directly (Retrofit requirement)
  /// **Repository Pattern**: Repository will parse response into ApiResponse<GroupData> and call .unwrap()
  @POST('/groups/join')
  Future<GroupData> joinGroup(@Body() JoinGroupRequest request);

  /// Get user's groups
  /// GET /api/v1/groups/my-groups
  ///
  /// **Architecture Note**: Returns DTO directly (Retrofit requirement)
  /// **Repository Pattern**: Repository will parse response into ApiResponse<List<GroupData>> and call .unwrap()
  @GET('/groups/my-groups')
  Future<List<GroupData>> getUserGroups();

  /// Get group families (family-based group management)
  /// GET /api/v1/groups/{groupId}/families
  ///
  /// **Architecture Note**: Returns DTO directly (Retrofit requirement)
  /// **Repository Pattern**: Repository will parse response into ApiResponse<List<GroupFamilyData>> and call .unwrap()
  @GET('/groups/{groupId}/families')
  Future<List<GroupFamilyData>> getFamilies(@Path('groupId') String groupId);

  /// Leave group (member action)
  /// POST /api/v1/groups/{groupId}/leave
  ///
  /// **Architecture Note**: Returns void directly (Retrofit requirement)
  /// **Repository Pattern**: Repository will parse response into ApiResponse<void> and call .unwrap()
  @POST('/groups/{groupId}/leave')
  Future<void> leaveGroup(@Path('groupId') String groupId);

  /// Update family role (admin only)
  /// PATCH /api/v1/groups/{groupId}/families/{familyId}/role
  ///
  /// **Architecture Note**: Returns DTO directly (Retrofit requirement)
  /// **Repository Pattern**: Repository will parse response into ApiResponse<GroupFamilyData> and call .unwrap()
  @PATCH('/groups/{groupId}/families/{familyId}/role')
  Future<GroupFamilyData> updateFamilyRole(
    @Path('groupId') String groupId,
    @Path('familyId') String familyId,
    @Body() UpdateFamilyRoleRequest request,
  );

  /// Remove family from group (admin only)
  /// DELETE /api/v1/groups/{groupId}/families/{familyId}
  ///
  /// **Architecture Note**: Returns void directly (Retrofit requirement)
  /// **Repository Pattern**: Repository will parse response into ApiResponse<void> and call .unwrap()
  @DELETE('/groups/{groupId}/families/{familyId}')
  Future<void> removeFamilyFromGroup(
    @Path('groupId') String groupId,
    @Path('familyId') String familyId,
  );

  /// Update group settings (admin only)
  /// PATCH /api/v1/groups/{groupId}
  ///
  /// **Architecture Note**: Returns DTO directly (Retrofit requirement)
  /// **Repository Pattern**: Repository will parse response into ApiResponse<GroupData> and call .unwrap()
  @PATCH('/groups/{groupId}')
  Future<GroupData> updateGroup(
    @Path('groupId') String groupId,
    @Body() UpdateGroupRequest request,
  );

  /// Delete group (admin only)
  /// DELETE /api/v1/groups/{groupId}
  ///
  /// **Architecture Note**: Returns void directly (Retrofit requirement)
  /// **Repository Pattern**: Repository will parse response into ApiResponse<void> and call .unwrap()
  @DELETE('/groups/{groupId}')
  Future<void> deleteGroup(@Path('groupId') String groupId);

  /// Search families for invitation (admin only)
  /// POST /api/v1/groups/{groupId}/search-families (CONFIRMED: POST METHOD)
  ///
  /// **Architecture Note**: Returns DTO directly (Retrofit requirement)
  /// **Repository Pattern**: Repository will parse response into ApiResponse<List<FamilySearchResult>> and call .unwrap()
  @POST('/groups/{groupId}/search-families')
  Future<List<FamilySearchResult>> searchFamilies(
    @Path('groupId') String groupId,
    @Body() SearchFamiliesRequest request,
  );

  /// Invite family to group
  /// POST /api/v1/groups/{groupId}/invite
  ///
  /// **Architecture Note**: Returns DTO directly (Retrofit requirement)
  /// **Repository Pattern**: Repository will parse response into ApiResponse<GroupInvitationData> and call .unwrap()
  @POST('/groups/{groupId}/invite')
  Future<GroupInvitationData> inviteFamilyToGroup(
    @Path('groupId') String groupId,
    @Body() InviteFamilyToGroupRequest request,
  );

  /// Get pending invitations
  /// GET /api/v1/groups/{groupId}/invitations
  ///
  /// **Architecture Note**: Returns DTO directly (Retrofit requirement)
  /// **Repository Pattern**: Repository will parse response into ApiResponse<List<GroupInvitationData>> and call .unwrap()
  @GET('/groups/{groupId}/invitations')
  Future<List<GroupInvitationData>> getPendingInvitations(
    @Path('groupId') String groupId,
  );

  /// Cancel invitation
  /// DELETE /api/v1/groups/{groupId}/invitations/{invitationId}
  ///
  /// **Architecture Note**: Returns void directly (Retrofit requirement)
  /// **Repository Pattern**: Repository will parse response into ApiResponse<void> and call .unwrap()
  @DELETE('/groups/{groupId}/invitations/{invitationId}')
  Future<void> cancelInvitation(
    @Path('groupId') String groupId,
    @Path('invitationId') String invitationId,
  );

  // Group Schedule Configuration routes

  /// Get default schedule hours (public for authenticated users)
  /// GET /api/v1/groups/schedule-config/default
  ///
  /// **Architecture Note**: Returns DTO directly (Retrofit requirement)
  /// **Repository Pattern**: Repository will parse response into ApiResponse<ScheduleConfigDto> and call .unwrap()
  @GET('/groups/schedule-config/default')
  Future<ScheduleConfigDto> getDefaultScheduleHours();

  /// Initialize default configurations for all groups (admin utility)
  /// POST /api/v1/groups/schedule-config/initialize
  ///
  /// **Architecture Note**: Returns void directly (Retrofit requirement)
  /// **Repository Pattern**: Repository will parse response into ApiResponse<void> and call .unwrap()
  @POST('/groups/schedule-config/initialize')
  Future<void> initializeDefaultConfigs();

  /// Get group schedule configuration (group member access)
  /// GET /api/v1/groups/{groupId}/schedule-config
  ///
  /// **Architecture Note**: Returns DTO directly (Retrofit requirement)
  /// **Repository Pattern**: Repository will parse response into ApiResponse<ScheduleConfigDto> and call .unwrap()
  @GET('/groups/{groupId}/schedule-config')
  Future<ScheduleConfigDto> getGroupScheduleConfig(
    @Path('groupId') String groupId,
  );

  /// Get time slots for specific weekday (group member access)
  /// GET /api/v1/groups/{groupId}/schedule-config/time-slots
  ///
  /// **Architecture Note**: Returns DTO directly (Retrofit requirement)
  /// **Repository Pattern**: Repository will parse response into ApiResponse<List<TimeSlotConfigDto>> and call .unwrap()
  @GET('/groups/{groupId}/schedule-config/time-slots')
  Future<List<TimeSlotConfigDto>> getGroupTimeSlots(
    @Path('groupId') String groupId,
  );

  /// Update group schedule configuration (admin only)
  /// PUT /api/v1/groups/{groupId}/schedule-config
  ///
  /// **Architecture Note**: Returns DTO directly (Retrofit requirement)
  /// **Repository Pattern**: Repository will parse response into ApiResponse<ScheduleConfigDto> and call .unwrap()
  @PUT('/groups/{groupId}/schedule-config')
  Future<ScheduleConfigDto> updateGroupScheduleConfig(
    @Path('groupId') String groupId,
    @Body() UpdateScheduleConfigRequest request,
  );

  /// Reset group schedule configuration to default (admin only)
  /// POST /api/v1/groups/{groupId}/schedule-config/reset
  ///
  /// **Architecture Note**: Returns void directly (Retrofit requirement)
  /// **Repository Pattern**: Repository will parse response into ApiResponse<void> and call .unwrap()
  @POST('/groups/{groupId}/schedule-config/reset')
  Future<void> resetGroupScheduleConfig(@Path('groupId') String groupId);

  // EMERGENCY ADDITIONS - Missing methods for unified invitation service

  /// Get my groups (legacy method name)
  /// GET /api/v1/groups/my-groups
  ///
  /// **Architecture Note**: Returns DTO directly (Retrofit requirement)
  /// **Repository Pattern**: Repository will parse response into ApiResponse<List<GroupData>> and call .unwrap()
  @GET('/groups/my-groups')
  Future<List<GroupData>> getMyGroups();

  /// Get specific group by ID
  /// GET /api/v1/groups/{groupId}
  ///
  /// **Architecture Note**: Returns DTO directly (Retrofit requirement)
  /// **Repository Pattern**: Repository will parse response into ApiResponse<GroupData> and call .unwrap()
  @GET('/groups/{groupId}')
  Future<GroupData> getGroup(@Path('groupId') String groupId);

  /// Accept group invitation by code
  /// POST /api/v1/invitations/group/{code}/accept
  ///
  /// **Architecture Note**: Returns simple success response (frontends only use success flag)
  /// **Repository Pattern**: Repository will parse response into ApiResponse<AcceptInvitationResponse> and call .unwrap()
  @POST('/invitations/group/{code}/accept')
  Future<AcceptInvitationResponse> acceptGroupInvitationByCode(
    @Path('code') String inviteCode,
  );

  /// Create group invitation
  /// POST /api/v1/groups/invitations
  ///
  /// **Architecture Note**: Returns DTO directly (Retrofit requirement)
  /// **Repository Pattern**: Repository will parse response into ApiResponse<GroupInvitationData> and call .unwrap()
  @POST('/groups/invitations')
  Future<GroupInvitationData> createGroupInvitation(
    @Body() CreateGroupInvitationRequest request,
  );
}

// Response Models
@JsonSerializable(includeIfNull: false)
class BaseResponse {
  final bool success;
  final String? message;

  BaseResponse({required this.success, this.message});

  factory BaseResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BaseResponseToJson(this);
}

@JsonSerializable(includeIfNull: false)
class GroupData {
  final String id;
  final String name;
  final String? description;
  final String familyId;
  @JsonKey(name: 'invite_code')
  final String? inviteCode;
  final String createdAt;
  final String updatedAt;
  final String? userRole;
  final String? joinedAt;
  final Map<String, dynamic>? ownerFamily;
  final int? familyCount;
  final int? scheduleCount;

  GroupData({
    required this.id,
    required this.name,
    this.description,
    required this.familyId,
    this.inviteCode,
    required this.createdAt,
    required this.updatedAt,
    this.userRole,
    this.joinedAt,
    this.ownerFamily,
    this.familyCount,
    this.scheduleCount,
  });

  factory GroupData.fromJson(Map<String, dynamic> json) =>
      _$GroupDataFromJson(json);
  Map<String, dynamic> toJson() => _$GroupDataToJson(this);
}

@JsonSerializable(includeIfNull: false)
class GroupResponse {
  final bool success;
  final GroupData data;

  GroupResponse({required this.success, required this.data});

  factory GroupResponse.fromJson(Map<String, dynamic> json) =>
      _$GroupResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GroupResponseToJson(this);
}

@JsonSerializable(includeIfNull: false)
class GroupListResponse {
  final bool success;
  final List<GroupData> data;

  GroupListResponse({required this.success, required this.data});

  factory GroupListResponse.fromJson(Map<String, dynamic> json) =>
      _$GroupListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GroupListResponseToJson(this);
}

@JsonSerializable(includeIfNull: false)
class GroupInvitationValidationResponse {
  final bool success;
  final GroupInvitationValidationData data;

  GroupInvitationValidationResponse({
    required this.success,
    required this.data,
  });

  factory GroupInvitationValidationResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$GroupInvitationValidationResponseFromJson(json);
  Map<String, dynamic> toJson() =>
      _$GroupInvitationValidationResponseToJson(this);
}

@JsonSerializable()
class GroupInvitationValidationData {
  final bool valid;
  final String? groupId;
  final String? groupName;
  final String? inviterName;
  final bool? requiresAuth;
  final String? error;
  final String? errorCode;
  final String? email;
  final bool? existingUser;

  GroupInvitationValidationData({
    required this.valid,
    this.groupId,
    this.groupName,
    this.inviterName,
    this.requiresAuth,
    this.error,
    this.errorCode,
    this.email,
    this.existingUser,
  });

  factory GroupInvitationValidationData.fromJson(Map<String, dynamic> json) =>
      GroupInvitationValidationData(
        valid: json['valid'] as bool,
        groupId: json['groupId'] as String?,
        groupName: json['groupName'] as String?,
        inviterName: json['inviterName'] as String?,
        requiresAuth: json['requiresAuth'] as bool?,
        error: json['error'] as String?,
        errorCode: json['errorCode'] as String?,
        email: json['email'] as String?,
        existingUser: json['existingUser'] as bool?,
      );

  Map<String, dynamic> toJson() => _$GroupInvitationValidationDataToJson(this);
}

@JsonSerializable()
class GroupFamiliesResponse {
  final bool success;
  final List<GroupFamilyData> data;

  GroupFamiliesResponse({required this.success, required this.data});

  factory GroupFamiliesResponse.fromJson(Map<String, dynamic> json) =>
      _$GroupFamiliesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GroupFamiliesResponseToJson(this);
}

/// Admin user data within a family
@JsonSerializable()
class FamilyAdminData {
  final String name;
  final String email;

  FamilyAdminData({required this.name, required this.email});

  factory FamilyAdminData.fromJson(Map<String, dynamic> json) =>
      _$FamilyAdminDataFromJson(json);
  Map<String, dynamic> toJson() => _$FamilyAdminDataToJson(this);
}

/// Group Family Data - Complete representation matching backend API
///
/// Represents a family within a group with role, permissions, and admin information.
/// For PENDING families, includes invitation metadata (invitationId, invitedAt, expiresAt).
@JsonSerializable()
class GroupFamilyData {
  /// Family ID (unique identifier)
  final String id;

  /// Family name
  final String name;

  /// Role in group: OWNER, ADMIN, MEMBER
  final String role;

  /// Is this the current user's family?
  @JsonKey(name: 'isMyFamily')
  final bool isMyFamily;

  /// Can the current user manage this family? (promote/demote/remove)
  @JsonKey(name: 'canManage')
  final bool canManage;

  /// List of admin users in this family
  final List<FamilyAdminData> admins;

  /// Invitation status (only for pending invitations): PENDING, ACCEPTED, REJECTED, EXPIRED
  final String? status;

  /// Invitation code (only for pending invitations)
  @JsonKey(name: 'inviteCode')
  final String? inviteCode;

  /// Invitation ID (only for pending invitations)
  @JsonKey(name: 'invitationId')
  final String? invitationId;

  /// Invitation creation date (only for pending invitations)
  @JsonKey(name: 'invitedAt')
  final String? invitedAt;

  /// Invitation expiration date (only for pending invitations)
  @JsonKey(name: 'expiresAt')
  final String? expiresAt;

  GroupFamilyData({
    required this.id,
    required this.name,
    required this.role,
    required this.isMyFamily,
    required this.canManage,
    required this.admins,
    this.status,
    this.inviteCode,
    this.invitationId,
    this.invitedAt,
    this.expiresAt,
  });

  factory GroupFamilyData.fromJson(Map<String, dynamic> json) =>
      _$GroupFamilyDataFromJson(json);
  Map<String, dynamic> toJson() => _$GroupFamilyDataToJson(this);
}

@JsonSerializable()
class GroupFamilyResponse {
  final bool success;
  final GroupFamilyData data;

  GroupFamilyResponse({required this.success, required this.data});

  factory GroupFamilyResponse.fromJson(Map<String, dynamic> json) =>
      _$GroupFamilyResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GroupFamilyResponseToJson(this);
}

@JsonSerializable()
class SearchFamiliesResponse {
  final bool success;
  final List<FamilySearchResult> data;

  SearchFamiliesResponse({required this.success, required this.data});

  factory SearchFamiliesResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchFamiliesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SearchFamiliesResponseToJson(this);
}

/// Admin contact information within a family search result
@JsonSerializable()
class AdminContact {
  final String name;
  final String email;

  AdminContact({required this.name, required this.email});

  factory AdminContact.fromJson(Map<String, dynamic> json) =>
      _$AdminContactFromJson(json);
  Map<String, dynamic> toJson() => _$AdminContactToJson(this);
}

/// Family search result for invitation - matches backend exactly
@JsonSerializable(explicitToJson: true)
class FamilySearchResult {
  final String id;
  final String name;
  final List<AdminContact> adminContacts;
  final int memberCount;
  final bool canInvite;

  FamilySearchResult({
    required this.id,
    required this.name,
    required this.adminContacts,
    required this.memberCount,
    required this.canInvite,
  });

  factory FamilySearchResult.fromJson(Map<String, dynamic> json) =>
      _$FamilySearchResultFromJson(json);
  Map<String, dynamic> toJson() => _$FamilySearchResultToJson(this);
}

@JsonSerializable()
class GroupInvitationResponse {
  final bool success;
  final GroupInvitationData data;

  GroupInvitationResponse({required this.success, required this.data});

  factory GroupInvitationResponse.fromJson(Map<String, dynamic> json) =>
      _$GroupInvitationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GroupInvitationResponseToJson(this);
}

@JsonSerializable()
class GroupInvitationData {
  final String id;
  final String groupId;
  final String? targetFamilyId;
  final String? email;
  final String role;
  final String? personalMessage;
  final String invitedBy;
  final String createdBy;
  final String? acceptedBy;
  final String status;
  final String inviteCode;
  final String expiresAt;
  final String? acceptedAt;
  final String createdAt;
  final String updatedAt;

  GroupInvitationData({
    required this.id,
    required this.groupId,
    this.targetFamilyId,
    this.email,
    required this.role,
    this.personalMessage,
    required this.invitedBy,
    required this.createdBy,
    this.acceptedBy,
    required this.status,
    required this.inviteCode,
    required this.expiresAt,
    this.acceptedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroupInvitationData.fromJson(Map<String, dynamic> json) =>
      _$GroupInvitationDataFromJson(json);
  Map<String, dynamic> toJson() => _$GroupInvitationDataToJson(this);
}

@JsonSerializable()
class InvitationListResponse {
  final bool success;
  final List<GroupInvitationData> data;

  InvitationListResponse({required this.success, required this.data});

  factory InvitationListResponse.fromJson(Map<String, dynamic> json) =>
      _$InvitationListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$InvitationListResponseToJson(this);
}

@JsonSerializable()
class DefaultScheduleHoursResponse {
  final bool success;
  final Map<String, dynamic> data;

  DefaultScheduleHoursResponse({required this.success, required this.data});

  factory DefaultScheduleHoursResponse.fromJson(Map<String, dynamic> json) =>
      _$DefaultScheduleHoursResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DefaultScheduleHoursResponseToJson(this);
}

@JsonSerializable()
class GroupScheduleConfigResponse {
  final bool success;
  final Map<String, dynamic> data;

  GroupScheduleConfigResponse({required this.success, required this.data});

  factory GroupScheduleConfigResponse.fromJson(Map<String, dynamic> json) =>
      _$GroupScheduleConfigResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GroupScheduleConfigResponseToJson(this);
}

@JsonSerializable()
class TimeSlotsResponse {
  final bool success;
  final List<Map<String, dynamic>> data;

  TimeSlotsResponse({required this.success, required this.data});

  factory TimeSlotsResponse.fromJson(Map<String, dynamic> json) =>
      _$TimeSlotsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TimeSlotsResponseToJson(this);
}
