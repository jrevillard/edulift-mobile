// EduLift Mobile - Timezone Formatter Utility
// Centralized timezone formatting for consistent UI display
//
// This utility provides formatting methods for displaying dates and times
// in the user's timezone throughout the mobile app.

import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import '../services/timezone_service.dart';
import 'app_logger.dart';

/// Centralized timezone formatting utility
///
/// Provides consistent date/time formatting with timezone awareness across the app.
/// All methods handle null values gracefully and provide sensible fallbacks.
class TimezoneFormatter {
  // Private constructor to prevent instantiation
  TimezoneFormatter._();

  /// Format DateTime to local time string with optional timezone indicator
  ///
  /// Parameters:
  /// - utcDateTime: DateTime in UTC to be formatted
  /// - userTimezone: IANA timezone string (e.g., "Europe/Paris")
  /// - showTimezoneIndicator: Whether to append timezone offset (e.g., "UTC+2")
  /// - format: DateFormat pattern (default: "HH:mm")
  ///
  /// Returns: Formatted time string (e.g., "14:30" or "14:30 (UTC+2)")
  ///
  /// Example:
  /// ```dart
  /// final formatted = TimezoneFormatter.formatWithTimezone(
  ///   DateTime.parse("2025-10-19T12:30:00Z"),
  ///   "Europe/Paris",
  ///   showTimezoneIndicator: true,
  /// );
  /// // Returns "14:30 (UTC+2)" in summer
  /// ```
  static String formatWithTimezone(
    DateTime? utcDateTime,
    String? userTimezone, {
    bool showTimezoneIndicator = true,
    String format = 'HH:mm',
  }) {
    // Handle null datetime
    if (utcDateTime == null) {
      AppLogger.warning(
        '[TimezoneFormatter] Null datetime provided to formatWithTimezone',
      );
      return '--:--';
    }

    // Use UTC if no timezone provided
    final timezone = userTimezone ?? 'UTC';

    try {
      // Convert to user's timezone
      final location = tz.getLocation(timezone);
      final localDateTime = tz.TZDateTime.from(utcDateTime.toUtc(), location);

      // Format the time
      final formatter = DateFormat(format);
      final formattedTime = formatter.format(localDateTime);

      // Add timezone indicator if requested
      if (showTimezoneIndicator) {
        final offset = getTimezoneOffsetDisplay(timezone, localDateTime);
        return '$formattedTime ($offset)';
      }

      return formattedTime;
    } catch (e, stackTrace) {
      AppLogger.error(
        '[TimezoneFormatter] Failed to format datetime with timezone: $timezone, format: $format',
        e,
        stackTrace,
      );

      // Fallback to UTC formatting
      final formatter = DateFormat(format);
      final formattedTime = formatter.format(utcDateTime.toUtc());
      return showTimezoneIndicator ? '$formattedTime (UTC)' : formattedTime;
    }
  }

  /// Format time only (HH:mm) without date
  ///
  /// Parameters:
  /// - utcDateTime: DateTime in UTC to be formatted
  /// - userTimezone: IANA timezone string (e.g., "Europe/Paris")
  ///
  /// Returns: Formatted time string (e.g., "14:30")
  ///
  /// Example:
  /// ```dart
  /// final time = TimezoneFormatter.formatTimeOnly(
  ///   DateTime.parse("2025-10-19T12:30:00Z"),
  ///   "Europe/Paris",
  /// );
  /// // Returns "14:30"
  /// ```
  static String formatTimeOnly(DateTime? utcDateTime, String? userTimezone) {
    return formatWithTimezone(
      utcDateTime,
      userTimezone,
      showTimezoneIndicator: false,
    );
  }

