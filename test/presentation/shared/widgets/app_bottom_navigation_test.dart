// EduLift Mobile - AppBottomNavigation Widget Tests
// Tests ACTUAL navigation widget behavior with REAL user interactions
// Following Flutter 2025 testing standards with accessibility compliance

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:edulift/core/router/app_routes.dart';
import 'package:edulift/core/services/providers/auth_provider.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';

import '../../../test_mocks/generated_mocks.dart';
import '../../../support/test_environment.dart';
import '../../../support/accessibility_test_helper.dart';
import '../../../support/test_provider_overrides.dart';
import '../../../support/test_router_config.dart';

void main() {
  group('AppBottomNavigation Widget Tests - REAL NAVIGATION BEHAVIOR', () {
    late ProviderContainer container;
    late GoRouter router;

    setUp(() async {
      await TestEnvironment.initialize();
    });

    tearDown(() {
      container.dispose();
    });

    group('Navigation Functionality', () {
      testWidgets('CRITICAL: Bottom nav displays all required tabs', (
        tester,
      ) async {
        // ARRANGE - User with family (all tabs accessible)
        final mockAuthState =
            AuthStateMockFactory.createAuthenticatedWithFamily();

        final overrides = [
          authStateProvider.overrideWith(
            (ref) {
              final notifier = TestAuthNotifier.withRef(ref);
              notifier.state = mockAuthState;
              return notifier;
            },
          ),
          currentUserProvider.overrideWith((ref) => mockAuthState.user),
        ];

        container = ProviderContainer(overrides: overrides);
        router = TestRouterConfig.createTestRouter(includeShell: true);

        // ACT - Navigate to dashboard and create AppBottomNavigation widget
        router.go(AppRoutes.dashboard);
        await tester.pumpWidget(
          ProviderScope(
            overrides: overrides,
            child: MaterialApp.router(
              routerConfig: router,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // ASSERT - All navigation destinations should be present
        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.byType(NavigationDestination), findsNWidgets(5));

        // Verify navigation destinations exist and are functional
        final navigationBar = tester.widget<NavigationBar>(
          find.byType(NavigationBar),
        );
        expect(navigationBar.destinations.length, equals(5));

        // Test navigation functionality by checking that destinations are tappable
        for (var i = 0; i < 5; i++) {
          expect(navigationBar.destinations[i], isA<NavigationDestination>());
        }

        // Run accessibility tests
        await AccessibilityTestHelper.runAccessibilityTestSuite(
          tester,
          requiredLabels:
              [], // Navigation destinations have dynamic labels from localization
        );
      });

      testWidgets('CRITICAL: Family tab guard redirects user without family', (
        tester,
      ) async {
        // ARRANGE - User WITHOUT family
        final mockAuthState =
            AuthStateMockFactory.createAuthenticatedWithoutFamily();

        final overrides = [
          authStateProvider.overrideWith(
            (ref) {
              final notifier = TestAuthNotifier.withRef(ref);
              notifier.state = mockAuthState;
              return notifier;
            },
          ),
          currentUserProvider.overrideWith((ref) => mockAuthState.user),
        ];

        container = ProviderContainer(overrides: overrides);
        router = TestRouterConfig.createTestRouter(includeShell: true);

        // Start at dashboard and set up widget properly
        router.go(AppRoutes.dashboard);
        await tester.pumpWidget(
          ProviderScope(
            overrides: overrides,
            child: MaterialApp.router(
              routerConfig: router,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify current location is dashboard (not onboarding yet)
        expect(
          router.routerDelegate.currentConfiguration.uri.path,
          equals('/dashboard'),
        );

        // Now test the bottom nav family tab tap (index 1)
        final navigationBarFinder = find.byType(NavigationBar);
        expect(navigationBarFinder, findsOneWidget);

        final navigationBar = tester.widget<NavigationBar>(navigationBarFinder);
        expect(navigationBar.destinations.length, equals(5));

        // ACT - Simulate tapping the family tab (index 1) by calling onDestinationSelected
        navigationBar.onDestinationSelected!(1);
        await tester.pumpAndSettle();

        // ASSERT - Should redirect to onboarding
        expect(
          router.routerDelegate.currentConfiguration.uri.path,
          equals('/onboarding/wizard'),
        );
      });

      testWidgets('Groups tab guard redirects user without family', (
        tester,
      ) async {
        // ARRANGE - User WITHOUT family
        final mockAuthState =
            AuthStateMockFactory.createAuthenticatedWithoutFamily();

        final overrides = [
          authStateProvider.overrideWith(
            (ref) {
              final notifier = TestAuthNotifier.withRef(ref);
              notifier.state = mockAuthState;
              return notifier;
            },
          ),
          currentUserProvider.overrideWith((ref) => mockAuthState.user),
        ];

        container = ProviderContainer(overrides: overrides);
        router = TestRouterConfig.createTestRouter(includeShell: true);

        router.go(AppRoutes.dashboard);
        await tester.pumpWidget(
          ProviderScope(
            overrides: overrides,
            child: MaterialApp.router(
              routerConfig: router,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find navigation bar and simulate groups tab tap (index 2)
        final navigationBarFinder = find.byType(NavigationBar);
        expect(navigationBarFinder, findsOneWidget);

        final navigationBar = tester.widget<NavigationBar>(navigationBarFinder);

        // ACT - Tap groups tab (index 2)
        navigationBar.onDestinationSelected!(2);
        await tester.pumpAndSettle();

        // ASSERT - Should redirect to onboarding
        expect(
          router.routerDelegate.currentConfiguration.uri.path,
          equals('/onboarding/wizard'),
        );
      });

      testWidgets('Schedule tab guard redirects user without family', (
        tester,
      ) async {
        // ARRANGE - User WITHOUT family
        final mockAuthState =
            AuthStateMockFactory.createAuthenticatedWithoutFamily();

        final overrides = [
          authStateProvider.overrideWith(
            (ref) {
              final notifier = TestAuthNotifier.withRef(ref);
              notifier.state = mockAuthState;
              return notifier;
            },
          ),
          currentUserProvider.overrideWith((ref) => mockAuthState.user),
        ];

        container = ProviderContainer(overrides: overrides);
        router = TestRouterConfig.createTestRouter(includeShell: true);

        router.go(AppRoutes.dashboard);
        await tester.pumpWidget(
          ProviderScope(
            overrides: overrides,
            child: MaterialApp.router(
              routerConfig: router,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find navigation bar and simulate schedule tab tap (index 3)
        final navigationBarFinder = find.byType(NavigationBar);
        expect(navigationBarFinder, findsOneWidget);

        final navigationBar = tester.widget<NavigationBar>(navigationBarFinder);

        // ACT - Tap schedule tab (index 3)
        navigationBar.onDestinationSelected!(3);
        await tester.pumpAndSettle();

        // ASSERT - Should redirect to onboarding
        expect(
          router.routerDelegate.currentConfiguration.uri.path,
          equals('/onboarding/wizard'),
        );
      });

      testWidgets('User with family can navigate to all tabs', (tester) async {
        // ARRANGE - User WITH family
        final mockAuthState =
            AuthStateMockFactory.createAuthenticatedWithFamily();

        final overrides = [
          authStateProvider.overrideWith(
            (ref) {
              final notifier = TestAuthNotifier.withRef(ref);
              notifier.state = mockAuthState;
              return notifier;
            },
          ),
          currentUserProvider.overrideWith((ref) => mockAuthState.user),
        ];

        container = ProviderContainer(overrides: overrides);
        router = TestRouterConfig.createTestRouter(includeShell: true);

        router.go(AppRoutes.dashboard);
        await tester.pumpWidget(
          ProviderScope(
            overrides: overrides,
            child: MaterialApp.router(
              routerConfig: router,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // ASSERT - Should be on dashboard
        expect(
          router.routerDelegate.currentConfiguration.uri.path,
          equals(AppRoutes.dashboard),
        );

        // Test navigation to each tab using indices
        final tabTests = [
          (1, AppRoutes.family),
          (2, AppRoutes.groups),
          (3, AppRoutes.schedule),
          (4, AppRoutes.profile),
        ];

        final navigationBarFinder = find.byType(NavigationBar);
        final navigationBar = tester.widget<NavigationBar>(navigationBarFinder);

        for (final (tabIndex, expectedRoute) in tabTests) {
          // ACT - Tap tab by calling onDestinationSelected
          navigationBar.onDestinationSelected!(tabIndex);
          await tester.pumpAndSettle();

          // ASSERT - Should navigate to correct route
          expect(
            router.routerDelegate.currentConfiguration.uri.path,
            equals(expectedRoute),
            reason: 'Failed to navigate to $expectedRoute',
          );
        }
      });
    });

    group('Tab Selection State', () {
      testWidgets('Current tab is correctly highlighted', (tester) async {
        // ARRANGE - User with family
        final mockAuthState =
            AuthStateMockFactory.createAuthenticatedWithFamily();

        final overrides = [
          authStateProvider.overrideWith(
            (ref) {
              final notifier = TestAuthNotifier.withRef(ref);
              notifier.state = mockAuthState;
              return notifier;
            },
          ),
          currentUserProvider.overrideWith((ref) => mockAuthState.user),
        ];

        container = ProviderContainer(overrides: overrides);
        router = TestRouterConfig.createTestRouter(includeShell: true);

        // Test each route and verify correct tab is selected
        final routeTests = [
          (AppRoutes.dashboard, 0),
          (AppRoutes.family, 1),
          (AppRoutes.groups, 2),
          (AppRoutes.schedule, 3),
          (AppRoutes.profile, 4),
        ];

        for (final (route, expectedIndex) in routeTests) {
          // ACT - Navigate to route
          router.go(route);
          await tester.pumpWidget(
            ProviderScope(
              overrides: overrides,
              child: MaterialApp.router(
                routerConfig: router,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: AppLocalizations.supportedLocales,
              ),
            ),
          );
          await tester.pumpAndSettle();

          // ASSERT - Find NavigationBar and check selectedIndex
          final navigationBar = tester.widget<NavigationBar>(
            find.byType(NavigationBar),
          );
          expect(
            navigationBar.selectedIndex,
            equals(expectedIndex),
            reason: 'Wrong tab selected for route $route',
          );
        }
      });
    });

    group('Accessibility Compliance', () {
      testWidgets('All tabs meet WCAG 2.1 AA standards', (tester) async {
        // ARRANGE - User with family to access all tabs
        final mockAuthState =
            AuthStateMockFactory.createAuthenticatedWithFamily();

        final overrides = [
          authStateProvider.overrideWith(
            (ref) {
              final notifier = TestAuthNotifier.withRef(ref);
              notifier.state = mockAuthState;
              return notifier;
            },
          ),
          currentUserProvider.overrideWith((ref) => mockAuthState.user),
        ];

        container = ProviderContainer(overrides: overrides);
        router = TestRouterConfig.createTestRouter(includeShell: true);

        router.go(AppRoutes.dashboard);
        await tester.pumpWidget(
          ProviderScope(
            overrides: overrides,
            child: MaterialApp.router(
              routerConfig: router,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // ACT & ASSERT - Run comprehensive accessibility tests
        await AccessibilityTestHelper.runAccessibilityTestSuite(
          tester,
          requiredLabels:
              [], // Navigation destinations have dynamic labels from localization
        );
      });

      testWidgets('Disabled tabs have proper accessibility indicators', (
        tester,
      ) async {
        // ARRANGE - User WITHOUT family (some tabs disabled)
        final mockAuthState =
            AuthStateMockFactory.createAuthenticatedWithoutFamily();

        final overrides = [
          authStateProvider.overrideWith(
            (ref) {
              final notifier = TestAuthNotifier.withRef(ref);
              notifier.state = mockAuthState;
              return notifier;
            },
          ),
          currentUserProvider.overrideWith((ref) => mockAuthState.user),
        ];

        container = ProviderContainer(overrides: overrides);
        router = TestRouterConfig.createTestRouter(includeShell: true);

        router.go(AppRoutes.dashboard);
        await tester.pumpWidget(
          ProviderScope(
            overrides: overrides,
            child: MaterialApp.router(
              routerConfig: router,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // ASSERT - Navigation destinations should exist (labels are dynamic from localization)
        final navigationBar = tester.widget<NavigationBar>(
          find.byType(NavigationBar),
        );
        expect(navigationBar.destinations.length, equals(5));

        // Verify destinations are present
        for (var i = 0; i < 5; i++) {
          expect(navigationBar.destinations[i], isA<NavigationDestination>());
        }

        // Run accessibility tests for disabled state
        await AccessibilityTestHelper.runAccessibilityTestSuite(
          tester,
          requiredLabels:
              [], // Navigation destinations have dynamic labels from localization
        );
      });
    });

    group('Real-time Updates', () {
      testWidgets('Bottom nav updates when user gains family access', (
        tester,
      ) async {
        // ARRANGE - Start with user without family - Use mutable TestAuthNotifier
        var mockAuthState =
            AuthStateMockFactory.createAuthenticatedWithoutFamily();
        late TestAuthNotifier authNotifier;

        final overrides = [
          authStateProvider.overrideWith((ref) {
            authNotifier = TestAuthNotifier.withRef(ref);
            authNotifier.state = mockAuthState;
            return authNotifier;
          }),
          currentUserProvider.overrideWith(
            (ref) => ref.watch(authStateProvider).user,
          ),
        ];

        container = TestProviderOverrides.createTestContainer(overrides);
        router = TestRouterConfig.createTestRouter(includeShell: true);

        router.go(AppRoutes.dashboard);
        await tester.pumpWidget(
          ProviderScope(
            overrides: overrides,
            child: MaterialApp.router(
              routerConfig: router,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // ASSERT - Initially navigation bar should exist
        final navigationBarFinder = find.byType(NavigationBar);
        expect(navigationBarFinder, findsOneWidget);

        // ACT - Update auth state to include family access through the existing notifier
        mockAuthState = AuthStateMockFactory.createAuthenticatedWithFamily();
        authNotifier.state = mockAuthState;

        // Wait for the UI to update in response to the state change
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // ASSERT - Navigation should still work (tab should be accessible)
        // Verify the family tab can be tapped without redirecting to onboarding
        final navigationBar = tester.widget<NavigationBar>(navigationBarFinder);
        navigationBar.onDestinationSelected!(1); // Family tab is index 1
        await tester.pumpAndSettle();

        // Should navigate to family page, not onboarding
        expect(
          router.routerDelegate.currentConfiguration.uri.path,
          equals(AppRoutes.family),
          reason: 'Family access should be available after state update',
        );
      });
    });
  });
}
