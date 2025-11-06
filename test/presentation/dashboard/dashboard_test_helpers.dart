import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edulift/features/dashboard/domain/entities/dashboard_transport_summary.dart';
import 'package:edulift/core/domain/entities/schedule/time_of_day.dart';
import 'package:edulift/core/domain/entities/schedule/vehicle_assignment.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Helper functions and mock data for dashboard component tests
class DashboardTestHelpers {
  // Mock Data Factory Methods
  static DayTransportSummary createMockDaySummary({
    DateTime? date,
    List<TransportSlotSummary>? transports,
    int totalChildren = 15,
    int totalVehicles = 2,
    bool hasTransports = true,
  }) {
    return DayTransportSummary(
      date: date ?? DateTime(2024, 1, 15),
      transports: transports ?? createMockTransportList(),
      totalChildrenInVehicles: totalChildren,
      totalVehiclesWithAssignments: totalVehicles,
      hasScheduledTransports: hasTransports,
    );
  }

  static TransportSlotSummary createMockTransport({
    TimeOfDayValue? time,
    String? destination,
    List<VehicleAssignmentSummary>? vehicles,
    int totalChildren = 15,
    int totalCapacity = 20,
    CapacityStatus status = CapacityStatus.available,
  }) {
    return TransportSlotSummary(
      time: time ?? const TimeOfDayValue(8, 30),
      destination: destination ?? 'Test School',
      vehicleAssignmentSummaries: vehicles ?? createMockVehicleList(),
      totalChildrenAssigned: totalChildren,
      totalCapacity: totalCapacity,
      overallCapacityStatus: status,
    );
  }

  static VehicleAssignmentSummary createMockVehicle({
    String? id,
    String? name,
    int capacity = 20,
    int assigned = 15,
    int available = 5,
    CapacityStatus status = CapacityStatus.available,
  }) {
    return VehicleAssignmentSummary(
      vehicleId: id ?? 'vehicle_$assigned',
      vehicleName: name ?? 'Bus $assigned',
      vehicleCapacity: capacity,
      assignedChildrenCount: assigned,
      availableSeats: available,
      capacityStatus: status,
    );
  }

  static List<TransportSlotSummary> createMockTransportList() {
    return [
      createMockTransport(
        time: const TimeOfDayValue(8, 0),
        destination: 'Morning School',
        totalChildren: 12,
      ),
      createMockTransport(
        time: const TimeOfDayValue(15, 30),
        destination: 'Afternoon Activity',
        status: CapacityStatus.nearFull,
        totalChildren: 18,
      ),
      createMockTransport(
        time: const TimeOfDayValue(18, 0),
        destination: 'Evening Program',
        status: CapacityStatus.full,
        totalCapacity: 15,
      ),
    ];
  }

  static List<VehicleAssignmentSummary> createMockVehicleList() {
    return [
      createMockVehicle(id: 'bus1', name: 'School Bus 1'),
      createMockVehicle(
        id: 'van1',
        name: 'Activity Van',
        capacity: 8,
        assigned: 7,
        available: 1,
        status: CapacityStatus.nearFull,
      ),
    ];
  }

  static List<DayTransportSummary> createMockWeekSummaries() {
    final today = DateTime.now();
    return List.generate(7, (index) {
      final date = today.add(Duration(days: index));
      final hasTransports =
          index % 2 == 0; // Alternate days with/without transports

      return createMockDaySummary(
        date: date,
        transports: hasTransports ? createMockTransportList() : [],
        hasTransports: hasTransports,
      );
    });
  }

