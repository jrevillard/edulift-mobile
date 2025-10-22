// EduLift Mobile - Group Response Models
// Matches backend /api/groups/* endpoints

/// Group response model
class GroupResponse {
  final String id;
  final String name;
  final String? description;
  final String familyId;
  final List<GroupMemberResponse>? members;
  final Map<String, dynamic>? settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GroupResponse({
    required this.id,
    required this.name,
    this.description,
    required this.familyId,
    this.members,
    this.settings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroupResponse.fromJson(Map<String, dynamic> json) {
    return GroupResponse(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      familyId: json['familyId'] as String,
      members: (json['members'] as List<dynamic>?)
          ?.map(
            (item) =>
                GroupMemberResponse.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      settings: json['settings'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// Group member response model
class GroupMemberResponse {
  final String id;
  final String groupId;
  final String childId;
  final String childName;
  final DateTime addedAt;
  final String addedBy;
  final bool isActive;
  final String? role;

  const GroupMemberResponse({
    required this.id,
    required this.groupId,
    required this.childId,
    required this.childName,
    required this.addedAt,
    required this.addedBy,
    required this.isActive,
    this.role,
  });

  factory GroupMemberResponse.fromJson(Map<String, dynamic> json) {
    return GroupMemberResponse(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      childId: json['childId'] as String,
      childName: json['childName'] as String,
      addedAt: DateTime.parse(json['addedAt'] as String),
      addedBy: json['addedBy'] as String,
      isActive: json['isActive'] as bool? ?? true,
      role: json['role'] as String?,
    );
  }
}

/// Group invitation response model
class GroupInvitationResponse {
  final String id;
  final String groupId;
  final String groupName;
  final String email;
  final String? role;
  final String invitedBy;
  final String invitedByName;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String status;

  const GroupInvitationResponse({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.email,
    this.role,
    required this.invitedBy,
    required this.invitedByName,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
  });

  factory GroupInvitationResponse.fromJson(Map<String, dynamic> json) {
    return GroupInvitationResponse(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      groupName: json['groupName'] as String,
      email: json['email'] as String,
      role: json['role'] as String?,
      invitedBy: json['invitedBy'] as String,
      invitedByName: json['invitedByName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      status: json['status'] as String? ?? 'pending',
    );
  }
}
