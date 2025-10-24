import 'package:edulift/features/schedule/presentation/utils/time_slot_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Skip widget tests that require localization
  // Focus on unit tests for internal logic

  group('TimeSlotMapper - getPeriodForTimeInternal', () {
    test('maps morning hours correctly', () {
      expect(
        TimeSlotMapper.getPeriodForTimeInternal('05:00'),
        PeriodOfDay.morning,
      );
      expect(
        TimeSlotMapper.getPeriodForTimeInternal('08:00'),
        PeriodOfDay.morning,
      );
      expect(
        TimeSlotMapper.getPeriodForTimeInternal('11:59'),
        PeriodOfDay.morning,
      );
    });

    test('maps midday hours correctly', () {
      expect(
        TimeSlotMapper.getPeriodForTimeInternal('12:00'),
        PeriodOfDay.midday,
      );
      expect(
        TimeSlotMapper.getPeriodForTimeInternal('13:00'),
        PeriodOfDay.midday,
      );
      expect(
        TimeSlotMapper.getPeriodForTimeInternal('13:59'),
        PeriodOfDay.midday,
      );
    });

    test('maps afternoon hours correctly', () {
      expect(
        TimeSlotMapper.getPeriodForTimeInternal('14:00'),
        PeriodOfDay.afternoon,
      );
      expect(
        TimeSlotMapper.getPeriodForTimeInternal('15:30'),
        PeriodOfDay.afternoon,
      );
      expect(
        TimeSlotMapper.getPeriodForTimeInternal('17:59'),
        PeriodOfDay.afternoon,
      );
    });

    test('maps evening hours correctly', () {
      expect(
        TimeSlotMapper.getPeriodForTimeInternal('18:00'),
        PeriodOfDay.evening,
      );
      expect(
        TimeSlotMapper.getPeriodForTimeInternal('19:30'),
        PeriodOfDay.evening,
      );
      expect(
        TimeSlotMapper.getPeriodForTimeInternal('20:59'),
        PeriodOfDay.evening,
      );
    });

    test('maps night hours correctly', () {
      expect(
        TimeSlotMapper.getPeriodForTimeInternal('21:00'),
        PeriodOfDay.night,
      );
      expect(
        TimeSlotMapper.getPeriodForTimeInternal('00:00'),
        PeriodOfDay.night,
      );
      expect(
        TimeSlotMapper.getPeriodForTimeInternal('04:59'),
        PeriodOfDay.night,
      );
    });

    test('handles invalid format', () {
      expect(
        TimeSlotMapper.getPeriodForTimeInternal('invalid'),
        PeriodOfDay.unknown,
      );
      expect(
        TimeSlotMapper.getPeriodForTimeInternal('25:00'),
        PeriodOfDay.unknown,
      );
      expect(TimeSlotMapper.getPeriodForTimeInternal(''), PeriodOfDay.unknown);
    });
  });
}
