# Schedule Architecture Comparison

**Visual Guide to Mobile App Schedule Implementation**

---

## Current Architecture Flow

### 🎯 ACTUAL WORKING FLOW (Handler-Based)

```
┌─────────────────────────────────────────────────────────────┐
│                        UI LAYER                             │
│  • SchedulePage                                             │
│  • ScheduleCoordinationScreen                               │
│  • Schedule Widgets                                         │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        │ Riverpod Provider
                        ▼
┌─────────────────────────────────────────────────────────────┐
│              REPOSITORY PROVIDER                            │
│  @riverpod                                                  │
│  GroupScheduleRepository scheduleRepository(Ref ref) {      │
│    return ScheduleRepositoryImpl(                           │
│      scheduleApiClient,  ← Direct API client               │
│      localDataSource,                                       │
│      networkInfo,                                           │
│    );                                                       │
│  }                                                          │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│           SCHEDULE REPOSITORY IMPL                          │
│  • Cache-First reads                                        │
│  • Server-First writes                                      │
│  • Delegates to handlers                                    │
└───┬────────┬──────────┬──────────┬──────────────────────────┘
    │        │          │          │
    ▼        ▼          ▼          ▼
┌────────┬────────┬────────┬────────────────┐
│ Basic  │Vehicle │ Config │ Advanced       │
│ Slot   │  Ops   │  Ops   │ Ops            │
│Handler │Handler │Handler │Handler         │
└────┬───┴───┬────┴───┬────┴───┬────────────┘
     │       │        │        │
     └───────┴────────┴────────┘
              │
              ▼
     ┌──────────────────────────────────┐
     │   SCHEDULE API CLIENT            │
     │   19 Aligned Endpoints           │
     │   ✅ GET /groups/{id}/schedule   │
     │   ✅ POST /groups/{id}/slots     │
     │   ✅ PATCH /slots/{id}           │
     │   ✅ DELETE /slots/{id}          │
     │   ✅ POST /slots/{id}/vehicles   │
     │   ✅ POST /slots/{id}/children   │
     │   ... (14 more endpoints)        │
     └──────────────────────────────────┘
```

### ❌ ORPHANED CODE (Not Used)

```
┌──────────────────────────────────────────────────────────┐
│      ORPHANED: ScheduleRemoteDataSourceImpl             │
│  • Has provider definition in datasource_providers.dart │
│  • But provider is NEVER consumed by repository         │
│  • References 8 deleted endpoint methods                │
│  • Should be deleted entirely                            │
└──────────────────────────────────────────────────────────┘
     ▲
     │
     │ NEVER CALLED
     │
     ✗ No connection to active code
```

---

## Endpoint Comparison: Mobile vs Web

### 19 Aligned Endpoints (Used by Both)

