import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_statistics_dto.freezed.dart';
part 'schedule_statistics_dto.g.dart';

/// Schedule Statistics Data Transfer Object
/// Represents schedule statistics for a group from the backend API
@freezed
abstract class ScheduleStatisticsDto with _$ScheduleStatisticsDto {
  const factory ScheduleStatisticsDto({
    required int totalSlots,
    required int filledSlots,
    required int availableSlots,
    required Map<String, int> slotsByDay,
    required Map<String, int> childrenByDay,
    required Map<String, int> vehiclesByDay,
    required String groupId,
    required String week,
    double? utilizationRate,
  }) = _ScheduleStatisticsDto;

  factory ScheduleStatisticsDto.fromJson(Map<String, dynamic> json) =>
      _$ScheduleStatisticsDtoFromJson(json);
}
