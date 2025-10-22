import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:edulift/core/storage/adaptive_secure_storage.dart';

/// ISOLATED TEST SUITE: Basic Storage Operations
///
/// PURPOSE: Test core CRUD operations and data integrity in isolation
/// FOCUS: Write, read, delete, containsKey functionality
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdaptiveSecureStorage - Basic Operations Tests', () {
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

    test('should maintain data integrity across write-read cycles', () async {
      // ARRANGE
      const testCases = [
        {
          'key': 'jwt_token',
          'value': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test1.sig',
        },
        {'key': 'jwt_token_dev', 'value': 'dev_token_12345'},
        {'key': 'secure_token', 'value': 'already_prefixed_token'},
        {'key': 'user_data', 'value': '{"id":"123","name":"Test User"}'},
      ];

      SharedPreferences.setMockInitialValues({});

      // ACT & ASSERT
      for (final testCase in testCases) {
        final key = testCase['key']!;
        final value = testCase['value']!;

        // Write
        await storage.write(key: key, value: value);

        // Immediate read
        final immediateRead = await storage.read(key: key);
        expect(
          immediateRead,
          equals(value),
          reason: 'Immediate read failed for key: $key',
        );

        // Delayed read (simulate storage persistence)
        await Future.delayed(const Duration(milliseconds: 10));
        final delayedRead = await storage.read(key: key);
        expect(
          delayedRead,
          equals(value),
          reason: 'Delayed read failed for key: $key',
        );
      }
    });

    test('should handle basic write and read operations', () async {
      // ARRANGE
      const testKey = 'basic_test_key';
      const testValue = 'basic_test_value';

      SharedPreferences.setMockInitialValues({});

      // ACT
      await storage.write(key: testKey, value: testValue);
      final retrieved = await storage.read(key: testKey);

      // ASSERT
      expect(retrieved, equals(testValue));
    });

    test('should handle containsKey operation correctly', () async {
      // ARRANGE
      const existingKey = 'existing_key';
      const nonExistentKey = 'non_existent_key';
      const testValue = 'test_value';

      SharedPreferences.setMockInitialValues({});

      // ACT - Write a value
      await storage.write(key: existingKey, value: testValue);

      // ASSERT
      expect(
        await storage.containsKey(key: existingKey),
        isTrue,
        reason: 'Should detect existing key',
      );

      expect(
        await storage.containsKey(key: nonExistentKey),
        isFalse,
        reason: 'Should not detect non-existent key',
      );
    });

    test('should handle delete operation correctly', () async {
      // ARRANGE
      const testKey = 'delete_test_key';
      const testValue = 'delete_test_value';

      SharedPreferences.setMockInitialValues({});

      // ACT - Write, verify, delete, verify deleted
      await storage.write(key: testKey, value: testValue);

      expect(
        await storage.read(key: testKey),
        equals(testValue),
        reason: 'Value should exist before deletion',
      );

      await storage.delete(key: testKey);

      // ASSERT
      expect(
        await storage.read(key: testKey),
        isNull,
        reason: 'Value should be null after deletion',
      );

      expect(
        await storage.containsKey(key: testKey),
        isFalse,
        reason: 'Key should not exist after deletion',
      );
    });

    test('should return null for non-existent keys', () async {
      // ARRANGE
      const nonExistentKey = 'does_not_exist';

      SharedPreferences.setMockInitialValues({});

      // ACT
      final result = await storage.read(key: nonExistentKey);

      // ASSERT
      expect(result, isNull, reason: 'Should return null for non-existent key');
    });

    test('should handle various data types as string values', () async {
      // ARRANGE
      const testCases = [
        {'key': 'string_key', 'value': 'simple_string'},
        {'key': 'json_key', 'value': '{"test": "data"}'},
        {'key': 'number_string_key', 'value': '12345'},
        {'key': 'boolean_string_key', 'value': 'true'},
        {
          'key': 'token_key',
          'value': 'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.signature',
        },
      ];

      SharedPreferences.setMockInitialValues({});

      // ACT & ASSERT
      for (final testCase in testCases) {
        final key = testCase['key']!;
        final value = testCase['value']!;

        await storage.write(key: key, value: value);
        final retrieved = await storage.read(key: key);

        expect(
          retrieved,
          equals(value),
          reason: 'Failed to store/retrieve value for key: $key',
        );

        // Verify key exists
        expect(
          await storage.containsKey(key: key),
          isTrue,
          reason: 'Key should exist: $key',
        );
      }
    });

    test('should overwrite existing values correctly', () async {
      // ARRANGE
      const testKey = 'overwrite_test_key';
      const originalValue = 'original_value';
      const newValue = 'new_overwritten_value';

      SharedPreferences.setMockInitialValues({});

      // ACT - Write original, verify, overwrite, verify new
      await storage.write(key: testKey, value: originalValue);
      expect(
        await storage.read(key: testKey),
        equals(originalValue),
        reason: 'Original value should be stored',
      );

      await storage.write(key: testKey, value: newValue);
      final finalValue = await storage.read(key: testKey);

      // ASSERT
      expect(
        finalValue,
        equals(newValue),
        reason: 'Value should be overwritten with new value',
      );
    });
  });
}
