import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import 'package:edulift/features/schedule/domain/usecases/manage_schedule_operations.dart';
import 'package:edulift/core/domain/entities/schedule.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';

import '../../../../test_mocks/test_mocks.dart';

void main() {
  // Setup Mockito dummy values for Result types
  setUpAll(() {
    setupMockFallbacks();
  });

  group('CopyWeeklySchedule', () {
    late CopyWeeklySchedule usecase;
    late MockGroupScheduleRepository mockRepository;

    setUp(() {
      mockRepository = MockGroupScheduleRepository();
      usecase = CopyWeeklySchedule(mockRepository);
    });

    group('Construction', () {
      test('should create usecase with repository dependency', () {
        // Arrange & Act
        final usecase = CopyWeeklySchedule(mockRepository);

        // Assert
        expect(usecase.repository, equals(mockRepository));
      });
    });

    group('Success Cases', () {
      test(
        'should copy weekly schedule successfully with different weeks',
        () async {
          // Arrange
          final params = CopyWeeklyScheduleParams(
            groupId: 'group-123',
            sourceWeek: '2024-W01',
            targetWeek: '2024-W02',
          );

          when(
            mockRepository.copyWeeklySchedule(any, any, any),
          ).thenAnswer((_) async => const Result.ok(null));

          // Act
          final result = await usecase.call(params);

          // Assert
          expect(result.isSuccess, isTrue);
          verify(
            mockRepository.copyWeeklySchedule(
              'group-123',
              '2024-W01',
              '2024-W02',
            ),
          ).called(1);
        },
      );

      test('should handle future week copying', () async {
        // Arrange
        final params = CopyWeeklyScheduleParams(
          groupId: 'group-123',
          sourceWeek: '2024-W10',
          targetWeek: '2024-W20',
        );

        when(
          mockRepository.copyWeeklySchedule(any, any, any),
        ).thenAnswer((_) async => const Result.ok(null));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isSuccess, isTrue);
        verify(
          mockRepository.copyWeeklySchedule(
            'group-123',
            '2024-W10',
            '2024-W20',
          ),
        ).called(1);
      });

      test('should handle past week copying', () async {
        // Arrange
        final params = CopyWeeklyScheduleParams(
          groupId: 'group-123',
          sourceWeek: '2024-W20',
          targetWeek: '2024-W10',
        );

        when(
          mockRepository.copyWeeklySchedule(any, any, any),
        ).thenAnswer((_) async => const Result.ok(null));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isSuccess, isTrue);
        verify(
          mockRepository.copyWeeklySchedule(
            'group-123',
            '2024-W20',
            '2024-W10',
          ),
        ).called(1);
      });
    });

    group('Validation Failures', () {
      test('should fail when source and target weeks are identical', () async {
        // Arrange
        final params = CopyWeeklyScheduleParams(
          groupId: 'group-123',
          sourceWeek: '2024-W01',
          targetWeek: '2024-W01', // Same as source - invalid
        );

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, isTrue);
        expect(
          result.error!.message,
          equals('Source and target weeks must be different'),
        );
        verifyNever(mockRepository.copyWeeklySchedule(any, any, any));
      });
    });

    group('Repository Failure Cases', () {
      test('should return error when repository copy fails', () async {
        // Arrange
        final params = CopyWeeklyScheduleParams(
          groupId: 'group-123',
          sourceWeek: '2024-W01',
          targetWeek: '2024-W02',
        );
        final failure = ApiFailure.serverError(
          message: 'Failed to copy schedule',
        );

        when(
          mockRepository.copyWeeklySchedule(any, any, any),
        ).thenAnswer((_) async => Result.err(failure));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, equals(failure));
      });

      test('should handle source week not found', () async {
        // Arrange
        final params = CopyWeeklyScheduleParams(
          groupId: 'group-123',
          sourceWeek: '2024-W99', // Non-existent week
          targetWeek: '2024-W02',
        );
        final failure = ApiFailure.notFound(resource: 'Source week schedule');

        when(
          mockRepository.copyWeeklySchedule(any, any, any),
        ).thenAnswer((_) async => Result.err(failure));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, equals(failure));
      });

      test('should handle unauthorized copy attempts', () async {
        // Arrange
        final params = CopyWeeklyScheduleParams(
          groupId: 'group-123',
          sourceWeek: '2024-W01',
          targetWeek: '2024-W02',
        );
        final failure = ApiFailure.unauthorized();

        when(
          mockRepository.copyWeeklySchedule(any, any, any),
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
        final params = CopyWeeklyScheduleParams(
          groupId: 'test-group-456',
          sourceWeek: 'test-source-week',
          targetWeek: 'test-target-week',
        );

        when(
          mockRepository.copyWeeklySchedule(any, any, any),
        ).thenAnswer((_) async => const Result.ok(null));

        // Act
        await usecase.call(params);

        // Assert
        verify(
          mockRepository.copyWeeklySchedule(
            'test-group-456',
            'test-source-week',
            'test-target-week',
          ),
        ).called(1);
        verifyNoMoreInteractions(mockRepository);
      });
    });

    group('Edge Cases', () {
      test(
        'should handle empty week strings gracefully (repository should validate)',
        () async {
          // Arrange
          final params = CopyWeeklyScheduleParams(
            groupId: 'group-123',
            sourceWeek: '',
            targetWeek: '2024-W02',
          );
          final failure = ApiFailure.validationError(
            message: 'Invalid source week format',
          );

          when(
            mockRepository.copyWeeklySchedule(any, any, any),
          ).thenAnswer((_) async => Result.err(failure));

          // Act
          final result = await usecase.call(params);

          // Assert
          expect(result.isError, isTrue);
          expect(result.error, equals(failure));
        },
      );
    });
  });

  group('ClearWeeklySchedule', () {
    late ClearWeeklySchedule usecase;
    late MockGroupScheduleRepository mockRepository;

    setUp(() {
      mockRepository = MockGroupScheduleRepository();
      usecase = ClearWeeklySchedule(mockRepository);
    });

    group('Construction', () {
      test('should create usecase with repository dependency', () {
        // Arrange & Act
        final usecase = ClearWeeklySchedule(mockRepository);

        // Assert
        expect(usecase.repository, equals(mockRepository));
      });
    });

    group('Success Cases', () {
      test('should clear weekly schedule successfully', () async {
        // Arrange
        final params = ClearWeeklyScheduleParams(
          groupId: 'group-123',
          week: '2024-W01',
        );

        when(
          mockRepository.clearWeeklySchedule(any, any),
        ).thenAnswer((_) async => const Result.ok(null));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isSuccess, isTrue);
        verify(
          mockRepository.clearWeeklySchedule('group-123', '2024-W01'),
        ).called(1);
      });

      test('should handle clearing future weeks', () async {
        // Arrange
        final params = ClearWeeklyScheduleParams(
          groupId: 'group-123',
          week: '2025-W30',
        );

        when(
          mockRepository.clearWeeklySchedule(any, any),
        ).thenAnswer((_) async => const Result.ok(null));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isSuccess, isTrue);
        verify(
          mockRepository.clearWeeklySchedule('group-123', '2025-W30'),
        ).called(1);
      });
    });

    group('Failure Cases', () {
      test('should return error when repository clear fails', () async {
        // Arrange
        final params = ClearWeeklyScheduleParams(
          groupId: 'group-123',
          week: '2024-W01',
        );
        final failure = ApiFailure.serverError(
          message: 'Failed to clear schedule',
        );

        when(
          mockRepository.clearWeeklySchedule(any, any),
        ).thenAnswer((_) async => Result.err(failure));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, equals(failure));
      });

      test('should handle unauthorized clear attempts', () async {
        // Arrange
        final params = ClearWeeklyScheduleParams(
          groupId: 'group-123',
          week: '2024-W01',
        );
        final failure = ApiFailure.unauthorized();

        when(
          mockRepository.clearWeeklySchedule(any, any),
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
        final params = ClearWeeklyScheduleParams(
          groupId: 'test-group-789',
          week: 'test-week-clear',
        );

        when(
          mockRepository.clearWeeklySchedule(any, any),
        ).thenAnswer((_) async => const Result.ok(null));

        // Act
        await usecase.call(params);

        // Assert
        verify(
          mockRepository.clearWeeklySchedule(
            'test-group-789',
            'test-week-clear',
          ),
        ).called(1);
        verifyNoMoreInteractions(mockRepository);
      });
    });
  });

  group('GetScheduleStatistics', () {
    late GetScheduleStatistics usecase;
    late MockGroupScheduleRepository mockRepository;

    setUp(() {
      mockRepository = MockGroupScheduleRepository();
      usecase = GetScheduleStatistics(mockRepository);
    });

    group('Construction', () {
      test('should create usecase with repository dependency', () {
        // Arrange & Act
        final usecase = GetScheduleStatistics(mockRepository);

        // Assert
        expect(usecase.repository, equals(mockRepository));
      });
    });

    group('Success Cases', () {
      test('should get schedule statistics successfully', () async {
        // Arrange
        final params = GetScheduleStatisticsParams(
          groupId: 'group-123',
          week: '2024-W01',
        );
        final expectedStats = {
          'totalSlots': 35,
          'occupiedSlots': 20,
          'occupancyRate': 0.57,
          'vehicleUtilization': {'vehicle-1': 0.8, 'vehicle-2': 0.6},
          'peakHours': ['08:00', '15:00'],
        };

        when(
          mockRepository.getScheduleStatistics(any, any),
        ).thenAnswer((_) async => Result.ok(expectedStats));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.value, equals(expectedStats));
        verify(
          mockRepository.getScheduleStatistics('group-123', '2024-W01'),
        ).called(1);
      });

      test('should handle empty statistics gracefully', () async {
        // Arrange
        final params = GetScheduleStatisticsParams(
          groupId: 'group-123',
          week: '2024-W01',
        );
        final expectedStats = <String, dynamic>{};

        when(
          mockRepository.getScheduleStatistics(any, any),
        ).thenAnswer((_) async => Result.ok(expectedStats));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.value, equals(expectedStats));
        expect(result.value!.isEmpty, isTrue);
      });
    });

    group('Failure Cases', () {
      test(
        'should return error when repository fails to get statistics',
        () async {
          // Arrange
          final params = GetScheduleStatisticsParams(
            groupId: 'group-123',
            week: '2024-W01',
          );
          final failure = ApiFailure.serverError(
            message: 'Failed to calculate statistics',
          );

          when(
            mockRepository.getScheduleStatistics(any, any),
          ).thenAnswer((_) async => Result.err(failure));

          // Act
          final result = await usecase.call(params);

          // Assert
          expect(result.isError, isTrue);
          expect(result.error, equals(failure));
        },
      );

      test('should handle week not found errors', () async {
        // Arrange
        final params = GetScheduleStatisticsParams(
          groupId: 'group-123',
          week: '2024-W99',
        );
        final failure = ApiFailure.notFound(resource: 'Week schedule');

        when(
          mockRepository.getScheduleStatistics(any, any),
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
        final params = GetScheduleStatisticsParams(
          groupId: 'stats-group-456',
          week: 'stats-week-test',
        );
        final mockStats = {'test': 'data'};

        when(
          mockRepository.getScheduleStatistics(any, any),
        ).thenAnswer((_) async => Result.ok(mockStats));

        // Act
        await usecase.call(params);

        // Assert
        verify(
          mockRepository.getScheduleStatistics(
            'stats-group-456',
            'stats-week-test',
          ),
        ).called(1);
        verifyNoMoreInteractions(mockRepository);
      });
    });
  });

  group('CheckScheduleConflicts', () {
    late CheckScheduleConflicts usecase;
    late MockGroupScheduleRepository mockRepository;

    setUp(() {
      mockRepository = MockGroupScheduleRepository();
      usecase = CheckScheduleConflicts(mockRepository);
    });

    group('Construction', () {
      test('should create usecase with repository dependency', () {
        // Arrange & Act
        final usecase = CheckScheduleConflicts(mockRepository);

        // Assert
        expect(usecase.repository, equals(mockRepository));
      });
    });

    group('Success Cases', () {
      test(
        'should check schedule conflicts successfully with no conflicts',
        () async {
          // Arrange
          final params = CheckScheduleConflictsParams(
            groupId: 'group-123',
            vehicleId: 'vehicle-1',
            week: '2024-W01',
            day: 'monday',
            time: '08:00',
          );
          final expectedConflicts = <ScheduleConflict>[];

          when(
            mockRepository.checkScheduleConflicts(any, any, any, any, any),
          ).thenAnswer((_) async => Result.ok(expectedConflicts));

          // Act
          final result = await usecase.call(params);

          // Assert
          expect(result.value, equals(expectedConflicts));
          expect(result.value!.isEmpty, isTrue);
          verify(
            mockRepository.checkScheduleConflicts(
              'group-123',
              'vehicle-1',
              '2024-W01',
              'monday',
              '08:00',
            ),
          ).called(1);
        },
      );

      test(
        'should check schedule conflicts successfully with conflicts found',
        () async {
          // Arrange
          final params = CheckScheduleConflictsParams(
            groupId: 'group-123',
            vehicleId: 'vehicle-1',
            week: '2024-W01',
            day: 'monday',
            time: '08:00',
          );
          final expectedConflicts = [
            ScheduleConflict(
              id: 'conflict-1',
              firstTimeSlotId: 'slot-1',
              secondTimeSlotId: 'slot-2',
              type: ConflictType.timeOverlap,
              severity: ConflictSeverity.high,
              description: 'Time overlap detected',
              detectedAt: DateTime.now(),
            ),
          ];

          when(
            mockRepository.checkScheduleConflicts(any, any, any, any, any),
          ).thenAnswer((_) async => Result.ok(expectedConflicts));

          // Act
          final result = await usecase.call(params);

          // Assert
          expect(result.value, equals(expectedConflicts));
          expect(result.value!.length, equals(1));
          expect(result.value!.first.type, equals(ConflictType.timeOverlap));
        },
      );

      test('should handle multiple conflicts correctly', () async {
        // Arrange
        final params = CheckScheduleConflictsParams(
          groupId: 'group-123',
          vehicleId: 'vehicle-1',
          week: '2024-W01',
          day: 'monday',
          time: '08:00',
        );
        final expectedConflicts = [
          ScheduleConflict(
            id: 'conflict-1',
            firstTimeSlotId: 'slot-1',
            secondTimeSlotId: 'slot-2',
            type: ConflictType.resourceConflict,
            severity: ConflictSeverity.medium,
            description: 'Capacity conflict',
            detectedAt: DateTime.now(),
          ),
          ScheduleConflict(
            id: 'conflict-2',
            firstTimeSlotId: 'slot-1',
            secondTimeSlotId: 'slot-3',
            type: ConflictType.timeOverlap,
            severity: ConflictSeverity.high,
            description: 'Time overlap',
            detectedAt: DateTime.now(),
          ),
          ScheduleConflict(
            id: 'conflict-3',
            firstTimeSlotId: 'slot-1',
            secondTimeSlotId: '',
            type: ConflictType.driverUnavailable,
            severity: ConflictSeverity.critical,
            description: 'Driver unavailable',
            detectedAt: DateTime.now(),
          ),
        ];

        when(
          mockRepository.checkScheduleConflicts(any, any, any, any, any),
        ).thenAnswer((_) async => Result.ok(expectedConflicts));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.value, equals(expectedConflicts));
        expect(result.value!.length, equals(3));
      });
    });

    group('Failure Cases', () {
      test(
        'should return error when repository fails to check conflicts',
        () async {
          // Arrange
          final params = CheckScheduleConflictsParams(
            groupId: 'group-123',
            vehicleId: 'vehicle-1',
            week: '2024-W01',
            day: 'monday',
            time: '08:00',
          );
          final failure = ApiFailure.serverError(
            message: 'Failed to check conflicts',
          );

          when(
            mockRepository.checkScheduleConflicts(any, any, any, any, any),
          ).thenAnswer((_) async => Result.err(failure));

          // Act
          final result = await usecase.call(params);

          // Assert
          expect(result.isError, isTrue);
          expect(result.error, equals(failure));
        },
      );

      test('should handle vehicle not found errors', () async {
        // Arrange
        final params = CheckScheduleConflictsParams(
          groupId: 'group-123',
          vehicleId: 'non-existent-vehicle',
          week: '2024-W01',
          day: 'monday',
          time: '08:00',
        );
        final failure = ApiFailure.notFound(resource: 'Vehicle');

        when(
          mockRepository.checkScheduleConflicts(any, any, any, any, any),
        ).thenAnswer((_) async => Result.err(failure));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, equals(failure));
      });

      test('should handle unauthorized conflict checks', () async {
        // Arrange
        final params = CheckScheduleConflictsParams(
          groupId: 'group-123',
          vehicleId: 'vehicle-1',
          week: '2024-W01',
          day: 'monday',
          time: '08:00',
        );
        final failure = ApiFailure.unauthorized();

        when(
          mockRepository.checkScheduleConflicts(any, any, any, any, any),
        ).thenAnswer((_) async => Result.err(failure));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, equals(failure));
      });
    });

    group('Business Logic Validation', () {
      test('should pass all parameters unchanged to repository', () async {
        // Arrange
        final params = CheckScheduleConflictsParams(
          groupId: 'conflict-group-789',
          vehicleId: 'conflict-vehicle-123',
          week: 'conflict-week-test',
          day: 'conflict-day-test',
          time: 'conflict-time-test',
        );
        final mockConflicts = <ScheduleConflict>[];

        when(
          mockRepository.checkScheduleConflicts(any, any, any, any, any),
        ).thenAnswer((_) async => Result.ok(mockConflicts));

        // Act
        await usecase.call(params);

        // Assert
        verify(
          mockRepository.checkScheduleConflicts(
            'conflict-group-789',
            'conflict-vehicle-123',
            'conflict-week-test',
            'conflict-day-test',
            'conflict-time-test',
          ),
        ).called(1);
        verifyNoMoreInteractions(mockRepository);
      });
    });

    group('Edge Cases', () {
      test('should handle edge time slots gracefully', () async {
        // Arrange
        final params = CheckScheduleConflictsParams(
          groupId: 'group-123',
          vehicleId: 'vehicle-1',
          week: '2024-W01',
          day: 'sunday',
          time: '23:59',
        );
        final expectedConflicts = <ScheduleConflict>[];

        when(
          mockRepository.checkScheduleConflicts(any, any, any, any, any),
        ).thenAnswer((_) async => Result.ok(expectedConflicts));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.value, equals(expectedConflicts));
        verify(
          mockRepository.checkScheduleConflicts(
            'group-123',
            'vehicle-1',
            '2024-W01',
            'sunday',
            '23:59',
          ),
        ).called(1);
      });

      test('should handle midnight time slots', () async {
        // Arrange
        final params = CheckScheduleConflictsParams(
          groupId: 'group-123',
          vehicleId: 'vehicle-1',
          week: '2024-W01',
          day: 'monday',
          time: '00:00',
        );
        final expectedConflicts = <ScheduleConflict>[];

        when(
          mockRepository.checkScheduleConflicts(any, any, any, any, any),
        ).thenAnswer((_) async => Result.ok(expectedConflicts));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.value, equals(expectedConflicts));
        verify(
          mockRepository.checkScheduleConflicts(
            'group-123',
            'vehicle-1',
            '2024-W01',
            'monday',
            '00:00',
          ),
        ).called(1);
      });
    });
  });
}
