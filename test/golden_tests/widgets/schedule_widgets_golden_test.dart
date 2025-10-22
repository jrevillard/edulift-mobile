import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

import 'package:edulift/features/schedule/presentation/widgets/schedule_grid.dart';
import 'package:edulift/features/schedule/presentation/widgets/vehicle_selection_modal.dart';
import 'package:edulift/features/schedule/presentation/widgets/schedule_config_widget.dart';
import 'package:edulift/features/schedule/presentation/widgets/schedule_slot_widget.dart';
import 'package:edulift/features/schedule/presentation/widgets/child_assignment_sheet.dart';
import 'package:edulift/features/schedule/presentation/widgets/time_picker.dart';
import 'package:edulift/features/schedule/presentation/widgets/per_day_time_slot_config.dart';
import 'package:edulift/features/schedule/presentation/pages/create_schedule_page.dart';
import 'package:edulift/features/family/presentation/providers/family_provider.dart' as family_provider;
import 'package:edulift/features/family/domain/usecases/get_family_usecase.dart';
import 'package:edulift/features/family/domain/usecases/leave_family_usecase.dart';
import 'package:edulift/features/family/domain/services/children_service.dart';
import 'package:edulift/features/family/domain/repositories/family_repository.dart';
import 'package:edulift/features/family/domain/repositories/family_invitation_repository.dart';
import 'package:edulift/features/groups/presentation/providers/group_schedule_config_provider.dart';
import 'package:edulift/features/schedule/domain/usecases/manage_schedule_config.dart';
import 'package:edulift/core/network/error_handler_service.dart';
import 'package:flutter/material.dart';
import 'package:edulift/core/domain/entities/family.dart' as entities;
import 'package:edulift/features/family/providers.dart' as family;
import 'package:edulift/features/groups/data/providers/groups_provider.dart';
import 'package:edulift/features/groups/domain/repositories/group_repository.dart';
import 'package:edulift/features/groups/providers.dart' as groups_providers;
import 'package:edulift/features/schedule/presentation/providers/schedule_providers.dart';
import 'package:edulift/core/di/providers/repository_providers.dart';
import 'package:edulift/core/navigation/navigation_state.dart' as nav;
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/domain/entities/schedule.dart';
import 'package:edulift/core/services/providers/auth_provider.dart';
import 'package:edulift/core/domain/entities/user.dart';

import '../../support/golden/golden_test_wrapper.dart';
import '../../support/golden/device_configurations.dart';
import '../../support/golden/theme_configurations.dart';
import '../../support/factories/schedule_data_factory.dart';
import '../../support/factories/group_data_factory.dart';
import '../../support/factories/family_data_factory.dart';
import '../../test_mocks/generated_mocks.mocks.dart';
import '../../support/mock_fallbacks.dart';
import '../../support/network_mocking.dart';
import 'package:timezone/data/latest.dart' as tz;

/// Helper to create a test schedule config - simple hours matching what factory generates
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



/// Pre-initialized FamilyNotifier that doesn't call repository during tests
class _PreInitializedScheduleFamilyNotifier extends family_provider.FamilyNotifier {
  _PreInitializedScheduleFamilyNotifier(
    GetFamilyUsecase getFamilyUsecase,
    ChildrenService childrenService,
    LeaveFamilyUsecase leaveFamilyUsecase,
    FamilyRepository familyRepository,
    InvitationRepository invitationRepository,
    Ref ref, {
    required entities.Family? initialFamily,
  }) : super(
          getFamilyUsecase,
          childrenService,
          leaveFamilyUsecase,
          familyRepository,
          invitationRepository,
          ref,
        ) {
    // Pre-set the state with test data to avoid async initialization issues
    if (initialFamily != null) {
      state = family_provider.FamilyState(
        family: initialFamily,
        children: initialFamily.children,
        vehicles: initialFamily.vehicles,
      );
    }
  }

  // Override loadFamily to do nothing - state is already set
  @override
  Future<void> loadFamily() async {
    // No-op: state is already pre-initialized with test data
  }

  // Override loadVehicles to do nothing - state is already set
  @override
  Future<void> loadVehicles() async {
    // No-op: state is already pre-initialized with test data
  }
}

/// Helper function to create a properly mocked FamilyProvider for schedule tests
/// This prevents Hive initialization errors by mocking all dependencies
/// The notifier is pre-initialized with test data to avoid async loadFamily() issues
Override createMockedFamilyProvider(List<entities.Vehicle> vehicles) {
  return family.familyComposedProvider.overrideWith((ref) {
    // Create all mocked dependencies
    final mockGetFamilyUsecase = MockGetFamilyUsecase();
    final mockChildrenService = MockChildrenService();
    final mockLeaveFamilyUsecase = MockLeaveFamilyUsecase();
    final mockFamilyRepository = MockFamilyRepository();
    final mockInvitationRepository = MockInvitationRepository();

    // Create test family with vehicles
    final testFamily = entities.Family(
      id: 'test-family',
      name: 'Test Family',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Stub repository methods to return test data (no network calls)
    when(mockFamilyRepository.getFamily()).thenAnswer((_) async {
      return Result.ok(testFamily);
    });

    when(mockInvitationRepository.getPendingInvitations(familyId: anyNamed('familyId')))
        .thenAnswer((_) async => const Result.ok([]));

    // Create a custom notifier that pre-sets the state
    final notifier = _PreInitializedScheduleFamilyNotifier(
      mockGetFamilyUsecase,
      mockChildrenService,
      mockLeaveFamilyUsecase,
      mockFamilyRepository,
      mockInvitationRepository,
      ref,
      initialFamily: testFamily,
    );

    return notifier;
  });
}

/// Creates comprehensive provider overrides including network mocking for golden tests
/// This ensures no real HTTP calls can be made during test execution
List<Override> createGoldenTestOverrides({
  required User testUser,
  List<ScheduleSlot>? scheduleSlots,
  String? groupId,
  String? week,
  GroupsState? groupsState,
  List<entities.Vehicle>? vehicles,
  ScheduleConfig? scheduleConfig,
}) {
  final overrides = <Override>[
    // Always include user provider
    currentUserProvider.overrideWith((ref) => testUser),

    // Always include navigation provider
    nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),

    // CRITICAL: Prevent all real network calls during golden tests
    ...getAllNetworkMockOverrides(),
  ];

  // Add optional mocks if provided
  if (scheduleSlots != null && groupId != null && week != null) {
    overrides.addAll([
      createMockedScheduleRepositoryProvider(scheduleSlots),
      createMockedScheduleProvider(groupId, week, scheduleSlots),
    ]);
  }

  if (groupsState != null) {
    overrides.add(createMockedGroupsProvider(groupsState));
  }

  if (vehicles != null) {
    overrides.add(createMockedFamilyProvider(vehicles));
  }

  if (scheduleConfig != null && groupId != null) {
    overrides.add(createMockedGroupScheduleConfigProvider(groupId, scheduleConfig));
  }

  return overrides;
}

/// Pre-initialized GroupScheduleConfigNotifier that doesn't call use cases during tests
class _PreInitializedGroupScheduleConfigNotifier extends GroupScheduleConfigNotifier {
  _PreInitializedGroupScheduleConfigNotifier(
    String groupId,
    GetScheduleConfig getConfigUseCase,
    UpdateScheduleConfig updateConfigUseCase,
    ResetScheduleConfig? resetConfigUseCase,
    ErrorHandlerService? errorHandlerService, {
    required AsyncValue<ScheduleConfig?> initialState,
  }) : super(
         groupId,
         getConfigUseCase,
         updateConfigUseCase,
         resetConfigUseCase,
         errorHandlerService ?? MockErrorHandlerService(),
       ) {
    // Pre-set the state with test data to avoid async initialization issues
    state = initialState;
  }

  // Override loadConfig to do nothing - state is already set
  @override
  Future<void> loadConfig() async {
    // No-op: state is already pre-initialized with test data
  }

  @override
  Future<void> updateConfig(ScheduleConfig config) async {
    state = AsyncValue.data(config);
  }
}

