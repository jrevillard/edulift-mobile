import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/domain/entities/schedule.dart';

/// Comprehensive DayOfWeek Entity Tests
/// Tests all enum values, factory methods, business logic, and edge cases
void main() {
  group('DayOfWeek Enum - Comprehensive Tests', () {
    group('Enum Values and Properties', () {
      test('should have correct weekday numbers', () {
        expect(DayOfWeek.monday.weekday, equals(1));
        expect(DayOfWeek.tuesday.weekday, equals(2));
        expect(DayOfWeek.wednesday.weekday, equals(3));
        expect(DayOfWeek.thursday.weekday, equals(4));
        expect(DayOfWeek.friday.weekday, equals(5));
        expect(DayOfWeek.saturday.weekday, equals(6));
        expect(DayOfWeek.sunday.weekday, equals(7));
      });

      test('should have correct full names', () {
        expect(DayOfWeek.monday.fullName, equals('Monday'));
        expect(DayOfWeek.tuesday.fullName, equals('Tuesday'));
        expect(DayOfWeek.wednesday.fullName, equals('Wednesday'));
        expect(DayOfWeek.thursday.fullName, equals('Thursday'));
        expect(DayOfWeek.friday.fullName, equals('Friday'));
        expect(DayOfWeek.saturday.fullName, equals('Saturday'));
        expect(DayOfWeek.sunday.fullName, equals('Sunday'));
      });

      test('should have correct short names', () {
        expect(DayOfWeek.monday.shortName, equals('Mon'));
        expect(DayOfWeek.tuesday.shortName, equals('Tue'));
        expect(DayOfWeek.wednesday.shortName, equals('Wed'));
        expect(DayOfWeek.thursday.shortName, equals('Thu'));
        expect(DayOfWeek.friday.shortName, equals('Fri'));
        expect(DayOfWeek.saturday.shortName, equals('Sat'));
        expect(DayOfWeek.sunday.shortName, equals('Sun'));
      });

      test('should have all 7 days defined', () {
        expect(DayOfWeek.values.length, equals(7));
      });

      test('should have unique weekday values', () {
        final weekdays = DayOfWeek.values.map((d) => d.weekday).toSet();
        expect(weekdays.length, equals(7));
        expect(weekdays, containsAll([1, 2, 3, 4, 5, 6, 7]));
      });
    });

    group('fromWeekday Factory Method', () {
      test('should create correct enum from valid weekday numbers', () {
        expect(DayOfWeek.fromWeekday(1), equals(DayOfWeek.monday));
        expect(DayOfWeek.fromWeekday(2), equals(DayOfWeek.tuesday));
        expect(DayOfWeek.fromWeekday(3), equals(DayOfWeek.wednesday));
        expect(DayOfWeek.fromWeekday(4), equals(DayOfWeek.thursday));
        expect(DayOfWeek.fromWeekday(5), equals(DayOfWeek.friday));
        expect(DayOfWeek.fromWeekday(6), equals(DayOfWeek.saturday));
        expect(DayOfWeek.fromWeekday(7), equals(DayOfWeek.sunday));
      });

      test('should throw ArgumentError for invalid weekday numbers', () {
        expect(() => DayOfWeek.fromWeekday(0), throwsArgumentError);
        expect(() => DayOfWeek.fromWeekday(8), throwsArgumentError);
        expect(() => DayOfWeek.fromWeekday(-1), throwsArgumentError);
        expect(() => DayOfWeek.fromWeekday(100), throwsArgumentError);
      });

      test('should throw ArgumentError with descriptive message', () {
        expect(
          () => DayOfWeek.fromWeekday(0),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Invalid weekday: 0'),
            ),
          ),
        );

        expect(
          () => DayOfWeek.fromWeekday(8),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Invalid weekday: 8'),
            ),
          ),
        );
      });
    });

    group('fromDateTime Factory Method', () {
      test('should create correct enum from DateTime objects', () {
        // Test with specific dates where we know the day of week
        final monday = DateTime(2024); // Monday
        final tuesday = DateTime(2024, 1, 2); // Tuesday
        final wednesday = DateTime(2024, 1, 3); // Wednesday
        final thursday = DateTime(2024, 1, 4); // Thursday
        final friday = DateTime(2024, 1, 5); // Friday
        final saturday = DateTime(2024, 1, 6); // Saturday
        final sunday = DateTime(2024, 1, 7); // Sunday

        expect(DayOfWeek.fromDateTime(monday), equals(DayOfWeek.monday));
        expect(DayOfWeek.fromDateTime(tuesday), equals(DayOfWeek.tuesday));
        expect(DayOfWeek.fromDateTime(wednesday), equals(DayOfWeek.wednesday));
        expect(DayOfWeek.fromDateTime(thursday), equals(DayOfWeek.thursday));
        expect(DayOfWeek.fromDateTime(friday), equals(DayOfWeek.friday));
        expect(DayOfWeek.fromDateTime(saturday), equals(DayOfWeek.saturday));
        expect(DayOfWeek.fromDateTime(sunday), equals(DayOfWeek.sunday));
      });

      test('should work with DateTime at different times of day', () {
        final monday = DateTime(2024);

        // Test different times on the same Monday
        final morningMonday = monday.copyWith(hour: 6, minute: 30);
        final afternoonMonday = monday.copyWith(hour: 14, minute: 45);
        final eveningMonday = monday.copyWith(hour: 22, minute: 15);
        final lateNightMonday = monday.copyWith(hour: 23, minute: 59);

        expect(DayOfWeek.fromDateTime(morningMonday), equals(DayOfWeek.monday));
        expect(
          DayOfWeek.fromDateTime(afternoonMonday),
          equals(DayOfWeek.monday),
        );
        expect(DayOfWeek.fromDateTime(eveningMonday), equals(DayOfWeek.monday));
        expect(
          DayOfWeek.fromDateTime(lateNightMonday),
          equals(DayOfWeek.monday),
        );
      });

      test('should work with different years and months', () {
        // Test leap year February 29, 2024 was a Thursday
        final leapYearThursday = DateTime(2024, 2, 29);
        expect(
          DayOfWeek.fromDateTime(leapYearThursday),
          equals(DayOfWeek.thursday),
        );

        // Test different years
        final pastDate = DateTime(2020, 12, 25); // Friday
        final futureDate = DateTime(2030, 6, 15); // Saturday

        expect(DayOfWeek.fromDateTime(pastDate), equals(DayOfWeek.friday));
        expect(DayOfWeek.fromDateTime(futureDate), equals(DayOfWeek.saturday));
      });

      test('should handle edge dates', () {
        // Test year boundaries
        final newYearsDay2024 = DateTime(2024); // Monday
        final newYearsEve2023 = DateTime(2023, 12, 31); // Sunday

        expect(
          DayOfWeek.fromDateTime(newYearsDay2024),
          equals(DayOfWeek.monday),
        );
        expect(
          DayOfWeek.fromDateTime(newYearsEve2023),
          equals(DayOfWeek.sunday),
        );
      });
    });

    group('fromString Factory Method', () {
      test('should create enum from full day names (case insensitive)', () {
        // Test lowercase
        expect(DayOfWeek.fromString('monday'), equals(DayOfWeek.monday));
        expect(DayOfWeek.fromString('tuesday'), equals(DayOfWeek.tuesday));
        expect(DayOfWeek.fromString('wednesday'), equals(DayOfWeek.wednesday));
        expect(DayOfWeek.fromString('thursday'), equals(DayOfWeek.thursday));
        expect(DayOfWeek.fromString('friday'), equals(DayOfWeek.friday));
        expect(DayOfWeek.fromString('saturday'), equals(DayOfWeek.saturday));
        expect(DayOfWeek.fromString('sunday'), equals(DayOfWeek.sunday));

        // Test uppercase
        expect(DayOfWeek.fromString('MONDAY'), equals(DayOfWeek.monday));
        expect(DayOfWeek.fromString('TUESDAY'), equals(DayOfWeek.tuesday));
        expect(DayOfWeek.fromString('WEDNESDAY'), equals(DayOfWeek.wednesday));
        expect(DayOfWeek.fromString('THURSDAY'), equals(DayOfWeek.thursday));
        expect(DayOfWeek.fromString('FRIDAY'), equals(DayOfWeek.friday));
        expect(DayOfWeek.fromString('SATURDAY'), equals(DayOfWeek.saturday));
        expect(DayOfWeek.fromString('SUNDAY'), equals(DayOfWeek.sunday));

        // Test mixed case
        expect(DayOfWeek.fromString('Monday'), equals(DayOfWeek.monday));
        expect(DayOfWeek.fromString('TuEsDay'), equals(DayOfWeek.tuesday));
        expect(DayOfWeek.fromString('WednesdaY'), equals(DayOfWeek.wednesday));
      });

      test('should create enum from short day names (case insensitive)', () {
        // Test lowercase
        expect(DayOfWeek.fromString('mon'), equals(DayOfWeek.monday));
        expect(DayOfWeek.fromString('tue'), equals(DayOfWeek.tuesday));
        expect(DayOfWeek.fromString('wed'), equals(DayOfWeek.wednesday));
        expect(DayOfWeek.fromString('thu'), equals(DayOfWeek.thursday));
        expect(DayOfWeek.fromString('fri'), equals(DayOfWeek.friday));
        expect(DayOfWeek.fromString('sat'), equals(DayOfWeek.saturday));
        expect(DayOfWeek.fromString('sun'), equals(DayOfWeek.sunday));

        // Test uppercase
        expect(DayOfWeek.fromString('MON'), equals(DayOfWeek.monday));
        expect(DayOfWeek.fromString('TUE'), equals(DayOfWeek.tuesday));
        expect(DayOfWeek.fromString('WED'), equals(DayOfWeek.wednesday));
        expect(DayOfWeek.fromString('THU'), equals(DayOfWeek.thursday));
        expect(DayOfWeek.fromString('FRI'), equals(DayOfWeek.friday));
        expect(DayOfWeek.fromString('SAT'), equals(DayOfWeek.saturday));
        expect(DayOfWeek.fromString('SUN'), equals(DayOfWeek.sunday));

        // Test mixed case
        expect(DayOfWeek.fromString('Mon'), equals(DayOfWeek.monday));
        expect(DayOfWeek.fromString('TuE'), equals(DayOfWeek.tuesday));
        expect(DayOfWeek.fromString('WeD'), equals(DayOfWeek.wednesday));
      });

      test('should throw ArgumentError for invalid strings', () {
        final invalidStrings = [
          '',
          'invalid',
          'day',
          'weekday',
          'tues', // Close but wrong
          'thurs', // Close but wrong
          'satur', // Close but wrong
          'mond', // Close but wrong
          '1',
          'monday1',
          ' monday', // Leading space
          'monday ', // Trailing space
          'mon day', // Space in middle
        ];

        for (final invalidString in invalidStrings) {
          expect(
            () => DayOfWeek.fromString(invalidString),
            throwsArgumentError,
            reason: 'Should throw for invalid string: "$invalidString"',
          );
        }
      });

      test('should throw ArgumentError with descriptive message', () {
        expect(
          () => DayOfWeek.fromString('invalid'),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Invalid day name: invalid'),
            ),
          ),
        );
      });
    });

    group('Weekday and Weekend Logic', () {
      test('should correctly identify weekdays', () {
        expect(DayOfWeek.monday.isWeekday, isTrue);
        expect(DayOfWeek.tuesday.isWeekday, isTrue);
        expect(DayOfWeek.wednesday.isWeekday, isTrue);
        expect(DayOfWeek.thursday.isWeekday, isTrue);
        expect(DayOfWeek.friday.isWeekday, isTrue);
        expect(DayOfWeek.saturday.isWeekday, isFalse);
        expect(DayOfWeek.sunday.isWeekday, isFalse);
      });

      test('should correctly identify weekends', () {
        expect(DayOfWeek.monday.isWeekend, isFalse);
        expect(DayOfWeek.tuesday.isWeekend, isFalse);
        expect(DayOfWeek.wednesday.isWeekend, isFalse);
        expect(DayOfWeek.thursday.isWeekend, isFalse);
        expect(DayOfWeek.friday.isWeekend, isFalse);
        expect(DayOfWeek.saturday.isWeekend, isTrue);
        expect(DayOfWeek.sunday.isWeekend, isTrue);
      });

      test('should have mutually exclusive weekday and weekend properties', () {
        for (final day in DayOfWeek.values) {
          expect(
            day.isWeekday && day.isWeekend,
            isFalse,
            reason: '${day.fullName} cannot be both weekday and weekend',
          );

          expect(
            day.isWeekday || day.isWeekend,
            isTrue,
            reason: '${day.fullName} must be either weekday or weekend',
          );
        }
      });

      test('should have exactly 5 weekdays and 2 weekend days', () {
        final weekdays = DayOfWeek.values.where((d) => d.isWeekday).length;
        final weekendDays = DayOfWeek.values.where((d) => d.isWeekend).length;

        expect(weekdays, equals(5));
        expect(weekendDays, equals(2));
        expect(weekdays + weekendDays, equals(7));
      });
    });

    group('Next Day Logic', () {
      test('should correctly calculate next day for each day', () {
        expect(DayOfWeek.monday.next, equals(DayOfWeek.tuesday));
        expect(DayOfWeek.tuesday.next, equals(DayOfWeek.wednesday));
        expect(DayOfWeek.wednesday.next, equals(DayOfWeek.thursday));
        expect(DayOfWeek.thursday.next, equals(DayOfWeek.friday));
        expect(DayOfWeek.friday.next, equals(DayOfWeek.saturday));
        expect(DayOfWeek.saturday.next, equals(DayOfWeek.sunday));
        expect(DayOfWeek.sunday.next, equals(DayOfWeek.monday)); // Week wraps
      });

      test('should create valid weekly cycle with next', () {
        var current = DayOfWeek.monday;
        final visitedDays = <DayOfWeek>{};

        // Should visit all 7 days and return to start
        for (var i = 0; i < 7; i++) {
          expect(
            visitedDays.contains(current),
            isFalse,
            reason: 'Should not revisit day',
          );
          visitedDays.add(current);
          current = current.next;
        }

        expect(visitedDays.length, equals(7));
        expect(current, equals(DayOfWeek.monday)); // Back to start
      });
    });

    group('Previous Day Logic', () {
      test('should correctly calculate previous day for each day', () {
        expect(DayOfWeek.monday.previous, equals(DayOfWeek.sunday));
        expect(DayOfWeek.tuesday.previous, equals(DayOfWeek.monday));
        expect(DayOfWeek.wednesday.previous, equals(DayOfWeek.tuesday));
        expect(DayOfWeek.thursday.previous, equals(DayOfWeek.wednesday));
        expect(DayOfWeek.friday.previous, equals(DayOfWeek.thursday));
        expect(DayOfWeek.saturday.previous, equals(DayOfWeek.friday));
        expect(DayOfWeek.sunday.previous, equals(DayOfWeek.saturday));
      });

      test('should create valid weekly cycle with previous', () {
        var current = DayOfWeek.sunday;
        final visitedDays = <DayOfWeek>{};

        // Should visit all 7 days in reverse and return to start
        for (var i = 0; i < 7; i++) {
          expect(
            visitedDays.contains(current),
            isFalse,
            reason: 'Should not revisit day',
          );
          visitedDays.add(current);
          current = current.previous;
        }

        expect(visitedDays.length, equals(7));
        expect(current, equals(DayOfWeek.sunday)); // Back to start
      });

      test('should be inverse of next operation', () {
        for (final day in DayOfWeek.values) {
          expect(
            day.next.previous,
            equals(day),
            reason:
                '${day.fullName}.next.previous should equal ${day.fullName}',
          );

          expect(
            day.previous.next,
            equals(day),
            reason:
                '${day.fullName}.previous.next should equal ${day.fullName}',
          );
        }
      });
    });

    group('toString Method', () {
      test('should return full name as string representation', () {
        expect(DayOfWeek.monday.toString(), equals('Monday'));
        expect(DayOfWeek.tuesday.toString(), equals('Tuesday'));
        expect(DayOfWeek.wednesday.toString(), equals('Wednesday'));
        expect(DayOfWeek.thursday.toString(), equals('Thursday'));
        expect(DayOfWeek.friday.toString(), equals('Friday'));
        expect(DayOfWeek.saturday.toString(), equals('Saturday'));
        expect(DayOfWeek.sunday.toString(), equals('Sunday'));
      });

      test('should be consistent with fullName property', () {
        for (final day in DayOfWeek.values) {
          expect(day.toString(), equals(day.fullName));
        }
      });
    });

    group('Business Logic Integration Tests', () {
      test('should support typical scheduling scenarios', () {
        // Scenario: Find next weekday after Friday
        const friday = DayOfWeek.friday;
        var nextDay = friday.next; // Saturday
        while (nextDay.isWeekend) {
          nextDay = nextDay.next;
        }
        expect(nextDay, equals(DayOfWeek.monday));

        // Scenario: Find previous weekday before Monday
        const monday = DayOfWeek.monday;
        var prevDay = monday.previous; // Sunday
        while (prevDay.isWeekend) {
          prevDay = prevDay.previous;
        }
        expect(prevDay, equals(DayOfWeek.friday));
      });

      test('should support weekend planning', () {
        final weekendDays = DayOfWeek.values.where((d) => d.isWeekend).toList();
        expect(weekendDays, hasLength(2));
        expect(weekendDays, contains(DayOfWeek.saturday));
        expect(weekendDays, contains(DayOfWeek.sunday));
      });

      test('should support school week planning (Monday-Friday)', () {
        final schoolDays = DayOfWeek.values.where((d) => d.isWeekday).toList();
        expect(schoolDays, hasLength(5));
        expect(schoolDays.map((d) => d.weekday), equals([1, 2, 3, 4, 5]));
      });

      test('should support creating date ranges', () {
        // Create a week starting from Monday
        final week = <DayOfWeek>[];
        var current = DayOfWeek.monday;

        for (var i = 0; i < 7; i++) {
          week.add(current);
          current = current.next;
        }

        expect(week.length, equals(7));
        expect(week.first, equals(DayOfWeek.monday));
        expect(week.last, equals(DayOfWeek.sunday));
        expect(week, equals(DayOfWeek.values));
      });
    });

    group('Edge Cases and Robustness', () {
      test('should handle all enum values consistently', () {
        for (final day in DayOfWeek.values) {
          // All days should have valid properties
          expect(day.weekday, isIn([1, 2, 3, 4, 5, 6, 7]));
          expect(day.fullName, isNotEmpty);
          expect(day.shortName, isNotEmpty);
          expect(day.shortName.length, lessThanOrEqualTo(3));

          // Should round-trip through factory methods
          expect(DayOfWeek.fromWeekday(day.weekday), equals(day));
          expect(DayOfWeek.fromString(day.fullName), equals(day));
          expect(DayOfWeek.fromString(day.shortName), equals(day));

          // Navigation should be consistent
          expect(day.next.previous, equals(day));
          expect(day.previous.next, equals(day));
        }
      });

      test('should handle DateTime edge cases', () {
        // Test with UTC and local time zones
        final utcDate = DateTime.utc(2024); // Monday UTC
        final localDate = DateTime(2024); // Monday local

        expect(DayOfWeek.fromDateTime(utcDate), equals(DayOfWeek.monday));
        expect(DayOfWeek.fromDateTime(localDate), equals(DayOfWeek.monday));

        // Test with milliseconds/microseconds
        final preciseDate = DateTime(2024, 1, 1, 12, 30, 45, 123, 456);
        expect(DayOfWeek.fromDateTime(preciseDate), equals(DayOfWeek.monday));
      });

      test('should maintain enum ordering', () {
        final orderedWeekdays = DayOfWeek.values.map((d) => d.weekday).toList();
        expect(orderedWeekdays, equals([1, 2, 3, 4, 5, 6, 7]));

        // Enum values should be in order
        for (var i = 0; i < DayOfWeek.values.length; i++) {
          expect(DayOfWeek.values[i].weekday, equals(i + 1));
        }
      });
    });
  });
}
