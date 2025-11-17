// EduLift - Golden Test Configuration
// Centralized configuration for golden test behavior

import 'package:flutter/material.dart';
import 'device_configurations.dart';
import 'theme_configurations.dart';

/// Global configuration for golden tests
class GoldenTestConfig {
  // Default device configurations
  static List<DeviceConfig> get defaultDevices =>
      DeviceConfigurations.defaultSet;

  // Default theme configurations
  static List<ThemeConfig> get defaultThemes => ThemeConfigurations.defaultSet;

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

  // Test execution configuration
  static const Duration settleDuration = Duration(seconds: 5);

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
      default:
        return '$goldenBasePath/$fileName';
    }
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
          devices: DeviceConfigurations.defaultSet,
          themes: ThemeConfigurations.all,
          locales: defaultLocales,
        );
    }
  }
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
