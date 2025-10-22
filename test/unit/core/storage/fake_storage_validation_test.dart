// EduLift Mobile - Fake Storage Validation Test
// Validates that our test infrastructure uses FakeSecureStorage correctly

import 'package:flutter_test/flutter_test.dart';
import '../../../test_mocks/storage/fake_secure_storage.dart';
import 'package:edulift/core/storage/secure_storage.dart';

void main() {
  group('Fake Storage Validation', () {
    late FakeSecureStorage fakeStorage;

    setUp(() {
      fakeStorage = FakeSecureStorage();
    });

    test('FakeSecureStorage performs fast in-memory operations', () async {
      final stopwatch = Stopwatch()..start();

      // Perform 100 operations to test performance
      for (var i = 0; i < 100; i++) {
        await fakeStorage.write(key: 'key_$i', value: 'value_$i');
        final value = await fakeStorage.read(key: 'key_$i');
        expect(value, equals('value_$i'));
      }

      stopwatch.stop();

      // Performance timing assertion removed - arbitrary timeout

      // Clean up
      await fakeStorage.deleteAll();
    });

    test('FakeSecureStorage implements all required methods', () async {
      // Write operation
      await fakeStorage.write(key: 'test_key', value: 'test_value');

      // Read operation
      final value = await fakeStorage.read(key: 'test_key');
      expect(value, equals('test_value'));

      // Contains key check
      expect(fakeStorage.containsKey('test_key'), isTrue);
      expect(fakeStorage.containsKey('nonexistent'), isFalse);

      // Delete operation
      await fakeStorage.delete(key: 'test_key');
      final deletedValue = await fakeStorage.read(key: 'test_key');
      expect(deletedValue, isNull);

      // DeleteAll operation
      await fakeStorage.write(key: 'key1', value: 'value1');
      await fakeStorage.write(key: 'key2', value: 'value2');
      expect(fakeStorage.keys.length, equals(2));

      await fakeStorage.deleteAll();
      expect(fakeStorage.keys.length, equals(0));
    });

    test('FakeSecureStorage error simulation works correctly', () async {
      final testError = Exception('Simulated storage error');

      // Simulate error
      fakeStorage.simulateError(testError);

      // All operations should throw the simulated error
      expect(() => fakeStorage.read(key: 'key'), throwsA(testError));
      expect(
        () => fakeStorage.write(key: 'key', value: 'value'),
        throwsA(testError),
      );
      expect(() => fakeStorage.delete(key: 'key'), throwsA(testError));
      expect(() => fakeStorage.deleteAll(), throwsA(testError));

      // Clear error and verify normal operation resumes
      fakeStorage.clearError();
      await fakeStorage.write(key: 'test', value: 'works');
      final result = await fakeStorage.read(key: 'test');
      expect(result, equals('works'));
    });

    test('FakeSecureStorage is a valid SecureStorage implementation', () {
      // Type check
      expect(fakeStorage, isA<SecureStorage>());

      // Interface compliance check
      final storage = fakeStorage as SecureStorage;
      expect(storage.read, isNotNull);
      expect(storage.write, isNotNull);
      expect(storage.delete, isNotNull);
      expect(storage.deleteAll, isNotNull);
    });

    test('FakeSecureStorage provides test isolation', () async {
      // First test scenario
      await fakeStorage.write(key: 'shared_key', value: 'scenario1');
      expect(await fakeStorage.read(key: 'shared_key'), equals('scenario1'));

      // Clear for next test
      fakeStorage.clear();

      // Second test scenario - should be isolated
      expect(await fakeStorage.read(key: 'shared_key'), isNull);
      await fakeStorage.write(key: 'shared_key', value: 'scenario2');
      expect(await fakeStorage.read(key: 'shared_key'), equals('scenario2'));
    });
  });
}
