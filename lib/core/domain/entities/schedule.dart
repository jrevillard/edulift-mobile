// Export all schedule entities
export 'schedule/assignment.dart';
export 'schedule/day_of_week.dart';
export 'schedule/optimized_schedule.dart';
export 'schedule/period_slot_data.dart';
export 'schedule/period_slot_group.dart';
export 'schedule/recurrence_pattern.dart';
export 'schedule/schedule_config.dart';
export 'schedule/schedule_conflict.dart';
export 'schedule/schedule_period.dart'; // NEW: Type-safe period representation
export 'schedule/schedule_priority.dart';
export 'schedule/schedule_slot.dart';
// NOTE: schedule_slot_simple.dart is excluded to avoid ambiguous export with schedule_slot.dart
export 'schedule/schedule_time_slot.dart';
export 'schedule/time_of_day.dart'; // NEW: Type-safe time representation
export 'schedule/time_slot.dart';
export 'schedule/vehicle_assignment.dart';
// NOTE: vehicle_assignment_simple.dart is excluded to avoid ambiguous export with vehicle_assignment.dart
export 'schedule/weekly_schedule.dart';
