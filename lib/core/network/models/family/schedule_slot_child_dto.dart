// CORRECTED - Child Assignment DTO aligned with backend ScheduleSlotChild schema
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/converters/domain_converter.dart';
import 'package:edulift/core/domain/entities/family.dart';
import '../child/child_dto.dart';

part 'schedule_slot_child_dto.freezed.dart';
part 'schedule_slot_child_dto.g.dart';

/// Schedule Slot Child Data Transfer Object
/// Handles TWO backend response formats:
/// 1. Detailed (POST /children): scheduleSlotId, childId, vehicleAssignmentId, assignedAt, child
/// 2. Simplified (GET /schedule): vehicleAssignmentId, child (only id & name)
@freezed
abstract class ScheduleSlotChildDto
    with _$ScheduleSlotChildDto
    implements DomainConverter<ChildAssignment> {
  const ScheduleSlotChildDto._();
  const factory ScheduleSlotChildDto({
    // Core fields from ScheduleSlotChild Prisma schema
    // Optional because simplified list responses may omit them
    String? scheduleSlotId, // Missing in list responses
    String? childId, // Missing in list responses (use child.id instead)
    required String vehicleAssignmentId, // Always present
    DateTime? assignedAt, // Missing in list responses (use current time)
    // Nested relations from API includes (when present)
    ChildDto? child, // Full child object when included
    // Note: scheduleSlot and vehicleAssignment are also returned but not needed for domain
  }) = _ScheduleSlotChildDto;

  factory ScheduleSlotChildDto.fromJson(Map<String, dynamic> json) =>
      _$ScheduleSlotChildDtoFromJson(json);

  @override
  ChildAssignment toDomain() {
    // Extract childId from nested child object if not directly provided
    final effectiveChildId = childId ?? child?.id ?? '';

    // Use current time if assignedAt is missing (list responses)
    final effectiveAssignedAt = assignedAt ?? DateTime.now();

    // Use empty string or placeholder for scheduleSlotId if missing
    // (will be injected by parent context in list responses)
    final effectiveScheduleSlotId = scheduleSlotId ?? '';

    return ChildAssignment(
      id: '${effectiveScheduleSlotId}_$effectiveChildId', // Generate composite ID
      childId: effectiveChildId,
      assignmentType: 'transportation', // Default type for ScheduleSlotChild
      assignmentId: vehicleAssignmentId,
      createdAt: effectiveAssignedAt,
      scheduleSlotId: effectiveScheduleSlotId,
      vehicleAssignmentId: vehicleAssignmentId,
      childName: child?.name,
      familyId: child?.familyId,
    );
  }

  /// Create DTO from domain model
  factory ScheduleSlotChildDto.fromDomain(ChildAssignment assignment) {
    return ScheduleSlotChildDto(
      scheduleSlotId: assignment.scheduleSlotId ?? '',
      childId: assignment.childId,
      vehicleAssignmentId: assignment.vehicleAssignmentId ?? '',
      assignedAt: assignment.createdAt,
      child: assignment.childName != null || assignment.familyId != null
          ? ChildDto(
              id: assignment.childId,
              name: assignment.childName,
              familyId: assignment.familyId,
            )
          : null,
    );
  }
}
