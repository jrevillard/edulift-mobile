# Timezone Handling - Quick Reference Guide

**For**: EduLift Developers
**Last Updated**: 2025-10-12
**Critical**: 🔴 **Known bug in mobile DateTime creation - see section 3**

---

## TL;DR

- ✅ **Backend**: Store UTC, compare UTC
- ✅ **Mobile**: Input local, convert to UTC for API, compare local for UI
- ❌ **Current Bug**: Mobile creates UTC times instead of converting local→UTC
- 🎯 **Fix**: Use `DateTime()` + `.toUtc()` instead of `DateTime.utc()`

---

## 1. Backend: Working with Datetimes

### ✅ DO: Store in UTC
```typescript
// Prisma schema
model ScheduleSlot {
  datetime  DateTime  // PostgreSQL: TIMESTAMP WITH TIME ZONE (UTC)
}
```

### ✅ DO: Validate in UTC
```typescript
import { isDateInPast } from '../utils/dateValidation';

// Correct: Compares UTC timestamps
if (isDateInPast(new Date(slotData.datetime))) {
  throw new Error('Cannot create trips in the past');
}
```

### ✅ DO: Accept ISO 8601 with timezone
```typescript
// API expects: "2025-10-07T05:30:00.000Z"
const datetime: string = req.body.datetime;

// Validation
const isoRegex = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?Z$/;
if (!isoRegex.test(datetime)) {
  throw new Error('Invalid datetime format');
}
```

### ❌ DON'T: Convert timezones in backend
```typescript
// ❌ WRONG: Backend should not convert timezones
const localTime = new Date(datetime).toLocaleString('en-US', {
  timeZone: 'America/New_York'
});

// ✅ CORRECT: Keep everything in UTC
const utcTime = new Date(datetime); // Already UTC
```

---

## 2. Mobile: Working with Datetimes

### ❌ CURRENT BUG: DateTime Creation

**File**: `vehicle_operations_handler.dart`

**Current Code** (WRONG):
```dart
// ❌ WRONG: Creates UTC datetime directly
return DateTime.utc(
  date.year,
  date.month,
  date.day,
  hour,  // User's local hour treated as UTC!
  minute,
);
```

**Problem**:
- User selects "07:30" (local time)
- Code creates "07:30 UTC"
- Result: Slot created 2+ hours late

**Correct Code**:
```dart
// ✅ CORRECT: Create local datetime, then convert to UTC
final localDateTime = DateTime(
  date.year,
  date.month,
  date.day,
  hour,  // User's local hour
  minute,
);

// Convert to UTC for backend
return localDateTime.toUtc();
```

**Example**:
- User in Paris (UTC+2): "07:30" → `DateTime(2025, 10, 07, 07, 30)` → `.toUtc()` → "05:30:00.000Z"
- User in NYC (UTC-5): "07:30" → `DateTime(2025, 10, 07, 07, 30)` → `.toUtc()` → "12:30:00.000Z"

---

### ✅ DO: Past Slot Detection (UI)

**File**: `schedule_grid.dart`

```dart
// ✅ CORRECT: Compare local times
bool _isTimeSlotInPast(String day, String timeSlot) {
  // Create local datetime
  final slotDateTime = DateTime(
    slotDate.year,
    slotDate.month,
    slotDate.day,
    hour,
    minute,
  );

  // Compare with local now
  return slotDateTime.isBefore(DateTime.now());
}
```

**Why**:
- Users think in local time
- "Is 7:30 AM tomorrow in the past?" should compare local times
- Timezone-safe: both datetimes are in same timezone

---

### ✅ DO: API Request Serialization

**File**: `schedule_requests.dart`

```dart
class CreateScheduleSlotRequest {
  final String datetime;  // ISO 8601 UTC string

  Map<String, dynamic> toJson() => {
    'datetime': datetime,  // "2025-10-07T05:30:00.000Z"
  };
}
```

