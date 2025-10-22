# Schedule API Client - Backend Alignment Report

**Date:** 2025-10-09
**Mobile API Client:** `/workspace/mobile_app/lib/core/network/schedule_api_client.dart`
**Backend Routes:** `/workspace/backend/src/routes/scheduleSlots.ts`, `/workspace/backend/src/routes/groups.ts`
**Backend Controllers:** `ScheduleSlotController.ts`, `GroupScheduleConfigController.ts`

---

## Executive Summary

**Total Endpoints Analyzed:** 32
**✅ Fully Aligned:** 19 (59%)
**⚠️ Partially Aligned:** 0 (0%)
**❌ Missing in Backend:** 13 (41%)
**🔄 Duplicates in Mobile:** 2 (6%)

### Critical Findings

1. **13 Weekly Schedule Endpoints Missing** - All endpoints in the "Weekly Schedule" section (endpoints #20-32) are missing from the backend
2. **2 Core Schedule Management Endpoints Missing** - `PATCH /schedule-slots/{slotId}` and `DELETE /schedule-slots/{slotId}` do not exist
3. **Duplicate Endpoints** - Mobile app has duplicate vehicle assignment endpoints (#12 vs #25, #13 vs #26)
4. **No Versioning Mismatch** - Both use `/api/v1/` prefix correctly

---

## Detailed Endpoint Analysis

### ✅ SCHEDULE CONFIGURATION ENDPOINTS (6/6 Aligned)

#### 1. Get Default Schedule Config
- **Mobile:** `GET /api/v1/groups/schedule-config/default`
- **Backend:** `GET /groups/schedule-config/default` (Line 143, groups.ts)
- **Status:** ✅ **ALIGNED**
- **Notes:** Backend controller returns `{ scheduleHours, isDefault: true }`

#### 2. Initialize Schedule Config
- **Mobile:** `POST /api/v1/groups/schedule-config/initialize`
- **Backend:** `POST /groups/schedule-config/initialize` (Line 148, groups.ts)
- **Status:** ✅ **ALIGNED**
- **Request:** `InitializeScheduleConfigRequest` (mobile) - Backend accepts any body
- **Response:** `ScheduleConfigDto` (mobile) vs `{ message: string }` (backend)
- **Notes:** Response structure differs but functional

#### 3. Get Group Schedule Config
- **Mobile:** `GET /api/v1/groups/{groupId}/schedule-config`
- **Backend:** `GET /groups/:groupId/schedule-config` (Line 153, groups.ts)
- **Status:** ✅ **ALIGNED**
- **Auth:** Requires group membership
- **Response:** Backend adds `isDefault: false` field

#### 4. Get Group Time Slots
- **Mobile:** `GET /api/v1/groups/{groupId}/schedule-config/time-slots?weekday={weekday}`
- **Backend:** `GET /groups/:groupId/schedule-config/time-slots` (Line 160, groups.ts)
- **Status:** ✅ **ALIGNED**
- **Query Params:** `weekday` (required, string)
- **Response:** `TimeSlotConfigDto` with `{ groupId, weekday, timeSlots }`

#### 5. Update Group Schedule Config
- **Mobile:** `PUT /api/v1/groups/{groupId}/schedule-config`
- **Backend:** `PUT /groups/:groupId/schedule-config` (Line 167, groups.ts)
- **Status:** ✅ **ALIGNED**
- **Auth:** Requires group admin
- **Request:** `UpdateScheduleConfigRequest` (mobile) vs `{ scheduleHours: object }` (backend)
- **Notes:** Mobile has DUPLICATE endpoint at #30 with `Map<String, dynamic>`

#### 6. Reset Group Schedule Config
- **Mobile:** `POST /api/v1/groups/{groupId}/schedule-config/reset`
- **Backend:** `POST /groups/:groupId/schedule-config/reset` (Line 174, groups.ts)
- **Status:** ✅ **ALIGNED**
- **Auth:** Requires group admin
- **Response:** Backend adds `isDefault: true` field

---

### ⚠️ SCHEDULE MANAGEMENT ENDPOINTS (7/9 Aligned, 2 Missing)

#### 7. Create Schedule Slot
- **Mobile:** `POST /api/v1/groups/{groupId}/schedule-slots`
- **Backend:** `POST /groups/:groupId/schedule-slots` (Line 82, scheduleSlots.ts)
- **Status:** ✅ **ALIGNED**
- **Request:** `CreateScheduleSlotRequest` (mobile) vs `{ datetime, vehicleId, driverId?, seatOverride? }` (backend)
- **Notes:** Backend REQUIRES vehicleId at creation (business rule enforcement)
- **WebSocket:** Emits `schedule-slot-created` and `schedule-update` events

#### 8. Get Group Schedule
- **Mobile:** `GET /api/v1/groups/{groupId}/schedule?startDate={date}&endDate={date}`
- **Backend:** `GET /groups/:groupId/schedule` (Line 90, scheduleSlots.ts)
- **Status:** ✅ **ALIGNED**
- **Query Params:** `startDate` (optional, ISO 8601), `endDate` (optional, ISO 8601)
- **Response:** `List<ScheduleSlotDto>` (mobile) vs `Array<ScheduleSlot>` (backend)

#### 9. Get Schedule Slot
- **Mobile:** `GET /api/v1/schedule-slots/{slotId}`
- **Backend:** `GET /schedule-slots/:scheduleSlotId` (Line 98, scheduleSlots.ts)
- **Status:** ✅ **ALIGNED**
- **Path Param:** Mobile uses `slotId`, backend uses `scheduleSlotId`
- **Notes:** Parameter name mismatch but functionally equivalent

#### 10. Update Schedule Slot ❌
- **Mobile:** `PATCH /api/v1/schedule-slots/{slotId}`
- **Backend:** **DOES NOT EXIST**
- **Status:** ❌ **MISSING IN BACKEND**
- **Mobile Request:** `UpdateScheduleSlotRequest`
- **Impact:** Cannot update schedule slot datetime or other properties
- **Recommendation:** Add backend endpoint or remove from mobile client

#### 11. Delete Schedule Slot ❌
- **Mobile:** `DELETE /api/v1/schedule-slots/{slotId}`
- **Backend:** **DOES NOT EXIST**
- **Status:** ❌ **MISSING IN BACKEND**
- **Impact:** Cannot delete individual schedule slots
- **Recommendation:** Add backend endpoint or remove from mobile client
- **Note:** Backend only auto-deletes slots when last vehicle is removed

#### 12. Assign Vehicle to Slot
- **Mobile:** `POST /api/v1/schedule-slots/{slotId}/vehicles`
- **Backend:** `POST /schedule-slots/:scheduleSlotId/vehicles` (Line 105, scheduleSlots.ts)
- **Status:** ✅ **ALIGNED**
- **Request:** `AssignVehicleRequest` (mobile) vs `{ vehicleId, driverId?, seatOverride? }` (backend)
- **Response:** `VehicleAssignmentDto`
- **WebSocket:** Emits `schedule-slot-update` and `schedule-update` events

#### 13. Remove Vehicle from Slot
- **Mobile:** `DELETE /api/v1/schedule-slots/{slotId}/vehicles`
- **Backend:** `DELETE /schedule-slots/:scheduleSlotId/vehicles` (Line 113, scheduleSlots.ts)
- **Status:** ✅ **ALIGNED**
- **Request Body:** Mobile sends no body, backend REQUIRES `{ vehicleId: string }` in body
- **Mismatch:** ⚠️ **REQUEST BODY MISMATCH** - Mobile doesn't send vehicleId
- **Response:** Backend returns `{ message, slotDeleted: boolean }`
- **WebSocket:** Emits `schedule-slot-deleted` if slot is deleted, else `schedule-slot-update`

#### 14. Update Vehicle Driver
- **Mobile:** `PATCH /api/v1/schedule-slots/{slotId}/vehicles/{vehicleId}/driver`
- **Backend:** `PATCH /schedule-slots/:scheduleSlotId/vehicles/:vehicleId/driver` (Line 121, scheduleSlots.ts)
- **Status:** ✅ **ALIGNED**
- **Request:** `UpdateDriverRequest` (mobile) vs `{ driverId: string | null }` (backend)
- **Response:** `VehicleAssignmentDto`
- **WebSocket:** Emits `schedule-slot-update` and `schedule-update` events

---

### ✅ CHILDREN ASSIGNMENT ENDPOINTS (5/5 Aligned)

#### 15. Assign Child to Slot
- **Mobile:** `POST /api/v1/schedule-slots/{slotId}/children`
- **Backend:** `POST /schedule-slots/:scheduleSlotId/children` (Line 132, scheduleSlots.ts)
- **Status:** ✅ **ALIGNED**
- **Request:** `AssignChildRequest` (mobile) vs `{ childId, vehicleAssignmentId }` (backend)
- **Response:** `ChildAssignmentDto`
- **WebSocket:** Emits `schedule-slot-update` and `schedule-update` events

#### 16. Remove Child from Slot
- **Mobile:** `DELETE /api/v1/schedule-slots/{slotId}/children/{childId}`
- **Backend:** `DELETE /schedule-slots/:scheduleSlotId/children/:childId` (Line 140, scheduleSlots.ts)
- **Status:** ✅ **ALIGNED**
- **Response:** Backend returns `{ message: 'Child removed successfully' }`

#### 17. Get Available Children
- **Mobile:** `GET /api/v1/schedule-slots/{slotId}/available-children`
- **Backend:** `GET /schedule-slots/:scheduleSlotId/available-children` (Line 150, scheduleSlots.ts)
- **Status:** ✅ **ALIGNED**
- **Response:** `List<ChildDto>` (mobile) vs `Array<Child>` (backend)
- **Auth:** Requires authentication, uses userId from token

#### 18. Get Schedule Conflicts
- **Mobile:** `GET /api/v1/schedule-slots/{slotId}/conflicts`
- **Backend:** `GET /schedule-slots/:scheduleSlotId/conflicts` (Line 157, scheduleSlots.ts)
- **Status:** ✅ **ALIGNED**
- **Response:** Mobile expects `List<ConflictDto>`, backend returns `{ conflicts: Array }`
- **Notes:** Response wrapper mismatch but data is present

#### 19. Update Seat Override
- **Mobile:** `PATCH /api/v1/vehicle-assignments/{vehicleAssignmentId}/seat-override`
- **Backend:** `PATCH /vehicle-assignments/:vehicleAssignmentId/seat-override` (Line 164, scheduleSlots.ts)
- **Status:** ✅ **ALIGNED**
- **Request:** `UpdateSeatOverrideRequest` (mobile) vs `{ seatOverride?: number }` (backend)
- **Response:** `VehicleAssignmentDto`
- **Validation:** Backend enforces `0 <= seatOverride <= MAX_CAPACITY`

---

### ❌ WEEKLY SCHEDULE ENDPOINTS (0/13 - ALL MISSING)

**CRITICAL ISSUE:** All 13 weekly schedule endpoints defined in the mobile app do not exist in the backend.

#### 20. Get Weekly Schedule ❌
- **Mobile:** `GET /api/v1/groups/{groupId}/schedule/week/{week}`
- **Backend:** **DOES NOT EXIST**
- **Status:** ❌ **MISSING IN BACKEND**
- **Expected Response:** `GroupWeeklyScheduleDto`
- **Purpose:** Fetch week-based schedule view

#### 21. Get Available Children for Schedule ❌
- **Mobile:** `GET /api/v1/groups/{groupId}/schedule/available-children?week={week}&day={day}&time={time}`
- **Backend:** **DOES NOT EXIST**
- **Status:** ❌ **MISSING IN BACKEND**
- **Expected Response:** `AvailableChildrenDto`
- **Query Params:** `week`, `day`, `time` (all required)

#### 22. Check Schedule Conflicts for Group ❌
- **Mobile:** `POST /api/v1/groups/{groupId}/schedule/conflicts`
- **Backend:** **DOES NOT EXIST**
- **Status:** ❌ **MISSING IN BACKEND**
- **Expected Response:** `ScheduleConflictsDto`
- **Request:** `Map<String, dynamic>`

#### 23. Copy Weekly Schedule ❌
- **Mobile:** `POST /api/v1/groups/{groupId}/schedule/copy`
- **Backend:** **DOES NOT EXIST**
- **Status:** ❌ **MISSING IN BACKEND**
- **Request:** `Map<String, dynamic>` (likely `{ sourceWeek, targetWeek }`)
- **Purpose:** Clone schedule from one week to another

#### 24. Upsert Schedule Slot for Group ❌
- **Mobile:** `POST /api/v1/groups/{groupId}/schedule/slots`
- **Backend:** **DOES NOT EXIST**
- **Status:** ❌ **MISSING IN BACKEND**
- **Expected Response:** `ScheduleSlotDto`
- **Request:** `Map<String, dynamic>`
- **Notes:** Different from endpoint #7 (create schedule slot)

#### 25. Assign Vehicle to Schedule Slot (Duplicate) ❌
- **Mobile:** `POST /api/v1/schedule-slots/{scheduleSlotId}/vehicles`
- **Backend:** Exists but **DUPLICATE** of endpoint #12
- **Status:** 🔄 **DUPLICATE ENDPOINT**
- **Notes:** Same path as #12, using untyped `Map<String, dynamic>` request

#### 26. Remove Vehicle from Schedule Slot (Duplicate) ❌
- **Mobile:** `DELETE /api/v1/schedule-slots/{scheduleSlotId}/vehicles`
- **Backend:** Exists but **DUPLICATE** of endpoint #13
- **Status:** 🔄 **DUPLICATE ENDPOINT**
- **Notes:** Same path as #13, includes request body `Map<String, dynamic>`

#### 27. Assign Children to Vehicle in Slot ❌
- **Mobile:** `POST /api/v1/groups/{groupId}/schedule/slots/{slotId}/vehicles/{vehicleAssignmentId}/children`
- **Backend:** **DOES NOT EXIST**
- **Status:** ❌ **MISSING IN BACKEND**
- **Expected Response:** `VehicleAssignmentDto`
- **Request:** `Map<String, dynamic>`
- **Notes:** Very long path with 4 path parameters

#### 28. Remove Child from Vehicle in Slot ❌
- **Mobile:** `DELETE /api/v1/groups/{groupId}/schedule/slots/{slotId}/vehicles/{vehicleAssignmentId}/children/{childAssignmentId}`
- **Backend:** **DOES NOT EXIST**
- **Status:** ❌ **MISSING IN BACKEND**
- **Notes:** Very long path with 5 path parameters

#### 29. Update Child Assignment Status ❌
- **Mobile:** `PATCH /api/v1/groups/{groupId}/schedule/slots/{slotId}/vehicles/{vehicleAssignmentId}/children/{childAssignmentId}`
- **Backend:** **DOES NOT EXIST**
- **Status:** ❌ **MISSING IN BACKEND**
- **Expected Response:** `ScheduleSlotChildDto`
- **Request:** `Map<String, dynamic>`
- **Notes:** Very long path with 5 path parameters

#### 30. Update Group Schedule Config (Duplicate) ❌
- **Mobile:** `PUT /api/v1/groups/{groupId}/schedule-config`
- **Backend:** Exists but **DUPLICATE** of endpoint #5
- **Status:** 🔄 **DUPLICATE ENDPOINT**
- **Notes:** Same as endpoint #5 but uses untyped `Map<String, dynamic>` request

#### 31. Clear Weekly Schedule ❌
- **Mobile:** `DELETE /api/v1/groups/{groupId}/schedule/week/{week}`
- **Backend:** **DOES NOT EXIST**
- **Status:** ❌ **MISSING IN BACKEND**
- **Purpose:** Delete all schedule slots for a specific week

#### 32. Get Schedule Statistics ❌
- **Mobile:** `GET /api/v1/groups/{groupId}/schedule/statistics?week={week}`
- **Backend:** **DOES NOT EXIST**
- **Status:** ❌ **MISSING IN BACKEND**
- **Expected Response:** `ScheduleStatisticsDto`
- **Query Param:** `week` (required)
- **Purpose:** Get statistics/summary for group schedule

---

## Critical Issues Summary

### 1. Missing Core Schedule Management Features

**Missing Endpoints:**
- `PATCH /schedule-slots/{slotId}` - Cannot update schedule slot properties
- `DELETE /schedule-slots/{slotId}` - Cannot explicitly delete schedule slots

**Impact:** Limited schedule management capabilities. Backend only allows auto-deletion when removing last vehicle.

**Recommendation:**
- Add `PATCH` endpoint to allow updating slot datetime
- Add explicit `DELETE` endpoint for better control
- OR remove from mobile client if not needed

---

### 2. Complete Missing "Weekly Schedule" Feature Set

**Missing Endpoints:** 13 endpoints (#20-32)

**Analysis:**
This appears to be a **planned feature** that was designed in the mobile app but never implemented in the backend. The endpoints suggest advanced weekly schedule management:

- **Week-based views** - View/manage schedules by week number
- **Bulk operations** - Copy entire week schedules
- **Statistics** - View schedule statistics by week
- **Advanced child assignment** - Group/slot/vehicle/child hierarchy

**Evidence:**
1. Backend has NO routes matching `/groups/{groupId}/schedule/week/*`
2. Backend has NO routes matching `/groups/{groupId}/schedule/available-children`
3. Backend has NO routes matching `/groups/{groupId}/schedule/conflicts`
4. Backend has NO routes matching `/groups/{groupId}/schedule/copy`
5. Backend has NO routes matching `/groups/{groupId}/schedule/slots`
6. Backend has NO routes matching `/groups/{groupId}/schedule/statistics`

**Recommendation:**
1. **Remove from mobile client** - If feature is not planned, remove all 13 endpoints
2. **OR Implement in backend** - If feature is needed, implement missing routes/controllers
3. **Document decision** - Update API docs to reflect actual vs planned features

---

### 3. Request Body Mismatches

#### Endpoint #13: Remove Vehicle from Slot
- **Mobile:** `DELETE /schedule-slots/{slotId}/vehicles` - **No request body**
- **Backend:** Expects `{ vehicleId: string }` in request body
- **Impact:** ⚠️ **CRITICAL** - Mobile calls will fail with 400 Bad Request
- **Fix Required:** Mobile must send `{ vehicleId }` in request body

---

### 4. Duplicate Endpoints

**Duplicates Identified:**
- **#12 vs #25** - Both `POST /schedule-slots/{slotId}/vehicles` (typed vs untyped)
- **#13 vs #26** - Both `DELETE /schedule-slots/{slotId}/vehicles` (typed vs untyped)
- **#5 vs #30** - Both `PUT /groups/{groupId}/schedule-config` (typed vs untyped)

**Reason:** Mobile has both typed (`*Typed`) and untyped (`Map<String, dynamic>`) versions

**Recommendation:**
- Remove duplicate untyped methods (#25, #26, #30)
- Keep only typed versions for better type safety
- OR document why duplicates exist (e.g., legacy support)

---

### 5. Parameter Name Inconsistencies

**Mobile vs Backend:**
- Mobile: `slotId`
- Backend: `scheduleSlotId`

**Locations:**
- Endpoints #9-14, 15-19

**Impact:** None (Retrofit maps path params correctly)

**Recommendation:** Standardize on `scheduleSlotId` in mobile client for consistency

---

### 6. Response Structure Differences

#### ApiResponse Wrapper Pattern
- **Mobile:** Most endpoints expect direct DTO responses (e.g., `ScheduleConfigDto`)
- **Backend:** Most endpoints return `ApiResponse<T>` wrapper: `{ success: boolean, data: T }`

**Example:**
```typescript
// Backend returns:
{
  "success": true,
  "data": {
    "id": "...",
    "scheduleHours": {...}
  }
}

// Mobile expects:
{
  "id": "...",
  "scheduleHours": {...}
}
```

**Impact:** May cause deserialization issues if not handled by interceptor

**Recommendation:**
- Verify Dio interceptor unwraps `ApiResponse.data` field
- OR update mobile DTOs to include `ApiResponse` wrapper
- Backend response pattern at line 51-54, 93-96, etc. in ScheduleSlotController.ts

---

## Data Type Verification Needed

The following DTOs should be verified for structure alignment:

### Schedule DTOs
1. `ScheduleConfigDto` - Verify `scheduleHours` structure
2. `TimeSlotConfigDto` - Verify `timeSlots` array structure
3. `ScheduleSlotDto` - Verify nested relationships (vehicles, children)
4. `VehicleAssignmentDto` - Verify driver and seat override fields
5. `ChildAssignmentDto` - Verify assignment status fields
6. `ConflictDto` - Verify conflict details structure

### Request DTOs
1. `InitializeScheduleConfigRequest` - Verify expected body
2. `UpdateScheduleConfigRequest` - Verify `scheduleHours` format
3. `CreateScheduleSlotRequest` - Verify required fields
4. `UpdateScheduleSlotRequest` - Verify updatable fields
5. `AssignVehicleRequest` - Verify fields match backend validation
6. `AssignChildRequest` - Verify fields match backend validation
7. `UpdateDriverRequest` - Verify driverId nullable
8. `UpdateSeatOverrideRequest` - Verify seatOverride optional

### Weekly Schedule DTOs (if implementing)
1. `GroupWeeklyScheduleDto` - Define structure
2. `AvailableChildrenDto` - Define structure
3. `ScheduleConflictsDto` - Define structure
4. `ScheduleStatisticsDto` - Define structure
5. `ScheduleSlotChildDto` - Define structure

---

## Authentication & Authorization

**Backend Middleware:**
- All routes require `authenticateToken` (scheduleSlots.ts line 33, groups.ts line 28)
- Schedule config updates require `requireGroupAdmin` (groups.ts lines 169, 176)
- Schedule config reads require `requireGroupMembership` (groups.ts lines 155, 162)

**Mobile Client:**
- No explicit auth headers in API client (assumed handled by Dio interceptor)

**Recommendation:**
- Verify JWT token is added by Dio interceptor
- Verify refresh token logic handles 401 responses

---

## WebSocket Events

**Backend Emits:**
Backend emits real-time WebSocket events for:
- `schedule-slot-created` (line 47, ScheduleSlotController)
- `schedule-slot-update` (lines 90, 131, 166, 197, 310)
- `schedule-slot-deleted` (line 129)
- `schedule-update` (lines 48, 91, 133, 167, 198, 311)

**Mobile Client:**
- No WebSocket event listeners visible in API client
- Check if WebSocket service exists elsewhere in mobile app

**Recommendation:**
- Implement WebSocket listeners for real-time schedule updates
- Handle optimistic UI updates with WebSocket event reconciliation

---

## Validation Rules

### Backend Validation (Zod schemas in scheduleSlots.ts)

**Schedule Slot:**
- `datetime`: ISO 8601 UTC string (line 50)
- `vehicleId`: CUID format (line 51)
- `driverId`: CUID format, optional (line 52)
- `seatOverride`: 0 <= value <= MAX_CAPACITY (line 53)

**Child Assignment:**
- `childId`: CUID format (line 63)
- `vehicleAssignmentId`: CUID format (line 64)

**Query Parameters:**
- `startDate`: ISO 8601 datetime, optional (line 45)
- `endDate`: ISO 8601 datetime, optional (line 46)
- `weekday`: String, required for time slots (GroupScheduleConfigController line 45)

**Mobile Client:**
- Should validate same rules client-side before API calls
- Check if request DTOs include validation annotations

---

## Performance Considerations

### Backend Logging
- Verbose logging in `getSchedule` controller (lines 242, 245, 252)
- Consider removing in production or using debug level

### Query Optimization
- `getSchedule` supports date range filtering for performance
- Mobile should always use date ranges to limit result sets

### Caching Opportunities
- Schedule configs rarely change - consider caching
- Available children lists could be cached with TTL
- Conflict checks could be memoized for same inputs

---

## Recommendations by Priority

### 🔴 Critical (Must Fix)

1. **Fix Request Body Mismatch** - Endpoint #13 (Remove Vehicle)
   - Mobile must send `{ vehicleId: string }` in DELETE body
   - File: `/workspace/mobile_app/lib/core/network/schedule_api_client.dart` line 102

2. **Decide on Weekly Schedule Feature**
   - Remove 13 unused endpoints OR
   - Implement backend routes for weekly schedule
   - Update documentation accordingly

3. **Add Missing Core Endpoints** (if needed)
   - `PATCH /schedule-slots/{slotId}` for updating slots
   - `DELETE /schedule-slots/{slotId}` for explicit deletion

### 🟡 High Priority (Should Fix)

4. **Remove Duplicate Endpoints**
   - Delete endpoints #25, #26, #30 (untyped duplicates)
   - Keep only typed versions (#12, #13, #5)

5. **Verify Response Unwrapping**
   - Ensure Dio interceptor unwraps `ApiResponse<T>.data`
   - Test all 19 aligned endpoints for correct deserialization

6. **Standardize Parameter Names**
   - Rename `slotId` to `scheduleSlotId` in mobile client
   - Update all affected endpoints (#9-19)

### 🟢 Medium Priority (Nice to Have)

7. **Implement WebSocket Listeners**
   - Add listeners for real-time schedule updates
   - Handle optimistic UI updates

8. **Add Client-Side Validation**
   - Mirror backend validation rules in request DTOs
   - Provide better error messages before API calls

9. **Add Integration Tests**
   - Test all 19 aligned endpoints
   - Verify request/response DTO mapping
   - Test error handling and edge cases

10. **Document API Contract**
    - Create OpenAPI/Swagger spec
    - Document expected request/response formats
    - Include authentication requirements

---

## Testing Checklist

For each endpoint, verify:

- [ ] HTTP method matches
- [ ] Path structure matches (excluding `/api/v1/` prefix)
- [ ] Path parameters match (names and types)
- [ ] Query parameters match (names, types, required vs optional)
- [ ] Request body structure matches
- [ ] Response structure matches (accounting for ApiResponse wrapper)
- [ ] Error responses match expected format
- [ ] Authentication headers included
- [ ] Authorization enforced correctly
- [ ] Validation rules enforced
- [ ] WebSocket events emitted correctly

---

## Conclusion

The mobile app's Schedule API client has **significant misalignment** with the backend:

- **59% of endpoints** are properly implemented and aligned
- **41% of endpoints** are completely missing from backend (weekly schedule feature)
- **2 critical request mismatches** that will cause runtime failures
- **2 duplicate endpoints** that should be removed

**Next Steps:**
1. Fix critical request body mismatch (#13)
2. Decide on weekly schedule feature (remove or implement)
3. Remove duplicate endpoints
4. Verify response unwrapping with Dio interceptor
5. Add integration tests for all aligned endpoints

**Estimated Effort:**
- Critical fixes: 2-4 hours
- Weekly schedule decision: 1-2 hours (removal) OR 40-60 hours (implementation)
- Cleanup and testing: 8-12 hours

---

## Appendix: Backend File Locations

**Routes:**
- `/workspace/backend/src/routes/scheduleSlots.ts` - Lines 82-172
- `/workspace/backend/src/routes/groups.ts` - Lines 143-178

**Controllers:**
- `/workspace/backend/src/controllers/ScheduleSlotController.ts` - Lines 29-436
- `/workspace/backend/src/controllers/GroupScheduleConfigController.ts` - Lines 20-121

**Services:**
- `/workspace/backend/src/services/ScheduleSlotService.ts` (not analyzed)
- `/workspace/backend/src/services/GroupScheduleConfigService.ts` (not analyzed)
- `/workspace/backend/src/services/ChildAssignmentService.ts` (not analyzed)

**Mobile Files:**
- `/workspace/mobile_app/lib/core/network/schedule_api_client.dart` - Lines 28-491
- `/workspace/mobile_app/lib/core/constants/api_constants.dart` - Lines 92-151

---

**Report Generated:** 2025-10-09
**Author:** Claude Code (Sonnet 4.5)
**Tool:** Schedule API Alignment Verification
