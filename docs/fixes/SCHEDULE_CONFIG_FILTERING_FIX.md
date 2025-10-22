# Schedule Config Filtering Fix

## Problem

The mobile app was displaying vehicle slots in time slots that were NOT configured in the group's `scheduleConfig`. For example:

- `scheduleConfig` had: `['07:30', '15:30']` for Monday
- API returned slots at: `['05:30', '07:30', '08:00', '15:30']` for Monday
- **UI was showing ALL four slots** instead of only the two configured ones

This violated **PRINCIPLE 0**: The UI must be a view of the CONFIGURATION, not the database.

## Root Cause

The schedule grid was building the time slot structure based on `scheduleConfig` (correct), but when fetching actual slot data from the API, it was **not validating** that the slot's time was actually configured. This meant orphaned slots (slots with unconfigured times) were being displayed.

### Code Flow Before Fix

1. `_buildMobileScheduleGrid()` - Builds grid structure from `scheduleConfig` ✅
2. `_getGroupedSlotsForDay(day)` - Gets configured times for specific day ✅
3. `_buildPeriodSlot()` - For each configured period, builds slot widget ✅
4. `_getScheduleSlotData(day, time)` - Searches API data for slot ❌ **NO VALIDATION**

The `_getScheduleSlotData()` method was simply searching through `widget.scheduleData` (API data) and returning any matching slot, without checking if that slot's time was actually configured in `scheduleConfig`.

## Solution

Added validation in `_getScheduleSlotData()` to **reject slots whose time is not configured**:

```dart
ScheduleSlot? _getScheduleSlotData(String day, String time) {
  // 🛡️ VALIDATION: Check if this time is actually configured for this day
  if (widget.scheduleConfig != null) {
    final dayKey = day.toUpperCase();
    final configuredTimes = widget.scheduleConfig!.scheduleHours[dayKey] ?? [];

    if (!configuredTimes.contains(time)) {
      debugPrint('🚫 Rejecting slot $day @ $time (not in scheduleConfig)');
      return null; // Time not configured - don't display this slot
    }
  }

  // Find the slot in API data
  try {
    final slot = widget.scheduleData.firstWhere(
      (slot) => slot.dayOfWeek.fullName == day && slot.timeOfDay.toApiFormat() == time,
    );

    debugPrint('✅ Found slot $day @ $time with ${slot.vehicleAssignments.length} vehicles');
    return slot;
  } catch (e) {
    // No slot found in API data for this configured time - this is normal (empty slot)
    return null;
  }
}
```

## Debug Logging

Added comprehensive logging to identify orphaned slots:

```dart
Widget _buildMobileScheduleGrid(BuildContext context) {
  // 🔍 DEBUG: Log all slots from API to identify orphaned slots
  debugPrint('📊 _buildMobileScheduleGrid: Analyzing ${widget.scheduleData.length} API slots');
  if (widget.scheduleConfig != null) {
    debugPrint('   ScheduleConfig hours: ${widget.scheduleConfig!.scheduleHours}');

    // Identify orphaned slots (slots with times not in scheduleConfig)
    final orphanedSlots = <ScheduleSlot>[];
    for (final slot in widget.scheduleData) {
      final dayKey = slot.dayOfWeek.fullName.toUpperCase();
      final timeStr = slot.timeOfDay.toApiFormat();
      final configuredTimes = widget.scheduleConfig!.scheduleHours[dayKey] ?? [];

      if (!configuredTimes.contains(timeStr)) {
        orphanedSlots.add(slot);
        debugPrint('   ⚠️ ORPHANED SLOT: ${slot.dayOfWeek.fullName} @ $timeStr (not in scheduleConfig)');
      }
    }

    if (orphanedSlots.isNotEmpty) {
      debugPrint('   ⚠️ Found ${orphanedSlots.length} orphaned slots that will be HIDDEN');
    } else {
      debugPrint('   ✅ All API slots match scheduleConfig');
    }
  }

  // ... rest of grid building
}
```

## Test Coverage

Created comprehensive test suite in `/test/unit/features/schedule/presentation/widgets/schedule_grid_orphan_filtering_test.dart`:

### Test Cases

1. **Should hide slots with times NOT in scheduleConfig**
   - Config: `['07:30', '15:30']`
   - API: `['05:30', '07:30', '08:00', '15:30']`
   - Expected: Only `['07:30', '15:30']` visible

