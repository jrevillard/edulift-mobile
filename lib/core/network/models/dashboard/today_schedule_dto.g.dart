// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_schedule_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TodayScheduleDto _$TodayScheduleDtoFromJson(Map<String, dynamic> json) =>
    _TodayScheduleDto(
      id: json['id'] as String,
      time: json['time'] as String,
      destination: json['destination'] as String,
      childrenNames: (json['childrenNames'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      vehicleName: json['vehicleName'] as String?,
      status: json['status'] as String,
    );

Map<String, dynamic> _$TodayScheduleDtoToJson(_TodayScheduleDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'time': instance.time,
      'destination': instance.destination,
      'childrenNames': instance.childrenNames,
      'vehicleName': instance.vehicleName,
      'status': instance.status,
    };

_TodayScheduleListDto _$TodayScheduleListDtoFromJson(
  Map<String, dynamic> json,
) =>
    _TodayScheduleListDto(
      schedules: (json['schedules'] as List<dynamic>)
          .map((e) => TodayScheduleDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      date: json['date'] as String,
    );

Map<String, dynamic> _$TodayScheduleListDtoToJson(
  _TodayScheduleListDto instance,
) =>
    <String, dynamic>{'schedules': instance.schedules, 'date': instance.date};
