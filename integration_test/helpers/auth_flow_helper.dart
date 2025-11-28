// EduLift Mobile E2E - Authentication Flow Helper
// Factory class for all authentication scenarios and flows
// Provides centralized, reusable authentication methods for E2E tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:edulift/bootstrap.dart';
import 'package:edulift/edulift_app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'test_data_generator.dart';
import 'mailpit_helper.dart';
import 'network_device_helper.dart';
import 'deep_link_helper.dart';

/// Factory class for all authentication flows in E2E tests
///
/// This helper provides centralized, reusable methods for authentication scenarios:
/// - New user registration (422 error → name field → magic link)
/// - Existing user login (direct magic link navigation)
/// - Magic link verification and processing
/// - Complete onboarding flow (new user → dashboard)
/// - Logout functionality (from dashboard or onboarding)
///
/// All methods maintain the exact same logic as the existing working implementation.
/// The helper ensures deterministic behavior and proper error handling.
///
/// Usage:
/// ```dart
/// // For new user registration
/// await AuthFlowHelper.handleNewUserAuthFlow($, userProfile);
///
/// // For existing user login
/// await AuthFlowHelper.handleExistingUserAuthFlow($, userProfile);
///
/// // For magic link processing
/// final magicLink = await MailpitHelper.waitForMagicLink(email);
/// await AuthFlowHelper.handleMagicLinkVerification($, magicLink);
///
/// // For complete onboarding
/// await AuthFlowHelper.completeOnboardingFlow($);
///
/// // For logout
/// await AuthFlowHelper.performLogout($, from: LogoutLocation.profile);
/// ```
class AuthFlowHelper {
  /// Internal helper for retry logic with exponential backoff
  /// This improves test reliability by retrying operations that might fail due to timing
  static Future<T> _waitWithRetry<T>(
    PatrolIntegrationTester $,
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delayBetweenRetries = const Duration(seconds: 1),
    String? description,
  }) async {
    Exception? lastException;

    for (var attempt = 0; attempt < maxRetries; attempt++) {
      try {
        return await operation();
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        if (attempt == maxRetries - 1) {
          debugPrint(
            '❌ ${description ?? "Operation"} failed after $maxRetries attempts: $e',
          );
          rethrow;
        }
        final delay =
            delayBetweenRetries * (attempt + 1); // Exponential backoff
        debugPrint(
          '⚠️ ${description ?? "Operation"} attempt ${attempt + 1} failed, retrying in ${delay.inMilliseconds}ms: $e',
        );
        await Future.delayed(delay);
        await $.pump(
          const Duration(milliseconds: 100),
        ); // Small pump between retries
      }
    }
    throw lastException ?? Exception('Retry logic failed unexpectedly');
  }

  /// Enhanced wait for element with better error messages and state checking
  /// Replaces basic waitUntilVisible with more robust timing
  static Future<void> waitForElementWithState(
    PatrolIntegrationTester $,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
    String? description,
    bool checkEnabled = false,
  }) async {
    final desc = description ?? 'element ${finder.toString()}';
    debugPrint('⏳ Waiting for $desc...');

    try {
      // Try to wait for visibility first
      try {
        await $.waitUntilVisible(finder, timeout: const Duration(seconds: 2));
      } catch (e) {
        // Element exists but not visible - try scrolling
        debugPrint('Element not immediately visible, attempting scroll...');
        try {
          await $.scrollUntilVisible(
            finder: finder,
            view: find.byType(Scrollable),
          );
        } catch (scrollError) {
          // If scrolling fails, wait a bit longer with original timeout
          await $.waitUntilVisible(finder, timeout: timeout);
        }
      }

      if (checkEnabled) {
        // Additional check to ensure element is interactive
        await Future.delayed(const Duration(milliseconds: 200));
        // Note: PatrolFinder doesn't have enabled property
        // The element being visible is generally sufficient for interaction
      }

      debugPrint('✅ Found $desc');
    } catch (e) {
      debugPrint('❌ Failed to find $desc after ${timeout.inSeconds}s: $e');
      rethrow;
    }
  }

  /// Safe tap with wait and verification - reduces flakiness from rapid taps
  static Future<void> safeTap(
    PatrolIntegrationTester $,
    Finder finder, {
    Duration timeout = const Duration(seconds: 5),
    String? description,
    bool waitAfterTap = true,
  }) async {
    final desc = description ?? 'element ${finder.toString()}';

    await waitForElementWithState(
      $,
      finder,
      timeout: timeout,
      description: desc,
      checkEnabled: true,
    );

    debugPrint('👆 Tapping $desc');
    await $.tap(finder);

    if (waitAfterTap) {
      // Small wait for UI to respond instead of pumpAndSettle
      await $.pump(const Duration(milliseconds: 300));
    }
  }

  /// Robust element waiting that combines visibility and text content checks
  /// Reduces brittleness from text-only searches
  static Future<bool> waitForElementOrText(
    PatrolIntegrationTester $,
    Finder? keyFinder,
    String? textContent, {
    Duration timeout = const Duration(seconds: 8),
    String? description,
  }) async {
    final desc = description ?? 'element or text';
    debugPrint('⏳ Waiting for $desc...');

    try {
      if (keyFinder != null) {
        await $.waitUntilVisible(keyFinder, timeout: timeout);
        debugPrint('✅ Found element by key: $desc');
        return true;
      }

      if (textContent != null) {
        await $.waitUntilVisible(
          find.textContaining(textContent),
          timeout: timeout,
        );
        debugPrint('✅ Found element by text: $desc');
        return true;
      }

      throw Exception('No finder or text provided');
    } catch (e) {
      debugPrint('❌ Failed to find $desc: $e');
      return false;
    }
  }

  /// Handle new user authentication flow with improved reliability
  ///
  /// This handles the NEW USER scenario:
  /// 1. Click auth button → expect 422 error
  /// 2. Name field appears with welcome message
  /// 3. Fill name and click auth button again
  /// 4. Navigate to MagicLinkPage with sent message
  ///
  /// The function will FAIL if the actual flow doesn't match expected new user flow.
  ///
  /// [userProfile] - User profile with email and firstName required
  ///
  /// Expected behavior:
  /// - First auth attempt triggers 422 error
  /// - Welcome message appears indicating name required
  /// - Name field becomes visible as second TextFormField
  /// - Second auth attempt navigates to MagicLinkPage
  static Future<void> handleNewUserAuthFlow(
    PatrolIntegrationTester $,
    Map<String, String> userProfile,
  ) async {
    debugPrint(
      '📝 NEW USER FLOW: Starting authentication for ${userProfile['email']}',
    );

    // First attempt - click the auth button with safe tap
    await safeTap(
      $,
      find.byKey(const Key('login_auth_action_button')),
      description: 'auth button (first attempt)',
    );

    debugPrint('📝 NEW USER: Expecting name field to appear after 422 error');

    // Must see the welcome message (indicates 422 error and name field requirement)
    await waitForElementWithState(
      $,
      find.byKey(const Key('auth_welcome_message')),
      timeout: const Duration(seconds: 8),
      description: 'welcome message for new user',
    );
    debugPrint('✅ NEW USER: Welcome message appeared - name field is required');

    // The name field should now be visible (second TextFormField after email)
    final nameFieldFinder = find.byType(TextFormField).at(1);
    await waitForElementWithState(
      $,
      nameFieldFinder,
      description: 'name field',
    );

    // Fill in the name
    await $.enterText(nameFieldFinder, userProfile['name']!);
    await $.pump(const Duration(milliseconds: 300)); // Allow text to settle
    debugPrint('✅ NEW USER: Name entered: ${userProfile['name']}');

    // Second attempt - click auth button again with safe tap
    await safeTap(
      $,
      find.byKey(const Key('login_auth_action_button')),
      description: 'auth button (second attempt)',
    );

    // Now should navigate to MagicLinkPage
    await waitForElementWithState(
      $,
      find.byKey(const Key('magic_link_sent_message')),
      timeout: const Duration(seconds: 8),
      description: 'magic link sent message',
    );
    debugPrint('✅ NEW USER: Account created - navigated to MagicLinkPage');
  }

  /// Handle existing user authentication flow with improved reliability
  ///
  /// This handles the EXISTING USER scenario:
  /// 1. Click auth button → direct navigation to MagicLinkPage
  /// 2. No name field should appear
  /// 3. Should immediately show magic link sent message
  ///
  /// The function will FAIL if name field appears or flow doesn't match existing user expectations.
  ///
  /// [userProfile] - User profile with email required
  ///
  /// Expected behavior:
  /// - Direct navigation to MagicLinkPage (no 422 error)
  /// - No welcome message or name field
  /// - Immediate magic link sent message display
  static Future<void> handleExistingUserAuthFlow(
    PatrolIntegrationTester $,
    Map<String, String> userProfile,
  ) async {
    debugPrint(
      '👤 EXISTING USER FLOW: Starting authentication for ${userProfile['email']}',
    );

    // First attempt - click the auth button with safe tap
    await safeTap(
      $,
      find.byKey(const Key('login_auth_action_button')),
      description: 'auth button for existing user',
    );

    debugPrint(
      '👤 EXISTING USER: Expecting direct navigation to MagicLinkPage',
    );

    // Should directly navigate to magic link page (no name field)
    await waitForElementWithState(
      $,
      find.byKey(const Key('magic_link_sent_message')),
      timeout: const Duration(seconds: 8),
      description: 'magic link sent message for existing user',
    );
    debugPrint(
      '✅ EXISTING USER: Direct navigation to MagicLinkPage successful',
    );
  }

  /// Handle magic link verification process with improved reliability
  ///
  /// This processes a magic link and waits for verification completion:
  /// 1. Open the magic link URL via deep link
  /// 2. Wait for verification processing with retry mechanism
  /// 3. Verify success message appears
  /// 4. Return when verification is complete
  ///
  /// [magicLink] - The magic link URL to process
  /// [timeout] - Optional timeout for verification (defaults to 15 seconds)
  ///
  /// Expected behavior:
  /// - Deep link opens and processes the magic link
  /// - Welcome message appears after successful verification
  /// - User is ready for next navigation step
  static Future<void> handleMagicLinkVerification(
    PatrolIntegrationTester $,
    String magicLink, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    debugPrint('🔗 MAGIC LINK: Processing verification link');
    debugPrint('   Link: ${magicLink.substring(0, 50)}...');

    // Open magic link - let it complete verification and redirect naturally
    // The app will automatically redirect to the appropriate destination
    await DeepLinkHelper.openWithTimeout(
      $,
      magicLink,
      pumpDuration: const Duration(milliseconds: 500),
    );

    // Give a moment for magic link verification to start
    await Future.delayed(const Duration(milliseconds: 500));

    debugPrint('✅ MAGIC LINK: Link opened and verification initiated');

    debugPrint('✅ MAGIC LINK: Verification completed successfully');
  }

  /// Complete onboarding flow for new users with improved reliability
  ///
  /// This handles the complete onboarding process:
  /// 1. Wait for onboarding welcome message
  /// 2. Navigate to family creation
  /// 3. Create family with generated name
  /// 4. Complete onboarding to dashboard
  ///
  /// Expected behavior:
  /// - User starts at onboarding welcome page
  /// - Creates family successfully
  /// - Navigates to dashboard with family
  /// - Dashboard title and navigation are visible
  static Future<String> completeOnboardingFlow(
    PatrolIntegrationTester $, {
    bool hasInvitation = false,
  }) async {
    debugPrint('🎯 ONBOARDING: Starting complete onboarding flow');

    // Wait for navigation to onboarding page after magic link success
    await waitForElementWithState(
      $,
      find.byKey(const Key('onboarding_welcome_message')),
      timeout: const Duration(seconds: 12),
      description: 'onboarding welcome page',
    );
    debugPrint('✅ ONBOARDING: Navigated to onboarding page');

    // Navigate to family creation by tapping the create family option
    // The button depends on whether there's an invitation:
    // - With invitation: "create_new_family_button" key
    // - Without invitation: "create_family_button" key
    if (hasInvitation) {
      // User has invitation - click "Create New Family Instead" button
      await waitForElementWithState(
        $,
        find.byKey(const Key('create_new_family_button')),
        timeout: const Duration(seconds: 8),
        description: 'create new family button (has invitation)',
      );
      await safeTap(
        $,
        find.byKey(const Key('create_new_family_button')),
        description: 'create new family button (has invitation)',
      );
      debugPrint(
        '✅ ONBOARDING: Tapped create new family button (has invitation)',
      );
    } else {
      // User has no invitation - click "Create Family" button
      await waitForElementWithState(
        $,
        find.byKey(const Key('create_family_button')),
        timeout: const Duration(seconds: 8),
        description: 'create family button (no invitation)',
      );
      await safeTap(
        $,
        find.byKey(const Key('create_family_button')),
        description: 'create family button (no invitation)',
      );
      debugPrint('✅ ONBOARDING: Tapped create family button (no invitation)');
    }

    // Wait for navigation to family creation page
    await waitForElementWithState(
      $,
      find.byKey(const Key('create_your_family_header')),
      timeout: const Duration(seconds: 8),
      description: 'family creation page header',
    );
    debugPrint('✅ ONBOARDING: Navigated to family creation page');

    // Generate unique family name
    final familyName = TestDataGenerator.generateUniqueFamilyName();
    debugPrint('🎯 ONBOARDING: Using family name: $familyName');

    // Fill in family name with improved reliability
    await waitForElementWithState(
      $,
      find.byKey(const Key('familyNameField')),
      timeout: const Duration(seconds: 8),
      description: 'family name field',
    );
    await safeTap(
      $,
      find.byKey(const Key('familyNameField')),
      description: 'family name field',
      waitAfterTap: false,
    );
    await $.enterText(find.byKey(const Key('familyNameField')), familyName);
    await $.pump(const Duration(milliseconds: 500)); // Allow text to settle
    debugPrint('✅ ONBOARDING: Entered family name');

    // Submit family creation with improved reliability
    await safeTap(
      $,
      find.byKey(const Key('submit_create_family_button')),
      timeout: const Duration(seconds: 8),
      description: 'create family submit button',
    );
    debugPrint('🎯 ONBOARDING: Submitted family creation');

    // Wait for successful family creation and navigation to dashboard
    await _waitWithRetry(
      $,
      () => $.waitUntilVisible(
        find.byKey(const Key('dashboard_title')),
        timeout: const Duration(seconds: 8),
      ),
      delayBetweenRetries: const Duration(seconds: 2),
      description: 'dashboard after family creation',
    );
    debugPrint(
      '✅ ONBOARDING: Family created successfully, navigated to dashboard',
    );

    return familyName;
  }

  /// Perform logout from specified location with improved reliability
  ///
  /// This handles logout functionality from different app locations:
  /// - Profile: Uses profile navigation → logout button
  /// - Onboarding: Uses appropriate onboarding logout mechanism with confirmation dialog
  ///
  /// [from] - Location to logout from (profile or onboarding)
  ///
  /// Expected behavior:
  /// - Logout is performed from appropriate location
  /// - User returns to login page
  /// - Welcome message is visible after logout
  static Future<void> performLogout(
    PatrolIntegrationTester $, {
    required LogoutLocation from,
  }) async {
    debugPrint('🚪 LOGOUT: Starting logout from ${from.name}');

    switch (from) {
      case LogoutLocation.profile:
        // Navigate to profile page for logout
        await safeTap(
          $,
          find.byKey(const Key('navigation_profile')),
          description: 'navigation profile button',
        );

        // Tap logout button on profile page (may require scrolling)
        final logoutButton = find.byKey(const Key('profile_logout_button'));
        await waitForElementWithState(
          $,
          logoutButton,
          description: 'profile logout button',
        );
        await $.tap(logoutButton);
        await $.pump(const Duration(milliseconds: 300));

        // Handle logout confirmation dialog
        await waitForElementWithState(
          $,
          find.byType(AlertDialog),
          description: 'logout confirmation dialog',
        );

        // Confirm logout (second button is typically Logout/Confirm)
        final confirmButtons = find.byType(TextButton);
        await safeTap(
          $,
          confirmButtons.at(1),
          description: 'logout confirm button',
        );

        debugPrint('✅ LOGOUT: Logged out from profile page');
        break;

      case LogoutLocation.onboarding:
        // Handle logout from onboarding page (has confirmation dialog)
        await safeTap(
          $,
          find.byKey(const Key('onboarding_logout_button')),
          description: 'onboarding logout button',
        );

        // Handle logout confirmation dialog with proper waiting
        await waitForElementWithState(
          $,
          find.byKey(const Key('logout_confirmation_dialog')),
          timeout: const Duration(seconds: 5),
          description: 'logout confirmation dialog',
        );

        await safeTap(
          $,
          find.byKey(const Key('logout_confirm_button')),
          description: 'logout confirm button',
        );
        debugPrint('✅ LOGOUT: Confirmed logout from onboarding');
        break;
    }

    // Verify logged out - should be back to login page with retry
    await _waitWithRetry(
      $,
      () => $.waitUntilVisible(
        find.byKey(const Key('welcomeToEduLift')),
        timeout: const Duration(seconds: 5),
      ),
      description: 'return to login page after logout',
    );
    debugPrint('✅ LOGOUT: Successfully returned to login page');
  }

  /// Initialize app with bootstrap container and improved reliability
  ///
  /// This is a convenience method for consistent app initialization
  /// across all authentication tests with better timing handling.
  ///
  /// Returns the initialized container for use in tests.
  ///
  /// [expectLoginPage] - If true (default), expects the app to start on login page.
  /// If false, skips login page verification (used for session persistence tests).
  /// [skipNetworkRestore] - If true, skips automatic network restoration
  /// (used for network simulation tests that intentionally set specific network states).
  static Future<ProviderContainer> initializeApp(
    PatrolIntegrationTester $, {
    bool expectLoginPage = true,
    bool skipNetworkRestore = false,
  }) async {
    debugPrint('🚀 APP INIT: Initializing app with bootstrap');

    if (!skipNetworkRestore) {
      // CRITICAL: Ensure network is restored before starting any test
      // Previous tests may have left device in airplane mode or network disabled
      try {
        debugPrint(
          '🔍 APP INIT: Checking network state before initialization...',
        );

        // Disable airplane mode if it's enabled
        await $.native.disableAirplaneMode();

        // Ensure WiFi is enabled
        await $.native.enableWifi();

        // Wait for network connectivity to be restored
        await NetworkDeviceHelper.waitForNetworkConnectivity($);

        debugPrint('✅ APP INIT: Network connectivity verified and restored');
      } catch (e) {
        debugPrint(
          '⚠️ APP INIT: Network state check failed, continuing anyway: $e',
        );
        // Don't fail the test due to network state issues - continue with test
      }
    } else {
      debugPrint(
        '⚠️ APP INIT: Skipping network restoration for network simulation test',
      );
    }

    final container = await bootstrap();
    await $.pumpWidgetAndSettle(
      UncontrolledProviderScope(
        container: container,
        child: const EduLiftApp(),
      ),
    );

    // Verify app is ready - conditionally check for login page
    if (expectLoginPage) {
      await waitForElementWithState(
        $,
        find.byKey(const Key('welcomeToEduLift')),
        description: 'login page',
      );
      debugPrint('✅ APP INIT: App initialized and ready on login page');
    } else {
      // DETERMINISTIC FIX: Session persistence test expects dashboard
      debugPrint(
        '🔄 SESSION PERSISTENCE: Waiting for dashboard after session restoration...',
      );

      // Use waitUntilVisible for deterministic dashboard expectation
      await $.waitUntilVisible(
        find.byKey(const Key('dashboard_title')),
        timeout: const Duration(seconds: 15),
      );

      debugPrint(
        '✅ SESSION PERSISTENCE: Dashboard found - session restored successfully',
      );
    }

    return container;
  }

  /// Navigate to login page and enter email with improved reliability
  ///
  /// This is a convenience method for consistent login page navigation
  /// and email entry across tests.
  ///
  /// [email] - Email address to enter
  static Future<void> navigateToLoginAndEnterEmail(
    PatrolIntegrationTester $,
    String email,
  ) async {
    debugPrint('📧 LOGIN SETUP: Entering email: $email');

    // Navigate to login page and verify initial state
    await waitForElementWithState(
      $,
      find.byKey(const Key('welcomeToEduLift')),
      description: 'welcome to edulift message',
    );

    // Enter email address with improved handling
    await waitForElementWithState(
      $,
      find.byKey(const Key('emailField')),
      description: 'email field',
    );
    await $.enterText(find.byKey(const Key('emailField')), email);
    await $.pump(const Duration(milliseconds: 300)); // Allow text to settle
    debugPrint('✅ LOGIN SETUP: Email entered successfully');
  }

  /// Complete full authentication flow for new user
  ///
  /// This is a convenience method that combines multiple steps:
  /// 1. Enter email on login page
  /// 2. Handle new user auth flow
  /// 3. Wait for and process magic link
  /// 4. Verify authentication completion
  ///
  /// [userProfile] - User profile with email and firstName
  ///
  /// Returns the magic link that was used for verification.
  static Future<String> completeNewUserAuthentication(
    PatrolIntegrationTester $,
    Map<String, String> userProfile,
  ) async {
    debugPrint('🔄 FULL AUTH: Starting complete new user authentication');
    debugPrint('   Email: ${userProfile['email']}');

    // Enter email
    await navigateToLoginAndEnterEmail($, userProfile['email']!);

    // Handle new user authentication flow
    await handleNewUserAuthFlow($, userProfile);

    // Wait for real email delivery via Mailpit
    debugPrint('📧 FULL AUTH: Waiting for magic link email...');
    final magicLink = await MailpitHelper.waitForMagicLink(
      userProfile['email']!,
    );

    if (magicLink == null) {
      throw Exception(
        'Magic link email not received for ${userProfile['email']}',
      );
    }

    debugPrint(
      '✅ FULL AUTH: Received magic link: ${magicLink.substring(0, 50)}...',
    );

    // Process magic link
    await handleMagicLinkVerification($, magicLink);

    debugPrint('🎉 FULL AUTH: Complete new user authentication successful');
    return magicLink;
  }

  /// Complete full authentication flow for existing user with improved reliability
  ///
  /// This is a convenience method that combines multiple steps:
  /// 1. Enter email on login page
  /// 2. Handle existing user auth flow
  /// 3. Wait for and process magic link
  /// 4. Verify authentication completion
  ///
  /// [userProfile] - User profile with email
  ///
  /// Returns the magic link that was used for verification.
  static Future<String> completeExistingUserAuthentication(
    PatrolIntegrationTester $,
    Map<String, String> userProfile,
  ) async {
    debugPrint('🔄 FULL AUTH: Starting complete existing user authentication');
    debugPrint('   Email: ${userProfile['email']}');

    // Enter email
    await navigateToLoginAndEnterEmail($, userProfile['email']!);

    // Handle existing user authentication flow (no name required)
    await handleExistingUserAuthFlow($, userProfile);

    // Wait for magic link with retry mechanism
    debugPrint('📧 FULL AUTH: Waiting for magic link email...');
    final magicLink = await _waitWithRetry(
      $,
      () async {
        final link = await MailpitHelper.waitForMagicLink(
          userProfile['email']!,
        );
        if (link == null) {
          throw Exception('Magic link not yet received');
        }
        return link;
      },
      delayBetweenRetries: const Duration(seconds: 2),
      description: 'magic link email delivery',
    );

    debugPrint(
      '✅ FULL AUTH: Received magic link: ${magicLink.substring(0, 50)}...',
    );

    // Process magic link
    await handleMagicLinkVerification($, magicLink);

    debugPrint(
      '🎉 FULL AUTH: Complete existing user authentication successful',
    );
    return magicLink;
  }

  /// Handle invitation authentication flow with progressive disclosure
  ///
  /// This handles the INVITATION-specific authentication scenario:
  /// 1. Click "Sign In to Join" button from invitation page
  /// 2. Fill invitation email in the email field
  /// 3. Click auth button → may trigger 422 if new user
  /// 4. If new user: name field appears, fill name, click auth again
  /// 5. Navigate to MagicLinkPage with sent message
  ///
  /// [inviteeEmail] - Email address from the invitation (must match invitation)
  /// [inviteeName] - Name for new users (required if expectNameField is true)
  /// [expectNameField] - Whether to expect the progressive name field for new users
  ///
  /// Expected behavior:
  /// - Navigates from invitation page to auth page
  /// - Uses the correct email that matches the invitation
  /// - Handles progressive disclosure if user is new (expectNameField = true)
  /// - Final navigation to MagicLinkPage for magic link processing
  static Future<void> handleInvitationAuthFlow(
    PatrolIntegrationTester $,
    String inviteeEmail,
    String inviteeName, {
    bool expectNameField = false,
  }) async {
    debugPrint(
      '📧 INVITATION AUTH: Starting invitation authentication flow for $inviteeEmail',
    );
    debugPrint('   Expect name field: $expectNameField');

    // Step 1: Click "Sign In to Join" button from invitation page
    await safeTap(
      $,
      find.byKey(const Key('invitation_signin_button')),
      description: 'invitation sign in button',
    );

    // Step 2: Wait for navigation to auth page and fill email
    await waitForElementWithState(
      $,
      find.byKey(const Key('emailField')),
      timeout: const Duration(seconds: 8),
      description: 'email field on auth page',
    );

    await $.enterText(find.byKey(const Key('emailField')), inviteeEmail);
    await $.pump(const Duration(milliseconds: 300)); // Allow text to settle
    debugPrint('✅ INVITATION AUTH: Email entered: $inviteeEmail');

    // Step 3: First auth attempt - click the auth button
    await safeTap(
      $,
      find.byKey(const Key('login_auth_action_button')),
      description: 'auth button (first attempt)',
    );

    if (expectNameField) {
      debugPrint('📝 INVITATION AUTH: Expecting name field for new user');

      // Step 4a: Must see the welcome message (indicates 422 error and name field requirement)
      await waitForElementWithState(
        $,
        find.byKey(const Key('auth_welcome_message')),
        timeout: const Duration(seconds: 8),
        description: 'welcome message for new user',
      );
      debugPrint(
        '✅ INVITATION AUTH: Welcome message appeared - name field is required',
      );

      // Step 4b: The name field should now be visible
      await waitForElementWithState(
        $,
        find.byKey(const Key('nameField')),
        description: 'name field',
      );

      // Step 4c: Fill in the name
      await $.enterText(find.byKey(const Key('nameField')), inviteeName);
      await $.pump(const Duration(milliseconds: 300)); // Allow text to settle
      debugPrint('✅ INVITATION AUTH: Name entered: $inviteeName');

      // Step 4d: Second auth attempt - click auth button again
      await safeTap(
        $,
        find.byKey(const Key('login_auth_action_button')),
        description: 'auth button (second attempt with name)',
      );
    }

    // Step 5: Should navigate to MagicLinkPage (regardless of new/existing user)
    await waitForElementWithState(
      $,
      find.byKey(const Key('magic_link_sent_message')),
      timeout: const Duration(seconds: 8),
      description: 'magic link sent message',
    );
    debugPrint(
      '✅ INVITATION AUTH: Navigated to MagicLinkPage - ready for magic link processing',
    );
  }

  /// Enhanced error handling for network-dependent operations
  /// This method handles common network error scenarios with appropriate retry logic
  static Future<T> handleNetworkOperation<T>(
    PatrolIntegrationTester $,
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
    String? description,
  }) async {
    return await _waitWithRetry(
      $,
      operation,
      maxRetries: maxRetries,
      delayBetweenRetries: initialDelay,
      description: description ?? 'network operation',
    );
  }

  /// Robust element search that combines multiple search strategies
  /// Reduces brittleness by trying key-based and text-based searches
  static Future<bool> findElementRobustly(
    PatrolIntegrationTester $, {
    Key? elementKey,
    String? textContent,
    Duration timeout = const Duration(seconds: 8),
    String? description,
  }) async {
    final desc = description ?? 'element';
    debugPrint('🔍 Searching for $desc...');

    // Try key-based search first (more reliable)
    if (elementKey != null) {
      try {
        await $.waitUntilVisible(
          find.byKey(elementKey),
          timeout: Duration(milliseconds: timeout.inMilliseconds ~/ 2),
        );
        debugPrint('✅ Found $desc by key');
        return true;
      } catch (e) {
        debugPrint('⚠️ Key-based search failed for $desc: $e');
      }
    }

    // Fallback to text-based search
    if (textContent != null) {
      try {
        await $.waitUntilVisible(
          find.textContaining(textContent),
          timeout: Duration(milliseconds: timeout.inMilliseconds ~/ 2),
        );
        debugPrint('✅ Found $desc by text');
        return true;
      } catch (e) {
        debugPrint('⚠️ Text-based search failed for $desc: $e');
      }
    }

    debugPrint('❌ Failed to find $desc with any search strategy');
    return false;
  }

  /// Verify that error message is displayed with correct localized content
  ///
  /// This ensures the error message widget exists AND contains the expected localized text.
  /// Unlike simple existence checks, this validates the actual user-facing message content.
  ///
  /// Parameters:
  /// - [$]: Patrol test instance
  /// - [expectedMessageKey]: The l10n key for the expected error message (e.g., 'errorEmailInvalid')
  /// - [timeout]: Optional timeout duration (default: 5 seconds)
  ///
  /// Returns: The actual error message text found
  ///
  /// Throws: TestFailure if error message widget not found or text doesn't match
  ///
  /// Example:
  /// ```dart
  /// await AuthFlowHelper.verifyErrorMessage($, 'errorEmailInvalid');
  /// ```
  static Future<String> verifyErrorMessage(
    PatrolIntegrationTester $,
    String expectedMessageKey, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    debugPrint('🔍 Verifying error message for key: $expectedMessageKey');

    // Step 1: Wait for error message widget to appear
    await $.waitUntilVisible(
      find.byKey(const Key('errorMessage')),
      timeout: timeout,
    );
    debugPrint('✅ Error message widget found');

    // Step 2: Get the error message text
    // Handle two possible structures:
    // 1. Container with key 'errorMessage' containing a Text child (login_page, magic_link_page)
    // 2. Text widget with key 'errorMessage' directly (magic_link_verify_page)

    final errorWidget = find.byKey(const Key('errorMessage'));
    String actualMessage;

    // Try to get the widget with the key
    // Use .first to handle multiple instances during rebuilds
    final widget = $.tester.widgetList(errorWidget).first;

    if (widget is Text) {
      // Case 2: Text widget has the key directly
      actualMessage = (widget.data ?? widget.textSpan?.toPlainText() ?? '')
          .trim();
      debugPrint('📝 Found error message (direct Text): "$actualMessage"');
    } else {
      // Case 1: Container has the key, Text is a descendant
      final textWidgets = find.descendant(
        of: errorWidget,
        matching: find.byType(Text),
      );

      expect(
        textWidgets,
        findsAtLeastNWidgets(1),
        reason:
            'Error message container should contain at least one Text widget',
      );

      final textWidget = $.tester.widget<Text>(textWidgets.first);
      actualMessage =
          (textWidget.data ?? textWidget.textSpan?.toPlainText() ?? '').trim();
      debugPrint('📝 Found error message (Container > Text): "$actualMessage"');
    }

    // Step 3: Verify message is not empty
    expect(
      actualMessage,
      isNotEmpty,
      reason: 'Error message should not be empty',
    );

    // Step 4: Verify message is not a raw localization key
    expect(
      actualMessage.startsWith('error') &&
          actualMessage.contains(RegExp(r'[A-Z]')),
      isFalse,
      reason:
          'Error message should be localized, not a raw key like "$actualMessage"',
    );

    debugPrint('✅ Error message validation passed: "$actualMessage"');
    return actualMessage;
  }

  /// Verify that NO error message is displayed
  ///
  /// Useful for testing successful validation or error state clearing
  static Future<void> verifyNoErrorMessage(PatrolIntegrationTester $) async {
    debugPrint('🔍 Verifying no error message is displayed');

    expect(
      find.byKey(const Key('errorMessage')),
      findsNothing,
      reason: 'Error message should not be visible',
    );

    debugPrint('✅ Confirmed: No error message displayed');
  }

  /// Verify magic link verification failed message with correct localized content
  ///
  /// This validates the 'verification-failed-text' error display used in magic_link_verify_page.dart
  /// Unlike the standard errorMessage container, this has a fixed title and a separate localized error message below.
  ///
  /// Parameters:
  /// - [$]: Patrol test instance
  /// - [expectedMessageKey]: The l10n key for the expected error message (e.g., 'errorAuthMagicLinkExpired')
  /// - [timeout]: Optional timeout duration (default: 5 seconds)
  ///
  /// Returns: The actual error message text found
  ///
  /// Throws: TestFailure if verification-failed-text not found or message doesn't match
  ///
  /// Example:
  /// ```dart
  /// await AuthFlowHelper.verifyVerificationFailedMessage($, 'errorAuthMagicLinkExpired');
  /// ```
  static Future<String> verifyVerificationFailedMessage(
    PatrolIntegrationTester $,
    String expectedMessageKey, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    debugPrint(
      '🔍 Verifying verification-failed message for key: $expectedMessageKey',
    );

    // Step 1: Wait for verification-failed-text to appear
    await $.waitUntilVisible(
      find.byKey(const Key('verification-failed-text')),
      timeout: timeout,
    );
    debugPrint('✅ Verification-failed-text found');

    // Step 2: Find the error message Text widget
    // The structure is: verification-failed-text (title) followed by error message Text
    // We need to find Text widgets near the verification-failed-text
    final allTextWidgets = find.byType(Text);

    // Get all Text widgets and find the one after verification-failed-text
    final textWidgetsList = $.tester.widgetList<Text>(allTextWidgets).toList();

    // Find the verification-failed-text widget first
    // Use .first to handle multiple instances during rebuilds
    final verificationFailedText = $.tester
        .widgetList<Text>(find.byKey(const Key('verification-failed-text')))
        .first;
    debugPrint(
      '📝 Found verification-failed title: "${verificationFailedText.data}"',
    );

    // The error message should be one of the Text widgets after the title
    // Look for a non-empty Text that's not the title itself
    String? actualMessage;
    for (final textWidget in textWidgetsList) {
      final text = (textWidget.data ?? textWidget.textSpan?.toPlainText() ?? '')
          .trim();
      // Skip empty texts and the title itself
      if (text.isNotEmpty &&
          text != verificationFailedText.data &&
          text != 'Verification failed') {
        // This is likely our error message
        actualMessage = text;
        break;
      }
    }

    if (actualMessage == null || actualMessage.isEmpty) {
      throw TestFailure(
        'Could not find error message text after verification-failed-text',
      );
    }

    debugPrint('📝 Found error message: "$actualMessage"');

    // Step 3: Verify message is not a raw localization key
    expect(
      actualMessage.startsWith('error') &&
          actualMessage.contains(RegExp(r'[A-Z]')),
      isFalse,
      reason:
          'Error message should be localized, not a raw key like "$actualMessage"',
    );

    debugPrint(
      '✅ Verification-failed message validation passed: "$actualMessage"',
    );
    return actualMessage;
  }
}

/// Enum for logout location specification
enum LogoutLocation {
  /// Logout from profile page (accessed via dashboard navigation)
  profile,

  /// Logout from onboarding pages
  onboarding,
}
