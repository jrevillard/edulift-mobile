// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_config_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ScheduleConfigDto _$ScheduleConfigDtoFromJson(Map<String, dynamic> json) =>
    _ScheduleConfigDto(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      scheduleHours:
          (json['scheduleHours'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
              k,
              (e as List<dynamic>).map((e) => e as String).toList(),
            ),
          ) ??
          const {},
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      group: json['group'] as Map<String, dynamic>?,
      totalSlots: (json['totalSlots'] as num?)?.toInt(),
      isDefault: json['isDefault'] as bool? ?? false,
    );

Map<String, dynamic> _$ScheduleConfigDtoToJson(_ScheduleConfigDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'scheduleHours': instance.scheduleHours,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'group': instance.group,
      'totalSlots': instance.totalSlots,
      'isDefault': instance.isDefault,
    };
