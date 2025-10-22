@Skip('Obsolete: Tests router redirects based on User.familyId which no longer exists. Architecture changed to use FamilyRepository.getCurrentFamily(). Needs rewrite.')
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:edulift/core/router/app_routes.dart';
import '../../../support/test_environment.dart';
import '../../../test_mocks/generated_mocks.dart';

void main() {
  group('Authenticated Without Family Redirect Tests', () {
    late GoRouter router;

    setUp(() async {
      await TestEnvironment.initialize();
    });

    tearDown(() {
      router.dispose();
    });

    testWidgets(
      'CRITICAL: Authenticated user without family at splash should redirect to onboarding',
      (tester) async {
        // ARRANGE - Authenticated user without family
        final mockAuthState =
            AuthStateMockFactory.createAuthenticatedWithoutFamily();

        // Create router with simplified redirect logic for testing
        router = GoRouter(
          initialLocation: AppRoutes.splash,
          redirect: (context, state) {
            final authState = mockAuthState;

            if (!authState.isInitialized) {
              return AppRoutes.splash;
            }

            final isAuthenticated = authState.isAuthenticated;
            final currentUser = authState.user;
            final isAuthRoute = state.matchedLocation.startsWith('/auth');
            final isSplashRoute = state.matchedLocation == '/splash';
            // final isOnboardingRoute = state.matchedLocation.startsWith('/onboarding'); // Unused variable
            final isMagicLinkVerifyRoute =
                state.matchedLocation == '/auth/verify';

            // Handle authenticated users on splash screen
            if (isAuthenticated && isSplashRoute) {
              // If user doesn't have a family, redirect to onboarding
              if (currentUser?.familyId == null) {
                return '/onboarding/wizard';
              }
              return AppRoutes.dashboard;
            }

            // If authenticated and on auth routes, check family status
            if (isAuthenticated && isAuthRoute && !isMagicLinkVerifyRoute) {
              if (currentUser?.familyId == null) {
                return '/onboarding/wizard';
              }
              return AppRoutes.dashboard;
            }

            return null;
          },
          routes: [
            GoRoute(
              path: AppRoutes.splash,
              builder: (context, state) => const Scaffold(body: Text('Splash')),
            ),
            GoRoute(
              path: AppRoutes.login,
              builder: (context, state) => const Scaffold(body: Text('Login')),
            ),
            GoRoute(
              path: AppRoutes.dashboard,
              builder: (context, state) =>
                  const Scaffold(body: Text('Dashboard')),
            ),
            GoRoute(
              path: '/onboarding/wizard',
              builder: (context, state) =>
                  const Scaffold(body: Text('Onboarding')),
            ),
            GoRoute(
              path: '/auth/login',
              builder: (context, state) =>
                  const Scaffold(body: Text('AuthLogin')),
            ),
            GoRoute(
              path: '/auth/verify',
              builder: (context, state) => const Scaffold(body: Text('Verify')),
            ),
          ],
        );

        // ACT - Navigate to splash
        router.go(AppRoutes.splash);
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        // ASSERT - Should redirect to onboarding wizard
        expect(
          router.routerDelegate.currentConfiguration.uri.path,
          equals('/onboarding/wizard'),
          reason:
              'Authenticated user without family should be redirected to onboarding',
        );
      },
    );

    testWidgets(
      'CRITICAL: Authenticated user with family at splash should redirect to dashboard',
      (tester) async {
        // ARRANGE - Authenticated user with family
        final mockAuthState =
            AuthStateMockFactory.createAuthenticatedWithFamily();

        // Create router with simplified redirect logic for testing
        router = GoRouter(
          initialLocation: AppRoutes.splash,
          redirect: (context, state) {
            final authState = mockAuthState;

            if (!authState.isInitialized) {
              return AppRoutes.splash;
            }

            final isAuthenticated = authState.isAuthenticated;
            final currentUser = authState.user;
            final isSplashRoute = state.matchedLocation == '/splash';

            // Handle authenticated users on splash screen
            if (isAuthenticated && isSplashRoute) {
              // If user doesn't have a family, redirect to onboarding
              if (currentUser?.familyId == null) {
                return '/onboarding/wizard';
              }
              return AppRoutes.dashboard;
            }

            return null;
          },
          routes: [
            GoRoute(
              path: AppRoutes.splash,
              builder: (context, state) => const Scaffold(body: Text('Splash')),
            ),
            GoRoute(
              path: AppRoutes.dashboard,
              builder: (context, state) =>
                  const Scaffold(body: Text('Dashboard')),
            ),
            GoRoute(
              path: '/onboarding/wizard',
              builder: (context, state) =>
                  const Scaffold(body: Text('Onboarding')),
            ),
          ],
        );

        // ACT - Navigate to splash
        router.go(AppRoutes.splash);
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        // ASSERT - Should redirect to onboarding wizard (user has family, gets dashboard)
        expect(
          router.routerDelegate.currentConfiguration.uri.path,
          equals('/dashboard'),
          reason:
              'Authenticated user with family should be redirected to dashboard',
        );
      },
    );

    testWidgets(
      'CRITICAL: Authenticated user without family at auth route should redirect to onboarding',
      (tester) async {
        // ARRANGE - Authenticated user without family
        final mockAuthState =
            AuthStateMockFactory.createAuthenticatedWithoutFamily();

        // Create router with simplified redirect logic for testing
        router = GoRouter(
          initialLocation: '/auth/login',
          redirect: (context, state) {
            final authState = mockAuthState;

            if (!authState.isInitialized) {
              return AppRoutes.splash;
            }

            final isAuthenticated = authState.isAuthenticated;
            final currentUser = authState.user;
            final isAuthRoute = state.matchedLocation.startsWith('/auth');
            final isMagicLinkVerifyRoute =
                state.matchedLocation == '/auth/verify';

            // If authenticated and on auth routes, check family status
            if (isAuthenticated && isAuthRoute && !isMagicLinkVerifyRoute) {
              if (currentUser?.familyId == null) {
                return '/onboarding/wizard';
              }
              return AppRoutes.dashboard;
            }

            return null;
          },
          routes: [
            GoRoute(
              path: '/auth/login',
              builder: (context, state) =>
                  const Scaffold(body: Text('AuthLogin')),
            ),
            GoRoute(
              path: AppRoutes.dashboard,
              builder: (context, state) =>
                  const Scaffold(body: Text('Dashboard')),
            ),
            GoRoute(
              path: '/onboarding/wizard',
              builder: (context, state) =>
                  const Scaffold(body: Text('Onboarding')),
            ),
            GoRoute(
              path: '/auth/verify',
              builder: (context, state) => const Scaffold(body: Text('Verify')),
            ),
          ],
        );

        // ACT - Navigate to auth/login
        router.go('/auth/login');
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        // ASSERT - Should redirect to onboarding wizard
        expect(
          router.routerDelegate.currentConfiguration.uri.path,
          equals('/onboarding/wizard'),
          reason:
              'Authenticated user without family on auth route should be redirected to onboarding',
        );
      },
    );
  });
}
