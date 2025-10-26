import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:edulift/features/schedule/domain/services/schedule_datetime_service.dart';

void main() {
  // Initialize timezone database for tests
  setUpAll(() {
    tz.initializeTimeZones();
  });
  group('ScheduleDateTimeService', () {
    late ScheduleDateTimeService service;

    setUp(() {
      service = const ScheduleDateTimeService();
    });

    group('calculateWeekStartDate', () {
      test('should calculate correct Monday for 2025-W02', () {
        final result = service.calculateWeekStartDate('2025-W02');

        expect(result, isNotNull);
        expect(result!.year, equals(2025));
        expect(result.month, equals(1));
        expect(result.day, equals(6)); // Monday, Jan 6, 2025
        expect(result.weekday, equals(DateTime.monday));
      });

      test('should return null for invalid week format', () {
        final result = service.calculateWeekStartDate('invalid');
        expect(result, isNull);
      });
    });

    group('calculateDateTimeFromSlot', () {
      test('should calculate correct UTC datetime for Monday 07:30', () {
        final result = service.calculateDateTimeFromSlot(
          'Monday',
          '07:30',
          '2025-W02',
        );

        expect(result, isNotNull);
        expect(result!.isUtc, isTrue);
        expect(result.year, equals(2025));
        expect(result.month, equals(1));
        expect(result.day, equals(6)); // Monday of week 2

        // Input time is treated as UTC (no timezone conversion)
        expect(result.hour, equals(7), reason: 'UTC hour should be 7');
        expect(result.minute, equals(30), reason: 'UTC minute should be 30');
      });

      test('should calculate correct UTC datetime for Friday 16:00', () {
        final result = service.calculateDateTimeFromSlot(
          'Friday',
          '16:00',
          '2025-W02',
        );

        expect(result, isNotNull);
        expect(result!.isUtc, isTrue);
        expect(result.year, equals(2025));
        expect(result.month, equals(1));
        expect(result.day, equals(10)); // Friday of week 2

        // Input time is treated as UTC (no timezone conversion)
        expect(result.hour, equals(16), reason: 'UTC hour should be 16');
        expect(result.minute, equals(0), reason: 'UTC minute should be 0');
      });

      test('should handle all weekdays correctly', () {
        final days = {
          'Monday': 6,
          'Tuesday': 7,
          'Wednesday': 8,
          'Thursday': 9,
          'Friday': 10,
          'Saturday': 11,
          'Sunday': 12,
        };

        for (final entry in days.entries) {
          final result = service.calculateDateTimeFromSlot(
            entry.key,
            '12:00',
            '2025-W02',
          );

          expect(result, isNotNull, reason: 'Failed for ${entry.key}');
          expect(
            result!.day,
            equals(entry.value),
            reason: 'Wrong day for ${entry.key}',
          );

          // Input time is treated as UTC (no timezone conversion)
          expect(result.hour, equals(12), reason: 'UTC hour should be 12');
          expect(result.minute, equals(0), reason: 'UTC minute should be 0');
        }
      });

      test('should handle short day names', () {
        final result = service.calculateDateTimeFromSlot(
          'Mon',
          '08:00',
          '2025-W02',
        );
        expect(result, isNotNull);
        expect(result!.day, equals(6)); // Monday of week 2
      });

      test('should return null for invalid day', () {
        final result = service.calculateDateTimeFromSlot(
          'InvalidDay',
          '08:00',
          '2025-W02',
        );
        expect(result, isNull);
      });

      test('should return null for invalid time format', () {
        final result = service.calculateDateTimeFromSlot(
          'Monday',
          'invalid',
          '2025-W02',
        );
        expect(result, isNull);
      });

      test('should return null for invalid week', () {
        final result = service.calculateDateTimeFromSlot(
          'Monday',
          '08:00',
          'invalid',
        );
        expect(result, isNull);
      });

      test('should produce ISO 8601 string with Z suffix', () {
        final result = service.calculateDateTimeFromSlot(
          'Monday',
          '07:30',
          '2025-W02',
        );

        expect(result, isNotNull);
        final isoString = result!.toIso8601String();
        expect(
          isoString,
          endsWith('Z'),
          reason: 'ISO string should end with Z for UTC',
        );
        expect(
          isoString,
          matches(r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z'),
        );
      });
    });

    group('calculateWeekEndDate', () {
      test('should calculate Sunday 23:59:59.999 from Monday', () {
        final weekStart = DateTime.utc(2025, 1, 6); // Monday
        final weekEnd = service.calculateWeekEndDate(weekStart);

        expect(weekEnd.year, equals(2025));
        expect(weekEnd.month, equals(1));
        expect(weekEnd.day, equals(12)); // Sunday
        expect(weekEnd.hour, equals(23));
        expect(weekEnd.minute, equals(59));
        expect(weekEnd.second, equals(59));
        expect(weekEnd.millisecond, equals(999));
        expect(weekEnd.weekday, equals(DateTime.sunday));
      });

      test('should be exactly 7 days minus 1 millisecond', () {
        final weekStart = DateTime.utc(2025, 1, 6);
        final weekEnd = service.calculateWeekEndDate(weekStart);
        final expectedEnd = weekStart
            .add(const Duration(days: 7))
            .subtract(const Duration(milliseconds: 1));

        expect(weekEnd, equals(expectedEnd));
      });
    });

    group('datetime comparison scenario', () {
      test('two datetimes with same values should match', () {
        final datetime1 = service.calculateDateTimeFromSlot(
          'Monday',
          '07:30',
          '2025-W02',
        );
        final datetime2 = service.calculateDateTimeFromSlot(
          'Monday',
          '07:30',
          '2025-W02',
        );

        expect(datetime1, isNotNull);
        expect(datetime2, isNotNull);

        // Test exact match (what _findExistingSlot does)
        final matches =
            datetime1!.year == datetime2!.year &&
            datetime1.month == datetime2.month &&
            datetime1.day == datetime2.day &&
            datetime1.hour == datetime2.hour &&
            datetime1.minute == datetime2.minute;

        expect(
          matches,
          isTrue,
          reason: 'Same slot should produce matching datetimes',
        );
      });

      test('different times should not match', () {
        final datetime1 = service.calculateDateTimeFromSlot(
          'Monday',
          '07:30',
          '2025-W02',
        );
        final datetime2 = service.calculateDateTimeFromSlot(
          'Monday',
          '08:00',
          '2025-W02',
        );

        expect(datetime1, isNotNull);
        expect(datetime2, isNotNull);

        final matches =
            datetime1!.year == datetime2!.year &&
            datetime1.month == datetime2.month &&
            datetime1.day == datetime2.day &&
            datetime1.hour == datetime2.hour &&
            datetime1.minute == datetime2.minute;

        expect(matches, isFalse, reason: 'Different times should not match');
      });
    });

    group('timezone conversion (bug regression test)', () {
      test('should NOT apply timezone conversion', () {
        // REGRESSION TEST: Input time should be treated as UTC directly
        // User clicks 07:30 → should store as 07:30 UTC (no conversion)

        final utcResult = service.calculateDateTimeFromSlot(
          'Monday',
          '07:30',
          '2025-W02',
        );
        expect(utcResult, isNotNull);
        expect(utcResult!.isUtc, isTrue);

        // The UTC time should be exactly what was input (no conversion)
        expect(
          utcResult.hour,
          equals(7),
          reason: 'Input time 07:30 should become 07:30 UTC (no conversion)',
        );
        expect(utcResult.minute, equals(30));

        // Verify the full datetime
        final expected = DateTime.utc(2025, 1, 6, 7, 30);
        expect(utcResult, equals(expected));
      });

      test('should produce consistent datetime when stored and retrieved', () {
        // Simulate the full flow: User clicks → Store → Retrieve → Display

        // 1. User clicks 07:30 (treated as UTC by calculateDateTimeFromSlot)
        final userClickedUtc = service.calculateDateTimeFromSlot(
          'Monday',
          '07:30',
          '2025-W02',
        );
        expect(userClickedUtc, isNotNull);

        // 2. This gets sent to API and stored in DB as UTC (simulated)
        final storedUtcString = userClickedUtc!.toIso8601String();

        // 3. Backend returns the UTC datetime (simulated by parsing the stored string)
        final retrievedUtc = DateTime.parse(storedUtcString);
        expect(retrievedUtc.isUtc, isTrue);

        // 4. Verify: The time remains 07:30 UTC (no conversion applied)
        expect(
          retrievedUtc.hour,
          equals(7),
          reason: 'Stored UTC time should remain 07:30',
        );
        expect(retrievedUtc.minute, equals(30));

        // The full datetime should match exactly
        final expected = DateTime.utc(2025, 1, 6, 7, 30);
        expect(retrievedUtc, equals(expected));
      });
    });

    group('isPastDate - User Timezone Tests', () {
      test('should check if date is past in user timezone', () {
        // Create a datetime that is definitely in the past (2020)
        final pastDate = DateTime.utc(2020, 1, 1, 12);

        // Check in different timezones - should be past in all
        expect(
          service.isPastDate(pastDate, userTimezone: 'America/New_York'),
          isTrue,
          reason: 'Date in 2020 should be past in New York',
        );
        expect(
          service.isPastDate(pastDate, userTimezone: 'Europe/Paris'),
          isTrue,
          reason: 'Date in 2020 should be past in Paris',
        );
        expect(
          service.isPastDate(pastDate, userTimezone: 'UTC'),
          isTrue,
          reason: 'Date in 2020 should be past in UTC',
        );
      });

      test(
        'should allow dates past in device timezone but future in user timezone',
        () {
          // Create a scenario where a date is past in UTC but future in New York
          // Current time in UTC: 2025-10-20 04:00:00 (midnight in NY)
          // Schedule time in UTC: 2025-10-20 01:00:00 (9pm previous day in NY)
          // This requires us to create a future time in NY timezone

          final nyLocation = tz.getLocation('America/New_York');
          final nowInNY = tz.TZDateTime.now(nyLocation);

          // Create a datetime 2 hours from now in NY time
          final futureInNY = nowInNY.add(const Duration(hours: 2));

          // Convert to UTC for testing
          final futureInNYasUTC = futureInNY.toUtc();

          // This should NOT be past in NY timezone
          expect(
            service.isPastDate(
              futureInNYasUTC,
              userTimezone: 'America/New_York',
            ),
            isFalse,
            reason: 'Date 2 hours in future (NY time) should not be past',
          );
        },
      );

      test('should handle DST transitions correctly', () {
        // Test dates around DST transitions
        // March 2025 DST start: 2025-03-09 02:00 → 03:00 in America/New_York
        final nyLocation = tz.getLocation('America/New_York');

        // Create a time during DST transition (this will be adjusted by timezone lib)
        // Create a time before the DST date
        final beforeDst = tz.TZDateTime(nyLocation, 2025, 3, 9, 10);
        final beforeDstUtc = beforeDst.toUtc();

        // The "before" time should be past when checking from "after" time perspective
        // We'll simulate this by checking if beforeDstUtc is past relative to a point after it

        // This test verifies the service can handle DST-affected datetimes
        expect(
          service.isPastDate(beforeDstUtc, userTimezone: 'America/New_York'),
          isTrue,
          reason: 'Past date should be correctly identified even during DST',
        );
      });

      test('should use UTC as default when timezone is null', () {
        final pastDate = DateTime.utc(2020, 1, 1, 12);

        // Should default to UTC when timezone not provided
        expect(
          service.isPastDate(pastDate),
          isTrue,
          reason: 'Should use UTC when timezone is null',
        );
      });

      test('should handle invalid timezone gracefully', () {
        final pastDate = DateTime.utc(2020, 1, 1, 12);

        // Invalid timezone should fallback to UTC comparison
        expect(
          service.isPastDate(pastDate, userTimezone: 'Invalid/Timezone'),
          isTrue,
          reason: 'Should fallback to UTC for invalid timezone',
        );
      });

      test('should correctly compare future dates in different timezones', () {
        // Create a datetime far in the future (1 week from now)
        final futureDate = DateTime.now().toUtc().add(const Duration(days: 7));

        // Should be future in all timezones
        expect(
          service.isPastDate(futureDate, userTimezone: 'America/New_York'),
          isFalse,
          reason: 'Date 1 week in future should not be past in NY',
        );
        expect(
          service.isPastDate(futureDate, userTimezone: 'Europe/Paris'),
          isFalse,
          reason: 'Date 1 week in future should not be past in Paris',
        );
      });
    });

    group('validateScheduleDateTime - User Timezone Tests', () {
      test('should validate future datetime as valid', () {
        // Create a datetime 1 day in the future
        final futureDate = DateTime.now().toUtc().add(const Duration(days: 1));

        final result = service.validateScheduleDateTime(
          futureDate,
          userTimezone: 'America/New_York',
        );

        expect(result.isValid, isTrue);
        expect(result.errorMessage, isNull);
      });

      test('should reject past datetime with error message', () {
        final pastDate = DateTime.utc(2020, 1, 1, 12);

        final result = service.validateScheduleDateTime(
          pastDate,
          userTimezone: 'America/New_York',
        );

        expect(result.isValid, isFalse);
        expect(result.errorMessage, isNotNull);
        expect(result.errorMessage, contains('past time'));
        expect(result.errorMessage, contains('timezone'));
      });

      test('should include timezone abbreviation in error message', () {
        final pastDate = DateTime.utc(2020, 1, 1, 12);

        final result = service.validateScheduleDateTime(
          pastDate,
          userTimezone: 'America/New_York',
        );

        expect(result.isValid, isFalse);
        expect(result.errorMessage, isNotNull);
        // Error message should include EST or EDT
        expect(
          result.errorMessage!.contains('EST') ||
              result.errorMessage!.contains('EDT'),
          isTrue,
          reason: 'Error message should include timezone abbreviation',
        );
      });

      test('should validate correctly across timezone boundaries', () {
        // Create a scenario where it's past midnight UTC but still evening in NY
        final nyLocation = tz.getLocation('America/New_York');
        final nowInNY = tz.TZDateTime.now(nyLocation);

        // Add 3 hours to current NY time (definitely future)
        final futureInNY = nowInNY.add(const Duration(hours: 3));
        final futureInNYasUTC = futureInNY.toUtc();

        final result = service.validateScheduleDateTime(
          futureInNYasUTC,
          userTimezone: 'America/New_York',
        );

        expect(result.isValid, isTrue);
      });

      test('should handle validation with null timezone (defaults to UTC)', () {
        final futureDate = DateTime.now().toUtc().add(const Duration(days: 1));

        final result = service.validateScheduleDateTime(futureDate);

        expect(result.isValid, isTrue);
      });

      test('should handle validation errors gracefully', () {
        final futureDate = DateTime.now().toUtc().add(const Duration(days: 1));

        // Test with invalid timezone - it falls back to UTC comparison
        // Since the date is in the future, it should still be valid
        final result = service.validateScheduleDateTime(
          futureDate,
          userTimezone: 'Invalid/Timezone',
        );

        // With fallback to UTC, future date should still be valid
        // The error handling catches the invalid timezone and falls back gracefully
        expect(result.isValid, isTrue);
      });

      test('should validate schedule across DST boundary', () {
        // Create a datetime during DST transition period
        final nyLocation = tz.getLocation('America/New_York');
        final nowInNY = tz.TZDateTime.now(nyLocation);

        // Create a future date well after current time (2 weeks from now to ensure it's future)
        final futureDate = nowInNY.add(const Duration(days: 14));
        final futureDateUtc = futureDate.toUtc();

        final result = service.validateScheduleDateTime(
          futureDateUtc,
          userTimezone: 'America/New_York',
        );

        expect(result.isValid, isTrue);
      });
    });

    group('Edge Cases - Timezone Validation', () {
      test('should handle datetime exactly at current time', () {
        final nyLocation = tz.getLocation('America/New_York');
        final nowInNY = tz.TZDateTime.now(nyLocation);
        final nowInNYasUTC = nowInNY.toUtc();

        // Current time should be considered past (not valid for scheduling)
        expect(
          service.isPastDate(nowInNYasUTC, userTimezone: 'America/New_York'),
          isTrue,
          reason: 'Current time should be considered past',
        );
      });

      test('should handle datetime 1 second in the future', () {
        final nyLocation = tz.getLocation('America/New_York');
        final nowInNY = tz.TZDateTime.now(nyLocation);
        final futureByOneSecond = nowInNY.add(const Duration(seconds: 1));
        final futureByOneSecondUTC = futureByOneSecond.toUtc();

        expect(
          service.isPastDate(
            futureByOneSecondUTC,
            userTimezone: 'America/New_York',
          ),
          isFalse,
          reason: 'Time 1 second in future should not be past',
        );
      });

      test(
        'should handle extreme timezone differences (Pacific to Eastern)',
        () {
          // Create a time that's evening in LA but late night in NY
          final laLocation = tz.getLocation('America/Los_Angeles');
          final futureInLA = tz.TZDateTime.now(
            laLocation,
          ).add(const Duration(hours: 5));
          final futureInLAasUTC = futureInLA.toUtc();

          // Should be future in both LA and NY timezones
          expect(
            service.isPastDate(
              futureInLAasUTC,
              userTimezone: 'America/Los_Angeles',
            ),
            isFalse,
          );
          expect(
            service.isPastDate(
              futureInLAasUTC,
              userTimezone: 'America/New_York',
            ),
            isFalse,
          );
        },
      );
    });
  });
}
