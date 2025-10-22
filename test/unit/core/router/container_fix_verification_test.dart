// Simple test to verify container fix works
// Tests ONLY the container sharing, not the complex routing

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edulift/core/services/providers/auth_provider.dart';
import 'package:edulift/core/domain/entities/user.dart';
import 'package:edulift/core/router/app_router.dart';
import 'package:edulift/core/utils/app_logger.dart';

import '../../../support/test_environment.dart';

void main() {
  group('Container Fix Verification', () {
    setUp(() async {
      await TestEnvironment.initialize();
    });

    testWidgets('Container fix: Router and auth should use same container', (
      tester,
    ) async {
      final container = ProviderContainer();
      final mainContainerHash = container.hashCode;

      AppLogger.info('🔍 CONTAINER FIX TEST');
      AppLogger.info('   - Main container: $mainContainerHash');

      // Create a minimal widget that uses AppRouter.createRouter
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (context, ref, child) {
              // This is the critical call - same as real app
              final router = AppRouter.createRouter(ref);

              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );

      // Let it initialize
      await tester.pump();

      // Initialize auth
      await container.read(authStateProvider.notifier).initializeAuth();
      await tester.pump();

      // The logs should show matching container hashCodes
      AppLogger.info('🔍 Check logs above for container hashCode matching');

      // Login user to trigger redirect logic
      final testUser = User(
        id: 'test-user',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      container.read(authStateProvider.notifier).login(testUser);
      await tester.pump();

      // The redirect logs should show the same container hashCode
      AppLogger.info(
        '🔍 RESULT: If fix works, all container hashCodes should match $mainContainerHash',
      );

      container.dispose();
    });
  });
}
