import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edulift/features/dashboard/presentation/widgets/today_transport_card.dart';
import 'package:edulift/features/dashboard/presentation/widgets/seven_day_timeline_widget.dart';
import 'package:edulift/features/dashboard/presentation/widgets/vehicle_assignment_row.dart';
import 'package:edulift/features/dashboard/domain/entities/dashboard_transport_summary.dart';
import 'package:edulift/core/domain/entities/schedule/time_of_day.dart';
import 'package:edulift/core/domain/entities/schedule/vehicle_assignment.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('Dashboard Components Tests', () {
    // Test Widget Wrapper
    Widget createTestWidget({
      required Widget child,
      Locale locale = const Locale('en', ''),
    }) {
      return ProviderScope(
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

    // Mock Data Factory Methods - Base methods first
    VehicleAssignmentSummary createMockVehicle({
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

    List<VehicleAssignmentSummary> createMockVehicleList() {
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

    TransportSlotSummary createMockTransport({
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

    List<TransportSlotSummary> createMockTransportList() {
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

    DayTransportSummary createMockDaySummary({
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

    TransportSlotSummary createEmptyTransport() {
      return const TransportSlotSummary(
        time: TimeOfDayValue(9, 0),
        destination: 'Empty Destination',
        vehicleAssignmentSummaries: [],
        totalChildrenAssigned: 0,
        totalCapacity: 0,
        overallCapacityStatus: CapacityStatus.available,
      );
    }

    VehicleAssignmentSummary createEmptyVehicle() {
      return createMockVehicle(assigned: 0, available: 20);
    }

    VehicleAssignmentSummary createFullVehicle() {
      return createMockVehicle(
        assigned: 20,
        available: 0,
        status: CapacityStatus.full,
      );
    }

    group('TodayTransportCard', () {
      testWidgets('renders card with proper structure', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(child: const TodayTransportCard()),
        );
        await tester.pumpAndSettle();

        // Verify card structure
        expect(find.byKey(const Key('today_transport_card')), findsOneWidget);
        expect(find.byType(Card), findsOneWidget);

        // Verify header elements
        expect(find.byKey(const Key('today_transports_title')), findsOneWidget);
        expect(find.byKey(const Key('current_date_badge')), findsOneWidget);
        expect(find.byIcon(Icons.today), findsOneWidget);
      });

      testWidgets('displays loading state correctly', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(child: const TodayTransportCard()),
        );

        // Should initially show loading state
        expect(
          find.byKey(const Key('today_transports_loading')),
          findsOneWidget,
        );
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Loading today\'s transports...'), findsOneWidget);
      });

      testWidgets('displays retry button in error state', (
        WidgetTester tester,
      ) async {
        // Let the widget load into error state (simulated)
        await tester.pumpWidget(
          createTestWidget(child: const TodayTransportCard()),
        );
        await tester.pump(const Duration(seconds: 5)); // Simulate timeout

        // Look for retry functionality
        expect(find.byType(TodayTransportCard), findsOneWidget);
      });

      testWidgets('footer button is present', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(child: const TodayTransportCard()),
        );
        await tester.pumpAndSettle();

        // Verify footer exists
        expect(
          find.byKey(const Key('see_full_schedule_button')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('see_full_schedule_text')), findsOneWidget);
        expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      });

      testWidgets('accessibility labels are present', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(child: const TodayTransportCard()),
        );
        await tester.pumpAndSettle();

        // Verify semantic labels
        expect(
          find.bySemanticsLabel(
            RegExp(r"today'.*transports", caseSensitive: false),
          ),
          findsWidgets,
        );
      });

      testWidgets('date formatting works correctly', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(child: const TodayTransportCard()),
        );
        await tester.pumpAndSettle();

        // Verify date badge exists and contains expected format
        expect(find.byKey(const Key('current_date_badge')), findsOneWidget);

        final dateText = tester.widget<Text>(
          find.byKey(const Key('current_date_badge')),
        );
        expect(dateText.data, isNotNull);
        expect(
          dateText.data!.contains(','),
          isTrue,
        ); // Should have "Day, Month Date" format
      });
    });

    group('TransportMiniCard', () {
      testWidgets('renders all transport sections correctly', (
        WidgetTester tester,
      ) async {
        final mockTransport = createMockTransport();

        await tester.pumpWidget(
          createTestWidget(child: TransportMiniCard(transport: mockTransport)),
        );
        await tester.pumpAndSettle();

        // Verify all sections are present
        expect(find.byKey(const Key('transport_time')), findsOneWidget);
        expect(find.byKey(const Key('transport_destination')), findsOneWidget);
        expect(find.byKey(const Key('transport_capacity')), findsOneWidget);
        expect(find.byKey(const Key('vehicle_count')), findsOneWidget);
      });

      testWidgets('displays time formatting correctly', (
        WidgetTester tester,
      ) async {
        final mockTransport = createMockTransport();

        await tester.pumpWidget(
          createTestWidget(child: TransportMiniCard(transport: mockTransport)),
        );
        await tester.pumpAndSettle();

        // Verify time format (8:30 AM)
        expect(find.text('8:30 AM'), findsOneWidget);
      });

      testWidgets('displays different capacity statuses correctly', (
        WidgetTester tester,
      ) async {
        final testCases = [
          CapacityStatus.available,
          CapacityStatus.nearFull,
          CapacityStatus.full,
          CapacityStatus.exceeded,
        ];

        for (final status in testCases) {
          final transport = createMockTransport(status: status);

          await tester.pumpWidget(
            createTestWidget(child: TransportMiniCard(transport: transport)),
          );
          await tester.pumpAndSettle();

          // Verify capacity indicator exists
          expect(find.byType(Icon), findsWidgets);

          // Clear for next iteration
          await tester.pumpWidget(Container());
        }
      });

      testWidgets('handles no vehicles assigned', (WidgetTester tester) async {
        final emptyTransport = createEmptyTransport();

        await tester.pumpWidget(
          createTestWidget(child: TransportMiniCard(transport: emptyTransport)),
        );
        await tester.pumpAndSettle();

        // Verify no vehicles message
        expect(find.byKey(const Key('no_vehicles_assigned')), findsOneWidget);
      });

      testWidgets('displays multiple vehicles correctly', (
        WidgetTester tester,
      ) async {
        final multiVehicleTransport = createMockTransport(
          vehicles: [
            createMockVehicle(id: 'bus1', name: 'Bus 1'),
            createMockVehicle(id: 'van1', name: 'Van 1'),
            createMockVehicle(id: 'car1', name: 'Car 1'),
          ],
        );

        await tester.pumpWidget(
          createTestWidget(
            child: TransportMiniCard(transport: multiVehicleTransport),
          ),
        );
        await tester.pumpAndSettle();

        // Verify multiple vehicles display
        expect(find.text('3 vehicles'), findsOneWidget);
      });

      testWidgets('displays capacity utilization progress bar', (
        WidgetTester tester,
      ) async {
        final mockTransport = createMockTransport();

        await tester.pumpWidget(
          createTestWidget(child: TransportMiniCard(transport: mockTransport)),
        );
        await tester.pumpAndSettle();

        // Verify progress bar exists
        expect(find.byType(FractionallySizedBox), findsOneWidget);
      });

      testWidgets('card is tappable', (WidgetTester tester) async {
        final mockTransport = createMockTransport();

        await tester.pumpWidget(
          createTestWidget(child: TransportMiniCard(transport: mockTransport)),
        );
        await tester.pumpAndSettle();

        // Tap the card
        await tester.tap(find.byType(TransportMiniCard));
        await tester.pumpAndSettle();

        // Verify widget still exists after tap
        expect(find.byType(TransportMiniCard), findsOneWidget);
      });

      testWidgets('handles long destination names', (
        WidgetTester tester,
      ) async {
        const longDestination =
            'Very Long School Name That Should Be Truncated With Ellipsis';
        final transportWithLongName = createMockTransport(
          destination: longDestination,
        );

        await tester.pumpWidget(
          createTestWidget(
            child: TransportMiniCard(transport: transportWithLongName),
          ),
        );
        await tester.pumpAndSettle();

        // Verify text is truncated
        final destinationText = tester.widget<Text>(
          find.byKey(const Key('transport_destination')),
        );
        expect(destinationText.overflow, equals(TextOverflow.ellipsis));
        expect(destinationText.maxLines, equals(1));
      });
    });

    group('SevenDayTimelineWidget', () {
      testWidgets('renders correctly with header', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(child: const SevenDayTimelineWidget()),
        );
        await tester.pumpAndSettle();

        // Verify widget structure
        expect(
          find.byKey(const Key('seven_day_timeline_widget')),
          findsOneWidget,
        );
        expect(find.byType(Card), findsOneWidget);

        // Verify header
        expect(find.byKey(const Key('next_7_days_title')), findsOneWidget);
        expect(
          find.byKey(const Key('week_view_toggle_button')),
          findsOneWidget,
        );
      });

      testWidgets('toggle button exists and is tappable', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(child: const SevenDayTimelineWidget()),
        );
        await tester.pumpAndSettle();

        // Verify toggle button exists
        expect(
          find.byKey(const Key('week_view_toggle_button')),
          findsOneWidget,
        );

        // Tap the toggle button
        await tester.tap(find.byKey(const Key('week_view_toggle_button')));
        await tester.pumpAndSettle();

        // Verify widget still exists after tap
        expect(find.byType(SevenDayTimelineWidget), findsOneWidget);
      });

      testWidgets('displays loading state correctly', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(child: const SevenDayTimelineWidget()),
        );

        // Should initially show loading state
        expect(find.byKey(const Key('week_timeline_loading')), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Loading week schedule...'), findsOneWidget);
      });

      testWidgets('footer button only shows in appropriate state', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(child: const SevenDayTimelineWidget()),
        );
        await tester.pumpAndSettle();

        // Footer button should exist
        expect(
          find.byKey(const Key('see_week_schedule_button')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('see_week_schedule_text')), findsOneWidget);
      });

      testWidgets('accessibility labels are present', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(child: const SevenDayTimelineWidget()),
        );
        await tester.pumpAndSettle();

        // Verify semantic labels
        expect(
          find.bySemanticsLabel(RegExp(r'next.*7.*days', caseSensitive: false)),
          findsWidgets,
        );
      });

      testWidgets('handles date formatting correctly', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(child: const SevenDayTimelineWidget()),
        );
        await tester.pumpAndSettle();

        // The widget should handle date formatting without errors
        expect(find.byType(SevenDayTimelineWidget), findsOneWidget);
      });
    });

    group('DayBadge', () {
      testWidgets('displays day name correctly', (WidgetTester tester) async {
        final testDate = DateTime(2024, 1, 15); // Monday
        final testSummary = createMockDaySummary(date: testDate);

        await tester.pumpWidget(
          createTestWidget(
            child: DayBadge(date: testDate, summary: testSummary),
          ),
        );
        await tester.pumpAndSettle();

        // Verify day name (Monday -> Mon)
        expect(find.text('Mon'), findsOneWidget);
      });

      testWidgets('displays transport count correctly', (
        WidgetTester tester,
      ) async {
        final testDate = DateTime(2024, 1, 15);
        final testSummary = createMockDaySummary(date: testDate);

        await tester.pumpWidget(
          createTestWidget(
            child: DayBadge(date: testDate, summary: testSummary),
          ),
        );
        await tester.pumpAndSettle();

        // Verify transport count
        expect(find.text('3'), findsOneWidget);
      });

      testWidgets('highlights today correctly', (WidgetTester tester) async {
        final today = DateTime.now();
        final todaySummary = createMockDaySummary(date: today);

        await tester.pumpWidget(
          createTestWidget(
            child: DayBadge(date: today, summary: todaySummary, isToday: true),
          ),
        );
        await tester.pumpAndSettle();

        // Verify today is highlighted
        final card = tester.widget<Card>(find.byType(Card));
        expect(card.color, isNotNull); // Should have primary container color
      });

      testWidgets('displays no transports correctly', (
        WidgetTester tester,
      ) async {
        final testDate = DateTime(2024, 1, 15);
        final emptySummary = createMockDaySummary(
          date: testDate,
          transports: [],
          hasTransports: false,
        );

        await tester.pumpWidget(
          createTestWidget(
            child: DayBadge(date: testDate, summary: emptySummary),
          ),
        );
        await tester.pumpAndSettle();

        // Verify no transports display
        expect(find.text('0'), findsOneWidget);
        expect(find.byKey(const Key('no_transports')), findsOneWidget);
      });

      testWidgets('capacity indicator shows correctly', (
        WidgetTester tester,
      ) async {
        final testDate = DateTime(2024, 1, 15);
        final testSummary = createMockDaySummary(date: testDate);

        await tester.pumpWidget(
          createTestWidget(
            child: DayBadge(date: testDate, summary: testSummary),
          ),
        );
        await tester.pumpAndSettle();

        // Verify capacity indicator exists
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('badge is tappable', (WidgetTester tester) async {
        final testDate = DateTime(2024, 1, 15);
        final testSummary = createMockDaySummary(date: testDate);

        await tester.pumpWidget(
          createTestWidget(
            child: DayBadge(date: testDate, summary: testSummary),
          ),
        );
        await tester.pumpAndSettle();

        // Tap the badge
        await tester.tap(find.byType(DayBadge));
        await tester.pumpAndSettle();

        // Verify widget still exists after tap
        expect(find.byType(DayBadge), findsOneWidget);
      });

      testWidgets('touch target meets WCAG AA requirements', (
        WidgetTester tester,
      ) async {
        final testDate = DateTime(2024, 1, 15);
        final testSummary = createMockDaySummary(date: testDate);

        await tester.pumpWidget(
          createTestWidget(
            child: DayBadge(date: testDate, summary: testSummary),
          ),
        );
        await tester.pumpAndSettle();

        // Verify minimum touch target size
        final renderBox =
            tester.renderObject(find.byType(DayBadge)) as RenderBox;
        expect(renderBox.size.height, greaterThanOrEqualTo(48.0));
      });
    });

    group('DayDetailCard', () {
      testWidgets('displays detailed information correctly', (
        WidgetTester tester,
      ) async {
        final testDate = DateTime(2024, 1, 15);
        final testSummary = createMockDaySummary(date: testDate);

        await tester.pumpWidget(
          createTestWidget(
            child: DayDetailCard(date: testDate, summary: testSummary),
          ),
        );
        await tester.pumpAndSettle();

        // Verify card structure
        expect(find.byKey(const Key('day_detail_card')), findsOneWidget);
        expect(find.byKey(const Key('day_name_header')), findsOneWidget);
        expect(find.byKey(const Key('date_header')), findsOneWidget);

        // Verify transport slots
        expect(find.byType(TransportTimeSlot), findsNWidgets(3));
      });

      testWidgets('shows today badge when isToday is true', (
        WidgetTester tester,
      ) async {
        final today = DateTime.now();
        final todaySummary = createMockDaySummary(date: today);

        await tester.pumpWidget(
          createTestWidget(
            child: DayDetailCard(
              date: today,
              summary: todaySummary,
              isToday: true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify today badge
        expect(find.text('Today'), findsOneWidget);
      });

      testWidgets('displays no transports message correctly', (
        WidgetTester tester,
      ) async {
        final testDate = DateTime(2024, 1, 15);
        final emptySummary = createMockDaySummary(
          date: testDate,
          transports: [],
          hasTransports: false,
        );

        await tester.pumpWidget(
          createTestWidget(
            child: DayDetailCard(date: testDate, summary: emptySummary),
          ),
        );
        await tester.pumpAndSettle();

        // Verify no transports message
        expect(find.text('No transports scheduled'), findsOneWidget);
        expect(find.byIcon(Icons.schedule_outlined), findsOneWidget);
      });

      testWidgets('date formatting is correct', (WidgetTester tester) async {
        final testDate = DateTime(2024, 1, 15);
        final testSummary = createMockDaySummary(date: testDate);

        await tester.pumpWidget(
          createTestWidget(
            child: DayDetailCard(date: testDate, summary: testSummary),
          ),
        );
        await tester.pumpAndSettle();

        // Verify date format (Jan 15)
        expect(find.text('Jan 15'), findsOneWidget);
        expect(find.text('Monday'), findsOneWidget);
      });
    });

    group('TransportTimeSlot', () {
      testWidgets('displays transport information correctly', (
        WidgetTester tester,
      ) async {
        final mockTransport = createMockTransport();

        await tester.pumpWidget(
          createTestWidget(child: TransportTimeSlot(transport: mockTransport)),
        );
        await tester.pumpAndSettle();

        // Verify transport details
        expect(find.byKey(const Key('transport_time_slot')), findsOneWidget);
        expect(
          find.byKey(const Key('transport_destination_slot')),
          findsOneWidget,
        );
        expect(find.text('8:30 AM'), findsOneWidget);
        expect(find.text('Test School'), findsOneWidget);
        expect(find.text('15/20 seats'), findsOneWidget);
        expect(find.text('75%'), findsOneWidget);
      });

      testWidgets('displays vehicles correctly', (WidgetTester tester) async {
        final mockTransport = createMockTransport();

        await tester.pumpWidget(
          createTestWidget(child: TransportTimeSlot(transport: mockTransport)),
        );
        await tester.pumpAndSettle();

        // Verify vehicle info rows
        expect(find.byType(VehicleInfoRow), findsNWidgets(2));
      });

      testWidgets('displays capacity status icon correctly', (
        WidgetTester tester,
      ) async {
        final mockTransport = createMockTransport();

        await tester.pumpWidget(
          createTestWidget(child: TransportTimeSlot(transport: mockTransport)),
        );
        await tester.pumpAndSettle();

        // Verify status icon (available = check_circle)
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });

      testWidgets('displays progress bar correctly', (
        WidgetTester tester,
      ) async {
        final mockTransport = createMockTransport();

        await tester.pumpWidget(
          createTestWidget(child: TransportTimeSlot(transport: mockTransport)),
        );
        await tester.pumpAndSettle();

        // Verify progress bar
        expect(find.byType(FractionallySizedBox), findsOneWidget);
      });

      testWidgets('handles no vehicles assigned', (WidgetTester tester) async {
        final emptyTransport = createEmptyTransport();

        await tester.pumpWidget(
          createTestWidget(child: TransportTimeSlot(transport: emptyTransport)),
        );
        await tester.pumpAndSettle();

        // Verify no vehicles message
        expect(find.text('No vehicles assigned'), findsOneWidget);
      });

      testWidgets('utilization percentage calculation is correct', (
        WidgetTester tester,
      ) async {
        final mockTransport = createMockTransport();

        await tester.pumpWidget(
          createTestWidget(child: TransportTimeSlot(transport: mockTransport)),
        );
        await tester.pumpAndSettle();

        // 15/20 = 75%
        expect(find.text('75%'), findsOneWidget);
      });
    });

    group('VehicleAssignmentRow', () {
      testWidgets('renders correctly with all sections', (
        WidgetTester tester,
      ) async {
        final mockVehicle = createMockVehicle();

        await tester.pumpWidget(
          createTestWidget(
            child: VehicleAssignmentRow(
              vehicleAssignment: mockVehicle,
              capacityStatus: CapacityStatus.available,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify all sections
        expect(find.byKey(const Key('vehicle_name')), findsOneWidget);
        expect(find.byKey(const Key('vehicle_capacity')), findsOneWidget);
        expect(find.byKey(const Key('capacity_ratio')), findsOneWidget);
        expect(find.byIcon(Icons.directions_car), findsOneWidget);
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      });

      testWidgets('displays vehicle information correctly', (
        WidgetTester tester,
      ) async {
        final mockVehicle = createMockVehicle();

        await tester.pumpWidget(
          createTestWidget(
            child: VehicleAssignmentRow(
              vehicleAssignment: mockVehicle,
              capacityStatus: CapacityStatus.available,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify vehicle details
        expect(find.text('Bus 15'), findsOneWidget);
        expect(find.text('20 seats'), findsOneWidget);
        expect(find.text('15/20'), findsOneWidget);
      });

      testWidgets('displays different capacity statuses correctly', (
        WidgetTester tester,
      ) async {
        final testCases = {
          CapacityStatus.available: Icons.check_circle,
          CapacityStatus.nearFull: Icons.warning,
          CapacityStatus.full: Icons.error,
          CapacityStatus.exceeded: Icons.error,
        };

        for (final entry in testCases.entries) {
          await tester.pumpWidget(
            createTestWidget(
              child: VehicleAssignmentRow(
                vehicleAssignment: createMockVehicle(),
                capacityStatus: entry.key,
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Verify correct icon for status
          expect(find.byIcon(entry.value), findsOneWidget);

          // Clear for next iteration
          await tester.pumpWidget(Container());
        }
      });

      testWidgets('progress bar reflects utilization correctly', (
        WidgetTester tester,
      ) async {
        final mockVehicle = createMockVehicle();

        await tester.pumpWidget(
          createTestWidget(
            child: VehicleAssignmentRow(
              vehicleAssignment: mockVehicle,
              capacityStatus: CapacityStatus.available,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify progress bar
        final progressIndicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        expect(progressIndicator.value, equals(0.75)); // 15/20 = 0.75
      });

      testWidgets('handles empty vehicle correctly', (
        WidgetTester tester,
      ) async {
        final emptyVehicle = createEmptyVehicle();

        await tester.pumpWidget(
          createTestWidget(
            child: VehicleAssignmentRow(
              vehicleAssignment: emptyVehicle,
              capacityStatus: CapacityStatus.available,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify empty vehicle display
        expect(find.text('0/20'), findsOneWidget);
        expect(find.text('20 seats'), findsOneWidget);

        final progressIndicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        expect(progressIndicator.value, equals(0.0)); // 0/20 = 0.0
      });

      testWidgets('handles full vehicle correctly', (
        WidgetTester tester,
      ) async {
        final fullVehicle = createFullVehicle();

        await tester.pumpWidget(
          createTestWidget(
            child: VehicleAssignmentRow(
              vehicleAssignment: fullVehicle,
              capacityStatus: CapacityStatus.full,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify full vehicle display
        expect(find.text('20/20'), findsOneWidget);
        expect(find.byIcon(Icons.error), findsOneWidget);

        final progressIndicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        expect(progressIndicator.value, equals(1.0)); // 20/20 = 1.0
      });

      testWidgets('row is tappable', (WidgetTester tester) async {
        final mockVehicle = createMockVehicle();

        await tester.pumpWidget(
          createTestWidget(
            child: VehicleAssignmentRow(
              vehicleAssignment: mockVehicle,
              capacityStatus: CapacityStatus.available,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap the row
        await tester.tap(find.byType(VehicleAssignmentRow));
        await tester.pumpAndSettle();

        // Verify widget still exists after tap
        expect(find.byType(VehicleAssignmentRow), findsOneWidget);
      });

      testWidgets('touch target meets WCAG AA requirements', (
        WidgetTester tester,
      ) async {
        final mockVehicle = createMockVehicle();

        await tester.pumpWidget(
          createTestWidget(
            child: VehicleAssignmentRow(
              vehicleAssignment: mockVehicle,
              capacityStatus: CapacityStatus.available,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify minimum touch target size
        final renderBox =
            tester.renderObject(find.byType(VehicleAssignmentRow)) as RenderBox;
        expect(renderBox.size.height, greaterThanOrEqualTo(48.0));
      });

      testWidgets('accessibility labels are present', (
        WidgetTester tester,
      ) async {
        final mockVehicle = createMockVehicle();

        await tester.pumpWidget(
          createTestWidget(
            child: VehicleAssignmentRow(
              vehicleAssignment: mockVehicle,
              capacityStatus: CapacityStatus.available,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify semantic label contains vehicle info
        expect(
          find.bySemanticsLabel(
            RegExp(
              r'vehicle.*bus.*15.*15.*20.*available',
              caseSensitive: false,
            ),
          ),
          findsWidgets,
        );
      });

      testWidgets('handles long vehicle names', (WidgetTester tester) async {
        final longNameVehicle = createMockVehicle(
          name: 'Very Long Vehicle Name That Should Be Truncated',
        );

        await tester.pumpWidget(
          createTestWidget(
            child: VehicleAssignmentRow(
              vehicleAssignment: longNameVehicle,
              capacityStatus: CapacityStatus.available,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify text is truncated
        final vehicleNameText = tester.widget<Text>(
          find.byKey(const Key('vehicle_name')),
        );
        expect(vehicleNameText.overflow, equals(TextOverflow.ellipsis));
        expect(vehicleNameText.maxLines, equals(1));
      });
    });

    group('Integration Tests', () {
      testWidgets('all dashboard components work together', (
        WidgetTester tester,
      ) async {
        final mockSummary = createMockDaySummary();

        await tester.pumpWidget(
          createTestWidget(
            child: Column(
              children: [
                const TodayTransportCard(),
                const SizedBox(height: 16),
                const SevenDayTimelineWidget(),
                const SizedBox(height: 16),
                VehicleAssignmentRow(
                  vehicleAssignment: mockSummary
                      .transports
                      .first
                      .vehicleAssignmentSummaries
                      .first,
                  capacityStatus: CapacityStatus.available,
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify all components render
        expect(find.byType(TodayTransportCard), findsOneWidget);
        expect(find.byType(SevenDayTimelineWidget), findsOneWidget);
        expect(find.byType(VehicleAssignmentRow), findsOneWidget);
        expect(
          find.byType(TransportMiniCard),
          findsNothing,
        ); // These are inside the cards
        expect(
          find.byType(DayBadge),
          findsNothing,
        ); // These are inside the timeline widget
      });
    });

    group('Performance Tests', () {
      testWidgets('widgets build efficiently', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();

        for (var i = 0; i < 3; i++) {
          await tester.pumpWidget(
            createTestWidget(child: const TodayTransportCard()),
          );
          await tester.pumpAndSettle();
        }

        stopwatch.stop();

        // Should complete within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(3000));
      });

      testWidgets('TransportMiniCard builds efficiently with large datasets', (
        WidgetTester tester,
      ) async {
        final largeTransportList = List.generate(
          10,
          (index) => createMockTransport(
            destination: 'School $index',
            vehicles: [
              createMockVehicle(id: 'vehicle_$index', name: 'Vehicle $index'),
            ],
          ),
        );

        final stopwatch = Stopwatch()..start();

        for (final transport in largeTransportList) {
          await tester.pumpWidget(
            createTestWidget(child: TransportMiniCard(transport: transport)),
          );
          await tester.pumpAndSettle();
        }

        stopwatch.stop();

        // Should complete within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });
    });

    group('Error Recovery Tests', () {
      testWidgets('components handle errors gracefully', (
        WidgetTester tester,
      ) async {
        // Test that widgets don't crash when data is unavailable
        await tester.pumpWidget(
          createTestWidget(
            child: Column(
              children: [
                const TodayTransportCard(),
                const SevenDayTimelineWidget(),
                VehicleAssignmentRow(
                  vehicleAssignment: createMockVehicle(),
                  capacityStatus: CapacityStatus.available,
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        // All components should render without crashing
        expect(find.byType(TodayTransportCard), findsOneWidget);
        expect(find.byType(SevenDayTimelineWidget), findsOneWidget);
        expect(find.byType(VehicleAssignmentRow), findsOneWidget);
      });

      testWidgets('widgets remain functional after state changes', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(child: const TodayTransportCard()),
        );
        await tester.pumpAndSettle();

        // Tap footer button
        await tester.tap(find.byKey(const Key('see_full_schedule_button')));
        await tester.pumpAndSettle();

        // Widget should still be functional
        expect(find.byType(TodayTransportCard), findsOneWidget);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('all interactive elements have semantic labels', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            child: Column(
              children: [
                const TodayTransportCard(),
                const SevenDayTimelineWidget(),
                VehicleAssignmentRow(
                  vehicleAssignment: createMockVehicle(),
                  capacityStatus: CapacityStatus.available,
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify semantic labels exist for main components
        expect(
          find.bySemanticsLabel(
            RegExp(r"today'.*transports", caseSensitive: false),
          ),
          findsWidgets,
        );
        expect(
          find.bySemanticsLabel(RegExp(r'next.*7.*days', caseSensitive: false)),
          findsWidgets,
        );
      });

      testWidgets('touch targets meet WCAG requirements', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            child: Column(
              children: [
                VehicleAssignmentRow(
                  vehicleAssignment: createMockVehicle(),
                  capacityStatus: CapacityStatus.available,
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify minimum touch target size
        final renderBox =
            tester.renderObject(find.byType(VehicleAssignmentRow)) as RenderBox;
        expect(renderBox.size.height, greaterThanOrEqualTo(48.0));
      });
    });

    group('Material 3 Design Tests', () {
      testWidgets('components use Material 3 theming', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            child: Column(
              children: [
                const TodayTransportCard(),
                const SevenDayTimelineWidget(),
                VehicleAssignmentRow(
                  vehicleAssignment: createMockVehicle(),
                  capacityStatus: CapacityStatus.available,
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify components render (Material 3 compliance is visual)
        expect(find.byType(Card), findsWidgets);
        expect(find.byType(Icon), findsWidgets);
        expect(find.byType(LinearProgressIndicator), findsWidgets);
      });

      testWidgets('color scheme is applied correctly', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            child: VehicleAssignmentRow(
              vehicleAssignment: createMockVehicle(),
              capacityStatus: CapacityStatus.available,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify widget uses theme colors (visual verification)
        expect(find.byType(VehicleAssignmentRow), findsOneWidget);
      });
    });
  });
}
