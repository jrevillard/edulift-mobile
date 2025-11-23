// EduLift - Golden Test Wrapper
// Comprehensive wrapper for golden test execution with all variants

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderScope, Override;
import 'package:timezone/data/latest_all.dart' as tz;

import 'package:edulift/generated/l10n/app_localizations.dart';

import 'device_configurations.dart';
import 'theme_configurations.dart';
import 'golden_test_config.dart';
import 'tolerant_golden_comparator.dart';

/// Wrapper for executing golden tests with multiple variants
class GoldenTestWrapper {
  static bool _isTimezoneInitialized = false;

  /// Execute a test with custom tolerance if specified
  static Future<void> _expectGoldenWithTolerance({
    required Finder finder,
    required String goldenPath,
    double? customTolerance,
    GoldenTestWidgetType? widgetType,
  }) async {
    // Determine tolerance to use
    final tolerance =
        customTolerance ??
        (widgetType != null
            ? GoldenTestConfig.getToleranceForType(widgetType)
            : GoldenTestConfig.defaultTolerance);

    // Use tolerant comparator if tolerance > 0
    if (tolerance > 0.0) {
      final originalComparator = goldenFileComparator;
      final tolerantComparator = TolerantGoldenFileComparator(
        Uri.parse((goldenFileComparator as LocalFileComparator).basedir.path),
        tolerance: tolerance,
      );

      goldenFileComparator = tolerantComparator;
      try {
        await expectLater(finder, matchesGoldenFile(goldenPath));
      } finally {
        // Always restore original comparator
        goldenFileComparator = originalComparator;
      }
    } else {
      // Use default behavior for strict comparison
      await expectLater(finder, matchesGoldenFile(goldenPath));
    }
  }

  /// Initialize timezone database once for all golden tests
  /// Prevents "Tried to get location before initializing timezone database" errors
  static void _ensureTimezoneInitialized() {
    if (!_isTimezoneInitialized) {
      tz.initializeTimeZones();
      _isTimezoneInitialized = true;
    }
  }

  /// Test a widget with all device and theme variants
  static Future<void> testAllVariants({
    required WidgetTester tester,
    required Widget widget,
    required String testName,
    List<DeviceConfig>? devices,
    List<ThemeConfig>? themes,
    List<Locale>? locales,
    String category = 'widget',
    double? customTolerance,
    GoldenTestWidgetType? widgetType,
    List<Override>? providerOverrides,
    bool skipSettle = false,
  }) async {
    _ensureTimezoneInitialized();
    final testDevices = devices ?? GoldenTestConfig.defaultDevices;
    final testThemes = themes ?? GoldenTestConfig.defaultThemes;
    final testLocales = locales ?? GoldenTestConfig.defaultLocales;

    for (final device in testDevices) {
      for (final theme in testThemes) {
        for (final locale in testLocales) {
          await _testVariant(
            tester: tester,
            widget: widget,
            testName: testName,
            device: device,
            theme: theme,
            locale: locale,
            category: category,
            customTolerance: customTolerance,
            widgetType: widgetType,
            providerOverrides: providerOverrides,
            skipSettle: skipSettle,
          );
        }
      }
    }
  }

  /// Test a full screen with routing and navigation
  static Future<void> testScreen({
    required WidgetTester tester,
    required Widget screen,
    required String testName,
    List<DeviceConfig>? devices,
    List<ThemeConfig>? themes,
    List<Locale>? locales,
    double? customTolerance,
    GoldenTestWidgetType? widgetType,
    List<Override>? providerOverrides,
  }) async {
    await testAllVariants(
      tester: tester,
      widget: screen,
      testName: testName,
      devices: devices,
      themes: themes,
      locales: locales,
      category: 'screen',
      customTolerance: customTolerance,
      widgetType: widgetType,
      providerOverrides: providerOverrides,
    );
  }