  /// Format date and time (e.g., "Oct 19, 14:30")
  ///
  /// Parameters:
  /// - utcDateTime: DateTime in UTC to be formatted
  /// - userTimezone: IANA timezone string (e.g., "Europe/Paris")
  /// - showTimezoneIndicator: Whether to append timezone offset
  ///
  /// Returns: Formatted datetime string (e.g., "Oct 19, 14:30" or "Oct 19, 14:30 (UTC+2)")
  ///
  /// Example:
  /// ```dart
  /// final datetime = TimezoneFormatter.formatDateTimeShort(
  ///   DateTime.parse("2025-10-19T12:30:00Z"),
  ///   "Europe/Paris",
  /// );
  /// // Returns "Oct 19, 14:30"
  /// ```
  static String formatDateTimeShort(
    DateTime? utcDateTime,
    String? userTimezone, {
    bool showTimezoneIndicator = false,
  }) {
    return formatWithTimezone(
      utcDateTime,
      userTimezone,
      showTimezoneIndicator: showTimezoneIndicator,
      format: 'MMM d, HH:mm',
    );
  }

  /// Format full date and time (e.g., "October 19, 2025 14:30")
  ///
  /// Parameters:
  /// - utcDateTime: DateTime in UTC to be formatted
  /// - userTimezone: IANA timezone string (e.g., "Europe/Paris")
  /// - showTimezoneIndicator: Whether to append timezone offset
  ///
  /// Returns: Formatted datetime string
  ///
  /// Example:
  /// ```dart
  /// final datetime = TimezoneFormatter.formatDateTimeFull(
  ///   DateTime.parse("2025-10-19T12:30:00Z"),
  ///   "Europe/Paris",
  /// );
  /// // Returns "October 19, 2025 14:30"
  /// ```
  static String formatDateTimeFull(
    DateTime? utcDateTime,
    String? userTimezone, {
    bool showTimezoneIndicator = false,
  }) {
    return formatWithTimezone(
      utcDateTime,
      userTimezone,
      showTimezoneIndicator: showTimezoneIndicator,
      format: 'MMMM d, y HH:mm',
    );
  }

  /// Format date only (e.g., "Oct 19, 2025")
  ///
  /// Parameters:
  /// - utcDateTime: DateTime in UTC to be formatted
  /// - userTimezone: IANA timezone string (e.g., "Europe/Paris")
  ///
  /// Returns: Formatted date string
  ///
  /// Example:
  /// ```dart
  /// final date = TimezoneFormatter.formatDateOnly(
  ///   DateTime.parse("2025-10-19T12:30:00Z"),
  ///   "Europe/Paris",
  /// );
  /// // Returns "Oct 19, 2025"
  /// ```
  static String formatDateOnly(DateTime? utcDateTime, String? userTimezone) {
    return formatWithTimezone(
      utcDateTime,
      userTimezone,
      showTimezoneIndicator: false,
      format: 'MMM d, y',
    );
  }

  /// Get timezone offset display (e.g., "UTC+2", "UTC-5")
  ///
  /// Parameters:
  /// - timezone: IANA timezone string (e.g., "Europe/Paris")
  /// - dateTime: Optional datetime to calculate offset at specific time (for DST)
  ///
  /// Returns: Timezone offset string (e.g., "UTC+2")
  ///
  /// Example:
  /// ```dart
  /// final offset = TimezoneFormatter.getTimezoneOffsetDisplay("Europe/Paris");
  /// // Returns "UTC+2" in summer, "UTC+1" in winter
  /// ```
  static String getTimezoneOffsetDisplay(
    String timezone, [
    DateTime? dateTime,
  ]) {
    try {
      final location = tz.getLocation(timezone);
      final now = dateTime ?? DateTime.now().toUtc();
      final tzDateTime = tz.TZDateTime.from(now, location);

      // Get offset in hours
      final offsetMinutes = tzDateTime.timeZoneOffset.inMinutes;
      final offsetHours = offsetMinutes ~/ 60;
      final offsetMins = offsetMinutes.abs() % 60;

      // Format offset
      final sign = offsetMinutes >= 0 ? '+' : '-';
      final hours = offsetHours.abs();

      if (offsetMins == 0) {
        return 'UTC$sign$hours';
      } else {
        return 'UTC$sign$hours:${offsetMins.toString().padLeft(2, '0')}';
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        '[TimezoneFormatter] Failed to get timezone offset for: $timezone',
        e,
        stackTrace,
      );
      return 'UTC';
    }
  }

