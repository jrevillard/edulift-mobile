// Widget Test Base (2025 Best Practices)
//
// Provides comprehensive widget testing foundation:
// - Proper DI setup and teardown
// - Accessibility testing integration
// - Golden test support
// - Performance monitoring
// - Memory leak detection
// - Responsive testing utilities

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:edulift/generated/l10n/app_localizations.dart';
import 'package:edulift/core/presentation/themes/app_theme.dart';

import 'test_environment.dart';
import 'accessibility_test_helper.dart';
import 'golden_test_helper.dart' as golden_test_helper;
import 'golden/device_configurations.dart';
import '../test_mocks/mock_factories.dart';
import 'test_screen_sizes.dart';
import 'simple_widget_test_helper.dart';

/// Base class for widget tests with comprehensive testing utilities
abstract class WidgetTestBase {
  /// Widget tester instance
  late WidgetTester tester;

  /// Provider overrides for testing
  final List<Override> providerOverrides = [];

  /// Setup method called before each test
  Future<void> setUp(WidgetTester widgetTester) async {
    tester = widgetTester;

    // Initialize test environment
    await TestEnvironment.initialize();

    // Setup accessibility testing
    AccessibilityTestHelper.configure();

    // Configure mocks
    await configureMocks();

    // Setup provider overrides
    await configureProviders();
  }

  /// Teardown method called after each test
  Future<void> tearDown() async {
    // Reset mocks
    MockConfigurator.resetAll();

    // Clear provider overrides
    providerOverrides.clear();

    // Cleanup test environment
    await TestEnvironment.cleanup();

    // Reset screen size to ensure clean state
    await TestScreenSizes.resetScreenSize(tester);
  }

  /// Configure mocks for testing (override in subclasses)
  Future<void> configureMocks() async {
    // Default: configure happy path
    MockConfigurator.configureHappyPath();
  }

  /// Configure provider overrides (override in subclasses)
  Future<void> configureProviders() async {
    // Implement in subclasses
  }

  /// Create test widget with full app context
  Widget createTestApp({
    required Widget child,
    List<Override>? additionalOverrides,
    GoRouter? router,
    Locale? locale,
    ThemeData? theme,
  }) {
    final testRouter = router ?? _createTestRouter(child);

    return ProviderScope(
      overrides: [...providerOverrides, ...?additionalOverrides],
      child: MaterialApp.router(
        routerConfig: testRouter,
        theme: theme ?? AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale ?? const Locale('en'),
      ),
    );
  }

