// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ScheduleResponseDto _$ScheduleResponseDtoFromJson(Map<String, dynamic> json) =>
    _ScheduleResponseDto(
      groupId: json['groupId'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      scheduleSlots: (json['scheduleSlots'] as List<dynamic>)
          .map((e) => ScheduleSlotDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ScheduleResponseDtoToJson(
  _ScheduleResponseDto instance,
) =>
    <String, dynamic>{
      'groupId': instance.groupId,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'scheduleSlots': instance.scheduleSlots,
    };
