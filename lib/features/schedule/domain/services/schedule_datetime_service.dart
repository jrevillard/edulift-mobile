import 'package:logging/logging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:edulift/core/utils/date/iso_week_utils.dart';

/// Domain service for schedule date/time calculations
/// Centralizes all date/week/time logic in one place
/// DELEGATES to iso_week_utils for actual calculations (no duplication!)
class ScheduleDateTimeService {
  static final _logger = Logger('ScheduleDateTimeService');

  const ScheduleDateTimeService();

  /// Calculate the start date of a week from week string (e.g., "2025-W02")
  /// DELEGATES to parseMondayFromISOWeek() to avoid code duplication
  DateTime? calculateWeekStartDate(String week) {
    try {
      return parseMondayFromISOWeek(week);
    } catch (e) {
      _logger.warning('Failed to parse week start date: $week, error: $e');
      return null;
    }
  }

  /// Calculate full DateTime from day string, time string, and week
  ///
  /// Example: ("Monday", "07:30", "2025-W02") → UTC datetime 2025-01-06 07:30:00.000Z
  /// Returns DateTime in UTC timezone for API compatibility
  ///
  /// IMPORTANT: This method treats input time as UTC time (no timezone conversion).
  /// The input time (e.g., "07:30") is interpreted as 07:30 UTC directly,
  /// ensuring consistent behavior regardless of device timezone.
  DateTime? calculateDateTimeFromSlot(String day, String time, String week) {
    try {
      final weekStart = calculateWeekStartDate(week);
      if (weekStart == null) return null;

      // Parse day to get offset (Monday = 0, Tuesday = 1, etc.)
      final dayLower = day.toLowerCase();
      final dayOffset = switch (dayLower) {
        'monday' || 'mon' => 0,
        'tuesday' || 'tue' => 1,
        'wednesday' || 'wed' => 2,
        'thursday' || 'thu' => 3,
        'friday' || 'fri' => 4,
        'saturday' || 'sat' => 5,
        'sunday' || 'sun' => 6,
        _ => throw ArgumentError('Invalid day: $day'),
      };

      // Parse time (HH:mm format)
      final timeParts = time.split(':');
      if (timeParts.length != 2) {
        throw ArgumentError('Invalid time format: $time');
      }
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // Validate time values
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        throw ArgumentError('Invalid time values: hour=$hour, minute=$minute');
      }

      // Build the date component
      final date = weekStart.add(Duration(days: dayOffset));

      // Create DateTime directly in UTC (no timezone conversion)
      // The input time (e.g., "07:30") is treated as UTC time, not local time
      // This ensures consistent behavior regardless of device timezone
      final utcDateTime = DateTime.utc(
        date.year,
        date.month,
        date.day,
        hour,
        minute,
      );

      _logger.fine(
        'Calculated datetime: day=$day, time=$time, week=$week → UTC: ${utcDateTime.toIso8601String()}',
      );
      return utcDateTime;
    } catch (e) {
      _logger.warning(
        'Failed to calculate datetime: day=$day, time=$time, week=$week, error: $e',
      );
      return null;
    }
  }

  /// Calculate the end date of a week (Sunday 23:59:59.999 UTC)
  /// Used for querying API with inclusive week range
  DateTime calculateWeekEndDate(DateTime weekStart) {
    // Week ends on Sunday at 23:59:59.999
    // Add 7 days to get to next Monday, then subtract 1 millisecond
    return weekStart
        .add(const Duration(days: 7))
        .subtract(const Duration(milliseconds: 1));
  }

  /// Check if a date is in the past based on user's timezone
  ///
  /// This method uses the user's timezone instead of device timezone to determine
  /// if a date/time has passed. This is critical for multi-timezone scenarios where
  /// a user's profile timezone differs from their device timezone.
  ///
  /// Example:
  /// - Device timezone: UTC (midnight)
  /// - User profile timezone: America/New_York (7pm previous day)
  /// - Schedule time: 8pm in New York
  /// - Result: NOT past (8pm > 7pm) even though it's past midnight UTC
  ///
  /// Parameters:
  /// - dateTime: The datetime to check (usually in UTC from API)
  /// - userTimezone: User's timezone from profile (e.g., "America/New_York", "Europe/Paris")
  ///                 If null, defaults to UTC
  ///
  /// Returns: true if the datetime is in the past in the user's timezone
  bool isPastDate(DateTime dateTime, {String? userTimezone}) {
    try {
      final timezone = userTimezone ?? 'UTC';
      _logger.fine(
        'Checking if date is past: $dateTime in timezone: $timezone',
      );

      // Get the timezone location
      final location = tz.getLocation(timezone);

      // Get current time in user's timezone
      final nowInUserTz = tz.TZDateTime.now(location);

      // Convert the provided datetime to user's timezone
      final dateTimeInUserTz = tz.TZDateTime.from(dateTime, location);

      // Compare in user's timezone
      final isPast = dateTimeInUserTz.isBefore(nowInUserTz);

      _logger.fine(
        'Date comparison: $dateTimeInUserTz (slot) vs $nowInUserTz (now) in $timezone → isPast: $isPast',
      );

      return isPast;
    } catch (e) {
      _logger.warning('Failed to check if date is past: $e');
      // Fallback to UTC comparison if timezone is invalid
      return dateTime.isBefore(DateTime.now().toUtc());
    }
  }

  /// Validate that a schedule datetime is not in the past
  ///
  /// This validation uses the user's timezone to ensure schedules can only be
  /// created for future times in the user's local context, not the device context.
  ///
  /// Parameters:
  /// - dateTime: The datetime to validate (usually in UTC from calculateDateTimeFromSlot)
  /// - userTimezone: User's timezone from profile (e.g., "America/New_York")
  ///                 If null, defaults to UTC
  ///
  /// Returns: ValidationResult with success=true if valid, or error message if past
  ScheduleDateTimeValidationResult validateScheduleDateTime(
    DateTime dateTime, {
    String? userTimezone,
  }) {
    try {
      final timezone = userTimezone ?? 'UTC';

      // Check if the datetime is in the past
      if (isPastDate(dateTime, userTimezone: timezone)) {
        final location = tz.getLocation(timezone);
        final dateTimeInUserTz = tz.TZDateTime.from(dateTime, location);
        // Get timezone abbreviation from location (e.g., "EST", "EDT", "PST")
        final tzAbbr = dateTimeInUserTz.timeZoneName;

        _logger.warning(
          'Schedule datetime validation failed: datetime is in the past ($dateTimeInUserTz $tzAbbr)',
        );

        return ScheduleDateTimeValidationResult(
          isValid: false,
          errorMessage:
              'Cannot create schedule for past time. '
              'Selected time has already passed in your timezone ($tzAbbr).',
        );
      }

      // Validation passed
      return const ScheduleDateTimeValidationResult(isValid: true);
    } catch (e) {
      _logger.severe('Schedule datetime validation error: $e');
      return ScheduleDateTimeValidationResult(
        isValid: false,
        errorMessage: 'Failed to validate schedule time: ${e.toString()}',
      );
    }
  }
}

/// Result of schedule datetime validation
class ScheduleDateTimeValidationResult {
  /// Whether the validation passed
  final bool isValid;

  /// Error message if validation failed (null if valid)
  final String? errorMessage;

  const ScheduleDateTimeValidationResult({
    required this.isValid,
    this.errorMessage,
  });
}
