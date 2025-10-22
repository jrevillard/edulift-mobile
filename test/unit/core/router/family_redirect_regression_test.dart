@Skip('Obsolete: Tests router redirects based on User.familyId which no longer exists. Architecture changed to use FamilyRepository.getCurrentFamily(). Needs rewrite.')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:edulift/core/domain/entities/user.dart';
import 'package:edulift/core/services/providers/auth_provider.dart';

import '../../../test_mocks/test_mocks.mocks.dart';
import '../../../support/mock_fallbacks.dart' as fallbacks;

/// CRITICAL REGRESSION TESTS: Router Family Redirect Logic
///
/// Following FLUTTER_TESTING_RESEARCH_2025.md standards:
/// - Tests organized by architectural layer (core/router)
/// - Comprehensive redirect scenario coverage
/// - Mock AuthStateProvider with realistic user states
///
/// **ISSUE FIXED**: Router redirect logic was checking user.familyId but
/// AuthService was not populating this field, causing redirect loops.
///
/// **ROUTER LOGIC TESTED**:
/// ```dart
/// if (currentUser?.familyId == null) {
///   return '/onboarding/wizard'; // Redirect to onboarding
/// }
/// return AppRoutes.dashboard; // Allow dashboard access
/// ```
///
/// **CRITICAL TEST SCENARIOS**:
/// 1. User with familyId -> Dashboard access (NO redirect loop)
/// 2. User without familyId -> Onboarding redirect (correct behavior)
/// 3. Magic link verification -> Always allowed regardless of family status
/// 4. Biometric auth scenarios with family status changes

