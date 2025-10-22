// Patrol Detection Test
// Verifies that EnvironmentConfig correctly detects Patrol context

// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/config/environment_config.dart';
import 'package:edulift/core/config/app_config.dart';

void main() {
  group('Patrol Detection', () {
    test('should detect E2E config when PATROL_TEST_SERVER_PORT is set', () {
      // This test simulates what happens when Patrol sets its internal dart-define
      // In reality, this would be set by Patrol as: --dart-define=PATROL_TEST_SERVER_PORT=8081

      // Test that our detection logic would work
      const patrolPort = String.fromEnvironment('PATROL_TEST_SERVER_PORT');
      final isPatrolContext = patrolPort.isNotEmpty;

      if (isPatrolContext) {
        // If this test runs with Patrol's dart-define, it should detect E2E
        final config = EnvironmentConfig.getConfig();
        expect(config, isA<E2EConfig>());
        expect(config.environmentName, equals('e2e'));
        expect(config.apiBaseUrl, equals('http://10.0.2.2:8030/api/v1'));
        expect(config.mailpitWebUrl, equals('http://10.0.2.2:8031'));

        print('✅ Patrol context detected successfully');
        print('🔗 API: ${config.apiBaseUrl}');
        print('📧 Mailpit: ${config.mailpitWebUrl}');
      } else {
        // Normal test environment - should use development
        final config = EnvironmentConfig.getConfig();
        expect(config, isA<DevelopmentConfig>());
        expect(config.environmentName, equals('development'));

        print('✅ Normal test context - using development config');
        print('🔗 API: ${config.apiBaseUrl}');
      }
    });

    test('should fall back to FLAVOR dart-define when not in Patrol', () {
      // This test verifies the normal FLAVOR-based detection still works
      final config = EnvironmentConfig.getConfig();

      expect(config, isNotNull);
      expect(config.validate(), isTrue);

      // Without Patrol context, should use development (default)
      const patrolPort = String.fromEnvironment('PATROL_TEST_SERVER_PORT');
      if (patrolPort.isEmpty) {
        expect(config.environmentName, equals('development'));
        print('✅ No Patrol context - correctly using development config');
      }
    });
  });
}
