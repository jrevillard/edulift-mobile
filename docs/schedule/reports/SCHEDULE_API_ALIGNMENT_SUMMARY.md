# Schedule API Alignment - Executive Summary

## Quick Stats

| Metric | Count | Percentage |
|--------|-------|------------|
| **Total Endpoints** | 32 | 100% |
| **Fully Aligned** | 19 | 59% |
| **Missing in Backend** | 13 | 41% |
| **Duplicates** | 2 | 6% |
| **Critical Issues** | 2 | 6% |

## Critical Issues Requiring Immediate Action

### 🔴 Issue #1: Request Body Mismatch - DELETE Vehicle

**Endpoint:** `DELETE /api/v1/schedule-slots/{slotId}/vehicles`

**Problem:**
- Mobile sends NO request body
- Backend expects `{ vehicleId: string }` in body

**Impact:** All vehicle removal calls will fail with 400 Bad Request

**Fix Location:** `/workspace/mobile_app/lib/core/network/schedule_api_client.dart` line 102

**Fix Required:**
```dart
// Current (line 102):
@DELETE('/schedule-slots/{slotId}/vehicles')
Future<void> removeVehicleFromSlotTyped(@Path('slotId') String slotId);

// Should be:
@DELETE('/schedule-slots/{slotId}/vehicles')
Future<void> removeVehicleFromSlotTyped(
  @Path('slotId') String slotId,
  @Body() Map<String, dynamic> body, // Must include { vehicleId: string }
);
```

---

### 🔴 Issue #2: 13 Weekly Schedule Endpoints Don't Exist

**Missing Endpoints:**
1. `GET /groups/{groupId}/schedule/week/{week}`
2. `GET /groups/{groupId}/schedule/available-children`
3. `POST /groups/{groupId}/schedule/conflicts`
4. `POST /groups/{groupId}/schedule/copy`
5. `POST /groups/{groupId}/schedule/slots`
6. `POST /schedule-slots/{scheduleSlotId}/vehicles` (duplicate)
7. `DELETE /schedule-slots/{scheduleSlotId}/vehicles` (duplicate)
8. `POST /groups/{groupId}/schedule/slots/{slotId}/vehicles/{vehicleAssignmentId}/children`
9. `DELETE /groups/{groupId}/schedule/slots/{slotId}/vehicles/{vehicleAssignmentId}/children/{childAssignmentId}`
10. `PATCH /groups/{groupId}/schedule/slots/{slotId}/vehicles/{vehicleAssignmentId}/children/{childAssignmentId}`
11. `PUT /groups/{groupId}/schedule-config` (duplicate)
12. `DELETE /groups/{groupId}/schedule/week/{week}`
13. `GET /groups/{groupId}/schedule/statistics`

**Analysis:** This appears to be a planned feature that was designed in mobile but never implemented in backend.

**Decision Required:**
- **Option A:** Remove all 13 endpoints from mobile client (2-4 hours)
- **Option B:** Implement full weekly schedule feature in backend (40-60 hours)

---

## Additional Missing Core Endpoints

### Update Schedule Slot
- **Endpoint:** `PATCH /api/v1/schedule-slots/{slotId}`
- **Impact:** Cannot update slot datetime or properties
- **Recommendation:** Add to backend OR remove from mobile

### Delete Schedule Slot
- **Endpoint:** `DELETE /api/v1/schedule-slots/{slotId}`
- **Impact:** Cannot explicitly delete slots (only auto-delete on last vehicle removal)
- **Recommendation:** Add to backend OR remove from mobile

---

## What's Working (19 Aligned Endpoints)

### ✅ Schedule Configuration (6 endpoints)
- Get default config
- Initialize config
- Get group config
- Get time slots
- Update config
- Reset config

### ✅ Schedule Management (5 endpoints)
- Create schedule slot
- Get group schedule
- Get schedule slot details
- Assign vehicle to slot
- Update vehicle driver

### ✅ Children Assignment (5 endpoints)
- Assign child to slot
- Remove child from slot
- Get available children
- Get schedule conflicts
- Update seat override

