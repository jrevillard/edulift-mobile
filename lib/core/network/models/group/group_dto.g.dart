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
  if (instance.description case final value?) 'description': value,
  'familyId': instance.familyId,
  if (instance.inviteCode case final value?) 'invite_code': value,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  if (instance.userRole case final value?) 'userRole': value,
  if (instance.joinedAt case final value?) 'joinedAt': value,
  if (instance.ownerFamily case final value?) 'ownerFamily': value,
  if (instance.familyCount case final value?) 'familyCount': value,
  if (instance.scheduleCount case final value?) 'scheduleCount': value,
};
