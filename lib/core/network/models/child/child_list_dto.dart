import 'package:freezed_annotation/freezed_annotation.dart';
import 'child_dto.dart';

part 'child_list_dto.freezed.dart';
part 'child_list_dto.g.dart';

@freezed
abstract class ChildrenListDto with _$ChildrenListDto {
  const factory ChildrenListDto({required List<ChildDto> children}) =
      _ChildrenListDto;

  factory ChildrenListDto.fromJson(Map<String, dynamic> json) =>
      _$ChildrenListDtoFromJson(json);
}

@freezed
abstract class AssignmentDto with _$AssignmentDto {
  const factory AssignmentDto({
    required String id,
    required String childId,
    required String scheduleSlotId,
    String? vehicleAssignmentId,
    required String status,
    required String createdAt,
    required String updatedAt,
  }) = _AssignmentDto;

  factory AssignmentDto.fromJson(Map<String, dynamic> json) => AssignmentDto(
    id: json['id'] as String,
    childId: json['child_id'] as String,
    scheduleSlotId: json['schedule_slot_id'] as String,
    vehicleAssignmentId: json['vehicle_assignment_id'] as String?,
    status: json['status'] as String,
    createdAt: json['created_at'] as String,
    updatedAt: json['updated_at'] as String,
  );
}

@freezed
abstract class ChildAssignmentsDto with _$ChildAssignmentsDto {
  const factory ChildAssignmentsDto({
    required List<AssignmentDto> assignments,
  }) = _ChildAssignmentsDto;

  factory ChildAssignmentsDto.fromJson(Map<String, dynamic> json) =>
      _$ChildAssignmentsDtoFromJson(json);
}

@freezed
abstract class GroupMembershipDto with _$GroupMembershipDto {
  const factory GroupMembershipDto({
    required String id,
    required String childId,
    required String groupId,
    required String groupName,
    required String createdAt,
  }) = _GroupMembershipDto;

  factory GroupMembershipDto.fromJson(Map<String, dynamic> json) =>
      GroupMembershipDto(
        id: json['id'] as String,
        childId: json['child_id'] as String,
        groupId: json['group_id'] as String,
        groupName: json['group_name'] as String,
        createdAt: json['created_at'] as String,
      );
}

@freezed
abstract class ChildGroupMembershipsDto with _$ChildGroupMembershipsDto {
  const factory ChildGroupMembershipsDto({
    required List<GroupMembershipDto> memberships,
  }) = _ChildGroupMembershipsDto;

  factory ChildGroupMembershipsDto.fromJson(Map<String, dynamic> json) =>
      _$ChildGroupMembershipsDtoFromJson(json);
}
