/// Timezone utilities for schedule management
/// Handles conversion between UTC and local timezones for schedule slots
///
/// CRITICAL CONTRACT WITH BACKEND:
/// - Backend stores ALL scheduleHours as UTC times (e.g., {"MONDAY": ["05:30"]})
/// - Mobile MUST convert User Timezone ↔ UTC at API boundaries
/// - Day boundary crossing MUST be handled correctly
///
/// Example: Paris user (UTC+1) creates Monday 00:30 local time
///   → Converts to Sunday 23:30 UTC
///   → Stored as {"SUNDAY": ["23:30"]}
///   → Displays back as "Monday 00:30" to Paris user

import 'package:timezone/timezone.dart' as tz;

/// Weekday constants in API format (uppercase)
const List<String> _weekdayNames = [
  'MONDAY',
  'TUESDAY',
  'WEDNESDAY',
  'THURSDAY',
  'FRIDAY',
  'SATURDAY',
  'SUNDAY',
];

/// Convert single time string from user timezone to UTC
///
/// @param localTime - Time in HH:MM format in user's local timezone (e.g., "07:30")
/// @param userTimezone - User's IANA timezone (e.g., "Europe/Paris")
/// @returns UTC time in HH:MM format (e.g., "05:30")
///
/// Example:
/// ```dart
/// // Paris timezone (UTC+2 in summer)
/// convertLocalToUtcTimeString("07:30", "Europe/Paris") // Returns "05:30"
///
/// // Handles day boundary crossing - returns time only, day handled separately
/// convertLocalToUtcTimeString("00:30", "Europe/Paris") // Returns "22:30" (previous day in UTC)
/// ```
String convertLocalToUtcTimeString(String localTime, String userTimezone) {
  // Parse the time string
  final timeParts = localTime.split(':');
  if (timeParts.length != 2) {
    throw ArgumentError('Invalid time format. Expected HH:MM, got: $localTime');
  }

  final hours = int.parse(timeParts[0]);
  final minutes = int.parse(timeParts[1]);

  // Get timezone location
  final location = tz.getLocation(userTimezone);

  // Create a datetime in the user's timezone using current date
  // This ensures correct DST offset for the current season
  final now = DateTime.now();
  final localDateTime = tz.TZDateTime(
    location,
    now.year,
    now.month,
    now.day,
    hours,
    minutes,
  );

  // Convert to UTC
  final utcDateTime = localDateTime.toUtc();

  // Format as HH:MM
  final utcHours = utcDateTime.hour.toString().padLeft(2, '0');
  final utcMinutes = utcDateTime.minute.toString().padLeft(2, '0');

  return '$utcHours:$utcMinutes';
}

/// Convert single time string from UTC to user timezone
///
/// @param utcTime - Time in HH:MM format in UTC (e.g., "05:30")
/// @param userTimezone - User's IANA timezone (e.g., "Europe/Paris")
/// @returns Local time in HH:MM format (e.g., "07:30")
///
/// Example:
/// ```dart
/// // Paris timezone (UTC+2 in summer)
/// convertUtcToLocalTimeString("05:30", "Europe/Paris") // Returns "07:30"
///
/// // Handles day boundary crossing - returns time only, day handled separately
/// convertUtcToLocalTimeString("22:30", "Europe/Paris") // Returns "00:30" (next day in Paris)
/// ```
String convertUtcToLocalTimeString(String utcTime, String userTimezone) {
  // Parse the time string
  final timeParts = utcTime.split(':');
  if (timeParts.length != 2) {
    throw ArgumentError('Invalid time format. Expected HH:MM, got: $utcTime');
  }

  final hours = int.parse(timeParts[0]);
  final minutes = int.parse(timeParts[1]);

  // Get timezone location
  final location = tz.getLocation(userTimezone);

  // Create a UTC datetime with the specified time using current date
  // This ensures correct DST offset for the current season
  final now = DateTime.now();
  final utcDateTime = DateTime.utc(
    now.year,
    now.month,
    now.day,
    hours,
    minutes,
  );

  // Convert to user's timezone
  final localDateTime = tz.TZDateTime.from(utcDateTime, location);

  // Format as HH:MM
  final localHours = localDateTime.hour.toString().padLeft(2, '0');
  final localMinutes = localDateTime.minute.toString().padLeft(2, '0');

  return '$localHours:$localMinutes';
}

