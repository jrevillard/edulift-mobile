// COMPREHENSIVE MAGIC LINK VERIFY PAGE WIDGET TESTS
// PRINCIPLE 0: RADICAL CANDOR - TRUTH ABOVE ALL
//
// SCOPE: Magic Link Verification UI Testing
// - Test verification process and states
// - Test loading states and error handling
// - Test success/failure navigation
// - Test accessibility compliance (WCAG 2.1 AA)
// - Test token validation flow

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:edulift/features/auth/presentation/pages/magic_link_verify_page.dart';
import 'package:edulift/core/services/providers/auth_provider.dart';
import 'package:edulift/core/domain/entities/user.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/core/domain/entities/auth_entities.dart';

import '../../../support/simple_widget_test_helper.dart';
import '../../../support/accessibility_test_helper.dart';
import '../../../test_mocks/test_mocks.dart';
import '../../../test_mocks/generated_mocks.mocks.dart' as gen_mocks;
import 'package:edulift/core/di/providers/service_providers.dart';
import 'package:dartz/dartz.dart';

void main() {
  const testToken = 'test-magic-link-token';

  setUpAll(() async {
    // Set up dummy values for Result types
    final dummyUser = User(
      id: 'test-user-id',
      email: 'test@example.com',
      name: 'Test User',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    provideDummy<Result<User, AuthFailure>>(Result.ok(dummyUser));

    await SimpleWidgetTestHelper.initialize();
    AccessibilityTestHelper.configure();
    setupMockFallbacks();
  });

  group('MagicLinkVerifyPage Widget Tests - CORE FUNCTIONALITY', () {
    late gen_mocks.MockIMagicLinkService mockMagicLinkService;

    setUp(() {
      mockMagicLinkService = gen_mocks.MockIMagicLinkService();

      // Default stub for magic link service to prevent FakeUsedError
      when(
        mockMagicLinkService.verifyMagicLink(
          any,
          inviteCode: anyNamed('inviteCode'),
        ),
      ).thenAnswer(
        (_) => Future.delayed(
          const Duration(milliseconds: 200),
          () => left(const AuthFailure(message: 'Test failure')),
        ),
      );
    });

    Widget createMagicLinkVerifyWidget({required String token}) {
      return ProviderScope(
        overrides: [
          // Override the problematic magicLinkServiceProvider to avoid provider dependency
          magicLinkServiceProvider.overrideWith(
            (ref) => mockMagicLinkService,
          ),
          authStateProvider.overrideWith(
            (ref) => AuthNotifier(
              MockAuthService(),
              MockAdaptiveStorageService(),
              MockBiometricService(),
              MockAppStateNotifier(),
              MockUserStatusService(),
              MockErrorHandlerService(),
              // MockComprehensiveFamilyDataService removed - Clean Architecture: auth UI separated from family services
              ref,
            ),
          ),
        ],
        child: SimpleWidgetTestHelper.createTestAppWithNavigation(
          child: MagicLinkVerifyPage(token: token),
          initialRoute: '/family/invite',
          additionalRoutes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('Dashboard'))),
            ),
            GoRoute(
              path: '/login',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('Login'))),
            ),
            GoRoute(
              path: '/onboarding/wizard',
              builder: (context, state) => const Scaffold(
                body: Center(child: Text('Onboarding Wizard')),
              ),
            ),
          ],
        ),
      );
    }

    testWidgets('should display loading state initially and verify token', (
      tester,
    ) async {
      // Arrange
      final dummyUser = {
        'id': 'test-user-id',
        'email': 'test@example.com',
        'name': 'Test User',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final successResult = MagicLinkVerificationResult(
        token: 'test-jwt-token',
        refreshToken: 'test-refresh-token',
        expiresIn: 900,
        user: dummyUser,
        expiresAt: DateTime(2024, 12, 31, 23, 59, 59),
      );

      when(
        mockMagicLinkService.verifyMagicLink(
          testToken,
          inviteCode: anyNamed('inviteCode'),
        ),
      ).thenAnswer(
        (_) => Future.delayed(
          const Duration(milliseconds: 100),
          () => right(successResult),
        ),
      );

      await tester.pumpWidget(createMagicLinkVerifyWidget(token: testToken));

      // Assert - Should show loading state initially (based on actual implementation)
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Verifying Magic Link'), findsOneWidget);

      // Assert - Accessibility during loading
      await AccessibilityTestHelper.runAccessibilityTestSuite(
        tester,
        requiredLabels: ['Verifying magic link...'],
      );

      // Wait for verification to complete
      await SimpleWidgetTestHelper.pumpAndSettleWithTimeout(tester);

      // Verify magic link service was called with correct token
      verify(
        mockMagicLinkService.verifyMagicLink(
          testToken,
          inviteCode: anyNamed('inviteCode'),
        ),
      ).called(1);

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });

    testWidgets('should display success state on successful verification', (
      tester,
    ) async {
      // Arrange
      final dummyUser = {
        'id': 'test-user-id',
        'email': 'test@example.com',
        'name': 'Test User',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final successResult = MagicLinkVerificationResult(
        token: 'test-jwt-token',
        refreshToken: 'test-refresh-token',
        expiresIn: 900,
        user: dummyUser,
        expiresAt: DateTime(2024, 12, 31, 23, 59, 59),
      );

      when(
        mockMagicLinkService.verifyMagicLink(
          testToken,
          inviteCode: anyNamed('inviteCode'),
        ),
      ).thenAnswer((_) async => right(successResult));

      await tester.pumpWidget(createMagicLinkVerifyWidget(token: testToken));

      // First check what's actually displayed during loading
      expect(find.text('Verifying Magic Link'), findsOneWidget);

      // Wait for the async verification to complete and UI to update to success state
      await tester.pump(); // Process the initial state
      await tester.pump(
        const Duration(milliseconds: 100),
      ); // Wait for mock response
      await tester.pump(); // Process success state update

      // Now check for success state BEFORE navigation happens (navigation has 1500ms delay)
      expect(find.text('Verification Successful'), findsOneWidget);
      expect(
        find.byKey(const Key('welcome_to_edulift_message')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      // Assert - Accessibility for success state
      await AccessibilityTestHelper.runAccessibilityTestSuite(
        tester,
        requiredLabels: ['Verification Successful'],
      );

      // Wait for all pending timers to complete to avoid test failure
      await tester.pumpAndSettle(const Duration(seconds: 3));

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });

    testWidgets('should display error state on verification failure', (
      tester,
    ) async {
      // Arrange
      when(
        mockMagicLinkService.verifyMagicLink(
          testToken,
          inviteCode: anyNamed('inviteCode'),
        ),
      ).thenAnswer(
        (_) async =>
            left(const ServerFailure(message: 'Invalid magic link token')),
      );

      await tester.pumpWidget(createMagicLinkVerifyWidget(token: testToken));

      // Wait for verification to complete and error state to show
      await tester.pump(); // Process initial state
      await tester.pump(
        const Duration(milliseconds: 100),
      ); // Wait for async call
      await tester.pump(); // Process error state

      // Assert - Should show error state
      expect(find.text('Verification Failed'), findsOneWidget);
      expect(
        find.text('This magic link is invalid or has already been used.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      // Assert - Should show request new link button (since invalid tokens can't be retried)
      expect(find.text('Request New Magic Link'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      // Assert - Accessibility for error state
      await AccessibilityTestHelper.runAccessibilityTestSuite(
        tester,
        requiredLabels: ['Verification Failed', 'Request New Magic Link'],
      );

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });

    testWidgets('should handle retry functionality', (tester) async {
      // Arrange - First call fails with network error (retryable), second succeeds
      final dummyUser = {
        'id': 'test-user-id',
        'email': 'test@example.com',
        'name': 'Test User',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      when(
        mockMagicLinkService.verifyMagicLink(
          testToken,
          inviteCode: anyNamed('inviteCode'),
        ),
      ).thenAnswer(
        (_) async => left(const NetworkFailure(message: 'Connection timeout')),
      );

      await tester.pumpWidget(createMagicLinkVerifyWidget(token: testToken));

      // Wait for error state to show
      await tester.pump(); // Process initial state
      await tester.pump(
        const Duration(milliseconds: 100),
      ); // Wait for async call
      await tester.pump(); // Process error state

      // Assert - Should show error state with retry option
      expect(find.text('Verification Failed'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      // Arrange - Setup success for retry
      final successResult = MagicLinkVerificationResult(
        token: 'test-jwt-token',
        refreshToken: 'test-refresh-token',
        expiresIn: 900,
        user: dummyUser,
        expiresAt: DateTime(2024, 12, 31, 23, 59, 59),
      );

      when(
        mockMagicLinkService.verifyMagicLink(
          testToken,
          inviteCode: anyNamed('inviteCode'),
        ),
      ).thenAnswer((_) async => right(successResult));

      // Act - Tap retry button
      final retryButton = find.text('Retry');
      await tester.tap(retryButton);
      await tester.pumpAndSettle(
        const Duration(milliseconds: 50),
      ); // Allow state transition

      // Assert - Should show loading again during retry
      // Note: The loading state might be very brief, so we check if the retry was triggered
      // by verifying we're no longer in error state
      expect(find.text('Verification Failed'), findsNothing);

      // Wait for success state
      await tester.pump(
        const Duration(milliseconds: 100),
      ); // Wait for async retry
      await tester.pump(); // Process success state

      // Assert - Should show success after retry
      expect(find.text('Verification Successful'), findsOneWidget);

      // Verify service was called twice (initial + retry)
      verify(
        mockMagicLinkService.verifyMagicLink(
          testToken,
          inviteCode: anyNamed('inviteCode'),
        ),
      ).called(2);

      // Wait for timers to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });

    testWidgets('should handle network errors appropriately', (tester) async {
      // Arrange
      when(
        mockMagicLinkService.verifyMagicLink(
          testToken,
          inviteCode: anyNamed('inviteCode'),
        ),
      ).thenAnswer(
        (_) async =>
            left(const NetworkFailure(message: 'No internet connection')),
      );

      await tester.pumpWidget(createMagicLinkVerifyWidget(token: testToken));

      // Wait for error state to show
      await tester.pump(); // Process initial state
      await tester.pump(
        const Duration(milliseconds: 100),
      ); // Wait for async call
      await tester.pump(); // Process error state

      // Assert - Should show network error with appropriate message
      expect(find.text('Verification Failed'), findsOneWidget);
      expect(
        find.text(
          'Unable to connect to the server. Please check your internet connection and try again.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('Check your internet connection and try again.'),
        findsOneWidget,
      );

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });
  });

  group('MagicLinkVerifyPage Widget Tests - USER INTERACTIONS', () {
    late gen_mocks.MockIMagicLinkService mockMagicLinkService;

    setUp(() {
      mockMagicLinkService = gen_mocks.MockIMagicLinkService();

      // Default stub for magic link service to prevent FakeUsedError
      when(
        mockMagicLinkService.verifyMagicLink(
          any,
          inviteCode: anyNamed('inviteCode'),
        ),
      ).thenAnswer(
        (_) => Future.delayed(
          const Duration(milliseconds: 200),
          () => left(const AuthFailure(message: 'Test failure')),
        ),
      );
    });

    Widget createMagicLinkVerifyWidget({required String token}) {
      return ProviderScope(
        overrides: [
          // Override the problematic magicLinkServiceProvider to avoid provider dependency
          magicLinkServiceProvider.overrideWith(
            (ref) => mockMagicLinkService,
          ),
          authStateProvider.overrideWith(
            (ref) => AuthNotifier(
              MockAuthService(),
              MockAdaptiveStorageService(),
              MockBiometricService(),
              MockAppStateNotifier(),
              MockUserStatusService(),
              MockErrorHandlerService(),
              // MockComprehensiveFamilyDataService removed - Clean Architecture: auth UI separated from family services
              ref,
            ),
          ),
        ],
        child: SimpleWidgetTestHelper.createTestAppWithNavigation(
          child: MagicLinkVerifyPage(token: token),
          initialRoute: '/family/invite',
          additionalRoutes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('Dashboard'))),
            ),
            GoRoute(
              path: '/login',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('Login'))),
            ),
            GoRoute(
              path: '/onboarding/wizard',
              builder: (context, state) => const Scaffold(
                body: Center(child: Text('Onboarding Wizard')),
              ),
            ),
          ],
        ),
      );
    }

    testWidgets('should handle empty or invalid tokens gracefully', (
      tester,
    ) async {
      // Arrange
      when(
        mockMagicLinkService.verifyMagicLink(
          '',
          inviteCode: anyNamed('inviteCode'),
        ),
      ).thenAnswer(
        (_) async =>
            left(const ValidationFailure(message: 'Invalid token format')),
      );

      await tester.pumpWidget(createMagicLinkVerifyWidget(token: ''));

      // Wait for error state to show
      await tester.pump(); // Process initial state
      await tester.pump(
        const Duration(milliseconds: 100),
      ); // Wait for async call
      await tester.pump(); // Process error state

      // Assert - Should show appropriate error
      expect(find.text('Verification Failed'), findsOneWidget);
      expect(
        find.text(
          'The magic link format is invalid. Please request a new one.',
        ),
        findsOneWidget,
      );

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });

    testWidgets('should have proper accessibility features throughout states', (
      tester,
    ) async {
      // Arrange
      final dummyUser = {
        'id': 'test-user-id',
        'email': 'test@example.com',
        'name': 'Test User',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final successResult = MagicLinkVerificationResult(
        token: 'test-jwt-token',
        refreshToken: 'test-refresh-token',
        expiresIn: 900,
        user: dummyUser,
        expiresAt: DateTime(2024, 12, 31, 23, 59, 59),
      );

      when(
        mockMagicLinkService.verifyMagicLink(
          testToken,
          inviteCode: anyNamed('inviteCode'),
        ),
      ).thenAnswer(
        (_) => Future.delayed(
          const Duration(milliseconds: 50),
          () => right(successResult),
        ),
      );

      await tester.pumpWidget(createMagicLinkVerifyWidget(token: testToken));

      // Assert - Accessibility during loading
      await AccessibilityTestHelper.runAccessibilityTestSuite(
        tester,
        requiredLabels: ['Verifying magic link...'],
      );

      // Wait for success state
      await tester.pump(); // Process initial state
      await tester.pump(
        const Duration(milliseconds: 50),
      ); // Wait for async call
      await tester.pump(); // Process success state

      // Assert - Accessibility in success state
      await AccessibilityTestHelper.runAccessibilityTestSuite(
        tester,
        requiredLabels: ['Verification Successful'],
      );

      // Wait for timers to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });
  });

  group('MagicLinkVerifyPage Widget Tests - GOLDEN TESTS', () {
    late gen_mocks.MockIMagicLinkService mockMagicLinkService;

    setUp(() {
      mockMagicLinkService = gen_mocks.MockIMagicLinkService();

      // Default stub for magic link service to prevent FakeUsedError
      when(
        mockMagicLinkService.verifyMagicLink(
          any,
          inviteCode: anyNamed('inviteCode'),
        ),
      ).thenAnswer(
        (_) => Future.delayed(
          const Duration(milliseconds: 200),
          () => left(const AuthFailure(message: 'Test failure')),
        ),
      );
    });

    Widget createMagicLinkVerifyWidget({required String token}) {
      return ProviderScope(
        overrides: [
          // Override the problematic magicLinkServiceProvider to avoid provider dependency
          magicLinkServiceProvider.overrideWith(
            (ref) => mockMagicLinkService,
          ),
          authStateProvider.overrideWith(
            (ref) => AuthNotifier(
              MockAuthService(),
              MockAdaptiveStorageService(),
              MockBiometricService(),
              MockAppStateNotifier(),
              MockUserStatusService(),
              MockErrorHandlerService(),
              // MockComprehensiveFamilyDataService removed - Clean Architecture: auth UI separated from family services
              ref,
            ),
          ),
        ],
        child: SimpleWidgetTestHelper.createTestAppWithNavigation(
          child: MagicLinkVerifyPage(token: token),
          initialRoute: '/family/invite',
          additionalRoutes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('Dashboard'))),
            ),
            GoRoute(
              path: '/login',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('Login'))),
            ),
            GoRoute(
              path: '/onboarding/wizard',
              builder: (context, state) => const Scaffold(
                body: Center(child: Text('Onboarding Wizard')),
              ),
            ),
          ],
        ),
      );
    }

    testWidgets('should match golden file for loading state', (tester) async {
      // Arrange
      final dummyUser = {
        'id': 'test-user-id',
        'email': 'test@example.com',
        'name': 'Test User',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final successResult = MagicLinkVerificationResult(
        token: 'test-jwt-token',
        refreshToken: 'test-refresh-token',
        expiresIn: 900,
        user: dummyUser,
        expiresAt: DateTime(2024, 12, 31, 23, 59, 59),
      );

      when(
        mockMagicLinkService.verifyMagicLink(
          testToken,
          inviteCode: anyNamed('inviteCode'),
        ),
      ).thenAnswer(
        (_) => Future.delayed(
          const Duration(seconds: 10), // Long delay to capture loading
          () => right(successResult),
        ),
      );

      await tester.pumpWidget(createMagicLinkVerifyWidget(token: testToken));
      await tester.pump(); // Don't settle to capture loading state

      // Assert - Should match golden file
      await SimpleWidgetTestHelper.expectGoldenFile(
        tester,
        'magic_link_verify_page_loading',
        finder: find.byType(MagicLinkVerifyPage),
        category: 'auth',
      );

      // Clean up pending timers
      await tester.pumpAndSettle(const Duration(seconds: 15));

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });

    testWidgets('should match golden file for success state', (tester) async {
      // Arrange
      final dummyUser = {
        'id': 'test-user-id',
        'email': 'test@example.com',
        'name': 'Test User',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final successResult = MagicLinkVerificationResult(
        token: 'test-jwt-token',
        refreshToken: 'test-refresh-token',
        expiresIn: 900,
        user: dummyUser,
        expiresAt: DateTime(2024, 12, 31, 23, 59, 59),
      );

      when(
        mockMagicLinkService.verifyMagicLink(
          testToken,
          inviteCode: anyNamed('inviteCode'),
        ),
      ).thenAnswer((_) async => right(successResult));

      await tester.pumpWidget(createMagicLinkVerifyWidget(token: testToken));

      // Wait for success state but don't navigate away
      await tester.pump(); // Process initial state
      await tester.pump(
        const Duration(milliseconds: 100),
      ); // Wait for async call
      await tester.pump(); // Process success state

      // Assert - Should match golden file
      await SimpleWidgetTestHelper.expectGoldenFile(
        tester,
        'magic_link_verify_page_success',
        finder: find.byType(MagicLinkVerifyPage),
        category: 'auth',
      );

      // Clean up pending timers
      await tester.pumpAndSettle(const Duration(seconds: 3));

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });

    testWidgets('should match golden file for error state', (tester) async {
      // Arrange
      when(
        mockMagicLinkService.verifyMagicLink(
          testToken,
          inviteCode: anyNamed('inviteCode'),
        ),
      ).thenAnswer(
        (_) async =>
            left(const ServerFailure(message: 'Invalid magic link token')),
      );

      await tester.pumpWidget(createMagicLinkVerifyWidget(token: testToken));

      // Wait for error state to show
      await tester.pump(); // Process initial state
      await tester.pump(
        const Duration(milliseconds: 100),
      ); // Wait for async call
      await tester.pump(); // Process error state

      // Assert - Should match golden file
      await SimpleWidgetTestHelper.expectGoldenFile(
        tester,
        'magic_link_verify_page_error',
        finder: find.byType(MagicLinkVerifyPage),
        category: 'auth',
      );

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });
  });

  group('MagicLinkVerifyPage - Email Retry Flow Tests', () {
    testWidgets('should accept email parameter in widget constructor', (
      tester,
    ) async {
      const testEmail = 'test@example.com';
      const testToken = 'test-token';

      // Simple test to verify widget accepts email parameter
      const widget = MagicLinkVerifyPage(token: testToken, email: testEmail);

      expect(widget.email, equals(testEmail));
      expect(widget.token, equals(testToken));
    });
  });

  // NOTE: Widget tests for invitation flow scenarios are covered by unit tests
  // due to complex provider dependency injection requirements.
  // See test/unit/auth/router_invitation_flow_test.dart and
  // test/unit/auth/magic_link_invitation_flow_test.dart for comprehensive
  // invitation flow testing including timing coordination and race condition prevention.
}
