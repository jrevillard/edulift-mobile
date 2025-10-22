# Schedule API Alignment - Visual Diagram

## Endpoint Coverage Map

```
┌─────────────────────────────────────────────────────────────────┐
│                    SCHEDULE API CLIENT (Mobile)                  │
│                          32 Endpoints                             │
└─────────────────────────────────────────────────────────────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    │                           │
        ┌───────────▼───────────┐   ┌──────────▼──────────┐
        │   ALIGNED (19)        │   │  MISSING (13)        │
        │   ✅ 59%              │   │  ❌ 41%              │
        └───────────┬───────────┘   └──────────┬──────────┘
                    │                           │
        ┌───────────┴───────────────────────────┴──────────┐
        │                                                    │
┌───────▼────────┐  ┌────────────┐  ┌─────────────────────▼──────┐
│ Schedule       │  │ Schedule   │  │ Weekly Schedule (Missing)   │
│ Configuration  │  │ Management │  │                             │
│                │  │            │  │ • Week views (3 endpoints)  │
│ ✅ 6/6         │  │ ⚠️ 7/9     │  │ • Bulk operations (2)       │
│                │  │            │  │ • Child assignment (3)      │
│ • Default cfg  │  │ • Create   │  │ • Statistics (1)            │
│ • Initialize   │  │ • Get list │  │ • Duplicates (4)            │
│ • Get config   │  │ • Get one  │  │                             │
│ • Get slots    │  │ • Assign   │  │ Decision Required:          │
│ • Update       │  │ • Remove   │  │ □ Remove (4 hrs)            │
│ • Reset        │  │ • Update   │  │ □ Implement (60 hrs)        │
└────────────────┘  │            │  └─────────────────────────────┘
                    │ Missing:   │
                    │ • Update   │
                    │ • Delete   │
                    └────────────┘
                         │
          ┌──────────────┴──────────────┐
          │                             │
┌─────────▼──────────┐    ┌────────────▼────────────┐
│ Children           │    │ Advanced                 │
│ Assignment         │    │                          │
│                    │    │ ✅ 3/3                   │
│ ✅ 5/5             │    │                          │
│                    │    │ • Available children     │
│ • Assign child     │    │ • Get conflicts          │
│ • Remove child     │    │ • Update seat override   │
│ • Get available    │    │                          │
│ • Get conflicts    │    └──────────────────────────┘
│ • Update override  │
└────────────────────┘
```

---

## Request/Response Flow Analysis

### ✅ Aligned Endpoint Example

```
Mobile App                    Backend
    │                            │
    │  POST /schedule-slots/{id}/vehicles
    ├──────────────────────────→ │
    │  { vehicleId, driverId }   │
    │                            ├─ Validate auth token
    │                            ├─ Validate CUID format
    │                            ├─ Check vehicle ownership
    │                            ├─ Create assignment
    │                            ├─ Emit WebSocket event
    │                            │
    │  { success: true,          │
    │    data: {                 │
    │      id, vehicleId,        │
    │      driverId, ...         │
    │    }                       │
    │  }                         │
    │ ←──────────────────────────┤
    │                            │
    ├─ Dio interceptor           │
    │  unwraps "data" field      │
    │                            │
    ▼                            ▼
VehicleAssignmentDto       VehicleAssignment
```

---

## ❌ Misaligned Endpoint Example

### Issue: DELETE Vehicle Without Body

```
Mobile App                    Backend
    │                            │
    │  DELETE /schedule-slots/{id}/vehicles
    ├──────────────────────────→ │
    │  (no body)                 │
    │                            ├─ Validate auth token
    │                            ├─ Expect { vehicleId } ❌
    │                            │
    │  400 Bad Request           │
    │  { error: "vehicleId       │
    │    required" }             │
    │ ←──────────────────────────┤
    │                            │
    ▼                            ▼
  FAILS                       REJECTS
```

**Fix Required:**
```dart
// Mobile must send:
await client.removeVehicleFromSlotTyped(
  slotId,
  { 'vehicleId': vehicleId }  // ← Add this
);
```

---

## 🔄 Duplicate Endpoints