/// Convert entire scheduleHours map from user timezone to UTC
///
/// CRITICAL: Handles day boundary crossing! A time slot can move to a different weekday.
///
/// @param localScheduleHours - scheduleHours with local times
/// @param userTimezone - User's IANA timezone
/// @returns scheduleHours with UTC times (may have different weekdays due to boundary crossing!)
///
/// Example:
/// ```dart
/// // Paris timezone (UTC+2 in summer)
/// // Monday 00:30 in Paris → Sunday 22:30 in UTC (crosses day boundary!)
/// convertScheduleHoursToUtc(
///   {"MONDAY": ["00:30", "07:00"]},
///   "Europe/Paris"
/// )
/// // Returns: {"SUNDAY": ["22:30"], "MONDAY": ["05:00"]}
/// ```
Map<String, List<String>> convertScheduleHoursToUtc(
  Map<String, List<String>> localScheduleHours,
  String userTimezone,
) {
  final utcScheduleHours = <String, List<String>>{};
  final location = tz.getLocation(userTimezone);

  // Weekday index map (MONDAY = 0, TUESDAY = 1, ..., SUNDAY = 6)
  final weekdayMap = <String, int>{
    'MONDAY': 0,
    'TUESDAY': 1,
    'WEDNESDAY': 2,
    'THURSDAY': 3,
    'FRIDAY': 4,
    'SATURDAY': 5,
    'SUNDAY': 6,
  };

  // Process each weekday and its time slots
  localScheduleHours.forEach((weekday, timeSlots) {
    final dayOffset = weekdayMap[weekday.toUpperCase()] ?? 0;

    for (final timeSlot in timeSlots) {
      // Parse time
      final timeParts = timeSlot.split(':');
      if (timeParts.length != 2) continue;

      final hours = int.parse(timeParts[0]);
      final minutes = int.parse(timeParts[1]);

      // Create date for this specific day and time in user's timezone
      // Calculate week starting from current date for correct DST offset
      final now = DateTime.now();
      // Get Monday of current week
      final currentMonday = now.subtract(Duration(days: now.weekday - 1));
      final dayDate = currentMonday.add(Duration(days: dayOffset));
      final localDateTime = tz.TZDateTime(
        location,
        dayDate.year,
        dayDate.month,
        dayDate.day,
        hours,
        minutes,
      );

      // Convert to UTC
      final utcDateTime = localDateTime.toUtc();

      // Get the weekday in UTC (might be different due to timezone shift!)
      // DateTime.weekday: 1 = Monday, 7 = Sunday
      final utcWeekdayIndex = utcDateTime.weekday == 7
          ? 6
          : utcDateTime.weekday - 1;
      final utcWeekday = _weekdayNames[utcWeekdayIndex];

      // Get the time in UTC
      final utcHours = utcDateTime.hour.toString().padLeft(2, '0');
      final utcMinutes = utcDateTime.minute.toString().padLeft(2, '0');
      final utcTime = '$utcHours:$utcMinutes';

      // Add to the appropriate weekday bucket in UTC
      if (!utcScheduleHours.containsKey(utcWeekday)) {
        utcScheduleHours[utcWeekday] = [];
      }
      utcScheduleHours[utcWeekday]!.add(utcTime);
    }
  });

  // Sort time slots for each weekday
  utcScheduleHours.forEach((weekday, times) {
    times.sort();
  });

  return utcScheduleHours;
}

