// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_schedule_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WeeklyScheduleItemDto _$WeeklyScheduleItemDtoFromJson(
  Map<String, dynamic> json,
) => _WeeklyScheduleItemDto(
  id: json['id'] as String,
  day: json['day'] as String,
  time: json['time'] as String,
  destination: json['destination'] as String,
  childrenNames: (json['childrenNames'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  vehicleName: json['vehicleName'] as String?,
  status: json['status'] as String,
);

Map<String, dynamic> _$WeeklyScheduleItemDtoToJson(
  _WeeklyScheduleItemDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'day': instance.day,
  'time': instance.time,
  'destination': instance.destination,
  'childrenNames': instance.childrenNames,
  'vehicleName': instance.vehicleName,
  'status': instance.status,
};

_WeeklyScheduleDto _$WeeklyScheduleDtoFromJson(Map<String, dynamic> json) =>
    _WeeklyScheduleDto(
      schedules: (json['schedules'] as List<dynamic>)
          .map((e) => WeeklyScheduleItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      weekStart: json['weekStart'] as String,
      weekEnd: json['weekEnd'] as String,
    );

Map<String, dynamic> _$WeeklyScheduleDtoToJson(_WeeklyScheduleDto instance) =>
    <String, dynamic>{
      'schedules': instance.schedules,
      'weekStart': instance.weekStart,
      'weekEnd': instance.weekEnd,
    };
