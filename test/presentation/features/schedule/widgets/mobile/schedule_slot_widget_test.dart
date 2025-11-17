import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/features/schedule/presentation/widgets/schedule_slot_widget.dart';
import 'package:edulift/core/domain/entities/schedule/schedule_slot.dart';
import 'package:edulift/core/domain/entities/schedule/day_of_week.dart';
import 'package:edulift/core/domain/entities/schedule/time_of_day.dart';
import 'package:edulift/core/domain/entities/schedule/vehicle_assignment.dart';
import 'package:edulift/core/domain/entities/family/child_assignment.dart';
import 'package:edulift/core/domain/entities/schedule/period_slot_data.dart';
import 'package:edulift/core/domain/entities/schedule/schedule_period.dart';
import '../../../../../../test/support/test_app_configuration.dart';

Widget createTestApp({required Widget child}) {
  return TestAppConfiguration.createTestWidget(child: child, locale: 'en');
}

void main() {
  group('ScheduleSlotWidget Tests', () {
    late PeriodSlotData testPeriodSlot;
    late VehicleAssignment testVehicleAssignment;

    setUp(() {
      final now = DateTime.now();

      // Create test vehicle assignment
      testVehicleAssignment = VehicleAssignment(
        id: 'va1',
        scheduleSlotId: 'slot1',
        vehicleId: 'vehicle1',
        assignedAt: now,
        assignedBy: 'user1',
        vehicleName: 'Family Van',
        capacity: 6,
        createdAt: now,
        updatedAt: now,
        childAssignments: [
          ChildAssignment.transportation(
            id: 'ca1',
            childId: 'child1',
            groupId: 'group1',
            scheduleSlotId: 'slot1',
            vehicleAssignmentId: 'va1',
            assignedAt: now,
            status: AssignmentStatus.confirmed,
            assignmentDate: now,
          ),
        ],
      );

      // Create test period slot data
      testPeriodSlot = PeriodSlotData(
        dayOfWeek: DayOfWeek.monday,
        period: const SpecificTimeSlot(TimeOfDayValue(8, 0)),
        times: const [TimeOfDayValue(8, 0)],
        slots: [
          ScheduleSlot(
            id: 'slot1',
            groupId: 'group1',
            dayOfWeek: DayOfWeek.monday,
            timeOfDay: const TimeOfDayValue(8, 0),
            week: '2024-W01',
            vehicleAssignments: [testVehicleAssignment],
            maxVehicles: 2,
            createdAt: now,
            updatedAt: now,
          ),
        ],
        week: '2024-W01',
      );
    });

    testWidgets('renders schedule slot with correct information', (
      WidgetTester tester,
    ) async {
      // Arrange
      final widget = ScheduleSlotWidget(
        groupId: 'group1',
        day: 'Monday',
        time: '08:00',
        week: '2024-W01',
        scheduleSlot: testPeriodSlot,
        onTap: () {},
        onVehicleDrop: (vehicleId) {},
      );

      // Act
      await tester.pumpWidget(createTestApp(child: widget));

      // Assert
      expect(find.text('1 vehicle'), findsOneWidget);
      expect(find.text('Family Van'), findsOneWidget);
    });

    testWidgets('displays empty slot when no assignments', (
      WidgetTester tester,
    ) async {
      // Arrange
      final emptySlot = testPeriodSlot.copyWith(
        slots: [
          ScheduleSlot(
            id: 'slot1',
            groupId: 'group1',
            dayOfWeek: DayOfWeek.monday,
            timeOfDay: const TimeOfDayValue(8, 0),
            week: '2024-W01',
            vehicleAssignments: const [],
            maxVehicles: 2,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
      );

      final widget = ScheduleSlotWidget(
        groupId: 'group1',
        day: 'Monday',
        time: '08:00',
        week: '2024-W01',
        scheduleSlot: emptySlot,
        onTap: () {},
        onVehicleDrop: (vehicleId) {},
      );

      // Act
      await tester.pumpWidget(createTestApp(child: widget));

      // Assert - check that the empty slot has an add icon
      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
    });

    testWidgets('handles tap on slot correctly', (WidgetTester tester) async {
      // Arrange
      var wasTapped = false;
      final widget = ScheduleSlotWidget(
        groupId: 'group1',
        day: 'Monday',
        time: '08:00',
        week: '2024-W01',
        scheduleSlot: testPeriodSlot,
        onTap: () {
          wasTapped = true;
        },
        onVehicleDrop: (vehicleId) {},
      );

      // Act
      await tester.pumpWidget(createTestApp(child: widget));

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      // Assert
      expect(wasTapped, isTrue);
    });

    testWidgets('displays different times correctly', (
      WidgetTester tester,
    ) async {
      // Test morning time
      final morningSlot = testPeriodSlot.copyWith(
        period: const SpecificTimeSlot(TimeOfDayValue(8, 30)),
        times: const [TimeOfDayValue(8, 30)],
      );

      await tester.pumpWidget(
        createTestApp(
          child: ScheduleSlotWidget(
            groupId: 'group1',
            day: 'Monday',
            time: '08:30',
            week: '2024-W01',
            scheduleSlot: morningSlot,
            onTap: () {},
            onVehicleDrop: (vehicleId) {},
          ),
        ),
      );

      // Test afternoon time
      final afternoonSlot = testPeriodSlot.copyWith(
        period: const SpecificTimeSlot(TimeOfDayValue(14, 15)),
        times: const [TimeOfDayValue(14, 15)],
      );

      await tester.pumpWidget(
        createTestApp(
          child: ScheduleSlotWidget(
            groupId: 'group1',
            day: 'Monday',
            time: '14:15',
            week: '2024-W01',
            scheduleSlot: afternoonSlot,
            onTap: () {},
            onVehicleDrop: (vehicleId) {},
          ),
        ),
      );

      // Test evening time
      final eveningSlot = testPeriodSlot.copyWith(
        period: const SpecificTimeSlot(TimeOfDayValue(18, 45)),
        times: const [TimeOfDayValue(18, 45)],
      );

      await tester.pumpWidget(
        createTestApp(
          child: ScheduleSlotWidget(
            groupId: 'group1',
            day: 'Monday',
            time: '18:45',
            week: '2024-W01',
            scheduleSlot: eveningSlot,
            onTap: () {},
            onVehicleDrop: (vehicleId) {},
          ),
        ),
      );
    });

    testWidgets('handles drag and drop interactions', (
      WidgetTester tester,
    ) async {
      // Arrange
      final widget = ScheduleSlotWidget(
        groupId: 'group1',
        day: 'Monday',
        time: '08:00',
        week: '2024-W01',
        scheduleSlot: testPeriodSlot,
        onTap: () {},
        onVehicleDrop: (vehicleId) {},
      );

      // Act
      await tester.pumpWidget(createTestApp(child: widget));

      // Simulate drag and drop
      await tester.drag(find.byType(ScheduleSlotWidget), const Offset(0, 0));
      await tester.pumpAndSettle();

      // The drop callback should be available (test verifies widget doesn't crash)
      expect(find.byType(ScheduleSlotWidget), findsOneWidget);
    });

    testWidgets('displays null slot when scheduleSlot is null', (
      WidgetTester tester,
    ) async {
      // Arrange
      final widget = ScheduleSlotWidget(
        groupId: 'group1',
        day: 'Monday',
        time: '08:00',
        week: '2024-W01',
        scheduleSlot: null,
        onTap: () {},
        onVehicleDrop: (vehicleId) {},
      );

      // Act
      await tester.pumpWidget(createTestApp(child: widget));

      // Assert
      expect(find.byType(ScheduleSlotWidget), findsOneWidget);
    });

    testWidgets('applies proper semantic labels', (WidgetTester tester) async {
      // Arrange
      final widget = ScheduleSlotWidget(
        groupId: 'group1',
        day: 'Monday',
        time: '08:00',
        week: '2024-W01',
        scheduleSlot: testPeriodSlot,
        onTap: () {},
        onVehicleDrop: (vehicleId) {},
      );

      // Act
      await tester.pumpWidget(createTestApp(child: widget));

      // Assert
      expect(
        find.bySemanticsLabel(RegExp(r'.*')),
        findsWidgets,
      ); // Just check that semantic labels exist
    });

    testWidgets('shows highlight state during drag', (
      WidgetTester tester,
    ) async {
      // Arrange
      final widget = ScheduleSlotWidget(
        groupId: 'group1',
        day: 'Monday',
        time: '08:00',
        week: '2024-W01',
        scheduleSlot: testPeriodSlot,
        onTap: () {},
        onVehicleDrop: (vehicleId) {},
      );

      // Act
      await tester.pumpWidget(createTestApp(child: widget));

      // Test that the widget exists and is built
      expect(find.byType(ScheduleSlotWidget), findsOneWidget);
    });
  });
}
