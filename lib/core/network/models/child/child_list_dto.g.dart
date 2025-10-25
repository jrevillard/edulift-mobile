// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_list_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChildrenListDto _$ChildrenListDtoFromJson(Map<String, dynamic> json) =>
    _ChildrenListDto(
      children: (json['children'] as List<dynamic>)
          .map((e) => ChildDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ChildrenListDtoToJson(_ChildrenListDto instance) =>
    <String, dynamic>{'children': instance.children};

_AssignmentDto _$AssignmentDtoFromJson(Map<String, dynamic> json) =>
    _AssignmentDto(
      id: json['id'] as String,
      childId: json['childId'] as String,
      scheduleSlotId: json['scheduleSlotId'] as String,
      vehicleAssignmentId: json['vehicleAssignmentId'] as String?,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$AssignmentDtoToJson(_AssignmentDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'childId': instance.childId,
      'scheduleSlotId': instance.scheduleSlotId,
      'vehicleAssignmentId': instance.vehicleAssignmentId,
      'status': instance.status,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

_ChildAssignmentsDto _$ChildAssignmentsDtoFromJson(Map<String, dynamic> json) =>
    _ChildAssignmentsDto(
      assignments: (json['assignments'] as List<dynamic>)
          .map((e) => AssignmentDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ChildAssignmentsDtoToJson(
  _ChildAssignmentsDto instance,
) =>
    <String, dynamic>{'assignments': instance.assignments};

_GroupMembershipDto _$GroupMembershipDtoFromJson(Map<String, dynamic> json) =>
    _GroupMembershipDto(
      id: json['id'] as String,
      childId: json['childId'] as String,
      groupId: json['groupId'] as String,
      groupName: json['groupName'] as String,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$GroupMembershipDtoToJson(_GroupMembershipDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'childId': instance.childId,
      'groupId': instance.groupId,
      'groupName': instance.groupName,
      'createdAt': instance.createdAt,
    };

_ChildGroupMembershipsDto _$ChildGroupMembershipsDtoFromJson(
  Map<String, dynamic> json,
) =>
    _ChildGroupMembershipsDto(
      memberships: (json['memberships'] as List<dynamic>)
          .map((e) => GroupMembershipDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ChildGroupMembershipsDtoToJson(
  _ChildGroupMembershipsDto instance,
) =>
    <String, dynamic>{'memberships': instance.memberships};
