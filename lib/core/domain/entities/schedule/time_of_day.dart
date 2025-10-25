import 'package:equatable/equatable.dart';

/// Immutable value object representing a specific time of day
///
/// Provides compile-time guarantees for time values with validation,
/// parsing, and conversion utilities. This replaces string-based time
/// representations throughout the schedule domain.
///
/// Example usage:
/// ```dart
/// // Create from validated components
/// final morning = TimeOfDayValue(7, 30);
///
/// // Parse from string
/// final afternoon = TimeOfDayValue.parse('14:00');
///
/// // Convert to API format
/// final apiTime = morning.toApiFormat(); // "07:30"
/// ```
class TimeOfDayValue extends Equatable {
  /// Hour component (0-23)
  final int hour;

  /// Minute component (0-59)
  final int minute;

  /// Creates a time of day with validation
  ///
  /// Throws [ArgumentError] if hour or minute are out of range
  const TimeOfDayValue(this.hour, this.minute)
    : assert(hour >= 0 && hour <= 23, 'Hour must be between 0 and 23'),
      assert(minute >= 0 && minute <= 59, 'Minute must be between 0 and 59');

  /// Creates a TimeOfDayValue from a string in HH:mm or H:mm format
  ///
  /// Examples: "07:30", "7:30", "14:00", "23:59"
  ///
  /// Throws [FormatException] if the string is not in valid format
  factory TimeOfDayValue.parse(String time) {
    final regex = RegExp(r'^(\d{1,2}):(\d{2})$');
    final match = regex.firstMatch(time);

    if (match == null) {
      throw FormatException(
        'Invalid time format: "$time". Expected format: HH:mm or H:mm',
      );
    }

    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);

    if (hour < 0 || hour > 23) {
      throw FormatException('Hour must be between 0 and 23, got: $hour');
    }
    if (minute < 0 || minute > 59) {
      throw FormatException('Minute must be between 0 and 59, got: $minute');
    }

    return TimeOfDayValue(hour, minute);
  }

  /// Creates a TimeOfDayValue from DateTime
  factory TimeOfDayValue.fromDateTime(DateTime dateTime) {
    return TimeOfDayValue(dateTime.hour, dateTime.minute);
  }

  /// Converts to API format string (HH:mm with zero-padding)
  ///
  /// Example: TimeOfDayValue(7, 30).toApiFormat() → "07:30"
  String toApiFormat() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Converts to DateTime on a specific date
  DateTime toDateTime(DateTime date) {
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  /// Validates if this is a valid time
  ///
  /// Returns true if hour is 0-23 and minute is 0-59
  bool get isValid => hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;

  /// Compares this time with another
  ///
  /// Returns:
  /// - negative if this time is before [other]
  /// - 0 if times are equal
  /// - positive if this time is after [other]
  int compareTo(TimeOfDayValue other) {
    if (hour != other.hour) {
      return hour.compareTo(other.hour);
    }
    return minute.compareTo(other.minute);
  }

  /// Returns true if this time is before [other]
  bool isBefore(TimeOfDayValue other) => compareTo(other) < 0;

  /// Returns true if this time is after [other]
  bool isAfter(TimeOfDayValue other) => compareTo(other) > 0;

  /// Returns true if this time is the same as [other]
  bool isSameAs(TimeOfDayValue other) => compareTo(other) == 0;

  /// Returns the duration between this time and [other]
  Duration difference(TimeOfDayValue other) {
    final thisMinutes = hour * 60 + minute;
    final otherMinutes = other.hour * 60 + other.minute;
    return Duration(minutes: (thisMinutes - otherMinutes).abs());
  }

  /// Adds duration to this time (wraps around midnight)
  TimeOfDayValue add(Duration duration) {
    final totalMinutes = hour * 60 + minute + duration.inMinutes;
    final newHour = (totalMinutes ~/ 60) % 24;
    final newMinute = totalMinutes % 60;
    return TimeOfDayValue(newHour, newMinute);
  }

  /// Subtracts duration from this time (wraps around midnight)
  TimeOfDayValue subtract(Duration duration) {
    final totalMinutes = hour * 60 + minute - duration.inMinutes;
    final adjustedMinutes = totalMinutes < 0
        ? totalMinutes + 24 * 60
        : totalMinutes;
    final newHour = (adjustedMinutes ~/ 60) % 24;
    final newMinute = adjustedMinutes % 60;
    return TimeOfDayValue(newHour, newMinute);
  }

  /// Returns a human-readable 24-hour format string
  ///
  /// Example: "07:30", "14:00"
  @override
  String toString() => toApiFormat();

  /// Common time constants
  static const TimeOfDayValue midnight = TimeOfDayValue(0, 0);
  static const TimeOfDayValue noon = TimeOfDayValue(12, 0);
  static const TimeOfDayValue endOfDay = TimeOfDayValue(23, 59);

  @override
  List<Object?> get props => [hour, minute];
}
