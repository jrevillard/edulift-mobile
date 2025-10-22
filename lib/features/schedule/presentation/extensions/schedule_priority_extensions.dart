// EduLift Mobile - Schedule Priority UI Extensions
// Provides Flutter-specific visual properties for SchedulePriority

import 'package:flutter/material.dart';
import 'package:edulift/core/domain/entities/schedule.dart';

/// Extension to provide Flutter UI properties for SchedulePriority
extension SchedulePriorityUI on SchedulePriority {
  /// Get color for this priority
  Color get color {
    switch (this) {
      case SchedulePriority.low:
        return Colors.green;
      case SchedulePriority.medium:
        return Colors.orange;
      case SchedulePriority.high:
        return Colors.red;
      case SchedulePriority.critical:
        return Colors.red;}
  }

  /// Get icon for this priority
  IconData get icon {
    switch (this) {
      case SchedulePriority.low:
        return Icons.low_priority;
      case SchedulePriority.medium:
        return Icons.remove;
      case SchedulePriority.high:
        return Icons.priority_high;
      case SchedulePriority.critical:
        return Icons.warning;}
  }
}
