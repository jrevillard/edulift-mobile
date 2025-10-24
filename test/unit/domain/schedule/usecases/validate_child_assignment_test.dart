import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/features/schedule/domain/usecases/validate_child_assignment.dart';
import 'package:edulift/core/domain/entities/schedule/vehicle_assignment.dart';
import '../../../../test_mocks/test_mocks.dart';

void main() {
  setUpAll(() {
    setupMockFallbacks();
  });

  group('ValidateChildAssignmentUseCase', () {
    late ValidateChildAssignmentUseCase useCase;
    late DateTime testDateTime;

    setUp(() {
      useCase = const ValidateChildAssignmentUseCase();
      testDateTime = DateTime(2025, 10, 9, 8);
    });

    group('effectiveCapacity validation', () {
      test('allows assignment when under capacity', () async {
        // Arrange
        final vehicleAssignment = VehicleAssignment(
          id: 'assignment-1',
          scheduleSlotId: 'slot-1',
          vehicleId: 'vehicle-1',
          assignedAt: testDateTime,
          assignedBy: 'user-1',
          vehicleName: 'School Van',
          capacity: 8,

          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        final params = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: 'child-1',
          currentlyAssignedChildIds: [
            'child-2',
            'child-3',
          ], // 2 assigned out of 8
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isOk, isTrue);
      });

      test('rejects assignment when at capacity', () async {
        // Arrange
        final vehicleAssignment = VehicleAssignment(
          id: 'assignment-1',
          scheduleSlotId: 'slot-1',
          vehicleId: 'vehicle-1',
          assignedAt: testDateTime,
          assignedBy: 'user-1',
          vehicleName: 'School Van',
          capacity: 3,

          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        final params = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: 'child-1',
          currentlyAssignedChildIds: [
            'child-2',
            'child-3',
            'child-4',
          ], // 3/3 full
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isErr, isTrue);
        final failure = result.unwrapErr();
        expect(failure.code, equals('schedule.capacity_exceeded'));
        expect(failure.details?['capacity'], equals(3));
        expect(failure.details?['assigned'], equals(3));
      });

      test('rejects assignment when over capacity', () async {
        // Arrange
        final vehicleAssignment = VehicleAssignment(
          id: 'assignment-1',
          scheduleSlotId: 'slot-1',
          vehicleId: 'vehicle-1',
          assignedAt: testDateTime,
          assignedBy: 'user-1',
          vehicleName: 'School Van',
          capacity: 2,

          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        final params = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: 'child-1',
          currentlyAssignedChildIds: [
            'c-2',
            'c-3',
            'c-4',
          ], // 3 > 2 (somehow over)
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isErr, isTrue);
        final failure = result.unwrapErr();
        expect(failure.code, equals('schedule.capacity_exceeded'));
      });

      test('allows assignment at capacity minus one', () async {
        // Arrange - edge case: one seat remaining
        final vehicleAssignment = VehicleAssignment(
          id: 'assignment-1',
          scheduleSlotId: 'slot-1',
          vehicleId: 'vehicle-1',
          assignedAt: testDateTime,
          assignedBy: 'user-1',
          vehicleName: 'School Van',
          capacity: 5,

          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        final params = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: 'child-new',
          currentlyAssignedChildIds: ['c-1', 'c-2', 'c-3', 'c-4'], // 4/5
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isOk, isTrue);
      });

      test('uses effectiveCapacity when seat override is set', () async {
        // Arrange
        final vehicleAssignment = VehicleAssignment(
          id: 'assignment-1',
          scheduleSlotId: 'slot-1',
          vehicleId: 'vehicle-1',
          assignedAt: testDateTime,
          assignedBy: 'user-1',
          vehicleName: 'Accessible Van',
          capacity: 8,
          seatOverride: 5, // Override to 5 seats (wheelchair accessibility)
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        final params = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: 'child-new',
          currentlyAssignedChildIds: ['c-1', 'c-2', 'c-3', 'c-4'], // 4/5
        );

        // Act
        final result = await useCase(params);

        // Assert
        // Should allow 1 more (4+1 = 5, which equals effectiveCapacity of 5)
        expect(result.isOk, isTrue);
      });

      test(
        'rejects assignment when seat override capacity is reached',
        () async {
          // Arrange
          final vehicleAssignment = VehicleAssignment(
            id: 'assignment-1',
            scheduleSlotId: 'slot-1',
            vehicleId: 'vehicle-1',
            assignedAt: testDateTime,
            assignedBy: 'user-1',
            vehicleName: 'Accessible Van',
            capacity: 8,
            seatOverride: 5, // Override to 5 seats
            createdAt: testDateTime,
            updatedAt: testDateTime,
          );

          final params = ValidateChildAssignmentParams(
            vehicleAssignment: vehicleAssignment,
            childId: 'child-new',
            currentlyAssignedChildIds: [
              'c-1',
              'c-2',
              'c-3',
              'c-4',
              'c-5',
            ], // 5/5 full
          );

          // Act
          final result = await useCase(params);

          // Assert
          expect(result.isErr, isTrue);
          final failure = result.unwrapErr();
          expect(failure.code, equals('schedule.capacity_exceeded'));
          expect(
            failure.details?['capacity'],
            equals(5),
          ); // Should use override
        },
      );

      test(
        'uses seat override correctly when increased above base capacity',
        () async {
          // Arrange - emergency capacity increase
          final vehicleAssignment = VehicleAssignment(
            id: 'assignment-1',
            scheduleSlotId: 'slot-1',
            vehicleId: 'vehicle-1',
            assignedAt: testDateTime,
            assignedBy: 'user-1',
            vehicleName: 'Emergency Van',
            capacity: 7,
            seatOverride: 10, // Temporarily increased for emergency
            createdAt: testDateTime,
            updatedAt: testDateTime,
          );

          final params = ValidateChildAssignmentParams(
            vehicleAssignment: vehicleAssignment,
            childId: 'child-new',
            currentlyAssignedChildIds: List.generate(
              8,
              (i) => 'child-$i',
            ), // 8/10
          );

          // Act
          final result = await useCase(params);

          // Assert
          expect(result.isOk, isTrue); // Should allow (8 < 10)
        },
      );
    });

    group('toggle off behavior', () {
      test(
        'allows unassignment when child already assigned to THIS vehicle',
        () async {
          // Arrange
          final vehicleAssignment = VehicleAssignment(
            id: 'assignment-1',
            scheduleSlotId: 'slot-1',
            vehicleId: 'vehicle-1',
            assignedAt: testDateTime,
            assignedBy: 'user-1',
            vehicleName: 'School Van',
            capacity: 5,
            createdAt: testDateTime,
            updatedAt: testDateTime,
          );

          final params = ValidateChildAssignmentParams(
            vehicleAssignment: vehicleAssignment,
            childId: 'child-1', // This child is IN the list
            currentlyAssignedChildIds: ['child-1', 'child-2', 'child-3'],
          );

          // Act
          final result = await useCase(params);

          // Assert
          // Should allow toggle off (unassignment) even if at capacity
          expect(result.isOk, isTrue);
        },
      );

      test(
        'allows unassignment even when vehicle is at full capacity',
        () async {
          // Arrange
          final vehicleAssignment = VehicleAssignment(
            id: 'assignment-1',
            scheduleSlotId: 'slot-1',
            vehicleId: 'vehicle-1',
            assignedAt: testDateTime,
            assignedBy: 'user-1',
            vehicleName: 'School Van',
            capacity: 3,
            createdAt: testDateTime,
            updatedAt: testDateTime,
          );

          final params = ValidateChildAssignmentParams(
            vehicleAssignment: vehicleAssignment,
            childId: 'child-2', // This child is IN the list
            currentlyAssignedChildIds: [
              'child-1',
              'child-2',
              'child-3',
            ], // Full
          );

          // Act
          final result = await useCase(params);

          // Assert
          expect(result.isOk, isTrue); // Allow toggle off
        },
      );
    });

    group('edge cases', () {
      test('handles zero capacity vehicle correctly', () async {
        // Arrange
        final vehicleAssignment = VehicleAssignment(
          id: 'assignment-1',
          scheduleSlotId: 'slot-1',
          vehicleId: 'vehicle-1',
          assignedAt: testDateTime,
          assignedBy: 'user-1',
          vehicleName: 'Broken Van',
          capacity: 0, // Edge case
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        final params = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: 'child-1',
          currentlyAssignedChildIds: [],
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isErr, isTrue);
        expect(result.unwrapErr().code, equals('schedule.capacity_exceeded'));
      });

      test('handles empty assignment list correctly', () async {
        // Arrange
        final vehicleAssignment = VehicleAssignment(
          id: 'assignment-1',
          scheduleSlotId: 'slot-1',
          vehicleId: 'vehicle-1',
          assignedAt: testDateTime,
          assignedBy: 'user-1',
          vehicleName: 'School Van',
          capacity: 5,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        final params = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: 'child-1',
          currentlyAssignedChildIds: [], // Empty
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isOk, isTrue); // Should allow first assignment
      });

      test('handles single seat vehicle correctly', () async {
        // Arrange
        final vehicleAssignment = VehicleAssignment(
          id: 'assignment-1',
          scheduleSlotId: 'slot-1',
          vehicleId: 'vehicle-1',
          assignedAt: testDateTime,
          assignedBy: 'user-1',
          vehicleName: 'Motorcycle',
          capacity: 1,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        // Test 1: Allow first assignment
        final params1 = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: 'child-1',
          currentlyAssignedChildIds: [],
        );

        final result1 = await useCase(params1);
        expect(result1.isOk, isTrue);

        // Test 2: Reject second assignment
        final params2 = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: 'child-2',
          currentlyAssignedChildIds: ['child-1'], // Already full
        );

        final result2 = await useCase(params2);
        expect(result2.isErr, isTrue);
      });

      test('handles large capacity bus correctly', () async {
        // Arrange
        final vehicleAssignment = VehicleAssignment(
          id: 'assignment-1',
          scheduleSlotId: 'slot-1',
          vehicleId: 'vehicle-1',
          assignedAt: testDateTime,
          assignedBy: 'user-1',
          vehicleName: 'School Bus',
          capacity: 45,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        final params = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: 'child-new',
          currentlyAssignedChildIds: List.generate(
            44,
            (i) => 'child-$i',
          ), // 44/45
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isOk, isTrue); // Should allow last seat
      });

      test('handles seat override set to zero correctly', () async {
        // Arrange
        final vehicleAssignment = VehicleAssignment(
          id: 'assignment-1',
          scheduleSlotId: 'slot-1',
          vehicleId: 'vehicle-1',
          assignedAt: testDateTime,
          assignedBy: 'user-1',
          vehicleName: 'Disabled Van',
          capacity: 8,
          seatOverride: 0, // Temporarily disabled
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        final params = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: 'child-1',
          currentlyAssignedChildIds: [],
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isErr, isTrue); // Should reject (0 capacity)
      });

      test('rejects assignment with negative seat override', () async {
        // Arrange - edge case that should never happen but we test anyway
        final vehicleAssignment = VehicleAssignment(
          id: 'assignment-1',
          scheduleSlotId: 'slot-1',
          vehicleId: 'vehicle-1',
          assignedAt: testDateTime,
          assignedBy: 'user-1',
          vehicleName: 'Invalid Van',
          capacity: 5,
          seatOverride: -1, // Invalid but possible in data
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        final params = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: 'child-1',
          currentlyAssignedChildIds: [],
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isErr, isTrue); // Should reject (negative capacity)
      });
    });

    group('failure details', () {
      test('provides correct capacity details in error', () async {
        // Arrange
        final vehicleAssignment = VehicleAssignment(
          id: 'assignment-1',
          scheduleSlotId: 'slot-1',
          vehicleId: 'vehicle-1',
          assignedAt: testDateTime,
          assignedBy: 'user-1',
          vehicleName: 'School Van',
          capacity: 5,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        final params = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: 'child-new',
          currentlyAssignedChildIds: ['c-1', 'c-2', 'c-3', 'c-4', 'c-5'], // 5/5
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isErr, isTrue);
        final failure = result.unwrapErr();
        expect(failure.code, equals('schedule.capacity_exceeded'));
        expect(failure.details?['capacity'], equals(5));
        expect(failure.details?['assigned'], equals(5));
        expect(failure.details?['available'], equals(0));
      });

      test('provides correct message in capacity error', () async {
        // Arrange
        final vehicleAssignment = VehicleAssignment(
          id: 'assignment-1',
          scheduleSlotId: 'slot-1',
          vehicleId: 'vehicle-1',
          assignedAt: testDateTime,
          assignedBy: 'user-1',
          vehicleName: 'School Van',
          capacity: 3,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        final params = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: 'child-new',
          currentlyAssignedChildIds: ['c-1', 'c-2', 'c-3'], // 3/3
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isErr, isTrue);
        final failure = result.unwrapErr();
        expect(failure.message, contains('Cannot assign child'));
        expect(failure.message, contains('3/3 seats'));
      });
    });

    group('realistic scenarios', () {
      test('handles morning school run scenario', () async {
        // Arrange - typical morning school run with 7-seater van
        final vehicleAssignment = VehicleAssignment(
          id: 'morning-run-assignment',
          scheduleSlotId: 'monday-morning-slot',
          vehicleId: 'family-van-1',
          assignedAt: testDateTime,
          assignedBy: 'parent-coordinator',
          vehicleName: 'Smith Family Van',
          driverName: 'Mrs. Smith',
          capacity: 7,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        // Test adding children one by one
        for (var i = 1; i <= 7; i++) {
          final params = ValidateChildAssignmentParams(
            vehicleAssignment: vehicleAssignment,
            childId: 'child-$i',
            currentlyAssignedChildIds: List.generate(
              i - 1,
              (j) => 'child-${j + 1}',
            ),
          );

          final result = await useCase(params);

          // Assert - should allow all 7 seats
          expect(result.isOk, isTrue, reason: 'Seat $i of 7 should be allowed');
        }

        // Test 8th child (should fail)
        final params8 = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: 'child-8',
          currentlyAssignedChildIds: List.generate(7, (i) => 'child-${i + 1}'),
        );

        final result8 = await useCase(params8);
        expect(result8.isErr, isTrue, reason: '8th child should be rejected');
      });

      test('handles wheelchair accessible van scenario', () async {
        // Arrange - 8-seater van reduced to 5 seats for wheelchair
        final vehicleAssignment = VehicleAssignment(
          id: 'accessible-van-assignment',
          scheduleSlotId: 'tuesday-morning-slot',
          vehicleId: 'accessible-van-1',
          assignedAt: testDateTime,
          assignedBy: 'accessibility-coordinator',
          vehicleName: 'Accessible School Van',
          capacity: 8,
          seatOverride: 5, // Reduced for wheelchair space
          notes: 'Wheelchair accessible configuration',
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        // Should allow 5 children (not 8)
        final params = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: 'child-6',
          currentlyAssignedChildIds: List.generate(5, (i) => 'child-${i + 1}'),
        );

        final result = await useCase(params);

        // Assert - should reject (5 is full with override)
        expect(result.isErr, isTrue);
        expect(result.unwrapErr().details?['capacity'], equals(5));
      });

      test('handles emergency capacity increase scenario', () async {
        // Arrange - emergency situation requiring temporary capacity increase
        final vehicleAssignment = VehicleAssignment(
          id: 'emergency-assignment',
          scheduleSlotId: 'emergency-slot',
          vehicleId: 'emergency-van-1',
          assignedAt: testDateTime,
          assignedBy: 'emergency-coordinator',
          vehicleName: 'Emergency Transport Van',
          capacity: 7,
          seatOverride: 9, // Temporarily increased for emergency
          notes: 'Emergency capacity override approved by principal',
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        // Should allow 9 children (not just 7)
        final params = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: 'child-9',
          currentlyAssignedChildIds: List.generate(8, (i) => 'child-${i + 1}'),
        );

        final result = await useCase(params);

        // Assert - should allow (8 < 9)
        expect(result.isOk, isTrue);
      });

      test('handles child toggling assignment on and off', () async {
        // Arrange
        final vehicleAssignment = VehicleAssignment(
          id: 'assignment-1',
          scheduleSlotId: 'slot-1',
          vehicleId: 'vehicle-1',
          assignedAt: testDateTime,
          assignedBy: 'user-1',
          vehicleName: 'School Van',
          capacity: 5,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        // Scenario: Parent assigns child, then changes mind, then assigns again

        // Step 1: Initial assignment (Alice not in list)
        final step1 = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: 'alice',
          currentlyAssignedChildIds: ['bob', 'charlie'],
        );
        final result1 = await useCase(step1);
        expect(result1.isOk, isTrue); // Should allow

        // Step 2: Toggle off (Alice now in list)
        final step2 = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: 'alice',
          currentlyAssignedChildIds: ['bob', 'charlie', 'alice'],
        );
        final result2 = await useCase(step2);
        expect(result2.isOk, isTrue); // Should allow toggle off

        // Step 3: Assign again (Alice not in list)
        final step3 = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: 'alice',
          currentlyAssignedChildIds: ['bob', 'charlie'],
        );
        final result3 = await useCase(step3);
        expect(result3.isOk, isTrue); // Should allow re-assignment
      });
    });
  });
}
