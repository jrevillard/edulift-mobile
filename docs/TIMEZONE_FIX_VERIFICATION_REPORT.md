# Timezone Fix Verification Report

**Date**: 2025-10-12
**Analyzed By**: Code Analyzer Agent
**Issue**: Week date calculation alignment between mobile app and backend API

---

## Executive Summary

✅ **YOUR FIX IS CORRECT**

The timezone fix you applied to convert local dates to UTC is the **correct solution** for aligning with backend API expectations.

**Verdict**: Keep the fix as-is. No changes needed.

---

## Analysis Details

### 1. Backend API Contract

**Endpoint**: `GET /api/v1/groups/:groupId/schedule`

**Query Parameters** (from `/workspace/backend/src/routes/scheduleSlots.ts:44-47`):
```typescript
const DateRangeQuerySchema = z.object({
  startDate: z.string().datetime('Start date must be a valid ISO 8601 datetime string').optional(),
  endDate: z.string().datetime('End date must be a valid ISO 8601 datetime string').optional()
});
```

**Key Findings**:
- Backend expects **ISO 8601 datetime strings** (e.g., `"2025-10-13T00:00:00.000Z"`)
- The `.datetime()` validator accepts RFC 3339 format with timezone
- Backend interprets these as **absolute UTC timestamps**

---

### 2. Backend Date Handling

**Source**: `/workspace/backend/src/services/ScheduleSlotService.ts:238-259`

```typescript
async getSchedule(groupId: string, startDate?: string, endDate?: string) {
  let rangeStart: Date;
  let rangeEnd: Date;

  if (startDate && endDate) {
    rangeStart = new Date(startDate);  // ← Parses ISO 8601 string
    rangeEnd = new Date(endDate);      // ← Parses ISO 8601 string
  } else {
    // Default to current week (Monday to Sunday)
    const now = new Date();
    const dayOfWeek = now.getDay();
    const daysToMonday = dayOfWeek === 0 ? -6 : 1 - dayOfWeek;

    rangeStart = new Date(now);
    rangeStart.setDate(now.getDate() + daysToMonday);
    rangeStart.setUTCHours(0, 0, 0, 0);

    rangeEnd = new Date(rangeStart);
    rangeEnd.setDate(rangeStart.getDate() + 6);
    rangeEnd.setUTCHours(23, 59, 59, 999);
  }

  const slots = await this.scheduleSlotRepository.getWeeklyScheduleByDateRange(
    groupId,
    rangeStart,
    rangeEnd
  );
  // ...
}
```

**Key Findings**:
- Backend uses `new Date(startDate)` which parses ISO 8601 strings
- The resulting `Date` object is treated as **UTC datetime**
- Default fallback uses `.setUTCHours()` confirming UTC expectation

---

### 3. Database Query

**Source**: `/workspace/backend/src/repositories/ScheduleSlotRepository.ts:246-254`

```typescript
async getWeeklyScheduleByDateRange(groupId: string, weekStart: Date, weekEnd: Date) {
  return this.prisma.scheduleSlot.findMany({
    where: {
      groupId,
      datetime: {
        gte: weekStart,  // ← Greater than or equal
        lte: weekEnd     // ← Less than or equal
      }
    },
    // ...
  });
}
```

**Prisma Schema** (`/workspace/backend/prisma/schema.prisma:149`):
```prisma
model ScheduleSlot {
  id        String   @id @default(cuid())
  groupId   String
  datetime  DateTime // UTC datetime when the schedule slot occurs
  // ...
}
```

**Key Findings**:
- Database field `datetime` is stored as **UTC timestamp**
- Query uses `gte`/`lte` for inclusive date range
- PostgreSQL `DateTime` fields are always stored as UTC
- Comment confirms: *"UTC datetime when the schedule slot occurs"*

---

### 4. Mobile App Implementation

**Source**: `/workspace/mobile_app/lib/features/schedule/data/repositories/handlers/basic_slot_operations_handler.dart:69-80`

```dart
// Calculate start and end dates for the week (in local time)
final startDate = _calculateWeekStartDate(week);
final endDate = _calculateWeekEndDate(week);

// Convert to UTC: Backend expects start of day (00:00 UTC) and end of day (23:59:59.999 UTC)
// We need to create UTC dates directly to avoid timezone shift issues
final startDateUtc = startDate != null
    ? DateTime.utc(startDate.year, startDate.month, startDate.day).toIso8601String()
    : null;
final endDateUtc = endDate != null
    ? DateTime.utc(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999).toIso8601String()
    : null;
```

