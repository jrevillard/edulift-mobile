// Configuration Integration Test
// Verifies that configuration system works with different dart-define values

// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/config/environment_config.dart';
import 'package:edulift/core/config/feature_flags.dart';
import 'package:edulift/core/config/app_config.dart';

void main() {
  group('Configuration Integration', () {
    test('E2E configuration should be properly detected', () {
      final config = EnvironmentConfig.getConfig();

      // This test will run with whatever FLAVOR is set via dart-define
      expect(config, isNotNull);
      expect(config.validate(), isTrue);

      // Log the detected configuration for debugging
      print('🎯 Detected Environment: ${config.environmentName}');
      print('📱 App Name: ${config.appName}');
      print('🔗 API Base URL: ${config.apiBaseUrl}');
      print('🌐 WebSocket URL: ${config.websocketUrl}');
      print('🔥 Firebase Enabled: ${config.firebaseEnabled}');
      print('🐛 Debug Enabled: ${config.debugEnabled}');

      if (config is E2EConfig) {
        print('📧 Mailpit Web: ${config.mailpitWebUrl}');
        print('📧 Mailpit API: ${config.mailpitApiUrl}');
        print('⏱️  Connect Timeout: ${config.connectTimeout.inSeconds}s');
      }
    });

    test('Feature flags should respond to environment', () {
      final config = EnvironmentConfig.getConfig();

      print('🚀 Feature Flags for ${config.environmentName}:');
      print('   🔥 Firebase: ${FeatureFlags.firebaseEnabled}');
      print('   📝 Verbose Logging: ${FeatureFlags.verboseLogging}');
      print('   🐛 Debug Mode: ${FeatureFlags.debugMode}');
      print('   🌐 Network Logging: ${FeatureFlags.networkLogging}');
      print('   ⏱️  Extended Timeouts: ${FeatureFlags.useExtendedTimeouts}');

      // Verify feature flags make sense for the environment
      expect(FeatureFlags.firebaseEnabled, equals(config.firebaseEnabled));

      if (config.environmentName == 'e2e') {
        expect(FeatureFlags.useExtendedTimeouts, isTrue);
        expect(FeatureFlags.verboseLogging, isTrue);
        expect(FeatureFlags.firebaseEnabled, isFalse);
      }

      if (config.environmentName == 'development') {
        expect(FeatureFlags.debugMode, isTrue);
        expect(FeatureFlags.firebaseEnabled, isFalse);
        expect(FeatureFlags.networkLogging, isTrue);
      }
    });
  });
}
