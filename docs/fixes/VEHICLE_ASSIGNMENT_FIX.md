# Fix: Vehicle Assignment Logic - Copy from Web Frontend

## Problem Analysis

The mobile app fails to add multiple vehicles to the same time slot because it always calls `createScheduleSlot`, which attempts to create a new slot even when one already exists at that datetime.

### Current Mobile Logic (BROKEN ❌)
```dart
// mobile_app/lib/features/schedule/data/repositories/handlers/vehicle_operations_handler.dart
// Line 38-107
Future<Result<VehicleAssignment, ApiFailure>> assignVehicleToSlot(...) async {
  // ❌ ALWAYS creates a new slot - no existence check
  final createSlotRequest = api_requests.CreateScheduleSlotRequest(
    datetime: datetime.toIso8601String(),
    vehicleId: vehicleId,
  );

  final scheduleSlotDto = await ApiResponseHelper.executeAndUnwrap<ScheduleSlotDto>(
    () => _apiClient.createScheduleSlot(groupId, createSlotRequest),
  );
  // ...
}
```

### Web Frontend Logic (WORKS ✅)
```typescript
// frontend/src/pages/SchedulePage.tsx
// Line 357-408
const handleVehicleDrop = async (day: string, time: string, vehicleId: string) => {
  try {
    const daySchedule = scheduleByDay[day] || [];

    // ✅ STEP 1: Check if slot already exists
    let scheduleSlot = daySchedule.find((slot: ScheduleSlot) => {
      const slotTime = new Date(slot.datetime).toLocaleTimeString('en-US', {
        hour: '2-digit',
        minute: '2-digit',
        hour12: false,
        timeZone: 'UTC'
      });
      return slotTime === time;
    });

    if (!scheduleSlot) {
      // ✅ STEP 2a: No slot exists → Create new slot with vehicle
      scheduleSlot = await createScheduleSlotWithVehicleMutation.mutateAsync({
        day,
        time,
        vehicleId,
        driverId: user!.id
      });
    } else {
      // ✅ STEP 2b: Slot exists → Just assign vehicle to existing slot
      await apiService.assignVehicleToScheduleSlot(scheduleSlot.id, vehicleId, user!.id);
    }

    // Refresh schedule
    await queryClient.invalidateQueries({ queryKey: ['weekly-schedule', selectedGroup, currentWeek] });
    await queryClient.refetchQueries({ queryKey: ['weekly-schedule', selectedGroup, currentWeek] });
  } catch (error) {
    // Error handling...
  }
};
```

### API Endpoints Used

**Web Frontend uses 2 different endpoints:**
1. `POST /groups/{groupId}/schedule-slots` - Creates new slot with vehicle (backend line 82-87)
2. `POST /schedule-slots/{slotId}/vehicles` - Assigns vehicle to existing slot (backend line 105-110)

**Mobile App only uses:**
1. `POST /groups/{groupId}/schedule-slots` - Always creates new slot ❌

## Solution: Copy Web Logic Exactly

