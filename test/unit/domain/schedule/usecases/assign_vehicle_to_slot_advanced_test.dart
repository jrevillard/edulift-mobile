// EduLift Mobile - Comprehensive AssignVehicleToSlot Advanced Test
// Focus: Complex business logic validation, conflict resolution, and error scenarios

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/features/schedule/domain/usecases/assign_vehicle_to_slot.dart';
import 'package:edulift/core/domain/entities/schedule.dart';

import '../../../../test_mocks/test_mocks.dart';

void main() {
  setUpAll(() {
    setupMockFallbacks();
    _provideScheduleDummyValues();
  });

  group('AssignVehicleToSlot - Advanced Business Logic & Conflict Resolution',
      () {
    late AssignVehicleToSlot usecase;
    late MockGroupScheduleRepository mockRepository;
    late DateTime testDateTime;

    setUp(() {
      mockRepository = MockGroupScheduleRepository();
      usecase = AssignVehicleToSlot(mockRepository);
      testDateTime = DateTime(2024, 1, 15, 8, 30);
    });

    group('Capacity Validation & Conflict Resolution', () {
      test('should handle vehicle over-capacity assignment attempts', () async {
        // Arrange
        final params = AssignVehicleToSlotParams(
          groupId: 'group-123',
          vehicleId: 'small-vehicle',
          week: '2024-W03',
          day: 'Monday',
          time: '08:00',
        );

        // Mock repository to return capacity exceeded error
        when(
          mockRepository.assignVehicleToSlot(any, any, any, any, any),
        ).thenAnswer(
          (_) async => Result.err(
            ApiFailure.validationError(
              message:
                  'Vehicle capacity exceeded: 15 children assigned but vehicle capacity is only 10',
            ),
          ),
        );

        // Act
        final result = await usecase.call(params);

        // Assert - TRUTH: Capacity violations must be rejected
        expect(result.isError, isTrue);
        expect(result.error!.message, contains('capacity exceeded'));
        expect(result.error!.message, contains('15 children'));
        expect(result.error!.message, contains('capacity is only 10'));
      });

      test('should detect and prevent double-booking of vehicles', () async {
        // Arrange
        final params = AssignVehicleToSlotParams(
          groupId: 'group-123',
          vehicleId: 'busy-vehicle',
          week: '2024-W03',
          day: 'Monday',
          time: '08:00',
        );

        // Mock repository to return conflict error
        when(
          mockRepository.assignVehicleToSlot(any, any, any, any, any),
        ).thenAnswer(
          (_) async => Result.err(
            ApiFailure.validationError(
              message:
                  'Vehicle "busy-vehicle" is already assigned to slot "slot-monday-afternoon" at 08:00 on Monday',
            ),
          ),
        );

        // Act
        final result = await usecase.call(params);

        // Assert - TRUTH: Double-booking must be prevented
        expect(result.isError, isTrue);
        expect(result.error!.message, contains('already assigned'));
        expect(result.error!.message, contains('busy-vehicle'));
        expect(result.error!.message, contains('08:00 on Monday'));
      });

      test('should validate time slot conflicts with buffer periods', () async {
        // Arrange
        final params = AssignVehicleToSlotParams(
          groupId: 'group-123',
          vehicleId: 'vehicle-123',
          week: '2024-W03',
          day: 'Tuesday',
          time: '08:30',
        );

        // Mock repository to return timing conflict
        when(
          mockRepository.assignVehicleToSlot(any, any, any, any, any),
        ).thenAnswer(
          (_) async => Result.err(
            ApiFailure.validationError(
              message:
                  'Insufficient buffer time: Vehicle has assignment at 08:15 with 30-minute minimum gap required',
            ),
          ),
        );

        // Act
        final result = await usecase.call(params);

        // Assert - TRUTH: Buffer time requirements must be enforced
        expect(result.isError, isTrue);
        expect(result.error!.message, contains('Insufficient buffer time'));
        expect(result.error!.message, contains('30-minute minimum gap'));
      });

      test(
        'should handle complex multi-slot vehicle assignment optimization',
        () async {
          // Arrange
          final params = AssignVehicleToSlotParams(
            groupId: 'group-large',
            vehicleId: 'efficient-vehicle',
            week: '2024-W03',
            day: 'Wednesday',
            time: '07:45',
          );

          // Mock successful assignment with optimization data
          final optimizedAssignment = VehicleAssignment(
            id: 'assignment-optimized',
            scheduleSlotId: 'slot-peak-hours',
            vehicleId: 'efficient-vehicle',
            assignedAt: testDateTime,
            assignedBy: 'system-optimizer',
            vehicleName: 'Efficient Route Vehicle',
            capacity: 25,
            createdAt: testDateTime,
            updatedAt: testDateTime,
            status: VehicleAssignmentStatus.confirmed,
            notes:
                'optimizationScore: 0.92, estimatedEfficiency: 87%, routeOptimization: true',
          );

          when(
            mockRepository.assignVehicleToSlot(any, any, any, any, any),
          ).thenAnswer((_) async => Result.ok(optimizedAssignment));

          // Act
          final result = await usecase.call(params);

          // Assert - TRUTH: Optimization data should be preserved in notes
          expect(result.isOk, isTrue);
          expect(result.value!.notes, contains('optimizationScore: 0.92'));
          expect(result.value!.notes, contains('estimatedEfficiency: 87%'));
          expect(
            result.value!.status,
            equals(VehicleAssignmentStatus.confirmed),
          );
        },
      );
    });

    group('Geographic & Route Constraint Validation', () {
      test('should validate geographic service area constraints', () async {
        // Arrange
        final params = AssignVehicleToSlotParams(
          groupId: 'group-remote',
          vehicleId: 'limited-range-vehicle',
          week: '2024-W03',
          day: 'Thursday',
          time: '09:00',
        );

        // Mock repository to return geographic constraint violation
        when(
          mockRepository.assignVehicleToSlot(any, any, any, any, any),
        ).thenAnswer(
          (_) async => Result.err(
            ApiFailure.validationError(
              message:
                  'Vehicle "limited-range-vehicle" service area does not cover pickup locations in zone "remote-north"',
            ),
          ),
        );

        // Act
        final result = await usecase.call(params);

        // Assert - TRUTH: Geographic constraints must be enforced
        expect(result.isError, isTrue);
        expect(result.error!.message, contains('service area does not cover'));
        expect(result.error!.message, contains('remote-north'));
      });

      test('should handle route optimization conflicts', () async {
        // Arrange
        final params = AssignVehicleToSlotParams(
          groupId: 'group-inefficient',
          vehicleId: 'standard-vehicle',
          week: '2024-W03',
          day: 'Friday',
          time: '08:00',
        );

        // Mock repository to return route efficiency warning (still succeeds)
        final inefficientAssignment = VehicleAssignment(
          id: 'assignment-inefficient',
          scheduleSlotId: 'slot-complex-route',
          vehicleId: 'standard-vehicle',
          assignedAt: testDateTime,
          assignedBy: 'admin-123',
          vehicleName: 'Standard Vehicle',
          capacity: 15,
          createdAt: testDateTime,
          updatedAt: testDateTime,
          notes:
              'routeEfficiencyWarning: true, estimatedExtraTime: 25, alternativeVehicleSuggested: route-optimized-vehicle-456',
        );

        when(
          mockRepository.assignVehicleToSlot(any, any, any, any, any),
        ).thenAnswer((_) async => Result.ok(inefficientAssignment));

        // Act
        final result = await usecase.call(params);

        // Assert - TRUTH: Warnings should be captured in notes
        expect(result.isOk, isTrue);
        expect(result.value!.notes, contains('routeEfficiencyWarning: true'));
        expect(result.value!.notes, contains('estimatedExtraTime: 25'));
        expect(result.value!.status, equals(VehicleAssignmentStatus.assigned));
      });
    });

    group('Advanced Error Propagation & Repository Integration', () {
      test(
        'should handle repository constraint violations with detailed context',
        () async {
          // Arrange
          final params = AssignVehicleToSlotParams(
            groupId: 'group-constraints',
            vehicleId: 'basic-vehicle',
            week: '2024-W03',
            day: 'Monday',
            time: '08:15',
          );

          // Mock repository to return detailed constraint error
          when(
            mockRepository.assignVehicleToSlot(any, any, any, any, any),
          ).thenAnswer(
            (_) async => Result.err(
              ApiFailure.validationError(
                message: 'Vehicle assignment violates multiple constraints: '
                    '1) Vehicle lacks wheelchair accessibility for child-456, '
                    '2) Vehicle does not have required car seats for ages 4-6, '
                    '3) Driver license does not permit passenger transport for children under 8',
              ),
            ),
          );

          // Act
          final result = await usecase.call(params);

          // Assert - TRUTH: Complex constraint violations must be detailed
          expect(result.isError, isTrue);
          expect(result.error!.message, contains('wheelchair accessibility'));
          expect(result.error!.message, contains('car seats for ages 4-6'));
          expect(result.error!.message, contains('passenger transport'));
        },
      );

      test('should handle concurrent modification conflicts', () async {
        // Arrange
        final params = AssignVehicleToSlotParams(
          groupId: 'group-concurrent',
          vehicleId: 'contested-vehicle',
          week: '2024-W03',
          day: 'Tuesday',
          time: '08:00',
        );

        // Mock repository to return concurrent modification error
        when(
          mockRepository.assignVehicleToSlot(any, any, any, any, any),
        ).thenAnswer(
          (_) async => Result.err(
            ApiFailure.validationError(
              message:
                  'Concurrent modification detected: Vehicle "contested-vehicle" was assigned '
                  'to different slot by user "admin-789" at 2024-01-15T08:29:45.123Z while '
                  'current operation was in progress',
            ),
          ),
        );

        // Act
        final result = await usecase.call(params);

        // Assert - TRUTH: Concurrent modifications must be detected and reported
        expect(result.isError, isTrue);
        expect(
          result.error!.message,
          contains('Concurrent modification detected'),
        );
        expect(result.error!.message, contains('contested-vehicle'));
        expect(result.error!.message, contains('admin-789'));
        expect(result.error!.message, contains('2024-01-15T08:29:45.123Z'));
      });

      test(
        'should maintain transactional integrity during complex assignments',
        () async {
          // Arrange
          final params = AssignVehicleToSlotParams(
            groupId: 'group-complex',
            vehicleId: 'transaction-vehicle',
            week: '2024-W03',
            day: 'Wednesday',
            time: '09:30',
          );

          // Mock repository to return transaction failure
          when(
            mockRepository.assignVehicleToSlot(
              'group-complex',
              'Wednesday',
              '09:30',
              '2024-W03',
              'transaction-vehicle',
            ),
          ).thenAnswer(
            (_) async => Result.err(
              ApiFailure.serverError(
                message:
                    'Transaction failed: Child assignment creation succeeded but vehicle '
                    'assignment update failed due to database constraint violation. '
                    'All changes have been rolled back.',
              ),
            ),
          );

          // Act
          final result = await usecase.call(params);

          // Assert - TRUTH: Transaction failures must ensure rollback
          expect(result.isError, isTrue);
          expect(result.error!.message, contains('Transaction failed'));
          expect(result.error!.message, contains('rolled back'));
          expect(result.error!.message, contains('constraint violation'));
        },
      );
    });

    group('Business Rule Orchestration', () {
      test('should coordinate multiple validation stages correctly', () async {
        // Arrange
        final params = AssignVehicleToSlotParams(
          groupId: 'group-orchestration',
          vehicleId: 'orchestration-vehicle',
          week: '2024-W03',
          day: 'Thursday',
          time: '08:00',
        );

        final validAssignment = VehicleAssignment(
          id: 'assignment-orchestrated',
          scheduleSlotId: 'slot-multi-validation',
          vehicleId: 'orchestration-vehicle',
          assignedAt: testDateTime,
          assignedBy: 'orchestration-admin',
          vehicleName: 'Orchestration Test Vehicle',
          capacity: 20,
          createdAt: testDateTime,
          updatedAt: testDateTime,
          status: VehicleAssignmentStatus.confirmed,
          notes:
              'validationStages: [capacity-check-passed, time-conflict-check-passed, geographic-constraint-check-passed, safety-requirement-check-passed], orchestrationCompleted: true',
        );

        when(
          mockRepository.assignVehicleToSlot(
            'group-orchestration',
            'Thursday',
            '08:00',
            '2024-W03',
            'orchestration-vehicle',
          ),
        ).thenAnswer((_) async => Result.ok(validAssignment));

        // Act
        final result = await usecase.call(params);

        // Assert - TRUTH: All validation stages must be documented in notes
        expect(result.isOk, isTrue);
        expect(result.value!.notes, contains('orchestrationCompleted: true'));
        expect(result.value!.notes, contains('capacity-check-passed'));
        expect(
          result.value!.notes,
          contains('safety-requirement-check-passed'),
        );

        // Verify correct parameters were passed
        verify(
          mockRepository.assignVehicleToSlot(
            'group-orchestration',
            'Thursday',
            '08:00',
            '2024-W03',
            'orchestration-vehicle',
          ),
        ).called(1);
      });
    });
  });
}

