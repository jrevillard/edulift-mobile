# Timezone Verification Report: After `datetime` Field Migration

**Date**: 2025-10-12
**Status**: 🔴 **CRITICAL ISSUE FOUND**
**Priority**: P0 - CRITICAL USER-FACING BUG
**Component**: Schedule Display / DTO Parsing

---

## Executive Summary

### Migration Context
The codebase was migrated from using separate `day`/`time`/`week` fields to a single `datetime` field in `ScheduleSlotDto`:

**BEFORE**:
```dart
{
  "day": "Monday",
  "time": "08:00",
  "week": "2025-W41"
}
```

**AFTER**:
```dart
{
  "datetime": "2025-10-14T05:30:00.000Z"  // UTC ISO 8601
}
```

### Critical Finding
🚨 **The migration has introduced a CRITICAL timezone display bug**:
- **Creating slots works correctly** ✅ (Local → UTC conversion is correct)
- **Viewing slots shows wrong time** ❌ (UTC time displayed instead of local time)

### Impact
**Severity**: Critical
**User Impact**: Users see wrong times for ALL schedule slots
- Paris user creates slot at 08:00 → Slot displays as **06:00** ❌
- New York user creates slot at 08:00 → Slot displays as **13:00** ❌

---

## Detailed Analysis

### 1. API Response Timezone ✅ CORRECT

**Question**: Is `datetime` from API in UTC?
**Answer**: ✅ Yes, confirmed

```json
{
  "datetime": "2025-10-14T05:30:00.000Z"
}
```

The `.000Z` suffix indicates UTC timezone. Backend stores all times in UTC using PostgreSQL `TIMESTAMP WITH TIME ZONE`.

**Verification Test**:
```dart
final apiResponse = '2025-10-14T05:30:00.000Z';
final parsed = DateTime.parse(apiResponse);
expect(parsed.isUtc, true);  // ✅ PASSES
expect(parsed.hour, 5);      // ✅ PASSES (UTC hour)
```

---

### 2. DTO Parsing ✅ CORRECT

**File**: `/workspace/mobile_app/lib/core/network/models/schedule/schedule_slot_dto.dart`
**Line**: 13

```dart
datetime: DateTime.parse(json['datetime'] as String),
```

**Analysis**:
- `DateTime.parse()` preserves UTC timezone when input has 'Z' suffix
- The parsed DateTime object has `.isUtc == true`
- No unwanted `.toLocal()` conversion happening

**Verification Test**:
```dart
final json = {'datetime': '2025-10-14T05:30:00.000Z'};
final dto = ScheduleSlotDto.fromJson(json);
expect(dto.datetime.isUtc, true);  // ✅ PASSES
expect(dto.datetime.hour, 5);      // ✅ PASSES
```

**Status**: ✅ CORRECT - DTO parsing preserves UTC

---

### 3. Domain Conversion ❌ **CRITICAL BUG**

**File**: `/workspace/mobile_app/lib/core/network/models/schedule/schedule_slot_dto.dart`
**Lines**: 43-45

```dart
@override
ScheduleSlot toDomain() {
  // Convert backend datetime to TYPE-SAFE domain entities
  final weekNumber = _getWeekFromDateTime(datetime);
  final dayOfWeek = DayOfWeek.fromWeekday(datetime.weekday);
  final timeOfDay = TimeOfDayValue.fromDateTime(datetime);  // 🔴 BUG HERE

  return ScheduleSlot(
    dayOfWeek: dayOfWeek,
    timeOfDay: timeOfDay,  // Contains UTC time, not local!
    // ...
  );
}
```

**File**: `/workspace/mobile_app/lib/core/domain/entities/schedule/time_of_day.dart`
**Lines**: 66-69

```dart
factory TimeOfDayValue.fromDateTime(DateTime dateTime) {
  return TimeOfDayValue(dateTime.hour, dateTime.minute);
}
```

**The Problem**:
1. `datetime` is in UTC (e.g., 05:30 UTC)
2. `TimeOfDayValue.fromDateTime(datetime)` extracts UTC hour/minute
3. Domain model stores UTC time (05:30) instead of local time (07:30)
4. UI displays domain `timeOfDay` directly → **User sees 05:30 instead of 07:30** ❌

**Verification Test**:
```dart
// API returns 05:30 UTC (which is 07:30 Paris local)
final dto = ScheduleSlotDto(
  datetime: DateTime.parse('2025-10-14T05:30:00.000Z'),
);

final domain = dto.toDomain();

print('DTO datetime (UTC): ${dto.datetime.toIso8601String()}');  // 05:30 UTC
print('Domain timeOfDay: ${domain.timeOfDay}');                  // 05:30 🔴 WRONG

final local = dto.datetime.toLocal();
print('Should display: ${local.hour}:${local.minute}');          // 07:30 ✅ CORRECT
```