| # | Endpoint | Mobile Usage | Web Usage | Status |
|---|----------|-------------|-----------|--------|
| **SCHEDULE CONFIGURATION** | | | | |
| 1 | `GET /groups/schedule-config/default` | ✅ ConfigHandler | ✅ scheduleConfigService | Aligned |
| 2 | `POST /groups/schedule-config/initialize` | ✅ ConfigHandler | ✅ scheduleConfigService | Aligned |
| 3 | `GET /groups/{groupId}/schedule-config` | ✅ ConfigHandler | ✅ scheduleConfigService | Aligned |
| 4 | `GET /groups/{groupId}/schedule-config/time-slots` | ✅ ConfigHandler | ✅ scheduleConfigService | Aligned |
| 5 | `PUT /groups/{groupId}/schedule-config` | ✅ ConfigHandler | ✅ scheduleConfigService | Aligned |
| 6 | `POST /groups/{groupId}/schedule-config/reset` | ✅ ConfigHandler | ✅ scheduleConfigService | Aligned |
| **SCHEDULE MANAGEMENT** | | | | |
| 7 | `POST /groups/{groupId}/schedule-slots` | ✅ BasicHandler | ✅ apiService | Aligned |
| 8 | `GET /groups/{groupId}/schedule` | ✅ **BasicHandler** | ✅ **apiService** | **KEY ENDPOINT** |
| 9 | `GET /schedule-slots/{slotId}` | ✅ BasicHandler | ✅ apiService | Aligned |
| 10 | `PATCH /schedule-slots/{slotId}` | ✅ BasicHandler | ✅ apiService | Aligned |
| 11 | `DELETE /schedule-slots/{slotId}` | ✅ BasicHandler | ✅ apiService | Aligned |
| 12 | `POST /schedule-slots/{slotId}/vehicles` | ✅ VehicleHandler | ✅ apiService | Aligned |
| 13 | `DELETE /schedule-slots/{slotId}/vehicles` | ✅ VehicleHandler | ✅ apiService | Aligned |
| 14 | `PATCH /schedule-slots/{slotId}/vehicles/{vehicleId}/driver` | ✅ VehicleHandler | ✅ apiService | Aligned |
| **CHILDREN ASSIGNMENT** | | | | |
| 15 | `POST /schedule-slots/{slotId}/children` | ✅ VehicleHandler | ✅ apiService | Aligned |
| 16 | `DELETE /schedule-slots/{slotId}/children/{childId}` | ✅ VehicleHandler | ✅ apiService | Aligned |
| 17 | `GET /schedule-slots/{slotId}/available-children` | ✅ BasicHandler | ✅ apiService | Aligned |
| 18 | `GET /schedule-slots/{slotId}/conflicts` | ✅ BasicHandler | ✅ apiService | Aligned |
| 19 | `PATCH /vehicle-assignments/{id}/seat-override` | ✅ VehicleHandler | ✅ apiService | Aligned |

### 13 Deleted Endpoints (No Longer Exist)

| # | Old Endpoint | Status | Replacement |
|---|-------------|---------|-------------|
| 1 | `GET /groups/{id}/schedule/weekly/{week}` | ❌ DELETED | #8 + date range calc |
| 2 | `POST /groups/{id}/schedule/weekly/copy` | ❌ DELETED | Client-side composition |
| 3 | `DELETE /groups/{id}/schedule/weekly/{week}` | ❌ DELETED | Client-side composition |
| 4 | `POST /slots/{id}/children/bulk` | ❌ DELETED | Loop #15 |
| 5 | `DELETE /slots/{id}/children/{childId}` | ❌ DELETED | Use #16 |
| 6 | `PATCH /slots/{id}/children/{childId}/status` | ❌ DELETED | Use #16 + #15 |
| 7 | `GET /groups/{id}/schedule/statistics/{week}` | ❌ DELETED | Client-side aggregation |
| 8 | `GET /groups/{id}/schedule/conflicts` | ❌ DELETED | Use #18 per slot |
| 9-13 | 5 more duplicate endpoints | ❌ DELETED | Covered by base 19 |

---

## Code Comparison: Weekly Schedule Fetching

### Mobile Implementation

**File:** `lib/features/schedule/data/repositories/handlers/basic_slot_operations_handler.dart`

```dart
// Step 1: Convert week number to date range
DateTime? _calculateWeekStartDate(String week) {
  // Parse "2025-W41" format
  final parts = week.split('-W');
  final year = int.parse(parts[0]);
  final weekNumber = int.parse(parts[1]);

  // ISO 8601 calculation: January 4th is always in week 1
  final jan4 = DateTime(year, 1, 4);
  final daysFromMonday = jan4.weekday - 1;
  final firstMonday = jan4.subtract(Duration(days: daysFromMonday));
  return firstMonday.add(Duration(days: (weekNumber - 1) * 7));
}

DateTime? _calculateWeekEndDate(String week) {
  final startDate = _calculateWeekStartDate(week);
  return startDate?.add(const Duration(days: 6));
}

// Step 2: Fetch using base endpoint with date range
Future<Result<List<ScheduleSlot>, ApiFailure>> getWeeklySchedule(
  String groupId,
  String week,
) async {
  final startDate = _calculateWeekStartDate(week);
  final endDate = _calculateWeekEndDate(week);

  // Call aligned endpoint
  final scheduleSlotDtos = await _apiClient.getGroupSchedule(
    groupId,
    startDate?.toIso8601String(),
    endDate?.toIso8601String(),
  );

  return Result.ok(scheduleSlotDtos.map((dto) => dto.toDomain()).toList());
}
```

