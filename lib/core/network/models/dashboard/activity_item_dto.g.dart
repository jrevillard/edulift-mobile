// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ActivityItemDto _$ActivityItemDtoFromJson(Map<String, dynamic> json) =>
    _ActivityItemDto(
      id: json['id'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      timestamp: json['timestamp'] as String,
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ActivityItemDtoToJson(_ActivityItemDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'description': instance.description,
      'timestamp': instance.timestamp,
      'userId': instance.userId,
      'userName': instance.userName,
      'metadata': instance.metadata,
    };
