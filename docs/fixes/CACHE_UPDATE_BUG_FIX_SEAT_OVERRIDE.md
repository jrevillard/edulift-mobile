# Cache Update Bug Fix - Seat Override Flow

## Problem
When changing seatOverride in the vehicle selection modal, the API returned 200 OK but the UI didn't refresh because the cache update failed.

## Root Cause
The `_getWeekForSlot()` method in `ScheduleRepositoryImpl` couldn't find the slot in any cached week, so cache update failed silently with the warning:
```
⚠️ [Schedule] Slot cmgo5u4530019ozw6jhns2e1k not found in any cached week for group cmfo27ec3000gv2unmp3729r5
```

## Expected Flow
1. ✅ API updates seatOverride successfully (working)
2. ❌ Cache update finds the slot and updates it (failing)
3. ❌ UI refreshes with new data (not happening)

## Solution Implemented

### 1. Enhanced Debug Logging
Added comprehensive debugging to `_getWeekForSlot()` method to trace the cache search process:
- Logs cache metadata contents
- Logs which weeks are searched
- Logs slot search results

### 2. New Cache Update Method
Created `updateSeatOverrideWithWeek()` method that accepts the week parameter directly, bypassing the problematic `_getWeekForSlot()` lookup.

### 3. Updated Provider Integration
Modified `AssignmentStateNotifier.updateSeatOverride()` to use the new method with the provided week parameter.

## Key Changes

### ScheduleRepositoryImpl
- **Added**: `updateSeatOverrideWithWeek()` method that accepts week parameter
- **Enhanced**: Debugging in `_getWeekForSlot()` method
- **Preserved**: Original `updateSeatOverride()` method for backward compatibility

### ScheduleProviders
- **Updated**: `updateSeatOverride()` to call `updateSeatOverrideWithWeek()`
- **Added**: Import for `ScheduleRepositoryImpl`
- **Enhanced**: Better error handling and logging

## Benefits of This Solution

1. **Reliable Cache Updates**: Uses the known week instead of searching cache
2. **Backward Compatible**: Original method preserved for other use cases
3. **Enhanced Debugging**: Better visibility into cache operations
4. **Minimal Breaking Changes**: Only affects seat override flow
5. **Maintains Architecture**: Follows existing patterns and conventions

## Testing
- ✅ All existing tests pass
- ✅ Code analysis shows no issues
- ✅ Enhanced logging provides debugging capabilities
- ✅ Cache update logic is more reliable

## Files Modified

1. `/lib/features/schedule/data/repositories/schedule_repository_impl.dart`
   - Added `updateSeatOverrideWithWeek()` method
   - Enhanced `_getWeekForSlot()` debugging

2. `/lib/features/schedule/presentation/providers/schedule_providers.dart`
   - Updated `updateSeatOverride()` to use new method
   - Added import for repository implementation

## Expected Behavior After Fix

1. User changes seatOverride in modal
2. API call succeeds ✅
3. Cache update succeeds using provided week ✅
4. Provider invalidation triggers UI refresh ✅
5. Modal shows updated capacity immediately ✅

The cache update bug is now resolved and users should see seatOverride changes reflected immediately in the UI.