```
┌─────────────────────────────────────────────────┐
│  Mobile Client Has Duplicate Methods            │
├─────────────────────────────────────────────────┤
│                                                  │
│  #12: assignVehicleToSlotTyped(slotId, request) │
│       ↓ AssignVehicleRequest (typed)            │
│                                                  │
│  #25: assignVehicleToScheduleSlot(slotId, map)  │
│       ↓ Map<String, dynamic> (untyped)          │
│                                                  │
│  Both call: POST /schedule-slots/{id}/vehicles  │
│  ────────────────────────────────────────────── │
│                                                  │
│  #13: removeVehicleFromSlotTyped(slotId)        │
│       ↓ No body (missing vehicleId) ❌          │
│                                                  │
│  #26: removeVehicleFromScheduleSlot(slotId, map)│
│       ↓ Map<String, dynamic> (with vehicleId)   │
│                                                  │
│  Both call: DELETE /schedule-slots/{id}/vehicles│
│  ────────────────────────────────────────────── │
│                                                  │
│  #5:  updateGroupScheduleConfigTyped(id, req)   │
│       ↓ UpdateScheduleConfigRequest (typed)     │
│                                                  │
│  #30: updateGroupScheduleConfig(id, map)        │
│       ↓ Map<String, dynamic> (untyped)          │
│                                                  │
│  Both call: PUT /groups/{id}/schedule-config    │
│                                                  │
└─────────────────────────────────────────────────┘

Recommendation: Keep ONLY typed versions (#12, #13, #5)
                Remove untyped duplicates (#25, #26, #30)
```

---

## Backend Response Wrapper Pattern

### All Backend Endpoints Return:

```typescript
interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  validationErrors?: Array<{
    field: string;
    message: string;
  }>;
}
```

### Mobile Client Expects Direct DTO:

```dart
// Mobile expects this:
ScheduleSlotDto slot = await client.getScheduleSlot(slotId);

// Backend returns this:
{
  "success": true,
  "data": {
    "id": "...",
    "groupId": "...",
    "datetime": "...",
    ...
  }
}

// Dio interceptor MUST unwrap "data" field:
return response.data['data']; // ← Critical
```

**Verification Needed:**
- [ ] Confirm Dio interceptor unwraps ApiResponse.data
- [ ] Test all 19 aligned endpoints
- [ ] Handle error responses correctly

---

## Missing Weekly Schedule Feature Architecture

### Proposed Backend Structure (If Implementing)

```
┌──────────────────────────────────────────────────┐
│         /groups/{groupId}/schedule/*             │
├──────────────────────────────────────────────────┤
│                                                   │
│  GET    /week/{week}                             │
│         → GroupWeeklyScheduleDto                 │
│         → All slots for week (Mon-Sun)           │
│                                                   │
│  GET    /available-children?week&day&time        │
│         → AvailableChildrenDto                   │
│         → Children not assigned at that time     │
│                                                   │
│  POST   /conflicts                               │
│         → ScheduleConflictsDto                   │
│         → Check child/vehicle conflicts          │
│                                                   │
│  POST   /copy                                    │
│         → void                                   │
│         → Clone week {source} to {target}        │
│                                                   │
│  POST   /slots                                   │
│         → ScheduleSlotDto                        │
│         → Upsert (create or update)              │
│                                                   │
│  DELETE /week/{week}                             │
│         → void                                   │
│         → Delete all slots in week               │
│                                                   │
│  GET    /statistics?week                         │
│         → ScheduleStatisticsDto                  │
│         → Coverage, utilization, etc.            │
│                                                   │
└──────────────────────────────────────────────────┘

Required New Backend Components:
- WeeklyScheduleController (new)
- WeeklyScheduleService (new)
- Week number calculation utilities
- Bulk operations support
- Statistics calculation logic

Estimated: 40-60 hours implementation
```

---

## Authentication Flow

```
┌─────────────────────────────────────────────────┐
│             All Schedule Endpoints               │
└─────────────────────────────────────────────────┘
                     │
                     ▼
          ┌──────────────────────┐
          │  authenticateToken   │
          │  (middleware)        │
          └──────────┬───────────┘
                     │
        ┌────────────┼────────────┐
        │                         │
        ▼                         ▼
┌──────────────┐        ┌──────────────────┐
│ Member       │        │ Admin            │
│ Access       │        │ Access           │
│              │        │                  │
│ • Get config │        │ • Update config  │
│ • Get slots  │        │ • Reset config   │
│ • Get list   │        │ • Delete slots   │
│ • View       │        │ • Manage all     │
└──────────────┘        └──────────────────┘
```

