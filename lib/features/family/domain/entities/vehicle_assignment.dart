// EduLift Mobile - Vehicle Assignment Entity - DEPRECATED
// CRITICAL: This entity is not supported by the backend API
// VehicleAssignment functionality is not available in the backend
// Use ../../../schedule/domain/entities/vehicle_assignment.dart instead

import 'package:equatable/equatable.dart';

/// DEPRECATED: VehicleAssignment functionality is not supported by the backend API
/// This class should not be used - the backend does not support vehicle assignment operations
@Deprecated(
  'VehicleAssignment functionality is not supported by the backend API. Use schedule domain entities instead.',
)
class VehicleAssignment extends Equatable {
  /// Unique identifier for the assignment
  final String id;

  /// Vehicle ID being assigned
  final String vehicleId;

  /// Schedule ID this assignment belongs to
  final String scheduleId;

  /// Driver ID (optional)
  final String? driverId;

  /// Route ID (optional)
  final String? routeId;

  /// Assignment status
  final String status;

  /// Assigned capacity
  final int capacity;

  /// Assignment timestamp
  final DateTime assignedAt;

  /// Assignment metadata
  final Map<String, dynamic>? metadata;

  const VehicleAssignment({
    required this.id,
    required this.vehicleId,
    required this.scheduleId,
    this.driverId,
    this.routeId,
    this.status = 'assigned',
    this.capacity = 4,
    required this.assignedAt,
    this.metadata,
  });

  /// Create a copy with updated fields
  VehicleAssignment copyWith({
    String? id,
    String? vehicleId,
    String? scheduleId,
    String? driverId,
    String? routeId,
    String? status,
    int? capacity,
    DateTime? assignedAt,
    Map<String, dynamic>? metadata,
  }) {
    return VehicleAssignment(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      scheduleId: scheduleId ?? this.scheduleId,
      driverId: driverId ?? this.driverId,
      routeId: routeId ?? this.routeId,
      status: status ?? this.status,
      capacity: capacity ?? this.capacity,
      assignedAt: assignedAt ?? this.assignedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
    id,
    vehicleId,
    scheduleId,
    driverId,
    routeId,
    status,
    capacity,
    assignedAt,
    metadata,
  ];

  @override
  String toString() {
    return 'VehicleAssignment(id: $id, vehicleId: $vehicleId, scheduleId: $scheduleId, status: $status)';
  }
}
