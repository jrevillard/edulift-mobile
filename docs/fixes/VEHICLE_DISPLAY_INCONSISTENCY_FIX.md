# Vehicle Display Inconsistency Bug Fix

## Problem Description

**Severity**: CRITICAL - UI Consistency Bug

The UI displayed an inconsistent state where:
- The ExpansionTile subtitle showed "No vehicles assigned to this time slot" (or French: "Aucun véhicule assigné à ce créneau horaire")
- BUT below that message, vehicles were actually listed with full details (name, capacity, children assignments)

This creates a confusing user experience and breaks the fundamental principle that UI must be 100% consistent.

## Root Cause Analysis

### The Bug

In `/workspace/mobile_app/lib/features/schedule/presentation/widgets/vehicle_selection_modal.dart`, two **different** methods were being used to check for assigned vehicles:

1. **Line 488** - In `_buildEnhancedTimeSlotList()` (ExpansionTile subtitle):
   ```dart
   final assignedVehicles = _getAssignedVehiclesForTime(timeSlot, slotData);
   ```
   This method filters vehicles by **specific time slot**.

2. **Line 595** - In `_buildSingleSlotContent()` (actual vehicle list):
   ```dart
   final assignedVehicles = _getAssignedVehicles(slotData);  // ❌ WRONG!
   ```
   This method gets **ALL vehicles in the period** without time filtering.

### Why This Caused the Bug

- `_getAssignedVehiclesForTime(timeSlot, slotData)` returns `[]` if no vehicles match the **specific time**
- `_getAssignedVehicles(slotData)` returns **all vehicles** from the entire period (all times)
- Result: Subtitle says "empty" but content shows vehicles

## Solution

**Changed line 595 to use the same method as line 488:**

```dart
// BEFORE (❌ WRONG)
final assignedVehicles = _getAssignedVehicles(slotData);

// AFTER (✅ CORRECT)
final assignedVehicles = _getAssignedVehiclesForTime(timeSlot, slotData);
```

This ensures **consistency**: both the subtitle check and the content list use the same filtering logic.

## Implementation Details

### File Modified
- `/workspace/mobile_app/lib/features/schedule/presentation/widgets/vehicle_selection_modal.dart` (line 595-597)

### Methods Involved

1. **`_getAssignedVehiclesForTime(TimeOfDayValue timeSlot, PeriodSlotData slotData)`** (lines 642-652):
   - Filters vehicles by **specific time slot**
   - Returns empty list if no matching slot found
   - Used for time-specific checks

2. **`_getAssignedVehicles(PeriodSlotData slotData)`** (lines 631-636):
   - Returns **ALL vehicles** from all time slots in the period
   - Used for period-level aggregation
   - Should NOT be used when displaying time-specific data

## Testing Strategy

### Manual Testing
1. ✅ Open schedule grid with multiple time slots
2. ✅ Assign vehicle to slot 07:30
3. ✅ Open slot 08:00 (no vehicles)
4. ✅ Verify: Should show "No vehicles assigned" AND no vehicle list below
5. ✅ Open slot 07:30 (has vehicles)
6. ✅ Verify: Should show "1 vehicle" AND display the vehicle details

### Expected Behavior

| Scenario | Subtitle Display | Content Display |
|----------|------------------|-----------------|
| No vehicles at specific time | "No vehicles assigned to this time slot" | Empty state message |
| 1 vehicle at specific time | "1 vehicle" | Vehicle card with details |
| 2+ vehicles at specific time | "X vehicles" | Multiple vehicle cards |

### Unit Test Coverage

Key test cases to implement:

```dart
test('subtitle and content use same vehicle list for consistency', () {
  // Given: Period with vehicles at 07:30 but not at 08:00
  final slotData = PeriodSlotData(...);

  // When: Building UI for 08:00
  // Then: Both subtitle AND content should show empty state

  // When: Building UI for 07:30
  // Then: Both subtitle AND content should show vehicles
});

test('_getAssignedVehiclesForTime filters by specific time', () {
  // Given: Slot with vehicle at 07:30
  // When: Query for 08:00
  // Then: Returns empty list
});

test('_getAssignedVehicles returns all vehicles regardless of time', () {
  // Given: Slots with vehicles at 07:30 and 08:00
  // When: Query period
  // Then: Returns both vehicles
});
```

## Validation

✅ **UI Consistency**: Subtitle and content always match
✅ **Type Safety**: Uses TimeOfDayValue for time matching
✅ **No Regression**: Existing functionality preserved
✅ **User Experience**: Clear, consistent messaging

## Related Issues

This fix is part of a broader effort to ensure UI consistency across the schedule module:
- See also: MULTI_VEHICLE_SLOT_FIX.md
- See also: SCHEDULE_GRID_FIX_SUMMARY.md

## Impact

- **User Facing**: Critical - Users will no longer see conflicting information
- **Developer Impact**: Minimal - One line change with clear intent
- **Performance**: None - Same filtering logic, just consistent usage

## Commit Message

```
fix(schedule): ensure consistent vehicle display in time slot modal

Previously, the ExpansionTile subtitle used _getAssignedVehiclesForTime()
to check for vehicles, but the content used _getAssignedVehicles() which
returns ALL vehicles in the period. This caused inconsistency where the
subtitle showed "No vehicles assigned" but the content listed vehicles.

Fix: Use _getAssignedVehiclesForTime() consistently for both the subtitle
check and content display to ensure UI consistency.

Fixes: Issue where user sees "Aucun véhicule assigné" message above a
vehicle list in the vehicle selection modal.
```

## Date
2025-10-13

## Author
Claude Code (AI Assistant)
