# Schedule Test Infrastructure

This directory contains comprehensive test infrastructure for the Schedule Mobile UX refactoring project. The infrastructure provides helpers, extensions, fixtures, and configuration for testing schedule-related widgets and business logic.

## Files Overview

### 1. ScheduleTestHelpers (`schedule_test_helpers.dart`)

Comprehensive helper methods for creating test data:

#### DisplayableTimeSlot Creation
- `createDisplayableSlot()` - Creates individual slots with configurable properties
- `createWeekSchedule()` - Generates complete week schedules
- `createPastSlot()` - Creates slots in the past for testing time-based behavior

#### Vehicle Management
- `createTestVehicle()` - Creates test vehicles with specified properties
- `createTestVehicles()` - Creates multiple test vehicles
- `createVehicleMap()` - Creates vehicle ID to entity mappings

#### Child Management
- `createTestChild()` - Creates test children with age and names
- `createTestChildren()` - Creates multiple test children
- `createChildMap()` - Creates child ID to entity mappings

#### Vehicle Assignment
- `createVehicleAssignment()` - Creates vehicle assignments with child assignments


#### Capacity Testing
- `createCapacityTestCases()` - Creates slots for different capacity scenarios

### 2. ScheduleTestExtensions (`schedule_test_extensions.dart`)

WidgetTester extensions for schedule widget testing:

#### Widget Pumping Extensions
- `pumpEnhancedSlotCard()` - Pumps EnhancedSlotCard with test configuration
- `pumpDayCardWidget()` - Pumps DayCardWidget with test data
- `pumpPeriodCardWidget()` - Pumps PeriodCardWidget with test data
- `pumpScheduleWeekCards()` - Pumps ScheduleWeekCards with test data
- `pumpAvailabilityIndicators()` - Pumps availability indicators
- `pumpChildSelectionCards()` - Pumps child selection components

#### Interaction Helpers
- `tapAddVehicleButton()` - Taps add vehicle buttons
- `tapVehicleAction()` - Taps vehicle action menu items
- `tapVehicleCard()` - Taps vehicle cards
- `selectChild()` - Selects children in selection cards

#### Verification Helpers
- `expectEnhancedSlotCard()` - Verifies slot card display
- `expectVehicleAssignments()` - Verifies vehicle assignments
- `expectAddVehicleButton()` - Verifies add button presence
- `expectChildSelectionCards()` - Verifies child selection UI

#### Golden Test Helpers
- `prepareForGoldenTest()` - Sets up surface size and themes
- `resetGoldenTest()` - Cleans up after golden tests

### 3. ScheduleTestFixtures (`schedule_test_fixtures.dart`)

JSON test data fixtures matching actual API structures:

#### DisplayableTimeSlot Fixtures
- `basicDisplayableSlot` - Slot with one vehicle and children
- `emptySlot` - Configured but not created slot
- `fullCapacitySlot` - Slot at maximum capacity
- `conflictingSlot` - Slot with overcapacity conflict
- `multiVehicleSlot` - Slot with multiple vehicles
- `seatOverrideSlot` - Slot with seat override
- `emptyVehicleSlot` - Vehicle assigned but no children

#### Vehicle Fixtures
- `basicVehicle` - Standard 5-seat vehicle
- `largeVehicle` - Large 8-seat vehicle
- `smallVehicle` - Small 4-seat vehicle

#### Child Fixtures
- `basicChild` - 8-year-old child
- `teenagerChild` - 14-year-old teenager
- `multipleChildren` - List of 5 children with different ages

#### Schedule Fixtures
- `weekSchedule` - Complete week with mixed scenarios

#### Utility Methods
- `parseJson()` - Parse JSON strings to Maps
- `parseJsonList()` - Parse JSON strings to Lists
- `getCapacityFixture()` - Get fixtures by capacity scenario
- `getConflictFixture()` - Get fixtures by conflict type

### 4. ScheduleGoldenTestConfig (`golden_test_config.dart`)

Configuration for golden testing across devices and themes:

#### Device Configurations
- `iphone13` - iPhone 13 (6.1-inch display)
- `pixel6` - Google Pixel 6 (6.4-inch display)
- `galaxyS21` - Samsung Galaxy S21 (6.2-inch display)
- `ipadPro11` - iPad Pro 11-inch

