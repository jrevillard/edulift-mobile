import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:edulift/features/schedule/domain/usecases/get_weekly_schedule.dart';
import 'package:edulift/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:edulift/core/domain/entities/schedule.dart';
import 'package:edulift/core/domain/entities/family/child_assignment.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';

import '../../../../../test_mocks/get_weekly_schedule_test.mocks.dart';

@GenerateMocks([GroupScheduleRepository])
void main() {
  group('GetWeeklySchedule UseCase', () {
    late MockGroupScheduleRepository mockRepository;
    late GetWeeklySchedule getWeeklySchedule;

    setUp(() {
      mockRepository = MockGroupScheduleRepository();
      getWeeklySchedule = GetWeeklySchedule(mockRepository);
    });

    // Test data setup
    final testScheduleSlots = [
      ScheduleSlot(
        id: 'slot1',
        groupId: 'group1',
        dayOfWeek: DayOfWeek.monday,
        timeOfDay: const TimeOfDayValue(8, 0),
        week: '2024-W01',
        vehicleAssignments: [
          VehicleAssignment(
            id: 'va1',
            scheduleSlotId: 'slot1',
            vehicleId: 'vehicle1',
            assignedAt: DateTime.now(),
            assignedBy: 'user1',
            vehicleName: 'Family Van',
            capacity: 6,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            childAssignments: [
              ChildAssignment.transportation(
                id: 'ca1',
                childId: 'child1',
                groupId: 'group1',
                scheduleSlotId: 'slot1',
                vehicleAssignmentId: 'va1',
                assignedAt: DateTime.now(),
                status: AssignmentStatus.confirmed,
                assignmentDate: DateTime.now(),
              ),
              ChildAssignment.transportation(
                id: 'ca2',
                childId: 'child2',
                groupId: 'group1',
                scheduleSlotId: 'slot1',
                vehicleAssignmentId: 'va1',
                assignedAt: DateTime.now(),
                status: AssignmentStatus.confirmed,
                assignmentDate: DateTime.now(),
              ),
            ],
          ),
        ],
        maxVehicles: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ScheduleSlot(
        id: 'slot2',
        groupId: 'group1',
        dayOfWeek: DayOfWeek.wednesday,
        timeOfDay: const TimeOfDayValue(15, 30),
        week: '2024-W01',
        vehicleAssignments: const [],
        maxVehicles: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    test(
      'should return weekly schedule when repository call is successful',
      () async {
        // Arrange
        final params = GetWeeklyScheduleParams(
          groupId: 'group1',
          week: '2024-W01',
        );
        when(
          mockRepository.getWeeklySchedule('group1', '2024-W01'),
        ).thenAnswer((_) async => Result.ok(testScheduleSlots));

        // Act
        final result = await getWeeklySchedule(params);

        // Assert
        expect(result.isOk, isTrue);
        expect(
          result.fold((failure) => null, (success) => success),
          equals(testScheduleSlots),
        );
        expect(testScheduleSlots.length, equals(2));
        verify(
          mockRepository.getWeeklySchedule('group1', '2024-W01'),
        ).called(1);
      },
    );

    test('should return failure when repository call fails', () async {
      // Arrange
      final apiFailure = ApiFailure.serverError(message: 'Server error');
      final params = GetWeeklyScheduleParams(
        groupId: 'group1',
        week: '2024-W01',
      );
      when(
        mockRepository.getWeeklySchedule('group1', '2024-W01'),
      ).thenAnswer((_) async => Result.err(apiFailure));

      // Act
      final result = await getWeeklySchedule(params);

      // Assert
      expect(result.isErr, isTrue);
      expect(
        result.fold((failure) => failure, (success) => null),
        equals(apiFailure),
      );
      verify(mockRepository.getWeeklySchedule('group1', '2024-W01')).called(1);
    });

    test(
      'should return empty list when repository returns empty schedule',
      () async {
        // Arrange
        final params = GetWeeklyScheduleParams(
          groupId: 'group1',
          week: '2024-W01',
        );
        when(
          mockRepository.getWeeklySchedule('group1', '2024-W01'),
        ).thenAnswer((_) async => const Result.ok(<ScheduleSlot>[]));

        // Act
        final result = await getWeeklySchedule(params);

        // Assert
        expect(result.isOk, isTrue);
        expect(result.fold((failure) => null, (success) => success), isEmpty);
        verify(
          mockRepository.getWeeklySchedule('group1', '2024-W01'),
        ).called(1);
      },
    );

    test('should handle network timeout failure', () async {
      // Arrange
      final timeoutFailure = ApiFailure.timeout(url: 'https://api.example.com');
      final params = GetWeeklyScheduleParams(
        groupId: 'group1',
        week: '2024-W01',
      );
      when(
        mockRepository.getWeeklySchedule('group1', '2024-W01'),
      ).thenAnswer((_) async => Result.err(timeoutFailure));

      // Act
      final result = await getWeeklySchedule(params);

      // Assert
      expect(result.isErr, isTrue);
      expect(
        result.fold((failure) => failure, (success) => null),
        equals(timeoutFailure),
      );
      expect(timeoutFailure.statusCode, equals(408));
      verify(mockRepository.getWeeklySchedule('group1', '2024-W01')).called(1);
    });

    test('should handle unauthorized access failure', () async {
      // Arrange
      final unauthorizedFailure = ApiFailure.unauthorized();
      final params = GetWeeklyScheduleParams(
        groupId: 'group1',
        week: '2024-W01',
      );
      when(
        mockRepository.getWeeklySchedule('group1', '2024-W01'),
      ).thenAnswer((_) async => Result.err(unauthorizedFailure));

      // Act
      final result = await getWeeklySchedule(params);

      // Assert
      expect(result.isErr, isTrue);
      expect(
        result.fold((failure) => failure, (success) => null),
        equals(unauthorizedFailure),
      );
      expect(unauthorizedFailure.statusCode, equals(401));
      verify(mockRepository.getWeeklySchedule('group1', '2024-W01')).called(1);
    });

    test('should handle not found failure', () async {
      // Arrange
      final notFoundFailure = ApiFailure.notFound(resource: 'Group');
      final params = GetWeeklyScheduleParams(
        groupId: 'nonexistent-group',
        week: '2024-W01',
      );
      when(
        mockRepository.getWeeklySchedule('nonexistent-group', '2024-W01'),
      ).thenAnswer((_) async => Result.err(notFoundFailure));

      // Act
      final result = await getWeeklySchedule(params);

      // Assert
      expect(result.isErr, isTrue);
      expect(
        result.fold((failure) => failure, (success) => null),
        equals(notFoundFailure),
      );
      expect(notFoundFailure.statusCode, equals(404));
      verify(
        mockRepository.getWeeklySchedule('nonexistent-group', '2024-W01'),
      ).called(1);
    });

    test('should handle network connectivity failure', () async {
      // Arrange
      final networkFailure = ApiFailure.noConnection();
      final params = GetWeeklyScheduleParams(
        groupId: 'group1',
        week: '2024-W01',
      );
      when(
        mockRepository.getWeeklySchedule('group1', '2024-W01'),
      ).thenAnswer((_) async => Result.err(networkFailure));

      // Act
      final result = await getWeeklySchedule(params);

      // Assert
      expect(result.isErr, isTrue);
      expect(
        result.fold((failure) => failure, (success) => null),
        equals(networkFailure),
      );
      expect(networkFailure.statusCode, equals(0));
      verify(mockRepository.getWeeklySchedule('group1', '2024-W01')).called(1);
    });

    test('should pass correct parameters to repository', () async {
      // Arrange
      final params = GetWeeklyScheduleParams(
        groupId: 'group123',
        week: '2024-W15',
      );
      when(
        mockRepository.getWeeklySchedule('group123', '2024-W15'),
      ).thenAnswer((_) async => Result.ok(testScheduleSlots));

      // Act
      await getWeeklySchedule(params);

      // Assert
      verify(
        mockRepository.getWeeklySchedule('group123', '2024-W15'),
      ).called(1);
    });

    test('should handle malformed week format', () async {
      // Arrange
      final validationFailure = ApiFailure.validationError(
        message: 'Invalid week format',
        code: 'invalid_week_format',
      );
      final params = GetWeeklyScheduleParams(
        groupId: 'group1',
        week: 'invalid-week',
      );
      when(
        mockRepository.getWeeklySchedule('group1', 'invalid-week'),
      ).thenAnswer((_) async => Result.err(validationFailure));

      // Act
      final result = await getWeeklySchedule(params);

      // Assert
      expect(result.isErr, isTrue);
      expect(
        result.fold((failure) => failure, (success) => null),
        equals(validationFailure),
      );
      expect(validationFailure.statusCode, equals(422));
      verify(
        mockRepository.getWeeklySchedule('group1', 'invalid-week'),
      ).called(1);
    });

    test('should return schedule slots as provided by repository', () async {
      // Arrange - Create schedule slots in specific order
      final scheduleSlots = [
        ScheduleSlot(
          id: 'friday-slot',
          groupId: 'group1',
          dayOfWeek: DayOfWeek.friday,
          timeOfDay: const TimeOfDayValue(10, 0),
          week: '2024-W01',
          vehicleAssignments: const [],
          maxVehicles: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ScheduleSlot(
          id: 'monday-slot',
          groupId: 'group1',
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: const TimeOfDayValue(8, 0),
          week: '2024-W01',
          vehicleAssignments: const [],
          maxVehicles: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ScheduleSlot(
          id: 'wednesday-slot',
          groupId: 'group1',
          dayOfWeek: DayOfWeek.wednesday,
          timeOfDay: const TimeOfDayValue(15, 30),
          week: '2024-W01',
          vehicleAssignments: const [],
          maxVehicles: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final params = GetWeeklyScheduleParams(
        groupId: 'group1',
        week: '2024-W01',
      );
      when(
        mockRepository.getWeeklySchedule('group1', '2024-W01'),
      ).thenAnswer((_) async => Result.ok(scheduleSlots));

      // Act
      final result = await getWeeklySchedule(params);

      // Assert
      expect(result.isOk, isTrue);
      expect(scheduleSlots.length, equals(3));
      final returnedSlots = result.fold(
        (failure) => null,
        (success) => success,
      )!;
      // The use case doesn't sort, it returns slots as provided by repository
      expect(returnedSlots[0].dayOfWeek, equals(DayOfWeek.friday));
      expect(returnedSlots[1].dayOfWeek, equals(DayOfWeek.monday));
      expect(returnedSlots[2].dayOfWeek, equals(DayOfWeek.wednesday));
    });

    test('should preserve vehicle assignment data in schedule', () async {
      // Arrange
      final params = GetWeeklyScheduleParams(
        groupId: 'group1',
        week: '2024-W01',
      );
      when(
        mockRepository.getWeeklySchedule('group1', '2024-W01'),
      ).thenAnswer((_) async => Result.ok(testScheduleSlots));

      // Act
      final result = await getWeeklySchedule(params);

      // Assert
      expect(result.isOk, isTrue);
      final scheduleSlots = result.fold(
        (failure) => null,
        (success) => success,
      )!;
      final mondaySlot = scheduleSlots.firstWhere(
        (slot) => slot.dayOfWeek == DayOfWeek.monday,
      );
      expect(mondaySlot.vehicleAssignments.length, equals(1));
      expect(
        mondaySlot.vehicleAssignments.first.vehicleName,
        equals('Family Van'),
      );
      expect(
        mondaySlot.vehicleAssignments.first.childAssignments.length,
        equals(2),
      );
    });
  });
}