### Modified Mobile Handler
```dart
// mobile_app/lib/features/schedule/data/repositories/handlers/vehicle_operations_handler.dart

Future<Result<VehicleAssignment, ApiFailure>> assignVehicleToSlot(
  String groupId,
  String day,
  String time,
  String week,
  String vehicleId,
  Future<Result<List<ScheduleSlot>, ApiFailure>> Function(String, String) getWeeklySchedule,
) async {
  try {
    _logger.info('Assigning vehicle $vehicleId to slot: $groupId, $day, $time, $week');

    // Calculate datetime from day, time, and week using domain service
    final datetime = _dateTimeService.calculateDateTimeFromSlot(day, time, week);
    if (datetime == null) {
      return Result.err(ApiFailure.validationError(
        message: 'Invalid datetime calculation: day=$day, time=$time, week=$week',
      ));
    }

    _logger.info('Target datetime: ${datetime.toIso8601String()}');

    // ✅ STEP 1: Fetch weekly schedule to check if slot exists
    final scheduleResult = await getWeeklySchedule(groupId, week);
    if (scheduleResult case Err(:final error)) {
      return Result.err(error);
    }
    final schedule = (scheduleResult as Ok).value as List<ScheduleSlot>;

    // ✅ STEP 2: Search for existing slot at this datetime
    ScheduleSlot? existingSlot;
    for (final slot in schedule) {
      final slotDateTime = DateTime.parse(slot.datetime);
      // Compare datetimes at minute precision (ignore seconds/milliseconds)
      if (slotDateTime.year == datetime.year &&
          slotDateTime.month == datetime.month &&
          slotDateTime.day == datetime.day &&
          slotDateTime.hour == datetime.hour &&
          slotDateTime.minute == datetime.minute) {
        existingSlot = slot;
        _logger.info('Found existing slot: ${slot.id}');
        break;
      }
    }

    VehicleAssignmentDto vehicleAssignmentDto;

    if (existingSlot == null) {
      // ✅ STEP 3a: No slot exists → Create new slot with vehicle
      _logger.info('No existing slot found - creating new slot with vehicle');

      final createSlotRequest = api_requests.CreateScheduleSlotRequest(
        datetime: datetime.toIso8601String(),
        vehicleId: vehicleId,
      );

      final scheduleSlotDto = await ApiResponseHelper.executeAndUnwrap<ScheduleSlotDto>(
        () => _apiClient.createScheduleSlot(groupId, createSlotRequest),
      );

      // Extract the vehicle assignment from the response
      final vehicleAssignments = scheduleSlotDto.vehicleAssignments;
      if (vehicleAssignments == null || vehicleAssignments.isEmpty) {
        _logger.severe('No vehicle assignment returned from API');
        return Result.err(const ApiFailure(
          code: 'schedule.assign_vehicle_failed',
          message: 'No vehicle assignment returned from API',
          statusCode: 500,
        ));
      }

      vehicleAssignmentDto = vehicleAssignments.first;
    } else {
      // ✅ STEP 3b: Slot exists → Assign vehicle to existing slot
      _logger.info('Existing slot found - assigning vehicle to slot ${existingSlot.id}');

      // Check if vehicle is already assigned to this slot
      final isAlreadyAssigned = existingSlot.vehicleAssignments.any(
        (va) => va.vehicleId == vehicleId,
      );

      if (isAlreadyAssigned) {
        _logger.warning('Vehicle $vehicleId is already assigned to slot ${existingSlot.id}');
        return Result.err(ApiFailure.validationError(
          message: 'Vehicle is already assigned to this time slot',
        ));
      }

      final assignRequest = api_requests.AssignVehicleRequest(
        vehicleId: vehicleId,
      );

      vehicleAssignmentDto = await ApiResponseHelper.executeAndUnwrap<VehicleAssignmentDto>(
        () => _apiClient.assignVehicleToSlotTyped(existingSlot.id, assignRequest),
      );
    }

    final vehicleAssignment = _mapVehicleAssignmentDtoToDomain(vehicleAssignmentDto);
    _logger.info('Successfully assigned vehicle');
    return Result.ok(vehicleAssignment);
  } on ServerException catch (e) {
    _logger.severe('Server error assigning vehicle to slot: ${e.message}');
    return Result.err(ApiFailure.serverError(message: e.message));
  } on NetworkException catch (e) {
    _logger.severe('Network error assigning vehicle to slot: ${e.message}');
    return Result.err(ApiFailure.network(message: e.message));
  } catch (e) {
    _logger.severe('Unexpected error assigning vehicle to slot: $e');
    return Result.err(ApiFailure(
      code: 'schedule.assign_vehicle_failed',
      details: {'error': e.toString()},
      statusCode: 500,
    ));
  }
}
```

## Changes Required

### 1. Update Method Signature
Add `getWeeklySchedule` callback parameter to fetch current schedule:
```dart
Future<Result<VehicleAssignment, ApiFailure>> assignVehicleToSlot(
  String groupId,
  String day,
  String time,
  String week,
  String vehicleId,
  Future<Result<List<ScheduleSlot>, ApiFailure>> Function(String, String) getWeeklySchedule,
)
```

### 2. Update Repository to Pass Callback
```dart
// mobile_app/lib/features/schedule/data/repositories/schedule_repository.dart

@override
Future<Result<VehicleAssignment, ApiFailure>> assignVehicleToSlot(
  String groupId,
  String day,
  String time,
  String week,
  String vehicleId,
) async {
  return await _vehicleHandler.assignVehicleToSlot(
    groupId,
    day,
    time,
    week,
    vehicleId,
    (group, wk) => _basicHandler.getWeeklySchedule(group, wk), // ✅ Pass callback
  );
}
```

### 3. Update All Callers
No changes needed - the public interface remains the same. The callback is passed internally.

## Testing

### Test Case 1: Add first vehicle to empty slot
- **Setup**: No existing slot at Monday 08:00
- **Action**: Add Vehicle A
- **Expected**: Creates new slot with Vehicle A
- **Endpoint used**: `POST /groups/{groupId}/schedule-slots`

### Test Case 2: Add second vehicle to existing slot
- **Setup**: Slot exists at Monday 08:00 with Vehicle A
- **Action**: Add Vehicle B
- **Expected**: Assigns Vehicle B to existing slot (2 vehicles total)
- **Endpoint used**: `POST /schedule-slots/{slotId}/vehicles`

### Test Case 3: Prevent duplicate vehicle assignment
- **Setup**: Slot exists at Monday 08:00 with Vehicle A
- **Action**: Try to add Vehicle A again
- **Expected**: Returns validation error "Vehicle already assigned"

## Files to Modify

1. ✅ `/workspace/mobile_app/lib/features/schedule/data/repositories/handlers/vehicle_operations_handler.dart`
   - Modify `assignVehicleToSlot()` method

2. ✅ `/workspace/mobile_app/lib/features/schedule/data/repositories/schedule_repository.dart`
   - Update call to pass callback

## Benefits

1. ✅ **Matches web behavior exactly** - Uses same API sequence
2. ✅ **Supports multiple vehicles per slot** - No more conflicts
3. ✅ **Prevents duplicate assignments** - Checks before assigning
4. ✅ **Maintains backend compatibility** - Uses existing endpoints correctly
5. ✅ **No backend changes needed** - Backend already works correctly

## Verification

After implementing:
1. Add Vehicle A to Monday 08:00 → ✅ Should succeed
2. Add Vehicle B to Monday 08:00 → ✅ Should succeed (2 vehicles)
3. Add Vehicle A to Monday 08:00 again → ❌ Should show error message
4. Refresh schedule → ✅ Both vehicles should appear
