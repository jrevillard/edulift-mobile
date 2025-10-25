// EduLift - Golden Test Wrapper
// Comprehensive wrapper for golden test execution with all variants

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderScope, Override;

import 'package:edulift/generated/l10n/app_localizations.dart';

import 'device_configurations.dart';
import 'theme_configurations.dart';
import 'golden_test_config.dart';

/// Wrapper for executing golden tests with multiple variants
class GoldenTestWrapper {
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
    List<Override>? providerOverrides,
    bool skipSettle = false,
  }) async {
    final testDevices = devices ?? GoldenTestConfig.defaultDevices;
    final testThemes = themes ?? GoldenTestConfig.defaultThemes;
    final testLocales = locales ?? [const Locale('en', 'US')];

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
      theme: theme.themeData,
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

    // Compare with golden file
    await expectLater(find.byType(Scaffold), matchesGoldenFile(goldenPath));

    // Reset to default size
    await tester.binding.setSurfaceSize(null);
    tester.view.resetDevicePixelRatio();
  }

  /// Test with specific test type configuration
  static Future<void> testWithType({
    required WidgetTester tester,
    required Widget widget,
    required String testName,
    required GoldenTestType testType,
    String category = 'widget',
    double? customTolerance,
    List<Override>? providerOverrides,
  }) async {
    final config = GoldenTestConfig.getConfigForTestType(testType);

    await testAllVariants(
      tester: tester,
      widget: widget,
      testName: testName,
      devices: config.devices,
      themes: config.themes,
      locales: config.locales,
      category: category,
      customTolerance: customTolerance,
      providerOverrides: providerOverrides,
    );
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

  /// Test widget with scrollable content
  static Future<void> testScrollable({
    required WidgetTester tester,
    required Widget widget,
    required String testName,
    List<DeviceConfig>? devices,
    List<ThemeConfig>? themes,
    List<double>? scrollPositions,
    List<Override>? providerOverrides,
  }) async {
    final positions = scrollPositions ?? [0.0, 0.5, 1.0];

    for (final position in positions) {
      final positionName = position == 0.0
          ? 'top'
          : position == 1.0
              ? 'bottom'
              : 'scroll_${(position * 100).toInt()}';

      await testAllVariants(
        tester: tester,
        widget: widget,
        testName: '${testName}_$positionName',
        devices: devices,
        themes: themes,
        providerOverrides: providerOverrides,
      );

      // Scroll to position for next iteration
      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty && position > 0.0) {
        await tester.drag(scrollable.first, Offset(0, -position * 500));
        await tester.pumpAndSettle();
      }
    }
  }
}
