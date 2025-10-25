import 'package:equatable/equatable.dart';

/// Core Child Assignment entity for shared use across layers
/// Simplified version without complex dependencies
class ChildAssignment extends Equatable {
  final String id;
  final String childId;
  final String assignmentType;
  final String assignmentId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  // Transportation/Schedule specific fields
  final String? groupId;
  final String? scheduleSlotId;
  final String? vehicleAssignmentId;
  final AssignmentStatus? status;
  final DateTime? assignmentDate;
  final String? notes;

  // Schedule/Pickup specific fields
  final String? childName;
  final String? familyId;
  final String? familyName;
  final String? pickupAddress;
  final double? pickupLat;
  final double? pickupLng;
  final DateTime? pickupTime;
  final DateTime? dropoffTime;

  // Schedule status as string for schedule assignments
  final String? _scheduleStatus;

  const ChildAssignment({
    required this.id,
    required this.childId,
    required this.assignmentType,
    required this.assignmentId,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.metadata,
    // Transportation/Schedule fields
    this.groupId,
    this.scheduleSlotId,
    this.vehicleAssignmentId,
    this.status,
    this.assignmentDate,
    this.notes,
    // Pickup/Schedule fields
    this.childName,
    this.familyId,
    this.familyName,
    this.pickupAddress,
    this.pickupLat,
    this.pickupLng,
    this.pickupTime,
    this.dropoffTime,
    String? scheduleStatus,
  }) : _scheduleStatus = scheduleStatus;

  /// Factory for transportation assignments
  factory ChildAssignment.transportation({
    required String id,
    required String childId,
    required String groupId,
    required String scheduleSlotId,
    required String vehicleAssignmentId,
    required DateTime assignedAt,
    required AssignmentStatus status,
    required DateTime assignmentDate,
    String? notes,
  }) {
    return ChildAssignment(
      id: id,
      childId: childId,
      assignmentType: 'transportation',
      assignmentId: vehicleAssignmentId,
      createdAt: assignedAt,
      groupId: groupId,
      scheduleSlotId: scheduleSlotId,
      vehicleAssignmentId: vehicleAssignmentId,
      status: status,
      assignmentDate: assignmentDate,
      notes: notes,
    );
  }

  /// Factory for schedule assignments
  factory ChildAssignment.schedule({
    required String id,
    required String childId,
    required String childName,
    required String familyId,
    required String familyName,
    required String pickupAddress,
    required double pickupLat,
    required double pickupLng,
    required String status,
    DateTime? createdAt,
    DateTime? pickupTime,
    DateTime? dropoffTime,
  }) {
    return ChildAssignment(
      id: id,
      childId: childId,
      assignmentType: 'schedule',
      assignmentId: id,
      createdAt: createdAt ?? DateTime.now(),
      childName: childName,
      familyId: familyId,
      familyName: familyName,
      pickupAddress: pickupAddress,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      pickupTime: pickupTime,
      dropoffTime: dropoffTime,
      scheduleStatus: status, // Store schedule status properly
    );
  }

  // Add properties that tests expect
  String? get scheduleStatus => _scheduleStatus;
  bool get isActiveTransportation =>
      assignmentType == 'transportation' &&
      (status == AssignmentStatus.confirmed ||
          status == AssignmentStatus.pending);
  bool get isFuture =>
      (assignmentDate?.isAfter(DateTime.now()) ?? false) ||
      (pickupTime?.isAfter(DateTime.now()) ?? false);
  ChildAssignment get composed => this;

  ChildAssignment copyWith({
    String? id,
    String? childId,
    String? assignmentType,
    String? assignmentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, dynamic>? metadata,
    String? groupId,
    String? scheduleSlotId,
    String? vehicleAssignmentId,
    AssignmentStatus? status,
    DateTime? assignmentDate,
    String? notes,
    String? childName,
    String? familyId,
    String? familyName,
    String? pickupAddress,
    double? pickupLat,
    double? pickupLng,
    DateTime? pickupTime,
    DateTime? dropoffTime,
    String? scheduleStatus,
  }) {
    return ChildAssignment(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      assignmentType: assignmentType ?? this.assignmentType,
      assignmentId: assignmentId ?? this.assignmentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
      groupId: groupId ?? this.groupId,
      scheduleSlotId: scheduleSlotId ?? this.scheduleSlotId,
      vehicleAssignmentId: vehicleAssignmentId ?? this.vehicleAssignmentId,
      status: status ?? this.status,
      assignmentDate: assignmentDate ?? this.assignmentDate,
      notes: notes ?? this.notes,
      childName: childName ?? this.childName,
      familyId: familyId ?? this.familyId,
      familyName: familyName ?? this.familyName,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      pickupTime: pickupTime ?? this.pickupTime,
      dropoffTime: dropoffTime ?? this.dropoffTime,
      scheduleStatus: scheduleStatus ?? _scheduleStatus,
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
        metadata,
        groupId,
        scheduleSlotId,
        vehicleAssignmentId,
        status,
        assignmentDate,
        notes,
        childName,
        familyId,
        familyName,
        pickupAddress,
        pickupLat,
        pickupLng,
        pickupTime,
        dropoffTime,
        _scheduleStatus,
      ];

  @override
  String toString() {
    return 'ChildAssignment(id: $id, childId: $childId, assignmentType: $assignmentType, assignmentId: $assignmentId, isActive: $isActive)';
  }
}

enum AssignmentStatus { pending, confirmed, cancelled, completed, noShow }
