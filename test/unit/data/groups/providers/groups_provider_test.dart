// Groups Provider Unit Tests - Optimized State Management
// Tests the optimized behavior where operations perform surgical state updates
// using REST responses directly, without calling loadUserGroups()

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:edulift/features/groups/data/providers/groups_provider.dart';
import 'package:edulift/core/domain/entities/groups/group.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';

import '../../../../test_mocks/test_mocks.dart';
import '../../../../support/test_mock_configuration.dart';

void main() {
  // Use comprehensive TestMockConfiguration for all mock setup
  setUpAll(() {
    TestMockConfiguration.setupGlobalMocks();
  });

  group('GroupsNotifier - Optimized State Management Tests', () {
    late GroupsNotifier notifier;
    late MockGroupRepository mockRepository;

    // Test data
    final testGroup = Group(
      id: 'group-123',
      name: 'Test Group',
      familyId: 'family-456',
      createdAt: DateTime.parse('2025-01-01T10:00:00Z'),
      updatedAt: DateTime.parse('2025-01-01T10:00:00Z'),
    );

    final existingGroup = Group(
      id: 'existing-group-1',
      name: 'Existing Group 1',
      familyId: 'family-456',
      createdAt: DateTime.parse('2025-01-01T09:00:00Z'),
      updatedAt: DateTime.parse('2025-01-01T09:00:00Z'),
    );

    setUp(() {
      mockRepository = MockGroupRepository();
      // Mock the constructor call to loadUserGroups()
      when(
        mockRepository.getGroups(),
      ).thenAnswer((_) async => Result.ok([existingGroup]));
      notifier = GroupsNotifier(mockRepository);
    });

    tearDown(() {
      notifier.dispose();
    });

    group('createGroup() Tests', () {
      test(
        'GIVEN successful createGroup WHEN operation completes THEN should add group to state without calling getGroups',
        () async {
          // GIVEN
          when(
            mockRepository.createGroup(any),
          ).thenAnswer((_) async => Result.ok(testGroup));

          // WHEN
          final result = await notifier.createGroup('Test Group');

          // THEN
          expect(result, isTrue);
          verify(mockRepository.createGroup(any)).called(1);
          // getGroups should only be called once (during constructor)
          verify(mockRepository.getGroups()).called(1);
          // Verify the new group was added to state
          expect(notifier.state.groups, contains(testGroup));
          expect(notifier.state.groups, contains(existingGroup));
          expect(notifier.state.groups.length, 2);
          expect(notifier.state.isCreateSuccess, isTrue);
          expect(notifier.state.isLoading, isFalse);
        },
      );

      test(
        'GIVEN failed createGroup WHEN operation completes THEN should NOT add group to state',
        () async {
          // GIVEN
          const apiFailure = ApiFailure(
            message: 'Failed to create group',
            statusCode: 400,
          );
          when(
            mockRepository.createGroup(any),
          ).thenAnswer((_) async => const Result.err(apiFailure));

          // WHEN
          final result = await notifier.createGroup('Test Group');

          // THEN
          expect(result, isFalse);
          verify(mockRepository.createGroup(any)).called(1);
          // Verify getGroups was only called once (during constructor)
          verify(mockRepository.getGroups()).called(1);
          // Verify state unchanged (still has only existing group)
          expect(notifier.state.groups, isNot(contains(testGroup)));
          expect(notifier.state.groups, contains(existingGroup));
          expect(notifier.state.groups.length, 1);
          expect(notifier.state.createError, 'errorInvalidData');
          expect(notifier.state.isCreateSuccess, isFalse);
        },
      );
    });

    group('joinGroup() Tests', () {
      test(
        'GIVEN successful joinGroup WHEN operation completes THEN should add group to state without calling getGroups',
        () async {
          // GIVEN
          when(
            mockRepository.joinGroup('invite123'),
          ).thenAnswer((_) async => Result.ok(testGroup));

          // WHEN
          final result = await notifier.joinGroup('invite123');

          // THEN
          expect(result, isTrue);
          verify(mockRepository.joinGroup('invite123')).called(1);
          // getGroups should only be called once (during constructor)
          verify(mockRepository.getGroups()).called(1);
          // Verify the joined group was added to state
          expect(notifier.state.groups, contains(testGroup));
          expect(notifier.state.groups, contains(existingGroup));
          expect(notifier.state.groups.length, 2);
          expect(notifier.state.isLoading, isFalse);
        },
      );

      test(
        'GIVEN failed joinGroup WHEN operation completes THEN should NOT add group to state',
        () async {
          // GIVEN
          const apiFailure = ApiFailure(
            message: 'Invalid invitation code',
            statusCode: 400,
          );
          when(
            mockRepository.joinGroup('invalid-code'),
          ).thenAnswer((_) async => const Result.err(apiFailure));

          // WHEN
          final result = await notifier.joinGroup('invalid-code');

          // THEN
          expect(result, isFalse);
          verify(mockRepository.joinGroup('invalid-code')).called(1);
          verify(mockRepository.getGroups()).called(1);
          // Verify state unchanged
          expect(notifier.state.groups, isNot(contains(testGroup)));
          expect(notifier.state.groups.length, 1);
          // Error message "Invalid invitation code" maps to errorInvalidInvitationCode
          expect(notifier.state.joinError, 'errorInvalidInvitationCode');
        },
      );
    });

    group('leaveGroup() Tests', () {
      test(
        'GIVEN successful leaveGroup WHEN operation completes THEN should remove group from state without calling getGroups',
        () async {
          // GIVEN
          when(
            mockRepository.leaveGroup('existing-group-1'),
          ).thenAnswer((_) async => const Result.ok(null));

          // WHEN
          final result = await notifier.leaveGroup('existing-group-1');

          // THEN
          expect(result, isTrue);
          verify(mockRepository.leaveGroup('existing-group-1')).called(1);
          // getGroups should only be called once (during constructor)
          verify(mockRepository.getGroups()).called(1);
          // Verify the group was removed from state
          expect(notifier.state.groups, isNot(contains(existingGroup)));
          expect(notifier.state.groups.length, 0);
          expect(notifier.state.isLoading, isFalse);
        },
      );

      test(
        'GIVEN failed leaveGroup WHEN operation completes THEN should NOT remove group from state',
        () async {
          // GIVEN
          const apiFailure = ApiFailure(
            message: 'Failed to leave group',
            statusCode: 403,
          );
          when(
            mockRepository.leaveGroup('existing-group-1'),
          ).thenAnswer((_) async => const Result.err(apiFailure));

          // WHEN
          final result = await notifier.leaveGroup('existing-group-1');

          // THEN
          expect(result, isFalse);
          verify(mockRepository.leaveGroup('existing-group-1')).called(1);
          verify(mockRepository.getGroups()).called(1);
          // Verify state unchanged
          expect(notifier.state.groups, contains(existingGroup));
          expect(notifier.state.groups.length, 1);
          expect(notifier.state.error, 'errorAccessDenied');
        },
      );
    });

    group('updateGroup() Tests', () {
      test(
        'GIVEN successful updateGroup WHEN operation completes THEN should update group in state without calling getGroups',
        () async {
          // GIVEN
          final updates = {'name': 'Updated Group Name'};
          final updatedGroup = Group(
            id: 'existing-group-1',
            name: 'Updated Group Name',
            familyId: 'family-456',
            createdAt: existingGroup.createdAt,
            updatedAt: DateTime.parse('2025-01-01T11:00:00Z'),
          );

          when(
            mockRepository.updateGroup('existing-group-1', updates),
          ).thenAnswer((_) async => Result.ok(updatedGroup));

          // WHEN
          final result = await notifier.updateGroup(
            'existing-group-1',
            updates,
          );

          // THEN
          expect(result, isTrue);
          verify(
            mockRepository.updateGroup('existing-group-1', updates),
          ).called(1);
          // getGroups should only be called once (during constructor)
          verify(mockRepository.getGroups()).called(1);
          // Verify the group was updated in state
          final updatedGroupInState = notifier.state.groups.firstWhere(
            (g) => g.id == 'existing-group-1',
          );
          expect(updatedGroupInState.name, 'Updated Group Name');
          expect(notifier.state.groups.length, 1);
          expect(notifier.state.isLoading, isFalse);
        },
      );

      test(
        'GIVEN failed updateGroup WHEN operation completes THEN should NOT update group in state',
        () async {
          // GIVEN
          final updates = {'name': 'Updated Group Name'};
          const apiFailure = ApiFailure(
            message: 'Failed to update group',
            statusCode: 403,
          );
          when(
            mockRepository.updateGroup('existing-group-1', updates),
          ).thenAnswer((_) async => const Result.err(apiFailure));

          // WHEN
          final result = await notifier.updateGroup(
            'existing-group-1',
            updates,
          );

          // THEN
          expect(result, isFalse);
          verify(
            mockRepository.updateGroup('existing-group-1', updates),
          ).called(1);
          verify(mockRepository.getGroups()).called(1);
          // Verify state unchanged
          final groupInState = notifier.state.groups.firstWhere(
            (g) => g.id == 'existing-group-1',
          );
          expect(groupInState.name, 'Existing Group 1'); // Original name
          expect(notifier.state.error, 'errorAccessDenied');
        },
      );
    });

    group('deleteGroup() Tests', () {
      test(
        'GIVEN successful deleteGroup WHEN operation completes THEN should remove group from state without calling getGroups',
        () async {
          // GIVEN
          when(
            mockRepository.deleteGroup('existing-group-1'),
          ).thenAnswer((_) async => const Result.ok(null));

          // WHEN
          final result = await notifier.deleteGroup('existing-group-1');

          // THEN
          expect(result, isTrue);
          verify(mockRepository.deleteGroup('existing-group-1')).called(1);
          // getGroups should only be called once (during constructor)
          verify(mockRepository.getGroups()).called(1);
          // Verify the group was removed from state
          expect(notifier.state.groups, isNot(contains(existingGroup)));
          expect(notifier.state.groups.length, 0);
          expect(notifier.state.isLoading, isFalse);
        },
      );

      test(
        'GIVEN failed deleteGroup WHEN operation completes THEN should NOT remove group from state',
        () async {
          // GIVEN
          const apiFailure = ApiFailure(
            message: 'Failed to delete group',
            statusCode: 403,
          );
          when(
            mockRepository.deleteGroup('existing-group-1'),
          ).thenAnswer((_) async => const Result.err(apiFailure));

          // WHEN
          final result = await notifier.deleteGroup('existing-group-1');

          // THEN
          expect(result, isFalse);
          verify(mockRepository.deleteGroup('existing-group-1')).called(1);
          verify(mockRepository.getGroups()).called(1);
          // Verify state unchanged
          expect(notifier.state.groups, contains(existingGroup));
          expect(notifier.state.groups.length, 1);
          expect(notifier.state.error, 'errorAccessDenied');
        },
      );
    });

    group('Integration Test', () {
      test(
        'GIVEN multiple operations WHEN all succeed THEN each should update state surgically without calling getGroups',
        () async {
          // GIVEN
          final newGroup = Group(
            id: 'new-group',
            name: 'New Group',
            familyId: 'family-456',
            createdAt: DateTime.parse('2025-01-01T10:00:00Z'),
            updatedAt: DateTime.parse('2025-01-01T10:00:00Z'),
          );

          final updatedExistingGroup = Group(
            id: 'existing-group-1',
            name: 'Updated Existing Group',
            familyId: 'family-456',
            createdAt: existingGroup.createdAt,
            updatedAt: DateTime.parse('2025-01-01T11:00:00Z'),
          );

          when(
            mockRepository.createGroup(any),
          ).thenAnswer((_) async => Result.ok(newGroup));
          when(
            mockRepository.updateGroup('existing-group-1', any),
          ).thenAnswer((_) async => Result.ok(updatedExistingGroup));

          // WHEN
          await notifier.createGroup('New Group');
          await notifier.updateGroup('existing-group-1', {
            'name': 'Updated Existing Group',
          });

          // THEN
          verify(mockRepository.createGroup(any)).called(1);
          verify(
            mockRepository.updateGroup('existing-group-1', {
              'name': 'Updated Existing Group',
            }),
          ).called(1);
          // getGroups should only be called once (during constructor)
          verify(mockRepository.getGroups()).called(1);

          // Verify final state has both groups with updates
          expect(notifier.state.groups.length, 2);
          expect(notifier.state.groups, contains(newGroup));
          final updatedGroup = notifier.state.groups.firstWhere(
            (g) => g.id == 'existing-group-1',
          );
          expect(updatedGroup.name, 'Updated Existing Group');
        },
      );
    });
  });
}
