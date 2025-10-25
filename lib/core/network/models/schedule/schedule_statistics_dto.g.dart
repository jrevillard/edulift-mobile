// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_statistics_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ScheduleStatisticsDto _$ScheduleStatisticsDtoFromJson(
  Map<String, dynamic> json,
) =>
    _ScheduleStatisticsDto(
      totalSlots: (json['totalSlots'] as num).toInt(),
      filledSlots: (json['filledSlots'] as num).toInt(),
      availableSlots: (json['availableSlots'] as num).toInt(),
      slotsByDay: Map<String, int>.from(json['slotsByDay'] as Map),
      childrenByDay: Map<String, int>.from(json['childrenByDay'] as Map),
      vehiclesByDay: Map<String, int>.from(json['vehiclesByDay'] as Map),
      groupId: json['groupId'] as String,
      week: json['week'] as String,
      utilizationRate: (json['utilizationRate'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ScheduleStatisticsDtoToJson(
  _ScheduleStatisticsDto instance,
) =>
    <String, dynamic>{
      'totalSlots': instance.totalSlots,
      'filledSlots': instance.filledSlots,
      'availableSlots': instance.availableSlots,
      'slotsByDay': instance.slotsByDay,
      'childrenByDay': instance.childrenByDay,
      'vehiclesByDay': instance.vehiclesByDay,
      'groupId': instance.groupId,
      'week': instance.week,
      'utilizationRate': instance.utilizationRate,
    };
