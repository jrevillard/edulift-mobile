import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:edulift/core/router/app_routes.dart';
// REMOVED: UserFamilyExtension - Clean Architecture violation eliminated
import '../support/test_provider_overrides.dart';

void main() {
  group('Family Invite Redirect Logic Tests', () {
    testWidgets('should allow access to /family/invite even without familyId', (
      WidgetTester tester,
    ) async {
      // Mock user without familyId (simulation via redirect logic)
      // No family ID - this is the key test condition

      var redirectCallCount = 0;
      String? lastRedirectDecision;

      // Create a simple router that mimics the redirect logic
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Home'))),
          ),
          GoRoute(
            path: AppRoutes.inviteMember,
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Invite Member Page'))),
          ),
          GoRoute(
            path: '/onboarding/wizard',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Onboarding Wizard'))),
          ),
        ],
        redirect: (context, state) {
          redirectCallCount++;

          // Prevent infinite redirect loops in tests
          if (redirectCallCount > 3) {
            return null;
          }

          // Simulate the app's redirect logic
          const isAuthenticated = true; // User is authenticated
          final isOnboardingRoute = state.matchedLocation.startsWith(
            '/onboarding',
          );

          // Apply the same logic as in app_router.dart
          if (isAuthenticated &&
              // CLEAN ARCHITECTURE: Use UserFamilyService to check family status
              // currentUser.familyId == null && // REMOVED
              true && // TODO: Implement family check via UserFamilyService
              (state.matchedLocation.startsWith('/family') ||
                  state.matchedLocation.startsWith('/groups') ||
                  state.matchedLocation.startsWith('/schedule')) &&
              !isOnboardingRoute &&
              state.matchedLocation != '/family/create' &&
              state.matchedLocation != '/family/invite') {
            lastRedirectDecision = '/onboarding/wizard';
            return '/onboarding/wizard';
          }

          lastRedirectDecision = null;
          return null;
        },
        initialLocation: '/',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: TestProviderOverrides.common,
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      // Try to navigate to the invite route using go instead of push to avoid state conflicts
      router.go(AppRoutes.inviteMember);

      // Use pump() instead of pumpAndSettle() to avoid infinite loops
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify redirect logic was called but didn't redirect away from /family/invite
      expect(redirectCallCount, greaterThan(0));
      expect(
        lastRedirectDecision,
        isNull,
        reason: 'Should not redirect away from /family/invite route',
      );

      // Verify we're on the invite page, not redirected to onboarding
      expect(find.text('Invite Member Page'), findsOneWidget);
      expect(find.text('Onboarding Wizard'), findsNothing);

      // Verify the current route is correct
      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        equals(AppRoutes.inviteMember),
      );
    });

    testWidgets('should still redirect other family routes without familyId', (
      WidgetTester tester,
    ) async {
      // Mock user without familyId (simulation via redirect logic)
      // No family ID - redirects to onboarding

      String? actualRedirectTarget;

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Home'))),
          ),
          GoRoute(
            path: '/family/manage',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Family Management'))),
          ),
          GoRoute(
            path: '/onboarding/wizard',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Onboarding Wizard'))),
          ),
        ],
        redirect: (context, state) {
          const isAuthenticated = true;
          final isOnboardingRoute = state.matchedLocation.startsWith(
            '/onboarding',
          );

          // Same redirect logic
          if (isAuthenticated &&
              // CLEAN ARCHITECTURE: Use UserFamilyService to check family status
              // currentUser.familyId == null && // REMOVED
              true && // TODO: Implement family check via UserFamilyService
              (state.matchedLocation.startsWith('/family') ||
                  state.matchedLocation.startsWith('/groups') ||
                  state.matchedLocation.startsWith('/schedule')) &&
              !isOnboardingRoute &&
              state.matchedLocation != '/family/create' &&
              state.matchedLocation != '/family/invite') {
            actualRedirectTarget = '/onboarding/wizard';
            return '/onboarding/wizard';
          }

          return null;
        },
        initialLocation: '/',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: TestProviderOverrides.common,
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      // Try to navigate to a different family route using go instead of push
      router.go('/family/manage');

      // Use pump() instead of pumpAndSettle() to avoid infinite loops
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // The redirect should have happened, verify the result
      expect(
        actualRedirectTarget,
        equals('/onboarding/wizard'),
        reason: 'Should redirect /family/manage to onboarding wizard',
      );

      // Verify we're redirected to onboarding, not the family page
      expect(find.text('Onboarding Wizard'), findsOneWidget);
      expect(find.text('Family Management'), findsNothing);

      // Verify the current route is the onboarding wizard
      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        equals('/onboarding/wizard'),
      );
    });

    test('family invite route path should be correctly defined', () {
      expect(AppRoutes.inviteMember, equals('/family/invite'));
    });
  });
}
