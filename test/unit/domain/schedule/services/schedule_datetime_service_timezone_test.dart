import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:edulift/features/schedule/domain/services/schedule_datetime_service.dart';

void main() {
  group('ScheduleDateTimeService - Timezone Regression Tests', () {
    late ScheduleDateTimeService dateTimeService;

    setUpAll(() async {
      // Initialize timezone database for tests
      tz.initializeTimeZones();
      dateTimeService = const ScheduleDateTimeService();
    });

    group('calculateDateTimeFromSlot', () {
      test('should create UTC DateTime without timezone conversion', () {
        // Arrange
        const day = 'Monday';
        const time = '07:00';
        const week = '2025-W43'; // Week starting Oct 20, 2025

        // Act
        final result = dateTimeService.calculateDateTimeFromSlot(
          day,
          time,
          week,
        );

        // Assert
        expect(result, isNotNull);
        expect(result!.isUtc, isTrue);

        // Should be Monday of week 43, 2025 at 07:00 UTC
        final expected = DateTime.utc(2025, 10, 20, 7);
        expect(result, equals(expected));

        // Verify the result is exactly what we expect (no timezone conversion applied)
        expect(result.year, equals(2025));
        expect(result.month, equals(10));
        expect(result.day, equals(20));
        expect(result.hour, equals(7));
        expect(result.minute, equals(0));
        expect(result.second, equals(0));
        expect(result.millisecond, equals(0));
      });

      test('should handle different days correctly', () {
        // Test each day of the week
        final testCases = {
          'Monday': DateTime.utc(2025, 10, 20, 8, 30),
          'Tuesday': DateTime.utc(2025, 10, 21, 8, 30),
          'Wednesday': DateTime.utc(2025, 10, 22, 8, 30),
          'Thursday': DateTime.utc(2025, 10, 23, 8, 30),
          'Friday': DateTime.utc(2025, 10, 24, 8, 30),
          'Saturday': DateTime.utc(2025, 10, 25, 8, 30),
          'Sunday': DateTime.utc(2025, 10, 26, 8, 30),
        };

        for (final entry in testCases.entries) {
          final result = dateTimeService.calculateDateTimeFromSlot(
            entry.key,
            '08:30',
            '2025-W43',
          );

          expect(
            result,
            isNotNull,
            reason: 'Result should not be null for ${entry.key}',
          );
          expect(
            result!.isUtc,
            isTrue,
            reason: 'Result should be in UTC for ${entry.key}',
          );
          expect(
            result,
            equals(entry.value),
            reason: 'Incorrect datetime for ${entry.key}',
          );
        }
      });

      test('should handle different time formats correctly', () {
        final testCases = {
          '00:00': DateTime.utc(2025, 10, 20), // Midnight
          '12:00': DateTime.utc(2025, 10, 20, 12), // Noon
          '23:59': DateTime.utc(2025, 10, 20, 23, 59), // End of day
          '15:30': DateTime.utc(2025, 10, 20, 15, 30), // Afternoon
        };

        for (final entry in testCases.entries) {
          final result = dateTimeService.calculateDateTimeFromSlot(
            'Monday',
            entry.key,
            '2025-W43',
          );

          expect(
            result,
            isNotNull,
            reason: 'Result should not be null for ${entry.key}',
          );
          expect(
            result!.isUtc,
            isTrue,
            reason: 'Result should be in UTC for ${entry.key}',
          );
          expect(
            result,
            equals(entry.value),
            reason: 'Incorrect datetime for ${entry.key}',
          );
        }
      });

      test('should handle abbreviated day names', () {
        final testCases = {
          'Mon': DateTime.utc(2025, 10, 20, 9),
          'Tue': DateTime.utc(2025, 10, 21, 9),
          'Wed': DateTime.utc(2025, 10, 22, 9),
          'Thu': DateTime.utc(2025, 10, 23, 9),
          'Fri': DateTime.utc(2025, 10, 24, 9),
          'Sat': DateTime.utc(2025, 10, 25, 9),
          'Sun': DateTime.utc(2025, 10, 26, 9),
        };

        for (final entry in testCases.entries) {
          final result = dateTimeService.calculateDateTimeFromSlot(
            entry.key,
            '09:00',
            '2025-W43',
          );

          expect(
            result,
            isNotNull,
            reason: 'Result should not be null for ${entry.key}',
          );
          expect(
            result!.isUtc,
            isTrue,
            reason: 'Result should be in UTC for ${entry.key}',
          );
          expect(
            result,
            equals(entry.value),
            reason: 'Incorrect datetime for ${entry.key}',
          );
        }
      });

      test('should handle different weeks correctly', () {
        final testCases = {
          '2025-W01': DateTime.utc(
            2024,
            12,
            30,
            10,
          ), // Week 1 starts on Monday Dec 30, 2024
          '2025-W02': DateTime.utc(
            2025,
            1,
            6,
            10,
          ), // Week 2 starts on Monday Jan 6, 2025
          '2025-W52': DateTime.utc(
            2025,
            12,
            22,
            10,
          ), // Week 52 starts on Monday Dec 22, 2025
        };

        for (final entry in testCases.entries) {
          final result = dateTimeService.calculateDateTimeFromSlot(
            'Monday',
            '10:00',
            entry.key,
          );

          expect(
            result,
            isNotNull,
            reason: 'Result should not be null for ${entry.key}',
          );
          expect(
            result!.isUtc,
            isTrue,
            reason: 'Result should be in UTC for ${entry.key}',
          );
          expect(
            result,
            equals(entry.value),
            reason: 'Incorrect datetime for ${entry.key}',
          );
        }
      });

      group('Regression Tests', () {
        test('should NOT apply timezone conversion (regression test for issue)',
            () {
          // This test specifically verifies that the timezone conversion bug is fixed
          // The bug was: 07:00 (user local) was being converted to 04:00 UTC instead of 05:00 UTC
          // After fix: 07:00 should remain 07:00 UTC (no conversion in domain layer)

          const day = 'Monday';
          const time = '07:00'; // This is what user clicks on
          const week = '2025-W43';

          final result = dateTimeService.calculateDateTimeFromSlot(
            day,
            time,
            week,
          );

          expect(result, isNotNull);
          expect(result!.isUtc, isTrue);

          // CRITICAL: This should be EXACTLY 07:00 UTC, not converted from user timezone
          expect(result.hour, equals(7));
          expect(result.minute, equals(0));

          // The full datetime should match exactly
          final expected = DateTime.utc(2025, 10, 20, 7);
          expect(result, equals(expected));

          // Verify it's NOT the wrong converted time (04:00 UTC from the original bug)
          final wrongResult = DateTime.utc(2025, 10, 20, 4);
          expect(result, isNot(equals(wrongResult)));
        });

        test('should be deterministic regardless of system timezone', () {
          // This test verifies that the method produces the same result
          // regardless of the system's timezone settings

          const day = 'Wednesday';
          const time = '14:30';
          const week = '2025-W43';

          final result1 = dateTimeService.calculateDateTimeFromSlot(
            day,
            time,
            week,
          );
          final result2 = dateTimeService.calculateDateTimeFromSlot(
            day,
            time,
            week,
          );

          expect(result1, isNotNull);
          expect(result2, isNotNull);
          expect(result1, equals(result2));
          expect(result1!.isUtc, isTrue);
          expect(result2!.isUtc, isTrue);

          // Should be exactly Wednesday 2025-10-22 at 14:30 UTC
          final expected = DateTime.utc(2025, 10, 22, 14, 30);
          expect(result1, equals(expected));
          expect(result2, equals(expected));
        });
      });

      group('Error Cases', () {
        test('should return null for invalid day', () {
          final result = dateTimeService.calculateDateTimeFromSlot(
            'Funday', // Invalid day
            '09:00',
            '2025-W43',
          );

          expect(result, isNull);
        });

        test('should return null for invalid time format', () {
          final result = dateTimeService.calculateDateTimeFromSlot(
            'Monday',
            'invalid-time', // Invalid time format
            '2025-W43',
          );

          expect(result, isNull);
        });

        test('should return null for invalid week format', () {
          final result = dateTimeService.calculateDateTimeFromSlot(
            'Monday',
            '09:00',
            '2025-W99', // Invalid week
          );

          expect(result, isNull);
        });
      });
    });

    group('calculateWeekStartDate', () {
      test('should calculate correct week start dates', () {
        final testCases = {
          '2025-W01': DateTime.utc(2024, 12, 30), // Monday of week 1
          '2025-W02': DateTime.utc(2025, 1, 6), // Monday of week 2
          '2025-W43': DateTime.utc(2025, 10, 20), // Monday of week 43
          '2025-W52': DateTime.utc(2025, 12, 22), // Monday of week 52
        };

        for (final entry in testCases.entries) {
          final result = dateTimeService.calculateWeekStartDate(entry.key);

          expect(
            result,
            isNotNull,
            reason: 'Week start should not be null for ${entry.key}',
          );
          expect(
            result!.isUtc,
            isTrue,
            reason: 'Week start should be in UTC for ${entry.key}',
          );
          expect(
            result.year,
            equals(entry.value.year),
            reason: 'Year mismatch for ${entry.key}',
          );
          expect(
            result.month,
            equals(entry.value.month),
            reason: 'Month mismatch for ${entry.key}',
          );
          expect(
            result.day,
            equals(entry.value.day),
            reason: 'Day mismatch for ${entry.key}',
          );
          expect(
            result.hour,
            equals(0),
            reason: 'Hour should be 0 for ${entry.key}',
          );
          expect(
            result.minute,
            equals(0),
            reason: 'Minute should be 0 for ${entry.key}',
          );
        }
      });

      test('should return null for invalid week format', () {
        final result = dateTimeService.calculateWeekStartDate('invalid-week');
        expect(result, isNull);
      });
    });

    group('isPastDate and validateScheduleDateTime', () {
      test('should validate future dates correctly', () {
        final futureDate = DateTime.now().add(const Duration(days: 1)).toUtc();

        final isPast = dateTimeService.isPastDate(
          futureDate,
          userTimezone: 'UTC',
        );
        expect(isPast, isFalse);

        final validation = dateTimeService.validateScheduleDateTime(
          futureDate,
          userTimezone: 'UTC',
        );
        expect(validation.isValid, isTrue);
        expect(validation.errorMessage, isNull);
      });

      test('should validate past dates correctly', () {
        final pastDate =
            DateTime.now().subtract(const Duration(days: 1)).toUtc();

        final isPast = dateTimeService.isPastDate(
          pastDate,
          userTimezone: 'UTC',
        );
        expect(isPast, isTrue);

        final validation = dateTimeService.validateScheduleDateTime(
          pastDate,
          userTimezone: 'UTC',
        );
        expect(validation.isValid, isFalse);
        expect(validation.errorMessage, isNotNull);
        expect(validation.errorMessage!, contains('past time'));
      });
    });
  });
}
