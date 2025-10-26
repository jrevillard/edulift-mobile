/// Utilities for ISO 8601 week date calculations - Timezone Aware
///
/// ISO 8601 week date system:
/// - Week 1 is the first week with a Thursday in the new year
/// - Weeks start on Monday and end on Sunday
/// - Most years have 52 weeks, some have 53 weeks
/// - Week format: "YYYY-WNN" (e.g., "2025-W41")
///
/// All functions use the user's timezone for calculations to ensure
/// that week numbers and boundaries are consistent with the user's
/// local calendar, not UTC.
library;

import 'package:timezone/timezone.dart' as tz;

/// Get ISO 8601 week number for a given date in the user's timezone
///
/// Week 1 is the first week with a Thursday in the new year.
///
/// Algorithm explanation:
/// 1. ISO 8601 defines week 1 as "the week containing the first Thursday"
/// 2. Mathematical property: January 4 is ALWAYS in week 1 (regardless of weekday)
///    - This is because Jan 4 can be at most 3 days away from the first Thursday
///    - If Jan 1 = Mon/Tue/Wed, the first Thursday is Jan 4/5/6 (same week as Jan 4)
///    - If Jan 1 = Thu/Fri/Sat/Sun, the first Thursday is Jan 1/2/3/4 (same week as Jan 4)
/// 3. We use Jan 4 as a reliable anchor point to find week 1's Monday
/// 4. Then count weeks from that Monday to the target date's Thursday
///
/// @param datetime - DateTime object (assumed to be in UTC)
/// @param timezone - IANA timezone string (e.g., "Europe/Paris", "America/Los_Angeles")
/// @returns ISO week number (1-53)
///
/// @example
/// // For Asia/Tokyo (UTC+9):
/// // Sunday 2024-12-31 20:00 UTC = Monday 2025-01-01 05:00 JST
/// getISOWeekNumber(DateTime.utc(2024, 12, 31, 20), 'Asia/Tokyo')
/// // Returns: 1 (because it's Monday in Tokyo, which is Week 1 of 2025)
///
/// @example
/// // For America/Los_Angeles (UTC-8):
/// // Monday 2024-01-01 07:00 UTC = Sunday 2023-12-31 23:00 PST
/// getISOWeekNumber(DateTime.utc(2024, 1, 1, 7), 'America/Los_Angeles')
/// // Returns: 52 (because it's still Sunday in LA, which is Week 52 of 2023)
int getISOWeekNumber(DateTime datetime, [String timezone = 'UTC']) {
  // Convert UTC datetime to user's timezone
  final location = tz.getLocation(timezone);
  final tzDateTime = tz.TZDateTime.from(datetime, location);

  // Find Thursday of current week (Thursday determines which week a date belongs to)
  final thursday = tzDateTime.add(
    Duration(days: DateTime.thursday - tzDateTime.weekday),
  );

  // Jan 4 is ALWAYS in week 1 by ISO 8601 mathematical property
  // This is a reliable anchor point that works for all years
  final jan4 = tz.TZDateTime(location, thursday.year, 1, 4);

  // Find Monday of week 1 (the week containing Jan 4)
  final week1Monday = jan4.subtract(
    Duration(days: jan4.weekday - DateTime.monday),
  );

  // Calculate week number by counting days from week 1 Monday to target Thursday
  final daysSinceWeek1 = thursday.difference(week1Monday).inDays;
  final weekNumber = (daysSinceWeek1 / 7).floor() + 1;

  return weekNumber;
}

/// Get the year for ISO 8601 week date in the user's timezone
///
/// This may differ from calendar year near year boundaries
///
/// @param datetime - DateTime object (assumed to be in UTC)
/// @param timezone - IANA timezone string
/// @returns ISO week year
///
/// @example
/// // For Asia/Tokyo (UTC+9):
/// // Sunday 2024-12-31 20:00 UTC = Monday 2025-01-01 05:00 JST
/// getISOWeekYear(DateTime.utc(2024, 12, 31, 20), 'Asia/Tokyo')
/// // Returns: 2025 (because it's Week 1 of 2025 in Tokyo)
///
/// @example
/// // For America/Los_Angeles (UTC-8):
/// // Monday 2024-01-01 07:00 UTC = Sunday 2023-12-31 23:00 PST
/// getISOWeekYear(DateTime.utc(2024, 1, 1, 7), 'America/Los_Angeles')
/// // Returns: 2023 (because it's still Week 52 of 2023 in LA)
int getISOWeekYear(DateTime datetime, [String timezone = 'UTC']) {
  // Convert UTC datetime to user's timezone
  final location = tz.getLocation(timezone);
  final tzDateTime = tz.TZDateTime.from(datetime, location);

  // Find Thursday of current week (Thursday determines the year)
  final thursday = tzDateTime.add(
    Duration(days: DateTime.thursday - tzDateTime.weekday),
  );
  return thursday.year;
}

