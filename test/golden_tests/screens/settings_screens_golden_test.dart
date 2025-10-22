// Phase 4: Settings Screens Golden Tests
// Tests for Settings UI components with Light + Dark themes
// CRITICAL: Uses GoldenTestWrapper pattern for device × theme matrix

@Tags(['golden'])
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:edulift/core/navigation/navigation_state.dart' as nav;
import 'package:edulift/core/presentation/widgets/settings/settings_page.dart';
import '../../support/golden/golden_test_wrapper.dart';
import '../../support/golden/device_configurations.dart';
import '../../support/golden/theme_configurations.dart';

void main() {
  group('Phase 4: Settings Screens Golden Tests', () {
    testWidgets('SettingsPage - Light Theme', (tester) async {
      final overrides = [
        nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const SettingsPage(),
        testName: 'settings_page_light',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.light],
        providerOverrides: overrides,
      );
    });

    testWidgets('SettingsPage - Dark Theme', (tester) async {
      final overrides = [
        nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const SettingsPage(),
        testName: 'settings_page_dark',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.dark],
        providerOverrides: overrides,
      );
    });

    // SKIP ProfilePage - uses providers that modify state during build
    // ProfilePage requires currentUserWithFamilyRoleProvider which has
    // lifecycle issues in golden tests (reads during build)
  });
}
