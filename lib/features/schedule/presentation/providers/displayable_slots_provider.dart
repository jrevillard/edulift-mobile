// EduLift Mobile - Displayable Slots Provider
// Merges schedule configuration with actual schedule slots
// to display ALL configured time slots (whether created or not)

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/entities/schedule.dart';
import '../models/displayable_time_slot.dart';
import './schedule_providers.dart';
import '../../../groups/presentation/providers/group_schedule_config_provider.dart';

part 'displayable_slots_provider.g.dart';

/// Provider for getting displayable time slots by merging configuration with actual slots
///
/// This provider solves the "configured but not created" problem by combining:
/// 1. ScheduleConfig.scheduleHours (what SHOULD exist)
/// 2. WeeklySchedule slots (what DOES exist)
///
/// **Result:** A unified list of DisplayableTimeSlot objects for ALL configured time slots,
/// regardless of whether they exist in the backend yet.
///
/// **Architecture Decision:**
/// - This is a PRESENTATION LAYER concern (view model pattern)
/// - Configuration defines the "shape" of the schedule (days/times)
/// - Backend slots contain the actual data (vehicles, assignments)
/// - UI should render ALL configured slots, marking uncreated ones as "add vehicle"
///
/// **Auto-dispose Pattern:**
/// - Watches both groupScheduleConfigProvider and weeklyScheduleProvider
/// - Automatically refreshes when either config or slots change
/// - Disposes when no longer needed
///
/// **Error Handling:**
/// - Returns AsyncValue.error if config is missing or invalid
/// - Returns AsyncValue.error if slots fail to load
/// - Returns empty list if config exists but has no schedule hours
///
/// **Usage Example:**
/// ```dart
/// final displayableSlotsAsync = ref.watch(
///   displayableSlotsProvider('group-123', '2025-W46')
/// );
/// displayableSlotsAsync.when(
///   data: (slots) => ScheduleGrid(displayableSlots: slots),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => ErrorWidget(err),
/// );
/// ```
///
/// **Parameters:**
/// - [groupId] - The unique identifier of the group
/// - [week] - ISO week format (YYYY-WW, e.g., "2025-W46")
///
/// **Returns:**
/// A Future that resolves to a list of [DisplayableTimeSlot] objects
@riverpod
Future<List<DisplayableTimeSlot>> displayableSlots(
  Ref ref,
  String groupId,
  String week,
) async {
  // Watch schedule config (defines what should exist)
  final configAsyncValue = ref.watch(groupScheduleConfigProvider(groupId));

  // Watch weekly schedule (defines what does exist)
  final actualSlots = await ref.watch(
    weeklyScheduleProvider(groupId, week).future,
  );

  // Handle config async value - return empty if loading or error
  final configState = configAsyncValue.when(
    data: (config) => config,
    loading: () => null,
    error: (_, __) => null,
  );

  // GUARD: If no config, return empty list
  // This allows UI to show "configure schedule" state
  if (configState == null) {
    return [];
  }

  // Build displayable slots by merging config with actual slots
  final displayableSlots = <DisplayableTimeSlot>[];

  // Iterate through each day in the config
  for (final dayEntry in configState.scheduleHours.entries) {
    final dayString = dayEntry.key; // e.g., "MONDAY"
    final timeStrings = dayEntry.value; // e.g., ["08:00", "15:00"]

    // Skip days with no time slots configured
    if (timeStrings.isEmpty) continue;

    // Parse day of week from string (case-insensitive)
    final DayOfWeek dayOfWeek;
    try {
      dayOfWeek = DayOfWeek.fromString(dayString);
    } catch (e) {
      // Skip invalid day names
      continue;
    }

    // Process each time slot for this day
    for (final timeString in timeStrings) {
      // Parse time of day from string
      final TimeOfDayValue timeOfDay;
      try {
        timeOfDay = TimeOfDayValue.parse(timeString);
      } catch (e) {
        // Skip invalid time formats
        continue;
      }

      // Find matching ScheduleSlot in actual slots (if it exists)
      final matchingSlot = _findMatchingSlot(actualSlots, dayOfWeek, timeOfDay);

      // Create DisplayableTimeSlot combining config + actual data
      final displayableSlot = DisplayableTimeSlot(
        dayOfWeek: dayOfWeek,
        timeOfDay: timeOfDay,
        week: week,
        scheduleSlot: matchingSlot,
        existsInBackend: matchingSlot != null,
      );

      displayableSlots.add(displayableSlot);
    }
  }

  // Sort by day of week, then by time
  displayableSlots.sort((a, b) {
    // First compare by day
    final dayComparison = a.dayOfWeek.weekday.compareTo(b.dayOfWeek.weekday);
    if (dayComparison != 0) return dayComparison;

    // Then compare by time
    return a.timeOfDay.compareTo(b.timeOfDay);
  });

  return displayableSlots;
}

/// Find a matching ScheduleSlot for the given day and time
///
/// **Logic:**
/// - Matches on dayOfWeek AND timeOfDay
/// - Returns null if no match found
///
/// **Note:** We use type-safe comparisons (DayOfWeek enum and TimeOfDayValue)
/// instead of string comparisons to avoid subtle bugs.
ScheduleSlot? _findMatchingSlot(
  List<ScheduleSlot> actualSlots,
  DayOfWeek dayOfWeek,
  TimeOfDayValue timeOfDay,
) {
  try {
    return actualSlots.firstWhere(
      (slot) =>
          slot.dayOfWeek == dayOfWeek &&
          slot.timeOfDay.hour == timeOfDay.hour &&
          slot.timeOfDay.minute == timeOfDay.minute,
    );
  } catch (e) {
    // No matching slot found
    return null;
  }
}