/// Get ISO 8601 week string for a date in the user's timezone
///
/// Returns format: "YYYY-WNN" (e.g., "2025-W41")
///
/// @param datetime - DateTime object (assumed to be in UTC)
/// @param timezone - IANA timezone string
/// @returns Formatted string "YYYY-WNN"
String getISOWeekString(DateTime datetime, [String timezone = 'UTC']) {
  final year = getISOWeekYear(datetime, timezone);
  final weekNumber = getISOWeekNumber(datetime, timezone);
  return '$year-W${weekNumber.toString().padLeft(2, '0')}';
}

/// Get number of weeks in a year (ISO 8601)
///
/// Most years have 52 weeks, some have 53 weeks
///
/// A year has 53 weeks if:
/// - It starts on Thursday (Jan 1 is Thursday), OR
/// - It's a leap year and starts on Wednesday (Jan 1 is Wednesday)
///
/// @param year - Calendar year
/// @param timezone - IANA timezone string
/// @returns Number of weeks (52 or 53)
int getWeeksInYear(int year, [String timezone = 'UTC']) {
  final location = tz.getLocation(timezone);
  final jan1 = tz.TZDateTime(location, year);
  final dec31 = tz.TZDateTime(location, year, 12, 31);

  // Check if Jan 1 is Thursday or (Wednesday and leap year)
  if (jan1.weekday == DateTime.thursday ||
      (jan1.weekday == DateTime.wednesday && isLeapYear(year))) {
    return 53;
  }

  // Check if Dec 31 is Thursday or (Friday and leap year)
  if (dec31.weekday == DateTime.thursday ||
      (dec31.weekday == DateTime.friday && isLeapYear(year))) {
    return 53;
  }

  return 52;
}

/// Check if year is leap year
bool isLeapYear(int year) {
  return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
}

/// Get the Monday of a specific ISO week in the user's timezone
///
/// Returns the date of the Monday that starts the given week.
/// The returned DateTime is in UTC but represents Monday 00:00 in the user's timezone.
///
/// @param year - ISO week year
/// @param weekNumber - ISO week number (1-53)
/// @param timezone - IANA timezone string
/// @returns DateTime representing Monday 00:00 in user's timezone (as UTC)
///
/// @example
/// // Get Week 1 of 2025 in Asia/Tokyo
/// getMondayOfISOWeek(2025, 1, 'Asia/Tokyo')
/// // Returns: Monday 2024-12-30 00:00 JST = Sunday 2024-12-29 15:00 UTC
///
/// @example
/// // Get Week 52 of 2023 in America/Los_Angeles
/// getMondayOfISOWeek(2023, 52, 'America/Los_Angeles')
/// // Returns: Monday 2023-12-25 00:00 PST = Monday 2023-12-25 08:00 UTC
DateTime getMondayOfISOWeek(
  int year,
  int weekNumber, [
  String timezone = 'UTC',
]) {
  final location = tz.getLocation(timezone);

  // Find Jan 4 of the year (always in week 1)
  final jan4 = tz.TZDateTime(location, year, 1, 4);

  // Find the Monday of week 1
  final week1Monday = jan4.subtract(Duration(days: jan4.weekday - 1));

  // Add weeks to get target Monday (at 00:00 in user's timezone)
  final targetMonday = week1Monday.add(Duration(days: (weekNumber - 1) * 7));

  // Return as UTC DateTime
  return targetMonday.toUtc();
}

/// Parse ISO week string to get Monday date in the user's timezone
///
/// Input format: "YYYY-WNN" (e.g., "2025-W41")
/// Returns the Monday of that week, or null if parsing fails
///
/// @param weekString - ISO week string format "YYYY-WNN"
/// @param timezone - IANA timezone string
/// @returns Monday DateTime in UTC, or null if parsing fails
DateTime? parseMondayFromISOWeek(String weekString, [String timezone = 'UTC']) {
  try {
    final parts = weekString.split('-W');
    if (parts.length != 2) return null;

    final year = int.parse(parts[0]);
    final weekNumber = int.parse(parts[1]);

    if (weekNumber < 1 || weekNumber > 53) return null;

    return getMondayOfISOWeek(year, weekNumber, timezone);
  } catch (e) {
    return null;
  }
}

