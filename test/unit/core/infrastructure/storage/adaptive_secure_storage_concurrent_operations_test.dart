import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:edulift/core/storage/adaptive_secure_storage.dart';

/// ISOLATED TEST SUITE: Concurrent Operations
///
/// PURPOSE: Test concurrent access and thread safety in isolation
/// FOCUS: Race conditions, state consistency under concurrent load
/// CRITICAL: Each test gets completely fresh mock instances
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdaptiveSecureStorage - Concurrent Operations Tests', () {
    late AdaptiveSecureStorage storage;

    setUp(() {
      // CRITICAL: COMPLETELY ISOLATED MOCK SETUP
      // Each test starts with fresh mocks to prevent state pollution
      SharedPreferences.setMockInitialValues({});
      storage = AdaptiveSecureStorage();
    });

    tearDown(() async {
      // CRITICAL: COMPLETE STATE CLEANUP
      // Force garbage collection of any shared state
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Additional cleanup for concurrent tests
      await Future.delayed(const Duration(milliseconds: 10));
    });

    test('should handle concurrent jwt_token_dev operations', () async {
      // ARRANGE
      const devTokenKey = 'jwt_token_dev';
      const token1 = 'concurrent_token_1';
      const token2 = 'concurrent_token_2';

      // Fresh mock setup for this specific test
      SharedPreferences.setMockInitialValues({});

      // ACT - Simulate concurrent operations
      final futures = [
        storage.write(key: devTokenKey, value: token1),
        storage.write(key: devTokenKey, value: token2),
        storage.read(key: devTokenKey),
      ];

      await Future.wait(futures);
      final finalToken = await storage.read(key: devTokenKey);

      // ASSERT - Should not crash or create inconsistent state
      expect(
        finalToken,
        isNotNull,
        reason: 'Concurrent operations should not result in NULL token',
      );
      expect(
        [token1, token2],
        contains(finalToken),
        reason: 'Final token should be one of the stored values',
      );
    });

    test('should handle concurrent storage operations correctly', () async {
      // ARRANGE
      const baseKey = 'concurrent_test';

      // Fresh mock setup specific to this test
      SharedPreferences.setMockInitialValues({});

      // ACT - Simulate multiple concurrent operations
      final futures = <Future>[];

      // Add multiple write operations
      for (var i = 0; i < 10; i++) {
        futures.add(storage.write(key: '${baseKey}_$i', value: 'value_$i'));
      }

      // Add read operations
      for (var i = 0; i < 10; i++) {
        futures.add(storage.read(key: '${baseKey}_$i'));
      }

      // Wait for all operations to complete
      final results = await Future.wait(futures);

      // ASSERT - No operation should fail
      expect(
        results.length,
        equals(20),
        reason: 'All concurrent operations should complete',
      );

      // Verify all data was stored correctly
      for (var i = 0; i < 10; i++) {
        final retrieved = await storage.read(key: '${baseKey}_$i');
        expect(
          retrieved,
          equals('value_$i'),
          reason: 'Concurrent write for key ${baseKey}_$i should succeed',
        );
      }
    });

    test('should maintain key consistency under concurrent access', () async {
      // ARRANGE
      const sharedKey = 'shared_concurrent_key';
      const values = ['value1', 'value2', 'value3', 'value4', 'value5'];

      // Fresh mock setup for this specific concurrent test
      SharedPreferences.setMockInitialValues({});

      // ACT - Multiple threads writing to same key
      final futures = values
          .map((value) => storage.write(key: sharedKey, value: value))
          .toList();

      await Future.wait(futures);

      // Read final value
      final finalValue = await storage.read(key: sharedKey);

      // ASSERT
      expect(
        finalValue,
        isNotNull,
        reason: 'Concurrent writes should not result in NULL value',
      );
      expect(
        values,
        contains(finalValue),
        reason: 'Final value should be one of the written values',
      );

      // Verify no double-prefixed keys were created
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();

      expect(
        allKeys,
        contains('shared_concurrent_key'),
        reason: 'Should contain key (no prefix in test environment)',
      );
      expect(
        allKeys,
        isNot(contains('secure_secure_shared_concurrent_key')),
        reason: 'Should not contain double-prefixed key',
      );
    });
  });
}
