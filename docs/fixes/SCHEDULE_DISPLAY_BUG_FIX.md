# Schedule Display Bug Fix

## Bug Summary
**Symptom**: Schedule slots not displaying in UI despite API returning valid data
**Root Cause**: Case mismatch between UI day keys and domain entity day names
**Status**: FIXED ✅
**Date**: 2025-10-12

---

## Problem Description

### Symptoms
- API returns 2 valid schedule slots (confirmed via logs)
- DTO deserialization succeeds
- Domain conversion succeeds
- Provider receives slots correctly
- **BUT**: UI shows empty schedule (no slots visible)

### API Response (Working Correctly)
```json
{
  "scheduleSlots": [
    {
      "id": "cmgo1nrje000xozw6r96szv1g",
      "datetime": "2025-10-14T05:30:00.000Z",
      "vehicleAssignments": [...]
    },
    {
      "id": "cmgnfqmcp000lozw6hkuqtwzc",
      "datetime": "2025-10-17T13:30:00.000Z",
      "vehicleAssignments": [...]
    }
  ]
}
```

---

## Root Cause Analysis

### Data Flow Trace

1. **API → Handler**: ✅ Working
   - API returns datetime: `"2025-10-14T05:30:00.000Z"` (Tuesday 05:30)
   - Handler receives response correctly

2. **DTO → Domain**: ✅ Working
   - `ScheduleSlotDto.toDomain()` converts datetime to:
     - `dayOfWeek: DayOfWeek.tuesday` (enum)
     - `dayOfWeek.fullName: "Tuesday"` (Title Case)
     - `timeOfDay: TimeOfDayValue(5, 30)`
     - `week: "2025-W42"`

3. **Provider → UI**: ✅ Working
   - Provider passes List<ScheduleSlot> to ScheduleGrid
   - Slots arrive with correct data

4. **UI Slot Lookup**: ❌ **BROKEN HERE**
   - ScheduleGrid uses constant keys: `'MONDAY'`, `'TUESDAY'` (UPPERCASE)
   - `_getScheduleSlotData()` searches for slots using:
     ```dart
     slot.dayOfWeek.fullName == day
     // "Tuesday" == "TUESDAY" → false (case mismatch!)
     ```

### The Bug

**File**: `/workspace/mobile_app/lib/features/schedule/presentation/widgets/schedule_grid.dart`

**Line 389-397**: Defines day keys as UPPERCASE constants
```dart
final allDays = [
  'MONDAY',    // ← UPPERCASE
  'TUESDAY',
  'WEDNESDAY',
  // ...
];
```

**Line 802-803**: Compares UPPERCASE key with Title Case property
```dart
widget.scheduleData.firstWhere(
  (slot) => slot.dayOfWeek.fullName == day,  // "Tuesday" != "TUESDAY"
);
```

**File**: `/workspace/mobile_app/lib/core/domain/entities/schedule/day_of_week.dart`

**Line 6-12**: Defines fullName as Title Case
```dart
enum DayOfWeek {
  monday(1, 'Monday', 'Mon'),      // ← Title Case
  tuesday(2, 'Tuesday', 'Tue'),
  wednesday(3, 'Wednesday', 'Wed'),
  // ...
}
```

---

## Solution

### Option A: Convert UPPERCASE Constants to Title Case (CHOSEN)

**Rationale**:
- DayOfWeek enum is used throughout the codebase
- Changing enum would require updating all domain code
- UI layer should adapt to domain layer (Clean Architecture)
- Backend accepts both formats

**Changes**:
1. Update ScheduleGrid day constants to Title Case
2. Update _getDayOffset() to handle Title Case
3. Update any other UI code using day constants

### Implementation

**File**: `schedule_grid.dart`

```dart
// BEFORE (BROKEN)
final allDays = [
  'MONDAY',
  'TUESDAY',
  'WEDNESDAY',
  'THURSDAY',
  'FRIDAY',
  'SATURDAY',
  'SUNDAY',
];

// AFTER (FIXED)
final allDays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
```

**File**: `schedule_grid.dart` - `_getDayOffset()`

```dart
// BEFORE (BROKEN)
int _getDayOffset(String day) {
  switch (day.toUpperCase()) {  // ← Forced uppercase
    case 'MONDAY': return 0;
    case 'TUESDAY': return 1;
    // ...
  }
}

// AFTER (FIXED)
int _getDayOffset(String day) {
  switch (day) {  // ← Direct comparison
    case 'Monday': return 0;
    case 'Tuesday': return 1;
    case 'Wednesday': return 2;
    case 'Thursday': return 3;
    case 'Friday': return 4;
    case 'Saturday': return 5;
    case 'Sunday': return 6;
    default: return 0;
  }
}
```

---

## Testing

### Before Fix
```
🔍 [ScheduleGrid._buildMobileScheduleGrid] Building grid with 2 schedule slots
🔍 [ScheduleGrid._buildMobileScheduleGrid] Week: 2025-W42
  - Slot: day=Tuesday, time=05:30, week=2025-W42
  - Slot: day=Friday, time=13:30, week=2025-W42
🔍 [ScheduleGrid._buildMobileScheduleGrid] Filtered days to show: [MONDAY, TUESDAY, WEDNESDAY, ...]
⚠️ [ScheduleGrid._getScheduleSlotData] No slot found for day=TUESDAY, time=05:30
⚠️ [ScheduleGrid._getScheduleSlotData] No slot found for day=FRIDAY, time=13:30
```

### After Fix
```
🔍 [ScheduleGrid._buildMobileScheduleGrid] Building grid with 2 schedule slots
🔍 [ScheduleGrid._buildMobileScheduleGrid] Week: 2025-W42
  - Slot: day=Tuesday, time=05:30, week=2025-W42
  - Slot: day=Friday, time=13:30, week=2025-W42
🔍 [ScheduleGrid._buildMobileScheduleGrid] Filtered days to show: [Monday, Tuesday, Wednesday, ...]
✅ [ScheduleGrid._getScheduleSlotData] Found slot for day=Tuesday, time=05:30: id=cmgo1nrje000xozw6r96szv1g
✅ [ScheduleGrid._getScheduleSlotData] Found slot for day=Friday, time=13:30: id=cmgnfqmcp000lozw6hkuqtwzc
```

---

## Prevention

### Why This Happened
1. No type safety for day constants (using strings instead of enum)
2. UI layer used different convention than domain layer
3. No integration test covering slot display

### Recommendations
1. **Use DayOfWeek enum directly in UI** instead of string constants
2. **Add integration test** that verifies slots display correctly
3. **Add compile-time validation** where possible
4. **Document day format conventions** in architecture docs

---

## Related Files
- `/workspace/mobile_app/lib/features/schedule/presentation/widgets/schedule_grid.dart` (UI)
- `/workspace/mobile_app/lib/core/domain/entities/schedule/day_of_week.dart` (Domain)
- `/workspace/mobile_app/lib/core/network/models/schedule/schedule_slot_dto.dart` (DTO)

---

## Impact
- **Severity**: CRITICAL (complete feature failure)
- **Scope**: All schedule display features
- **User Impact**: Users couldn't see any schedule slots
- **Data Loss**: None (data was correct, only display was broken)
