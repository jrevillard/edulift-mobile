import 'package:equatable/equatable.dart';
import 'time_of_day.dart';

/// Type of aggregate period in a schedule
enum PeriodType {
  morning('Morning'),
  afternoon('Afternoon'),
  evening('Evening'),
  allDay('All Day');

  const PeriodType(this.label);

  final String label;

  /// Parse period type from string label
  static PeriodType fromLabel(String label) {
    final lowerLabel = label.toLowerCase();
    switch (lowerLabel) {
      case 'morning':
      case 'matin':
        return PeriodType.morning;
      case 'afternoon':
      case 'après-midi':
      case 'apres-midi':
        return PeriodType.afternoon;
      case 'evening':
      case 'soir':
        return PeriodType.evening;
      case 'all day':
      case 'toute la journée':
      case 'toute la journee':
        return PeriodType.allDay;
      default:
        throw ArgumentError('Unknown period type: $label');
    }
  }

  @override
  String toString() => label;
}

/// Represents either an aggregate period (Morning/Afternoon) OR a specific time slot
///
/// This sealed class enables exhaustive pattern matching and compile-time guarantees
/// for handling different period representations in the schedule domain.
///
/// Example usage:
/// ```dart
/// // Pattern matching on period type
/// switch (period) {
///   case AggregatePeriod(:final type, :final timeSlots):
///     print('Period: ${type.label}, Slots: ${timeSlots.length}');
///   case SpecificTimeSlot(:final timeSlot):
///     print('Time: ${timeSlot.toApiFormat()}');
/// }
/// ```
sealed class SchedulePeriod extends Equatable {
  const SchedulePeriod();

  /// Checks if this is an aggregate period
  bool get isAggregate => this is AggregatePeriod;

  /// Checks if this is a specific time slot
  bool get isSpecific => this is SpecificTimeSlot;

  /// Gets all time slots contained in this period
  List<TimeOfDayValue> get allTimeSlots {
    return switch (this) {
      AggregatePeriod(:final timeSlots) => timeSlots,
      SpecificTimeSlot(:final timeSlot) => [timeSlot],
    };
  }

  /// Gets a display string for this period
  String get displayString {
    return switch (this) {
      AggregatePeriod(:final type, :final timeSlots) => timeSlots.isEmpty
          ? type.label
          : '${type.label} (${timeSlots.first.toApiFormat()} - ${timeSlots.last.toApiFormat()})',
      SpecificTimeSlot(:final timeSlot) => timeSlot.toApiFormat(),
    };
  }
}

/// Represents an aggregate period (Morning/Afternoon/Evening) containing multiple time slots
///
/// Used when the schedule is organized by broad periods rather than specific times.
/// Contains all the individual time slots that make up this period.
class AggregatePeriod extends SchedulePeriod {
  /// Type of aggregate period (Morning, Afternoon, Evening, All Day)
  final PeriodType type;

  /// All time slots contained in this period (sorted chronologically)
  final List<TimeOfDayValue> timeSlots;

  const AggregatePeriod({
    required this.type,
    required this.timeSlots,
  });

  /// Creates an aggregate period from a list of time strings
  factory AggregatePeriod.fromTimeStrings({
    required PeriodType type,
    required List<String> timeStrings,
  }) {
    final timeSlots = timeStrings
        .map((timeStr) => TimeOfDayValue.parse(timeStr))
        .toList()
      ..sort((a, b) => a.compareTo(b));

    return AggregatePeriod(type: type, timeSlots: timeSlots);
  }

  /// Gets the start time of this period (earliest time slot)
  TimeOfDayValue? get startTime => timeSlots.isEmpty ? null : timeSlots.first;

  /// Gets the end time of this period (latest time slot)
  TimeOfDayValue? get endTime => timeSlots.isEmpty ? null : timeSlots.last;

  /// Gets the duration of this period
  Duration? get duration {
    if (startTime == null || endTime == null) return null;
    return startTime!.difference(endTime!);
  }

  /// Checks if a specific time is contained in this period
  bool containsTime(TimeOfDayValue time) {
    return timeSlots.any((slot) => slot.isSameAs(time));
  }

  @override
  List<Object?> get props => [type, timeSlots];

  @override
  String toString() => 'AggregatePeriod(${type.label}, ${timeSlots.length} slots)';
}

/// Represents a specific time slot in the schedule
///
/// Used when the schedule operates at granular time level rather than
/// aggregated periods. Contains a single specific time.
class SpecificTimeSlot extends SchedulePeriod {
  /// The specific time of this slot
  final TimeOfDayValue timeSlot;

  const SpecificTimeSlot(this.timeSlot);

  /// Creates a specific time slot from a time string
  factory SpecificTimeSlot.parse(String timeString) {
    return SpecificTimeSlot(TimeOfDayValue.parse(timeString));
  }

  @override
  List<Object?> get props => [timeSlot];

  @override
  String toString() => 'SpecificTimeSlot(${timeSlot.toApiFormat()})';
}

/// Extension methods for working with lists of schedule periods
extension SchedulePeriodListExtensions on List<SchedulePeriod> {
  /// Gets all unique time slots across all periods
  List<TimeOfDayValue> get allTimeSlots {
    return expand((period) => period.allTimeSlots).toSet().toList()
      ..sort((a, b) => a.compareTo(b));
  }

  /// Gets only aggregate periods from the list
  List<AggregatePeriod> get aggregatePeriods {
    return whereType<AggregatePeriod>().toList();
  }

  /// Gets only specific time slots from the list
  List<SpecificTimeSlot> get specificTimeSlots {
    return whereType<SpecificTimeSlot>().toList();
  }

  /// Checks if all periods are aggregate
  bool get isAllAggregate => every((p) => p.isAggregate);

  /// Checks if all periods are specific
  bool get isAllSpecific => every((p) => p.isSpecific);
}
