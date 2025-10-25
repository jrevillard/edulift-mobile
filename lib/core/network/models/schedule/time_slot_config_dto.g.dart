// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_slot_config_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TimeSlotConfigDto _$TimeSlotConfigDtoFromJson(Map<String, dynamic> json) =>
    _TimeSlotConfigDto(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      availableDays: (json['availableDays'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      timeSlots:
          (json['timeSlots'] as List<dynamic>).map((e) => e as String).toList(),
      settings: json['settings'] as Map<String, dynamic>,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TimeSlotConfigDtoToJson(_TimeSlotConfigDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'availableDays': instance.availableDays,
      'timeSlots': instance.timeSlots,
      'settings': instance.settings,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
