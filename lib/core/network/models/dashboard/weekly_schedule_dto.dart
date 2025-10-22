import 'package:freezed_annotation/freezed_annotation.dart';

part 'weekly_schedule_dto.freezed.dart';
part 'weekly_schedule_dto.g.dart';

@freezed
abstract class WeeklyScheduleItemDto with _$WeeklyScheduleItemDto {
  const factory WeeklyScheduleItemDto({
    required String id,
    required String day,
    required String time,
    required String destination,
    required List<String> childrenNames,
    required String? vehicleName,
    required String status,
  }) = _WeeklyScheduleItemDto;

  factory WeeklyScheduleItemDto.fromJson(Map<String, dynamic> json) =>
      _$WeeklyScheduleItemDtoFromJson(json);
}

@freezed
abstract class WeeklyScheduleDto with _$WeeklyScheduleDto {
  const factory WeeklyScheduleDto({
    required List<WeeklyScheduleItemDto> schedules,
    required String weekStart,
    required String weekEnd,
  }) = _WeeklyScheduleDto;

  factory WeeklyScheduleDto.fromJson(Map<String, dynamic> json) =>
      _$WeeklyScheduleDtoFromJson(json);
}