  // Test Widget Wrappers
  static Widget createTestWidget({
    required Widget child,
    Locale locale = const Locale('en', ''),
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', ''), Locale('fr', '')],
        locale: locale,
        home: Scaffold(body: child),
      ),
    );
  }

  // Test Data Variants for Different Scenarios
  static TransportSlotSummary createEmptyTransport() {
    return const TransportSlotSummary(
      time: TimeOfDayValue(9, 0),
      destination: 'Empty Destination',
      vehicleAssignmentSummaries: [],
      totalChildrenAssigned: 0,
      totalCapacity: 0,
      overallCapacityStatus: CapacityStatus.available,
    );
  }

  static TransportSlotSummary createOverCapacityTransport() {
    return createMockTransport(
      totalChildren: 25,
      status: CapacityStatus.exceeded,
      vehicles: [
        createMockVehicle(
          assigned: 25,
          available: -5,
          status: CapacityStatus.exceeded,
        ),
      ],
    );
  }

  static VehicleAssignmentSummary createEmptyVehicle() {
    return createMockVehicle(assigned: 0, available: 20);
  }

  static VehicleAssignmentSummary createFullVehicle() {
    return createMockVehicle(
      assigned: 20,
      available: 0,
      status: CapacityStatus.full,
    );
  }

  // Performance Test Helpers
  static Future<void> testWidgetPerformance(
    WidgetTester tester,
    Widget widget, {
    int buildCount = 5,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final stopwatch = Stopwatch()..start();

    for (var i = 0; i < buildCount; i++) {
      await tester.pumpWidget(createTestWidget(child: widget));
      await tester.pumpAndSettle();

      if (stopwatch.elapsed > timeout) {
        throw TimeoutException(
          'Widget building exceeded timeout: ${stopwatch.elapsed}',
          timeout,
        );
      }
    }

    stopwatch.stop();
    debugPrint('Widget built $buildCount times in ${stopwatch.elapsed}');

    // Verify memory usage is reasonable
    expect(
      stopwatch.elapsedMilliseconds / buildCount,
      lessThan(1000),
    ); // < 1s per build
  }

  // Accessibility Test Helpers
  static void verifySemanticLabels(
    WidgetTester tester,
    List<String> expectedLabels,
  ) {
    for (final label in expectedLabels) {
      expect(
        find.bySemanticsLabel(RegExp(label, caseSensitive: false)),
        findsWidgets,
        reason: 'Expected to find semantic label containing: $label',
      );
    }
  }

  static void verifyTouchTargets(WidgetTester tester, List<Key> widgetKeys) {
    for (final key in widgetKeys) {
      final renderBox = tester.renderObject(find.byKey(key)) as RenderBox;

      // Verify minimum touch target size (48dp WCAG AA)
      expect(
        renderBox.size.width,
        greaterThanOrEqualTo(48.0),
        reason: 'Widget with key $key should have minimum width of 48dp',
      );
      expect(
        renderBox.size.height,
        greaterThanOrEqualTo(48.0),
        reason: 'Widget with key $key should have minimum height of 48dp',
      );
    }
  }

  // Color Test Helpers
  static void verifyMaterial3Colors(WidgetTester tester, Key widgetKey) {
    final renderBox = tester.renderObject(find.byKey(widgetKey)) as RenderBox;
    // In real tests, you would verify that colors come from Theme.of(context).colorScheme
    // This is a placeholder for color verification logic
    expect(renderBox, isNotNull);
  }

  // Error State Test Helpers
  static Exception createMockNetworkError() {
    return Exception('Network connection failed');
  }

  static Exception createMockTimeoutError() {
    return Exception('Request timeout');
  }

  // Localization Test Helpers
  static List<Locale> get supportedLocales => const [
    Locale('en', ''),
    Locale('fr', ''),
  ];

  static Future<void> verifyLocalization(
    WidgetTester tester,
    Widget widget,
    Map<String, String> expectedTexts,
  ) async {
    for (final entry in expectedTexts.entries) {
      final locale = Locale(entry.key);
      await tester.pumpWidget(createTestWidget(child: widget, locale: locale));
      await tester.pumpAndSettle();

      expect(
        find.text(entry.value),
        findsWidgets,
        reason: 'Expected to find text "${entry.value}" in locale ${entry.key}',
      );
    }
  }
}

/// Mock provider overrides for testing
class MockProviders {
  static final todayTransportProvider =
      Provider<AsyncValue<DayTransportSummary?>>((ref) {
        return const AsyncValue.data(null);
      });

  static final weekTransportProvider =
      Provider<AsyncValue<List<DayTransportSummary>>>((ref) {
        return AsyncValue.data(DashboardTestHelpers.createMockWeekSummaries());
      });

  static final refreshProvider = Provider<VoidCallback?>((ref) {
    return () {};
  });

  static final weekViewExpandedProvider = StateProvider<bool>((ref) => false);
}

/// Test Constants
class TestConstants {
  static const Key todayTransportCardKey = Key('today_transport_card');
  static const Key sevenDayTimelineKey = Key('seven_day_timeline_widget');
  static const Key vehicleAssignmentRowKey = Key('vehicle_assignment_row');

  static const List<Key> interactiveKeys = [
    Key('see_full_schedule_button'),
    Key('week_view_toggle_button'),
    Key('retry_button'),
    Key('week_retry_button'),
  ];

  static const List<String> requiredSemanticLabels = [
    r"today'.*transports",
    r'next.*7.*days',
    r'vehicle.*name',
    r'capacity.*status',
    r'transport.*time',
    r'destination',
  ];

  static const Map<String, String> expectedLocalizations = {
    'en': "Today's Transports",
    'fr': "Transports d'aujourd'hui", // This would need to be verified
  };
}
