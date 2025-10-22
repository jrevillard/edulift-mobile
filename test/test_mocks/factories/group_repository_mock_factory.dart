// EduLift Mobile - Group Repository Mock Factory
// Phase 2.3: Separate factory per repository as required by execution plan

import 'package:mockito/mockito.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/core/domain/entities/groups/group.dart';

// Generated mocks
import '../generated_mocks.dart';

/// Group Repository Mock Factory
/// TRUTH: Provides consistent group mock behavior
class GroupRepositoryMockFactory {
  static MockGroupRepository createGroupRepository({
    bool shouldSucceed = true,
    Group? mockGroup,
  }) {
    final mock = MockGroupRepository();
    final group = mockGroup ?? _createMockGroup();

    if (shouldSucceed) {
      when(mock.createGroup(any)).thenAnswer((_) async => Result.ok(group));
      when(mock.getGroup(any)).thenAnswer((_) async => Result.ok(group));
      when(mock.getGroups()).thenAnswer((_) async => Result.ok([group]));
      when(
        mock.updateGroup(any, any),
      ).thenAnswer((_) async => Result.ok(group));
      when(mock.deleteGroup(any)).thenAnswer((_) async => const Result.ok(()));
      when(mock.joinGroup(any)).thenAnswer((_) async => Result.ok(group));
      when(mock.leaveGroup(any)).thenAnswer((_) async => const Result.ok(()));
    } else {
      when(mock.createGroup(any)).thenAnswer(
        (_) async =>
            const Result.err(ApiFailure(message: 'Group creation failed')),
      );
      when(mock.getGroup(any)).thenAnswer(
        (_) async =>
            const Result.err(ApiFailure(message: 'Group fetch failed')),
      );
      when(mock.getGroups()).thenAnswer(
        (_) async =>
            const Result.err(ApiFailure(message: 'Groups fetch failed')),
      );
    }

    return mock;
  }

  // ========================================
  // HELPER METHODS
  // ========================================

  static Group _createMockGroup() {
    return Group(
      id: 'test-group-id',
      name: 'Test Group',
      familyId: 'test-family-id',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        1640995200000,
      ), // 2022-01-01
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        1640995200000,
      ), // 2022-01-01
    );
  }
}
