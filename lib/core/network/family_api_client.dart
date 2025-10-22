import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'models/family/index.dart';
import 'models/common/index.dart';
import 'models/child/child_dto.dart';
import 'models/vehicle/vehicle_dto.dart';
import 'api_response_helper.dart';
import 'requests/family_requests.dart';

// Re-export request classes for backward compatibility with datasources
export 'requests/family_requests.dart';

part 'family_api_client.g.dart';

/// Family API Client - Private Retrofit methods only
/// All public methods implemented in FamilyApiClient wrapper
@RestApi()
abstract class _FamilyApiClientBase {
  factory _FamilyApiClientBase(Dio dio, {String? baseUrl}) =
      __FamilyApiClientBase;

  @GET('/invitations/family/{code}/validate')
  Future<FamilyInvitationValidationDto> validateInviteCode(
    @Path('code') String code,
  );

  @POST('/families')
  Future<FamilyDto> createFamily(@Body() CreateFamilyRequest request);

  @POST('/families/join')
  Future<FamilyDto> joinFamily(@Body() JoinFamilyRequest request);

  @GET('/families/current')
  Future<FamilyDto> getCurrentFamily();

  @GET('/families/{familyId}/permissions')
  Future<FamilyPermissionsDto> getUserPermissions(
    @Path('familyId') String familyId,
  );

  @PUT('/families/members/{memberId}/role')
  Future<void> updateMemberRole(
    @Path('memberId') String memberId,
    @Body() UpdateMemberRoleRequest request,
  );

  @POST('/families/invite-code')
  Future<InviteCodeResponseDto> generateInviteCode();

  @POST('/families/{familyId}/invite')
  Future<FamilyInvitationDto> inviteMember(
    @Path('familyId') String familyId,
    @Body() InviteMemberRequest request,
  );

  @GET('/families/{familyId}/invitations')
  Future<List<FamilyInvitationDto>> getPendingInvitations(
    @Path('familyId') String familyId,
  );

  @DELETE('/families/{familyId}/invitations/{invitationId}')
  Future<void> cancelInvitation(
    @Path('familyId') String familyId,
    @Path('invitationId') String invitationId,
  );

  @PUT('/families/name')
  Future<FamilyDto> updateFamilyName(@Body() UpdateFamilyNameRequest request);

  @DELETE('/families/{familyId}/members/{memberId}')
  Future<void> removeMember(
    @Path('familyId') String familyId,
    @Path('memberId') String memberId,
  );

  @POST('/families/{familyId}/leave')
  Future<void> leaveFamily(@Path('familyId') String familyId);

  @POST('/children')
  Future<ChildDto> createChild(@Body() CreateChildRequest request);

  @PUT('/children/{childId}')
  Future<ChildDto> updateChild(
    @Path('childId') String childId,
    @Body() UpdateChildRequest request,
  );

  @DELETE('/children/{childId}')
  Future<DeleteResponseDto> deleteChild(@Path('childId') String childId);

  @POST('/vehicles')
  Future<VehicleDto> createVehicle(@Body() CreateVehicleRequest request);

  @PATCH('/vehicles/{vehicleId}')
  Future<VehicleDto> updateVehicle(
    @Path('vehicleId') String vehicleId,
    @Body() UpdateVehicleRequest request,
  );

  @DELETE('/vehicles/{vehicleId}')
  Future<DeleteResponseDto> deleteVehicle(@Path('vehicleId') String vehicleId);

  @GET('/families/{familyId}/children')
  Future<List<ChildDto>> getFamilyChildren(@Path('familyId') String familyId);

  @GET('/families/{familyId}/vehicles')
  Future<List<VehicleDto>> getFamilyVehicles(@Path('familyId') String familyId);

  @GET('/families/{familyId}/members')
  Future<List<FamilyMemberDto>> getFamilyMembers(
    @Path('familyId') String familyId,
  );

  @POST('/families/invitations')
  Future<FamilyInvitationDto> createFamilyInvitation(
    @Body() CreateFamilyInvitationRequest request,
  );

  @POST('/families/{familyId}/invite')
  Future<FamilyInvitationDto> inviteFamilyMember(
    @Path('familyId') String familyId,
    @Body() InviteFamilyMemberRequest request,
  );

  @GET('/families/{familyId}/invitations')
  Future<List<FamilyInvitationDto>> getFamilyInvitations(
    @Path('familyId') String familyId,
  );