/// Helper function to create a properly mocked GroupScheduleConfigProvider
/// This prevents use case initialization errors by mocking all dependencies
/// The notifier is pre-initialized with test data to avoid async loadConfig() issues
Override createMockedGroupScheduleConfigProvider(String groupId, ScheduleConfig? config) {
  return groupScheduleConfigProvider.overrideWith((
    ref,
    String providedGroupId,
  ) {
    // Create initial state
    final initialState = config != null
        ? AsyncValue.data(config)
        : const AsyncValue.data(null);

    // Create a custom notifier that pre-sets the state
    final notifier = _PreInitializedGroupScheduleConfigNotifier(
      providedGroupId,
      MockGetScheduleConfig(), // GetScheduleConfig - mocked
      MockUpdateScheduleConfig(), // UpdateScheduleConfig - mocked
      MockResetScheduleConfig(), // ResetScheduleConfig - mocked
      MockErrorHandlerService(), // ErrorHandlerService - mocked
      initialState: initialState,
    );

    return notifier;
  });
}

/// Helper function to create a mocked GroupScheduleConfigProvider in loading state
Override createMockedGroupScheduleConfigLoadingProvider(String groupId) {
  return groupScheduleConfigProvider.overrideWith((
    ref,
    String providedGroupId,
  ) {
    // Create a custom notifier that starts in loading state
    final notifier = _PreInitializedGroupScheduleConfigNotifier(
      providedGroupId,
      MockGetScheduleConfig(), // GetScheduleConfig - mocked
      MockUpdateScheduleConfig(), // UpdateScheduleConfig - mocked
      MockResetScheduleConfig(), // ResetScheduleConfig - mocked
      MockErrorHandlerService(), // ErrorHandlerService - mocked
      initialState: const AsyncValue.loading(),
    );

    return notifier;
  });
}

/// Helper function to create a mocked GroupScheduleConfigProvider in error state
Override createMockedGroupScheduleConfigErrorProvider(String groupId, String errorMessage) {
  return groupScheduleConfigProvider.overrideWith((
    ref,
    String providedGroupId,
  ) {
    // Create a custom notifier that starts in error state
    final notifier = _PreInitializedGroupScheduleConfigNotifier(
      providedGroupId,
      MockGetScheduleConfig(), // GetScheduleConfig - mocked
      MockUpdateScheduleConfig(), // UpdateScheduleConfig - mocked
      MockResetScheduleConfig(), // ResetScheduleConfig - mocked
      MockErrorHandlerService(), // ErrorHandlerService - mocked
      initialState: AsyncValue.error(errorMessage, StackTrace.current),
    );

    return notifier;
  });
}

/// Simple mock for GetScheduleConfig
class MockGetScheduleConfig extends Mock implements GetScheduleConfig {}

/// Simple mock for UpdateScheduleConfig
class MockUpdateScheduleConfig extends Mock implements UpdateScheduleConfig {}

/// Simple mock for ResetScheduleConfig
class MockResetScheduleConfig extends Mock implements ResetScheduleConfig {}

