// EduLift Mobile - Recurrence Pattern Entity
// Defines how schedules repeat over time

import 'package:equatable/equatable.dart';
import 'day_of_week.dart';

/// Enum for recurrence frequency
enum RecurrenceFrequency { daily, weekly, monthly, yearly }

/// Represents a recurrence pattern for schedules
class RecurrencePattern extends Equatable {
  final String id;
  final RecurrenceFrequency frequency;
  final int interval; // Every N days/weeks/months/years
  final List<DayOfWeek>? daysOfWeek; // For weekly recurrence
  final List<int>? daysOfMonth; // For monthly recurrence (1-31)
  final List<int>? monthsOfYear; // For yearly recurrence (1-12)
  final DateTime? endDate;
  final int? occurrences; // Number of occurrences before stopping
  final Map<String, dynamic> metadata;

  const RecurrencePattern({
    required this.id,
    required this.frequency,
    this.interval = 1,
    this.daysOfWeek,
    this.daysOfMonth,
    this.monthsOfYear,
    this.endDate,
    this.occurrences,
    this.metadata = const {},
  });

  /// Create a daily recurrence pattern
  factory RecurrencePattern.daily({
    required String id,
    int interval = 1,
    DateTime? endDate,
    int? occurrences,
  }) {
    return RecurrencePattern(
      id: id,
      frequency: RecurrenceFrequency.daily,
      interval: interval,
      endDate: endDate,
      occurrences: occurrences,
    );
  }

  /// Create a weekly recurrence pattern
  factory RecurrencePattern.weekly({
    required String id,
    int interval = 1,
    List<DayOfWeek>? daysOfWeek,
    DateTime? endDate,
    int? occurrences,
  }) {
    return RecurrencePattern(
      id: id,
      frequency: RecurrenceFrequency.weekly,
      interval: interval,
      daysOfWeek: daysOfWeek,
      endDate: endDate,
      occurrences: occurrences,
    );
  }

  /// Create a monthly recurrence pattern
  factory RecurrencePattern.monthly({
    required String id,
    int interval = 1,
    List<int>? daysOfMonth,
    DateTime? endDate,
    int? occurrences,
  }) {
    return RecurrencePattern(
      id: id,
      frequency: RecurrenceFrequency.monthly,
      interval: interval,
      daysOfMonth: daysOfMonth,
      endDate: endDate,
      occurrences: occurrences,
    );
  }

  /// Create a yearly recurrence pattern
  factory RecurrencePattern.yearly({
    required String id,
    int interval = 1,
    List<int>? monthsOfYear,
    DateTime? endDate,
    int? occurrences,
  }) {
    return RecurrencePattern(
      id: id,
      frequency: RecurrenceFrequency.yearly,
      interval: interval,
      monthsOfYear: monthsOfYear,
      endDate: endDate,
      occurrences: occurrences,
    );
  }

  /// Check if the recurrence is still active at a given date
  bool isActiveAt(DateTime date) {
    if (endDate != null && date.isAfter(endDate!)) {
      return false;
    }
    return true;
  }

  /// Calculate the next occurrence after a given date
  DateTime? getNextOccurrence(DateTime baseDate, DateTime afterDate) {
    if (!isActiveAt(afterDate)) {
      return null;
    }

    switch (frequency) {
      case RecurrenceFrequency.daily:
        return _getNextDailyOccurrence(baseDate, afterDate);
      case RecurrenceFrequency.weekly:
        return _getNextWeeklyOccurrence(baseDate, afterDate);
      case RecurrenceFrequency.monthly:
        return _getNextMonthlyOccurrence(baseDate, afterDate);
      case RecurrenceFrequency.yearly:
        return _getNextYearlyOccurrence(baseDate, afterDate);
    }
  }

  DateTime? _getNextDailyOccurrence(DateTime baseDate, DateTime afterDate) {
    var nextDate = baseDate;
    while (
        nextDate.isBefore(afterDate) || nextDate.isAtSameMomentAs(afterDate)) {
      nextDate = nextDate.add(Duration(days: interval));
    }
    return isActiveAt(nextDate) ? nextDate : null;
  }

  DateTime? _getNextWeeklyOccurrence(DateTime baseDate, DateTime afterDate) {
    if (daysOfWeek == null || daysOfWeek!.isEmpty) {
      // Default to the same day of week as base date
      var nextDate = baseDate;
      while (nextDate.isBefore(afterDate) ||
          nextDate.isAtSameMomentAs(afterDate)) {
        nextDate = nextDate.add(Duration(days: 7 * interval));
      }
      return isActiveAt(nextDate) ? nextDate : null;
    }

    // Find the next occurrence on any of the specified days
    DateTime? earliest;
    for (final dayOfWeek in daysOfWeek!) {
      final nextDate = _getNextDateForDayOfWeek(baseDate, afterDate, dayOfWeek);
      if (nextDate != null &&
          (earliest == null || nextDate.isBefore(earliest))) {
        earliest = nextDate;
      }
    }
    return earliest;
  }

  DateTime? _getNextDateForDayOfWeek(
    DateTime baseDate,
    DateTime afterDate,
    DayOfWeek dayOfWeek,
  ) {
    var currentWeek = baseDate;
    while (currentWeek.isBefore(afterDate)) {
      currentWeek = currentWeek.add(Duration(days: 7 * interval));
    }

    // Find the correct day of week in this week
    final weekStart = currentWeek.subtract(
      Duration(days: currentWeek.weekday - 1),
    );
    final targetDate = weekStart.add(Duration(days: dayOfWeek.weekday - 1));

    return targetDate.isAfter(afterDate) && isActiveAt(targetDate)
        ? targetDate
        : null;
  }

  DateTime? _getNextMonthlyOccurrence(DateTime baseDate, DateTime afterDate) {
    // Simplified monthly recurrence - same day of month
    var nextDate = DateTime(
      baseDate.year,
      baseDate.month + interval,
      baseDate.day,
    );
    while (
        nextDate.isBefore(afterDate) || nextDate.isAtSameMomentAs(afterDate)) {
      nextDate = DateTime(
        nextDate.year,
        nextDate.month + interval,
        nextDate.day,
      );
    }
    return isActiveAt(nextDate) ? nextDate : null;
  }

  DateTime? _getNextYearlyOccurrence(DateTime baseDate, DateTime afterDate) {
    // Simplified yearly recurrence - same month and day
    var nextDate = DateTime(
      baseDate.year + interval,
      baseDate.month,
      baseDate.day,
    );
    while (
        nextDate.isBefore(afterDate) || nextDate.isAtSameMomentAs(afterDate)) {
      nextDate = DateTime(
        nextDate.year + interval,
        nextDate.month,
        nextDate.day,
      );
    }
    return isActiveAt(nextDate) ? nextDate : null;
  }

  /// Create a copy with updated fields
  RecurrencePattern copyWith({
    String? id,
    RecurrenceFrequency? frequency,
    int? interval,
    List<DayOfWeek>? daysOfWeek,
    List<int>? daysOfMonth,
    List<int>? monthsOfYear,
    DateTime? endDate,
    int? occurrences,
    Map<String, dynamic>? metadata,
  }) {
    return RecurrencePattern(
      id: id ?? this.id,
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      daysOfMonth: daysOfMonth ?? this.daysOfMonth,
      monthsOfYear: monthsOfYear ?? this.monthsOfYear,
      endDate: endDate ?? this.endDate,
      occurrences: occurrences ?? this.occurrences,
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
        frequency,
        interval,
        daysOfWeek,
        daysOfMonth,
        monthsOfYear,
        endDate,
        occurrences,
        metadata,
      ];
}
