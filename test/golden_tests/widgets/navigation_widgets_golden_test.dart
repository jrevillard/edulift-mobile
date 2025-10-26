// Phase 4: Navigation Widgets Golden Tests
// Tests for AppNavigation, AdaptiveNavigation components
// CRITICAL: Uses GoldenTestWrapper pattern for device × theme matrix

@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/presentation/widgets/navigation/app_navigation.dart';
import '../../support/golden/golden_test_wrapper.dart';
import '../../support/golden/device_configurations.dart';
import '../../support/golden/theme_configurations.dart';

void main() {
  group('Phase 4: Navigation Widgets Golden Tests', () {
    group('AppNavigation - Mobile (NavigationBar)', () {
      testWidgets('AppNavigation - First Tab Selected - Light', (tester) async {
        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: AppNavigation(currentIndex: 0, onDestinationSelected: (_) {}),
          testName: 'app_navigation_first_tab_light',
          devices: DeviceConfigurations.defaultSet,
          themes: [ThemeConfigurations.light],
        );
      });

      testWidgets('AppNavigation - Family Tab Selected - Light', (
        tester,
      ) async {
        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: AppNavigation(currentIndex: 1, onDestinationSelected: (_) {}),
          testName: 'app_navigation_family_tab_light',
          devices: DeviceConfigurations.defaultSet,
          themes: [ThemeConfigurations.light],
        );
      });

      testWidgets('AppNavigation - Groups Tab Selected - Dark', (tester) async {
        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: AppNavigation(currentIndex: 3, onDestinationSelected: (_) {}),
          testName: 'app_navigation_groups_tab_dark',
          devices: DeviceConfigurations.defaultSet,
          themes: [ThemeConfigurations.dark],
        );
      });

      testWidgets('AppNavigation - Settings Tab Selected - Dark', (
        tester,
      ) async {
        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: AppNavigation(currentIndex: 4, onDestinationSelected: (_) {}),
          testName: 'app_navigation_settings_tab_dark',
          devices: DeviceConfigurations.defaultSet,
          themes: [ThemeConfigurations.dark],
        );
      });
    });

    group('AdaptiveNavigation', () {
      testWidgets('AdaptiveNavigation - Mobile Layout', (tester) async {
        const destinations = [
          AdaptiveNavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          AdaptiveNavigationDestination(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          AdaptiveNavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ];

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: AdaptiveNavigation(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            destinations: destinations,
          ),
          testName: 'adaptive_navigation_mobile',
          devices: DeviceConfigurations.defaultSet,
          themes: [ThemeConfigurations.light],
        );
      });

      testWidgets('AdaptiveNavigation - With Selected Icon', (tester) async {
        const destinations = [
          AdaptiveNavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          AdaptiveNavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
        ];

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: AdaptiveNavigation(
            selectedIndex: 1,
            onDestinationSelected: (_) {},
            destinations: destinations,
          ),
          testName: 'adaptive_navigation_selected_icon_dark',
          devices: DeviceConfigurations.defaultSet,
          themes: [ThemeConfigurations.dark],
        );
      });
    });

    group('QuickNavigation', () {
      testWidgets('QuickNavigation - Horizontal Layout', (tester) async {
        final actions = [
          QuickNavigationAction(
            icon: Icons.add,
            label: 'Add',
            onPressed: () {},
            semanticLabel: 'Add item',
          ),
          QuickNavigationAction(
            icon: Icons.edit,
            label: 'Edit',
            onPressed: () {},
            semanticLabel: 'Edit item',
          ),
          QuickNavigationAction(
            icon: Icons.delete,
            label: 'Delete',
            onPressed: () {},
            semanticLabel: 'Delete item',
          ),
        ];

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: QuickNavigation(actions: actions),
          testName: 'quick_navigation_horizontal',
          devices: DeviceConfigurations.defaultSet,
          themes: [ThemeConfigurations.light],
        );
      });

      testWidgets('QuickNavigation - Vertical Layout - Dark', (tester) async {
        final actions = [
          QuickNavigationAction(
            icon: Icons.people,
            label: 'Family',
            onPressed: () {},
            semanticLabel: 'Manage family',
          ),
          QuickNavigationAction(
            icon: Icons.group,
            label: 'Groups',
            onPressed: () {},
            semanticLabel: 'Manage groups',
          ),
        ];

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: QuickNavigation(actions: actions, direction: Axis.vertical),
          testName: 'quick_navigation_vertical_dark',
          devices: DeviceConfigurations.defaultSet,
          themes: [ThemeConfigurations.dark],
        );
      });
    });

    // SKIP ResponsiveScaffold - too complex for golden tests
    // (requires body widget, multiple layout sizes)
  });
}
