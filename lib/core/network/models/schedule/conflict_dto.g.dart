// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conflict_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ConflictDto _$ConflictDtoFromJson(Map<String, dynamic> json) => _ConflictDto(
  id: json['id'] as String,
  type: json['type'] as String,
  description: json['description'] as String,
  conflictingResourceId: json['conflictingResourceId'] as String,
  conflictTime: DateTime.parse(json['conflictTime'] as String),
  resolution: json['resolution'] as String?,
);

Map<String, dynamic> _$ConflictDtoToJson(_ConflictDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'description': instance.description,
      'conflictingResourceId': instance.conflictingResourceId,
      'conflictTime': instance.conflictTime.toIso8601String(),
      'resolution': instance.resolution,
    };
