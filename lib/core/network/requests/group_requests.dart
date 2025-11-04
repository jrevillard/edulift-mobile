// EduLift Mobile - Group Request Models
// Matches backend /api/groups/* endpoints

import 'package:equatable/equatable.dart';

/// Group creation request model
class CreateGroupRequest extends Equatable {
  final String name;
  final String? description;
  final Map<String, dynamic>? settings;
  final int? maxMembers;
  final Map<String, dynamic>? scheduleConfig;

  const CreateGroupRequest({
    required this.name,
    this.description,
    this.settings,
    this.maxMembers,
    this.scheduleConfig,
  });

  factory CreateGroupRequest.fromJson(Map<String, dynamic> json) {
    return CreateGroupRequest(
      name: json['name'],
      description: json['description'],
      settings: json['settings'],
      maxMembers: json['maxMembers'],
      scheduleConfig: json['scheduleConfig'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    if (description != null) 'description': description,
    if (settings != null) 'settings': settings,
    if (maxMembers != null) 'maxMembers': maxMembers,
    if (scheduleConfig != null) 'scheduleConfig': scheduleConfig,
  };

  @override
  List<Object?> get props => [
    name,
    description,
    settings,
    maxMembers,
    scheduleConfig,
  ];
}

/// Group update request model
/// Backend only supports updating name and description
class UpdateGroupRequest extends Equatable {
  final String? name;
  final String? description;

  const UpdateGroupRequest({this.name, this.description});

  factory UpdateGroupRequest.fromJson(Map<String, dynamic> json) {
    return UpdateGroupRequest(
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (description != null) 'description': description,
  };

  @override
  List<Object?> get props => [name, description];
}

/// Group invitation creation request model
/// COMPLETE VERSION with groupId (required by group_api_client.dart)
class CreateGroupInvitationRequest extends Equatable {
  final String groupId;
  final String email;
  final String? role;
  final String? message;

  const CreateGroupInvitationRequest({
    required this.groupId,
    required this.email,
    this.role,
    this.message,
  });

  factory CreateGroupInvitationRequest.fromJson(Map<String, dynamic> json) {
    return CreateGroupInvitationRequest(
      groupId: json['group_id'] ?? json['groupId'],
      email: json['email'],
      role: json['role'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() => {
    'group_id': groupId,
    'email': email,
    if (role != null) 'role': role,
    if (message != null) 'message': message,
  };

  @override
  List<Object?> get props => [groupId, email, role, message];
}

/// Join group request model
class JoinGroupRequest extends Equatable {
  final String code;

  const JoinGroupRequest({required this.code});

  factory JoinGroupRequest.fromJson(Map<String, dynamic> json) {
    return JoinGroupRequest(code: json['code']);
  }

  Map<String, dynamic> toJson() => {'inviteCode': code};

  @override
  List<Object?> get props => [code];
}

/// Update group family role request model
class UpdateGroupFamilyRoleRequest extends Equatable {
  final String role;

  const UpdateGroupFamilyRoleRequest({required this.role});

  factory UpdateGroupFamilyRoleRequest.fromJson(Map<String, dynamic> json) {
    return UpdateGroupFamilyRoleRequest(role: json['role']);
  }

  Map<String, dynamic> toJson() => {'role': role};

  @override
  List<Object?> get props => [role];
}

/// Search families request model
class SearchFamiliesRequest extends Equatable {
  final String? query;
  final int? limit;

  const SearchFamiliesRequest({this.query, this.limit});

  factory SearchFamiliesRequest.fromJson(Map<String, dynamic> json) {
    return SearchFamiliesRequest(query: json['query'], limit: json['limit']);
  }

  Map<String, dynamic> toJson() => {
    if (query != null) 'searchTerm': query, // Backend expects 'searchTerm'
    if (limit != null) 'limit': limit,
  };

  @override
  List<Object?> get props => [query, limit];
}

/// Invite group family request model
class InviteGroupFamilyRequest extends Equatable {
  final String familyId;
  final String? message;

  const InviteGroupFamilyRequest({required this.familyId, this.message});

  factory InviteGroupFamilyRequest.fromJson(Map<String, dynamic> json) {
    return InviteGroupFamilyRequest(
      familyId: json['familyId'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() => {
    'familyId': familyId,
    if (message != null) 'message': message,
  };

  @override
  List<Object?> get props => [familyId, message];
}

/// Update family role in group request model (used by group_api_client.dart)
class UpdateFamilyRoleRequest extends Equatable {
  final String role;

  const UpdateFamilyRoleRequest({required this.role});

  factory UpdateFamilyRoleRequest.fromJson(Map<String, dynamic> json) {
    return UpdateFamilyRoleRequest(role: json['role']);
  }

  Map<String, dynamic> toJson() => {'role': role};

  @override
  List<Object?> get props => [role];
}

/// Invite family to group request (for group_api_client InviteFamilyToGroupRequest compatibility)
class InviteFamilyToGroupRequest extends Equatable {
  final String familyId;
  final String? role;
  final String? message;

  const InviteFamilyToGroupRequest({
    required this.familyId,
    this.role,
    this.message,
  });

  factory InviteFamilyToGroupRequest.fromJson(Map<String, dynamic> json) {
    return InviteFamilyToGroupRequest(
      familyId: json['family_id'] ?? json['familyId'],
      role: json['role'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() => {
    'familyId': familyId, // Backend expects camelCase
    if (role != null) 'role': role,
    if (message != null)
      'personalMessage': message, // Backend expects 'personalMessage'
  };

  @override
  List<Object?> get props => [familyId, role, message];
}

/// Update schedule configuration request
/// Backend expects: {scheduleHours: {...}} directly, NOT wrapped in {config: {...}}
class UpdateScheduleConfigRequest extends Equatable {
  final Map<String, dynamic> scheduleHours;

  const UpdateScheduleConfigRequest({required this.scheduleHours});

  factory UpdateScheduleConfigRequest.fromJson(Map<String, dynamic> json) {
    return UpdateScheduleConfigRequest(
      scheduleHours: json['scheduleHours'] ?? json,
    );
  }

  /// Send scheduleHours directly to match backend expectation:
  /// PUT /groups/:groupId/schedule-config expects: {scheduleHours: {MONDAY: [...], ...}}
  Map<String, dynamic> toJson() => {'scheduleHours': scheduleHours};

  @override
  List<Object?> get props => [scheduleHours];
}
