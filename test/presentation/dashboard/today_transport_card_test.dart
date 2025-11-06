import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edulift/features/dashboard/presentation/widgets/today_transport_card.dart';
import 'package:edulift/features/dashboard/domain/entities/dashboard_transport_summary.dart';
import 'package:edulift/core/domain/entities/schedule/time_of_day.dart';
import 'package:edulift/core/domain/entities/schedule/vehicle_assignment.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('TodayTransportCard Widget Tests', () {
    Widget createTestWidget({DayTransportSummary? summary}) {
      return const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en', '')],
          home: Scaffold(body: TodayTransportCard()),
        ),
      );
    }

    testWidgets('renders TodayTransportCard with proper structure', (
      WidgetTester tester,
    ) async {
      // Build the widget
      await tester.pumpWidget(createTestWidget());

      // Verify the card exists
      expect(find.byKey(const Key('today_transport_card')), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('displays header with title and date badge', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Verify title exists
      expect(find.byKey(const Key('today_transports_title')), findsOneWidget);
      expect(find.byKey(const Key('current_date_badge')), findsOneWidget);
      expect(find.byIcon(Icons.today), findsOneWidget);
    });

    testWidgets('displays content area for transports', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Look for refreshable content area
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets(
      'footer has see full schedule button when refresh callback is available',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Look for footer elements
        expect(
          find.byKey(const Key('see_full_schedule_button')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('see_full_schedule_text')), findsOneWidget);
        expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      },
    );

    testWidgets('all interactive elements have proper accessibility labels', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Verify semantic labels exist
      expect(
        find.bySemanticsLabel(
          RegExp(r"Today'.*Transports", caseSensitive: false),
        ),
        findsOneWidget,
      );
    });
  });

  group('TransportMiniCard Widget Tests', () {
    late TransportSlotSummary mockTransport;

    setUp(() {
      mockTransport = const TransportSlotSummary(
        time: TimeOfDayValue(8, 30),
        destination: 'Test School',
        vehicleAssignmentSummaries: [
          VehicleAssignmentSummary(
            vehicleId: 'vehicle1',
            vehicleName: 'Bus 1',
            vehicleCapacity: 20,
            assignedChildrenCount: 15,
            availableSeats: 5,
            capacityStatus: CapacityStatus.available,
          ),
        ],
        totalChildrenAssigned: 15,
        totalCapacity: 20,
        overallCapacityStatus: CapacityStatus.available,
      );
    });

    Widget createMiniCardTestWidget() {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', '')],
        home: Scaffold(body: TransportMiniCard(transport: mockTransport)),
      );
    }

    testWidgets('renders TransportMiniCard with all sections', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createMiniCardTestWidget());

      // Verify card structure
      expect(find.byType(TransportMiniCard), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);

      // Verify time section
      expect(find.byKey(const Key('transport_time')), findsOneWidget);

      // Verify destination section
      expect(find.byKey(const Key('transport_destination')), findsOneWidget);

      // Verify capacity section
      expect(find.byKey(const Key('transport_capacity')), findsOneWidget);

      // Verify vehicle section
      expect(find.byKey(const Key('vehicle_count')), findsOneWidget);
    });

    testWidgets('displays transport time correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createMiniCardTestWidget());

      // Verify time display
      expect(find.text('8:30 AM'), findsOneWidget);
    });

    testWidgets('displays destination correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createMiniCardTestWidget());

      // Verify destination display
      expect(find.text('Test School'), findsOneWidget);
    });

    testWidgets('displays capacity information correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createMiniCardTestWidget());

      // Verify capacity display
      expect(find.text('15/20 seats'), findsOneWidget);
    });

    testWidgets('displays vehicle information correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createMiniCardTestWidget());

      // Verify vehicle display
      expect(find.text('Bus 1'), findsOneWidget);
    });

    testWidgets('displays capacity indicator icon correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createMiniCardTestWidget());

      // Verify capacity indicator shows available status
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('handles no vehicles assigned correctly', (
      WidgetTester tester,
    ) async {
      const emptyTransport = TransportSlotSummary(
        time: TimeOfDayValue(9, 0),
        destination: 'Empty School',
        vehicleAssignmentSummaries: [],
        totalChildrenAssigned: 0,
        totalCapacity: 0,
        overallCapacityStatus: CapacityStatus.available,
      );

      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en', '')],
          home: Scaffold(body: TransportMiniCard(transport: emptyTransport)),
        ),
      );

      // Verify no vehicles message
      expect(find.byKey(const Key('no_vehicles_assigned')), findsOneWidget);
    });

    testWidgets('displays multiple vehicles correctly', (
      WidgetTester tester,
    ) async {
      const multiVehicleTransport = TransportSlotSummary(
        time: TimeOfDayValue(10, 0),
        destination: 'Multi School',
        vehicleAssignmentSummaries: [
          VehicleAssignmentSummary(
            vehicleId: 'vehicle1',
            vehicleName: 'Bus 1',
            vehicleCapacity: 20,
            assignedChildrenCount: 15,
            availableSeats: 5,
            capacityStatus: CapacityStatus.available,
          ),
          VehicleAssignmentSummary(
            vehicleId: 'vehicle2',
            vehicleName: 'Van 1',
            vehicleCapacity: 8,
            assignedChildrenCount: 6,
            availableSeats: 2,
            capacityStatus: CapacityStatus.available,
          ),
        ],
        totalChildrenAssigned: 21,
        totalCapacity: 28,
        overallCapacityStatus: CapacityStatus.available,
      );

      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en', '')],
          home: Scaffold(
            body: TransportMiniCard(transport: multiVehicleTransport),
          ),
        ),
      );

      // Verify multiple vehicles display
      expect(find.text('2 vehicles'), findsOneWidget);
    });

    testWidgets('displays capacity utilization progress bar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createMiniCardTestWidget());

      // Verify progress bar exists
      expect(find.byType(FractionallySizedBox), findsOneWidget);
    });

    testWidgets('displays capacity status for different statuses', (
      WidgetTester tester,
    ) async {
      // Test full capacity
      const fullTransport = TransportSlotSummary(
        time: TimeOfDayValue(11, 0),
        destination: 'Full School',
        vehicleAssignmentSummaries: [
          VehicleAssignmentSummary(
            vehicleId: 'vehicle1',
            vehicleName: 'Bus 1',
            vehicleCapacity: 20,
            assignedChildrenCount: 20,
            availableSeats: 0,
            capacityStatus: CapacityStatus.full,
          ),
        ],
        totalChildrenAssigned: 20,
        totalCapacity: 20,
        overallCapacityStatus: CapacityStatus.full,
      );

      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en', '')],
          home: Scaffold(body: TransportMiniCard(transport: fullTransport)),
        ),
      );

      // Verify error icon for full capacity
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('card is tappable', (WidgetTester tester) async {
      await tester.pumpWidget(createMiniCardTestWidget());

      // Find and tap the card
      final card = find.byType(TransportMiniCard);
      expect(card, findsOneWidget);

      await tester.tap(card);
      await tester.pump();

      // Verify tap was handled (card should still exist)
      expect(card, findsOneWidget);
    });

    testWidgets('displays children count for vehicles', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createMiniCardTestWidget());

      // Verify children count display
      expect(find.text('15 children'), findsOneWidget);
    });
  });
}
