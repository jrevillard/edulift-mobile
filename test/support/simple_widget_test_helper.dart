// Simple Widget Test Helper
// Provides basic widget testing utilities with proper provider initialization

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import '../support/test_di_initializer.dart';
import 'test_provider_overrides.dart';
// Removed unused imports

/// Device configuration for tests
class DeviceConfiguration {
  const DeviceConfiguration({required this.name, required this.size});

  final String name;
  final Size size;
}

class SimpleWidgetTestHelper {
  /// Create test widget with properly initialized providers
  static Widget createTestApp({
    required Widget child,
    List<Override>? overrides,
  }) {
    return ProviderScope(
      overrides: [...(_getDefaultProviderOverrides()), ...(overrides ?? [])],
      child: MaterialApp(
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

  /// Create test widget for pages that already have their own Scaffold
  static Widget createTestAppForPage({
    required Widget child,
    List<Override>? overrides,
  }) {
    // Create a simple GoRouter for testing navigation with parent/child routes
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Home Page'))),
          routes: [GoRoute(path: '/form', builder: (context, state) => child)],
        ),
      ],
      initialLocation: '/form', // Start at the form page
    );

    return ProviderScope(
      overrides: [...(_getDefaultProviderOverrides()), ...(overrides ?? [])],
      child: MaterialApp.router(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
  }

  /// Create test widget with GoRouter context for navigation testing
  static Widget createTestAppWithNavigation({
    required Widget child,
    List<Override>? overrides,
    String initialRoute = '/',
    List<GoRoute>? additionalRoutes,
  }) {
    // Create routes including the widget under test and common navigation routes
    final routes = <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Home Page'))),
        routes: [
          GoRoute(
            path: 'family/invite',
            builder: (context, state) => Scaffold(body: child),
          ),
        ],
      ),
      // Add any additional routes provided
      ...(additionalRoutes ?? []),
    ];

    final router = GoRouter(routes: routes, initialLocation: initialRoute);

    return ProviderScope(
      overrides: [...(_getDefaultProviderOverrides()), ...(overrides ?? [])],
      child: MaterialApp.router(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
  }

  /// Simple test setup
  static Future<void> initialize() async {
    // Initialize dependency injection for tests
    try {
      // TestDIInitializer.initialize() now returns a ProviderContainer
      TestDIInitializer.initialize();
    } catch (e) {
      // Continue with basic setup if DI fails
    }
  }

  /// Simple teardown
  static Future<void> tearDown() async {
    // Clean up dependency injection
    try {
      await TestDIInitializer.tearDown();
    } catch (e) {
      // Ignore teardown errors
    }
  }

  /// Test accessibility (simplified)
  static Future<void> expectAccessibility(
    WidgetTester tester, {
    List<String>? requiredLabels,
  }) async {
    if (requiredLabels != null) {
      for (final label in requiredLabels) {
        expect(
          find.bySemanticsLabel(label),
          findsOneWidget,
          reason: 'Missing semantic label: $label',
        );
      }
    }
  }

  /// Test golden files (simplified)
  static Future<void> expectGoldenFile(
    WidgetTester tester,
    String goldenKey, {
    Finder? finder,
    String category = 'family',
    List<DeviceConfiguration>? devices,
  }) async {
    final targetFinder = finder ?? find.byType(MaterialApp);
    // Use absolute path by finding the project root programmatically
    final scriptPath = Platform.script.toFilePath();
    final projectRoot = scriptPath.contains('/mobile_app/')
        ? scriptPath.substring(
            0,
            scriptPath.indexOf('/mobile_app/') + '/mobile_app'.length,
          )
        : Directory.current.path;
    final goldenPath = '$projectRoot/test/goldens/$category/$goldenKey.png';

    await expectLater(targetFinder, matchesGoldenFile(goldenPath));
  }

  /// Create simple test widget
  static Widget createSimpleTestWidget({
    required Widget child,
    List<Override>? providerOverrides,
  }) {
    return createTestApp(child: child, overrides: providerOverrides);
  }

  /// Alias for createSimpleTestWidget for backward compatibility
  static Widget createTestWidget({
    required Widget child,
    List<Override>? providerOverrides,
  }) {
    return createSimpleTestWidget(
      child: child,
      providerOverrides: providerOverrides,
    );
  }

  /// Get default provider overrides using expert-recommended type-safe pattern
  static List<Override> _getDefaultProviderOverrides() {
    // Use centralized type-safe provider overrides
    return TestProviderOverrides.common;
  }

  /// Verify no exceptions occurred
  static void verifyNoExceptions(WidgetTester tester) {
    final exception = tester.takeException();
    if (exception != null) {
      fail('Unexpected exception during test: $exception');
    }
  }

  /// Pump and settle with timeout
  static Future<void> pumpAndSettleWithTimeout(
    WidgetTester tester, {
    Duration timeout = const Duration(
      seconds: 3,
    ), // Reduced timeout for faster tests
  }) async {
    try {
      // Use a more robust settling approach
      await tester.pumpAndSettle(timeout);
    } catch (e) {
      debugPrint('pumpAndSettle timeout, using fallback: $e');
      // Fallback: Multiple pumps with delays for animation-heavy widgets
      for (var i = 0; i < 3; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Final attempt to settle any remaining animations
      try {
        await tester.pumpAndSettle(const Duration(seconds: 1));
      } catch (_) {
        // If still failing, just ensure the widget tree is updated
        await tester.pump();
      }
    }
  }

  /// Safe tap method that checks if widget is hittable
  static Future<void> safeTap(
    WidgetTester tester,
    Finder finder, {
    bool warnIfMissed = false,
  }) async {
    try {
      // Ensure widget is visible before tapping
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      await tester.tap(finder, warnIfMissed: warnIfMissed);
    } catch (e) {
      debugPrint('SafeTap failed, trying alternative approach: $e');
      // Fallback: try scrolling to make widget visible
      try {
        await tester.scrollUntilVisible(finder, 100.0);
        await tester.pumpAndSettle();
        await tester.tap(finder, warnIfMissed: false);
      } catch (fallbackError) {
        debugPrint('SafeTap fallback also failed: $fallbackError');
        // Final attempt without warnIfMissed
        await tester.tap(finder, warnIfMissed: false);
      }
    }
  }
}
