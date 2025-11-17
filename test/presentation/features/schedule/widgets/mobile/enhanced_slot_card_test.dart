import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:edulift/features/schedule/presentation/widgets/mobile/enhanced_slot_card.dart';
import 'package:edulift/core/domain/entities/family/vehicle.dart';
import 'package:edulift/core/domain/entities/family/child.dart';
import 'package:edulift/core/domain/entities/schedule/day_of_week.dart';
import 'package:edulift/core/domain/entities/schedule/time_of_day.dart';
import 'package:edulift/core/services/providers/auth_provider.dart';
import 'package:edulift/core/domain/entities/user.dart';
import 'package:edulift/features/schedule/presentation/models/displayable_time_slot.dart';
import 'package:edulift/core/presentation/widgets/vehicle_card.dart';
import '../../../../../../test/support/test_app_configuration.dart';
import '../../../../../../test/helpers/schedule_test_helpers.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'enhanced_slot_card_test.mocks.dart';

@GenerateMocks([User])
void main() {
  group('EnhancedSlotCard Tests', () {
    late Map<String, Child> testChildren;
    late Map<String, Vehicle?> testVehicles;
    late MockUser mockUser;

    setUpAll(() async {
      // Initialize timezone database for tests
      tz.initializeTimeZones();
      await TestAppConfiguration.initialize();
    });

    setUp(() {
      testChildren = ScheduleTestHelpers.createChildMap(
        children: ScheduleTestHelpers.createTestChildren(),
      );

      testVehicles = ScheduleTestHelpers.createVehicleMap(
        vehicles: ScheduleTestHelpers.createTestVehicles(count: 4),
      );

      mockUser = MockUser();
      when(mockUser.id).thenReturn('test-user-id');
      when(mockUser.timezone).thenReturn('America/New_York');
    });

    Widget createTestWidget({required Widget child, String locale = 'fr'}) {
      return ProviderScope(
        overrides: [currentUserProvider.overrideWithValue(mockUser)],
        child: TestAppConfiguration.createTestWidget(
          child: child,
          locale: locale,
        ),
      );
    }

    group('Displayable Slot States', () {
      testWidgets('displays uncreated slot correctly', (
        WidgetTester tester,
      ) async {
        final displayableSlot = ScheduleTestHelpers.createDisplayableSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: const TimeOfDayValue(8, 0),
          existsInBackend: false,
        );

        await tester.pumpWidget(
          createTestWidget(
            child: EnhancedSlotCard(
              key: const Key('test_uncreated_slot'),
              displayableSlot: displayableSlot,
              childrenMap: testChildren,
            ),
          ),
        );

        expect(
          find.byKey(const Key('enhanced_slot_card_uncreated_monday_08:00')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('add_vehicle_uncreated_slot')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('add_vehicle_text')), findsOneWidget);
        expect(
          find.text('Ajouter un véhicule'),
          findsOneWidget,
        ); // Localized text
      });

      testWidgets('displays empty existing slot correctly', (
        WidgetTester tester,
      ) async {
        final displayableSlot = ScheduleTestHelpers.createDisplayableSlot(
          dayOfWeek: DayOfWeek.tuesday,
          timeOfDay: const TimeOfDayValue(10, 0),
        );

        await tester.pumpWidget(
          createTestWidget(
            child: EnhancedSlotCard(
              key: const Key('test_empty_slot'),
              displayableSlot: displayableSlot,
              childrenMap: testChildren,
              isSlotInPast: (slot) =>
                  false, // Disable timezone-dependent past detection
            ),
          ),
        );

        final slotId = displayableSlot.scheduleSlot!.id;
        expect(find.byKey(Key('enhanced_slot_card_$slotId')), findsOneWidget);
        expect(
          find.byKey(const Key('add_vehicle_empty_state')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('add_vehicle_text')), findsOneWidget);
      });

      testWidgets('displays slot with vehicles correctly', (
        WidgetTester tester,
      ) async {
        final displayableSlot = ScheduleTestHelpers.createDisplayableSlot(
          dayOfWeek: DayOfWeek.wednesday,
          timeOfDay: const TimeOfDayValue(14, 0),
          vehicles: 2,
          childrenPerVehicle: 2,
        );

        await tester.pumpWidget(
          createTestWidget(
            child: EnhancedSlotCard(
              isSlotInPast: (slot) =>
                  false, // Disable timezone-dependent past detection

              key: const Key('test_slot_with_vehicles'),
              displayableSlot: displayableSlot,
              vehicles: testVehicles,
              childrenMap: testChildren,
            ),
          ),
        );

        final slotId2 = displayableSlot.scheduleSlot!.id;
        expect(find.byKey(Key('enhanced_slot_card_$slotId2')), findsOneWidget);
        // Note: VehicleCard is not directly testable as it's part of EnhancedSlotCard internal structure
      });

      testWidgets('displays slot at full capacity correctly', (
        WidgetTester tester,
      ) async {
        final displayableSlot = ScheduleTestHelpers.createDisplayableSlot(
          dayOfWeek: DayOfWeek.thursday,
          timeOfDay: const TimeOfDayValue(16, 0),
          vehicles: 3,
          childrenPerVehicle: 5,
        );

        await tester.pumpWidget(
          createTestWidget(
            child: EnhancedSlotCard(
              isSlotInPast: (slot) =>
                  false, // Disable timezone-dependent past detection

              key: const Key('test_full_capacity_slot'),
              displayableSlot: displayableSlot,
              vehicles: testVehicles,
              childrenMap: testChildren,
            ),
          ),
        );

        expect(find.byKey(const Key('max_capacity_badge')), findsOneWidget);
        expect(find.text('Maximum vehicles reached'), findsOneWidget);
      });

      testWidgets('displays slot with limited capacity correctly', (
        WidgetTester tester,
      ) async {
        final displayableSlot = ScheduleTestHelpers.createDisplayableSlot(
          dayOfWeek: DayOfWeek.friday,
          timeOfDay: const TimeOfDayValue(9, 0),
          vehicles: 2,
          childrenPerVehicle: 4,
        );

        await tester.pumpWidget(
          createTestWidget(
            child: EnhancedSlotCard(
              isSlotInPast: (slot) =>
                  false, // Disable timezone-dependent past detection

              key: const Key('test_limited_capacity_slot'),
              displayableSlot: displayableSlot,
              vehicles: testVehicles,
              childrenMap: testChildren,
            ),
          ),
        );

        expect(
          find.byKey(const Key('add_another_vehicle_button')),
          findsOneWidget,
        );
        // French locale (default): "Ajouter un véhicule"
        expect(find.text('Ajouter un véhicule'), findsOneWidget);
      });

      testWidgets('displays past slot correctly', (WidgetTester tester) async {
        final displayableSlot = ScheduleTestHelpers.createDisplayableSlot(
          dayOfWeek: DayOfWeek.saturday,
          timeOfDay: const TimeOfDayValue(8, 0),
          vehicles: 1,
          childrenPerVehicle: 2,
          isPast: true,
        );

        await tester.pumpWidget(
          createTestWidget(
            child: EnhancedSlotCard(
              key: const Key('test_past_slot'),
              displayableSlot: displayableSlot,
              vehicles: testVehicles,
              childrenMap: testChildren,
              isSlotInPast: (slot) => true, // Force past slot
            ),
          ),
        );

        // Past slots show lock icon and have reduced opacity
        expect(find.byIcon(Icons.lock_outline), findsWidgets);
        // Verify the card is rendered with past state (reduced elevation)
        final card = tester.widget<Card>(find.byType(Card));
        expect(card.elevation, equals(1)); // Past slots have elevation 1
      });

      testWidgets('handles overcapacity slot correctly', (
        WidgetTester tester,
      ) async {
        final displayableSlot = ScheduleTestHelpers.createDisplayableSlot(
          dayOfWeek: DayOfWeek.sunday,
          timeOfDay: const TimeOfDayValue(15, 0),
          vehicles: 2,
          childrenPerVehicle: 5, // At capacity (max allowed)
          maxVehicles: 2,
        );

        await tester.pumpWidget(
          createTestWidget(
            child: EnhancedSlotCard(
              isSlotInPast: (slot) =>
                  false, // Disable timezone-dependent past detection

              key: const Key('test_overcapacity_slot'),
              displayableSlot: displayableSlot,
              vehicles: testVehicles,
              childrenMap: testChildren,
            ),
          ),
        );

        expect(find.byKey(const Key('max_capacity_badge')), findsOneWidget);
      });
    });

    group('User Interactions', () {
      testWidgets(
        'calls onAddVehicle when tapping add vehicle button on uncreated slot',
        (WidgetTester tester) async {
          DisplayableTimeSlot? tappedSlot;
          final displayableSlot = ScheduleTestHelpers.createDisplayableSlot(
            dayOfWeek: DayOfWeek.monday,
            timeOfDay: const TimeOfDayValue(8, 0),
            existsInBackend: false,
          );

          await tester.pumpWidget(
            createTestWidget(
              child: EnhancedSlotCard(
                isSlotInPast: (slot) =>
                    false, // Disable timezone-dependent past detection

                key: const Key('test_add_vehicle_uncreated'),
                displayableSlot: displayableSlot,
                onAddVehicle: (slot) {
                  tappedSlot = slot;
                },
                childrenMap: testChildren,
              ),
            ),
          );

          await tester.tap(find.byKey(const Key('add_vehicle_uncreated_slot')));
          await tester.pumpAndSettle();

          expect(tappedSlot, isNotNull);
          expect(tappedSlot, equals(displayableSlot));
        },
      );

      testWidgets(
        'calls onAddVehicle when tapping add vehicle button on empty slot',
        (WidgetTester tester) async {
          DisplayableTimeSlot? tappedSlot;
          final displayableSlot = ScheduleTestHelpers.createDisplayableSlot(
            dayOfWeek: DayOfWeek.tuesday,
            timeOfDay: const TimeOfDayValue(10, 0),
          );

          await tester.pumpWidget(
            createTestWidget(
              child: EnhancedSlotCard(
                isSlotInPast: (slot) =>
                    false, // Disable timezone-dependent past detection

                key: const Key('test_add_vehicle_empty'),
                displayableSlot: displayableSlot,
                onAddVehicle: (slot) {
                  tappedSlot = slot;
                },
                childrenMap: testChildren,
              ),
            ),
          );

          await tester.tap(find.byKey(const Key('add_vehicle_empty_state')));
          await tester.pumpAndSettle();

          expect(tappedSlot, isNotNull);
          expect(tappedSlot, equals(displayableSlot));
        },
      );

      testWidgets('calls onVehicleAction when removing vehicle', (
        WidgetTester tester,
      ) async {
        final receivedActions = <Map<String, dynamic>>[];
        final displayableSlot = ScheduleTestHelpers.createDisplayableSlot(
          dayOfWeek: DayOfWeek.wednesday,
          timeOfDay: const TimeOfDayValue(14, 0),
          vehicles: 1,
          childrenPerVehicle: 2,
        );

        await tester.pumpWidget(
          createTestWidget(
            child: EnhancedSlotCard(
              isSlotInPast: (slot) =>
                  false, // Disable timezone-dependent past detection

              key: const Key('test_vehicle_action'),
              displayableSlot: displayableSlot,
              vehicles: testVehicles,
              onVehicleAction: (vehicle, action) {
                receivedActions.add({
                  'vehicleId': vehicle.vehicleId,
                  'action': action,
                });
              },
              childrenMap: testChildren,
            ),
          ),
        );

        // Get the first vehicle assignment from the slot
        final firstVehicleAssignment =
            displayableSlot.scheduleSlot!.vehicleAssignments.first;
        final removeButton = find.byKey(
          Key('vehicle_remove_${firstVehicleAssignment.vehicleId}'),
        );
        expect(removeButton, findsOneWidget);

        // Tap remove button
        await tester.tap(removeButton);
        await tester.pumpAndSettle();

        // Verify remove action was called
        expect(receivedActions.length, equals(1));
        expect(receivedActions.first['action'], equals('remove'));
        expect(
          receivedActions.first['vehicleId'],
          equals(firstVehicleAssignment.vehicleId),
        );
      });

      testWidgets('disables interactions on past slot vehicle', (
        WidgetTester tester,
      ) async {
        final displayableSlot = ScheduleTestHelpers.createDisplayableSlot(
          dayOfWeek: DayOfWeek.thursday,
          timeOfDay: const TimeOfDayValue(16, 0),
          vehicles: 1,
          childrenPerVehicle: 2,
          isPast: true,
        );

        await tester.pumpWidget(
          createTestWidget(
            child: EnhancedSlotCard(
              key: const Key('test_past_slot_disabled'),
              displayableSlot: displayableSlot,
              vehicles: testVehicles,
              childrenMap: testChildren,
              isSlotInPast: (slot) => true,
            ),
          ),
        );

        // Get the vehicle assignment from the past slot
        final firstVehicleAssignment =
            displayableSlot.scheduleSlot!.vehicleAssignments.first;

        // Remove button should not be present on past slots
        final removeButton = find.byKey(
          Key('vehicle_remove_${firstVehicleAssignment.vehicleId}'),
        );
        expect(removeButton, findsNothing);

        // Verify VehicleCard is rendered with disabled state
        expect(find.byType(VehicleCard), findsOneWidget);
      });
    });

    group('Status Badges', () {
      testWidgets('displays empty status badge correctly', (
        WidgetTester tester,
      ) async {
        final displayableSlot = ScheduleTestHelpers.createDisplayableSlot(
          dayOfWeek: DayOfWeek.friday,
          timeOfDay: const TimeOfDayValue(9, 0),
        );

        await tester.pumpWidget(
          createTestWidget(
            child: EnhancedSlotCard(
              isSlotInPast: (slot) =>
                  false, // Disable timezone-dependent past detection

              key: const Key('test_empty_status'),
              displayableSlot: displayableSlot,
              childrenMap: testChildren,
            ),
          ),
        );

        expect(find.byIcon(Icons.circle_outlined), findsOneWidget);
      });

      testWidgets('displays available status badge correctly', (
        WidgetTester tester,
      ) async {
        final displayableSlot = ScheduleTestHelpers.createDisplayableSlot(
          dayOfWeek: DayOfWeek.saturday,
          timeOfDay: const TimeOfDayValue(11, 0),
          vehicles: 1,
          childrenPerVehicle: 2,
        );

        await tester.pumpWidget(
          createTestWidget(
            child: EnhancedSlotCard(
              isSlotInPast: (slot) =>
                  false, // Disable timezone-dependent past detection

              key: const Key('test_available_status'),
              displayableSlot: displayableSlot,
              childrenMap: testChildren,
            ),
          ),
        );

        // Find the status badge specifically (has key 'status_badge')
        final statusBadge = find.byKey(const Key('status_badge'));
        expect(statusBadge, findsOneWidget);

        // Verify it contains the check_circle icon
        final statusBadgeWidget = tester.widget<Container>(statusBadge);
        expect(statusBadgeWidget.child, isA<Icon>());
        final icon = statusBadgeWidget.child as Icon;
        expect(icon.icon, equals(Icons.check_circle));
      });

      testWidgets('displays limited status badge correctly', (
        WidgetTester tester,
      ) async {
        final displayableSlot = ScheduleTestHelpers.createDisplayableSlot(
          dayOfWeek: DayOfWeek.sunday,
          timeOfDay: const TimeOfDayValue(13, 0),
          vehicles: 2,
          childrenPerVehicle: 4,
        );

        await tester.pumpWidget(
          createTestWidget(
            child: EnhancedSlotCard(
              isSlotInPast: (slot) =>
                  false, // Disable timezone-dependent past detection

              key: const Key('test_limited_status'),
              displayableSlot: displayableSlot,
              childrenMap: testChildren,
            ),
          ),
        );

        // Find the status badge specifically (has key 'status_badge')
        final statusBadge = find.byKey(const Key('status_badge'));
        expect(statusBadge, findsOneWidget);

        // Verify it contains the warning icon
        final statusBadgeWidget = tester.widget<Container>(statusBadge);
        expect(statusBadgeWidget.child, isA<Icon>());
        final icon = statusBadgeWidget.child as Icon;
        expect(icon.icon, equals(Icons.warning));
      });

      testWidgets('displays full status badge correctly', (
        WidgetTester tester,
      ) async {
        final displayableSlot = ScheduleTestHelpers.createDisplayableSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: const TimeOfDayValue(17, 0),
          vehicles: 2,
          childrenPerVehicle: 5,
          maxVehicles: 2,
        );

        await tester.pumpWidget(
          createTestWidget(
            child: EnhancedSlotCard(
              isSlotInPast: (slot) =>
                  false, // Disable timezone-dependent past detection

              key: const Key('test_full_status'),
              displayableSlot: displayableSlot,
              childrenMap: testChildren,
            ),
          ),
        );

        // Find the status badge specifically (has key 'status_badge')
        final statusBadge = find.byKey(const Key('status_badge'));
        expect(statusBadge, findsOneWidget);

        // Verify it contains the error icon
        final statusBadgeWidget = tester.widget<Container>(statusBadge);
        expect(statusBadgeWidget.child, isA<Icon>());
        final icon = statusBadgeWidget.child as Icon;
        expect(icon.icon, equals(Icons.error));
      });
    });

    group('Responsive Design', () {
      testWidgets('adapts layout correctly in compact mode', (
        WidgetTester tester,
      ) async {
        final displayableSlot = ScheduleTestHelpers.createDisplayableSlot(
          dayOfWeek: DayOfWeek.tuesday,
          timeOfDay: const TimeOfDayValue(8, 0),
          vehicles: 1,
          childrenPerVehicle: 2,
        );

        await tester.pumpWidget(
          createTestWidget(
            child: EnhancedSlotCard(
              isSlotInPast: (slot) =>
                  false, // Disable timezone-dependent past detection

              key: const Key('test_compact_mode'),
              displayableSlot: displayableSlot,
              compact: true,
              vehicles: testVehicles,
              childrenMap: testChildren,
            ),
          ),
        );

        expect(find.byType(EnhancedSlotCard), findsOneWidget);
        // Compact mode should still display all essential elements
        expect(find.byKey(const Key('slot_time')), findsOneWidget);
        expect(find.byKey(const Key('status_badge')), findsOneWidget);
      });

      testWidgets('handles missing vehicles gracefully', (
        WidgetTester tester,
      ) async {
        final displayableSlot = ScheduleTestHelpers.createDisplayableSlot(
          dayOfWeek: DayOfWeek.wednesday,
          timeOfDay: const TimeOfDayValue(10, 0),
          vehicles: 1,
          childrenPerVehicle: 2,
        );

        await tester.pumpWidget(
          createTestWidget(
            child: EnhancedSlotCard(
              isSlotInPast: (slot) =>
                  false, // Disable timezone-dependent past detection

              key: const Key('test_missing_vehicles'),
              displayableSlot: displayableSlot,
              // No vehicles provided
              childrenMap: testChildren,
            ),
          ),
        );

        expect(find.byType(EnhancedSlotCard), findsOneWidget);
        // Should still display the slot without crashing
      });

      testWidgets('handles missing children gracefully', (
        WidgetTester tester,
      ) async {
        final displayableSlot = ScheduleTestHelpers.createDisplayableSlot(
          dayOfWeek: DayOfWeek.thursday,
          timeOfDay: const TimeOfDayValue(14, 0),
          vehicles: 1,
          childrenPerVehicle: 2,
        );

        await tester.pumpWidget(
          createTestWidget(
            child: EnhancedSlotCard(
              isSlotInPast: (slot) =>
                  false, // Disable timezone-dependent past detection

              key: const Key('test_missing_children'),
              displayableSlot: displayableSlot,
              vehicles: testVehicles,
              // Empty children map
              childrenMap: const {},
            ),
          ),
        );

        expect(find.byType(EnhancedSlotCard), findsOneWidget);
        // Should still display the slot without crashing
      });
    });

    group('Localization', () {
      testWidgets('displays localized text correctly in French', (
        WidgetTester tester,
      ) async {
        final displayableSlot = ScheduleTestHelpers.createDisplayableSlot(
          dayOfWeek: DayOfWeek.friday,
          timeOfDay: const TimeOfDayValue(9, 0),
          existsInBackend: false,
        );

        await tester.pumpWidget(
          createTestWidget(
            child: EnhancedSlotCard(
              isSlotInPast: (slot) =>
                  false, // Disable timezone-dependent past detection

              key: const Key('test_localization_fr'),
              displayableSlot: displayableSlot,
              childrenMap: testChildren,
            ),
          ),
        );

        expect(find.text('Ajouter un véhicule'), findsOneWidget);
      });

      testWidgets('displays localized text correctly in English', (
        WidgetTester tester,
      ) async {
        final displayableSlot = ScheduleTestHelpers.createDisplayableSlot(
          dayOfWeek: DayOfWeek.saturday,
          timeOfDay: const TimeOfDayValue(11, 0),
          existsInBackend: false,
        );

        await tester.pumpWidget(
          createTestWidget(
            child: EnhancedSlotCard(
              isSlotInPast: (slot) =>
                  false, // Disable timezone-dependent past detection

              key: const Key('test_localization_en'),
              displayableSlot: displayableSlot,
              childrenMap: testChildren,
            ),
            locale: 'en',
          ),
        );

        expect(find.text('Add vehicle'), findsOneWidget);
      });
    });

    group('Edge Cases', () {
      testWidgets('handles slot with no user timezone', (
        WidgetTester tester,
      ) async {
        // Override with null timezone
        when(mockUser.timezone).thenReturn(null);

        final displayableSlot = ScheduleTestHelpers.createDisplayableSlot(
          dayOfWeek: DayOfWeek.sunday,
          timeOfDay: const TimeOfDayValue(15, 0),
          existsInBackend: false,
        );

        await tester.pumpWidget(
          createTestWidget(
            child: EnhancedSlotCard(
              isSlotInPast: (slot) =>
                  false, // Disable timezone-dependent past detection

              key: const Key('test_no_timezone'),
              displayableSlot: displayableSlot,
              childrenMap: testChildren,
            ),
          ),
        );

        expect(find.byType(EnhancedSlotCard), findsOneWidget);
        // Should handle null timezone gracefully
      });

      testWidgets('handles slot with empty timezone string', (
        WidgetTester tester,
      ) async {
        // Override with empty timezone
        when(mockUser.timezone).thenReturn('');

        final displayableSlot = ScheduleTestHelpers.createDisplayableSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: const TimeOfDayValue(8, 0),
          vehicles: 1,
          childrenPerVehicle: 1,
        );

        await tester.pumpWidget(
          createTestWidget(
            child: EnhancedSlotCard(
              isSlotInPast: (slot) =>
                  false, // Disable timezone-dependent past detection

              key: const Key('test_empty_timezone'),
              displayableSlot: displayableSlot,
              vehicles: testVehicles,
              childrenMap: testChildren,
            ),
          ),
        );

        expect(find.byType(EnhancedSlotCard), findsOneWidget);
        // Should handle empty timezone gracefully
      });

      testWidgets('handles no available vehicles correctly', (
        WidgetTester tester,
      ) async {
        // Create scenario where ALL 4 vehicles from testVehicles are assigned to this slot
        // testVehicles contains 4 vehicles, so we need to assign all 4
        final displayableSlot = ScheduleTestHelpers.createDisplayableSlot(
          dayOfWeek: DayOfWeek.tuesday,
          timeOfDay: const TimeOfDayValue(10, 0),
          vehicles: 4, // Assign all 4 available test vehicles
          childrenPerVehicle: 2,
          maxVehicles: 5, // Allow enough capacity
        );

        await tester.pumpWidget(
          createTestWidget(
            child: EnhancedSlotCard(
              isSlotInPast: (slot) =>
                  false, // Disable timezone-dependent past detection

              key: const Key('test_no_available_vehicles'),
              displayableSlot: displayableSlot,
              vehicles:
                  testVehicles, // All 4 test vehicles are now assigned to this slot
              childrenMap: testChildren,
            ),
          ),
        );

        // Should show no vehicles available badge because all vehicles are assigned
        expect(
          find.byKey(const Key('no_vehicles_available_badge')),
          findsOneWidget,
        );
      });
    });
  });
}
