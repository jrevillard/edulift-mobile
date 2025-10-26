// Local Persistence Helper for Assignment
// Handles JSON serialization for local storage only (not API communication)

import 'package:edulift/core/domain/entities/schedule.dart';

/// Local persistence helper for Assignment entity
/// This is separate from API DTOs - used only for local storage
class AssignmentPersistence {
  /// Convert Assignment to JSON for local storage
  static Map<String, dynamic> toJson(Assignment assignment) {
    return {
      'id': assignment.id,
      'timeSlotId': assignment.timeSlotId,
      'childId': assignment.childId,
      'vehicleId': assignment.vehicleId,
      'driverId': assignment.driverId,
      'type': assignment.type.name,
      'assignedAt': assignment.assignedAt.toIso8601String(),
      'assignedBy': assignment.assignedBy,
      'isActive': assignment.isActive,
      'notes': assignment.notes,
    };
  }

  /// Convert JSON from local storage to Assignment
  static Assignment fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as String,
      timeSlotId: json['timeSlotId'] as String,
      childId: json['childId'] as String?,
      vehicleId: json['vehicleId'] as String?,
      driverId: json['driverId'] as String?,
      type: AssignmentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AssignmentType.child,
      ),
      assignedAt: DateTime.parse(json['assignedAt'] as String),
      assignedBy: json['assignedBy'] as String,
      isActive: json['isActive'] as bool? ?? true,
      notes: json['notes'] as String?,
    );
  }
}
