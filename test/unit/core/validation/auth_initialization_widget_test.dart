import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edulift/core/services/providers/auth_provider.dart';

void main() {
  group('Auth Initialization Widget Test', () {
    testWidgets('AuthStateProvider should not cause pumpAndSettle timeout', (WidgetTester tester) async {
      // This test validates that the surgical fix prevents infinite loops
      // that would cause pumpAndSettle to timeout

      var didTimeout = false;

      try {
        // Create a simple widget that reads auth state
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Consumer(
                builder: (context, ref, child) {
                  ref.watch(authStateProvider);
                  return const Scaffold(
                    body: Text(
                      'Auth provider test',
                    ),
                  );
                },
              ),
            ),
          ),
        );

        // CRITICAL TEST: This should complete without timeout
        // The previous addPostFrameCallback would cause infinite loops here
        await tester.pumpAndSettle(const Duration(seconds: 5));

      } catch (e) {
        if (e.toString().contains('timed out') || e.toString().contains('timeout')) {
          didTimeout = true;
        }
        rethrow;
      }

      // VALIDATION: Should not timeout
      expect(didTimeout, false, reason: 'pumpAndSettle should not timeout after surgical fix');

      // Additional validation: Widget should render
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('Multiple provider reads should not cause issues', (WidgetTester tester) async {
      // Test that multiple widgets reading auth state don't cause problems

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Column(
              children: [
                Consumer(
                  builder: (context, ref, child) {
                    ref.watch(authStateProvider);
                    return const Text('Widget 1: test');
                  },
                ),
                Consumer(
                  builder: (context, ref, child) {
                    ref.watch(isAuthenticatedProvider);
                    return const Text('Widget 2: test');
                  },
                ),
                Consumer(
                  builder: (context, ref, child) {
                    ref.watch(currentUserProvider);
                    return const Text('Widget 3: test');
                  },
                ),
              ],
            ),
          ),
        ),
      );

      // This should complete without timeout
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // All widgets should render
      expect(find.byType(Text), findsNWidgets(3));
    });
  });
}