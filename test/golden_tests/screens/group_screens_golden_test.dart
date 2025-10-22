// EduLift - Group Screens Golden Tests
// Comprehensive visual regression tests for group screens using REAL production pages

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

import 'package:edulift/features/groups/presentation/pages/groups_page.dart';
import 'package:edulift/features/groups/presentation/pages/create_group_page.dart';
import 'package:edulift/features/groups/data/providers/groups_provider.dart';
import 'package:edulift/features/groups/domain/repositories/group_repository.dart';
import 'package:edulift/core/navigation/navigation_state.dart' as nav;
import 'package:edulift/core/services/providers/auth_provider.dart';
import 'package:edulift/core/domain/entities/user.dart';
import 'package:edulift/core/utils/result.dart';

import '../../support/golden/golden_test_wrapper.dart';
import '../../support/golden/device_configurations.dart';
import '../../support/golden/theme_configurations.dart';
import '../../support/factories/group_data_factory.dart';
import '../../support/factories/test_data_factory.dart';
import '../../test_mocks/generated_mocks.mocks.dart';

/// Custom GroupsNotifier that pre-initializes with test data
/// This avoids the async loadUserGroups() call that causes Hive errors
class _PreInitializedGroupsNotifier extends GroupsNotifier {
  _PreInitializedGroupsNotifier(
    GroupRepository repository, {
    required GroupsState initialState,
  }) : super(repository) {
    // Pre-set the state with test data to avoid async initialization issues
    state = initialState;
  }

  // Override loadUserGroups to do nothing - state is already set
  @override
  Future<void> loadUserGroups() async {
    // No-op: state is already pre-initialized with test data
  }

  // Override refresh to do nothing
  @override
  Future<void> refresh() async {
    // No-op: state is already pre-initialized with test data
  }
}

@Tags(['golden'])
void main() {
  // Reset factories before tests
  setUpAll(() {
    GroupDataFactory.resetCounters();
    TestDataFactory.resetSeed();
  });

  /// Helper function to create a properly mocked GroupsProvider
  /// This prevents Hive initialization errors by mocking all dependencies
  /// The notifier is pre-initialized with test data to avoid async loadUserGroups() issues
  Override createMockedGroupsProvider(GroupsState initialState) {
    return groupsProvider.overrideWith((ref) {
      // Create mocked repository
      final mockRepository = MockGroupRepository();

      // Stub repository methods to return test data (no Hive/network calls)
      when(mockRepository.getGroups()).thenAnswer((_) async {
        return const Result.ok([]);
      });

      // Create a custom notifier that pre-sets the state
      final notifier = _PreInitializedGroupsNotifier(
        mockRepository,
        initialState: initialState,
      );

      return notifier;
    });
  }

  group('Groups List Screen - Golden Tests (Real Production Code)', () {
    testWidgets('GroupsPage - with realistic data', (tester) async {
      final testUser = User(
        id: 'user-1',
        email: 'admin@example.com',
        name: 'Admin User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final testGroups = GroupDataFactory.createLargeGroupList(count: 5);
      final groupsState = GroupsState(
        groups: testGroups,
      );

      final overrides = [
        currentUserProvider.overrideWith((ref) => testUser),
        createMockedGroupsProvider(groupsState),
        nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const GroupsPage(),
        testName: 'groups_list_realistic',
        devices: DeviceConfigurations.defaultSet,
        themes: ThemeConfigurations.basic,
        providerOverrides: overrides,
      );
    });

    testWidgets('GroupsPage - with different statuses', (tester) async {
      final testUser = User(
        id: 'user-2',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final testGroups = [
        GroupDataFactory.createRealisticGroup(index: 0),
        GroupDataFactory.createPausedGroup(),
        GroupDataFactory.createArchivedGroup(),
        GroupDataFactory.createDraftGroup(),
      ];

      final groupsState = GroupsState(
        groups: testGroups,
      );

      final overrides = [
        currentUserProvider.overrideWith((ref) => testUser),
        createMockedGroupsProvider(groupsState),
        nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const GroupsPage(),
        testName: 'groups_list_different_statuses',
        devices: [DeviceConfigurations.iphone13],
        themes: [ThemeConfigurations.light],
        providerOverrides: overrides,
      );
    });

    testWidgets('GroupsPage - empty state', (tester) async {
      final testUser = User(
        id: 'user-3',
        email: 'new@example.com',
        name: 'New User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      const groupsState = GroupsState();

      final overrides = [
        currentUserProvider.overrideWith((ref) => testUser),
        createMockedGroupsProvider(groupsState),
        nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
      ];

      await GoldenTestWrapper.testEmptyState(
        tester: tester,
        widget: const GroupsPage(),
        testName: 'groups_list',
        devices: [DeviceConfigurations.iphone13],
        themes: [ThemeConfigurations.light],
        category: 'screen',
        providerOverrides: overrides,
      );
    });

    testWidgets('GroupsPage - loading state', (tester) async {
      final testUser = User(
        id: 'user-4',
        email: 'loading@example.com',
        name: 'Loading User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      const groupsState = GroupsState(
        isLoading: true,
      );

      final overrides = [
        currentUserProvider.overrideWith((ref) => testUser),
        createMockedGroupsProvider(groupsState),
        nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
      ];

      await GoldenTestWrapper.testLoadingState(
        tester: tester,
        widget: const GroupsPage(),
        testName: 'groups_list',
        devices: [DeviceConfigurations.iphone13],
        themes: [ThemeConfigurations.light],
        category: 'screen',
        providerOverrides: overrides,
      );
    });

    testWidgets('GroupsPage - error state', (tester) async {
      final testUser = User(
        id: 'user-5',
        email: 'error@example.com',
        name: 'Error User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      const groupsState = GroupsState(
        error: 'errorNetworkGeneral',
      );

      final overrides = [
        currentUserProvider.overrideWith((ref) => testUser),
        createMockedGroupsProvider(groupsState),
        nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
      ];

      await GoldenTestWrapper.testErrorState(
        tester: tester,
        widget: const GroupsPage(),
        testName: 'groups_list',
        devices: [DeviceConfigurations.iphone13],
        themes: [ThemeConfigurations.light],
        category: 'screen',
        providerOverrides: overrides,
      );
    });
  });

  group('Create Group Page - Golden Tests (Real Production Code)', () {
    testWidgets('CreateGroupPage - All Themes', (tester) async {
      final testUser = User(
        id: 'user-6',
        email: 'creator@example.com',
        name: 'Creator User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      const groupsState = GroupsState();

      final overrides = [
        currentUserProvider.overrideWith((ref) => testUser),
        createMockedGroupsProvider(groupsState),
        nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const CreateGroupPage(),
        testName: 'create_group_page',
        devices: DeviceConfigurations.defaultSet,
        themes: [
          ThemeConfigurations.light,
          ThemeConfigurations.dark,
          ThemeConfigurations.highContrastLight,
        ],
        providerOverrides: overrides,
      );
    });
  });
}
