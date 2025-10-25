// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_slot_child_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ScheduleSlotChildDto _$ScheduleSlotChildDtoFromJson(
  Map<String, dynamic> json,
) =>
    _ScheduleSlotChildDto(
      scheduleSlotId: json['scheduleSlotId'] as String?,
      childId: json['childId'] as String?,
      vehicleAssignmentId: json['vehicleAssignmentId'] as String,
      assignedAt: json['assignedAt'] == null
          ? null
          : DateTime.parse(json['assignedAt'] as String),
      child: json['child'] == null
          ? null
          : ChildDto.fromJson(json['child'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ScheduleSlotChildDtoToJson(
  _ScheduleSlotChildDto instance,
) =>
    <String, dynamic>{
      'scheduleSlotId': instance.scheduleSlotId,
      'childId': instance.childId,
      'vehicleAssignmentId': instance.vehicleAssignmentId,
      'assignedAt': instance.assignedAt?.toIso8601String(),
      'child': instance.child,
    };
