import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/features/schedule/domain/usecases/assign_children_to_vehicle.dart';
import 'package:edulift/core/domain/entities/schedule.dart';
import 'package:edulift/core/domain/entities/family.dart';

import '../../../../test_mocks/test_mocks.dart';

void main() {
  // Setup Mockito dummy values for Result types
  setUpAll(() {
    setupMockFallbacks();
    _provideScheduleDummyValues();
  });

  group('AssignChildrenToVehicle', () {
    late AssignChildrenToVehicle usecase;
    late MockGroupScheduleRepository mockRepository;
    late DateTime testDateTime;

    setUp(() {
      mockRepository = MockGroupScheduleRepository();
      usecase = AssignChildrenToVehicle(mockRepository);
      testDateTime = DateTime(2024, 1, 15, 8, 30);
    });

    group('Construction', () {
      test('should create usecase with repository dependency', () {
        // Arrange & Act
        final usecase = AssignChildrenToVehicle(mockRepository);

        // Assert
        expect(usecase.repository, equals(mockRepository));
      });
    });

    group('Success Cases', () {
      test('should assign children to vehicle successfully', () async {
        // Arrange
        final params = AssignChildrenToVehicleParams(
          groupId: 'group-123',
          slotId: 'slot-456',
          vehicleAssignmentId: 'vehicle-assignment-789',
          childIds: ['child-1', 'child-2'],
          week: '2024-W03',
          day: 'Monday',
          time: '08:00',
        );

        final expectedVehicleAssignment = VehicleAssignment(
          id: 'vehicle-assignment-789',
          scheduleSlotId: 'slot-456',
          vehicleId: 'vehicle-123',
          assignedAt: testDateTime,
          assignedBy: 'user-123',
          vehicleName: 'Family Van',
          capacity: 8,
          createdAt: testDateTime,
          updatedAt: testDateTime,
          childAssignments: [
            ChildAssignment.transportation(
              id: 'assignment-1',
              childId: 'child-1',
              groupId: 'group-123',
              scheduleSlotId: 'slot-456',
              vehicleAssignmentId: 'vehicle-assignment-789',
              assignedAt: testDateTime,
              status: AssignmentStatus.confirmed,
              assignmentDate: testDateTime,
            ),
            ChildAssignment.transportation(
              id: 'assignment-2',
              childId: 'child-2',
              groupId: 'group-123',
              scheduleSlotId: 'slot-456',
              vehicleAssignmentId: 'vehicle-assignment-789',
              assignedAt: testDateTime,
              status: AssignmentStatus.confirmed,
              assignmentDate: testDateTime,
            ),
          ],
        );

        when(
          mockRepository.assignChildrenToVehicle(any, any, any, any),
        ).thenAnswer((_) async => Result.ok(expectedVehicleAssignment));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.value, equals(expectedVehicleAssignment));
        expect(result.value!.childAssignments.length, equals(2));
        verify(
          mockRepository.assignChildrenToVehicle(
            'group-123',
            'slot-456',
            'vehicle-assignment-789',
            ['child-1', 'child-2'],
          ),
        ).called(1);
      });

      test('should handle single child assignment', () async {
        // Arrange
        final params = AssignChildrenToVehicleParams(
          groupId: 'group-123',
          slotId: 'slot-456',
          vehicleAssignmentId: 'vehicle-assignment-789',
          childIds: ['child-1'],
          week: '2024-W03',
          day: 'Monday',
          time: '08:00',
        );

        final expectedVehicleAssignment = VehicleAssignment(
          id: 'vehicle-assignment-789',
          scheduleSlotId: 'slot-456',
          vehicleId: 'vehicle-123',
          assignedAt: testDateTime,
          assignedBy: 'user-123',
          vehicleName: 'Small Car',
          capacity: 4,
          createdAt: testDateTime,
          updatedAt: testDateTime,
          childAssignments: [
            ChildAssignment.transportation(
              id: 'assignment-1',
              childId: 'child-1',
              groupId: 'group-123',
              scheduleSlotId: 'slot-456',
              vehicleAssignmentId: 'vehicle-assignment-789',
              assignedAt: testDateTime,
              status: AssignmentStatus.confirmed,
              assignmentDate: testDateTime,
            ),
          ],
        );

        when(
          mockRepository.assignChildrenToVehicle(any, any, any, any),
        ).thenAnswer((_) async => Result.ok(expectedVehicleAssignment));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.value!.childAssignments.length, equals(1));
        verify(
          mockRepository.assignChildrenToVehicle(
            'group-123',
            'slot-456',
            'vehicle-assignment-789',
            ['child-1'],
          ),
        ).called(1);
      });

      test('should handle empty child list gracefully', () async {
        // Arrange
        final params = AssignChildrenToVehicleParams(
          groupId: 'group-123',
          slotId: 'slot-456',
          vehicleAssignmentId: 'vehicle-assignment-789',
          childIds: [],
          week: '2024-W03',
          day: 'Monday',
          time: '08:00',
        );

        final expectedVehicleAssignment = VehicleAssignment(
          id: 'vehicle-assignment-789',
          scheduleSlotId: 'slot-456',
          vehicleId: 'vehicle-123',
          assignedAt: testDateTime,
          assignedBy: 'user-123',
          vehicleName: 'Empty Vehicle',
          capacity: 4,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        when(
          mockRepository.assignChildrenToVehicle(any, any, any, any),
        ).thenAnswer((_) async => Result.ok(expectedVehicleAssignment));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.value!.childAssignments, isEmpty);
        verify(
          mockRepository.assignChildrenToVehicle(
            'group-123',
            'slot-456',
            'vehicle-assignment-789',
            [],
          ),
        ).called(1);
      });
    });

    group('Failure Cases', () {
      test(
        'should return validation failure when vehicle assignment not found',
        () async {
          // Arrange
          final params = AssignChildrenToVehicleParams(
            groupId: 'group-123',
            slotId: 'slot-456',
            vehicleAssignmentId: 'non-existent-assignment',
            childIds: ['child-1'],
            week: '2024-W03',
            day: 'Monday',
            time: '08:00',
          );

          final failure = ApiFailure.notFound(resource: 'Vehicle assignment');

          when(
            mockRepository.assignChildrenToVehicle(any, any, any, any),
          ).thenAnswer((_) async => Result.err(failure));

          // Act
          final result = await usecase.call(params);

          // Assert
          expect(result.isError, isTrue);
          expect(result.error, equals(failure));
        },
      );

      test(
        'should return validation failure when children exceed vehicle capacity',
        () async {
          // Arrange
          final params = AssignChildrenToVehicleParams(
            groupId: 'group-123',
            slotId: 'slot-456',
            vehicleAssignmentId: 'vehicle-assignment-789',
            childIds: ['child-1', 'child-2', 'child-3', 'child-4', 'child-5'],
            week: '2024-W03',
            day: 'Monday',
            time: '08:00',
          );

          final failure = ApiFailure.validationError(
            message: 'Cannot assign 5 children to vehicle with capacity 4',
          );

          when(
            mockRepository.assignChildrenToVehicle(any, any, any, any),
          ).thenAnswer((_) async => Result.err(failure));

          // Act
          final result = await usecase.call(params);

          // Assert
          expect(result.isError, isTrue);
          expect(result.error, equals(failure));
        },
      );

      test(
        'should return unauthorized failure for permission issues',
        () async {
          // Arrange
          final params = AssignChildrenToVehicleParams(
            groupId: 'group-123',
            slotId: 'slot-456',
            vehicleAssignmentId: 'vehicle-assignment-789',
            childIds: ['child-1'],
            week: '2024-W03',
            day: 'Monday',
            time: '08:00',
          );

          final failure = ApiFailure.unauthorized();

          when(
            mockRepository.assignChildrenToVehicle(any, any, any, any),
          ).thenAnswer((_) async => Result.err(failure));

          // Act
          final result = await usecase.call(params);

          // Assert
          expect(result.isError, isTrue);
          expect(result.error, equals(failure));
        },
      );
    });

    group('Business Logic Validation', () {
      test('should pass parameters unchanged to repository', () async {
        // Arrange
        final params = AssignChildrenToVehicleParams(
          groupId: 'specific-group',
          slotId: 'specific-slot',
          vehicleAssignmentId: 'specific-vehicle-assignment',
          childIds: ['specific-child-1', 'specific-child-2'],
          week: '2024-W10',
          day: 'Wednesday',
          time: '15:30',
        );

        final dummyVehicleAssignment = VehicleAssignment(
          id: 'vehicle-assignment-789',
          scheduleSlotId: 'slot-456',
          vehicleId: 'vehicle-123',
          assignedAt: testDateTime,
          assignedBy: 'user-123',
          vehicleName: 'Test Vehicle',
          capacity: 4,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        when(
          mockRepository.assignChildrenToVehicle(any, any, any, any),
        ).thenAnswer((_) async => Result.ok(dummyVehicleAssignment));

        // Act
        await usecase.call(params);

        // Assert
        verify(
          mockRepository.assignChildrenToVehicle(
            'specific-group',
            'specific-slot',
            'specific-vehicle-assignment',
            ['specific-child-1', 'specific-child-2'],
          ),
        ).called(1);
        verifyNoMoreInteractions(mockRepository);
      });
    });
  });
}

