// EduLift Mobile - Family Request Models
// Matches backend /api/family/* endpoints

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../models/family/family_invitation_dto.dart';

part 'family_requests.g.dart';

/// Family creation request model
class CreateFamilyRequest extends Equatable {
  final String name;

  const CreateFamilyRequest({required this.name});

  factory CreateFamilyRequest.fromJson(Map<String, dynamic> json) {
    return CreateFamilyRequest(name: json['name']);
  }

  Map<String, dynamic> toJson() => {'name': name};

  @override
  List<Object?> get props => [name];
}

/// Family update request model
class UpdateFamilyRequest extends Equatable {
  final String? name;

  const UpdateFamilyRequest({this.name});

  factory UpdateFamilyRequest.fromJson(Map<String, dynamic> json) {
    return UpdateFamilyRequest(name: json['name']);
  }

  Map<String, dynamic> toJson() => {if (name != null) 'name': name};

  @override
  List<Object?> get props => [name];
}

/// Join family request model
class JoinFamilyRequest extends Equatable {
  final String inviteCode;

  const JoinFamilyRequest({required this.inviteCode});

  factory JoinFamilyRequest.fromJson(Map<String, dynamic> json) {
    return JoinFamilyRequest(inviteCode: json['inviteCode']);
  }

  Map<String, dynamic> toJson() => {'inviteCode': inviteCode};

  @override
  List<Object?> get props => [inviteCode];
}

/// Child creation request model
class CreateChildRequest extends Equatable {
  final String name;
  final int? age;

  const CreateChildRequest({required this.name, this.age});

  factory CreateChildRequest.fromJson(Map<String, dynamic> json) {
    return CreateChildRequest(name: json['name'], age: json['age']);
  }

  Map<String, dynamic> toJson() => {'name': name, if (age != null) 'age': age};

  @override
  List<Object?> get props => [name, age];
}

/// Child update request model
class UpdateChildRequest extends Equatable {
  final String? name;
  final int? age;

  const UpdateChildRequest({this.name, this.age});

  factory UpdateChildRequest.fromJson(Map<String, dynamic> json) {
    return UpdateChildRequest(name: json['name'], age: json['age']);
  }

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (age != null) 'age': age,
  };

  @override
  List<Object?> get props => [name, age];
}

/// Vehicle creation request model
class CreateVehicleRequest extends Equatable {
  final String name;
  final int capacity;
  final String? description;

  const CreateVehicleRequest({
    required this.name,
    required this.capacity,
    this.description,
  });

  factory CreateVehicleRequest.fromJson(Map<String, dynamic> json) {
    return CreateVehicleRequest(
      name: json['name'],
      capacity: json['capacity'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'capacity': capacity,
    if (description != null) 'description': description,
  };

  @override
  List<Object?> get props => [name, capacity, description];
}

/// Vehicle update request model
class UpdateVehicleRequest extends Equatable {
  final String? name;
  final int? capacity;
  final String? description;

  const UpdateVehicleRequest({this.name, this.capacity, this.description});

  factory UpdateVehicleRequest.fromJson(Map<String, dynamic> json) {
    return UpdateVehicleRequest(
      name: json['name'],
      capacity: json['capacity'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (capacity != null) 'capacity': capacity,
    if (description != null) 'description': description,
  };

  @override
  List<Object?> get props => [name, capacity, description];
}

/// Family invitation creation request model
class CreateFamilyInvitationRequest extends Equatable {
  final String email;
  final String? message;
  final String platform;

  const CreateFamilyInvitationRequest({
    required this.email,
    this.message,
    this.platform = 'native', // Default to 'native' for Flutter apps
  });

  factory CreateFamilyInvitationRequest.fromJson(Map<String, dynamic> json) {
    return CreateFamilyInvitationRequest(
      email: json['email'],
      message: json['message'],
      platform: json['platform'] ?? 'native',
    );
  }

  /// Create simple invitation request
  /// Simplified approach - backend handles all security validation
  factory CreateFamilyInvitationRequest.simple({
    required String email,
    String? message,
    String platform = 'native',
  }) {
    return CreateFamilyInvitationRequest(
      email: email.toLowerCase().trim(),
      message: message?.trim(),
      platform: platform,
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    if (message != null) 'message': message,
    'platform': platform,
  };

  @override
  List<Object?> get props => [email, message, platform];
}

/// Update family name request model
class UpdateFamilyNameRequest extends Equatable {
  final String name;

  const UpdateFamilyNameRequest({required this.name});

  factory UpdateFamilyNameRequest.fromJson(Map<String, dynamic> json) {
    return UpdateFamilyNameRequest(name: json['name']);
  }

  Map<String, dynamic> toJson() => {'name': name};

  @override
  List<Object?> get props => [name];
}

/// Update member role request model
class UpdateMemberRoleRequest extends Equatable {
  final String role;

  const UpdateMemberRoleRequest({required this.role});

  factory UpdateMemberRoleRequest.fromJson(Map<String, dynamic> json) {
    return UpdateMemberRoleRequest(role: json['role']);
  }

  Map<String, dynamic> toJson() => {'role': role};

  @override
  List<Object?> get props => [role];
}

/// Invite family member request model
@JsonSerializable()
class InviteFamilyMemberRequest extends Equatable {
  final String email;
  final String role;

  @JsonKey(name: 'personalMessage')
  final String? message;

  final String platform;

  const InviteFamilyMemberRequest({
    required this.email,
    required this.role,
    this.message,
    this.platform = 'native', // Default to 'native' for Flutter apps
  });

  factory InviteFamilyMemberRequest.fromJson(Map<String, dynamic> json) =>
      _$InviteFamilyMemberRequestFromJson(json);

  Map<String, dynamic> toJson() => _$InviteFamilyMemberRequestToJson(this);

  @override
  List<Object?> get props => [email, role, message, platform];
}

/// Invite member request model (legacy compatibility)
@JsonSerializable(includeIfNull: false)
class InviteMemberRequest {
  final String email;
  final String? role;

  InviteMemberRequest({required this.email, this.role});

  factory InviteMemberRequest.fromJson(Map<String, dynamic> json) =>
      _$InviteMemberRequestFromJson(json);
  Map<String, dynamic> toJson() => _$InviteMemberRequestToJson(this);
}

/// Validate invite request model
@JsonSerializable(includeIfNull: false)
class ValidateInviteRequest {
  final String inviteCode;

  ValidateInviteRequest({required this.inviteCode});

  factory ValidateInviteRequest.fromJson(Map<String, dynamic> json) =>
      _$ValidateInviteRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ValidateInviteRequestToJson(this);
}

/// Delete response DTO
@JsonSerializable(includeIfNull: false)
class DeleteResponseDto {
  final bool success;
  final String? message;

  DeleteResponseDto({required this.success, this.message});

  factory DeleteResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DeleteResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$DeleteResponseDtoToJson(this);
}

/// Invitation list response DTO
@JsonSerializable(includeIfNull: false)
class InvitationListResponseDto {
  final List<FamilyInvitationDto> invitations;
  final int totalCount;

  InvitationListResponseDto({
    required this.invitations,
    required this.totalCount,
  });

  factory InvitationListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$InvitationListResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$InvitationListResponseDtoToJson(this);
}
