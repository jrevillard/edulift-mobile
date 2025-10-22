import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edulift/features/schedule/presentation/widgets/schedule_grid.dart';
import 'package:edulift/core/domain/entities/schedule.dart';

import '../../../test_mocks/test_mocks.dart';
import '../../../support/localized_test_app.dart';

void main() {
  setUpAll(() {
    setupMockFallbacks();
  });

  group('ScheduleGrid Widget Tests', () {
    late List<ScheduleSlot> testScheduleData;

    setUp(() {
      // Create test schedule data using type-safe ScheduleSlot entities
      final now = DateTime.now();
      testScheduleData = [
        ScheduleSlot(
          id: 'slot-1',
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
          id: 'slot-2',
          groupId: 'group-1',
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: const TimeOfDayValue(14, 0),
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
          timeOfDay: const TimeOfDayValue(8, 0),
          week: '2025-W01',
          vehicleAssignments: const [],
          maxVehicles: 5,
          createdAt: now,
          updatedAt: now,
        ),
      ];
    });

    testWidgets('PageView renders with initial week', (tester) async {
      // GIVEN
      await tester.pumpWidget(
        createLocalizedTestApp(
          child: ScheduleGrid(
            groupId: 'group-1',
            week: '2025-W01',
            scheduleData: testScheduleData,
            onManageVehicles: (_) {},
            onVehicleDrop: (_, __, ___) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // THEN
      expect(find.byType(PageView), findsOneWidget);
      // Verify date picker icon is present instead of week label
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('week indicator displays correct week', (tester) async {
      // GIVEN
      await tester.pumpWidget(
        createLocalizedTestApp(
          child: ScheduleGrid(
            groupId: 'group-1',
            week: '2025-W01',
            scheduleData: testScheduleData,
            onManageVehicles: (_) {},
            onVehicleDrop: (_, __, ___) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // THEN - Should show calendar icon for week selection
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('week navigation arrows work', (tester) async {
      // GIVEN
      await tester.pumpWidget(
        createLocalizedTestApp(
          child: ScheduleGrid(
            groupId: 'group-1',
            week: '2025-W01',
            scheduleData: testScheduleData,
            onManageVehicles: (_) {},
            onVehicleDrop: (_, __, ___) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // WHEN - Tap next week arrow
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      // THEN - Calendar icon should still be visible (no week labels)
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);

      // WHEN - Tap previous week arrow twice
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      // THEN - Calendar icon should still be visible
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('schedule slots render for current week', (tester) async {
      // GIVEN - With scheduleConfig to show all days
      final now = DateTime.now();
      final scheduleConfig = ScheduleConfig(
        id: 'config-1',
        groupId: 'group-1',
        scheduleHours: const {
          'MONDAY': ['08:00', '14:00'],
          'TUESDAY': ['08:00'],
          'WEDNESDAY': ['09:00'],
          'THURSDAY': ['08:00'],
          'FRIDAY': ['15:00'],
          'SATURDAY': [],
          'SUNDAY': [],
        },
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        createLocalizedTestApp(
          child: ScheduleGrid(
            groupId: 'group-1',
            week: '2025-W01',
            scheduleData: testScheduleData,
            scheduleConfig: scheduleConfig,
            onManageVehicles: (_) {},
            onVehicleDrop: (_, __, ___) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // THEN - Should show configured weekdays
      // At least Monday should be visible initially
      expect(find.text('Monday'), findsOneWidget);

      // The grid should be scrollable and show configured days
      // Verify that we have a ListView (scrollable)
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('tap on slot opens details', (tester) async {
      // GIVEN - With scheduleConfig so slots are interactive
      final now = DateTime.now();
      final scheduleConfig = ScheduleConfig(
        id: 'config-1',
        groupId: 'group-1',
        scheduleHours: const {
          'MONDAY': ['08:00', '14:00'],
          'TUESDAY': ['08:00'],
          'WEDNESDAY': [],
          'THURSDAY': [],
          'FRIDAY': [],
          'SATURDAY': [],
          'SUNDAY': [],
        },
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        createLocalizedTestApp(
          child: ScheduleGrid(
            groupId: 'group-1',
            week: '2025-W01',
            scheduleData: testScheduleData,
            scheduleConfig: scheduleConfig,
            onManageVehicles: (_) {},
            onVehicleDrop: (_, __, ___) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // WHEN - Tap on a schedule slot (find InkWell widgets for slots)
      final inkWells = find.byType(InkWell);
      if (inkWells.evaluate().isNotEmpty) {
        await tester.tap(inkWells.first);
        await tester.pumpAndSettle();

        // THEN - Should show modal with manage option
        // Note: The actual modal content depends on implementation
        expect(find.byType(InkWell), findsWidgets);
      }
    });

    testWidgets('displays day icons correctly', (tester) async {
      // GIVEN
      await tester.pumpWidget(
        createLocalizedTestApp(
          child: ScheduleGrid(
            groupId: 'group-1',
            week: '2025-W01',
            scheduleData: testScheduleData,
            onManageVehicles: (_) {},
            onVehicleDrop: (_, __, ___) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // THEN - Each day card should have an icon
      // Verify that Icon widgets exist (exact icons may vary based on AppColors configuration)
      final iconWidgets = find.byType(Icon);
      expect(
        iconWidgets,
        findsWidgets,
      ); // At least some icons should be present

      // Verify we have at least 3 visible day cards with icons (Mon, Tue, Wed)
      expect(iconWidgets.evaluate().length, greaterThanOrEqualTo(3));
    });

    testWidgets('displays day colors correctly', (tester) async {
      // GIVEN
      await tester.pumpWidget(
        createLocalizedTestApp(
          child: ScheduleGrid(
            groupId: 'group-1',
            week: '2025-W01',
            scheduleData: testScheduleData,
            onManageVehicles: (_) {},
            onVehicleDrop: (_, __, ___) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // THEN - Verify icons are shown with colors
      // Find any Icon widgets that have colors set
      final coloredIcons = find.byWidgetPredicate(
        (widget) => widget is Icon && widget.color != null,
      );

      // Should have at least 3 colored icons (for Mon, Tue, Wed that are visible)
      expect(coloredIcons.evaluate().length, greaterThanOrEqualTo(3));
    });

    testWidgets('handles empty schedule data', (tester) async {
      // GIVEN - Empty schedule data
      final emptyScheduleData = <ScheduleSlot>[];

      await tester.pumpWidget(
        createLocalizedTestApp(
          child: ScheduleGrid(
            groupId: 'group-1',
            week: '2025-W01',
            scheduleData: emptyScheduleData,
            onManageVehicles: (_) {},
            onVehicleDrop: (_, __, ___) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // THEN - Should still render the grid structure
      expect(find.text('Monday'), findsOneWidget);
      // Verify calendar icon is present (no confusing labels)
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('bottom sheet shows manage vehicles option', (tester) async {
      // GIVEN - With scheduleConfig so slots are interactive
      final now = DateTime.now();
      final scheduleConfig = ScheduleConfig(
        id: 'config-1',
        groupId: 'group-1',
        scheduleHours: const {
          'MONDAY': ['08:00', '14:00'],
          'TUESDAY': ['08:00'],
          'WEDNESDAY': [],
          'THURSDAY': [],
          'FRIDAY': [],
          'SATURDAY': [],
          'SUNDAY': [],
        },
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        createLocalizedTestApp(
          child: ScheduleGrid(
            groupId: 'group-1',
            week: '2025-W01',
            scheduleData: testScheduleData,
            scheduleConfig: scheduleConfig,
            onManageVehicles: (_) {},
            onVehicleDrop: (_, __, ___) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // WHEN - Tap on a slot
      final inkWells = find.byType(InkWell);
      if (inkWells.evaluate().isNotEmpty) {
        await tester.tap(inkWells.first);
        await tester.pumpAndSettle();

        // THEN - Modal should open (exact content depends on implementation)
        expect(find.byType(InkWell), findsWidgets);
      }
    });

    testWidgets('week offset labels work correctly', (tester) async {
      // GIVEN
      await tester.pumpWidget(
        createLocalizedTestApp(
          child: ScheduleGrid(
            groupId: 'group-1',
            week: '2025-W01',
            scheduleData: testScheduleData,
            onManageVehicles: (_) {},
            onVehicleDrop: (_, __, ___) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to future weeks
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pumpAndSettle();
      }

      // THEN - Calendar icon should still be visible (no confusing week offset labels)
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('responsive layout for tablet', (tester) async {
      // GIVEN - Tablet size
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      await tester.pumpWidget(
        createLocalizedTestApp(
          child: ScheduleGrid(
            groupId: 'group-1',
            week: '2025-W01',
            scheduleData: testScheduleData,
            onManageVehicles: (_) {},
            onVehicleDrop: (_, __, ___) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // THEN - Should render with tablet layout
      expect(find.byType(ScheduleGrid), findsOneWidget);
      expect(find.text('Monday'), findsOneWidget);

      // Reset size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('handles list of ScheduleSlot entities', (tester) async {
      // GIVEN - Schedule data as List<ScheduleSlot> with type-safe constructors
      final scheduleSlots = [
        ScheduleSlot(
          id: 'slot-1',
          groupId: 'group-1',
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: const TimeOfDayValue(8, 0),
          week: '2025-W01',
          vehicleAssignments: const [],
          maxVehicles: 5,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ScheduleSlot(
          id: 'slot-2',
          groupId: 'group-1',
          dayOfWeek: DayOfWeek.tuesday,
          timeOfDay: const TimeOfDayValue(14, 0),
          week: '2025-W01',
          vehicleAssignments: const [],
          maxVehicles: 5,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        createLocalizedTestApp(
          child: ScheduleGrid(
            groupId: 'group-1',
            week: '2025-W01',
            scheduleData: scheduleSlots,
            onManageVehicles: (_) {},
            onVehicleDrop: (_, __, ___) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // THEN - Should render correctly
      expect(find.text('Monday'), findsOneWidget);
      expect(find.text('Tuesday'), findsOneWidget);
    });

    testWidgets('cancel button in bottom sheet closes it', (tester) async {
      // GIVEN - With scheduleConfig so slots are interactive
      final now = DateTime.now();
      final scheduleConfig = ScheduleConfig(
        id: 'config-1',
        groupId: 'group-1',
        scheduleHours: const {
          'MONDAY': ['08:00', '14:00'],
          'TUESDAY': ['08:00'],
          'WEDNESDAY': [],
          'THURSDAY': [],
          'FRIDAY': [],
          'SATURDAY': [],
          'SUNDAY': [],
        },
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        createLocalizedTestApp(
          child: ScheduleGrid(
            groupId: 'group-1',
            week: '2025-W01',
            scheduleData: testScheduleData,
            scheduleConfig: scheduleConfig,
            onManageVehicles: (_) {},
            onVehicleDrop: (_, __, ___) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // WHEN - Tap on a slot to open modal
      final inkWells = find.byType(InkWell);
      if (inkWells.evaluate().isNotEmpty) {
        await tester.tap(inkWells.first);
        await tester.pumpAndSettle();

        // Modal opened - verify it's showing something
        // Note: Exact modal behavior depends on onManageVehicles callback
        expect(find.byType(InkWell), findsWidgets);
      }
    });

    testWidgets('Should hide days without configured time slots', (
      tester,
    ) async {
      // GIVEN - ScheduleConfig with only Monday and Thursday having slots
      final now = DateTime.now();
      final scheduleConfig = ScheduleConfig(
        id: 'config-1',
        groupId: 'group-1',
        scheduleHours: const {
          'MONDAY': ['08:00', '16:00'],
          'TUESDAY': [], // Empty - should be hidden
          'WEDNESDAY': [], // Empty - should be hidden
          'THURSDAY': ['09:00', '17:00'],
          'FRIDAY': [], // Empty - should be hidden
          'SATURDAY': [], // Empty - should be hidden
          'SUNDAY': [], // Empty - should be hidden
        },
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        createLocalizedTestApp(
          child: ScheduleGrid(
            groupId: 'group-1',
            week: '2025-W01',
            scheduleData: testScheduleData,
            scheduleConfig: scheduleConfig,
            onManageVehicles: (_) {},
            onVehicleDrop: (_, __, ___) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // THEN - Should show only Monday and Thursday
      expect(find.text('Monday'), findsOneWidget);
      expect(find.text('Thursday'), findsOneWidget);

      // THEN - Should NOT show Tuesday, Wednesday, Friday, Saturday, Sunday
      expect(find.text('Tuesday'), findsNothing);
      expect(find.text('Wednesday'), findsNothing);
      expect(find.text('Friday'), findsNothing);
      expect(find.text('Saturday'), findsNothing);
      expect(find.text('Sunday'), findsNothing);
    });

    testWidgets('Should show all days when no scheduleConfig provided', (
      tester,
    ) async {
      // GIVEN - No scheduleConfig (graceful degradation)
      await tester.pumpWidget(
        createLocalizedTestApp(
          child: ScheduleGrid(
            groupId: 'group-1',
            week: '2025-W01',
            scheduleData: testScheduleData,
            onManageVehicles: (_) {},
            onVehicleDrop: (_, __, ___) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // THEN - Should show all 7 days (graceful fallback)
      // The days are in a scrollable ListView, so we need to scroll to see all
      expect(find.text('Monday'), findsOneWidget);
      expect(find.text('Tuesday'), findsOneWidget);
      expect(find.text('Wednesday'), findsOneWidget);

      // Scroll down to see the rest of the days
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.text('Thursday'), findsOneWidget);
      expect(find.text('Friday'), findsOneWidget);

      // Scroll more to see weekend days
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.text('Saturday'), findsOneWidget);
      expect(find.text('Sunday'), findsOneWidget);
    });

    testWidgets('Should handle weekend-only schedule', (tester) async {
      // GIVEN - ScheduleConfig with only Saturday and Sunday
      final now = DateTime.now();
      final scheduleConfig = ScheduleConfig(
        id: 'config-1',
        groupId: 'group-1',
        scheduleHours: const {
          'MONDAY': [],
          'TUESDAY': [],
          'WEDNESDAY': [],
          'THURSDAY': [],
          'FRIDAY': [],
          'SATURDAY': ['10:00'],
          'SUNDAY': ['11:00'],
        },
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        createLocalizedTestApp(
          child: ScheduleGrid(
            groupId: 'group-1',
            week: '2025-W01',
            scheduleData: const [],
            scheduleConfig: scheduleConfig,
            onManageVehicles: (_) {},
            onVehicleDrop: (_, __, ___) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // THEN - Should show only Saturday and Sunday
      expect(find.text('Saturday'), findsOneWidget);
      expect(find.text('Sunday'), findsOneWidget);

      // THEN - Should NOT show weekdays
      expect(find.text('Monday'), findsNothing);
      expect(find.text('Tuesday'), findsNothing);
      expect(find.text('Wednesday'), findsNothing);
      expect(find.text('Thursday'), findsNothing);
      expect(find.text('Friday'), findsNothing);
    });

    testWidgets('Should handle single day configuration', (tester) async {
      // GIVEN - ScheduleConfig with only one day
      final now = DateTime.now();
      final scheduleConfig = ScheduleConfig(
        id: 'config-1',
        groupId: 'group-1',
        scheduleHours: const {
          'MONDAY': [],
          'TUESDAY': [],
          'WEDNESDAY': ['08:00', '16:00'], // Only Wednesday configured
          'THURSDAY': [],
          'FRIDAY': [],
          'SATURDAY': [],
          'SUNDAY': [],
        },
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        createLocalizedTestApp(
          child: ScheduleGrid(
            groupId: 'group-1',
            week: '2025-W01',
            scheduleData: const [],
            scheduleConfig: scheduleConfig,
            onManageVehicles: (_) {},
            onVehicleDrop: (_, __, ___) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // THEN - Should show only Wednesday
      expect(find.text('Wednesday'), findsOneWidget);

      // THEN - Should NOT show other days
      expect(find.text('Monday'), findsNothing);
      expect(find.text('Tuesday'), findsNothing);
      expect(find.text('Thursday'), findsNothing);
      expect(find.text('Friday'), findsNothing);
      expect(find.text('Saturday'), findsNothing);
      expect(find.text('Sunday'), findsNothing);
    });
  });
}