  @DELETE('/families/{familyId}/invitations/{invitationId}')
  Future<void> cancelFamilyInvitation(
    @Path('familyId') String familyId,
    @Path('invitationId') String invitationId,
  );

  @DELETE('/families/{familyId}/members/{memberId}')
  Future<void> removeFamilyMember(
    @Path('familyId') String familyId,
    @Path('memberId') String memberId,
  );
}

/// Public Family API Client with ApiResponse wrapper pattern
/// This is the class that should be used by data sources
class FamilyApiClient {
  final _FamilyApiClientBase _client;

  FamilyApiClient._(this._client);

  factory FamilyApiClient.create(Dio dio, {String? baseUrl}) {
    return FamilyApiClient._(_FamilyApiClientBase(dio, baseUrl: baseUrl));
  }

  /// Validate family invitation code (public route)
  /// GET /api/v1/invitations/family/:code/validate
  Future<ApiResponse<FamilyInvitationValidationDto>> validateInviteCode(
    String code,
  ) async {
    return ApiResponseHelper.execute(() => _client.validateInviteCode(code));
  }

  /// Create a new family
  /// POST /api/v1/families
  Future<ApiResponse<FamilyDto>> createFamily(
    CreateFamilyRequest request,
  ) async {
    return ApiResponseHelper.execute(() => _client.createFamily(request));
  }

  /// Join family using invitation code
  /// POST /api/v1/families/join
  Future<ApiResponse<FamilyDto>> joinFamily(JoinFamilyRequest request) async {
    return ApiResponseHelper.execute(() => _client.joinFamily(request));
  }

  /// Get current family information
  /// GET /api/v1/families/current
  Future<ApiResponse<FamilyDto>> getCurrentFamily() async {
    return ApiResponseHelper.execute(() => _client.getCurrentFamily());
  }

  /// Get user permissions for a family
  /// GET /api/v1/families/{familyId}/permissions
  Future<ApiResponse<FamilyPermissionsDto>> getUserPermissions(
    String familyId,
  ) async {
    return ApiResponseHelper.execute(
      () => _client.getUserPermissions(familyId),
    );
  }

  /// Update member role
  /// PUT /api/v1/families/members/{memberId}/role
  Future<ApiResponse<void>> updateMemberRole(
    String memberId,
    UpdateMemberRoleRequest request,
  ) async {
    return ApiResponseHelper.execute(
      () => _client.updateMemberRole(memberId, request),
    );
  }

  /// Generate new invite code for family
  /// POST /api/v1/families/invite-code
  Future<ApiResponse<InviteCodeResponseDto>> generateInviteCode() async {
    return ApiResponseHelper.execute(() => _client.generateInviteCode());
  }

  /// Invite a new member to family
  /// POST /api/v1/families/{familyId}/invite
  Future<ApiResponse<FamilyInvitationDto>> inviteMember(
    String familyId,
    InviteMemberRequest request,
  ) async {
    return ApiResponseHelper.execute(
      () => _client.inviteMember(familyId, request),
    );
  }

  /// Get pending invitations
  /// GET /api/v1/families/{familyId}/invitations
  Future<ApiResponse<List<FamilyInvitationDto>>> getPendingInvitations(
    String familyId,
  ) async {
    return ApiResponseHelper.execute(
      () => _client.getPendingInvitations(familyId),
    );
  }

  /// Cancel invitation
  /// DELETE /api/v1/families/{familyId}/invitations/{invitationId}
  Future<ApiResponse<void>> cancelInvitation(
    String familyId,
    String invitationId,
  ) async {
    return ApiResponseHelper.execute(
      () => _client.cancelInvitation(familyId, invitationId),
    );
  }

  /// Update family name
  /// PUT /api/v1/families/name
  Future<ApiResponse<FamilyDto>> updateFamilyName(
    UpdateFamilyNameRequest request,
  ) async {
    return ApiResponseHelper.execute(() => _client.updateFamilyName(request));
  }

  /// Remove family member
  /// DELETE /api/v1/families/{familyId}/members/{memberId}
  Future<ApiResponse<void>> removeMember(
    String familyId,
    String memberId,
  ) async {
    return ApiResponseHelper.execute(
      () => _client.removeMember(familyId, memberId),
    );
  }

  /// Leave family
  /// POST /api/v1/families/{familyId}/leave
  Future<ApiResponse<void>> leaveFamily(String familyId) async {
    return ApiResponseHelper.execute(() => _client.leaveFamily(familyId));
  }

