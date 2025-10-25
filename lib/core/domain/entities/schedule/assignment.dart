import 'package:equatable/equatable.dart';

/// Represents an assignment in the schedule system
class Assignment extends Equatable {
  final String id;
  final String timeSlotId;
  final String? childId;
  final String? vehicleId;
  final String? driverId;
  final AssignmentType type;
  final DateTime assignedAt;
  final String assignedBy;
  final bool isActive;
  final String? notes;

  const Assignment({
    required this.id,
    required this.timeSlotId,
    this.childId,
    this.vehicleId,
    this.driverId,
    required this.type,
    required this.assignedAt,
    required this.assignedBy,
    this.isActive = true,
    this.notes,
  });

  /// Create an empty Assignment for testing and fallback scenarios
  factory Assignment.empty() {
    return Assignment(
      id: '',
      timeSlotId: '',
      type: AssignmentType.general,
      assignedAt: DateTime.now(),
      assignedBy: '',
    );
  }

  @override
  List<Object?> get props => [
    id,
    timeSlotId,
    childId,
    vehicleId,
    driverId,
    type,
    assignedAt,
    assignedBy,
    isActive,
    notes,
  ];

  Assignment copyWith({
    String? id,
    String? timeSlotId,
    String? childId,
    String? vehicleId,
    String? driverId,
    AssignmentType? type,
    DateTime? assignedAt,
    String? assignedBy,
    bool? isActive,
    String? notes,
  }) {
    return Assignment(
      id: id ?? this.id,
      timeSlotId: timeSlotId ?? this.timeSlotId,
      childId: childId ?? this.childId,
      vehicleId: vehicleId ?? this.vehicleId,
      driverId: driverId ?? this.driverId,
      type: type ?? this.type,
      assignedAt: assignedAt ?? this.assignedAt,
      assignedBy: assignedBy ?? this.assignedBy,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
    );
  }
}

enum AssignmentType { child, vehicle, driver, general }
