@Skip('Obsolete: Tests router refresh based on User.familyId which no longer exists. Architecture changed to use FamilyRepository.getCurrentFamily(). Needs rewrite.')
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:edulift/core/domain/entities/user.dart';
import 'package:edulift/core/services/providers/auth_provider.dart';
import '../../../test_mocks/test_mocks.mocks.dart';

void main() {
  group('RouterRefreshNotifier Provider Scope Tests', () {
    late ProviderContainer container;
    late MockAdaptiveStorageService mockStorageService;

    setUp(() {
      mockStorageService = MockAdaptiveStorageService();

      // Setup common mocks
      when(mockStorageService.hasStoredToken()).thenAnswer((_) async => false);
      when(mockStorageService.getToken()).thenAnswer((_) async => null);

      container = ProviderContainer(
        overrides: [
          // Use a simple mock override instead of creating new AuthNotifier
          // This avoids constructor parameter mismatches
          authStateProvider.overrideWith((ref) {
            final mockNotifier = MockAuthNotifier();
            // Setup mock behavior if needed
            when(mockNotifier.state).thenReturn(const AuthState());
            return mockNotifier;
          }),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets(
      'RouterRefreshNotifier uses same Ref instance as redirect function',
      (tester) async {
        // Track the Ref instances used
        final refInstances = <int>{};
        var refreshNotifierRef = 0;
        var routerProviderRef = 0;

        // Custom router provider to capture Ref instance
        final testRouterProvider = Provider<TestRouterInfo>((ref) {
          routerProviderRef = ref.hashCode;
          refInstances.add(ref.hashCode);

          // Create a test router refresh notifier to capture its Ref
          final refreshNotifier = TestRouterRefreshNotifier(ref, (refHash) {
            refreshNotifierRef = refHash;
            refInstances.add(refHash);
          });

          return TestRouterInfo(
            refreshNotifier: refreshNotifier,
            authState: ref.read(authStateProvider),
          );
        });

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: Consumer(
              builder: (context, ref, child) {
                final routerInfo = ref.watch(testRouterProvider);
                return MaterialApp(
                  home: Scaffold(
                    body: Text(
                      'Ref instances: $refInstances\n'
                      'RouterProvider Ref: $routerProviderRef\n'
                      'RefreshNotifier Ref: $refreshNotifierRef\n'
                      'Auth state: ${routerInfo.authState.isAuthenticated}',
                    ),
                  ),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // CRITICAL TEST: Both should use the same Ref instance
        expect(
          refreshNotifierRef,
          equals(routerProviderRef),
          reason:
              'RouterRefreshNotifier and router provider must use the same Ref instance',
        );

        // Should only have one unique Ref instance
        expect(
          refInstances.length,
          equals(1),
          reason:
              'There should be only one Ref instance used across all router components',
        );
      },
    );

    testWidgets(
      'Auth state changes trigger router refresh with consistent provider scope',
      (tester) async {
        var refreshCount = 0;
        late TestRouterRefreshNotifier refreshNotifier;

        final testRouterProvider = Provider<TestRouterRefreshNotifier>((ref) {
          refreshNotifier = TestRouterRefreshNotifier(ref, (_) {});
          refreshNotifier.addListener(() {
            refreshCount++;
          });
          return refreshNotifier;
        });

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: Consumer(
              builder: (context, ref, child) {
                ref.watch(testRouterProvider);
                final authState = ref.watch(authStateProvider);
                return MaterialApp(
                  home: Scaffold(
                    body: Column(
                      children: [
                        Text('Refresh count: $refreshCount'),
                        Text('Auth state: ${authState.isAuthenticated}'),
                        ElevatedButton(
                          onPressed: () {
                            // Simulate login
                            ref
                                .read(authStateProvider.notifier)
                                .login(
                                  User(
                                    id: 'test-user-id',
                                    email: 'test@example.com',
                                    name: 'Test User',
                                    createdAt: DateTime.now(),
                                    updatedAt: DateTime.now(),
                                  ),
                                );
                          },
                          child: const Text('Login'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Initial state - no refreshes yet
        expect(refreshCount, equals(0));

        // Trigger login
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Allow microtasks to complete
        await tester.binding.delayed(const Duration(milliseconds: 10));
        await tester.pumpAndSettle();

        // CRITICAL TEST: Router refresh should have been triggered
        expect(
          refreshCount,
          greaterThan(0),
          reason: 'Router refresh should be triggered when auth state changes',
        );

        // Verify auth state is updated
        final authState = container.read(authStateProvider);
        expect(authState.isAuthenticated, isTrue);
        expect(authState.user?.id, equals('test-user-id'));
        expect(authState.user?.familyId, equals('test-family-id'));
      },
    );

    testWidgets('Router redirect reads same auth state as refresh notifier', (
      tester,
    ) async {
      late AuthState redirectAuthState;
      var redirectCallCount = 0;

      final testRouterProvider = Provider<TestRouterInfo>((ref) {
        final refreshNotifier = TestRouterRefreshNotifier(ref, (_) {
          // Capture auth state when refresh notifier is triggered
          ref.read(authStateProvider);
        });

        // Simulate what the redirect function does
        final mockRedirectFunction = () {
          redirectCallCount++;
          redirectAuthState = ref.read(authStateProvider);
          return redirectAuthState.isAuthenticated ? '/dashboard' : '/login';
        };

        return TestRouterInfo(
          refreshNotifier: refreshNotifier,
          authState: ref.read(authStateProvider),
          mockRedirect: mockRedirectFunction,
        );
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (context, ref, child) {
              final routerInfo = ref.watch(testRouterProvider);
              final authState = ref.watch(authStateProvider);
              return MaterialApp(
                home: Scaffold(
                  body: Column(
                    children: [
                      Text('Redirect calls: $redirectCallCount'),
                      Text('Auth authenticated: ${authState.isAuthenticated}'),
                      ElevatedButton(
                        onPressed: () {
                          // Trigger login and then simulate redirect
                          ref
                              .read(authStateProvider.notifier)
                              .login(
                                User(
                                  id: 'consistency-test-user',
                                  email: 'test@consistency.com',
                                  name: 'Consistency Test User',
                                  createdAt: DateTime.now(),
                                  updatedAt: DateTime.now(),
                                ),
                              );

                          // Simulate router refresh and redirect call
                          Future.microtask(() {
                            if (routerInfo.mockRedirect != null) {
                              routerInfo.mockRedirect!();
                            }
                          });
                        },
                        child: const Text('Login and Redirect'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Trigger the test
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Allow microtasks to complete
      await tester.binding.delayed(const Duration(milliseconds: 20));
      await tester.pumpAndSettle();

      // CRITICAL TEST: Both should read the same auth state
      expect(
        redirectCallCount,
        greaterThan(0),
        reason: 'Redirect function should have been called',
      );

      if (redirectCallCount > 0) {
        expect(
          redirectAuthState.isAuthenticated,
          isTrue,
          reason: 'Redirect function should read authenticated state',
        );
        expect(
          redirectAuthState.user?.id,
          equals('consistency-test-user'),
          reason: 'Redirect function should read the correct user',
        );
        expect(
          redirectAuthState.user?.familyId,
          equals('consistency-family-id'),
          reason: 'Redirect function should read the correct family ID',
        );
      }
    });
  });
}

/// Test implementation of RouterRefreshNotifier for testing
class TestRouterRefreshNotifier extends ChangeNotifier {
  final Ref _ref;
  final Function(int) _onRefConstruction;
  late final ProviderSubscription<AuthState> _subscription;

  TestRouterRefreshNotifier(this._ref, this._onRefConstruction) {
    _onRefConstruction(_ref.hashCode);

    _subscription = _ref.listen(authStateProvider, (previous, next) {
      if ((previous?.isAuthenticated ?? false) != next.isAuthenticated ||
          (previous?.user?.id != next.user?.id) ||
          (previous?.user?.familyId != next.user?.familyId)) {
        // FIXED: Immediate synchronous refresh - no microtask delay needed
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

/// Test data structure to hold router components
class TestRouterInfo {
  final TestRouterRefreshNotifier refreshNotifier;
  final AuthState authState;
  final String Function()? mockRedirect;

  TestRouterInfo({
    required this.refreshNotifier,
    required this.authState,
    this.mockRedirect,
  });
}