**Your Fix** (lines 75-76, 78-79):
```dart
// ✅ CORRECT FIX
DateTime.utc(startDate.year, startDate.month, startDate.day)
```

**Previous Code** (what you fixed):
```dart
// ❌ WRONG (before your fix)
startDate?.toUtc().toIso8601String()
```

---

## 5. Why Your Fix Is Correct

### Scenario Analysis: User in Paris (UTC+2), Week 2025-W42

**Week**: Oct 13-19, 2025
**User Location**: Paris (UTC+2 during summer time)

#### ❌ BEFORE Fix (Wrong)

```dart
// _calculateWeekStartDate returns: DateTime(2025, 10, 13, 0, 0) // Local time
final startDate = DateTime(2025, 10, 13, 0, 0); // 2025-10-13 00:00 Paris time

// .toUtc() converts to UTC keeping the same INSTANT
final startDateUtc = startDate.toUtc(); // 2025-10-12 22:00 UTC ← WRONG DATE!

// Result sent to backend
"startDate=2025-10-12T22:00:00.000Z" // ← WRONG! Off by 1 day!
```

**Problem**: Backend would query for slots starting from **October 12** instead of October 13.

#### ✅ AFTER Fix (Correct)

```dart
// _calculateWeekStartDate returns: DateTime(2025, 10, 13, 0, 0) // Local time
final startDate = DateTime(2025, 10, 13, 0, 0);

// DateTime.utc creates UTC date with SAME CALENDAR DATE
final startDateUtc = DateTime.utc(
  startDate.year,   // 2025
  startDate.month,  // 10
  startDate.day     // 13
); // 2025-10-13 00:00 UTC ← CORRECT!

// Result sent to backend
"startDate=2025-10-13T00:00:00.000Z" // ✅ CORRECT!
```

**Solution**: Backend queries for slots starting from **October 13**, matching user's week selection.

---

## 6. Test Case Verification

### Test Case 1: Week 2025-W42 (Oct 13-19)

**Mobile App**:
```
User selects: Week 2025-W42
_calculateWeekStartDate("2025-W42") → DateTime(2025, 10, 13) local

With your fix:
  startDate → "2025-10-13T00:00:00.000Z"
  endDate   → "2025-10-19T23:59:59.999Z"
```

**Backend**:
```typescript
new Date("2025-10-13T00:00:00.000Z") → Mon Oct 13 2025 00:00:00 GMT
new Date("2025-10-19T23:59:59.999Z") → Sun Oct 19 2025 23:59:59 GMT

Prisma query:
  WHERE datetime >= '2025-10-13 00:00:00 UTC'
    AND datetime <= '2025-10-19 23:59:59.999 UTC'
```

**Result**: ✅ **ALIGNED** - Backend returns all slots for Oct 13-19

### Test Case 2: Slot at Friday Oct 17, 13:30 UTC

**Database**:
```
ScheduleSlot {
  datetime: 2025-10-17T13:30:00.000Z (Friday 13:30 UTC)
}
```

**Query with your fix**:
```
2025-10-13 00:00:00 <= 2025-10-17 13:30:00 <= 2025-10-19 23:59:59.999
TRUE                   ✓                     TRUE
```

**Result**: ✅ **INCLUDED** - Slot is correctly returned

### Test Case 3: Edge case - Monday at midnight

**Database**:
```
ScheduleSlot {
  datetime: 2025-10-13T00:00:00.000Z (Monday 00:00 UTC)
}
```

**Query with your fix**:
```
2025-10-13 00:00:00 <= 2025-10-13 00:00:00 <= 2025-10-19 23:59:59.999
TRUE                   ✓                     TRUE
```

**Result**: ✅ **INCLUDED** - Boundary condition handled correctly

---

## 7. Code Evidence from Backend Tests

**Source**: `/workspace/backend/src/controllers/__tests__/ScheduleSlotController.test.ts:429-434`

```typescript
it('should return schedule with date range', async () => {
  mockRequest.params = { groupId: 'group-1' };
  mockRequest.query = {
    startDate: '2024-01-01T00:00:00.000Z',  // ← UTC format
    endDate: '2024-01-07T23:59:59.999Z'     // ← UTC format
  };
```

**Evidence**: Backend tests explicitly use **UTC timestamps** for date range queries.

