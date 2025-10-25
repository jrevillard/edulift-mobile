// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_invitation_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InvitedByUser _$InvitedByUserFromJson(Map<String, dynamic> json) =>
    _InvitedByUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );

Map<String, dynamic> _$InvitedByUserToJson(_InvitedByUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
    };

_FamilyInvitationDto _$FamilyInvitationDtoFromJson(Map<String, dynamic> json) =>
    _FamilyInvitationDto(
      id: json['id'] as String,
      familyId: json['familyId'] as String,
      email: json['email'] as String?,
      role: json['role'] as String,
      personalMessage: json['personalMessage'] as String?,
      invitedBy: json['invitedBy'] as String,
      createdBy: json['createdBy'] as String,
      acceptedBy: json['acceptedBy'] as String?,
      status: json['status'] as String,
      inviteCode: json['inviteCode'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      acceptedAt: json['acceptedAt'] == null
          ? null
          : DateTime.parse(json['acceptedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      invitedByUser: InvitedByUser.fromJson(
        json['invitedByUser'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$FamilyInvitationDtoToJson(
  _FamilyInvitationDto instance,
) =>
    <String, dynamic>{
      'id': instance.id,
      'familyId': instance.familyId,
      'email': instance.email,
      'role': instance.role,
      'personalMessage': instance.personalMessage,
      'invitedBy': instance.invitedBy,
      'createdBy': instance.createdBy,
      'acceptedBy': instance.acceptedBy,
      'status': instance.status,
      'inviteCode': instance.inviteCode,
      'expiresAt': instance.expiresAt.toIso8601String(),
      'acceptedAt': instance.acceptedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'invitedByUser': instance.invitedByUser,
    };
