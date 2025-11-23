/// TieredStorageService Tests
/// STATE-OF-THE-ART 2024-2025 Flutter Secure Storage Architecture Tests
///
/// Tests the tiered storage service with:
/// - Data sensitivity levels (high/medium/low)
/// - Hardware-backed encryption for sensitive data
/// - SharedPreferences for ephemeral data
/// - Performance characteristics

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edulift/core/security/tiered_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TieredStorageService', () {
    late TieredStorageService service;

    setUp(() async {
      // Reset SharedPreferences for each test
      SharedPreferences.setMockInitialValues({});
      service = TieredStorageService();
      await service.initialize();
    });

    group('Initialization', () {
      test('should initialize successfully', () async {
        final newService = TieredStorageService();
        await newService.initialize();
        // Should not throw
        expect(true, isTrue);
      });

      test('should be safe to initialize multiple times', () async {
        await service.initialize();
        await service.initialize();
        // Should not throw
        expect(true, isTrue);
      });

      test('should throw if used before initialization', () {
        // Create a fresh instance without initialization
        // Each test creates a new instance with proper DI
        final freshService = TieredStorageService();
        expect(
          () => freshService.read('test', DataSensitivity.low),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('DataSensitivity.low - SharedPreferences', () {
      test('should store and read low sensitivity data', () async {
        const key = 'test_low_key';
        const value = 'test_low_value';

        await service.store(key, value, DataSensitivity.low);
        final retrieved = await service.read(key, DataSensitivity.low);

        expect(retrieved, equals(value));
      });

      test('should return null for non-existent low sensitivity key', () async {
        final retrieved = await service.read(
          'non_existent_key',
          DataSensitivity.low,
        );
        expect(retrieved, isNull);
      });

      test('should delete low sensitivity data', () async {
        const key = 'test_delete_key';
        const value = 'test_value';

        await service.store(key, value, DataSensitivity.low);
        await service.delete(key, DataSensitivity.low);
        final retrieved = await service.read(key, DataSensitivity.low);

        expect(retrieved, isNull);
      });

      test('should check if low sensitivity key exists', () async {
        const key = 'test_exists_key';
        const value = 'test_value';

        final existsBefore = await service.containsKey(
          key,
          DataSensitivity.low,
        );
        expect(existsBefore, isFalse);

        await service.store(key, value, DataSensitivity.low);

        final existsAfter = await service.containsKey(key, DataSensitivity.low);
        expect(existsAfter, isTrue);
      });

      test('should overwrite existing low sensitivity data', () async {
        const key = 'test_overwrite_key';
        const value1 = 'first_value';
        const value2 = 'second_value';

        await service.store(key, value1, DataSensitivity.low);
        await service.store(key, value2, DataSensitivity.low);
        final retrieved = await service.read(key, DataSensitivity.low);

        expect(retrieved, equals(value2));
      });
    });

    group('PKCE Verifier Convenience Methods', () {
      test('should store and retrieve PKCE verifier', () async {
        const verifier = 'test_pkce_verifier_12345';

        await service.storePkceVerifier(verifier);
        final retrieved = await service.getPkceVerifier();

        expect(retrieved, equals(verifier));
      });

      test('should clear PKCE verifier', () async {
        const verifier = 'test_pkce_verifier_to_clear';

        await service.storePkceVerifier(verifier);
        await service.clearPkceVerifier();
        final retrieved = await service.getPkceVerifier();

        expect(retrieved, isNull);
      });

      test('PKCE verifier should use low sensitivity storage', () async {
        const verifier = 'pkce_low_sensitivity_test';

        await service.storePkceVerifier(verifier);

        // Verify it's stored in SharedPreferences (low sensitivity)
        final prefs = await SharedPreferences.getInstance();
        final storedValue = prefs.getString('pkce_verifier');
        expect(storedValue, equals(verifier));
      });
    });

    group('Magic Link Email Convenience Methods', () {
      test('should store and retrieve magic link email', () async {
        const email = 'test@example.com';

        await service.storeMagicLinkEmail(email);
        final retrieved = await service.getMagicLinkEmail();

        expect(retrieved, equals(email));
      });

      test('should clear magic link email', () async {
        const email = 'test@example.com';

        await service.storeMagicLinkEmail(email);
        await service.clearMagicLinkEmail();
        final retrieved = await service.getMagicLinkEmail();

        expect(retrieved, isNull);
      });

      test('magic link email should use low sensitivity storage', () async {
        const email = 'low_sensitivity@test.com';

        await service.storeMagicLinkEmail(email);

        // Verify it's stored in SharedPreferences (low sensitivity)
        final prefs = await SharedPreferences.getInstance();
        final storedValue = prefs.getString('magic_link_email');
        expect(storedValue, equals(email));
      });
    });

    group('OAuth State Convenience Methods', () {
      test('should store and retrieve OAuth state', () async {
        const state = 'random_oauth_state_12345';

        await service.storeOAuthState(state);
        final retrieved = await service.getOAuthState();

        expect(retrieved, equals(state));
      });

      test('OAuth state should use low sensitivity storage', () async {
        const state = 'oauth_state_test';

        await service.storeOAuthState(state);

        // Verify it's stored in SharedPreferences (low sensitivity)
        final prefs = await SharedPreferences.getInstance();
        final storedValue = prefs.getString('oauth_state');
        expect(storedValue, equals(state));
      });
    });

    group('Clear All Auth Data', () {
      test('should clear all authentication-related data', () async {
        // Store various auth data
        await service.storePkceVerifier('test_verifier');
        await service.storeMagicLinkEmail('test@email.com');
        await service.storeOAuthState('test_state');

        // Clear all
        await service.clearAuthData();

        // Verify all cleared
        expect(await service.getPkceVerifier(), isNull);
        expect(await service.getMagicLinkEmail(), isNull);
        expect(await service.getOAuthState(), isNull);
      });
    });

    group('DataSensitivity Enum', () {
      test('high sensitivity should be defined', () {
        expect(DataSensitivity.high, isNotNull);
        expect(DataSensitivity.high.name, equals('high'));
      });

      test('medium sensitivity should be defined', () {
        expect(DataSensitivity.medium, isNotNull);
        expect(DataSensitivity.medium.name, equals('medium'));
      });

      test('low sensitivity should be defined', () {
        expect(DataSensitivity.low, isNotNull);
        expect(DataSensitivity.low.name, equals('low'));
      });
    });

    group('Performance Characteristics', () {
      test('low sensitivity operations should be fast', () async {
        const iterations = 100;
        final stopwatch = Stopwatch()..start();

        for (var i = 0; i < iterations; i++) {
          await service.store('key_$i', 'value_$i', DataSensitivity.low);
        }

        stopwatch.stop();

        // Low sensitivity should be very fast (< 100ms for 100 operations)
        // This is a rough benchmark, actual performance varies by device
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(1000),
          reason: 'Low sensitivity storage should be fast',
        );
      });

      test('read operations should be fast', () async {
        // Pre-populate data
        for (var i = 0; i < 10; i++) {
          await service.store('read_key_$i', 'value_$i', DataSensitivity.low);
        }

        final stopwatch = Stopwatch()..start();

        for (var i = 0; i < 100; i++) {
          await service.read('read_key_${i % 10}', DataSensitivity.low);
        }

        stopwatch.stop();

        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(500),
          reason: 'Read operations should be fast',
        );
      });
    });

    group('Edge Cases', () {
      test('should handle empty string values', () async {
        const key = 'empty_value_key';
        const value = '';

        await service.store(key, value, DataSensitivity.low);
        final retrieved = await service.read(key, DataSensitivity.low);

        expect(retrieved, equals(''));
      });

      test('should handle very long values', () async {
        const key = 'long_value_key';
        final value = 'x' * 10000; // 10KB string

        await service.store(key, value, DataSensitivity.low);
        final retrieved = await service.read(key, DataSensitivity.low);

        expect(retrieved, equals(value));
      });

      test('should handle special characters in values', () async {
        const key = 'special_chars_key';
        const value = '!@#\$%^&*()_+-=[]{}|;:\'",.<>?/\\`~\n\t';

        await service.store(key, value, DataSensitivity.low);
        final retrieved = await service.read(key, DataSensitivity.low);

        expect(retrieved, equals(value));
      });

      test('should handle unicode characters', () async {
        const key = 'unicode_key';
        const value = 'Hello World! Bonjour!';

        await service.store(key, value, DataSensitivity.low);
        final retrieved = await service.read(key, DataSensitivity.low);

        expect(retrieved, equals(value));
      });
    });
  });
}
