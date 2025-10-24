// COMPREHENSIVE DASHBOARD COMPONENTS WIDGET TESTS
// PRINCIPLE 0: RADICAL CANDOR - TRUTH ABOVE ALL
//
// SCOPE: Dashboard Component UI Testing
// - Test individual dashboard components
// - Test quick action buttons functionality
// - Test recent activities display
// - Test upcoming trips display
// - Test accessibility compliance (WCAG 2.1 AA)
// - Test responsive layouts and interactions

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edulift/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:edulift/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:edulift/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:edulift/core/domain/entities/family.dart' as entities;
import 'package:edulift/core/domain/entities/family.dart';
import 'package:edulift/features/family/providers.dart';
import 'package:edulift/core/services/app_state_provider.dart';
import 'package:edulift/core/services/providers/auth_provider.dart';
import 'package:edulift/core/domain/entities/user.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';

import '../../support/simple_widget_test_helper.dart';
import '../../support/accessibility_test_helper.dart';
import '../../support/test_screen_sizes.dart';
import '../../test_mocks/test_mocks.dart';

void main() {
  setUpAll(() async {
    // Set up dummy values for Result types
    final dummyFamily = entities.Family(
      id: 'test-family-id',
      name: 'Test Family',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    provideDummy<Result<entities.Family, ApiFailure>>(Result.ok(dummyFamily));
    provideDummy<Result<List<Vehicle>, ApiFailure>>(const Result.ok([]));
    provideDummy<Result<List<Child>, ApiFailure>>(const Result.ok([]));

    await SimpleWidgetTestHelper.initialize();
    AccessibilityTestHelper.configure();
  });

  group('Dashboard Components Tests - QUICK ACTIONS', () {
    late MockFamilyRepository mockFamilyRepository;
    late MockAppStateNotifier mockAppStateNotifier;

    setUp(() {
      mockFamilyRepository = MockFamilyRepository();
      mockAppStateNotifier = MockAppStateNotifier();
    });

    Widget createDashboardWidget() {
      final mockUser = User(
        id: 'test-user-id',
        name: 'Test User',
        email: 'test@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return ProviderScope(
        overrides: [
          familyRepositoryComposedProvider.overrideWithValue(
            mockFamilyRepository,
          ),
          appStateProvider.overrideWith((ref) => mockAppStateNotifier),
          // Override the auth state provider and set authenticated user
          authStateProvider.overrideWith(
            (ref) => AuthNotifier(
              MockAuthService(),
              MockAdaptiveStorageService(),
              MockBiometricService(),
              MockAppStateNotifier(),
              MockUserStatusService(),
              MockErrorHandlerService(),
              // MockComprehensiveFamilyDataService removed - Clean Architecture: dashboard separated from family data service
              ref,
            )..login(mockUser), // Set the user in the auth state
          ),
          // Override the current user provider to work with the overridden auth state
          currentUserProvider.overrideWith((ref) => mockUser),
          recentActivitiesProvider.overrideWith(
            (ref) => const <RecentActivity>[],
          ),
          upcomingTripsProvider.overrideWith(
            (ref) => const <UpcomingTripDisplay>[],
          ),
          dashboardActionsProvider.overrideWith(
            (ref) => DashboardActionConfig(
              canAddChild: true,
              canJoinGroup: true,
              canAddVehicle: true,
            ),
          ),
        ],
        child: SimpleWidgetTestHelper.createTestApp(
          child: const DashboardPage(),
        ),
      );
    }

    testWidgets('should display all quick action buttons with accessibility', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createDashboardWidget());
      await tester.pumpAndSettle();

      // Assert - Quick action buttons should exist
      expect(find.text('Add Child'), findsOneWidget);
      expect(find.text('Join a Group'), findsOneWidget);
      expect(find.text('Add Vehicle'), findsOneWidget);

      // Assert - Icons should be present
      expect(find.byIcon(Icons.person_add), findsOneWidget);
      expect(find.byIcon(Icons.groups), findsOneWidget);
      expect(find.byIcon(Icons.directions_car), findsOneWidget);

      // Assert - Accessibility compliance
      await AccessibilityTestHelper.runAccessibilityTestSuite(
        tester,
        requiredLabels: ['Add Child', 'Join a Group', 'Add Vehicle'],
      );

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });

    testWidgets('should handle quick action button taps', (tester) async {
      // Arrange
      var addChildTapped = false;
      var joinGroupTapped = false;
      var addVehicleTapped = false;

      final mockUser = User(
        id: 'test-user-id',
        name: 'Test User',
        email: 'test@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final testWidget = ProviderScope(
        overrides: [
          familyRepositoryComposedProvider.overrideWithValue(
            mockFamilyRepository,
          ),
          appStateProvider.overrideWith((ref) => mockAppStateNotifier),
          // Override the auth state provider and set authenticated user
          authStateProvider.overrideWith(
            (ref) => AuthNotifier(
              MockAuthService(),
              MockAdaptiveStorageService(),
              MockBiometricService(),
              MockAppStateNotifier(),
              MockUserStatusService(),
              MockErrorHandlerService(),
              // MockComprehensiveFamilyDataService removed - Clean Architecture: dashboard separated from family data service
              ref,
            )..login(mockUser), // Set the user in the auth state
          ),
          // Override the current user provider to work with the overridden auth state
          currentUserProvider.overrideWith((ref) => mockUser),
          recentActivitiesProvider.overrideWith(
            (ref) => const <RecentActivity>[],
          ),
          upcomingTripsProvider.overrideWith(
            (ref) => const <UpcomingTripDisplay>[],
          ),
          dashboardActionsProvider.overrideWith(
            (ref) => DashboardActionConfig(
              canAddChild: true,
              canJoinGroup: true,
              canAddVehicle: true,
            ),
          ),
          dashboardCallbacksProvider.overrideWith(
            (ref) => DashboardCallbacks(
              onAddChild: () {
                addChildTapped = true;
              },
              onJoinGroup: () {
                joinGroupTapped = true;
              },
              onAddVehicle: () {
                addVehicleTapped = true;
              },
            ),
          ),
        ],
        child: SimpleWidgetTestHelper.createTestApp(
          child: const DashboardPage(),
        ),
      );

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Act - Tap each quick action button
      await tester.tap(find.text('Add Child'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Join a Group'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Vehicle'));
      await tester.pumpAndSettle();

      // Assert - Callbacks should have been triggered
      expect(addChildTapped, isTrue);
      expect(joinGroupTapped, isTrue);
      expect(addVehicleTapped, isTrue);

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });

    testWidgets('should have proper touch target sizes for quick actions', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createDashboardWidget());
      await tester.pumpAndSettle();

      // Assert - Touch target sizes should meet accessibility guidelines
      await AccessibilityTestHelper.expectProperTouchTargets(tester);

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });
  });

  group('Dashboard Components Tests - RECENT ACTIVITIES', () {
    late MockFamilyRepository mockFamilyRepository;
    late MockAppStateNotifier mockAppStateNotifier;

    setUp(() {
      mockFamilyRepository = MockFamilyRepository();
      mockAppStateNotifier = MockAppStateNotifier();
    });

    Widget createDashboardWithActivities(List<RecentActivity> activities) {
      final mockUser = User(
        id: 'test-user-id',
        name: 'Test User',
        email: 'test@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return ProviderScope(
        overrides: [
          familyRepositoryComposedProvider.overrideWithValue(
            mockFamilyRepository,
          ),
          appStateProvider.overrideWith((ref) => mockAppStateNotifier),
          // Override the auth state provider and set authenticated user
          authStateProvider.overrideWith(
            (ref) => AuthNotifier(
              MockAuthService(),
              MockAdaptiveStorageService(),
              MockBiometricService(),
              MockAppStateNotifier(),
              MockUserStatusService(),
              MockErrorHandlerService(),
              // MockComprehensiveFamilyDataService removed - Clean Architecture: dashboard separated from family data service
              ref,
            )..login(mockUser), // Set the user in the auth state
          ),
          // Override the current user provider to work with the overridden auth state
          currentUserProvider.overrideWith((ref) => mockUser),
          recentActivitiesProvider.overrideWith((ref) => activities),
          upcomingTripsProvider.overrideWith(
            (ref) => const <UpcomingTripDisplay>[],
          ),
          dashboardActionsProvider.overrideWith(
            (ref) => DashboardActionConfig(
              canAddChild: true,
              canJoinGroup: true,
              canAddVehicle: true,
            ),
          ),
        ],
        child: SimpleWidgetTestHelper.createTestApp(
          child: const DashboardPage(),
        ),
      );
    }

    testWidgets('should display recent activities when available', (
      tester,
    ) async {
      // Arrange
      final activities = [
        RecentActivity(
          id: '1',
          type: ActivityType.childAdded,
          title: 'Child Added',
          subtitle: 'Emma was added to the family',
          iconName: 'person_add',
        ),
        RecentActivity(
          id: '2',
          type: ActivityType.groupJoined,
          title: 'Group Joined',
          subtitle: 'Joined School Carpool Group',
          iconName: 'group',
        ),
      ];

      await tester.pumpWidget(createDashboardWithActivities(activities));
      await tester.pumpAndSettle();

      // Assert - Activities should be displayed
      expect(find.text('Recent Activity'), findsOneWidget);
      expect(find.text('Child Added'), findsOneWidget);
      expect(find.text('Emma was added to the family'), findsOneWidget);
      expect(find.text('Group Joined'), findsOneWidget);
      expect(find.text('Joined School Carpool Group'), findsOneWidget);

      // Assert - Activity icons
      expect(find.byIcon(Icons.person_add), findsAtLeast(1));
      expect(find.byIcon(Icons.groups), findsAtLeast(1));

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });

    testWidgets('should display empty state when no activities', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createDashboardWithActivities([]));
      await tester.pumpAndSettle();

      // Assert - Should show empty state
      expect(find.text('Recent Activity'), findsOneWidget);
      expect(find.text('No recent activity'), findsOneWidget);

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });

    testWidgets('should handle different activity types correctly', (
      tester,
    ) async {
      // Arrange
      final activities = [
        RecentActivity(
          id: '1',
          type: ActivityType.vehicleAdded,
          title: 'Vehicle Added',
          subtitle: 'Toyota Camry added',
          iconName: 'directions_car',
        ),
        RecentActivity(
          id: '2',
          type: ActivityType.scheduleCreated,
          title: 'Schedule Created',
          subtitle: 'Weekly schedule updated',
          iconName: 'schedule',
        ),
      ];

      await tester.pumpWidget(createDashboardWithActivities(activities));
      await tester.pumpAndSettle();

      // Assert - Different activity types should be displayed
      expect(find.text('Vehicle Added'), findsOneWidget);
      expect(find.text('Toyota Camry added'), findsOneWidget);
      expect(find.text('Schedule Created'), findsOneWidget);
      expect(find.text('Weekly schedule updated'), findsOneWidget);

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });
  });

  group('Dashboard Components Tests - UPCOMING TRIPS', () {
    late MockFamilyRepository mockFamilyRepository;
    late MockAppStateNotifier mockAppStateNotifier;

    setUp(() {
      mockFamilyRepository = MockFamilyRepository();
      mockAppStateNotifier = MockAppStateNotifier();
    });

    Widget createDashboardWithTrips(List<UpcomingTripDisplay> trips) {
      final mockUser = User(
        id: 'test-user-id',
        name: 'Test User',
        email: 'test@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return ProviderScope(
        overrides: [
          familyRepositoryComposedProvider.overrideWithValue(
            mockFamilyRepository,
          ),
          appStateProvider.overrideWith((ref) => mockAppStateNotifier),
          // Override the auth state provider and set authenticated user
          authStateProvider.overrideWith(
            (ref) => AuthNotifier(
              MockAuthService(),
              MockAdaptiveStorageService(),
              MockBiometricService(),
              MockAppStateNotifier(),
              MockUserStatusService(),
              MockErrorHandlerService(),
              // MockComprehensiveFamilyDataService removed - Clean Architecture: dashboard separated from family data service
              ref,
            )..login(mockUser), // Set the user in the auth state
          ),
          // Override the current user provider to work with the overridden auth state
          currentUserProvider.overrideWith((ref) => mockUser),
          recentActivitiesProvider.overrideWith(
            (ref) => const <RecentActivity>[],
          ),
          upcomingTripsProvider.overrideWith((ref) => trips),
          dashboardActionsProvider.overrideWith(
            (ref) => DashboardActionConfig(
              canAddChild: true,
              canJoinGroup: true,
              canAddVehicle: true,
            ),
          ),
        ],
        child: SimpleWidgetTestHelper.createTestApp(
          child: const DashboardPage(),
        ),
      );
    }

    testWidgets('should display upcoming trips when available', (tester) async {
      // Arrange
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final trips = [
        UpcomingTripDisplay(
          id: '1',
          time: '8:00 AM',
          destination: 'Lincoln Elementary',
          type: TripType.pickup,
          date: tomorrow.toString(),
          children: [
            Child(
              id: '1',
              name: 'Emma',
              familyId: 'test-family-id',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
            Child(
              id: '2',
              name: 'Liam',
              familyId: 'test-family-id',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ],
        ),
        UpcomingTripDisplay(
          id: '2',
          time: '3:00 PM',
          destination: 'Soccer Practice',
          type: TripType.dropOff,
          date: tomorrow.toString(),
          children: [
            Child(
              id: '1',
              name: 'Emma',
              familyId: 'test-family-id',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ],
        ),
      ];

      await tester.pumpWidget(createDashboardWithTrips(trips));
      await tester.pumpAndSettle();

      // Assert - Trips should be displayed
      expect(find.text('This Week\'s Trips'), findsOneWidget);
      expect(find.text('8:00 AM'), findsOneWidget);
      expect(find.text('Lincoln Elementary'), findsOneWidget);
      expect(find.text('3:00 PM'), findsOneWidget);
      expect(find.text('Soccer Practice'), findsOneWidget);

      // Assert - Trip details
      expect(find.text('Emma, Liam'), findsOneWidget);
      expect(find.text('Emma'), findsOneWidget);

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });

    testWidgets('should display empty state when no trips', (tester) async {
      // Arrange
      await tester.pumpWidget(createDashboardWithTrips([]));
      await tester.pumpAndSettle();

      // Assert - Should show empty state
      expect(find.text('This Week\'s Trips'), findsOneWidget);
      expect(find.text('No trips this week'), findsOneWidget);

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });

    testWidgets('should distinguish between pickup and drop-off trips', (
      tester,
    ) async {
      // Arrange
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final trips = [
        UpcomingTripDisplay(
          id: '1',
          time: '8:00 AM',
          destination: 'School',
          type: TripType.pickup,
          date: tomorrow.toString(),
          children: [
            Child(
              id: '1',
              name: 'Child',
              familyId: 'test-family-id',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ],
        ),
        UpcomingTripDisplay(
          id: '2',
          time: '3:00 PM',
          destination: 'Home',
          type: TripType.dropOff,
          date: tomorrow.toString(),
          children: [
            Child(
              id: '1',
              name: 'Child',
              familyId: 'test-family-id',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ],
        ),
      ];

      await tester.pumpWidget(createDashboardWithTrips(trips));
      await tester.pumpAndSettle();

      // Assert - Should show trip type indicators
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget); // Pickup
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget); // Drop-off

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });
  });

  group('Dashboard Components Tests - RESPONSIVE LAYOUT', () {
    late MockFamilyRepository mockFamilyRepository;
    late MockAppStateNotifier mockAppStateNotifier;

    setUp(() {
      mockFamilyRepository = MockFamilyRepository();
      mockAppStateNotifier = MockAppStateNotifier();
    });

    Widget createDashboardWidget() {
      final mockUser = User(
        id: 'test-user-id',
        name: 'Test User',
        email: 'test@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return ProviderScope(
        overrides: [
          familyRepositoryComposedProvider.overrideWithValue(
            mockFamilyRepository,
          ),
          appStateProvider.overrideWith((ref) => mockAppStateNotifier),
          // Override the auth state provider and set authenticated user
          authStateProvider.overrideWith(
            (ref) => AuthNotifier(
              MockAuthService(),
              MockAdaptiveStorageService(),
              MockBiometricService(),
              MockAppStateNotifier(),
              MockUserStatusService(),
              MockErrorHandlerService(),
              // MockComprehensiveFamilyDataService removed - Clean Architecture: dashboard separated from family data service
              ref,
            )..login(mockUser), // Set the user in the auth state
          ),
          // Override the current user provider to work with the overridden auth state
          currentUserProvider.overrideWith((ref) => mockUser),
          recentActivitiesProvider.overrideWith(
            (ref) => const <RecentActivity>[],
          ),
          upcomingTripsProvider.overrideWith(
            (ref) => const <UpcomingTripDisplay>[],
          ),
          dashboardActionsProvider.overrideWith(
            (ref) => DashboardActionConfig(
              canAddChild: true,
              canJoinGroup: true,
              canAddVehicle: true,
            ),
          ),
        ],
        child: SimpleWidgetTestHelper.createTestApp(
          child: const DashboardPage(),
        ),
      );
    }

    testWidgets('should adapt to phone layout on small screens', (
      tester,
    ) async {
      // Arrange - Test mobile responsive layout with standard phone size
      await TestScreenSizes.setScreenSize(tester, TestScreenSizes.testPhone);

      await tester.pumpWidget(createDashboardWidget());
      await tester.pumpAndSettle();

      // Assert - Should use phone layout (single column)
      expect(find.byType(Column), findsWidgets);
      // Phone layout should stack components vertically

      SimpleWidgetTestHelper.verifyNoExceptions(tester);

      // Reset to default size
      await TestScreenSizes.resetScreenSize(tester);
    });

    testWidgets('should adapt to tablet layout on large screens', (
      tester,
    ) async {
      // Arrange - Test tablet responsive layout with standard tablet size
      await TestScreenSizes.setScreenSize(
        tester,
        TestScreenSizes.testLargeTablet,
      );

      await tester.pumpWidget(createDashboardWidget());
      await tester.pumpAndSettle();

      // Assert - Should use tablet layout (multi-column)
      expect(find.byType(Row), findsWidgets);
      // Tablet layout should arrange components in rows

      SimpleWidgetTestHelper.verifyNoExceptions(tester);

      // Reset to default size
      await TestScreenSizes.resetScreenSize(tester);
    });
  });

  group('Dashboard Components Tests - GOLDEN TESTS', () {
    late MockFamilyRepository mockFamilyRepository;
    late MockAppStateNotifier mockAppStateNotifier;

    setUp(() {
      mockFamilyRepository = MockFamilyRepository();
      mockAppStateNotifier = MockAppStateNotifier();
    });

    Widget createDashboardWidget() {
      final mockUser = User(
        id: 'test-user-id',
        name: 'Test User',
        email: 'test@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return ProviderScope(
        overrides: [
          familyRepositoryComposedProvider.overrideWithValue(
            mockFamilyRepository,
          ),
          appStateProvider.overrideWith((ref) => mockAppStateNotifier),
          // Override the auth state provider and set authenticated user
          authStateProvider.overrideWith(
            (ref) => AuthNotifier(
              MockAuthService(),
              MockAdaptiveStorageService(),
              MockBiometricService(),
              MockAppStateNotifier(),
              MockUserStatusService(),
              MockErrorHandlerService(),
              // MockComprehensiveFamilyDataService removed - Clean Architecture: dashboard separated from family data service
              ref,
            )..login(mockUser), // Set the user in the auth state
          ),
          // Override the current user provider to work with the overridden auth state
          currentUserProvider.overrideWith((ref) => mockUser),
          recentActivitiesProvider.overrideWith(
            (ref) => const <RecentActivity>[],
          ),
          upcomingTripsProvider.overrideWith(
            (ref) => const <UpcomingTripDisplay>[],
          ),
          dashboardActionsProvider.overrideWith(
            (ref) => DashboardActionConfig(
              canAddChild: true,
              canJoinGroup: true,
              canAddVehicle: true,
            ),
          ),
        ],
        child: SimpleWidgetTestHelper.createTestApp(
          child: const DashboardPage(),
        ),
      );
    }

    testWidgets('should match golden file for empty dashboard', (tester) async {
      // Arrange
      await tester.pumpWidget(createDashboardWidget());
      await tester.pumpAndSettle();

      // Assert - Should match golden file
      await SimpleWidgetTestHelper.expectGoldenFile(
        tester,
        'dashboard_components_empty',
        finder: find.byType(DashboardPage),
        category: 'dashboard',
      );

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });

    testWidgets('should match golden file for populated dashboard', (
      tester,
    ) async {
      // Arrange - Dashboard with activities and trips
      final activities = [
        RecentActivity(
          id: '1',
          type: ActivityType.childAdded,
          title: 'Child Added',
          subtitle: 'Emma was added to the family',
          iconName: 'person_add',
        ),
      ];

      final trips = [
        UpcomingTripDisplay(
          id: '1',
          time: '8:00 AM',
          destination: 'School',
          type: TripType.pickup,
          date: DateTime.now().add(const Duration(days: 1)).toString(),
          children: [
            Child(
              id: '1',
              name: 'Emma',
              familyId: 'test-family-id',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ],
        ),
      ];

      final mockUser = User(
        id: 'test-user-id',
        name: 'Test User',
        email: 'test@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final testWidget = ProviderScope(
        overrides: [
          familyRepositoryComposedProvider.overrideWithValue(
            mockFamilyRepository,
          ),
          appStateProvider.overrideWith((ref) => mockAppStateNotifier),
          // Override the auth state provider and set authenticated user
          authStateProvider.overrideWith(
            (ref) => AuthNotifier(
              MockAuthService(),
              MockAdaptiveStorageService(),
              MockBiometricService(),
              MockAppStateNotifier(),
              MockUserStatusService(),
              MockErrorHandlerService(),
              // MockComprehensiveFamilyDataService removed - Clean Architecture: dashboard separated from family data service
              ref,
            )..login(mockUser), // Set the user in the auth state
          ),
          // Override the current user provider to work with the overridden auth state
          currentUserProvider.overrideWith((ref) => mockUser),
          recentActivitiesProvider.overrideWith((ref) => activities),
          upcomingTripsProvider.overrideWith((ref) => trips),
          dashboardActionsProvider.overrideWith(
            (ref) => DashboardActionConfig(
              canAddChild: true,
              canJoinGroup: true,
              canAddVehicle: true,
            ),
          ),
        ],
        child: SimpleWidgetTestHelper.createTestApp(
          child: const DashboardPage(),
        ),
      );

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Assert - Should match golden file
      await SimpleWidgetTestHelper.expectGoldenFile(
        tester,
        'dashboard_components_populated',
        finder: find.byType(DashboardPage),
        category: 'dashboard',
      );

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });
  });
}
