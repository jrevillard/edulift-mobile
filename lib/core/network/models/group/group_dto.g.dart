// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroupDto _$GroupDtoFromJson(Map<String, dynamic> json) => _GroupDto(
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

Map<String, dynamic> _$GroupDtoToJson(_GroupDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'familyId': instance.familyId,
  'invite_code': instance.inviteCode,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  'userRole': instance.userRole,
  'joinedAt': instance.joinedAt,
  'ownerFamily': instance.ownerFamily,
  'familyCount': instance.familyCount,
  'scheduleCount': instance.scheduleCount,
};
