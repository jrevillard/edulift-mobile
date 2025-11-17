/// Date utilities for common date operations
///
/// Provides centralized date utilities to avoid code duplication across features.
/// All methods use timezone-aware operations for consistency.

import 'package:timezone/timezone.dart' as tz;
import '../../utils/app_logger.dart';

/// Centralized date utilities
///
/// Provides common date operations with timezone awareness.
/// All methods handle errors gracefully and provide sensible fallbacks.
class DateUtils {
  // Private constructor to prevent instantiation
  DateUtils._();

  /// Get today's date in user timezone at midnight (00:00:00)
  ///
  /// This ensures that "today" is calculated based on the user's timezone,
  /// not the device timezone. This is critical for consistent date operations.
  ///
  /// Parameters:
  /// - userTimezone: IANA timezone string (e.g., "Europe/Paris")
  ///
  /// Returns: DateTime representing today at midnight in user timezone
  ///
  /// Example:
  /// ```dart
  /// // For Paris user (UTC+2):
  /// // If UTC time is 2025-11-11 22:30:00Z
  /// // Returns: 2025-11-12 00:00:00 (Wednesday in Paris)
  /// final todayParis = DateUtils.getTodayInUserTimezone('Europe/Paris');
  /// ```
  static DateTime getTodayInUserTimezone(String userTimezone) {
    try {
      // Get current UTC time
      final nowUtc = DateTime.now().toUtc();

      // Convert to user's timezone using timezone package
      final location = tz.getLocation(userTimezone);
      final nowInUserTz = tz.TZDateTime.from(nowUtc, location);

      AppLogger.debug('[DateUtils] Generated today in user timezone', {
        'userTimezone': userTimezone,
        'utcTime': nowUtc.toIso8601String(),
        'localTime': nowInUserTz.toIso8601String(),
        'result': DateTime.utc(
          nowInUserTz.year,
          nowInUserTz.month,
          nowInUserTz.day,
        ).toIso8601String(),
      });

      // Return midnight of today as UTC DateTime (preserving just the date)
      // We use UTC to avoid timezone interpretation issues later
      return DateTime.utc(nowInUserTz.year, nowInUserTz.month, nowInUserTz.day);
    } catch (e, stackTrace) {
      AppLogger.error(
        '[DateUtils] Failed to get today in user timezone, falling back to device timezone',
        e,
        stackTrace,
      );

      // Fallback to device timezone (not ideal, but better than failing)
      final now = DateTime.now();
      return DateTime.utc(now.year, now.month, now.day);
    }
  }

  /// Check if a date is "today" in user's timezone
  ///
  /// This is useful for UI logic that needs to know if something happens today.
  ///
  /// Parameters:
  /// - dateTime: DateTime to check (in UTC)
  /// - userTimezone: User's IANA timezone (e.g., "Europe/Paris")
  ///
  /// Returns: true if the date is today in user's timezone
  ///
  /// Example:
  /// ```dart
  /// final isToday = DateUtils.isTodayInUserTimezone(
  ///   DateTime.parse("2025-11-11T22:30:00Z"),
  ///   "Europe/Paris"
  /// );
  /// // Returns true if it's Wednesday 2025-11-12 in Paris
  /// ```
  static bool isTodayInUserTimezone(DateTime dateTime, String userTimezone) {
    try {
      final today = getTodayInUserTimezone(userTimezone);

      // Convert the dateTime to user's timezone for comparison
      final location = tz.getLocation(userTimezone);
      final dateTimeInUserTz = tz.TZDateTime.from(dateTime.toUtc(), location);

      // Compare directly with today's date components
      // today is already a UTC DateTime with the date in user's timezone
      return dateTimeInUserTz.year == today.year &&
          dateTimeInUserTz.month == today.month &&
          dateTimeInUserTz.day == today.day;
    } catch (e, stackTrace) {
      AppLogger.error(
        '[DateUtils] Failed to check if date is today in user timezone',
        e,
        stackTrace,
      );

      // Fallback to simple comparison (may be wrong due to timezone)
      final now = DateTime.now();
      return dateTime.year == now.year &&
          dateTime.month == now.month &&
          dateTime.day == now.day;
    }
  }

  /// Get start of day (midnight) for a date in user timezone
  ///
  /// Useful for date range calculations that need to start at midnight.
  ///
  /// Parameters:
  /// - dateTime: Date to process (in UTC)
  /// - userTimezone: User's IANA timezone (e.g., "Europe/Paris")
  ///
  /// Returns: DateTime representing the start of the day in user timezone
  static DateTime getStartOfDayInUserTimezone(
    DateTime dateTime,
    String userTimezone,
  ) {
    try {
      final location = tz.getLocation(userTimezone);
      final dateTimeInUserTz = tz.TZDateTime.from(dateTime.toUtc(), location);

      // Return as UTC DateTime with the date components from user timezone
      return DateTime.utc(
        dateTimeInUserTz.year,
        dateTimeInUserTz.month,
        dateTimeInUserTz.day,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        '[DateUtils] Failed to get start of day in user timezone',
        e,
        stackTrace,
      );

      // Fallback to simple truncation (use UTC to avoid timezone issues)
      return DateTime.utc(dateTime.year, dateTime.month, dateTime.day);
    }
  }

  /// Check if a DateTime is in the past in user's timezone
  ///
  /// This method properly handles timezone conversion to determine if a given
  /// DateTime is in the past from the perspective of a user in a specific timezone.
  /// This is critical for schedule features where slot availability depends on
  /// the user's local time, not UTC time.
  ///
  /// Parameters:
  /// - dateTime: DateTime to check (should be in UTC for consistency)
  /// - userTimezone: User's IANA timezone (e.g., "Europe/Paris", "America/New_York")
  /// - minutesBuffer: Optional buffer in minutes (e.g., 5 to allow 5-minute grace period)
  ///
  /// Returns: true if the dateTime is before current time in user's timezone
  ///
  /// Example:
  /// ```dart
  /// // Check if a slot at 20:30 UTC is past for Paris user
  /// final isPast = DateUtils.isPastInUserTimezone(
  ///   DateTime.parse("2025-11-12T20:30:00Z"),
  ///   "Europe/Paris",
  ///   minutesBuffer: 5
  /// );
  /// ```
  static bool isPastInUserTimezone(
    DateTime dateTime,
    String userTimezone, {
    int minutesBuffer = 0,
  }) {
    AppLogger.debug(
      '[DateUtils] Checking if datetime is past in user timezone',
      {
        'dateTime': dateTime.toIso8601String(),
        'userTimezone': userTimezone,
        'minutesBuffer': minutesBuffer,
      },
    );

    final location = tz.getLocation(userTimezone);
    final nowInUserTz = tz.TZDateTime.now(location);

    // Apply buffer if specified
    final comparisonTime = minutesBuffer > 0
        ? nowInUserTz.subtract(Duration(minutes: minutesBuffer))
        : nowInUserTz;

    // Convert input dateTime to user timezone for comparison
    final dateTimeInUserTz = tz.TZDateTime.from(dateTime.toUtc(), location);

    final isPast = dateTimeInUserTz.isBefore(comparisonTime);

    AppLogger.debug('[DateUtils] Past check result', {
      'dateTimeInUserTz': dateTimeInUserTz.toIso8601String(),
      'comparisonTime': comparisonTime.toIso8601String(),
      'isPast': isPast,
    });

    return isPast;
  }
}