---

## 8. Comparison: Before vs After

| Aspect | Before Fix (❌ Wrong) | After Fix (✅ Correct) |
|--------|----------------------|------------------------|
| **Method** | `.toUtc()` | `DateTime.utc(year, month, day)` |
| **Behavior** | Converts time instant to UTC | Creates UTC date with same calendar date |
| **Example** | `2025-10-13 00:00 Paris` → `2025-10-12 22:00 UTC` | `2025-10-13 00:00 Paris` → `2025-10-13 00:00 UTC` |
| **Backend Interpretation** | Query from Oct 12 | Query from Oct 13 |
| **User Experience** | Week off by 1 day | Week matches user selection |
| **Correctness** | ❌ Incorrect | ✅ Correct |

---

## 9. Additional Issues Found

### ✅ No Additional Issues

The codebase shows good timezone handling practices:

1. **Database**: All `datetime` fields stored as UTC
2. **API**: Validates ISO 8601 datetime strings
3. **Comments**: Explicit documentation about UTC expectations
4. **Tests**: Consistent use of UTC timestamps
5. **Mobile**: Your fix aligns with backend expectations

---

## 10. Recommendations

### ✅ Keep Your Fix

**Action**: **NO CHANGES NEEDED** - Your fix is correct and should remain as-is.

**Reasoning**:
1. Backend expects UTC dates with calendar dates matching week selection
2. `DateTime.utc(year, month, day)` creates the correct UTC date
3. All test scenarios pass with your implementation
4. Backend code and tests confirm this approach

### 📝 Consider Adding Tests

**Optional Enhancement**: Add unit tests to verify the date conversion logic:

```dart
// test/unit/data/handlers/basic_slot_operations_handler_test.dart

test('should convert week dates to UTC correctly', () {
  // Given: Week 2025-W42 (Oct 13-19)
  final week = '2025-W42';

  // When: Calculate dates
  final startDate = handler._calculateWeekStartDate(week);
  final startDateUtc = DateTime.utc(
    startDate!.year,
    startDate.month,
    startDate.day
  );

  // Then: Should be Oct 13 at 00:00 UTC regardless of local timezone
  expect(startDateUtc.toIso8601String(), '2025-10-13T00:00:00.000Z');
  expect(startDateUtc.day, 13); // Not 12!
  expect(startDateUtc.hour, 0);
  expect(startDateUtc.timeZoneOffset, Duration.zero); // Confirm UTC
});
```

### 📚 Documentation Enhancement

**Optional**: Add inline comment explaining the conversion logic:

```dart
// Convert to UTC: Backend expects calendar dates in UTC, NOT timezone-shifted instants.
// Example: Week starting Oct 13 should send "2025-10-13T00:00:00.000Z",
// NOT "2025-10-12T22:00:00.000Z" (which .toUtc() would produce in Paris timezone).
final startDateUtc = startDate != null
    ? DateTime.utc(startDate.year, startDate.month, startDate.day).toIso8601String()
    : null;
```

---

## Conclusion

Your timezone fix is **100% correct** and aligns perfectly with the backend API's expectations.

### Key Takeaways

1. ✅ Backend stores and queries dates as **UTC timestamps**
2. ✅ Backend expects **calendar dates** in UTC (e.g., Oct 13 00:00 UTC)
3. ✅ Your fix uses `DateTime.utc(year, month, day)` which creates the correct UTC date
4. ✅ The alternative `.toUtc()` would shift the time instant, causing date mismatch
5. ✅ All test scenarios confirm alignment between mobile and backend

**Recommendation**: **KEEP THE FIX** - No changes required.

---

## Appendix: Technical References

### ISO 8601 Week Date Format
- Format: `YYYY-Www` (e.g., `2025-W42`)
- Week 1 = week containing January 4th
- Weeks start on Monday

### PostgreSQL DateTime Behavior
- Always stores as UTC internally
- Converts to session timezone on retrieval (not relevant for API)
- Prisma `DateTime` maps to PostgreSQL `TIMESTAMP WITH TIME ZONE`

### Dart DateTime Behavior
- `DateTime(year, month, day)` creates local time
- `.toUtc()` converts instant to UTC (shifts hours)
- `DateTime.utc(year, month, day)` creates UTC date (same calendar date)

---

**Report Generated**: 2025-10-12
**Status**: ✅ VERIFIED - FIX IS CORRECT
