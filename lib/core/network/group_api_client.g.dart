// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_api_client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseResponse _$BaseResponseFromJson(Map<String, dynamic> json) => BaseResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$BaseResponseToJson(BaseResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      if (instance.message case final value?) 'message': value,
    };

GroupData _$GroupDataFromJson(Map<String, dynamic> json) => GroupData(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      familyId: json['familyId'] as String,
      inviteCode: json['invite_code'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      userRole: json['userRole'] as String?,
      joinedAt: json['joinedAt'] as String?,
      ownerFamily: json['ownerFamily'] as Map<String, dynamic>?,
      familyCount: (json['familyCount'] as num?)?.toInt(),
      scheduleCount: (json['scheduleCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$GroupDataToJson(GroupData instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      if (instance.description case final value?) 'description': value,
      'familyId': instance.familyId,
      if (instance.inviteCode case final value?) 'invite_code': value,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      if (instance.userRole case final value?) 'userRole': value,
      if (instance.joinedAt case final value?) 'joinedAt': value,
      if (instance.ownerFamily case final value?) 'ownerFamily': value,
      if (instance.familyCount case final value?) 'familyCount': value,
      if (instance.scheduleCount case final value?) 'scheduleCount': value,
    };

GroupResponse _$GroupResponseFromJson(Map<String, dynamic> json) =>
    GroupResponse(
      success: json['success'] as bool,
      data: GroupData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GroupResponseToJson(GroupResponse instance) =>
    <String, dynamic>{'success': instance.success, 'data': instance.data};

GroupListResponse _$GroupListResponseFromJson(Map<String, dynamic> json) =>
    GroupListResponse(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>)
          .map((e) => GroupData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GroupListResponseToJson(GroupListResponse instance) =>
    <String, dynamic>{'success': instance.success, 'data': instance.data};

GroupInvitationValidationResponse _$GroupInvitationValidationResponseFromJson(
  Map<String, dynamic> json,
) =>
    GroupInvitationValidationResponse(
      success: json['success'] as bool,
      data: GroupInvitationValidationData.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$GroupInvitationValidationResponseToJson(
  GroupInvitationValidationResponse instance,
) =>
    <String, dynamic>{'success': instance.success, 'data': instance.data};

GroupInvitationValidationData _$GroupInvitationValidationDataFromJson(
  Map<String, dynamic> json,
) =>
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

Map<String, dynamic> _$GroupInvitationValidationDataToJson(
  GroupInvitationValidationData instance,
) =>
    <String, dynamic>{
      'valid': instance.valid,
      'groupId': instance.groupId,
      'groupName': instance.groupName,
      'inviterName': instance.inviterName,
      'requiresAuth': instance.requiresAuth,
      'error': instance.error,
      'errorCode': instance.errorCode,
      'email': instance.email,
      'existingUser': instance.existingUser,
    };

GroupFamiliesResponse _$GroupFamiliesResponseFromJson(
  Map<String, dynamic> json,
) =>
    GroupFamiliesResponse(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>)
          .map((e) => GroupFamilyData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GroupFamiliesResponseToJson(
  GroupFamiliesResponse instance,
) =>
    <String, dynamic>{'success': instance.success, 'data': instance.data};

FamilyAdminData _$FamilyAdminDataFromJson(Map<String, dynamic> json) =>
    FamilyAdminData(
      name: json['name'] as String,
      email: json['email'] as String,
    );

Map<String, dynamic> _$FamilyAdminDataToJson(FamilyAdminData instance) =>
    <String, dynamic>{'name': instance.name, 'email': instance.email};

GroupFamilyData _$GroupFamilyDataFromJson(Map<String, dynamic> json) =>
    GroupFamilyData(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      isMyFamily: json['isMyFamily'] as bool,
      canManage: json['canManage'] as bool,
      admins: (json['admins'] as List<dynamic>)
          .map((e) => FamilyAdminData.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String?,
      inviteCode: json['inviteCode'] as String?,
      invitationId: json['invitationId'] as String?,
      invitedAt: json['invitedAt'] as String?,
      expiresAt: json['expiresAt'] as String?,
    );

Map<String, dynamic> _$GroupFamilyDataToJson(GroupFamilyData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'role': instance.role,
      'isMyFamily': instance.isMyFamily,
      'canManage': instance.canManage,
      'admins': instance.admins,
      'status': instance.status,
      'inviteCode': instance.inviteCode,
      'invitationId': instance.invitationId,
      'invitedAt': instance.invitedAt,
      'expiresAt': instance.expiresAt,
    };

GroupFamilyResponse _$GroupFamilyResponseFromJson(Map<String, dynamic> json) =>
    GroupFamilyResponse(
      success: json['success'] as bool,
      data: GroupFamilyData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GroupFamilyResponseToJson(
  GroupFamilyResponse instance,
) =>
    <String, dynamic>{'success': instance.success, 'data': instance.data};

SearchFamiliesResponse _$SearchFamiliesResponseFromJson(
  Map<String, dynamic> json,
) =>
    SearchFamiliesResponse(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>)
          .map((e) => FamilySearchResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SearchFamiliesResponseToJson(
  SearchFamiliesResponse instance,
) =>
    <String, dynamic>{'success': instance.success, 'data': instance.data};

AdminContact _$AdminContactFromJson(Map<String, dynamic> json) =>
    AdminContact(name: json['name'] as String, email: json['email'] as String);

Map<String, dynamic> _$AdminContactToJson(AdminContact instance) =>
    <String, dynamic>{'name': instance.name, 'email': instance.email};

FamilySearchResult _$FamilySearchResultFromJson(Map<String, dynamic> json) =>
    FamilySearchResult(
      id: json['id'] as String,
      name: json['name'] as String,
      adminContacts: (json['adminContacts'] as List<dynamic>)
          .map((e) => AdminContact.fromJson(e as Map<String, dynamic>))
          .toList(),
      memberCount: (json['memberCount'] as num).toInt(),
      canInvite: json['canInvite'] as bool,
    );

Map<String, dynamic> _$FamilySearchResultToJson(FamilySearchResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'adminContacts': instance.adminContacts.map((e) => e.toJson()).toList(),
      'memberCount': instance.memberCount,
      'canInvite': instance.canInvite,
    };

GroupInvitationResponse _$GroupInvitationResponseFromJson(
  Map<String, dynamic> json,
) =>
    GroupInvitationResponse(
      success: json['success'] as bool,
      data: GroupInvitationData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GroupInvitationResponseToJson(
  GroupInvitationResponse instance,
) =>
    <String, dynamic>{'success': instance.success, 'data': instance.data};

GroupInvitationData _$GroupInvitationDataFromJson(Map<String, dynamic> json) =>
    GroupInvitationData(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      targetFamilyId: json['targetFamilyId'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String,
      personalMessage: json['personalMessage'] as String?,
      invitedBy: json['invitedBy'] as String,
      createdBy: json['createdBy'] as String,
      acceptedBy: json['acceptedBy'] as String?,
      status: json['status'] as String,
      inviteCode: json['inviteCode'] as String,
      expiresAt: json['expiresAt'] as String,
      acceptedAt: json['acceptedAt'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$GroupInvitationDataToJson(
  GroupInvitationData instance,
) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'targetFamilyId': instance.targetFamilyId,
      'email': instance.email,
      'role': instance.role,
      'personalMessage': instance.personalMessage,
      'invitedBy': instance.invitedBy,
      'createdBy': instance.createdBy,
      'acceptedBy': instance.acceptedBy,
      'status': instance.status,
      'inviteCode': instance.inviteCode,
      'expiresAt': instance.expiresAt,
      'acceptedAt': instance.acceptedAt,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

InvitationListResponse _$InvitationListResponseFromJson(
  Map<String, dynamic> json,
) =>
    InvitationListResponse(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>)
          .map((e) => GroupInvitationData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$InvitationListResponseToJson(
  InvitationListResponse instance,
) =>
    <String, dynamic>{'success': instance.success, 'data': instance.data};

DefaultScheduleHoursResponse _$DefaultScheduleHoursResponseFromJson(
  Map<String, dynamic> json,
) =>
    DefaultScheduleHoursResponse(
      success: json['success'] as bool,
      data: json['data'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$DefaultScheduleHoursResponseToJson(
  DefaultScheduleHoursResponse instance,
) =>
    <String, dynamic>{'success': instance.success, 'data': instance.data};

GroupScheduleConfigResponse _$GroupScheduleConfigResponseFromJson(
  Map<String, dynamic> json,
) =>
    GroupScheduleConfigResponse(
      success: json['success'] as bool,
      data: json['data'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$GroupScheduleConfigResponseToJson(
  GroupScheduleConfigResponse instance,
) =>
    <String, dynamic>{'success': instance.success, 'data': instance.data};

TimeSlotsResponse _$TimeSlotsResponseFromJson(Map<String, dynamic> json) =>
    TimeSlotsResponse(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$TimeSlotsResponseToJson(TimeSlotsResponse instance) =>
    <String, dynamic>{'success': instance.success, 'data': instance.data};

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter

class _GroupApiClient implements GroupApiClient {
  _GroupApiClient(this._dio, {this.baseUrl, this.errorLogger});

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<GroupInvitationValidationData> validateInviteCode(String code) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<GroupInvitationValidationData>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/invitations/group/${code}/validate',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late GroupInvitationValidationData _value;
    try {
      _value = GroupInvitationValidationData.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<GroupData> createGroup(CreateGroupRequest request) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _options = _setStreamType<GroupData>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/groups',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late GroupData _value;
    try {
      _value = GroupData.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<GroupData> joinGroup(JoinGroupRequest request) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _options = _setStreamType<GroupData>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/groups/join',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late GroupData _value;
    try {
      _value = GroupData.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<List<GroupData>> getUserGroups() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<List<GroupData>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/groups/my-groups',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<List<dynamic>>(_options);
    late List<GroupData> _value;
    try {
      _value = _result.data!
          .map((dynamic i) => GroupData.fromJson(i as Map<String, dynamic>))
          .toList();
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<List<GroupFamilyData>> getFamilies(String groupId) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<List<GroupFamilyData>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/groups/${groupId}/families',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<List<dynamic>>(_options);
    late List<GroupFamilyData> _value;
    try {
      _value = _result.data!
          .map(
            (dynamic i) => GroupFamilyData.fromJson(i as Map<String, dynamic>),
          )
          .toList();
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<void> leaveGroup(String groupId) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<void>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/groups/${groupId}/leave',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    await _dio.fetch<void>(_options);
  }

  @override
  Future<GroupFamilyData> updateFamilyRole(
    String groupId,
    String familyId,
    UpdateFamilyRoleRequest request,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _options = _setStreamType<GroupFamilyData>(
      Options(method: 'PATCH', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/groups/${groupId}/families/${familyId}/role',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late GroupFamilyData _value;
    try {
      _value = GroupFamilyData.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<void> removeFamilyFromGroup(String groupId, String familyId) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<void>(
      Options(method: 'DELETE', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/groups/${groupId}/families/${familyId}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    await _dio.fetch<void>(_options);
  }

  @override
  Future<GroupData> updateGroup(
    String groupId,
    UpdateGroupRequest request,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _options = _setStreamType<GroupData>(
      Options(method: 'PATCH', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/groups/${groupId}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late GroupData _value;
    try {
      _value = GroupData.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<void>(
      Options(method: 'DELETE', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/groups/${groupId}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    await _dio.fetch<void>(_options);
  }

  @override
  Future<List<FamilySearchResult>> searchFamilies(
    String groupId,
    SearchFamiliesRequest request,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _options = _setStreamType<List<FamilySearchResult>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/groups/${groupId}/search-families',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<List<dynamic>>(_options);
    late List<FamilySearchResult> _value;
    try {
      _value = _result.data!
          .map(
            (dynamic i) =>
                FamilySearchResult.fromJson(i as Map<String, dynamic>),
          )
          .toList();
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<GroupInvitationData> inviteFamilyToGroup(
    String groupId,
    InviteFamilyToGroupRequest request,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _options = _setStreamType<GroupInvitationData>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/groups/${groupId}/invite',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late GroupInvitationData _value;
    try {
      _value = GroupInvitationData.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<List<GroupInvitationData>> getPendingInvitations(
    String groupId,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<List<GroupInvitationData>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/groups/${groupId}/invitations',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<List<dynamic>>(_options);
    late List<GroupInvitationData> _value;
    try {
      _value = _result.data!
          .map(
            (dynamic i) =>
                GroupInvitationData.fromJson(i as Map<String, dynamic>),
          )
          .toList();
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<void> cancelInvitation(String groupId, String invitationId) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<void>(
      Options(method: 'DELETE', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/groups/${groupId}/invitations/${invitationId}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    await _dio.fetch<void>(_options);
  }

  @override
  Future<ScheduleConfigDto> getDefaultScheduleHours() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ScheduleConfigDto>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/groups/schedule-config/default',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ScheduleConfigDto _value;
    try {
      _value = ScheduleConfigDto.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<void> initializeDefaultConfigs() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<void>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/groups/schedule-config/initialize',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    await _dio.fetch<void>(_options);
  }

  @override
  Future<ScheduleConfigDto> getGroupScheduleConfig(String groupId) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ScheduleConfigDto>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/groups/${groupId}/schedule-config',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ScheduleConfigDto _value;
    try {
      _value = ScheduleConfigDto.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<List<TimeSlotConfigDto>> getGroupTimeSlots(String groupId) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<List<TimeSlotConfigDto>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/groups/${groupId}/schedule-config/time-slots',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<List<dynamic>>(_options);
    late List<TimeSlotConfigDto> _value;
    try {
      _value = _result.data!
          .map(
            (dynamic i) =>
                TimeSlotConfigDto.fromJson(i as Map<String, dynamic>),
          )
          .toList();
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ScheduleConfigDto> updateGroupScheduleConfig(
    String groupId,
    UpdateScheduleConfigRequest request,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _options = _setStreamType<ScheduleConfigDto>(
      Options(method: 'PUT', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/groups/${groupId}/schedule-config',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ScheduleConfigDto _value;
    try {
      _value = ScheduleConfigDto.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<void> resetGroupScheduleConfig(String groupId) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<void>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/groups/${groupId}/schedule-config/reset',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    await _dio.fetch<void>(_options);
  }

  @override
  Future<List<GroupData>> getMyGroups() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<List<GroupData>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/groups/my-groups',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<List<dynamic>>(_options);
    late List<GroupData> _value;
    try {
      _value = _result.data!
          .map((dynamic i) => GroupData.fromJson(i as Map<String, dynamic>))
          .toList();
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<GroupData> getGroup(String groupId) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<GroupData>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/groups/${groupId}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late GroupData _value;
    try {
      _value = GroupData.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<AcceptInvitationResponse> acceptGroupInvitationByCode(
    String inviteCode,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<AcceptInvitationResponse>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/invitations/group/${inviteCode}/accept',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late AcceptInvitationResponse _value;
    try {
      _value = AcceptInvitationResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<GroupInvitationData> createGroupInvitation(
    CreateGroupInvitationRequest request,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _options = _setStreamType<GroupInvitationData>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/groups/invitations',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late GroupInvitationData _value;
    try {
      _value = GroupInvitationData.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}
