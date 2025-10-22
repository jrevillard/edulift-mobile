import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/domain/entities/schedule.dart';

void main() {
  group('DayOfWeek Entity', () {
    group('Enum Values and Properties', () {
      test('should have correct weekday values', () {
        expect(DayOfWeek.monday.weekday, 1);
        expect(DayOfWeek.tuesday.weekday, 2);
        expect(DayOfWeek.wednesday.weekday, 3);
        expect(DayOfWeek.thursday.weekday, 4);
        expect(DayOfWeek.friday.weekday, 5);
        expect(DayOfWeek.saturday.weekday, 6);
        expect(DayOfWeek.sunday.weekday, 7);
      });

      test('should have correct full names', () {
        expect(DayOfWeek.monday.fullName, 'Monday');
        expect(DayOfWeek.tuesday.fullName, 'Tuesday');
        expect(DayOfWeek.wednesday.fullName, 'Wednesday');
        expect(DayOfWeek.thursday.fullName, 'Thursday');
        expect(DayOfWeek.friday.fullName, 'Friday');
        expect(DayOfWeek.saturday.fullName, 'Saturday');
        expect(DayOfWeek.sunday.fullName, 'Sunday');
      });

      test('should have correct short names', () {
        expect(DayOfWeek.monday.shortName, 'Mon');
        expect(DayOfWeek.tuesday.shortName, 'Tue');
        expect(DayOfWeek.wednesday.shortName, 'Wed');
        expect(DayOfWeek.thursday.shortName, 'Thu');
        expect(DayOfWeek.friday.shortName, 'Fri');
        expect(DayOfWeek.saturday.shortName, 'Sat');
        expect(DayOfWeek.sunday.shortName, 'Sun');
      });
    });

    group('fromWeekday Factory Method', () {
      test('should create correct DayOfWeek from weekday int', () {
        expect(DayOfWeek.fromWeekday(1), DayOfWeek.monday);
        expect(DayOfWeek.fromWeekday(2), DayOfWeek.tuesday);
        expect(DayOfWeek.fromWeekday(3), DayOfWeek.wednesday);
        expect(DayOfWeek.fromWeekday(4), DayOfWeek.thursday);
        expect(DayOfWeek.fromWeekday(5), DayOfWeek.friday);
        expect(DayOfWeek.fromWeekday(6), DayOfWeek.saturday);
        expect(DayOfWeek.fromWeekday(7), DayOfWeek.sunday);
      });

      test('should throw ArgumentError for invalid weekday values', () {
        expect(() => DayOfWeek.fromWeekday(0), throwsArgumentError);
        expect(() => DayOfWeek.fromWeekday(8), throwsArgumentError);
        expect(() => DayOfWeek.fromWeekday(-1), throwsArgumentError);
        expect(() => DayOfWeek.fromWeekday(100), throwsArgumentError);
      });

      test('should throw ArgumentError with descriptive message', () {
        expect(
          () => DayOfWeek.fromWeekday(0),
          throwsA(
            predicate(
              (e) => e is ArgumentError && e.message == 'Invalid weekday: 0',
            ),
          ),
        );
        expect(
          () => DayOfWeek.fromWeekday(10),
          throwsA(
            predicate(
              (e) => e is ArgumentError && e.message == 'Invalid weekday: 10',
            ),
          ),
        );
      });
    });

    group('fromDateTime Factory Method', () {
      test('should create correct DayOfWeek from DateTime', () {
        // Test specific dates with known weekdays
        final monday = DateTime(2025, 1, 27); // Monday
        final tuesday = DateTime(2025, 1, 28); // Tuesday
        final wednesday = DateTime(2025, 1, 29); // Wednesday
        final thursday = DateTime(2025, 1, 30); // Thursday
        final friday = DateTime(2025, 1, 31); // Friday
        final saturday = DateTime(2025, 2); // Saturday
        final sunday = DateTime(2025, 2, 2); // Sunday

        expect(DayOfWeek.fromDateTime(monday), DayOfWeek.monday);
        expect(DayOfWeek.fromDateTime(tuesday), DayOfWeek.tuesday);
        expect(DayOfWeek.fromDateTime(wednesday), DayOfWeek.wednesday);
        expect(DayOfWeek.fromDateTime(thursday), DayOfWeek.thursday);
        expect(DayOfWeek.fromDateTime(friday), DayOfWeek.friday);
        expect(DayOfWeek.fromDateTime(saturday), DayOfWeek.saturday);
        expect(DayOfWeek.fromDateTime(sunday), DayOfWeek.sunday);
      });

      test('should handle different years and months correctly', () {
        final monday2024 = DateTime(2024, 12, 23); // Monday
        final sunday2026 = DateTime(2026, 3); // Sunday

        expect(DayOfWeek.fromDateTime(monday2024), DayOfWeek.monday);
        expect(DayOfWeek.fromDateTime(sunday2026), DayOfWeek.sunday);
      });

      test('should ignore time components', () {
        final mondayMorning = DateTime(2025, 1, 27, 8, 30);
        final mondayEvening = DateTime(2025, 1, 27, 18, 45);

        expect(DayOfWeek.fromDateTime(mondayMorning), DayOfWeek.monday);
        expect(DayOfWeek.fromDateTime(mondayEvening), DayOfWeek.monday);
      });
    });

    group('fromString Factory Method', () {
      test('should create correct DayOfWeek from full name strings', () {
        expect(DayOfWeek.fromString('monday'), DayOfWeek.monday);
        expect(DayOfWeek.fromString('tuesday'), DayOfWeek.tuesday);
        expect(DayOfWeek.fromString('wednesday'), DayOfWeek.wednesday);
        expect(DayOfWeek.fromString('thursday'), DayOfWeek.thursday);
        expect(DayOfWeek.fromString('friday'), DayOfWeek.friday);
        expect(DayOfWeek.fromString('saturday'), DayOfWeek.saturday);
        expect(DayOfWeek.fromString('sunday'), DayOfWeek.sunday);
      });

      test('should create correct DayOfWeek from short name strings', () {
        expect(DayOfWeek.fromString('mon'), DayOfWeek.monday);
        expect(DayOfWeek.fromString('tue'), DayOfWeek.tuesday);
        expect(DayOfWeek.fromString('wed'), DayOfWeek.wednesday);
        expect(DayOfWeek.fromString('thu'), DayOfWeek.thursday);
        expect(DayOfWeek.fromString('fri'), DayOfWeek.friday);
        expect(DayOfWeek.fromString('sat'), DayOfWeek.saturday);
        expect(DayOfWeek.fromString('sun'), DayOfWeek.sunday);
      });

      test('should handle case-insensitive input', () {
        expect(DayOfWeek.fromString('MONDAY'), DayOfWeek.monday);
        expect(DayOfWeek.fromString('Monday'), DayOfWeek.monday);
        expect(DayOfWeek.fromString('mOnDaY'), DayOfWeek.monday);
        expect(DayOfWeek.fromString('TUE'), DayOfWeek.tuesday);
        expect(DayOfWeek.fromString('Wed'), DayOfWeek.wednesday);
        expect(DayOfWeek.fromString('THU'), DayOfWeek.thursday);
        expect(DayOfWeek.fromString('FRI'), DayOfWeek.friday);
        expect(DayOfWeek.fromString('SAT'), DayOfWeek.saturday);
        expect(DayOfWeek.fromString('SUN'), DayOfWeek.sunday);
      });

      test('should throw ArgumentError for invalid day names', () {
        expect(() => DayOfWeek.fromString('invalid'), throwsArgumentError);
        expect(() => DayOfWeek.fromString('weekday'), throwsArgumentError);
        expect(() => DayOfWeek.fromString('monday1'), throwsArgumentError);
        expect(() => DayOfWeek.fromString(''), throwsArgumentError);
        expect(() => DayOfWeek.fromString(' '), throwsArgumentError);
      });

      test('should throw ArgumentError with descriptive message', () {
        expect(
          () => DayOfWeek.fromString('invalid'),
          throwsA(
            predicate(
              (e) =>
                  e is ArgumentError &&
                  e.message == 'Invalid day name: invalid',
            ),
          ),
        );
        expect(
          () => DayOfWeek.fromString('xyz'),
          throwsA(
            predicate(
              (e) => e is ArgumentError && e.message == 'Invalid day name: xyz',
            ),
          ),
        );
      });
    });

    group('Weekday and Weekend Classification', () {
      test('should correctly identify weekdays', () {
        expect(DayOfWeek.monday.isWeekday, true);
        expect(DayOfWeek.tuesday.isWeekday, true);
        expect(DayOfWeek.wednesday.isWeekday, true);
        expect(DayOfWeek.thursday.isWeekday, true);
        expect(DayOfWeek.friday.isWeekday, true);
        expect(DayOfWeek.saturday.isWeekday, false);
        expect(DayOfWeek.sunday.isWeekday, false);
      });

      test('should correctly identify weekend days', () {
        expect(DayOfWeek.monday.isWeekend, false);
        expect(DayOfWeek.tuesday.isWeekend, false);
        expect(DayOfWeek.wednesday.isWeekend, false);
        expect(DayOfWeek.thursday.isWeekend, false);
        expect(DayOfWeek.friday.isWeekend, false);
        expect(DayOfWeek.saturday.isWeekend, true);
        expect(DayOfWeek.sunday.isWeekend, true);
      });

      test('should have mutually exclusive weekday and weekend properties', () {
        for (final day in DayOfWeek.values) {
          expect(
            day.isWeekday && day.isWeekend,
            false,
            reason: '$day cannot be both weekday and weekend',
          );
          expect(
            day.isWeekday || day.isWeekend,
            true,
            reason: '$day must be either weekday or weekend',
          );
        }
      });
    });

    group('Navigation - Next Day', () {
      test('should correctly return next day for each day of week', () {
        expect(DayOfWeek.monday.next, DayOfWeek.tuesday);
        expect(DayOfWeek.tuesday.next, DayOfWeek.wednesday);
        expect(DayOfWeek.wednesday.next, DayOfWeek.thursday);
        expect(DayOfWeek.thursday.next, DayOfWeek.friday);
        expect(DayOfWeek.friday.next, DayOfWeek.saturday);
        expect(DayOfWeek.saturday.next, DayOfWeek.sunday);
        expect(DayOfWeek.sunday.next, DayOfWeek.monday);
      });

      test('should handle week wrap-around correctly', () {
        // Sunday should wrap to Monday
        expect(DayOfWeek.sunday.next, DayOfWeek.monday);

        // Verify complete cycle
        var current = DayOfWeek.monday;
        final visited = <DayOfWeek>[];

        for (var i = 0; i < 7; i++) {
          visited.add(current);
          current = current.next;
        }

        expect(visited.length, 7);
        expect(visited.toSet().length, 7); // All unique
        expect(current, DayOfWeek.monday); // Back to start
      });
    });

    group('Navigation - Previous Day', () {
      test('should correctly return previous day for each day of week', () {
        expect(DayOfWeek.monday.previous, DayOfWeek.sunday);
        expect(DayOfWeek.tuesday.previous, DayOfWeek.monday);
        expect(DayOfWeek.wednesday.previous, DayOfWeek.tuesday);
        expect(DayOfWeek.thursday.previous, DayOfWeek.wednesday);
        expect(DayOfWeek.friday.previous, DayOfWeek.thursday);
        expect(DayOfWeek.saturday.previous, DayOfWeek.friday);
        expect(DayOfWeek.sunday.previous, DayOfWeek.saturday);
      });

      test('should handle week wrap-around correctly', () {
        // Monday should wrap to Sunday
        expect(DayOfWeek.monday.previous, DayOfWeek.sunday);

        // Verify complete cycle backwards
        var current = DayOfWeek.sunday;
        final visited = <DayOfWeek>[];

        for (var i = 0; i < 7; i++) {
          visited.add(current);
          current = current.previous;
        }

        expect(visited.length, 7);
        expect(visited.toSet().length, 7); // All unique
        expect(current, DayOfWeek.sunday); // Back to start
      });
    });

    group('Bidirectional Navigation Consistency', () {
      test('should have consistent next and previous operations', () {
        for (final day in DayOfWeek.values) {
          // Going next then previous should return to original
          expect(
            day.next.previous,
            day,
            reason: 'next.previous should equal original for $day',
          );

          // Going previous then next should return to original
          expect(
            day.previous.next,
            day,
            reason: 'previous.next should equal original for $day',
          );
        }
      });

      test('should form complete cycles', () {
        // Test forward cycle
        var current = DayOfWeek.monday;
        for (var i = 0; i < 7; i++) {
          current = current.next;
        }
        expect(current, DayOfWeek.monday);

        // Test backward cycle
        current = DayOfWeek.monday;
        for (var i = 0; i < 7; i++) {
          current = current.previous;
        }
        expect(current, DayOfWeek.monday);
      });
    });

    group('toString Method', () {
      test('should return full name as string representation', () {
        expect(DayOfWeek.monday.toString(), 'Monday');
        expect(DayOfWeek.tuesday.toString(), 'Tuesday');
        expect(DayOfWeek.wednesday.toString(), 'Wednesday');
        expect(DayOfWeek.thursday.toString(), 'Thursday');
        expect(DayOfWeek.friday.toString(), 'Friday');
        expect(DayOfWeek.saturday.toString(), 'Saturday');
        expect(DayOfWeek.sunday.toString(), 'Sunday');
      });
    });

    group('Integration with DateTime', () {
      test('should correctly round-trip with DateTime conversion', () {
        final testDates = [
          DateTime(2025, 1, 27), // Monday
          DateTime(2025, 1, 28), // Tuesday
          DateTime(2025, 1, 29), // Wednesday
          DateTime(2025, 1, 30), // Thursday
          DateTime(2025, 1, 31), // Friday
          DateTime(2025, 2), // Saturday
          DateTime(2025, 2, 2), // Sunday
        ];

        for (final date in testDates) {
          final dayOfWeek = DayOfWeek.fromDateTime(date);
          expect(
            dayOfWeek.weekday,
            date.weekday,
            reason: 'DayOfWeek.weekday should match DateTime.weekday for $date',
          );
        }
      });

      test('should work with various DateTime edge cases', () {
        // Leap year date
        final leapYearDate = DateTime(2024, 2, 29); // Thursday
        expect(DayOfWeek.fromDateTime(leapYearDate), DayOfWeek.thursday);

        // Year boundary
        final newYearsEve = DateTime(2024, 12, 31); // Tuesday
        final newYearsDay = DateTime(2025); // Wednesday
        expect(DayOfWeek.fromDateTime(newYearsEve), DayOfWeek.tuesday);
        expect(DayOfWeek.fromDateTime(newYearsDay), DayOfWeek.wednesday);

        // Different time zones (UTC vs local shouldn't matter for date)
        final utcDate = DateTime.utc(2025, 1, 27); // Monday
        expect(DayOfWeek.fromDateTime(utcDate), DayOfWeek.monday);
      });
    });

    group('Enum Completeness', () {
      test('should have exactly 7 values', () {
        expect(DayOfWeek.values.length, 7);
      });

      test('should have unique weekday values', () {
        final weekdays = DayOfWeek.values.map((d) => d.weekday).toSet();
        expect(weekdays.length, 7);
        expect(weekdays, {1, 2, 3, 4, 5, 6, 7});
      });

      test('should have unique full names', () {
        final fullNames = DayOfWeek.values.map((d) => d.fullName).toSet();
        expect(fullNames.length, 7);
      });

      test('should have unique short names', () {
        final shortNames = DayOfWeek.values.map((d) => d.shortName).toSet();
        expect(shortNames.length, 7);
      });
    });

    group('Business Logic Validation', () {
      test('should correctly categorize work week vs weekend', () {
        final weekdays = DayOfWeek.values.where((d) => d.isWeekday).toList();
        final weekends = DayOfWeek.values.where((d) => d.isWeekend).toList();

        expect(weekdays.length, 5);
        expect(weekends.length, 2);

        expect(
          weekdays,
          containsAll([
            DayOfWeek.monday,
            DayOfWeek.tuesday,
            DayOfWeek.wednesday,
            DayOfWeek.thursday,
            DayOfWeek.friday,
          ]),
        );

        expect(weekends, containsAll([DayOfWeek.saturday, DayOfWeek.sunday]));
      });

      test('should support scheduling logic scenarios', () {
        // Test common scheduling scenarios

        // Find all weekdays for regular school schedule
        final schoolDays = DayOfWeek.values.where((d) => d.isWeekday).toList();
        expect(schoolDays.length, 5);

        // Find weekend days for special events
        final weekendDays = DayOfWeek.values.where((d) => d.isWeekend).toList();
        expect(weekendDays.length, 2);

        // Navigate to next school day from Friday (should be Monday)
        final nextSchoolDay = DayOfWeek.friday.next.next.next;
        expect(nextSchoolDay, DayOfWeek.monday);
        expect(nextSchoolDay.isWeekday, true);
      });
    });
  });
}
