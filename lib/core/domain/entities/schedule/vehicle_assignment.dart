import 'package:equatable/equatable.dart';
import '../family/child_assignment.dart';

/// Represents a vehicle assignment to a schedule slot
class VehicleAssignment extends Equatable {
  final String id;
  final String scheduleSlotId;
  final String vehicleId;
  final String? driverId;
  final DateTime assignedAt;
  final String assignedBy;
  final bool isActive;
  final int? seatOverride;
  final String? notes;
  final VehicleAssignmentStatus status;

  // Additional properties needed by ScheduleSlotWidget and legacy compatibility
  final String vehicleName;
  final String?
  driverName; // Legacy compatibility - can be derived from driverId
  final List<ChildAssignment> childAssignments;
  final int capacity;
  final DateTime createdAt; // Legacy compatibility
  final DateTime updatedAt; // Legacy compatibility

  const VehicleAssignment({
    required this.id,
    required this.scheduleSlotId,
    required this.vehicleId,
    this.driverId,
    required this.assignedAt,
    required this.assignedBy,
    this.isActive = true,
    this.seatOverride,
    this.notes,
    this.status = VehicleAssignmentStatus.assigned,
    // Additional required properties
    required this.vehicleName,
    this.driverName, // Legacy compatibility
    this.childAssignments = const [],
    required this.capacity,
    required this.createdAt, // Legacy compatibility
    required this.updatedAt, // Legacy compatibility
  });

  /// Returns the effective capacity considering seat override
  /// If seatOverride is set, use it; otherwise use base capacity
  int get effectiveCapacity => seatOverride ?? capacity;

  /// Returns true if a seat override is active
  bool get hasOverride => seatOverride != null;

  /// Returns a display string showing capacity with override info
  /// Examples: "5 seats" or "5 seats (8 base)"
  String get capacityDisplay {
    if (hasOverride) {
      return '$effectiveCapacity ($capacity base)';
    }
    return '$effectiveCapacity';
  }

  /// Returns the capacity status based on assigned children
  /// Business logic for capacity thresholds (80% = near full)
  CapacityStatus capacityStatus() {
    final assignedCount = childAssignments.length;

    if (assignedCount > effectiveCapacity) {
      return CapacityStatus.exceeded;
    } else if (assignedCount == effectiveCapacity) {
      return CapacityStatus.full;
    } else if (effectiveCapacity > 0 &&
        assignedCount / effectiveCapacity >= 0.8) {
      return CapacityStatus.nearFull;
    } else {
      return CapacityStatus.available;
    }
  }

  /// Create an empty VehicleAssignment for error handling
  factory VehicleAssignment.empty() {
    final now = DateTime.now();
    return VehicleAssignment(
      id: '',
      scheduleSlotId: '',
      vehicleId: '',
      assignedAt: now,
      assignedBy: '',
      vehicleName: '',
      capacity: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  VehicleAssignment copyWith({
    String? id,
    String? scheduleSlotId,
    String? vehicleId,
    String? driverId,
    DateTime? assignedAt,
    String? assignedBy,
    bool? isActive,
    int? seatOverride,
    String? notes,
    VehicleAssignmentStatus? status,
    String? vehicleName,
    String? driverName,
    List<ChildAssignment>? childAssignments,
    int? capacity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleAssignment(
      id: id ?? this.id,
      scheduleSlotId: scheduleSlotId ?? this.scheduleSlotId,
      vehicleId: vehicleId ?? this.vehicleId,
      driverId: driverId ?? this.driverId,
      assignedAt: assignedAt ?? this.assignedAt,
      assignedBy: assignedBy ?? this.assignedBy,
      isActive: isActive ?? this.isActive,
      seatOverride: seatOverride ?? this.seatOverride,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      vehicleName: vehicleName ?? this.vehicleName,
      driverName: driverName ?? this.driverName,
      childAssignments: childAssignments ?? this.childAssignments,
      capacity: capacity ?? this.capacity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    scheduleSlotId,
    vehicleId,
    driverId,
    assignedAt,
    assignedBy,
    isActive,
    seatOverride,
    notes,
    status,
    vehicleName,
    driverName,
    childAssignments,
    capacity,
    createdAt,
    updatedAt,
  ];
}

enum VehicleAssignmentStatus { assigned, confirmed, cancelled, completed }

/// Represents the capacity status of a vehicle assignment
/// Used by UI to determine visual representation without business logic
enum CapacityStatus {
  /// Vehicle has available seats (less than 80% full)
  available,

  /// Vehicle is near capacity (80% or more, but not full)
  nearFull,

  /// Vehicle is at full capacity
  full,

  /// Vehicle capacity has been exceeded
  exceeded,
}
