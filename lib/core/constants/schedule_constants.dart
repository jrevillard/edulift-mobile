/// Constants for schedule-related functionality
class ScheduleConstants {
  // Weekday constants (uppercase for API compatibility) - Backend only supports MONDAY-FRIDAY
  static const List<String> weekdays = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
  ];

  // Default config values
  static const int defaultMaxVehiclesPerSlot =
      2; // Default max vehicles per departure hour
  static const bool defaultAllowConflicts = false;
  static const bool defaultRequireApproval = false;

  // Departure hour configuration limits
  static const int maxTimeSlotsPerDay = 20; // Max departure hours per day
  static const int minIntervalMinutes = 15;
}
