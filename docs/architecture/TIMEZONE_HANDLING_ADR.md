# Architecture Decision Record: Timezone Handling in Schedule System

**Status**: 🔴 **Needs Correction**
**Date**: 2025-10-12
**Decision Maker**: System Architecture Designer
**Context**: EduLift Schedule System - Multi-timezone support

---

## Context

The EduLift schedule system must handle time-based scheduling across multiple timezones. Users can be in different countries, but the system must ensure:
1. Schedule slots are created at the correct local time
2. Past slot detection works correctly
3. Backend stores and validates times consistently
4. Multi-timezone groups can coordinate schedules

---

## Decision

### Timezone Strategy: **"Local Input, UTC Storage, Local Display"**

#### 1. Schedule Configuration
- **Storage Format**: `{ "MONDAY": ["07:30", "15:00"], ... }`
- **Interpretation**: Times represent **local times** in user's timezone
- **Rationale**: Users think in local time, not UTC

#### 2. Schedule Slot Creation
- **Input**: User selects "Mardi 07:30" (local time)
- **Mobile Processing**:
  1. Create DateTime in **local timezone**: `DateTime(2025, 10, 07, 07, 30)`
  2. Convert to UTC: `localDateTime.toUtc()`
  3. Send ISO 8601 string: `"2025-10-07T05:30:00.000Z"` (Paris UTC+2 → -2 hours)
- **Backend Storage**: UTC datetime in PostgreSQL `TIMESTAMP WITH TIME ZONE`
- **Rationale**: Backend operates in UTC for consistency; conversion at boundary

#### 3. Past Slot Detection
- **Mobile (UI)**: Compare local times
  ```dart
  final slotDateTime = DateTime(2025, 10, 07, 07, 30); // Local
  final now = DateTime.now(); // Local
  return slotDateTime.isBefore(now);
  ```
- **Backend (API)**: Compare UTC timestamps
  ```typescript
  const now = new Date(); // UTC
  const checkDate = new Date(datetime); // UTC
  return checkDate.getTime() < now.getTime();
  ```
- **Rationale**: Each layer compares within its own timezone context

#### 4. API Contract
- **Request Format**: ISO 8601 with UTC timezone
  ```json
  {
    "datetime": "2025-10-07T05:30:00.000Z",
    "vehicleId": "cm..."
  }
  ```
- **Response Format**: ISO 8601 with UTC timezone
  ```json
  {
    "id": "slot_123",
    "datetime": "2025-10-07T05:30:00.000Z",
    "groupId": "group_456"
  }
  ```
- **Rationale**: ISO 8601 is industry standard; 'Z' suffix ensures UTC

---

## Current Implementation Issues

### 🔴 CRITICAL BUG: Mobile DateTime Creation

**File**: `/workspace/mobile_app/lib/features/schedule/data/repositories/handlers/vehicle_operations_handler.dart`

**Current Code** (Line 86):
```dart
return DateTime.utc(
  date.year,
  date.month,
  date.day,
  hour,  // ❌ Interpreted as UTC hour, not local
  minute,
);
```

**Problem**:
- User in Paris selects "07:30" (local time)
- Mobile creates: "2025-10-07T07:30:00.000Z" (UTC)
- Actual Paris time: **09:30** (07:30 UTC + 2 hours)
- **User expects 07:30, gets 09:30** ❌

**Correct Code**:
```dart
// Create LOCAL datetime first
final localDateTime = DateTime(
  date.year,
  date.month,
  date.day,
  hour,  // ✅ Local hour (07:30 Paris)
  minute,
);

// Convert to UTC for backend
return localDateTime.toUtc(); // Returns 05:30 UTC (07:30 Paris - 2 hours)
```

**Impact**:
- All schedule slots are created 2 hours late in summer (UTC+2)
- Users can't create morning slots (they become afternoon)
- Critical UX and functional bug

---

## Design Principles

### 1. Timezone Conversion at Boundary
- **Principle**: Convert timezones at system boundaries, not internally
- **Application**:
  - Mobile: Local → UTC at API call
  - Backend: Store UTC, no conversion
  - Mobile: UTC → Local at display (future enhancement)

### 2. Explicit Timezone Markers
- **Principle**: Always use explicit timezone markers
- **Application**:
  - ISO 8601 strings MUST end with 'Z' or timezone offset
  - Never send naive datetime strings
  - Example: ✅ `"2025-10-07T05:30:00.000Z"`, ❌ `"2025-10-07T05:30:00"`

### 3. Local Time for UX, UTC for Storage
- **Principle**: Users see local times, system stores UTC
- **Application**:
  - Schedule config: "07:30" displayed to user
  - Internal storage: "05:30:00.000Z" (after conversion)
  - API response: "05:30:00.000Z"
  - Future: Mobile converts back to "07:30" for display

### 4. Timezone-Safe Comparisons
- **Principle**: Never compare datetimes in different timezones
- **Application**:
  - Mobile past detection: Local vs Local ✅
  - Backend past detection: UTC vs UTC ✅
  - Never: Local vs UTC ❌

