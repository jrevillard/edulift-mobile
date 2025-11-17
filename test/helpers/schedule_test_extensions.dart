import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edulift/core/domain/entities/family/child.dart';
import 'package:edulift/core/domain/entities/family/vehicle.dart';
import 'package:edulift/core/domain/entities/user.dart';
import 'package:edulift/core/domain/entities/schedule.dart';
import 'package:edulift/features/schedule/presentation/models/displayable_time_slot.dart';
import 'package:edulift/features/schedule/presentation/widgets/mobile/enhanced_slot_card.dart';
import 'package:edulift/features/schedule/presentation/widgets/mobile/day_card_widget.dart';
import 'package:edulift/features/schedule/presentation/widgets/mobile/period_card_widget.dart';
import 'package:edulift/features/schedule/presentation/widgets/mobile/schedule_week_cards.dart';
import 'package:edulift/features/schedule/presentation/widgets/mobile/availability_indicators.dart';
import 'package:edulift/features/schedule/presentation/widgets/mobile/child_selection_cards.dart';

import 'package:edulift/generated/l10n/app_localizations.dart';
import 'package:edulift/core/services/providers/auth_provider.dart';

import 'schedule_test_helpers.dart';

/// WidgetTester extensions for schedule widget testing
///
/// This file provides specialized WidgetTester extensions for pumping and testing
/// schedule-related widgets. These extensions handle the complex setup required
/// for Riverpod providers, mock data, and proper widget configuration.
///
/// Example usage:
/// ```dart
/// testWidgets('EnhancedSlotCard displays correctly', (tester) async {
///   await tester.pumpEnhancedSlotCard(
///     displayableSlot: testSlot,
///     childrenMap: testChildren,
///     vehicles: testVehicles,
///   );
///
///   expect(find.byKey(Key('enhanced_slot_card_${testSlot.compositeKey}')), findsOneWidget);
///   await tester.tapVehicleAction('test-vehicle-1', 'manage');
/// });
/// ```
extension ScheduleWidgetTesterExtensions on WidgetTester {
  // ====================================================================
  // WIDGET PUMPING EXTENSIONS
  // ====================================================================

  /// Pumps an EnhancedSlotCard with test configuration
  ///
  /// Parameters:
  /// - [displayableSlot]: The slot data to display
  /// - [childrenMap]: Map of children for displaying names
  /// - [vehicles]: Available vehicles (optional)
  /// - [onAddVehicle]: Optional callback for add vehicle action
  /// - [onVehicleAction]: Optional callback for vehicle actions
  /// - [compact]: Whether to use compact mode
  /// - [isSlotInPast]: Optional function to determine if slot is in past
  Future<void> pumpEnhancedSlotCard({
    required DisplayableTimeSlot displayableSlot,
    required Map<String, Child> childrenMap,
    Map<String, Vehicle?>? vehicles,
    Function(DisplayableTimeSlot)? onAddVehicle,
    Function(VehicleAssignment, String)? onVehicleAction,
    bool compact = false,
    bool Function(DisplayableTimeSlot)? isSlotInPast,
  }) async {
    final widget = ProviderScope(
      overrides: [
        // Mock current user provider for timezone
        currentUserProvider.overrideWithValue(
          User(
            id: 'test-user',
            email: 'test@example.com',
            name: 'Test User',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            timezone: ScheduleTestHelpers.testTimezone,
          ),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: EnhancedSlotCard(
            key: const Key('enhanced_slot_card_test'),
            displayableSlot: displayableSlot,
            childrenMap: childrenMap,
            vehicles: vehicles,
            onAddVehicle: onAddVehicle,
            onVehicleAction: onVehicleAction,
            compact: compact,
            isSlotInPast: isSlotInPast,
          ),
        ),
      ),
    );

    await pumpWidget(widget);
    await pumpAndSettle();
  }