/// Convert entire scheduleHours map from UTC to user timezone
///
/// CRITICAL: Handles day boundary crossing! A time slot can move to a different weekday.
///
/// @param utcScheduleHours - scheduleHours with UTC times
/// @param userTimezone - User's IANA timezone
/// @returns scheduleHours with local times (may have different weekdays!)
///
/// Example:
/// ```dart
/// // Paris timezone (UTC+2 in summer)
/// // Sunday 22:30 UTC → Monday 00:30 in Paris (crosses day boundary!)
/// convertScheduleHoursToLocal(
///   {"SUNDAY": ["22:30"], "MONDAY": ["05:00"]},
///   "Europe/Paris"
/// )
/// // Returns: {"MONDAY": ["00:30", "07:00"]}
/// ```
Map<String, List<String>> convertScheduleHoursToLocal(
  Map<String, List<String>> utcScheduleHours,
  String userTimezone,
) {
  final localScheduleHours = <String, List<String>>{};
  final location = tz.getLocation(userTimezone);

  // Weekday index map (MONDAY = 0, TUESDAY = 1, ..., SUNDAY = 6)
  final weekdayMap = <String, int>{
    'MONDAY': 0,
    'TUESDAY': 1,
    'WEDNESDAY': 2,
    'THURSDAY': 3,
    'FRIDAY': 4,
    'SATURDAY': 5,
    'SUNDAY': 6,
  };

  // Process each weekday and its time slots
  utcScheduleHours.forEach((weekday, timeSlots) {
    final dayOffset = weekdayMap[weekday.toUpperCase()] ?? 0;

    for (final timeSlot in timeSlots) {
      // Parse time
      final timeParts = timeSlot.split(':');
      if (timeParts.length != 2) continue;

      final hours = int.parse(timeParts[0]);
      final minutes = int.parse(timeParts[1]);

      // Create UTC date for this specific day and time
      // Calculate week starting from current date for correct DST offset
      final now = DateTime.now();
      // Get Monday of current week
      final currentMonday = now.subtract(Duration(days: now.weekday - 1));
      final dayDate = currentMonday.add(Duration(days: dayOffset));
      final utcDate = DateTime.utc(
        dayDate.year,
        dayDate.month,
        dayDate.day,
        hours,
        minutes,
      );

      // Convert to user's timezone
      final localDateTime = tz.TZDateTime.from(utcDate, location);

      // Get the weekday in user's timezone (might be different!)
      // DateTime.weekday: 1 = Monday, 7 = Sunday
      final localWeekdayIndex = localDateTime.weekday == 7
          ? 6
          : localDateTime.weekday - 1;
      final localWeekday = _weekdayNames[localWeekdayIndex];

      // Get the time in user's timezone
      final localHours = localDateTime.hour.toString().padLeft(2, '0');
      final localMinutes = localDateTime.minute.toString().padLeft(2, '0');
      final localTime = '$localHours:$localMinutes';

      // Add to the appropriate weekday bucket in user's timezone
      if (!localScheduleHours.containsKey(localWeekday)) {
        localScheduleHours[localWeekday] = [];
      }
      localScheduleHours[localWeekday]!.add(localTime);
    }
  });

  // Sort time slots for each weekday
  localScheduleHours.forEach((weekday, times) {
    times.sort();
  });

  return localScheduleHours;
}

/// Get UTC weekday from local datetime
///
/// @param localDate - Date in user's timezone
/// @param userTimezone - User's IANA timezone
/// @returns UTC weekday (MONDAY, TUESDAY, etc.)
String getUtcWeekday(DateTime localDate, String userTimezone) {
  final location = tz.getLocation(userTimezone);

  // Create TZDateTime from the local date in the specified timezone
  final localDateTime = tz.TZDateTime(
    location,
    localDate.year,
    localDate.month,
    localDate.day,
    localDate.hour,
    localDate.minute,
  );

  // Convert to UTC
  final utcDateTime = localDateTime.toUtc();

  // Get UTC weekday index (1 = Monday, 7 = Sunday)
  final weekdayIndex = utcDateTime.weekday == 7 ? 6 : utcDateTime.weekday - 1;

  return _weekdayNames[weekdayIndex];
}

/// Get local weekday from UTC datetime
///
/// @param utcDate - Date in UTC
/// @param userTimezone - User's IANA timezone
/// @returns Local weekday (MONDAY, TUESDAY, etc.)
String getLocalWeekday(DateTime utcDate, String userTimezone) {
  final location = tz.getLocation(userTimezone);

  // Convert UTC date to user's timezone
  final localDateTime = tz.TZDateTime.from(utcDate, location);

  // Get local weekday index (1 = Monday, 7 = Sunday)
  final weekdayIndex = localDateTime.weekday == 7
      ? 6
      : localDateTime.weekday - 1;

  return _weekdayNames[weekdayIndex];
}

/// Initialize timezone database
/// Call this once at app startup before using any timezone utilities
Future<void> initializeTimezoneDatabase() async {
  // The timezone package requires initialization
  // This should be called in main() before runApp()
  // Note: The actual database loading is typically done via:
  // import 'package:timezone/data/latest.dart' as tz;
  // tz.initializeTimeZones();
}
