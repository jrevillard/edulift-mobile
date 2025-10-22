import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/domain/entities/schedule.dart';

void main() {
  group('TimeSlot Entity', () {
    late DateTime testStartTime;
    late DateTime testEndTime;
    late DateTime testCreatedAt;
    late DateTime testUpdatedAt;

    setUp(() {
      testStartTime = DateTime(2024, 3, 15, 8); // 8:00 AM
      testEndTime = DateTime(2024, 3, 15, 9); // 9:00 AM
      testCreatedAt = DateTime(2024, 1, 1, 10);
      testUpdatedAt = DateTime(2024, 1, 2, 10);
    });

    group('constructor', () {
      test('should create TimeSlot with all required fields', () {
        // arrange & act
        final timeSlot = TimeSlot(
          id: 'timeslot-123',
          scheduleId: 'schedule-456',
          startTime: testStartTime,
          endTime: testEndTime,
          title: 'School Pickup',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // assert
        expect(timeSlot.id, equals('timeslot-123'));
        expect(timeSlot.scheduleId, equals('schedule-456'));
        expect(timeSlot.startTime, equals(testStartTime));
        expect(timeSlot.endTime, equals(testEndTime));
        expect(timeSlot.title, equals('School Pickup'));
        expect(timeSlot.createdAt, equals(testCreatedAt));
        expect(timeSlot.updatedAt, equals(testUpdatedAt));
      });

      test(
        'should create TimeSlot with default values for optional fields',
        () {
          // arrange & act
          final timeSlot = TimeSlot(
            id: 'timeslot-123',
            scheduleId: 'schedule-456',
            startTime: testStartTime,
            endTime: testEndTime,
            title: 'School Pickup',
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          );

          // assert
          expect(timeSlot.description, isNull);
          expect(timeSlot.location, isNull);
          expect(timeSlot.assignedChildIds, equals([]));
          expect(timeSlot.assignedVehicleId, isNull);
          expect(timeSlot.driverId, isNull);
          expect(timeSlot.isRecurring, equals(false));
          expect(timeSlot.recurrencePattern, isNull);
          expect(timeSlot.isActive, equals(true));
        },
      );

      test('should create TimeSlot with all optional fields specified', () {
        // arrange & act
        final timeSlot = TimeSlot(
          id: 'timeslot-123',
          scheduleId: 'schedule-456',
          startTime: testStartTime,
          endTime: testEndTime,
          title: 'School Pickup',
          description: 'Daily school pickup routine',
          location: 'Main School Gate',
          assignedChildIds: const ['child-1', 'child-2'],
          assignedVehicleId: 'vehicle-789',
          driverId: 'driver-101',
          isRecurring: true,
          recurrencePattern: 'FREQ=DAILY',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // assert
        expect(timeSlot.description, equals('Daily school pickup routine'));
        expect(timeSlot.location, equals('Main School Gate'));
        expect(timeSlot.assignedChildIds, equals(['child-1', 'child-2']));
        expect(timeSlot.assignedVehicleId, equals('vehicle-789'));
        expect(timeSlot.driverId, equals('driver-101'));
        expect(timeSlot.isRecurring, equals(true));
        expect(timeSlot.recurrencePattern, equals('FREQ=DAILY'));
        expect(timeSlot.isActive, equals(true));
      });
    });

    group('copyWith', () {
      late TimeSlot originalTimeSlot;

      setUp(() {
        originalTimeSlot = TimeSlot(
          id: 'timeslot-123',
          scheduleId: 'schedule-456',
          startTime: testStartTime,
          endTime: testEndTime,
          title: 'School Pickup',
          description: 'Original description',
          location: 'Original location',
          assignedChildIds: const ['child-1'],
          assignedVehicleId: 'vehicle-789',
          driverId: 'driver-101',
          isRecurring: true,
          recurrencePattern: 'FREQ=DAILY',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );
      });

      test('should return identical TimeSlot when no parameters provided', () {
        // act
        final result = originalTimeSlot.copyWith();

        // assert
        expect(result, equals(originalTimeSlot));
      });

      test('should update basic fields correctly', () {
        // arrange
        const newTitle = 'School Dropoff';
        const newDescription = 'Updated description';

        // act
        final result = originalTimeSlot.copyWith(
          title: newTitle,
          description: newDescription,
        );

        // assert
        expect(result.title, equals(newTitle));
        expect(result.description, equals(newDescription));
        expect(result.id, equals(originalTimeSlot.id));
        expect(result.scheduleId, equals(originalTimeSlot.scheduleId));
        expect(result.startTime, equals(originalTimeSlot.startTime));
        expect(result.endTime, equals(originalTimeSlot.endTime));
      });

      test('should update time fields correctly', () {
        // arrange
        final newStartTime = DateTime(2024, 3, 15, 9);
        final newEndTime = DateTime(2024, 3, 15, 10);

        // act
        final result = originalTimeSlot.copyWith(
          startTime: newStartTime,
          endTime: newEndTime,
        );

        // assert
        expect(result.startTime, equals(newStartTime));
        expect(result.endTime, equals(newEndTime));
      });

      test('should update assignment fields correctly', () {
        // arrange
        const newAssignedChildIds = ['child-2', 'child-3'];
        const newVehicleId = 'vehicle-999';
        const newDriverId = 'driver-202';

        // act
        final result = originalTimeSlot.copyWith(
          assignedChildIds: newAssignedChildIds,
          assignedVehicleId: newVehicleId,
          driverId: newDriverId,
        );

        // assert
        expect(result.assignedChildIds, equals(newAssignedChildIds));
        expect(result.assignedVehicleId, equals(newVehicleId));
        expect(result.driverId, equals(newDriverId));
      });

      test('should update recurrence fields correctly', () {
        // arrange
        const newIsRecurring = false;
        const newRecurrencePattern = 'FREQ=WEEKLY';

        // act
        final result = originalTimeSlot.copyWith(
          isRecurring: newIsRecurring,
          recurrencePattern: newRecurrencePattern,
        );

        // assert
        expect(result.isRecurring, equals(newIsRecurring));
        expect(result.recurrencePattern, equals(newRecurrencePattern));
      });

      test('should update status fields correctly', () {
        // arrange
        const newIsActive = false;

        // act
        final result = originalTimeSlot.copyWith(isActive: newIsActive);

        // assert
        expect(result.isActive, equals(newIsActive));
      });

      test('should preserve original values when no changes specified', () {
        // act
        final result = originalTimeSlot.copyWith();

        // assert
        expect(result.description, equals(originalTimeSlot.description));
        expect(result.location, equals(originalTimeSlot.location));
        expect(
          result.assignedVehicleId,
          equals(originalTimeSlot.assignedVehicleId),
        );
        expect(result.driverId, equals(originalTimeSlot.driverId));
        expect(
          result.recurrencePattern,
          equals(originalTimeSlot.recurrencePattern),
        );
      });
    });

    group('equality', () {
      late TimeSlot timeSlot1;
      late TimeSlot timeSlot2;

      setUp(() {
        timeSlot1 = TimeSlot(
          id: 'timeslot-123',
          scheduleId: 'schedule-456',
          startTime: testStartTime,
          endTime: testEndTime,
          title: 'School Pickup',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );
        timeSlot2 = TimeSlot(
          id: 'timeslot-123',
          scheduleId: 'schedule-456',
          startTime: testStartTime,
          endTime: testEndTime,
          title: 'School Pickup',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );
      });

      test('should be equal for identical time slots', () {
        // act & assert
        expect(timeSlot1, equals(timeSlot2));
        expect(timeSlot1.hashCode, equals(timeSlot2.hashCode));
      });

      test('should not be equal for different IDs', () {
        // arrange
        final differentTimeSlot = timeSlot1.copyWith(id: 'different-id');

        // act & assert
        expect(timeSlot1, isNot(equals(differentTimeSlot)));
      });

      test('should not be equal for different start times', () {
        // arrange
        final differentTimeSlot = timeSlot1.copyWith(
          startTime: DateTime(2024, 3, 15, 10),
        );

        // act & assert
        expect(timeSlot1, isNot(equals(differentTimeSlot)));
      });

      test('should not be equal for different assigned children', () {
        // arrange
        final timeSlotWithChildren = timeSlot1.copyWith(
          assignedChildIds: const ['child-1'],
        );
        final timeSlotWithDifferentChildren = timeSlot1.copyWith(
          assignedChildIds: ['child-2'],
        );

        // act & assert
        expect(
          timeSlotWithChildren,
          isNot(equals(timeSlotWithDifferentChildren)),
        );
      });

      test('should handle null optional fields in equality', () {
        // arrange
        final timeSlotWithNulls = timeSlot1.copyWith();
        final anotherTimeSlotWithNulls = timeSlot1.copyWith();

        // act & assert
        expect(timeSlotWithNulls, equals(anotherTimeSlotWithNulls));
      });
    });

    group('data validation', () {
      late TimeSlot timeSlot;

      setUp(() {
        timeSlot = TimeSlot(
          id: 'timeslot-123',
          scheduleId: 'schedule-456',
          startTime: testStartTime,
          endTime: testEndTime,
          title: 'School Pickup',
          description: 'Daily school pickup routine',
          location: 'Main School Gate',
          assignedChildIds: const ['child-1', 'child-2'],
          assignedVehicleId: 'vehicle-789',
          driverId: 'driver-101',
          isRecurring: true,
          recurrencePattern: 'FREQ=DAILY',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );
      });

      test('should validate basic time slot properties', () {
        // assert
        expect(timeSlot.id, isNotEmpty);
        expect(timeSlot.title, isNotEmpty);
        expect(timeSlot.startTime.isBefore(timeSlot.endTime), isTrue);
      });

      test('should handle optional fields correctly', () {
        // arrange - Create a time slot with null optional fields
        final timeSlotWithNulls = TimeSlot(
          id: timeSlot.id,
          scheduleId: timeSlot.scheduleId,
          startTime: timeSlot.startTime,
          endTime: timeSlot.endTime,
          title: timeSlot.title,
          // description: null (default),
          // location: null (default),
          // assignedVehicleId: null (default),
          // driverId: null (default),
          // recurrencePattern: null (default),
          createdAt: timeSlot.createdAt,
          updatedAt: timeSlot.updatedAt,
        );

        // assert
        expect(timeSlotWithNulls.description, isNull);
        expect(timeSlotWithNulls.location, isNull);
        expect(timeSlotWithNulls.assignedVehicleId, isNull);
        expect(timeSlotWithNulls.driverId, isNull);
        expect(timeSlotWithNulls.recurrencePattern, isNull);
        expect(timeSlotWithNulls.assignedChildIds, equals([]));
        expect(timeSlotWithNulls.isRecurring, equals(false));
        expect(timeSlotWithNulls.isActive, equals(true));
      });

      test('should preserve timestamp precision correctly', () {
        // arrange
        final preciseTime = DateTime(2024, 3, 15, 8, 30, 45, 123, 456);
        final timeSlotWithPreciseTime = timeSlot.copyWith(
          startTime: preciseTime,
          endTime: preciseTime.add(const Duration(hours: 1)),
        );

        // assert - timestamps should be preserved exactly
        expect(
          timeSlotWithPreciseTime.startTime.millisecondsSinceEpoch,
          equals(preciseTime.millisecondsSinceEpoch),
        );
        expect(timeSlotWithPreciseTime.id, equals(timeSlot.id));
      });

      group('validation edge cases', () {
        test('should handle boolean field defaults correctly', () {
          // arrange - create slot with mixed boolean values
          final mixedBooleanSlot = timeSlot.copyWith(
            isRecurring: false,
            isActive: true,
          );

          // assert
          expect(mixedBooleanSlot.isRecurring, equals(false));
          expect(mixedBooleanSlot.isActive, equals(true));
        });
      });
    });

    group('business logic validation', () {
      test(
        'should validate time slots with realistic scheduling scenarios',
        () {
          // arrange & act
          final schoolPickupSlots = [
            TimeSlot(
              id: 'morning-pickup',
              scheduleId: 'schedule-1',
              startTime: DateTime(2024, 3, 15, 8),
              endTime: DateTime(2024, 3, 15, 8, 30),
              title: 'Morning School Pickup',
              location: 'Elementary School',
              assignedChildIds: const ['child-1', 'child-2'],
              assignedVehicleId: 'minivan-1',
              isRecurring: true,
              recurrencePattern: 'FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR',
              createdAt: testCreatedAt,
              updatedAt: testUpdatedAt,
            ),
            TimeSlot(
              id: 'afternoon-dropoff',
              scheduleId: 'schedule-1',
              startTime: DateTime(2024, 3, 15, 15, 30),
              endTime: DateTime(2024, 3, 15, 16),
              title: 'Afternoon School Dropoff',
              location: 'Elementary School',
              assignedChildIds: const ['child-1', 'child-2'],
              assignedVehicleId: 'minivan-1',
              isRecurring: true,
              recurrencePattern: 'FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR',
              createdAt: testCreatedAt,
              updatedAt: testUpdatedAt,
            ),
          ];

          for (final slot in schoolPickupSlots) {
            // assert - should handle realistic scheduling scenarios
            expect(slot.startTime.isBefore(slot.endTime), isTrue);
            expect(slot.assignedChildIds, isNotEmpty);
            expect(slot.assignedVehicleId, isNotNull);
            expect(slot.id, isNotEmpty);
            expect(slot.startTime.isBefore(slot.endTime), isTrue);
          }
        },
      );

      test('should handle edge case scheduling scenarios', () {
        // arrange
        final edgeCaseSlots = [
          // Very short time slot (1 minute)
          TimeSlot(
            id: 'quick-pickup',
            scheduleId: 'schedule-1',
            startTime: DateTime(2024, 3, 15, 8),
            endTime: DateTime(2024, 3, 15, 8, 1),
            title: 'Quick Pickup',
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          ),
          // Long duration time slot (8 hours)
          TimeSlot(
            id: 'all-day-event',
            scheduleId: 'schedule-1',
            startTime: DateTime(2024, 3, 15, 8),
            endTime: DateTime(2024, 3, 15, 16),
            title: 'All Day Field Trip',
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          ),
          // Overnight time slot (crosses midnight)
          TimeSlot(
            id: 'overnight-event',
            scheduleId: 'schedule-1',
            startTime: DateTime(2024, 3, 15, 22),
            endTime: DateTime(2024, 3, 16, 6),
            title: 'Overnight Camp Pickup',
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          ),
        ];

        for (final slot in edgeCaseSlots) {
          // act & assert - should handle edge cases gracefully
          expect(slot.startTime.isBefore(slot.endTime), isTrue);
          expect(slot.id, isNotEmpty);
          expect(slot.startTime.isBefore(slot.endTime), isTrue);
        }
      });

      test(
        'should maintain data integrity through complex transformations',
        () {
          // arrange
          final originalSlot = TimeSlot(
            id: 'timeslot-123',
            scheduleId: 'schedule-456',
            startTime: testStartTime,
            endTime: testEndTime,
            title: 'Original Title',
            assignedChildIds: const ['child-1'],
            assignedVehicleId: 'vehicle-1',
            isRecurring: true,
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          );

          // act - multiple transformations
          final transformed = originalSlot
              .copyWith(title: 'Updated Title')
              .copyWith(assignedChildIds: ['child-1', 'child-2'])
              .copyWith(isRecurring: false)
              .copyWith(title: originalSlot.title);

          // assert - verify selective changes
          expect(transformed.id, equals(originalSlot.id));
          expect(
            transformed.title,
            equals(originalSlot.title),
          ); // Reverted back
          expect(
            transformed.assignedChildIds,
            equals(['child-1', 'child-2']),
          ); // Updated
          expect(
            transformed.assignedVehicleId,
            equals(originalSlot.assignedVehicleId),
          ); // Preserved
          expect(transformed.isRecurring, equals(false)); // Updated
          expect(transformed.startTime, equals(originalSlot.startTime));
          expect(transformed.endTime, equals(originalSlot.endTime));
        },
      );

      test('should handle complex recurrence patterns', () {
        // arrange
        final recurrencePatterns = [
          'FREQ=DAILY',
          'FREQ=WEEKLY;BYDAY=MO,WE,FR',
          'FREQ=MONTHLY;BYMONTHDAY=15',
          'FREQ=YEARLY;BYMONTH=9;BYMONTHDAY=1',
          'FREQ=WEEKLY;INTERVAL=2;BYDAY=TU,TH',
        ];

        for (final pattern in recurrencePatterns) {
          // act
          final timeSlot = TimeSlot(
            id: 'recurring-slot',
            scheduleId: 'schedule-456',
            startTime: testStartTime,
            endTime: testEndTime,
            title: 'Recurring Event',
            isRecurring: true,
            recurrencePattern: pattern,
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          );

          // assert - should handle complex patterns
          expect(timeSlot.recurrencePattern, equals(pattern));
          expect(timeSlot.isRecurring, isTrue);
          expect(timeSlot.id, isNotEmpty);
        }
      });

      test('should handle multiple child assignments', () {
        // arrange
        final largeChildGroup = List.generate(
          20,
          (index) => 'child-${index + 1}',
        );

        // act
        final timeSlot = TimeSlot(
          id: 'large-group-pickup',
          scheduleId: 'schedule-456',
          startTime: testStartTime,
          endTime: testEndTime,
          title: 'Large Group Event',
          assignedChildIds: largeChildGroup,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // assert
        expect(timeSlot.assignedChildIds.length, equals(20));
        expect(timeSlot.assignedChildIds, equals(largeChildGroup));
        expect(timeSlot.id, isNotEmpty);
        expect(timeSlot.assignedChildIds.length, greaterThan(0));
      });
    });
  });
}
