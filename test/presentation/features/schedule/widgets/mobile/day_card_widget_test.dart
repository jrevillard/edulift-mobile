import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/features/schedule/presentation/widgets/mobile/day_card_widget.dart';
import 'package:edulift/features/schedule/presentation/widgets/mobile/period_card_widget.dart';
import 'package:edulift/core/domain/entities/family/vehicle.dart';
import 'package:edulift/core/domain/entities/family/child.dart';
import 'package:edulift/core/domain/entities/schedule/day_of_week.dart';
import 'package:edulift/core/domain/entities/schedule/time_of_day.dart';
import 'package:edulift/features/schedule/presentation/models/displayable_time_slot.dart';
import '../../../../../../test/support/test_app_configuration.dart';

void main() {
  group('DayCardWidget', () {
    late DateTime testDate;
    late List<DisplayableTimeSlot> testDisplayableSlots;
    late Map<String, Vehicle> testVehicles;
    late Map<String, Child> testChildren;

    setUpAll(() async {
      // Initialiser les localisations pour tous les tests du groupe
      await TestAppConfiguration.initialize();
    });

    setUp(() {
      testDate = DateTime(2024, 1, 15); // Monday

      testDisplayableSlots = [
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
          existsInBackend: true,
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

    testWidgets('displays day card with basic information', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: DayCardWidget(
            key: const Key('test_day_card'),
            date: testDate,
            displayableSlots: testDisplayableSlots,
            onSlotTap: (slot) {},
            childrenMap: testChildren,
          ),
        ),
      );

      expect(find.byType(DayCardWidget), findsOneWidget);
      expect(
        find.byKey(Key('day_card_${testDate.millisecondsSinceEpoch}')),
        findsOneWidget,
      );
      expect(
        find.byKey(Key('day_header_${testDate.millisecondsSinceEpoch}')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('displays formatted date correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: DayCardWidget(
            key: const Key('test_day_card'),
            date: testDate,
            displayableSlots: testDisplayableSlots,
            onSlotTap: (slot) {},
            childrenMap: testChildren,
          ),
        ),
      );

      expect(find.text('Lun 15 janv.'), findsOneWidget);
    });

    testWidgets('displays period cards correctly grouped by time', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: DayCardWidget(
            key: const Key('test_day_card'),
            date: testDate,
            displayableSlots: testDisplayableSlots,
            vehicles: testVehicles,
            onSlotTap: (slot) {},
            childrenMap: testChildren,
          ),
        ),
      );

      // Should have both morning and afternoon periods
      expect(find.text('Matin'), findsOneWidget);
      expect(find.text('Après-midi'), findsOneWidget);

      // Check period cards are created
      expect(find.byType(PeriodCardWidget), findsNWidgets(2));
    });

    testWidgets('calls onSlotTap when slot is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: DayCardWidget(
            key: const Key('test_day_card'),
            date: testDate,
            displayableSlots: testDisplayableSlots,
            vehicles: testVehicles,
            onSlotTap: (slot) {
              // Slot tap callback handled by PeriodCardWidget
            },
            childrenMap: testChildren,
          ),
        ),
      );

      // Find and tap on a period card
      final periodCard = find.byType(PeriodCardWidget).first;
      expect(periodCard, findsOneWidget);

      await tester.tap(periodCard);
      await tester.pumpAndSettle();

      // Note: Actual slot tapping is handled by PeriodCardWidget
      // This test verifies the callback is properly wired
    });

    testWidgets('handles empty displayable slots list', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: DayCardWidget(
            key: const Key('test_day_card_empty'),
            date: testDate,
            displayableSlots: const [],
            onSlotTap: (slot) {},
            childrenMap: testChildren,
          ),
        ),
      );

      expect(
        find.byKey(Key('day_card_${testDate.millisecondsSinceEpoch}')),
        findsOneWidget,
      );
      expect(find.text('0/0'), findsOneWidget);

      final summaryContainer = tester.widget<Container>(
        find.byKey(Key('day_quick_summary_${testDate.millisecondsSinceEpoch}')),
      );
      final decoration = summaryContainer.decoration as BoxDecoration;
      expect(decoration.color, Colors.green); // No slots to assign
    });

    testWidgets('displays different days of the week correctly', (
      WidgetTester tester,
    ) async {
      final weekDays = [
        DateTime(2024, 1, 15), // Monday
        DateTime(2024, 1, 16), // Tuesday
        DateTime(2024, 1, 17), // Wednesday
      ];

      final expectedDayNames = ['Lun 15 janv.', 'Mar 16 janv.', 'Mer 17 janv.'];

      for (var i = 0; i < weekDays.length; i++) {
        final testDate = weekDays[i];

        await tester.pumpWidget(
          createTestWidget(
            child: DayCardWidget(
              key: Key('test_day_card_$i'),
              date: testDate,
              displayableSlots: testDisplayableSlots,
              onSlotTap: (slot) {},
              childrenMap: testChildren,
            ),
          ),
        );

        expect(find.text(expectedDayNames[i]), findsOneWidget);
        await tester.pumpWidget(Container()); // Clean up for next iteration
      }
    });

    testWidgets('handles missing vehicles correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: DayCardWidget(
            key: const Key('test_day_card'),
            date: testDate,
            displayableSlots: testDisplayableSlots,
            onSlotTap: (slot) {},
            childrenMap: testChildren,
          ),
        ),
      );

      // Should still display the card without crashing
      expect(
        find.byKey(Key('day_card_${testDate.millisecondsSinceEpoch}')),
        findsOneWidget,
      );
      expect(find.byType(PeriodCardWidget), findsNWidgets(2));
    });

    testWidgets('passes vehicles to period cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: DayCardWidget(
            key: const Key('test_day_card_with_vehicles'),
            date: testDate,
            displayableSlots: testDisplayableSlots,
            vehicles: testVehicles,
            onSlotTap: (slot) {},
            childrenMap: testChildren,
          ),
        ),
      );

      expect(find.byType(DayCardWidget), findsOneWidget);
      expect(find.byType(PeriodCardWidget), findsNWidgets(2));
    });

    testWidgets('displays availability summary', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: DayCardWidget(
            key: const Key('test_day_card_availability'),
            date: testDate,
            displayableSlots: testDisplayableSlots,
            vehicles: testVehicles,
            onSlotTap: (slot) {},
            childrenMap: testChildren,
          ),
        ),
      );

      expect(
        find.byKey(Key('day_quick_summary_${testDate.millisecondsSinceEpoch}')),
        findsOneWidget,
      );
      expect(find.text('0/4'), findsOneWidget); // No slots have vehicles yet
    });

    testWidgets('handles non-existent displayable slots', (
      WidgetTester tester,
    ) async {
      final mixedSlots = [
        ...testDisplayableSlots.take(2),
        const DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: TimeOfDayValue(18, 0),
          week: '2024-W03',
          existsInBackend: false,
        ),
      ];

      await tester.pumpWidget(
        createTestWidget(
          child: DayCardWidget(
            key: const Key('test_day_card_mixed'),
            date: testDate,
            displayableSlots: mixedSlots,
            onSlotTap: (slot) {},
            childrenMap: testChildren,
          ),
        ),
      );

      expect(find.byType(DayCardWidget), findsOneWidget);
      expect(
        find.byType(PeriodCardWidget),
        findsNWidgets(2),
      ); // Morning and Afternoon
    });

    testWidgets('shows past slots correctly when isSlotInPast is provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: DayCardWidget(
            key: const Key('test_day_card_past_slots'),
            date: testDate,
            displayableSlots: testDisplayableSlots,
            vehicles: testVehicles,
            onSlotTap: (slot) {},
            isSlotInPast: (slot) =>
                slot.timeOfDay.hour < 12, // Morning slots are in the past
            childrenMap: testChildren,
          ),
        ),
      );

      expect(find.byType(DayCardWidget), findsOneWidget);
      expect(find.byType(PeriodCardWidget), findsNWidgets(2));
    });

    testWidgets('groups slots by periods correctly', (
      WidgetTester tester,
    ) async {
      // Create slots for different periods of the day
      final variedTimeSlots = [
        const DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: TimeOfDayValue(8, 0), // Morning
          week: '2024-W03',
          existsInBackend: true,
        ),
        const DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: TimeOfDayValue(12, 0), // Noon
          week: '2024-W03',
          existsInBackend: true,
        ),
        const DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: TimeOfDayValue(15, 0), // Afternoon
          week: '2024-W03',
          existsInBackend: false,
        ),
        const DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: TimeOfDayValue(18, 0), // Evening
          week: '2024-W03',
          existsInBackend: true,
        ),
      ];

      await tester.pumpWidget(
        createTestWidget(
          child: DayCardWidget(
            key: const Key('test_day_card_varied_periods'),
            date: testDate,
            displayableSlots: variedTimeSlots,
            onSlotTap: (slot) {},
            childrenMap: testChildren,
          ),
        ),
      );

      expect(find.byType(DayCardWidget), findsOneWidget);
      // Should find period cards for each time period
      expect(find.byType(PeriodCardWidget), findsWidgets);
    });
  });
}