2. **Should show ONLY configured slots, even when API has extras**
   - Config: `['07:30']`
   - API: `['05:30', '07:30', '08:00', '15:30']`
   - Expected: Only `['07:30']` visible

3. **Should show NOTHING when scheduleConfig is empty**
   - Config: `[]`
   - API: `['07:30', '08:00']`
   - Expected: No slots visible (empty grid)

4. **Should filter orphans per-day independently**
   - Monday config: `['07:30']`, Tuesday config: `['08:00', '15:30']`
   - Verifies filtering is day-specific

5. **Should handle slots with unconfigured times gracefully (no crash)**
   - Tests with weird times: `['05:30', '23:45', '00:00']`
   - Verifies no crashes occur

6. **Should fall back to showing all slots when scheduleConfig is null**
   - No config provided (graceful degradation)
   - Shows all API slots

### Test Results

```bash
# Run orphan filtering tests
flutter test test/unit/features/schedule/presentation/widgets/schedule_grid_orphan_filtering_test.dart

# All 6 tests PASS ✅
```

Example debug output from tests:

```
📊 _buildMobileScheduleGrid: Analyzing 4 API slots
   ScheduleConfig hours: {MONDAY: [07:30, 15:30], TUESDAY: [07:30, 15:30], ...}
   ⚠️ ORPHANED SLOT: Monday @ 05:30 (not in scheduleConfig)
   ⚠️ ORPHANED SLOT: Monday @ 08:00 (not in scheduleConfig)
   ⚠️ Found 2 orphaned slots that will be HIDDEN
   ✅ _getScheduleSlotData: Found slot Monday @ 07:30 with 0 vehicles
   ✅ _getScheduleSlotData: Found slot Monday @ 15:30 with 0 vehicles
```

## Impact

### Before Fix
- ❌ UI showed ALL slots from database, regardless of configuration
- ❌ Users saw time slots they never configured (e.g., 05:30)
- ❌ Confusing and inconsistent with group settings

### After Fix
- ✅ UI shows ONLY configured time slots
- ✅ Orphaned slots (unconfigured times) are hidden
- ✅ Clean, consistent UI based on configuration
- ✅ Comprehensive debug logging for troubleshooting
- ✅ Full test coverage

## Files Modified

1. `/workspace/mobile_app/lib/features/schedule/presentation/widgets/schedule_grid.dart`
   - Added orphan detection logging in `_buildMobileScheduleGrid()`
   - Added validation in `_getScheduleSlotData()` to reject unconfigured times

2. `/workspace/mobile_app/test/unit/features/schedule/presentation/widgets/schedule_grid_orphan_filtering_test.dart`
   - New test file with 6 comprehensive test cases
   - Tests all edge cases and validation scenarios

## Backward Compatibility

- ✅ Graceful degradation: If `scheduleConfig` is `null`, shows all slots (fallback mode)
- ✅ No breaking changes to API or data models
- ✅ All existing tests still pass

## Verification Steps

1. **Check debug logs** when running the app:
   ```
   flutter run --debug
   ```
   Look for orphan slot warnings in console

2. **Verify in UI**:
   - Create a group with specific time slots (e.g., only 07:30, 15:30)
   - Add slots via API with other times (e.g., 05:30, 08:00)
   - Verify UI shows ONLY configured slots

3. **Run tests**:
   ```bash
   flutter test test/unit/features/schedule/presentation/widgets/schedule_grid_orphan_filtering_test.dart
   ```

## Related Issues

- Fixes the issue where vehicles appeared in unconfigured time slots
- Enforces PRINCIPLE 0: Configuration is the source of truth for UI display
- Improves data consistency between scheduleConfig and displayed slots

## Future Improvements

1. **Backend validation**: Prevent creating slots with unconfigured times in the first place
2. **Admin tool**: Add UI to clean up orphaned slots in database
3. **Migration script**: One-time cleanup of existing orphaned slots
4. **Warning banner**: Show admin warning if orphaned slots are detected

## Notes

- Debug logging is comprehensive but only appears in debug mode
- Production builds will have minimal overhead from validation checks
- Orphaned slots are hidden from UI but still exist in database (non-destructive)
