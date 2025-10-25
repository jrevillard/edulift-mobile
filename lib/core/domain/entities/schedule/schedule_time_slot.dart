// EduLift Mobile - Schedule Time Slot Entity
// Represents available time slots for scheduling

import 'package:equatable/equatable.dart';

/// Represents an available time slot for scheduling
class ScheduleTimeSlot extends Equatable {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;
  final List<String> conflictingScheduleIds;
  final String? groupId;
  final Map<String, dynamic> metadata;

  const ScheduleTimeSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    required this.conflictingScheduleIds,
    this.groupId,
    this.metadata = const {},
  });

  /// Duration of the time slot
  Duration get duration => endTime.difference(startTime);

  /// Check if this time slot conflicts with another
  bool conflictsWith(DateTime otherStart, DateTime otherEnd) {
    return startTime.isBefore(otherEnd) && endTime.isAfter(otherStart);
  }

  /// Create a copy with updated fields
  ScheduleTimeSlot copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAvailable,
    List<String>? conflictingScheduleIds,
    String? groupId,
    Map<String, dynamic>? metadata,
  }) {
    return ScheduleTimeSlot(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAvailable: isAvailable ?? this.isAvailable,
      conflictingScheduleIds:
          conflictingScheduleIds ?? this.conflictingScheduleIds,
      groupId: groupId ?? this.groupId,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to JSON
  // Implementation removed for now - can be added later if needed

  /// Create from JSON
  // Implementation removed for now - can be added later if needed

  @override
  List<Object?> get props => [
    id,
    startTime,
    endTime,
    isAvailable,
    conflictingScheduleIds,
    groupId,
    metadata,
  ];
}
