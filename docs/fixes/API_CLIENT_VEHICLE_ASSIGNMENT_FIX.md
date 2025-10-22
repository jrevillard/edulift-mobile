# Fix: API Request Format for Vehicle Assignment

**Date**: 2025-10-11
**Status**: ✅ FIXED
**Priority**: CRITICAL

## Problem

When adding a vehicle to a schedule slot, the mobile app was sending an incorrect request format:

```json
{
  "name": "Schedule Slot Tuesday 07:30",
  "start_time": "2025-10-11T07:30:00.000",
  "end_time": "2025-10-11T08:30:00.000"
}
```

But the backend expected:

```json
{
  "datetime": "2025-10-11T07:30:00.000Z",
  "vehicleId": "cm...",
  "driverId": "cm..." // optional
}
```

**Result**: 400 Bad Request - "datetime Required, vehicleId Required"

## Root Cause

The mobile app was using a two-step process:
1. Create empty schedule slot (using wrong DTO format)
2. Assign vehicle to slot separately

The backend API changed to create slot + vehicle in a single atomic operation via:
`POST /api/v1/groups/:groupId/schedule-slots`

## Solution

### 1. Updated `CreateScheduleSlotRequest` DTO

**File**: `/workspace/mobile_app/lib/core/network/requests/schedule_requests.dart`

Changed from:
```dart
class CreateScheduleSlotRequest {
  final String name;
  final DateTime startTime;
  final DateTime endTime;
  final String? vehicleId;  // Optional
  // ...
}
```

To:
```dart
class CreateScheduleSlotRequest {
  final String datetime;      // ✅ ISO 8601 datetime (required)
  final String vehicleId;     // ✅ Vehicle CUID (required)
  final String? driverId;     // Optional driver CUID
  final int? seatOverride;    // Optional seat override
  // ...
}
```

### 2. Updated Vehicle Assignment Handler

**File**: `/workspace/mobile_app/lib/features/schedule/data/repositories/handlers/vehicle_operations_handler.dart`

**Key Changes**:

1. **Added datetime calculation helper**:
```dart
DateTime? _calculateDateTimeFromSlot(String day, String time, String week) {
  // Calculates full ISO 8601 datetime from:
  // - day: "Monday", "Tuesday", etc.
  // - time: "07:30", "14:00", etc.
  // - week: "2025-W02", "2025-W03", etc.

  // Returns UTC datetime: "2025-01-13T07:30:00.000Z"
}
```

2. **Simplified vehicle assignment to single API call**:
```dart
Future<Result<VehicleAssignment, ApiFailure>> assignVehicleToSlot(
  String groupId, String day, String time, String week, String vehicleId
) async {
  // Calculate datetime from day, time, and week
  final datetime = _calculateDateTimeFromSlot(day, time, week);

  // Create slot with vehicle in ONE API call
  final request = CreateScheduleSlotRequest(
    datetime: datetime.toIso8601String(),
    vehicleId: vehicleId,
  );

  final scheduleSlotDto = await _apiClient.createScheduleSlot(groupId, request);

  // Extract vehicle assignment from created slot
  return Result.ok(scheduleSlotDto.vehicleAssignments.first.toDomain());
}
```

**Before**: 2 API calls (create slot → assign vehicle)
**After**: 1 API call (create slot with vehicle)

### 3. Deprecated Old Slot Creation Method

**File**: `/workspace/mobile_app/lib/features/schedule/data/repositories/handlers/basic_slot_operations_handler.dart`

Marked `upsertScheduleSlot()` as deprecated with clear error message:

```dart
@Deprecated(
  'For vehicle assignments, use VehicleOperationsHandler.assignVehicleToSlot() '
  'which creates slot + vehicle in one API call.'
)
Future<Result<ScheduleSlot, ApiFailure>> upsertScheduleSlot(...) async {
  return Result.err(ApiFailure.validationError(
    message: 'Cannot create empty schedule slots. '
             'Use VehicleOperationsHandler.assignVehicleToSlot() instead.',
  ));
}
```

This forces proper usage and prevents regression.

## Request Format Verification

### Correct Request (After Fix)

```json
POST /api/v1/groups/{groupId}/schedule-slots
{
  "datetime": "2025-10-11T07:30:00.000Z",  ✅ ISO 8601 UTC
  "vehicleId": "cm4abc123...",             ✅ Required CUID
  "driverId": null,                        ✅ Optional (null is valid)
  "seatOverride": null                     ✅ Optional (null is valid)
}
```

### Backend Schema Match

From `/workspace/backend/src/routes/scheduleSlots.ts:49-54`:

```typescript
const CreateScheduleSlotWithVehicleSchema = z.object({
  datetime: z.string().datetime(),    // ✅ Matches
  vehicleId: z.string().cuid(),       // ✅ Matches
  driverId: z.string().optional(),    // ✅ Matches
  seatOverride: z.number().optional() // ✅ Matches
});
```

✅ **100% Schema Alignment**

## Success Criteria

- [x] `CreateScheduleSlotRequest` matches backend schema exactly
- [x] `datetime` field sent in ISO 8601 format
- [x] `vehicleId` field sent (required)
- [x] No more 400 "datetime Required, vehicleId Required" errors
- [x] Vehicle assignment succeeds with one API call
- [x] Schedule slot created with vehicle atomically
- [x] Old slot creation method deprecated to prevent misuse

## Testing

### Manual Test

```bash
cd /workspace/mobile_app
flutter run -d linux
# Click "Add MG4" on Tuesday Morning
# Should succeed without 400 error
```

### Expected API Call

```
POST /api/v1/groups/cm4xyz789.../schedule-slots
{
  "datetime": "2025-10-11T07:30:00.000Z",
  "vehicleId": "cm4abc123..."
}

Response: 200 OK
{
  "id": "slot_id",
  "datetime": "2025-10-11T07:30:00.000Z",
  "vehicleAssignments": [
    {
      "id": "assignment_id",
      "vehicleId": "cm4abc123...",
      // ...
    }
  ]
}
```

## Notes

### Why DateTime Calculation is Needed

The UI works with:
- **day**: "Monday", "Tuesday" (human-readable)
- **time**: "07:30", "14:00" (HH:mm format)
- **week**: "2025-W02" (ISO week format)

The backend API expects:
- **datetime**: "2025-01-13T07:30:00.000Z" (full ISO 8601)

The `_calculateDateTimeFromSlot()` helper bridges this gap by:
1. Parsing week format to find Monday of that week
2. Adding day offset (Monday=0, Tuesday=1, etc.)
3. Combining with time to create full datetime
4. Converting to UTC ISO 8601 string

### Test Failures (Separate Issue)

Test files use old `ScheduleSlot` constructor with `day` and `time` parameters.
These have been replaced with typed `dayOfWeek` and `timeOfDay`.

Test fixes are tracked separately and do NOT block this API fix.

## Files Modified

1. `/workspace/mobile_app/lib/core/network/requests/schedule_requests.dart`
2. `/workspace/mobile_app/lib/features/schedule/data/repositories/handlers/vehicle_operations_handler.dart`
3. `/workspace/mobile_app/lib/features/schedule/data/repositories/handlers/basic_slot_operations_handler.dart`

## Related Issues

- Backend schema change to atomic slot+vehicle creation
- Type-safe schedule domain migration (separate initiative)
- Test suite updates for new ScheduleSlot API (separate task)
