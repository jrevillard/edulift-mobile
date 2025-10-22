# Timezone Fix Visual Diagram

## The Problem and Solution

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          USER'S PERSPECTIVE                                  │
│                         (Paris, UTC+2 timezone)                              │
└─────────────────────────────────────────────────────────────────────────────┘

User selects: Week 2025-W42 (October 13-19, 2025)
Expected: See schedule for Monday Oct 13 through Sunday Oct 19


┌─────────────────────────────────────────────────────────────────────────────┐
│                        MOBILE APP CALCULATION                                │
└─────────────────────────────────────────────────────────────────────────────┘

_calculateWeekStartDate("2025-W42")
    ↓
DateTime(2025, 10, 13, 0, 0)  ← Local time (Paris)
    ↓
    ├─────────────────────────┬─────────────────────────┐
    │                         │                         │
    ❌ WRONG (before fix)     ✅ CORRECT (your fix)     │
    │                         │                         │
startDate.toUtc()         DateTime.utc(               │
    ↓                       startDate.year,            │
Converts INSTANT           startDate.month,           │
to UTC                     startDate.day              │
    ↓                     )                            │
                              ↓                        │
                          Creates UTC date            │
                          with SAME calendar date     │
                              ↓                        │
                                                       │

┌────────────────────────────┐  ┌─────────────────────────────────┐
│  ❌ WRONG RESULT           │  │  ✅ CORRECT RESULT              │
│                            │  │                                 │
│  2025-10-12T22:00:00.000Z  │  │  2025-10-13T00:00:00.000Z       │
│         ^^^^               │  │         ^^^^                    │
│      Oct 12 (wrong!)       │  │      Oct 13 (correct!)          │
└────────────────────────────┘  └─────────────────────────────────┘
         │                               │
         │                               │
         ↓                               ↓

┌─────────────────────────────────────────────────────────────────────────────┐
│                          BACKEND API PROCESSING                              │
└─────────────────────────────────────────────────────────────────────────────┘

❌ Wrong:                         ✅ Correct:
GET /schedule?                    GET /schedule?
  startDate=2025-10-12T22:00Z       startDate=2025-10-13T00:00Z
  endDate=2025-10-19T21:59Z         endDate=2025-10-19T23:59Z
         ↓                                  ↓
new Date("2025-10-12T22:00Z")     new Date("2025-10-13T00:00Z")
         ↓                                  ↓
┌────────────────────────┐        ┌─────────────────────────────┐
│ Database Query         │        │ Database Query              │
│                        │        │                             │
│ WHERE datetime >=      │        │ WHERE datetime >=           │
│   '2025-10-12 22:00'   │        │   '2025-10-13 00:00'        │
│ AND datetime <=        │        │ AND datetime <=             │
│   '2025-10-19 21:59'   │        │   '2025-10-19 23:59'        │
└────────────────────────┘        └─────────────────────────────┘
         ↓                                  ↓
Returns slots from:               Returns slots from:
Oct 12 22:00 to Oct 19 21:59      Oct 13 00:00 to Oct 19 23:59
(Missing first hours of Oct 13!)  (Complete week Oct 13-19!)
(Includes last 2 hours of Oct 12) 


┌─────────────────────────────────────────────────────────────────────────────┐
│                          USER EXPERIENCE                                     │
└─────────────────────────────────────────────────────────────────────────────┘

❌ Wrong (before fix):            ✅ Correct (your fix):
- Week appears shifted            - Week shows exactly Oct 13-19
- Missing slots on Monday AM      - All slots visible
- Shows extra slots from Sunday   - No extra/missing slots
- User confusion!                 - Perfect user experience!
```

---

## Technical Deep Dive

### Understanding `.toUtc()` vs `DateTime.utc()`

```dart
// Given: Local time in Paris (UTC+2)
final local = DateTime(2025, 10, 13, 0, 0);
print(local);  // 2025-10-13 00:00:00.000 (local time)

// ❌ Method 1: .toUtc() - Converts the INSTANT
final wrongUtc = local.toUtc();
print(wrongUtc);  // 2025-10-12 22:00:00.000Z
// Explanation: Midnight in Paris (UTC+2) = 22:00 previous day in UTC
// Same moment in time, different timezone → WRONG for calendar dates!

// ✅ Method 2: DateTime.utc() - Creates UTC date with SAME calendar date
final correctUtc = DateTime.utc(local.year, local.month, local.day);
print(correctUtc);  // 2025-10-13 00:00:00.000Z
// Explanation: Creates a NEW UTC date with year=2025, month=10, day=13
// Same calendar date, different timezone → CORRECT for date queries!
```

### Timeline Visualization

```
Time axis (Paris timezone, UTC+2):
─────────────────────────────────────────────────────────────────────────
         Oct 12            Oct 13            Oct 14
    ─────────────────|──────────────────|──────────────────
Paris:  22:00  23:00 | 00:00  01:00     | 00:00  01:00
                     ↑
              User wants THIS
                (Oct 13 start)

Time axis (UTC):
─────────────────────────────────────────────────────────────────────────
         Oct 12            Oct 13            Oct 14
    ─────────────────|──────────────────|──────────────────
UTC:    22:00  23:00 | 00:00  01:00     | 00:00  01:00
        ↑                   ↑
    WRONG (.toUtc())   CORRECT (DateTime.utc())
```

---

## Real-World Example

### Database Contents

```sql
schedule_slots (datetime stored as UTC):
+------+----------+---------------------+
| id   | groupId  | datetime            |
+------+----------+---------------------+
| s1   | g1       | 2025-10-12 22:30 Z  |  ← Sunday evening
| s2   | g1       | 2025-10-13 07:30 Z  |  ← Monday morning  
| s3   | g1       | 2025-10-13 15:30 Z  |  ← Monday afternoon
| s4   | g1       | 2025-10-17 13:30 Z  |  ← Friday afternoon
| s5   | g1       | 2025-10-19 18:00 Z  |  ← Sunday evening
+------+----------+---------------------+
```

### Query Results

**❌ With Wrong Fix** (`.toUtc()`):
```
Query: WHERE datetime >= '2025-10-12 22:00:00 Z' 
       AND datetime <= '2025-10-19 21:59:59 Z'

Results: [s1, s2, s3, s4, s5]
         ↑                  ↑
    WRONG (from Sunday)  WRONG (missing last 2h of Sunday)
```

**✅ With Your Fix** (`DateTime.utc()`):
```
Query: WHERE datetime >= '2025-10-13 00:00:00 Z'
       AND datetime <= '2025-10-19 23:59:59 Z'

Results: [s2, s3, s4, s5]
         ↑              ↑
    CORRECT (Monday)  CORRECT (full Sunday)
```

---

## Summary

### The Core Issue

```
Calendar Date ≠ Time Instant

User thinks:     "Show me the week starting October 13"
                  (calendar date)

Wrong approach:  Convert midnight Oct 13 Paris to UTC instant
                 → Oct 12 22:00 UTC (same instant, wrong date!)

Correct approach: Use calendar date Oct 13 in UTC
                  → Oct 13 00:00 UTC (same date!)
```

### The Fix

```dart
// DON'T: Convert time instant to UTC
startDate.toUtc()  // ❌ Changes calendar date!

// DO: Create UTC date with same calendar date
DateTime.utc(startDate.year, startDate.month, startDate.day)  // ✅ Preserves date!
```

---

**Key Principle**: When working with **calendar dates** (like week boundaries), 
use `DateTime.utc()` to preserve the date. When working with **time instants** 
(like "now"), use `.toUtc()` to convert the moment in time.

