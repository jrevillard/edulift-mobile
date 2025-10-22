# 🚨 CRITICAL: Timezone Display Bug After DateTime Migration

**Status**: 🔴 CRITICAL BUG FOUND
**Date**: 2025-10-12
**Priority**: P0 - Fix before release

---

## The Bug

**Symptom**: Users see incorrect times for schedule slots

**Example**:
- User in Paris creates slot at **08:00**
- User views schedule and sees **06:00** ❌
- Expected: Should see **08:00** ✅

---

## Root Cause

**Location**: `/workspace/mobile_app/lib/core/network/models/schedule/schedule_slot_dto.dart:45`

```dart
// 🔴 BUG: Extracts UTC time instead of local time
final timeOfDay = TimeOfDayValue.fromDateTime(datetime);  // datetime is UTC
```

**Problem**:
- API returns `"2025-10-14T06:00:00.000Z"` (06:00 UTC = 08:00 Paris)
- Code extracts **06:00** (UTC hour) instead of converting to **08:00** (local hour)
- UI displays **06:00** to user ❌

---

## The Fix

**Change ONE line in `schedule_slot_dto.dart`**:

```dart
// ❌ BEFORE (WRONG):
final timeOfDay = TimeOfDayValue.fromDateTime(datetime);

// ✅ AFTER (CORRECT):
final timeOfDay = TimeOfDayValue.fromDateTime(datetime.toLocal());
```

**Full method**:
```dart
@override
ScheduleSlot toDomain() {
  final now = DateTime.now();

  // ✅ FIX: Convert UTC to local time before extracting components
  final localDatetime = datetime.toLocal();

  // Extract components from LOCAL time (not UTC)
  final weekNumber = _getWeekFromDateTime(localDatetime);
  final dayOfWeek = DayOfWeek.fromWeekday(localDatetime.weekday);
  final timeOfDay = TimeOfDayValue.fromDateTime(localDatetime);

  return ScheduleSlot(
    id: id,
    groupId: groupId,
    dayOfWeek: dayOfWeek,
    timeOfDay: timeOfDay,  // Now contains local time ✅
    week: weekNumber,
    // ...
  );
}
```

---

## Verification

**Before fix**:
```dart
API returns: "2025-10-14T06:00:00.000Z" (06:00 UTC)
Domain timeOfDay: 06:00 ❌
User sees: 06:00 ❌ (WRONG - should be 08:00 in Paris)
```

**After fix**:
```dart
API returns: "2025-10-14T06:00:00.000Z" (06:00 UTC)
Local conversion: 08:00 (Paris UTC+2)
Domain timeOfDay: 08:00 ✅
User sees: 08:00 ✅ (CORRECT)
```

---

## Impact

**Severity**: 🔴 CRITICAL
- **100% of users** see wrong times
- **No data corruption** (API stores correct UTC)
- **Fix complexity**: 🟢 Low (1 line)
- **Fix time**: ⚡ 30 minutes (1 line + tests)

---

## Testing Checklist

After applying fix:

- [ ] **Paris user (UTC+2)**: Create 08:00 → Displays 08:00 ✅
- [ ] **New York user (UTC-5)**: Create 08:00 → Displays 08:00 ✅
- [ ] **London user (UTC+0)**: Create 08:00 → Displays 08:00 ✅
- [ ] **Morning slot**: 07:00 displays correctly ✅
- [ ] **Afternoon slot**: 14:00 displays correctly ✅
- [ ] **Evening slot**: 18:30 displays correctly ✅
- [ ] **Week navigation**: Still works ✅
- [ ] **Creating slots**: Still works ✅
- [ ] **Unit tests**: All pass ✅

---

## Files to Modify

1. **Fix the bug**:
   - `/workspace/mobile_app/lib/core/network/models/schedule/schedule_slot_dto.dart` (line 45)

2. **Add test**:
   - `/workspace/mobile_app/test/unit/domain/schedule/entities/schedule_slot_dto_test.dart`

3. **Update docs**:
   - `/workspace/mobile_app/docs/TIMEZONE_VERIFICATION_AFTER_DATETIME_MIGRATION.md` (already created)

---

## Related Files (No Changes Needed)

These files are working correctly:
- ✅ `vehicle_operations_handler.dart` - Creating slots works
- ✅ `basic_slot_operations_handler.dart` - Week navigation works
- ✅ `time_of_day.dart` - TimeOfDayValue class is correct
- ✅ `schedule_grid.dart` - UI display logic is correct

---

## Command to Apply Fix

```bash
cd /workspace/mobile_app

# 1. Edit the file (line 45)
# Change:    final timeOfDay = TimeOfDayValue.fromDateTime(datetime);
# To:        final timeOfDay = TimeOfDayValue.fromDateTime(datetime.toLocal());

# 2. Also update line 43 and 44:
# Change:    final weekNumber = _getWeekFromDateTime(datetime);
#            final dayOfWeek = DayOfWeek.fromWeekday(datetime.weekday);
# To:        final localDatetime = datetime.toLocal();
#            final weekNumber = _getWeekFromDateTime(localDatetime);
#            final dayOfWeek = DayOfWeek.fromWeekday(localDatetime.weekday);

# 3. Run tests
flutter test test/unit/domain/schedule/
flutter test test/unit/presentation/widgets/schedule_grid_test.dart

# 4. Run full test suite
flutter test
```

---

## Additional Context

**Why creating slots works but viewing doesn't**:
- **Creating**: Starts with local time (08:00) → Converts to UTC (06:00) → API ✅
- **Viewing**: Starts with UTC time (06:00) → Should convert to local (08:00) → UI ❌

**Why this bug was introduced**:
- Old code used string times (`"08:00"`) with implicit timezone (local)
- New code uses DateTime objects with explicit timezone (UTC)
- Forgot to convert UTC → local when extracting time components

**Why previous fixes still work**:
- Previous fix converted local dates to UTC for API queries (still working ✅)
- This fix converts UTC dates back to local for display (broken ❌)

---

## Timeline

- **Discovery**: 2025-10-12 (during timezone audit)
- **Fix estimate**: 30 minutes
- **Testing estimate**: 1 hour
- **Total time**: 1.5 hours
- **Priority**: 🔴 P0 - Block release until fixed

---

For full technical details, see:
📄 `/workspace/mobile_app/docs/TIMEZONE_VERIFICATION_AFTER_DATETIME_MIGRATION.md`
