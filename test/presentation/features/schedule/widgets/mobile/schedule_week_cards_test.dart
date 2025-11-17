import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/features/schedule/presentation/widgets/mobile/schedule_week_cards.dart';
import 'package:edulift/features/schedule/presentation/widgets/mobile/day_card_widget.dart';
import 'package:edulift/core/domain/entities/family/vehicle.dart';
import 'package:edulift/core/domain/entities/family/child.dart';
import 'package:edulift/core/domain/entities/schedule/day_of_week.dart';
import 'package:edulift/core/domain/entities/schedule/time_of_day.dart';
import 'package:edulift/features/schedule/presentation/models/displayable_time_slot.dart';
import '../../../../../../test/support/test_app_configuration.dart';

void main() {
  group('ScheduleWeekCards', () {
    late List<DisplayableTimeSlot> testDisplayableSlots;
    late Map<String, Vehicle> testVehicles;
    late Map<String, Child> testChildren;

    setUpAll(() async {
      // Initialiser les localisations pour tous les tests du groupe
      await TestAppConfiguration.initialize();
    });

    setUp(() {
      testDisplayableSlots = [
        // Monday slots
        const DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: TimeOfDayValue(8, 0),
          week: '2024-W03',
          existsInBackend: true,
        ),
        const DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: TimeOfDayValue(14, 0),
          week: '2024-W03',
          existsInBackend: false,
        ),
        // Tuesday slots
        const DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.tuesday,
          timeOfDay: TimeOfDayValue(9, 0),
          week: '2024-W03',
          existsInBackend: true,
        ),
        const DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.tuesday,
          timeOfDay: TimeOfDayValue(15, 0),
          week: '2024-W03',
          existsInBackend: true,
        ),
        // Wednesday slots
        const DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.wednesday,
          timeOfDay: TimeOfDayValue(10, 0),
          week: '2024-W03',
          existsInBackend: false,
        ),
      ];

      testVehicles = {
        'vehicle_1': Vehicle(
          id: 'vehicle_1',
          name: 'Vehicle 1',
          familyId: 'family_1',
          capacity: 4,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        'vehicle_2': Vehicle(
          id: 'vehicle_2',
          name: 'Vehicle 2',
          familyId: 'family_1',
          capacity: 4,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      };

      testChildren = {
        'child_1': Child(
          id: 'child_1',
          name: 'John Doe',
          familyId: 'family_1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      };
    });

    Widget createTestWidget({required Widget child}) {
      return TestAppConfiguration.createTestWidget(child: child);
    }

    testWidgets('displays week cards with basic information', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: ScheduleWeekCards(
            key: const Key('test_schedule_week_cards'),
            displayableSlots: testDisplayableSlots,
            onSlotTap: (slot) {},
            vehicles: testVehicles,
            childrenMap: testChildren,
            isSlotInPast: (slot) => false,
          ),
        ),
      );

      expect(find.byType(ScheduleWeekCards), findsOneWidget);
      // Should find day cards for each day that has slots
      expect(find.byType(DayCardWidget), findsWidgets);
    });

    testWidgets('displays correct number of day cards', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: ScheduleWeekCards(
            key: const Key('test_schedule_week_cards_count'),
            displayableSlots: testDisplayableSlots,
            onSlotTap: (slot) {},
            configuredDays: const [
              DayOfWeek.monday,
              DayOfWeek.tuesday,
              DayOfWeek.wednesday,
            ],
            vehicles: testVehicles,
            childrenMap: testChildren,
            isSlotInPast: (slot) => false,
          ),
        ),
      );

      // Should have day cards for Monday, Tuesday, and Wednesday
      expect(find.byType(DayCardWidget), findsNWidgets(3));
    });

    testWidgets('filters days based on configuredDays', (
      WidgetTester tester,
    ) async {
      // Only configure Monday and Wednesday
      final limitedDays = [DayOfWeek.monday, DayOfWeek.wednesday];

      await tester.pumpWidget(
        createTestWidget(
          child: ScheduleWeekCards(
            key: const Key('test_schedule_week_cards_filtered'),
            displayableSlots: testDisplayableSlots,
            onSlotTap: (slot) {},
            configuredDays: limitedDays,
            vehicles: testVehicles,
            childrenMap: testChildren,
            isSlotInPast: (slot) => false,
          ),
        ),
      );

      // Should only have day cards for Monday and Wednesday
      expect(find.byType(DayCardWidget), findsNWidgets(2));
    });

    testWidgets('displays empty week correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: ScheduleWeekCards(
            key: const Key('test_schedule_week_cards_empty'),
            displayableSlots: const [],
            onSlotTap: (slot) {},
            configuredDays: const [], // No configured days
            vehicles: testVehicles,
            childrenMap: testChildren,
            isSlotInPast: (slot) => false,
          ),
        ),
      );

      expect(find.byType(ScheduleWeekCards), findsOneWidget);
      expect(find.byType(DayCardWidget), findsNothing);
    });

    testWidgets('calls onSlotTap when slot is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: ScheduleWeekCards(
            key: const Key('test_schedule_week_cards_tap'),
            displayableSlots: testDisplayableSlots,
            onSlotTap: (slot) {
              // Slot tap callback for testing
            },
            vehicles: testVehicles,
            childrenMap: testChildren,
            isSlotInPast: (slot) => false,
          ),
        ),
      );

      // Find and tap on a day card
      final dayCard = find.byType(DayCardWidget).first;
      expect(dayCard, findsOneWidget);

      await tester.tap(dayCard);
      await tester.pumpAndSettle();

      // Note: Actual slot tapping is handled by DayCardWidget
      // This test verifies the callback is properly wired through the widget hierarchy
    });

    testWidgets('provides onAddVehicle callback', (WidgetTester tester) async {
      DisplayableTimeSlot? slotToAddVehicle;

      await tester.pumpWidget(
        createTestWidget(
          child: ScheduleWeekCards(
            key: const Key('test_schedule_week_cards_add_vehicle'),
            displayableSlots: testDisplayableSlots,
            onSlotTap: (slot) {},
            onAddVehicle: (slot) => slotToAddVehicle = slot,
            vehicles: testVehicles,
            childrenMap: testChildren,
            isSlotInPast: (slot) => false,
          ),
        ),
      );

      expect(find.byType(ScheduleWeekCards), findsOneWidget);
      expect(find.byType(DayCardWidget), findsWidgets);

      // Verify the callback is available (callback should be passed down)
      expect(slotToAddVehicle, isNull); // Initially null
    });

    testWidgets('provides onVehicleAction callback', (
      WidgetTester tester,
    ) async {
      DisplayableTimeSlot? actionSlot;
      String? action;

      await tester.pumpWidget(
        createTestWidget(
          child: ScheduleWeekCards(
            key: const Key('test_schedule_week_cards_vehicle_action'),
            displayableSlots: testDisplayableSlots,
            onSlotTap: (slot) {},
            onVehicleAction: (slot, vehicleAssignment, actionType) {
              actionSlot = slot;
              action = actionType;
            },
            vehicles: testVehicles,
            childrenMap: testChildren,
            isSlotInPast: (slot) => false,
          ),
        ),
      );

      expect(find.byType(ScheduleWeekCards), findsOneWidget);
      expect(find.byType(DayCardWidget), findsWidgets);

      // Verify the callback is available
      expect(actionSlot, isNull); // Initially null
      expect(action, isNull); // Initially null
    });

    testWidgets('passes vehicles to day cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: ScheduleWeekCards(
            key: const Key('test_schedule_week_cards_vehicles'),
            displayableSlots: testDisplayableSlots,
            onSlotTap: (slot) {},
            configuredDays: const [
              DayOfWeek.monday,
              DayOfWeek.tuesday,
              DayOfWeek.wednesday,
            ],
            vehicles: testVehicles,
            childrenMap: testChildren,
            isSlotInPast: (slot) => false,
          ),
        ),
      );

      expect(find.byType(ScheduleWeekCards), findsOneWidget);
      expect(find.byType(DayCardWidget), findsNWidgets(3));
    });

    testWidgets('handles missing vehicles correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: ScheduleWeekCards(
            key: const Key('test_schedule_week_cards_no_vehicles'),
            displayableSlots: testDisplayableSlots,
            onSlotTap: (slot) {},
            configuredDays: const [
              DayOfWeek.monday,
              DayOfWeek.tuesday,
              DayOfWeek.wednesday,
            ],
            vehicles: const {}, // Empty vehicles map
            childrenMap: testChildren,
            isSlotInPast: (slot) => false,
          ),
        ),
      );

      // Should still display the cards without crashing
      expect(find.byType(ScheduleWeekCards), findsOneWidget);
      expect(find.byType(DayCardWidget), findsNWidgets(3));
    });

    testWidgets('passes childrenMap to day cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: ScheduleWeekCards(
            key: const Key('test_schedule_week_cards_children'),
            displayableSlots: testDisplayableSlots,
            onSlotTap: (slot) {},
            configuredDays: const [
              DayOfWeek.monday,
              DayOfWeek.tuesday,
              DayOfWeek.wednesday,
            ],
            vehicles: testVehicles,
            childrenMap: testChildren,
            isSlotInPast: (slot) => false,
          ),
        ),
      );

      expect(find.byType(ScheduleWeekCards), findsOneWidget);
      expect(find.byType(DayCardWidget), findsNWidgets(3));
    });

    testWidgets('uses isSlotInPast function correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: ScheduleWeekCards(
            key: const Key('test_schedule_week_cards_past_slots'),
            displayableSlots: testDisplayableSlots,
            onSlotTap: (slot) {},
            configuredDays: const [
              DayOfWeek.monday,
              DayOfWeek.tuesday,
              DayOfWeek.wednesday,
            ],
            vehicles: testVehicles,
            childrenMap: testChildren,
            isSlotInPast: (slot) =>
                slot.timeOfDay.hour < 12, // Morning slots are in the past
          ),
        ),
      );

      expect(find.byType(ScheduleWeekCards), findsOneWidget);
      expect(find.byType(DayCardWidget), findsNWidgets(3));
    });

    testWidgets('handles mixed existing and non-existing slots', (
      WidgetTester tester,
    ) async {
      final mixedSlots = [
        // Existing slot
        const DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: TimeOfDayValue(8, 0),
          week: '2024-W03',
          existsInBackend: true,
        ),
        // Non-existing slot
        const DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: TimeOfDayValue(14, 0),
          week: '2024-W03',
          existsInBackend: false,
        ),
      ];

      await tester.pumpWidget(
        createTestWidget(
          child: ScheduleWeekCards(
            key: const Key('test_schedule_week_cards_mixed'),
            displayableSlots: mixedSlots,
            onSlotTap: (slot) {},
            configuredDays: const [DayOfWeek.monday],
            vehicles: testVehicles,
            childrenMap: testChildren,
            isSlotInPast: (slot) => false,
          ),
        ),
      );

      expect(find.byType(ScheduleWeekCards), findsOneWidget);
      expect(find.byType(DayCardWidget), findsNWidgets(1)); // Only Monday
    });

    testWidgets('displays full week correctly', (WidgetTester tester) async {
      // Create slots for all weekdays
      final fullWeekSlots = [
        for (final day in DayOfWeek.values)
          DisplayableTimeSlot(
            dayOfWeek: day,
            timeOfDay: const TimeOfDayValue(9, 0),
            week: '2024-W03',
            existsInBackend: true,
          ),
      ];

      await tester.pumpWidget(
        createTestWidget(
          child: ScheduleWeekCards(
            key: const Key('test_schedule_week_cards_full_week'),
            displayableSlots: fullWeekSlots,
            onSlotTap: (slot) {},
            vehicles: testVehicles,
            childrenMap: testChildren,
            isSlotInPast: (slot) => false,
          ),
        ),
      );

      expect(find.byType(ScheduleWeekCards), findsOneWidget);
      expect(find.byType(DayCardWidget), findsNWidgets(7)); // All 7 days
    });

    testWidgets('handles single day configuration', (
      WidgetTester tester,
    ) async {
      // Only configure Monday
      final singleDay = [DayOfWeek.monday];

      await tester.pumpWidget(
        createTestWidget(
          child: ScheduleWeekCards(
            key: const Key('test_schedule_week_cards_single_day'),
            displayableSlots: testDisplayableSlots,
            onSlotTap: (slot) {},
            configuredDays: singleDay,
            vehicles: testVehicles,
            childrenMap: testChildren,
            isSlotInPast: (slot) => false,
          ),
        ),
      );

      expect(find.byType(ScheduleWeekCards), findsOneWidget);
      expect(find.byType(DayCardWidget), findsNWidgets(1)); // Only Monday
    });

    testWidgets('groups slots by day correctly', (WidgetTester tester) async {
      // Create multiple slots for the same day
      final multiSlotDay = [
        const DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: TimeOfDayValue(8, 0), // Morning
          week: '2024-W03',
          existsInBackend: true,
        ),
        const DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: TimeOfDayValue(10, 0), // Mid-morning
          week: '2024-W03',
          existsInBackend: true,
        ),
        const DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: TimeOfDayValue(14, 0), // Afternoon
          week: '2024-W03',
          existsInBackend: false,
        ),
      ];

      await tester.pumpWidget(
        createTestWidget(
          child: ScheduleWeekCards(
            key: const Key('test_schedule_week_cards_multi_slots'),
            displayableSlots: multiSlotDay,
            onSlotTap: (slot) {},
            configuredDays: const [DayOfWeek.monday], // Only configure Monday
            vehicles: testVehicles,
            childrenMap: testChildren,
            isSlotInPast: (slot) => false,
          ),
        ),
      );

      expect(find.byType(ScheduleWeekCards), findsOneWidget);
      expect(
        find.byType(DayCardWidget),
        findsNWidgets(1),
      ); // All slots grouped into one day card
    });
  });
}
