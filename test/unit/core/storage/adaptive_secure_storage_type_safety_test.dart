import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edulift/core/storage/adaptive_secure_storage.dart';

/// Tests for type safety in AdaptiveSecureStorage
///
/// CRITICAL BUG FIX: Ensures that reading non-String values (like bool)
/// doesn't cause type cast errors. This was causing crashes when
/// autoSyncTimezone (bool) was in the same SharedPreferences as jwt_token (String).
void main() {
  group('AdaptiveSecureStorage Type Safety', () {
    late AdaptiveSecureStorage storage;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storage = AdaptiveSecureStorage();
    });

    test('read() handles bool values gracefully', () async {
      // Simulate the scenario where a bool value is stored at a key
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('autoSyncTimezone', true);

      // Reading the bool key should return null, not throw
      final result = await storage.read(key: 'autoSyncTimezone');

      expect(result, isNull, reason: 'Should return null for non-string values');
    });

    test('read() handles int values gracefully', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('some_counter', 42);

      final result = await storage.read(key: 'some_counter');

      expect(result, isNull, reason: 'Should return null for non-string values');
    });

    test('read() handles double values gracefully', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('some_ratio', 3.14);

      final result = await storage.read(key: 'some_ratio');

      expect(result, isNull, reason: 'Should return null for non-string values');
    });

    test('read() handles List<String> values gracefully', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('some_list', ['a', 'b', 'c']);

      final result = await storage.read(key: 'some_list');

      expect(result, isNull, reason: 'Should return null for non-string values');
    });

    test('read() returns string values correctly', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token_dev', 'valid-token-123');

      final result = await storage.read(key: 'jwt_token_dev');

      expect(result, equals('valid-token-123'), reason: 'Should return string values correctly');
    });

    test('readAll() skips non-string values', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('string_key', 'string_value');
      await prefs.setBool('bool_key', true);
      await prefs.setInt('int_key', 42);
      await prefs.setDouble('double_key', 3.14);
      await prefs.setStringList('list_key', ['a', 'b']);

      final result = await storage.readAll();

      // Should only contain the string value
      expect(result.length, equals(1), reason: 'Should only include string values');
      expect(result['string_key'], equals('string_value'));
      expect(result.containsKey('bool_key'), isFalse);
      expect(result.containsKey('int_key'), isFalse);
      expect(result.containsKey('double_key'), isFalse);
      expect(result.containsKey('list_key'), isFalse);
    });

    test('mixed storage scenario - token and bool preference coexist', () async {
      // This simulates the real-world bug scenario:
      // - autoSyncTimezone is stored as bool
      // - jwt_token_dev is stored as string
      // Reading jwt_token_dev should work without errors

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('autoSyncTimezone', true);
      await prefs.setString('jwt_token_dev', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...');

      // Reading the token should work
      final token = await storage.read(key: 'jwt_token_dev');
      expect(token, isNotNull);
      expect(token, startsWith('eyJ'));

      // Reading the bool should return null (not crash)
      final autoSync = await storage.read(key: 'autoSyncTimezone');
      expect(autoSync, isNull);

      // readAll should only include the token
      final all = await storage.readAll();
      expect(all.length, equals(1));
      expect(all['jwt_token_dev'], isNotNull);
      expect(all.containsKey('autoSyncTimezone'), isFalse);
    });

    test('write() and read() work correctly for strings', () async {
      const testKey = 'test_key';
      const testValue = 'test_value';

      await storage.write(key: testKey, value: testValue);
      final result = await storage.read(key: testKey);

      expect(result, equals(testValue));
    });

    test('delete() works correctly', () async {
      const testKey = 'test_key';
      const testValue = 'test_value';

      await storage.write(key: testKey, value: testValue);
      await storage.delete(key: testKey);
      final result = await storage.read(key: testKey);

      expect(result, isNull);
    });
  });
}
