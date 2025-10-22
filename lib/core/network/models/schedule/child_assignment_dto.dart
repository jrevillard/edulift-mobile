import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../converters/domain_converter.dart';
import '../../../../core/domain/entities/family/child_assignment.dart';

part 'child_assignment_dto.freezed.dart';
part 'child_assignment_dto.g.dart';

/// Default assignment type for schedule assignments
const String _kScheduleAssignmentType = 'schedule';

/// Child Assignment Data Transfer Object
/// Represents child-to-schedule assignment from the backend API
@freezed
abstract class ChildAssignmentDto
    with _$ChildAssignmentDto
    implements DomainConverter<ChildAssignment> {
  const ChildAssignmentDto._();

  const factory ChildAssignmentDto({
    required String id,
    required String childId,
    required String assignmentId,
    required String status,
    DateTime? assignedAt,
    String? notes,
  }) = _ChildAssignmentDto;

  factory ChildAssignmentDto.fromJson(Map<String, dynamic> json) =>
      _$ChildAssignmentDtoFromJson(json);

  /// Convert DTO to Domain Entity
  @override
  ChildAssignment toDomain() {
    // Parse status to AssignmentStatus enum
    AssignmentStatus? parsedStatus;
    switch (status.toLowerCase()) {
      case 'pending':
        parsedStatus = AssignmentStatus.pending;
        break;
      case 'confirmed':
        parsedStatus = AssignmentStatus.confirmed;
        break;
      case 'cancelled':
        parsedStatus = AssignmentStatus.cancelled;
        break;
      case 'completed':
        parsedStatus = AssignmentStatus.completed;
        break;
      case 'noshow':
      case 'no_show':
        parsedStatus = AssignmentStatus.noShow;
        break;
      default:
        parsedStatus = AssignmentStatus.pending;
    }

    return ChildAssignment(
      id: id,
      childId: childId,
      assignmentType: _kScheduleAssignmentType,
      assignmentId: assignmentId,
      createdAt: assignedAt ?? DateTime.now(),
      status: parsedStatus,
      notes: notes,
    );
  }
}
