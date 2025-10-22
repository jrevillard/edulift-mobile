// EduLift Mobile - WebSocket DTO Extensions
// Optimized serialization extensions for WebSocket events

import '../models/vehicle/vehicle_dto.dart';
import '../models/child/child_dto.dart';
import '../models/schedule/vehicle_assignment_dto.dart';
import '../models/schedule/child_assignment_dto.dart';

/// WebSocket-optimized extensions for Vehicle DTOs
extension VehicleWebSocketExtension on VehicleDto {
  /// Convert to WebSocket event format with minimal data
  Map<String, dynamic> toWebSocketEventData() {
    return {
      'id': id,
      'name': name,
      'familyId': familyId,
      'capacity': capacity,
      'description': description,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from WebSocket event data
  static VehicleDto? fromWebSocketEventData(Map<String, dynamic> json) {
    try {
      return VehicleDto(
        id: json['id'] as String,
        name: json['name'] as String,
        familyId: json['familyId'] as String,
        capacity: json['capacity'] as int,
        description: json['description'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );
    } catch (e) {
      return null;
    }
  }
}

/// WebSocket-optimized extensions for Child DTOs
extension ChildWebSocketExtension on ChildDto {
  /// Convert to WebSocket event format with minimal data
  Map<String, dynamic> toWebSocketEventData() {
    return {
      'id': id,
      'name': name,
      'familyId': familyId,
      'age': age,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from WebSocket event data
  static ChildDto? fromWebSocketEventData(Map<String, dynamic> json) {
    try {
      return ChildDto(
        id: json['id'] as String,
        name: json['name'] as String,
        familyId: json['familyId'] as String,
        age: json['age'] as int?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );
    } catch (e) {
      return null;
    }
  }
}

/// WebSocket-optimized extensions for VehicleAssignment DTOs
extension VehicleAssignmentWebSocketExtension on VehicleAssignmentDto {
  /// Convert to WebSocket event format with optimized data
  /// Mirrors ACTUAL backend API response structure
  Map<String, dynamic> toWebSocketEventData() {
    return {
      'id': id,
      'scheduleSlotId': scheduleSlotId,
      'vehicleId': vehicle.id,
      'seatOverride': seatOverride,
      'createdAt': DateTime.now().toIso8601String(),
      'vehicle': vehicle.toJson(),
      // NOTE: driverId and driver removed - not in actual API response
      'childAssignments': const [],
    };
  }
}

/// WebSocket-optimized extensions for ChildAssignment DTOs
extension ChildAssignmentWebSocketExtension on ChildAssignmentDto {
  /// Convert to WebSocket event format with optimized data
  Map<String, dynamic> toWebSocketEventData() {
    return {
      'id': id,
      'childId': childId,
      'assignmentId': assignmentId,
      'status': status,
      'assignedAt': assignedAt?.toIso8601String(),
      'notes': notes,
    };
  }
}