// Real Connectivity Helper for Android Emulator ↔ Backend Testing
// Tests the ACTUAL network connectivity from Android emulator to backend services
// This validates the real network path that the app will use during E2E tests

// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:edulift/core/config/environment_config.dart';

/// Helper class for testing real connectivity from Android emulator to backend services
///
/// This addresses the critical issue: shell `curl` tests host→backend connectivity,
/// but we need to test emulator→backend connectivity for real E2E validation.
class ConnectivityHelper {
  /// Validates that the backend is accessible from the Android emulator
  ///
  /// This test runs ON the emulator, so it tests the actual network path
  /// that the Flutter app will use during E2E tests.
  ///
  /// Throws [TestFailure] if backend is not accessible from emulator
  static Future<void> ensureBackendAccessibleFromEmulator() async {
    // Get configuration from environment
    final config = EnvironmentConfig.getConfig();

    try {
      final response = await http
          .get(
            Uri.parse('${config.apiBaseUrl}/health'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      expect(
        response.statusCode,
        equals(200),
        reason:
            'Backend must be accessible from Android emulator at ${config.apiBaseUrl}/health',
      );

      print(
        '✅ Backend accessible from emulator: ${config.apiBaseUrl}/health (${response.statusCode})',
      );
    } catch (e) {
      fail(
        'CRITICAL: Backend not accessible from Android emulator!\n'
        'URL: ${config.apiBaseUrl}/health\n'
        'Error: $e\n'
        'This means the network path emulator→backend is broken.\n'
        'Check Docker port mapping and Android emulator network config.',
      );
    }
  }

  /// Validates that Mailpit is accessible from the Android emulator
  ///
  /// Mailpit typically returns 400 for root requests, which is acceptable
  /// as it indicates the service is running and accessible.
  static Future<void> ensureMailpitAccessibleFromEmulator() async {
    // Get configuration from environment
    final config = EnvironmentConfig.getConfig();

    try {
      final response = await http
          .get(Uri.parse(config.mailpitWebUrl))
          .timeout(const Duration(seconds: 10));

      // Mailpit returns 400 for root, but that means it's accessible
      final acceptableStatuses = [200, 400];
      expect(
        acceptableStatuses.contains(response.statusCode),
        isTrue,
        reason:
            'Mailpit must be accessible from Android emulator at ${config.mailpitWebUrl}',
      );

      print(
        '✅ Mailpit accessible from emulator: ${config.mailpitWebUrl} (${response.statusCode})',
      );
    } catch (e) {
      fail(
        'CRITICAL: Mailpit not accessible from Android emulator!\n'
        'URL: ${config.mailpitWebUrl}\n'
        'Error: $e\n'
        'Email testing will fail if Mailpit is not reachable from emulator.',
      );
    }
  }

  /// Validates complete connectivity from emulator to all required services
  ///
  /// This should be called in `setUpAll()` of every E2E test group to ensure
  /// the emulator can reach all backend services before tests start.
  ///
  /// Gemini Pro's hybrid approach:
  /// - Phase 0 (shell): Validates services are running
  /// - Phase 1 (this method): Validates emulator→services connectivity
  /// - Phase 2: Run actual E2E tests
  static Future<void> validateEmulatorConnectivity() async {
    print('🔍 Phase 1: Validating Android emulator → backend connectivity...');

    await ensureBackendAccessibleFromEmulator();
    await ensureMailpitAccessibleFromEmulator();

    print(
      '🎉 Phase 1 complete: All services accessible from Android emulator!',
    );
  }
}
