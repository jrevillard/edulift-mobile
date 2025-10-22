# Schedule API Alignment - Action Plan

## Quick Reference

**Priority:** 🔴 CRITICAL
**Estimated Time:** 14-20 hours (without weekly schedule) OR 54-80 hours (with weekly schedule)
**Files to Modify:** 1-3 mobile files, 0-4 backend files

---

## Phase 1: Critical Fixes (MUST DO)

### 1.1 Fix DELETE Vehicle Request Body (30 minutes)

**Issue:** Mobile sends no body, backend expects `{ vehicleId }`

**File:** `/workspace/mobile_app/lib/core/network/schedule_api_client.dart`

**Current Code (Lines 101-102):**
```dart
@DELETE('/schedule-slots/{slotId}/vehicles')
Future<void> removeVehicleFromSlotTyped(@Path('slotId') String slotId);
```

**Fix:**
```dart
@DELETE('/schedule-slots/{slotId}/vehicles')
Future<void> removeVehicleFromSlotTyped(
  @Path('slotId') String slotId,
  @Body() Map<String, dynamic> body,  // Add this parameter
);
```

**Public Wrapper (Lines 329-331):**
```dart
// Current:
Future<void> removeVehicleFromSlotTyped(String slotId) =>
    _client.removeVehicleFromSlotTyped(slotId);

// Fix:
Future<void> removeVehicleFromSlotTyped(String slotId, String vehicleId) =>
    _client.removeVehicleFromSlotTyped(slotId, {'vehicleId': vehicleId});
```

**Callers to Update:**
Find all calls to `removeVehicleFromSlotTyped` and add vehicleId parameter:
```bash
cd /workspace/mobile_app
grep -r "removeVehicleFromSlotTyped" --include="*.dart" lib/
```

**Testing:**
- [ ] Test vehicle removal succeeds with vehicleId
- [ ] Verify slot is deleted when last vehicle removed
- [ ] Check WebSocket events are emitted

---

### 1.2 Weekly Schedule Decision (2-60 hours)

**Decision Required:** Remove unused endpoints OR implement backend feature?

#### Option A: Remove from Mobile (Recommended) - 2-4 hours

**Rationale:**
- Feature not implemented in backend
- No usage in mobile app found
- Reduces maintenance burden
- Can add later if needed

**Files to Modify:**
- `/workspace/mobile_app/lib/core/network/schedule_api_client.dart`

**Methods to Remove (Lines 143-235):**
```dart
// Remove these 13 methods:
getWeeklyScheduleForGroup                  // Line 143-147
getAvailableChildrenForSchedule            // Line 149-155
checkScheduleConflictsForGroup             // Line 157-161
copyWeeklyScheduleForGroup                 // Line 163-167
upsertScheduleSlotForGroup                 // Line 169-173
assignVehicleToScheduleSlot                // Line 175-179 (duplicate)
removeVehicleFromScheduleSlot              // Line 181-185 (duplicate)
assignChildrenToVehicleInSlot              // Line 187-195
removeChildFromVehicleInSlot               // Line 197-205
updateChildAssignmentStatusInSlot          // Line 207-216
updateGroupScheduleConfig                  // Line 218-222 (duplicate)
clearWeeklyScheduleForGroup                // Line 224-228
getScheduleStatisticsForGroup              // Line 230-235

// Also remove public wrappers (Lines 378-490)
```

**DTOs to Remove:**
```bash
# Check if these DTOs are used elsewhere:
grep -r "GroupWeeklyScheduleDto" lib/
grep -r "AvailableChildrenDto" lib/
grep -r "ScheduleConflictsDto" lib/
grep -r "ScheduleStatisticsDto" lib/
grep -r "ScheduleSlotChildDto" lib/

# If only used by removed endpoints, delete:
lib/core/network/models/schedule/group_weekly_schedule_dto.dart
lib/core/network/models/schedule/available_children_dto.dart
lib/core/network/models/schedule/schedule_conflicts_dto.dart
lib/core/network/models/schedule/schedule_statistics_dto.dart
lib/features/family/schedule_slot_child_dto.dart
```

**Testing:**
- [ ] Verify app compiles
- [ ] Run existing tests
- [ ] Check no broken references

---

#### Option B: Implement in Backend (Not Recommended Now) - 40-60 hours

**If you choose to implement, see:**
- SCHEDULE_API_ALIGNMENT_REPORT.md (Appendix: Implementation Guide)
- Create new backend routes, controllers, services
- Implement week calculation logic
- Add bulk operations
- Create statistics engine

**Defer this decision if:**
- No immediate user need
- MVP/beta phase
- Limited backend resources

---

### 1.3 Remove Duplicate Endpoints (1 hour)