### ✅ Advanced (3 endpoints)
- Get available children for slot
- Get schedule conflicts
- Update seat override

---

## Minor Issues to Address

### Duplicate Endpoints
- Endpoint #12 vs #25 (assign vehicle) - typed vs untyped versions
- Endpoint #13 vs #26 (remove vehicle) - typed vs untyped versions
- Endpoint #5 vs #30 (update config) - typed vs untyped versions

**Recommendation:** Remove untyped duplicates (#25, #26, #30)

### Parameter Name Inconsistency
- Mobile uses `slotId`
- Backend uses `scheduleSlotId`
- Functional impact: None (Retrofit maps correctly)
- Recommendation: Standardize for consistency

### Response Wrapper Verification Needed
- Backend returns `{ success: true, data: T }`
- Mobile expects direct DTO `T`
- Verify: Dio interceptor unwraps `data` field correctly

---

## Action Items by Priority

### Must Do (Critical)
1. [ ] Fix vehicle removal request body (Issue #1)
2. [ ] Decide on weekly schedule endpoints (Issue #2)
3. [ ] Test aligned endpoints for response unwrapping
4. [ ] Add/remove update and delete schedule slot endpoints

### Should Do (High Priority)
5. [ ] Remove duplicate endpoints (#25, #26, #30)
6. [ ] Verify DTO structure alignment for all 19 working endpoints
7. [ ] Add integration tests

### Nice to Have (Medium Priority)
8. [ ] Standardize parameter names (slotId → scheduleSlotId)
9. [ ] Implement WebSocket listeners for real-time updates
10. [ ] Add client-side validation matching backend rules

---

## Estimated Effort

| Task | Time Estimate |
|------|---------------|
| Fix critical request body mismatch | 30 minutes |
| Remove 13 weekly schedule endpoints | 2-4 hours |
| Remove duplicate endpoints | 1 hour |
| Verify response unwrapping | 2 hours |
| Add integration tests | 8-12 hours |
| **Total (without weekly schedule implementation)** | **14-20 hours** |
| **Total (with weekly schedule implementation)** | **54-80 hours** |

---

## Files Modified (If Fixing Issues)

### Mobile App
- `/workspace/mobile_app/lib/core/network/schedule_api_client.dart`
- `/workspace/mobile_app/lib/core/network/models/schedule/*.dart` (DTO verification)
- `/workspace/mobile_app/test/core/network/schedule_api_client_test.dart` (new tests)

### Backend (If Implementing Weekly Schedule)
- `/workspace/backend/src/routes/scheduleSlots.ts` (add routes)
- `/workspace/backend/src/controllers/ScheduleSlotController.ts` (add methods)
- `/workspace/backend/src/services/ScheduleSlotService.ts` (add business logic)

---

## Testing Strategy

### Phase 1: Verify Aligned Endpoints (19 endpoints)
1. Create integration tests for each aligned endpoint
2. Test request/response DTO mapping
3. Test error handling
4. Test authentication/authorization

### Phase 2: Fix Critical Issues
1. Fix vehicle removal request body
2. Test vehicle removal flow
3. Verify WebSocket events

### Phase 3: Clean Up
1. Remove duplicate endpoints OR weekly schedule endpoints
2. Update documentation
3. Run full test suite

---

## References

- **Full Report:** `/workspace/mobile_app/SCHEDULE_API_ALIGNMENT_REPORT.md`
- **Mobile API Client:** `/workspace/mobile_app/lib/core/network/schedule_api_client.dart`
- **Backend Routes:** `/workspace/backend/src/routes/scheduleSlots.ts`, `/workspace/backend/src/routes/groups.ts`
- **Backend Controllers:** `/workspace/backend/src/controllers/ScheduleSlotController.ts`, `/workspace/backend/src/controllers/GroupScheduleConfigController.ts`

---

**Report Date:** 2025-10-09
**Status:** Analysis Complete - Awaiting Decision on Weekly Schedule Feature
