// Test Screen Sizes Helper
// Provides standardized screen size testing utilities following Flutter best practices

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Device configuration for screen size testing
class TestDeviceConfiguration {
  const TestDeviceConfiguration({
    required this.name,
    required this.size,
    required this.devicePixelRatio,
    this.description,
  });

  /// Human-readable device name
  final String name;

  /// Screen size in logical pixels
  final Size size;

  /// Device pixel ratio
  final double devicePixelRatio;

  /// Optional description of the device
  final String? description;

  /// Physical size in pixels
  Size get physicalSize =>
      Size(size.width * devicePixelRatio, size.height * devicePixelRatio);

  /// Check if this is considered a mobile device
  bool get isMobile => size.width < 768;

  /// Check if this is considered a tablet device
  bool get isTablet => size.width >= 768 && size.width < 1200;

  /// Check if this is considered a desktop device
  bool get isDesktop => size.width >= 1200;

  @override
  String toString() => '$name (${size.width}x${size.height})';
}

/// Helper class for testing widgets across different screen sizes
///
/// Provides standardized device configurations and utilities for testing
/// responsive layouts, breakpoint behavior, and device-specific UI adaptations.
class TestScreenSizes {
  // Mobile Devices (Width < 768px)

  /// iPhone SE (1st generation) - Smallest modern iPhone
  static const TestDeviceConfiguration iphoneSE = TestDeviceConfiguration(
    name: 'iPhone SE',
    size: Size(320, 568),
    devicePixelRatio: 2.0,
    description: 'Smallest modern iPhone screen',
  );

  /// iPhone 12 mini - Compact modern iPhone
  static const TestDeviceConfiguration iphone12Mini = TestDeviceConfiguration(
    name: 'iPhone 12 mini',
    size: Size(375, 812),
    devicePixelRatio: 3.0,
    description: 'Compact modern iPhone with notch',
  );

  /// iPhone 14 - Standard modern iPhone size
  static const TestDeviceConfiguration iphone14 = TestDeviceConfiguration(
    name: 'iPhone 14',
    size: Size(390, 844),
    devicePixelRatio: 3.0,
    description: 'Standard iPhone size',
  );

  /// iPhone 14 Pro Max - Largest iPhone
  static const TestDeviceConfiguration iphone14ProMax = TestDeviceConfiguration(
    name: 'iPhone 14 Pro Max',
    size: Size(430, 932),
    devicePixelRatio: 3.0,
    description: 'Largest iPhone screen',
  );

  /// Google Pixel 7 - Standard Android phone
  static const TestDeviceConfiguration pixel7 = TestDeviceConfiguration(
    name: 'Pixel 7',
    size: Size(412, 915),
    devicePixelRatio: 2.625,
    description: 'Standard Android phone size',
  );

  /// Samsung Galaxy S23 - Popular Android device
  static const TestDeviceConfiguration galaxyS23 = TestDeviceConfiguration(
    name: 'Galaxy S23',
    size: Size(360, 780),
    devicePixelRatio: 3.0,
    description: 'Popular Android device',
  );

  // Common test sizes from existing code

  /// Test mobile size from existing code
  static const TestDeviceConfiguration testMobile = TestDeviceConfiguration(
    name: 'Test Mobile',
    size: Size(375, 667),
    devicePixelRatio: 2.0,
    description: 'Standard test mobile size',
  );

  /// Small test mobile from existing code
  static const TestDeviceConfiguration testSmallMobile =
      TestDeviceConfiguration(
        name: 'Small Mobile',
        size: Size(300, 400),
        devicePixelRatio: 2.0,
        description: 'Very small mobile for edge cases',
      );

  /// Standard test phone from existing code
  static const TestDeviceConfiguration testPhone = TestDeviceConfiguration(
    name: 'Test Phone',
    size: Size(400, 800),
    devicePixelRatio: 2.0,
    description: 'Standard test phone size',
  );

  // Tablet Devices (Width 768px - 1199px)

  /// iPad mini - Smallest tablet
  static const TestDeviceConfiguration ipadMini = TestDeviceConfiguration(
    name: 'iPad mini',
    size: Size(744, 1133),
    devicePixelRatio: 2.0,
    description: 'Compact tablet size',
  );

  /// iPad (10th generation) - Standard tablet
  static const TestDeviceConfiguration ipad = TestDeviceConfiguration(
    name: 'iPad',
    size: Size(820, 1180),
    devicePixelRatio: 2.0,
    description: 'Standard tablet size',
  );

  /// iPad Pro 11" - Modern tablet
  static const TestDeviceConfiguration ipadPro11 = TestDeviceConfiguration(
    name: 'iPad Pro 11"',
    size: Size(834, 1194),
    devicePixelRatio: 2.0,
    description: 'Modern tablet with narrow bezels',
  );

  /// iPad Pro 12.9" - Large tablet
  static const TestDeviceConfiguration ipadPro12 = TestDeviceConfiguration(
    name: 'iPad Pro 12.9"',
    size: Size(1024, 1366),
    devicePixelRatio: 2.0,
    description: 'Large tablet size',
  );

