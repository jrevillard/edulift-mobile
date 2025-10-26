// EduLift Mobile - Day of Week Enum
// Represents days of the week for scheduling

/// Enum representing days of the week
enum DayOfWeek {
  monday(1, 'Monday', 'Mon'),
  tuesday(2, 'Tuesday', 'Tue'),
  wednesday(3, 'Wednesday', 'Wed'),
  thursday(4, 'Thursday', 'Thu'),
  friday(5, 'Friday', 'Fri'),
  saturday(6, 'Saturday', 'Sat'),
  sunday(7, 'Sunday', 'Sun');

  const DayOfWeek(this.weekday, this.fullName, this.shortName);

  final int weekday;
  final String fullName;
  final String shortName;

  /// Get day of week from DateTime weekday value
  static DayOfWeek fromWeekday(int weekday) {
    switch (weekday) {
      case 1:
        return DayOfWeek.monday;
      case 2:
        return DayOfWeek.tuesday;
      case 3:
        return DayOfWeek.wednesday;
      case 4:
        return DayOfWeek.thursday;
      case 5:
        return DayOfWeek.friday;
      case 6:
        return DayOfWeek.saturday;
      case 7:
        return DayOfWeek.sunday;
      default:
        throw ArgumentError('Invalid weekday: $weekday');
    }
  }

  /// Get day of week from DateTime
  static DayOfWeek fromDateTime(DateTime dateTime) {
    return fromWeekday(dateTime.weekday);
  }

  /// Get day of week from string name
  static DayOfWeek fromString(String name) {
    final lowerName = name.toLowerCase();
    switch (lowerName) {
      case 'monday':
      case 'mon':
        return DayOfWeek.monday;
      case 'tuesday':
      case 'tue':
        return DayOfWeek.tuesday;
      case 'wednesday':
      case 'wed':
        return DayOfWeek.wednesday;
      case 'thursday':
      case 'thu':
        return DayOfWeek.thursday;
      case 'friday':
      case 'fri':
        return DayOfWeek.friday;
      case 'saturday':
      case 'sat':
        return DayOfWeek.saturday;
      case 'sunday':
      case 'sun':
        return DayOfWeek.sunday;
      default:
        throw ArgumentError('Invalid day name: $name');
    }
  }

  /// Check if this is a weekday (Monday-Friday)
  bool get isWeekday => weekday >= 1 && weekday <= 5;

  /// Check if this is a weekend (Saturday-Sunday)
  bool get isWeekend => weekday == 6 || weekday == 7;

  /// Get the next day of week
  DayOfWeek get next {
    switch (this) {
      case DayOfWeek.monday:
        return DayOfWeek.tuesday;
      case DayOfWeek.tuesday:
        return DayOfWeek.wednesday;
      case DayOfWeek.wednesday:
        return DayOfWeek.thursday;
      case DayOfWeek.thursday:
        return DayOfWeek.friday;
      case DayOfWeek.friday:
        return DayOfWeek.saturday;
      case DayOfWeek.saturday:
        return DayOfWeek.sunday;
      case DayOfWeek.sunday:
        return DayOfWeek.monday;
    }
  }

  /// Get the previous day of week
  DayOfWeek get previous {
    switch (this) {
      case DayOfWeek.monday:
        return DayOfWeek.sunday;
      case DayOfWeek.tuesday:
        return DayOfWeek.monday;
      case DayOfWeek.wednesday:
        return DayOfWeek.tuesday;
      case DayOfWeek.thursday:
        return DayOfWeek.wednesday;
      case DayOfWeek.friday:
        return DayOfWeek.thursday;
      case DayOfWeek.saturday:
        return DayOfWeek.friday;
      case DayOfWeek.sunday:
        return DayOfWeek.saturday;
    }
  }

  @override
  String toString() => fullName;
}
