import 'package:equatable/equatable.dart';
import 'interfaces/assignment_interfaces.dart';
import '../../../../core/domain/entities/family/child_assignment.dart';

/// Transportation assignment entity containing vehicle and scheduling specific data
///
/// This entity is focused on transportation-related assignment properties,
/// implementing Interface Segregation by containing only transportation concerns.
class TransportationAssignment extends Equatable
    implements ITransportationAssignment {
  @override
  final String? groupId;

  @override
  final String? scheduleSlotId;

  @override
  final String? vehicleAssignmentId;

  @override
  final AssignmentStatus? status;

  @override
  final DateTime? assignmentDate;

  @override
  final String? notes;

  const TransportationAssignment({
    this.groupId,
    this.scheduleSlotId,
    this.vehicleAssignmentId,
    this.status,
    this.assignmentDate,
    this.notes,
  });

  /// Factory for confirmed transportation assignments
  factory TransportationAssignment.confirmed({
    required String groupId,
    required String scheduleSlotId,
    required String vehicleAssignmentId,
    required DateTime assignmentDate,
    String? notes,
  }) {
    return TransportationAssignment(
      groupId: groupId,
      scheduleSlotId: scheduleSlotId,
      vehicleAssignmentId: vehicleAssignmentId,
      status: AssignmentStatus.confirmed,
      assignmentDate: assignmentDate,
      notes: notes,
    );
  }

  @override
  bool get isActiveTransportation => status == AssignmentStatus.confirmed;

  @override
  bool get isFuture => assignmentDate?.isAfter(DateTime.now()) ?? false;

  TransportationAssignment copyWith({
    String? groupId,
    String? scheduleSlotId,
    String? vehicleAssignmentId,
    AssignmentStatus? status,
    DateTime? assignmentDate,
    String? notes,
  }) {
    return TransportationAssignment(
      groupId: groupId ?? this.groupId,
      scheduleSlotId: scheduleSlotId ?? this.scheduleSlotId,
      vehicleAssignmentId: vehicleAssignmentId ?? this.vehicleAssignmentId,
      status: status ?? this.status,
      assignmentDate: assignmentDate ?? this.assignmentDate,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    groupId,
    scheduleSlotId,
    vehicleAssignmentId,
    status,
    assignmentDate,
    notes,
  ];

  @override
  String toString() {
    return 'TransportationAssignment(groupId: $groupId, vehicleAssignmentId: $vehicleAssignmentId, status: $status)';
  }
}
