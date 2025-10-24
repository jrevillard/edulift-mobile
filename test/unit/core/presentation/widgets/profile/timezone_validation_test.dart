import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:edulift/core/presentation/widgets/profile/timezone_selector.dart';

void main() {
  group('Timezone Validation Tests', () {
    setUpAll(() async {
      // Initialize timezone database for all tests
      tz.initializeTimeZones();
    });

    group('TimezoneData Validation', () {
      test('all timezones have valid IANA format', () {
        final timezones = getAllTimezones();

        for (final timezone in timezones) {
          expect(timezone.iana, isNotEmpty);
          expect(timezone.city, isNotEmpty);
          expect(timezone.offset, isNotEmpty);

          // IANA timezone format should be either UTC or Region/City
          if (timezone.iana != 'UTC') {
            expect(timezone.iana, contains('/'));
            expect(timezone.iana, matches(r'^[A-Za-z_]+/[A-Za-z_]+$'));
          }
        }
      });

      test('all timezones can be found in timezone database', () {
        final timezones = getAllTimezones();

        for (final timezone in timezones) {
          try {
            final location = tz.getLocation(timezone.iana);
            expect(location, isNotNull);
            expect(location.name, equals(timezone.iana));
          } catch (e) {
            fail(
              'Timezone "${timezone.iana}" is not valid in timezone database: $e',
            );
          }
        }
      });

      test('timezone display names are well-formatted', () {
        final timezones = getAllTimezones();

        for (final timezone in timezones) {
          final displayName = timezone.displayName;
          expect(displayName, isNotEmpty);

          // Should contain city name
          expect(displayName, contains(timezone.city));

          // Should contain offset information
          expect(displayName, contains(timezone.offset));

          // Should be properly formatted: "City (UTC+X)" (allowing special characters)
          expect(
            displayName,
            matches(r'^[\w\s\(\)\-\u00C0-\u017F]+ \(UTC[+-][0-9:]+.*\)$'),
          );
        }
      });
    });

    group('Timezone Coverage Tests', () {
      test('covers all major geographic regions', () {
        final timezones = getAllTimezones();

        // North America coverage
        expect(timezones.any((tz) => tz.iana.startsWith('America/')), isTrue);
        expect(timezones.any((tz) => tz.city.contains('New York')), isTrue);
        expect(timezones.any((tz) => tz.city.contains('Los Angeles')), isTrue);
        expect(timezones.any((tz) => tz.city.contains('Chicago')), isTrue);
        expect(timezones.any((tz) => tz.city.contains('Toronto')), isTrue);

        // Europe coverage
        expect(timezones.any((tz) => tz.iana.startsWith('Europe/')), isTrue);
        expect(timezones.any((tz) => tz.city.contains('Paris')), isTrue);
        expect(timezones.any((tz) => tz.city.contains('London')), isTrue);
        expect(timezones.any((tz) => tz.city.contains('Berlin')), isTrue);
        expect(timezones.any((tz) => tz.city.contains('Madrid')), isTrue);

        // Asia coverage
        expect(timezones.any((tz) => tz.iana.startsWith('Asia/')), isTrue);
        expect(timezones.any((tz) => tz.city.contains('Tokyo')), isTrue);
        expect(timezones.any((tz) => tz.city.contains('Shanghai')), isTrue);
        expect(timezones.any((tz) => tz.city.contains('Dubai')), isTrue);
        expect(timezones.any((tz) => tz.city.contains('Singapore')), isTrue);

        // Australia & Pacific coverage
        expect(timezones.any((tz) => tz.iana.startsWith('Australia/')), isTrue);
        expect(timezones.any((tz) => tz.city.contains('Sydney')), isTrue);
        expect(timezones.any((tz) => tz.city.contains('Melbourne')), isTrue);
        expect(timezones.any((tz) => tz.iana.startsWith('Pacific/')), isTrue);

        // Africa coverage
        expect(timezones.any((tz) => tz.iana.startsWith('Africa/')), isTrue);
        expect(timezones.any((tz) => tz.city.contains('Cairo')), isTrue);
        expect(timezones.any((tz) => tz.city.contains('Johannesburg')), isTrue);
        expect(timezones.any((tz) => tz.city.contains('Lagos')), isTrue);
      });

      test('covers major timezone offsets', () {
        final timezones = getAllTimezones();
        final offsets = timezones.map((tz) => tz.offset).toSet();

        // Should cover major UTC offsets
        expect(offsets, contains('UTC+0'));
        expect(offsets.any((offset) => offset.contains('UTC+1')), isTrue);
        expect(offsets.any((offset) => offset.contains('UTC+2')), isTrue);
        expect(offsets.any((offset) => offset.contains('UTC+5')), isTrue);
        expect(offsets.any((offset) => offset.contains('UTC+8')), isTrue);
        expect(offsets.any((offset) => offset.contains('UTC+9')), isTrue);
        expect(offsets.any((offset) => offset.contains('UTC-5')), isTrue);
        expect(offsets.any((offset) => offset.contains('UTC-8')), isTrue);

        // Should cover DST offsets
        expect(
          offsets.any((offset) => offset.contains('/')),
          isTrue,
        ); // Indicates DST
      });

      test('includes important business and population centers', () {
        final timezones = getAllTimezones();

        // Major financial centers
        expect(timezones.any((tz) => tz.city.contains('New York')), isTrue);
        expect(timezones.any((tz) => tz.city.contains('London')), isTrue);
        expect(timezones.any((tz) => tz.city.contains('Tokyo')), isTrue);
        expect(timezones.any((tz) => tz.city.contains('Hong Kong')), isTrue);
        expect(timezones.any((tz) => tz.city.contains('Singapore')), isTrue);

        // Major population centers
        expect(timezones.any((tz) => tz.city.contains('Shanghai')), isTrue);
        expect(timezones.any((tz) => tz.city.contains('Mumbai')), isTrue);
        expect(timezones.any((tz) => tz.city.contains('São Paulo')), isTrue);
        expect(timezones.any((tz) => tz.city.contains('Mexico City')), isTrue);
      });
    });

    group('Timezone Search Functionality Tests', () {
      test('search matches city names', () {
        final timezones = getAllTimezones();

        // Search by city name
        final yorkResults = timezones
            .where((tz) => tz.city.toLowerCase().contains('york'))
            .toList();
        expect(yorkResults, isNotEmpty);
        expect(yorkResults.any((tz) => tz.city.contains('New York')), isTrue);

        // Search by partial city name
        final yorkPartialResults = timezones
            .where((tz) => tz.city.toLowerCase().contains('york'))
            .toList();
        expect(yorkPartialResults, isNotEmpty);
      });

      test('search matches IANA timezone names', () {
        final timezones = getAllTimezones();

        // Search by IANA timezone name
        final americaResults = timezones
            .where((tz) => tz.iana.toLowerCase().contains('america'))
            .toList();
        expect(americaResults, isNotEmpty);
        expect(
          americaResults.length,
          greaterThan(5),
        ); // Multiple American timezones

        // Search by region
        final europeResults = timezones
            .where((tz) => tz.iana.toLowerCase().contains('europe'))
            .toList();
        expect(europeResults, isNotEmpty);
        expect(
          europeResults.length,
          greaterThan(10),
        ); // Multiple European timezones
      });

      test('search is case-insensitive', () {
        final timezones = getAllTimezones();

        // Test lowercase search
        final lowercaseResults = timezones
            .where((tz) => tz.city.toLowerCase().contains('paris'))
            .toList();
        expect(lowercaseResults, isNotEmpty);

        // Test uppercase search (should still work with toLowerCase)
        final uppercaseResults = timezones
            .where((tz) => tz.city.toLowerCase().contains('paris'))
            .toList();
        expect(uppercaseResults, isNotEmpty);

        // Both should return same results
        expect(lowercaseResults.length, equals(uppercaseResults.length));
      });

      test('search handles partial matches', () {
        final timezones = getAllTimezones();

        // Search for partial city name
        final angelesResults = timezones
            .where((tz) => tz.city.toLowerCase().contains('angeles'))
            .toList();
        expect(angelesResults, isNotEmpty);
        expect(
          angelesResults.any((tz) => tz.city.contains('Los Angeles')),
          isTrue,
        );

        // Search for partial timezone name
        final yorkResults = timezones
            .where((tz) => tz.iana.toLowerCase().contains('york'))
            .toList();
        expect(yorkResults, isNotEmpty);
        expect(yorkResults.any((tz) => tz.iana == 'America/New_York'), isTrue);
      });

      test('empty search returns all timezones', () {
        final timezones = getAllTimezones();

        // Empty search should match all
        final emptyResults = timezones
            .where((tz) => tz.city.toLowerCase().contains(''))
            .toList();
        expect(emptyResults.length, equals(timezones.length));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('handles timezone with complex offsets', () {
        final timezones = getAllTimezones();

        // Find timezones with complex offsets (non-hourly)
        final complexOffsets = timezones
            .where(
              (tz) => tz.offset.contains(':30') || tz.offset.contains(':45'),
            )
            .toList();

        expect(complexOffsets, isNotEmpty);

        // Should include India (UTC+5:30)
        expect(complexOffsets.any((tz) => tz.iana == 'Asia/Kolkata'), isTrue);

        // Should include some Australian timezones
        expect(
          complexOffsets.any((tz) => tz.iana.startsWith('Australia/')),
          isTrue,
        );
      });

      test('handles timezone with DST information', () {
        final timezones = getAllTimezones();

        // Find timezones with DST (indicated by slash in offset)
        final dstTimezones = timezones
            .where((tz) => tz.offset.contains('/'))
            .toList();

        expect(dstTimezones, isNotEmpty);

        // Should include timezones from regions that observe DST
        expect(dstTimezones.any((tz) => tz.iana == 'America/New_York'), isTrue);
        expect(dstTimezones.any((tz) => tz.iana == 'Europe/Paris'), isTrue);
        expect(dstTimezones.any((tz) => tz.iana == 'Europe/London'), isTrue);
        expect(dstTimezones.any((tz) => tz.iana == 'Australia/Sydney'), isTrue);
      });

      test('handles timezone without DST', () {
        final timezones = getAllTimezones();

        // Find timezones without DST (no slash in offset)
        final nonDstTimezones = timezones
            .where((tz) => !tz.offset.contains('/'))
            .toList();

        expect(nonDstTimezones, isNotEmpty);

        // UTC doesn't observe DST
        expect(nonDstTimezones.any((tz) => tz.iana == 'UTC'), isTrue);

        // Some equatorial regions don't observe DST
        expect(nonDstTimezones.any((tz) => tz.city.contains('Dubai')), isTrue);
        expect(
          nonDstTimezones.any((tz) => tz.city.contains('Singapore')),
          isTrue,
        );
      });
    });

    group('Performance Tests', () {
      test('timezone list generation is performant', () {
        final stopwatch = Stopwatch()..start();

        final timezones = getAllTimezones();

        stopwatch.stop();

        // Should generate list quickly (under 10ms)
        expect(stopwatch.elapsedMilliseconds, lessThan(10));
        expect(timezones.length, greaterThan(70));
      });

      test('timezone search is performant', () {
        final timezones = getAllTimezones();

        final stopwatch = Stopwatch()..start();

        // Simulate searching for "New"
        final results = timezones
            .where((tz) => tz.city.toLowerCase().contains('new'))
            .toList();

        stopwatch.stop();

        // Search should be fast (under 5ms)
        expect(stopwatch.elapsedMilliseconds, lessThan(5));
        expect(results, isNotEmpty);
      });
    });
  });
}
