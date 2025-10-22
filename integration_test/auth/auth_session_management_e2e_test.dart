// EduLift Mobile E2E - Authentication Session Management Test Suite
// Focused session handling tests with deterministic flows and integrated button testing
// Tests core session scenarios: persistence, logout flows, and button interactions
//
// OPTIMIZED FOR DETERMINISTIC TESTING:
// - Removed ALL conditional branching logic
// - Integrated button testing within existing flows
// - Uses keys for element finding, never text
// - Follows navigationStateProvider pattern
// - Reduced complexity while maintaining comprehensive coverage

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import '../helpers/test_data_generator.dart';
import '../helpers/mailpit_helper.dart';
import '../helpers/auth_flow_helper.dart';

/// E2E tests for authentication session management
///
/// Optimized test coverage:
/// 1. Session persistence across app restarts with verification
/// 2. Dashboard logout with integrated button testing and re-authentication
/// 3. Onboarding logout with cancel button testing and state verification
///
/// Testing philosophy:
/// - Deterministic flows only - no conditional branching
/// - Button testing integrated within functional flows
/// - Use keys for all element identification
/// - Follow established patterns from user registration tests
void main() {
  group('Authentication Session Management E2E Tests', () {
    String? testEmail;

    setUpAll(() async {
      debugPrint('🔧 AUTH SESSION: Setting up test suite');
    });

    setUp(() async {
      debugPrint('🔧 AUTH SESSION: Setting up individual test');
      testEmail = null;
    });

    tearDown(() async {
      if (testEmail != null && testEmail!.isNotEmpty) {
        await MailpitHelper.clearEmailsForRecipient(testEmail!);
        debugPrint('🧹 AUTH SESSION: Cleaned up emails for: $testEmail');
      }
    });

    patrolTest(
      'user session persists when app is restarted and user returns to dashboard then expects authenticated state',
      tags: ['current'],
      ($) async {
        // STEP 1: Generate unique test data and complete full authentication flow
        final userProfile = TestDataGenerator.generateUniqueUserProfile(
          prefix: 'session_persist',
        );
        testEmail = userProfile['email']!;

        debugPrint('🚀 Starting session persistence test');
        debugPrint('   Email: ${userProfile['email']}');

        // STEP 2: Complete full authentication and onboarding to dashboard
        await AuthFlowHelper.initializeApp($);
        await AuthFlowHelper.completeNewUserAuthentication($, userProfile);
        final familyName = await AuthFlowHelper.completeOnboardingFlow($);

        debugPrint(
          '✅ User authenticated and onboarded with family: $familyName',
        );

        // STEP 3: Simulate app restart by reinitializing (skip login page check for persistence)
        debugPrint('🔄 Simulating app restart for session persistence test...');
        await AuthFlowHelper.initializeApp($, expectLoginPage: false);

        // STEP 4: Verify session persisted - user should be on dashboard
        await AuthFlowHelper.waitForElementWithState(
          $,
          find.byKey(const Key('dashboard_title')),
          timeout: const Duration(seconds: 12),
          description: 'dashboard after session persistence',
        );
        debugPrint('✅ Session persisted - user returned to dashboard');

        // STEP 5: Verify complete session restoration by checking navigation
        await AuthFlowHelper.waitForElementWithState(
          $,
          find.byKey(const Key('navigation_family')),
          description: 'family navigation after session persistence',
        );
        debugPrint('✅ Family navigation confirmed - session fully restored');

        debugPrint('🎉 Session persistence test completed successfully!');
        debugPrint('   User session verified across app restart');
      },
    );

    patrolTest(
      'user can logout from dashboard when authenticated with button testing then expects clean session termination',
      ($) async {
        // STEP 1: Generate unique test data and complete authentication to dashboard
        final userProfile = TestDataGenerator.generateUniqueUserProfile(
          prefix: 'session_logout_dash',
        );
        testEmail = userProfile['email']!;

        debugPrint('🚀 Starting dashboard logout with button testing');
        debugPrint('   Email: ${userProfile['email']}');

        await AuthFlowHelper.initializeApp($);
        await AuthFlowHelper.completeNewUserAuthentication($, userProfile);
        await AuthFlowHelper.completeOnboardingFlow($);

        debugPrint('✅ User authenticated and on dashboard');

        // STEP 2: Test dashboard logout with integrated button testing
        await AuthFlowHelper.performLogout($, from: LogoutLocation.profile);
        debugPrint('✅ Dashboard logout with button testing completed');

        // STEP 3: Verify logout completed successfully
        await AuthFlowHelper.waitForElementWithState(
          $,
          find.byKey(const Key('welcomeToEduLift')),
          timeout: const Duration(seconds: 8),
          description: 'welcome page after dashboard logout',
        );
        debugPrint('✅ User returned to login page after logout');

        // STEP 4: Verify session clearing by requiring re-authentication
        await AuthFlowHelper.navigateToLoginAndEnterEmail(
          $,
          userProfile['email']!,
        );
        await AuthFlowHelper.handleExistingUserAuthFlow($, userProfile);

        // Should require new magic link verification after logout
        final magicLink = await MailpitHelper.waitForMagicLink(
          userProfile['email']!,
        );
        expect(
          magicLink,
          isNotNull,
          reason: 'Should require new magic link after logout',
        );

        await AuthFlowHelper.handleMagicLinkVerification($, magicLink!);

        // Should return to dashboard (existing user with family)
        await AuthFlowHelper.waitForElementWithState(
          $,
          find.byKey(const Key('dashboard_title')),
          timeout: const Duration(seconds: 12),
          description: 'dashboard after re-authentication',
        );

        debugPrint('🎉 Dashboard logout with button testing completed!');
        debugPrint('   Logout button functionality: TESTED AND WORKING');
        debugPrint(
          '   Clean session termination and re-authentication verified',
        );
      },
    );

    patrolTest(
      'user can logout from onboarding with cancel button testing then expects proper dialog handling',
      ($) async {
        // STEP 1: Generate unique test data and complete authentication to onboarding
        final userProfile = TestDataGenerator.generateUniqueUserProfile(
          prefix: 'session_logout_onboard',
        );
        testEmail = userProfile['email']!;

        debugPrint('🚀 Starting onboarding logout with cancel button testing');
        debugPrint('   Email: ${userProfile['email']}');

        await AuthFlowHelper.initializeApp($);
        await AuthFlowHelper.completeNewUserAuthentication($, userProfile);

        // Stop at onboarding page (don't complete family creation)
        await AuthFlowHelper.waitForElementWithState(
          $,
          find.byKey(const Key('onboarding_welcome_message')),
          timeout: const Duration(seconds: 12),
          description: 'onboarding welcome message',
        );
        debugPrint('✅ User authenticated and on onboarding page');

        // STEP 2: Test onboarding logout button presence and functionality
        debugPrint('🔄 Testing onboarding logout button functionality');

        await AuthFlowHelper.safeTap(
          $,
          find.byKey(const Key('onboarding_logout_button')),
          description: 'onboarding logout button',
        );

        // STEP 3: Test logout confirmation dialog and cancel button
        await AuthFlowHelper.waitForElementWithState(
          $,
          find.byKey(const Key('logout_confirmation_dialog')),
          timeout: const Duration(seconds: 5),
          description: 'logout confirmation dialog',
        );
        debugPrint('✅ Logout confirmation dialog appeared');

        // Test cancel button functionality
        debugPrint('🔄 Testing cancel button in logout confirmation dialog');
        await AuthFlowHelper.safeTap(
          $,
          find.byKey(const Key('logout_cancel_button')),
          description: 'logout cancel button',
        );
        debugPrint('✅ Cancel button functionality tested');

        // STEP 4: Verify user remained on onboarding after canceling logout
        await AuthFlowHelper.waitForElementWithState(
          $,
          find.byKey(const Key('onboarding_welcome_message')),
          timeout: const Duration(seconds: 5),
          description: 'onboarding welcome after cancel',
        );
        debugPrint('✅ User remained on onboarding page after canceling logout');

        // Verify user info is still displayed (authenticated state preserved)
        await AuthFlowHelper.waitForElementWithState(
          $,
          find.byKey(const Key('onboarding_user_info_card')),
          timeout: const Duration(seconds: 5),
          description: 'user info card after cancel',
        );
        debugPrint(
          '✅ User info card still visible - authenticated state preserved',
        );

        // STEP 5: Test actual logout after testing cancel functionality
        debugPrint('🔄 Testing actual logout flow after cancel button test');

        // Open logout dialog again
        await AuthFlowHelper.safeTap(
          $,
          find.byKey(const Key('onboarding_logout_button')),
          description: 'onboarding logout button (second time)',
        );

        await AuthFlowHelper.waitForElementWithState(
          $,
          find.byKey(const Key('logout_confirmation_dialog')),
          description: 'logout confirmation dialog (second time)',
        );

        // This time confirm the logout
        await AuthFlowHelper.safeTap(
          $,
          find.byKey(const Key('logout_confirm_button')),
          description: 'logout confirm button',
        );
        debugPrint('✅ Logout confirmed after testing cancel button');

        // STEP 6: Verify logout completed successfully
        await AuthFlowHelper.waitForElementWithState(
          $,
          find.byKey(const Key('welcomeToEduLift')),
          timeout: const Duration(seconds: 8),
          description: 'welcome page after onboarding logout',
        );

        debugPrint(
          '🎉 Onboarding logout with cancel button testing completed!',
        );
        debugPrint('   Onboarding logout button: TESTED AND WORKING');
        debugPrint('   Cancel button functionality: TESTED AND WORKING');
        debugPrint('   Logout confirmation: TESTED AND WORKING');
        debugPrint('   Session cleared from onboarding state');
      },
    );
  });
}
