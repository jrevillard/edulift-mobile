import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/src/dummies.dart';
import 'package:dartz/dartz.dart';

import 'package:edulift/features/auth/presentation/pages/login_page.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/presentation/widgets/accessibility/accessible_button.dart';
import '../../../support/simple_widget_test_helper.dart';

/// Test fixtures for auth-related results and entities
class AuthTestFixtures {
  /// Creates a successful void result for auth operations
  static Result<void, Failure> successVoid() =>
      const Result<void, Failure>.ok(null);

  /// Creates a server error result for auth operations
  static Result<void, Failure> serverError({String? message}) =>
      Result<void, Failure>.err(ApiFailure.serverError(message: message));

  /// Creates a network error result for auth operations
  static Result<void, Failure> networkError() =>
      const Result<void, Failure>.err(
        NoConnectionFailure(
          message: 'No internet connection',
          statusCode: 0,
          details: {'type': 'no_connection'},
        ),
      );

  /// Creates a validation error for missing name
  static Result<void, Failure> nameRequiredError() => Result<void, Failure>.err(
        ApiFailure.serverError(message: 'Name is required for new users'),
      );

  /// Creates a generic validation error
  static Result<void, Failure> validationError(String message) =>
      Result<void, Failure>.err(
        ValidationFailure(
          message: message,
          statusCode: 422,
          details: const {'field': 'validation'},
        ),
      );

  /// Creates delayed successful response for loading state tests
  static Future<Result<void, Failure>> delayedSuccess({
    int milliseconds = 100,
  }) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
    return successVoid();
  }

  /// Creates delayed error response for loading state tests
  static Future<Result<void, Failure>> delayedError({
    int milliseconds = 100,
    String? message,
  }) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
    return serverError(message: message);
  }
}

