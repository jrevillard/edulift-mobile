// EduLift - Theme Configurations for Golden Tests
// Comprehensive theme variants for visual regression testing

import 'package:flutter/material.dart';

/// Theme configuration for golden tests
class ThemeConfig {
  const ThemeConfig({
    required this.name,
    required this.themeData,
    this.fontScale = 1.0,
  });

  final String name;
  final ThemeData themeData;
  final double fontScale;

  @override
  String toString() => '$name (${fontScale}x font)';
}

/// Complete theme configurations for golden tests
class ThemeConfigurations {
  // Base light theme
  static final light = ThemeConfig(
    name: 'light',
    themeData: ThemeData.light(useMaterial3: true),
  );

  // Base dark theme
  static final dark = ThemeConfig(
    name: 'dark',
    themeData: ThemeData.dark(useMaterial3: true),
  );

  // High contrast light theme for accessibility
  static final highContrastLight = ThemeConfig(
    name: 'high_contrast_light',
    themeData: ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Colors.black,
        secondary: Colors.black87,
        error: Color(0xFFD32F2F),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black, fontSize: 16),
        bodyMedium: TextStyle(color: Colors.black, fontSize: 14),
        titleLarge: TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );

  // High contrast dark theme for accessibility
  static final highContrastDark = ThemeConfig(
    name: 'high_contrast_dark',
    themeData: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Colors.white,
        secondary: Colors.white70,
        error: Color(0xFFEF5350),
        surface: Colors.black,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
        bodyMedium: TextStyle(color: Colors.white, fontSize: 14),
        titleLarge: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );

  // Accessibility: Small font scale (0.8x)
  static final lightSmallFont = ThemeConfig(
    name: 'light_small_font',
    themeData: ThemeData.light(useMaterial3: true),
    fontScale: 0.8,
  );

  // Accessibility: Normal font scale (1.0x) - default
  static final lightNormalFont = ThemeConfig(
    name: 'light_normal_font',
    themeData: ThemeData.light(useMaterial3: true),
  );

  // Accessibility: Large font scale (1.3x)
  static final lightLargeFont = ThemeConfig(
    name: 'light_large_font',
    themeData: ThemeData.light(useMaterial3: true),
    fontScale: 1.3,
  );

  // Accessibility: Extra large font scale (1.5x)
  static final lightExtraLargeFont = ThemeConfig(
    name: 'light_extra_large_font',
    themeData: ThemeData.light(useMaterial3: true),
    fontScale: 1.5,
  );

  // Custom EduLift brand theme
  static final eduLiftBrand = ThemeConfig(
    name: 'edulift_brand',
    themeData: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1976D2), // EduLift blue
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1976D2),
        ),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16),
        bodyMedium: TextStyle(fontSize: 14),
      ),
    ),
  );

  // Theme groups for different test scenarios

  /// Basic themes for quick tests
  static List<ThemeConfig> get basic => [light, dark];

  /// Accessibility themes with font scaling
  static List<ThemeConfig> get accessibility => [
    lightSmallFont,
    lightNormalFont,
    lightLargeFont,
    lightExtraLargeFont,
  ];

  /// High contrast themes for accessibility
  static List<ThemeConfig> get highContrast => [
    highContrastLight,
    highContrastDark,
  ];

  /// All themes for comprehensive testing
  static List<ThemeConfig> get all => [
    light,
    dark,
    highContrastLight,
    highContrastDark,
    ...accessibility,
    eduLiftBrand,
  ];

  /// Default subset for fast tests
  static List<ThemeConfig> get defaultSet => [light, dark];

  /// Extended set for regression tests
  static List<ThemeConfig> get extendedSet => [
    light,
    dark,
    lightLargeFont,
    highContrastLight,
  ];
}
