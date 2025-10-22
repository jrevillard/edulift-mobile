import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'models/child/index.dart';
import 'requests/children_requests.dart';

part 'children_api_client.g.dart';

/// Children API Client - Returns DTOs only (Clean Architecture compliant)
/// Backend routes: /api/v1/children/{CRUD operations, assignments, group membership}
@RestApi()
abstract class ChildrenApiClient {
  factory ChildrenApiClient.create(Dio dio, {String? baseUrl}) =
      _ChildrenApiClient;

  /// Create child
  /// POST /api/v1/children
  @POST('/children')
  Future<ChildDto> createChild(@Body() CreateChildInlineRequest request);

  /// Get user's children
  /// GET /api/v1/children
  @GET('/children')
  Future<ChildrenListDto> getChildren();

  /// Get specific child
  /// GET /api/v1/children/{childId}
  @GET('/children/{childId}')
  Future<ChildDto> getChild(@Path('childId') String childId);

  /// Update child - supports both PUT and PATCH
  /// PUT /api/v1/children/{childId}
  @PUT('/children/{childId}')
  Future<ChildDto> updateChild(
    @Path('childId') String childId,
    @Body() UpdateChildInlineRequest request,
  );

  /// Delete child
  /// DELETE /api/v1/children/{childId}
  @DELETE('/children/{childId}')
  Future<void> deleteChild(@Path('childId') String childId);

  /// Get child's trip assignments
  /// GET /api/v1/children/{childId}/assignments
  @GET('/children/{childId}/assignments')
  Future<ChildAssignmentsDto> getChildAssignments(
    @Path('childId') String childId,
    @Query('week') String? week,
  );

  /// Add child to group
  /// POST /api/v1/children/{childId}/groups/{groupId}
  @POST('/children/{childId}/groups/{groupId}')
  Future<void> addChildToGroup(
    @Path('childId') String childId,
    @Path('groupId') String groupId,
  );

  /// Remove child from group
  /// DELETE /api/v1/children/{childId}/groups/{groupId}
  @DELETE('/children/{childId}/groups/{groupId}')
  Future<void> removeChildFromGroup(
    @Path('childId') String childId,
    @Path('groupId') String groupId,
  );

  /// Get child group memberships
  /// GET /api/v1/children/{childId}/groups
  @GET('/children/{childId}/groups')
  Future<ChildGroupMembershipsDto> getChildGroupMemberships(
    @Path('childId') String childId,
  );
}
