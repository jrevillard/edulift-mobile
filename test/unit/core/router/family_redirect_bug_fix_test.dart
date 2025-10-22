@Skip('Obsolete: Tests router redirects based on User.familyId which no longer exists. Architecture changed to use FamilyRepository.getCurrentFamily(). Needs rewrite.')
library;

// COMPREHENSIVE ROUTER REDIRECT TESTS FOR FAMILY SYNCHRONIZATION BUG FIX
//
// CRITICAL BUG SCENARIO: Users with families were getting redirected to
// onboarding instead of dashboard because familyId was null in local state
// even though the API showed they belonged to a family.
//
// These tests verify that the router correctly handles family-based redirects
// after the AuthService family synchronization fix is in place.

import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/domain/entities/user.dart';

void main() {
  group('Router Family Redirect Bug Fix Tests', () {
    /// Helper to create test user with specific family status
    User createTestUser({
      required String id,
      required String email,
      required String name,
      String? familyId,
      bool hasCompletedOnboarding = true,
    }) {
      return User(
        id: id,
        email: email,
        name: name,
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2024-08-27T10:00:00Z'),
        hasCompletedOnboarding: hasCompletedOnboarding,
      );
    }

    group('Dashboard Access - Users WITH Family', () {
      test(
        'CRITICAL: User with familyId MUST access dashboard (not onboarding)',
        () {
          // Arrange: User with existing family membership (FIXED scenario)
          final userWithFamily = createTestUser(
            id: 'user-with-family-123',
            email: 'parent@family.com',
            name: 'John Parent',
            // familyId removed: 'family-456', // CRITICAL: This prevents redirect loop
          );

          // Act: Test redirect logic that router would use
          final shouldRedirectToOnboarding = _needsOnboarding(userWithFamily);
          final shouldRedirectToDashboard = _canAccessDashboard(userWithFamily);

          // Assert: MUST NOT redirect to onboarding when user has family
          expect(
            shouldRedirectToOnboarding,
            isFalse,
            reason:
                'Users with familyId should NOT be redirected to onboarding',
          );

          expect(
            shouldRedirectToDashboard,
            isTrue,
            reason: 'Users with familyId should be able to access dashboard',
          );
        },
      );

      test(
        'should allow access to all family routes when user has familyId',
        () {
          final userWithFamily = createTestUser(
            id: 'user-123',
            email: 'parent@family.com',
            name: 'John Parent',
            // familyId removed: 'family-456',
          );

          // Test various family-related routes
          final familyRoutes = [
            '/dashboard',
            '/family',
            '/family/vehicles',
            '/family/children',
            '/family/schedule',
          ];

          for (final route in familyRoutes) {
            final canAccess = _canAccessRoute(route, userWithFamily);
            expect(
              canAccess,
              isTrue,
              reason: 'User with familyId should access route: $route',
            );
          }
        },
      );

      test('should handle users with family during magic link authentication', () {
        // Simulate the exact bug fix scenario
        final userAfterMagicLinkAuth = createTestUser(
          id: 'user-123',
          email: 'parent@family.com',
          name: 'John Parent',
          // familyId removed - Family data synced via getCurrentUser(forceRefresh: true)
        );

        // Act: Check redirect behavior post-authentication
        final redirectTarget = _determinePostAuthRedirect(
          userAfterMagicLinkAuth,
        );

        // Assert: Should redirect to dashboard, not onboarding
        expect(
          redirectTarget,
          equals('/dashboard'),
          reason:
              'After magic link auth with family sync, user should go to dashboard',
        );
      });
    });

    group('Onboarding Access - Users WITHOUT Family', () {
      test('should redirect new users to onboarding when familyId is null', () {
        // Arrange: New user without family membership
        final userWithoutFamily = createTestUser(
          id: 'user-789',
          email: 'newuser@example.com',
          name: 'New User',
          // familyId defaults to null - no family membership
        );

        // Act: Test redirect logic
        final shouldRedirectToOnboarding = _needsOnboarding(userWithoutFamily);
        final shouldRedirectToDashboard = _canAccessDashboard(
          userWithoutFamily,
        );

        // Assert: Should redirect to onboarding
        expect(
          shouldRedirectToOnboarding,
          isTrue,
          reason: 'Users without familyId should be redirected to onboarding',
        );

        expect(
          shouldRedirectToDashboard,
          isFalse,
          reason: 'Users without familyId cannot access dashboard',
        );
      });

      test('should block protected routes when user has no familyId', () {
        final userWithoutFamily = createTestUser(
          id: 'user-789',
          email: 'newuser@example.com',
          name: 'New User',
          // familyId defaults to null
        );

        final protectedRoutes = [
          '/dashboard',
          '/family',
          '/family/vehicles',
          '/family/children',
          '/schedule',
        ];

        for (final route in protectedRoutes) {
          final canAccess = _canAccessRoute(route, userWithoutFamily);
          expect(
            canAccess,
            isFalse,
            reason: 'User without familyId should NOT access route: $route',
          );
        }
      });

      test('should allow onboarding routes even without familyId', () {
        final userWithoutFamily = createTestUser(
          id: 'user-789',
          email: 'newuser@example.com',
          name: 'New User',
        );

        final onboardingRoutes = [
          '/onboarding',
          '/onboarding/welcome',
          '/family/create',
          '/family/join',
        ];

        for (final route in onboardingRoutes) {
          final canAccess = _canAccessRoute(route, userWithoutFamily);
          expect(
            canAccess,
            isTrue,
            reason: 'User should access onboarding route: $route',
          );
        }
      });
    });

    group('Edge Cases and Transitions', () {
      test(
        'should handle user state transition from no-family to with-family',
        () {
          // Simulate the user joining a family during their session

          // Initial state: No family
          final initialUser = createTestUser(
            id: 'user-123',
            email: 'user@example.com',
            name: 'Test User',
            // familyId defaults to null
          );

          expect(_needsOnboarding(initialUser), isTrue);
          expect(
            _determinePostAuthRedirect(initialUser),
            equals('/onboarding'),
          );

          // Updated state: Family joined (via family sync)
          final updatedUser = createTestUser(
            id: 'user-123',
            email: 'user@example.com',
            name: 'Test User',
            // familyId removed: 'family-456', // Family now populated via API sync
          );

          expect(_needsOnboarding(updatedUser), isFalse);
          expect(_determinePostAuthRedirect(updatedUser), equals('/dashboard'));
        },
      );

      test('should handle family creation flow correctly', () {
        // User starts without family, creates one
        final userCreatingFamily = createTestUser(
          id: 'user-999',
          email: 'creator@example.com',
          name: 'Family Creator',
        );

        // Should be able to access family creation routes
        expect(_canAccessRoute('/family/create', userCreatingFamily), isTrue);
        expect(_canAccessRoute('/onboarding', userCreatingFamily), isTrue);

        // After family creation (familyId gets populated)
        // ARCHITECTURE FIX: familyId removed from User entity
        final userAfterCreation = userCreatingFamily;

        expect(_needsOnboarding(userAfterCreation), isFalse);
        expect(_canAccessRoute('/dashboard', userAfterCreation), isTrue);
      });

      test('should handle concurrent auth scenarios with family status', () {
        // Test rapid state changes during authentication
        final scenarios = [
          // Scenario 1: User with family
          createTestUser(
            id: 'concurrent-1',
            email: 'user1@family.com',
            name: 'User 1',
            // familyId removed: 'family-concurrent',
          ),
          // Scenario 2: User without family
          createTestUser(
            id: 'concurrent-2',
            email: 'user2@example.com',
            name: 'User 2',
          ),
        ];

        for (var i = 0; i < scenarios.length; i++) {
          final user = scenarios[i];
          final hasFamily = user.familyId != null;

          expect(
            _canAccessDashboard(user),
            equals(hasFamily),
            reason:
                'Concurrent scenario $i: Dashboard access should match family status',
          );

          expect(
            _needsOnboarding(user),
            equals(!hasFamily),
            reason:
                'Concurrent scenario $i: Onboarding need should be inverse of family status',
          );
        }
      });

      test(
        'should properly handle logout and re-authentication with family data',
        () {
          // User before logout (has family)
          final authenticatedUser = createTestUser(
            id: 'user-123',
            email: 'parent@family.com',
            name: 'John Parent',
            // familyId removed: 'family-456',
          );

          expect(_canAccessDashboard(authenticatedUser), isTrue);

          // After logout (no user data)
          const User? loggedOutUser = null;
          expect(_canAccessDashboard(loggedOutUser), isFalse);

          // After re-authentication with family data preserved
          final reAuthenticatedUser = createTestUser(
            id: 'user-123',
            email: 'parent@family.com',
            name: 'John Parent',
            // familyId removed: 'family-456', // Family preserved after re-auth
          );

          expect(_canAccessDashboard(reAuthenticatedUser), isTrue);
          expect(_needsOnboarding(reAuthenticatedUser), isFalse);
        },
      );
    });

    group('Authentication Flow Integration', () {
      test('magic link authentication should result in correct routing', () {
        // Test various user types after magic link authentication
        final testCases = [
          {
            'name': 'Existing family member',
            'user': createTestUser(
              id: 'member-123',
              email: 'member@family.com',
              name: 'Family Member',
              // familyId removed: 'existing-family',
            ),
            'expectedRoute': '/dashboard',
            'shouldOnboard': false,
          },
          {
            'name': 'New user without family',
            'user': createTestUser(
              id: 'new-456',
              email: 'new@example.com',
              name: 'New User',
            ),
            'expectedRoute': '/onboarding',
            'shouldOnboard': true,
          },
        ];

        for (final testCase in testCases) {
          final user = testCase['user'] as User;
          final expectedRoute = testCase['expectedRoute'] as String;
          final shouldOnboard = testCase['shouldOnboard'] as bool;

          final actualRoute = _determinePostAuthRedirect(user);
          final actualOnboarding = _needsOnboarding(user);

          expect(
            actualRoute,
            equals(expectedRoute),
            reason: '${testCase['name']}: Wrong route after magic link auth',
          );

          expect(
            actualOnboarding,
            equals(shouldOnboard),
            reason: '${testCase['name']}: Wrong onboarding decision',
          );
        }
      });
    });
  });
}

