// EduLift - Device Configurations for Golden Tests
// Complete device matrix for comprehensive UI testing

import 'package:flutter/material.dart';

/// Device configuration for golden tests
class DeviceConfig {
  const DeviceConfig({
    required this.name,
    required this.size,
    required this.pixelRatio,
    required this.platform,
  });

  final String name;
  final Size size;
  final double pixelRatio;
  final TargetPlatform platform;

  @override
  String toString() => '$name (${size.width}×${size.height} @${pixelRatio}x)';
}

/// Complete device configurations for golden tests
class DeviceConfigurations {
  // Small phones (320-375px)
  static const iphoneSE = DeviceConfig(
    name: 'iphone_se',
    size: Size(320, 568),
    pixelRatio: 2.0,
    platform: TargetPlatform.iOS,
  );

  static const pixel4a = DeviceConfig(
    name: 'pixel_4a',
    size: Size(360, 640),
    pixelRatio: 2.0,
    platform: TargetPlatform.android,
  );

  // Regular phones (375-414px)
  static const iphone13 = DeviceConfig(
    name: 'iphone_13',
    size: Size(390, 844),
    pixelRatio: 3.0,
    platform: TargetPlatform.iOS,
  );

  static const pixel6 = DeviceConfig(
    name: 'pixel_6',
    size: Size(412, 915),
    pixelRatio: 2.625,
    platform: TargetPlatform.android,
  );

  static const galaxyS21 = DeviceConfig(
    name: 'galaxy_s21',
    size: Size(360, 800),
    pixelRatio: 3.0,
    platform: TargetPlatform.android,
  );

  // Large phones (428+px)
  static const iphoneProMax = DeviceConfig(
    name: 'iphone_14_pro_max',
    size: Size(428, 926),
    pixelRatio: 3.0,
    platform: TargetPlatform.iOS,
  );

  // Tablets
  static const iPadPro = DeviceConfig(
    name: 'ipad_pro_11',
    size: Size(834, 1194),
    pixelRatio: 2.0,
    platform: TargetPlatform.iOS,
  );

  // Device groups
  static List<DeviceConfig> get smallPhones => [iphoneSE, pixel4a];

  static List<DeviceConfig> get regularPhones => [iphone13, pixel6, galaxyS21];

  static List<DeviceConfig> get largePhones => [iphoneProMax];

  static List<DeviceConfig> get mobilePhones => [
    ...smallPhones,
    ...regularPhones,
    ...largePhones,
  ];

  static List<DeviceConfig> get tablets => [iPadPro];

  static List<DeviceConfig> get all => [...mobilePhones, ...tablets];

  /// Default subset for fast tests (iOS only - existing tests)
  static List<DeviceConfig> get defaultSet => [
    iphoneSE,    // Small iOS
    iphone13,    // Regular iOS
    iPadPro,     // Tablet iOS
  ];

  /// Cross-platform subset for comprehensive tests (iOS + Android)
  static List<DeviceConfig> get crossPlatformSet => [
    iphoneSE,    // Small iOS
    pixel4a,     // Small Android
    iphone13,    // Regular iOS
    pixel6,      // Regular Android
    iPadPro,     // Tablet iOS
  ];

  /// Extended set for regression tests
  static List<DeviceConfig> get extendedSet => [
    ...smallPhones,
    ...regularPhones,
    largePhones.first,
    ...tablets,
  ];
}

/// Test configuration combining device, theme, and pixel ratio
class TestConfiguration {
  const TestConfiguration({
    required this.device,
    required this.themeName,
    this.pixelRatio,
    this.name,
  });

  final DeviceConfig device;
  final String themeName;
  final double? pixelRatio;
  final String? name;

  String get configName => name ?? '${device.name}_$themeName';

  @override
  String toString() => configName;
}