/// Extended dummy values specifically for Schedule domain entities
void _provideScheduleDummyValues() {
  final testDateTime = DateTime(2024, 1, 15, 8, 30);

  // Dummy VehicleAssignment for Result<VehicleAssignment, ApiFailure>
  final dummyVehicleAssignment = VehicleAssignment(
    id: 'dummy-vehicle-assignment-id',
    scheduleSlotId: 'dummy-slot-id',
    vehicleId: 'dummy-vehicle-id',
    assignedAt: testDateTime,
    assignedBy: 'dummy-user',
    vehicleName: 'Dummy Vehicle',
    capacity: 4,
    createdAt: testDateTime,
    updatedAt: testDateTime,
  );

  // Dummy ChildAssignment for tests using transportation factory
  final dummyChildAssignment = ChildAssignment.transportation(
    id: 'dummy-child-assignment-id',
    childId: 'dummy-child-id',
    groupId: 'dummy-group-id',
    scheduleSlotId: 'dummy-slot-id',
    vehicleAssignmentId: 'dummy-vehicle-assignment-id',
    assignedAt: testDateTime,
    status: AssignmentStatus.confirmed,
    assignmentDate: testDateTime,
  );

  // Register dummy values for Schedule domain Result types
  provideDummy<Result<VehicleAssignment, Failure>>(
    Result.ok(dummyVehicleAssignment),
  );

  provideDummy(dummyVehicleAssignment);
  provideDummy(dummyChildAssignment);
  provideDummy(AssignmentStatus.confirmed);
}
