// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_member_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserDto _$UserDtoFromJson(Map<String, dynamic> json) => _UserDto(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );

Map<String, dynamic> _$UserDtoToJson(_UserDto instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
    };

_FamilyMemberDto _$FamilyMemberDtoFromJson(Map<String, dynamic> json) =>
    _FamilyMemberDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      familyId: json['familyId'] as String,
      role: json['role'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      user: json['user'] == null
          ? null
          : UserDto.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FamilyMemberDtoToJson(_FamilyMemberDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'familyId': instance.familyId,
      'role': instance.role,
      'joinedAt': instance.joinedAt.toIso8601String(),
      'user': instance.user,
    };
