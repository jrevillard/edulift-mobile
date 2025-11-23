// EduLift Mobile - Schedule Repository Mock Factory
// Phase 2.3: Separate factory per repository as required by execution plan

import 'package:mockito/mockito.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/core/domain/entities/schedule.dart';
// Schedule entity removed from family domain

// Generated mocks
import '../test_mocks.mocks.dart';

/// Schedule Repository Mock Factory
/// TRUTH: Provides consistent schedule mock behavior for GroupScheduleRepository
class ScheduleRepositoryMockFactory {
  // Groups Schedule Repository
  static MockGroupScheduleRepository createGroupScheduleRepository({
    bool shouldSucceed = true,
    List<ScheduleSlot>? mockSlots,
  }) {
    final mock = MockGroupScheduleRepository();
    final slots = mockSlots ?? [_createMockScheduleSlot()];

    if (shouldSucceed) {
      when(
        mock.getWeeklySchedule(any, any),
      ).thenAnswer((_) async => Result.ok(slots));
    } else {
      when(mock.getWeeklySchedule(any, any)).thenAnswer(
        (_) async =>
            const Result.err(ApiFailure(message: 'Schedule fetch failed')),
      );
    }

    return mock;
  }

  // Family Schedule Repository - REMOVED
  // Schedule functionality moved to separate domain
  static dynamic createFamilyScheduleRepository({
    bool shouldSucceed = true,
    List<Map<String, dynamic>>? mockSchedules,
  }) {
    throw UnimplementedError('Schedule functionality moved to separate domain');
  }

  // ========================================
  // HELPER METHODS
  // ========================================

  static ScheduleSlot _createMockScheduleSlot() {
    final now = DateTime.now();
    return ScheduleSlot(
      id: 'test-slot-id',
      groupId: 'test-group-id',
      dayOfWeek: DayOfWeek.monday,
      timeOfDay: const TimeOfDayValue(8, 0),
      week: '2024-01',
      vehicleAssignments: const [],
      maxVehicles: 5,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Mock schedule data helper removed - no longer needed
}
