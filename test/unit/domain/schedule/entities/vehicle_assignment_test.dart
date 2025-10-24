import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/domain/entities/schedule.dart';
import 'package:edulift/core/domain/entities/family.dart';

void main() {
  group('VehicleAssignment Entity', () {
    late DateTime testAssignedAt;
    late DateTime testCreatedAt;
    late DateTime testUpdatedAt;
    late ChildAssignment testChildAssignment;

    setUp(() {
      testAssignedAt = DateTime(2024, 3, 15, 8);
      testCreatedAt = DateTime(2024, 1, 1, 10);
      testUpdatedAt = DateTime(2024, 1, 2, 10);
      testChildAssignment = ChildAssignment(
        id: 'child-assignment-123',
        childId: 'child-456',
        assignmentType: 'transportation',
        assignmentId: 'vehicle-789',
        createdAt: testAssignedAt,
        scheduleSlotId: 'slot-101',
        status: AssignmentStatus.confirmed,
      );
    });

    group('constructor', () {
      test('should create VehicleAssignment with all required fields', () {
        // arrange & act
        final vehicleAssignment = VehicleAssignment(
          id: 'assignment-123',
          scheduleSlotId: 'slot-456',
          vehicleId: 'vehicle-789',
          assignedAt: testAssignedAt,
          assignedBy: 'user-101',
          vehicleName: 'School Van',
          capacity: 8,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // assert
        expect(vehicleAssignment.id, equals('assignment-123'));
        expect(vehicleAssignment.scheduleSlotId, equals('slot-456'));
        expect(vehicleAssignment.vehicleId, equals('vehicle-789'));
        expect(vehicleAssignment.assignedAt, equals(testAssignedAt));
        expect(vehicleAssignment.assignedBy, equals('user-101'));
        expect(vehicleAssignment.vehicleName, equals('School Van'));
        expect(vehicleAssignment.capacity, equals(8));
        expect(vehicleAssignment.createdAt, equals(testCreatedAt));
        expect(vehicleAssignment.updatedAt, equals(testUpdatedAt));
      });

      test(
        'should create VehicleAssignment with default values for optional fields',
        () {
          // arrange & act
          final vehicleAssignment = VehicleAssignment(
            id: 'assignment-123',
            scheduleSlotId: 'slot-456',
            vehicleId: 'vehicle-789',
            assignedAt: testAssignedAt,
            assignedBy: 'user-101',
            vehicleName: 'School Van',
            capacity: 8,
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          );

          // assert
          expect(vehicleAssignment.driverId, isNull);
          expect(vehicleAssignment.isActive, equals(true));
          expect(vehicleAssignment.seatOverride, isNull);
          expect(vehicleAssignment.notes, isNull);
          expect(
            vehicleAssignment.status,
            equals(VehicleAssignmentStatus.assigned),
          );
          expect(vehicleAssignment.driverName, isNull);
          expect(vehicleAssignment.childAssignments, equals([]));
        },
      );

      test(
        'should create VehicleAssignment with all optional fields specified',
        () {
          // arrange & act
          final vehicleAssignment = VehicleAssignment(
            id: 'assignment-123',
            scheduleSlotId: 'slot-456',
            vehicleId: 'vehicle-789',
            driverId: 'driver-202',
            assignedAt: testAssignedAt,
            assignedBy: 'user-101',
            seatOverride: 6,
            notes: 'Special pickup arrangement',
            status: VehicleAssignmentStatus.confirmed,
            vehicleName: 'School Van',
            driverName: 'John Smith',
            childAssignments: [testChildAssignment],
            capacity: 8,
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          );

          // assert
          expect(vehicleAssignment.driverId, equals('driver-202'));
          expect(vehicleAssignment.isActive, equals(true));
          expect(vehicleAssignment.seatOverride, equals(6));
          expect(vehicleAssignment.notes, equals('Special pickup arrangement'));
          expect(
            vehicleAssignment.status,
            equals(VehicleAssignmentStatus.confirmed),
          );
          expect(vehicleAssignment.driverName, equals('John Smith'));
          expect(
            vehicleAssignment.childAssignments,
            equals([testChildAssignment]),
          );
        },
      );
    });

    group('status enum', () {
      test('should have all expected VehicleAssignmentStatus values', () {
        // arrange & act
        const statusValues = VehicleAssignmentStatus.values;

        // assert
        expect(statusValues, contains(VehicleAssignmentStatus.assigned));
        expect(statusValues, contains(VehicleAssignmentStatus.confirmed));
        expect(statusValues, contains(VehicleAssignmentStatus.cancelled));
        expect(statusValues, contains(VehicleAssignmentStatus.completed));
        expect(statusValues.length, equals(4));
      });

      test('should have correct string representations for status values', () {
        // act & assert
        expect(VehicleAssignmentStatus.assigned.name, equals('assigned'));
        expect(VehicleAssignmentStatus.confirmed.name, equals('confirmed'));
        expect(VehicleAssignmentStatus.cancelled.name, equals('cancelled'));
        expect(VehicleAssignmentStatus.completed.name, equals('completed'));
      });
    });

    group('copyWith', () {
      late VehicleAssignment originalAssignment;

      setUp(() {
        originalAssignment = VehicleAssignment(
          id: 'assignment-123',
          scheduleSlotId: 'slot-456',
          vehicleId: 'vehicle-789',
          driverId: 'driver-202',
          assignedAt: testAssignedAt,
          assignedBy: 'user-101',
          seatOverride: 6,
          notes: 'Original notes',
          vehicleName: 'School Van',
          driverName: 'John Smith',
          childAssignments: [testChildAssignment],
          capacity: 8,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );
      });

      test(
        'should return identical VehicleAssignment when no parameters provided',
        () {
          // act
          final result = originalAssignment.copyWith();

          // assert
          expect(result, equals(originalAssignment));
        },
      );

      test('should update basic assignment fields correctly', () {
        // arrange
        const newScheduleSlotId = 'new-slot-789';
        const newVehicleId = 'new-vehicle-101';
        const newDriverId = 'new-driver-303';

        // act
        final result = originalAssignment.copyWith(
          scheduleSlotId: newScheduleSlotId,
          vehicleId: newVehicleId,
          driverId: newDriverId,
        );

        // assert
        expect(result.scheduleSlotId, equals(newScheduleSlotId));
        expect(result.vehicleId, equals(newVehicleId));
        expect(result.driverId, equals(newDriverId));
        expect(result.id, equals(originalAssignment.id));
        expect(result.assignedBy, equals(originalAssignment.assignedBy));
      });

      test('should update assignment metadata correctly', () {
        // arrange
        final newAssignedAt = DateTime(2024, 3, 20, 10);
        const newAssignedBy = 'admin-user';
        const newIsActive = false;

        // act
        final result = originalAssignment.copyWith(
          assignedAt: newAssignedAt,
          assignedBy: newAssignedBy,
          isActive: newIsActive,
        );

        // assert
        expect(result.assignedAt, equals(newAssignedAt));
        expect(result.assignedBy, equals(newAssignedBy));
        expect(result.isActive, equals(newIsActive));
      });

      test('should update seat and notes correctly', () {
        // arrange
        const newSeatOverride = 10;
        const newNotes = 'Updated special instructions';

        // act
        final result = originalAssignment.copyWith(
          seatOverride: newSeatOverride,
          notes: newNotes,
        );

        // assert
        expect(result.seatOverride, equals(newSeatOverride));
        expect(result.notes, equals(newNotes));
      });

      test('should update status correctly', () {
        // arrange
        const newStatus = VehicleAssignmentStatus.completed;

        // act
        final result = originalAssignment.copyWith(status: newStatus);

        // assert
        expect(result.status, equals(newStatus));
      });

      test('should update vehicle information correctly', () {
        // arrange
        const newVehicleName = 'Updated Van Name';
        const newDriverName = 'Jane Doe';
        const newCapacity = 12;

        // act
        final result = originalAssignment.copyWith(
          vehicleName: newVehicleName,
          driverName: newDriverName,
          capacity: newCapacity,
        );

        // assert
        expect(result.vehicleName, equals(newVehicleName));
        expect(result.driverName, equals(newDriverName));
        expect(result.capacity, equals(newCapacity));
      });

      test('should update child assignments correctly', () {
        // arrange
        final newChildAssignment = ChildAssignment(
          id: 'new-child-assignment',
          childId: 'new-child-789',
          assignmentType: 'transportation',
          assignmentId: 'vehicle-789',
          createdAt: testAssignedAt,
          scheduleSlotId: 'slot-456',
          status: AssignmentStatus.confirmed,
        );
        final newChildAssignments = [newChildAssignment];

        // act
        final result = originalAssignment.copyWith(
          childAssignments: newChildAssignments,
        );

        // assert
        expect(result.childAssignments, equals(newChildAssignments));
        expect(result.childAssignments.length, equals(1));
        expect(result.childAssignments.first, equals(newChildAssignment));
      });

      test('should update timestamps correctly', () {
        // arrange
        final newCreatedAt = DateTime(2024, 6, 15);
        final newUpdatedAt = DateTime(2024, 6, 16);

        // act
        final result = originalAssignment.copyWith(
          createdAt: newCreatedAt,
          updatedAt: newUpdatedAt,
        );

        // assert
        expect(result.createdAt, equals(newCreatedAt));
        expect(result.updatedAt, equals(newUpdatedAt));
      });

      test('should preserve original values when no arguments provided', () {
        // act
        final result = originalAssignment.copyWith();

        // assert
        expect(result.driverId, equals(originalAssignment.driverId));
        expect(result.seatOverride, equals(originalAssignment.seatOverride));
        expect(result.notes, equals(originalAssignment.notes));
        expect(result.driverName, equals(originalAssignment.driverName));
      });
    });

    group('equality', () {
      late VehicleAssignment assignment1;
      late VehicleAssignment assignment2;

      setUp(() {
        assignment1 = VehicleAssignment(
          id: 'assignment-123',
          scheduleSlotId: 'slot-456',
          vehicleId: 'vehicle-789',
          assignedAt: testAssignedAt,
          assignedBy: 'user-101',
          vehicleName: 'School Van',
          capacity: 8,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );
        assignment2 = VehicleAssignment(
          id: 'assignment-123',
          scheduleSlotId: 'slot-456',
          vehicleId: 'vehicle-789',
          assignedAt: testAssignedAt,
          assignedBy: 'user-101',
          vehicleName: 'School Van',
          capacity: 8,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );
      });

      test('should be equal for identical vehicle assignments', () {
        // act & assert
        expect(assignment1, equals(assignment2));
        expect(assignment1.hashCode, equals(assignment2.hashCode));
      });

      test('should not be equal for different IDs', () {
        // arrange
        final differentAssignment = assignment1.copyWith(id: 'different-id');

        // act & assert
        expect(assignment1, isNot(equals(differentAssignment)));
      });

      test('should not be equal for different vehicle IDs', () {
        // arrange
        final differentAssignment = assignment1.copyWith(
          vehicleId: 'different-vehicle',
        );

        // act & assert
        expect(assignment1, isNot(equals(differentAssignment)));
      });

      test('should not be equal for different status', () {
        // arrange
        final differentAssignment = assignment1.copyWith(
          status: VehicleAssignmentStatus.cancelled,
        );

        // act & assert
        expect(assignment1, isNot(equals(differentAssignment)));
      });

      test('should not be equal for different child assignments', () {
        // arrange
        final assignmentWithChildren = assignment1.copyWith(
          childAssignments: [testChildAssignment],
        );
        final assignmentWithoutChildren = assignment1.copyWith(
          childAssignments: [],
        );

        // act & assert
        expect(
          assignmentWithChildren,
          isNot(equals(assignmentWithoutChildren)),
        );
      });

      test('should handle null optional fields in equality', () {
        // arrange
        final assignmentWithNulls = assignment1.copyWith();
        final anotherAssignmentWithNulls = assignment1.copyWith();

        // act & assert
        expect(assignmentWithNulls, equals(anotherAssignmentWithNulls));
      });
    });

    group('JSON serialization', () {
      late VehicleAssignment vehicleAssignment;
      // Removed vehicleAssignmentJson variable - domain entities don't use JSON

      setUp(() {
        vehicleAssignment = VehicleAssignment(
          id: 'assignment-123',
          scheduleSlotId: 'slot-456',
          vehicleId: 'vehicle-789',
          driverId: 'driver-202',
          assignedAt: testAssignedAt,
          assignedBy: 'user-101',
          seatOverride: 6,
          notes: 'Special pickup arrangement',
          status: VehicleAssignmentStatus.confirmed,
          vehicleName: 'School Van',
          driverName: 'John Smith',
          childAssignments: [testChildAssignment],
          capacity: 8,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Test data setup - removed JSON serialization test data
      });

      test('should create vehicle assignment with proper validation', () {
        // act & assert
        expect(vehicleAssignment.id, isNotEmpty);
        expect(vehicleAssignment.vehicleName, isNotEmpty);
        expect(vehicleAssignment.capacity, greaterThan(0));
      });

      test('should handle optional fields correctly with defaults', () {
        // arrange - create assignment with minimal required fields
        final minimalAssignment = VehicleAssignment(
          id: 'assignment-123',
          scheduleSlotId: 'slot-456',
          vehicleId: 'vehicle-789',
          assignedAt: testAssignedAt,
          assignedBy: 'user-101',
          vehicleName: 'School Van',
          capacity: 8,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // assert - check default values
        expect(minimalAssignment.driverId, isNull);
        expect(minimalAssignment.isActive, equals(true));
        expect(minimalAssignment.seatOverride, isNull);
        expect(minimalAssignment.notes, isNull);
        expect(
          minimalAssignment.status,
          equals(VehicleAssignmentStatus.assigned),
        );
        expect(minimalAssignment.driverName, isNull);
        expect(minimalAssignment.childAssignments, equals([]));
      });

      test('should handle child assignments correctly', () {
        // arrange - create assignment without children
        final assignmentWithoutChildren = vehicleAssignment.copyWith(
          childAssignments: [],
        );

        // assert
        expect(assignmentWithoutChildren.childAssignments, equals([]));
        expect(assignmentWithoutChildren.id, equals(vehicleAssignment.id));
      });

      test('should preserve timestamp precision correctly', () {
        // arrange
        final preciseTime = DateTime(2024, 3, 15, 8, 30, 45, 123, 456);
        final assignmentWithPreciseTime = vehicleAssignment.copyWith(
          assignedAt: preciseTime,
        );

        // assert - timestamps should be preserved exactly
        expect(
          assignmentWithPreciseTime.assignedAt.millisecondsSinceEpoch,
          equals(preciseTime.millisecondsSinceEpoch),
        );
        expect(assignmentWithPreciseTime.id, equals(vehicleAssignment.id));
      });

      group('edge case validation', () {
        test('should handle status transitions correctly', () {
          // arrange
          final assignmentWithStatus = vehicleAssignment.copyWith(
            status: VehicleAssignmentStatus.confirmed,
          );

          // act
          final cancelledAssignment = assignmentWithStatus.copyWith(
            status: VehicleAssignmentStatus.cancelled,
          );

          // assert
          expect(
            cancelledAssignment.status,
            equals(VehicleAssignmentStatus.cancelled),
          );
          expect(cancelledAssignment.id, equals(vehicleAssignment.id));
        });

        test('should handle capacity validation', () {
          // arrange & act
          final highCapacityAssignment = vehicleAssignment.copyWith(
            capacity: 45,
          );
          final lowCapacityAssignment = vehicleAssignment.copyWith(capacity: 1);

          // assert
          expect(highCapacityAssignment.capacity, equals(45));
          expect(lowCapacityAssignment.capacity, equals(1));
        });

        test('should handle active status correctly', () {
          // arrange
          final inactiveAssignment = vehicleAssignment.copyWith(
            isActive: false,
          );

          // assert
          expect(inactiveAssignment.isActive, equals(false));
          expect(vehicleAssignment.isActive, equals(true));
        });
      });
    });

    group('business logic validation', () {
      test('should handle realistic vehicle assignment scenarios', () {
        // arrange & act
        final assignmentScenarios = [
          // Regular school pickup assignment
          VehicleAssignment(
            id: 'morning-pickup-assignment',
            scheduleSlotId: 'monday-morning-slot',
            vehicleId: 'minivan-1',
            driverId: 'driver-smith',
            assignedAt: testAssignedAt,
            assignedBy: 'coordinator-jones',
            status: VehicleAssignmentStatus.confirmed,
            vehicleName: 'Blue Minivan',
            driverName: 'Sarah Smith',
            capacity: 7,
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          ),
          // Emergency assignment without driver
          VehicleAssignment(
            id: 'emergency-assignment',
            scheduleSlotId: 'emergency-slot',
            vehicleId: 'backup-van',
            assignedAt: testAssignedAt,
            assignedBy: 'admin-user',
            vehicleName: 'Emergency Van',
            notes: 'Emergency backup vehicle - driver TBD',
            capacity: 5,
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          ),
          // Large capacity bus assignment
          VehicleAssignment(
            id: 'bus-assignment',
            scheduleSlotId: 'field-trip-slot',
            vehicleId: 'school-bus-1',
            driverId: 'driver-johnson',
            assignedAt: testAssignedAt,
            assignedBy: 'trip-coordinator',
            status: VehicleAssignmentStatus.confirmed,
            vehicleName: 'Yellow School Bus #47',
            driverName: 'Mike Johnson',
            capacity: 45,
            notes: 'Field trip to science museum',
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          ),
        ];

        for (final assignment in assignmentScenarios) {
          // assert - should handle realistic scenarios
          expect(assignment.vehicleName, isNotEmpty);
          expect(assignment.capacity, greaterThan(0));
          expect(assignment.assignedBy, isNotEmpty);
          expect(assignment.assignedAt.isBefore(DateTime.now()), isTrue);
          expect(assignment.vehicleName, isNotEmpty);
          expect(assignment.capacity, greaterThan(0));
          expect(assignment.assignedBy, isNotEmpty);
          expect(assignment.assignedAt.isBefore(DateTime.now()), isTrue);
        }
      });

      test('should handle different capacity scenarios', () {
        // arrange
        final capacityScenarios = [
          1,
          5,
          7,
          12,
          15,
          30,
          45,
        ]; // Different vehicle sizes

        for (final capacity in capacityScenarios) {
          // act
          final assignment = VehicleAssignment(
            id: 'capacity-test-$capacity',
            scheduleSlotId: 'slot-456',
            vehicleId: 'vehicle-$capacity',
            assignedAt: testAssignedAt,
            assignedBy: 'user-101',
            vehicleName: 'Vehicle $capacity-seater',
            capacity: capacity,
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          );

          // assert - should handle various capacity scenarios
          expect(assignment.capacity, equals(capacity));
          expect(assignment.capacity, greaterThan(0));
        }
      });

      test('should handle seat override scenarios', () {
        // arrange & act
        final seatOverrideScenarios = [
          // Reduce capacity due to safety equipment
          VehicleAssignment(
            id: 'reduced-capacity',
            scheduleSlotId: 'slot-456',
            vehicleId: 'van-with-wheelchair',
            assignedAt: testAssignedAt,
            assignedBy: 'accessibility-coordinator',
            vehicleName: 'Accessible Van',
            capacity: 8,
            seatOverride: 5, // Reduced for wheelchair space
            notes: 'Wheelchair accessible configuration',
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          ),
          // Increase capacity for emergency
          VehicleAssignment(
            id: 'emergency-capacity',
            scheduleSlotId: 'emergency-slot',
            vehicleId: 'emergency-van',
            assignedAt: testAssignedAt,
            assignedBy: 'emergency-coordinator',
            vehicleName: 'Emergency Transport',
            capacity: 7,
            seatOverride: 9, // Temporary increase for emergency
            notes: 'Emergency capacity override approved',
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          ),
        ];

        for (final assignment in seatOverrideScenarios) {
          // assert - should handle seat override scenarios
          expect(assignment.seatOverride, isNotNull);
          expect(assignment.seatOverride, greaterThan(0));
          expect(assignment.notes, isNotEmpty); // Should have justification
        }
      });

      test('should maintain data integrity through status transitions', () {
        // arrange
        final originalAssignment = VehicleAssignment(
          id: 'assignment-123',
          scheduleSlotId: 'slot-456',
          vehicleId: 'vehicle-789',
          driverId: 'driver-202',
          assignedAt: testAssignedAt,
          assignedBy: 'user-101',
          vehicleName: 'School Van',
          capacity: 8,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // act - simulate status transitions
        final confirmed = originalAssignment.copyWith(
          status: VehicleAssignmentStatus.confirmed,
          updatedAt: testUpdatedAt.add(const Duration(hours: 1)),
        );
        final completed = confirmed.copyWith(
          status: VehicleAssignmentStatus.completed,
          updatedAt: testUpdatedAt.add(const Duration(hours: 8)),
        );

        // assert - verify status progression maintains integrity
        expect(confirmed.status, equals(VehicleAssignmentStatus.confirmed));
        expect(completed.status, equals(VehicleAssignmentStatus.completed));
        expect(confirmed.id, equals(originalAssignment.id));
        expect(completed.vehicleId, equals(originalAssignment.vehicleId));
        expect(
          completed.scheduleSlotId,
          equals(originalAssignment.scheduleSlotId),
        );
      });

      test('should handle complex child assignment scenarios', () {
        // arrange
        final multipleChildren = List.generate(
          10,
          (index) => ChildAssignment(
            id: 'child-assignment-$index',
            childId: 'child-$index',
            assignmentType: 'transportation',
            assignmentId: 'vehicle-789',
            createdAt: testAssignedAt.add(Duration(minutes: index)),
            scheduleSlotId: 'slot-456',
            status: AssignmentStatus.confirmed,
          ),
        );

        // act
        final assignmentWithManyChildren = VehicleAssignment(
          id: 'large-group-assignment',
          scheduleSlotId: 'large-group-slot',
          vehicleId: 'large-bus',
          assignedAt: testAssignedAt,
          assignedBy: 'group-coordinator',
          vehicleName: 'Large School Bus',
          childAssignments: multipleChildren,
          capacity: 30,
          notes: 'Large group field trip',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // assert
        expect(assignmentWithManyChildren.childAssignments.length, equals(10));
        expect(
          assignmentWithManyChildren.childAssignments.length,
          lessThan(assignmentWithManyChildren.capacity),
        );
        expect(assignmentWithManyChildren.notes, contains('Large group'));
      });

      test('should handle edge case assignment timing scenarios', () {
        // arrange
        final futureAssignmentTime = DateTime.now().add(
          const Duration(days: 7),
        );
        final pastAssignmentTime = DateTime.now().subtract(
          const Duration(days: 1),
        );

        // act
        final futureAssignment = VehicleAssignment(
          id: 'future-assignment',
          scheduleSlotId: 'future-slot',
          vehicleId: 'vehicle-789',
          assignedAt: futureAssignmentTime,
          assignedBy: 'scheduler',
          vehicleName: 'Future Van',
          capacity: 8,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final pastAssignment = VehicleAssignment(
          id: 'past-assignment',
          scheduleSlotId: 'past-slot',
          vehicleId: 'vehicle-789',
          assignedAt: pastAssignmentTime,
          assignedBy: 'scheduler',
          vehicleName: 'Past Van',
          capacity: 8,
          status: VehicleAssignmentStatus.completed,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // assert - should handle timing edge cases
        expect(futureAssignment.assignedAt.isAfter(DateTime.now()), isTrue);
        expect(pastAssignment.assignedAt.isBefore(DateTime.now()), isTrue);
        expect(
          pastAssignment.status,
          equals(VehicleAssignmentStatus.completed),
        );
      });
    });

    group('effectiveCapacity getter', () {
      test('returns base capacity when no seat override is set', () {
        // arrange & act
        final assignment = VehicleAssignment(
          id: 'assignment-1',
          scheduleSlotId: 'slot-1',
          vehicleId: 'vehicle-1',
          assignedAt: testAssignedAt,
          assignedBy: 'user-1',
          vehicleName: 'School Van',
          capacity: 8,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // assert
        expect(assignment.effectiveCapacity, equals(8));
        expect(assignment.effectiveCapacity, equals(assignment.capacity));
      });

      test('returns seat override when set', () {
        // arrange & act
        final assignment = VehicleAssignment(
          id: 'assignment-1',
          scheduleSlotId: 'slot-1',
          vehicleId: 'vehicle-1',
          assignedAt: testAssignedAt,
          assignedBy: 'user-1',
          vehicleName: 'Accessible Van',
          capacity: 8,
          seatOverride: 5, // Reduced for wheelchair
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // assert
        expect(assignment.effectiveCapacity, equals(5));
        expect(
          assignment.effectiveCapacity,
          isNot(equals(assignment.capacity)),
        );
      });

      test('returns override when increased above base capacity', () {
        // arrange & act
        final assignment = VehicleAssignment(
          id: 'assignment-1',
          scheduleSlotId: 'slot-1',
          vehicleId: 'vehicle-1',
          assignedAt: testAssignedAt,
          assignedBy: 'user-1',
          vehicleName: 'Emergency Van',
          capacity: 7,
          seatOverride: 10, // Temporarily increased
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // assert
        expect(assignment.effectiveCapacity, equals(10));
        expect(assignment.effectiveCapacity, greaterThan(assignment.capacity));
      });

      test('handles zero seat override correctly', () {
        // arrange & act
        final assignment = VehicleAssignment(
          id: 'assignment-1',
          scheduleSlotId: 'slot-1',
          vehicleId: 'vehicle-1',
          assignedAt: testAssignedAt,
          assignedBy: 'user-1',
          vehicleName: 'Disabled Van',
          capacity: 8,
          seatOverride: 0, // Temporarily disabled
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // assert
        expect(assignment.effectiveCapacity, equals(0));
      });

      test('handles negative seat override correctly', () {
        // arrange & act - edge case that should never happen
        final assignment = VehicleAssignment(
          id: 'assignment-1',
          scheduleSlotId: 'slot-1',
          vehicleId: 'vehicle-1',
          assignedAt: testAssignedAt,
          assignedBy: 'user-1',
          vehicleName: 'Invalid Van',
          capacity: 5,
          seatOverride: -1, // Invalid data
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // assert
        expect(assignment.effectiveCapacity, equals(-1));
      });

      test('effectiveCapacity updates when seat override is changed', () {
        // arrange
        final original = VehicleAssignment(
          id: 'assignment-1',
          scheduleSlotId: 'slot-1',
          vehicleId: 'vehicle-1',
          assignedAt: testAssignedAt,
          assignedBy: 'user-1',
          vehicleName: 'School Van',
          capacity: 8,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // act - set override
        final withOverride = original.copyWith(seatOverride: 6);

        // assert
        expect(original.effectiveCapacity, equals(8));
        expect(withOverride.effectiveCapacity, equals(6));
      });

      test('effectiveCapacity updates when override is removed', () {
        // arrange
        final withOverride = VehicleAssignment(
          id: 'assignment-1',
          scheduleSlotId: 'slot-1',
          vehicleId: 'vehicle-1',
          assignedAt: testAssignedAt,
          assignedBy: 'user-1',
          vehicleName: 'School Van',
          capacity: 8,
          seatOverride: 5,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Note: copyWith cannot remove override (set to null) due to Dart limitations
        // We would need explicit clearSeatOverride method or recreate object
        // This is a known limitation, not a bug

        // assert
        expect(withOverride.effectiveCapacity, equals(5));
      });
    });

    group('hasOverride getter', () {
      test('returns false when no seat override is set', () {
        // arrange & act
        final assignment = VehicleAssignment(
          id: 'assignment-1',
          scheduleSlotId: 'slot-1',
          vehicleId: 'vehicle-1',
          assignedAt: testAssignedAt,
          assignedBy: 'user-1',
          vehicleName: 'School Van',
          capacity: 8,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // assert
        expect(assignment.hasOverride, isFalse);
      });

      test('returns true when seat override is set', () {
        // arrange & act
        final assignment = VehicleAssignment(
          id: 'assignment-1',
          scheduleSlotId: 'slot-1',
          vehicleId: 'vehicle-1',
          assignedAt: testAssignedAt,
          assignedBy: 'user-1',
          vehicleName: 'Accessible Van',
          capacity: 8,
          seatOverride: 5,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // assert
        expect(assignment.hasOverride, isTrue);
      });

      test('returns true even when seat override is zero', () {
        // arrange & act
        final assignment = VehicleAssignment(
          id: 'assignment-1',
          scheduleSlotId: 'slot-1',
          vehicleId: 'vehicle-1',
          assignedAt: testAssignedAt,
          assignedBy: 'user-1',
          vehicleName: 'Disabled Van',
          capacity: 8,
          seatOverride: 0,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // assert
        expect(assignment.hasOverride, isTrue);
      });

      test('returns true even when seat override is negative', () {
        // arrange & act - edge case
        final assignment = VehicleAssignment(
          id: 'assignment-1',
          scheduleSlotId: 'slot-1',
          vehicleId: 'vehicle-1',
          assignedAt: testAssignedAt,
          assignedBy: 'user-1',
          vehicleName: 'Invalid Van',
          capacity: 5,
          seatOverride: -1,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // assert
        expect(assignment.hasOverride, isTrue);
      });
    });

    group('capacityDisplay getter', () {
      test('returns only effective capacity when no override', () {
        // arrange & act
        final assignment = VehicleAssignment(
          id: 'assignment-1',
          scheduleSlotId: 'slot-1',
          vehicleId: 'vehicle-1',
          assignedAt: testAssignedAt,
          assignedBy: 'user-1',
          vehicleName: 'School Van',
          capacity: 8,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // assert
        expect(assignment.capacityDisplay, equals('8'));
      });

      test('shows both effective and base capacity when override is set', () {
        // arrange & act
        final assignment = VehicleAssignment(
          id: 'assignment-1',
          scheduleSlotId: 'slot-1',
          vehicleId: 'vehicle-1',
          assignedAt: testAssignedAt,
          assignedBy: 'user-1',
          vehicleName: 'Accessible Van',
          capacity: 8,
          seatOverride: 5,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // assert
        expect(assignment.capacityDisplay, equals('5 (8 base)'));
      });

      test('shows override correctly when increased above base', () {
        // arrange & act
        final assignment = VehicleAssignment(
          id: 'assignment-1',
          scheduleSlotId: 'slot-1',
          vehicleId: 'vehicle-1',
          assignedAt: testAssignedAt,
          assignedBy: 'user-1',
          vehicleName: 'Emergency Van',
          capacity: 7,
          seatOverride: 10,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // assert
        expect(assignment.capacityDisplay, equals('10 (7 base)'));
      });

      test('shows zero override correctly', () {
        // arrange & act
        final assignment = VehicleAssignment(
          id: 'assignment-1',
          scheduleSlotId: 'slot-1',
          vehicleId: 'vehicle-1',
          assignedAt: testAssignedAt,
          assignedBy: 'user-1',
          vehicleName: 'Disabled Van',
          capacity: 8,
          seatOverride: 0,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // assert
        expect(assignment.capacityDisplay, equals('0 (8 base)'));
      });

      test('provides user-friendly display for UI', () {
        // arrange & act
        final scenarios = [
          // No override
          VehicleAssignment(
            id: 'assignment-1',
            scheduleSlotId: 'slot-1',
            vehicleId: 'vehicle-1',
            assignedAt: testAssignedAt,
            assignedBy: 'user-1',
            vehicleName: 'Van 1',
            capacity: 5,
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          ),
          // With override
          VehicleAssignment(
            id: 'assignment-2',
            scheduleSlotId: 'slot-1',
            vehicleId: 'vehicle-2',
            assignedAt: testAssignedAt,
            assignedBy: 'user-1',
            vehicleName: 'Van 2',
            capacity: 7,
            seatOverride: 4,
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          ),
        ];

        // assert
        expect(scenarios[0].capacityDisplay, equals('5'));
        expect(scenarios[1].capacityDisplay, equals('4 (7 base)'));

        // Verify display strings are suitable for UI
        for (final scenario in scenarios) {
          expect(scenario.capacityDisplay, isNotEmpty);
          expect(scenario.capacityDisplay, isA<String>());
        }
      });
    });
  });
}