**Output**:
```
DTO datetime (UTC): 2025-10-14T05:30:00.000Z
Domain timeOfDay: 05:30  🔴 WRONG (UTC time)
Should display: 7:30     ✅ CORRECT (Local time)
```

**Status**: 🔴 **CRITICAL BUG** - Domain model stores UTC time instead of local time

---

### 4. Previous Timezone Fixes ✅ STILL WORKING

**File**: `/workspace/mobile_app/lib/features/schedule/data/repositories/handlers/basic_slot_operations_handler.dart`
**Lines**: 75-80

```dart
// Convert to UTC: Backend expects start of day (00:00 UTC) and end of day (23:59:59.999 UTC)
final startDateUtc = startDate != null
    ? DateTime.utc(startDate.year, startDate.month, startDate.day).toIso8601String()
    : null;
final endDateUtc = endDate != null
    ? DateTime.utc(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999).toIso8601String()
    : null;
```

**Analysis**:
- Week navigation date range fix is still working correctly
- `DateTime.utc()` is used correctly for calendar dates (year/month/day only)
- This is different from datetime with time components

**Status**: ✅ CORRECT - Week navigation still works

---

### 5. Creating Slots ✅ CORRECT

**File**: `/workspace/mobile_app/lib/features/schedule/data/repositories/handlers/vehicle_operations_handler.dart`
**Lines**: 84-95

```dart
// Build full datetime in local time, then convert to UTC
// User time selection is in local time (e.g., 07:30 Paris time)
// Backend expects UTC (e.g., 07:30 Paris → 05:30 UTC in winter, 06:30 UTC in summer)
final date = weekStart.add(Duration(days: dayOffset));
final localDateTime = DateTime(
  date.year,
  date.month,
  date.day,
  hour,
  minute,
);
return localDateTime.toUtc();
```

**Analysis**:
- User selects 08:00 local → Creates `DateTime(2025, 10, 14, 8, 0)` (local)
- Converts to UTC → `toUtc()` → `DateTime.utc(2025, 10, 14, 6, 0)` (UTC+2)
- Sends to API → `"2025-10-14T06:00:00.000Z"` ✅

**Status**: ✅ CORRECT - Creating slots converts local to UTC properly

---

### 6. Display to User 🔴 **CRITICAL BUG**

**File**: `/workspace/mobile_app/lib/features/schedule/presentation/widgets/schedule_grid.dart`
**Line**: 795

```dart
ScheduleSlot? _getScheduleSlotData(String day, String time) {
  return widget.scheduleData.firstWhere(
    (slot) => slot.dayOfWeek.fullName == day && slot.timeOfDay.toApiFormat() == time,
  );
}
```

**The Flow**:
1. User creates slot at 08:00 local (Paris UTC+2)
2. API stores: `"2025-10-14T06:00:00.000Z"` (06:00 UTC) ✅
3. API returns: `"2025-10-14T06:00:00.000Z"` ✅
4. DTO parses to UTC datetime ✅
5. **Domain extracts UTC time: 06:00** 🔴 **BUG**
6. **UI displays: 06:00** 🔴 **USER SEES WRONG TIME**

**Expected Flow**:
1. User creates slot at 08:00 local
2. API stores: `"2025-10-14T06:00:00.000Z"` (06:00 UTC) ✅
3. API returns: `"2025-10-14T06:00:00.000Z"` ✅
4. DTO parses to UTC datetime ✅
5. **Convert to local: 08:00** ✅
6. **UI displays: 08:00** ✅

**Status**: 🔴 **CRITICAL BUG** - UI displays UTC time instead of local time

---

## Test Scenarios

### Scenario 1: Paris User Creates 08:00 Slot ❌ FAILS

**Setup**: User in Paris (UTC+2)

| Step | Expected | Actual | Status |
|------|----------|--------|--------|
| User selects | 08:00 | 08:00 | ✅ |
| Local DateTime created | `2025-10-14 08:00` | `2025-10-14 08:00` | ✅ |
| Convert to UTC | `2025-10-14T06:00:00.000Z` | `2025-10-14T06:00:00.000Z` | ✅ |
| API receives | `06:00 UTC` | `06:00 UTC` | ✅ |
| API stores | `06:00 UTC` | `06:00 UTC` | ✅ |
| API returns | `06:00 UTC` | `06:00 UTC` | ✅ |
| DTO parsing | `06:00 UTC` | `06:00 UTC` | ✅ |
| Domain model | `08:00 local` | `06:00 UTC` | ❌ **BUG** |
| UI displays | `08:00` | `06:00` | ❌ **BUG** |