  /// Test tablet from existing code
  static const TestDeviceConfiguration testTablet = TestDeviceConfiguration(
    name: 'Test Tablet',
    size: Size(800, 600),
    devicePixelRatio: 2.0,
    description: 'Standard test tablet size',
  );

  /// Large test tablet from existing code
  static const TestDeviceConfiguration testLargeTablet =
      TestDeviceConfiguration(
        name: 'Large Tablet',
        size: Size(1024, 768),
        devicePixelRatio: 2.0,
        description: 'Large test tablet size',
      );

  // Foldable and Edge Cases

  /// Samsung Galaxy Z Fold - Unfolded
  static const TestDeviceConfiguration galaxyZFoldUnfolded =
      TestDeviceConfiguration(
        name: 'Galaxy Z Fold (Unfolded)',
        size: Size(768, 1024),
        devicePixelRatio: 2.6,
        description: 'Foldable device in tablet mode',
      );

  /// Samsung Galaxy Z Fold - Folded
  static const TestDeviceConfiguration galaxyZFoldFolded =
      TestDeviceConfiguration(
        name: 'Galaxy Z Fold (Folded)',
        size: Size(360, 816),
        devicePixelRatio: 2.6,
        description: 'Foldable device in phone mode',
      );

  /// Very narrow screen for edge case testing
  static const TestDeviceConfiguration veryNarrow = TestDeviceConfiguration(
    name: 'Very Narrow',
    size: Size(240, 800),
    devicePixelRatio: 2.0,
    description: 'Extremely narrow screen for edge cases',
  );

  /// Very wide screen for edge case testing
  static const TestDeviceConfiguration veryWide = TestDeviceConfiguration(
    name: 'Very Wide',
    size: Size(1600, 400),
    devicePixelRatio: 2.0,
    description: 'Extremely wide screen for edge cases',
  );

  // Critical Breakpoints

  /// Mobile/tablet breakpoint (768px)
  static const double mobileTabletBreakpoint = 768.0;

  /// Tablet/desktop breakpoint (1200px)
  static const double tabletDesktopBreakpoint = 1200.0;

  /// Just below mobile/tablet breakpoint
  static const TestDeviceConfiguration justBelowTablet =
      TestDeviceConfiguration(
        name: 'Just Below Tablet',
        size: Size(767, 800),
        devicePixelRatio: 2.0,
        description: 'Just below 768px breakpoint',
      );

  /// Just above mobile/tablet breakpoint
  static const TestDeviceConfiguration justAboveTablet =
      TestDeviceConfiguration(
        name: 'Just Above Tablet',
        size: Size(769, 800),
        devicePixelRatio: 2.0,
        description: 'Just above 768px breakpoint',
      );

  // Device Collections

  /// All mobile devices
  static const List<TestDeviceConfiguration> mobileDevices = [
    iphoneSE,
    iphone12Mini,
    iphone14,
    iphone14ProMax,
    pixel7,
    galaxyS23,
    testMobile,
    testSmallMobile,
    testPhone,
  ];

  /// All tablet devices
  static const List<TestDeviceConfiguration> tabletDevices = [
    ipadMini,
    ipad,
    ipadPro11,
    ipadPro12,
    testTablet,
    testLargeTablet,
    galaxyZFoldUnfolded,
  ];

  /// Edge case devices for comprehensive testing
  static const List<TestDeviceConfiguration> edgeCaseDevices = [
    veryNarrow,
    veryWide,
    justBelowTablet,
    justAboveTablet,
    galaxyZFoldFolded,
  ];

  /// Most common devices for standard testing
  static const List<TestDeviceConfiguration> commonDevices = [
    iphone14,
    pixel7,
    ipad,
    testMobile,
    testTablet,
  ];

  /// All devices combined
  static const List<TestDeviceConfiguration> allDevices = [
    ...mobileDevices,
    ...tabletDevices,
    ...edgeCaseDevices,
  ];

  /// Set screen size for testing
  ///
  /// Example:
  /// ```dart
  /// testWidgets('works on mobile', (tester) async {
  ///   await TestScreenSizes.setScreenSize(tester, TestScreenSizes.iphone14);
  ///   await tester.pumpWidget(MyApp());
  ///   // ... test mobile layout
  /// });
  /// ```
  static Future<void> setScreenSize(
    WidgetTester tester,
    TestDeviceConfiguration device,
  ) async {
    await tester.binding.setSurfaceSize(device.size);
    tester.view.devicePixelRatio = device.devicePixelRatio;
    await tester.pump();
  }

  /// Reset screen size to default (clears any size constraints)
  static Future<void> resetScreenSize(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(null);
    tester.view.resetDevicePixelRatio();
    await tester.pump();
  }

