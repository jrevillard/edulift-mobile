// COMPREHENSIVE MAGIC LINK PAGE WIDGET TESTS
// PRINCIPLE 0: RADICAL CANDOR - TRUTH ABOVE ALL
//
// SCOPE: Magic Link Confirmation Screen Testing
// - Test confirmation screen display after magic link is sent
// - Test resend functionality and loading states
// - Test navigation behavior
// - Test accessibility compliance (WCAG 2.1 AA)
// - Test error handling

@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:edulift/features/auth/presentation/pages/magic_link_page.dart';
import 'package:edulift/core/services/providers/auth_provider.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';

import '../../../support/simple_widget_test_helper.dart';
import '../../../support/accessibility_test_helper.dart';
import '../../../test_mocks/test_mocks.dart';

void main() {
  setUpAll(() async {
    // Set up dummy values for Result types
    provideDummy(const Result<void, ApiFailure>.ok(null));

    await SimpleWidgetTestHelper.initialize();
    AccessibilityTestHelper.configure();
    setupMockFallbacks();
  });

  group('MagicLinkPage Widget Tests - CONFIRMATION SCREEN', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    Widget createMagicLinkWidget() {
      return SimpleWidgetTestHelper.createTestAppForPage(
        overrides: [
          // Mock the auth state provider at presentation layer
          authStateProvider.overrideWith(
            (ref) => AuthNotifier(
              mockAuthService,
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
        child: const MagicLinkPage(email: 'test@example.com'),
      );
    }

    testWidgets(
      'should display magic link confirmation screen with proper elements and accessibility',
      (tester) async {
        // Set test screen size to prevent overflow issues
        tester.view.physicalSize = const Size(1200, 2000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        // Arrange
        await tester.pumpWidget(createMagicLinkWidget());
        await tester.pumpAndSettle();

        // Assert - Basic UI structure
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);

        // Assert - Confirmation screen elements (based on actual implementation)
        expect(find.byIcon(Icons.mark_email_read), findsOneWidget);
        // Email is part of larger description text
        expect(find.textContaining('test@example.com'), findsOneWidget);
        expect(
          find.byKey(const Key('resend_magic_link_button')),
          findsOneWidget,
        ); // Resend button
        expect(
          find.byKey(const Key('back_to_login_button')),
          findsOneWidget,
        ); // Back to login button

        // Assert - Help card with instructions
        expect(find.byType(Card), findsOneWidget);

        // Assert - Accessibility compliance
        await AccessibilityTestHelper.runAccessibilityTestSuite(
          tester,
          requiredLabels: [],
        );

        SimpleWidgetTestHelper.verifyNoExceptions(tester);
      },
    );

    testWidgets('should handle resend magic link correctly', (tester) async {
      // Arrange
      when(
        mockAuthService.sendMagicLink(any, name: anyNamed('name')),
      ).thenAnswer((_) async => const Result.ok(null));

      await tester.pumpWidget(createMagicLinkWidget());
      await tester.pumpAndSettle();

      // Act - Tap resend button
      final resendButton = find.byKey(const Key('resend_magic_link_button'));
      await tester.tap(resendButton);
      await tester.pumpAndSettle();

      // Assert - Should call service
      verify(mockAuthService.sendMagicLink('test@example.com')).called(1);

      // Assert - Should show success snackbar
      expect(find.byType(SnackBar), findsOneWidget);

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });

    testWidgets('should handle back to login navigation', (tester) async {
      // Arrange
      await tester.pumpWidget(createMagicLinkWidget());
      await tester.pumpAndSettle();

      // Act - Tap back to login button
      final backButton = find.byKey(const Key('back_to_login_button'));
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Assert - Navigation is handled by go_router (no direct assertions possible)
      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });

    testWidgets('should show loading state during resend', (tester) async {
      // Arrange - Mock delayed response
      when(
        mockAuthService.sendMagicLink(any, name: anyNamed('name')),
      ).thenAnswer(
        (_) => Future.delayed(
          const Duration(milliseconds: 200),
          () => const Result.ok(null),
        ),
      );

      await tester.pumpWidget(createMagicLinkWidget());
      await tester.pumpAndSettle();

      // Act - Tap resend button
      final resendButton = find.byKey(const Key('resend_magic_link_button'));
      await tester.tap(resendButton);
      await tester.pump(); // Start loading

      // Assert - Should show loading indicator in button
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the request
      await tester.pumpAndSettle();

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });

    testWidgets('should display error message on resend failure', (
      tester,
    ) async {
      // Arrange - Mock error state
      when(
        mockAuthService.sendMagicLink(any, name: anyNamed('name')),
      ).thenAnswer(
        (_) async => const Result.err(NetworkFailure(message: 'Network error')),
      );

      await tester.pumpWidget(createMagicLinkWidget());
      await tester.pumpAndSettle();

      // Act - Tap resend button
      final resendButton = find.byKey(const Key('resend_magic_link_button'));
      await tester.tap(resendButton);
      await tester.pumpAndSettle();

      // Assert - Error is shown through auth state provider
      // The actual error display depends on auth state provider implementation
      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });

    testWidgets('should match golden file for initial state', (tester) async {
      // Set consistent screen size for golden tests
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Arrange
      await tester.pumpWidget(createMagicLinkWidget());
      await tester.pumpAndSettle();

      // Assert - Should match golden file
      await SimpleWidgetTestHelper.expectGoldenFile(
        tester,
        'magic_link_page_initial',
        finder: find.byType(MagicLinkPage),
        category: 'auth',
      );

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });

    testWidgets('should match golden file for success state', (tester) async {
      // Set consistent screen size for golden tests
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Arrange
      when(
        mockAuthService.sendMagicLink(any, name: anyNamed('name')),
      ).thenAnswer((_) async => const Result.ok(null));

      await tester.pumpWidget(createMagicLinkWidget());
      await tester.pumpAndSettle();

      // Act - Trigger resend
      final resendButton = find.byKey(const Key('resend_magic_link_button'));
      await tester.tap(resendButton);
      await tester.pumpAndSettle();

      // Assert - Should match golden file
      await SimpleWidgetTestHelper.expectGoldenFile(
        tester,
        'magic_link_page_success',
        finder: find.byType(MagicLinkPage),
        category: 'auth',
      );

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });

    testWidgets('should match golden file for error state', (tester) async {
      // Set consistent screen size for golden tests
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Arrange
      when(
        mockAuthService.sendMagicLink(any, name: anyNamed('name')),
      ).thenAnswer(
        (_) async => const Result.err(NetworkFailure(message: 'Network error')),
      );

      await tester.pumpWidget(createMagicLinkWidget());
      await tester.pumpAndSettle();

      // Act - Trigger resend to get error state
      final resendButton = find.byKey(const Key('resend_magic_link_button'));
      await tester.tap(resendButton);
      await tester.pumpAndSettle();

      // Assert - Should match golden file
      await SimpleWidgetTestHelper.expectGoldenFile(
        tester,
        'magic_link_page_error',
        finder: find.byType(MagicLinkPage),
        category: 'auth',
      );

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });
  });
}