**File:** `/workspace/mobile_app/lib/core/network/schedule_api_client.dart`

**Remove These Methods:**

```dart
// Line 175-179 - Duplicate of assignVehicleToSlotTyped (#12)
@POST('/schedule-slots/{scheduleSlotId}/vehicles')
Future<VehicleAssignmentDto> assignVehicleToScheduleSlot(...);

// Line 181-185 - Duplicate of removeVehicleFromSlotTyped (#13)
@DELETE('/schedule-slots/{scheduleSlotId}/vehicles')
Future<void> removeVehicleFromScheduleSlot(...);

// Line 218-222 - Duplicate of updateGroupScheduleConfigTyped (#5)
@PUT('/groups/{groupId}/schedule-config')
Future<ScheduleConfigDto> updateGroupScheduleConfig(...);
```

**Also remove public wrappers:**
```dart
// Lines 415-420
assignVehicleToScheduleSlot(...)

// Lines 422-427
removeVehicleFromScheduleSlot(...)

// Lines 473-478
updateGroupScheduleConfig(...)
```

**Keep Only:**
- `assignVehicleToSlotTyped` (typed, better)
- `removeVehicleFromSlotTyped` (typed, better - after fixing)
- `updateGroupScheduleConfigTyped` (typed, better)

**Testing:**
- [ ] Find all callers of removed methods
- [ ] Update to use typed versions
- [ ] Verify app compiles

---

## Phase 2: Verification (4-6 hours)

### 2.1 Verify Response Unwrapping (2 hours)

**Check Dio Interceptor:**

Find interceptor that unwraps ApiResponse:
```bash
cd /workspace/mobile_app
grep -r "interceptor" lib/core/network/ --include="*.dart"
grep -r "ApiResponse" lib/core/network/ --include="*.dart"
```

**Expected Pattern:**
```dart
// Interceptor should do:
if (response.data is Map && response.data.containsKey('data')) {
  return Response(
    requestOptions: response.requestOptions,
    data: response.data['data'], // Unwrap here
    statusCode: response.statusCode,
    headers: response.headers,
  );
}
```

**Test Each Endpoint:**
```dart
// Create test file:
// test/core/network/schedule_api_client_integration_test.dart

void main() {
  group('Schedule API Client Integration', () {
    test('GET schedule config unwraps correctly', () async {
      final config = await client.getGroupScheduleConfig(groupId);
      expect(config, isA<ScheduleConfigDto>());
      expect(config.id, isNotNull);
    });

    test('POST assign vehicle unwraps correctly', () async {
      final assignment = await client.assignVehicleToSlotTyped(
        slotId,
        AssignVehicleRequest(vehicleId: vehicleId),
      );
      expect(assignment, isA<VehicleAssignmentDto>());
    });

    // Add test for each of 19 aligned endpoints
  });
}
```

**Checklist:**
- [ ] Interceptor unwraps `data` field
- [ ] Success responses deserialize to DTOs
- [ ] Error responses handle `error` field
- [ ] Validation errors handled correctly

---

### 2.2 Verify DTO Structure Alignment (2-4 hours)

**For Each DTO, Compare:**

**Example: ScheduleSlotDto**

Mobile DTO:
```dart
class ScheduleSlotDto {
  final String id;
  final String groupId;
  final DateTime datetime;
  final List<VehicleAssignmentDto> vehicleAssignments;
  final List<ChildAssignmentDto> childAssignments;
  // ... etc
}
```

Backend Response (from ScheduleSlotService):
```typescript
{
  id: string,
  groupId: string,
  datetime: Date,
  vehicleAssignments: VehicleAssignment[],
  childAssignments: ChildAssignment[],
  // ... etc
}
```

**DTOs to Verify:**
- [ ] ScheduleConfigDto
- [ ] TimeSlotConfigDto
- [ ] ScheduleSlotDto
- [ ] VehicleAssignmentDto
- [ ] ChildAssignmentDto
- [ ] ConflictDto
- [ ] ChildDto

**Check:**
- Field names match (camelCase in both)
- Field types match (String, int, bool, DateTime)
- Nested objects handled (List<T>, nested DTOs)
- Optional fields marked correctly (@JsonKey(required: false))
- Date serialization format (ISO 8601)

---

## Phase 3: Testing (8-12 hours)

### 3.1 Create Integration Tests (6-8 hours)

**Test File:** `test/core/network/schedule_api_client_integration_test.dart`

