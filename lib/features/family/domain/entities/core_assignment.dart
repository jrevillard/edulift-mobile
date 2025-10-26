import 'package:equatable/equatable.dart';
import 'interfaces/assignment_interfaces.dart';

/// Core assignment entity containing base assignment data
///
/// This entity represents the essential assignment information that is
/// common across all assignment types. It implements Single Responsibility
/// by focusing solely on core assignment data.
class CoreAssignment extends Equatable implements ICoreAssignment {
  @override
  final String id;

  @override
  final String childId;

  @override
  final String assignmentType; // 'transportation', 'schedule', 'activity', etc.

  @override
  final String assignmentId; // Generic assignment reference

  @override
  final DateTime createdAt;

  @override
  final DateTime? updatedAt;

  @override
  final bool isActive;

  @override
  final Map<String, dynamic>? metadata;

  const CoreAssignment({
    required this.id,
    required this.childId,
    required this.assignmentType,
    required this.assignmentId,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.metadata,
  });

  CoreAssignment copyWith({
    String? id,
    String? childId,
    String? assignmentType,
    String? assignmentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return CoreAssignment(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      assignmentType: assignmentType ?? this.assignmentType,
      assignmentId: assignmentId ?? this.assignmentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
    id,
    childId,
    assignmentType,
    assignmentId,
    createdAt,
    updatedAt,
    isActive,
    _metadataForEquality(),
  ];

  /// Helper method to ensure metadata comparison is done by content, not reference
  Object? _metadataForEquality() {
    if (metadata == null) return null;
    // Create a sorted representation of metadata for consistent equality
    final sortedKeys = metadata!.keys.toList()..sort();
    return sortedKeys.map((key) => '$key:${metadata![key]}').join(',');
  }

  @override
  String toString() {
    return 'CoreAssignment(id: $id, childId: $childId, assignmentType: $assignmentType, assignmentId: $assignmentId, isActive: $isActive)';
  }
}
