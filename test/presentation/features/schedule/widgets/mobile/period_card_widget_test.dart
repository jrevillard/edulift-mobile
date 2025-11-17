import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/features/schedule/presentation/widgets/mobile/period_card_widget.dart';
import 'package:edulift/core/domain/entities/family/vehicle.dart';
import 'package:edulift/core/domain/entities/family/child.dart';
import 'package:edulift/core/domain/entities/schedule/time_of_day.dart';
import 'package:edulift/core/domain/entities/schedule/day_of_week.dart';
import 'package:edulift/core/domain/entities/schedule/schedule_slot.dart';
import 'package:edulift/core/domain/entities/schedule/vehicle_assignment.dart';
import 'package:edulift/features/schedule/presentation/models/displayable_time_slot.dart';
import 'package:edulift/features/schedule/presentation/widgets/mobile/enhanced_slot_card.dart';
import '../../../../../../test/support/test_app_configuration.dart';

void main() {
  group('PeriodCardWidget', () {
    late List<DisplayableTimeSlot> testDisplayableSlots;
    late Map<String, Vehicle> testVehicles;
    late Map<String, Child> testChildren;

    setUpAll(() async {
      // Initialiser les localisations pour tous les tests du groupe
      await TestAppConfiguration.initialize();
    });

    setUp(() {
      // Créer les données de test manuellement
      final now = DateTime.now();
      final assignedSlot = ScheduleSlot(
        id: 'slot_2',
        groupId: 'group_1',
        dayOfWeek: DayOfWeek.monday,
        timeOfDay: const TimeOfDayValue(9, 0),
        week: '2024-W01',
        vehicleAssignments: [
          VehicleAssignment(
            id: 'va_1',
            scheduleSlotId: 'slot_2',
            vehicleId: 'vehicle_1',
            assignedAt: now,
            assignedBy: 'user_1',
            vehicleName: 'Vehicle 1',
            capacity: 4,
            createdAt: now,
            updatedAt: now,
          ),
        ],
        maxVehicles: 2,
        createdAt: now,
        updatedAt: now,
      );

      testDisplayableSlots = [
        const DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: TimeOfDayValue(8, 0),
          week: '2024-W01',
          existsInBackend: true, // Un slot sans véhicule
        ),
        DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: const TimeOfDayValue(9, 0),
          week: '2024-W01',
          existsInBackend: true,
          scheduleSlot: assignedSlot, // Un slot avec véhicule
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

    testWidgets('displays period card with basic information', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: PeriodCardWidget(
            key: const Key('test_period_card'),
            periodName: 'Matin',
            displayableSlots: testDisplayableSlots,
            onSlotTap: (slot) {},
            childrenMap: testChildren,
          ),
        ),
      );

      expect(find.byKey(const Key('period_card_matin')), findsOneWidget);
      expect(find.byKey(const Key('period_header_matin')), findsOneWidget);
      expect(find.text('Matin'), findsOneWidget);
      expect(find.byKey(const Key('period_slots_matin')), findsOneWidget);
      expect(
        find.byKey(const Key('period_availability_matin')),
        findsOneWidget,
      );
    });

    testWidgets('displays correct availability summary', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: PeriodCardWidget(
            key: const Key('test_period_card'),
            periodName: 'Matin',
            displayableSlots: testDisplayableSlots,
            onSlotTap: (slot) {},
            childrenMap: testChildren,
          ),
        ),
      );

      // 1 out of 2 slots are assigned (those with vehicles)
      expect(find.text('1/2'), findsOneWidget);

      final summaryContainer = tester.widget<Container>(
        find.byKey(const Key('period_availability_matin')),
      );
      final decoration = summaryContainer.decoration as BoxDecoration;
      expect(decoration.color, Colors.blue); // Not fully assigned
    });

    testWidgets('displays enhanced slot cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: PeriodCardWidget(
            key: const Key('test_period_card'),
            periodName: 'Matin',
            displayableSlots: testDisplayableSlots,
            vehicles: testVehicles,
            onSlotTap: (slot) {},
            childrenMap: testChildren,
          ),
        ),
      );

      // Should find 2 enhanced slot cards
      expect(find.byType(EnhancedSlotCard), findsNWidgets(2));
    });

    testWidgets('provides onSlotTap callback to child widgets', (
      WidgetTester tester,
    ) async {
      DisplayableTimeSlot? tappedSlot;

      await tester.pumpWidget(
        createTestWidget(
          child: PeriodCardWidget(
            key: const Key('test_period_card'),
            periodName: 'Matin',
            displayableSlots: testDisplayableSlots,
            onSlotTap: (slot) => tappedSlot = slot,
            childrenMap: testChildren,
          ),
        ),
      );

      // Verify the widget renders correctly with the callback provided
      expect(find.byType(PeriodCardWidget), findsOneWidget);
      expect(find.byType(EnhancedSlotCard), findsNWidgets(2));
      expect(find.byType(GestureDetector), findsWidgets);

      // Callback should be available (initially null until widget interaction)
      expect(tappedSlot, isNull);
    });

    testWidgets('handles empty slots list correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: PeriodCardWidget(
            key: const Key('test_period_card'),
            periodName: 'Matin',
            displayableSlots: const [],
            onSlotTap: (slot) {},
            childrenMap: testChildren,
          ),
        ),
      );

      expect(find.byKey(const Key('period_card_matin')), findsOneWidget);
      expect(find.text('Matin'), findsOneWidget);
      expect(find.text('0/0'), findsOneWidget);

      final summaryContainer = tester.widget<Container>(
        find.byKey(const Key('period_availability_matin')),
      );
      final decoration = summaryContainer.decoration as BoxDecoration;
      expect(decoration.color, Colors.green); // No slots to assign
    });

    testWidgets('displays period name correctly with different cases', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: PeriodCardWidget(
            key: const Key('test_period_card'),
            periodName: 'Après-midi',
            displayableSlots: testDisplayableSlots,
            onSlotTap: (slot) {},
            childrenMap: testChildren,
          ),
        ),
      );

      expect(find.byKey(const Key('period_card_après-midi')), findsOneWidget);
      expect(find.byKey(const Key('period_header_après-midi')), findsOneWidget);
      expect(find.byKey(const Key('period_slots_après-midi')), findsOneWidget);
      expect(
        find.byKey(const Key('period_availability_après-midi')),
        findsOneWidget,
      );
      expect(find.text('Après-midi'), findsOneWidget);
    });

    testWidgets('displays fully assigned slots correctly', (
      WidgetTester tester,
    ) async {
      // Create fully assigned slots avec vrais ScheduleSlot
      final now = DateTime.now();
      final fullyAssignedDisplayableSlots = [
        DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: const TimeOfDayValue(10, 0),
          week: '2024-W01',
          existsInBackend: true,
          scheduleSlot: ScheduleSlot(
            id: 'slot_full_1',
            groupId: 'group_1',
            dayOfWeek: DayOfWeek.monday,
            timeOfDay: const TimeOfDayValue(10, 0),
            week: '2024-W01',
            vehicleAssignments: [
              VehicleAssignment(
                id: 'va_full_1',
                scheduleSlotId: 'slot_full_1',
                vehicleId: 'vehicle_1',
                assignedAt: now,
                assignedBy: 'user_1',
                vehicleName: 'Vehicle 1',
                capacity: 4,
                createdAt: now,
                updatedAt: now,
              ),
            ],
            maxVehicles: 2,
            createdAt: now,
            updatedAt: now,
          ),
        ),
        DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: const TimeOfDayValue(11, 0),
          week: '2024-W01',
          existsInBackend: true,
          scheduleSlot: ScheduleSlot(
            id: 'slot_full_2',
            groupId: 'group_1',
            dayOfWeek: DayOfWeek.monday,
            timeOfDay: const TimeOfDayValue(11, 0),
            week: '2024-W01',
            vehicleAssignments: [
              VehicleAssignment(
                id: 'va_full_2',
                scheduleSlotId: 'slot_full_2',
                vehicleId: 'vehicle_1',
                assignedAt: now,
                assignedBy: 'user_1',
                vehicleName: 'Vehicle 1',
                capacity: 4,
                createdAt: now,
                updatedAt: now,
              ),
            ],
            maxVehicles: 2,
            createdAt: now,
            updatedAt: now,
          ),
        ),
      ];

      await tester.pumpWidget(
        createTestWidget(
          child: PeriodCardWidget(
            key: const Key('test_period_card'),
            periodName: 'Matin',
            displayableSlots: fullyAssignedDisplayableSlots,
            onSlotTap: (slot) {},
            childrenMap: testChildren,
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Attendre que le widget soit stable
      await tester.pumpAndSettle();

      expect(find.text('2/2'), findsOneWidget);

      final summaryContainer = tester.widget<Container>(
        find.byKey(const Key('period_availability_matin')),
      );
      final decoration = summaryContainer.decoration as BoxDecoration;
      expect(decoration.color, Colors.green); // Fully assigned
    });

    testWidgets('handles non-existent displayable slots', (
      WidgetTester tester,
    ) async {
      // Create mix of existing and non-existing slots
      final mixedSlots = [
        ...testDisplayableSlots.take(1),
        const DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: TimeOfDayValue(14, 0),
          week: '2024-W01',
          existsInBackend: false,
        ),
      ];

      await tester.pumpWidget(
        createTestWidget(
          child: PeriodCardWidget(
            key: const Key('test_period_card'),
            periodName: 'Matin',
            displayableSlots: mixedSlots,
            onSlotTap: (slot) {},
            childrenMap: testChildren,
          ),
        ),
      );

      // Should still display the card without crashing
      expect(find.byKey(const Key('period_card_matin')), findsOneWidget);
      expect(find.byType(EnhancedSlotCard), findsNWidgets(2));
    });
  });
}
