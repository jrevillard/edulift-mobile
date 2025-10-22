// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import 'package:edulift/core/services/providers/auth_provider.dart';
import 'package:edulift/core/domain/entities/user.dart';
import '../../../support/test_environment.dart';

/// Debug test to see if our router refresh notifier is actually being triggered
void main() {
  group('Router Refresh Debug', () {
    setUp(() async {
      await TestEnvironment.initialize();
    });

    test(
      'CRITICAL: Auth state select should trigger when authentication changes',
      () {
        final container = ProviderContainer();

        // Track if the listener is called
        var listenerCalled = false;
        var previousValue = false;
        var nextValue = false;

        // Set up the EXACT same listener as our _RouterRefreshNotifier
        final subscription = container.listen(
          authStateProvider.select((state) => state.isAuthenticated),
          (previous, next) {
            print('🔔 Listener called: $previous -> $next');
            listenerCalled = true;
            previousValue = previous ?? false;
            nextValue = next;
          },
        );

        // Initial state should be unauthenticated
        expect(container.read(authStateProvider).isAuthenticated, isFalse);
        expect(listenerCalled, isFalse);

        // Change auth state to authenticated
        final testUser = User(
          id: 'test-user',
          email: 'test@example.com',
          name: 'Test User',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        container.read(authStateProvider.notifier).login(testUser);

        // Verify auth state changed
        expect(container.read(authStateProvider).isAuthenticated, isTrue);

        // CRITICAL: Our listener should have been called
        expect(
          listenerCalled,
          isTrue,
          reason: 'Listener should be called when authentication state changes',
        );
        expect(previousValue, isFalse);
        expect(nextValue, isTrue);

        subscription.close();
        container.dispose();
      },
    );

    test('CRITICAL: ChangeNotifier should notify listeners when triggered', () {
      // Test the basic ChangeNotifier mechanism
      final notifier = ChangeNotifier();
      var notified = false;

      notifier.addListener(() {
        notified = true;
      });

      expect(notified, isFalse);

      notifier.notifyListeners();

      expect(
        notified,
        isTrue,
        reason:
            'ChangeNotifier should notify listeners when notifyListeners is called',
      );

      notifier.dispose();
    });
  });
}