/// Add weeks to an ISO week string
///
/// Input format: "YYYY-WNN"
/// Returns new week string after adding offset weeks
/// Handles year boundaries correctly (52/53 week years)
///
/// @param weekString - ISO week string format "YYYY-WNN"
/// @param weeksToAdd - Number of weeks to add (can be negative)
/// @param timezone - IANA timezone string
/// @returns New ISO week string
String addWeeksToISOWeek(
  String weekString,
  int weeksToAdd, [
  String timezone = 'UTC',
]) {
  final parts = weekString.split('-W');
  if (parts.length != 2) {
    throw ArgumentError('Invalid ISO week format: $weekString');
  }

  var year = int.parse(parts[0]);
  var weekNumber = int.parse(parts[1]) + weeksToAdd;

  // Handle year boundaries
  while (weekNumber > getWeeksInYear(year, timezone)) {
    weekNumber -= getWeeksInYear(year, timezone);
    year++;
  }
  while (weekNumber < 1) {
    year--;
    weekNumber += getWeeksInYear(year, timezone);
  }

  return '$year-W${weekNumber.toString().padLeft(2, '0')}';
}

/// Calculate the number of weeks between two ISO week strings
///
/// Returns positive if target is after base, negative if before
///
/// @param baseWeek - Base ISO week string
/// @param targetWeek - Target ISO week string
/// @param timezone - IANA timezone string
/// @returns Number of weeks between the two weeks
int weeksBetween(
  String baseWeek,
  String targetWeek, [
  String timezone = 'UTC',
]) {
  final baseMonday = parseMondayFromISOWeek(baseWeek, timezone);
  final targetMonday = parseMondayFromISOWeek(targetWeek, timezone);

  if (baseMonday == null || targetMonday == null) {
    throw ArgumentError('Invalid ISO week format');
  }

  return targetMonday.difference(baseMonday).inDays ~/ 7;
}

/// Get week boundaries (Monday 00:00 to Sunday 23:59:59.999) in user's timezone
///
/// Returns UTC dates representing the boundaries
///
/// @param datetime - DateTime object (assumed to be in UTC)
/// @param timezone - IANA timezone string
/// @returns Object with weekStart and weekEnd in UTC
///
/// @example
/// // For a datetime in Week 1 of 2025 in Asia/Tokyo
/// getWeekBoundaries(DateTime.utc(2025, 1, 1, 5), 'Asia/Tokyo')
/// // Returns:
/// // {
/// //   weekStart: Monday 2024-12-30 00:00 JST = Sunday 2024-12-29 15:00 UTC
/// //   weekEnd:   Sunday 2025-01-05 23:59:59.999 JST = Sunday 2025-01-05 14:59:59.999 UTC
/// // }
({DateTime weekStart, DateTime weekEnd}) getWeekBoundaries(
  DateTime datetime, [
  String timezone = 'UTC',
]) {
  final location = tz.getLocation(timezone);
  final tzDateTime = tz.TZDateTime.from(datetime, location);

  // Get Monday of current week (00:00 in user's timezone)
  final daysFromMonday = tzDateTime.weekday - DateTime.monday;
  final weekStart = tz.TZDateTime(
    location,
    tzDateTime.year,
    tzDateTime.month,
    tzDateTime.day,
  ).subtract(Duration(days: daysFromMonday));

  // Get Sunday of current week (23:59:59.999 in user's timezone)
  final weekEnd = weekStart.add(
    const Duration(
      days: 6,
      hours: 23,
      minutes: 59,
      seconds: 59,
      milliseconds: 999,
    ),
  );

  return (weekStart: weekStart.toUtc(), weekEnd: weekEnd.toUtc());
}

/// Format ISO week for display
///
/// @param datetime - DateTime object (assumed to be in UTC)
/// @param timezone - IANA timezone string
/// @returns Formatted string "Week W, YYYY" (e.g., "Week 1, 2025")
String formatISOWeek(DateTime datetime, [String timezone = 'UTC']) {
  final week = getISOWeekNumber(datetime, timezone);
  final year = getISOWeekYear(datetime, timezone);
  return 'Week $week, $year';
}

/// Check if two datetimes are in the same ISO week in the user's timezone
///
/// @param datetime1 - First datetime
/// @param datetime2 - Second datetime
/// @param timezone - IANA timezone string
/// @returns true if both datetimes are in the same ISO week
bool isSameISOWeek(
  DateTime datetime1,
  DateTime datetime2, [
  String timezone = 'UTC',
]) {
  final week1 = getISOWeekNumber(datetime1, timezone);
  final year1 = getISOWeekYear(datetime1, timezone);
  final week2 = getISOWeekNumber(datetime2, timezone);
  final year2 = getISOWeekYear(datetime2, timezone);

  return week1 == week2 && year1 == year2;
}