  /// Get timezone abbreviation (e.g., "CET", "PST")
  ///
  /// Parameters:
  /// - timezone: IANA timezone string (e.g., "Europe/Paris")
  /// - dateTime: Optional datetime to get abbreviation at specific time (for DST)
  ///
  /// Returns: Timezone abbreviation string
  ///
  /// Example:
  /// ```dart
  /// final abbr = TimezoneFormatter.getTimezoneAbbreviation("Europe/Paris");
  /// // Returns "CET" in winter, "CEST" in summer
  /// ```
  static String getTimezoneAbbreviation(String timezone, [DateTime? dateTime]) {
    try {
      final location = tz.getLocation(timezone);
      final now = dateTime ?? DateTime.now().toUtc();
      final tzDateTime = tz.TZDateTime.from(now, location);

      return tzDateTime.timeZoneName;
    } catch (e, stackTrace) {
      AppLogger.error(
        '[TimezoneFormatter] Failed to get timezone abbreviation for: $timezone',
        e,
        stackTrace,
      );
      return 'UTC';
    }
  }

  /// Format time slot string (HH:mm) to display in user's timezone
  ///
  /// This is useful for schedule time slots which are stored as "HH:mm" strings in UTC.
  ///
  /// Parameters:
  /// - timeSlot: Time in HH:mm format (e.g., "07:30")
  /// - userTimezone: IANA timezone string (e.g., "Europe/Paris")
  /// - referenceDate: Optional reference date (defaults to today)
  ///
  /// Returns: Formatted time string in user's timezone
  ///
  /// Example:
  /// ```dart
  /// final localTime = TimezoneFormatter.formatTimeSlot(
  ///   "07:30", // UTC
  ///   "Europe/Paris",
  /// );
  /// // Returns "09:30" (UTC+2 in summer)
  /// ```
  static String formatTimeSlot(
    String timeSlot,
    String? userTimezone, {
    DateTime? referenceDate,
  }) {
    try {
      // Parse time slot (HH:mm format)
      final parts = timeSlot.split(':');
      if (parts.length != 2) {
        AppLogger.warning(
          '[TimezoneFormatter] Invalid time slot format: $timeSlot',
        );
        return timeSlot;
      }

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);

      if (hour == null || minute == null) {
        AppLogger.warning(
          '[TimezoneFormatter] Invalid time slot values: $timeSlot',
        );
        return timeSlot;
      }

      // Create UTC datetime with the time slot
      final refDate = referenceDate ?? DateTime.now().toUtc();
      final utcDateTime = DateTime.utc(
        refDate.year,
        refDate.month,
        refDate.day,
        hour,
        minute,
      );

      // Format in user's timezone
      return formatTimeOnly(utcDateTime, userTimezone);
    } catch (e, stackTrace) {
      AppLogger.error(
        '[TimezoneFormatter] Failed to format time slot $timeSlot for timezone: $userTimezone',
        e,
        stackTrace,
      );
      return timeSlot;
    }
  }

  /// Convert local time string to UTC time string for API requests
  ///
  /// This is a convenience wrapper around TimezoneService.convertLocalTimeToUtc
  ///
  /// Parameters:
  /// - localTime: ISO 8601 datetime string in local time
  /// - timezone: IANA timezone string (e.g., "Europe/Paris")
  ///
  /// Returns: ISO 8601 datetime string in UTC
  static String convertLocalToUtc(String localTime, String timezone) {
    return TimezoneService.convertLocalTimeToUtc(localTime, timezone);
  }

  /// Convert UTC time string to local time string
  ///
  /// This is a convenience wrapper around TimezoneService.convertUtcTimeToLocal
  ///
  /// Parameters:
  /// - utcTime: ISO 8601 datetime string in UTC
  /// - timezone: IANA timezone string (e.g., "Europe/Paris")
  ///
  /// Returns: ISO 8601 datetime string in local timezone
  static String convertUtcToLocal(String utcTime, String timezone) {
    return TimezoneService.convertUtcTimeToLocal(utcTime, timezone);
  }
}
