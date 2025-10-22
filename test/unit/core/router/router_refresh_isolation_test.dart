@Skip('Obsolete: Tests router refresh based on User.familyId which no longer exists. Architecture changed to use FamilyRepository.getCurrentFamily(). Needs rewrite.')
library;

// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:edulift/core/services/providers/auth_provider.dart';
import 'package:edulift/core/domain/entities/user.dart';
import 'package:edulift/core/router/app_router.dart';
import '../../../support/test_environment.dart';

/// Test to verify router refresh mechanism works with auth state changes
void main() {
  group('Router Refresh Isolation Test', () {
    setUp(() async {
      await TestEnvironment.initialize();
    });

    testWidgets('CRITICAL: AppRouterProvider should work with auth state changes', (
      tester,
    ) async {
      // Test the actual provider that the app uses
      final container = ProviderContainer();

      // CRITICAL FIX: Create router with same method as main app to test provider container fix
      // This simulates creating a router with a WidgetRef like in EduLiftApp
      late final GoRouter router;

      // We need to simulate the widget context, so create a minimal test
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (context, ref, child) {
              router = AppRouter.createRouter(ref);
              return Container(); // Minimal widget
            },
          ),
        ),
      );

      expect(router, isNotNull);

      // Verify initial auth state
      final initialAuthState = container.read(authStateProvider);
      expect(initialAuthState.isAuthenticated, isFalse);
      print(
        '🔍 Initial auth state: authenticated=${initialAuthState.isAuthenticated}',
      );

      // Change auth state - this should trigger router refresh
      final testUser = User(
        id: 'test-user',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print('🔄 About to login user...');
      container.read(authStateProvider.notifier).login(testUser);
      print('✅ User login completed');

      // Verify auth state changed
      final newAuthState = container.read(authStateProvider);
      expect(newAuthState.isAuthenticated, isTrue);
      expect(newAuthState.user?.id, equals('test-user'));
      expect(newAuthState.user?.familyId, equals('test-family'));
      print(
        '🔍 New auth state: authenticated=${newAuthState.isAuthenticated}, familyId=${newAuthState.user?.familyId}',
      );

      // Verify router can be used with new auth state
      expect(router.routerDelegate, isNotNull);
      print('🎯 Router should handle auth state properly');

      container.dispose();
    });

    test('CRITICAL: Auth state changes should be immediate', () {
      final container = ProviderContainer();

      // Track auth state changes
      AuthState? previousState;
      AuthState? currentState;

      container.listen(authStateProvider, (previous, next) {
        previousState = previous;
        currentState = next;
        print(
          '🔔 Auth state changed: ${previous?.isAuthenticated} -> ${next.isAuthenticated}',
        );
      });

      // Verify initial state
      final initialState = container.read(authStateProvider);
      expect(initialState.isAuthenticated, isFalse);

      // Login user
      final testUser = User(
        id: 'test-user',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      container.read(authStateProvider.notifier).login(testUser);

      // Verify state changed immediately
      expect(currentState, isNotNull);
      expect(previousState?.isAuthenticated, isFalse);
      expect(currentState?.isAuthenticated, isTrue);
      expect(currentState?.user?.familyId, equals('test-family'));

      container.dispose();
    });
  });
}
