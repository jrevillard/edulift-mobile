import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:edulift/core/storage/adaptive_secure_storage.dart';

/// ISOLATED TEST SUITE: Environment-Specific Behavior
///
/// PURPOSE: Test environment detection and adaptive behavior in isolation
/// FOCUS: Test/development/production environment handling
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdaptiveSecureStorage - Environment-Specific Behavior Tests', () {
    late AdaptiveSecureStorage storage;

    setUp(() {
      // ISOLATED MOCK SETUP - Fresh for each test
      SharedPreferences.setMockInitialValues({});
      storage = AdaptiveSecureStorage();
    });

    tearDown(() async {
      // ISOLATED CLEANUP - Clear state after each test
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    test('should handle test environment correctly', () async {
      // ARRANGE - Verify we're in test environment
      expect(
        Platform.environment['FLUTTER_TEST'],
        isNotNull,
        reason: 'Should be running in test environment',
      );

      const testKey = 'environment_test_token';
      const testValue = 'test_env_token_value';

      SharedPreferences.setMockInitialValues({});

      // ACT
      await storage.write(key: testKey, value: testValue);
      final retrieved = await storage.read(key: testKey);

      // ASSERT
      expect(
        retrieved,
        equals(testValue),
        reason: 'Test environment should use SharedPreferences backend',
      );
    });

    test(
      'should use SharedPreferences backend in adaptive environments',
      () async {
        // ARRANGE
        const testKey = 'backend_verification_key';
        const testValue = 'backend_test_value';

        SharedPreferences.setMockInitialValues({});

        // ACT
        await storage.write(key: testKey, value: testValue);

        // ASSERT - Verify data is actually in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        // In test environment, keys are used as-is (no secure_ prefix)
        final directRead = prefs.getString('backend_verification_key');

        expect(
          directRead,
          equals(testValue),
          reason:
              'Data should be stored in SharedPreferences in test environment',
        );
      },
    );

    test(
      'should store and retrieve jwt_token_dev with consistent key naming',
      () async {
        // ARRANGE
        const devTokenKey = 'jwt_token_dev';
        const tokenValue = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dev.signature';

        SharedPreferences.setMockInitialValues({});

        // ACT - Store token
        await storage.write(key: devTokenKey, value: tokenValue);

        // ACT - Retrieve token immediately
        final retrievedToken = await storage.read(key: devTokenKey);

        // ASSERT
        expect(
          retrievedToken,
          equals(tokenValue),
          reason:
              'Development token should be stored and retrieved consistently',
        );
      },
    );
  });
}
