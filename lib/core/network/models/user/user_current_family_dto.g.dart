// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_current_family_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserCurrentFamilyDto _$UserCurrentFamilyDtoFromJson(
  Map<String, dynamic> json,
) =>
    _UserCurrentFamilyDto(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      timezone: json['timezone'] as String? ?? 'UTC',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      isBiometricEnabled: json['is_biometric_enabled'] as bool? ?? false,
      familyId: json['family_id'] as String?,
      familyName: json['family_name'] as String?,
      userRole: json['user_role'] as String?,
      joinedAt: json['joined_at'] == null
          ? null
          : DateTime.parse(json['joined_at'] as String),
      isActive: json['is_active'] as bool?,
    );

Map<String, dynamic> _$UserCurrentFamilyDtoToJson(
  _UserCurrentFamilyDto instance,
) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'timezone': instance.timezone,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'is_biometric_enabled': instance.isBiometricEnabled,
      'family_id': instance.familyId,
      'family_name': instance.familyName,
      'user_role': instance.userRole,
      'joined_at': instance.joinedAt?.toIso8601String(),
      'is_active': instance.isActive,
    };
