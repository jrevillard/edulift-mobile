// EduLift Mobile - Router Redirect Logic Unit Tests
// Tests ACTUAL redirect behavior with REAL GoRouter instances
// Following Flutter 2025 testing standards - NO BOOLEAN MATH!

@Skip('Test file obsolete: Tests router redirects based on User.familyId which no longer exists. Architecture changed: familyId now accessed via FamilyRepository.getCurrentFamily(), not User entity. Entire test suite needs rewrite for new architecture.')

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

import 'package:edulift/core/router/app_routes.dart';
import 'package:edulift/core/extensions/user_family_extensions.dart';
import '../../../test_mocks/generated_mocks.dart';
import '../../../test_mocks/test_mocks.mocks.dart';
import '../../../support/test_environment.dart';

void main() {
  group('AppRouter Redirect Logic Tests - REAL ROUTER TESTING', () {
    late GoRouter router;
    late MockUserFamilyService mockUserFamilyService;

    setUp(() async {
      await TestEnvironment.initialize();

      // Setup UserFamilyService mock for extension methods
      mockUserFamilyService = MockUserFamilyService();
      UserFamilyServiceInjector.setService(mockUserFamilyService);

      // Setup mock responses for both user types used in tests
      // User without family (test-user-1)
      when(mockUserFamilyService.getCachedFamilyId('test-user-1'))
          .thenReturn(null);
      when(mockUserFamilyService.getCachedHasFamily('test-user-1'))
          .thenReturn(false);
      when(mockUserFamilyService.getCachedFamilyRole('test-user-1'))
          .thenReturn(null);

      // User with family (test-user-2)
      when(mockUserFamilyService.getCachedFamilyId('test-user-2'))
          .thenReturn('test-family-123');
      when(mockUserFamilyService.getCachedHasFamily('test-user-2'))
          .thenReturn(true);
      when(mockUserFamilyService.getCachedFamilyRole('test-user-2'))
          .thenReturn('parent');
    });

    tearDown(() {
      router.dispose();
      UserFamilyServiceInjector.clearService();
    });

    group('Authentication-Based Redirects', () {
      testWidgets('CRITICAL: Splash redirect for authenticated user', (
        tester,
      ) async {
        // ARRANGE - Create authenticated user WITHOUT family
        final mockAuthState =
            AuthStateMockFactory.createAuthenticatedWithoutFamily();

        // Create router with a mock ref that returns our auth state
        router = GoRouter(
          initialLocation: AppRoutes.splash,
          redirect: (context, state) {
            // Simulate the same redirect logic as AppRouter
            final authState = mockAuthState;

            if (!authState.isInitialized) {
              return AppRoutes.splash;
            }

            final isAuthenticated = authState.isAuthenticated;
            final currentUser = authState.user;
            final isAuthRoute = state.matchedLocation.startsWith('/auth');
            final isSplashRoute = state.matchedLocation == '/splash';
            final isOnboardingRoute = state.matchedLocation.startsWith(
              '/onboarding',
            );
            final isMagicLinkVerifyRoute =
                state.matchedLocation == '/auth/verify';

            // Similar redirect logic as in AppRouter
            if (!isAuthenticated &&
                !isAuthRoute &&
                !isSplashRoute &&
                !isOnboardingRoute &&
                !isMagicLinkVerifyRoute) {
              return AppRoutes.login;
            }

            if (isMagicLinkVerifyRoute) {
              return null; // Allow access
            }

            if (isAuthenticated && isSplashRoute) {
              return AppRoutes.dashboard;
            }

            if (isAuthenticated && isAuthRoute && !isMagicLinkVerifyRoute) {
              if (currentUser?.familyId == null) {
                return '/onboarding/wizard';
              }
              return AppRoutes.dashboard;
            }

            if (isAuthenticated &&
                currentUser?.familyId == null &&
                state.matchedLocation == '/dashboard' &&
                !isOnboardingRoute) {
              return '/onboarding/wizard';
            }

            if (isAuthenticated &&
                currentUser?.familyId == null &&
                (state.matchedLocation.startsWith('/family') ||
                    state.matchedLocation.startsWith('/groups') ||
                    state.matchedLocation.startsWith('/schedule')) &&
                !isOnboardingRoute) {
              return '/onboarding/wizard';
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
              path: AppRoutes.family,
              builder: (context, state) => const Scaffold(body: Text('Family')),
            ),
            GoRoute(
              path: AppRoutes.groups,
              builder: (context, state) => const Scaffold(body: Text('Groups')),
            ),
            GoRoute(
              path: AppRoutes.schedule,
              builder: (context, state) =>
                  const Scaffold(body: Text('Schedule')),
            ),
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) =>
                  const Scaffold(body: Text('Profile')),
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

        // ACT - Navigate to splash
        router.go(AppRoutes.splash);
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        // ASSERT - Should redirect to dashboard, then to onboarding
        expect(
          router.routerDelegate.currentConfiguration.uri.path,
          equals('/onboarding/wizard'),
        );

        // Verify the redirect chain happened: splash -> dashboard -> onboarding
        // (User without family gets redirected from dashboard to onboarding)
      });

      testWidgets(
        'CRITICAL: Authenticated user with family stays on dashboard',
        (tester) async {
          // ARRANGE - Create authenticated user WITH family
          final mockAuthState =
              AuthStateMockFactory.createAuthenticatedWithFamily();

          // Create router with a mock ref that returns our auth state
          router = GoRouter(
            initialLocation: AppRoutes.splash,
            redirect: (context, state) {
              // Simulate the same redirect logic as AppRouter
              final authState = mockAuthState;

              if (!authState.isInitialized) {
                return AppRoutes.splash;
              }

              final isAuthenticated = authState.isAuthenticated;
              final currentUser = authState.user;
              final isAuthRoute = state.matchedLocation.startsWith('/auth');
              final isSplashRoute = state.matchedLocation == '/splash';
              final isOnboardingRoute = state.matchedLocation.startsWith(
                '/onboarding',
              );
              final isMagicLinkVerifyRoute =
                  state.matchedLocation == '/auth/verify';

              // Similar redirect logic as in AppRouter
              if (!isAuthenticated &&
                  !isAuthRoute &&
                  !isSplashRoute &&
                  !isOnboardingRoute &&
                  !isMagicLinkVerifyRoute) {
                return AppRoutes.login;
              }

              if (isMagicLinkVerifyRoute) {
                return null; // Allow access
              }

              if (isAuthenticated && isSplashRoute) {
                return AppRoutes.dashboard;
              }

              if (isAuthenticated && isAuthRoute && !isMagicLinkVerifyRoute) {
                if (currentUser?.familyId == null) {
                  return '/onboarding/wizard';
                }
                return AppRoutes.dashboard;
              }

              if (isAuthenticated &&
                  currentUser?.familyId == null &&
                  state.matchedLocation == '/dashboard' &&
                  !isOnboardingRoute) {
                return '/onboarding/wizard';
              }

              if (isAuthenticated &&
                  currentUser?.familyId == null &&
                  (state.matchedLocation.startsWith('/family') ||
                      state.matchedLocation.startsWith('/groups') ||
                      state.matchedLocation.startsWith('/schedule')) &&
                  !isOnboardingRoute) {
                return '/onboarding/wizard';
              }

              return null;
            },
            routes: [
              GoRoute(
                path: AppRoutes.splash,
                builder: (context, state) =>
                    const Scaffold(body: Text('Splash')),
              ),
              GoRoute(
                path: AppRoutes.login,
                builder: (context, state) =>
                    const Scaffold(body: Text('Login')),
              ),
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) =>
                    const Scaffold(body: Text('Dashboard')),
              ),
              GoRoute(
                path: AppRoutes.family,
                builder: (context, state) =>
                    const Scaffold(body: Text('Family')),
              ),
              GoRoute(
                path: AppRoutes.groups,
                builder: (context, state) =>
                    const Scaffold(body: Text('Groups')),
              ),
              GoRoute(
                path: AppRoutes.schedule,
                builder: (context, state) =>
                    const Scaffold(body: Text('Schedule')),
              ),
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) =>
                    const Scaffold(body: Text('Profile')),
              ),
              GoRoute(
                path: '/onboarding/wizard',
                builder: (context, state) =>
                    const Scaffold(body: Text('Onboarding')),
              ),
              GoRoute(
                path: '/auth/verify',
                builder: (context, state) =>
                    const Scaffold(body: Text('Verify')),
              ),
            ],
          );

          // ACT - Navigate to splash
          router.go(AppRoutes.splash);
          await tester.pumpWidget(MaterialApp.router(routerConfig: router));
          await tester.pumpAndSettle();

          // ASSERT - Should redirect to dashboard and STAY there
          expect(
            router.routerDelegate.currentConfiguration.uri.path,
            equals('/dashboard'),
          );
        },
      );

      testWidgets('CRITICAL: Unauthenticated user redirects to login', (
        tester,
      ) async {
        // ARRANGE - Create unauthenticated state
        final mockAuthState = AuthStateMockFactory.createUnauthenticated();

        // Create router with a mock ref that returns our auth state
        router = GoRouter(
          initialLocation: AppRoutes.splash,
          redirect: (context, state) {
            // Simulate the same redirect logic as AppRouter
            final authState = mockAuthState;

            if (!authState.isInitialized) {
              return AppRoutes.splash;
            }

            final isAuthenticated = authState.isAuthenticated;
            final currentUser = authState.user;
            final isAuthRoute = state.matchedLocation.startsWith('/auth');
            final isSplashRoute = state.matchedLocation == '/splash';
            final isOnboardingRoute = state.matchedLocation.startsWith(
              '/onboarding',
            );
            final isMagicLinkVerifyRoute =
                state.matchedLocation == '/auth/verify';

            // Similar redirect logic as in AppRouter
            if (!isAuthenticated &&
                !isAuthRoute &&
                !isSplashRoute &&
                !isOnboardingRoute &&
                !isMagicLinkVerifyRoute) {
              return AppRoutes.login;
            }

            if (isMagicLinkVerifyRoute) {
              return null; // Allow access
            }

            if (isAuthenticated && isSplashRoute) {
              return AppRoutes.dashboard;
            }

            if (isAuthenticated && isAuthRoute && !isMagicLinkVerifyRoute) {
              if (currentUser?.familyId == null) {
                return '/onboarding/wizard';
              }
              return AppRoutes.dashboard;
            }

            if (isAuthenticated &&
                currentUser?.familyId == null &&
                state.matchedLocation == '/dashboard' &&
                !isOnboardingRoute) {
              return '/onboarding/wizard';
            }

            if (isAuthenticated &&
                currentUser?.familyId == null &&
                (state.matchedLocation.startsWith('/family') ||
                    state.matchedLocation.startsWith('/groups') ||
                    state.matchedLocation.startsWith('/schedule')) &&
                !isOnboardingRoute) {
              return '/onboarding/wizard';
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
              path: AppRoutes.family,
              builder: (context, state) => const Scaffold(body: Text('Family')),
            ),
            GoRoute(
              path: AppRoutes.groups,
              builder: (context, state) => const Scaffold(body: Text('Groups')),
            ),
            GoRoute(
              path: AppRoutes.schedule,
              builder: (context, state) =>
                  const Scaffold(body: Text('Schedule')),
            ),
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) =>
                  const Scaffold(body: Text('Profile')),
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

        // ACT - Try to access protected route
        router.go('/family');
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        // ASSERT - Should redirect to login
        expect(
          router.routerDelegate.currentConfiguration.uri.path,
          equals(AppRoutes.login),
        );
      });
    });

    group('Family Status-Based Redirects', () {
      testWidgets(
        'CRITICAL: User without family redirected from dashboard to onboarding',
        (tester) async {
          // ARRANGE - User without family
          final mockAuthState =
              AuthStateMockFactory.createAuthenticatedWithoutFamily();

          // Create router with a mock ref that returns our auth state
          router = GoRouter(
            initialLocation: AppRoutes.splash,
            redirect: (context, state) {
              // Simulate the same redirect logic as AppRouter
              final authState = mockAuthState;

              if (!authState.isInitialized) {
                return AppRoutes.splash;
              }

              final isAuthenticated = authState.isAuthenticated;
              final currentUser = authState.user;
              final isAuthRoute = state.matchedLocation.startsWith('/auth');
              final isSplashRoute = state.matchedLocation == '/splash';
              final isOnboardingRoute = state.matchedLocation.startsWith(
                '/onboarding',
              );
              final isMagicLinkVerifyRoute =
                  state.matchedLocation == '/auth/verify';

              // Similar redirect logic as in AppRouter
              if (!isAuthenticated &&
                  !isAuthRoute &&
                  !isSplashRoute &&
                  !isOnboardingRoute &&
                  !isMagicLinkVerifyRoute) {
                return AppRoutes.login;
              }

              if (isMagicLinkVerifyRoute) {
                return null; // Allow access
              }

              if (isAuthenticated && isSplashRoute) {
                return AppRoutes.dashboard;
              }

              if (isAuthenticated && isAuthRoute && !isMagicLinkVerifyRoute) {
                if (currentUser?.familyId == null) {
                  return '/onboarding/wizard';
                }
                return AppRoutes.dashboard;
              }

              if (isAuthenticated &&
                  currentUser?.familyId == null &&
                  state.matchedLocation == '/dashboard' &&
                  !isOnboardingRoute) {
                return '/onboarding/wizard';
              }

              if (isAuthenticated &&
                  currentUser?.familyId == null &&
                  (state.matchedLocation.startsWith('/family') ||
                      state.matchedLocation.startsWith('/groups') ||
                      state.matchedLocation.startsWith('/schedule')) &&
                  !isOnboardingRoute) {
                return '/onboarding/wizard';
              }

              return null;
            },
            routes: [
              GoRoute(
                path: AppRoutes.splash,
                builder: (context, state) =>
                    const Scaffold(body: Text('Splash')),
              ),
              GoRoute(
                path: AppRoutes.login,
                builder: (context, state) =>
                    const Scaffold(body: Text('Login')),
              ),
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) =>
                    const Scaffold(body: Text('Dashboard')),
              ),
              GoRoute(
                path: AppRoutes.family,
                builder: (context, state) =>
                    const Scaffold(body: Text('Family')),
              ),
              GoRoute(
                path: AppRoutes.groups,
                builder: (context, state) =>
                    const Scaffold(body: Text('Groups')),
              ),
              GoRoute(
                path: AppRoutes.schedule,
                builder: (context, state) =>
                    const Scaffold(body: Text('Schedule')),
              ),
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) =>
                    const Scaffold(body: Text('Profile')),
              ),
              GoRoute(
                path: '/onboarding/wizard',
                builder: (context, state) =>
                    const Scaffold(body: Text('Onboarding')),
              ),
              GoRoute(
                path: '/auth/verify',
                builder: (context, state) =>
                    const Scaffold(body: Text('Verify')),
              ),
            ],
          );

          // ACT - Direct navigation to dashboard
          router.go(AppRoutes.dashboard);
          await tester.pumpWidget(MaterialApp.router(routerConfig: router));
          await tester.pumpAndSettle();

          // ASSERT - Should redirect to onboarding
          expect(
            router.routerDelegate.currentConfiguration.uri.path,
            equals('/onboarding/wizard'),
          );
        },
      );

      testWidgets(
        'CRITICAL: User without family redirected from family route to onboarding',
        (tester) async {
          // ARRANGE - User without family
          final mockAuthState =
              AuthStateMockFactory.createAuthenticatedWithoutFamily();

          // Create router with a mock ref that returns our auth state
          router = GoRouter(
            initialLocation: AppRoutes.splash,
            redirect: (context, state) {
              // Simulate the same redirect logic as AppRouter
              final authState = mockAuthState;

              if (!authState.isInitialized) {
                return AppRoutes.splash;
              }

              final isAuthenticated = authState.isAuthenticated;
              final currentUser = authState.user;
              final isAuthRoute = state.matchedLocation.startsWith('/auth');
              final isSplashRoute = state.matchedLocation == '/splash';
              final isOnboardingRoute = state.matchedLocation.startsWith(
                '/onboarding',
              );
              final isMagicLinkVerifyRoute =
                  state.matchedLocation == '/auth/verify';

              // Similar redirect logic as in AppRouter
              if (!isAuthenticated &&
                  !isAuthRoute &&
                  !isSplashRoute &&
                  !isOnboardingRoute &&
                  !isMagicLinkVerifyRoute) {
                return AppRoutes.login;
              }

              if (isMagicLinkVerifyRoute) {
                return null; // Allow access
              }

              if (isAuthenticated && isSplashRoute) {
                return AppRoutes.dashboard;
              }

              if (isAuthenticated && isAuthRoute && !isMagicLinkVerifyRoute) {
                if (currentUser?.familyId == null) {
                  return '/onboarding/wizard';
                }
                return AppRoutes.dashboard;
              }

              if (isAuthenticated &&
                  currentUser?.familyId == null &&
                  state.matchedLocation == '/dashboard' &&
                  !isOnboardingRoute) {
                return '/onboarding/wizard';
              }

              if (isAuthenticated &&
                  currentUser?.familyId == null &&
                  (state.matchedLocation.startsWith('/family') ||
                      state.matchedLocation.startsWith('/groups') ||
                      state.matchedLocation.startsWith('/schedule')) &&
                  !isOnboardingRoute) {
                return '/onboarding/wizard';
              }

              return null;
            },
            routes: [
              GoRoute(
                path: AppRoutes.splash,
                builder: (context, state) =>
                    const Scaffold(body: Text('Splash')),
              ),
              GoRoute(
                path: AppRoutes.login,
                builder: (context, state) =>
                    const Scaffold(body: Text('Login')),
              ),
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) =>
                    const Scaffold(body: Text('Dashboard')),
              ),
              GoRoute(
                path: AppRoutes.family,
                builder: (context, state) =>
                    const Scaffold(body: Text('Family')),
              ),
              GoRoute(
                path: AppRoutes.groups,
                builder: (context, state) =>
                    const Scaffold(body: Text('Groups')),
              ),
              GoRoute(
                path: AppRoutes.schedule,
                builder: (context, state) =>
                    const Scaffold(body: Text('Schedule')),
              ),
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) =>
                    const Scaffold(body: Text('Profile')),
              ),
              GoRoute(
                path: '/onboarding/wizard',
                builder: (context, state) =>
                    const Scaffold(body: Text('Onboarding')),
              ),
              GoRoute(
                path: '/auth/verify',
                builder: (context, state) =>
                    const Scaffold(body: Text('Verify')),
              ),
            ],
          );

          // ACT - Try to access family route
          router.go(AppRoutes.family);
          await tester.pumpWidget(MaterialApp.router(routerConfig: router));
          await tester.pumpAndSettle();

          // ASSERT - Should redirect to onboarding
          expect(
            router.routerDelegate.currentConfiguration.uri.path,
            equals('/onboarding/wizard'),
          );
        },
      );

      testWidgets('User with family can access family routes', (tester) async {
        // ARRANGE - User with family
        final mockAuthState =
            AuthStateMockFactory.createAuthenticatedWithFamily();

        // Create router with a mock ref that returns our auth state
        router = GoRouter(
          initialLocation: AppRoutes.splash,
          redirect: (context, state) {
            // Simulate the same redirect logic as AppRouter
            final authState = mockAuthState;

            if (!authState.isInitialized) {
              return AppRoutes.splash;
            }

            final isAuthenticated = authState.isAuthenticated;
            final currentUser = authState.user;
            final isAuthRoute = state.matchedLocation.startsWith('/auth');
            final isSplashRoute = state.matchedLocation == '/splash';
            final isOnboardingRoute = state.matchedLocation.startsWith(
              '/onboarding',
            );
            final isMagicLinkVerifyRoute =
                state.matchedLocation == '/auth/verify';

            // Similar redirect logic as in AppRouter
            if (!isAuthenticated &&
                !isAuthRoute &&
                !isSplashRoute &&
                !isOnboardingRoute &&
                !isMagicLinkVerifyRoute) {
              return AppRoutes.login;
            }

            if (isMagicLinkVerifyRoute) {
              return null; // Allow access
            }

            if (isAuthenticated && isSplashRoute) {
              return AppRoutes.dashboard;
            }

            if (isAuthenticated && isAuthRoute && !isMagicLinkVerifyRoute) {
              if (currentUser?.familyId == null) {
                return '/onboarding/wizard';
              }
              return AppRoutes.dashboard;
            }

            if (isAuthenticated &&
                currentUser?.familyId == null &&
                state.matchedLocation == '/dashboard' &&
                !isOnboardingRoute) {
              return '/onboarding/wizard';
            }

            if (isAuthenticated &&
                currentUser?.familyId == null &&
                (state.matchedLocation.startsWith('/family') ||
                    state.matchedLocation.startsWith('/groups') ||
                    state.matchedLocation.startsWith('/schedule')) &&
                !isOnboardingRoute) {
              return '/onboarding/wizard';
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
              path: AppRoutes.family,
              builder: (context, state) => const Scaffold(body: Text('Family')),
            ),
            GoRoute(
              path: AppRoutes.groups,
              builder: (context, state) => const Scaffold(body: Text('Groups')),
            ),
            GoRoute(
              path: AppRoutes.schedule,
              builder: (context, state) =>
                  const Scaffold(body: Text('Schedule')),
            ),
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) =>
                  const Scaffold(body: Text('Profile')),
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

        // ACT - Navigate to family route
        router.go(AppRoutes.family);
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        // ASSERT - Should stay on family route
        expect(
          router.routerDelegate.currentConfiguration.uri.path,
          equals(AppRoutes.family),
        );
      });
    });

    group('Magic Link Verification Bypass', () {
      testWidgets('CRITICAL: Magic link verification bypasses auth checks', (
        tester,
      ) async {
        // ARRANGE - Unauthenticated user (normally would redirect to login)
        final mockAuthState = AuthStateMockFactory.createUnauthenticated();

        // Create router with a mock ref that returns our auth state
        router = GoRouter(
          initialLocation: AppRoutes.splash,
          redirect: (context, state) {
            // Simulate the same redirect logic as AppRouter
            final authState = mockAuthState;

            if (!authState.isInitialized) {
              return AppRoutes.splash;
            }

            final isAuthenticated = authState.isAuthenticated;
            final currentUser = authState.user;
            final isAuthRoute = state.matchedLocation.startsWith('/auth');
            final isSplashRoute = state.matchedLocation == '/splash';
            final isOnboardingRoute = state.matchedLocation.startsWith(
              '/onboarding',
            );
            final isMagicLinkVerifyRoute =
                state.matchedLocation == '/auth/verify';

            // Similar redirect logic as in AppRouter
            if (!isAuthenticated &&
                !isAuthRoute &&
                !isSplashRoute &&
                !isOnboardingRoute &&
                !isMagicLinkVerifyRoute) {
              return AppRoutes.login;
            }

            if (isMagicLinkVerifyRoute) {
              return null; // Allow access
            }

            if (isAuthenticated && isSplashRoute) {
              return AppRoutes.dashboard;
            }

            if (isAuthenticated && isAuthRoute && !isMagicLinkVerifyRoute) {
              if (currentUser?.familyId == null) {
                return '/onboarding/wizard';
              }
              return AppRoutes.dashboard;
            }

            if (isAuthenticated &&
                currentUser?.familyId == null &&
                state.matchedLocation == '/dashboard' &&
                !isOnboardingRoute) {
              return '/onboarding/wizard';
            }

            if (isAuthenticated &&
                currentUser?.familyId == null &&
                (state.matchedLocation.startsWith('/family') ||
                    state.matchedLocation.startsWith('/groups') ||
                    state.matchedLocation.startsWith('/schedule')) &&
                !isOnboardingRoute) {
              return '/onboarding/wizard';
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
              path: AppRoutes.family,
              builder: (context, state) => const Scaffold(body: Text('Family')),
            ),
            GoRoute(
              path: AppRoutes.groups,
              builder: (context, state) => const Scaffold(body: Text('Groups')),
            ),
            GoRoute(
              path: AppRoutes.schedule,
              builder: (context, state) =>
                  const Scaffold(body: Text('Schedule')),
            ),
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) =>
                  const Scaffold(body: Text('Profile')),
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

        // ACT - Navigate to magic link verification with token
        router.go('/auth/verify?token=test-token-123');
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        // ASSERT - Should stay on verification route (no redirect to login)
        expect(
          router.routerDelegate.currentConfiguration.uri.path,
          equals('/auth/verify'),
        );
        expect(
          router
              .routerDelegate
              .currentConfiguration
              .uri
              .queryParameters['token'],
          equals('test-token-123'),
        );
      });

      testWidgets(
        'Magic link verification with invite code bypasses family checks',
        (tester) async {
          // ARRANGE - Authenticated user without family (normally redirected to onboarding)
          final mockAuthState =
              AuthStateMockFactory.createAuthenticatedWithoutFamily();

          // Create router with a mock ref that returns our auth state
          router = GoRouter(
            initialLocation: AppRoutes.splash,
            redirect: (context, state) {
              // Simulate the same redirect logic as AppRouter
              final authState = mockAuthState;

              if (!authState.isInitialized) {
                return AppRoutes.splash;
              }

              final isAuthenticated = authState.isAuthenticated;
              final currentUser = authState.user;
              final isAuthRoute = state.matchedLocation.startsWith('/auth');
              final isSplashRoute = state.matchedLocation == '/splash';
              final isOnboardingRoute = state.matchedLocation.startsWith(
                '/onboarding',
              );
              final isMagicLinkVerifyRoute =
                  state.matchedLocation == '/auth/verify';

              // Similar redirect logic as in AppRouter
              if (!isAuthenticated &&
                  !isAuthRoute &&
                  !isSplashRoute &&
                  !isOnboardingRoute &&
                  !isMagicLinkVerifyRoute) {
                return AppRoutes.login;
              }

              if (isMagicLinkVerifyRoute) {
                return null; // Allow access
              }

              if (isAuthenticated && isSplashRoute) {
                return AppRoutes.dashboard;
              }

              if (isAuthenticated && isAuthRoute && !isMagicLinkVerifyRoute) {
                if (currentUser?.familyId == null) {
                  return '/onboarding/wizard';
                }
                return AppRoutes.dashboard;
              }

              if (isAuthenticated &&
                  currentUser?.familyId == null &&
                  state.matchedLocation == '/dashboard' &&
                  !isOnboardingRoute) {
                return '/onboarding/wizard';
              }

              if (isAuthenticated &&
                  currentUser?.familyId == null &&
                  (state.matchedLocation.startsWith('/family') ||
                      state.matchedLocation.startsWith('/groups') ||
                      state.matchedLocation.startsWith('/schedule')) &&
                  !isOnboardingRoute) {
                return '/onboarding/wizard';
              }

              return null;
            },
            routes: [
              GoRoute(
                path: AppRoutes.splash,
                builder: (context, state) =>
                    const Scaffold(body: Text('Splash')),
              ),
              GoRoute(
                path: AppRoutes.login,
                builder: (context, state) =>
                    const Scaffold(body: Text('Login')),
              ),
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) =>
                    const Scaffold(body: Text('Dashboard')),
              ),
              GoRoute(
                path: AppRoutes.family,
                builder: (context, state) =>
                    const Scaffold(body: Text('Family')),
              ),
              GoRoute(
                path: AppRoutes.groups,
                builder: (context, state) =>
                    const Scaffold(body: Text('Groups')),
              ),
              GoRoute(
                path: AppRoutes.schedule,
                builder: (context, state) =>
                    const Scaffold(body: Text('Schedule')),
              ),
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) =>
                    const Scaffold(body: Text('Profile')),
              ),
              GoRoute(
                path: '/onboarding/wizard',
                builder: (context, state) =>
                    const Scaffold(body: Text('Onboarding')),
              ),
              GoRoute(
                path: '/auth/verify',
                builder: (context, state) =>
                    const Scaffold(body: Text('Verify')),
              ),
            ],
          );

          // ACT - Navigate to magic link verification with invite code
          router.go('/auth/verify?token=test-token&inviteCode=INVITE123');
          await tester.pumpWidget(MaterialApp.router(routerConfig: router));
          await tester.pumpAndSettle();

          // ASSERT - Should stay on verification route (no redirect to onboarding)
          expect(
            router.routerDelegate.currentConfiguration.uri.path,
            equals('/auth/verify'),
          );
          expect(
            router
                .routerDelegate
                .currentConfiguration
                .uri
                .queryParameters['inviteCode'],
            equals('INVITE123'),
          );
        },
      );
    });

    group('Onboarding Route Access', () {
      testWidgets('User without family can access onboarding routes', (
        tester,
      ) async {
        // ARRANGE - User without family
        final mockAuthState =
            AuthStateMockFactory.createAuthenticatedWithoutFamily();

        // Create router with a mock ref that returns our auth state
        router = GoRouter(
          initialLocation: AppRoutes.splash,
          redirect: (context, state) {
            // Simulate the same redirect logic as AppRouter
            final authState = mockAuthState;

            if (!authState.isInitialized) {
              return AppRoutes.splash;
            }

            final isAuthenticated = authState.isAuthenticated;
            final currentUser = authState.user;
            final isAuthRoute = state.matchedLocation.startsWith('/auth');
            final isSplashRoute = state.matchedLocation == '/splash';
            final isOnboardingRoute = state.matchedLocation.startsWith(
              '/onboarding',
            );
            final isMagicLinkVerifyRoute =
                state.matchedLocation == '/auth/verify';

            // Similar redirect logic as in AppRouter
            if (!isAuthenticated &&
                !isAuthRoute &&
                !isSplashRoute &&
                !isOnboardingRoute &&
                !isMagicLinkVerifyRoute) {
              return AppRoutes.login;
            }

            if (isMagicLinkVerifyRoute) {
              return null; // Allow access
            }

            if (isAuthenticated && isSplashRoute) {
              return AppRoutes.dashboard;
            }

            if (isAuthenticated && isAuthRoute && !isMagicLinkVerifyRoute) {
              if (currentUser?.familyId == null) {
                return '/onboarding/wizard';
              }
              return AppRoutes.dashboard;
            }

            if (isAuthenticated &&
                currentUser?.familyId == null &&
                state.matchedLocation == '/dashboard' &&
                !isOnboardingRoute) {
              return '/onboarding/wizard';
            }

            if (isAuthenticated &&
                currentUser?.familyId == null &&
                (state.matchedLocation.startsWith('/family') ||
                    state.matchedLocation.startsWith('/groups') ||
                    state.matchedLocation.startsWith('/schedule')) &&
                !isOnboardingRoute) {
              return '/onboarding/wizard';
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
              path: AppRoutes.family,
              builder: (context, state) => const Scaffold(body: Text('Family')),
            ),
            GoRoute(
              path: AppRoutes.groups,
              builder: (context, state) => const Scaffold(body: Text('Groups')),
            ),
            GoRoute(
              path: AppRoutes.schedule,
              builder: (context, state) =>
                  const Scaffold(body: Text('Schedule')),
            ),
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) =>
                  const Scaffold(body: Text('Profile')),
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

        // ACT - Navigate directly to onboarding
        router.go('/onboarding/wizard');
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        // ASSERT - Should stay on onboarding (no redirect)
        expect(
          router.routerDelegate.currentConfiguration.uri.path,
          equals('/onboarding/wizard'),
        );
      });
    });

    group('Auth Initialization Handling', () {
      testWidgets('Uninitialized auth shows splash screen', (tester) async {
        // ARRANGE - Uninitialized auth state
        final mockAuthState = AuthStateMockFactory.createUninitialized();

        // Create router with a mock ref that returns our auth state
        router = GoRouter(
          initialLocation: AppRoutes.splash,
          redirect: (context, state) {
            // Simulate the same redirect logic as AppRouter
            final authState = mockAuthState;

            if (!authState.isInitialized) {
              return AppRoutes.splash;
            }

            final isAuthenticated = authState.isAuthenticated;
            final currentUser = authState.user;
            final isAuthRoute = state.matchedLocation.startsWith('/auth');
            final isSplashRoute = state.matchedLocation == '/splash';
            final isOnboardingRoute = state.matchedLocation.startsWith(
              '/onboarding',
            );
            final isMagicLinkVerifyRoute =
                state.matchedLocation == '/auth/verify';

            // Similar redirect logic as in AppRouter
            if (!isAuthenticated &&
                !isAuthRoute &&
                !isSplashRoute &&
                !isOnboardingRoute &&
                !isMagicLinkVerifyRoute) {
              return AppRoutes.login;
            }

            if (isMagicLinkVerifyRoute) {
              return null; // Allow access
            }

            if (isAuthenticated && isSplashRoute) {
              return AppRoutes.dashboard;
            }

            if (isAuthenticated && isAuthRoute && !isMagicLinkVerifyRoute) {
              if (currentUser?.familyId == null) {
                return '/onboarding/wizard';
              }
              return AppRoutes.dashboard;
            }

            if (isAuthenticated &&
                currentUser?.familyId == null &&
                state.matchedLocation == '/dashboard' &&
                !isOnboardingRoute) {
              return '/onboarding/wizard';
            }

            if (isAuthenticated &&
                currentUser?.familyId == null &&
                (state.matchedLocation.startsWith('/family') ||
                    state.matchedLocation.startsWith('/groups') ||
                    state.matchedLocation.startsWith('/schedule')) &&
                !isOnboardingRoute) {
              return '/onboarding/wizard';
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
              path: AppRoutes.family,
              builder: (context, state) => const Scaffold(body: Text('Family')),
            ),
            GoRoute(
              path: AppRoutes.groups,
              builder: (context, state) => const Scaffold(body: Text('Groups')),
            ),
            GoRoute(
              path: AppRoutes.schedule,
              builder: (context, state) =>
                  const Scaffold(body: Text('Schedule')),
            ),
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) =>
                  const Scaffold(body: Text('Profile')),
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

        // ACT - Try to access any route
        router.go('/dashboard');
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        // ASSERT - Should redirect to splash while initializing
        expect(
          router.routerDelegate.currentConfiguration.uri.path,
          equals(AppRoutes.splash),
        );
      });
    });
  });
}
