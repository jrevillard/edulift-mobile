// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_invitation_validation_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FamilyInvitationValidationDto _$FamilyInvitationValidationDtoFromJson(
  Map<String, dynamic> json,
) =>
    _FamilyInvitationValidationDto(
      valid: json['valid'] as bool,
      familyId: json['familyId'] as String?,
      familyName: json['familyName'] as String?,
      inviterName: json['inviterName'] as String?,
      role: json['role'] as String?,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      error: json['error'] as String?,
      errorCode: json['errorCode'] as String?,
      requiresAuth: json['requiresAuth'] as bool?,
      alreadyMember: json['alreadyMember'] as bool?,
    );

Map<String, dynamic> _$FamilyInvitationValidationDtoToJson(
  _FamilyInvitationValidationDto instance,
) =>
    <String, dynamic>{
      'valid': instance.valid,
      'familyId': instance.familyId,
      'familyName': instance.familyName,
      'inviterName': instance.inviterName,
      'role': instance.role,
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'error': instance.error,
      'errorCode': instance.errorCode,
      'requiresAuth': instance.requiresAuth,
      'alreadyMember': instance.alreadyMember,
    };

_PermissionsDto _$PermissionsDtoFromJson(Map<String, dynamic> json) =>
    _PermissionsDto(
      permissions: (json['permissions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      role: json['role'] as String,
    );

Map<String, dynamic> _$PermissionsDtoToJson(_PermissionsDto instance) =>
    <String, dynamic>{
      'permissions': instance.permissions,
      'role': instance.role,
    };
