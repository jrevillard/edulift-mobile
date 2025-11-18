// EduLift Mobile - TimeOfDayValue Timezone Display Extension
// Provides timezone-aware formatting for TimeOfDayValue
//
// This extension adds methods to display TimeOfDayValue (which stores UTC times)
// in the user's local timezone throughout the UI.

import '../entities/schedule/time_of_day.dart';
import '../../utils/timezone_formatter.dart';

/// Extension for displaying TimeOfDayValue in user's timezone
///
/// Example usage:
/// ```dart
/// final utcTime = TimeOfDayValue(7, 30); // 07:30 UTC
/// final userTimezone = "Europe/Paris"; // UTC+2 in summer
///
/// // Display in user timezone
/// final localTime = utcTime.toLocalTimeString(userTimezone);
/// // Returns "09:30"
///
/// // Display with timezone indicator
/// final withTz = utcTime.toLocalTimeString(userTimezone, showTimezoneIndicator: true);
/// // Returns "09:30 (UTC+2)"
/// ```
extension TimeOfDayValueTimezoneExtension on TimeOfDayValue {
  /// Convert UTC time to local time string for display
  ///
  /// Parameters:
  /// - userTimezone: IANA timezone string (e.g., "Europe/Paris")
  /// - showTimezoneIndicator: Whether to append timezone offset (e.g., "UTC+2")
  /// - referenceDate: Optional reference date for timezone calculation (defaults to today)
  ///
  /// Returns: Formatted time string in user's timezone
  ///
  /// Example:
  /// ```dart
  /// final time = TimeOfDayValue(7, 30); // 07:30 UTC
  /// final display = time.toLocalTimeString("Europe/Paris");
  /// // Returns "09:30" (UTC+2 in summer)
  /// ```
  String toLocalTimeString(
    String? userTimezone, {
    bool showTimezoneIndicator = false,
    DateTime? referenceDate,
  }) {
    // Use TimezoneFormatter to convert the time slot
    final apiFormat = toApiFormat(); // "HH:mm" format
    return TimezoneFormatter.formatTimeSlot(
      apiFormat,
      userTimezone,
      referenceDate: referenceDate,
    );
  }

  /// Convert UTC time to local time string with timezone indicator
  ///
  /// This is a convenience method that always shows the timezone indicator.
  ///
  /// Parameters:
  /// - userTimezone: IANA timezone string (e.g., "Europe/Paris")
  /// - referenceDate: Optional reference date for timezone calculation (defaults to today)
  ///
  /// Returns: Formatted time string with timezone (e.g., "09:30 (UTC+2)")
  ///
  /// Example:
  /// ```dart
  /// final time = TimeOfDayValue(7, 30); // 07:30 UTC
  /// final display = time.toLocalTimeStringWithTz("Europe/Paris");
  /// // Returns "09:30 (UTC+2)"
  /// ```
  String toLocalTimeStringWithTz(
    String? userTimezone, {
    DateTime? referenceDate,
  }) {
    return toLocalTimeString(
      userTimezone,
      showTimezoneIndicator: true,
      referenceDate: referenceDate,
    );
  }

  /// Get just the timezone offset display for this time
  ///
  /// Useful for showing timezone information separately from the time.
  ///
  /// Parameters:
  /// - userTimezone: IANA timezone string (e.g., "Europe/Paris")
  /// - referenceDate: Optional reference date for DST calculation
  ///
  /// Returns: Timezone offset string (e.g., "UTC+2")
  ///
  /// Example:
  /// ```dart
  /// final time = TimeOfDayValue(7, 30);
  /// final offset = time.getTimezoneOffset("Europe/Paris");
  /// // Returns "UTC+2" in summer, "UTC+1" in winter
  /// ```
  String getTimezoneOffset(String? userTimezone, {DateTime? referenceDate}) {
    if (userTimezone == null) return 'UTC';

    // Use reference date or today to calculate offset
    final refDate = referenceDate ?? DateTime.now();
    final dateTime = toDateTime(refDate);

    return TimezoneFormatter.getTimezoneOffsetDisplay(userTimezone, dateTime);
  }
}