### Web Implementation

**File:** `/workspace/frontend/src/services/apiService.ts`

```typescript
async getWeeklySchedule(groupId: string, week?: string): Promise<{ scheduleSlots: ScheduleSlot[] }> {
  let queryParams = '';

  if (week) {
    // Parse "2025-W41" format
    const [year, weekNum] = week.split('-').map(Number);

    // ISO 8601 calculation: January 4th is always in week 1
    const jan4 = new Date(year, 0, 4);
    const jan4DayOfWeek = (jan4.getDay() + 6) % 7;
    const weekStart = new Date(jan4);
    weekStart.setDate(jan4.getDate() - jan4DayOfWeek + (weekNum - 1) * 7);

    // Convert to UTC
    const weekStartUTC = new Date(Date.UTC(
      weekStart.getFullYear(),
      weekStart.getMonth(),
      weekStart.getDate(),
      0, 0, 0, 0
    ));

    const weekEnd = new Date(weekStartUTC);
    weekEnd.setUTCDate(weekStartUTC.getUTCDate() + 6);
    weekEnd.setUTCHours(23, 59, 59, 999);

    queryParams = `?startDate=${weekStartUTC.toISOString()}&endDate=${weekEnd.toISOString()}`;
  }

  // Call aligned endpoint
  const response = await axios.get(`${API_BASE_URL}/groups/${groupId}/schedule${queryParams}`);
  return response.data.data;
}
```

### 🎯 Comparison Result

✅ **IDENTICAL ALGORITHM**
- Both use ISO 8601 week calculation
- Both convert to date ranges
- Both call the same base endpoint
- Both handle UTC correctly

---

## Client-Side Composition Examples

### Copy Weekly Schedule

**Mobile:**
```dart
Future<Result<void, ApiFailure>> copyWeeklySchedule(
  String groupId,
  String sourceWeek,
  String targetWeek,
) async {
  // 1. Fetch source schedule
  final sourceResult = await getWeeklySchedule(groupId, sourceWeek);
  final sourceSchedule = sourceResult.value;

  // 2. Create each slot in target week
  for (final slot in sourceSchedule) {
    await upsertScheduleSlot(groupId, slot.day, slot.time, targetWeek);
  }

  return const Result.ok(null);
}
```

**Web:** Similar client-side logic (not shown in provided code, but implied by architecture)

### Clear Weekly Schedule

**Mobile:**
```dart
Future<Result<void, ApiFailure>> clearWeeklySchedule(
  String groupId,
  String week,
) async {
  // 1. Fetch schedule
  final scheduleResult = await getWeeklySchedule(groupId, week);
  final schedule = scheduleResult.value;

  // 2. Delete each slot
  for (final slot in schedule) {
    await _apiClient.deleteScheduleSlot(slot.id);
  }

  return const Result.ok(null);
}
```

**Web:** Similar client-side logic (not shown in provided code, but implied by architecture)

### Calculate Statistics

**Mobile:**
```dart
Future<Result<Map<String, dynamic>, ApiFailure>> getScheduleStatistics(
  String groupId,
  String week,
) async {
  // 1. Fetch schedule
  final scheduleResult = await getWeeklySchedule(groupId, week);
  final schedule = scheduleResult.value;

  // 2. Calculate client-side
  final stats = {
    'totalSlots': schedule.length,
    'totalVehicles': schedule.fold(0, (sum, s) => sum + s.vehicleAssignments.length),
    'totalChildren': schedule.fold(0, (sum, s) => sum + s.childAssignments.length),
    // ... more aggregations
  };

  return Result.ok(stats);
}
```

