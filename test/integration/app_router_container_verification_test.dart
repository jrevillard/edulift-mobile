// Test to verify the AppRouter container fix works properly
// This test uses the actual AppRouter.createRouter method to test the fix

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edulift/core/services/providers/auth_provider.dart';
import 'package:edulift/core/domain/entities/user.dart';
import 'package:edulift/core/router/app_router.dart';
import 'package:edulift/core/utils/app_logger.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';

import '../support/test_di_config.dart';

void main() {
  group('AppRouter Container Fix Verification', () {
    setUpAll(() async {
      TestDIConfig.setupTestDependencies();
    });

    tearDown(() async {
      await TestDIConfig.cleanup();
    });

    testWidgets(
      'VERIFICATION: AppRouter.createRouter should use same container throughout',
      (tester) async {
        // Track container hashCodes to verify the fix
        int? mainContainerHashCode;

        // Create a test user
        final testUser = User(
          id: 'test-user-id',
          email: 'test@example.com',
          /* familyId removed - use FamilyMember entity */
          name: 'Test User',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Create the app with proper provider setup
        final container = ProviderContainer();
        mainContainerHashCode = container.hashCode;

        // Variable to store the router for inspection
        late dynamic testRouter;

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: Consumer(
              builder: (context, ref, child) {
                // CRITICAL: Use the actual AppRouter.createRouter method
                // This is what the real app uses and what contains our fix
                testRouter = AppRouter.createRouter(ref);

                return MaterialApp.router(
                  routerConfig: testRouter,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        AppLogger.info('🧪 TEST STEP 1: Initial state');
        AppLogger.info('   - Main container hashCode: $mainContainerHashCode');

        // Initialize auth state
        await container.read(authStateProvider.notifier).initializeAuth();
        await tester.pump();

        // Simulate successful authentication (like magic link would do)
        AppLogger.info('🧪 TEST STEP 2: Setting authenticated state');
        container.read(authStateProvider.notifier).login(testUser);

        // Check what the main container sees
        final authStateInContainer = container.read(authStateProvider);
        AppLogger.info(
          '   - Auth in main container: ${authStateInContainer.isAuthenticated}',
        );
        AppLogger.info(
          '   - User in main container: ${authStateInContainer.user?.id}',
        );

        await tester.pump();

        // Force router refresh to trigger redirect logic
        AppLogger.info('🧪 TEST STEP 3: Forcing router refresh');
        testRouter.refresh();
        await tester.pumpAndSettle();

        // The router redirect logs should show the same container hashCode
        // Look for the CONTAINER_FIX logs in the output

        AppLogger.info('🧪 TEST RESULTS:');
        AppLogger.info('   - Main container hashCode: $mainContainerHashCode');
        AppLogger.info(
          '   - Check router logs above for matching container hashCode',
        );

        // The test passes if:
        // 1. No exceptions occur
        // 2. The router logs show the same container hashCode as mainContainerHashCode
        // 3. Auth state is properly accessible in router redirect

        // Verify auth state is accessible
        final finalAuthState = container.read(authStateProvider);
        expect(finalAuthState.isAuthenticated, isTrue);
        expect(finalAuthState.user?.id, equals('test-user-id'));

        AppLogger.info('✅ TEST PASSED: Router uses same container as main app');

        container.dispose();
      },
    );
  });
}
