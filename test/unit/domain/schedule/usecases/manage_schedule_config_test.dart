import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import 'package:edulift/features/schedule/domain/usecases/manage_schedule_config.dart';
import 'package:edulift/core/domain/entities/schedule.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';

import '../../../../test_mocks/test_mocks.dart';

/// Helper to create test ScheduleConfig objects with all required parameters
ScheduleConfig createTestScheduleConfig({
  String id = 'test-config-id',
  String groupId = 'test-group-id',
  Map<String, List<String>>? scheduleHours,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return ScheduleConfig(
    id: id,
    groupId: groupId,
    scheduleHours:
        scheduleHours ??
        {
          'MONDAY': ['08:00'],
          'TUESDAY': ['08:00'],
        },
    createdAt: createdAt ?? DateTime(2024),
    updatedAt: updatedAt ?? DateTime(2024),
  );
}

void main() {
  // Setup Mockito dummy values for Result types
  setUpAll(() {
    setupMockFallbacks();
  });

  group('GetScheduleConfig', () {
    late GetScheduleConfig usecase;
    late MockGroupScheduleRepository mockRepository;

    setUp(() {
      mockRepository = MockGroupScheduleRepository();
      reset(mockRepository);
      usecase = GetScheduleConfig(mockRepository);
    });

    tearDown(() {
      clearInteractions(mockRepository);
    });

    group('Construction', () {
      test('should create usecase with repository dependency', () {
        // Arrange & Act
        final usecase = GetScheduleConfig(mockRepository);

        // Assert
        expect(usecase.repository, equals(mockRepository));
      });
    });

    group('Success Cases', () {
      test('should get schedule config successfully', () async {
        // Arrange
        final params = GetScheduleConfigParams(groupId: 'group-123');
        final expectedConfig = createTestScheduleConfig(
          id: 'config-1',
          groupId: 'group-123',
        );

        when(
          mockRepository.getScheduleConfig(any),
        ).thenAnswer((_) async => Result.ok(expectedConfig));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.value, equals(expectedConfig));
        verify(mockRepository.getScheduleConfig('group-123')).called(1);
      });
    });

    group('Failure Cases', () {
      test('should return error when repository fails', () async {
        // Arrange
        final params = GetScheduleConfigParams(groupId: 'group-123');
        final failure = ApiFailure.notFound();

        when(
          mockRepository.getScheduleConfig(any),
        ).thenAnswer((_) async => Result.err(failure));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, equals(failure));
      });

      test('should handle network errors gracefully', () async {
        // Arrange
        final params = GetScheduleConfigParams(groupId: 'group-123');
        final failure = ApiFailure.network();

        when(
          mockRepository.getScheduleConfig(any),
        ).thenAnswer((_) async => Result.err(failure));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, equals(failure));
      });

      test('should handle unauthorized access', () async {
        // Arrange
        final params = GetScheduleConfigParams(groupId: 'group-123');
        final failure = ApiFailure.unauthorized();

        when(
          mockRepository.getScheduleConfig(any),
        ).thenAnswer((_) async => Result.err(failure));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, equals(failure));
      });
    });

    group('Business Logic Validation', () {
      test('should pass group ID unchanged to repository', () async {
        // Arrange
        final params = GetScheduleConfigParams(groupId: 'test-group-456');
        final mockConfig = createTestScheduleConfig(
          id: 'config-2',
          groupId: 'test-group-456',
        );

        when(
          mockRepository.getScheduleConfig(any),
        ).thenAnswer((_) async => Result.ok(mockConfig));

        // Act
        await usecase.call(params);

        // Assert
        verify(mockRepository.getScheduleConfig('test-group-456')).called(1);
        verifyNoMoreInteractions(mockRepository);
      });
    });

    group('Edge Cases', () {
      test('should handle empty group ID gracefully', () async {
        // Arrange
        final params = GetScheduleConfigParams(groupId: '');
        final failure = ApiFailure.validationError();

        when(
          mockRepository.getScheduleConfig(any),
        ).thenAnswer((_) async => Result.err(failure));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, equals(failure));
      });
    });
  });

  group('UpdateScheduleConfig', () {
    late UpdateScheduleConfig usecase;
    late MockGroupScheduleRepository mockRepository;

    setUp(() {
      mockRepository = MockGroupScheduleRepository();
      reset(mockRepository);
      usecase = UpdateScheduleConfig(mockRepository);
    });

    tearDown(() {
      clearInteractions(mockRepository);
    });

    group('Success Cases', () {
      test('should update schedule config successfully', () async {
        // Arrange
        final config = createTestScheduleConfig(
          groupId: 'group-123',
          scheduleHours: {
            'MONDAY': ['08:00', '15:00'],
            'TUESDAY': ['08:00', '15:00'],
          },
        );
        final params = UpdateScheduleConfigParams(
          groupId: 'group-123',
          config: config,
        );

        when(
          mockRepository.updateScheduleConfig(any, any),
        ).thenAnswer((_) async => Result.ok(config));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.value, equals(config));
        verify(
          mockRepository.updateScheduleConfig('group-123', config),
        ).called(1);
      });

      test('should handle partial config updates', () async {
        // Arrange
        final config = createTestScheduleConfig(
          groupId: 'group-456',
          scheduleHours: {
            'MONDAY': ['08:00', '15:00'],
            'TUESDAY': ['08:00', '15:00'],
            'WEDNESDAY': ['08:00', '15:00'],
            'THURSDAY': ['08:00', '15:00'],
            'FRIDAY': ['08:00', '15:00'],
          },
        );
        final params = UpdateScheduleConfigParams(
          groupId: 'group-456',
          config: config,
        );

        when(
          mockRepository.updateScheduleConfig(any, any),
        ).thenAnswer((_) async => Result.ok(config));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.value, equals(config));
      });

      test('should update time slots correctly', () async {
        // Arrange
        final config = createTestScheduleConfig(
          groupId: 'group-789',
          scheduleHours: {
            'MONDAY': ['07:30', '08:00', '08:30'],
            'TUESDAY': ['07:30', '08:00'],
            'WEDNESDAY': ['08:00'],
          },
        );
        final params = UpdateScheduleConfigParams(
          groupId: 'group-789',
          config: config,
        );

        when(
          mockRepository.updateScheduleConfig(any, any),
        ).thenAnswer((_) async => Result.ok(config));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isSuccess, isTrue);
        // Count total time slots across all days
        final totalTimeSlots = config.scheduleHours.values.fold(
          0,
          (sum, slots) => sum + slots.length,
        );
        expect(totalTimeSlots, equals(6)); // 3 + 2 + 1 = 6 time slots total
      });

      test('should update active days correctly', () async {
        // Arrange
        final config = createTestScheduleConfig(
          groupId: 'group-abc',
          scheduleHours: {
            'MONDAY': ['08:00', '15:00'],
            'WEDNESDAY': ['08:00', '15:00'],
            'FRIDAY': ['08:00', '15:00'],
          },
        );
        final params = UpdateScheduleConfigParams(
          groupId: 'group-abc',
          config: config,
        );

        when(
          mockRepository.updateScheduleConfig(any, any),
        ).thenAnswer((_) async => Result.ok(config));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isSuccess, isTrue);
        // Extract active days from scheduleHours keys
        final activeDays = config.scheduleHours.keys
            .where((day) => config.scheduleHours[day]!.isNotEmpty)
            .toList();
        expect(activeDays, contains('MONDAY'));
        expect(activeDays, contains('WEDNESDAY'));
        expect(activeDays, contains('FRIDAY'));
      });
    });

    group('Validation Tests', () {
      test('should reject config with empty active days', () async {
        // Arrange
        final config = createTestScheduleConfig(
          groupId: 'group-validation',
          scheduleHours: {}, // Empty schedule hours means no active days
        );
        final params = UpdateScheduleConfigParams(
          groupId: 'group-validation',
          config: config,
        );

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, isA<ApiFailure>());
        verifyNever(mockRepository.updateScheduleConfig(any, any));
      });

      test('should reject config with empty time slots', () async {
        // Arrange
        final config = createTestScheduleConfig(
          groupId: 'group-validation',
          scheduleHours: {
            'MONDAY': [], // Empty time slots for active day
            'TUESDAY': [],
          },
        );
        final params = UpdateScheduleConfigParams(
          groupId: 'group-validation',
          config: config,
        );

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, isA<ApiFailure>());
        verifyNever(mockRepository.updateScheduleConfig(any, any));
      });

      // Note: Removed validation test for maxVehiclesPerSlot as this attribute was removed from ScheduleConfig
    });

    group('Failure Cases', () {
      test('should handle repository update failures', () async {
        // Arrange
        final config = createTestScheduleConfig(groupId: 'group-fail');
        final params = UpdateScheduleConfigParams(
          groupId: 'group-fail',
          config: config,
        );
        final failure = ApiFailure.serverError();

        when(
          mockRepository.updateScheduleConfig(any, any),
        ).thenAnswer((_) async => Result.err(failure));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, equals(failure));
      });
    });
  });

  group('ResetScheduleConfig', () {
    late ResetScheduleConfig usecase;
    late MockGroupScheduleRepository mockRepository;

    setUp(() {
      mockRepository = MockGroupScheduleRepository();
      usecase = ResetScheduleConfig(mockRepository);
    });

    group('Success Cases', () {
      test('should reset schedule config successfully', () async {
        // Arrange
        final params = ResetScheduleConfigParams(groupId: 'group-reset');
        final defaultConfig = createTestScheduleConfig(groupId: 'group-reset');

        when(
          mockRepository.resetScheduleConfig(any),
        ).thenAnswer((_) async => Result.ok(defaultConfig));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.value, equals(defaultConfig));
        verify(mockRepository.resetScheduleConfig('group-reset')).called(1);
      });
    });

    group('Failure Cases', () {
      test('should handle reset failures', () async {
        // Arrange
        final params = ResetScheduleConfigParams(groupId: 'group-reset-fail');
        final failure = ApiFailure.serverError();

        when(
          mockRepository.resetScheduleConfig(any),
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
