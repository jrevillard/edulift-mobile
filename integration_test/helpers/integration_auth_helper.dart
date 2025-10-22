// EduLift Mobile E2E - Integration Test Auth Helper
// Provides authentication methods for integration_test (not Patrol)
// Adapted from AuthFlowHelper but uses WidgetTester instead of PatrolIntegrationTester

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/bootstrap.dart';
import 'package:edulift/edulift_app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Helper class for authentication flows using integration_test
class IntegrationAuthHelper {
  /// Initialize the app for integration testing
  static Future<ProviderContainer> initializeApp(
    WidgetTester tester, {
    bool expectLoginPage = true,
  }) async {
    debugPrint('🚀 APP INIT: Initializing app with bootstrap');
    final container = await bootstrap();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const EduLiftApp(),
      ),
    );
    await tester.pumpAndSettle();

    debugPrint('✅ APP INIT: App initialized successfully');

    // Verify login page if expected
    if (expectLoginPage) {
      expect(
        find.byKey(const Key('welcomeToEduLift')),
        findsOneWidget,
        reason: 'App should start on login page',
      );
    }

    debugPrint('🚀 APP INIT: App is ready for testing');
    return container;
  }

  /// Navigate to login and enter email
  static Future<void> navigateToLoginAndEnterEmail(
    WidgetTester tester,
    String email,
  ) async {
    debugPrint('📧 EMAIL INPUT: Entering email: $email');

    // Ensure we're on the login page
    expect(find.byKey(const Key('welcomeToEduLift')), findsOneWidget);

    // Find and tap the email input field
    final emailField = find.byKey(const Key('emailField'));
    expect(emailField, findsOneWidget);

    await tester.tap(emailField);
    await tester.pumpAndSettle();

    // Clear any existing text and enter the email
    await tester.enterText(emailField, email);
    await tester.pumpAndSettle();

    debugPrint('✅ EMAIL INPUT: Email entered successfully');
  }

  /// Handle new user authentication flow (trigger 422 error then handle name field)
  static Future<void> handleNewUserAuthFlow(
    WidgetTester tester,
    Map<String, String> userProfile,
  ) async {
    final fullName = userProfile['name']!;

    debugPrint(
      '👤 NEW USER: Starting new user auth flow for ${userProfile['email']}',
    );

    // Tap the login button to trigger the 422 error
    final loginButton = find.byKey(const Key('login_auth_action_button'));
    expect(loginButton, findsOneWidget);

    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // Wait for the name field to appear (422 error response)
    debugPrint('⏳ NEW USER: Waiting for name field to appear...');

    await tester.pumpAndSettle(const Duration(seconds: 2));

    // The name field doesn't have a key, so we'll find it by looking for TextFormField
    // that appears after the email field (it's the second TextFormField)
    final textFields = find.byType(TextFormField);
    expect(textFields, findsNWidgets(2)); // email and name fields

    // Get the name field (second TextFormField)
    final nameField = textFields.at(1);
    await tester.tap(nameField);
    await tester.pumpAndSettle();

    await tester.enterText(nameField, fullName);
    await tester.pumpAndSettle();

    debugPrint('👤 NEW USER: Name field filled - $fullName');

    // Tap the login button again to create the account
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // Wait for magic link sent message
    await _waitForWidget(
      tester,
      find.byKey(const Key('magic_link_sent_message')),
      timeout: const Duration(seconds: 8),
    );

    debugPrint('✅ NEW USER: Magic link sent successfully');
  }

  /// Handle magic link verification
  static Future<void> handleMagicLinkVerification(
    WidgetTester tester,
    String magicLink,
  ) async {
    debugPrint('🔗 MAGIC LINK: Processing magic link verification');

    // Simulate opening the magic link URL using the modern API
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    await messenger.handlePlatformMessage(
      'flutter/navigation',
      const StandardMethodCodec().encodeMethodCall(
        MethodCall('routeUpdated', {'location': magicLink, 'state': null}),
      ),
      (data) {},
    );

    // Allow processing time
    await tester.pumpAndSettle(const Duration(seconds: 3));

    debugPrint('✅ MAGIC LINK: Magic link processed');
  }

  /// Complete onboarding flow
  static Future<void> completeOnboardingFlow(WidgetTester tester) async {
    debugPrint('🎓 ONBOARDING: Starting onboarding completion');

    // Verify we're on onboarding
    expect(find.byKey(const Key('onboarding_welcome_message')), findsOneWidget);

    // Find and tap next/continue buttons until dashboard
    // This is a simplified version - the actual flow might have more steps
    final continueButton = find.byKey(const Key('onboarding_continue_button'));
    if (continueButton.evaluate().isNotEmpty) {
      await tester.tap(continueButton);
      await tester.pumpAndSettle();
    }

    // Wait for dashboard
    await _waitForWidget(tester, find.byKey(const Key('dashboard_home')));

    debugPrint('✅ ONBOARDING: Completed successfully');
  }

  /// Perform logout
  static Future<void> performLogout(
    WidgetTester tester, {
    required LogoutLocation from,
  }) async {
    debugPrint('🚪 LOGOUT: Starting logout from $from');

    // Find logout button based on location
    final logoutButton = from == LogoutLocation.profile
        ? find.byKey(const Key('dashboard_logout_button'))
        : find.byKey(const Key('onboarding_logout_button'));

    expect(logoutButton, findsOneWidget);
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    // Handle confirmation dialog
    expect(find.byKey(const Key('logout_confirmation_dialog')), findsOneWidget);

    await tester.tap(find.byKey(const Key('logout_confirm_button')));
    await tester.pumpAndSettle();

    // Wait for return to login page
    await _waitForWidget(
      tester,
      find.byKey(const Key('welcomeToEduLift')),
      timeout: const Duration(seconds: 5),
    );

    debugPrint('✅ LOGOUT: Completed successfully');
  }

  /// Wait for a widget to appear with timeout
  static Future<void> _waitForWidget(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < timeout) {
      await tester.pumpAndSettle();

      if (finder.evaluate().isNotEmpty) {
        return;
      }

      await Future.delayed(const Duration(milliseconds: 200));
    }

    throw Exception(
      'Widget ${finder.toString()} not found within ${timeout.inSeconds}s',
    );
  }
}

/// Enum for logout locations
enum LogoutLocation { profile, onboarding }
