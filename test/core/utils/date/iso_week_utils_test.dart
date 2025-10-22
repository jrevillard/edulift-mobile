import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/utils/date/iso_week_utils.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  // Initialize timezone database before running tests
  setUpAll(() {
    tz.initializeTimeZones();
  });

  group('ISO Week Utilities - Timezone Aware', () {
    group('getISOWeekNumber', () {
      test('should calculate ISO week in user timezone', () {
        // Week 1 of 2024 in Europe/Paris (UTC+1)
        // Monday 2024-01-01 00:00 CET = Sunday 2023-12-31 23:00 UTC
        final utcDate = DateTime.utc(2023, 12, 31, 23);
        final week = getISOWeekNumber(utcDate, 'Europe/Paris');
        expect(week, 1); // It's Monday in Paris, so Week 1
      });

      test('should handle timezone where week boundary differs from UTC - Asia/Tokyo', () {
        // Sunday 2024-12-31 20:00 UTC = Monday 2025-01-01 05:00 JST
        // In Tokyo, this is Monday of Week 1, 2025
        final utcDate = DateTime.utc(2024, 12, 31, 20);
        final week = getISOWeekNumber(utcDate, 'Asia/Tokyo');
        expect(week, 1);
      });

      test('should handle timezone where week boundary differs from UTC - America/Los_Angeles', () {
        // Monday 2024-01-01 07:00 UTC = Sunday 2023-12-31 23:00 PST
        // In LA, this is still Sunday of Week 52, 2023
        final utcDate = DateTime.utc(2024, 1, 1, 7);
        final week = getISOWeekNumber(utcDate, 'America/Los_Angeles');
        expect(week, 52);
      });

      test('should handle mid-week dates correctly', () {
        // Wednesday 2024-01-03 12:00 UTC in Europe/Paris
        final utcDate = DateTime.utc(2024, 1, 3, 12);
        final week = getISOWeekNumber(utcDate, 'Europe/Paris');
        expect(week, 1); // Week 1 of 2024
      });

      test('should handle DST transition within a week', () {
        // US DST starts on March 10, 2024 at 02:00 -> 03:00
        // Week containing DST transition
        final beforeDST = DateTime.utc(2024, 3, 8, 12); // Friday before DST
        final afterDST = DateTime.utc(2024, 3, 11, 12); // Monday after DST

        final weekBefore = getISOWeekNumber(beforeDST, 'America/New_York');
        final weekAfter = getISOWeekNumber(afterDST, 'America/New_York');

        // Both should be in different weeks
        expect(weekBefore, 10);
        expect(weekAfter, 11);
      });

      test('should handle year-end edge case', () {
        // Thursday 2024-12-26 12:00 UTC in Europe/Paris
        // This is Week 52 of 2024
        final utcDate = DateTime.utc(2024, 12, 26, 12);
        final week = getISOWeekNumber(utcDate, 'Europe/Paris');
        expect(week, 52);
      });

      test('should handle year-start edge case', () {
        // Sunday 2023-01-01 is in ISO Week 52 of 2022
        final utcDate = DateTime.utc(2023, 1, 1, 12);
        final week = getISOWeekNumber(utcDate, 'Europe/Paris');
        expect(week, 52); // Week 52 of 2022
      });
    });

    group('getISOWeekYear', () {
      test('should return correct year for dates in first ISO week', () {
        // Monday 2024-01-01 00:00 CET = Sunday 2023-12-31 23:00 UTC
        final utcDate = DateTime.utc(2023, 12, 31, 23);
        final year = getISOWeekYear(utcDate, 'Europe/Paris');
        expect(year, 2024); // Week 1 of 2024
      });

      test('should return correct year for Asia/Tokyo edge case', () {
        // Sunday 2024-12-31 20:00 UTC = Monday 2025-01-01 05:00 JST
        final utcDate = DateTime.utc(2024, 12, 31, 20);
        final year = getISOWeekYear(utcDate, 'Asia/Tokyo');
        expect(year, 2025); // Week 1 of 2025
      });

      test('should return correct year for America/Los_Angeles edge case', () {
        // Monday 2024-01-01 07:00 UTC = Sunday 2023-12-31 23:00 PST
        final utcDate = DateTime.utc(2024, 1, 1, 7);
        final year = getISOWeekYear(utcDate, 'America/Los_Angeles');
        expect(year, 2023); // Week 52 of 2023
      });

      test('should handle year-end dates that belong to next year', () {
        // Friday 2023-12-29 is in Week 52 of 2023
        final utcDate = DateTime.utc(2023, 12, 29, 12);
        final year = getISOWeekYear(utcDate, 'Europe/Paris');
        expect(year, 2023);
      });

      test('should handle year-start dates that belong to previous year', () {
        // Sunday 2023-01-01 is in ISO Week 52 of 2022
        final utcDate = DateTime.utc(2023, 1, 1, 12);
        final year = getISOWeekYear(utcDate, 'Europe/Paris');
        expect(year, 2022);
      });
    });

    group('getMondayOfISOWeek', () {
      test('should get correct date from ISO week in user timezone', () {
        // Week 1 of 2024 in Europe/Paris
        // Should return Monday 2024-01-01 00:00 CET = Sunday 2023-12-31 23:00 UTC
        final date = getMondayOfISOWeek(2024, 1, 'Europe/Paris');

        final location = tz.getLocation('Europe/Paris');
        final expected = tz.TZDateTime(location, 2024, 1, 1).toUtc();

        expect(date.toIso8601String(), expected.toIso8601String());
      });

      test('should get correct date from ISO week in Asia/Tokyo', () {
        // Week 1 of 2024 in Asia/Tokyo
        // Should return Monday 2024-01-01 00:00 JST = Sunday 2023-12-31 15:00 UTC
        final date = getMondayOfISOWeek(2024, 1, 'Asia/Tokyo');

        final location = tz.getLocation('Asia/Tokyo');
        final expected = tz.TZDateTime(location, 2024, 1, 1).toUtc();

        expect(date.toIso8601String(), expected.toIso8601String());
      });

      test('should get correct date from ISO week in America/Los_Angeles', () {
        // Week 52 of 2023 in America/Los_Angeles
        // Should return Monday 2023-12-25 00:00 PST = Monday 2023-12-25 08:00 UTC
        final date = getMondayOfISOWeek(2023, 52, 'America/Los_Angeles');

        final location = tz.getLocation('America/Los_Angeles');
        final expected = tz.TZDateTime(location, 2023, 12, 25).toUtc();

        expect(date.toIso8601String(), expected.toIso8601String());
      });

      test('should handle week during DST transition', () {
        // Week 11 of 2024 in America/New_York (contains DST start on March 10)
        final date = getMondayOfISOWeek(2024, 11, 'America/New_York');

        // Week 11 starts on Monday 2024-03-11 00:00 EDT (DST is in effect)
        // EDT is UTC-4, so Monday 00:00 EDT = Monday 04:00 UTC
        // But TZDateTime constructor creates time in standard time context

        // Just verify the date is correct (Monday March 11) and the week matches
        final resultWeek = getISOWeekNumber(date, 'America/New_York');
        final resultYear = getISOWeekYear(date, 'America/New_York');

        expect(resultWeek, 11);
        expect(resultYear, 2024);
        expect(date.day, 11);
        expect(date.month, 3);
      });

      test('should round-trip with getISOWeekNumber and getISOWeekYear', () {
        const timezone = 'Europe/Paris';
        const year = 2024;
        const week = 15;

        // Get date from week
        final date = getMondayOfISOWeek(year, week, timezone);

        // Convert back to week and year
        final resultWeek = getISOWeekNumber(date, timezone);
        final resultYear = getISOWeekYear(date, timezone);

        expect(resultWeek, week);
        expect(resultYear, year);
      });
    });

    group('getWeekBoundaries', () {
      test('should return correct week boundaries in user timezone', () {
        // Wednesday 2024-01-03 12:00 UTC in Europe/Paris
        final utcDate = DateTime.utc(2024, 1, 3, 12);
        final boundaries = getWeekBoundaries(utcDate, 'Europe/Paris');

        final location = tz.getLocation('Europe/Paris');

        // Week should start on Monday 2024-01-01 00:00 CET
        final expectedStart = tz.TZDateTime(location, 2024, 1, 1).toUtc();

        // Week should end on Sunday 2024-01-07 23:59:59.999 CET
        final expectedEnd = tz.TZDateTime(
          location,
          2024,
          1,
          7,
          23,
          59,
          59,
          999,
        ).toUtc();

        expect(boundaries.weekStart.toIso8601String(), expectedStart.toIso8601String());
        expect(boundaries.weekEnd.toIso8601String(), expectedEnd.toIso8601String());
      });

      test('should handle week boundaries in Asia/Tokyo', () {
        // Sunday 2024-12-31 20:00 UTC = Monday 2025-01-01 05:00 JST
        final utcDate = DateTime.utc(2024, 12, 31, 20);
        final boundaries = getWeekBoundaries(utcDate, 'Asia/Tokyo');

        final location = tz.getLocation('Asia/Tokyo');

        // Week should start on Monday 2024-12-30 00:00 JST
        final expectedStart = tz.TZDateTime(location, 2024, 12, 30).toUtc();

        // Week should end on Sunday 2025-01-05 23:59:59.999 JST
        final expectedEnd = tz.TZDateTime(
          location,
          2025,
          1,
          5,
          23,
          59,
          59,
          999,
        ).toUtc();

        expect(boundaries.weekStart.toIso8601String(), expectedStart.toIso8601String());
        expect(boundaries.weekEnd.toIso8601String(), expectedEnd.toIso8601String());
      });

      test('should handle week boundaries in America/Los_Angeles', () {
        // Monday 2024-01-01 07:00 UTC = Sunday 2023-12-31 23:00 PST
        final utcDate = DateTime.utc(2024, 1, 1, 7);
        final boundaries = getWeekBoundaries(utcDate, 'America/Los_Angeles');

        final location = tz.getLocation('America/Los_Angeles');

        // Week should start on Monday 2023-12-25 00:00 PST (Week 52)
        final expectedStart = tz.TZDateTime(location, 2023, 12, 25).toUtc();

        // Week should end on Sunday 2023-12-31 23:59:59.999 PST
        final expectedEnd = tz.TZDateTime(
          location,
          2023,
          12,
          31,
          23,
          59,
          59,
          999,
        ).toUtc();

        expect(boundaries.weekStart.toIso8601String(), expectedStart.toIso8601String());
        expect(boundaries.weekEnd.toIso8601String(), expectedEnd.toIso8601String());
      });
    });

    group('formatISOWeek', () {
      test('should format ISO week correctly', () {
        final utcDate = DateTime.utc(2024, 1, 3, 12);
        final formatted = formatISOWeek(utcDate, 'Europe/Paris');
        expect(formatted, 'Week 1, 2024');
      });

      test('should format ISO week for year-end edge case', () {
        // Sunday 2023-01-01 is in Week 52 of 2022
        final utcDate = DateTime.utc(2023, 1, 1, 12);
        final formatted = formatISOWeek(utcDate, 'Europe/Paris');
        expect(formatted, 'Week 52, 2022');
      });

      test('should format ISO week for timezone edge case', () {
        // Monday 2024-01-01 07:00 UTC = Sunday 2023-12-31 23:00 PST
        final utcDate = DateTime.utc(2024, 1, 1, 7);
        final formatted = formatISOWeek(utcDate, 'America/Los_Angeles');
        expect(formatted, 'Week 52, 2023');
      });
    });

    group('isSameISOWeek', () {
      test('should return true for dates in same ISO week', () {
        final monday = DateTime.utc(2024, 1, 1, 12);
        final friday = DateTime.utc(2024, 1, 5, 12);
        final result = isSameISOWeek(monday, friday, 'Europe/Paris');
        expect(result, true);
      });

      test('should return false for dates in different ISO weeks', () {
        final sunday = DateTime.utc(2023, 12, 31, 12); // Week 52 of 2023
        final monday = DateTime.utc(2024, 1, 1, 12); // Week 1 of 2024
        final result = isSameISOWeek(sunday, monday, 'Europe/Paris');
        expect(result, false);
      });

      test('should handle timezone differences', () {
        // Sunday 2024-12-31 20:00 UTC = Monday 2025-01-01 05:00 JST (Week 1)
        // Monday 2025-01-01 12:00 UTC = Monday 2025-01-01 21:00 JST (Week 1)
        final date1 = DateTime.utc(2024, 12, 31, 20);
        final date2 = DateTime.utc(2025, 1, 1, 12);
        final result = isSameISOWeek(date1, date2, 'Asia/Tokyo');
        expect(result, true); // Both are in Week 1 of 2025 in Tokyo
      });

      test('should return false for dates in different years', () {
        final date1 = DateTime.utc(2023, 12, 28, 12); // Week 52 of 2023
        final date2 = DateTime.utc(2024, 1, 4, 12); // Week 1 of 2024
        final result = isSameISOWeek(date1, date2, 'Europe/Paris');
        expect(result, false);
      });
    });

    group('parseMondayFromISOWeek', () {
      test('should parse valid ISO week string', () {
        final monday = parseMondayFromISOWeek('2024-W01', 'Europe/Paris');
        expect(monday, isNotNull);

        final week = getISOWeekNumber(monday!, 'Europe/Paris');
        final year = getISOWeekYear(monday, 'Europe/Paris');

        expect(week, 1);
        expect(year, 2024);
      });

      test('should return null for invalid format', () {
        final monday = parseMondayFromISOWeek('2024-01', 'Europe/Paris');
        expect(monday, isNull);
      });

      test('should return null for out-of-range week', () {
        final monday = parseMondayFromISOWeek('2024-W54', 'Europe/Paris');
        expect(monday, isNull);
      });
    });

    group('addWeeksToISOWeek', () {
      test('should add weeks within same year', () {
        final result = addWeeksToISOWeek('2024-W10', 5, 'Europe/Paris');
        expect(result, '2024-W15');
      });

      test('should handle year boundary when adding weeks', () {
        final result = addWeeksToISOWeek('2024-W50', 5, 'Europe/Paris');
        expect(result, '2025-W03');
      });

      test('should handle negative weeks (subtract)', () {
        final result = addWeeksToISOWeek('2024-W10', -5, 'Europe/Paris');
        expect(result, '2024-W05');
      });

      test('should handle year boundary when subtracting weeks', () {
        final result = addWeeksToISOWeek('2024-W02', -5, 'Europe/Paris');
        expect(result, '2023-W49');
      });
    });

    group('weeksBetween', () {
      test('should calculate positive weeks between', () {
        final weeks = weeksBetween('2024-W10', '2024-W15', 'Europe/Paris');
        expect(weeks, 5);
      });

      test('should calculate negative weeks between', () {
        final weeks = weeksBetween('2024-W15', '2024-W10', 'Europe/Paris');
        expect(weeks, -5);
      });

      test('should handle year boundaries', () {
        final weeks = weeksBetween('2023-W52', '2024-W02', 'Europe/Paris');
        expect(weeks, 2);
      });
    });

    group('getISOWeekString', () {
      test('should format ISO week string', () {
        final utcDate = DateTime.utc(2024, 1, 3, 12);
        final weekString = getISOWeekString(utcDate, 'Europe/Paris');
        expect(weekString, '2024-W01');
      });

      test('should pad week number with zero', () {
        final utcDate = DateTime.utc(2024, 3, 1, 12);
        final weekString = getISOWeekString(utcDate, 'Europe/Paris');
        expect(weekString, '2024-W09');
      });
    });

    group('getWeeksInYear', () {
      test('should return 52 for regular year', () {
        final weeks = getWeeksInYear(2023, 'Europe/Paris');
        expect(weeks, 52);
      });

      test('should return 53 for year starting on Thursday', () {
        // 2015 starts on Thursday
        final weeks = getWeeksInYear(2015, 'Europe/Paris');
        expect(weeks, 53);
      });

      test('should return 53 for leap year starting on Wednesday', () {
        // 2020 is a leap year starting on Wednesday
        final weeks = getWeeksInYear(2020, 'Europe/Paris');
        expect(weeks, 53);
      });
    });

    group('Cross-Platform Parity - Backend Verification', () {
      test('should match backend: Asia/Tokyo - Sunday 2024-12-31 20:00 UTC → Week 1, 2025', () {
        final utcDate = DateTime.utc(2024, 12, 31, 20);
        final week = getISOWeekNumber(utcDate, 'Asia/Tokyo');
        final year = getISOWeekYear(utcDate, 'Asia/Tokyo');

        // In Tokyo, this is Monday 2025-01-01 05:00 JST → Week 1, 2025
        expect(week, 1);
        expect(year, 2025);
      });

      test('should match backend: America/Los_Angeles - Monday 2024-01-01 07:00 UTC → Week 52, 2023', () {
        final utcDate = DateTime.utc(2024, 1, 1, 7);
        final week = getISOWeekNumber(utcDate, 'America/Los_Angeles');
        final year = getISOWeekYear(utcDate, 'America/Los_Angeles');

        // In LA, this is Sunday 2023-12-31 23:00 PST → Week 52, 2023
        expect(week, 52);
        expect(year, 2023);
      });

      test('should match backend: week boundaries are Monday 00:00 in user timezone', () {
        final utcDate = DateTime.utc(2024, 1, 3, 12);
        final boundaries = getWeekBoundaries(utcDate, 'Europe/Paris');

        // Convert back to Europe/Paris to check
        final location = tz.getLocation('Europe/Paris');
        final startInParis = tz.TZDateTime.from(boundaries.weekStart, location);

        expect(startInParis.weekday, DateTime.monday); // Monday
        expect(startInParis.hour, 0);
        expect(startInParis.minute, 0);
        expect(startInParis.second, 0);
        expect(startInParis.millisecond, 0);
      });

      test('should match backend: Europe/Paris - Monday 2024-01-01 00:00 CET → Week 1, 2024', () {
        // Monday 2024-01-01 00:00 CET = Sunday 2023-12-31 23:00 UTC
        final utcDate = DateTime.utc(2023, 12, 31, 23);
        final week = getISOWeekNumber(utcDate, 'Europe/Paris');
        final year = getISOWeekYear(utcDate, 'Europe/Paris');

        expect(week, 1);
        expect(year, 2024);
      });

      test('should match backend: round-trip conversion consistency', () {
        const timezone = 'Asia/Tokyo';
        const year = 2025;
        const week = 1;

        // Get Monday from week
        final monday = getMondayOfISOWeek(year, week, timezone);

        // Convert back to week and year
        final resultWeek = getISOWeekNumber(monday, timezone);
        final resultYear = getISOWeekYear(monday, timezone);

        expect(resultWeek, week);
        expect(resultYear, year);
      });
    });

    group('DST Handling', () {
      test('should handle DST start transition correctly', () {
        // US DST starts on March 10, 2024 at 02:00 -> 03:00
        final beforeDST = DateTime.utc(2024, 3, 10, 6); // 01:00 EST
        final afterDST = DateTime.utc(2024, 3, 10, 8); // 04:00 EDT (after spring forward)

        final weekBefore = getISOWeekNumber(beforeDST, 'America/New_York');
        final weekAfter = getISOWeekNumber(afterDST, 'America/New_York');

        // Both should be in the same week (Week 10)
        expect(weekBefore, 10);
        expect(weekAfter, 10);
      });

      test('should handle DST end transition correctly', () {
        // US DST ends on November 3, 2024 at 02:00 -> 01:00
        final beforeDST = DateTime.utc(2024, 11, 3, 5); // 01:00 EDT
        final afterDST = DateTime.utc(2024, 11, 3, 7); // 02:00 EST (after fall back)

        final weekBefore = getISOWeekNumber(beforeDST, 'America/New_York');
        final weekAfter = getISOWeekNumber(afterDST, 'America/New_York');

        // Both should be in the same week (Week 44)
        expect(weekBefore, 44);
        expect(weekAfter, 44);
      });
    });
  });
}