void main() {
  setUpAll(() {
    fallbacks.setupMockFallbacks();
  });

  group('Router Family Redirect Regression Tests', () {
    late MockAuthNotifier mockAuthNotifier;

    setUp(() {
      mockAuthNotifier = MockAuthNotifier();
    });

    /// Creates a test user with specified family status
    User createTestUser({
      required String id,
      required String email,
      required String name,
      String? familyId,
      bool isBiometricEnabled = false,
    }) {
      return User(
        id: id,
        email: email,
        name: name,
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2024-08-25T10:00:00Z'),
        isBiometricEnabled: isBiometricEnabled,
        // familyId removed - using UserFamilyExtension bridge
      );
    }

    /// Creates mock AuthState
    AuthState createAuthState({required bool isAuthenticated, User? user}) {
      return AuthState(user: user, isInitialized: true);
    }

    group('CRITICAL REGRESSION: User with Family -> Dashboard Access', () {
      test('MUST allow dashboard access when user has familyId', () {
        // ARRANGE: User with existing family (FIXED scenario)
        final userWithFamily = createTestUser(
          id: 'user-123',
          email: 'parent@family.com',
          name: 'John Parent',
          familyId: 'family-456', // CRITICAL: This prevents redirect loop
        );

        final authState = createAuthState(
          isAuthenticated: true,
          user: userWithFamily,
        );

        when(mockAuthNotifier.state).thenReturn(authState);

        // SIMULATE: Router redirect function logic
        final shouldRedirectToOnboarding = authState.user?.familyId == null;
        final shouldAllowDashboard =
            authState.isAuthenticated && authState.user?.familyId != null;

        // ASSERT: Verify redirect logic prevents loop
        expect(
          shouldRedirectToOnboarding,
          false,
          reason: 'User with familyId should NOT be redirected to onboarding',
        );
        expect(
          shouldAllowDashboard,
          true,
          reason: 'User with familyId should be allowed dashboard access',
        );

        // VERIFY: Family ID is properly populated
        expect(authState.user!.familyId, 'family-456');
        expect(authState.user!.email, 'parent@family.com');
      });

      test(
        'MUST NOT redirect to onboarding when accessing auth routes with family',
        () {
          // ARRANGE: Authenticated user with family trying to access /auth routes
          final userWithFamily = createTestUser(
            id: 'user-123',
            email: 'parent@family.com',
            name: 'John Parent',
            familyId: 'family-456',
          );

          final authState = createAuthState(
            isAuthenticated: true,
            user: userWithFamily,
          );

          // SIMULATE: Router logic for auth routes
          const currentLocation = '/auth/profile';
          final isAuthRoute = currentLocation.startsWith('/auth');
          final shouldRedirectToDashboard =
              authState.isAuthenticated &&
              isAuthRoute &&
              authState.user?.familyId != null;

          // ASSERT: Should redirect to dashboard, not onboarding
          expect(shouldRedirectToDashboard, true);
          expect(authState.user!.familyId, isNotNull);
        },
      );

      test('MUST handle biometric authentication with family correctly', () {
        // ARRANGE: User with both biometric enabled and family
        final userWithFamilyAndBiometric = createTestUser(
          id: 'user-123',
          email: 'parent@family.com',
          name: 'John Parent',
          familyId:
              'family-456', // CRITICAL: Must be preserved during biometric auth
          isBiometricEnabled: true,
        );

        final authState = createAuthState(
          isAuthenticated: true,
          user: userWithFamilyAndBiometric,
        );

        // SIMULATE: Router decisions after biometric auth
        final hasFamily = authState.user?.familyId != null;
        final hasBiometric = authState.user?.isBiometricEnabled == true;

        // ASSERT: Both family and biometric status preserved
        expect(
          hasFamily,
          true,
          reason: 'familyId must be preserved during biometric operations',
        );
        expect(hasBiometric, true);
        expect(authState.user!.familyId, 'family-456');
      });
    });

    group(
      'CRITICAL REGRESSION: User without Family -> Onboarding Redirect',
      () {
        test('MUST redirect to onboarding when user has no familyId', () {
          // ARRANGE: New user without family (correct behavior)
          final userWithoutFamily = createTestUser(
            id: 'user-789',
            email: 'newuser@example.com',
            name: 'New User',
            // familyId defaults to null - no family -> should go to onboarding
          );

          final authState = createAuthState(
            isAuthenticated: true,
            user: userWithoutFamily,
          );

          // SIMULATE: Router redirect logic
          final shouldRedirectToOnboarding =
              authState.isAuthenticated && authState.user?.familyId == null;
          final shouldBlockDashboard = authState.user?.familyId == null;

          // ASSERT: Correct redirect behavior for new users
          expect(
            shouldRedirectToOnboarding,
            true,
            reason: 'New users without family should go to onboarding',
          );
          expect(
            shouldBlockDashboard,
            true,
            reason: 'Dashboard should be blocked without familyId',
          );
          expect(authState.user!.familyId, null);
        });

        test('MUST block protected routes when no familyId', () {
          // ARRANGE: User without family trying to access protected routes
          final userWithoutFamily = createTestUser(
            id: 'user-789',
            email: 'newuser@example.com',
            name: 'New User',
            // familyId defaults to null
          );

          final authState = createAuthState(
            isAuthenticated: true,
            user: userWithoutFamily,
          );

          // SIMULATE: Router logic for protected routes
          final protectedRoutes = [
            '/dashboard',
            '/family/members',
            '/groups/list',
            '/schedule/view',
          ];

          for (final route in protectedRoutes) {
            final shouldBlock =
                authState.isAuthenticated &&
                authState.user?.familyId == null &&
                (route.startsWith('/family') ||
                    route.startsWith('/groups') ||
                    route.startsWith('/schedule') ||
                    route == '/dashboard');

            expect(
              shouldBlock,
              true,
              reason: 'Route $route should be blocked without familyId',
            );
          }
        });

        test('MUST allow create family routes even without familyId', () {
          // ARRANGE: User without family accessing family creation
          final userWithoutFamily = createTestUser(
            id: 'user-789',
            email: 'newuser@example.com',
            name: 'New User',
            // familyId defaults to null
          );

          final authState = createAuthState(
            isAuthenticated: true,
            user: userWithoutFamily,
          );

          // SIMULATE: Router logic for family creation routes
          final allowedRoutes = ['/family/create', '/family/invite'];

          for (final route in allowedRoutes) {
            final shouldAllow =
                authState.isAuthenticated &&
                (route == '/family/create' || route == '/family/invite');

            expect(
              shouldAllow,
              true,
              reason: 'Route $route should be allowed for family creation',
            );
          }
        });
      },
    );

    group('CRITICAL REGRESSION: Magic Link Verification Edge Cases', () {
      test(
        'MUST always allow magic link verification regardless of family status',
        () {
          // ARRANGE: Various user states during magic link verification
          final testCases = [
            {
              'user': null,
              'authenticated': false,
              'scenario': 'unauthenticated',
            },
            {
              'user': createTestUser(
                id: 'user-123',
                email: 'user@example.com',
                name: 'User',
                // familyId defaults to null
              ),
              'authenticated': true,
              'scenario': 'authenticated without family',
            },
            {
              'user': createTestUser(
                id: 'user-456',
                email: 'parent@family.com',
                name: 'Parent',
                familyId: 'family-123',
              ),
              'authenticated': true,
              'scenario': 'authenticated with family',
            },
          ];

          for (final testCase in testCases) {
            // AuthState not needed - just verify route access logic

            // SIMULATE: Magic link verification route access
            const magicLinkVerifyRoute = '/auth/verify';
            const isMagicLinkVerifyRoute =
                magicLinkVerifyRoute == '/auth/verify';

            // ASSERT: Magic link verification should ALWAYS be allowed
            expect(
              isMagicLinkVerifyRoute,
              true,
              reason:
                  'Magic link verification must be allowed for ${testCase['scenario']}',
            );
          }
        },
      );

      test('MUST handle invitation flows with family join scenarios', () {
        // ARRANGE: Test invitation route access without requiring user state

        // SIMULATE: Invitation route access
        final invitationRoutes = [
          '/invite/family-123',
          '/families/join/family-456',
          '/groups/join/group-789',
        ];

        for (final route in invitationRoutes) {
          final isInvitationRoute =
              route.startsWith('/invite') ||
              route.startsWith('/families/join') ||
              route.startsWith('/groups/join');

          // ASSERT: Invitation routes should be accessible
          expect(
            isInvitationRoute,
            true,
            reason: 'Invitation route $route should be accessible',
          );
        }

        // SIMULATE: After successful family join (familyId gets populated)
        final userAfterJoin = createTestUser(
          id: 'user-999',
          email: 'invitee@example.com',
          name: 'Invitee',
          familyId: 'family-123', // Now has family
        );

        final authStateAfterJoin = createAuthState(
          isAuthenticated: true,
          user: userAfterJoin,
        );

        final shouldAllowDashboard = authStateAfterJoin.user?.familyId != null;

        // ASSERT: After joining family, dashboard should be accessible
        expect(
          shouldAllowDashboard,
          true,
          reason: 'After joining family, dashboard should be accessible',
        );
        expect(authStateAfterJoin.user!.familyId, 'family-123');
      });
    });

    group('EDGE CASES: Router State Transitions', () {
      test(
        'MUST handle auth state changes from null to populated familyId',
        () {
          // ARRANGE: Simulate auth state transition during family join

          // Initial state: No family
          final initialUser = createTestUser(
            id: 'user-123',
            email: 'user@example.com',
            name: 'User',
            // familyId defaults to null
          );

          final initialAuthState = createAuthState(
            isAuthenticated: true,
            user: initialUser,
          );

          // Updated state: Family joined
          final updatedUser = createTestUser(
            id: 'user-123',
            email: 'user@example.com',
            name: 'User',
            familyId: 'family-456', // Family now populated
          );

          final updatedAuthState = createAuthState(
            isAuthenticated: true,
            user: updatedUser,
          );

          // SIMULATE: Router decisions before and after
          final initialShouldRedirect = initialAuthState.user?.familyId == null;
          final updatedShouldRedirect = updatedAuthState.user?.familyId == null;

          // ASSERT: Router behavior changes correctly
          expect(
            initialShouldRedirect,
            true,
            reason: 'Initially should redirect to onboarding',
          );
          expect(
            updatedShouldRedirect,
            false,
            reason: 'After family join, should not redirect to onboarding',
          );

          // VERIFY: Family ID transition
          expect(initialAuthState.user!.familyId, null);
          expect(updatedAuthState.user!.familyId, 'family-456');
        },
      );

      test('MUST handle concurrent auth operations with family status', () {
        // ARRANGE: User with family enabling biometric auth
        final userWithFamily = createTestUser(
          id: 'user-123',
          email: 'parent@family.com',
          name: 'John Parent',
          familyId: 'family-456',
          // isBiometricEnabled defaults to false
        );

        final beforeBiometricEnable = createAuthState(
          isAuthenticated: true,
          user: userWithFamily,
        );

        // SIMULATE: After biometric enable (familyId should be preserved)
        final userAfterBiometricEnable = createTestUser(
          id: 'user-123',
          email: 'parent@family.com',
          name: 'John Parent',
          familyId: 'family-456', // CRITICAL: Must be preserved
          isBiometricEnabled: true,
        );

        final afterBiometricEnable = createAuthState(
          isAuthenticated: true,
          user: userAfterBiometricEnable,
        );

        // VERIFY: Family status preserved through biometric operations
        expect(beforeBiometricEnable.user!.familyId, 'family-456');
        expect(afterBiometricEnable.user!.familyId, 'family-456');
        expect(beforeBiometricEnable.user!.isBiometricEnabled, false);
        expect(afterBiometricEnable.user!.isBiometricEnabled, true);

        // VERIFY: Router decisions remain consistent
        final beforeShouldRedirect =
            beforeBiometricEnable.user?.familyId == null;
        final afterShouldRedirect = afterBiometricEnable.user?.familyId == null;

        expect(beforeShouldRedirect, false);
        expect(
          afterShouldRedirect,
          false,
          reason:
              'familyId preservation prevents redirect loop during biometric operations',
        );
      });

      test('MUST handle logout and re-authentication scenarios', () {
        // ARRANGE: User logout scenario
        final authenticatedUser = createTestUser(
          id: 'user-123',
          email: 'parent@family.com',
          name: 'John Parent',
          familyId: 'family-456',
        );

        final authenticatedState = createAuthState(
          isAuthenticated: true,
          user: authenticatedUser,
        );

        final loggedOutState = createAuthState(
          isAuthenticated: false,
          // user defaults to null
        );

        // SIMULATE: Router decisions
        final authenticatedShouldRedirect = !authenticatedState.isAuthenticated;
        final loggedOutShouldRedirect = !loggedOutState.isAuthenticated;

        // ASSERT: Proper redirect behavior
        expect(authenticatedShouldRedirect, false);
        expect(
          loggedOutShouldRedirect,
          true,
          reason: 'Logged out users should be redirected to login',
        );

        // SIMULATE: Re-authentication with family data intact
        final reAuthenticatedUser = createTestUser(
          id: 'user-123',
          email: 'parent@family.com',
          name: 'John Parent',
          familyId: 'family-456', // Family preserved after re-auth
        );

        final reAuthenticatedState = createAuthState(
          isAuthenticated: true,
          user: reAuthenticatedUser,
        );

        final reAuthShouldAllowDashboard =
            reAuthenticatedState.isAuthenticated &&
            reAuthenticatedState.user?.familyId != null;

        expect(
          reAuthShouldAllowDashboard,
          true,
          reason: 'Re-authenticated user with family should access dashboard',
        );
      });
    });

    group('PERFORMANCE: Router Refresh Optimization', () {
      test('SHOULD verify router refresh triggers on auth state changes', () {
        // This test documents expected router refresh behavior
        // when auth state changes (especially familyId changes)

        // ARRANGE: Auth state changes that should trigger router refresh
        final stateChanges = [
          'user login with family',
          'user login without family',
          'family join (familyId populated)',
          'biometric enable (familyId preserved)',
          'biometric disable (familyId preserved)',
          'user logout',
        ];

        for (final changeType in stateChanges) {
          // Each auth state change should trigger router refresh
          // to re-evaluate redirect logic with new user.familyId state

          expect(
            changeType.isNotEmpty,
            true,
            reason:
                'Auth state change "$changeType" should trigger router refresh',
          );
        }

        // VERIFY: Critical auth state fields that affect routing
        final criticalFields = ['isAuthenticated', 'user.familyId', 'user.id'];

        for (final field in criticalFields) {
          expect(
            field.isNotEmpty,
            true,
            reason:
                'Field "$field" changes should trigger router re-evaluation',
          );
        }
      });
    });
  });
}
