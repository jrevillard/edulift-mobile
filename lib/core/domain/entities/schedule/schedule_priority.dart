// EduLift Mobile - Schedule Priority Enum
// Defines priority levels for schedules

/// Enum representing schedule priority levels
enum SchedulePriority {
  low(1, 'Low', 'Low priority schedule'),
  medium(2, 'Medium', 'Medium priority schedule'),
  high(3, 'High', 'High priority schedule'),
  critical(4, 'Critical', 'Critical priority schedule');

  const SchedulePriority(this.level, this.label, this.description);

  final int level;
  final String label;
  final String description;

  /// Get priority from string
  static SchedulePriority fromString(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return SchedulePriority.low;
      case 'medium':
        return SchedulePriority.medium;
      case 'high':
        return SchedulePriority.high;
      case 'critical':
        return SchedulePriority.critical;
      default:
        return SchedulePriority.medium;
    }
  }

  /// Get priority from level number
  static SchedulePriority fromLevel(int level) {
    switch (level) {
      case 1:
        return SchedulePriority.low;
      case 2:
        return SchedulePriority.medium;
      case 3:
        return SchedulePriority.high;
      case 4:
        return SchedulePriority.critical;
      default:
        return SchedulePriority.medium;
    }
  }

  /// Check if this priority is higher than another
  bool isHigherThan(SchedulePriority other) {
    return level > other.level;
  }

  /// Check if this priority is lower than another
  bool isLowerThan(SchedulePriority other) {
    return level < other.level;
  }

  @override
  String toString() => label;
}
