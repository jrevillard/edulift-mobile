# 🔧 FIX: Timezone Bug - +2h Offset When Adding Vehicle

## 🐛 Bug Description

**Symptom**: When a user clicks on a time slot (e.g., `07:30`), the vehicle is added but appears at a different time (e.g., `09:30`) with a +2h offset (for UTC+2 timezone).

**Root Cause**: The mobile app was treating local time as UTC time, causing a double timezone conversion:
1. User clicks `07:30 LOCAL`
2. App treated it as `07:30 UTC` (first error)
3. Display converted `07:30 UTC` → `09:30 LOCAL` (second conversion)
4. Result: User sees `09:30` instead of `07:30`

## ✅ Fix Applied

### File: `/workspace/mobile_app/lib/features/schedule/domain/services/schedule_datetime_service.dart`

**Before (BUGGY)**:
```dart
// Build datetime directly in UTC
final utcDateTime = DateTime.utc(
  date.year,
  date.month,
  date.day,
  hour,  // ❌ Treats local hour as UTC hour
  minute,
);
```

**After (FIXED)**:
```dart
// ✅ FIX: Build datetime in LOCAL timezone first (what the user sees/clicks)
final localDateTime = DateTime(
  date.year,
  date.month,
  date.day,
  hour,  // ✅ Local hour as the user intended
  minute,
);

// ✅ Then convert to UTC for API/backend storage
final utcDateTime = localDateTime.toUtc();
```

## 🔍 How the Fix Works

### Correct Flow (After Fix)

1. **User Action**: Clicks `07:30` in local timezone
2. **Mobile Calculation**:
   - Builds `DateTime(2025, 1, 6, 7, 30)` in LOCAL timezone
   - Converts to UTC: `07:30 LOCAL` → `05:30 UTC` (for UTC+2)
3. **API Call**: Sends `2025-01-06T05:30:00.000Z` to backend
4. **Backend**: Stores `05:30 UTC` in database
5. **API Response**: Returns `05:30 UTC`
6. **Mobile DTO**: Converts `05:30 UTC` → `07:30 LOCAL`
7. **Display**: Shows `07:30` ✅ (matches user input!)

### Example for Different Timezones

| Timezone | User Clicks | Stored in DB (UTC) | Displayed to User |
|----------|-------------|-------------------|-------------------|
| UTC+0    | 07:30       | 07:30 UTC         | 07:30 ✅          |
| UTC+2    | 07:30       | 05:30 UTC         | 07:30 ✅          |
| UTC-5    | 07:30       | 12:30 UTC         | 07:30 ✅          |

## 🧪 Testing

### Test Files Updated

1. **`schedule_datetime_service_test.dart`**:
   - Updated existing tests to verify LOCAL → UTC conversion
   - Added regression tests for timezone bug

### New Regression Tests

```dart
test('should convert local time to UTC correctly', () {
  final utcResult = service.calculateDateTimeFromSlot('Monday', '07:30', '2025-W02');
  final localResult = utcResult.toLocal();

  // User clicked 07:30 LOCAL, should display 07:30 LOCAL after round-trip
  expect(localResult.hour, equals(7));
  expect(localResult.minute, equals(30));
});

test('should produce consistent datetime when stored and retrieved', () {
  // Simulate: User clicks → Store → Retrieve → Display
  final userClickedUtc = service.calculateDateTimeFromSlot('Monday', '07:30', '2025-W02');
  final storedUtcString = userClickedUtc!.toIso8601String();
  final retrievedUtc = DateTime.parse(storedUtcString);
  final displayedLocal = retrievedUtc.toLocal();

  // Verify: Displayed time = User clicked time
  expect(displayedLocal.hour, equals(7)); // Not 09:30!
});
```

### Test Results

```bash
$ flutter test test/unit/features/schedule/domain/services/schedule_datetime_service_test.dart
All tests passed! ✅
```

## 📊 Debugging Logs Added

Added comprehensive logging to trace the exact conversion flow:

### Mobile Side (`vehicle_operations_handler.dart`)

```dart
_logger.info('🕐 Target datetime (UTC): ${datetime.toIso8601String()}');
_logger.info('🕐 Target time components: day=$day, time=$time, week=$week');
_logger.info('🕐 UTC hour=${datetime.hour}, minute=${datetime.minute}');
_logger.info('🕐 Local hour=${localDatetime.hour}, minute=${localDatetime.minute}');
_logger.info('📤 Sending to API: datetime=$datetimeString');
```

### Backend Side

- `ScheduleSlotController.ts`: Logs received datetime from API
- `ScheduleSlotService.ts`: Logs datetime parsing and conversion
- `ScheduleSlotRepository.ts`: Logs what gets stored in database

## 🎯 Impact

### Before Fix (Buggy Behavior)
- ❌ User clicks `07:30` → Display shows `09:30`
- ❌ Data corruption: Wrong times stored/displayed
- ❌ Confusing UX for users

### After Fix (Correct Behavior)
- ✅ User clicks `07:30` → Display shows `07:30`
- ✅ Correct timezone handling: LOCAL ↔ UTC conversions work properly
- ✅ Consistent UX across all timezones

## 🔑 Key Principles

**PRINCIPLE 0**: User's selected time MUST equal displayed time
- User Input Time = Display Time (always in local timezone)
- Backend stores in UTC (for consistency across timezones)
- Mobile handles conversion: Local → UTC → Local

## 📝 Related Files

- **Fixed**: `schedule_datetime_service.dart` (main fix)
- **Updated Tests**: `schedule_datetime_service_test.dart`
- **Logging Added**:
  - `vehicle_operations_handler.dart`
  - `ScheduleSlotController.ts`
  - `ScheduleSlotService.ts`
  - `ScheduleSlotRepository.ts`

## ✅ Verification Checklist

- [x] Fix applied to `schedule_datetime_service.dart`
- [x] All existing tests updated and passing
- [x] New regression tests added
- [x] Logging added for debugging
- [x] Documentation created
- [ ] Manual testing in app (with different timezones)
- [ ] Backend logs reviewed to verify UTC storage

## 🚀 Next Steps

1. **Manual Testing**:
   - Test on device with UTC+2 timezone
   - Click slot at 07:30, verify it displays as 07:30
   - Check backend logs to confirm 05:30 UTC is stored

2. **Cross-Timezone Testing**:
   - Test with different device timezones (UTC+0, UTC-5, etc.)
   - Verify all show correct local times

3. **Integration Testing**:
   - Test full flow: Create → Retrieve → Update → Delete
   - Verify times remain consistent throughout

## 📚 References

- Analysis document: `/workspace/BUG_TIMEZONE_ANALYSIS.md`
- Prisma schema: `/workspace/backend/prisma/schema.prisma` (datetime stored as `DateTime` in UTC)
- ISO 8601 standard: DateTime with 'Z' suffix = UTC
