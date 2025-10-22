# Week Navigation Rebuild - Simple & Bulletproof

**Date:** 2025-10-13
**Status:** ✅ Complete
**Tests:** 14/14 passing

## Problem

Week navigation was "doing n'importe quoi" (acting randomly) due to complex offset tracking logic:

1. **Offset confusion**: Tracked `_currentWeekOffset` relative to page 1000, but this didn't directly map to actual weeks
2. **Date picker bug**: Used `widget.week` for calculations but `_currentWeekOffset` for state, causing misalignment
3. **Unpredictable behavior**: Users experienced week skipping, especially after using the date picker

## Solution: Dead Simple Week Tracking

### Core Change: Track Week Strings Directly

**Before (Complex):**
```dart
int _currentWeekOffset = 0;  // Offset from... what exactly?
```

**After (Simple):**
```dart
String _currentDisplayedWeek = widget.week;  // Exactly what it says!
```

### Key Improvements

#### 1. Simple PageView Navigation

**Before:**
```dart
onPageChanged: (page) {
  final newOffset = page - 1000;
  setState(() => _currentWeekOffset = newOffset);
  widget.onWeekChanged?.call(newOffset);
}
```

**After:**
```dart
onPageChanged: (page) {
  final pageOffset = page - 1000;
  final initialWeek = widget.week;
  final newWeek = addWeeksToISOWeek(initialWeek, pageOffset);

  setState(() => _currentDisplayedWeek = newWeek);

  final weekOffset = weeksBetween(widget.week, newWeek);
  widget.onWeekChanged?.call(weekOffset);
}
```

**Why it's better:**
- Directly calculates the actual week being displayed
- No ambiguity about what offset means
- Every page has a clear week string

#### 2. Fixed Date Picker Calculation

**Before (BUGGY):**
```dart
// Used widget.week but calculated from _currentWeekOffset
final currentWeekMonday = parseMondayFromISOWeek(widget.week);
// ...
final weeksDiff = weeksBetween(widget.week, selectedWeekString);
final targetWeekOffset = _currentWeekOffset + weeksDiff;  // ⚠️ WRONG!
```

**After (CORRECT):**
```dart
// Use the currently displayed week for date picker
final currentWeekMonday = parseMondayFromISOWeek(_currentDisplayedWeek);
// ...
// Always calculate from initial week
final targetPageOffset = weeksBetween(widget.week, selectedWeekString);
_weekPageController.jumpToPage(1000 + targetPageOffset);
```

**Why it's better:**
- Date picker shows the actual displayed week
- Calculation is always from a known reference (widget.week)
- No accumulation of offset errors

#### 3. Simplified Week Date Range

**Before:**
```dart
({DateTime monday, DateTime sunday})? _getWeekDateRange(int weekOffset) {
  final monday = parseMondayFromISOWeek(widget.week);
  final targetMonday = monday.add(Duration(days: weekOffset * 7));
  // ...
}
```

**After:**
```dart
({DateTime monday, DateTime sunday})? _getWeekDateRange(String weekString) {
  final monday = parseMondayFromISOWeek(weekString);
  final sunday = monday.add(const Duration(days: 6));
  return (monday: monday, sunday: sunday);
}
```

**Why it's better:**
- Direct week string to dates conversion
- No offset math needed
- Works with any week string

## The Math: How It Works

### Page Navigation Math

```
Page Number = 1000 + weeks from initial week
```

**Example:**
- Initial week: `2025-W10` (widget.week)
- User clicks "next" 3 times → Page 1003
- onPageChanged calculates: `addWeeksToISOWeek("2025-W10", 3)` → `"2025-W13"` ✓

### Date Picker Math

```
Target Page = 1000 + weeksBetween(initial week, selected week)
```

**Example:**
- Initial week: `2025-W10`
- Currently displayed: `2025-W15` (after navigating)
- User selects date in `2025-W20`
- Jump to: `1000 + weeksBetween(W10, W20)` = `1000 + 10` = `1010`
- onPageChanged calculates: `addWeeksToISOWeek("2025-W10", 10)` → `"2025-W20"` ✓

## Testing

All 14 tests pass, covering:

### Basic Navigation
- ✅ Forward navigation (click next 5 times)
- ✅ Backward navigation (click previous 5 times)
- ✅ Mixed forward/backward patterns

### Edge Cases
- ✅ Year boundaries (Week 52 → Week 1)
- ✅ Week 53 handling (years with 53 weeks)
- ✅ DST transitions

### Date Picker
- ✅ Jump from displayed week
- ✅ Jump far from initial week
- ✅ Backward jumps

## Benefits

### 1. Predictability
**Before:** Click next 10 times → might end up at week 11 or 12 (random)
**After:** Click next 10 times → exactly 10 weeks forward (boring, but correct!)

### 2. Simplicity
- No complex offset tracking
- Direct week string manipulation
- Easy to debug

### 3. Correctness
- No week skipping
- Date picker always shows correct week
- Math is always from a known reference point

## Key Insight

**The core issue was mixing two reference frames:**
- Widget used `widget.week` (initial week) for data loading
- State tracked `_currentWeekOffset` (relative to page 1000)
- Date picker mixed both

**The fix: One source of truth**
- Pages are numbered relative to page 1000
- All calculations use `widget.week` as reference
- `_currentDisplayedWeek` is just for display/state, not calculations

## Files Changed

1. **`lib/features/schedule/presentation/widgets/schedule_grid.dart`**
   - Added `_currentDisplayedWeek` state
   - Simplified `onPageChanged` logic
   - Fixed `_showDatePicker` calculation
   - Updated `_getWeekDateRange` signature
   - Updated `_isTimeSlotInPast` to use displayed week

2. **`test/unit/features/schedule/week_navigation_test.dart`**
   - Replaced bug reproduction tests with fixed implementation tests
   - Added 3 new date picker navigation tests
   - All 14 tests passing

## Utilities Used (No Changes Needed)

The ISO week utilities in `lib/features/schedule/utils/iso_week_utils.dart` were **already correct**:
- ✅ `getISOWeekString(DateTime)` - Convert date to week string
- ✅ `parseMondayFromISOWeek(String)` - Convert week string to Monday
- ✅ `addWeeksToISOWeek(String, int)` - Add weeks to week string
- ✅ `weeksBetween(String, String)` - Calculate week difference

## Conclusion

**Mission accomplished:** Week navigation is now DEAD SIMPLE and PREDICTABLE.

No clever tricks. No complex state. Just straightforward date arithmetic.

**Result:** Boring, reliable navigation that does exactly what users expect.