  /// Test widget across multiple screen sizes
  ///
  /// Example:
  /// ```dart
  /// testWidgets('responsive layout', (tester) async {
  ///   await TestScreenSizes.testMultipleSizes(
  ///     tester,
  ///     MyResponsiveWidget(),
  ///     devices: TestScreenSizes.commonDevices,
  ///     test: (device) async {
  ///       if (device.isMobile) {
  ///         expect(find.byKey(Key('mobile-layout')), findsOneWidget);
  ///       } else {
  ///         expect(find.byKey(Key('tablet-layout')), findsOneWidget);
  ///       }
  ///     },
  ///   );
  /// });
  /// ```
  static Future<void> testMultipleSizes(
    WidgetTester tester,
    Widget widget, {
    List<TestDeviceConfiguration> devices = commonDevices,
    required Future<void> Function(TestDeviceConfiguration device) test,
  }) async {
    for (final device in devices) {
      await setScreenSize(tester, device);
      await tester.pumpWidget(widget);
      await tester.pump();

      try {
        await test(device);
      } catch (e, stackTrace) {
        throw Exception(
          'Test failed for device ${device.name} (${device.size}): $e\n$stackTrace',
        );
      }
    }

    // Reset to default size after testing
    await resetScreenSize(tester);
  }

  /// Test breakpoint behavior
  ///
  /// Example:
  /// ```dart
  /// testWidgets('breakpoint behavior', (tester) async {
  ///   await TestScreenSizes.testBreakpointBehavior(
  ///     tester,
  ///     MyResponsiveWidget(),
  ///     mobileTest: () async {
  ///       expect(find.byKey(Key('mobile-nav')), findsOneWidget);
  ///     },
  ///     tabletTest: () async {
  ///       expect(find.byKey(Key('tablet-nav')), findsOneWidget);
  ///     },
  ///   );
  /// });
  /// ```
  static Future<void> testBreakpointBehavior(
    WidgetTester tester,
    Widget widget, {
    Future<void> Function()? mobileTest,
    Future<void> Function()? tabletTest,
  }) async {
    if (mobileTest != null) {
      // Test just below tablet breakpoint
      await setScreenSize(tester, justBelowTablet);
      await tester.pumpWidget(widget);
      await tester.pump();
      await mobileTest();
    }

    if (tabletTest != null) {
      // Test just above tablet breakpoint
      await setScreenSize(tester, justAboveTablet);
      await tester.pumpWidget(widget);
      await tester.pump();
      await tabletTest();
    }

    // Reset after testing
    await resetScreenSize(tester);
  }

  /// Helper method to verify screen size is set correctly
  static void verifyScreenSize(
    WidgetTester tester,
    TestDeviceConfiguration expectedDevice,
  ) {
    // Get the logical size from the view
    final actualSize = tester.view.physicalSize / tester.view.devicePixelRatio;
    expect(
      actualSize,
      equals(expectedDevice.size),
      reason:
          'Screen size should be ${expectedDevice.size} but was $actualSize',
    );
  }

  /// Get device configuration by name (useful for dynamic testing)
  static TestDeviceConfiguration? getDeviceByName(String name) {
    return allDevices.cast<TestDeviceConfiguration?>().firstWhere(
      (device) => device?.name == name,
      orElse: () => null,
    );
  }

  /// Comprehensive tearDown helper to reset all screen size modifications
  ///
  /// This should be called in test tearDown to ensure clean state:
  /// ```dart
  /// tearDown(() {
  ///   TestScreenSizes.tearDownSync();
  /// });
  /// ```
  static void tearDownSync() {
    try {
      // Reset to default size - this is synchronous
      TestWidgetsFlutterBinding.ensureInitialized();
    } catch (e) {
      // Ignore tearDown errors to prevent cascading test failures
      debugPrint('Warning: TestScreenSizes tearDown failed: $e');
    }
  }

  /// Asynchronous tearDown helper (use only within testWidgets)
  static Future<void> tearDown(WidgetTester tester) async {
    try {
      // Reset surface size to default (null removes size constraints)
      await tester.binding.setSurfaceSize(null);

      // Reset device pixel ratio to default
      tester.view.resetDevicePixelRatio();

      // Pump to apply changes
      await tester.pump();
    } catch (e) {
      // Ignore tearDown errors to prevent cascading test failures
      debugPrint('Warning: TestScreenSizes tearDown failed: $e');
    }
  }
}

/// Extension to add screen size utilities to WidgetTester
extension TestScreenSizesExtension on WidgetTester {
  /// Quick access to set screen size
  Future<void> setScreenSize(TestDeviceConfiguration device) async {
    await TestScreenSizes.setScreenSize(this, device);
  }

  /// Quick access to reset screen size
  Future<void> resetScreenSize() async {
    await TestScreenSizes.resetScreenSize(this);
  }

  /// Get current logical screen size
  Size get currentScreenSize {
    return view.physicalSize / view.devicePixelRatio;
  }

  /// Check if current screen size is mobile
  bool get isMobileSize {
    return currentScreenSize.width < TestScreenSizes.mobileTabletBreakpoint;
  }

  /// Check if current screen size is tablet
  bool get isTabletSize {
    final width = currentScreenSize.width;
    return width >= TestScreenSizes.mobileTabletBreakpoint &&
        width < TestScreenSizes.tabletDesktopBreakpoint;
  }
}
