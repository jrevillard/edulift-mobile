// EduLift - Authentication Screens Golden Tests
// Comprehensive visual regression tests for authentication screens

@Tags(['golden'])
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:edulift/features/auth/presentation/pages/login_page.dart';
import 'package:edulift/features/auth/presentation/pages/magic_link_page.dart';
import 'package:edulift/core/navigation/navigation_state.dart' as nav;

import '../../support/golden/golden_test_wrapper.dart';
import '../../support/golden/device_configurations.dart';
import '../../support/golden/theme_configurations.dart';
import '../../support/network_mocking.dart';

void main() {
  group('Authentication Screens - Golden Tests', () {
    testWidgets('LoginPage - Light Theme', (tester) async {
      // Provide minimal overrides to ensure ProviderScope is created
      final overrides = [
        nav.navigationStateProvider.overrideWith(
          (ref) => nav.NavigationStateNotifier(),
        ),

        // CRITICAL: Prevent all real network calls during golden tests
        ...getAllNetworkMockOverrides(),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const LoginPage(),
        testName: 'login_page_light',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.light],
        providerOverrides: overrides,
      );
    });

    testWidgets('LoginPage - Dark Theme', (tester) async {
      final overrides = [
        nav.navigationStateProvider.overrideWith(
          (ref) => nav.NavigationStateNotifier(),
        ),

        // CRITICAL: Prevent all real network calls during golden tests
        ...getAllNetworkMockOverrides(),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const LoginPage(),
        testName: 'login_page_dark',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.dark],
        providerOverrides: overrides,
      );
    });

    testWidgets('MagicLinkPage - Light Theme', (tester) async {
      final overrides = [
        nav.navigationStateProvider.overrideWith(
          (ref) => nav.NavigationStateNotifier(),
        ),

        // CRITICAL: Prevent all real network calls during golden tests
        ...getAllNetworkMockOverrides(),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const MagicLinkPage(email: 'jean-pierre.müller@example.com'),
        testName: 'magic_link_page_light',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.light],
        providerOverrides: overrides,
      );
    });

    testWidgets('MagicLinkPage - Dark Theme', (tester) async {
      final overrides = [
        nav.navigationStateProvider.overrideWith(
          (ref) => nav.NavigationStateNotifier(),
        ),

        // CRITICAL: Prevent all real network calls during golden tests
        ...getAllNetworkMockOverrides(),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const MagicLinkPage(email: 'josé.garcía@example.com'),
        testName: 'magic_link_page_dark',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.dark],
        providerOverrides: overrides,
      );
    });
  });
}