**Test Structure:**
```dart
void main() {
  late ScheduleApiClient client;
  late Dio dio;
  late String testGroupId;
  late String testSlotId;

  setUpAll(() async {
    // Set up test environment
    // Authenticate test user
    // Create test group
  });

  tearDownAll(() async {
    // Clean up test data
  });

  group('Schedule Configuration', () {
    test('GET default config', () async { /* ... */ });
    test('POST initialize config', () async { /* ... */ });
    test('GET group config', () async { /* ... */ });
    test('GET time slots', () async { /* ... */ });
    test('PUT update config', () async { /* ... */ });
    test('POST reset config', () async { /* ... */ });
  });

  group('Schedule Management', () {
    test('POST create slot with vehicle', () async { /* ... */ });
    test('GET group schedule', () async { /* ... */ });
    test('GET schedule slot', () async { /* ... */ });
    test('POST assign vehicle', () async { /* ... */ });
    test('DELETE remove vehicle', () async { /* ... */ });
    test('PATCH update driver', () async { /* ... */ });
  });

  group('Children Assignment', () {
    test('POST assign child', () async { /* ... */ });
    test('DELETE remove child', () async { /* ... */ });
    test('GET available children', () async { /* ... */ });
    test('GET conflicts', () async { /* ... */ });
    test('PATCH update seat override', () async { /* ... */ });
  });

  group('Error Handling', () {
    test('handles 401 unauthorized', () async { /* ... */ });
    test('handles 403 forbidden', () async { /* ... */ });
    test('handles 404 not found', () async { /* ... */ });
    test('handles 409 conflict', () async { /* ... */ });
    test('handles validation errors', () async { /* ... */ });
  });
}
```

**Run Tests:**
```bash
cd /workspace/mobile_app
flutter test test/core/network/schedule_api_client_integration_test.dart
```

---

### 3.2 Manual Testing (2-4 hours)

**Test Scenarios:**

1. **Create Schedule Flow:**
   - [ ] Create schedule slot with vehicle
   - [ ] Verify slot appears in group schedule
   - [ ] Assign children to slot
   - [ ] Update driver assignment
   - [ ] Remove vehicle (verify slot deleted)

2. **Configuration Flow:**
   - [ ] Get default config
   - [ ] Update group config with custom hours
   - [ ] Verify time slots reflect changes
   - [ ] Reset to default
   - [ ] Verify reset worked

3. **Conflict Detection:**
   - [ ] Create overlapping slots
   - [ ] Assign same child twice
   - [ ] Verify conflicts detected
   - [ ] Resolve conflicts

4. **Error Scenarios:**
   - [ ] Try to assign child without permission
   - [ ] Try to delete non-existent slot
   - [ ] Try to exceed vehicle capacity
   - [ ] Try to update config as non-admin

---

## Phase 4: Optional Improvements (8-16 hours)

### 4.1 Standardize Parameter Names (2 hours)

**Change:** `slotId` → `scheduleSlotId` everywhere in mobile

**Files to Update:**
- schedule_api_client.dart
- All data sources using schedule API
- All repositories
- All use cases

**Find all occurrences:**
```bash
grep -r "slotId" lib/ --include="*.dart" | grep -v "scheduleSlotId"
```

---

### 4.2 Implement WebSocket Listeners (6-8 hours)

**Create Service:**
```dart
// lib/core/network/websocket_service.dart

class ScheduleWebSocketService {
  final Socket socket;

  void listenToScheduleUpdates(String groupId, {
    required Function(String slotId, Map<String, dynamic> slot) onSlotCreated,
    required Function(String slotId, Map<String, dynamic> changes) onSlotUpdated,
    required Function(String slotId) onSlotDeleted,
    required Function() onScheduleUpdate,
  }) {
    socket.emit('join-schedule', {'groupId': groupId});

    socket.on('schedule-slot-created', (data) {
      onSlotCreated(data['slotId'], data['slot']);
    });

    socket.on('schedule-slot-updated', (data) {
      onSlotUpdated(data['slotId'], data['changes']);
    });

    socket.on('schedule-slot-deleted', (data) {
      onSlotDeleted(data['slotId']);
    });

    socket.on('schedule-update', (_) {
      onScheduleUpdate();
    });
  }

  void disconnect() {
    socket.disconnect();
  }
}
```

**Integrate with State Management:**
```dart
// In your bloc/cubit/riverpod provider:
_webSocketService.listenToScheduleUpdates(
  groupId,
  onSlotCreated: (slotId, slot) {
    // Add slot to state
    emit(state.copyWith(
      slots: [...state.slots, ScheduleSlot.fromJson(slot)],
    ));
  },
  onSlotUpdated: (slotId, changes) {
    // Update slot in state
  },
  onSlotDeleted: (slotId) {
    // Remove slot from state
  },
  onScheduleUpdate: () {
    // Refresh entire schedule
    _fetchSchedule();
  },
);
```

---

### 4.3 Add Client-Side Validation (2-4 hours)

