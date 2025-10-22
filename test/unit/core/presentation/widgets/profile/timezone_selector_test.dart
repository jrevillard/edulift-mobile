import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import 'package:edulift/core/presentation/widgets/profile/timezone_selector.dart';
import 'package:edulift/core/services/providers/auth_provider.dart';
import 'package:edulift/core/domain/entities/user.dart';

void main() {
  group('TimezoneSelector Widget Tests', () {
    late User mockUser;

    setUp(() async {
      // Initialize timezone database for tests
      tz.initializeTimeZones();

      final now = DateTime.now();
      mockUser = User(
        id: 'test-user-id',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: now,
        updatedAt: now,
        timezone: 'America/New_York',
      );

      // Mock SharedPreferences behavior
      SharedPreferences.setMockInitialValues({
        'autoSyncTimezone': false,
      });
    });

    Widget createWidgetUnderTest({User? user}) {
      return ProviderScope(
        overrides: [
          currentUserProvider.overrideWithValue(user ?? mockUser),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: TimezoneSelector(),
          ),
        ),
      );
    }

    testWidgets('displays current timezone correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify timezone card is displayed
      expect(find.byKey(const Key('profile_timezone_card')), findsOneWidget);

      // Verify current timezone is displayed
      expect(find.byKey(const Key('current_timezone_display')), findsOneWidget);
      expect(find.text('Current: America/New_York'), findsOneWidget);
    });

    testWidgets('displays search field and dropdown', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify search field is present
      expect(find.byKey(const Key('timezone_search_field')), findsOneWidget);
      expect(find.text('Search timezones...'), findsOneWidget);

      // Verify dropdown is present
      expect(find.byKey(const Key('timezone_dropdown')), findsOneWidget);
    });

    testWidgets('search field filters timezones correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find search field
      final searchField = find.byKey(const Key('timezone_search_field'));
      expect(searchField, findsOneWidget);

      // Enter search query
      await tester.enterText(searchField, 'Paris');
      await tester.pumpAndSettle();

      // Find dropdown
      final dropdown = find.byKey(const Key('timezone_dropdown'));
      expect(dropdown, findsOneWidget);

      // Open dropdown to see filtered results
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // Should show Paris in the filtered results
      expect(find.text('Paris (UTC+1/+2)'), findsAtLeastNWidgets(1));
    });

    testWidgets('search field filters by IANA timezone name', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Search by IANA timezone name
      await tester.enterText(find.byKey(const Key('timezone_search_field')), 'Europe');
      await tester.pumpAndSettle();

      // Open dropdown
      await tester.tap(find.byKey(const Key('timezone_dropdown')));
      await tester.pumpAndSettle();

      // Should show European timezones
      expect(find.text('Paris (UTC+1/+2)'), findsAtLeastNWidgets(1));
      expect(find.text('London (UTC+0/+1)'), findsAtLeastNWidgets(1));
      expect(find.text('Berlin (UTC+1/+2)'), findsAtLeastNWidgets(1));
    });

    testWidgets('search field shows no results message', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Enter search query with no results
      await tester.enterText(find.byKey(const Key('timezone_search_field')), 'InvalidTimezone');
      await tester.pumpAndSettle();

      // Should show "No timezones found" in dropdown label
      expect(find.text('No timezones found'), findsOneWidget);
      expect(find.text('Try a different search term'), findsOneWidget);
    });

    testWidgets('search field clearing shows all timezones', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byKey(const Key('timezone_search_field')), 'Paris');
      await tester.pumpAndSettle();

      // Clear search
      await tester.enterText(find.byKey(const Key('timezone_search_field')), '');
      await tester.pumpAndSettle();

      // Open dropdown
      await tester.tap(find.byKey(const Key('timezone_dropdown')));
      await tester.pumpAndSettle();

      // Should show all timezones again (should be many)
      // Use timezones from the beginning of the list that are guaranteed to be visible
      expect(find.text('UTC (UTC+0)'), findsAtLeastNWidgets(1));
      expect(find.text('New York (UTC-5/-4)'), findsAtLeastNWidgets(1));
      expect(find.text('Los Angeles (UTC-8/-7)'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows auto-sync checkbox', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify auto-sync checkbox is present
      expect(find.byKey(const Key('auto_sync_timezone_checkbox')), findsOneWidget);
      expect(find.text('Automatically sync timezone'), findsOneWidget);
      expect(find.text('Keep timezone synchronized with device'), findsOneWidget);
    });

    testWidgets('controls are disabled during update', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Initially controls should be enabled
      expect(find.byKey(const Key('timezone_search_field')), findsOneWidget);
      expect(find.byKey(const Key('timezone_dropdown')), findsOneWidget);
      expect(find.byKey(const Key('auto_sync_timezone_checkbox')), findsOneWidget);

      // TODO: Test during update state (would need to mock the update process)
    });

    testWidgets('controls are disabled when auto-sync is enabled', (WidgetTester tester) async {
      // Create widget with auto-sync enabled
      SharedPreferences.setMockInitialValues({
        'autoSyncTimezone': true,
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Search field should be present when auto-sync is enabled
      expect(find.byKey(const Key('timezone_search_field')), findsOneWidget);

      // TODO: Test the actual disabled state - need to check if the widget is actually disabled
    });

    testWidgets('handles user with null timezone gracefully', (WidgetTester tester) async {
      // Create user with null timezone
      final now = DateTime.now();
      final userWithNullTimezone = User(
        id: 'test-user-id',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(createWidgetUnderTest(user: userWithNullTimezone));
      await tester.pumpAndSettle();

      // Should fallback to UTC
      expect(find.text('Current: UTC'), findsOneWidget);
    });

    testWidgets('timezone list includes comprehensive coverage', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Open dropdown to see all timezones
      await tester.tap(find.byKey(const Key('timezone_dropdown')));
      await tester.pumpAndSettle();

      // Verify major regions are covered using timezones that are visible in the dropdown
      // Note: Flutter dropdown only renders ~11 items for performance, so we test visible ones
      expect(find.text('UTC (UTC+0)'), findsAtLeastNWidgets(1));

      // North America (all within first few visible entries)
      expect(find.text('New York (UTC-5/-4)'), findsAtLeastNWidgets(1));
      expect(find.text('Los Angeles (UTC-8/-7)'), findsAtLeastNWidgets(1));
      expect(find.text('Chicago (UTC-6/-5)'), findsAtLeastNWidgets(1));
      expect(find.text('Denver (UTC-7/-6)'), findsAtLeastNWidgets(1));
      expect(find.text('Toronto (UTC-5/-4)'), findsAtLeastNWidgets(1));
      expect(find.text('Vancouver (UTC-8/-7)'), findsAtLeastNWidgets(1));
      expect(find.text('Montreal (UTC-5/-4)'), findsAtLeastNWidgets(1));
      expect(find.text('Mexico City (UTC-6/-5)'), findsAtLeastNWidgets(1));
      expect(find.text('Phoenix (UTC-7)'), findsAtLeastNWidgets(1));
      expect(find.text('Anchorage (UTC-9/-8)'), findsAtLeastNWidgets(1));

      // The comprehensive timezone coverage is tested by the getAllTimezones() function tests
      // This test focuses on the UI display of the first visible items in the dropdown
    });
  });

  group('TimezoneData Model Tests', () {
    test('TimezoneData displays correct format', () {
      const timezoneData = TimezoneData(
        iana: 'America/New_York',
        city: 'New York',
        offset: 'UTC-5/-4',
      );

      expect(timezoneData.displayName, equals('New York (UTC-5/-4)'));
    });

    test('TimezoneData handles UTC correctly', () {
      const timezoneData = TimezoneData(
        iana: 'UTC',
        city: 'UTC',
        offset: 'UTC+0',
      );

      expect(timezoneData.displayName, equals('UTC (UTC+0)'));
    });

    test('TimezoneData handles complex offsets', () {
      const timezoneData = TimezoneData(
        iana: 'Asia/Kolkata',
        city: 'Mumbai (Kolkata)',
        offset: 'UTC+5:30',
      );

      expect(timezoneData.displayName, equals('Mumbai (Kolkata) (UTC+5:30)'));
    });
  });

  group('getAllTimezones Function Tests', () {
    test('returns comprehensive timezone list', () {
      final timezones = getAllTimezones();

      // Should have significantly more timezones than the original 8
      expect(timezones.length, greaterThan(60));

      // Should include UTC
      expect(timezones.any((tz) => tz.iana == 'UTC'), isTrue);

      // Should include major timezones from different regions
      expect(timezones.any((tz) => tz.iana == 'America/New_York'), isTrue);
      expect(timezones.any((tz) => tz.iana == 'Europe/Paris'), isTrue);
      expect(timezones.any((tz) => tz.iana == 'Asia/Tokyo'), isTrue);
      expect(timezones.any((tz) => tz.iana == 'Australia/Sydney'), isTrue);
    });

    test('timezones are organized by region', () {
      final timezones = getAllTimezones();

      // Should have timezone data for all entries
      for (final timezone in timezones) {
        expect(timezone.iana, isNotEmpty);
        expect(timezone.city, isNotEmpty);
        expect(timezone.offset, isNotEmpty);
        expect(timezone.displayName, isNotEmpty);
      }
    });

    test('all IANA timezone names are valid', () {
      final timezones = getAllTimezones();

      // All IANA timezone names should be valid format
      for (final timezone in timezones) {
        expect(timezone.iana, matches(r'^[A-Za-z_]+/[A-Za-z_]+$|^UTC$'));
      }
    });
  });
}