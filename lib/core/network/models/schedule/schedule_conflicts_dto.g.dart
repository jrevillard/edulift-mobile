// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_conflicts_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ScheduleConflictsDto _$ScheduleConflictsDtoFromJson(
  Map<String, dynamic> json,
) =>
    _ScheduleConflictsDto(
      conflicts: (json['conflicts'] as List<dynamic>)
          .map((e) => ConflictDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasConflicts: json['hasConflicts'] as bool,
      groupId: json['groupId'] as String,
      conflictDetails: json['conflictDetails'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ScheduleConflictsDtoToJson(
  _ScheduleConflictsDto instance,
) =>
    <String, dynamic>{
      'conflicts': instance.conflicts,
      'hasConflicts': instance.hasConflicts,
      'groupId': instance.groupId,
      'conflictDetails': instance.conflictDetails,
    };