**Create Validators:**
```dart
// lib/core/validators/schedule_validators.dart

class ScheduleValidators {
  static String? validateVehicleId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vehicle ID is required';
    }
    if (!_isCuid(value)) {
      return 'Invalid vehicle ID format';
    }
    return null;
  }

  static String? validateSeatOverride(int? value, int maxCapacity) {
    if (value == null) return null;
    if (value < 0) {
      return 'Seat override cannot be negative';
    }
    if (value > maxCapacity) {
      return 'Seat override exceeds vehicle capacity';
    }
    return null;
  }

  static String? validateDateTime(DateTime? value) {
    if (value == null) {
      return 'Date and time are required';
    }
    if (value.isBefore(DateTime.now())) {
      return 'Schedule time must be in the future';
    }
    return null;
  }

  static bool _isCuid(String value) {
    // CUID format: c + timestamp + counter + fingerprint + random
    return RegExp(r'^c[a-z0-9]{24}$').hasMatch(value);
  }
}
```

**Use in Forms:**
```dart
TextFormField(
  validator: ScheduleValidators.validateVehicleId,
  // ...
),
```

---

## Timeline

### Fast Track (Minimal - 14-20 hours)
```
Day 1: Fix DELETE vehicle (30 min)
Day 1: Remove weekly schedule endpoints (4 hrs)
Day 1: Remove duplicates (1 hr)
Day 1: Verify unwrapping (2 hrs)
─────────────────────────────────
Day 2: Verify DTOs (4 hrs)
Day 2: Integration tests (8 hrs)
─────────────────────────────────
Total: 19.5 hours
```

### Full Track (With Improvements - 30-40 hours)
```
Week 1 (20 hrs):
  - All fast track items
  - Manual testing (4 hrs)
  - Standardize params (2 hrs)
─────────────────────────────────
Week 2 (16 hrs):
  - WebSocket implementation (8 hrs)
  - Client validation (4 hrs)
  - Documentation (2 hrs)
  - Code review (2 hrs)
─────────────────────────────────
Total: 36 hours
```

### With Weekly Schedule Backend (80-100 hours)
```
Weeks 1-2: Fast Track (20 hrs)
Weeks 3-5: Backend Implementation (60 hrs)
Week 6: Full Integration & Testing (20 hrs)
─────────────────────────────────
Total: 100 hours
```

---

## Success Criteria

### Phase 1 Complete When:
- [ ] DELETE vehicle works with vehicleId in body
- [ ] Weekly schedule endpoints removed (or implemented)
- [ ] Duplicate endpoints removed
- [ ] No compilation errors

### Phase 2 Complete When:
- [ ] All 19 endpoints deserialize correctly
- [ ] DTOs match backend structure
- [ ] Error responses handled properly

### Phase 3 Complete When:
- [ ] Integration tests pass (all 19 endpoints)
- [ ] Manual testing scenarios pass
- [ ] No regressions in existing features

### Phase 4 Complete When:
- [ ] WebSocket listeners implemented
- [ ] Client validation added
- [ ] Code reviewed and documented

---

## Risk Mitigation

### Risk: Breaking Existing Features
**Mitigation:**
- Create feature branch for changes
- Run full test suite before/after
- Manual regression testing
- Gradual rollout

### Risk: DTO Mismatches Discovered
**Mitigation:**
- Verify DTOs early (Phase 2.2)
- Add integration tests
- Use strict type checking

### Risk: Backend Changes Required
**Mitigation:**
- Document all backend assumptions
- Coordinate with backend team
- Version API if breaking changes needed

### Risk: Timeline Overrun
**Mitigation:**
- Start with critical fixes only
- Defer optional improvements
- Track time per phase
- Adjust scope as needed

---

## Rollback Plan

If issues discovered after deployment:

1. **Revert Git Commit:**
   ```bash
   git revert <commit-hash>
   git push
   ```

2. **Emergency Hotfix:**
   - Disable schedule features
   - Show maintenance message
   - Rollback mobile app version

3. **Communication:**
   - Notify users of temporary issues
   - Provide ETA for fix
   - Document learnings

---

## Next Steps

1. **Review with Team:**
   - Discuss weekly schedule decision
   - Allocate developer time
   - Set milestones

2. **Create Tickets:**
   - One ticket per phase
   - Assign to developers
   - Link to this action plan

3. **Set Up Environment:**
   - Create feature branch
   - Set up test backend
   - Configure CI/CD

4. **Begin Phase 1:**
   - Start with critical fixes
   - Track time carefully
   - Update this document as needed

---

**Document Version:** 1.0
**Last Updated:** 2025-10-09
**Owner:** Development Team
**Status:** Ready for Review
