// Phase 4: Common Widgets Golden Tests
// Tests for LoadingIndicator, OfflineIndicator, etc.
// CRITICAL: Uses GoldenTestWrapper pattern for device × theme matrix

@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/presentation/widgets/loading_indicator.dart';
import '../../support/golden/golden_test_wrapper.dart';
import '../../support/golden/device_configurations.dart';
import '../../support/golden/theme_configurations.dart';

void main() {
  group('Phase 4: Common Widgets Golden Tests', () {
    group('LoadingIndicator', () {
      testWidgets('LoadingIndicator - Default - Light Theme', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: LoadingIndicator())),
        );
        await tester
            .pump(); // Use pump() not pumpAndSettle() for infinite animations

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: const LoadingIndicator(),
          testName: 'loading_indicator_default_light',
          devices: DeviceConfigurations.defaultSet,
          themes: [ThemeConfigurations.light],
          skipSettle: true, // Infinite animation
        );
      });

      testWidgets('LoadingIndicator - With Message - Light Theme', (
        tester,
      ) async {
        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: const LoadingIndicator(message: 'Chargement en cours...'),
          testName: 'loading_indicator_with_message_light',
          devices: DeviceConfigurations.defaultSet,
          themes: [ThemeConfigurations.light],
          skipSettle: true, // Infinite animation
        );
      });

      testWidgets('LoadingIndicator - UTF-8 Message - Dark Theme', (
        tester,
      ) async {
        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: const LoadingIndicator(
            message: 'Chargement des données école 🚌',
          ),
          testName: 'loading_indicator_utf8_dark',
          devices: DeviceConfigurations.defaultSet,
          themes: [ThemeConfigurations.dark],
          skipSettle: true, // Infinite animation
        );
      });

      testWidgets('LoadingIndicator - No Message', (tester) async {
        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: const LoadingIndicator(showMessage: false),
          testName: 'loading_indicator_no_message',
          devices: DeviceConfigurations.defaultSet,
          themes: [ThemeConfigurations.light],
          skipSettle: true, // Infinite animation
        );
      });
    });

    group('InlineLoadingIndicator', () {
      testWidgets('InlineLoadingIndicator - Default Size', (tester) async {
        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: const Center(child: InlineLoadingIndicator()),
          testName: 'inline_loading_indicator_default',
          devices: DeviceConfigurations.defaultSet,
          themes: [ThemeConfigurations.light],
          skipSettle: true, // Infinite animation
        );
      });

      testWidgets('InlineLoadingIndicator - Custom Size and Color', (
        tester,
      ) async {
        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: const Center(
            child: InlineLoadingIndicator(size: 32, color: Colors.red),
          ),
          testName: 'inline_loading_indicator_custom',
          devices: DeviceConfigurations.defaultSet,
          themes: [ThemeConfigurations.light],
          skipSettle: true, // Infinite animation
        );
      });
    });

    group('LoadingOverlay', () {
      testWidgets('LoadingOverlay - Not Loading', (tester) async {
        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: const LoadingOverlay(
            isLoading: false,
            child: Center(child: Text('Content visible')),
          ),
          testName: 'loading_overlay_not_loading',
          devices: DeviceConfigurations.defaultSet,
          themes: [ThemeConfigurations.light],
        );
      });

      testWidgets('LoadingOverlay - Loading with Message', (tester) async {
        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: const LoadingOverlay(
            isLoading: true,
            loadingMessage: 'Synchronisation...',
            child: Center(child: Text('Background content')),
          ),
          testName: 'loading_overlay_loading',
          devices: DeviceConfigurations.defaultSet,
          themes: [ThemeConfigurations.light],
          skipSettle: true, // Infinite animation
        );
      });
    });

    // SKIP OfflineIndicator - uses providers (appStateProvider)
    // which cause lifecycle issues in golden tests
  });
}
