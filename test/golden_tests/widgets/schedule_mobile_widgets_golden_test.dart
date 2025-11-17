// EduLift - Schedule Mobile Widgets Golden Tests
// Comprehensive visual regression tests for schedule mobile widgets
// Tests: DayCardWidget and EnhancedSlotCard with realistic data

@Tags(['golden'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:edulift/features/schedule/presentation/widgets/mobile/day_card_widget.dart';
import 'package:edulift/features/schedule/presentation/widgets/mobile/enhanced_slot_card.dart';
import 'package:edulift/features/schedule/presentation/models/displayable_time_slot.dart';
import 'package:edulift/core/domain/entities/family/vehicle.dart';
import 'package:edulift/core/domain/entities/family/child.dart';
import 'package:edulift/core/domain/entities/schedule.dart';

import '../../support/golden/golden_test_wrapper.dart';
import '../../support/test_app_configuration.dart';

void main() {
  setUpAll(() async {
    // Initialize app configuration including localizations for schedule widgets
    // Note: timezone initialization is now handled automatically by GoldenTestWrapper
    await TestAppConfiguration.initialize();
  });

  group('Schedule Mobile Widgets - Golden Tests', () {
    final testDate = DateTime(2025);
    late Map<String, Vehicle> testVehicles;
    late Map<String, Child> testChildren;

    setUp(() {
      // Create test vehicles matching fixture IDs
      testVehicles = {
        'vehicle-1': Vehicle(
          id: 'vehicle-1',
          name: 'Family Car',
          capacity: 5,
          familyId: 'family-1',
          createdAt: testDate,
          updatedAt: testDate,
        ),
        'vehicle-2': Vehicle(
          id: 'vehicle-2',
          name: 'Mini Van',
          capacity: 3,
          familyId: 'family-1',
          createdAt: testDate,
          updatedAt: testDate,
        ),
      };

      // Create test children matching fixture IDs
      testChildren = {
        'child-1': Child(
          id: 'child-1',
          name: 'Alice Johnson',
          familyId: 'family-1',
          createdAt: testDate,
          updatedAt: testDate,
        ),
        'child-2': Child(
          id: 'child-2',
          name: 'Bob Smith',
          familyId: 'family-2',
          createdAt: testDate,
          updatedAt: testDate,
        ),
      };
    });

    // =================================================================
    // ENHANCED SLOT CARD TESTS
    // =================================================================

    testWidgets('EnhancedSlotCard - empty slot (not created)', (tester) async {
      const slot = DisplayableTimeSlot(
        dayOfWeek: DayOfWeek.monday,
        timeOfDay: TimeOfDayValue(8, 0),
        week: '2025-W01',
        existsInBackend: false,
      );

      await GoldenTestWrapper.testWidget(
        tester: tester,
        testName: 'enhanced_slot_card_empty',
        widget: EnhancedSlotCard(
          displayableSlot: slot,
          onVehicleAction: (assignment, action) {},
          onAddVehicle: (slot) {},
          childrenMap: testChildren,
          vehicles: testVehicles,
        ),
      );
    });

    testWidgets('EnhancedSlotCard - morning slot (created)', (tester) async {
      const slot = DisplayableTimeSlot(
        dayOfWeek: DayOfWeek.tuesday,
        timeOfDay: TimeOfDayValue(9, 0),
        week: '2025-W01',
        existsInBackend: true,
      );

      await GoldenTestWrapper.testWidget(
        tester: tester,
        testName: 'enhanced_slot_card_morning',
        widget: EnhancedSlotCard(
          displayableSlot: slot,
          onVehicleAction: (assignment, action) {},
          onAddVehicle: (slot) {},
          childrenMap: testChildren,
          vehicles: testVehicles,
        ),
      );
    });

    testWidgets('EnhancedSlotCard - afternoon slot', (tester) async {
      const slot = DisplayableTimeSlot(
        dayOfWeek: DayOfWeek.wednesday,
        timeOfDay: TimeOfDayValue(15, 0),
        week: '2025-W01',
        existsInBackend: true,
      );

      await GoldenTestWrapper.testWidget(
        tester: tester,
        testName: 'enhanced_slot_card_afternoon',
        widget: EnhancedSlotCard(
          displayableSlot: slot,
          onVehicleAction: (assignment, action) {},
          onAddVehicle: (slot) {},
          childrenMap: testChildren,
          vehicles: testVehicles,
        ),
      );
    });

    // =================================================================
    // DAY CARD WIDGET TESTS
    // =================================================================

    testWidgets('DayCardWidget - with mixed slots', (tester) async {
      const slots = [
        DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: TimeOfDayValue(8, 0),
          week: '2025-W01',
          existsInBackend: true,
        ),
        DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: TimeOfDayValue(14, 0),
          week: '2025-W01',
          existsInBackend: false,
        ),
      ];

      await GoldenTestWrapper.testWidget(
        tester: tester,
        testName: 'day_card_mixed_slots',
        widget: TestAppConfiguration.createTestWidget(
          child: DayCardWidget(
            key: const Key('day_card_mixed_slots_test'),
            date: testDate,
            displayableSlots: slots,
            onSlotTap: (slot) {},
            onAddVehicle: (slot) {},
            onVehicleAction: (slot, assignment, action) {},
            vehicles: testVehicles,
            childrenMap: testChildren,
          ),
        ),
      );
    });

    testWidgets('DayCardWidget - single empty slot', (tester) async {
      const slots = [
        DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.tuesday,
          timeOfDay: TimeOfDayValue(8, 0),
          week: '2025-W01',
          existsInBackend: false,
        ),
      ];

      await GoldenTestWrapper.testWidget(
        tester: tester,
        testName: 'day_card_empty_slots',
        widget: TestAppConfiguration.createTestWidget(
          child: DayCardWidget(
            key: const Key('day_card_empty_slots_test'),
            date: testDate,
            displayableSlots: slots,
            onSlotTap: (slot) {},
            childrenMap: testChildren,
          ),
        ),
      );
    });

    testWidgets('DayCardWidget - single morning slot', (tester) async {
      const slots = [
        DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.wednesday,
          timeOfDay: TimeOfDayValue(7, 30),
          week: '2025-W01',
          existsInBackend: true,
        ),
      ];

      await GoldenTestWrapper.testWidget(
        tester: tester,
        testName: 'day_card_single_morning',
        widget: TestAppConfiguration.createTestWidget(
          child: DayCardWidget(
            key: const Key('day_card_single_morning_test'),
            date: testDate,
            displayableSlots: slots,
            onSlotTap: (slot) {},
            childrenMap: testChildren,
          ),
        ),
      );
    });
  });
}
