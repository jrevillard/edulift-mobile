import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/domain/entities/schedule.dart';

void main() {
  group('ScheduleSlot Entity', () {
    late DateTime testCreatedAt;
    late DateTime testUpdatedAt;
    late VehicleAssignment testVehicleAssignment;

    setUp(() {
      testCreatedAt = DateTime(2024, 1, 1, 10);
      testUpdatedAt = DateTime(2024, 1, 2, 10);
      testVehicleAssignment = VehicleAssignment(
        id: 'assignment-123',
        scheduleSlotId: 'slot-456',
        vehicleId: 'vehicle-789',
        driverId: 'driver-101',
        assignedAt: testCreatedAt,
        assignedBy: 'user-admin',
        vehicleName: 'Test Vehicle',
        capacity: 8,
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
      );
    });

    group('constructor', () {
      test('should create ScheduleSlot with all required fields', () {
        // arrange & act
        final scheduleSlot = ScheduleSlot(
          id: 'slot-123',
          groupId: 'group-456',
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: const TimeOfDayValue(8, 0),
          week: 'Week1',
          vehicleAssignments: [testVehicleAssignment],
          maxVehicles: 3,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // assert
        expect(scheduleSlot.id, equals('slot-123'));
        expect(scheduleSlot.groupId, equals('group-456'));
        expect(scheduleSlot.dayOfWeek, equals(DayOfWeek.monday));
        expect(scheduleSlot.timeOfDay, equals(const TimeOfDayValue(8, 0)));
        expect(scheduleSlot.week, equals('Week1'));
        expect(
          scheduleSlot.vehicleAssignments,
          equals([testVehicleAssignment]),
        );
        expect(scheduleSlot.maxVehicles, equals(3));
        expect(scheduleSlot.createdAt, equals(testCreatedAt));
        expect(scheduleSlot.updatedAt, equals(testUpdatedAt));
      });

      test('should create ScheduleSlot with empty vehicle assignments', () {
        // arrange & act
        final scheduleSlot = ScheduleSlot(
          id: 'slot-123',
          groupId: 'group-456',
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: const TimeOfDayValue(8, 0),
          week: 'Week1',
          vehicleAssignments: const [],
          maxVehicles: 3,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // assert
        expect(scheduleSlot.vehicleAssignments, equals([]));
        expect(scheduleSlot.maxVehicles, equals(3));
      });

      test('should create ScheduleSlot with multiple vehicle assignments', () {
        // arrange
        final assignment1 = VehicleAssignment(
          id: 'assignment-1',
          scheduleSlotId: 'slot-456',
          vehicleId: 'vehicle-1',
          driverId: 'driver-1',
          assignedAt: testCreatedAt,
          assignedBy: 'user-admin',
          vehicleName: 'Vehicle 1',
          capacity: 8,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );
        final assignment2 = VehicleAssignment(
          id: 'assignment-2',
          scheduleSlotId: 'slot-456',
          vehicleId: 'vehicle-2',
          driverId: 'driver-2',
          assignedAt: testCreatedAt,
          assignedBy: 'user-admin',
          vehicleName: 'Vehicle 2',
          capacity: 8,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // act
        final scheduleSlot = ScheduleSlot(
          id: 'slot-123',
          groupId: 'group-456',
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: const TimeOfDayValue(8, 0),
          week: 'Week1',
          vehicleAssignments: [assignment1, assignment2],
          maxVehicles: 3,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // assert
        expect(scheduleSlot.vehicleAssignments.length, equals(2));
        expect(scheduleSlot.vehicleAssignments, contains(assignment1));
        expect(scheduleSlot.vehicleAssignments, contains(assignment2));
      });
    });

    group('copyWith', () {
      late ScheduleSlot originalScheduleSlot;

      setUp(() {
        originalScheduleSlot = ScheduleSlot(
          id: 'slot-123',
          groupId: 'group-456',
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: const TimeOfDayValue(8, 0),
          week: 'Week1',
          vehicleAssignments: [testVehicleAssignment],
          maxVehicles: 3,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );
      });

      test(
        'should return identical ScheduleSlot when no parameters provided',
        () {
          // act
          final result = originalScheduleSlot.copyWith();

          // assert
          expect(result, equals(originalScheduleSlot));
        },
      );

      test('should update basic scheduling fields correctly', () {
        // arrange
        const newDayOfWeek = DayOfWeek.tuesday;
        const newTimeOfDay = TimeOfDayValue(9, 0);
        const newWeek = 'Week2';

        // act
        final result = originalScheduleSlot.copyWith(
          dayOfWeek: newDayOfWeek,
          timeOfDay: newTimeOfDay,
          week: newWeek,
        );

        // assert
        expect(result.dayOfWeek, equals(newDayOfWeek));
        expect(result.timeOfDay, equals(newTimeOfDay));
        expect(result.week, equals(newWeek));
        expect(result.id, equals(originalScheduleSlot.id));
        expect(result.groupId, equals(originalScheduleSlot.groupId));
      });

      test('should update vehicle assignments correctly', () {
        // arrange
        final newAssignment = VehicleAssignment(
          id: 'new-assignment',
          scheduleSlotId: 'slot-456',
          vehicleId: 'new-vehicle',
          driverId: 'new-driver',
          assignedAt: testUpdatedAt,
          assignedBy: 'user-admin',
          vehicleName: 'New Vehicle',
          capacity: 8,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );
        final newAssignments = [newAssignment];

        // act
        final result = originalScheduleSlot.copyWith(
          vehicleAssignments: newAssignments,
        );

        // assert
        expect(result.vehicleAssignments, equals(newAssignments));
        expect(result.vehicleAssignments.length, equals(1));
        expect(result.vehicleAssignments.first, equals(newAssignment));
      });

      test('should update max vehicles correctly', () {
        // arrange
        const newMaxVehicles = 5;

        // act
        final result = originalScheduleSlot.copyWith(
          maxVehicles: newMaxVehicles,
        );

        // assert
        expect(result.maxVehicles, equals(newMaxVehicles));
      });

      test('should update timestamps correctly', () {
        // arrange
        final newCreatedAt = DateTime(2024, 6, 15);
        final newUpdatedAt = DateTime(2024, 6, 16);

        // act
        final result = originalScheduleSlot.copyWith(
          createdAt: newCreatedAt,
          updatedAt: newUpdatedAt,
        );

        // assert
        expect(result.createdAt, equals(newCreatedAt));
        expect(result.updatedAt, equals(newUpdatedAt));
      });
    });

    group('equality', () {
      late ScheduleSlot scheduleSlot1;
      late ScheduleSlot scheduleSlot2;

      setUp(() {
        scheduleSlot1 = ScheduleSlot(
          id: 'slot-123',
          groupId: 'group-456',
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: const TimeOfDayValue(8, 0),
          week: 'Week1',
          vehicleAssignments: [testVehicleAssignment],
          maxVehicles: 3,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );
        scheduleSlot2 = ScheduleSlot(
          id: 'slot-123',
          groupId: 'group-456',
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: const TimeOfDayValue(8, 0),
          week: 'Week1',
          vehicleAssignments: [testVehicleAssignment],
          maxVehicles: 3,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );
      });

      test('should be equal for identical schedule slots', () {
        // act & assert
        expect(scheduleSlot1, equals(scheduleSlot2));
        expect(scheduleSlot1.hashCode, equals(scheduleSlot2.hashCode));
      });

      test('should not be equal for different IDs', () {
        // arrange
        final differentScheduleSlot = scheduleSlot1.copyWith(
          id: 'different-id',
        );

        // act & assert
        expect(scheduleSlot1, isNot(equals(differentScheduleSlot)));
      });

      test('should not be equal for different days', () {
        // arrange
        final differentScheduleSlot = scheduleSlot1.copyWith(
          dayOfWeek: DayOfWeek.tuesday,
        );

        // act & assert
        expect(scheduleSlot1, isNot(equals(differentScheduleSlot)));
      });

      test('should not be equal for different times', () {
        // arrange
        final differentScheduleSlot = scheduleSlot1.copyWith(
          timeOfDay: const TimeOfDayValue(9, 0),
        );

        // act & assert
        expect(scheduleSlot1, isNot(equals(differentScheduleSlot)));
      });

      test('should not be equal for different vehicle assignments', () {
        // arrange
        final differentAssignment = VehicleAssignment(
          id: 'different-assignment',
          scheduleSlotId: 'slot-456',
          vehicleId: 'different-vehicle',
          driverId: 'different-driver',
          assignedAt: testCreatedAt,
          assignedBy: 'user-admin',
          vehicleName: 'Different Vehicle',
          capacity: 8,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );
        final differentScheduleSlot = scheduleSlot1.copyWith(
          vehicleAssignments: [differentAssignment],
        );

        // act & assert
        expect(scheduleSlot1, isNot(equals(differentScheduleSlot)));
      });

      test('should not be equal for different max vehicles', () {
        // arrange
        final differentScheduleSlot = scheduleSlot1.copyWith(maxVehicles: 5);

        // act & assert
        expect(scheduleSlot1, isNot(equals(differentScheduleSlot)));
      });

      test('should handle empty vehicle assignments in equality', () {
        // arrange
        final scheduleSlotEmpty1 = scheduleSlot1.copyWith(
          vehicleAssignments: [],
        );
        final scheduleSlotEmpty2 = scheduleSlot1.copyWith(
          vehicleAssignments: [],
        );

        // act & assert
        expect(scheduleSlotEmpty1, equals(scheduleSlotEmpty2));
      });
    });

    group('business logic validation', () {
      test('should handle realistic scheduling scenarios', () {
        // arrange & act
        final weeklyScheduleSlots = [
          ScheduleSlot(
            id: 'monday-morning',
            groupId: 'elementary-group',
            dayOfWeek: DayOfWeek.monday,
            timeOfDay: const TimeOfDayValue(8, 0),
            week: 'Week1',
            vehicleAssignments: const [],
            maxVehicles: 2,
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          ),
          ScheduleSlot(
            id: 'monday-afternoon',
            groupId: 'elementary-group',
            dayOfWeek: DayOfWeek.monday,
            timeOfDay: const TimeOfDayValue(15, 30),
            week: 'Week1',
            vehicleAssignments: const [],
            maxVehicles: 2,
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          ),
          ScheduleSlot(
            id: 'friday-morning',
            groupId: 'elementary-group',
            dayOfWeek: DayOfWeek.friday,
            timeOfDay: const TimeOfDayValue(8, 0),
            week: 'Week1',
            vehicleAssignments: const [],
            maxVehicles: 3,
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          ),
        ];

        for (final slot in weeklyScheduleSlots) {
          // assert - should handle realistic scheduling scenarios
          expect(slot.dayOfWeek.fullName, isNotEmpty);
          expect(slot.timeOfDay.toApiFormat(), isNotEmpty);
          expect(slot.maxVehicles, greaterThan(0));
          expect(slot.id, isNotEmpty);
          expect(slot.groupId, isNotEmpty);
        }
      });

      test('should handle all days of week', () {
        // arrange & act
        final allDays = [
          DayOfWeek.monday,
          DayOfWeek.tuesday,
          DayOfWeek.wednesday,
          DayOfWeek.thursday,
          DayOfWeek.friday,
          DayOfWeek.saturday,
          DayOfWeek.sunday,
        ];

        for (final dayOfWeek in allDays) {
          // act
          final scheduleSlot = ScheduleSlot(
            id: 'slot-${dayOfWeek.fullName.toLowerCase()}',
            groupId: 'group-456',
            dayOfWeek: dayOfWeek,
            timeOfDay: const TimeOfDayValue(8, 0),
            week: 'Week1',
            vehicleAssignments: const [],
            maxVehicles: 3,
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          );

          // assert - should handle all days of week
          expect(scheduleSlot.dayOfWeek, equals(dayOfWeek));
          expect(scheduleSlot.dayOfWeek.fullName, isNotEmpty);
          expect(scheduleSlot.id, isNotEmpty);
        }
      });

      test('should handle various time values', () {
        // arrange
        final timeValues = [
          const TimeOfDayValue(8, 0), // Morning
          const TimeOfDayValue(7, 30), // Early morning
          const TimeOfDayValue(20, 30), // Evening
          const TimeOfDayValue(12, 0), // Noon
          const TimeOfDayValue(23, 59), // End of day
        ];

        for (final timeOfDay in timeValues) {
          // act
          final scheduleSlot = ScheduleSlot(
            id: 'slot-${timeOfDay.toApiFormat().replaceAll(':', '-')}',
            groupId: 'group-456',
            dayOfWeek: DayOfWeek.monday,
            timeOfDay: timeOfDay,
            week: 'Week1',
            vehicleAssignments: const [],
            maxVehicles: 3,
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          );

          // assert - should handle various time values
          expect(scheduleSlot.timeOfDay, equals(timeOfDay));
          expect(scheduleSlot.timeOfDay.toApiFormat(), isNotEmpty);
          expect(scheduleSlot.id, isNotEmpty);
        }
      });

      test('should handle different week identifiers', () {
        // arrange
        final weekIdentifiers = [
          'Week1',
          'Week 1',
          'W1',
          '2024-W01',
          'Semester1-Week1',
          'Q1W1',
        ];

        for (final week in weekIdentifiers) {
          // act
          final scheduleSlot = ScheduleSlot(
            id: 'slot-${week.replaceAll(' ', '-').replaceAll('-', '_')}',
            groupId: 'group-456',
            dayOfWeek: DayOfWeek.monday,
            timeOfDay: const TimeOfDayValue(8, 0),
            week: week,
            vehicleAssignments: const [],
            maxVehicles: 3,
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          );

          // assert - should handle different week identifiers
          expect(scheduleSlot.week, equals(week));
          expect(scheduleSlot.id, isNotEmpty);
        }
      });

      test(
        'should maintain data integrity through complex scheduling operations',
        () {
          // arrange
          final originalSlot = ScheduleSlot(
            id: 'slot-123',
            groupId: 'group-456',
            dayOfWeek: DayOfWeek.monday,
            timeOfDay: const TimeOfDayValue(8, 0),
            week: 'Week1',
            vehicleAssignments: [testVehicleAssignment],
            maxVehicles: 3,
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          );

          // act - simulate scheduling operations
          final updatedSlot = originalSlot
              .copyWith(maxVehicles: 5) // Increase capacity
              .copyWith(vehicleAssignments: []) // Clear assignments
              .copyWith(dayOfWeek: DayOfWeek.tuesday) // Reschedule
              .copyWith(
                vehicleAssignments: [testVehicleAssignment],
              ); // Reassign

          // assert - verify selective changes
          expect(updatedSlot.id, equals(originalSlot.id));
          expect(updatedSlot.groupId, equals(originalSlot.groupId));
          expect(updatedSlot.dayOfWeek, equals(DayOfWeek.tuesday)); // Updated
          expect(updatedSlot.timeOfDay, equals(originalSlot.timeOfDay));
          expect(updatedSlot.week, equals(originalSlot.week));
          expect(
            updatedSlot.vehicleAssignments,
            equals([testVehicleAssignment]),
          ); // Reassigned
          expect(updatedSlot.maxVehicles, equals(5)); // Updated
        },
      );

      test('should handle capacity constraints scenarios', () {
        // arrange & act
        final capacityScenarios = [
          // Single vehicle slot
          ScheduleSlot(
            id: 'single-vehicle',
            groupId: 'small-group',
            dayOfWeek: DayOfWeek.monday,
            timeOfDay: const TimeOfDayValue(8, 0),
            week: 'Week1',
            vehicleAssignments: const [],
            maxVehicles: 1,
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          ),
          // Large capacity slot
          ScheduleSlot(
            id: 'large-capacity',
            groupId: 'large-group',
            dayOfWeek: DayOfWeek.monday,
            timeOfDay: const TimeOfDayValue(8, 0),
            week: 'Week1',
            vehicleAssignments: const [],
            maxVehicles: 10,
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          ),
        ];

        for (final slot in capacityScenarios) {
          // assert - should handle various capacity scenarios
          expect(slot.maxVehicles, greaterThan(0));
          expect(
            slot.vehicleAssignments.length,
            lessThanOrEqualTo(slot.maxVehicles),
          );
          expect(slot.id, isNotEmpty);
        }
      });

      test('should handle complex vehicle assignment scenarios', () {
        // arrange
        final multipleAssignments = List.generate(
          5,
          (index) => VehicleAssignment(
            id: 'assignment-$index',
            scheduleSlotId: 'slot-456',
            vehicleId: 'vehicle-$index',
            driverId: 'driver-$index',
            assignedAt: testCreatedAt.add(Duration(minutes: index)),
            assignedBy: 'user-admin',
            vehicleName: 'Vehicle $index',
            capacity: 8,
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          ),
        );

        // act
        final scheduleSlot = ScheduleSlot(
          id: 'multi-vehicle-slot',
          groupId: 'group-456',
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: const TimeOfDayValue(8, 0),
          week: 'Week1',
          vehicleAssignments: multipleAssignments,
          maxVehicles: 5,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // assert
        expect(scheduleSlot.vehicleAssignments.length, equals(5));
        expect(
          scheduleSlot.vehicleAssignments.length,
          equals(scheduleSlot.maxVehicles),
        );
        expect(scheduleSlot.id, isNotEmpty);
        expect(scheduleSlot.vehicleAssignments.length, greaterThan(0));
      });
    });
  });
}
