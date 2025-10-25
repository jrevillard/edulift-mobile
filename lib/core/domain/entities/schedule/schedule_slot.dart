import 'package:equatable/equatable.dart';
import 'vehicle_assignment.dart';
import 'day_of_week.dart';
import 'time_of_day.dart';

/// Represents a time slot in the schedule grid
///
/// **TYPE-SAFE DOMAIN MODEL**
/// - Uses [DayOfWeek] enum instead of strings for day representation
/// - Uses [TimeOfDayValue] instead of strings for time representation
///
/// This ensures compile-time guarantees and eliminates string validation bugs.
class ScheduleSlot extends Equatable {
  final String id;
  final String groupId;

  /// Day of the week (type-safe enum)
  final DayOfWeek dayOfWeek;

  /// Time of this slot (type-safe value object)
  final TimeOfDayValue timeOfDay;

  /// Week identifier (ISO week format: "YYYY-WNN")
  final String week;

  final List<VehicleAssignment> vehicleAssignments;
  final int maxVehicles;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ScheduleSlot({
    required this.id,
    required this.groupId,
    required this.dayOfWeek,
    required this.timeOfDay,
    required this.week,
    required this.vehicleAssignments,
    required this.maxVehicles,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create an empty ScheduleSlot for error handling
  factory ScheduleSlot.empty() {
    return ScheduleSlot(
      id: '',
      groupId: '',
      dayOfWeek: DayOfWeek.monday,
      timeOfDay: TimeOfDayValue.midnight,
      week: '',
      vehicleAssignments: const [],
      maxVehicles: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  ScheduleSlot copyWith({
    String? id,
    String? groupId,
    DayOfWeek? dayOfWeek,
    TimeOfDayValue? timeOfDay,
    String? week,
    List<VehicleAssignment>? vehicleAssignments,
    int? maxVehicles,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduleSlot(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      week: week ?? this.week,
      vehicleAssignments: vehicleAssignments ?? this.vehicleAssignments,
      maxVehicles: maxVehicles ?? this.maxVehicles,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// ScheduleSlot is a domain entity - no JSON serialization methods
  /// Use ScheduleSlotDto for data transfer and API communication

  @override
  List<Object?> get props => [
        id,
        groupId,
        dayOfWeek,
        timeOfDay,
        week,
        vehicleAssignments,
        maxVehicles,
        createdAt,
        updatedAt,
      ];
}

// VehicleAssignment class moved to separate file: vehicle_assignment.dart
