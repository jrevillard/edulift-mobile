import 'package:freezed_annotation/freezed_annotation.dart';
import 'conflict_dto.dart';

part 'schedule_conflicts_dto.freezed.dart';
part 'schedule_conflicts_dto.g.dart';

/// Schedule Conflicts Data Transfer Object
/// Represents schedule conflicts response from the backend API
@freezed
abstract class ScheduleConflictsDto with _$ScheduleConflictsDto {
  const factory ScheduleConflictsDto({
    required List<ConflictDto> conflicts,
    required bool hasConflicts,
    required String groupId,
    Map<String, dynamic>? conflictDetails,
  }) = _ScheduleConflictsDto;

  factory ScheduleConflictsDto.fromJson(Map<String, dynamic> json) =>
      _$ScheduleConflictsDtoFromJson(json);
}
