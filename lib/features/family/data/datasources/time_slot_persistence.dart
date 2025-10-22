// Local Persistence Helper for TimeSlot
// Handles JSON serialization for local storage only (not API communication)

import 'package:edulift/core/domain/entities/schedule.dart';

/// Local persistence helper for TimeSlot entity
/// This is separate from API DTOs - used only for local storage
class TimeSlotPersistence {
  /// Convert TimeSlot to JSON for local storage
  static Map<String, dynamic> toJson(TimeSlot timeSlot) {
    return {
      'id': timeSlot.id,
      'scheduleId': timeSlot.scheduleId,
      'startTime': timeSlot.startTime.toIso8601String(),
      'endTime': timeSlot.endTime.toIso8601String(),
      'title': timeSlot.title,
      'description': timeSlot.description,
      'location': timeSlot.location,
      'assignedChildIds': timeSlot.assignedChildIds,
      'assignedVehicleId': timeSlot.assignedVehicleId,
      'driverId': timeSlot.driverId,
      'isRecurring': timeSlot.isRecurring,
      'recurrencePattern': timeSlot.recurrencePattern,
      'isActive': timeSlot.isActive,
      'createdAt': timeSlot.createdAt.toIso8601String(),
      'updatedAt': timeSlot.updatedAt.toIso8601String()
    };
  }

  /// Convert JSON from local storage to TimeSlot
  static TimeSlot fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'] as String,
      scheduleId: json['scheduleId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      title: json['title'] as String,
      description: json['description'] as String?,
      location: json['location'] as String?,
      assignedChildIds: List<String>.from(json['assignedChildIds'] ?? []),
      assignedVehicleId: json['assignedVehicleId'] as String?,
      driverId: json['driverId'] as String?,
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurrencePattern: json['recurrencePattern'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String)
    );
  }
}
