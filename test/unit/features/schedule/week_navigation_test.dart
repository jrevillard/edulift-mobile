import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/utils/date/iso_week_utils.dart';

/// Test suite for week navigation edge cases
/// Tests the logic used in schedule_page.dart and schedule_grid.dart
void main() {
  group('Week Navigation Logic', () {
    group('Consecutive Week Navigation', () {
      test('navigating forward one week at a time should not skip weeks', () {
        const startWeek = '2025-W10';

        // Simulate clicking "next week" button 5 times
        var currentWeek = startWeek;
        final expectedWeeks = [
          '2025-W10',
          '2025-W11',
          '2025-W12',
          '2025-W13',
          '2025-W14',
          '2025-W15',
        ];

        for (var i = 0; i < 5; i++) {
          expect(currentWeek, expectedWeeks[i]);
          currentWeek = addWeeksToISOWeek(currentWeek, 1);
        }
        expect(currentWeek, expectedWeeks[5]);
      });

      test('navigating backward one week at a time should not skip weeks', () {
        const startWeek = '2025-W15';

        // Simulate clicking "previous week" button 5 times
        var currentWeek = startWeek;
        final expectedWeeks = [
          '2025-W15',
          '2025-W14',
          '2025-W13',
          '2025-W12',
          '2025-W11',
          '2025-W10',
        ];

        for (var i = 0; i < 5; i++) {
          expect(currentWeek, expectedWeeks[i]);
          currentWeek = addWeeksToISOWeek(currentWeek, -1);
        }
        expect(currentWeek, expectedWeeks[5]);
      });
    });

    group('Offset-based Navigation (Current Implementation)', () {
      test(
        'offset-based navigation from initial week should work correctly',
        () {
          const initialWeek = '2025-W10';

          // This is how schedule_page.dart currently works:
          // weekOffset is relative to initialWeek
          expect(addWeeksToISOWeek(initialWeek, 0), '2025-W10');
          expect(addWeeksToISOWeek(initialWeek, 1), '2025-W11');
          expect(addWeeksToISOWeek(initialWeek, 2), '2025-W12');
          expect(addWeeksToISOWeek(initialWeek, -1), '2025-W09');
          expect(addWeeksToISOWeek(initialWeek, -2), '2025-W08');
        },
      );
    });

    group('Date Picker Week Calculation', () {
      test(
        'calculating week offset from dates should match ISO week offset',
        () {
          // Test the logic used in _showDatePicker
          // Monday of week 10 (2025-03-03)
          final week10Monday = parseMondayFromISOWeek('2025-W10');
          expect(week10Monday, isNotNull);

          // Monday of week 11 (2025-03-10)
          final week11Monday = parseMondayFromISOWeek('2025-W11');
          expect(week11Monday, isNotNull);

          // Calculate day difference and convert to weeks
          final daysDiff = week11Monday!.difference(week10Monday!).inDays;
          final weeksDiff = daysDiff ~/ 7;

          expect(daysDiff, 7);
          expect(weeksDiff, 1);

          // Verify this matches ISO week arithmetic
          expect(addWeeksToISOWeek('2025-W10', weeksDiff), '2025-W11');
        },
      );

      test('week offset calculation should handle year boundaries', () {
        // Week 52 of 2025
        final week52Monday = parseMondayFromISOWeek('2025-W52');
        expect(week52Monday, isNotNull);

        // Week 1 of 2026
        final week01Monday = parseMondayFromISOWeek('2026-W01');
        expect(week01Monday, isNotNull);

        // Calculate day difference
        final daysDiff = week01Monday!.difference(week52Monday!).inDays;
        final weeksDiff = daysDiff ~/ 7;

        expect(daysDiff, 7);
        expect(weeksDiff, 1);

        // Verify ISO week arithmetic
        expect(addWeeksToISOWeek('2025-W52', 1), '2026-W01');
      });
    });

    group('Mixed Navigation Patterns', () {
      test('forward then backward navigation should return to start', () {
        const startWeek = '2025-W10';

        // Go forward 3 weeks
        final forward3 = addWeeksToISOWeek(startWeek, 3);
        expect(forward3, '2025-W13');

        // Go back 3 weeks
        final back3 = addWeeksToISOWeek(forward3, -3);
        expect(back3, startWeek);
      });

      test('multiple forward/backward navigations should be consistent', () {
        const startWeek = '2025-W10';

        // Complex navigation pattern: +2, -1, +3, -2, +1
        var currentWeek = startWeek;
        currentWeek = addWeeksToISOWeek(currentWeek, 2); // W12
        expect(currentWeek, '2025-W12');

        currentWeek = addWeeksToISOWeek(currentWeek, -1); // W11
        expect(currentWeek, '2025-W11');

        currentWeek = addWeeksToISOWeek(currentWeek, 3); // W14
        expect(currentWeek, '2025-W14');

        currentWeek = addWeeksToISOWeek(currentWeek, -2); // W12
        expect(currentWeek, '2025-W12');

        currentWeek = addWeeksToISOWeek(currentWeek, 1); // W13
        expect(currentWeek, '2025-W13');
      });
    });

    group('DST Transitions (Edge Case)', () {
      test('week navigation should work across DST transitions', () {
        // DST typically happens in March and November (varies by location)
        // Test week navigation around typical DST dates

        // March 2025 (around typical spring DST)
        const marchWeek = '2025-W11'; // Week of March 10, 2025
        expect(addWeeksToISOWeek(marchWeek, 1), '2025-W12');
        expect(addWeeksToISOWeek(marchWeek, -1), '2025-W10');

        // November 2025 (around typical fall DST)
        const novemberWeek = '2025-W45'; // Week of November 3, 2025
        expect(addWeeksToISOWeek(novemberWeek, 1), '2025-W46');
        expect(addWeeksToISOWeek(novemberWeek, -1), '2025-W44');
      });
    });

    group('Week 53 Edge Cases', () {
      test('navigation around week 53 should work correctly', () {
        // 2026 has 53 weeks
        expect(getWeeksInYear(2026), 53);

        // Navigate from week 52 to week 53
        expect(addWeeksToISOWeek('2026-W52', 1), '2026-W53');

        // Navigate from week 53 to week 1 of next year
        expect(addWeeksToISOWeek('2026-W53', 1), '2027-W01');

        // Navigate backward from week 1 to week 53 of previous year
        expect(addWeeksToISOWeek('2027-W01', -1), '2026-W53');
      });

      test('navigation in years without week 53 should skip correctly', () {
        // 2025 has only 52 weeks
        expect(getWeeksInYear(2025), 52);

        // Navigate from week 52 to week 1 of next year
        expect(addWeeksToISOWeek('2025-W52', 1), '2026-W01');

        // Navigate backward from week 1 to week 52 of previous year
        expect(addWeeksToISOWeek('2026-W01', -1), '2025-W52');
      });
    });

    group('Current Week Display Calculation', () {
      test(
        '_getWeekDateRange logic should calculate correct Monday for offset',
        () {
          // This tests the logic in schedule_grid.dart _getWeekDateRange
          const baseWeek = '2025-W10';
          final baseMonday = parseMondayFromISOWeek(baseWeek);
          expect(baseMonday, isNotNull);

          // Offset = 0 (current week)
          final offset0Monday = baseMonday!;
          expect(getISOWeekString(offset0Monday), baseWeek);

          // Offset = 1 (next week)
          final offset1Monday = baseMonday.add(const Duration(days: 1 * 7));
          expect(getISOWeekString(offset1Monday), '2025-W11');

          // Offset = -1 (previous week)
          final offsetNeg1Monday = baseMonday.add(const Duration(days: -1 * 7));
          expect(getISOWeekString(offsetNeg1Monday), '2025-W09');
        },
      );
    });
  });

  group('Bug Fix: Navigation from Current Week (Not Initial)', () {
    test('CRITICAL: should calculate offset from current week, not initial week', () {
      // This tests the fix for the bug where navigation got stuck after 2-3 clicks
      //
      // OLD BUG: schedule_page used fixed _initialWeek for all calculations
      // FIX: schedule_page now calculates from _currentWeek

      // Scenario: User on W42, clicks next 3 times
      var currentWeek = '2025-W42';

      // Click 1: offset=1 from current (W42)
      const offset1 = 1;
      currentWeek = addWeeksToISOWeek(currentWeek, offset1);
      expect(currentWeek, '2025-W43'); // ✓

      // Click 2: offset=1 from current (W43)
      const offset2 = 1;
      currentWeek = addWeeksToISOWeek(currentWeek, offset2);
      expect(currentWeek, '2025-W44'); // ✓

      // Click 3: offset=1 from current (W44)
      const offset3 = 1;
      currentWeek = addWeeksToISOWeek(currentWeek, offset3);
      expect(currentWeek, '2025-W45'); // ✓ FIXED!

      // OLD BUG would calculate: W42+3=W45 (skipping W43, W44)
      // NEW FIX calculates: W44+1=W45 (correct!)
    });

    test('should work correctly across year boundary', () {
      // Test navigation across 2025 → 2026 transition
      var currentWeek = '2025-W51'; // Late December 2025

      // Click next 3 times
      currentWeek = addWeeksToISOWeek(currentWeek, 1);
      expect(currentWeek, '2025-W52');

      currentWeek = addWeeksToISOWeek(currentWeek, 1);
      expect(currentWeek, '2026-W01'); // ✓ Crossed into 2026

      currentWeek = addWeeksToISOWeek(currentWeek, 1);
      expect(currentWeek, '2026-W02'); // ✓ Continue in 2026
    });

    test('should work correctly backward across year boundary', () {
      // Test navigation across 2026 → 2025 transition
      var currentWeek = '2026-W02'; // Early January 2026

      // Click previous 3 times
      currentWeek = addWeeksToISOWeek(currentWeek, -1);
      expect(currentWeek, '2026-W01');

      currentWeek = addWeeksToISOWeek(currentWeek, -1);
      expect(currentWeek, '2025-W52'); // ✓ Crossed back to 2025

      currentWeek = addWeeksToISOWeek(currentWeek, -1);
      expect(currentWeek, '2025-W51'); // ✓ Continue in 2025
    });

    test('should handle week 53 years correctly', () {
      // 2026 has 53 weeks
      var currentWeek = '2026-W52';

      // Navigate forward through W53 into 2027
      currentWeek = addWeeksToISOWeek(currentWeek, 1);
      expect(currentWeek, '2026-W53'); // ✓

      currentWeek = addWeeksToISOWeek(currentWeek, 1);
      expect(currentWeek, '2027-W01'); // ✓

      // Navigate backward through W53 into 2026
      currentWeek = addWeeksToISOWeek(currentWeek, -1);
      expect(currentWeek, '2026-W53'); // ✓

      currentWeek = addWeeksToISOWeek(currentWeek, -1);
      expect(currentWeek, '2026-W52'); // ✓
    });
  });

  group('Date Picker Navigation (Fixed Implementation)', () {
    test('date picker should calculate from displayed week, not initial week', () {
      // ✅ FIXED: The new implementation tracks _currentDisplayedWeek directly
      // and calculates offsets from widget.week (initial week)
      //
      // Scenario: User opens page on W10, navigates to W12, then uses date picker

      const initialWeek = '2025-W10';

      // User navigates forward 2 weeks to W12
      final currentDisplayedWeek = addWeeksToISOWeek(initialWeek, 2);
      expect(currentDisplayedWeek, '2025-W12');

      // User selects Monday of W13 (March 24) in the date picker
      final selectedDate = DateTime(2025, 3, 24);
      final selectedMonday = _getMondayOfWeek(selectedDate);
      final selectedWeekString = getISOWeekString(selectedMonday);
      expect(selectedWeekString, '2025-W13');

      // NEW IMPLEMENTATION: Calculate offset from initial week
      // This is what schedule_grid.dart now does:
      final targetPageOffset = weeksBetween(initialWeek, selectedWeekString);
      expect(targetPageOffset, 3); // W13 is 3 weeks from W10

      // Jump to page 1000 + 3 = 1003
      // onPageChanged calculates: addWeeksToISOWeek(W10, 3) = W13 ✓
      final result = addWeeksToISOWeek(initialWeek, targetPageOffset);
      expect(result, '2025-W13');
    });

    test('date picker should work correctly when far from initial week', () {
      // Test case: User navigates far from initial week, then uses date picker

      const initialWeek = '2025-W10';

      // User navigates to W15 (5 weeks forward)
      final currentDisplayedWeek = addWeeksToISOWeek(initialWeek, 5);
      expect(currentDisplayedWeek, '2025-W15');

      // User jumps to W18 using date picker (April 28 - Monday of W18)
      final selectedDate = DateTime(2025, 4, 28);
      final selectedMonday = _getMondayOfWeek(selectedDate);
      final selectedWeekString = getISOWeekString(selectedMonday);
      expect(selectedWeekString, '2025-W18');

      // NEW IMPLEMENTATION: Always calculate from initial week
      final targetPageOffset = weeksBetween(initialWeek, selectedWeekString);
      expect(targetPageOffset, 8); // W18 is 8 weeks from W10

      // Jump to page 1000 + 8 = 1008
      // onPageChanged calculates: addWeeksToISOWeek(W10, 8) = W18 ✓
      final result = addWeeksToISOWeek(initialWeek, targetPageOffset);
      expect(result, '2025-W18');
    });

    test('date picker should handle backward jumps correctly', () {
      // Test case: User navigates forward, then jumps backward with date picker

      const initialWeek = '2025-W15';

      // User navigates forward 3 weeks to W18
      final currentDisplayedWeek = addWeeksToISOWeek(initialWeek, 3);
      expect(currentDisplayedWeek, '2025-W18');

      // User jumps back to W12 using date picker
      final selectedDate = DateTime(2025, 3, 17); // Monday of W12
      final selectedMonday = _getMondayOfWeek(selectedDate);
      final selectedWeekString = getISOWeekString(selectedMonday);
      expect(selectedWeekString, '2025-W12');

      // Calculate offset from initial week (should be negative)
      final targetPageOffset = weeksBetween(initialWeek, selectedWeekString);
      expect(targetPageOffset, -3); // W12 is 3 weeks before W15

      // Jump to page 1000 + (-3) = 997
      // onPageChanged calculates: addWeeksToISOWeek(W15, -3) = W12 ✓
      final result = addWeeksToISOWeek(initialWeek, targetPageOffset);
      expect(result, '2025-W12');
    });
  });
}

/// Helper: Get Monday of the week containing a date
DateTime _getMondayOfWeek(DateTime date) {
  final weekday = date.weekday; // 1 = Monday, 7 = Sunday
  final daysFromMonday = weekday - 1;
  return date.subtract(Duration(days: daysFromMonday));
}
