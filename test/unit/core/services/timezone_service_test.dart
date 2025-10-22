// EduLift Mobile - TimezoneService Unit Tests
// Tests for timezone detection and conversion functionality

import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/services/timezone_service.dart';

void main() {
  group('TimezoneService', () {
    setUp(() {
      // Reset the service before each test
      TimezoneService.reset();
    });

    group('initialize', () {
      test('should initialize timezone database successfully', () async {
        // Act
        await TimezoneService.initialize();

        // Assert
        expect(TimezoneService.isInitialized, true);
      });

      test('should not re-initialize if already initialized', () async {
        // Arrange
        await TimezoneService.initialize();

        // Act
        await TimezoneService.initialize();

        // Assert - should not throw
        expect(TimezoneService.isInitialized, true);
      });
    });

    group('getCurrentTimezone', () {
      test('should return a valid IANA timezone string', () async {
        // Arrange
        await TimezoneService.initialize();

        // Act
        final timezone = await TimezoneService.getCurrentTimezone();

        // Assert
        expect(timezone, isNotNull);
        expect(timezone, isNotEmpty);
        // Should be a valid timezone format (e.g., "Europe/Paris", "America/New_York", "UTC")
        expect(timezone.contains('/') || timezone == 'UTC', true);
      });

      test('should cache timezone after first call', () async {
        // Arrange
        await TimezoneService.initialize();

        // Act
        final timezone1 = await TimezoneService.getCurrentTimezone();
        final timezone2 = await TimezoneService.getCurrentTimezone();

        // Assert
        expect(timezone1, equals(timezone2));
      });

      test('should return UTC as fallback on error', () async {
        // Note: This test depends on the implementation details
        // In a real scenario, you might want to mock flutter_native_timezone
        // to force an error condition

        // For now, just verify that getCurrentTimezone doesn't throw
        await TimezoneService.initialize();
        final timezone = await TimezoneService.getCurrentTimezone();
        expect(timezone, isNotNull);
      });
    });

    group('convertUtcTimeToLocal', () {
      setUp(() async {
        await TimezoneService.initialize();
      });

      test('should convert UTC time to Paris local time (summer)', () {
        // Arrange
        const utcTime = '2025-07-15T10:00:00.000Z'; // Summer - UTC+2
        const timezone = 'Europe/Paris';

        // Act
        final localTime = TimezoneService.convertUtcTimeToLocal(utcTime, timezone);

        // Assert
        expect(localTime, isNotNull);
        expect(localTime, contains('2025-07-15'));
        expect(localTime, contains('12:00:00')); // 10:00 UTC + 2h = 12:00
      });

      test('should convert UTC time to Paris local time (winter)', () {
        // Arrange
        const utcTime = '2025-01-15T10:00:00.000Z'; // Winter - UTC+1
        const timezone = 'Europe/Paris';

        // Act
        final localTime = TimezoneService.convertUtcTimeToLocal(utcTime, timezone);

        // Assert
        expect(localTime, isNotNull);
        expect(localTime, contains('2025-01-15'));
        expect(localTime, contains('11:00:00')); // 10:00 UTC + 1h = 11:00
      });

      test('should convert UTC time to New York local time', () {
        // Arrange
        const utcTime = '2025-07-15T14:00:00.000Z'; // Summer - UTC-4
        const timezone = 'America/New_York';

        // Act
        final localTime = TimezoneService.convertUtcTimeToLocal(utcTime, timezone);

        // Assert
        expect(localTime, isNotNull);
        expect(localTime, contains('2025-07-15'));
        expect(localTime, contains('10:00:00')); // 14:00 UTC - 4h = 10:00
      });

      test('should handle UTC timezone', () {
        // Arrange
        const utcTime = '2025-10-19T07:30:00.000Z';
        const timezone = 'UTC';

        // Act
        final localTime = TimezoneService.convertUtcTimeToLocal(utcTime, timezone);

        // Assert
        expect(localTime, isNotNull);
        expect(localTime, contains('2025-10-19'));
        expect(localTime, contains('07:30:00'));
      });

      test('should return original time on conversion error', () {
        // Arrange
        const invalidTime = 'invalid-time-string';
        const timezone = 'Europe/Paris';

        // Act
        final result = TimezoneService.convertUtcTimeToLocal(invalidTime, timezone);

        // Assert - should return original string as fallback
        expect(result, equals(invalidTime));
      });
    });

    group('convertLocalTimeToUtc', () {
      setUp(() async {
        await TimezoneService.initialize();
      });

      test('should convert Paris local time to UTC (summer)', () {
        // Arrange
        const localTime = '2025-07-15T12:00:00'; // Summer - UTC+2
        const timezone = 'Europe/Paris';

        // Act
        final utcTime = TimezoneService.convertLocalTimeToUtc(localTime, timezone);

        // Assert
        expect(utcTime, isNotNull);
        expect(utcTime, contains('2025-07-15'));
        expect(utcTime, contains('10:00:00')); // 12:00 Paris - 2h = 10:00 UTC
      });

      test('should convert Paris local time to UTC (winter)', () {
        // Arrange
        const localTime = '2025-01-15T11:00:00'; // Winter - UTC+1
        const timezone = 'Europe/Paris';

        // Act
        final utcTime = TimezoneService.convertLocalTimeToUtc(localTime, timezone);

        // Assert
        expect(utcTime, isNotNull);
        expect(utcTime, contains('2025-01-15'));
        expect(utcTime, contains('10:00:00')); // 11:00 Paris - 1h = 10:00 UTC
      });

      test('should convert New York local time to UTC', () {
        // Arrange
        const localTime = '2025-07-15T10:00:00'; // Summer - UTC-4
        const timezone = 'America/New_York';

        // Act
        final utcTime = TimezoneService.convertLocalTimeToUtc(localTime, timezone);

        // Assert
        expect(utcTime, isNotNull);
        expect(utcTime, contains('2025-07-15'));
        expect(utcTime, contains('14:00:00')); // 10:00 NY + 4h = 14:00 UTC
      });

      test('should handle time strings with timezone info', () {
        // Arrange
        const localTime = '2025-10-19T09:30:00+02:00'; // Already has timezone
        const timezone = 'Europe/Paris';

        // Act
        final utcTime = TimezoneService.convertLocalTimeToUtc(localTime, timezone);

        // Assert
        expect(utcTime, isNotNull);
        expect(utcTime, contains('2025-10-19'));
        expect(utcTime, contains('07:30:00')); // 09:30+02:00 = 07:30 UTC
      });

      test('should handle UTC timezone', () {
        // Arrange
        const localTime = '2025-10-19T07:30:00';
        const timezone = 'UTC';

        // Act
        final utcTime = TimezoneService.convertLocalTimeToUtc(localTime, timezone);

        // Assert
        expect(utcTime, isNotNull);
        expect(utcTime, contains('2025-10-19'));
        expect(utcTime, contains('07:30:00'));
      });

      test('should return original time on conversion error', () {
        // Arrange
        const invalidTime = 'invalid-time-string';
        const timezone = 'Europe/Paris';

        // Act
        final result = TimezoneService.convertLocalTimeToUtc(invalidTime, timezone);

        // Assert - should return original string as fallback
        expect(result, equals(invalidTime));
      });
    });

    group('clearCache', () {
      test('should clear cached timezone', () async {
        // Arrange
        await TimezoneService.initialize();
        await TimezoneService.getCurrentTimezone(); // Cache a value

        // Act
        TimezoneService.clearCache();

        // Note: We can't directly verify the cache is cleared without exposing
        // internal state, but we can verify the method doesn't throw
        final timezone = await TimezoneService.getCurrentTimezone();

        // Assert
        expect(timezone, isNotNull);
      });
    });

    group('reset', () {
      test('should reset service state', () async {
        // Arrange
        await TimezoneService.initialize();

        // Act
        TimezoneService.reset();

        // Assert
        expect(TimezoneService.isInitialized, false);
      });
    });

    group('round-trip conversion', () {
      setUp(() async {
        await TimezoneService.initialize();
      });

      test('should maintain datetime integrity in round-trip conversion', () {
        // Arrange
        const originalUtc = '2025-10-19T07:30:00.000Z';
        const timezone = 'Europe/Paris';

        // Act - Convert UTC → Local → UTC
        final local = TimezoneService.convertUtcTimeToLocal(originalUtc, timezone);
        final backToUtc = TimezoneService.convertLocalTimeToUtc(local, timezone);

        // Assert - Should get back to original UTC time (accounting for milliseconds)
        expect(backToUtc, contains('2025-10-19'));
        expect(backToUtc, contains('07:30:00'));
      });

      test('should handle multiple timezones consistently', () {
        // Arrange
        const utcTime = '2025-10-19T12:00:00.000Z';
        const timezones = [
          'Europe/Paris',
          'America/New_York',
          'Asia/Tokyo',
          'Australia/Sydney',
        ];

        // Act & Assert
        for (final timezone in timezones) {
          final local = TimezoneService.convertUtcTimeToLocal(utcTime, timezone);
          final backToUtc = TimezoneService.convertLocalTimeToUtc(local, timezone);

          // The round-trip conversion should preserve the original UTC time
          // Parse and compare the datetime objects
          final originalParsed = DateTime.parse(utcTime);
          final resultParsed = DateTime.parse(backToUtc);

          expect(resultParsed.year, equals(originalParsed.year));
          expect(resultParsed.month, equals(originalParsed.month));
          expect(resultParsed.day, equals(originalParsed.day));
          expect(resultParsed.hour, equals(originalParsed.hour));
          expect(resultParsed.minute, equals(originalParsed.minute));
        }
      });
    });
  });
}
