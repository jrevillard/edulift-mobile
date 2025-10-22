import 'package:equatable/equatable.dart';

/// Represents a time slot in a schedule
class TimeSlot extends Equatable {
  final String id;
  final String scheduleId;
  final DateTime startTime;
  final DateTime endTime;
  final String title;
  final String? description;
  final String? location;
  final List<String> assignedChildIds;
  final String? assignedVehicleId;
  final String? driverId;
  final bool isRecurring;
  final String? recurrencePattern;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TimeSlot({
    required this.id,
    required this.scheduleId,
    required this.startTime,
    required this.endTime,
    required this.title,
    this.description,
    this.location,
    this.assignedChildIds = const [],
    this.assignedVehicleId,
    this.driverId,
    this.isRecurring = false,
    this.recurrencePattern,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create an empty TimeSlot for testing and fallback scenarios
  factory TimeSlot.empty() {
    return TimeSlot(
      id: '',
      scheduleId: '',
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 1)),
      title: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    scheduleId,
    startTime,
    endTime,
    title,
    description,
    location,
    assignedChildIds,
    assignedVehicleId,
    driverId,
    isRecurring,
    recurrencePattern,
    isActive,
    createdAt,
    updatedAt,
  ];

  TimeSlot copyWith({
    String? id,
    String? scheduleId,
    DateTime? startTime,
    DateTime? endTime,
    String? title,
    String? description,
    String? location,
    List<String>? assignedChildIds,
    String? assignedVehicleId,
    String? driverId,
    bool? isRecurring,
    String? recurrencePattern,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TimeSlot(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      assignedChildIds: assignedChildIds ?? this.assignedChildIds,
      assignedVehicleId: assignedVehicleId ?? this.assignedVehicleId,
      driverId: driverId ?? this.driverId,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
