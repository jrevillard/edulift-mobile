import 'package:equatable/equatable.dart';
import '../../../../core/domain/entities/schedule/schedule_slot.dart';
import 'day_of_week.dart';
import 'schedule_period.dart';
import 'time_of_day.dart';

/// Represents schedule data for a specific period slot
///
/// **TYPE-SAFE DOMAIN MODEL**
/// - Uses [DayOfWeek] enum instead of strings for day representation
/// - Uses [SchedulePeriod] sealed class for period/time representation
/// - Uses [TimeOfDayValue] for individual time slots
///
/// This ensures compile-time guarantees and eliminates string validation bugs.
class PeriodSlotData extends Equatable {
  /// Day of the week (type-safe enum)
  final DayOfWeek dayOfWeek;

  /// Period information (aggregate period OR specific time slot)
  final SchedulePeriod period;

  /// All time slots in this period (extracted from SchedulePeriod)
  final List<TimeOfDayValue> times;

  /// Schedule slots with vehicle assignments
  final List<ScheduleSlot> slots;

  /// Week identifier (ISO week format: "YYYY-WNN")
  final String week;

  const PeriodSlotData({
    required this.dayOfWeek,
    required this.period,
    required this.times,
    required this.slots,
    required this.week,
  });

  @override
  List<Object?> get props => [dayOfWeek, period, times, slots, week];

  PeriodSlotData copyWith({
    DayOfWeek? dayOfWeek,
    SchedulePeriod? period,
    List<TimeOfDayValue>? times,
    List<ScheduleSlot>? slots,
    String? week,
  }) {
    return PeriodSlotData(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      period: period ?? this.period,
      times: times ?? this.times,
      slots: slots ?? this.slots,
      week: week ?? this.week,
    );
  }
}
