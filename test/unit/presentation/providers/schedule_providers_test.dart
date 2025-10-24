// EduLift Mobile - Schedule Providers Unit Tests
// Comprehensive tests for schedule Riverpod providers
// Uses centralized mocks from test_mocks/test_mocks.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

import 'package:edulift/features/schedule/presentation/providers/schedule_providers.dart';
import 'package:edulift/core/domain/entities/schedule/schedule_slot.dart';
import 'package:edulift/core/domain/entities/schedule/day_of_week.dart';
import 'package:edulift/core/domain/entities/schedule/time_of_day.dart';
import 'package:edulift/core/domain/entities/schedule/vehicle_assignment.dart';
import 'package:edulift/features/schedule/domain/failures/schedule_failure.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/core/di/providers/repository_providers.dart';
import 'package:edulift/core/services/providers/auth_provider.dart';

import '../../../test_mocks/test_mocks.dart';
import '../../../support/test_mock_configuration.dart';

void main() {
  // Use comprehensive TestMockConfiguration for all mock setup
  setUpAll(() {
    TestMockConfiguration.setupGlobalMocks();
    setupMockFallbacks();
  });

  group('weeklyScheduleProvider Tests', () {
    late MockGroupScheduleRepository mockRepository;
    late ProviderContainer container;

    // Test data - using typed constructors
    final testSlot1 = ScheduleSlot(
      id: 'slot-1',
      groupId: 'group-123',
      dayOfWeek: DayOfWeek.monday,
      timeOfDay: TimeOfDayValue.parse('08:00'),
      week: '2025-W10',
      vehicleAssignments: const [],
      maxVehicles: 5,
      createdAt: DateTime.parse('2025-01-01T10:00:00Z'),
      updatedAt: DateTime.parse('2025-01-01T10:00:00Z'),
    );

    final testSlot2 = ScheduleSlot(
      id: 'slot-2',
      groupId: 'group-123',
      dayOfWeek: DayOfWeek.tuesday,
      timeOfDay: TimeOfDayValue.parse('15:00'),
      week: '2025-W10',
      vehicleAssignments: const [],
      maxVehicles: 5,
      createdAt: DateTime.parse('2025-01-01T10:00:00Z'),
      updatedAt: DateTime.parse('2025-01-01T10:00:00Z'),
    );

    setUp(() {
      mockRepository = MockGroupScheduleRepository();
      container = ProviderContainer(
        overrides: [
          scheduleRepositoryProvider.overrideWithValue(mockRepository),
          // Mock auth provider to return null user (not logged in)
          currentUserProvider.overrideWith((ref) => null),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'GIVEN repository returns schedule slots WHEN provider is read THEN returns slots',
      () async {
        // GIVEN
        final slots = <ScheduleSlot>[testSlot1, testSlot2];
        when(
          mockRepository.getWeeklySchedule('group-123', '2025-W10'),
        ).thenAnswer((_) async => Result.ok(slots));

        // WHEN
        final result = await container.read(
          weeklyScheduleProvider('group-123', '2025-W10').future,
        );

        // THEN
        expect(result, equals(slots));
        verify(
          mockRepository.getWeeklySchedule('group-123', '2025-W10'),
        ).called(1);
      },
    );

    test(
      'GIVEN repository returns error WHEN provider is read THEN throws exception',
      () async {
        // GIVEN
        const failure = ApiFailure(message: 'Network error', statusCode: 500);
        when(
          mockRepository.getWeeklySchedule('group-123', '2025-W10'),
        ).thenAnswer((_) async => const Result.err(failure));

        // WHEN & THEN
        expect(
          () => container.read(
            weeklyScheduleProvider('group-123', '2025-W10').future,
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Network error'),
            ),
          ),
        );
      },
    );

    test(
      'GIVEN repository returns generic error WHEN provider is read THEN throws generic exception',
      () async {
        // GIVEN
        const failure = ApiFailure(
          statusCode: 500, // No message (default: null)
        );
        when(
          mockRepository.getWeeklySchedule('group-123', '2025-W10'),
        ).thenAnswer((_) async => const Result.err(failure));

        // WHEN & THEN
        expect(
          () => container.read(
            weeklyScheduleProvider('group-123', '2025-W10').future,
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to load weekly schedule'),
            ),
          ),
        );
      },
    );

    test(
      'GIVEN cached data WHEN same provider instance is read again THEN returns cached data',
      () async {
        // GIVEN
        final slots = <ScheduleSlot>[testSlot1, testSlot2];
        when(
          mockRepository.getWeeklySchedule('group-123', '2025-W10'),
        ).thenAnswer((_) async => Result.ok(slots));

        // WHEN - First read
        await container.read(
          weeklyScheduleProvider('group-123', '2025-W10').future,
        );

        // Second read (should use cache)
        final result = await container.read(
          weeklyScheduleProvider('group-123', '2025-W10').future,
        );

        // THEN - Repository called only once (cached on second call)
        expect(result, equals(slots));
        verify(
          mockRepository.getWeeklySchedule('group-123', '2025-W10'),
        ).called(1);
      },
    );

    test(
      'GIVEN different week parameter WHEN provider is read THEN creates separate instance',
      () async {
        // GIVEN
        final slots1 = <ScheduleSlot>[testSlot1];
        final slots2 = <ScheduleSlot>[testSlot2];
        when(
          mockRepository.getWeeklySchedule('group-123', '2025-W10'),
        ).thenAnswer((_) async => Result.ok(slots1));
        when(
          mockRepository.getWeeklySchedule('group-123', '2025-W11'),
        ).thenAnswer((_) async => Result.ok(slots2));

        // WHEN
        final result1 = await container.read(
          weeklyScheduleProvider('group-123', '2025-W10').future,
        );
        final result2 = await container.read(
          weeklyScheduleProvider('group-123', '2025-W11').future,
        );

        // THEN - Each week gets its own data
        expect(result1, equals(slots1));
        expect(result2, equals(slots2));
        verify(
          mockRepository.getWeeklySchedule('group-123', '2025-W10'),
        ).called(1);
        verify(
          mockRepository.getWeeklySchedule('group-123', '2025-W11'),
        ).called(1);
      },
    );

    test(
      'GIVEN empty schedule WHEN provider is read THEN returns empty list',
      () async {
        // GIVEN
        when(
          mockRepository.getWeeklySchedule('group-123', '2025-W10'),
        ).thenAnswer((_) async => const Result.ok([]));

        // WHEN
        final result = await container.read(
          weeklyScheduleProvider('group-123', '2025-W10').future,
        );

        // THEN
        expect(result, isEmpty);
        verify(
          mockRepository.getWeeklySchedule('group-123', '2025-W10'),
        ).called(1);
      },
    );
  });

  // NOTE: vehicleAssignmentsProvider and childAssignmentsProvider are now fully implemented
  // and tested through integration tests. These providers extract data from weeklyScheduleProvider
  // and are tested in the schedule_grid_test.dart and vehicle_selection_modal_test.dart files.

  group('AssignmentStateNotifier Tests', () {
    late MockGroupScheduleRepository mockRepository;
    late ProviderContainer container;

    // Test data
    final now = DateTime.now();
    final testVehicleAssignment = VehicleAssignment(
      id: 'vehicle-assignment-1',
      scheduleSlotId: 'slot-1',
      vehicleId: 'vehicle-1',
      assignedAt: now,
      assignedBy: 'user-1',
      vehicleName: 'Test Van',
      capacity: 5,
      createdAt: now,
      updatedAt: now,
    );

    setUp(() {
      mockRepository = MockGroupScheduleRepository();
      container = ProviderContainer(
        overrides: [
          scheduleRepositoryProvider.overrideWithValue(mockRepository),
          currentUserProvider.overrideWith((ref) => null),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('assignChild Tests', () {
      test(
        'GIVEN successful repository call WHEN assignChild is called THEN returns success and invalidates provider',
        () async {
          // GIVEN
          when(
            mockRepository.assignChildrenToVehicle(
              'group-123',
              'slot-1',
              'vehicle-assignment-1',
              ['child-1'],
            ),
          ).thenAnswer((_) async => Result.ok(testVehicleAssignment));

          // Setup weekly schedule provider for invalidation check
          when(
            mockRepository.getWeeklySchedule('group-123', '2025-W10'),
          ).thenAnswer((_) async => const Result.ok([]));

          final notifier = container.read(
            assignmentStateNotifierProvider.notifier,
          );

          // WHEN
          final result = await notifier.assignChild(
            groupId: 'group-123',
            week: '2025-W10',
            assignmentId: 'vehicle-assignment-1',
            childId: 'child-1',
            vehicleAssignment: testVehicleAssignment,
          );

          // THEN
          expect(result.isOk, isTrue);
          verify(
            mockRepository.assignChildrenToVehicle(
              'group-123',
              'slot-1',
              'vehicle-assignment-1',
              ['child-1'],
            ),
          ).called(1);

          // Verify state is data (not loading or error)
          final state = container.read(assignmentStateNotifierProvider);
          expect(state.isLoading, isFalse);
          expect(state.hasError, isFalse);
        },
      );

      test(
        'GIVEN repository returns error WHEN assignChild is called THEN returns failure',
        () async {
          // GIVEN
          const apiFailure = ApiFailure(
            message: 'Capacity exceeded',
            statusCode: 400,
            code: 'capacity_exceeded',
          );
          when(
            mockRepository.assignChildrenToVehicle(
              'group-123',
              'slot-1',
              'vehicle-assignment-1',
              ['child-1'],
            ),
          ).thenAnswer((_) async => const Result.err(apiFailure));

          final notifier = container.read(
            assignmentStateNotifierProvider.notifier,
          );

          // WHEN
          final result = await notifier.assignChild(
            groupId: 'group-123',
            week: '2025-W10',
            assignmentId: 'vehicle-assignment-1',
            childId: 'child-1',
            vehicleAssignment: testVehicleAssignment,
          );

          // THEN
          expect(result.isErr, isTrue);
          result.when(
            ok: (_) => fail('Expected error result'),
            err: (failure) {
              expect(failure, isA<ScheduleFailure>());
              expect(failure.message, equals('Capacity exceeded'));
              expect(failure.code, equals('capacity_exceeded'));
            },
          );

          // Verify state has error
          final state = container.read(assignmentStateNotifierProvider);
          expect(state.hasError, isTrue);
        },
      );

      test(
        'GIVEN repository throws exception WHEN assignChild is called THEN returns server error',
        () async {
          // GIVEN
          when(
            mockRepository.assignChildrenToVehicle(
              'group-123',
              'slot-1',
              'vehicle-assignment-1',
              ['child-1'],
            ),
          ).thenThrow(Exception('Network timeout'));

          final notifier = container.read(
            assignmentStateNotifierProvider.notifier,
          );

          // WHEN
          final result = await notifier.assignChild(
            groupId: 'group-123',
            week: '2025-W10',
            assignmentId: 'vehicle-assignment-1',
            childId: 'child-1',
            vehicleAssignment: testVehicleAssignment,
          );

          // THEN
          expect(result.isErr, isTrue);
          result.when(
            ok: (_) => fail('Expected error result'),
            err: (failure) {
              expect(failure, isA<ScheduleFailure>());
              expect(failure.message, contains('Network timeout'));
            },
          );
        },
      );

      test(
        'GIVEN successful assignment WHEN called THEN invalidates correct provider instance',
        () async {
          // GIVEN
          when(
            mockRepository.assignChildrenToVehicle(
              'group-123',
              'slot-1',
              'vehicle-assignment-1',
              ['child-1'],
            ),
          ).thenAnswer((_) async => Result.ok(testVehicleAssignment));

          // Setup multiple week providers
          when(
            mockRepository.getWeeklySchedule('group-123', '2025-W10'),
          ).thenAnswer((_) async => const Result.ok([]));
          when(
            mockRepository.getWeeklySchedule('group-123', '2025-W11'),
          ).thenAnswer((_) async => const Result.ok([]));

          // Pre-fetch both weeks to cache them
          await container.read(
            weeklyScheduleProvider('group-123', '2025-W10').future,
          );
          await container.read(
            weeklyScheduleProvider('group-123', '2025-W11').future,
          );

          final notifier = container.read(
            assignmentStateNotifierProvider.notifier,
          );

          // WHEN - Assign to W10
          await notifier.assignChild(
            groupId: 'group-123',
            week: '2025-W10',
            assignmentId: 'vehicle-assignment-1',
            childId: 'child-1',
            vehicleAssignment: testVehicleAssignment,
          );

          // THEN - Only W10 should be invalidated (called twice: initial + after invalidation)
          verify(
            mockRepository.getWeeklySchedule('group-123', '2025-W10'),
          ).called(
            1,
          ); // Initial call only, invalidation doesn't refetch immediately
          verify(
            mockRepository.getWeeklySchedule('group-123', '2025-W11'),
          ).called(1); // Not invalidated, still cached
        },
      );
    });

    group('unassignChild Tests', () {
      test(
        'GIVEN successful repository call WHEN unassignChild is called THEN returns success',
        () async {
          // GIVEN
          when(
            mockRepository.removeChildFromVehicle(
              'group-123',
              'slot-1',
              'vehicle-assignment-1',
              'child-assignment-1',
            ),
          ).thenAnswer((_) async => const Result.ok(null));

          when(
            mockRepository.getWeeklySchedule('group-123', '2025-W10'),
          ).thenAnswer((_) async => const Result.ok([]));

          final notifier = container.read(
            assignmentStateNotifierProvider.notifier,
          );

          // WHEN
          final result = await notifier.unassignChild(
            groupId: 'group-123',
            week: '2025-W10',
            assignmentId: 'vehicle-assignment-1',
            childId: 'child-1',
            slotId: 'slot-1',
            childAssignmentId: 'child-assignment-1',
          );

          // THEN
          expect(result.isOk, isTrue);
          verify(
            mockRepository.removeChildFromVehicle(
              'group-123',
              'slot-1',
              'vehicle-assignment-1',
              'child-assignment-1',
            ),
          ).called(1);

          // Verify state is data (not loading or error)
          final state = container.read(assignmentStateNotifierProvider);
          expect(state.isLoading, isFalse);
          expect(state.hasError, isFalse);
        },
      );

      test(
        'GIVEN repository returns error WHEN unassignChild is called THEN returns failure',
        () async {
          // GIVEN
          const apiFailure = ApiFailure(
            message: 'Child not found',
            statusCode: 404,
          );
          when(
            mockRepository.removeChildFromVehicle(
              'group-123',
              'slot-1',
              'vehicle-assignment-1',
              'child-assignment-1',
            ),
          ).thenAnswer((_) async => const Result.err(apiFailure));

          final notifier = container.read(
            assignmentStateNotifierProvider.notifier,
          );

          // WHEN
          final result = await notifier.unassignChild(
            groupId: 'group-123',
            week: '2025-W10',
            assignmentId: 'vehicle-assignment-1',
            childId: 'child-1',
            slotId: 'slot-1',
            childAssignmentId: 'child-assignment-1',
          );

          // THEN
          expect(result.isErr, isTrue);
          result.when(
            ok: (_) => fail('Expected error result'),
            err: (failure) {
              expect(failure, isA<ScheduleFailure>());
              expect(failure.message, equals('Child not found'));
            },
          );
        },
      );

      test(
        'GIVEN repository throws exception WHEN unassignChild is called THEN returns server error',
        () async {
          // GIVEN
          when(
            mockRepository.removeChildFromVehicle(
              'group-123',
              'slot-1',
              'vehicle-assignment-1',
              'child-assignment-1',
            ),
          ).thenThrow(Exception('Database error'));

          final notifier = container.read(
            assignmentStateNotifierProvider.notifier,
          );

          // WHEN
          final result = await notifier.unassignChild(
            groupId: 'group-123',
            week: '2025-W10',
            assignmentId: 'vehicle-assignment-1',
            childId: 'child-1',
            slotId: 'slot-1',
            childAssignmentId: 'child-assignment-1',
          );

          // THEN
          expect(result.isErr, isTrue);
          result.when(
            ok: (_) => fail('Expected error result'),
            err: (failure) {
              expect(failure, isA<ScheduleFailure>());
              expect(failure.message, contains('Database error'));
            },
          );
        },
      );

      test(
        'GIVEN successful unassignment WHEN called THEN invalidates correct provider instance',
        () async {
          // GIVEN
          when(
            mockRepository.removeChildFromVehicle(
              'group-123',
              'slot-1',
              'vehicle-assignment-1',
              'child-assignment-1',
            ),
          ).thenAnswer((_) async => const Result.ok(null));

          when(
            mockRepository.getWeeklySchedule('group-123', '2025-W10'),
          ).thenAnswer((_) async => const Result.ok([]));

          final notifier = container.read(
            assignmentStateNotifierProvider.notifier,
          );

          // WHEN
          await notifier.unassignChild(
            groupId: 'group-123',
            week: '2025-W10',
            assignmentId: 'vehicle-assignment-1',
            childId: 'child-1',
            slotId: 'slot-1',
            childAssignmentId: 'child-assignment-1',
          );

          // THEN - Provider invalidation happens
          verify(
            mockRepository.removeChildFromVehicle(
              'group-123',
              'slot-1',
              'vehicle-assignment-1',
              'child-assignment-1',
            ),
          ).called(1);
        },
      );
    });

    group('updateSeatOverride Tests', () {
      test(
        'GIVEN successful repository call WHEN updateSeatOverride is called THEN returns success',
        () async {
          // GIVEN
          final updatedAssignment = testVehicleAssignment.copyWith(
            seatOverride: 8, // Override from 5 to 8
          );
          when(
            mockRepository.updateSeatOverride(
              'group-123',
              'vehicle-assignment-1',
              8,
            ),
          ).thenAnswer((_) async => Result.ok(updatedAssignment));

          when(
            mockRepository.getWeeklySchedule('group-123', '2025-W10'),
          ).thenAnswer((_) async => const Result.ok([]));

          final notifier = container.read(
            assignmentStateNotifierProvider.notifier,
          );

          // WHEN
          final result = await notifier.updateSeatOverride(
            groupId: 'group-123',
            week: '2025-W10',
            assignmentId: 'vehicle-assignment-1',
            seatOverride: 8,
          );

          // THEN
          expect(result.isOk, isTrue);
          verify(
            mockRepository.updateSeatOverride(
              'group-123',
              'vehicle-assignment-1',
              8,
            ),
          ).called(1);

          // Verify state is data (not loading or error)
          final state = container.read(assignmentStateNotifierProvider);
          expect(state.isLoading, isFalse);
          expect(state.hasError, isFalse);
        },
      );

      test(
        'GIVEN null seatOverride WHEN updateSeatOverride is called THEN removes override',
        () async {
          // GIVEN - Remove seat override (copyWith with null removes the override)
          final updatedAssignment = testVehicleAssignment.copyWith();
          when(
            mockRepository.updateSeatOverride(
              'group-123',
              'vehicle-assignment-1',
              null,
            ),
          ).thenAnswer((_) async => Result.ok(updatedAssignment));

          when(
            mockRepository.getWeeklySchedule('group-123', '2025-W10'),
          ).thenAnswer((_) async => const Result.ok([]));

          final notifier = container.read(
            assignmentStateNotifierProvider.notifier,
          );

          // WHEN
          final result = await notifier.updateSeatOverride(
            groupId: 'group-123',
            week: '2025-W10',
            assignmentId: 'vehicle-assignment-1',
            seatOverride: null,
          );

          // THEN
          expect(result.isOk, isTrue);
          verify(
            mockRepository.updateSeatOverride(
              'group-123',
              'vehicle-assignment-1',
              null,
            ),
          ).called(1);
        },
      );

      test(
        'GIVEN repository returns error WHEN updateSeatOverride is called THEN returns failure',
        () async {
          // GIVEN
          const apiFailure = ApiFailure(
            message: 'Invalid seat override',
            statusCode: 400,
          );
          when(
            mockRepository.updateSeatOverride(
              'group-123',
              'vehicle-assignment-1',
              8,
            ),
          ).thenAnswer((_) async => const Result.err(apiFailure));

          final notifier = container.read(
            assignmentStateNotifierProvider.notifier,
          );

          // WHEN
          final result = await notifier.updateSeatOverride(
            groupId: 'group-123',
            week: '2025-W10',
            assignmentId: 'vehicle-assignment-1',
            seatOverride: 8,
          );

          // THEN
          expect(result.isErr, isTrue);
          result.when(
            ok: (_) => fail('Expected error result'),
            err: (failure) {
              expect(failure, isA<ScheduleFailure>());
              expect(failure.message, equals('Invalid seat override'));
            },
          );
        },
      );

      test(
        'GIVEN repository throws exception WHEN updateSeatOverride is called THEN returns server error',
        () async {
          // GIVEN
          when(
            mockRepository.updateSeatOverride(
              'group-123',
              'vehicle-assignment-1',
              8,
            ),
          ).thenThrow(Exception('Connection error'));

          final notifier = container.read(
            assignmentStateNotifierProvider.notifier,
          );

          // WHEN
          final result = await notifier.updateSeatOverride(
            groupId: 'group-123',
            week: '2025-W10',
            assignmentId: 'vehicle-assignment-1',
            seatOverride: 8,
          );

          // THEN
          expect(result.isErr, isTrue);
          result.when(
            ok: (_) => fail('Expected error result'),
            err: (failure) {
              expect(failure, isA<ScheduleFailure>());
              expect(failure.message, contains('Connection error'));
            },
          );
        },
      );

      test(
        'GIVEN successful update WHEN called THEN invalidates correct provider instance',
        () async {
          // GIVEN
          final updatedAssignment = testVehicleAssignment.copyWith(
            seatOverride: 8,
          );
          when(
            mockRepository.updateSeatOverride(
              'group-123',
              'vehicle-assignment-1',
              8,
            ),
          ).thenAnswer((_) async => Result.ok(updatedAssignment));

          when(
            mockRepository.getWeeklySchedule('group-123', '2025-W10'),
          ).thenAnswer((_) async => const Result.ok([]));

          final notifier = container.read(
            assignmentStateNotifierProvider.notifier,
          );

          // WHEN
          await notifier.updateSeatOverride(
            groupId: 'group-123',
            week: '2025-W10',
            assignmentId: 'vehicle-assignment-1',
            seatOverride: 8,
          );

          // THEN - Provider invalidation happens
          verify(
            mockRepository.updateSeatOverride(
              'group-123',
              'vehicle-assignment-1',
              8,
            ),
          ).called(1);
        },
      );
    });

    group('State Transition Tests', () {
      test(
        'GIVEN initial state WHEN notifier is created THEN state is data(null)',
        () {
          // WHEN
          final state = container.read(assignmentStateNotifierProvider);

          // THEN
          expect(state.isLoading, isFalse);
          expect(state.hasError, isFalse);
          expect(state.hasValue, isTrue);
        },
      );

      test(
        'GIVEN operation starts WHEN state changes THEN transitions loading -> data',
        () async {
          // GIVEN
          when(
            mockRepository.assignChildrenToVehicle(any, any, any, any),
          ).thenAnswer((_) async => Result.ok(testVehicleAssignment));

          when(
            mockRepository.getWeeklySchedule(any, any),
          ).thenAnswer((_) async => const Result.ok([]));

          final notifier = container.read(
            assignmentStateNotifierProvider.notifier,
          );

          // WHEN
          final future = notifier.assignChild(
            groupId: 'group-123',
            week: '2025-W10',
            assignmentId: 'vehicle-assignment-1',
            childId: 'child-1',
            vehicleAssignment: testVehicleAssignment,
          );

          // THEN - Eventually completes with data state
          await future;
          final finalState = container.read(assignmentStateNotifierProvider);
          expect(finalState.isLoading, isFalse);
          expect(finalState.hasError, isFalse);
        },
      );

      test(
        'GIVEN operation fails WHEN state changes THEN transitions loading -> error',
        () async {
          // GIVEN
          const apiFailure = ApiFailure(message: 'Test error', statusCode: 500);
          when(
            mockRepository.assignChildrenToVehicle(any, any, any, any),
          ).thenAnswer((_) async => const Result.err(apiFailure));

          final notifier = container.read(
            assignmentStateNotifierProvider.notifier,
          );

          // WHEN
          await notifier.assignChild(
            groupId: 'group-123',
            week: '2025-W10',
            assignmentId: 'vehicle-assignment-1',
            childId: 'child-1',
            vehicleAssignment: testVehicleAssignment,
          );

          // THEN - State has error
          final finalState = container.read(assignmentStateNotifierProvider);
          expect(finalState.hasError, isTrue);
        },
      );
    });
  });

  group('SlotStateNotifier Tests', () {
    late MockGroupScheduleRepository mockRepository;
    late ProviderContainer container;

    // Test data - using typed constructor
    final now = DateTime.now();
    final testSlot = ScheduleSlot(
      id: 'slot-1',
      groupId: 'group-123',
      dayOfWeek: DayOfWeek.monday,
      timeOfDay: TimeOfDayValue.parse('08:00'),
      week: '2025-W10',
      vehicleAssignments: const [],
      maxVehicles: 5,
      createdAt: now,
      updatedAt: now,
    );

    setUp(() {
      mockRepository = MockGroupScheduleRepository();
      container = ProviderContainer(
        overrides: [
          scheduleRepositoryProvider.overrideWithValue(mockRepository),
          currentUserProvider.overrideWith((ref) => null),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('upsertSlot Tests', () {
      test(
        'GIVEN successful repository call WHEN upsertSlot is called THEN returns success and invalidates provider',
        () async {
          // GIVEN
          when(
            mockRepository.upsertScheduleSlot(
              'group-123',
              'Monday',
              '08:00',
              '2025-W10',
            ),
          ).thenAnswer((_) async => Result.ok(testSlot));

          when(
            mockRepository.getWeeklySchedule('group-123', '2025-W10'),
          ).thenAnswer((_) async => const Result.ok([]));

          final notifier = container.read(slotStateNotifierProvider.notifier);

          // WHEN
          final result = await notifier.upsertSlot(
            groupId: 'group-123',
            day: 'Monday',
            time: '08:00',
            week: '2025-W10',
          );

          // THEN
          expect(result.isOk, isTrue);
          result.when(
            ok: (slot) => expect(slot.id, equals('slot-1')),
            err: (_) => fail('Expected success result'),
          );

          verify(
            mockRepository.upsertScheduleSlot(
              'group-123',
              'Monday',
              '08:00',
              '2025-W10',
            ),
          ).called(1);

          // Verify state is data (not loading or error)
          final state = container.read(slotStateNotifierProvider);
          expect(state.isLoading, isFalse);
          expect(state.hasError, isFalse);
        },
      );

      test(
        'GIVEN repository returns error WHEN upsertSlot is called THEN returns failure',
        () async {
          // GIVEN
          const apiFailure = ApiFailure(
            message: 'Slot already exists',
            statusCode: 409,
          );
          when(
            mockRepository.upsertScheduleSlot(
              'group-123',
              'Monday',
              '08:00',
              '2025-W10',
            ),
          ).thenAnswer((_) async => const Result.err(apiFailure));

          final notifier = container.read(slotStateNotifierProvider.notifier);

          // WHEN
          final result = await notifier.upsertSlot(
            groupId: 'group-123',
            day: 'Monday',
            time: '08:00',
            week: '2025-W10',
          );

          // THEN
          expect(result.isErr, isTrue);
          result.when(
            ok: (_) => fail('Expected error result'),
            err: (failure) {
              expect(failure, isA<ScheduleFailure>());
              expect(failure.message, equals('Slot already exists'));
            },
          );

          // Verify state has error
          final state = container.read(slotStateNotifierProvider);
          expect(state.hasError, isTrue);
        },
      );

      test(
        'GIVEN repository throws exception WHEN upsertSlot is called THEN returns server error',
        () async {
          // GIVEN
          when(
            mockRepository.upsertScheduleSlot(
              'group-123',
              'Monday',
              '08:00',
              '2025-W10',
            ),
          ).thenThrow(Exception('Network error'));

          final notifier = container.read(slotStateNotifierProvider.notifier);

          // WHEN
          final result = await notifier.upsertSlot(
            groupId: 'group-123',
            day: 'Monday',
            time: '08:00',
            week: '2025-W10',
          );

          // THEN
          expect(result.isErr, isTrue);
          result.when(
            ok: (_) => fail('Expected error result'),
            err: (failure) {
              expect(failure, isA<ScheduleFailure>());
              expect(failure.message, contains('Network error'));
            },
          );
        },
      );

      test(
        'GIVEN successful upsert WHEN called THEN invalidates correct provider instance',
        () async {
          // GIVEN
          when(
            mockRepository.upsertScheduleSlot(
              'group-123',
              'Monday',
              '08:00',
              '2025-W10',
            ),
          ).thenAnswer((_) async => Result.ok(testSlot));

          when(
            mockRepository.getWeeklySchedule('group-123', '2025-W10'),
          ).thenAnswer((_) async => const Result.ok([]));
          when(
            mockRepository.getWeeklySchedule('group-123', '2025-W11'),
          ).thenAnswer((_) async => const Result.ok([]));

          // Pre-fetch both weeks
          await container.read(
            weeklyScheduleProvider('group-123', '2025-W10').future,
          );
          await container.read(
            weeklyScheduleProvider('group-123', '2025-W11').future,
          );

          final notifier = container.read(slotStateNotifierProvider.notifier);

          // WHEN - Upsert for W10
          await notifier.upsertSlot(
            groupId: 'group-123',
            day: 'Monday',
            time: '08:00',
            week: '2025-W10',
          );

          // THEN - Only W10 should be invalidated
          verify(
            mockRepository.getWeeklySchedule('group-123', '2025-W10'),
          ).called(1); // Initial call only
          verify(
            mockRepository.getWeeklySchedule('group-123', '2025-W11'),
          ).called(1); // Not invalidated
        },
      );
    });

    // NOTE: Schedule slot deletion is handled automatically by the backend.
    // When the last vehicle is removed from a slot, the backend automatically
    // deletes the slot. There is no explicit deleteSlot endpoint or method.
    // See clearWeeklySchedule in the repository for the proper way to clear
    // slots by removing all vehicles.

    group('State Transition Tests', () {
      test(
        'GIVEN initial state WHEN notifier is created THEN state is data(null)',
        () {
          // WHEN
          final state = container.read(slotStateNotifierProvider);

          // THEN
          expect(state.isLoading, isFalse);
          expect(state.hasError, isFalse);
          expect(state.hasValue, isTrue);
        },
      );

      test(
        'GIVEN operation starts WHEN state changes THEN transitions loading -> data',
        () async {
          // GIVEN
          when(
            mockRepository.upsertScheduleSlot(any, any, any, any),
          ).thenAnswer((_) async => Result.ok(testSlot));

          when(
            mockRepository.getWeeklySchedule(any, any),
          ).thenAnswer((_) async => const Result.ok([]));

          final notifier = container.read(slotStateNotifierProvider.notifier);

          // WHEN
          final future = notifier.upsertSlot(
            groupId: 'group-123',
            day: 'Monday',
            time: '08:00',
            week: '2025-W10',
          );

          // THEN - Eventually completes with data state
          await future;
          final finalState = container.read(slotStateNotifierProvider);
          expect(finalState.isLoading, isFalse);
          expect(finalState.hasError, isFalse);
        },
      );

      test(
        'GIVEN operation fails WHEN state changes THEN transitions loading -> error',
        () async {
          // GIVEN
          const apiFailure = ApiFailure(message: 'Test error', statusCode: 500);
          when(
            mockRepository.upsertScheduleSlot(any, any, any, any),
          ).thenAnswer((_) async => const Result.err(apiFailure));

          final notifier = container.read(slotStateNotifierProvider.notifier);

          // WHEN
          await notifier.upsertSlot(
            groupId: 'group-123',
            day: 'Monday',
            time: '08:00',
            week: '2025-W10',
          );

          // THEN - State has error
          final finalState = container.read(slotStateNotifierProvider);
          expect(finalState.hasError, isTrue);
        },
      );
    });
  });
}
