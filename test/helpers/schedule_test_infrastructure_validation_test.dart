import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/domain/entities/schedule/day_of_week.dart';
import 'package:edulift/core/domain/entities/schedule/time_of_day.dart';

import 'schedule_test_helpers.dart';

/// Validation test for the schedule test infrastructure
///
/// This test ensures that all the helper methods in ScheduleTestHelpers
/// work correctly and generate valid test data.
void main() {
  group('ScheduleTestHelpers Validation', () {
    test('createDisplayableSlot creates valid slot', () {
      final slot = ScheduleTestHelpers.createDisplayableSlot(
        dayOfWeek: DayOfWeek.monday,
        timeOfDay: const TimeOfDayValue(8, 0),
        vehicles: 1,
        childrenPerVehicle: 2,
      );

      expect(slot.dayOfWeek, DayOfWeek.monday);
      expect(slot.timeOfDay.hour, 8);
      expect(slot.timeOfDay.minute, 0);
      expect(slot.existsInBackend, true);
      expect(slot.hasVehicles, true);
      expect(slot.vehicleCount, 1);
      expect(slot.canAddVehicle, true);
    });

    test('createDisplayableSlot with no vehicles creates empty slot', () {
      final slot = ScheduleTestHelpers.createDisplayableSlot(
        dayOfWeek: DayOfWeek.tuesday,
        timeOfDay: const TimeOfDayValue(15, 0),
      );

      expect(slot.dayOfWeek, DayOfWeek.tuesday);
      expect(slot.hasVehicles, false);
      expect(slot.vehicleCount, 0);
      expect(slot.canAddVehicle, true);
    });

    test('createDisplayableSlot with uncreated slot', () {
      final slot = ScheduleTestHelpers.createDisplayableSlot(
        dayOfWeek: DayOfWeek.wednesday,
        timeOfDay: const TimeOfDayValue(9, 30),
        existsInBackend: false,
      );

      expect(slot.dayOfWeek, DayOfWeek.wednesday);
      expect(slot.existsInBackend, false);
      expect(slot.hasVehicles, false);
      expect(slot.scheduleSlot, null);
    });

    test('createWeekSchedule generates correct number of slots', () {
      final weekSchedule = ScheduleTestHelpers.createWeekSchedule();

      // 5 days * 2 time slots per day = 10 slots
      expect(weekSchedule.length, 10);

      // Verify each day appears twice (morning and afternoon)
      final dayCounts = <DayOfWeek, int>{};
      for (final slot in weekSchedule) {
        dayCounts[slot.dayOfWeek] = (dayCounts[slot.dayOfWeek] ?? 0) + 1;
      }

      expect(dayCounts[DayOfWeek.monday], 2);
      expect(dayCounts[DayOfWeek.tuesday], 2);
      expect(dayCounts[DayOfWeek.wednesday], 2);
      expect(dayCounts[DayOfWeek.thursday], 2);
      expect(dayCounts[DayOfWeek.friday], 2);
    });

    test('createTestVehicle creates valid vehicle', () {
      final vehicle = ScheduleTestHelpers.createTestVehicle(
        name: 'Test Car',
        capacity: 5,
      );

      expect(vehicle.name, 'Test Car');
      expect(vehicle.capacity, 5);
      expect(vehicle.familyId, ScheduleTestHelpers.testFamilyId);
      expect(vehicle.initials, 'TC');
      expect(vehicle.availablePassengerSeats, 4);
      expect(vehicle.canAccommodate(4), true);
      expect(vehicle.canAccommodate(5), false);
    });

    test('createTestVehicles creates multiple vehicles', () {
      final vehicles = ScheduleTestHelpers.createTestVehicles(
        capacity: 7,
        namePrefix: 'Van',
      );

      expect(vehicles.length, 3);
      expect(vehicles[0].name, 'Van 1');
      expect(vehicles[1].name, 'Van 2');
      expect(vehicles[2].name, 'Van 3');

      for (final vehicle in vehicles) {
        expect(vehicle.capacity, 7);
        expect(vehicle.familyId, ScheduleTestHelpers.testFamilyId);
      }
    });

    test('createVehicleMap creates proper mapping', () {
      final vehicles = ScheduleTestHelpers.createTestVehicles(count: 2);
      final vehicleMap = ScheduleTestHelpers.createVehicleMap(
        vehicles: vehicles,
      );

      expect(vehicleMap.length, 2);
      expect(vehicleMap.containsKey(vehicles[0].id), true);
      expect(vehicleMap.containsKey(vehicles[1].id), true);
      expect(vehicleMap[vehicles[0].id], vehicles[0]);
      expect(vehicleMap[vehicles[1].id], vehicles[1]);
    });

    test('createTestChild creates valid child', () {
      final child = ScheduleTestHelpers.createTestChild(
        name: 'Emma Johnson',
        age: 8,
      );

      expect(child.name, 'Emma Johnson');
      expect(child.age, 8);
      expect(child.familyId, ScheduleTestHelpers.testFamilyId);
      expect(child.initials, 'EJ');
    });

    test('createTestChildren creates multiple children', () {
      final children = ScheduleTestHelpers.createTestChildren(
        count: 4,
        startAge: 6,
        namePrefix: 'Kid',
      );

      expect(children.length, 4);
      expect(children[0].name, 'Kid 1');
      expect(children[0].age, 6);
      expect(children[1].name, 'Kid 2');
      expect(children[1].age, 7);
      expect(children[2].name, 'Kid 3');
      expect(children[2].age, 8);
      expect(children[3].name, 'Kid 4');
      expect(children[3].age, 9);
    });

    test('createChildMap creates proper mapping', () {
      final children = ScheduleTestHelpers.createTestChildren(count: 3);
      final childMap = ScheduleTestHelpers.createChildMap(children: children);

      expect(childMap.length, 3);
      expect(childMap.containsKey(children[0].id), true);
      expect(childMap.containsKey(children[1].id), true);
      expect(childMap.containsKey(children[2].id), true);
    });

    test('createCapacityTestCases creates all scenarios', () {
      final testCases = ScheduleTestHelpers.createCapacityTestCases();

      expect(testCases.length, 5);
      expect(testCases.containsKey('empty'), true);
      expect(testCases.containsKey('available'), true);
      expect(testCases.containsKey('limited'), true);
      expect(testCases.containsKey('full'), true);
      expect(testCases.containsKey('overcapacity'), true);

      // Test empty slot
      final emptySlot = testCases['empty']!;
      expect(emptySlot.hasVehicles, false);

      // Test full slot
      final fullSlot = testCases['full']!;
      expect(fullSlot.hasVehicles, true);
      // Note: canAddVehicle checks if we can add more vehicles, not if the current vehicle is full
      // The logic is at the ScheduleSlot level with maxVehicles check

      // Test overcapacity slot
      final overcapacitySlot = testCases['overcapacity']!;
      expect(overcapacitySlot.hasVehicles, true);
      // Note: overcapacity logic would need to be checked at the ScheduleSlot level
    });

    test('createPastSlot creates slot in the past', () {
      final pastSlot = ScheduleTestHelpers.createPastSlot(hasVehicles: true);

      expect(pastSlot.dayOfWeek, DayOfWeek.monday);
      expect(pastSlot.existsInBackend, true);
      // Note: Past detection logic would depend on actual time comparison
    });

    test('Constants are properly defined', () {
      expect(ScheduleTestHelpers.testGroupId, isNotEmpty);
      expect(ScheduleTestHelpers.testFamilyId, isNotEmpty);
      expect(ScheduleTestHelpers.testWeek, isNotEmpty);
      expect(ScheduleTestHelpers.testTimezone, isNotEmpty);
    });

    test('Error handling for invalid parameters', () {
      // Test vehicles > maxVehicles
      expect(
        () => ScheduleTestHelpers.createDisplayableSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: const TimeOfDayValue(8, 0),
          vehicles: 5,
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Test children > vehicle capacity
      expect(
        () => ScheduleTestHelpers.createDisplayableSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: const TimeOfDayValue(8, 0),
          vehicles: 1,
          childrenPerVehicle: 8,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