**Mobile Client:**
- Assumes Dio interceptor adds `Authorization: Bearer {token}`
- Must handle 401 (expired token) → refresh → retry
- Must handle 403 (forbidden) → insufficient permissions

---

## WebSocket Real-Time Updates

### Backend Emits (Currently Implemented)

```
Schedule Slot Created
  ↓
  schedule-slot-created
  { groupId, slotId, slot }
  ↓
  schedule-update
  { groupId }

Schedule Slot Updated
  ↓
  schedule-slot-update
  { groupId, slotId, changes }
  ↓
  schedule-update
  { groupId }

Schedule Slot Deleted
  ↓
  schedule-slot-deleted
  { groupId, slotId }
  ↓
  schedule-update
  { groupId }
```

### Mobile Client (Missing?)

```
❓ WebSocket listeners not found in API client

Should implement:
- Listen to 'schedule-update' → refresh schedule list
- Listen to 'schedule-slot-update' → update specific slot
- Listen to 'schedule-slot-deleted' → remove from UI
- Listen to 'schedule-slot-created' → add to UI

Enables:
- Real-time collaborative editing
- Instant conflict detection
- Optimistic UI updates with server reconciliation
```

---

## Recommendation Flow Chart

```
                    START
                      │
                      ▼
        ┌─────────────────────────┐
        │ Do you need weekly      │
        │ schedule feature?       │
        └─────────┬───────────────┘
                  │
         ┌────────┴────────┐
         │                 │
        YES               NO
         │                 │
         ▼                 ▼
    ┌─────────┐      ┌──────────┐
    │Implement│      │ Remove   │
    │Backend  │      │13 methods│
    │60 hrs   │      │ 4 hrs    │
    └────┬────┘      └─────┬────┘
         │                 │
         └────────┬────────┘
                  │
                  ▼
        ┌─────────────────────────┐
        │ Fix Critical Issues:    │
        │ 1. DELETE vehicle body  │
        │ 2. Remove duplicates    │
        │ 3. Verify unwrapping    │
        └────────┬────────────────┘
                 │
                 ▼
        ┌─────────────────────────┐
        │ Add Integration Tests   │
        │ (8-12 hours)            │
        └────────┬────────────────┘
                 │
                 ▼
        ┌─────────────────────────┐
        │ Optional Improvements:  │
        │ • Standardize params    │
        │ • Add WebSocket         │
        │ • Client validation     │
        └────────┬────────────────┘
                 │
                 ▼
               DONE
```

---

## Priority Matrix

```
┌────────────────────────────────────────────────────────┐
│                    IMPACT vs EFFORT                     │
│                                                         │
│  High Impact  │                                         │
│               │  ● Fix DELETE       ● Weekly Schedule  │
│               │    vehicle body       Decision         │
│               │    (30 min)           (4 or 60 hrs)    │
│               │                                         │
│               │  ● Remove           ● Integration      │
│               │    duplicates         Tests            │
│               │    (1 hr)             (8-12 hrs)       │
│  ────────────┼─────────────────────────────────────────│
│               │                                         │
│               │  ● Standardize      ● WebSocket        │
│               │    params             listeners        │
│               │    (2 hrs)            (8 hrs)          │
│               │                                         │
│  Low Impact   │  ● Documentation                       │
│               │    (2 hrs)                              │
│               │                                         │
│               └─────────────────────────────────────────│
│                     Low Effort      High Effort        │
└────────────────────────────────────────────────────────┘

Do First:  ● Fix DELETE vehicle body (Critical bug)
Do Next:   ● Weekly Schedule Decision (Blocks other work)
Do Soon:   ● Remove duplicates, Integration tests
Do Later:  ● WebSocket, Standardization, Docs
```

---

**Last Updated:** 2025-10-09
**See Also:**
- SCHEDULE_API_ALIGNMENT_REPORT.md (Full details)
- SCHEDULE_API_ALIGNMENT_SUMMARY.md (Quick reference)
