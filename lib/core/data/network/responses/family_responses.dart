// EduLift Mobile - Family Response Models
// Matches backend /api/family/* endpoints

/// Family data response model
class FamilyResponse {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<FamilyMemberResponse>? members;
  final List<ChildResponse>? children;
  final List<VehicleResponse>? vehicles;

  const FamilyResponse({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.members,
    this.children,
    this.vehicles,
  });

  factory FamilyResponse.fromJson(Map<String, dynamic> json) {
    return FamilyResponse(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      members: (json['members'] as List<dynamic>?)
          ?.map(
            (item) =>
                FamilyMemberResponse.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      children: (json['children'] as List<dynamic>?)
          ?.map((item) => ChildResponse.fromJson(item as Map<String, dynamic>))
          .toList(),
      vehicles: (json['vehicles'] as List<dynamic>?)
          ?.map(
            (item) => VehicleResponse.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

/// Family member response model
class FamilyMemberResponse {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String role;
  final Map<String, dynamic> permissions;
  final DateTime joinedAt;

  const FamilyMemberResponse({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.permissions,
    required this.joinedAt,
  });

  factory FamilyMemberResponse.fromJson(Map<String, dynamic> json) {
    return FamilyMemberResponse(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      permissions: json['permissions'] as Map<String, dynamic>,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }
}

/// Child response model
class ChildResponse {
  final String id;
  final String name;
  final String familyId;
  final int? age;
  final String? school;
  final String? grade;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChildResponse({
    required this.id,
    required this.name,
    required this.familyId,
    this.age,
    this.school,
    this.grade,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChildResponse.fromJson(Map<String, dynamic> json) {
    return ChildResponse(
      id: json['id'] as String,
      name: json['name'] as String,
      familyId: json['familyId'] as String,
      age: json['age'] as int?,
      school: json['school'] as String?,
      grade: json['grade'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// Vehicle response model
class VehicleResponse {
  final String id;
  final String name;
  final String familyId;
  final int? capacity;
  final String? description;
  final String? color;
  final String? licensePlate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VehicleResponse({
    required this.id,
    required this.name,
    required this.familyId,
    this.capacity,
    this.description,
    this.color,
    this.licensePlate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VehicleResponse.fromJson(Map<String, dynamic> json) {
    return VehicleResponse(
      id: json['id'] as String,
      name: json['name'] as String,
      familyId: json['familyId'] as String,
      capacity: json['capacity'] as int?,
      description: json['description'] as String?,
      color: json['color'] as String?,
      licensePlate: json['licensePlate'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// Family invitation response model
class FamilyInvitationResponse {
  final String id;
  final String familyId;
  final String familyName;
  final String email;
  final String role;
  final String invitedBy;
  final String invitedByName;
  final String? personalMessage;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String status;

  const FamilyInvitationResponse({
    required this.id,
    required this.familyId,
    required this.familyName,
    required this.email,
    required this.role,
    required this.invitedBy,
    required this.invitedByName,
    this.personalMessage,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
  });

  factory FamilyInvitationResponse.fromJson(Map<String, dynamic> json) {
    return FamilyInvitationResponse(
      id: json['id'] as String,
      familyId: json['familyId'] as String,
      familyName: json['familyName'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      invitedBy: json['invitedBy'] as String,
      invitedByName: json['invitedByName'] as String,
      personalMessage: json['personalMessage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      status: json['status'] as String? ?? 'pending',
    );
  }
}

/// Family permissions response model
class FamilyPermissionsResponse {
  final bool canManageFamily;
  final bool canInviteMembers;
  final bool canManageChildren;
  final bool canManageVehicles;
  final String role;

  const FamilyPermissionsResponse({
    required this.canManageFamily,
    required this.canInviteMembers,
    required this.canManageChildren,
    required this.canManageVehicles,
    required this.role,
  });

  factory FamilyPermissionsResponse.fromJson(Map<String, dynamic> json) {
    return FamilyPermissionsResponse(
      canManageFamily: json['canManageFamily'] as bool,
      canInviteMembers: json['canInviteMembers'] as bool,
      canManageChildren: json['canManageChildren'] as bool,
      canManageVehicles: json['canManageVehicles'] as bool,
      role: json['role'] as String,
    );
  }
}
