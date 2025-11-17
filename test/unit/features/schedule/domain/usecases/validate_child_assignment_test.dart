import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/features/schedule/domain/usecases/validate_child_assignment.dart';
import 'package:edulift/features/schedule/domain/failures/schedule_failure.dart';
import 'package:edulift/features/schedule/domain/errors/schedule_error.dart';
import 'package:edulift/core/domain/entities/schedule.dart';

void main() {
  group('ValidateChildAssignmentUseCase', () {
    late ValidateChildAssignmentUseCase usecase;

    setUp(() {
      usecase = const ValidateChildAssignmentUseCase();
    });

    // Helper method to create test VehicleAssignment
    VehicleAssignment createTestVehicleAssignment({
      required String id,
      required int capacity,
      int? seatOverride,
    }) {
      return VehicleAssignment(
        id: id,
        scheduleSlotId: 'slot1',
        vehicleId: 'vehicle1',
        assignedAt: DateTime.now(),
        assignedBy: 'user1',
        vehicleName: 'Test Vehicle',
        capacity: capacity,
        seatOverride: seatOverride,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    group('child already assigned scenarios', () {
      test(
        'should allow assignment when child is already assigned (toggle off scenario)',
        () async {
          // Arrange
          final vehicleAssignment = createTestVehicleAssignment(
            id: 'va1',
            capacity: 4,
          );
          final currentlyAssignedChildIds = ['child1', 'child2', 'child3'];

          final params = ValidateChildAssignmentParams(
            vehicleAssignment: vehicleAssignment,
            childId: 'child2', // Already assigned
            currentlyAssignedChildIds: currentlyAssignedChildIds,
          );

          // Act
          final result = await usecase(params);

          // Assert
          expect(result.isOk, isTrue);
        },
      );

      test(
        'should allow assignment when child is already assigned to full vehicle',
        () async {
          // Arrange
          final vehicleAssignment = createTestVehicleAssignment(
            id: 'va1',
            capacity: 3,
          );
          final currentlyAssignedChildIds = [
            'child1',
            'child2',
            'child3',
          ]; // At capacity

          final params = ValidateChildAssignmentParams(
            vehicleAssignment: vehicleAssignment,
            childId: 'child1', // Already assigned, should allow toggle off
            currentlyAssignedChildIds: currentlyAssignedChildIds,
          );

          // Act
          final result = await usecase(params);

          // Assert
          expect(result.isOk, isTrue);
        },
      );

      test(
        'should allow assignment when child is already assigned with seat override',
        () async {
          // Arrange
          final vehicleAssignment = createTestVehicleAssignment(
            id: 'va1',
            capacity: 6,
            seatOverride: 4, // Reduced capacity
          );
          final currentlyAssignedChildIds = [
            'child1',
            'child2',
            'child3',
            'child4',
          ]; // At override capacity

          final params = ValidateChildAssignmentParams(
            vehicleAssignment: vehicleAssignment,
            childId: 'child3', // Already assigned
            currentlyAssignedChildIds: currentlyAssignedChildIds,
          );

          // Act
          final result = await usecase(params);

          // Assert
          expect(result.isOk, isTrue);
        },
      );
    });

    group('capacity validation scenarios', () {
      test(
        'should allow assignment when vehicle has available capacity',
        () async {
          // Arrange
          final vehicleAssignment = createTestVehicleAssignment(
            id: 'va1',
            capacity: 4,
          );
          final currentlyAssignedChildIds = [
            'child1',
            'child2',
          ]; // 2/4 capacity used

          final params = ValidateChildAssignmentParams(
            vehicleAssignment: vehicleAssignment,
            childId: 'child3', // New assignment
            currentlyAssignedChildIds: currentlyAssignedChildIds,
          );

          // Act
          final result = await usecase(params);

          // Assert
          expect(result.isOk, isTrue);
        },
      );

      test(
        'should allow assignment when vehicle is at exactly capacity-1',
        () async {
          // Arrange
          final vehicleAssignment = createTestVehicleAssignment(
            id: 'va1',
            capacity: 5,
          );
          final currentlyAssignedChildIds = [
            'child1',
            'child2',
            'child3',
            'child4',
          ]; // 4/5 capacity used

          final params = ValidateChildAssignmentParams(
            vehicleAssignment: vehicleAssignment,
            childId: 'child5', // Last available spot
            currentlyAssignedChildIds: currentlyAssignedChildIds,
          );

          // Act
          final result = await usecase(params);

          // Assert
          expect(result.isOk, isTrue);
        },
      );

      test('should allow assignment when vehicle is empty', () async {
        // Arrange
        final vehicleAssignment = createTestVehicleAssignment(
          id: 'va1',
          capacity: 8,
        );
        final currentlyAssignedChildIds = <String>[]; // Empty

        final params = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: 'child1', // First assignment
          currentlyAssignedChildIds: currentlyAssignedChildIds,
        );

        // Act
        final result = await usecase(params);

        // Assert
        expect(result.isOk, isTrue);
      });

      test(
        'should block assignment when vehicle is at full capacity',
        () async {
          // Arrange
          final vehicleAssignment = createTestVehicleAssignment(
            id: 'va1',
            capacity: 3,
          );
          final currentlyAssignedChildIds = [
            'child1',
            'child2',
            'child3',
          ]; // 3/3 capacity used

          final params = ValidateChildAssignmentParams(
            vehicleAssignment: vehicleAssignment,
            childId: 'child4', // New assignment - should be blocked
            currentlyAssignedChildIds: currentlyAssignedChildIds,
          );

          // Act
          final result = await usecase(params);

          // Assert
          expect(result.isErr, isTrue);
          final failure = result.fold((failure) => failure, (success) => null);
          expect(failure, isA<ScheduleFailure>());

          final scheduleFailure = failure as ScheduleFailure;
          expect(scheduleFailure.code, equals('schedule_error'));
          expect(
            scheduleFailure.error,
            equals(ScheduleError.vehicleCapacityExceeded),
          );
          expect(scheduleFailure.details!['capacity'], equals(3));
          expect(scheduleFailure.details!['assigned'], equals(3));
          expect(
            scheduleFailure.message,
            contains('Vehicle is at full capacity'),
          );
          expect(scheduleFailure.details!['available'], equals(0));
        },
      );

      test('should block assignment when vehicle is over capacity', () async {
        // Arrange
        final vehicleAssignment = createTestVehicleAssignment(
          id: 'va1',
          capacity: 2,
        );
        final currentlyAssignedChildIds = [
          'child1',
          'child2',
          'child3',
        ]; // 3/2 capacity (over capacity)

        final params = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: 'child4', // New assignment - should be blocked
          currentlyAssignedChildIds: currentlyAssignedChildIds,
        );

        // Act
        final result = await usecase(params);

        // Assert
        expect(result.isErr, isTrue);
        final failure = result.fold((failure) => failure, (success) => null);
        expect(failure, isA<ScheduleFailure>());

        final scheduleFailure = failure as ScheduleFailure;
        expect(scheduleFailure.code, equals('schedule_error'));
        expect(
          scheduleFailure.error,
          equals(ScheduleError.vehicleCapacityExceeded),
        );
        expect(scheduleFailure.details!['capacity'], equals(2));
        expect(scheduleFailure.details!['assigned'], equals(3));
        expect(
          scheduleFailure.details!['available'],
          equals(-1),
        ); // Over capacity
      });

      test(
        'should block assignment when vehicle capacity is 1 and already assigned',
        () async {
          // Arrange
          final vehicleAssignment = createTestVehicleAssignment(
            id: 'va1',
            capacity: 1,
          );
          final currentlyAssignedChildIds = ['child1']; // 1/1 capacity used

          final params = ValidateChildAssignmentParams(
            vehicleAssignment: vehicleAssignment,
            childId: 'child2', // New assignment - should be blocked
            currentlyAssignedChildIds: currentlyAssignedChildIds,
          );

          // Act
          final result = await usecase(params);

          // Assert
          expect(result.isErr, isTrue);
          final failure = result.fold((failure) => failure, (success) => null);
          expect(failure, isA<ScheduleFailure>());

          final scheduleFailure = failure as ScheduleFailure;
          expect(scheduleFailure.details!['capacity'], equals(1));
          expect(scheduleFailure.details!['assigned'], equals(1));
        },
      );

      test('should block assignment when vehicle capacity is 0', () async {
        // Arrange
        final vehicleAssignment = createTestVehicleAssignment(
          id: 'va1',
          capacity: 0,
        );
        final currentlyAssignedChildIds = <String>[]; // 0/0 capacity used

        final params = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: 'child1', // New assignment - should be blocked
          currentlyAssignedChildIds: currentlyAssignedChildIds,
        );

        // Act
        final result = await usecase(params);

        // Assert
        expect(result.isErr, isTrue);
        final failure = result.fold((failure) => failure, (success) => null);
        expect(failure, isA<ScheduleFailure>());

        final scheduleFailure = failure as ScheduleFailure;
        expect(scheduleFailure.details!['capacity'], equals(0));
        expect(scheduleFailure.details!['assigned'], equals(0));
      });
    });

    group('seat override scenarios', () {
      test('should use seat override when it reduces capacity', () async {
        // Arrange
        final vehicleAssignment = createTestVehicleAssignment(
          id: 'va1',
          capacity: 8,
          seatOverride: 4, // Override reduces capacity
        );
        final currentlyAssignedChildIds = [
          'child1',
          'child2',
          'child3',
          'child4',
        ]; // At override capacity

        final params = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: 'child5', // New assignment - should be blocked
          currentlyAssignedChildIds: currentlyAssignedChildIds,
        );

        // Act
        final result = await usecase(params);

        // Assert
        expect(result.isErr, isTrue);
        final failure = result.fold((failure) => failure, (success) => null);
        final scheduleFailure = failure as ScheduleFailure;
        expect(
          scheduleFailure.details!['capacity'],
          equals(4),
        ); // Should use override, not base capacity
        expect(scheduleFailure.details!['assigned'], equals(4));
      });

      test('should allow assignment within seat override limits', () async {
        // Arrange
        final vehicleAssignment = createTestVehicleAssignment(
          id: 'va1',
          capacity: 8,
          seatOverride: 6, // Override reduces capacity
        );
        final currentlyAssignedChildIds = [
          'child1',
          'child2',
          'child3',
        ]; // 3/6 override capacity used

        final params = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: 'child4', // New assignment - should be allowed
          currentlyAssignedChildIds: currentlyAssignedChildIds,
        );

        // Act
        final result = await usecase(params);

        // Assert
        expect(result.isOk, isTrue);
      });

      test('should use seat override when it increases capacity', () async {
        // Arrange
        final vehicleAssignment = createTestVehicleAssignment(
          id: 'va1',
          capacity: 4,
          seatOverride: 6, // Override increases capacity
        );
        final currentlyAssignedChildIds = [
          'child1',
          'child2',
          'child3',
          'child4',
        ]; // 4/6 override capacity used

        final params = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: 'child5', // New assignment - should be allowed
          currentlyAssignedChildIds: currentlyAssignedChildIds,
        );

        // Act
        final result = await usecase(params);

        // Assert
        expect(result.isOk, isTrue);
      });

      test('should block assignment at seat override capacity', () async {
        // Arrange
        final vehicleAssignment = createTestVehicleAssignment(
          id: 'va1',
          capacity: 4,
          seatOverride: 6, // Override increases capacity
        );
        final currentlyAssignedChildIds = [
          'child1',
          'child2',
          'child3',
          'child4',
          'child5',
          'child6',
        ]; // At override capacity

        final params = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: 'child7', // New assignment - should be blocked
          currentlyAssignedChildIds: currentlyAssignedChildIds,
        );

        // Act
        final result = await usecase(params);

        // Assert
        expect(result.isErr, isTrue);
        final failure = result.fold((failure) => failure, (success) => null);
        final scheduleFailure = failure as ScheduleFailure;
        expect(
          scheduleFailure.details!['capacity'],
          equals(6),
        ); // Should use override
        expect(scheduleFailure.details!['assigned'], equals(6));
      });
    });

    group('edge cases', () {
      test('should handle empty currently assigned list correctly', () async {
        // Arrange
        final vehicleAssignment = createTestVehicleAssignment(
          id: 'va1',
          capacity: 3,
        );
        final currentlyAssignedChildIds = <String>[];

        final params = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: 'child1',
          currentlyAssignedChildIds: currentlyAssignedChildIds,
        );

        // Act
        final result = await usecase(params);

        // Assert
        expect(result.isOk, isTrue);
      });

      test('should handle single child assignment correctly', () async {
        // Arrange
        final vehicleAssignment = createTestVehicleAssignment(
          id: 'va1',
          capacity: 1,
        );
        final currentlyAssignedChildIds = <String>[];

        final params = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: 'child1',
          currentlyAssignedChildIds: currentlyAssignedChildIds,
        );

        // Act
        final result = await usecase(params);

        // Assert
        expect(result.isOk, isTrue);
      });

      test('should handle large capacity vehicles correctly', () async {
        // Arrange
        final vehicleAssignment = createTestVehicleAssignment(
          id: 'va1',
          capacity: 50,
        );
        final currentlyAssignedChildIds = List.generate(
          25,
          (index) => 'child${index + 1}',
        ); // 25/50 capacity

        final params = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: 'child26',
          currentlyAssignedChildIds: currentlyAssignedChildIds,
        );

        // Act
        final result = await usecase(params);

        // Assert
        expect(result.isOk, isTrue);
      });

      test('should block assignment at large capacity', () async {
        // Arrange
        final vehicleAssignment = createTestVehicleAssignment(
          id: 'va1',
          capacity: 50,
        );
        final currentlyAssignedChildIds = List.generate(
          50,
          (index) => 'child${index + 1}',
        ); // 50/50 capacity

        final params = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: 'child51',
          currentlyAssignedChildIds: currentlyAssignedChildIds,
        );

        // Act
        final result = await usecase(params);

        // Assert
        expect(result.isErr, isTrue);
        final failure = result.fold((failure) => failure, (success) => null);
        final scheduleFailure = failure as ScheduleFailure;
        expect(scheduleFailure.details!['capacity'], equals(50));
        expect(scheduleFailure.details!['assigned'], equals(50));
      });

      test('should handle special characters in child IDs correctly', () async {
        // Arrange
        final vehicleAssignment = createTestVehicleAssignment(
          id: 'va1',
          capacity: 4,
        );
        final currentlyAssignedChildIds = ['child-1', 'child_2', 'child.3'];

        final params = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: 'child-4',
          currentlyAssignedChildIds: currentlyAssignedChildIds,
        );

        // Act
        final result = await usecase(params);

        // Assert
        expect(result.isOk, isTrue);
      });

      test(
        'should handle already assigned child with special characters',
        () async {
          // Arrange
          final vehicleAssignment = createTestVehicleAssignment(
            id: 'va1',
            capacity: 4,
          );
          final currentlyAssignedChildIds = [
            'child-special-123',
            'child_normal_456',
          ];

          final params = ValidateChildAssignmentParams(
            vehicleAssignment: vehicleAssignment,
            childId:
                'child-special-123', // Already assigned with special characters
            currentlyAssignedChildIds: currentlyAssignedChildIds,
          );

          // Act
          final result = await usecase(params);

          // Assert
          expect(result.isOk, isTrue);
        },
      );
    });

    group('parameter validation', () {
      test('should handle empty child ID correctly', () async {
        // Arrange
        final vehicleAssignment = createTestVehicleAssignment(
          id: 'va1',
          capacity: 4,
        );
        final currentlyAssignedChildIds = ['child1', 'child2'];

        final params = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: '', // Empty child ID
          currentlyAssignedChildIds: currentlyAssignedChildIds,
        );

        // Act
        final result = await usecase(params);

        // Assert - should treat as new assignment since empty string is not in the list
        expect(result.isOk, isTrue);
      });

      test(
        'should handle null child ID in currently assigned list correctly',
        () async {
          // Arrange
          final vehicleAssignment = createTestVehicleAssignment(
            id: 'va1',
            capacity: 4,
          );
          final currentlyAssignedChildIds = [
            'child1',
            '',
            'child2',
          ]; // Contains empty string

          final params = ValidateChildAssignmentParams(
            vehicleAssignment: vehicleAssignment,
            childId:
                '', // Empty child ID - should match the empty string in the list
            currentlyAssignedChildIds: currentlyAssignedChildIds,
          );

          // Act
          final result = await usecase(params);

          // Assert - should allow since empty string is already in the list
          expect(result.isOk, isTrue);
        },
      );

      test('should handle whitespace-only child IDs correctly', () async {
        // Arrange
        final vehicleAssignment = createTestVehicleAssignment(
          id: 'va1',
          capacity: 4,
        );
        final currentlyAssignedChildIds = [
          '   ',
          'child1',
          'child2',
        ]; // Contains whitespace-only

        final params = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: '   ', // Whitespace-only ID - should match
          currentlyAssignedChildIds: currentlyAssignedChildIds,
        );

        // Act
        final result = await usecase(params);

        // Assert - should allow since whitespace-only string is already in the list
        expect(result.isOk, isTrue);
      });
    });

    group('error message content validation', () {
      test(
        'should include correct capacity information in error message',
        () async {
          // Arrange
          final vehicleAssignment = createTestVehicleAssignment(
            id: 'va1',
            capacity: 5,
          );
          final currentlyAssignedChildIds = [
            'child1',
            'child2',
            'child3',
            'child4',
            'child5',
          ]; // Full

          final params = ValidateChildAssignmentParams(
            vehicleAssignment: vehicleAssignment,
            childId: 'child6',
            currentlyAssignedChildIds: currentlyAssignedChildIds,
          );

          // Act
          final result = await usecase(params);

          // Assert
          expect(result.isErr, isTrue);
          final failure =
              result.fold((failure) => failure, (success) => null)
                  as ScheduleFailure;
          expect(failure.message, contains('Cannot assign child'));
          expect(failure.message, contains('Vehicle is at full capacity'));
          expect(failure.details?['capacity'], equals(5));
          expect(failure.details?['assigned'], equals(5));
          expect(failure.details?['available'], equals(0));
        },
      );

      test(
        'should include overcapacity information in error message',
        () async {
          // Arrange
          final vehicleAssignment = createTestVehicleAssignment(
            id: 'va1',
            capacity: 3,
          );
          final currentlyAssignedChildIds = [
            'child1',
            'child2',
            'child3',
            'child4',
            'child5',
          ]; // Over capacity

          final params = ValidateChildAssignmentParams(
            vehicleAssignment: vehicleAssignment,
            childId: 'child6',
            currentlyAssignedChildIds: currentlyAssignedChildIds,
          );

          // Act
          final result = await usecase(params);

          // Assert
          expect(result.isErr, isTrue);
          final failure =
              result.fold((failure) => failure, (success) => null)
                  as ScheduleFailure;
          expect(failure.message, contains('Cannot assign child'));
          expect(failure.message, contains('Vehicle is at full capacity'));
          expect(failure.details?['capacity'], equals(3));
          expect(failure.details?['assigned'], equals(5));
          expect(failure.details?['available'], equals(-2));
        },
      );

      test(
        'should include seat override information in error message',
        () async {
          // Arrange
          final vehicleAssignment = createTestVehicleAssignment(
            id: 'va1',
            capacity: 10,
            seatOverride: 4, // Override reduces capacity
          );
          final currentlyAssignedChildIds = [
            'child1',
            'child2',
            'child3',
            'child4',
          ]; // At override capacity

          final params = ValidateChildAssignmentParams(
            vehicleAssignment: vehicleAssignment,
            childId: 'child5',
            currentlyAssignedChildIds: currentlyAssignedChildIds,
          );

          // Act
          final result = await usecase(params);

          // Assert
          expect(result.isErr, isTrue);
          final failure =
              result.fold((failure) => failure, (success) => null)
                  as ScheduleFailure;
          expect(
            failure.details?['capacity'],
            equals(4),
          ); // Should use override capacity
          expect(failure.message, contains('Cannot assign child'));
          expect(failure.message, contains('Vehicle is at full capacity'));
        },
      );
    });

    group('performance considerations', () {
      test('should handle large assignment lists efficiently', () async {
        // Arrange
        final vehicleAssignment = createTestVehicleAssignment(
          id: 'va1',
          capacity: 100,
        );
        final currentlyAssignedChildIds = List.generate(
          99,
          (index) => 'child${index + 1}',
        ); // Near capacity

        final params = ValidateChildAssignmentParams(
          vehicleAssignment: vehicleAssignment,
          childId: 'child100',
          currentlyAssignedChildIds: currentlyAssignedChildIds,
        );

        // Act
        final result = await usecase(params);

        // Assert
        expect(result.isOk, isTrue);
      });

      test(
        'should be efficient with already assigned child in large list',
        () async {
          // Arrange
          final vehicleAssignment = createTestVehicleAssignment(
            id: 'va1',
            capacity: 100,
          );
          final currentlyAssignedChildIds = List.generate(
            50,
            (index) => 'child${index + 1}',
          ); // 50/100 capacity

          final params = ValidateChildAssignmentParams(
            vehicleAssignment: vehicleAssignment,
            childId: 'child25', // Already assigned, should find it efficiently
            currentlyAssignedChildIds: currentlyAssignedChildIds,
          );

          // Act
          final result = await usecase(params);

          // Assert
          expect(result.isOk, isTrue);
        },
      );
    });
  });
}
