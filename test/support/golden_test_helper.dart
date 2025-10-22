// Golden Test Helper (2025 Best Practices)
//
// Provides utilities for golden file testing following Flutter guidelines:
// - Cross-platform golden file management
// - Device-specific golden variants
// - Loading state golden tests
// - Error state golden tests
// - Integration with new golden test infrastructure

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'golden/device_configurations.dart';
import 'golden/theme_configurations.dart';

/// Golden test configuration and utilities
class GoldenTestHelper {
  /// Configure golden file testing
  static Future<void> configure() async {
    if (kIsWeb) return; // Golden tests not supported on web

    // Set golden file comparator for platform-specific handling
    if (Platform.isMacOS) {
      goldenFileComparator = _MacOSGoldenFileComparator();
    } else if (Platform.isLinux) {
      goldenFileComparator = _LinuxGoldenFileComparator();
    }
  }

  /// Test widget golden with multiple device configurations
  static Future<void> expectGoldenForDevices(
    WidgetTester tester,
    Finder finder,
    String goldenKey, {
    List<DeviceConfig>? devices,
  }) async {
    final testDevices = devices ?? DeviceConfigurations.defaultSet;

    for (final device in testDevices) {
      await tester.binding.setSurfaceSize(device.size);
      tester.view.devicePixelRatio = device.pixelRatio;
      await tester.pump();

      await expectLater(
        finder,
        matchesGoldenFile('goldens/${goldenKey}_${device.name}.png'),
      );
    }

    // Reset to default size
    await tester.binding.setSurfaceSize(null);
    tester.view.resetDevicePixelRatio();
  }

  /// Test loading states golden
  static Future<void> expectLoadingStateGolden(
    WidgetTester tester,
    Widget widget,
    String goldenKey, {
    List<DeviceConfig>? devices,
  }) async {
    await tester.pumpWidget(widget);
    await tester.pump();

    final testDevices = devices ?? DeviceConfigurations.defaultSet;

    for (final device in testDevices) {
      await tester.binding.setSurfaceSize(device.size);
      tester.view.devicePixelRatio = device.pixelRatio;
      await tester.pump();

      await expectLater(
        find.byWidget(widget),
        matchesGoldenFile('goldens/loading/${goldenKey}_loading_${device.name}.png'),
      );
    }

    await tester.binding.setSurfaceSize(null);
    tester.view.resetDevicePixelRatio();
  }

  /// Test error states golden
  static Future<void> expectErrorStateGolden(
    WidgetTester tester,
    Widget widget,
    String goldenKey, {
    List<DeviceConfig>? devices,
  }) async {
    await tester.pumpWidget(widget);
    await tester.pump();

    final testDevices = devices ?? DeviceConfigurations.defaultSet;

    for (final device in testDevices) {
      await tester.binding.setSurfaceSize(device.size);
      tester.view.devicePixelRatio = device.pixelRatio;
      await tester.pump();

      await expectLater(
        find.byWidget(widget),
        matchesGoldenFile('goldens/errors/${goldenKey}_error_${device.name}.png'),
      );
    }

    await tester.binding.setSurfaceSize(null);
    tester.view.resetDevicePixelRatio();
  }

  /// Test widget with theme variants
  static Future<void> expectGoldenForThemes(
    WidgetTester tester,
    Widget Function(ThemeData theme) widgetBuilder,
    String goldenKey, {
    List<ThemeConfig>? themes,
  }) async {
    final testThemes = themes ?? ThemeConfigurations.defaultSet;

    for (final themeConfig in testThemes) {
      final widget = widgetBuilder(themeConfig.themeData);
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      await expectLater(
        find.byWidget(widget),
        matchesGoldenFile('goldens/${goldenKey}_${themeConfig.name}.png'),
      );
    }
  }
}

/// Platform-specific golden file comparator for macOS
class _MacOSGoldenFileComparator extends LocalFileComparator {
  _MacOSGoldenFileComparator() : super(Uri.parse('test/goldens/'));
}

/// Platform-specific golden file comparator for Linux
class _LinuxGoldenFileComparator extends LocalFileComparator {
  _LinuxGoldenFileComparator() : super(Uri.parse('test/goldens/'));
}