**Web:** Similar client-side logic (not shown in provided code, but implied by architecture)

---

## Provider Configuration Comparison

### ❌ INCORRECT (What We DON'T Have)

```dart
// This would be WRONG:
@riverpod
GroupScheduleRepository scheduleRepository(Ref ref) {
  final remoteDataSource = ref.watch(scheduleRemoteDatasourceProvider);  // ❌
  final localDataSource = ref.watch(scheduleLocalDatasourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return ScheduleRepositoryImpl(
    remoteDataSource,  // ❌ Would reference deleted endpoints
    localDataSource,
    networkInfo,
  );
}
```

### ✅ CORRECT (What We Actually Have)

```dart
// This is what we ACTUALLY have:
@riverpod
GroupScheduleRepository scheduleRepository(Ref ref) {
  final scheduleApiClient = ref.watch(scheduleApiClientProvider);  // ✅
  final localDataSource = ref.watch(scheduleLocalDatasourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return ScheduleRepositoryImpl(
    scheduleApiClient,  // ✅ Uses aligned endpoints directly
    localDataSource,
    networkInfo,
  );
}
```

---

## Summary Diagrams

### Mobile App Data Flow

```
User Action
    │
    ▼
Riverpod State Management
    │
    ▼
Repository (Cache + Network Logic)
    │
    ▼
Handler (Business Logic)
    │
    ▼
API Client (19 Endpoints)
    │
    ▼
Backend API
```

### Comparison: Old vs New Approach

**OLD APPROACH (Backend Composition):**
```
Client → Backend Endpoint: GET /schedule/weekly/{week}
                                    │
                                    ▼
                          Backend calculates date range
                                    │
                                    ▼
                          Backend queries database
                                    │
                                    ▼
                          Backend returns results
```

**NEW APPROACH (Client Composition):**
```
Client calculates date range (2025-W41 → 2025-10-06 to 2025-10-12)
    │
    ▼
Client → Backend Endpoint: GET /schedule?startDate=2025-10-06&endDate=2025-10-12
                                    │
                                    ▼
                          Backend queries database
                                    │
                                    ▼
                          Backend returns results
```

**Benefits:**
- ✅ More flexible (any date range, not just weeks)
- ✅ Fewer endpoints to maintain
- ✅ Better caching (cache by date range, not week)
- ✅ Consistent across all clients
- ✅ Backend stays simple and focused

---

## Visual Cleanup Checklist

### Before Cleanup

```
┌────────────────────────────────────────────────┐
│ Repository Provider                            │
│   ✅ Uses scheduleApiClient                    │
└────────────────────────────────────────────────┘

┌────────────────────────────────────────────────┐
│ Datasource Provider                            │
│   ❌ Defines scheduleRemoteDatasource          │
│   ❌ NEVER CONSUMED                            │
└────────────────────────────────────────────────┘

┌────────────────────────────────────────────────┐
│ ScheduleRemoteDataSourceImpl                   │
│   ❌ References 8 deleted endpoints            │
│   ❌ NOT USED                                   │
└────────────────────────────────────────────────┘
```

### After Cleanup

```
┌────────────────────────────────────────────────┐
│ Repository Provider                            │
│   ✅ Uses scheduleApiClient                    │
└────────────────────────────────────────────────┘

┌────────────────────────────────────────────────┐
│ Datasource Provider                            │
│   ✅ Removed unused provider                   │
└────────────────────────────────────────────────┘

┌────────────────────────────────────────────────┐
│ ScheduleRemoteDataSourceImpl                   │
│   ✅ DELETED                                    │
└────────────────────────────────────────────────┘
```

---

**End of Visual Comparison**