---

## Consequences

### Positive
- ✅ Backend stores all times in consistent UTC
- ✅ PostgreSQL `TIMESTAMP WITH TIME ZONE` handles timezone conversions
- ✅ API uses industry-standard ISO 8601 format
- ✅ Past slot detection is timezone-safe in both layers
- ✅ System can support users in any timezone

### Negative
- ⚠️ Current mobile implementation has critical bug
- ⚠️ Schedule config times are ambiguous (no timezone info)
- ⚠️ Multi-timezone groups may have confusion without proper UI
- ⚠️ No timezone display in mobile UI (shows raw config times)

### Risks
- 🔴 Users create slots at wrong times (current bug)
- 🟡 Confusion when users are in different timezones
- 🟡 Schedule config doesn't store original timezone
- 🟢 Backend timezone changes could break system (mitigated by UTC storage)

---

## Migration Path

### Phase 1: Fix Critical Bug (P0)
**ETA**: 1 day

1. Update `vehicle_operations_handler.dart`:
   - Change `DateTime.utc()` to `DateTime()` + `.toUtc()`
2. Test with users in UTC+2, UTC-5, UTC+9
3. Verify past slot detection still works
4. Deploy to production

### Phase 2: Documentation (P1)
**ETA**: 2 days

1. Add timezone comments to all date-handling code
2. Document API contract explicitly
3. Update developer documentation
4. Add timezone test scenarios

### Phase 3: Enhanced UI (P2)
**ETA**: 1 week

1. Display timezone info in schedule config
2. Show converted times to users
3. Add "Your timezone" indicator
4. Implement timezone picker for groups

### Phase 4: Timezone-Aware Config (P3)
**ETA**: 2 weeks

1. Add `timezone` field to `GroupScheduleConfig`
2. Store IANA timezone (e.g., "Europe/Paris")
3. Allow groups to set preferred timezone
4. Convert config times to user's timezone for display

---

## Alternatives Considered

### Alternative 1: Store Local Times in Backend
**Decision**: ❌ Rejected

- **Pros**: No conversion needed
- **Cons**:
  - Requires storing timezone with each slot
  - Complex queries (can't sort by time)
  - Difficult to handle DST transitions
  - Backend loses single source of truth

### Alternative 2: Store Both UTC and Local
**Decision**: ❌ Rejected

- **Pros**: No conversion needed for display
- **Cons**:
  - Data duplication
  - Risk of inconsistency
  - More storage space
  - Complexity in updates

### Alternative 3: Timezone-Naive System (All UTC)
**Decision**: ❌ Rejected

- **Pros**: Simplest implementation
- **Cons**:
  - Users must manually convert times
  - Poor UX
  - Error-prone
  - Not scalable internationally

### Alternative 4: Local Input, UTC Storage (CHOSEN)
**Decision**: ✅ Selected

- **Pros**:
  - Industry best practice
  - PostgreSQL native support
  - Scalable to any timezone
  - Clear separation of concerns
- **Cons**:
  - Requires careful implementation
  - Conversion at boundaries
  - Current bug needs fixing

---

## Validation Checklist

### Backend
- [x] Database stores UTC datetimes (`TIMESTAMP WITH TIME ZONE`)
- [x] Backend validation uses UTC comparison
- [x] API expects ISO 8601 with timezone
- [x] API returns ISO 8601 with timezone
- [ ] Documentation includes timezone notes

### Mobile
- [ ] DateTime creation converts local → UTC (❌ **CURRENTLY BROKEN**)
- [x] Past slot detection uses local time comparison
- [x] API requests send ISO 8601 UTC strings
- [ ] UI displays timezone information
- [ ] Documentation includes timezone notes

### Testing
- [ ] Test Case 1: User in UTC+2 (Paris)
- [ ] Test Case 2: User in UTC-5 (New York)
- [ ] Test Case 3: User in UTC+9 (Tokyo)
- [ ] Test Case 4: DST transition
- [ ] Test Case 5: Past slot detection at midnight

---

## References

- [ISO 8601 Standard](https://en.wikipedia.org/wiki/ISO_8601)
- [PostgreSQL Timezone Documentation](https://www.postgresql.org/docs/current/datatype-datetime.html)
- [Dart DateTime API](https://api.dart.dev/stable/dart-core/DateTime-class.html)
- [JavaScript Date API](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date)

---

## Decision Log

| Date | Decision | Rationale |
|------|----------|-----------|
| 2025-10-12 | Adopt "Local Input, UTC Storage" pattern | Industry best practice, scalable |
| 2025-10-12 | Identify critical bug in mobile DateTime creation | Audit revealed timezone mismatch |
| 2025-10-12 | Recommend 4-phase migration | Prioritize critical fix, then enhancements |

---

**Signed**: Claude (System Architecture Designer)
**Review Status**: Pending team review
**Next Review**: After Phase 1 implementation