  /// Pumps a DayCardWidget with test configuration
  ///
  /// Parameters:
  /// - [dayOfWeek]: Day of the week to display
  /// - [slots]: List of slots for this day
  /// - [childrenMap]: Map of children for displaying names
  /// - [vehicles]: Available vehicles (optional)
  /// - [onSlotTap]: Optional callback for slot taps
  /// - [onAddVehicle]: Optional callback for add vehicle action
  /// - [compact]: Whether to use compact mode
  Future<void> pumpDayCardWidget({
    required DayOfWeek dayOfWeek,
    required List<DisplayableTimeSlot> slots,
    required Map<String, Child> childrenMap,
    Map<String, Vehicle?>? vehicles,
    Function(DisplayableTimeSlot)? onSlotTap,
    Function(DisplayableTimeSlot)? onAddVehicle,
    bool compact = false,
  }) async {
    final widget = ProviderScope(
      overrides: [
        currentUserProvider.overrideWithValue(
          User(
            id: 'test-user',
            email: 'test@example.com',
            name: 'Test User',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            timezone: ScheduleTestHelpers.testTimezone,
          ),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: DayCardWidget(
            key: Key('day_card_${dayOfWeek.name}'),
            date: DateTime.now(),
            displayableSlots: slots,
            childrenMap: childrenMap,
            vehicles: vehicles,
            onSlotTap: onSlotTap ?? (_) {},
            onAddVehicle: onAddVehicle,
          ),
        ),
      ),
    );

    await pumpWidget(widget);
    await pumpAndSettle();
  }

  /// Pumps a PeriodCardWidget with test configuration
  ///
  /// Parameters:
  /// - [periodName]: Name of the period
  /// - [displayableSlots]: List of displayable slots for the period
  /// - [childrenMap]: Map of children for displaying names
  /// - [vehicles]: Available vehicles (optional)
  /// - [onSlotTap]: Optional callback for slot taps
  /// - [onAddVehicle]: Optional callback for add vehicle action
  Future<void> pumpPeriodCardWidget({
    required String periodName,
    required List<DisplayableTimeSlot> displayableSlots,
    required Map<String, Child> childrenMap,
    Map<String, Vehicle?>? vehicles,
    Function(DisplayableTimeSlot)? onSlotTap,
    Function(DisplayableTimeSlot)? onAddVehicle,
    bool compact = false,
  }) async {
    final widget = ProviderScope(
      overrides: [
        currentUserProvider.overrideWithValue(
          User(
            id: 'test-user',
            email: 'test@example.com',
            name: 'Test User',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            timezone: ScheduleTestHelpers.testTimezone,
          ),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PeriodCardWidget(
            key: Key('period_card_$periodName'),
            periodName: periodName,
            displayableSlots: displayableSlots,
            childrenMap: childrenMap,
            vehicles: vehicles,
            onSlotTap: onSlotTap ?? (_) {},
            onAddVehicle: onAddVehicle,
          ),
        ),
      ),
    );

    await pumpWidget(widget);
    await pumpAndSettle();
  }

  /// Pumps ScheduleWeekCards with test configuration
  ///
  /// Parameters:
  /// - [weekSchedule]: Complete week schedule
  /// - [childrenMap]: Map of children for displaying names
  /// - [vehicles]: Available vehicles (optional)
  /// - [onSlotTap]: Optional callback for slot taps
  /// - [onAddVehicle]: Optional callback for add vehicle action
  /// - [compact]: Whether to use compact mode
  Future<void> pumpScheduleWeekCards({
    required List<DisplayableTimeSlot> weekSchedule,
    required Map<String, Child> childrenMap,
    Map<String, Vehicle?>? vehicles,
    Function(DisplayableTimeSlot)? onSlotTap,
    Function(DisplayableTimeSlot)? onAddVehicle,
    bool compact = false,
  }) async {
    final widget = ProviderScope(
      overrides: [
        currentUserProvider.overrideWithValue(
          User(
            id: 'test-user',
            email: 'test@example.com',
            name: 'Test User',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            timezone: ScheduleTestHelpers.testTimezone,
          ),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ScheduleWeekCards(
            key: const Key('schedule_week_cards'),
            displayableSlots: weekSchedule,
            childrenMap: childrenMap,
            vehicles: vehicles ?? {},
            onSlotTap: onSlotTap ?? (_) {},
            onAddVehicle: onAddVehicle,
            isSlotInPast: (slot) => false,
          ),
        ),
      ),
    );

    await pumpWidget(widget);
    await pumpAndSettle();
  }

