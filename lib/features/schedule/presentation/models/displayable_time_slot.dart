import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:edulift/core/domain/entities/schedule.dart';

part 'displayable_time_slot.freezed.dart';

/// Presentation model combining configured time slots with actual schedule slots
///
/// This solves the "configured but not created" problem by unifying:
/// - Configuration data (from ScheduleConfig.scheduleHours)
/// - Entity data (from ScheduleSlot if it exists)
///
/// This is a VIEW MODEL - it lives in the presentation layer only.
///
/// **Architecture Decision:**
/// We store configuration data in ScheduleConfig and actual schedule slots
/// as ScheduleSlot entities. This presentation model merges them to display
/// ALL configured time slots, whether they have been created in the backend or not.
///
/// **Example:**
/// ```dart
/// // Config says Monday should have 08:00 and 15:00 slots
/// // Backend only has a ScheduleSlot for 08:00
/// // Result: Two DisplayableTimeSlots:
/// // 1. Monday 08:00 (existsInBackend: true, scheduleSlot: ScheduleSlot(...))
/// // 2. Monday 15:00 (existsInBackend: false, scheduleSlot: null)
/// ```
@freezed
abstract class DisplayableTimeSlot with _$DisplayableTimeSlot {
  const DisplayableTimeSlot._();

  const factory DisplayableTimeSlot({
    /// Day of the week for this slot
    required DayOfWeek dayOfWeek,

    /// Time of day for this slot
    required TimeOfDayValue timeOfDay,

    /// Week identifier (ISO format: "2025-W46")
    required String week,

    /// The actual schedule slot from backend (null if not yet created)
    ScheduleSlot? scheduleSlot,

    /// Whether this slot exists in the backend
    required bool existsInBackend,
  }) = _DisplayableTimeSlot;

  /// Whether this slot has any vehicle assignments
  bool get hasVehicles => scheduleSlot?.vehicleAssignments.isNotEmpty ?? false;

  /// Number of vehicles assigned to this slot
  int get vehicleCount => scheduleSlot?.vehicleAssignments.length ?? 0;

  /// Whether this slot can accept more vehicles
  bool get canAddVehicle {
    if (!existsInBackend) {
      return true; // Not created yet, so can add first vehicle
    }
    final maxVehicles = scheduleSlot?.maxVehicles ?? 0;
    return vehicleCount < maxVehicles;
  }

  /// Get all vehicle assignments (empty list if slot doesn't exist)
  List<VehicleAssignment> get vehicleAssignments =>
      scheduleSlot?.vehicleAssignments ?? [];

  /// Composite key for this time slot (unique identifier)
  String get compositeKey => '${dayOfWeek.name}_${timeOfDay.toApiFormat()}';
}
