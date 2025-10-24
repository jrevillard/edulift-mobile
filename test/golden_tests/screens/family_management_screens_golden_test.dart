// EduLift - Family Management Screens Golden Tests
// Phase 2: Complete visual coverage for family management screens

@Tags(['golden'])
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:edulift/core/navigation/navigation_state.dart' as nav;

import 'package:edulift/features/family/presentation/pages/create_family_page.dart';
import 'package:edulift/features/family/presentation/pages/add_child_page.dart';
import 'package:edulift/features/family/presentation/pages/add_vehicle_page.dart';

import '../../support/golden/golden_test_wrapper.dart';
import '../../support/golden/device_configurations.dart';
import '../../support/golden/theme_configurations.dart';
import '../../support/network_mocking.dart';

void main() {
  group('CreateFamilyPage - Golden Tests', () {
    testWidgets('CreateFamilyPage - light theme', (tester) async {
      final overrides = [
        nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
      // CRITICAL: Prevent all real network calls during golden tests

      ...getAllNetworkMockOverrides(),

      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const CreateFamilyPage(),
        testName: 'create_family_page_light',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.light],
        providerOverrides: overrides,
      );
    });

    testWidgets('CreateFamilyPage - dark theme', (tester) async {
      final overrides = [
        nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
      // CRITICAL: Prevent all real network calls during golden tests

      ...getAllNetworkMockOverrides(),

      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const CreateFamilyPage(),
        testName: 'create_family_page_dark',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.dark],
        providerOverrides: overrides,
      );
    });
  });

  group('AddChildPage - Golden Tests', () {
    testWidgets('AddChildPage - light theme', (tester) async {
      final overrides = [
        nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
      // CRITICAL: Prevent all real network calls during golden tests

      ...getAllNetworkMockOverrides(),

      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const AddChildPage(),
        testName: 'add_child_page_light',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.light],
        providerOverrides: overrides,
      );
    });

    testWidgets('AddChildPage - dark theme', (tester) async {
      final overrides = [
        nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
      // CRITICAL: Prevent all real network calls during golden tests

      ...getAllNetworkMockOverrides(),

      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const AddChildPage(),
        testName: 'add_child_page_dark',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.dark],
        providerOverrides: overrides,
      );
    });
  });

  group('AddVehiclePage - Golden Tests', () {
    testWidgets('AddVehiclePage - light theme', (tester) async {
      final overrides = [
        nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
      // CRITICAL: Prevent all real network calls during golden tests

      ...getAllNetworkMockOverrides(),

      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const AddVehiclePage(),
        testName: 'add_vehicle_page_light',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.light],
        providerOverrides: overrides,
      );
    });

    testWidgets('AddVehiclePage - dark theme', (tester) async {
      final overrides = [
        nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
      // CRITICAL: Prevent all real network calls during golden tests

      ...getAllNetworkMockOverrides(),

      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const AddVehiclePage(),
        testName: 'add_vehicle_page_dark',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.dark],
        providerOverrides: overrides,
      );
    });
  });
}
