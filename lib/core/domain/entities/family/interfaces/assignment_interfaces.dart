/// Interface segregation for assignment contexts
///
/// These interfaces define focused contracts for different assignment contexts,
/// allowing clients to depend only on the specific properties they need.

import '../../../../../core/domain/entities/family/child_assignment.dart';

/// Core assignment interface - base properties for all assignments
abstract class ICoreAssignment {
  String get id;
  String get childId;
  String get assignmentType;
  String get assignmentId;
  DateTime get createdAt;
  DateTime? get updatedAt;
  bool get isActive;
  Map<String, dynamic>? get metadata;
}

/// Transportation context interface - vehicle and scheduling specific data
abstract class ITransportationAssignment {
  String? get groupId;
  String? get scheduleSlotId;
  String? get vehicleAssignmentId;
  AssignmentStatus? get status;
  DateTime? get assignmentDate;
  String? get notes;

  /// Check if assignment is confirmed for transportation
  bool get isActiveTransportation;

  /// Check if assignment is in the future
  bool get isFuture;
}

/// Schedule context interface - pickup/dropoff specific data
abstract class IScheduleAssignment {
  DateTime? get pickupTime;
  DateTime? get dropoffTime;
  String? get pickupAddress;
  double? get pickupLat;
  double? get pickupLng;

  /// Get string status for schedule assignments
  String get scheduleStatus;
}

/// Family context interface - family-specific view data
abstract class IFamilyContext {
  String? get childName;
  String? get familyId;
  String? get familyName;
}

// AssignmentStatus enum is now imported from core domain
// This was previously duplicated here, causing enum equality issues in tests
