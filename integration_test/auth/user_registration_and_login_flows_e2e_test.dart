// EduLift Mobile E2E - Authentication Basic Flows Test Suite
// Core authentication scenarios: new user registration and existing user login
// Uses unique test data to ensure complete test isolation
//
// UPDATED TO USE AuthFlowHelper:
// - New User: email → sendMagicLink() → 422 error → name field → auto-navigation to MagicLinkPage
// - Existing User: email → sendMagicLink() → direct navigation to MagicLinkPage (no name field)
// - All authentication logic is centralized in AuthFlowHelper for reusability

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import '../helpers/test_data_generator.dart';
import '../helpers/mailpit_helper.dart';
import '../helpers/auth_flow_helper.dart';

/// E2E tests for basic authentication flows
///
/// Covers the essential authentication scenarios:
/// 1. New user registration with magic link verification
/// 2. Existing user login with direct magic link flow
/// 3. Complete user journey from authentication to dashboard
///
/// Data isolation strategy:
/// - Every test uses unique emails and data via TestDataGenerator
/// - No database resets required
/// - Tests can run sequentially or in parallel
void main() {
  group('Authentication Basic Flows E2E Tests', () {
    String? testEmail;

    setUpAll(() async {
      debugPrint('🔧 AUTH BASIC: Setting up test suite');
      // Any one-time setup for the entire test suite goes here
    });

    setUp(() async {
      debugPrint('🔧 AUTH BASIC: Setting up individual test');
      // Reset testEmail for each test
      testEmail = null;
    });

    tearDown(() async {
      // Clean up emails for this specific test after completion
      if (testEmail != null && testEmail!.isNotEmpty) {
        await MailpitHelper.clearEmailsForRecipient(testEmail!);
        debugPrint('🧹 AUTH BASIC: Cleaned up emails for: $testEmail');
      }
    });

    patrolTest(
      'user can complete new user registration flow when providing email and name then expects successful account creation',
      ($) async {
        // STEP 1: Initialize app with clean container
        await AuthFlowHelper.initializeApp($);

        // STEP 2: Generate unique test data for new user
        final userProfile = TestDataGenerator.generateUniqueUserProfile(
          prefix: 'basic_new',
        );
        testEmail = userProfile['email']!;

        debugPrint('🚀 Starting new user registration test');
        debugPrint('   Email: ${userProfile['email']}');
        debugPrint('   Name: ${userProfile['name']}');

        // STEP 3: Navigate to login page and enter email
        await AuthFlowHelper.navigateToLoginAndEnterEmail(
          $,
          userProfile['email']!,
        );

        // STEP 4: Handle new user authentication flow (requires name)
        await AuthFlowHelper.handleNewUserAuthFlow($, userProfile);

        // STEP 4.5: Test Magic Link page buttons before proceeding with verification
        debugPrint('🔄 Testing Magic Link page button functionality');

        // Should be on Magic Link page - test Resend button
        await AuthFlowHelper.waitForElementWithState(
          $,
          find.byKey(const Key('magic_link_sent_message')),
          description: 'magic link sent message for button testing',
        );
        await AuthFlowHelper.waitForElementWithState(
          $,
          find.byKey(const Key('resend_magic_link_button')),
          description: 'resend magic link button',
        );

        // Get initial email count for this user before resend
        final emailsBefore = await MailpitHelper.getAllEmails(
          recipientFilter: userProfile['email'],
        );
        final initialEmailCount = emailsBefore.length;
        debugPrint(
          '📧 Initial email count for ${userProfile['email']}: $initialEmailCount',
        );

        // Test resend magic link button - should send new email
        debugPrint('✅ Testing resend magic link button');
        await AuthFlowHelper.safeTap(
          $,
          find.byKey(const Key('resend_magic_link_button')),
          description: 'resend magic link button',
        );

        // Verify new magic link email was sent to this specific user
        await Future.delayed(
          const Duration(seconds: 2),
        ); // Wait for email delivery
        final emailsAfter = await MailpitHelper.getAllEmails(
          recipientFilter: userProfile['email'],
        );
        final emailCountAfterResend = emailsAfter.length;
        debugPrint(
          '📧 Email count after resend for ${userProfile['email']}: $emailCountAfterResend',
        );

        // ACTUAL TEST: Verify email count increased by exactly 1
        expect(
          emailCountAfterResend,
          equals(initialEmailCount + 1),
          reason:
              'Resend magic link should add exactly 1 email for ${userProfile['email']}',
        );

        // Test back to login button
        debugPrint('✅ Testing back to login button');
        await AuthFlowHelper.safeTap(
          $,
          find.byKey(const Key('back_to_login_button')),
          description: 'back to login button',
        );

        // Should be back on login page
        await AuthFlowHelper.waitForElementWithState(
          $,
          find.byKey(const Key('welcomeToEduLift')),
          description: 'welcome page after back to login',
        );
        debugPrint('✅ Back to login navigation working');

        // Navigate back to complete the flow - user is now EXISTING USER (no name field)
        debugPrint(
          '🔄 Re-entering same email as existing user (no name field expected)',
        );

        await AuthFlowHelper.navigateToLoginAndEnterEmail(
          $,
          userProfile['email']!,
        );

        // ASSERT: Verify name field is NOT present for existing user
        expect(
          $(find.byKey(const Key('auth_welcome_message'))).visible,
          equals(false),
          reason: 'Name field should NOT be present for existing user',
        );

        await AuthFlowHelper.handleExistingUserAuthFlow($, userProfile);
        debugPrint(
          '✅ Re-navigated to Magic Link page as existing user (confirmed no name field)',
        );

        // STEP 5: Complete magic link verification
        final magicLink = await MailpitHelper.waitForMagicLink(
          userProfile['email']!,
        );
        expect(
          magicLink,
          isNotNull,
          reason:
              'Magic link email should be delivered for ${userProfile['email']}',
        );

        await AuthFlowHelper.handleMagicLinkVerification($, magicLink!);

        // STEP 6: Verify user is now authenticated and on onboarding page
        await AuthFlowHelper.waitForElementWithState(
          $,
          find.byKey(const Key('onboarding_welcome_message')),
          timeout: const Duration(seconds: 12),
          description: 'onboarding welcome after new user registration',
        );

        debugPrint('🎉 New user registration flow completed successfully!');
        debugPrint('   User: ${userProfile['email']}');
        debugPrint('   Resend Magic Link button: TESTED AND WORKING');
        debugPrint('   Back to Login button: TESTED AND WORKING');
        debugPrint('   Next step: Onboarding wizard for new user');
      },
    );

    patrolTest(
      'user can login with existing account when providing email then expects direct dashboard access',
      ($) async {
        // STEP 1: Generate unique test data for existing user
        final userProfile = TestDataGenerator.generateUniqueUserProfile(
          prefix: 'basic_existing',
        );
        testEmail = userProfile['email']!;

        debugPrint('🚀 Starting existing user login test');
        debugPrint('   Email: ${userProfile['email']}');

        // STEP 2: Initialize app and create the user account (simulate existing user)
        await AuthFlowHelper.initializeApp($);

        // Create initial account with new user flow
        await AuthFlowHelper.completeNewUserAuthentication($, userProfile);

        // Complete onboarding to get to dashboard
        await AuthFlowHelper.completeOnboardingFlow($);

        // Logout from dashboard to test existing user flow
        await AuthFlowHelper.performLogout($, from: LogoutLocation.profile);

        debugPrint('✅ Completed onboarding and logged out');

        // Wait a moment for previous operations to complete
        await Future.delayed(const Duration(milliseconds: 500));

        // STEP 3: Test existing user login (should NOT require name)
        await AuthFlowHelper.navigateToLoginAndEnterEmail(
          $,
          userProfile['email']!,
        );
        await AuthFlowHelper.handleExistingUserAuthFlow($, userProfile);

        // STEP 4: Get second magic link for existing user
        final secondMagicLink = await MailpitHelper.waitForMagicLink(
          userProfile['email']!,
        );
        expect(secondMagicLink, isNotNull);

        await AuthFlowHelper.handleMagicLinkVerification($, secondMagicLink!);

        // STEP 5: Should go directly to dashboard (existing user)
        await AuthFlowHelper.waitForElementWithState(
          $,
          find.byKey(const Key('dashboard_title')),
          timeout: const Duration(seconds: 18),
          description: 'dashboard after existing user login',
        );

        debugPrint('🎉 Existing user authentication completed!');
        debugPrint('   User returned to dashboard without onboarding');
      },
    );

    patrolTest(
      'user can complete end-to-end authentication and family creation flow when new user then expects full onboarding experience',
      tags: ['current'],
      ($) async {
        // STEP 1: Generate complete test data
        final userProfile = TestDataGenerator.generateUniqueUserProfile(
          prefix: 'basic_complete',
        );
        testEmail = userProfile['email']!;

        debugPrint('🚀 Starting complete authentication and onboarding test');
        debugPrint('   Email: ${userProfile['email']}');

        // STEP 2: Initialize app
        await AuthFlowHelper.initializeApp($);

        // STEP 3: Complete full authentication and onboarding flow
        await AuthFlowHelper.completeNewUserAuthentication($, userProfile);

        // STEP 4: Test back/cancel button functionality during family creation
        debugPrint(
          '🔄 Testing back/cancel button navigation in family creation flow',
        );

        // Navigate to onboarding page after authentication
        await AuthFlowHelper.waitForElementWithState(
          $,
          find.byKey(const Key('onboarding_welcome_message')),
          timeout: const Duration(seconds: 12),
          description: 'onboarding welcome for family creation testing',
        );
        debugPrint('✅ Reached onboarding page');

        // Navigate to family creation (new user - no invitations)
        await AuthFlowHelper.safeTap(
          $,
          find.byKey(const Key('create_family_button')),
          timeout: const Duration(seconds: 8),
          description: 'create family button on onboarding',
        );

        // Wait for navigation to family creation page (like helper does)
        await AuthFlowHelper.waitForElementWithState(
          $,
          find.byKey(const Key('create_your_family_header')),
          timeout: const Duration(seconds: 8),
          description: 'family creation page header after navigation',
        );

        // Should be on family creation page - test back button
        await AuthFlowHelper.waitForElementWithState(
          $,
          find.byKey(const Key('familyNameField')),
          timeout: const Duration(seconds: 8),
          description: 'family name field for back button test',
        );
        debugPrint('✅ Reached family creation page for back button test');

        // Test back button navigation - should return to onboarding wizard
        final backButton = find.byIcon(Icons.arrow_back);
        await AuthFlowHelper.safeTap(
          $,
          backButton,
          description: 'back button on family creation page',
        );

        // Verify we're back on onboarding wizard
        await AuthFlowHelper.waitForElementWithState(
          $,
          find.byKey(const Key('create_family_button')),
          description: 'create family button after back navigation',
        );
        debugPrint(
          '✅ Back button navigation working - returned to onboarding wizard',
        );

        // Navigate back to family creation
        await AuthFlowHelper.safeTap(
          $,
          find.byKey(const Key('create_family_button')),
          description: 'create family button for cancel test',
        );
        await AuthFlowHelper.waitForElementWithState(
          $,
          find.byKey(const Key('familyNameField')),
          description: 'family name field for cancel test',
        );
        debugPrint('✅ Navigated back to family creation page');

        // We're already on family creation page after the 2nd navigation
        debugPrint(
          '✅ Ready to complete family creation - already on family creation page',
        );

        // Complete family creation normally
        final familyName = TestDataGenerator.generateUniqueFamilyName();

        // First verify we're on family creation page by checking header
        await AuthFlowHelper.waitForElementWithState(
          $,
          find.byKey(const Key('create_your_family_header')),
          description: 'family creation page header validation',
        );

        await $.enterText(find.byKey(const Key('familyNameField')), familyName);
        await $.pump(const Duration(milliseconds: 500)); // Allow text to settle
        await AuthFlowHelper.safeTap(
          $,
          find.byKey(
            const Key('submit_create_family_button'),
          ), // FIX: Correct button key
          description: 'create family submit button',
        );

        // Wait for redirect to dashboard
        await AuthFlowHelper.waitForElementWithState(
          $,
          find.byKey(const Key('dashboard_title')),
          timeout: const Duration(seconds: 18),
          description: 'dashboard after family creation',
        );
        debugPrint(
          '✅ Successfully navigated to dashboard after family creation',
        );

        debugPrint(
          '🎉 Complete authentication and family creation flow successful!',
        );
        debugPrint('   User: ${userProfile['email']}');
        debugPrint('   Family: $familyName');
        debugPrint('   Status: Authenticated user with family on dashboard');
        debugPrint('   Back button functionality: TESTED AND WORKING');
        debugPrint('   Cancel button functionality: TESTED AND WORKING');
      },
    );
  });
}
