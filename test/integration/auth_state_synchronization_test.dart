import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:edulift/core/services/providers/auth_provider.dart';
import 'package:edulift/core/domain/entities/user.dart';
import 'package:edulift/core/router/app_router.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';

import '../support/test_di_config.dart';

void main() {
  group('Auth State Synchronization Tests', () {
    setUpAll(() async {
      TestDIConfig.setupTestDependencies();
    });

    setUp(() {
      // Mock services are initialized in TestDIConfig.setupTestDependencies()
    });

    tearDown(() async {
      await TestDIConfig.cleanup();
    });

    testWidgets(
      'CRITICAL: Magic link verification success should redirect to dashboard (not stuck on verification page)',
      (tester) async {
        // Arrange: Set up authenticated user with family
        final testUser = User(
          id: 'test-user-id',
          email: 'test@example.com',
          /* familyId removed - use FamilyMember entity */
          name: 'Test User',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Create a container to control the auth state
        final container = ProviderContainer();
        late final GoRouter testRouter;

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: Consumer(
              builder: (context, ref, child) {
                // CRITICAL FIX: Create router with the same method as main app
                // This ensures we test the actual fix for provider container mismatch
                testRouter = AppRouter.createRouter(ref);

                return MaterialApp.router(
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                  ],
                  supportedLocales: AppLocalizations.supportedLocales,
                  routerConfig: testRouter,
                );
              },
            ),
          ),
        );

        // Navigate to the verification page manually since we're using the real router
        testRouter.go('/auth/verify?token=test-token');

        // Pump to initialize the app
        await tester.pump();

        // Verify we start at verification page (magic link flow)
        expect(find.text('Verification Successful'), findsOneWidget);

        // Act: Simulate successful magic link authentication
        // This is what happens when MagicLinkVerifyPage completes authentication

        // 1. Set authenticated state (this is what AuthNotifier.login() does)
        container.read(authStateProvider.notifier).state = AuthState(
          user: testUser,
          isInitialized: true,
        );

        // 2. Pump to trigger router rebuild
        // BUG: Router should see auth state change and redirect to dashboard
        // ACTUAL: Router sees stale state and user stays stuck on verification page
        await tester.pump();

        // Assert: Verify we are NOT stuck on verification success page
        // The bug causes the router to see stale state and NOT redirect to dashboard
        expect(
          find.text('Verification Successful'),
          findsNothing,
          reason:
              'User should not be stuck on verification page after successful authentication',
        );

        // Verify we're redirected to dashboard
        expect(
          find.text('Dashboard'),
          findsOneWidget,
          reason:
              'Should be automatically redirected to dashboard after successful magic link auth',
        );
      },
    );

    testWidgets(
      'CRITICAL: Auth state propagation should be synchronous with router checks',
      (tester) async {
        final testUser = User(
          id: 'test-user-id',
          email: 'test@example.com',
          /* familyId removed - use FamilyMember entity */
          name: 'Test User',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final container = ProviderContainer();

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Consumer(
                  builder: (context, ref, child) {
                    final authState = ref.watch(authStateProvider);
                    return Text('Auth: ${authState.isAuthenticated}');
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        // Verify initial unauthenticated state
        final initialAuthState = container.read(authStateProvider);
        expect(initialAuthState.isAuthenticated, isFalse);

        // Act: Update auth state to authenticated
        container.read(authStateProvider.notifier).state = AuthState(
          user: testUser,
          isInitialized: true,
        );

        // Immediately check the state (this simulates what router redirect does)
        final updatedAuthState = container.read(authStateProvider);

        // Assert: State should be immediately available (no race condition)
        expect(
          updatedAuthState.isAuthenticated,
          isTrue,
          reason: 'Auth state should be immediately available after update',
        );
        expect(
          updatedAuthState.user,
          equals(testUser),
          reason: 'User data should be immediately available after update',
        );
      },
    );

    testWidgets(
      'CRITICAL: Router refresh should trigger on auth state changes',
      (tester) async {
        final testUser = User(
          id: 'test-user-id',
          email: 'test@example.com',
          /* familyId removed - use FamilyMember entity */
          name: 'Test User',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        var routerRedirectCalled = false;
        final container = ProviderContainer();

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              routerConfig: GoRouter(
                initialLocation: '/auth/login',
                redirect: (context, state) {
                  routerRedirectCalled = true;

                  // Read auth state (this is what the real router does)
                  final authState = container.read(authStateProvider);

                  if (!authState.isAuthenticated) {
                    return '/auth/login';
                  }

                  if (authState.isAuthenticated &&
                      state.matchedLocation.startsWith('/auth')) {
                    return '/dashboard';
                  }

                  return null;
                },
                routes: [
                  GoRoute(
                    path: '/auth/login',
                    builder: (context, state) =>
                        const Scaffold(body: Text('Login')),
                  ),
                  GoRoute(
                    path: '/dashboard',
                    builder: (context, state) =>
                        const Scaffold(body: Text('Dashboard')),
                  ),
                ],
              ),
            ),
          ),
        );

        await tester.pump();

        // Reset redirect tracking
        routerRedirectCalled = false;

        // Act: Change auth state
        container.read(authStateProvider.notifier).state = AuthState(
          user: testUser,
          isInitialized: true,
        );

        await tester.pump();

        // Assert: Router redirect should have been called with updated state
        expect(
          routerRedirectCalled,
          isTrue,
          reason: 'Router redirect should be called when auth state changes',
        );
      },
    );

    testWidgets(
      'REGRESSION: Magic link should not cause infinite redirect loop',
      (tester) async {
        final testUser = User(
          id: 'test-user-id',
          email: 'test@example.com',
          /* familyId removed - use FamilyMember entity */
          name: 'Test User',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        var redirectCount = 0;
        final container = ProviderContainer();

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              routerConfig: GoRouter(
                initialLocation: '/auth/verify?token=test-token',
                redirect: (context, state) {
                  redirectCount++;

                  // Prevent infinite loops in tests
                  if (redirectCount > 5) {
                    fail('Infinite redirect loop detected');
                  }

                  final authState = container.read(authStateProvider);

                  if (!authState.isAuthenticated &&
                      !state.matchedLocation.startsWith('/auth')) {
                    return '/auth/login';
                  }

                  if (authState.isAuthenticated &&
                      state.matchedLocation.startsWith('/auth') &&
                      state.matchedLocation != '/auth/verify') {
                    return '/dashboard';
                  }

                  return null;
                },
                routes: [
                  GoRoute(
                    path: '/auth/login',
                    builder: (context, state) =>
                        const Scaffold(body: Text('Login')),
                  ),
                  GoRoute(
                    path: '/auth/verify',
                    builder: (context, state) =>
                        const Scaffold(body: Text('Verify')),
                  ),
                  GoRoute(
                    path: '/dashboard',
                    builder: (context, state) =>
                        const Scaffold(body: Text('Dashboard')),
                  ),
                ],
              ),
            ),
          ),
        );

        await tester.pump();

        // Simulate magic link verification completing
        container.read(authStateProvider.notifier).state = AuthState(
          user: testUser,
          isInitialized: true,
        );

        await tester.pump();

        // Assert: Should not have excessive redirects
        expect(
          redirectCount,
          lessThan(5),
          reason:
              'Should not cause infinite redirect loop during magic link auth',
        );
      },
    );
  });
}