void main() {
  // Reset factories and setup mock fallbacks before tests
  setUpAll(() async {
    setupMockFallbacks();
    ScheduleDataFactory.resetCounters();
    GroupDataFactory.resetCounters();
    FamilyDataFactory.resetCounters();

    // CRITICAL: Prevent all real network calls during golden tests
    setupGoldenTestNetworkOverrides();

    // Initialize timezone database for all schedule tests
    tz.initializeTimeZones();
  });

  // Clean up network overrides after all tests complete
  tearDownAll(() {
    clearGoldenTestNetworkOverrides();
  });

  group('Schedule Widgets - Golden Tests (Real Production Code)', () {
    const testWeek = '2025-W41';

    group('ScheduleGrid Widget Tests', () {
      testWidgets('ScheduleGrid - with data (light theme)', (tester) async {
        final groups = GroupDataFactory.createLargeGroupList(count: 2);
        final scheduleConfig = createTestScheduleConfig(groups[0].id);
        final scheduleSlots = ScheduleDataFactory.createLargeScheduleSlotList(
          count: 10,
          groupId: groups[0].id,
        );
        final testUser = User(
          id: 'widget-user-1',
          email: 'widget1@example.com',
          name: 'Widget Test User 1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final overrides = createGoldenTestOverrides(
          testUser: testUser,
          scheduleSlots: scheduleSlots,
          groupId: groups[0].id,
          week: testWeek,
          groupsState: GroupsState(groups: groups),
        );

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ProviderScope(
            overrides: overrides,
            child: ScheduleGrid(
              groupId: groups[0].id,
              week: testWeek,
              scheduleData: scheduleSlots,
              scheduleConfig: scheduleConfig,
              onManageVehicles: (periodSlotData) {},
              onVehicleDrop: (day, time, vehicleId) {},
              onWeekChanged: (weekOffset) {},
            ),
          ),
          testName: 'schedule_grid_light_data',
          devices: DeviceConfigurations.crossPlatformSet,
          themes: [ThemeConfigurations.light],
        );
      });

      testWidgets('ScheduleGrid - with data (dark theme)', (tester) async {
        final groups = GroupDataFactory.createLargeGroupList(count: 2);
        final scheduleConfig = createTestScheduleConfig(groups[0].id);
        final scheduleSlots = ScheduleDataFactory.createLargeScheduleSlotList(
          count: 15,
          groupId: groups[0].id,
        );
        final testUser = User(
          id: 'widget-user-2',
          email: 'widget2@example.com',
          name: 'Widget Test User 2',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final overrides = createGoldenTestOverrides(
          testUser: testUser,
          scheduleSlots: scheduleSlots,
          groupId: groups[0].id,
          week: testWeek,
          groupsState: GroupsState(groups: groups),
        );

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ProviderScope(
            overrides: overrides,
            child: ScheduleGrid(
              groupId: groups[0].id,
              week: testWeek,
              scheduleData: scheduleSlots,
              scheduleConfig: scheduleConfig,
              onManageVehicles: (periodSlotData) {},
              onVehicleDrop: (day, time, vehicleId) {},
              onWeekChanged: (weekOffset) {},
            ),
          ),
          testName: 'schedule_grid_dark_data',
          devices: DeviceConfigurations.crossPlatformSet,
          themes: [ThemeConfigurations.dark],
        );
      });

      testWidgets('ScheduleGrid - empty schedule', (tester) async {
        final groups = GroupDataFactory.createLargeGroupList(count: 1);
        final scheduleSlots = <ScheduleSlot>[];
        final scheduleConfig = createTestScheduleConfig(groups[0].id);
        final testUser = User(
          id: 'widget-user-3',
          email: 'widget3@example.com',
          name: 'Widget Test User 3',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final overrides = [
          currentUserProvider.overrideWith((ref) => testUser),
          createMockedScheduleRepositoryProvider(scheduleSlots),
          createMockedScheduleProvider(groups[0].id, testWeek, scheduleSlots),
          createMockedGroupsProvider(GroupsState(groups: groups)),
            nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
        ];

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ProviderScope(
            overrides: overrides,
            child: ScheduleGrid(
              groupId: groups[0].id,
              week: testWeek,
              scheduleData: scheduleSlots,
              scheduleConfig: scheduleConfig,
              onManageVehicles: (periodSlotData) {},
              onVehicleDrop: (day, time, vehicleId) {},
              onWeekChanged: (weekOffset) {},
            ),
          ),
          testName: 'schedule_grid_empty',
          devices: [DeviceConfigurations.iphone13],
          themes: [ThemeConfigurations.light],
        );
      });

      testWidgets('ScheduleGrid - responsive design (small screen)', (tester) async {
        final groups = GroupDataFactory.createLargeGroupList(count: 2);
        final scheduleConfig = createTestScheduleConfig(groups[0].id);
        final scheduleSlots = ScheduleDataFactory.createLargeScheduleSlotList(
          count: 25,
          groupId: groups[0].id,
        );
        final testUser = User(
          id: 'widget-user-4',
          email: 'widget4@example.com',
          name: 'Widget Test User 4',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final overrides = [
          currentUserProvider.overrideWith((ref) => testUser),
          createMockedScheduleRepositoryProvider(scheduleSlots),
          createMockedScheduleProvider(groups[0].id, testWeek, scheduleSlots),
          createMockedGroupsProvider(GroupsState(groups: groups)),
            nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
        ];

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ProviderScope(
            overrides: overrides,
            child: ScheduleGrid(
              groupId: groups[0].id,
              week: testWeek,
              scheduleData: scheduleSlots,
              scheduleConfig: scheduleConfig,
              onManageVehicles: (periodSlotData) {},
              onVehicleDrop: (day, time, vehicleId) {},
              onWeekChanged: (weekOffset) {},
            ),
          ),
          testName: 'schedule_grid_responsive_small',
          devices: [DeviceConfigurations.iphoneSE],
          themes: [ThemeConfigurations.light],
        );
      });
    });

    group('VehicleSelectionModal Widget Tests', () {
      testWidgets('VehicleSelectionModal - with available vehicles (light)', (tester) async {
        final groups = GroupDataFactory.createLargeGroupList(count: 1);
        final vehicles = FamilyDataFactory.createLargeVehicleList(count: 5);
        final scheduleSlot = ScheduleDataFactory.createRealisticScheduleSlot(
          groupId: groups[0].id,
        );

        // Create PeriodSlotData for VehicleSelectionModal
        final periodSlotData = PeriodSlotData(
          dayOfWeek: scheduleSlot.dayOfWeek,
          period: AggregatePeriod(type: PeriodType.morning, timeSlots: [scheduleSlot.timeOfDay]),
          times: [scheduleSlot.timeOfDay],
          slots: [scheduleSlot],
          week: testWeek,
        );

        final testUser = User(
          id: 'widget-user-5',
          email: 'widget5@example.com',
          name: 'Widget Test User 5',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final overrides = [
          currentUserProvider.overrideWith((ref) => testUser),
          createMockedFamilyProvider(vehicles),
          createMockedScheduleRepositoryProvider([scheduleSlot]),
          createMockedGroupsProvider(GroupsState(groups: groups)),
          createMockedScheduleProvider(groups[0].id, testWeek, [scheduleSlot]),
          nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
        ];

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ProviderScope(
            overrides: overrides,
            child: VehicleSelectionModal(
              groupId: groups[0].id,
              scheduleSlot: periodSlotData,
            ),
          ),
          testName: 'vehicle_selection_modal_light_available',
          devices: DeviceConfigurations.crossPlatformSet,
          themes: [ThemeConfigurations.light],
        );
      });

      testWidgets('VehicleSelectionModal - with assigned vehicles (dark)', (tester) async {
        final groups = GroupDataFactory.createLargeGroupList(count: 1);
        final vehicles = FamilyDataFactory.createLargeVehicleList(count: 4);
        final scheduleSlot = ScheduleDataFactory.createRealisticScheduleSlot(
          groupId: groups[0].id,
        );

        // Create PeriodSlotData with vehicle assignment
        final periodSlotData = PeriodSlotData(
          dayOfWeek: scheduleSlot.dayOfWeek,
          period: AggregatePeriod(type: PeriodType.morning, timeSlots: [scheduleSlot.timeOfDay]),
          times: [scheduleSlot.timeOfDay],
          slots: [scheduleSlot],
          week: testWeek,
        );

        final testUser = User(
          id: 'widget-user-6',
          email: 'widget6@example.com',
          name: 'Widget Test User 6',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final overrides = [
          currentUserProvider.overrideWith((ref) => testUser),
          createMockedFamilyProvider(vehicles),
          createMockedScheduleRepositoryProvider([scheduleSlot]),
          createMockedGroupsProvider(GroupsState(groups: groups)),
          createMockedScheduleProvider(groups[0].id, testWeek, [scheduleSlot]),
          nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
        ];

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ProviderScope(
            overrides: overrides,
            child: VehicleSelectionModal(
              groupId: groups[0].id,
              scheduleSlot: periodSlotData,
            ),
          ),
          testName: 'vehicle_selection_modal_dark_assigned',
          devices: DeviceConfigurations.crossPlatformSet,
          themes: [ThemeConfigurations.dark],
        );
      });

      testWidgets('VehicleSelectionModal - responsive design (tablet)', (tester) async {
        final groups = GroupDataFactory.createLargeGroupList(count: 1);
        final vehicles = FamilyDataFactory.createLargeVehicleList(count: 8);
        final scheduleSlot = ScheduleDataFactory.createRealisticScheduleSlot(
          groupId: groups[0].id,
        );

        // Create PeriodSlotData
        final periodSlotData = PeriodSlotData(
          dayOfWeek: scheduleSlot.dayOfWeek,
          period: AggregatePeriod(type: PeriodType.morning, timeSlots: [scheduleSlot.timeOfDay]),
          times: [scheduleSlot.timeOfDay],
          slots: [scheduleSlot],
          week: testWeek,
        );

        final testUser = User(
          id: 'widget-user-7',
          email: 'widget7@example.com',
          name: 'Widget Test User 7',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final overrides = [
          currentUserProvider.overrideWith((ref) => testUser),
          createMockedFamilyProvider(vehicles),
          createMockedScheduleRepositoryProvider([scheduleSlot]),
          createMockedGroupsProvider(GroupsState(groups: groups)),
          createMockedScheduleProvider(groups[0].id, testWeek, [scheduleSlot]),
          nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
        ];

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ProviderScope(
            overrides: overrides,
            child: VehicleSelectionModal(
              groupId: groups[0].id,
              scheduleSlot: periodSlotData,
            ),
          ),
          testName: 'vehicle_selection_modal_tablet',
          devices: DeviceConfigurations.crossPlatformSet,
          themes: [ThemeConfigurations.light],
        );
      });
    });

    group('Schedule Component Edge Cases', () {
      testWidgets('ScheduleGrid - high contrast theme', (tester) async {
        final groups = GroupDataFactory.createLargeGroupList(count: 1);
        final scheduleConfig = createTestScheduleConfig(groups[0].id);
        final scheduleSlots = ScheduleDataFactory.createLargeScheduleSlotList(
          count: 10,
          groupId: groups[0].id,
        );
        final testUser = User(
          id: 'widget-user-8',
          email: 'widget8@example.com',
          name: 'Widget Test User 8',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final overrides = [
          currentUserProvider.overrideWith((ref) => testUser),
          createMockedScheduleRepositoryProvider(scheduleSlots),
          createMockedScheduleProvider(groups[0].id, testWeek, scheduleSlots),
          createMockedGroupsProvider(GroupsState(groups: groups)),
            nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
        ];

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ProviderScope(
            overrides: overrides,
            child: ScheduleGrid(
              groupId: groups[0].id,
              week: testWeek,
              scheduleData: scheduleSlots,
              scheduleConfig: scheduleConfig,
              onManageVehicles: (periodSlotData) {},
              onVehicleDrop: (day, time, vehicleId) {},
              onWeekChanged: (weekOffset) {},
            ),
          ),
          testName: 'schedule_grid_high_contrast',
          devices: [DeviceConfigurations.iphone13],
          themes: [ThemeConfigurations.highContrastLight],
        );
      });

      testWidgets('VehicleSelectionModal - complex assignment scenario', (tester) async {
        final groups = GroupDataFactory.createLargeGroupList(count: 1);
        final vehicles = FamilyDataFactory.createLargeVehicleList(count: 6);

        // Create a schedule slot with a complex assignment
        final scheduleSlot = ScheduleDataFactory.createRealisticScheduleSlot(
          groupId: groups[0].id,
        );

        // Create PeriodSlotData
        final periodSlotData = PeriodSlotData(
          dayOfWeek: scheduleSlot.dayOfWeek,
          period: AggregatePeriod(type: PeriodType.morning, timeSlots: [scheduleSlot.timeOfDay]),
          times: [scheduleSlot.timeOfDay],
          slots: [scheduleSlot],
          week: testWeek,
        );

        final testUser = User(
          id: 'widget-user-9',
          email: 'widget9@example.com',
          name: 'Widget Test User 9',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final overrides = [
          currentUserProvider.overrideWith((ref) => testUser),
          createMockedFamilyProvider(vehicles),
          createMockedScheduleRepositoryProvider([scheduleSlot]),
          createMockedGroupsProvider(GroupsState(groups: groups)),
          createMockedScheduleProvider(groups[0].id, testWeek, [scheduleSlot]),
          nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
        ];

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ProviderScope(
            overrides: overrides,
            child: VehicleSelectionModal(
              groupId: groups[0].id,
              scheduleSlot: periodSlotData,
            ),
          ),
          testName: 'vehicle_selection_modal_complex',
          devices: DeviceConfigurations.crossPlatformSet,
          themes: [ThemeConfigurations.light],
        );
      });
    });

    group('ScheduleConfigWidget Tests', () {
      testWidgets('ScheduleConfigWidget - with existing configuration (light theme)', (tester) async {
        final groups = GroupDataFactory.createLargeGroupList(count: 1);
        final groupId = groups[0].id;

        // Create a comprehensive schedule config with time slots for multiple days
        final scheduleConfig = ScheduleConfig(
          groupId: groupId,
          scheduleHours: const {
            'monday': ['08:00', '15:30'],
            'tuesday': ['08:00', '15:30'],
            'wednesday': ['08:00'],
            'thursday': ['08:00', '12:30', '15:30'],
            'friday': ['08:00', '15:30'],
            'saturday': [],
            'sunday': [],
          },
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        );

        final testUser = User(
          id: 'config-user-1',
          email: 'config1@example.com',
          name: 'Config Test User 1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final overrides = [
          currentUserProvider.overrideWith((ref) => testUser),
          createMockedGroupScheduleConfigProvider(groupId, scheduleConfig),
          createMockedGroupsProvider(GroupsState(groups: groups)),
          nav.navigationStateProvider.overrideWith(
            (ref) => nav.NavigationStateNotifier(),
          ),
        ];

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ProviderScope(
            overrides: overrides,
            child: ScheduleConfigWidget(
              groupId: groupId,
              onConfigUpdated: () {},
              onActionsChanged: (saveCallback, cancelCallback, hasChanges) {},
            ),
          ),
          testName: 'schedule_config_widget_light_existing',
          devices: DeviceConfigurations.crossPlatformSet,
          themes: [ThemeConfigurations.light],
        );
      });

      testWidgets('ScheduleConfigWidget - with existing configuration (dark theme)', (tester) async {
        final groups = GroupDataFactory.createLargeGroupList(count: 1);
        final groupId = groups[0].id;

        // Create schedule config with complex time slots
        final scheduleConfig = ScheduleConfig(
          groupId: groupId,
          scheduleHours: const {
            'monday': ['07:30', '08:45', '15:15', '16:30'],
            'tuesday': ['07:30', '15:15'],
            'wednesday': ['07:30', '08:45', '15:15'],
            'thursday': ['07:30', '15:15', '16:30'],
            'friday': ['07:30', '08:45', '15:15'],
            'saturday': ['10:00'],
            'sunday': [],
          },
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        );

        final testUser = User(
          id: 'config-user-2',
          email: 'config2@example.com',
          name: 'Config Test User 2',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final overrides = [
          currentUserProvider.overrideWith((ref) => testUser),
          createMockedGroupScheduleConfigProvider(groupId, scheduleConfig),
          createMockedGroupsProvider(GroupsState(groups: groups)),
          nav.navigationStateProvider.overrideWith(
            (ref) => nav.NavigationStateNotifier(),
          ),
        ];

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ProviderScope(
            overrides: overrides,
            child: ScheduleConfigWidget(
              groupId: groupId,
              onConfigUpdated: () {},
              onActionsChanged: (saveCallback, cancelCallback, hasChanges) {},
            ),
          ),
          testName: 'schedule_config_widget_dark_existing',
          devices: DeviceConfigurations.crossPlatformSet,
          themes: [ThemeConfigurations.dark],
        );
      });

      testWidgets('ScheduleConfigWidget - default configuration (no existing config)', (tester) async {
        final groups = GroupDataFactory.createLargeGroupList(count: 1);
        final groupId = groups[0].id;

        final testUser = User(
          id: 'config-user-3',
          email: 'config3@example.com',
          name: 'Config Test User 3',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final overrides = [
          currentUserProvider.overrideWith((ref) => testUser),
          createMockedGroupScheduleConfigProvider(
            groupId,
            null,
          ), // No existing config
          createMockedGroupsProvider(GroupsState(groups: groups)),
          nav.navigationStateProvider.overrideWith(
            (ref) => nav.NavigationStateNotifier(),
          ),
        ];

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ProviderScope(
            overrides: overrides,
            child: ScheduleConfigWidget(
              groupId: groupId,
              onConfigUpdated: () {},
              onActionsChanged: (saveCallback, cancelCallback, hasChanges) {},
            ),
          ),
          testName: 'schedule_config_widget_default',
          devices: DeviceConfigurations.crossPlatformSet,
          themes: [ThemeConfigurations.light],
        );
      });

      testWidgets('ScheduleConfigWidget - loading state', (tester) async {
        final groups = GroupDataFactory.createLargeGroupList(count: 1);
        final groupId = groups[0].id;

        final testUser = User(
          id: 'config-user-4',
          email: 'config4@example.com',
          name: 'Config Test User 4',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final overrides = [
          currentUserProvider.overrideWith((ref) => testUser),
          createMockedGroupScheduleConfigLoadingProvider(groupId),
          createMockedGroupsProvider(GroupsState(groups: groups)),
          nav.navigationStateProvider.overrideWith(
            (ref) => nav.NavigationStateNotifier(),
          ),
        ];

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ProviderScope(
            overrides: overrides,
            child: ScheduleConfigWidget(
              groupId: groupId,
              onConfigUpdated: () {},
              onActionsChanged: (saveCallback, cancelCallback, hasChanges) {},
            ),
          ),
          testName: 'schedule_config_widget_loading',
          devices: [DeviceConfigurations.iphone13],
          themes: [ThemeConfigurations.light],
          skipSettle:
              true, // Loading state has infinite animations that cause pumpAndSettle to timeout
        );
      });

      testWidgets('ScheduleConfigWidget - error state', (tester) async {
        final groups = GroupDataFactory.createLargeGroupList(count: 1);
        final groupId = groups[0].id;

        final testUser = User(
          id: 'config-user-5',
          email: 'config5@example.com',
          name: 'Config Test User 5',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final overrides = [
          currentUserProvider.overrideWith((ref) => testUser),
          createMockedGroupScheduleConfigErrorProvider(
            groupId,
            'Failed to load schedule configuration',
          ),
          createMockedGroupsProvider(GroupsState(groups: groups)),
          nav.navigationStateProvider.overrideWith(
            (ref) => nav.NavigationStateNotifier(),
          ),
        ];

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ProviderScope(
            overrides: overrides,
            child: ScheduleConfigWidget(
              groupId: groupId,
              onConfigUpdated: () {},
              onActionsChanged: (saveCallback, cancelCallback, hasChanges) {},
            ),
          ),
          testName: 'schedule_config_widget_error',
          devices: [DeviceConfigurations.iphone13],
          themes: [ThemeConfigurations.light],
        );
      });

      testWidgets('ScheduleConfigWidget - responsive design (small screen)', (tester) async {
        final groups = GroupDataFactory.createLargeGroupList(count: 1);
        final groupId = groups[0].id;

        // Create config with many time slots to test responsive behavior
        final scheduleConfig = ScheduleConfig(
          groupId: groupId,
          scheduleHours: const {
            'monday': [
              '07:00',
              '08:00',
              '09:00',
              '10:00',
              '11:00',
              '12:00',
              '13:00',
              '14:00',
              '15:00',
              '16:00',
            ],
            'tuesday': ['07:00', '08:00', '15:00'],
            'wednesday': ['07:00', '08:00', '15:00'],
            'thursday': ['07:00', '08:00', '15:00'],
            'friday': ['07:00', '08:00', '15:00'],
            'saturday': [],
            'sunday': [],
          },
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
        );

        final testUser = User(
          id: 'config-user-6',
          email: 'config6@example.com',
          name: 'Config Test User 6',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final overrides = [
          currentUserProvider.overrideWith((ref) => testUser),
          createMockedGroupScheduleConfigProvider(groupId, scheduleConfig),
          createMockedGroupsProvider(GroupsState(groups: groups)),
          nav.navigationStateProvider.overrideWith(
            (ref) => nav.NavigationStateNotifier(),
          ),
        ];

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ProviderScope(
            overrides: overrides,
            child: ScheduleConfigWidget(
              groupId: groupId,
              onConfigUpdated: () {},
              onActionsChanged: (saveCallback, cancelCallback, hasChanges) {},
            ),
          ),
          testName: 'schedule_config_widget_responsive_small',
          devices: [DeviceConfigurations.iphoneSE],
          themes: [ThemeConfigurations.light],
        );
      });

      testWidgets('ScheduleConfigWidget - responsive design (tablet)', (tester) async {
        final groups = GroupDataFactory.createLargeGroupList(count: 1);
        final groupId = groups[0].id;

        // Create comprehensive config for tablet testing
        final scheduleConfig = ScheduleConfig(
          groupId: groupId,
          scheduleHours: const {
            'monday': [
              '06:30',
              '07:15',
              '08:00',
              '08:45',
              '09:30',
              '10:15',
              '11:00',
              '14:00',
              '14:45',
              '15:30',
              '16:15',
              '17:00',
            ],
            'tuesday': [
              '06:30',
              '07:15',
              '08:00',
              '14:00',
              '14:45',
              '15:30',
              '16:15',
            ],
            'wednesday': [
              '06:30',
              '07:15',
              '08:00',
              '14:00',
              '14:45',
              '15:30',
              '16:15',
            ],
            'thursday': [
              '06:30',
              '07:15',
              '08:00',
              '09:30',
              '10:15',
              '11:00',
              '14:00',
              '14:45',
              '15:30',
              '16:15',
            ],
            'friday': ['06:30', '07:15', '08:00', '14:00', '14:45', '15:30'],
            'saturday': ['09:00', '10:00', '11:00', '12:00'],
            'sunday': [],
          },
          createdAt: DateTime.now().subtract(const Duration(days: 45)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
        );

        final testUser = User(
          id: 'config-user-7',
          email: 'config7@example.com',
          name: 'Config Test User 7',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final overrides = [
          currentUserProvider.overrideWith((ref) => testUser),
          createMockedGroupScheduleConfigProvider(groupId, scheduleConfig),
          createMockedGroupsProvider(GroupsState(groups: groups)),
          nav.navigationStateProvider.overrideWith(
            (ref) => nav.NavigationStateNotifier(),
          ),
        ];

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ProviderScope(
            overrides: overrides,
            child: ScheduleConfigWidget(
              groupId: groupId,
              onConfigUpdated: () {},
              onActionsChanged: (saveCallback, cancelCallback, hasChanges) {},
            ),
          ),
          testName: 'schedule_config_widget_responsive_tablet',
          devices: [DeviceConfigurations.iPadPro],
          themes: [ThemeConfigurations.light],
        );
      });

      testWidgets('ScheduleConfigWidget - high contrast theme accessibility', (tester) async {
        final groups = GroupDataFactory.createLargeGroupList(count: 1);
        final groupId = groups[0].id;

        final scheduleConfig = ScheduleConfig(
          groupId: groupId,
          scheduleHours: const {
            'monday': ['08:00', '15:00'],
            'tuesday': ['08:00', '15:00'],
            'wednesday': ['08:00'],
            'thursday': ['08:00', '15:00'],
            'friday': ['08:00', '15:00'],
            'saturday': [],
            'sunday': [],
          },
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        final testUser = User(
          id: 'config-user-8',
          email: 'config8@example.com',
          name: 'Config Test User 8',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final overrides = [
          currentUserProvider.overrideWith((ref) => testUser),
          createMockedGroupScheduleConfigProvider(groupId, scheduleConfig),
          createMockedGroupsProvider(GroupsState(groups: groups)),
          nav.navigationStateProvider.overrideWith(
            (ref) => nav.NavigationStateNotifier(),
          ),
        ];

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ProviderScope(
            overrides: overrides,
            child: ScheduleConfigWidget(
              groupId: groupId,
              onConfigUpdated: () {},
              onActionsChanged: (saveCallback, cancelCallback, hasChanges) {},
            ),
          ),
          testName: 'schedule_config_widget_high_contrast',
          devices: [DeviceConfigurations.iphone13],
          themes: [ThemeConfigurations.highContrastLight],
        );
      });

      testWidgets('ScheduleConfigWidget - edge case (weekend-only schedule)', (tester) async {
        final groups = GroupDataFactory.createLargeGroupList(count: 1);
        final groupId = groups[0].id;

        // Create schedule config with only weekend time slots
        final scheduleConfig = ScheduleConfig(
          groupId: groupId,
          scheduleHours: const {
            'monday': [],
            'tuesday': [],
            'wednesday': [],
            'thursday': [],
            'friday': [],
            'saturday': ['09:00', '12:00', '15:00', '18:00'],
            'sunday': ['10:00', '13:00', '16:00'],
          },
          createdAt: DateTime.now().subtract(const Duration(days: 8)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        );

        final testUser = User(
          id: 'config-user-9',
          email: 'config9@example.com',
          name: 'Config Test User 9',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final overrides = [
          currentUserProvider.overrideWith((ref) => testUser),
          createMockedGroupScheduleConfigProvider(groupId, scheduleConfig),
          createMockedGroupsProvider(GroupsState(groups: groups)),
          nav.navigationStateProvider.overrideWith(
            (ref) => nav.NavigationStateNotifier(),
          ),
        ];

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ProviderScope(
            overrides: overrides,
            child: ScheduleConfigWidget(
              groupId: groupId,
              onConfigUpdated: () {},
              onActionsChanged: (saveCallback, cancelCallback, hasChanges) {},
            ),
          ),
          testName: 'schedule_config_widget_weekend_only',
          devices: [DeviceConfigurations.iphone13],
          themes: [ThemeConfigurations.light],
        );
      });

      testWidgets('ScheduleConfigWidget - edge case (max time slots per day)', (tester) async {
        final groups = GroupDataFactory.createLargeGroupList(count: 1);
        final groupId = groups[0].id;

        // Create schedule config with maximum time slots for testing limits
        final scheduleConfig = ScheduleConfig(
          groupId: groupId,
          scheduleHours: const {
            'monday': [
              '06:00',
              '07:00',
              '08:00',
              '09:00',
              '10:00',
              '11:00',
              '12:00',
              '13:00',
              '14:00',
              '15:00',
              '16:00',
              '17:00',
              '18:00',
              '19:00',
              '20:00',
            ],
            'tuesday': ['08:00'],
            'wednesday': ['08:00'],
            'thursday': ['08:00'],
            'friday': ['08:00'],
            'saturday': [],
            'sunday': [],
          },
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 15)),
        );

        final testUser = User(
          id: 'config-user-10',
          email: 'config10@example.com',
          name: 'Config Test User 10',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final overrides = [
          currentUserProvider.overrideWith((ref) => testUser),
          createMockedGroupScheduleConfigProvider(groupId, scheduleConfig),
          createMockedGroupsProvider(GroupsState(groups: groups)),
          nav.navigationStateProvider.overrideWith(
            (ref) => nav.NavigationStateNotifier(),
          ),
        ];

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ProviderScope(
            overrides: overrides,
            child: ScheduleConfigWidget(
              groupId: groupId,
              onConfigUpdated: () {},
              onActionsChanged: (saveCallback, cancelCallback, hasChanges) {},
            ),
          ),
          testName: 'schedule_config_widget_max_slots',
          devices: [DeviceConfigurations.iphone13],
          themes: [ThemeConfigurations.light],
        );
      });
    });

    group('ScheduleSlotWidget Tests', () {
      testWidgets('ScheduleSlotWidget - empty slot (light theme)', (tester) async {
        final groups = GroupDataFactory.createLargeGroupList(count: 1);
        final testUser = User(
          id: 'slot-user-1',
          email: 'slot1@example.com',
          name: 'Slot Test User 1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final overrides = [
          currentUserProvider.overrideWith((ref) => testUser),
          createMockedGroupsProvider(GroupsState(groups: groups)),
          nav.navigationStateProvider.overrideWith(
            (ref) => nav.NavigationStateNotifier(),
          ),
        ];

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ProviderScope(
            overrides: overrides,
            child: ScheduleSlotWidget(
              groupId: groups[0].id,
              day: 'Monday',
              time: '08:00',
              week: testWeek,
              scheduleSlot: const PeriodSlotData(
                dayOfWeek: DayOfWeek.monday,
                period: AggregatePeriod(type: PeriodType.morning, timeSlots: [TimeOfDayValue(8, 0)]),
                times: [TimeOfDayValue(8, 0)],
                slots: [],
                week: '2025-W41',
              ),
              onTap: () {},
              onVehicleDrop: (vehicleId) {},
            ),
          ),
          testName: 'schedule_slot_widget_empty_light',
          devices: DeviceConfigurations.crossPlatformSet,
          themes: [ThemeConfigurations.light],
        );
      });

      testWidgets('ScheduleSlotWidget - empty slot (dark theme)', (tester) async {
        final groups = GroupDataFactory.createLargeGroupList(count: 1);
        final testUser = User(
          id: 'slot-user-2',
          email: 'slot2@example.com',
          name: 'Slot Test User 2',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final overrides = [
          currentUserProvider.overrideWith((ref) => testUser),
          createMockedGroupsProvider(GroupsState(groups: groups)),
          nav.navigationStateProvider.overrideWith(
            (ref) => nav.NavigationStateNotifier(),
          ),
        ];

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ProviderScope(
            overrides: overrides,
            child: ScheduleSlotWidget(
              groupId: groups[0].id,
              day: 'Tuesday',
              time: '15:00',
              week: testWeek,
              scheduleSlot: const PeriodSlotData(
                dayOfWeek: DayOfWeek.tuesday,
                period: AggregatePeriod(type: PeriodType.afternoon, timeSlots: [TimeOfDayValue(15, 0)]),
                times: [TimeOfDayValue(15, 0)],
                slots: [],
                week: '2025-W41',
              ),
              onTap: () {},
              onVehicleDrop: (vehicleId) {},
            ),
          ),
          testName: 'schedule_slot_widget_empty_dark',
          devices: DeviceConfigurations.crossPlatformSet,
          themes: [ThemeConfigurations.dark],
        );
      });

      testWidgets('ScheduleSlotWidget - single vehicle with children', (tester) async {
        final groups = GroupDataFactory.createLargeGroupList(count: 1);
        final scheduleSlot = ScheduleDataFactory.createRealisticScheduleSlot(
          groupId: groups[0].id,
        );

        // Create PeriodSlotData for ScheduleSlotWidget
        final periodSlotData = PeriodSlotData(
          dayOfWeek: scheduleSlot.dayOfWeek,
          period: AggregatePeriod(type: PeriodType.morning, timeSlots: [scheduleSlot.timeOfDay]),
          times: [scheduleSlot.timeOfDay],
          slots: [scheduleSlot],
          week: testWeek,
        );

        final testUser = User(
          id: 'slot-user-3',
          email: 'slot3@example.com',
          name: 'Slot Test User 3',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final overrides = [
          currentUserProvider.overrideWith((ref) => testUser),
          createMockedGroupsProvider(GroupsState(groups: groups)),
          nav.navigationStateProvider.overrideWith(
            (ref) => nav.NavigationStateNotifier(),
          ),
        ];

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ProviderScope(
            overrides: overrides,
            child: ScheduleSlotWidget(
              groupId: groups[0].id,
              day: 'Monday',
              time: scheduleSlot.timeOfDay.toApiFormat(),
              week: testWeek,
              scheduleSlot: periodSlotData,
              onTap: () {},
              onVehicleDrop: (vehicleId) {},
            ),
          ),
          testName: 'schedule_slot_widget_single_vehicle',
          devices: DeviceConfigurations.crossPlatformSet,
          themes: [ThemeConfigurations.light],
        );
      });

      testWidgets('ScheduleSlotWidget - multiple vehicles', (tester) async {
        final groups = GroupDataFactory.createLargeGroupList(count: 1);
        final scheduleSlots =
            ScheduleDataFactory.createLargeScheduleSlotList(
                  count: 3,
                  groupId: groups[0].id,
                  // Create multiple slots for the same time period
                )
                .map(
                  (slot) =>
                      slot.copyWith(timeOfDay: const TimeOfDayValue(8, 0)),
                )
                .toList();

        // Create PeriodSlotData with multiple slots
        final periodSlotData = PeriodSlotData(
          dayOfWeek: scheduleSlots[0].dayOfWeek,
          period: AggregatePeriod.fromTimeStrings(
            type: PeriodType.morning,
            timeStrings: [scheduleSlots[0].timeOfDay.toApiFormat()],
          ),
          times: [scheduleSlots[0].timeOfDay],
          slots: scheduleSlots,
          week: testWeek,
        );

        final testUser = User(
          id: 'slot-user-4',
          email: 'slot4@example.com',
          name: 'Slot Test User 4',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final overrides = [
          currentUserProvider.overrideWith((ref) => testUser),
          createMockedGroupsProvider(GroupsState(groups: groups)),
          nav.navigationStateProvider.overrideWith(
            (ref) => nav.NavigationStateNotifier(),
          ),
        ];

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ProviderScope(
            overrides: overrides,
            child: ScheduleSlotWidget(
              groupId: groups[0].id,
              day: 'Monday',
              time: scheduleSlots[0].timeOfDay.toApiFormat(),
              week: testWeek,
              scheduleSlot: periodSlotData,
              onTap: () {},
              onVehicleDrop: (vehicleId) {},
            ),
          ),
          testName: 'schedule_slot_widget_multiple_vehicles',
          devices: DeviceConfigurations.crossPlatformSet,
          themes: [ThemeConfigurations.light],
        );
      });

      testWidgets('ScheduleSlotWidget - vehicles without children', (tester) async {
        final groups = GroupDataFactory.createLargeGroupList(count: 1);
        final scheduleSlot = ScheduleDataFactory.createRealisticScheduleSlot(
          groupId: groups[0].id,
        );

        // Remove children from vehicle assignments
        final slotWithNoChildren = scheduleSlot.copyWith(
          vehicleAssignments: scheduleSlot.vehicleAssignments
              .map((va) => va.copyWith(childAssignments: []))
              .toList(),
        );

        final periodSlotData = PeriodSlotData(
          dayOfWeek: slotWithNoChildren.dayOfWeek,
          period: AggregatePeriod.fromTimeStrings(
            type: PeriodType.morning,
            timeStrings: [slotWithNoChildren.timeOfDay.toApiFormat()],
          ),
          times: [slotWithNoChildren.timeOfDay],
          slots: [slotWithNoChildren],
          week: testWeek,
        );

        final testUser = User(
          id: 'slot-user-5',
          email: 'slot5@example.com',
          name: 'Slot Test User 5',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final overrides = [
          currentUserProvider.overrideWith((ref) => testUser),
          createMockedGroupsProvider(GroupsState(groups: groups)),
          nav.navigationStateProvider.overrideWith(
            (ref) => nav.NavigationStateNotifier(),
          ),
        ];

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ProviderScope(
            overrides: overrides,
            child: ScheduleSlotWidget(
              groupId: groups[0].id,
              day: 'Monday',
              time: slotWithNoChildren.timeOfDay.toApiFormat(),
              week: testWeek,
              scheduleSlot: periodSlotData,
              onTap: () {},
              onVehicleDrop: (vehicleId) {},
            ),
          ),
          testName: 'schedule_slot_widget_no_children',
          devices: [DeviceConfigurations.iphone13],
          themes: [ThemeConfigurations.light],
        );
      });

      testWidgets('ScheduleSlotWidget - responsive design (small screen)', (tester) async {
        final groups = GroupDataFactory.createLargeGroupList(count: 1);
        final scheduleSlots =
            ScheduleDataFactory.createLargeScheduleSlotList(
                  count: 5,
                  groupId: groups[0].id,
                )
                .map(
                  (slot) =>
                      slot.copyWith(timeOfDay: const TimeOfDayValue(8, 0)),
                )
                .toList();

        final periodSlotData = PeriodSlotData(
          dayOfWeek: scheduleSlots[0].dayOfWeek,
          period: AggregatePeriod.fromTimeStrings(
            type: PeriodType.morning,
            timeStrings: [scheduleSlots[0].timeOfDay.toApiFormat()],
          ),
          times: [scheduleSlots[0].timeOfDay],
          slots: scheduleSlots,
          week: testWeek,
        );

        final testUser = User(
          id: 'slot-user-6',
          email: 'slot6@example.com',
          name: 'Slot Test User 6',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final overrides = [
          currentUserProvider.overrideWith((ref) => testUser),
          createMockedGroupsProvider(GroupsState(groups: groups)),
          nav.navigationStateProvider.overrideWith(
            (ref) => nav.NavigationStateNotifier(),
          ),
        ];

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ProviderScope(
            overrides: overrides,
            child: ScheduleSlotWidget(
              groupId: groups[0].id,
              day: 'Monday',
              time: scheduleSlots[0].timeOfDay.toApiFormat(),
              week: testWeek,
              scheduleSlot: periodSlotData,
              onTap: () {},
              onVehicleDrop: (vehicleId) {},
            ),
          ),
          testName: 'schedule_slot_widget_responsive_small',
          devices: [DeviceConfigurations.iphoneSE],
          themes: [ThemeConfigurations.light],
        );
      });

      testWidgets('ScheduleSlotWidget - responsive design (tablet)', (tester) async {
        final groups = GroupDataFactory.createLargeGroupList(count: 1);
        final scheduleSlots =
            ScheduleDataFactory.createLargeScheduleSlotList(
                  count: 8,
                  groupId: groups[0].id,
                )
                .map(
                  (slot) =>
                      slot.copyWith(timeOfDay: const TimeOfDayValue(15, 30)),
                )
                .toList();

        final periodSlotData = PeriodSlotData(
          dayOfWeek: scheduleSlots[0].dayOfWeek,
          period: AggregatePeriod.fromTimeStrings(
            type: PeriodType.afternoon,
            timeStrings: [scheduleSlots[0].timeOfDay.toApiFormat()],
          ),
          times: [scheduleSlots[0].timeOfDay],
          slots: scheduleSlots,
          week: testWeek,
        );

        final testUser = User(
          id: 'slot-user-7',
          email: 'slot7@example.com',
          name: 'Slot Test User 7',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final overrides = [
          currentUserProvider.overrideWith((ref) => testUser),
          createMockedGroupsProvider(GroupsState(groups: groups)),
          nav.navigationStateProvider.overrideWith(
            (ref) => nav.NavigationStateNotifier(),
          ),
        ];

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ProviderScope(
            overrides: overrides,
            child: ScheduleSlotWidget(
              groupId: groups[0].id,
              day: 'Monday',
              time: scheduleSlots[0].timeOfDay.toApiFormat(),
              week: testWeek,
              scheduleSlot: periodSlotData,
              onTap: () {},
              onVehicleDrop: (vehicleId) {},
            ),
          ),
          testName: 'schedule_slot_widget_responsive_tablet',
          devices: [DeviceConfigurations.iPadPro],
          themes: [ThemeConfigurations.light],
        );
      });

      testWidgets('ScheduleSlotWidget - high contrast theme accessibility', (tester) async {
        final groups = GroupDataFactory.createLargeGroupList(count: 1);
        final scheduleSlot = ScheduleDataFactory.createRealisticScheduleSlot(
          groupId: groups[0].id,
        );

        final periodSlotData = PeriodSlotData(
          dayOfWeek: scheduleSlot.dayOfWeek,
          period: AggregatePeriod(type: PeriodType.morning, timeSlots: [scheduleSlot.timeOfDay]),
          times: [scheduleSlot.timeOfDay],
          slots: [scheduleSlot],
          week: testWeek,
        );

        final testUser = User(
          id: 'slot-user-8',
          email: 'slot8@example.com',
          name: 'Slot Test User 8',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final overrides = [
          currentUserProvider.overrideWith((ref) => testUser),
          createMockedGroupsProvider(GroupsState(groups: groups)),
          nav.navigationStateProvider.overrideWith(
            (ref) => nav.NavigationStateNotifier(),
          ),
        ];

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ProviderScope(
            overrides: overrides,
            child: ScheduleSlotWidget(
              groupId: groups[0].id,
              day: 'Monday',
              time: scheduleSlot.timeOfDay.toApiFormat(),
              week: testWeek,
              scheduleSlot: periodSlotData,
              onTap: () {},
              onVehicleDrop: (vehicleId) {},
            ),
          ),
          testName: 'schedule_slot_widget_high_contrast',
          devices: [DeviceConfigurations.iphone13],
          themes: [ThemeConfigurations.highContrastLight],
        );
      });

      testWidgets('ScheduleSlotWidget - edge case (many vehicles overflow)', (tester) async {
        final groups = GroupDataFactory.createLargeGroupList(count: 1);
        final scheduleSlots =
            ScheduleDataFactory.createLargeScheduleSlotList(
                  count: 15,
                  groupId: groups[0].id,
                )
                .map(
                  (slot) =>
                      slot.copyWith(timeOfDay: const TimeOfDayValue(8, 0)),
                )
                .toList();

        final periodSlotData = PeriodSlotData(
          dayOfWeek: scheduleSlots[0].dayOfWeek,
          period: AggregatePeriod.fromTimeStrings(
            type: PeriodType.morning,
            timeStrings: [scheduleSlots[0].timeOfDay.toApiFormat()],
          ),
          times: [scheduleSlots[0].timeOfDay],
          slots: scheduleSlots,
          week: testWeek,
        );

        final testUser = User(
          id: 'slot-user-9',
          email: 'slot9@example.com',
          name: 'Slot Test User 9',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final overrides = [
          currentUserProvider.overrideWith((ref) => testUser),
          createMockedGroupsProvider(GroupsState(groups: groups)),
          nav.navigationStateProvider.overrideWith(
            (ref) => nav.NavigationStateNotifier(),
          ),
        ];

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ProviderScope(
            overrides: overrides,
            child: ScheduleSlotWidget(
              groupId: groups[0].id,
              day: 'Monday',
              time: scheduleSlots[0].timeOfDay.toApiFormat(),
              week: testWeek,
              scheduleSlot: periodSlotData,
              onTap: () {},
              onVehicleDrop: (vehicleId) {},
            ),
          ),
          testName: 'schedule_slot_widget_many_vehicles',
          devices: [DeviceConfigurations.iphone13],
          themes: [ThemeConfigurations.light],
        );
      });
    });

    group('CreateSchedulePage Tests', () {
      testWidgets('CreateSchedulePage - basic layout (light theme)', (tester) async {
        await GoldenTestWrapper.testScreen(
          tester: tester,
          screen: const CreateSchedulePage(),
          testName: 'create_schedule_page_light_basic',
          devices: DeviceConfigurations.crossPlatformSet,
          themes: [ThemeConfigurations.light],
        );
      });

      testWidgets('CreateSchedulePage - basic layout (dark theme)', (tester) async {
        await GoldenTestWrapper.testScreen(
          tester: tester,
          screen: const CreateSchedulePage(),
          testName: 'create_schedule_page_dark_basic',
          devices: DeviceConfigurations.crossPlatformSet,
          themes: [ThemeConfigurations.dark],
        );
      });

      testWidgets('CreateSchedulePage - responsive design (small screen)', (tester) async {
        await GoldenTestWrapper.testScreen(
          tester: tester,
          screen: const CreateSchedulePage(),
          testName: 'create_schedule_page_responsive_small',
          devices: [DeviceConfigurations.iphoneSE],
          themes: [ThemeConfigurations.light],
        );
      });

      testWidgets('CreateSchedulePage - responsive design (tablet)', (tester) async {
        await GoldenTestWrapper.testScreen(
          tester: tester,
          screen: const CreateSchedulePage(),
          testName: 'create_schedule_page_responsive_tablet',
          devices: [DeviceConfigurations.iPadPro],
          themes: [ThemeConfigurations.light],
        );
      });

      testWidgets('CreateSchedulePage - high contrast theme accessibility', (tester) async {
        await GoldenTestWrapper.testScreen(
          tester: tester,
          screen: const CreateSchedulePage(),
          testName: 'create_schedule_page_high_contrast',
          devices: [DeviceConfigurations.iphone13],
          themes: [ThemeConfigurations.highContrastLight],
        );
      });

      testWidgets('CreateSchedulePage - edge case (minimal content)', (tester) async {
        await GoldenTestWrapper.testScreen(
          tester: tester,
          screen: const CreateSchedulePage(),
          testName: 'create_schedule_page_minimal',
          devices: [DeviceConfigurations.pixel4a],
          themes: [ThemeConfigurations.light],
        );
      });
    });

    group('ChildAssignmentSheet Tests', () {
      testWidgets('ChildAssignmentSheet - with available children (light theme)', (tester) async {
        final groups = GroupDataFactory.createLargeGroupList(count: 1);
        final vehicleAssignment = ScheduleDataFactory.createRealisticVehicleAssignment(
          index: 1,
          childCount: 2,
        );
        final availableChildren = FamilyDataFactory.createLargeChildList(count: 5);
        final assignedChildIds = ['child-1', 'child-2'];

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ProviderScope(
            overrides: [
              createMockedGroupsProvider(GroupsState(groups: groups)),
              nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
            ],
            child: ChildAssignmentSheet(
              groupId: groups[0].id,
              week: testWeek,
              slotId: 'slot-1',
              vehicleAssignment: vehicleAssignment,
              availableChildren: availableChildren,
              currentlyAssignedChildIds: assignedChildIds,
            ),
          ),
          testName: 'child_assignment_sheet_light_children',
          devices: DeviceConfigurations.crossPlatformSet,
          themes: [ThemeConfigurations.light],
        );
      });

      testWidgets('ChildAssignmentSheet - capacity full scenario (dark theme)', (tester) async {
        final groups = GroupDataFactory.createLargeGroupList(count: 1);
        final vehicleAssignment = ScheduleDataFactory.createFullVehicleAssignment();
        final availableChildren = FamilyDataFactory.createLargeChildList(count: 8);
        final assignedChildIds = ['child-1', 'child-2'];

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ProviderScope(
            overrides: [
              createMockedGroupsProvider(GroupsState(groups: groups)),
              nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
            ],
            child: ChildAssignmentSheet(
              groupId: groups[0].id,
              week: testWeek,
              slotId: 'slot-2',
              vehicleAssignment: vehicleAssignment,
              availableChildren: availableChildren,
              currentlyAssignedChildIds: assignedChildIds,
            ),
          ),
          testName: 'child_assignment_sheet_dark_capacity_full',
          devices: DeviceConfigurations.crossPlatformSet,
          themes: [ThemeConfigurations.dark],
        );
      });

      testWidgets('ChildAssignmentSheet - many children selection (tablet)', (tester) async {
        final groups = GroupDataFactory.createLargeGroupList(count: 1);
        final vehicleAssignment = ScheduleDataFactory.createRealisticVehicleAssignment(
          index: 3,
          childCount: 0,
        );
        final availableChildren = FamilyDataFactory.createLargeChildList();
        final assignedChildIds = <String>[];

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ProviderScope(
            overrides: [
              createMockedGroupsProvider(GroupsState(groups: groups)),
              nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
            ],
            child: ChildAssignmentSheet(
              groupId: groups[0].id,
              week: testWeek,
              slotId: 'slot-3',
              vehicleAssignment: vehicleAssignment,
              availableChildren: availableChildren,
              currentlyAssignedChildIds: assignedChildIds,
            ),
          ),
          testName: 'child_assignment_sheet_tablet_many_children',
          devices: [DeviceConfigurations.iPadPro],
          themes: [ThemeConfigurations.light],
        );
      });

      testWidgets('ChildAssignmentSheet - responsive design (small screen)', (tester) async {
        final groups = GroupDataFactory.createLargeGroupList(count: 1);
        final vehicleAssignment = ScheduleDataFactory.createRealisticVehicleAssignment(
          index: 4,
          childCount: 1,
        );
        final availableChildren = FamilyDataFactory.createLargeChildList(count: 6);
        final assignedChildIds = ['child-1'];

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ProviderScope(
            overrides: [
              createMockedGroupsProvider(GroupsState(groups: groups)),
              nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
            ],
            child: ChildAssignmentSheet(
              groupId: groups[0].id,
              week: testWeek,
              slotId: 'slot-4',
              vehicleAssignment: vehicleAssignment,
              availableChildren: availableChildren,
              currentlyAssignedChildIds: assignedChildIds,
            ),
          ),
          testName: 'child_assignment_sheet_responsive_small',
          devices: [DeviceConfigurations.iphoneSE],
          themes: [ThemeConfigurations.light],
        );
      });
    });

    group('ScheduleTimePicker Tests', () {
      testWidgets('ScheduleTimePicker - empty selection (light theme)', (tester) async {
        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ScheduleTimePicker(
            selectedTimeSlots: const [],
            onTimeSlotsChanged: (timeSlots) {},
            maxSlots: 10,
            weekdayLabel: 'Monday',
          ),
          testName: 'schedule_time_picker_empty_light',
          devices: DeviceConfigurations.crossPlatformSet,
          themes: [ThemeConfigurations.light],
          constrainedSize: const Size(400, 600),
        );
      });

      testWidgets('ScheduleTimePicker - with selected times (dark theme)', (tester) async {
        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ScheduleTimePicker(
            selectedTimeSlots: const ['08:00', '12:30', '15:45'],
            onTimeSlotsChanged: (timeSlots) {},
            maxSlots: 8,
            weekdayLabel: 'Tuesday',
          ),
          testName: 'schedule_time_picker_selected_dark',
          devices: DeviceConfigurations.crossPlatformSet,
          themes: [ThemeConfigurations.dark],
        );
      });

      testWidgets('ScheduleTimePicker - maximum slots reached', (tester) async {
        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ScheduleTimePicker(
            selectedTimeSlots: const [
              '06:00', '06:30', '07:00', '07:30', '08:00', '08:30',
              '09:00', '09:30', '10:00', '10:30'
            ],
            onTimeSlotsChanged: (timeSlots) {},
            maxSlots: 10,
            weekdayLabel: 'Wednesday',
          ),
          testName: 'schedule_time_picker_max_slots',
          devices: DeviceConfigurations.crossPlatformSet,
          themes: [ThemeConfigurations.light],
        );
      });

      testWidgets('ScheduleTimePicker - responsive design (tablet)', (tester) async {
        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ScheduleTimePicker(
            selectedTimeSlots: const ['07:15', '11:45', '14:20', '16:30'],
            onTimeSlotsChanged: (timeSlots) {},
            maxSlots: 15,
            weekdayLabel: 'Thursday',
          ),
          testName: 'schedule_time_picker_tablet',
          devices: [DeviceConfigurations.iPadPro],
          themes: [ThemeConfigurations.light],
        );
      });

      testWidgets('ScheduleTimePicker - high contrast theme', (tester) async {
        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: ScheduleTimePicker(
            selectedTimeSlots: const ['08:30', '13:00', '17:15'],
            onTimeSlotsChanged: (timeSlots) {},
            maxSlots: 6,
            weekdayLabel: 'Friday',
          ),
          testName: 'schedule_time_picker_high_contrast',
          devices: [DeviceConfigurations.iphone13],
          themes: [ThemeConfigurations.highContrastLight],
        );
      });
    });

    group('PerDayTimeSlotConfig Tests', () {
      testWidgets('PerDayTimeSlotConfig - empty state (light theme)', (tester) async {
        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: PerDayTimeSlotConfig(
            weekday: 'monday',
            weekdayLabel: 'Monday',
            timeSlots: const [],
            onTimeSlotsChanged: (timeSlots) {},
            maxSlots: 10,
          ),
          testName: 'per_day_time_slot_config_empty_light',
          devices: DeviceConfigurations.crossPlatformSet,
          themes: [ThemeConfigurations.light],
        );
      });

      testWidgets('PerDayTimeSlotConfig - with time slots (dark theme)', (tester) async {
        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: PerDayTimeSlotConfig(
            weekday: 'tuesday',
            weekdayLabel: 'Tuesday',
            timeSlots: const ['08:00', '12:30', '15:45'],
            onTimeSlotsChanged: (timeSlots) {},
            maxSlots: 8,
          ),
          testName: 'per_day_time_slot_config_with_slots_dark',
          devices: DeviceConfigurations.crossPlatformSet,
          themes: [ThemeConfigurations.dark],
        );
      });

      testWidgets('PerDayTimeSlotConfig - many time slots', (tester) async {
        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: PerDayTimeSlotConfig(
            weekday: 'wednesday',
            weekdayLabel: 'Wednesday',
            timeSlots: const [
              '06:00', '06:30', '07:00', '08:00', '09:00', '10:00',
              '11:00', '12:00', '13:00', '14:00', '15:00', '16:00'
            ],
            onTimeSlotsChanged: (timeSlots) {},
            maxSlots: 15,
          ),
          testName: 'per_day_time_slot_config_many_slots',
          devices: DeviceConfigurations.crossPlatformSet,
          themes: [ThemeConfigurations.light],
        );
      });

      testWidgets('PerDayTimeSlotConfig - responsive design (small screen)', (tester) async {
        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: PerDayTimeSlotConfig(
            weekday: 'thursday',
            weekdayLabel: 'Thursday',
            timeSlots: const ['07:30', '12:15', '16:45'],
            onTimeSlotsChanged: (timeSlots) {},
            maxSlots: 6,
          ),
          testName: 'per_day_time_slot_config_responsive_small',
          devices: [DeviceConfigurations.iphoneSE],
          themes: [ThemeConfigurations.light],
        );
      });

      testWidgets('PerDayTimeSlotConfig - responsive design (tablet)', (tester) async {
        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: PerDayTimeSlotConfig(
            weekday: 'friday',
            weekdayLabel: 'Friday',
            timeSlots: const ['08:15', '11:30', '14:20', '17:00', '19:30'],
            onTimeSlotsChanged: (timeSlots) {},
            maxSlots: 12,
          ),
          testName: 'per_day_time_slot_config_responsive_tablet',
          devices: [DeviceConfigurations.iPadPro],
          themes: [ThemeConfigurations.light],
        );
      });
    });
  });
}