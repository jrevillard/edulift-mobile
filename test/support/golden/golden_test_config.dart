// EduLift - Golden Test Configuration
// Centralized configuration for golden test behavior

import 'package:flutter/material.dart';
import 'device_configurations.dart';
import 'theme_configurations.dart';

/// Global configuration for golden tests
class GoldenTestConfig {
  // Pixel comparison tolerance (0.0 = exact match, 1.0 = any difference allowed)
  static const double defaultTolerance = 0.01;

  // Default device configurations
  static List<DeviceConfig> get defaultDevices =>
      DeviceConfigurations.defaultSet;

  // Default theme configurations
  static List<ThemeConfig> get defaultThemes => ThemeConfigurations.defaultSet;

  // Default pixel ratios to test
  static const List<double> defaultPixelRatios = [1.0, 2.0, 3.0];

  // Locales to test for internationalization
  static const List<Locale> defaultLocales = [
    Locale('en', 'US'), // English
    Locale('fr', 'FR'), // French
  ];

  // Golden file path configuration
  // Paths are relative to test file directory.
  // For tests in test/golden_tests/screens/ or test/golden_tests/widgets/,
  // we go up 1 level to test/golden_tests/, then to goldens/
  static const String goldenBasePath = '../goldens';
  static const String screenGoldensPath = '$goldenBasePath/screens';
  static const String widgetGoldensPath = '$goldenBasePath/widgets';
  static const String errorGoldensPath = '$goldenBasePath/errors';
  static const String loadingGoldensPath = '$goldenBasePath/loading';

  // Test execution configuration
  static const Duration pumpDuration = Duration(milliseconds: 100);
  static const Duration settleDuration = Duration(seconds: 5);
  static const int maxPumpIterations = 100;

  // Device configuration presets
  static Map<String, List<DeviceConfig>> get devicePresets => {
        'quick': DeviceConfigurations.defaultSet,
        'mobile': DeviceConfigurations.mobilePhones,
        'full': DeviceConfigurations.all,
        'small': DeviceConfigurations.smallPhones,
        'regular': DeviceConfigurations.regularPhones,
        'large': DeviceConfigurations.largePhones,
        'tablet': DeviceConfigurations.tablets,
      };

  // Theme configuration presets
  static Map<String, List<ThemeConfig>> get themePresets => {
        'quick': ThemeConfigurations.basic,
        'accessibility': ThemeConfigurations.accessibility,
        'high_contrast': ThemeConfigurations.highContrast,
        'full': ThemeConfigurations.all,
      };

  // Test variants configuration
  static const Map<String, dynamic> testVariants = {
    'include_loading_states': true,
    'include_error_states': true,
    'include_empty_states': true,
    'include_edge_cases': true,
  };

  // Performance thresholds
  static const Duration maxRenderTime = Duration(milliseconds: 100);
  static const int maxMemoryUsageMB = 512;

  // Accessibility configuration
  static const bool enforceAccessibility = true;
  static const double minTouchTargetSize = 48.0;
  static const double minTextContrast = 4.5;

  /// Get golden file path for a test
  static String getGoldenPath({
    required String testName,
    required String category,
    String? deviceName,
    String? themeName,
    String? locale,
  }) {
    final parts = <String>[testName];

    if (deviceName != null) parts.add(deviceName);
    if (themeName != null) parts.add(themeName);
    if (locale != null) parts.add(locale);

    final fileName = '${parts.join('_')}.png';

    switch (category) {
      case 'screen':
        return '$screenGoldensPath/$fileName';
      case 'widget':
        return '$widgetGoldensPath/$fileName';
      case 'error':
        return '$errorGoldensPath/$fileName';
      case 'loading':
        return '$loadingGoldensPath/$fileName';
      default:
        return '$goldenBasePath/$fileName';
    }
  }

  /// Generate all test variants for comprehensive testing
  static List<TestVariant> generateVariants({
    List<DeviceConfig>? devices,
    List<ThemeConfig>? themes,
    List<Locale>? locales,
  }) {
    final testDevices = devices ?? defaultDevices;
    final testThemes = themes ?? defaultThemes;
    final testLocales = locales ?? defaultLocales;

    final variants = <TestVariant>[];

    for (final device in testDevices) {
      for (final theme in testThemes) {
        for (final locale in testLocales) {
          variants.add(
            TestVariant(device: device, theme: theme, locale: locale),
          );
        }
      }
    }

    return variants;
  }

  /// Get configuration for specific test type
  static TestTypeConfig getConfigForTestType(GoldenTestType type) {
    switch (type) {
      case GoldenTestType.quick:
        return TestTypeConfig(
          devices: [DeviceConfigurations.iphone13],
          themes: [ThemeConfigurations.light],
          locales: [const Locale('en', 'US')],
        );

      case GoldenTestType.standard:
        return TestTypeConfig(
          devices: DeviceConfigurations.defaultSet,
          themes: ThemeConfigurations.defaultSet,
          locales: defaultLocales,
        );

      case GoldenTestType.accessibility:
        return TestTypeConfig(
          devices: DeviceConfigurations.defaultSet,
          themes: ThemeConfigurations.accessibility,
          locales: defaultLocales,
        );

      case GoldenTestType.comprehensive:
        return TestTypeConfig(
          devices: DeviceConfigurations.all,
          themes: ThemeConfigurations.all,
          locales: defaultLocales,
        );
    }
  }
}

/// Test variant combining device, theme, and locale
class TestVariant {
  const TestVariant({
    required this.device,
    required this.theme,
    required this.locale,
  });

  final DeviceConfig device;
  final ThemeConfig theme;
  final Locale locale;

  String get name => '${device.name}_${theme.name}_${locale.languageCode}';

  @override
  String toString() => name;
}

/// Test type configuration
class TestTypeConfig {
  const TestTypeConfig({
    required this.devices,
    required this.themes,
    required this.locales,
  });

  final List<DeviceConfig> devices;
  final List<ThemeConfig> themes;
  final List<Locale> locales;
}

/// Golden test types
enum GoldenTestType {
  quick, // Single device, single theme, single locale
  standard, // Default devices, default themes, all locales
  accessibility, // All font scales and high contrast themes
  comprehensive, // All combinations
}
