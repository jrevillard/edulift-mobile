import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/features/schedule/domain/usecases/assign_vehicle_to_slot.dart';
import 'package:edulift/core/domain/entities/schedule.dart';

import '../../../../test_mocks/test_mocks.dart';

void main() {
  // Setup Mockito dummy values for Result types
  setUpAll(() {
    // Initialize timezone database for datetime calculations
    tz.initializeTimeZones();
    setupMockFallbacks();
    _provideScheduleDummyValues();
  });

  group('AssignVehicleToSlot', () {
    late AssignVehicleToSlot usecase;
    late MockGroupScheduleRepository mockRepository;
    late DateTime testDateTime;

    setUp(() {
      mockRepository = MockGroupScheduleRepository();
      usecase = AssignVehicleToSlot(mockRepository);
      testDateTime = DateTime(2024, 1, 15, 8, 30);
    });

    group('Construction', () {
      test('should create usecase with repository dependency', () {
        // Arrange & Act
        final usecase = AssignVehicleToSlot(mockRepository);

        // Assert
        expect(usecase.repository, equals(mockRepository));
      });
    });

    group('Success Cases', () {
      test('should assign vehicle to slot successfully', () async {
        // Arrange
        final params = AssignVehicleToSlotParams(
          groupId: 'group-123',
          day: 'Monday',
          time: '08:00',
          week: '2024-W03',
          vehicleId: 'vehicle-456',
        );

        final expectedVehicleAssignment = VehicleAssignment(
          id: 'vehicle-assignment-789',
          scheduleSlotId: 'slot-generated-123',
          vehicleId: 'vehicle-456',
          assignedAt: testDateTime,
          assignedBy: 'user-123',
          vehicleName: 'Family Van',
          capacity: 8,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        when(
          mockRepository.assignVehicleToSlot(any, any, any, any, any),
        ).thenAnswer((_) async => Result.ok(expectedVehicleAssignment));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.value, equals(expectedVehicleAssignment));
        expect(result.value!.vehicleId, equals('vehicle-456'));
        expect(result.value!.status, equals(VehicleAssignmentStatus.assigned));
        verify(
          mockRepository.assignVehicleToSlot(
            'group-123',
            'Monday',
            '08:00',
            '2024-W03',
            'vehicle-456',
          ),
        ).called(1);
      });
    });

    group('Failure Cases', () {
      test(
        'should return not found failure when vehicle does not exist',
        () async {
          // Arrange
          final params = AssignVehicleToSlotParams(
            groupId: 'group-123',
            day: 'Monday',
            time: '08:00',
            week: '2024-W03',
            vehicleId: 'non-existent-vehicle',
          );

          final failure = ApiFailure.notFound(resource: 'Vehicle');

          when(
            mockRepository.assignVehicleToSlot(any, any, any, any, any),
          ).thenAnswer((_) async => Result.err(failure));

          // Act
          final result = await usecase.call(params);

          // Assert
          expect(result.isError, isTrue);
          expect(result.error, equals(failure));
        },
      );

      test('should return validation failure for invalid time slot', () async {
        // Arrange
        final params = AssignVehicleToSlotParams(
          groupId: 'group-123',
          day: 'Monday',
          time: '25:00', // Invalid time
          week: '2024-W03',
          vehicleId: 'vehicle-456',
        );

        // Act
        final result = await usecase.call(params);

        // Assert
        // The usecase validates datetime BEFORE calling repository
        // Invalid time (25:00) is caught by ScheduleDateTimeService
        expect(result.isError, isTrue);
        expect(result.error!.statusCode, equals(422));
        expect(result.error!.message, contains('Invalid datetime calculation'));
        // Verify repository was NOT called due to validation failure
        verifyNever(
          mockRepository.assignVehicleToSlot(any, any, any, any, any),
        );
      });
    });

    group('Business Logic Validation', () {
      test('should pass parameters unchanged to repository', () async {
        // Arrange
        final params = AssignVehicleToSlotParams(
          groupId: 'specific-group',
          day: 'Friday',
          time: '14:15',
          week: '2024-W10',
          vehicleId: 'specific-vehicle',
        );

        final dummyVehicleAssignment = VehicleAssignment(
          id: 'vehicle-assignment-test',
          scheduleSlotId: 'slot-test',
          vehicleId: 'specific-vehicle',
          assignedAt: testDateTime,
          assignedBy: 'user-123',
          vehicleName: 'Test Vehicle',
          capacity: 4,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        when(
          mockRepository.assignVehicleToSlot(any, any, any, any, any),
        ).thenAnswer((_) async => Result.ok(dummyVehicleAssignment));

        // Act
        await usecase.call(params);

        // Assert
        verify(
          mockRepository.assignVehicleToSlot(
            'specific-group',
            'Friday',
            '14:15',
            '2024-W10',
            'specific-vehicle',
          ),
        ).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should handle concurrent vehicle assignments correctly', () async {
        // Arrange
        final params1 = AssignVehicleToSlotParams(
          groupId: 'group-123',
          day: 'Monday',
          time: '08:00',
          week: '2024-W03',
          vehicleId: 'vehicle-1',
        );

        final params2 = AssignVehicleToSlotParams(
          groupId: 'group-123',
          day: 'Monday',
          time: '15:30',
          week: '2024-W03',
          vehicleId: 'vehicle-2',
        );

        final assignment1 = VehicleAssignment(
          id: 'assignment-1',
          scheduleSlotId: 'slot-morning',
          vehicleId: 'vehicle-1',
          assignedAt: testDateTime,
          assignedBy: 'user-123',
          vehicleName: 'Vehicle 1',
          capacity: 4,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        final assignment2 = VehicleAssignment(
          id: 'assignment-2',
          scheduleSlotId: 'slot-afternoon',
          vehicleId: 'vehicle-2',
          assignedAt: testDateTime,
          assignedBy: 'user-123',
          vehicleName: 'Vehicle 2',
          capacity: 6,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        when(
          mockRepository.assignVehicleToSlot(
            'group-123',
            'Monday',
            '08:00',
            '2024-W03',
            'vehicle-1',
          ),
        ).thenAnswer((_) async => Result.ok(assignment1));

        when(
          mockRepository.assignVehicleToSlot(
            'group-123',
            'Monday',
            '15:30',
            '2024-W03',
            'vehicle-2',
          ),
        ).thenAnswer((_) async => Result.ok(assignment2));

        // Act
        final results = await Future.wait([
          usecase.call(params1),
          usecase.call(params2),
        ]);

        // Assert
        expect(results[0].value, equals(assignment1));
        expect(results[1].value, equals(assignment2));
        verify(
          mockRepository.assignVehicleToSlot(
            'group-123',
            'Monday',
            '08:00',
            '2024-W03',
            'vehicle-1',
          ),
        ).called(1);
        verify(
          mockRepository.assignVehicleToSlot(
            'group-123',
            'Monday',
            '15:30',
            '2024-W03',
            'vehicle-2',
          ),
        ).called(1);
      });
    });

    group('Edge Cases', () {
      test('should handle special characters in IDs', () async {
        // Arrange
        final params = AssignVehicleToSlotParams(
          groupId: 'group-josé-123',
          day: 'Monday',
          time: '08:00',
          week: '2024-W03',
          vehicleId: 'vehicle-李小明',
        );

        final expectedVehicleAssignment = VehicleAssignment(
          id: 'assignment-international',
          scheduleSlotId: 'slot-international',
          vehicleId: 'vehicle-李小明',
          assignedAt: testDateTime,
          assignedBy: 'user-123',
          vehicleName: 'International Vehicle',
          capacity: 4,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        when(
          mockRepository.assignVehicleToSlot(any, any, any, any, any),
        ).thenAnswer((_) async => Result.ok(expectedVehicleAssignment));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.value, equals(expectedVehicleAssignment));
        verify(
          mockRepository.assignVehicleToSlot(
            'group-josé-123',
            'Monday',
            '08:00',
            '2024-W03',
            'vehicle-李小明',
          ),
        ).called(1);
      });

      test('should handle edge case time formats', () async {
        // Arrange
        final params = AssignVehicleToSlotParams(
          groupId: 'group-123',
          day: 'Monday',
          time: '00:00', // Midnight
          week: '2024-W03',
          vehicleId: 'vehicle-456',
        );

        final expectedVehicleAssignment = VehicleAssignment(
          id: 'assignment-midnight',
          scheduleSlotId: 'slot-midnight',
          vehicleId: 'vehicle-456',
          assignedAt: testDateTime,
          assignedBy: 'user-123',
          vehicleName: 'Night Vehicle',
          capacity: 4,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        when(
          mockRepository.assignVehicleToSlot(any, any, any, any, any),
        ).thenAnswer((_) async => Result.ok(expectedVehicleAssignment));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.value, equals(expectedVehicleAssignment));
        verify(
          mockRepository.assignVehicleToSlot(
            'group-123',
            'Monday',
            '00:00',
            '2024-W03',
            'vehicle-456',
          ),
        ).called(1);
      });

      test('should handle different day formats', () async {
        // Arrange
        final testDays = [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday',
        ];
        final assignmentResults = <Result<VehicleAssignment, ApiFailure>>[];

        for (var i = 0; i < testDays.length; i++) {
          final params = AssignVehicleToSlotParams(
            groupId: 'group-123',
            day: testDays[i],
            time: '08:00',
            week: '2024-W03',
            vehicleId: 'vehicle-456',
          );

          final assignment = VehicleAssignment(
            id: 'assignment-${testDays[i].toLowerCase()}',
            scheduleSlotId: 'slot-${testDays[i].toLowerCase()}',
            vehicleId: 'vehicle-456',
            assignedAt: testDateTime,
            assignedBy: 'user-123',
            vehicleName: '${testDays[i]} Vehicle',
            capacity: 4,
            createdAt: testDateTime,
            updatedAt: testDateTime,
          );

          when(
            mockRepository.assignVehicleToSlot(
              'group-123',
              testDays[i],
              '08:00',
              '2024-W03',
              'vehicle-456',
            ),
          ).thenAnswer((_) async => Result.ok(assignment));

          // Act
          final result = await usecase.call(params);
          assignmentResults.add(result);
        }

        // Assert
        expect(assignmentResults.length, equals(7));
        for (var i = 0; i < testDays.length; i++) {
          expect(assignmentResults[i].isSuccess, isTrue);
          expect(
            assignmentResults[i].value!.vehicleName,
            equals('${testDays[i]} Vehicle'),
          );
          verify(
            mockRepository.assignVehicleToSlot(
              'group-123',
              testDays[i],
              '08:00',
              '2024-W03',
              'vehicle-456',
            ),
          ).called(1);
        }
      });

      test('should handle different week formats', () async {
        // Arrange
        final weekFormats = ['2024-W01', '2024-W10', '2024-W52', '2025-W01'];

        for (final week in weekFormats) {
          final params = AssignVehicleToSlotParams(
            groupId: 'group-123',
            day: 'Monday',
            time: '08:00',
            week: week,
            vehicleId: 'vehicle-456',
          );

          final assignment = VehicleAssignment(
            id: 'assignment-$week',
            scheduleSlotId: 'slot-$week',
            vehicleId: 'vehicle-456',
            assignedAt: testDateTime,
            assignedBy: 'user-123',
            vehicleName: 'Weekly Vehicle',
            capacity: 4,
            createdAt: testDateTime,
            updatedAt: testDateTime,
          );

          when(
            mockRepository.assignVehicleToSlot(
              'group-123',
              'Monday',
              '08:00',
              week,
              'vehicle-456',
            ),
          ).thenAnswer((_) async => Result.ok(assignment));

          // Act
          final result = await usecase.call(params);

          // Assert
          expect(result.isSuccess, isTrue);
          verify(
            mockRepository.assignVehicleToSlot(
              'group-123',
              'Monday',
              '08:00',
              week,
              'vehicle-456',
            ),
          ).called(1);
        }
      });
    });

    group('Error Recovery', () {
      test('should handle timeout scenarios gracefully', () async {
        // Arrange
        final params = AssignVehicleToSlotParams(
          groupId: 'group-123',
          day: 'Monday',
          time: '08:00',
          week: '2024-W03',
          vehicleId: 'vehicle-456',
        );

        final failure = ApiFailure.timeout();

        when(
          mockRepository.assignVehicleToSlot(any, any, any, any, any),
        ).thenAnswer((_) async => Result.err(failure));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, equals(failure));
      });

      test('should handle server errors gracefully', () async {
        // Arrange
        final params = AssignVehicleToSlotParams(
          groupId: 'group-123',
          day: 'Monday',
          time: '08:00',
          week: '2024-W03',
          vehicleId: 'vehicle-456',
        );

        final failure = ApiFailure.serverError(
          message: 'Database connection failed',
        );

        when(
          mockRepository.assignVehicleToSlot(any, any, any, any, any),
        ).thenAnswer((_) async => Result.err(failure));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, equals(failure));
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

  // Register dummy values for Schedule domain Result types
  provideDummy<Result<VehicleAssignment, Failure>>(
    Result.ok(dummyVehicleAssignment),
  );

  provideDummy(dummyVehicleAssignment);
}
