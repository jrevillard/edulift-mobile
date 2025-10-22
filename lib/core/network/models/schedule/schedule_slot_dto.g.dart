// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_slot_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ScheduleSlotDto _$ScheduleSlotDtoFromJson(Map<String, dynamic> json) =>
    _ScheduleSlotDto(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      datetime: DateTime.parse(json['datetime'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      vehicleAssignments: (json['vehicleAssignments'] as List<dynamic>?)
          ?.map((e) => VehicleAssignmentDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      childAssignments: (json['childAssignments'] as List<dynamic>?)
          ?.map((e) => ScheduleSlotChildDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ScheduleSlotDtoToJson(_ScheduleSlotDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'datetime': instance.datetime.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'vehicleAssignments': instance.vehicleAssignments,
      'childAssignments': instance.childAssignments,
    };
