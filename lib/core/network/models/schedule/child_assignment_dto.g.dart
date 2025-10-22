// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_assignment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChildAssignmentDto _$ChildAssignmentDtoFromJson(Map<String, dynamic> json) =>
    _ChildAssignmentDto(
      id: json['id'] as String,
      childId: json['childId'] as String,
      assignmentId: json['assignmentId'] as String,
      status: json['status'] as String,
      assignedAt: json['assignedAt'] == null
          ? null
          : DateTime.parse(json['assignedAt'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$ChildAssignmentDtoToJson(_ChildAssignmentDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'childId': instance.childId,
      'assignmentId': instance.assignmentId,
      'status': instance.status,
      'assignedAt': instance.assignedAt?.toIso8601String(),
      'notes': instance.notes,
    };
