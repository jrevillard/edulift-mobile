// EduLift Mobile - Child Assignment Data Entity
// Data structure for child assignment API responses

import 'package:equatable/equatable.dart';
import 'child_assignment.dart';

/// Child assignment data entity used for API data exchange
/// This is a simplified version of ChildAssignment focused on data transfer
class ChildAssignmentData extends Equatable {
  /// Unique identifier for the assignment
  final String id;

  /// Child identifier
  final String childId;

  /// Assignment type (schedule, transportation, etc.)
  final String assignmentType;

  /// Reference to the assigned resource (vehicle, slot, etc.)
  final String assignmentId;

  /// Assignment status
  final String status;

  /// Assignment date/time
  final DateTime? assignmentDate;

  /// Additional assignment metadata
  final Map<String, dynamic>? metadata;

  /// Creation timestamp
  final DateTime createdAt;

  /// Update timestamp
  final DateTime? updatedAt;

  const ChildAssignmentData({
    required this.id,
    required this.childId,
    required this.assignmentType,
    required this.assignmentId,
    required this.status,
    this.assignmentDate,
    this.metadata,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert to full ChildAssignment domain entity
  ChildAssignment toAssignment() {
    return ChildAssignment(
      id: id,
      childId: childId,
      assignmentType: assignmentType,
      assignmentId: assignmentId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: status != 'cancelled' && status != 'completed',
      metadata: {...?metadata, 'status': status},
      status: _parseAssignmentStatus(status),
      assignmentDate: assignmentDate,
    );
  }

  /// Parse string status to AssignmentStatus enum
  AssignmentStatus _parseAssignmentStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AssignmentStatus.pending;
      case 'confirmed':
        return AssignmentStatus.confirmed;
      case 'cancelled':
        return AssignmentStatus.cancelled;
      case 'completed':
        return AssignmentStatus.completed;
      default:
        return AssignmentStatus.pending;
    }
  }

  /// Create a copy with updated fields
  ChildAssignmentData copyWith({
    String? id,
    String? childId,
    String? assignmentType,
    String? assignmentId,
    String? status,
    DateTime? assignmentDate,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChildAssignmentData(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      assignmentType: assignmentType ?? this.assignmentType,
      assignmentId: assignmentId ?? this.assignmentId,
      status: status ?? this.status,
      assignmentDate: assignmentDate ?? this.assignmentDate,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if assignment is active
  bool get isActive => status != 'cancelled' && status != 'completed';

  /// Check if assignment is in the future
  bool get isFuture => assignmentDate?.isAfter(DateTime.now()) ?? false;

  @override
  List<Object?> get props => [
    id,
    childId,
    assignmentType,
    assignmentId,
    status,
    assignmentDate,
    metadata,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'ChildAssignmentData(id: $id, childId: $childId, assignmentType: $assignmentType, status: $status)';
  }
}