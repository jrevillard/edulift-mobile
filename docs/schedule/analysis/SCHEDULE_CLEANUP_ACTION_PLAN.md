# Schedule Endpoint Cleanup - Quick Action Plan

**Date:** 2025-10-09
**Status:** ✅ Ready for Cleanup
**Estimated Time:** 5 minutes

---

## TL;DR

The mobile app **already uses the correct 19 aligned endpoints** via its handler-based architecture. We just need to remove obsolete legacy code that references the 13 deleted "weekly schedule" endpoints.

---

## What Needs to Be Done

### 1. Delete Orphaned Datasource File
```bash
rm lib/features/schedule/data/datasources/schedule_remote_datasource.dart
```

**Why:** This file references 8 deleted endpoint methods but is never used by the repository.

### 2. Clean Up Provider Registration

**File:** `lib/core/di/providers/data/datasource_providers.dart`

**Delete lines 60-73:**
```dart
/// ScheduleRemoteDataSource provider - real implementation
@riverpod
ScheduleRemoteDataSourceImpl scheduleRemoteDatasource(Ref ref) {
  final scheduleApiClient = ref.watch(scheduleApiClientProvider);
  final webSocketService = WebSocketService(
    ref.watch(adaptiveStorageServiceProvider),
    ref.watch(appConfigProvider),
  );
  return ScheduleRemoteDataSourceImpl(
    apiClient: scheduleApiClient,
    webSocketService: webSocketService,
  );
}
```

**Delete line 11:**
```dart
import '../../../../features/schedule/data/datasources/schedule_remote_datasource.dart';
```

### 3. Remove Export Statement

**File:** `lib/features/schedule/index.dart`

**Find and delete:**
```dart
export 'data/datasources/schedule_remote_datasource.dart';
```

### 4. Regenerate DI Code
```bash
cd /workspace/mobile_app
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. Verify No Errors
```bash
flutter analyze lib/features/schedule/
```

---

## Why This Is Safe

1. ✅ **Repository doesn't use the datasource** - It uses `ScheduleApiClient` directly
2. ✅ **Handlers already implement correct logic** - Using aligned 19 endpoints
3. ✅ **Provider is never consumed** - `scheduleRepository` never references it
4. ✅ **No UI impact** - All functionality works through handlers

---

## Architecture Proof

**Current Repository Provider** (`repository_providers.dart` lines 108-118):
```dart
@riverpod
GroupScheduleRepository scheduleRepository(Ref ref) {
  final scheduleApiClient = ref.watch(scheduleApiClientProvider);  // ✅ API client
  final localDataSource = ref.watch(scheduleLocalDatasourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return ScheduleRepositoryImpl(
    scheduleApiClient,    // ✅ NOT datasource!
    localDataSource,
    networkInfo,
  );
}
```

**Repository Constructor** (`schedule_repository_impl.dart` lines 36-45):
```dart
ScheduleRepositoryImpl(
  this._apiClient,           // ✅ Takes API client
  this._localDataSource,     // ✅ Takes local datasource (for cache)
  this._networkInfo,
) {
  _basicSlotHandler = handlers.BasicSlotOperationsHandler(_apiClient);
  _vehicleHandler = vehicle_handlers.VehicleOperationsHandler(_apiClient);
  _configHandler = config_handlers.ScheduleConfigOperationsHandler(_apiClient);
  _advancedHandler = advanced_handlers.AdvancedOperationsHandler(_apiClient);
}
```

**Conclusion:** The remote datasource is completely bypassed!

---

## What Already Works

### ✅ Weekly Schedule Fetching
**File:** `basic_slot_operations_handler.dart` (lines 49-107)

Uses `GET /groups/{groupId}/schedule` with date range query params, calculated from week number (e.g., "2025-W41").

### ✅ Copy Weekly Schedule
**File:** `basic_slot_operations_handler.dart` (lines 287-344)

Client-side composition:
1. Fetch source week schedule
2. Create each slot in target week using base endpoints

### ✅ Clear Weekly Schedule
**File:** `basic_slot_operations_handler.dart` (lines 346-393)

Client-side composition:
1. Fetch current week schedule
2. Delete each slot individually using `DELETE /schedule-slots/{slotId}`

### ✅ Schedule Statistics
**File:** `advanced_operations_handler.dart`

Client-side aggregation:
1. Fetch weekly schedule
2. Calculate statistics (total slots, vehicles, children, etc.)

### ✅ All Other Operations
- Create/update/delete slots ✅
- Assign/remove vehicles ✅
- Assign/remove children ✅
- Get available children ✅
- Check conflicts ✅
- Seat overrides ✅

---

## Verification Checklist

After cleanup:

- [ ] `flutter analyze` passes with no errors
- [ ] No references to `ScheduleRemoteDataSource` in codebase
- [ ] No references to `scheduleRemoteDatasource` provider
- [ ] Repository provider still creates `ScheduleRepositoryImpl` correctly
- [ ] Handler tests still pass
- [ ] Repository tests still pass

---

## Detailed Analysis

For a comprehensive analysis including:
- Complete endpoint mapping
- Web frontend comparison
- Code examples
- Testing strategy

See: `MOBILE_SCHEDULE_ENDPOINT_MIGRATION_ANALYSIS.md`

---

## Summary

**Before:**
```
Repository → ❌ Orphaned Datasource (references deleted endpoints) → API Client
```

**After (Already Implemented):**
```
Repository → Handlers → API Client (19 aligned endpoints) ✅
```

**Action Required:** Remove the orphaned datasource that's just sitting there unused.
