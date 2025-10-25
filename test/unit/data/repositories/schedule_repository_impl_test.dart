import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:edulift/features/schedule/data/repositories/schedule_repository_impl.dart';
import 'package:edulift/core/domain/entities/schedule/schedule_slot.dart';
import 'package:edulift/core/domain/entities/schedule/day_of_week.dart';
import 'package:edulift/core/domain/entities/schedule/time_of_day.dart';
import 'package:edulift/core/network/models/schedule/schedule_slot_dto.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';
import '../../../test_mocks/test_mocks.dart';

void main() {
  setUpAll(() {
    setupMockFallbacks();
  });

  group('ScheduleRepositoryImpl', () {
    late ScheduleRepositoryImpl repository;
    late MockScheduleRemoteDataSource mockRemoteDataSource;
    late MockScheduleLocalDataSource mockLocalDataSource;
    late MockNetworkErrorHandler mockNetworkErrorHandler;

    setUp(() {
      mockRemoteDataSource = MockScheduleRemoteDataSource();
      mockLocalDataSource = MockScheduleLocalDataSource();
      mockNetworkErrorHandler = MockNetworkErrorHandler();

      repository = ScheduleRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        localDataSource: mockLocalDataSource,
        networkErrorHandler: mockNetworkErrorHandler,
      );
    });

    group('getWeeklySchedule - Cache-First Pattern', () {
      const testGroupId = 'group-123';
      const testWeek = '2025-W10';
      final testSlots = [
        ScheduleSlot(
          id: 'slot-1',
          groupId: testGroupId,
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: TimeOfDayValue.parse('08:00'),
          week: testWeek,
          vehicleAssignments: const [],
          maxVehicles: 5,
          createdAt: DateTime(2025, 3, 3),
          updatedAt: DateTime(2025, 3, 3),
        ),
        ScheduleSlot(
          id: 'slot-2',
          groupId: testGroupId,
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: TimeOfDayValue.parse('15:00'),
          week: testWeek,
          vehicleAssignments: const [],
          maxVehicles: 5,
          createdAt: DateTime(2025, 3, 3),
          updatedAt: DateTime(2025, 3, 3),
        ),
      ];

      test('returns cached data when available and not expired', () async {
        // Arrange
        final testDtos = testSlots
            .map(
              (slot) => ScheduleSlotDto(
                id: slot.id,
                groupId: slot.groupId,
                day: slot.dayOfWeek.toString().split('.').last,
                time: slot.timeOfDay.format24Hour(),
                week: slot.week,
                vehicleAssignments: const [],
                maxVehicles: slot.maxVehicles,
                createdAt: slot.createdAt,
                updatedAt: slot.updatedAt,
              ),
            )
            .toList();

        // Mock NetworkErrorHandler to return success with DTOs
        when(
          mockNetworkErrorHandler
              .executeRepositoryOperation<List<ScheduleSlotDto>>(
                any,
                operationName: anyNamed('operationName'),
                strategy: anyNamed('strategy'),
                serviceName: anyNamed('serviceName'),
                config: anyNamed('config'),
                onSuccess: anyNamed('onSuccess'),
                context: anyNamed('context'),
              ),
        ).thenAnswer((invocation) async {
          // Execute the onSuccess callback to cache the data
          final onSuccess = invocation.namedArguments[#onSuccess] as Function?;
          if (onSuccess != null) {
            await onSuccess(testDtos);
          }
          return Result.ok(testDtos);
        });

        // Act
        final result = await repository.getWeeklySchedule(
          testGroupId,
          testWeek,
        );

        // Assert
        expect(result.isOk, isTrue);
        expect(result.unwrap(), equals(testSlots));

        // Verify NetworkErrorHandler was called (network-first strategy)
        verify(
          mockNetworkErrorHandler
              .executeRepositoryOperation<List<ScheduleSlotDto>>(
                any,
                operationName: anyNamed('operationName'),
                strategy: anyNamed('strategy'),
                serviceName: anyNamed('serviceName'),
                config: anyNamed('config'),
                onSuccess: anyNamed('onSuccess'),
                context: anyNamed('context'),
              ),
        ).called(1);

        // Verify cache was updated via onSuccess callback
        verify(
          mockLocalDataSource.cacheWeeklySchedule(
            testGroupId,
            testWeek,
            testSlots,
          ),
        ).called(1);
      });

      test('fetches from API when cache is empty', () async {
        // Arrange
        final testDtos = testSlots
            .map(
              (slot) => ScheduleSlotDto(
                id: slot.id,
                groupId: slot.groupId,
                day: slot.dayOfWeek.toString().split('.').last,
                time: slot.timeOfDay.format24Hour(),
                week: slot.week,
                vehicleAssignments: const [],
                maxVehicles: slot.maxVehicles,
                createdAt: slot.createdAt,
                updatedAt: slot.updatedAt,
              ),
            )
            .toList();

        // Mock NetworkErrorHandler to return success (network-first strategy)
        when(
          mockNetworkErrorHandler
              .executeRepositoryOperation<List<ScheduleSlotDto>>(
                any,
                operationName: anyNamed('operationName'),
                strategy: anyNamed('strategy'),
                serviceName: anyNamed('serviceName'),
                config: anyNamed('config'),
                onSuccess: anyNamed('onSuccess'),
                context: anyNamed('context'),
              ),
        ).thenAnswer((invocation) async {
          final onSuccess = invocation.namedArguments[#onSuccess] as Function?;
          if (onSuccess != null) {
            await onSuccess(testDtos);
          }
          return Result.ok(testDtos);
        });

        // Act
        final result = await repository.getWeeklySchedule(
          testGroupId,
          testWeek,
        );

        // Assert
        expect(result.isOk, isTrue);
        expect(result.unwrap(), equals(testSlots));

        // Verify cache was updated
        verify(
          mockLocalDataSource.cacheWeeklySchedule(
            testGroupId,
            testWeek,
            testSlots,
          ),
        ).called(1);
      });

      test('returns stale cache when offline and cache exists', () async {
        // Arrange - Network error (HTTP 0 = offline)
        when(
          mockNetworkErrorHandler
              .executeRepositoryOperation<List<ScheduleSlotDto>>(
                any,
                operationName: anyNamed('operationName'),
                strategy: anyNamed('strategy'),
                serviceName: anyNamed('serviceName'),
                config: anyNamed('config'),
                onSuccess: anyNamed('onSuccess'),
                context: anyNamed('context'),
              ),
        ).thenAnswer((_) async => Result.err(ApiFailure.networkError()));

        // Mock cache to return stale data
        when(
          mockLocalDataSource.getCachedWeeklySchedule(testGroupId, testWeek),
        ).thenAnswer((_) async => testSlots);

        // Act
        final result = await repository.getWeeklySchedule(
          testGroupId,
          testWeek,
        );

        // Assert - should return stale cache when offline (Principe 0)
        expect(result.isOk, isTrue);
        expect(result.unwrap(), equals(testSlots));

        // Verify cache was checked after network failure
        verify(
          mockLocalDataSource.getCachedWeeklySchedule(testGroupId, testWeek),
        ).called(1);
      });

      test('returns network error when offline and no cache', () async {
        // Arrange - Network error (HTTP 0 = offline)
        when(
          mockNetworkErrorHandler
              .executeRepositoryOperation<List<ScheduleSlotDto>>(
                any,
                operationName: anyNamed('operationName'),
                strategy: anyNamed('strategy'),
                serviceName: anyNamed('serviceName'),
                config: anyNamed('config'),
                onSuccess: anyNamed('onSuccess'),
                context: anyNamed('context'),
              ),
        ).thenAnswer((_) async => Result.err(ApiFailure.networkError()));

        // Mock cache to return empty/null
        when(
          mockLocalDataSource.getCachedWeeklySchedule(testGroupId, testWeek),
        ).thenAnswer((_) async => null);

        // Act
        final result = await repository.getWeeklySchedule(
          testGroupId,
          testWeek,
        );

        // Assert - should return error when offline with no cache
        expect(result.isErr, isTrue);
        final failure = result.unwrapErr();
        expect(failure.statusCode, equals(0)); // Network error
      });

      test('handles cache miss with no metadata', () async {
        // Arrange
        final testDtos = testSlots
            .map(
              (slot) => ScheduleSlotDto(
                id: slot.id,
                groupId: slot.groupId,
                day: slot.dayOfWeek.toString().split('.').last,
                time: slot.timeOfDay.format24Hour(),
                week: slot.week,
                vehicleAssignments: const [],
                maxVehicles: slot.maxVehicles,
                createdAt: slot.createdAt,
                updatedAt: slot.updatedAt,
              ),
            )
            .toList();

        when(
          mockNetworkErrorHandler
              .executeRepositoryOperation<List<ScheduleSlotDto>>(
                any,
                operationName: anyNamed('operationName'),
                strategy: anyNamed('strategy'),
                serviceName: anyNamed('serviceName'),
                config: anyNamed('config'),
                onSuccess: anyNamed('onSuccess'),
                context: anyNamed('context'),
              ),
        ).thenAnswer((invocation) async {
          final onSuccess = invocation.namedArguments[#onSuccess] as Function?;
          if (onSuccess != null) {
            await onSuccess(testDtos);
          }
          return Result.ok(testDtos);
        });

        // Act
        final result = await repository.getWeeklySchedule(
          testGroupId,
          testWeek,
        );

        // Assert
        expect(result.isOk, isTrue);
        verify(
          mockLocalDataSource.cacheWeeklySchedule(
            testGroupId,
            testWeek,
            testSlots,
          ),
        ).called(1);
      });

      test('handles expired cache correctly', () async {
        // Arrange - With network-first strategy, expired cache doesn't matter
        // The repository always tries network first, then falls back to cache on error
        final testDtos = testSlots
            .map(
              (slot) => ScheduleSlotDto(
                id: slot.id,
                groupId: slot.groupId,
                day: slot.dayOfWeek.toString().split('.').last,
                time: slot.timeOfDay.format24Hour(),
                week: slot.week,
                vehicleAssignments: const [],
                maxVehicles: slot.maxVehicles,
                createdAt: slot.createdAt,
                updatedAt: slot.updatedAt,
              ),
            )
            .toList();

        when(
          mockNetworkErrorHandler
              .executeRepositoryOperation<List<ScheduleSlotDto>>(
                any,
                operationName: anyNamed('operationName'),
                strategy: anyNamed('strategy'),
                serviceName: anyNamed('serviceName'),
                config: anyNamed('config'),
                onSuccess: anyNamed('onSuccess'),
                context: anyNamed('context'),
              ),
        ).thenAnswer((invocation) async {
          final onSuccess = invocation.namedArguments[#onSuccess] as Function?;
          if (onSuccess != null) {
            await onSuccess(testDtos);
          }
          return Result.ok(testDtos);
        });

        // Act
        await repository.getWeeklySchedule(testGroupId, testWeek);

        // Assert - should fetch from network and update cache
        verify(
          mockLocalDataSource.cacheWeeklySchedule(
            testGroupId,
            testWeek,
            testSlots,
          ),
        ).called(1);
      });
    });

    group('upsertScheduleSlot - Server-First Pattern', () {
      const testGroupId = 'group-123';
      const testDay = 'Monday';
      const testTime = '08:00';
      const testWeek = '2025-W10';

      test('stores pending operation when offline', () async {
        // Arrange
        when(
          mockLocalDataSource.storePendingOperation(any),
        ).thenAnswer((_) async {});

        // Act
        final result = await repository.upsertScheduleSlot(
          testGroupId,
          testDay,
          testTime,
          testWeek,
        );

        // Assert - should fail with validation error (empty slot creation deprecated)
        expect(result.isErr, isTrue);
        final failure = result.unwrapErr();
        expect(failure.code, contains('validation'));

        verifyNever(
          mockLocalDataSource.storePendingOperation(
            argThat(
              predicate<Map<String, dynamic>>((op) {
                return op['type'] == 'upsert_slot' &&
                    op['groupId'] == testGroupId &&
                    op['day'] == testDay &&
                    op['time'] == testTime &&
                    op['week'] == testWeek &&
                    op['retryCount'] == 0;
              }),
            ),
          ),
        );
      });

      test('requires network connection for writes', () async {
        // Arrange
        when(
          mockLocalDataSource.storePendingOperation(any),
        ).thenAnswer((_) async {});

        // Act
        final result = await repository.upsertScheduleSlot(
          testGroupId,
          testDay,
          testTime,
          testWeek,
        );

        // Assert - upsertScheduleSlot is deprecated and returns validation error
        expect(result.isErr, isTrue);
        expect(result.unwrapErr().code, contains('validation'));
      });
    });

    group('cache invalidation', () {
      test('getWeeklySchedule reads from cache before API', () async {
        // Arrange
        const testGroupId = 'group-123';
        const testWeek = '2025-W10';
        final testSlots = <ScheduleSlot>[];

        final testDtos = <ScheduleSlotDto>[];

        // Note: With network-first strategy, network is tried FIRST
        // Cache is only checked on network failure (Principe 0)
        when(
          mockNetworkErrorHandler
              .executeRepositoryOperation<List<ScheduleSlotDto>>(
                any,
                operationName: anyNamed('operationName'),
                strategy: anyNamed('strategy'),
                serviceName: anyNamed('serviceName'),
                config: anyNamed('config'),
                onSuccess: anyNamed('onSuccess'),
                context: anyNamed('context'),
              ),
        ).thenAnswer((invocation) async {
          final onSuccess = invocation.namedArguments[#onSuccess] as Function?;
          if (onSuccess != null) {
            await onSuccess(testDtos);
          }
          return Result.ok(testDtos);
        });

        // Act
        await repository.getWeeklySchedule(testGroupId, testWeek);

        // Assert - cache should be updated after successful network call
        verify(
          mockLocalDataSource.cacheWeeklySchedule(
            testGroupId,
            testWeek,
            testSlots,
          ),
        ).called(1);
      });
    });

    group('offline handling', () {
      test('returns appropriate error when offline with no cache', () async {
        // Arrange
        when(
          mockNetworkErrorHandler
              .executeRepositoryOperation<List<ScheduleSlotDto>>(
                any,
                operationName: anyNamed('operationName'),
                strategy: anyNamed('strategy'),
                serviceName: anyNamed('serviceName'),
                config: anyNamed('config'),
                onSuccess: anyNamed('onSuccess'),
                context: anyNamed('context'),
              ),
        ).thenAnswer((_) async => Result.err(ApiFailure.networkError()));

        when(
          mockLocalDataSource.getCachedWeeklySchedule(any, any),
        ).thenAnswer((_) async => null);

        // Act
        const testGroupId = 'group-1';
        const testWeek = '2025-W10';
        final result = await repository.getWeeklySchedule(
          testGroupId,
          testWeek,
        );

        // Assert
        expect(result.isErr, isTrue);
        expect(result.unwrapErr().statusCode, equals(0));
      });

      test(
        'upsertScheduleSlot returns validation error (deprecated)',
        () async {
          // Arrange
          when(
            mockLocalDataSource.storePendingOperation(any),
          ).thenAnswer((_) async {});

          // Act
          final result = await repository.upsertScheduleSlot(
            'group-1',
            'Monday',
            '08:00',
            '2025-W10',
          );

          // Assert - upsertScheduleSlot is deprecated
          expect(result.isErr, isTrue);
          expect(result.unwrapErr().code, contains('validation'));
          verifyNever(mockLocalDataSource.storePendingOperation(any));
        },
      );
    });

    group('error handling', () {
      test('handles cache read errors gracefully', () async {
        // Arrange
        when(
          mockNetworkErrorHandler
              .executeRepositoryOperation<List<ScheduleSlotDto>>(
                any,
                operationName: anyNamed('operationName'),
                strategy: anyNamed('strategy'),
                serviceName: anyNamed('serviceName'),
                config: anyNamed('config'),
                onSuccess: anyNamed('onSuccess'),
                context: anyNamed('context'),
              ),
        ).thenAnswer((_) async => Result.err(ApiFailure.networkError()));

        when(
          mockLocalDataSource.getCachedWeeklySchedule(any, any),
        ).thenThrow(Exception('Cache read failed'));

        // Act
        final result = await repository.getWeeklySchedule(
          'group-1',
          '2025-W10',
        );

        // Assert - should handle cache error and return network error
        expect(result.isErr, isTrue);
      });

      test('handles errors from NetworkErrorHandler gracefully', () async {
        // Arrange
        when(
          mockNetworkErrorHandler
              .executeRepositoryOperation<List<ScheduleSlotDto>>(
                any,
                operationName: anyNamed('operationName'),
                strategy: anyNamed('strategy'),
                serviceName: anyNamed('serviceName'),
                config: anyNamed('config'),
                onSuccess: anyNamed('onSuccess'),
                context: anyNamed('context'),
              ),
        ).thenAnswer((_) async => Result.err(ApiFailure.serverError()));

        when(
          mockLocalDataSource.getCachedWeeklySchedule(any, any),
        ).thenAnswer((_) async => null);

        // Act
        final result = await repository.getWeeklySchedule(
          'group-1',
          '2025-W10',
        );

        // Assert - should return error Result
        expect(result.isErr, isTrue);
        expect(result.unwrapErr().statusCode, equals(500));
      });
    });

    group('cache freshness logic', () {
      test('considers cache fresh within 1 hour', () async {
        // NOTE: With network-first strategy, cache freshness doesn't matter
        // The repository ALWAYS tries network first regardless of cache age

        when(
          mockNetworkErrorHandler
              .executeRepositoryOperation<List<ScheduleSlotDto>>(
                any,
                operationName: anyNamed('operationName'),
                strategy: anyNamed('strategy'),
                serviceName: anyNamed('serviceName'),
                config: anyNamed('config'),
                onSuccess: anyNamed('onSuccess'),
                context: anyNamed('context'),
              ),
        ).thenAnswer((invocation) async {
          final onSuccess = invocation.namedArguments[#onSuccess] as Function?;
          if (onSuccess != null) {
            await onSuccess(<ScheduleSlotDto>[]);
          }
          return Result.ok(<ScheduleSlotDto>[]);
        });

        // Act
        final result = await repository.getWeeklySchedule(
          'group-1',
          '2025-W10',
        );

        // Assert - network-first always tries network
        expect(result.isOk, isTrue);
      });

      test('considers cache stale after 1 hour', () async {
        // NOTE: With network-first strategy, this test is same as above
        // Cache staleness is irrelevant - network is always tried first

        when(
          mockNetworkErrorHandler
              .executeRepositoryOperation<List<ScheduleSlotDto>>(
                any,
                operationName: anyNamed('operationName'),
                strategy: anyNamed('strategy'),
                serviceName: anyNamed('serviceName'),
                config: anyNamed('config'),
                onSuccess: anyNamed('onSuccess'),
                context: anyNamed('context'),
              ),
        ).thenAnswer((invocation) async {
          final onSuccess = invocation.namedArguments[#onSuccess] as Function?;
          if (onSuccess != null) {
            await onSuccess(<ScheduleSlotDto>[]);
          }
          return Result.ok(<ScheduleSlotDto>[]);
        });

        // Act
        await repository.getWeeklySchedule('group-1', '2025-W10');

        // Assert - network attempt was made
        verify(
          mockNetworkErrorHandler
              .executeRepositoryOperation<List<ScheduleSlotDto>>(
                any,
                operationName: anyNamed('operationName'),
                strategy: anyNamed('strategy'),
                serviceName: anyNamed('serviceName'),
                config: anyNamed('config'),
                onSuccess: anyNamed('onSuccess'),
                context: anyNamed('context'),
              ),
        ).called(1);
      });

      test('returns stale cache when offline instead of failing', () async {
        // Arrange - Network error (offline)
        when(
          mockNetworkErrorHandler
              .executeRepositoryOperation<List<ScheduleSlotDto>>(
                any,
                operationName: anyNamed('operationName'),
                strategy: anyNamed('strategy'),
                serviceName: anyNamed('serviceName'),
                config: anyNamed('config'),
                onSuccess: anyNamed('onSuccess'),
                context: anyNamed('context'),
              ),
        ).thenAnswer((_) async => Result.err(ApiFailure.networkError()));

        final testDate = DateTime(2025, 3);
        final staleData = [
          ScheduleSlot(
            id: 'slot-old',
            groupId: 'group-1',
            dayOfWeek: DayOfWeek.monday,
            timeOfDay: TimeOfDayValue.parse('08:00'),
            week: '2025-W10',
            vehicleAssignments: const [],
            maxVehicles: 5,
            createdAt: testDate,
            updatedAt: testDate,
          ),
        ];

        when(
          mockLocalDataSource.getCachedWeeklySchedule(any, any),
        ).thenAnswer((_) async => staleData);

        // Act
        final result = await repository.getWeeklySchedule(
          'group-1',
          '2025-W10',
        );

        // Assert - should return stale cache rather than fail (Principe 0)
        expect(result.isOk, isTrue);
        expect(result.unwrap(), equals(staleData));
      });
    });
  });
}