#### Theme Configurations
- `lightTheme` - Light Material 3 theme
- `darkTheme` - Dark Material 3 theme
- `highContrastTheme` - High contrast accessibility theme

#### Test Variants
- `basicVariants` - Mobile devices with all themes
- `tabletVariants` - Tablet devices with all themes
- `mobileVariants` - Mobile devices only (performance optimized)
- `lightThemeVariants` - Light theme across devices
- `darkThemeVariants` - Dark theme across devices
- `highContrastVariants` - High contrast across devices

#### Golden Test Helpers
- `TestApp` - Widget wrapper for golden testing
- `scheduleScaffolder` - Scaffold wrapper for schedule widgets
- `createGoldenTest()` - Creates golden tests with variants
- `createMobileGoldenTest()` - Mobile-specific golden tests
- `createComprehensiveGoldenTest()` - All device/theme combinations

## Usage Examples

### Basic DisplayableTimeSlot Creation
```dart
final slot = ScheduleTestHelpers.createDisplayableSlot(
  dayOfWeek: DayOfWeek.monday,
  timeOfDay: const TimeOfDayValue(8, 0),
  existsInBackend: true,
  vehicles: 1,
  childrenPerVehicle: 3,
);
```

### Week Schedule Creation
```dart
final weekSchedule = ScheduleTestHelpers.createWeekSchedule(
  weekId: '2025-W46',
  vehiclesPerSlot: 2,
  childrenPerVehicle: 3,
  includeWeekend: false,
);
```

### Widget Testing with Extensions
```dart
testWidgets('EnhancedSlotCard displays correctly', (tester) async {
  await tester.pumpEnhancedSlotCard(
    displayableSlot: testSlot,
    childrenMap: testChildren,
    vehicles: testVehicles,
    onAddVehicle: (slot) => handleAddVehicle(slot),
    onVehicleAction: (vehicle, action) => handleAction(vehicle, action),
  );

  expect(find.byKey(Key('enhanced_slot_card_${testSlot.compositeKey}')), findsOneWidget);
  await tester.tapVehicleAction('test-vehicle-1', 'manage');
});
```

### Golden Testing
```dart
testGoldens('EnhancedSlotCard golden test', (tester) async {
  await tester.pumpGoldenWidget(
    ScheduleGoldenTestConfig.TestApp(
      child: EnhancedSlotCard(...),
    ),
    variants: ScheduleGoldenTestConfig.mobileVariants,
  );
});
```

### Using Fixtures
```dart
// Get JSON fixture
final basicSlotJson = ScheduleTestFixtures.basicDisplayableSlot;
final slotData = ScheduleTestFixtures.parseJson(basicSlotJson);

// Get capacity-specific fixture
final overcapacitySlot = ScheduleTestFixtures.getCapacityFixture('overcapacity');
```


## Test Data Validation

The infrastructure includes validation tests to ensure all helpers work correctly:

```bash
flutter test test/helpers/schedule_test_infrastructure_validation_test.dart
```

This test suite validates:
- DisplayableTimeSlot creation with various configurations
- Vehicle and child data generation
- Week schedule generation
- Capacity scenario creation
- Error handling for invalid parameters
- Mock service creation

## Best Practices

1. **Use helpers instead of manual data creation** - Helpers ensure data consistency and validity
2. **Leverage fixtures for edge cases** - Fixtures provide realistic JSON test data
3. **Use extensions for widget testing** - Extensions handle complex setup and teardown
4. **Test across devices and themes** - Use golden test variants for comprehensive coverage
5. **Validate test data** - Use the validation test to ensure helpers work correctly
6. **Mock external dependencies** - Use the mock helpers for consistent test isolation

## Architecture Compliance

The infrastructure respects the project's Clean Architecture:
- **Domain layer** - Uses proper domain entities (DayOfWeek, TimeOfDayValue, etc.)
- **Presentation layer** - Tests DisplayableTimeSlot presentation models
- **Data layer** - Provides mock data that matches API structures
- **Feature-first organization** - Organized under schedule feature directory

All helpers generate valid, coherent data that respects the domain model constraints and business logic rules.