**Calling Code**:
```dart
final datetime = _calculateDateTimeFromSlot(day, time, week);
final request = CreateScheduleSlotRequest(
  datetime: datetime.toIso8601String(),  // Converts UTC DateTime to ISO string
);
```

---

## 3. Common Patterns

### Pattern 1: User Input → Backend Storage

```
User Input (Local) → Local DateTime → UTC DateTime → ISO String → Backend (UTC)
```

**Example**:
```dart
// Step 1: User selects "Tuesday 07:30" in Paris
final userInput = "07:30";

// Step 2: Create local datetime
final localDateTime = DateTime(2025, 10, 07, 07, 30);

// Step 3: Convert to UTC
final utcDateTime = localDateTime.toUtc(); // 2025-10-07 05:30:00.000Z

// Step 4: Serialize for API
final isoString = utcDateTime.toIso8601String(); // "2025-10-07T05:30:00.000Z"

// Step 5: Send to backend
api.createScheduleSlot(isoString);
```

---

### Pattern 2: Backend Response → User Display

```
Backend (UTC) → ISO String → UTC DateTime → Local DateTime → User Display (Local)
```

**Example**:
```dart
// Step 1: Backend returns
// { "datetime": "2025-10-07T05:30:00.000Z" }

// Step 2: Parse to DateTime
final utcDateTime = DateTime.parse("2025-10-07T05:30:00.000Z");

// Step 3: Convert to local
final localDateTime = utcDateTime.toLocal(); // 2025-10-07 07:30:00

// Step 4: Format for display
final displayTime = DateFormat('HH:mm').format(localDateTime); // "07:30"

// Step 5: Show to user
Text("Trip at $displayTime"); // "Trip at 07:30"
```

---

### Pattern 3: Past Detection (Local Context)

```dart
// ✅ CORRECT: Compare local times
final slotDateTime = DateTime(2025, 10, 07, 07, 30); // Local
final now = DateTime.now(); // Local
final isPast = slotDateTime.isBefore(now);
```

```typescript
// ✅ CORRECT: Compare UTC times
const slotDateTime = new Date("2025-10-07T05:30:00.000Z"); // UTC
const now = new Date(); // UTC
const isPast = slotDateTime.getTime() < now.getTime();
```

---

## 4. Testing Checklist

### Before Committing DateTime Code

- [ ] User in UTC+2: Creates "07:30" → Stores "05:30:00.000Z" ✅
- [ ] User in UTC-5: Creates "07:30" → Stores "12:30:00.000Z" ✅
- [ ] Past detection: Local time comparison ✅
- [ ] API request: ISO 8601 with 'Z' suffix ✅
- [ ] Backend validation: UTC comparison ✅

### Manual Testing

```dart
// Test: User in Paris (UTC+2) creates "07:30"
final localDateTime = DateTime(2025, 10, 07, 07, 30);
final utcDateTime = localDateTime.toUtc();
print(utcDateTime.toIso8601String()); // Should print: 2025-10-07T05:30:00.000Z

// Test: User in NYC (UTC-5) creates "07:30"
final localDateTime = DateTime(2025, 10, 07, 07, 30);
final utcDateTime = localDateTime.toUtc();
print(utcDateTime.toIso8601String()); // Should print: 2025-10-07T12:30:00.000Z
```

---

## 5. Common Mistakes

### ❌ Mistake 1: Using `DateTime.utc()` for user input
```dart
// ❌ WRONG
final datetime = DateTime.utc(2025, 10, 07, 07, 30);

// ✅ CORRECT
final datetime = DateTime(2025, 10, 07, 07, 30).toUtc();
```

### ❌ Mistake 2: Comparing local with UTC
```dart
// ❌ WRONG
final localSlot = DateTime(2025, 10, 07, 07, 30);
final utcNow = DateTime.now().toUtc();
if (localSlot.isBefore(utcNow)) { ... }

// ✅ CORRECT
final localSlot = DateTime(2025, 10, 07, 07, 30);
final localNow = DateTime.now();
if (localSlot.isBefore(localNow)) { ... }
```

