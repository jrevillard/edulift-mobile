import 'package:equatable/equatable.dart';

/// Types of schedule conflicts
enum ConflictType {
  timeOverlap,
  resourceConflict,
  locationConflict,
  driverUnavailable,
  vehicleUnavailable,
  childUnavailable,
}

/// Severity levels for conflicts
enum ConflictSeverity { low, medium, high, critical }

/// Represents a conflict in the schedule system
class ScheduleConflict extends Equatable {
  final String id;
  final String firstTimeSlotId;
  final String secondTimeSlotId;
  final ConflictType type;
  final ConflictSeverity severity;
  final String description;
  final DateTime detectedAt;
  final bool isResolved;
  final DateTime? resolvedAt;
  final String? resolution;

  const ScheduleConflict({
    required this.id,
    required this.firstTimeSlotId,
    required this.secondTimeSlotId,
    required this.type,
    required this.severity,
    required this.description,
    required this.detectedAt,
    this.isResolved = false,
    this.resolvedAt,
    this.resolution,
  });

  @override
  List<Object?> get props => [
        id,
        firstTimeSlotId,
        secondTimeSlotId,
        type,
        severity,
        description,
        detectedAt,
        isResolved,
        resolvedAt,
        resolution,
      ];

  /// Factory constructor to create a ScheduleConflict with auto-calculated severity
  /// based on the conflict type
  factory ScheduleConflict.fromType({
    required String id,
    required String firstTimeSlotId,
    String? secondTimeSlotId,
    required ConflictType type,
    required String description,
    required DateTime detectedAt,
    bool isResolved = false,
    DateTime? resolvedAt,
    String? resolution,
  }) {
    // Determine severity based on type
    final ConflictSeverity severity;
    if (type == ConflictType.timeOverlap ||
        type == ConflictType.vehicleUnavailable) {
      severity = ConflictSeverity.high;
    } else if (type == ConflictType.driverUnavailable) {
      severity = ConflictSeverity.critical;
    } else {
      severity = ConflictSeverity.medium;
    }

    return ScheduleConflict(
      id: id,
      firstTimeSlotId: firstTimeSlotId,
      secondTimeSlotId: secondTimeSlotId ?? '',
      type: type,
      severity: severity,
      description: description,
      detectedAt: detectedAt,
      isResolved: isResolved,
      resolvedAt: resolvedAt,
      resolution: resolution,
    );
  }

  ScheduleConflict copyWith({
    String? id,
    String? firstTimeSlotId,
    String? secondTimeSlotId,
    ConflictType? type,
    ConflictSeverity? severity,
    String? description,
    DateTime? detectedAt,
    bool? isResolved,
    DateTime? resolvedAt,
    String? resolution,
  }) {
    return ScheduleConflict(
      id: id ?? this.id,
      firstTimeSlotId: firstTimeSlotId ?? this.firstTimeSlotId,
      secondTimeSlotId: secondTimeSlotId ?? this.secondTimeSlotId,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      description: description ?? this.description,
      detectedAt: detectedAt ?? this.detectedAt,
      isResolved: isResolved ?? this.isResolved,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolution: resolution ?? this.resolution,
    );
  }
}