**Result**: ❌ User creates 08:00 but sees 06:00 (2 hours off!)

---

### Scenario 2: Week Navigation Date Range ✅ PASSES

**Setup**: User navigates to week 2025-W42

| Step | Expected | Actual | Status |
|------|----------|--------|--------|
| Parse week | Monday Oct 13 | Monday Oct 13 | ✅ |
| Start date UTC | `2025-10-13T00:00:00.000Z` | `2025-10-13T00:00:00.000Z` | ✅ |
| End date UTC | `2025-10-19T23:59:59.999Z` | `2025-10-19T23:59:59.999Z` | ✅ |
| API query | Correct range | Correct range | ✅ |

**Result**: ✅ Week navigation works correctly

---

### Scenario 3: Cross-Timezone Collaboration ❌ FAILS

**Setup**:
- User A (Paris UTC+2) creates slot at 08:00
- User B (New York UTC-5) views same slot

| User | Expected Display | Actual Display | Status |
|------|------------------|----------------|--------|
| User A (Paris) | 08:00 | 06:00 | ❌ |
| User B (New York) | 08:00 | 06:00 | ❌ |

**Analysis**:
- Both users see 06:00 (UTC time)
- Should both see their local equivalent of the same UTC time
- Current implementation shows raw UTC, not converted to local

**Result**: ❌ Both users see wrong time

---

## Root Cause Analysis

### The Core Issue

**Old Architecture** (day/time/week fields):
```dart
// API returned time as STRING
"time": "08:00"

// Domain stored time as STRING
TimeOfDayValue.parse("08:00") → 08:00

// Timezone context was IMPLICIT (assumed local)
// This "worked" because there was no timezone conversion
```

**New Architecture** (datetime field):
```dart
// API returns time as UTC DATETIME
"datetime": "2025-10-14T06:00:00.000Z"

// Domain extracts TIME from UTC DATETIME
TimeOfDayValue.fromDateTime(utc) → 06:00 UTC  // 🔴 WRONG

// Timezone context is EXPLICIT (UTC)
// But we're extracting UTC time instead of converting to local!
```

### Why It's Wrong

The `TimeOfDayValue` domain model is **timezone-naive**:
- It only stores `hour` and `minute` (no timezone)
- It doesn't know if those values are UTC or local
- The UI assumes values are in local time

When we do `TimeOfDayValue.fromDateTime(utcDateTime)`, we're:
1. Taking a UTC datetime (06:00 UTC)
2. Extracting its hour/minute (6, 0)
3. Storing in timezone-naive value object
4. Displaying to user as if it were local → **User sees 06:00 instead of 08:00**

---

## The Fix

### Option A: Convert to Local in toDomain() 🟢 **RECOMMENDED**

**Location**: `schedule_slot_dto.dart:45`

```dart
@override
ScheduleSlot toDomain() {
  final now = DateTime.now();

  // Convert UTC datetime to local for domain model
  final localDatetime = datetime.toLocal();  // ✅ FIX: Convert to local

  // Extract components from local time
  final weekNumber = _getWeekFromDateTime(localDatetime);  // Use local
  final dayOfWeek = DayOfWeek.fromWeekday(localDatetime.weekday);  // Use local
  final timeOfDay = TimeOfDayValue.fromDateTime(localDatetime);  // ✅ FIX: Extract local time

  return ScheduleSlot(
    dayOfWeek: dayOfWeek,
    timeOfDay: timeOfDay,  // Now contains local time
    week: weekNumber,
    // ...
  );
}
```

**Pros**:
- ✅ Minimal change (1 line)
- ✅ Domain model remains timezone-naive (simpler)
- ✅ UI code doesn't need to change
- ✅ All existing code continues to work

**Cons**:
- ⚠️ Domain model loses UTC information
- ⚠️ Need to recalculate UTC when sending updates

---

### Option B: Store UTC in Domain, Convert in UI 🟡 Alternative

**Location**: Multiple files

**Changes Required**:
1. Domain model stores UTC time
2. UI converts UTC to local for display
3. Update all display logic

**Pros**:
- ✅ Domain model preserves UTC (more accurate)
- ✅ Can show times in any timezone (future feature)

**Cons**:
- ⚠️ More code changes required
- ⚠️ Higher risk of introducing bugs
- ⚠️ UI must remember to convert everywhere

---

### Recommended Approach: Option A

**Rationale**:
1. The domain model (`ScheduleSlot`) represents a *logical* schedule slot, not a *physical* timestamp
2. Users think of slots as "Tuesday 08:00" not "Tuesday 06:00 UTC"
3. The UI already treats `timeOfDay` as local time
4. Converting at the DTO boundary is the safest approach

---

