import '../constants/schedule_constants.dart';

/// Utility methods for schedule-related operations
class ScheduleUtils {
  /// Creates an empty weekday map with empty lists for time slots
  static Map<String, List<String>> createEmptyWeekdayMap() {
    return {
      for (final String weekday in ScheduleConstants.weekdays)
        weekday: <String>[],
    };
  }

  /// Validates schedule hours format (HH:MM)
  static bool validateScheduleTime(String time) {
    final timeRegex = RegExp(r'^\d{2}:\d{2}$');
    return timeRegex.hasMatch(time);
  }
}
