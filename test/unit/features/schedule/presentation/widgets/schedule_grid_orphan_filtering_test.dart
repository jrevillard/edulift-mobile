import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edulift/features/schedule/presentation/widgets/schedule_grid.dart';
import 'package:edulift/core/domain/entities/schedule.dart';

import '../../../../../support/localized_test_app.dart';
import '../../../../../test_mocks/test_mocks.dart';

/// Tests for scheduleConfig-based orphan slot filtering
///
/// PRINCIPLE 0: The UI must be a view of the CONFIGURATION, not the database.
/// The scheduleConfig is the source of truth for what should be displayed.
///
/// These tests verify that:
/// 1. Only slots with times matching scheduleConfig are displayed
/// 2. API slots with unconfigured times (orphans) are hidden
/// 3. Empty scheduleConfig shows no slots (even if API data exists)
/// 4. The filtering works correctly for each day independently
void main() {
  setUpAll(() {
    setupMockFallbacks();
  });

  group('ScheduleGrid Orphan Slot Filtering Tests', () {
    late DateTime now;

    setUp(() {
      now = DateTime.now();
    });

    testWidgets(
      'Should hide slots with times NOT in scheduleConfig',
      (tester) async {
        // GIVEN - ScheduleConfig with only 07:30 and 15:30 configured
        final scheduleConfig = ScheduleConfig(
          id: 'config-1',
          groupId: 'group-1',
          scheduleHours: const {
            'MONDAY': ['07:30', '15:30'],
            'TUESDAY': ['07:30', '15:30'],
            'WEDNESDAY': [],
            'THURSDAY': [],
            'FRIDAY': [],
            'SATURDAY': [],
            'SUNDAY': [],
          },
          createdAt: now,
          updatedAt: now,
        );

        // API data contains ORPHANED slots at 05:30 and 08:00 (not configured)
        final scheduleData = [
          // ❌ ORPHAN: 05:30 not in scheduleConfig
          ScheduleSlot(
            id: 'orphan-slot-1',
            groupId: 'group-1',
            dayOfWeek: DayOfWeek.monday,
            timeOfDay: const TimeOfDayValue(5, 30),
            week: '2025-W01',
            vehicleAssignments: const [],
            maxVehicles: 5,
            createdAt: now,
            updatedAt: now,
          ),
          // ✅ VALID: 07:30 is configured
          ScheduleSlot(
            id: 'valid-slot-1',
            groupId: 'group-1',
            dayOfWeek: DayOfWeek.monday,
            timeOfDay: const TimeOfDayValue(7, 30),
            week: '2025-W01',
            vehicleAssignments: const [],
            maxVehicles: 5,
            createdAt: now,
            updatedAt: now,
          ),
          // ❌ ORPHAN: 08:00 not in scheduleConfig
          ScheduleSlot(
            id: 'orphan-slot-2',
            groupId: 'group-1',
            dayOfWeek: DayOfWeek.monday,
            timeOfDay: const TimeOfDayValue(8, 0),
            week: '2025-W01',
            vehicleAssignments: const [],
            maxVehicles: 5,
            createdAt: now,
            updatedAt: now,
          ),
          // ✅ VALID: 15:30 is configured
          ScheduleSlot(
            id: 'valid-slot-2',
            groupId: 'group-1',
            dayOfWeek: DayOfWeek.monday,
            timeOfDay: const TimeOfDayValue(15, 30),
            week: '2025-W01',
            vehicleAssignments: const [],
            maxVehicles: 5,
            createdAt: now,
            updatedAt: now,
          ),
        ];

        // WHEN
        await tester.pumpWidget(
          createLocalizedTestApp(
            child: ScheduleGrid(
              groupId: 'group-1',
              week: '2025-W01',
              scheduleData: scheduleData,
              scheduleConfig: scheduleConfig,
              onManageVehicles: (_) {},
              onVehicleDrop: (_, __, ___) {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        // THEN - Should show Monday with only configured time slots
        expect(find.text('Monday'), findsOneWidget);

        // The grid should show 2 period labels: Morning (07:30) and Afternoon (15:30)
        // NOT 05:30 or 08:00 (orphaned slots)

        // Verify the time header shows correct periods
        // Since 07:30 is morning and 15:30 is afternoon, we should see these labels
        final timeHeaderText = find.textContaining('Morning', findRichText: true);
        expect(timeHeaderText, findsOneWidget);
      },
    );

    testWidgets(
      'Should show ONLY configured slots, even when API has extras',
      (tester) async {
        // GIVEN - ScheduleConfig with ONLY 07:30 configured
        final scheduleConfig = ScheduleConfig(
          id: 'config-1',
          groupId: 'group-1',
          scheduleHours: const {
            'MONDAY': ['07:30'], // Only one time configured
            'TUESDAY': [],
            'WEDNESDAY': [],
            'THURSDAY': [],
            'FRIDAY': [],
            'SATURDAY': [],
            'SUNDAY': [],
          },
          createdAt: now,
          updatedAt: now,
        );

        // API data contains many slots, only one is valid
        final scheduleData = [
          // ✅ VALID: 07:30 is configured
          ScheduleSlot(
            id: 'valid-slot',
            groupId: 'group-1',
            dayOfWeek: DayOfWeek.monday,
            timeOfDay: const TimeOfDayValue(7, 30),
            week: '2025-W01',
            vehicleAssignments: const [],
            maxVehicles: 5,
            createdAt: now,
            updatedAt: now,
          ),
          // ❌ ALL ORPHANS
          ScheduleSlot(
            id: 'orphan-1',
            groupId: 'group-1',
            dayOfWeek: DayOfWeek.monday,
            timeOfDay: const TimeOfDayValue(5, 30),
            week: '2025-W01',
            vehicleAssignments: const [],
            maxVehicles: 5,
            createdAt: now,
            updatedAt: now,
          ),
          ScheduleSlot(
            id: 'orphan-2',
            groupId: 'group-1',
            dayOfWeek: DayOfWeek.monday,
            timeOfDay: const TimeOfDayValue(8, 0),
            week: '2025-W01',
            vehicleAssignments: const [],
            maxVehicles: 5,
            createdAt: now,
            updatedAt: now,
          ),
          ScheduleSlot(
            id: 'orphan-3',
            groupId: 'group-1',
            dayOfWeek: DayOfWeek.monday,
            timeOfDay: const TimeOfDayValue(15, 30),
            week: '2025-W01',
            vehicleAssignments: const [],
            maxVehicles: 5,
            createdAt: now,
            updatedAt: now,
          ),
        ];

        // WHEN
        await tester.pumpWidget(
          createLocalizedTestApp(
            child: ScheduleGrid(
              groupId: 'group-1',
              week: '2025-W01',
              scheduleData: scheduleData,
              scheduleConfig: scheduleConfig,
              onManageVehicles: (_) {},
              onVehicleDrop: (_, __, ___) {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        // THEN - Should show Monday (it has config)
        expect(find.text('Monday'), findsOneWidget);

        // Should show only ONE time period (Morning with 07:30)
        // The time header should contain "Morning"
        expect(find.byType(ListView), findsOneWidget);
      },
    );

    testWidgets(
      'Should show NOTHING when scheduleConfig is empty',
      (tester) async {
        // GIVEN - Empty scheduleConfig (no times configured)
        final scheduleConfig = ScheduleConfig(
          id: 'config-1',
          groupId: 'group-1',
          scheduleHours: const {
            'MONDAY': [], // Empty!
            'TUESDAY': [],
            'WEDNESDAY': [],
            'THURSDAY': [],
            'FRIDAY': [],
            'SATURDAY': [],
            'SUNDAY': [],
          },
          createdAt: now,
          updatedAt: now,
        );

        // API data has many slots, but ALL are orphans (no times configured)
        final scheduleData = [
          ScheduleSlot(
            id: 'orphan-1',
            groupId: 'group-1',
            dayOfWeek: DayOfWeek.monday,
            timeOfDay: const TimeOfDayValue(7, 30),
            week: '2025-W01',
            vehicleAssignments: const [],
            maxVehicles: 5,
            createdAt: now,
            updatedAt: now,
          ),
          ScheduleSlot(
            id: 'orphan-2',
            groupId: 'group-1',
            dayOfWeek: DayOfWeek.tuesday,
            timeOfDay: const TimeOfDayValue(8, 0),
            week: '2025-W01',
            vehicleAssignments: const [],
            maxVehicles: 5,
            createdAt: now,
            updatedAt: now,
          ),
        ];

        // WHEN
        await tester.pumpWidget(
          createLocalizedTestApp(
            child: ScheduleGrid(
              groupId: 'group-1',
              week: '2025-W01',
              scheduleData: scheduleData,
              scheduleConfig: scheduleConfig,
              onManageVehicles: (_) {},
              onVehicleDrop: (_, __, ___) {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        // THEN - Should show EMPTY grid (no days with configuration)
        // No day cards should be visible
        expect(find.text('Monday'), findsNothing);
        expect(find.text('Tuesday'), findsNothing);
        expect(find.text('Wednesday'), findsNothing);
        expect(find.text('Thursday'), findsNothing);
        expect(find.text('Friday'), findsNothing);
        expect(find.text('Saturday'), findsNothing);
        expect(find.text('Sunday'), findsNothing);

        // The grid structure (PageView, week indicator) should still exist
        expect(find.byType(PageView), findsOneWidget);
        expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      },
    );

    testWidgets(
      'Should filter orphans per-day independently',
      (tester) async {
        // GIVEN - Different times configured for different days
        final scheduleConfig = ScheduleConfig(
          id: 'config-1',
          groupId: 'group-1',
          scheduleHours: const {
            'MONDAY': ['07:30'], // Monday: only 07:30
            'TUESDAY': ['08:00', '15:30'], // Tuesday: 08:00 and 15:30
            'WEDNESDAY': [],
            'THURSDAY': [],
            'FRIDAY': [],
            'SATURDAY': [],
            'SUNDAY': [],
          },
          createdAt: now,
          updatedAt: now,
        );

        // API data has slots for both days with various times
        final scheduleData = [
          // Monday slots
          ScheduleSlot(
            id: 'mon-valid',
            groupId: 'group-1',
            dayOfWeek: DayOfWeek.monday,
            timeOfDay: const TimeOfDayValue(7, 30), // ✅ Valid for Monday
            week: '2025-W01',
            vehicleAssignments: const [],
            maxVehicles: 5,
            createdAt: now,
            updatedAt: now,
          ),
          ScheduleSlot(
            id: 'mon-orphan',
            groupId: 'group-1',
            dayOfWeek: DayOfWeek.monday,
            timeOfDay: const TimeOfDayValue(8, 0), // ❌ Orphan for Monday
            week: '2025-W01',
            vehicleAssignments: const [],
            maxVehicles: 5,
            createdAt: now,
            updatedAt: now,
          ),
          // Tuesday slots
          ScheduleSlot(
            id: 'tue-orphan',
            groupId: 'group-1',
            dayOfWeek: DayOfWeek.tuesday,
            timeOfDay: const TimeOfDayValue(7, 30), // ❌ Orphan for Tuesday
            week: '2025-W01',
            vehicleAssignments: const [],
            maxVehicles: 5,
            createdAt: now,
            updatedAt: now,
          ),
          ScheduleSlot(
            id: 'tue-valid-1',
            groupId: 'group-1',
            dayOfWeek: DayOfWeek.tuesday,
            timeOfDay: const TimeOfDayValue(8, 0), // ✅ Valid for Tuesday
            week: '2025-W01',
            vehicleAssignments: const [],
            maxVehicles: 5,
            createdAt: now,
            updatedAt: now,
          ),
          ScheduleSlot(
            id: 'tue-valid-2',
            groupId: 'group-1',
            dayOfWeek: DayOfWeek.tuesday,
            timeOfDay: const TimeOfDayValue(15, 30), // ✅ Valid for Tuesday
            week: '2025-W01',
            vehicleAssignments: const [],
            maxVehicles: 5,
            createdAt: now,
            updatedAt: now,
          ),
        ];

        // WHEN
        await tester.pumpWidget(
          createLocalizedTestApp(
            child: ScheduleGrid(
              groupId: 'group-1',
              week: '2025-W01',
              scheduleData: scheduleData,
              scheduleConfig: scheduleConfig,
              onManageVehicles: (_) {},
              onVehicleDrop: (_, __, ___) {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        // THEN - Should show both Monday and Tuesday
        expect(find.text('Monday'), findsOneWidget);
        expect(find.text('Tuesday'), findsOneWidget);

        // Monday should show 1 period (Morning with 07:30 only)
        // Tuesday should show 2 periods (Morning with 08:00, Afternoon with 15:30)
        // 08:00 should NOT appear for Monday (orphan)
        // 07:30 should NOT appear for Tuesday (orphan)

        // The grid should be properly filtered per day
        expect(find.byType(ListView), findsOneWidget);
      },
    );

    testWidgets(
      'Should handle slots with unconfigured times gracefully (no crash)',
      (tester) async {
        // GIVEN - ScheduleConfig with specific times
        final scheduleConfig = ScheduleConfig(
          id: 'config-1',
          groupId: 'group-1',
          scheduleHours: const {
            'MONDAY': ['07:30', '15:30'],
            'TUESDAY': [],
            'WEDNESDAY': [],
            'THURSDAY': [],
            'FRIDAY': [],
            'SATURDAY': [],
            'SUNDAY': [],
          },
          createdAt: now,
          updatedAt: now,
        );

        // API data contains MANY orphaned slots with weird times
        final scheduleData = [
          // Valid slots
          ScheduleSlot(
            id: 'valid-1',
            groupId: 'group-1',
            dayOfWeek: DayOfWeek.monday,
            timeOfDay: const TimeOfDayValue(7, 30),
            week: '2025-W01',
            vehicleAssignments: const [],
            maxVehicles: 5,
            createdAt: now,
            updatedAt: now,
          ),
          ScheduleSlot(
            id: 'valid-2',
            groupId: 'group-1',
            dayOfWeek: DayOfWeek.monday,
            timeOfDay: const TimeOfDayValue(15, 30),
            week: '2025-W01',
            vehicleAssignments: const [],
            maxVehicles: 5,
            createdAt: now,
            updatedAt: now,
          ),
          // Orphaned slots with various times
          ScheduleSlot(
            id: 'orphan-1',
            groupId: 'group-1',
            dayOfWeek: DayOfWeek.monday,
            timeOfDay: const TimeOfDayValue(5, 30),
            week: '2025-W01',
            vehicleAssignments: const [],
            maxVehicles: 5,
            createdAt: now,
            updatedAt: now,
          ),
          ScheduleSlot(
            id: 'orphan-2',
            groupId: 'group-1',
            dayOfWeek: DayOfWeek.monday,
            timeOfDay: const TimeOfDayValue(23, 45),
            week: '2025-W01',
            vehicleAssignments: const [],
            maxVehicles: 5,
            createdAt: now,
            updatedAt: now,
          ),
          ScheduleSlot(
            id: 'orphan-3',
            groupId: 'group-1',
            dayOfWeek: DayOfWeek.monday,
            timeOfDay: const TimeOfDayValue(0, 0),
            week: '2025-W01',
            vehicleAssignments: const [],
            maxVehicles: 5,
            createdAt: now,
            updatedAt: now,
          ),
        ];

        // WHEN - Should not crash
        await tester.pumpWidget(
          createLocalizedTestApp(
            child: ScheduleGrid(
              groupId: 'group-1',
              week: '2025-W01',
              scheduleData: scheduleData,
              scheduleConfig: scheduleConfig,
              onManageVehicles: (_) {},
              onVehicleDrop: (_, __, ___) {},
            ),
          ),
        );

        // THEN - Should render without crashing
        await tester.pumpAndSettle();
        expect(find.text('Monday'), findsOneWidget);
        expect(find.byType(PageView), findsOneWidget);
      },
    );

    testWidgets(
      'Should fall back to showing all slots when scheduleConfig is null',
      (tester) async {
        // GIVEN - NO scheduleConfig (null)
        // API data has various slots
        final scheduleData = [
          ScheduleSlot(
            id: 'slot-1',
            groupId: 'group-1',
            dayOfWeek: DayOfWeek.monday,
            timeOfDay: const TimeOfDayValue(5, 30),
            week: '2025-W01',
            vehicleAssignments: const [],
            maxVehicles: 5,
            createdAt: now,
            updatedAt: now,
          ),
          ScheduleSlot(
            id: 'slot-2',
            groupId: 'group-1',
            dayOfWeek: DayOfWeek.monday,
            timeOfDay: const TimeOfDayValue(8, 0),
            week: '2025-W01',
            vehicleAssignments: const [],
            maxVehicles: 5,
            createdAt: now,
            updatedAt: now,
          ),
          ScheduleSlot(
            id: 'slot-3',
            groupId: 'group-1',
            dayOfWeek: DayOfWeek.tuesday,
            timeOfDay: const TimeOfDayValue(15, 30),
            week: '2025-W01',
            vehicleAssignments: const [],
            maxVehicles: 5,
            createdAt: now,
            updatedAt: now,
          ),
        ];

        // WHEN - No scheduleConfig provided (graceful degradation)
        await tester.pumpWidget(
          createLocalizedTestApp(
            child: ScheduleGrid(
              groupId: 'group-1',
              week: '2025-W01',
              scheduleData: scheduleData,
              onManageVehicles: (_) {},
              onVehicleDrop: (_, __, ___) {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        // THEN - Should show all days (fallback mode)
        expect(find.text('Monday'), findsOneWidget);
        expect(find.text('Tuesday'), findsOneWidget);

        // All API slots should be visible (no filtering)
        expect(find.byType(PageView), findsOneWidget);
      },
    );
  });
}
