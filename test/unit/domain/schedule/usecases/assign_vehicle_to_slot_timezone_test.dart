import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/features/schedule/domain/usecases/assign_vehicle_to_slot.dart';
import 'package:edulift/features/schedule/domain/services/schedule_datetime_service.dart';
import 'package:edulift/core/domain/entities/schedule.dart';

import '../../../../test_mocks/test_mocks.dart';

void main() {
  group('AssignVehicleToSlot - Timezone Regression Tests', () {
    late AssignVehicleToSlot usecase;
    late MockGroupScheduleRepository mockRepository;
    late ScheduleDateTimeService mockDateTimeService;
    late DateTime testDateTime;

    setUpAll(() {
      setupMockFallbacks();
      _provideScheduleDummyValues();
    });

    setUp(() {
      mockRepository = MockGroupScheduleRepository();
      mockDateTimeService = const ScheduleDateTimeService();
      usecase = AssignVehicleToSlot(mockRepository, dateTimeService: mockDateTimeService);
      testDateTime = DateTime(2025, 10, 27, 5, 0); // Expected UTC time after fix
    });

    group('Timezone Handling - Regression Tests', () {
      test('should pass correct UTC datetime to repository without timezone conversion', () async {
        // Arrange - This test specifically verifies the timezone bug is fixed
        // User clicks on 07:00 slot in UTC+2 timezone
        // Expected: 07:00 UTC should be passed to repository (no conversion in domain layer)

        final params = AssignVehicleToSlotParams(
          groupId: 'group-123',
          day: 'Monday',
          time: '07:00', // User clicks on 07:00
          week: '2025-W43',
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
        expect(result.isSuccess, isTrue);
        expect(result.value, equals(expectedVehicleAssignment));

        // CRITICAL: Verify repository was called with the exact same parameters
        // No timezone conversion should have happened in the domain layer
        verify(
          mockRepository.assignVehicleToSlot(
            'group-123',
            'Monday',
            '07:00', // Time should remain 07:00 (not converted to 04:00 or 05:00)
            '2025-W43',
            'vehicle-456',
          ),
        ).called(1);
      });

      test('should handle different time slots without timezone conversion', () async {
        // Test multiple time slots to ensure no timezone conversion occurs
        final testCases = [
          {
            'time': '07:00',
            'expectedHour': 7, // Should remain 7, not converted to 4 or 5
          },
          {
            'time': '08:30',
            'expectedHour': 8, // Should remain 8:30, not converted
          },
          {
            'time': '14:00',
            'expectedHour': 14, // Should remain 14, not converted
          },
        ];

        for (final testCase in testCases) {
          // Arrange
          final params = AssignVehicleToSlotParams(
            groupId: 'group-123',
            day: 'Monday',
            time: testCase['time'] as String,
            week: '2025-W43',
            vehicleId: 'vehicle-456',
          );

          final expectedAssignment = VehicleAssignment(
            id: 'assignment-${testCase['time']}',
            scheduleSlotId: 'slot-${testCase['time']}',
            vehicleId: 'vehicle-456',
            assignedAt: testDateTime,
            assignedBy: 'user-123',
            vehicleName: 'Test Vehicle',
            capacity: 4,
            createdAt: testDateTime,
            updatedAt: testDateTime,
          );

          when(
            mockRepository.assignVehicleToSlot(any, any, any, any, any),
          ).thenAnswer((_) async => Result.ok(expectedAssignment));

          // Act
          final result = await usecase.call(params);

          // Assert
          expect(result.isSuccess, isTrue, reason: 'Call should succeed for ${testCase['time']}');

          // Verify the exact time string is passed to repository
          verify(
            mockRepository.assignVehicleToSlot(
              'group-123',
              'Monday',
              testCase['time'] as String, // Should match exactly, no conversion
              '2025-W43',
              'vehicle-456',
            ),
          ).called(1);

          clearInteractions(mockRepository);
        }
      });

      test('should handle different days without timezone conversion', () async {
        // Test different days to ensure consistency
        final testCases = [
          {'day': 'Monday', 'expectedDay': 20},
          {'day': 'Tuesday', 'expectedDay': 21},
          {'day': 'Wednesday', 'expectedDay': 22},
        ];

        for (final testCase in testCases) {
          // Arrange
          final params = AssignVehicleToSlotParams(
            groupId: 'group-123',
            day: testCase['day'] as String,
            time: '10:00',
            week: '2025-W43',
            vehicleId: 'vehicle-456',
          );

          final expectedAssignment = VehicleAssignment(
            id: 'assignment-${testCase['day']}',
            scheduleSlotId: 'slot-${testCase['day']}',
            vehicleId: 'vehicle-456',
            assignedAt: testDateTime,
            assignedBy: 'user-123',
            vehicleName: 'Test Vehicle',
            capacity: 4,
            createdAt: testDateTime,
            updatedAt: testDateTime,
          );

          when(
            mockRepository.assignVehicleToSlot(any, any, any, any, any),
          ).thenAnswer((_) async => Result.ok(expectedAssignment));

          // Act
          final result = await usecase.call(params);

          // Assert
          expect(result.isSuccess, isTrue, reason: 'Call should succeed for ${testCase['day']}');

          // Verify the exact day string is passed to repository
          verify(
            mockRepository.assignVehicleToSlot(
              'group-123',
              testCase['day'] as String, // Should match exactly
              '10:00',
              '2025-W43',
              'vehicle-456',
            ),
          ).called(1);

          clearInteractions(mockRepository);
        }
      });

      test('should validate datetime calculation without timezone conversion', () async {
        // This test verifies that the usecase correctly validates the datetime calculation
        // without applying timezone conversion

        final params = AssignVehicleToSlotParams(
          groupId: 'group-123',
          day: 'Monday',
          time: '07:00',
          week: '2025-W43',
          vehicleId: 'vehicle-456',
        );

        final expectedAssignment = VehicleAssignment(
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
        ).thenAnswer((_) async => Result.ok(expectedAssignment));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isSuccess, isTrue);

        // The usecase should have successfully validated the datetime
        // If timezone conversion was happening incorrectly, this would fail
        verify(mockRepository.assignVehicleToSlot(any, any, any, any, any)).called(1);
      });

      test('should handle validation failure for invalid datetime calculation', () async {
        // Test edge case validation
        final params = AssignVehicleToSlotParams(
          groupId: 'group-123',
          day: 'InvalidDay', // Invalid day
          time: '07:00',
          week: '2025-W43',
          vehicleId: 'vehicle-456',
        );

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, isA<ApiFailure>());
        expect(result.error, isA<ApiFailure>());

        // Repository should NOT be called for invalid parameters
        verifyNever(mockRepository.assignVehicleToSlot(any, any, any, any, any));
      });

      test('should handle boundary case: midnight slot', () async {
        // Test boundary case to ensure no timezone conversion issues
        final params = AssignVehicleToSlotParams(
          groupId: 'group-123',
          day: 'Sunday',
          time: '00:00', // Midnight
          week: '2025-W43',
          vehicleId: 'vehicle-456',
        );

        final expectedAssignment = VehicleAssignment(
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
        ).thenAnswer((_) async => Result.ok(expectedAssignment));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isSuccess, isTrue);

        // Verify midnight is handled correctly without timezone conversion
        verify(
          mockRepository.assignVehicleToSlot(
            'group-123',
            'Sunday',
            '00:00', // Should remain exactly 00:00
            '2025-W43',
            'vehicle-456',
          ),
        ).called(1);
      });
    });

    group('Parameter Validation - Timezone Independent', () {
      test('should validate all required parameters', () async {
        // Test empty groupId
        var params = AssignVehicleToSlotParams(
          groupId: '', // Empty
          day: 'Monday',
          time: '07:00',
          week: '2025-W43',
          vehicleId: 'vehicle-456',
        );

        var result = await usecase.call(params);
        expect(result.isError, isTrue);
        expect(result.error, isA<ApiFailure>());

        // Test empty day
        params = AssignVehicleToSlotParams(
          groupId: 'group-123',
          day: '', // Empty
          time: '07:00',
          week: '2025-W43',
          vehicleId: 'vehicle-456',
        );

        result = await usecase.call(params);
        expect(result.isError, isTrue);
        expect(result.error, isA<ApiFailure>());

        // Test empty time
        params = AssignVehicleToSlotParams(
          groupId: 'group-123',
          day: 'Monday',
          time: '', // Empty
          week: '2025-W43',
          vehicleId: 'vehicle-456',
        );

        result = await usecase.call(params);
        expect(result.isError, isTrue);
        expect(result.error, isA<ApiFailure>());

        // Test empty week
        params = AssignVehicleToSlotParams(
          groupId: 'group-123',
          day: 'Monday',
          time: '07:00',
          week: '', // Empty
          vehicleId: 'vehicle-456',
        );

        result = await usecase.call(params);
        expect(result.isError, isTrue);
        expect(result.error, isA<ApiFailure>());

        // Test empty vehicleId
        params = AssignVehicleToSlotParams(
          groupId: 'group-123',
          day: 'Monday',
          time: '07:00',
          week: '2025-W43',
          vehicleId: '', // Empty
        );

        result = await usecase.call(params);
        expect(result.isError, isTrue);
        expect(result.error, isA<ApiFailure>());

        // Repository should never be called for invalid parameters
        verifyNever(mockRepository.assignVehicleToSlot(any, any, any, any, any));
      });
    });
  });
}

/// Extended dummy values specifically for Schedule domain entities
void _provideScheduleDummyValues() {
  final testDateTime = DateTime(2025, 10, 27, 5, 0);

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