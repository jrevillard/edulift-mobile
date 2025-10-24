import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/features/schedule/domain/usecases/get_weekly_schedule.dart';
import 'package:edulift/core/domain/entities/schedule.dart';
import 'package:edulift/core/domain/entities/family.dart';

import '../../../../test_mocks/test_mocks.dart';

void main() {
  // Setup Mockito dummy values for Result types
  setUpAll(() {
    setupMockFallbacks();
    _provideScheduleDummyValues();
  });

  group('GetWeeklySchedule', () {
    late GetWeeklySchedule usecase;
    late MockGroupScheduleRepository mockRepository;
    late DateTime testDateTime;

    setUp(() {
      mockRepository = MockGroupScheduleRepository();
      usecase = GetWeeklySchedule(mockRepository);
      testDateTime = DateTime(2024, 1, 15, 8, 30);
    });

    group('Construction', () {
      test('should create usecase with repository dependency', () {
        // Arrange & Act
        final usecase = GetWeeklySchedule(mockRepository);

        // Assert
        expect(usecase.repository, equals(mockRepository));
      });
    });

    group('Success Cases', () {
      test(
        'should get weekly schedule successfully with multiple slots',
        () async {
          // Arrange
          final params = GetWeeklyScheduleParams(
            groupId: 'group-123',
            week: '2024-W03',
          );

          final expectedScheduleSlots = [
            ScheduleSlot(
              id: 'slot-monday-morning',
              groupId: 'group-123',
              dayOfWeek: DayOfWeek.monday,
              timeOfDay: TimeOfDayValue.parse('08:00'),
              week: '2024-W03',
              maxVehicles: 2,
              createdAt: testDateTime,
              updatedAt: testDateTime,
              vehicleAssignments: [
                VehicleAssignment(
                  id: 'assignment-1',
                  scheduleSlotId: 'slot-monday-morning',
                  vehicleId: 'vehicle-1',
                  assignedAt: testDateTime,
                  assignedBy: 'user-123',
                  vehicleName: 'Morning Bus',
                  capacity: 20,
                  createdAt: testDateTime,
                  updatedAt: testDateTime,
                  childAssignments: [
                    ChildAssignment.transportation(
                      id: 'child-assignment-1',
                      childId: 'child-1',
                      groupId: 'group-123',
                      scheduleSlotId: 'slot-monday-morning',
                      vehicleAssignmentId: 'assignment-1',
                      assignedAt: testDateTime,
                      status: AssignmentStatus.confirmed,
                      assignmentDate: testDateTime,
                    ),
                  ],
                ),
              ],
            ),
            ScheduleSlot(
              id: 'slot-monday-afternoon',
              groupId: 'group-123',
              dayOfWeek: DayOfWeek.monday,
              timeOfDay: TimeOfDayValue.parse('15:30'),
              week: '2024-W03',
              maxVehicles: 2,
              createdAt: testDateTime,
              updatedAt: testDateTime,
              vehicleAssignments: const [],
            ),
          ];

          when(
            mockRepository.getWeeklySchedule(any, any),
          ).thenAnswer((_) async => Result.ok(expectedScheduleSlots));

          // Act
          final result = await usecase.call(params);

          // Assert
          expect(result.value, equals(expectedScheduleSlots));
          expect(result.value!.length, equals(2));
          expect(result.value![0].vehicleAssignments.length, equals(1));
          expect(result.value![1].vehicleAssignments.length, equals(0));
          verify(
            mockRepository.getWeeklySchedule('group-123', '2024-W03'),
          ).called(1);
        },
      );

      test('should get empty weekly schedule successfully', () async {
        // Arrange
        final params = GetWeeklyScheduleParams(
          groupId: 'group-456',
          week: '2024-W04',
        );

        final expectedScheduleSlots = <ScheduleSlot>[];

        when(
          mockRepository.getWeeklySchedule(any, any),
        ).thenAnswer((_) async => Result.ok(expectedScheduleSlots));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.value, equals(expectedScheduleSlots));
        expect(result.value!.isEmpty, isTrue);
        verify(
          mockRepository.getWeeklySchedule('group-456', '2024-W04'),
        ).called(1);
      });

      test('should get weekly schedule with full capacity slots', () async {
        // Arrange
        final params = GetWeeklyScheduleParams(
          groupId: 'group-789',
          week: '2024-W05',
        );

        final expectedScheduleSlots = [
          ScheduleSlot(
            id: 'slot-full-capacity',
            groupId: 'group-789',
            dayOfWeek: DayOfWeek.wednesday,
            timeOfDay: TimeOfDayValue.parse('08:00'),
            week: '2024-W05',
            maxVehicles: 3,
            createdAt: testDateTime,
            updatedAt: testDateTime,
            vehicleAssignments: [
              VehicleAssignment(
                id: 'assignment-1',
                scheduleSlotId: 'slot-full-capacity',
                vehicleId: 'vehicle-1',
                assignedAt: testDateTime,
                assignedBy: 'user-123',
                vehicleName: 'Vehicle One',
                capacity: 8,
                createdAt: testDateTime,
                updatedAt: testDateTime,
              ),
              VehicleAssignment(
                id: 'assignment-2',
                scheduleSlotId: 'slot-full-capacity',
                vehicleId: 'vehicle-2',
                assignedAt: testDateTime,
                assignedBy: 'user-456',
                vehicleName: 'Vehicle Two',
                capacity: 6,
                createdAt: testDateTime,
                updatedAt: testDateTime,
              ),
              VehicleAssignment(
                id: 'assignment-3',
                scheduleSlotId: 'slot-full-capacity',
                vehicleId: 'vehicle-3',
                assignedAt: testDateTime,
                assignedBy: 'user-789',
                vehicleName: 'Vehicle Three',
                capacity: 4,
                createdAt: testDateTime,
                updatedAt: testDateTime,
              ),
            ],
          ),
        ];

        when(
          mockRepository.getWeeklySchedule(any, any),
        ).thenAnswer((_) async => Result.ok(expectedScheduleSlots));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.value![0].vehicleAssignments.length, equals(3));
        expect(result.value![0].maxVehicles, equals(3));
        verify(
          mockRepository.getWeeklySchedule('group-789', '2024-W05'),
        ).called(1);
      });

      test('should get weekly schedule for different week formats', () async {
        // Arrange
        final weekFormats = ['2024-W01', '2024-W10', '2024-W52', '2025-W01'];

        for (final week in weekFormats) {
          final params = GetWeeklyScheduleParams(
            groupId: 'group-123',
            week: week,
          );

          final expectedScheduleSlots = [
            ScheduleSlot(
              id: 'slot-$week',
              groupId: 'group-123',
              dayOfWeek: DayOfWeek.monday,
              timeOfDay: TimeOfDayValue.parse('08:00'),
              week: week,
              maxVehicles: 2,
              createdAt: testDateTime,
              updatedAt: testDateTime,
              vehicleAssignments: const [],
            ),
          ];

          when(
            mockRepository.getWeeklySchedule('group-123', week),
          ).thenAnswer((_) async => Result.ok(expectedScheduleSlots));

          // Act
          final result = await usecase.call(params);

          // Assert
          expect(result.value![0].week, equals(week));
          verify(mockRepository.getWeeklySchedule('group-123', week)).called(1);
        }
      });
    });

    group('Failure Cases', () {
      test(
        'should return not found failure when group does not exist',
        () async {
          // Arrange
          final params = GetWeeklyScheduleParams(
            groupId: 'non-existent-group',
            week: '2024-W03',
          );

          final failure = ApiFailure.notFound(resource: 'Group');

          when(
            mockRepository.getWeeklySchedule(any, any),
          ).thenAnswer((_) async => Result.err(failure));

          // Act
          final result = await usecase.call(params);

          // Assert
          expect(result.isError, isTrue);
          expect(result.error, equals(failure));
        },
      );

      test(
        'should return validation failure for invalid week format',
        () async {
          // Arrange
          final params = GetWeeklyScheduleParams(
            groupId: 'group-123',
            week: 'invalid-week',
          );

          final failure = ApiFailure.validationError(
            message: 'Invalid week format. Expected format: YYYY-WNN',
          );

          when(
            mockRepository.getWeeklySchedule(any, any),
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
          final params = GetWeeklyScheduleParams(
            groupId: 'restricted-group',
            week: '2024-W03',
          );

          final failure = ApiFailure.unauthorized();

          when(
            mockRepository.getWeeklySchedule(any, any),
          ).thenAnswer((_) async => Result.err(failure));

          // Act
          final result = await usecase.call(params);

          // Assert
          expect(result.isError, isTrue);
          expect(result.error, equals(failure));
        },
      );

      test('should return network failure for connection issues', () async {
        // Arrange
        final params = GetWeeklyScheduleParams(
          groupId: 'group-123',
          week: '2024-W03',
        );

        final failure = ApiFailure.network(
          message: 'Failed to connect to server',
        );

        when(
          mockRepository.getWeeklySchedule(any, any),
        ).thenAnswer((_) async => Result.err(failure));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, equals(failure));
      });

      test('should return server error for internal server issues', () async {
        // Arrange
        final params = GetWeeklyScheduleParams(
          groupId: 'group-123',
          week: '2024-W03',
        );

        final failure = ApiFailure.serverError(
          message: 'Database query failed',
        );

        when(
          mockRepository.getWeeklySchedule(any, any),
        ).thenAnswer((_) async => Result.err(failure));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, equals(failure));
      });
    });

    group('Business Logic Validation', () {
      test('should pass parameters unchanged to repository', () async {
        // Arrange
        final params = GetWeeklyScheduleParams(
          groupId: 'specific-group-id',
          week: '2024-W25',
        );

        final dummyScheduleSlots = <ScheduleSlot>[];

        when(
          mockRepository.getWeeklySchedule(any, any),
        ).thenAnswer((_) async => Result.ok(dummyScheduleSlots));

        // Act
        await usecase.call(params);

        // Assert
        verify(
          mockRepository.getWeeklySchedule('specific-group-id', '2024-W25'),
        ).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test(
        'should handle concurrent weekly schedule requests correctly',
        () async {
          // Arrange
          final params1 = GetWeeklyScheduleParams(
            groupId: 'group-1',
            week: '2024-W03',
          );

          final params2 = GetWeeklyScheduleParams(
            groupId: 'group-2',
            week: '2024-W04',
          );

          final schedule1 = [
            ScheduleSlot(
              id: 'slot-group-1',
              groupId: 'group-1',
              dayOfWeek: DayOfWeek.monday,
              timeOfDay: TimeOfDayValue.parse('08:00'),
              week: '2024-W03',
              maxVehicles: 2,
              createdAt: testDateTime,
              updatedAt: testDateTime,
              vehicleAssignments: const [],
            ),
          ];

          final schedule2 = [
            ScheduleSlot(
              id: 'slot-group-2',
              groupId: 'group-2',
              dayOfWeek: DayOfWeek.tuesday,
              timeOfDay: TimeOfDayValue.parse('09:00'),
              week: '2024-W04',
              maxVehicles: 3,
              createdAt: testDateTime,
              updatedAt: testDateTime,
              vehicleAssignments: const [],
            ),
          ];

          when(
            mockRepository.getWeeklySchedule('group-1', '2024-W03'),
          ).thenAnswer((_) async => Result.ok(schedule1));
          when(
            mockRepository.getWeeklySchedule('group-2', '2024-W04'),
          ).thenAnswer((_) async => Result.ok(schedule2));

          // Act
          final results = await Future.wait([
            usecase.call(params1),
            usecase.call(params2),
          ]);

          // Assert
          expect(results[0].value, equals(schedule1));
          expect(results[1].value, equals(schedule2));
          verify(
            mockRepository.getWeeklySchedule('group-1', '2024-W03'),
          ).called(1);
          verify(
            mockRepository.getWeeklySchedule('group-2', '2024-W04'),
          ).called(1);
        },
      );
    });

    group('Edge Cases', () {
      test('should handle special characters in group IDs', () async {
        // Arrange
        final params = GetWeeklyScheduleParams(
          groupId: 'group-josé-李小明',
          week: '2024-W03',
        );

        final expectedScheduleSlots = [
          ScheduleSlot(
            id: 'slot-international',
            groupId: 'group-josé-李小明',
            dayOfWeek: DayOfWeek.monday,
            timeOfDay: TimeOfDayValue.parse('08:00'),
            week: '2024-W03',
            maxVehicles: 2,
            createdAt: testDateTime,
            updatedAt: testDateTime,
            vehicleAssignments: const [],
          ),
        ];

        when(
          mockRepository.getWeeklySchedule(any, any),
        ).thenAnswer((_) async => Result.ok(expectedScheduleSlots));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.value, equals(expectedScheduleSlots));
        verify(
          mockRepository.getWeeklySchedule('group-josé-李小明', '2024-W03'),
        ).called(1);
      });

      test('should handle very large schedule data', () async {
        // Arrange
        final params = GetWeeklyScheduleParams(
          groupId: 'large-group',
          week: '2024-W03',
        );

        // Generate a large number of schedule slots
        final largeScheduleSlots = List.generate(100, (index) {
          final hour = (index % 10).toString().padLeft(2, '0');
          final minute = ((index * 15) % 60).toString().padLeft(2, '0');
          return ScheduleSlot(
            id: 'slot-$index',
            groupId: 'large-group',
            dayOfWeek: DayOfWeek.monday,
            timeOfDay: TimeOfDayValue.parse('$hour:$minute'),
            week: '2024-W03',
            maxVehicles: index % 5 + 1,
            createdAt: testDateTime,
            updatedAt: testDateTime,
            vehicleAssignments: const [],
          );
        });

        when(
          mockRepository.getWeeklySchedule(any, any),
        ).thenAnswer((_) async => Result.ok(largeScheduleSlots));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.value!.length, equals(100));
        verify(
          mockRepository.getWeeklySchedule('large-group', '2024-W03'),
        ).called(1);
      });

      test('should handle edge case week numbers', () async {
        // Arrange
        final edgeWeeks = ['2024-W01', '2024-W53', '2020-W53', '2021-W52'];

        for (final week in edgeWeeks) {
          final params = GetWeeklyScheduleParams(
            groupId: 'group-123',
            week: week,
          );

          final expectedScheduleSlots = [
            ScheduleSlot(
              id: 'slot-$week',
              groupId: 'group-123',
              dayOfWeek: DayOfWeek.monday,
              timeOfDay: TimeOfDayValue.parse('08:00'),
              week: week,
              maxVehicles: 2,
              createdAt: testDateTime,
              updatedAt: testDateTime,
              vehicleAssignments: const [],
            ),
          ];

          when(
            mockRepository.getWeeklySchedule('group-123', week),
          ).thenAnswer((_) async => Result.ok(expectedScheduleSlots));

          // Act
          final result = await usecase.call(params);

          // Assert
          expect(result.value![0].week, equals(week));
          verify(mockRepository.getWeeklySchedule('group-123', week)).called(1);
        }
      });

      test(
        'should handle schedule slots with mixed vehicle assignment statuses',
        () async {
          // Arrange
          final params = GetWeeklyScheduleParams(
            groupId: 'group-mixed-status',
            week: '2024-W03',
          );

          final expectedScheduleSlots = [
            ScheduleSlot(
              id: 'slot-mixed-status',
              groupId: 'group-mixed-status',
              dayOfWeek: DayOfWeek.wednesday,
              timeOfDay: TimeOfDayValue.parse('14:30'),
              week: '2024-W03',
              maxVehicles: 3,
              createdAt: testDateTime,
              updatedAt: testDateTime,
              vehicleAssignments: [
                VehicleAssignment(
                  id: 'assignment-assigned',
                  scheduleSlotId: 'slot-mixed-status',
                  vehicleId: 'vehicle-1',
                  assignedAt: testDateTime,
                  assignedBy: 'user-123',
                  vehicleName: 'Assigned Vehicle',
                  capacity: 8,
                  createdAt: testDateTime,
                  updatedAt: testDateTime,
                ),
                VehicleAssignment(
                  id: 'assignment-confirmed',
                  scheduleSlotId: 'slot-mixed-status',
                  vehicleId: 'vehicle-2',
                  assignedAt: testDateTime,
                  assignedBy: 'user-456',
                  vehicleName: 'Confirmed Vehicle',
                  capacity: 6,
                  status: VehicleAssignmentStatus.confirmed,
                  createdAt: testDateTime,
                  updatedAt: testDateTime,
                ),
                VehicleAssignment(
                  id: 'assignment-cancelled',
                  scheduleSlotId: 'slot-mixed-status',
                  vehicleId: 'vehicle-3',
                  assignedAt: testDateTime,
                  assignedBy: 'user-789',
                  vehicleName: 'Cancelled Vehicle',
                  capacity: 4,
                  status: VehicleAssignmentStatus.cancelled,
                  createdAt: testDateTime,
                  updatedAt: testDateTime,
                ),
              ],
            ),
          ];

          when(
            mockRepository.getWeeklySchedule(any, any),
          ).thenAnswer((_) async => Result.ok(expectedScheduleSlots));

          // Act
          final result = await usecase.call(params);

          // Assert
          expect(result.value![0].vehicleAssignments.length, equals(3));
          expect(
            result.value![0].vehicleAssignments[0].status,
            equals(VehicleAssignmentStatus.assigned),
          );
          expect(
            result.value![0].vehicleAssignments[1].status,
            equals(VehicleAssignmentStatus.confirmed),
          );
          expect(
            result.value![0].vehicleAssignments[2].status,
            equals(VehicleAssignmentStatus.cancelled),
          );
          verify(
            mockRepository.getWeeklySchedule('group-mixed-status', '2024-W03'),
          ).called(1);
        },
      );
    });

    group('Error Recovery', () {
      test('should handle timeout scenarios gracefully', () async {
        // Arrange
        final params = GetWeeklyScheduleParams(
          groupId: 'group-123',
          week: '2024-W03',
        );

        final failure = ApiFailure.timeout();

        when(
          mockRepository.getWeeklySchedule(any, any),
        ).thenAnswer((_) async => Result.err(failure));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, equals(failure));
      });

      test('should handle cache failures gracefully', () async {
        // Arrange
        final params = GetWeeklyScheduleParams(
          groupId: 'group-123',
          week: '2024-W03',
        );

        final failure = ApiFailure.cacheError(
          message: 'Cache server unavailable',
        );

        when(
          mockRepository.getWeeklySchedule(any, any),
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

  // Dummy ScheduleSlot for Result<List<ScheduleSlot>, ApiFailure>
  final dummyScheduleSlot = ScheduleSlot(
    id: 'dummy-slot-id',
    groupId: 'dummy-group-id',
    dayOfWeek: DayOfWeek.monday,
    timeOfDay: TimeOfDayValue.parse('08:00'),
    week: '2024-W03',
    maxVehicles: 2,
    createdAt: testDateTime,
    updatedAt: testDateTime,
    vehicleAssignments: const [],
  );

  // Dummy VehicleAssignment for tests
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
  provideDummy<Result<List<ScheduleSlot>, ApiFailure>>(
    const Result.ok(<ScheduleSlot>[]),
  );

  provideDummy<Result<VehicleAssignment, Failure>>(
    Result.ok(dummyVehicleAssignment),
  );

  provideDummy(dummyScheduleSlot);
  provideDummy(dummyVehicleAssignment);
}
