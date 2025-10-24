// EduLift - Family Screens Golden Tests
// Comprehensive visual regression tests for family screens using REAL production pages

@Tags(['golden'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

import 'package:edulift/features/family/presentation/pages/family_management_screen.dart';
import 'package:edulift/features/family/presentation/providers/family_provider.dart'
    as family_provider;
import 'package:edulift/core/domain/entities/family.dart' as entities;
import 'package:edulift/features/family/domain/usecases/get_family_usecase.dart';
import 'package:edulift/features/family/domain/usecases/leave_family_usecase.dart';
import 'package:edulift/features/family/domain/services/children_service.dart';
import 'package:edulift/features/family/domain/repositories/family_repository.dart';
import 'package:edulift/features/family/domain/repositories/family_invitation_repository.dart';
import 'package:edulift/core/domain/entities/family.dart';
import 'package:edulift/core/services/providers/auth_provider.dart';
import 'package:edulift/core/domain/entities/user.dart';
import 'package:edulift/core/navigation/navigation_state.dart' as nav;
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';

import '../../support/golden/golden_test_wrapper.dart';
import '../../support/golden/device_configurations.dart';
import '../../support/golden/theme_configurations.dart';
import '../../support/factories/family_data_factory.dart';
import '../../support/factories/test_data_factory.dart';
import '../../test_mocks/generated_mocks.mocks.dart';
import '../../support/mock_fallbacks.dart';
import '../../support/network_mocking.dart';

/// Custom FamilyNotifier that pre-initializes with test data
/// This avoids the async loadFamily() call that causes "Family not available" errors
class _PreInitializedFamilyNotifier extends family_provider.FamilyNotifier {
  _PreInitializedFamilyNotifier(
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

void main() {
  // Reset factories before tests
  setUpAll(() {
    // Setup all mock fallbacks first
    setupMockFallbacks();

    FamilyDataFactory.resetCounters();
    TestDataFactory.resetSeed();

    // Register missing dummy value for Mockito
    provideDummy<Result<List<FamilyInvitation>, ApiFailure>>(
      const Result.ok([]),
    );
  });

  /// Helper function to create a properly mocked FamilyNotifier
  /// This prevents "Family not available" runtime errors by mocking all dependencies
  /// The notifier is pre-initialized with test data to avoid async loadFamily() issues
  Override createMockedFamilyProvider(entities.Family? testFamily) {
    return family_provider.familyProvider.overrideWith((ref) {
      // Create all mocked dependencies
      final mockGetFamilyUsecase = MockGetFamilyUsecase();
      final mockChildrenService = MockChildrenService();
      final mockLeaveFamilyUsecase = MockLeaveFamilyUsecase();
      final mockFamilyRepository = MockFamilyRepository();
      final mockInvitationRepository = MockInvitationRepository();

      // Stub repository methods to return test data (no network calls)
      when(mockFamilyRepository.getFamily()).thenAnswer((_) async {
        if (testFamily == null) {
          return const Result.err(
            ApiFailure(message: 'No family found', statusCode: 404),
          );
        }
        return Result.ok(testFamily);
      });

      when(mockInvitationRepository.getPendingInvitations(familyId: anyNamed('familyId')))
          .thenAnswer((_) async => const Result.ok([]));

      // Create a custom notifier that pre-sets the state
      final notifier = _PreInitializedFamilyNotifier(
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

  group('Family Management Screen - Golden Tests (Real Production Code)', () {
    testWidgets('FamilyManagementScreen - members tab with data', (tester) async {
      final testUser = User(
        id: 'user-1',
        email: 'admin@example.com',
        name: 'Admin User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final members = FamilyDataFactory.createLargeMemberList(count: 8);
      final testFamily = entities.Family(
        id: 'family-0',
        name: 'Test Family 0',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ).copyWith(
        members: members,
      );

      final overrides = [
        currentUserProvider.overrideWith((ref) => testUser),
        createMockedFamilyProvider(testFamily),
        nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
      // CRITICAL: Prevent all real network calls during golden tests

      ...getAllNetworkMockOverrides(),

      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const FamilyManagementScreen(initialTabIndex: 0),
        testName: 'family_members_list_realistic',
        devices: DeviceConfigurations.defaultSet,
        themes: ThemeConfigurations.basic,
        providerOverrides: overrides,
      );
    });

    testWidgets('FamilyManagementScreen - members tab with edge cases', (tester) async {
      final testUser = User(
        id: 'user-2',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final members = [
        FamilyDataFactory.createRealisticMember(index: 0),
        FamilyDataFactory.createMemberWithSpecialChars(),
        FamilyDataFactory.createMemberWithLongName(),
        FamilyDataFactory.createRealisticMember(index: 1),
      ];

      final testFamily = entities.Family(
        id: 'family-1',
        name: 'Test Family 1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ).copyWith(
        members: members,
      );

      final overrides = [
        currentUserProvider.overrideWith((ref) => testUser),
        createMockedFamilyProvider(testFamily),
        nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
      // CRITICAL: Prevent all real network calls during golden tests

      ...getAllNetworkMockOverrides(),

      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const FamilyManagementScreen(initialTabIndex: 0),
        testName: 'family_members_list_edge_cases',
        devices: [DeviceConfigurations.iphone13],
        themes: [ThemeConfigurations.light],
        providerOverrides: overrides,
      );
    });

    testWidgets('FamilyManagementScreen - members tab empty state', (tester) async {
      final testUser = User(
        id: 'user-3',
        email: 'new@example.com',
        name: 'New User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final overrides = [
        currentUserProvider.overrideWith((ref) => testUser),
        createMockedFamilyProvider(null), // No family for empty state
        nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
      // CRITICAL: Prevent all real network calls during golden tests

      ...getAllNetworkMockOverrides(),

      ];

      await GoldenTestWrapper.testEmptyState(
        tester: tester,
        widget: const FamilyManagementScreen(initialTabIndex: 0),
        testName: 'family_members_list',
        devices: [DeviceConfigurations.iphone13],
        themes: [ThemeConfigurations.light],
        category: 'screen',
        providerOverrides: overrides,
      );
    });

    testWidgets('FamilyManagementScreen - children tab with data', (tester) async {
      final testUser = User(
        id: 'user-4',
        email: 'parent@example.com',
        name: 'Parent User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final children = FamilyDataFactory.createLargeChildList(count: 6);
      final testFamily = entities.Family(
        id: 'family-2',
        name: 'Test Family 2',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ).copyWith(
        children: children,
      );

      final overrides = [
        currentUserProvider.overrideWith((ref) => testUser),
        createMockedFamilyProvider(testFamily),
        nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
      // CRITICAL: Prevent all real network calls during golden tests

      ...getAllNetworkMockOverrides(),

      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const FamilyManagementScreen(initialTabIndex: 1),
        testName: 'children_list_realistic',
        devices: DeviceConfigurations.defaultSet,
        themes: ThemeConfigurations.basic,
        providerOverrides: overrides,
      );
    });

    testWidgets('FamilyManagementScreen - children tab with edge cases', (tester) async {
      final testUser = User(
        id: 'user-5',
        email: 'test2@example.com',
        name: 'Test User 2',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final children = [
        FamilyDataFactory.createRealisticChild(index: 0),
        FamilyDataFactory.createChildWithSpecialChars(),
        FamilyDataFactory.createChildWithLongName(),
        FamilyDataFactory.createRealisticChild(index: 1),
      ];

      final testFamily = entities.Family(
        id: 'family-3',
        name: 'Test Family 3',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ).copyWith(
        children: children,
      );

      final overrides = [
        currentUserProvider.overrideWith((ref) => testUser),
        createMockedFamilyProvider(testFamily),
        nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
      // CRITICAL: Prevent all real network calls during golden tests

      ...getAllNetworkMockOverrides(),

      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const FamilyManagementScreen(initialTabIndex: 1),
        testName: 'children_list_edge_cases',
        devices: [DeviceConfigurations.iphone13],
        themes: [ThemeConfigurations.light],
        providerOverrides: overrides,
      );
    });

    testWidgets('FamilyManagementScreen - vehicles tab with data', (tester) async {
      final testUser = User(
        id: 'user-6',
        email: 'driver@example.com',
        name: 'Driver User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final vehicles = FamilyDataFactory.createLargeVehicleList(count: 5);
      final testFamily = entities.Family(
        id: 'family-4',
        name: 'Test Family 4',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ).copyWith(
        vehicles: vehicles,
      );

      final overrides = [
        currentUserProvider.overrideWith((ref) => testUser),
        createMockedFamilyProvider(testFamily),
        nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
      // CRITICAL: Prevent all real network calls during golden tests

      ...getAllNetworkMockOverrides(),

      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const FamilyManagementScreen(initialTabIndex: 2),
        testName: 'vehicles_list_realistic',
        devices: DeviceConfigurations.defaultSet,
        themes: ThemeConfigurations.basic,
        providerOverrides: overrides,
      );
    });

    testWidgets('FamilyManagementScreen - vehicles tab with edge cases', (tester) async {
      final testUser = User(
        id: 'user-7',
        email: 'test3@example.com',
        name: 'Test User 3',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final vehicles = [
        FamilyDataFactory.createRealisticVehicle(index: 0),
        FamilyDataFactory.createVehicleWithLongName(),
        FamilyDataFactory.createVehicleWithMinCapacity(),
        FamilyDataFactory.createVehicleWithMaxCapacity(),
      ];

      final testFamily = entities.Family(
        id: 'family-5',
        name: 'Test Family 5',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ).copyWith(
        vehicles: vehicles,
      );

      final overrides = [
        currentUserProvider.overrideWith((ref) => testUser),
        createMockedFamilyProvider(testFamily),
        nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
      // CRITICAL: Prevent all real network calls during golden tests

      ...getAllNetworkMockOverrides(),

      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const FamilyManagementScreen(initialTabIndex: 2),
        testName: 'vehicles_list_edge_cases',
        devices: [DeviceConfigurations.iphone13],
        themes: [ThemeConfigurations.light],
        providerOverrides: overrides,
      );
    });
  });
}
