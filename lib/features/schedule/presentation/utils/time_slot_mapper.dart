import '../../../../generated/l10n/app_localizations.dart';
import 'package:edulift/core/domain/entities/schedule.dart';

/// Period of day enum for time slot categorization
enum PeriodOfDay {
  morning,
  midday,
  afternoon,
  evening,
  night,
  unknown,
}

/// Maps time slots from ScheduleConfig to localized labels
/// Handles extracting unique time slots and mapping them to user-friendly labels
class TimeSlotMapper {
  /// Extract all unique time slots from schedule config
  /// Returns a sorted list of unique time slots (e.g., ["08:00", "12:00", "16:00"])
  static List<String> extractTimeSlots(ScheduleConfig? config) {
    if (config == null) return [];

    final allTimeSlots = <String>{};

    // Collect all time slots from all days
    for (final daySlots in config.scheduleHours.values) {
      allTimeSlots.addAll(daySlots);
    }

    // Sort time slots chronologically
    final sortedSlots = allTimeSlots.toList()..sort();
    return sortedSlots;
  }

  /// Map time slot (HH:mm format) to localized label
  /// Examples:
  /// - "08:00" → "Morning"
  /// - "12:00" → "Midday"
  /// - "16:00" → "Afternoon"
  /// - "18:00" → "Evening"
  ///
  /// For unknown times, returns the time itself as label
  static String mapTimeToLabel(AppLocalizations l10n, String timeSlot) {
    // Parse hour from time slot (format: HH:mm)
    final parts = timeSlot.split(':');
    if (parts.length != 2) return timeSlot; // Invalid format, return as-is

    final hour = int.tryParse(parts[0]);
    if (hour == null) return timeSlot; // Invalid hour, return as-is

    // Map hour to label based on time of day
    // Morning: 5:00 - 11:59
    // Midday: 12:00 - 13:59
    // Afternoon: 14:00 - 17:59
    // Evening: 18:00 - 20:59
    // Night: 21:00 - 4:59 (not typically used for school transport)

    if (hour >= 5 && hour < 12) {
      return l10n.morning;
    } else if (hour >= 12 && hour < 14) {
      return l10n.midday;
    } else if (hour >= 14 && hour < 18) {
      return l10n.afternoon;
    } else if (hour >= 18 && hour < 21) {
      return l10n.evening;
    } else {
      // For other times (night/early morning), return time as label
      return timeSlot;
    }
  }

  /// Get time slots with their localized labels
  /// Returns a list of maps: [{"time": "08:00", "label": "Morning"}, ...]
  static List<Map<String, String>> getTimeSlotsWithLabels(
    AppLocalizations l10n,
    ScheduleConfig? config,
  ) {
    final timeSlots = extractTimeSlots(config);

    return timeSlots.map((timeSlot) {
      return {
        'time': timeSlot,
        'label': mapTimeToLabel(l10n, timeSlot),
      };
    }).toList();
  }


  /// Check if time slot is configured for a specific day
  /// dayKey should be uppercase (e.g., "MONDAY", "TUESDAY")
  static bool isTimeSlotAvailableForDay(
    ScheduleConfig? config,
    String dayKey,
    String timeSlot,
  ) {
    if (config == null) return false;

    final daySlots = config.scheduleHours[dayKey.toUpperCase()];
    if (daySlots == null) return false;

    return daySlots.contains(timeSlot);
  }

  /// Get all time slots for a given period label
  /// Example: "Morning" + ["08:00", "08:30", "12:00", "15:30"] → ["08:00", "08:30"]
  static List<String> getTimeSlotsForPeriod(
    AppLocalizations l10n,
    String periodLabel,
    List<String> allSlots,
  ) {
    if (allSlots.isEmpty) return [];

    // Group slots by period
    final grouped = <String, List<String>>{};
    for (final slot in allSlots) {
      final period = mapTimeToLabel(l10n, slot);
      grouped.putIfAbsent(period, () => []).add(slot);
    }

    // Return slots matching the period label
    return grouped[periodLabel] ?? [];
  }

  /// Get period of day for a time slot without context
  /// Internal helper for grouping logic
  /// Returns enum instead of localized string for type safety
  static PeriodOfDay getPeriodForTimeInternal(String timeSlot) {
    final parts = timeSlot.split(':');
    if (parts.length != 2) return PeriodOfDay.unknown;

    final hour = int.tryParse(parts[0]);
    if (hour == null || hour < 0 || hour > 23) return PeriodOfDay.unknown;

    if (hour >= 5 && hour < 12) return PeriodOfDay.morning;
    if (hour >= 12 && hour < 14) return PeriodOfDay.midday;
    if (hour >= 14 && hour < 18) return PeriodOfDay.afternoon;
    if (hour >= 18 && hour < 21) return PeriodOfDay.evening;
    return PeriodOfDay.night;
  }

  /// Get localized label for a period of day
  /// Use this to convert PeriodOfDay enum to user-facing string
  static String getPeriodLabel(AppLocalizations l10n, PeriodOfDay period) {
    switch (period) {
      case PeriodOfDay.morning:
        return l10n.morning;
      case PeriodOfDay.midday:
        return l10n.midday;
      case PeriodOfDay.afternoon:
        return l10n.afternoon;
      case PeriodOfDay.evening:
        return l10n.evening;
      case PeriodOfDay.night:
        return l10n.night;
      case PeriodOfDay.unknown:
        return l10n.unknown;
    }
  }

  /// Group time slots by period for Level 1 display
  /// Returns: [PeriodSlotGroup(label: "Morning", times: ["08:00", "09:00"]), PeriodSlotGroup(label: "Afternoon", times: ["16:00"])]
  /// This is used for compact Level 1 view where we show ONE slot per period
  static List<PeriodSlotGroup> getGroupedSlotsByPeriod(
    AppLocalizations l10n,
    ScheduleConfig? config,
  ) {
    if (config == null) return [];

    final timeSlots = extractTimeSlots(config);
    if (timeSlots.isEmpty) return [];

    // Group by period
    final grouped = <String, List<String>>{};
    for (final slot in timeSlots) {
      final label = mapTimeToLabel(l10n, slot);
      grouped.putIfAbsent(label, () => []).add(slot);
    }

    // Convert to list of PeriodSlotGroup maintaining chronological order
    final result = <PeriodSlotGroup>[];
    for (final entry in grouped.entries) {
      result.add(PeriodSlotGroup(
        label: entry.key,
        times: entry.value,
      ));
    }

    // Sort by first time slot in each group
    result.sort((a, b) {
      final aFirst = a.times.first;
      final bFirst = b.times.first;
      return aFirst.compareTo(bFirst);
    });

    return result;
  }
}
