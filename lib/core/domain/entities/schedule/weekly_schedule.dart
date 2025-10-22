import 'package:equatable/equatable.dart';
import 'time_slot.dart';
import 'assignment.dart';

/// Represents a weekly schedule structure
class WeeklySchedule extends Equatable {
  final String id;
  final String familyId;
  final String name;
  final DateTime weekStartDate;
  final List<TimeSlot> timeSlots;
  final List<Assignment> assignments;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? description;

  const WeeklySchedule({
    required this.id,
    required this.familyId,
    required this.name,
    required this.weekStartDate,
    required this.timeSlots,
    this.assignments = const [],
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.description,
  });

  @override
  List<Object?> get props => [
    id,
    familyId,
    name,
    weekStartDate,
    timeSlots,
    assignments,
    isActive,
    createdAt,
    updatedAt,
    description,
  ];

  WeeklySchedule copyWith({
    String? id,
    String? familyId,
    String? name,
    DateTime? weekStartDate,
    List<TimeSlot>? timeSlots,
    List<Assignment>? assignments,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? description,
  }) {
    return WeeklySchedule(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      name: name ?? this.name,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      timeSlots: timeSlots ?? this.timeSlots,
      assignments: assignments ?? this.assignments,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      description: description ?? this.description,
    );
  }

  /// Create an empty WeeklySchedule for testing and fallback scenarios
  factory WeeklySchedule.empty() {
    return WeeklySchedule(
      id: '',
      familyId: '',
      name: '',
      weekStartDate: DateTime.now(),
      timeSlots: const [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// WeeklySchedule is a domain entity - no JSON serialization methods
  /// Use WeeklyScheduleDto for data transfer and API communication
}
