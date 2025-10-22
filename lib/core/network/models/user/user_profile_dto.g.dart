// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfileDto _$UserProfileDtoFromJson(Map<String, dynamic> json) =>
    _UserProfileDto(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      timezone: json['timezone'] as String? ?? 'UTC',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UserProfileDtoToJson(_UserProfileDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'timezone': instance.timezone,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_CreateUserProfileDto _$CreateUserProfileDtoFromJson(
  Map<String, dynamic> json,
) => _CreateUserProfileDto(
  email: json['email'] as String,
  name: json['name'] as String,
);

Map<String, dynamic> _$CreateUserProfileDtoToJson(
  _CreateUserProfileDto instance,
) => <String, dynamic>{'email': instance.email, 'name': instance.name};

_UpdateUserProfileDto _$UpdateUserProfileDtoFromJson(
  Map<String, dynamic> json,
) => _UpdateUserProfileDto(name: json['name'] as String?);

Map<String, dynamic> _$UpdateUserProfileDtoToJson(
  _UpdateUserProfileDto instance,
) => <String, dynamic>{'name': instance.name};
