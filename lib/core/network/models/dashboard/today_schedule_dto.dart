import 'package:freezed_annotation/freezed_annotation.dart';

part 'today_schedule_dto.freezed.dart';
part 'today_schedule_dto.g.dart';

@freezed
abstract class TodayScheduleDto with _$TodayScheduleDto {
  const factory TodayScheduleDto({
    required String id,
    required String time,
    required String destination,
    required List<String> childrenNames,
    required String? vehicleName,
    required String status,
  }) = _TodayScheduleDto;

  factory TodayScheduleDto.fromJson(Map<String, dynamic> json) =>
      _$TodayScheduleDtoFromJson(json);
}

@freezed
abstract class TodayScheduleListDto with _$TodayScheduleListDto {
  const factory TodayScheduleListDto({
    required List<TodayScheduleDto> schedules,
    required String date,
  }) = _TodayScheduleListDto;

  factory TodayScheduleListDto.fromJson(Map<String, dynamic> json) =>
      _$TodayScheduleListDtoFromJson(json);
}