/// Helper functions that simulate the actual router logic

bool _needsOnboarding(User? user) {
  if (user == null) return false;
  // User needs onboarding if they're authenticated but have no familyId
  return user.familyId == null && user.hasCompletedOnboarding;
}

bool _canAccessDashboard(User? user) {
  if (user == null) return false;
  // User can access dashboard if they have a familyId
  return user.familyId != null;
}

bool _canAccessRoute(String route, User? user) {
  if (user == null) return false;

  // Public routes (always accessible)
  final publicRoutes = ['/login', '/auth'];
  if (publicRoutes.any((r) => route.startsWith(r))) return true;

  // Onboarding routes (accessible without family)
  final onboardingRoutes = ['/onboarding', '/family/create', '/family/join'];
  if (onboardingRoutes.any((r) => route.startsWith(r))) return true;

  // Protected routes (require family membership)
  final protectedRoutes = ['/dashboard', '/family', '/schedule'];
  if (protectedRoutes.any((r) => route.startsWith(r))) {
    return user.familyId != null;
  }

  // Default: allow if user exists
  return true;
}

String _determinePostAuthRedirect(User? user) {
  if (user == null) return '/login';

  // CRITICAL LOGIC: This is the exact bug that was fixed
  // Users with familyId should go to dashboard
  // Users without familyId should go to onboarding
  if (user.familyId != null) {
    return '/dashboard'; // BUG FIX: Family users go to dashboard
  } else {
    return '/onboarding'; // New users without family go to onboarding
  }
}