### ❌ Mistake 3: Sending datetime without timezone
```json
// ❌ WRONG
{
  "datetime": "2025-10-07T07:30:00"
}

// ✅ CORRECT
{
  "datetime": "2025-10-07T05:30:00.000Z"
}
```

### ❌ Mistake 4: Backend timezone conversion
```typescript
// ❌ WRONG
const localTime = new Date(datetime).toLocaleString('en-US', {
  timeZone: 'America/New_York'
});

// ✅ CORRECT
const utcTime = new Date(datetime); // Keep in UTC
```

---

## 6. Debugging Tips

### Check 1: Verify DateTime is UTC
```dart
final datetime = DateTime.utc(2025, 10, 07, 07, 30);
print(datetime.isUtc); // Should be: true
print(datetime.toIso8601String()); // Should end with: Z
```

### Check 2: Verify API Request
```dart
// Add logging to API client
debugPrint('API Request datetime: ${request.datetime}');
// Should print: 2025-10-07T05:30:00.000Z (with Z)
```

### Check 3: Verify Backend Receives UTC
```typescript
// Add logging to controller
console.log('Received datetime:', req.body.datetime);
// Should log: 2025-10-07T05:30:00.000Z (with Z)

const date = new Date(req.body.datetime);
console.log('Parsed date:', date.toISOString());
// Should log: 2025-10-07T05:30:00.000Z
```

### Check 4: Verify Database Storage
```sql
-- Query database directly
SELECT id, datetime AT TIME ZONE 'UTC' as utc_time
FROM schedule_slots
WHERE id = 'slot_123';

-- Result should be: 2025-10-07 05:30:00
```

---

## 7. Quick Commands

### Dart: Create UTC from local
```dart
final local = DateTime(2025, 10, 07, 07, 30);
final utc = local.toUtc();
```

### Dart: Create local from UTC
```dart
final utc = DateTime.utc(2025, 10, 07, 05, 30);
final local = utc.toLocal();
```

### Dart: Check if UTC
```dart
final datetime = DateTime.now();
print(datetime.isUtc); // false (local)

final utcDatetime = DateTime.now().toUtc();
print(utcDatetime.isUtc); // true
```

### TypeScript: Parse ISO 8601
```typescript
const datetime = new Date("2025-10-07T05:30:00.000Z");
console.log(datetime.toISOString()); // 2025-10-07T05:30:00.000Z
```

### TypeScript: Compare timestamps
```typescript
const date1 = new Date("2025-10-07T05:30:00.000Z");
const date2 = new Date("2025-10-07T07:30:00.000Z");
console.log(date1.getTime() < date2.getTime()); // true
```

---

## 8. Resources

- **Full Audit Report**: `/workspace/mobile_app/docs/TIMEZONE_AUDIT_REPORT.md`
- **Architecture Decision**: `/workspace/mobile_app/docs/architecture/TIMEZONE_HANDLING_ADR.md`
- **Dart DateTime Docs**: https://api.dart.dev/stable/dart-core/DateTime-class.html
- **ISO 8601 Standard**: https://en.wikipedia.org/wiki/ISO_8601
- **PostgreSQL Timezones**: https://www.postgresql.org/docs/current/datatype-datetime.html

---

## 9. Emergency Contact

**If you encounter timezone bugs**:

1. Check mobile DateTime creation (likely culprit)
2. Verify API request has 'Z' suffix
3. Check backend logs for received datetime
4. Query database directly to verify storage
5. Contact: System Architecture Designer

**Known Issues**:
- 🔴 **CRITICAL**: Mobile `DateTime.utc()` bug in `vehicle_operations_handler.dart`
  - **Impact**: All schedule slots created at wrong time
  - **Fix**: Use `DateTime()` + `.toUtc()` instead

---

**Last Updated**: 2025-10-12
**Status**: 🔴 Critical bug documented, fix pending