  /// Test an isolated widget component
  static Future<void> testWidget({
    required WidgetTester tester,
    required Widget widget,
    required String testName,
    List<DeviceConfig>? devices,
    List<ThemeConfig>? themes,
    List<Locale>? locales,
    double? customTolerance,
    GoldenTestWidgetType? widgetType,
    List<Override>? providerOverrides,
    Size? constrainedSize,
    bool skipSettle = false,
  }) async {
    var testWidget = widget;

    // Constrain widget size if specified
    if (constrainedSize != null) {
      testWidget = SizedBox(
        width: constrainedSize.width,
        height: constrainedSize.height,
        child: widget,
      );
    }

    await testAllVariants(
      tester: tester,
      widget: testWidget,
      testName: testName,
      devices: devices,
      themes: themes,
      locales: locales,
      customTolerance: customTolerance,
      widgetType: widgetType,
      providerOverrides: providerOverrides,
      skipSettle: skipSettle,
    );
  }

  /// Test widget in loading state
  static Future<void> testLoadingState({
    required WidgetTester tester,
    required Widget widget,
    required String testName,
    List<DeviceConfig>? devices,
    List<ThemeConfig>? themes,
    double? customTolerance,
    List<Override>? providerOverrides,
    String category = 'loading',
  }) async {
    await testAllVariants(
      tester: tester,
      widget: widget,
      testName: '${testName}_loading',
      devices: devices,
      themes: themes,
      category: category,
      customTolerance: customTolerance,
      widgetType: GoldenTestWidgetType.animation, // Loading states are animated
      providerOverrides: providerOverrides,
      skipSettle: true, // Loading states have infinite animations
    );
  }

  /// Test widget in error state
  static Future<void> testErrorState({
    required WidgetTester tester,
    required Widget widget,
    required String testName,
    List<DeviceConfig>? devices,
    List<ThemeConfig>? themes,
    double? customTolerance,
    GoldenTestWidgetType? widgetType,
    List<Override>? providerOverrides,
    String category = 'error',
  }) async {
    await testAllVariants(
      tester: tester,
      widget: widget,
      testName: '${testName}_error',
      devices: devices,
      themes: themes,
      category: category,
      customTolerance: customTolerance,
      widgetType: widgetType ?? GoldenTestWidgetType.standard,
      providerOverrides: providerOverrides,
    );
  }

  /// Test widget in empty state
  static Future<void> testEmptyState({
    required WidgetTester tester,
    required Widget widget,
    required String testName,
    List<DeviceConfig>? devices,
    List<ThemeConfig>? themes,
    double? customTolerance,
    GoldenTestWidgetType? widgetType,
    List<Override>? providerOverrides,
    String category = 'widget',
  }) async {
    await testAllVariants(
      tester: tester,
      widget: widget,
      testName: '${testName}_empty',
      devices: devices,
      themes: themes,
      category: category,
      customTolerance: customTolerance,
      widgetType: widgetType ?? GoldenTestWidgetType.standard,
      providerOverrides: providerOverrides,
    );
  }

