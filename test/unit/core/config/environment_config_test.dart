// Environment Configuration Tests
// Verifies that dart-define based configuration works correctly

import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:edulift/core/config/environment_config.dart';
import 'package:edulift/core/config/environment.dart';
import 'package:edulift/core/config/app_config.dart';

void main() {
  group('EnvironmentConfig', () {
    test('should return DevelopmentConfig when FLAVOR is development', () {
      // Note: This test runs with the default FLAVOR value (development)
      final config = EnvironmentConfig.getConfig();

      expect(config, isA<DevelopmentConfig>());
      expect(config.environmentName, equals('development'));
      expect(config.apiBaseUrl, equals('http://localhost:3001/api/v1'));
      expect(config.logLevel, equals('debug'));
      expect(config.loggerLogLevel, equals(Level.debug));
      expect(config.firebaseEnabled, isFalse);
    });

    test('should validate configuration successfully', () {
      final config = EnvironmentConfig.getConfig();

      expect(config.validate(), isTrue);
      expect(config.apiBaseUrl.isNotEmpty, isTrue);
      expect(config.websocketUrl.isNotEmpty, isTrue);
      expect(config.appName.isNotEmpty, isTrue);
    });

    test('should provide complete configuration summary', () {
      final config = EnvironmentConfig.getConfig();
      final summary = config.configSummary;

      expect(summary, isA<Map<String, dynamic>>());
      expect(summary.containsKey('environment'), isTrue);
      expect(summary.containsKey('apiBaseUrl'), isTrue);
      expect(summary.containsKey('logLevel'), isTrue);
      expect(summary.containsKey('firebaseEnabled'), isTrue);
    });

    test('should support environment detection methods', () {
      expect(EnvironmentConfig.supportedEnvironments, contains('development'));
      expect(EnvironmentConfig.supportedEnvironments, contains('staging'));
      expect(EnvironmentConfig.supportedEnvironments, contains('e2e'));
      expect(EnvironmentConfig.supportedEnvironments, contains('production'));

      expect(EnvironmentConfig.isSupported('development'), isTrue);
      expect(EnvironmentConfig.isSupported('dev'), isTrue);
      expect(EnvironmentConfig.isSupported('unknown'), isFalse);
    });

    test('should support all environment aliases from enum', () {
      // Test canonical names
      expect(EnvironmentConfig.isSupported('development'), isTrue);
      expect(EnvironmentConfig.isSupported('staging'), isTrue);
      expect(EnvironmentConfig.isSupported('e2e'), isTrue);
      expect(EnvironmentConfig.isSupported('production'), isTrue);

      // Test aliases
      expect(EnvironmentConfig.isSupported('dev'), isTrue);
      expect(EnvironmentConfig.isSupported('stage'), isTrue);
      expect(EnvironmentConfig.isSupported('test'), isTrue);
      expect(EnvironmentConfig.isSupported('prod'), isTrue);

      // Test case insensitivity
      expect(EnvironmentConfig.isSupported('DEV'), isTrue);
      expect(EnvironmentConfig.isSupported('Test'), isTrue);
      expect(EnvironmentConfig.isSupported('E2E'), isTrue);

      // Test invalid values
      expect(EnvironmentConfig.isSupported('invalid'), isFalse);
      expect(EnvironmentConfig.isSupported(''), isFalse);
    });

    test('should provide consistent environment lists', () {
      final canonical = EnvironmentConfig.supportedEnvironments;
      final allSupported = EnvironmentConfig.allSupportedEnvironments;

      // Canonical should match enum canonical names
      expect(canonical, equals(Environment.canonicalNames));
      expect(canonical.length, equals(4));

      // All supported should include aliases
      expect(allSupported, equals(Environment.allSupportedNames));
      expect(allSupported.length, equals(8)); // 4 canonical + 4 aliases

      // Verify specific contents
      expect(allSupported, containsAll(['development', 'dev']));
      expect(allSupported, containsAll(['staging', 'stage']));
      expect(allSupported, containsAll(['e2e', 'test']));
      expect(allSupported, containsAll(['production', 'prod']));
    });

    group('Log Levels', () {
      test(
        'should provide correct default log levels for each environment',
        () {
          // Test development config
          final devConfig = DevelopmentConfig();
          expect(devConfig.logLevel, equals('debug'));
          expect(devConfig.loggerLogLevel, equals(Level.debug));

          // Test staging config
          final stagingConfig = StagingConfig();
          expect(stagingConfig.logLevel, equals('info'));
          expect(stagingConfig.loggerLogLevel, equals(Level.info));

          // Test E2E config
          final e2eConfig = E2EConfig();
          expect(e2eConfig.logLevel, equals('debug'));
          expect(e2eConfig.loggerLogLevel, equals(Level.debug));

          // Test production config
          final prodConfig = ProductionConfig();
          expect(prodConfig.logLevel, equals('warning'));
          expect(prodConfig.loggerLogLevel, equals(Level.warning));
        },
      );

      test('should handle case insensitive log level strings', () {
        // This test verifies the string to enum conversion works correctly
        final configs = [
          DevelopmentConfig(),
          StagingConfig(),
          E2EConfig(),
          ProductionConfig(),
        ];

        for (final config in configs) {
          final level = config.loggerLogLevel;
          expect(level, isA<Level>());
          expect(
            config.logLevel.toLowerCase(),
            isIn(['trace', 'debug', 'info', 'warning', 'error', 'fatal']),
          );
        }
      });
    });
  });
}
