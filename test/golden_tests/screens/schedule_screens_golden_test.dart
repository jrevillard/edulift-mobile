// EduLift - Schedule Screens Golden Tests
// Comprehensive visual regression tests for schedule screens using REAL production pages

@Tags(['golden'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import 'package:mockito/mockito.dart';

import 'package:edulift/features/schedule/presentation/pages/schedule_page.dart';
import 'package:edulift/features/family/presentation/providers/family_provider.dart';
import 'package:edulift/features/groups/data/providers/groups_provider.dart';
import 'package:edulift/features/groups/domain/repositories/group_repository.dart';
import 'package:edulift/features/groups/providers.dart' as groups_providers;
import 'package:edulift/features/groups/presentation/providers/group_schedule_config_provider.dart';
import 'package:edulift/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:edulift/features/schedule/presentation/providers/schedule_providers.dart';
import 'package:edulift/core/di/providers/repository_providers.dart';
import 'package:edulift/core/navigation/navigation_state.dart' as nav;
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/domain/entities/schedule.dart';
import 'package:edulift/features/schedule/domain/usecases/manage_schedule_config.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/core/services/providers/auth_provider.dart';
import 'package:edulift/core/domain/entities/user.dart';

import '../../support/golden/golden_test_wrapper.dart';
import '../../support/golden/device_configurations.dart';
import '../../support/golden/theme_configurations.dart';
import '../../support/factories/schedule_data_factory.dart';
import '../../support/factories/group_data_factory.dart';
import '../../support/factories/family_data_factory.dart';
import '../../support/factories/test_data_factory.dart';
import '../../support/network_mocking.dart';
import '../../test_mocks/generated_mocks.mocks.dart';

/// Helper to create a test schedule config using centralized configuration
ScheduleConfig createTestScheduleConfig(String groupId) {
  return ScheduleConfig(
    id: 'test-config-$groupId',
    groupId: groupId,
    scheduleHours: const {
      'MONDAY': ['07:00', '08:00', '09:00', '10:00', '11:00'],
      'TUESDAY': ['07:00', '08:00', '09:00', '10:00', '11:00'],
      'WEDNESDAY': ['07:00', '08:00', '09:00', '10:00', '11:00'],
      'THURSDAY': ['07:00', '08:00', '09:00', '10:00', '11:00'],
      'FRIDAY': ['07:00', '08:00', '09:00', '10:00', '11:00'],
      'SATURDAY': ['09:00', '10:00', '11:00', '12:00'],
      'SUNDAY': ['09:00', '10:00', '11:00', '12:00'],
    },
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );
}

/// Helper to create a mock schedule repository that doesn't access Hive
MockGroupScheduleRepository createMockScheduleRepository(List<ScheduleSlot> scheduleSlots) {
  final mockRepository = MockGroupScheduleRepository();

  // Stub the getWeeklySchedule method to return test data directly
  when(mockRepository.getWeeklySchedule(any, any))
      .thenAnswer((_) async => Result.ok(scheduleSlots));

  // Stub other methods that might be called during tests
  when(mockRepository.getScheduleConfig(any))
      .thenAnswer((_) async => Result.ok(createTestScheduleConfig('test-group')));
  when(mockRepository.getAvailableChildren(any, any, any, any))
      .thenAnswer((_) async => const Result.ok([]));
  when(mockRepository.checkScheduleConflicts(any, any, any, any, any))
      .thenAnswer((_) async => const Result.ok([]));

  return mockRepository;
}

/// Helper to create provider override with mocked schedule repository
/// This prevents Hive access by providing a mock repository
Override createMockedScheduleRepositoryProvider(List<ScheduleSlot> scheduleSlots) {
  return scheduleRepositoryProvider.overrideWith((ref) {
    return createMockScheduleRepository(scheduleSlots);
  });
}

/// Helper to create provider override with mocked schedule data
/// Uses the modern weeklyScheduleProvider (auto-dispose)
Override createMockedScheduleProvider(String groupId, String week, List<ScheduleSlot> scheduleSlots) {
  return weeklyScheduleProvider(groupId, week).overrideWith((ref) async {
    // Return pre-defined schedule slots directly
    return scheduleSlots;
  });
}

/// Pre-initialized GroupsNotifier that doesn't call repository during tests
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

/// Helper function to create a properly mocked GroupsProvider
/// This prevents Hive initialization errors by mocking all dependencies
Override createMockedGroupsProvider(GroupsState initialState) {
  return groups_providers.groupsComposedProvider.overrideWith((ref) {
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

/// Helper to create mocked schedule config provider
/// Prevents API calls to /groups/{groupId}/schedule-config
Override createMockedScheduleConfigProvider(String groupId, ScheduleConfig? config) {
  return groupScheduleConfigProvider(groupId).overrideWith((ref) {
    return _PreInitializedScheduleConfigNotifier(
      groupId: groupId,
      initialConfig: config,
    );
  });
}

/// Stub group schedule repository for testing
class _StubGroupScheduleRepository implements GroupScheduleRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// Stub update schedule config use case for testing
class _StubUpdateScheduleConfig extends UpdateScheduleConfig {
  _StubUpdateScheduleConfig() : super(_StubGroupScheduleRepository());

  @override
  Future<Result<ScheduleConfig, ApiFailure>> call(UpdateScheduleConfigParams params) async {
    // Not called in golden tests
    throw UnimplementedError();
  }
}

/// Pre-initialized Schedule Config Notifier
class _PreInitializedScheduleConfigNotifier extends GroupScheduleConfigNotifier {
  _PreInitializedScheduleConfigNotifier({
    required String groupId,
    required ScheduleConfig? initialConfig,
  }) : super(
          groupId,
          null, // No use case - won't make API calls
          _StubUpdateScheduleConfig(), // Stub for update use case
          null, // No reset use case
          MockErrorHandlerService(),
        ) {
    // Pre-set state to avoid API calls
    state = AsyncValue.data(initialConfig);
  }

  @override
  Future<void> loadConfig() async {
    // No-op: state already set in constructor
  }

  @override
  Future<void> updateConfig(ScheduleConfig config) async {
    // No-op: not needed for golden tests
  }

  @override
  Future<void> resetConfig() async {
    // No-op: not needed for golden tests
  }
}

void main() {
  setUpAll(() async {
    // Initialize timezone database to prevent LocationNotFoundException
    tz.initializeTimeZones();

    ScheduleDataFactory.resetCounters();
    GroupDataFactory.resetCounters();
    FamilyDataFactory.resetCounters();
    TestDataFactory.resetSeed();
  });

  group('Schedule Page - Golden Tests (Real Production Code)', () {
    // Use a fixed test week string for consistency
    const testWeek = '2025-W41';

    testWidgets('SchedulePage - with groups and schedules (light)', (tester) async {
      final groups = GroupDataFactory.createLargeGroupList(count: 3);
      final vehicles = FamilyDataFactory.createLargeVehicleList(count: 5);
      final scheduleConfig = createTestScheduleConfig(groups[0].id);
      final scheduleSlots = ScheduleDataFactory.createLargeScheduleSlotList(
        count: 15,
        groupId: groups[0].id,
      );

      final groupsState = GroupsState(groups: groups);
      final testUser = User(
        id: 'user-1',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final overrides = [
        currentUserProvider.overrideWith((ref) => testUser),
        familyVehiclesProvider.overrideWith((ref) => vehicles),
        createMockedScheduleRepositoryProvider(scheduleSlots),
        createMockedScheduleProvider(groups[0].id, testWeek, scheduleSlots),
        createMockedGroupsProvider(groupsState),
        createMockedScheduleConfigProvider(groups[0].id, scheduleConfig),
        nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
        // CRITICAL: Prevent all real network calls during golden tests
        ...getAllNetworkMockOverrides(),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: SchedulePage(groupId: groups[0].id),
        testName: 'schedule_list_light_15slots',
        devices: DeviceConfigurations.crossPlatformSet,
        themes: [ThemeConfigurations.light],
        providerOverrides: overrides,
      );
    });

    testWidgets('SchedulePage - with groups and schedules (dark)', (tester) async {
      final groups = GroupDataFactory.createLargeGroupList(count: 3);
      final vehicles = FamilyDataFactory.createLargeVehicleList(count: 5);
      final scheduleSlots = ScheduleDataFactory.createLargeScheduleSlotList(
        groupId: groups[0].id,
      );

      final scheduleConfig = createTestScheduleConfig(groups[0].id);
      final groupsState = GroupsState(groups: groups);
      final testUser = User(
        id: 'user-2',
        email: 'test2@example.com',
        name: 'Test User 2',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final overrides = [
        currentUserProvider.overrideWith((ref) => testUser),
        familyVehiclesProvider.overrideWith((ref) => vehicles),
        createMockedScheduleRepositoryProvider(scheduleSlots),
        createMockedScheduleProvider(groups[0].id, testWeek, scheduleSlots),
        createMockedGroupsProvider(groupsState),
        createMockedScheduleConfigProvider(groups[0].id, scheduleConfig),
        nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
        // CRITICAL: Prevent all real network calls during golden tests
        ...getAllNetworkMockOverrides(),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: SchedulePage(groupId: groups[0].id),
        testName: 'schedule_list_dark_20slots',
        devices: DeviceConfigurations.crossPlatformSet,
        themes: [ThemeConfigurations.dark],
        providerOverrides: overrides,
      );
    });

    testWidgets('SchedulePage - no groups (empty state)', (tester) async {
      const groupsState = GroupsState();
      final testUser = User(
        id: 'user-3',
        email: 'test3@example.com',
        name: 'Test User 3',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final overrides = [
        currentUserProvider.overrideWith((ref) => testUser),
        familyVehiclesProvider.overrideWith((ref) => []),
        createMockedScheduleRepositoryProvider([]),
        createMockedGroupsProvider(groupsState),
        nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
        // CRITICAL: Prevent all real network calls during golden tests
        ...getAllNetworkMockOverrides(),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const SchedulePage(),
        testName: 'schedule_no_groups_empty',
        devices: DeviceConfigurations.crossPlatformSet,
        themes: [ThemeConfigurations.light],
        providerOverrides: overrides,
      );
    });

    testWidgets('SchedulePage - loading state', (tester) async {
      final groups = GroupDataFactory.createLargeGroupList(count: 2);
      final groupsState = GroupsState(groups: groups);
      final scheduleConfig = createTestScheduleConfig(groups[0].id);
      // Create empty schedule (no slots - shows empty schedule grid)
      final scheduleSlots = <ScheduleSlot>[];
      final testUser = User(
        id: 'user-4',
        email: 'test4@example.com',
        name: 'Test User 4',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final overrides = [
        currentUserProvider.overrideWith((ref) => testUser),
        familyVehiclesProvider.overrideWith((ref) => []),
        createMockedScheduleRepositoryProvider(scheduleSlots),
        createMockedScheduleProvider(groups[0].id, testWeek, scheduleSlots),
        createMockedGroupsProvider(groupsState),
        createMockedScheduleConfigProvider(groups[0].id, scheduleConfig),
        nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: SchedulePage(groupId: groups[0].id),
        testName: 'schedule_with_group_loading',
        devices: DeviceConfigurations.crossPlatformSet,
        themes: [ThemeConfigurations.light],
        providerOverrides: overrides,
      );
    });

    testWidgets('SchedulePage - error state', (tester) async {
      final groups = GroupDataFactory.createLargeGroupList(count: 2);
      final groupsState = GroupsState(groups: groups);
      // Pass null config to simulate "Configuration Required" state
      const ScheduleConfig? scheduleConfig = null;
      // Mock schedule (even though it won't be shown due to null config)
      final scheduleSlots = <ScheduleSlot>[];
      final testUser = User(
        id: 'user-5',
        email: 'test5@example.com',
        name: 'Test User 5',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final overrides = [
        currentUserProvider.overrideWith((ref) => testUser),
        familyVehiclesProvider.overrideWith((ref) => []),
        createMockedScheduleRepositoryProvider(scheduleSlots),
        createMockedScheduleProvider(groups[0].id, testWeek, scheduleSlots),
        createMockedGroupsProvider(groupsState),
        createMockedScheduleConfigProvider(groups[0].id, scheduleConfig),
        nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: SchedulePage(groupId: groups[0].id),
        testName: 'schedule_with_group_error',
        devices: DeviceConfigurations.crossPlatformSet,
        themes: [ThemeConfigurations.light],
        providerOverrides: overrides,
      );
    });

    testWidgets('SchedulePage - tablet layout with data', (tester) async {
      final groups = GroupDataFactory.createLargeGroupList(count: 3);
      final vehicles = FamilyDataFactory.createLargeVehicleList(count: 8);
      final scheduleConfig = createTestScheduleConfig(groups[0].id);
      final scheduleSlots = ScheduleDataFactory.createLargeScheduleSlotList(
        count: 15,
        groupId: groups[0].id,
      );
      final groupsState = GroupsState(groups: groups);
      final testUser = User(
        id: 'user-6',
        email: 'test6@example.com',
        name: 'Test User 6',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final overrides = [
        currentUserProvider.overrideWith((ref) => testUser),
        familyVehiclesProvider.overrideWith((ref) => vehicles),
        createMockedScheduleRepositoryProvider(scheduleSlots),
        createMockedScheduleProvider(groups[0].id, testWeek, scheduleSlots),
        createMockedGroupsProvider(groupsState),
        createMockedScheduleConfigProvider(groups[0].id, scheduleConfig),
        nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
        // CRITICAL: Prevent all real network calls during golden tests
        ...getAllNetworkMockOverrides(),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: SchedulePage(groupId: groups[0].id),
        testName: 'schedule_tablet_with_sidebar',
        devices: [DeviceConfigurations.iPadPro],
        themes: [ThemeConfigurations.light],
        providerOverrides: overrides,
      );
    });

    testWidgets('SchedulePage - high contrast theme', (tester) async {
      final groups = GroupDataFactory.createLargeGroupList(count: 2);
      final vehicles = FamilyDataFactory.createLargeVehicleList(count: 4);
      final scheduleSlots = ScheduleDataFactory.createLargeScheduleSlotList(
        groupId: groups[0].id,
      );
      final scheduleConfig = createTestScheduleConfig(groups[0].id);

      final groupsState = GroupsState(groups: groups);
      final testUser = User(
        id: 'user-7',
        email: 'test7@example.com',
        name: 'Test User 7',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final overrides = [
        currentUserProvider.overrideWith((ref) => testUser),
        familyVehiclesProvider.overrideWith((ref) => vehicles),
        createMockedScheduleRepositoryProvider(scheduleSlots),
        createMockedScheduleProvider(groups[0].id, testWeek, scheduleSlots),
        createMockedGroupsProvider(groupsState),
        createMockedScheduleConfigProvider(groups[0].id, scheduleConfig),
        nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
        // CRITICAL: Prevent all real network calls during golden tests
        ...getAllNetworkMockOverrides(),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: SchedulePage(groupId: groups[0].id),
        testName: 'schedule_high_contrast',
        devices: DeviceConfigurations.crossPlatformSet,
        themes: [ThemeConfigurations.highContrastLight],
        providerOverrides: overrides,
      );
    });

    testWidgets('SchedulePage - responsive design (small screen)', (tester) async {
      final groups = GroupDataFactory.createLargeGroupList(count: 2);
      final vehicles = FamilyDataFactory.createLargeVehicleList(count: 3);
      final scheduleSlots = ScheduleDataFactory.createLargeScheduleSlotList(
        groupId: groups[0].id,
      );
      final scheduleConfig = createTestScheduleConfig(groups[0].id);

      final groupsState = GroupsState(groups: groups);
      final testUser = User(
        id: 'user-8',
        email: 'test8@example.com',
        name: 'Test User 8',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final overrides = [
        currentUserProvider.overrideWith((ref) => testUser),
        familyVehiclesProvider.overrideWith((ref) => vehicles),
        createMockedScheduleRepositoryProvider(scheduleSlots),
        createMockedScheduleProvider(groups[0].id, testWeek, scheduleSlots),
        createMockedGroupsProvider(groupsState),
        createMockedScheduleConfigProvider(groups[0].id, scheduleConfig),
        nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
        // CRITICAL: Prevent all real network calls during golden tests
        ...getAllNetworkMockOverrides(),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: SchedulePage(groupId: groups[0].id),
        testName: 'schedule_responsive_small',
        devices: DeviceConfigurations.crossPlatformSet,
        themes: [ThemeConfigurations.light, ThemeConfigurations.dark],
        providerOverrides: overrides,
      );
    });

    testWidgets('SchedulePage - complex data scenario', (tester) async {
      final groups = GroupDataFactory.createLargeGroupList(count: 4);
      final vehicles = FamilyDataFactory.createLargeVehicleList();
      final scheduleSlots = ScheduleDataFactory.createLargeScheduleSlotList(
        groupId: groups[0].id,
      );
      final scheduleConfig = createTestScheduleConfig(groups[0].id);

      final groupsState = GroupsState(groups: groups);
      final testUser = User(
        id: 'user-9',
        email: 'test9@example.com',
        name: 'Test User 9',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final overrides = [
        currentUserProvider.overrideWith((ref) => testUser),
        familyVehiclesProvider.overrideWith((ref) => vehicles),
        createMockedScheduleRepositoryProvider(scheduleSlots),
        createMockedScheduleProvider(groups[0].id, testWeek, scheduleSlots),
        createMockedGroupsProvider(groupsState),
        createMockedScheduleConfigProvider(groups[0].id, scheduleConfig),
        nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
        // CRITICAL: Prevent all real network calls during golden tests
        ...getAllNetworkMockOverrides(),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: SchedulePage(groupId: groups[0].id),
        testName: 'schedule_complex_data',
        devices: DeviceConfigurations.crossPlatformSet,
        themes: [ThemeConfigurations.light, ThemeConfigurations.dark],
        providerOverrides: overrides,
      );
    });
  });
}