  /// Create a child
  /// POST /api/v1/children
  Future<ApiResponse<ChildDto>> createChild(CreateChildRequest request) async {
    return ApiResponseHelper.execute(() => _client.createChild(request));
  }

  /// Update a child
  /// PUT /api/v1/children/{childId}
  Future<ApiResponse<ChildDto>> updateChild(
    String childId,
    UpdateChildRequest request,
  ) async {
    return ApiResponseHelper.execute(
      () => _client.updateChild(childId, request),
    );
  }

  /// Delete a child
  /// DELETE /api/v1/children/{childId}
  Future<ApiResponse<DeleteResponseDto>> deleteChild(String childId) async {
    return ApiResponseHelper.execute(() => _client.deleteChild(childId));
  }

  /// Create a vehicle
  /// POST /api/v1/vehicles
  Future<ApiResponse<VehicleDto>> createVehicle(
    CreateVehicleRequest request,
  ) async {
    return ApiResponseHelper.execute(() => _client.createVehicle(request));
  }

  /// Update a vehicle
  /// PATCH /api/v1/vehicles/{vehicleId}
  Future<ApiResponse<VehicleDto>> updateVehicle(
    String vehicleId,
    UpdateVehicleRequest request,
  ) async {
    return ApiResponseHelper.execute(
      () => _client.updateVehicle(vehicleId, request),
    );
  }

  /// Delete a vehicle
  /// DELETE /api/v1/vehicles/{vehicleId}
  Future<ApiResponse<DeleteResponseDto>> deleteVehicle(String vehicleId) async {
    return ApiResponseHelper.execute(() => _client.deleteVehicle(vehicleId));
  }

  /// Get children for family
  /// GET /api/v1/families/{familyId}/children
  Future<ApiResponse<List<ChildDto>>> getFamilyChildren(String familyId) async {
    return ApiResponseHelper.execute(() => _client.getFamilyChildren(familyId));
  }

  /// Get vehicles for family
  /// GET /api/v1/families/{familyId}/vehicles
  Future<ApiResponse<List<VehicleDto>>> getFamilyVehicles(
    String familyId,
  ) async {
    return ApiResponseHelper.execute(() => _client.getFamilyVehicles(familyId));
  }

  /// Get family members
  /// GET /api/v1/families/{familyId}/members
  Future<ApiResponse<List<FamilyMemberDto>>> getFamilyMembers(
    String familyId,
  ) async {
    return ApiResponseHelper.execute(() => _client.getFamilyMembers(familyId));
  }

  /// Create family invitation (for unified invitation service)
  /// POST /api/v1/families/invitations
  Future<ApiResponse<FamilyInvitationDto>> createFamilyInvitation(
    CreateFamilyInvitationRequest request,
  ) async {
    return ApiResponseHelper.execute(
      () => _client.createFamilyInvitation(request),
    );
  }

  /// Invite family member (for remote datasource)
  /// POST /api/v1/families/{familyId}/invite
  Future<ApiResponse<FamilyInvitationDto>> inviteFamilyMember(
    String familyId,
    InviteFamilyMemberRequest request,
  ) async {
    return ApiResponseHelper.execute(
      () => _client.inviteFamilyMember(familyId, request),
    );
  }

  /// Get family invitations (for remote datasource)
  /// GET /api/v1/families/{familyId}/invitations
  Future<ApiResponse<List<FamilyInvitationDto>>> getFamilyInvitations(
    String familyId,
  ) async {
    return ApiResponseHelper.execute(
      () => _client.getFamilyInvitations(familyId),
    );
  }

  /// Cancel family invitation (for remote datasource)
  /// DELETE /api/v1/families/{familyId}/invitations/{invitationId}
  Future<ApiResponse<void>> cancelFamilyInvitation(
    String familyId,
    String invitationId,
  ) async {
    return ApiResponseHelper.execute(
      () => _client.cancelFamilyInvitation(familyId, invitationId),
    );
  }

  /// Remove family member (for remote datasource)
  /// DELETE /api/v1/families/{familyId}/members/{memberId}
  Future<ApiResponse<void>> removeFamilyMember(
    String familyId,
    String memberId,
  ) async {
    return ApiResponseHelper.execute(
      () => _client.removeFamilyMember(familyId, memberId),
    );
  }
}
