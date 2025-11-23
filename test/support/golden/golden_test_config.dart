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
  static const String goldenBasePath = '../test/goldens';
  static const String screenGoldensPath = '$goldenBasePath/screens';
  static const String widgetGoldensPath = '$goldenBasePath/widgets';

  // Test execution configuration
  static const Duration settleDuration = Duration(seconds: 5);

  // Pixel tolerance configuration (percentage)
  // Based on industry best practices for Flutter golden tests

  /// Default tolerance for most tests (0.5% = reasonable tolerance)
  static const double defaultTolerance = 0.5; // 0.5%

  /// Tolerance for text-heavy widgets (handles anti-aliasing differences)
  static const double textTolerance = 0.2; // 0.2%

  /// Tolerance for complex widgets with gradients/shadows
  static const double complexTolerance = 0.5; // 0.5%

  /// Tolerance for animations or dynamic content (use sparingly)
  static const double animationTolerance = 1.0; // 1.0%

  /// Get tolerance for specific widget types
  static double getToleranceForType(GoldenTestWidgetType type) {
    switch (type) {
      case GoldenTestWidgetType.text:
        return textTolerance;
      case GoldenTestWidgetType.complex:
        return complexTolerance;
      case GoldenTestWidgetType.animation:
        return animationTolerance;
      case GoldenTestWidgetType.standard:
        return defaultTolerance;
    }
  }

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
}

/// Widget types for tolerance configuration
enum GoldenTestWidgetType {
  standard, // Most UI components - 0.5% tolerance
  text, // Text-heavy widgets - 0.2% tolerance
  complex, // Complex widgets with gradients/shadows - 0.5% tolerance
  animation, // Animated or dynamic content - 1.0% tolerance (use sparingly)
}