  /// Create test widget for isolated component testing
  Widget createComponentTest({
    required Widget child,
    List<Override>? additionalOverrides,
    Locale? locale,
    ThemeData? theme,
  }) {
    return ProviderScope(
      overrides: [...providerOverrides, ...?additionalOverrides],
      child: MaterialApp(
        theme: theme ?? AppTheme.lightTheme,
        locale: locale ?? const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );
  }

  /// Pump widget with comprehensive setup
  Future<void> pumpTestWidget(
    Widget widget, {
    Duration? duration,
    bool settlePolicy = true,
  }) async {
    await tester.pumpWidget(widget);

    if (settlePolicy) {
      await tester.pumpAndSettle(duration ?? const Duration(seconds: 10));
    } else if (duration != null) {
      await tester.pump(duration);
    }
  }

  /// Pump and settle with timeout and error handling
  Future<void> pumpAndSettleSafely({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      await tester.pumpAndSettle(timeout);
    } catch (e) {
      // Log the error and continue
      debugPrint('PumpAndSettle failed: $e');
      // Pump once more to ensure we're in a stable state
      await tester.pump();
    }
  }

  /// Verify no exceptions occurred during test
  void verifyNoExceptions() {
    final exception = tester.takeException();
    if (exception != null) {
      fail('Unexpected exception during test: $exception');
    }
  }

  /// Run accessibility tests
  Future<void> expectAccessibility({List<String>? requiredLabels}) async {
    await AccessibilityTestHelper.runAccessibilityTestSuite(
      tester,
      requiredLabels: requiredLabels ?? [],
    );
  }

  /// Test golden files for the widget
  Future<void> expectGolden(
    String goldenKey, {
    Finder? finder,
    List<DeviceConfig>? devices,
  }) async {
    final targetFinder = finder ?? find.byType(MaterialApp);
    await golden_test_helper.GoldenTestHelper.expectGoldenForDevices(
      tester,
      targetFinder,
      goldenKey,
      devices: devices,
    );
  }

  /// Test responsive behavior across different screen sizes using standardized TestScreenSizes
  ///
  /// Example:
  /// ```dart
  /// await expectResponsiveBehavior(
  ///   MyWidget(),
  ///   deviceTests: {
  ///     TestScreenSizes.iphone14: () => expect(find.text('Mobile'), findsOneWidget),
  ///     TestScreenSizes.ipad: () => expect(find.text('Tablet'), findsOneWidget),
  ///   },
  /// );
  /// ```
  Future<void> expectResponsiveBehavior(
    Widget widget, {
    Map<TestDeviceConfiguration, void Function()>? deviceTests,
    // Legacy support for raw Size objects (deprecated - use deviceTests instead)
    Map<Size, void Function()>? sizeTests,
  }) async {
    if (deviceTests != null) {
      // Preferred approach using TestScreenSizes constants
      await TestScreenSizes.testMultipleSizes(
        tester,
        widget,
        devices: deviceTests.keys.toList(),
        test: (device) async {
          final test = deviceTests[device];
          if (test != null) {
            test();
          }
        },
      );
    } else if (sizeTests != null) {
      // Legacy support - convert to TestDeviceConfiguration
      debugPrint(
        'Warning: Using deprecated sizeTests. Consider using deviceTests with TestScreenSizes constants.',
      );

      for (final entry in sizeTests.entries) {
        final size = entry.key;
        final test = entry.value;

        // Set screen size using deprecated approach
        await tester.binding.setSurfaceSize(size);

        // Rebuild widget with new size
        await pumpTestWidget(widget);

        // Run size-specific test
        test();
      }

      // Reset to default size
      await TestScreenSizes.resetScreenSize(tester);
    } else {
      throw ArgumentError('Either deviceTests or sizeTests must be provided');
    }
  }

  /// Test loading states
  Future<void> expectLoadingState(
    Widget widget,
    Future<void> Function() triggerLoading,
  ) async {
    await pumpTestWidget(widget);

    // Trigger loading state
    await triggerLoading();
    await tester.pump(); // Single pump to see loading state

    // Verify loading indicator is shown
    expect(
      find.byType(CircularProgressIndicator),
      findsAtLeastNWidgets(1),
      reason: 'Loading indicator should be visible',
    );

    // Wait for loading to complete
    await pumpAndSettleSafely();

    // Verify loading indicator is gone
    expect(
      find.byType(CircularProgressIndicator),
      findsNothing,
      reason: 'Loading indicator should be hidden after completion',
    );
  }

  /// Test error states
  Future<void> expectErrorState(
    Widget widget,
    String expectedErrorMessage,
  ) async {
    await pumpTestWidget(widget);

    // Verify error message is displayed
    expect(
      find.text(expectedErrorMessage),
      findsOneWidget,
      reason: 'Error message "$expectedErrorMessage" should be visible',
    );
  }

  /// Test form validation
  Future<void> expectFormValidation(
    Map<Finder, String> fieldValidations,
  ) async {
    for (final entry in fieldValidations.entries) {
      final field = entry.key;
      final expectedError = entry.value;

      // Clear field and submit to trigger validation
      await tester.enterText(field, '');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Verify validation error appears
      expect(
        find.text(expectedError),
        findsOneWidget,
        reason: 'Validation error "$expectedError" should be shown',
      );
    }
  }

  /// Performance testing utilities
  Future<void> measurePerformance(
    String testName,
    Future<void> Function() testFunction,
  ) async {
    final stopwatch = Stopwatch()..start();

    await testFunction();

    stopwatch.stop();
    debugPrint('Performance [$testName]: ${stopwatch.elapsedMilliseconds}ms');

    // Assert performance threshold (customize as needed)
    expect(
      stopwatch.elapsedMilliseconds,
      lessThan(5000), // 5 seconds max for widget tests
      reason:
          'Test "$testName" took too long: ${stopwatch.elapsedMilliseconds}ms',
    );
  }

  /// Create default test router
  GoRouter _createTestRouter(Widget home) {
    return GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => home),
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
        // Add more routes as needed for testing
      ],
    );
  }
}

/// Mixin for common widget test patterns
mixin WidgetTestPatterns {
  /// Test button interactions
  Future<void> testButtonInteraction(
    WidgetTester tester,
    Finder buttonFinder,
    void Function() verifyAction,
  ) async {
    // Verify button exists and is enabled
    expect(buttonFinder, findsOneWidget);

    final button = tester.widget(buttonFinder);
    if (button is ElevatedButton) {
      expect(button.onPressed, isNotNull, reason: 'Button should be enabled');
    }

    // Tap button
    await tester.tap(buttonFinder);
    await SimpleWidgetTestHelper.pumpAndSettleWithTimeout(tester);

    // Verify expected action occurred
    verifyAction();
  }

  /// Test navigation behavior
  Future<void> testNavigation(
    WidgetTester tester,
    Finder triggerFinder,
    Type expectedPageType,
  ) async {
    await tester.tap(triggerFinder);
    await SimpleWidgetTestHelper.pumpAndSettleWithTimeout(tester);

    expect(
      find.byType(expectedPageType),
      findsOneWidget,
      reason: 'Should navigate to ${expectedPageType.toString()}',
    );
  }

  /// Test text input behavior
  Future<void> testTextInput(
    WidgetTester tester,
    Finder textFieldFinder,
    String inputText,
    String expectedResult,
  ) async {
    await tester.enterText(textFieldFinder, inputText);
    await tester.pump();

    expect(
      find.text(expectedResult),
      findsOneWidget,
      reason: 'Text field should contain "$expectedResult"',
    );
  }
}