  /// Pumps AvailabilityIndicators with test configuration
  ///
  /// Parameters:
  /// - [slot]: The slot to show indicators for
  /// - [vehicles]: Available vehicles (optional)
  /// - [isPast]: Whether the slot is in the past
  Future<void> pumpAvailabilityIndicators({
    required DisplayableTimeSlot slot,
    Map<String, Vehicle?>? vehicles,
    bool isPast = false,
  }) async {
    final widget = ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SlotAvailabilityIndicator(
            key: Key('availability_indicators_${slot.compositeKey}'),
            status: SlotAvailabilityStatus.available,
            capacity: 5,
          ),
        ),
      ),
    );

    await pumpWidget(widget);
    await pumpAndSettle();
  }

  /// Pumps ChildSelectionCards with test configuration
  ///
  /// Parameters:
  /// - [availableChildren]: List of available children
  /// - [selectedChildren]: Currently selected children
  /// - [onChildSelected]: Callback when child is selected
  /// - [onChildDeselected]: Callback when child is deselected
  /// - [maxSelections]: Maximum number of selections allowed
  Future<void> pumpChildSelectionCards({
    required List<Child> availableChildren,
    required Set<String> selectedChildren,
    required Function(String) onChildSelected,
    required Function(String) onChildDeselected,
    int? maxSelections,
  }) async {
    final widget = MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: ChildSelectionCards(
          key: const Key('child_selection_cards'),
          groupId: 'test-group',
          week: '2024-W01',
          slotId: 'test-slot',
          vehicleAssignment: VehicleAssignment(
            id: 'test-vehicle',
            scheduleSlotId: 'test-slot',
            vehicleId: 'vehicle-1',
            assignedAt: DateTime.now(),
            assignedBy: 'test-user',
            vehicleName: 'Test Vehicle',
            capacity: 5,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          availableChildren: availableChildren,
          currentlyAssignedChildIds: selectedChildren.toList(),
        ),
      ),
    );

    await pumpWidget(widget);
    await pumpAndSettle();
  }

  // ====================================================================
  // INTERACTION HELPERS
  // ====================================================================

  /// Taps the add vehicle button in an EnhancedSlotCard
  Future<void> tapAddVehicleButton({String? slotKey}) async {
    const key = Key('add_vehicle_empty_state');

    await tap(find.byKey(key));
    await pumpAndSettle();
  }

  /// Taps a vehicle action menu option
  ///
  /// Parameters:
  /// - [vehicleId]: ID of the vehicle
  /// - [action]: Action to perform ('manage', 'replace', 'remove')
  Future<void> tapVehicleAction(String vehicleId, String action) async {
    // First tap the menu button
    final menuKey = Key('vehicle_action_menu_$vehicleId');
    await tap(find.byKey(menuKey));
    await pumpAndSettle();

    // Then tap the specific action
    final actionKey = Key('vehicle_action_${action}_$vehicleId');
    await tap(find.byKey(actionKey));
    await pumpAndSettle();
  }

  /// Taps a vehicle card to manage children
  Future<void> tapVehicleCard(String vehicleId) async {
    final cardKey = Key('vehicle_card_$vehicleId');
    await tap(find.byKey(cardKey));
    await pumpAndSettle();
  }

  /// Taps a slot time header
  Future<void> tapSlotTime() async {
    await tap(find.byKey(const Key('slot_time')));
    await pumpAndSettle();
  }

  /// Taps a status badge
  Future<void> tapStatusBadge() async {
    await tap(find.byKey(const Key('status_badge')));
    await pumpAndSettle();
  }

  /// Selects a child in ChildSelectionCards
  Future<void> selectChild(String childId) async {
    final childCardKey = Key('child_card_$childId');
    await tap(find.byKey(childCardKey));
    await pumpAndSettle();
  }

  // ====================================================================
  // VERIFICATION HELPERS
  // ====================================================================

  /// Verifies that an EnhancedSlotCard is displayed with expected data
  void expectEnhancedSlotCard({
    required DisplayableTimeSlot slot,
    bool shouldExist = true,
  }) {
    final cardKey = slot.existsInBackend
        ? Key('enhanced_slot_card_${slot.scheduleSlot!.id}')
        : Key('enhanced_slot_card_uncreated_${slot.compositeKey}');

    expect(find.byKey(cardKey), shouldExist ? findsOneWidget : findsNothing);
  }

  /// Verifies that vehicle assignments are displayed correctly
  void expectVehicleAssignments({
    required List<String> vehicleIds,
    bool shouldBeDisplayed = true,
  }) {
    for (final vehicleId in vehicleIds) {
      final cardKey = Key('vehicle_card_$vehicleId');
      expect(
        find.byKey(cardKey),
        shouldBeDisplayed ? findsOneWidget : findsNothing,
      );
    }
  }

  /// Verifies that add vehicle button is displayed
  void expectAddVehicleButton({bool shouldBeDisplayed = true}) {
    expect(
      find.byKey(const Key('add_vehicle_empty_state')),
      shouldBeDisplayed ? findsOneWidget : findsNothing,
    );
  }

  /// Verifies that max capacity badge is displayed
  void expectMaxCapacityBadge({bool shouldBeDisplayed = true}) {
    expect(
      find.byKey(const Key('max_capacity_badge')),
      shouldBeDisplayed ? findsOneWidget : findsNothing,
    );
  }

  /// Verifies that no vehicles available badge is displayed
  void expectNoVehiclesAvailableBadge({bool shouldBeDisplayed = true}) {
    expect(
      find.byKey(const Key('no_vehicles_available_badge')),
      shouldBeDisplayed ? findsOneWidget : findsNothing,
    );
  }

  /// Verifies that child selection cards are displayed
  void expectChildSelectionCards({
    required List<String> childIds,
    bool shouldBeDisplayed = true,
  }) {
    for (final childId in childIds) {
      final cardKey = Key('child_card_$childId');
      expect(
        find.byKey(cardKey),
        shouldBeDisplayed ? findsOneWidget : findsNothing,
      );
    }
  }

  /// Verifies that a specific child is selected
  void expectChildSelected({required String childId, bool isSelected = true}) {
    final selectedKey = Key('child_selected_$childId');
    expect(find.byKey(selectedKey), isSelected ? findsOneWidget : findsNothing);
  }

  /// Verifies that slot time is displayed with expected text
  void expectSlotTime(String expectedTime) {
    expect(find.text(expectedTime), findsOneWidget);
  }

  /// Verifies that a vehicle name is displayed
  void expectVehicleName(String vehicleName) {
    expect(find.text(vehicleName), findsOneWidget);
  }

  /// Verifies that child names are displayed in vehicle cards
  void expectChildNamesInVehicle(List<String> childNames) {
    for (final childName in childNames) {
      expect(find.text(childName), findsWidgets);
    }
  }

  /// Verifies capacity information is displayed
  void expectCapacityInfo(String capacityText) {
    expect(find.text(capacityText), findsOneWidget);
  }

  // ====================================================================
  // GOLDEN TEST HELPERS
  // ====================================================================

  /// Prepares widget for golden testing with specific surface size
  Future<void> prepareForGoldenTest({
    required Size surfaceSize,
    Brightness brightness = Brightness.light,
  }) async {
    await binding.setSurfaceSize(surfaceSize);
  }

  /// Resets surface size after golden testing
  void resetGoldenTest() {
    binding.setSurfaceSize(null);
  }
}

/// Mock user for testing timezone functionality
class MockUser {
  final String id;
  final String email;
  final String timezone;

  MockUser({required this.id, required this.email, required this.timezone});
}