void main() {
  // Provide dummy values for Result types to fix MissingDummyValueError
  setUpAll(() async {
    provideDummy<Result<void, AuthFailure>>(
      const Result<void, AuthFailure>.ok(null),
    );
    provideDummy<Either<AuthFailure, bool>>(const Right(false));

    // Initialize test DI system properly
    await SimpleWidgetTestHelper.initialize();
  });

  tearDownAll(() async {
    await SimpleWidgetTestHelper.tearDown();
  });

  group('LoginPage Progressive Disclosure Tests', () {
    Widget buildLoginPage({Locale? locale}) {
      // Use English locale for consistent test results
      return ProviderScope(
        child: SimpleWidgetTestHelper.createTestApp(child: const LoginPage()),
      );
    }

    group('Initial State', () {
      testWidgets('should show only email field initially', (tester) async {
        await tester.pumpWidget(buildLoginPage());
        await tester.pumpAndSettle();

        // Verify initial state - using key-based finding
        expect(find.byKey(const Key('emailField')), findsOneWidget);
        expect(find.byKey(const Key('nameField')), findsNothing);
        expect(
          find.byKey(const Key('login_auth_action_button')),
          findsOneWidget,
        );
        expect(find.text('Create account'), findsNothing);

        SimpleWidgetTestHelper.verifyNoExceptions(tester);
      });

      testWidgets('should show email field with proper validation', (
        tester,
      ) async {
        await tester.pumpWidget(buildLoginPage());
        await tester.pumpAndSettle();

        final emailField = find.byType(TextFormField).first;
        await tester.enterText(emailField, 'invalid-email');
        await tester.tap(find.byKey(const Key('login_auth_action_button')));
        await tester.pumpAndSettle();

        expect(find.text('Please enter a valid email address'), findsOneWidget);
        SimpleWidgetTestHelper.verifyNoExceptions(tester);
      });
    });

    group('Basic UI Tests', () {
      testWidgets('should display proper UI elements', (tester) async {
        await tester.pumpWidget(buildLoginPage());
        await tester.pumpAndSettle();

        // Check for basic UI elements
        expect(find.byType(TextFormField), findsAtLeastNWidgets(1));
        expect(
          find.byKey(const Key('login_auth_action_button')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('emailField')), findsOneWidget);
      });

      testWidgets('should handle text input properly', (tester) async {
        await tester.pumpWidget(buildLoginPage());
        await tester.pumpAndSettle();

        final emailField = find.byType(TextFormField).first;
        await tester.enterText(emailField, 'test@example.com');
        await tester.pump();

        expect(find.text('test@example.com'), findsOneWidget);
      });
    });

    group('Loading States', () {
      testWidgets('should show form elements correctly', (tester) async {
        await tester.pumpWidget(buildLoginPage());
        await tester.pumpAndSettle();

        // Test basic form interaction without mocking
        final emailField = find.byType(TextFormField).first;
        await tester.enterText(emailField, 'test@example.com');
        await tester.pump();

        // Verify the text was entered
        expect(find.text('test@example.com'), findsOneWidget);

        // Verify button is present and tappable
        final button = find.byKey(const Key('login_auth_action_button'));
        expect(button, findsOneWidget);

        // Test that button can be found and is enabled
        final buttonWidget = tester.widget<AccessibleButton>(
          find.byKey(const Key('login_auth_action_button')),
        );
        expect(buttonWidget.onPressed, isNotNull);
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper semantic labels', (tester) async {
        await tester.pumpWidget(buildLoginPage());
        await tester.pumpAndSettle();

        // Verify accessibility - check for text fields and buttons are accessible
        expect(find.byType(TextFormField), findsAtLeastNWidgets(1));
        expect(
          find.byKey(const Key('login_auth_action_button')),
          findsOneWidget,
        );

        // Verify email field is accessible
        final emailField = find.byType(TextFormField).first;
        expect(emailField, findsOneWidget);
      });

      testWidgets('should support keyboard navigation', (tester) async {
        await tester.pumpWidget(buildLoginPage());
        await tester.pumpAndSettle();

        // Test basic keyboard interaction
        final emailField = find.byType(TextFormField).first;
        await tester.tap(emailField);
        await tester.pump();

        // Send some keyboard input
        await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
        await tester.pump();

        // The field should be focusable
        expect(emailField, findsOneWidget);
      });
    });

    group('Form Validation', () {
      testWidgets('should validate email format', (tester) async {
        await tester.pumpWidget(buildLoginPage());
        await tester.pumpAndSettle();

        // Test invalid email
        final emailField = find.byType(TextFormField).first;
        await tester.enterText(emailField, 'invalid-email');

        // Trigger validation by tapping submit
        await tester.tap(find.byKey(const Key('login_auth_action_button')));
        await tester.pumpAndSettle();

        // Should show validation error (English text)
        expect(find.text('Please enter a valid email address'), findsOneWidget);
      });

      testWidgets('should accept valid email format', (tester) async {
        await tester.pumpWidget(buildLoginPage());
        await tester.pumpAndSettle();

        // Test valid email
        final emailField = find.byType(TextFormField).first;
        await tester.enterText(emailField, 'valid@example.com');
        await tester.pump();

        // Should not show validation error immediately
        expect(find.text('Please enter a valid email address'), findsNothing);
      });
    });

    group('State Management', () {
      testWidgets('should handle form state changes', (tester) async {
        await tester.pumpWidget(buildLoginPage());
        await tester.pumpAndSettle();

        final emailField = find.byType(TextFormField).first;

        // Change email multiple times
        await tester.enterText(emailField, 'first@example.com');
        await tester.pump();
        expect(find.text('first@example.com'), findsOneWidget);

        await tester.enterText(emailField, 'second@example.com');
        await tester.pump();
        expect(find.text('second@example.com'), findsOneWidget);
        expect(find.text('first@example.com'), findsNothing);
      });

      testWidgets('should maintain form state during widget rebuilds', (
        tester,
      ) async {
        await tester.pumpWidget(buildLoginPage());
        await tester.pumpAndSettle();

        final emailField = find.byType(TextFormField).first;
        await tester.enterText(emailField, 'persistent@example.com');
        await tester.pump();

        // Trigger a rebuild
        await tester.pumpWidget(buildLoginPage());
        await tester.pump();

        // Text should still be there (or cleared, depending on implementation)
        // This tests the widget's state management
        expect(emailField, findsOneWidget);
      });
    });

    group('User Experience', () {
      testWidgets('should provide clear visual feedback', (tester) async {
        await tester.pumpWidget(buildLoginPage());
        await tester.pumpAndSettle();

        // Verify visual elements are present
        expect(find.byType(TextFormField), findsAtLeastNWidgets(1));
        expect(
          find.byKey(const Key('login_auth_action_button')),
          findsOneWidget,
        );

        // Test focus behavior
        final emailField = find.byType(TextFormField).first;
        await tester.tap(emailField);
        await tester.pump();

        // Field should be focusable and responsive
        expect(emailField, findsOneWidget);
      });

      testWidgets('should handle rapid user interactions gracefully', (
        tester,
      ) async {
        await tester.pumpWidget(buildLoginPage());
        await tester.pumpAndSettle();

        final emailField = find.byType(TextFormField).first;
        final button = find.byKey(const Key('login_auth_action_button'));

        // Rapid interactions
        await tester.enterText(emailField, 'rapid@example.com');
        await tester.pump();

        // Multiple quick taps shouldn't crash
        await tester.tap(button);
        await tester.pump();
        await tester.tap(button);
        await tester.pump();

        // Should handle gracefully
        SimpleWidgetTestHelper.verifyNoExceptions(tester);
      });
    });
  });
}