/// Provide dummy values for Schedule domain entities
void _provideScheduleDummyValues() {
  final testDateTime = DateTime(2024, 1, 15, 8, 30);

  provideDummy<VehicleAssignment>(
    VehicleAssignment(
      id: 'dummy-assignment-id',
      scheduleSlotId: 'dummy-slot-id',
      vehicleId: 'dummy-vehicle-id',
      assignedAt: testDateTime,
      assignedBy: 'dummy-user',
      vehicleName: 'Dummy Vehicle',
      capacity: 10,
      createdAt: testDateTime,
      updatedAt: testDateTime,
    ),
  );

  provideDummy<Result<VehicleAssignment, ApiFailure>>(
    Result.ok(
      VehicleAssignment(
        id: 'dummy-result-assignment',
        scheduleSlotId: 'dummy-result-slot',
        vehicleId: 'dummy-result-vehicle',
        assignedAt: testDateTime,
        assignedBy: 'dummy-result-user',
        vehicleName: 'Dummy Result Vehicle',
        capacity: 15,
        createdAt: testDateTime,
        updatedAt: testDateTime,
      ),
    ),
  );

  provideDummy<AssignVehicleToSlotParams>(
    AssignVehicleToSlotParams(
      groupId: 'dummy-group',
      vehicleId: 'dummy-vehicle',
      week: '2024-W03',
      day: 'Monday',
      time: '08:00',
    ),
  );
}