  /// Internal method to test a single variant
  static Future<void> _testVariant({
    required WidgetTester tester,
    required Widget widget,
    required String testName,
    required DeviceConfig device,
    required ThemeConfig theme,
    required Locale locale,
    required String category,
    double? customTolerance,
    GoldenTestWidgetType? widgetType,
    List<Override>? providerOverrides,
    bool skipSettle = false,
  }) async {
    // Set device size
    await tester.binding.setSurfaceSize(device.size);
    tester.view.devicePixelRatio = device.pixelRatio;

    // Build widget tree with theme and localization
    // Don't wrap in Scaffold if the widget is already a full screen with Scaffold
    final wrappedWidget = widget is Scaffold || category == 'screen'
        ? widget
        : Scaffold(body: widget);

    Widget testWidget = MaterialApp(
      theme: theme.themeData.copyWith(
        // Disable shadows for deterministic golden tests across environments
        shadowColor: Colors.transparent,
      ),
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: GoldenTestConfig.defaultLocales,
      home: MediaQuery(
        data: MediaQueryData(
          size: device.size,
          devicePixelRatio: device.pixelRatio,
          textScaler: TextScaler.linear(theme.fontScale),
        ),
        child: wrappedWidget,
      ),
    );

    // Always wrap with ProviderScope (required by many widgets)
    testWidget = ProviderScope(
      overrides: providerOverrides ?? [],
      child: testWidget,
    );

    // Pump widget
    await tester.pumpWidget(testWidget);
    if (skipSettle) {
      // For widgets with infinite animations (LoadingIndicator, etc)
      await tester.pump();
    } else {
      await tester.pumpAndSettle(GoldenTestConfig.settleDuration);
    }

    // Generate golden file path
    final goldenPath = GoldenTestConfig.getGoldenPath(
      testName: testName,
      category: category,
      deviceName: device.name,
      themeName: theme.name,
      locale: locale.languageCode,
    );

    // Use the first Scaffold found to avoid multiple Scaffold issues
    final scaffoldFinder = find.byType(Scaffold);
    await tester.pump();

    await _expectGoldenWithTolerance(
      finder: scaffoldFinder.first,
      goldenPath: goldenPath,
      customTolerance: customTolerance,
      widgetType: widgetType,
    );

    // Reset to default size
    await tester.binding.setSurfaceSize(null);
    tester.view.resetDevicePixelRatio();
  }

  /// Test multiple states of the same widget
  static Future<void> testStates({
    required WidgetTester tester,
    required Map<String, Widget> states,
    required String baseTestName,
    List<DeviceConfig>? devices,
    List<ThemeConfig>? themes,
    String category = 'widget',
    List<Override>? providerOverrides,
  }) async {
    for (final entry in states.entries) {
      await testAllVariants(
        tester: tester,
        widget: entry.value,
        testName: '${baseTestName}_${entry.key}',
        devices: devices,
        themes: themes,
        category: category,
        providerOverrides: providerOverrides,
      );
    }
  }

  // Convenience methods for common widget types

  /// Test text-heavy widgets with appropriate tolerance
  static Future<void> testTextWidget({
    required WidgetTester tester,
    required Widget widget,
    required String testName,
    List<DeviceConfig>? devices,
    List<ThemeConfig>? themes,
    List<Locale>? locales,
    List<Override>? providerOverrides,
  }) async {
    await testWidget(
      tester: tester,
      widget: widget,
      testName: testName,
      devices: devices,
      themes: themes,
      locales: locales,
      widgetType: GoldenTestWidgetType.text,
      providerOverrides: providerOverrides,
    );
  }

  /// Test complex widgets with appropriate tolerance
  static Future<void> testComplexWidget({
    required WidgetTester tester,
    required Widget widget,
    required String testName,
    List<DeviceConfig>? devices,
    List<ThemeConfig>? themes,
    List<Locale>? locales,
    List<Override>? providerOverrides,
  }) async {
    await testWidget(
      tester: tester,
      widget: widget,
      testName: testName,
      devices: devices,
      themes: themes,
      locales: locales,
      widgetType: GoldenTestWidgetType.complex,
      providerOverrides: providerOverrides,
    );
  }

  /// Quick test with default tolerance (0% - strict)
  static Future<void> testStrict({
    required WidgetTester tester,
    required Widget widget,
    required String testName,
    List<DeviceConfig>? devices,
    List<ThemeConfig>? themes,
    List<Locale>? locales,
    List<Override>? providerOverrides,
  }) async {
    await testWidget(
      tester: tester,
      widget: widget,
      testName: testName,
      devices: devices,
      themes: themes,
      locales: locales,
      widgetType: GoldenTestWidgetType.standard,
      providerOverrides: providerOverrides,
    );
  }
}