## Implementation Plan

### Phase 1: Fix the Bug (Immediate) - 2 hours

1. **Update `schedule_slot_dto.dart:toDomain()`**:
   ```dart
   final localDatetime = datetime.toLocal();
   final timeOfDay = TimeOfDayValue.fromDateTime(localDatetime);
   ```

2. **Add unit test**:
   ```dart
   test('toDomain extracts local time from UTC datetime', () {
     // API returns 06:00 UTC
     final dto = ScheduleSlotDto(
       datetime: DateTime.parse('2025-10-14T06:00:00.000Z'),
     );

     final domain = dto.toDomain();

     // In Paris UTC+2, user should see 08:00
     final localDateTime = dto.datetime.toLocal();
     expect(domain.timeOfDay.hour, localDateTime.hour);
     expect(domain.timeOfDay.minute, localDateTime.minute);
   });
   ```

3. **Run full test suite**:
   ```bash
   flutter test
   flutter test test/unit/domain/schedule/
   flutter test test/unit/presentation/widgets/schedule_grid_test.dart
   ```

4. **Manual testing** (different timezones):
   - Paris UTC+2: Create 08:00 → Should display 08:00 ✅
   - New York UTC-5: Create 08:00 → Should display 08:00 ✅

### Phase 2: Update Documentation (1 hour)

1. Update `TIMEZONE_HANDLING_ADR.md`
2. Document the fix in `TIMEZONE_FIX_VERIFICATION_REPORT.md`
3. Add comments in code explaining timezone handling

### Phase 3: Edge Case Testing (1 hour)

1. Test DST transition dates
2. Test midnight/end-of-day times
3. Test cross-timezone collaboration

---

## Success Criteria

| Criterion | Expected | Status |
|-----------|----------|--------|
| API datetime is UTC | ✅ Yes | ✅ PASS |
| DTO parsing preserves UTC | ✅ Yes | ✅ PASS |
| Domain conversion to local | ✅ Yes | ❌ **FAIL** |
| UI displays local time | ✅ Yes | ❌ **FAIL** |
| Week navigation works | ✅ Yes | ✅ PASS |
| Creating slots works | ✅ Yes | ✅ PASS |
| No regression from previous fixes | ✅ Yes | ✅ PASS |

**Overall Status**: 🔴 **2/7 CRITICAL FAILURES**

---

## Conclusion

### Summary

The migration from `day/time/week` to `datetime` field was **partially successful**:

✅ **What Works**:
- API timezone handling (UTC storage) ✅
- DTO parsing (preserves UTC) ✅
- Creating slots (local → UTC conversion) ✅
- Week navigation (date range queries) ✅

❌ **What's Broken**:
- Domain model stores UTC time instead of local time ❌
- UI displays UTC time instead of local time ❌

### Impact

**Severity**: 🔴 CRITICAL
**User Impact**: ALL users see incorrect times for ALL slots
**Data Integrity**: ✅ No data corruption (API stores correct UTC)
**Fix Complexity**: 🟢 Low (1 line change + tests)

### Recommendation

**Action**: Implement Option A (Convert to local in `toDomain()`)
**Timeline**: 4 hours (2h fix + 1h docs + 1h testing)
**Risk**: 🟢 Low (minimal code change, no API changes)
**Priority**: 🔴 P0 - Fix immediately before release

---

## Appendix: Test Results

### Test 1: DateTime.parse Preserves UTC ✅
```
✅ Parsing preserves UTC: 2025-10-14T05:30:00.000Z -> 2025-10-14T05:30:00.000Z
```

### Test 2: Local to UTC Conversion ✅
```
Local: 2025-10-14T08:00:00.000
UTC:   2025-10-14T06:00:00.000Z
Offset: 2 hours
✅ PASS
```

### Test 3: DTO Parsing ✅
```
Input datetime (UTC): 2025-10-14T05:30:00.000Z
Parsed datetime: 2025-10-14T05:30:00.000Z
Is UTC: true
Hour: 5, Minute: 30
✅ PASS
```

### Test 4: Domain Conversion ❌ **BUG CONFIRMED**
```
DTO datetime (UTC): 2025-10-14T05:30:00.000Z
Domain time: 05:30
User expects to see: 7:30
⚠️ WARNING: Domain time (05:30) != Local time (7:30)
❌ FAIL - BUG CONFIRMED
```

### Test 5: Week Navigation ✅
```
Week: 2025-W42
Start (UTC): 2025-10-13T00:00:00.000Z
End (UTC): 2025-10-19T23:59:59.999Z
✅ PASS
```

---

**Report Generated**: 2025-10-12
**Auditor**: Code Analyzer Agent
**Next Steps**: Implement fix in Phase 1 (Option A)
