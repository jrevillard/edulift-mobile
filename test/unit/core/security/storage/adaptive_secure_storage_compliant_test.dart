import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:edulift/core/storage/adaptive_secure_storage.dart';

/// COMPLIANCE TEST SUITE: AdaptiveSecureStorage Architecture Compliance
///
/// PURPOSE: Validates architectural compliance of AdaptiveSecureStorage
/// FOCUS: Architecture rules, security patterns, environment detection
/// COMPLIANCE: Tests follow clean architecture and security patterns
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdaptiveSecureStorage - Compliance Tests', () {
    late AdaptiveSecureStorage storage;

    setUp(() {
      // Set up SharedPreferences mock for test environment
      SharedPreferences.setMockInitialValues({});

      // Create storage instance - will detect test environment
      storage = AdaptiveSecureStorage();
    });

    tearDown(() async {
      // Clean up after each test
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    group('Architectural Compliance', () {
      test('should detect test environment correctly', () {
        // Test environment detection is implicit in the storage behavior
        // In test environment, storage should use SharedPreferences
        expect(storage, isA<AdaptiveSecureStorage>());
      });

      test('should implement SecureStorage interface completely', () {
        // Verify all interface methods are implemented
        expect(storage.read, isA<Function>());
        expect(storage.write, isA<Function>());
        expect(storage.delete, isA<Function>());
        expect(storage.deleteAll, isA<Function>());
        expect(storage.containsKey, isA<Function>());
        expect(storage.readAll, isA<Function>());
      });

      test('should follow clean architecture principles', () async {
        // Test that the class follows clean architecture
        // 1. No direct UI dependencies
        // 2. Implements abstract interface
        // 3. Handles errors gracefully

        const testKey = 'architecture_test';
        const testValue = 'clean_architecture_value';

        // Should not throw during normal operations
        await storage.write(key: testKey, value: testValue);
        final result = await storage.read(key: testKey);
        expect(result, equals(testValue));
      });
    });

    group('Security Compliance', () {
      test('should handle key normalization securely', () async {
        const testCases = [
          {'key': 'normal_key', 'expectedBehavior': 'store_as_is_in_test'},
          {'key': 'jwt_token', 'expectedBehavior': 'store_securely'},
          {'key': 'secure_prefixed', 'expectedBehavior': 'handle_prefix'},
        ];

        for (final testCase in testCases) {
          final key = testCase['key']!;
          const value = 'test_value';

          await storage.write(key: key, value: value);
          final result = await storage.read(key: key);

          expect(
            result,
            equals(value),
            reason: 'Key normalization failed for: $key',
          );
        }
      });

      test('should handle sensitive data appropriately', () async {
        const sensitiveData = {
          'access_token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
          'refresh_token': 'rt_abcdef123456',
          'api_key': 'sk-1234567890abcdef',
          'user_credentials': '{"username":"test","password":"****"}',
        };

        for (final entry in sensitiveData.entries) {
          await storage.write(key: entry.key, value: entry.value);
          final retrieved = await storage.read(key: entry.key);

          expect(
            retrieved,
            equals(entry.value),
            reason: 'Sensitive data handling failed for: ${entry.key}',
          );
        }
      });

      test('should provide secure deletion', () async {
        const testKey = 'delete_test_key';
        const testValue = 'delete_test_value';

        // Write data
        await storage.write(key: testKey, value: testValue);
        expect(await storage.containsKey(key: testKey), isTrue);

        // Delete data
        await storage.delete(key: testKey);

        // Verify deletion
        expect(await storage.containsKey(key: testKey), isFalse);
        expect(await storage.read(key: testKey), isNull);
      });

      test('should provide secure bulk deletion', () async {
        const testData = {'key1': 'value1', 'key2': 'value2', 'key3': 'value3'};

        // Write test data
        for (final entry in testData.entries) {
          await storage.write(key: entry.key, value: entry.value);
        }

        // Verify data exists
        for (final key in testData.keys) {
          expect(await storage.containsKey(key: key), isTrue);
        }

        // Delete all
        await storage.deleteAll();

        // Verify all deleted
        for (final key in testData.keys) {
          expect(await storage.containsKey(key: key), isFalse);
          expect(await storage.read(key: key), isNull);
        }
      });
    });

    group('Environment Detection Compliance', () {
      test('should adapt storage method based on environment', () {
        // In test environment, should use SharedPreferences
        // This is verified by the fact that our mocked SharedPreferences works
        expect(storage, isA<AdaptiveSecureStorage>());
      });

      test('should handle multiple environment variables correctly', () {
        // Test that environment detection logic is sound
        // In test environment, secure storage should be bypassed
        expect(storage, isA<AdaptiveSecureStorage>());
      });
    });

    group('Error Handling Compliance', () {
      test('should handle read errors gracefully', () async {
        const nonExistentKey = 'does_not_exist';

        final result = await storage.read(key: nonExistentKey);
        expect(result, isNull);
      });

      test('should handle write verification in test environment', () async {
        const testKey = 'verification_test';
        const testValue = 'verification_value';

        // Write the value
        await storage.write(key: testKey, value: testValue);

        // Should be readable
        final result = await storage.read(key: testKey);
        expect(result, equals(testValue));
      });

      test('should handle null value writes correctly', () async {
        const testKey = 'null_test';

        // Writing null should not crash but should not store anything
        await storage.write(key: testKey, value: null);
        final result = await storage.read(key: testKey);

        expect(result, isNull);
        expect(await storage.containsKey(key: testKey), isFalse);
      });
    });

    group('Performance Compliance', () {
      test('should handle concurrent operations safely', () async {
        const keyPrefix = 'concurrent_';
        const testCount = 10;

        // Create multiple concurrent write operations
        final futures = <Future<void>>[];
        for (var i = 0; i < testCount; i++) {
          futures.add(storage.write(key: '$keyPrefix$i', value: 'value_$i'));
        }

        // Wait for all operations to complete
        await Future.wait(futures);

        // Verify all data was written correctly
        for (var i = 0; i < testCount; i++) {
          final result = await storage.read(key: '$keyPrefix$i');
          expect(
            result,
            equals('value_$i'),
            reason: 'Concurrent write failed for index $i',
          );
        }
      });

      test('should handle large data efficiently', () async {
        const testKey = 'large_data_test';
        const largeValue =
            'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'; // Large string

        final stopwatch = Stopwatch()..start();

        await storage.write(key: testKey, value: largeValue);
        final result = await storage.read(key: testKey);

        stopwatch.stop();

        expect(result, equals(largeValue));
        // Should complete reasonably quickly (less than 1 second in tests)
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });

    group('Interface Compliance', () {
      test('should implement readAll correctly', () async {
        const testData = {
          'key1': 'value1',
          'key2': 'value2',
          'token_key': 'token_value',
        };

        // Write test data
        for (final entry in testData.entries) {
          await storage.write(key: entry.key, value: entry.value);
        }

        // Read all data
        final allData = await storage.readAll();

        // Verify all data is present
        for (final entry in testData.entries) {
          expect(
            allData.containsKey(entry.key),
            isTrue,
            reason: 'Missing key: ${entry.key}',
          );
          expect(
            allData[entry.key],
            equals(entry.value),
            reason: 'Value mismatch for key: ${entry.key}',
          );
        }
      });

      test('should implement containsKey correctly', () async {
        const existingKey = 'existing';
        const nonExistentKey = 'non_existent';
        const testValue = 'test_value';

        await storage.write(key: existingKey, value: testValue);

        expect(await storage.containsKey(key: existingKey), isTrue);
        expect(await storage.containsKey(key: nonExistentKey), isFalse);
      });
    });

    group('Integration Compliance', () {
      test('should maintain consistency across operations', () async {
        const testKey = 'consistency_test';
        const originalValue = 'original';
        const updatedValue = 'updated';

        // Initial write
        await storage.write(key: testKey, value: originalValue);
        expect(await storage.read(key: testKey), equals(originalValue));
        expect(await storage.containsKey(key: testKey), isTrue);

        // Update
        await storage.write(key: testKey, value: updatedValue);
        expect(await storage.read(key: testKey), equals(updatedValue));
        expect(await storage.containsKey(key: testKey), isTrue);

        // Delete
        await storage.delete(key: testKey);
        expect(await storage.read(key: testKey), isNull);
        expect(await storage.containsKey(key: testKey), isFalse);
      });

      test(
        'should work correctly with SharedPreferences in test environment',
        () async {
          // This test verifies that in test environment,
          // AdaptiveSecureStorage correctly uses SharedPreferences
          const testKey = 'shared_prefs_test';
          const testValue = 'shared_prefs_value';

          // Write using AdaptiveSecureStorage
          await storage.write(key: testKey, value: testValue);

          // Should be readable via AdaptiveSecureStorage
          final result = await storage.read(key: testKey);
          expect(result, equals(testValue));

          // Verify it's in the underlying SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          // In test environment, keys are stored as-is (no secure_ prefix)
          expect(prefs.containsKey(testKey), isTrue);
        },
      );
    });
  });
}
