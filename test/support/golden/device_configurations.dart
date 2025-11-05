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

  static const oppoFindX2Neo = DeviceConfig(
    name: 'oppo_find_x2_neo',
    size: Size(360, 800), // 1080x2400 physical -> ~360x800 logical
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

  /// UNIQUE centralized configuration for ALL tests
  /// SINGLE source of truth - tests ALL important devices
  static List<DeviceConfig> get defaultSet => [
    iphoneSE, // Small iOS (320x568)
    pixel4a, // Small Android (360x640)
    iphone13, // Regular iOS (390x844)
    pixel6, // Regular Android (412x915)
    galaxyS21, // Android (360x800)
    oppoFindX2Neo, // User's device (360x800 Android 12) - IMPORTANT
    iPadPro, // Tablet iOS (834x1194)
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
