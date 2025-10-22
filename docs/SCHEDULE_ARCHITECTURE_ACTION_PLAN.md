# Schedule Architecture - Action Plan

**Based on:** SCHEDULE_ARCHITECTURE_REVIEW.md
**Date:** 2025-10-13
**Priority:** HIGH - Immediate action required for architecture compliance

---

## Executive Summary

The schedule feature has **excellent foundations** but requires **critical error handling upgrades** to comply with ERROR_HANDLING_ARCHITECTURE.md.

**Overall Score:** 78/100
**Target Score:** 95/100 (achievable in 3-5 days)

---

## Critical Issues Requiring Immediate Action

### Issue #1: No ErrorHandlerService Integration ❌

**Current State:**
```dart
// vehicle_operations_handler.dart:171-184
} on ServerException catch (e) {
  _logger.severe('Server error: ${e.message}');
  return Result.err(ApiFailure.serverError(message: e.message));
}
```

**Required State:**
```dart
} on ServerException catch (e) {
  final context = ErrorContext.scheduleOperation('assign_vehicle', metadata: {
    'vehicleId': vehicleId,
    'slotId': slotId,
  });
  final errorResult = await _errorHandler.handleError(e, context);
  return Result.err(errorResult.userMessage);
}
```

**Impact:** Technical errors shown to users, no centralized logging
**Effort:** 1-2 days
**Files Affected:** 4 handler files

---

### Issue #2: No ErrorContext Usage ❌

**Required Addition:**
```dart
// Add to core/errors/error_context.dart
extension ScheduleErrorContext on ErrorContext {
  factory ErrorContext.scheduleOperation(
    String operation, {
    Map<String, dynamic>? metadata,
  }) {
    return ErrorContext(
      operation: operation,
      feature: 'schedule',
      metadata: metadata ?? {},
      timestamp: DateTime.now(),
      sessionId: _generateSessionId(),
    );
  }
}
```

**Impact:** No operation tracking, no debugging context
**Effort:** 0.5 days
**Files Affected:** All handlers

---

### Issue #3: No UserMessageService ❌

**Required Change:**
```dart
// Current: Technical message
return Result.err(ApiFailure.serverError(message: e.message));

// Required: User-friendly message
final errorResult = await _errorHandler.handleError(e, context);
return Result.err(errorResult.userMessage);
// Returns: UserErrorMessage with localized keys
```

**Impact:** Poor UX with technical error messages
**Effort:** 1 day (including localization)
**Files Affected:** All handlers, l10n files

---

## Implementation Plan

### Phase 1: Foundation Setup (Day 1)

**Task 1.1: Add ErrorContext.scheduleOperation**
```dart
// lib/core/errors/error_context.dart

extension ScheduleErrorContext on ErrorContext {
  factory ErrorContext.scheduleOperation(
    String operation, {
    Map<String, dynamic>? metadata,
  }) {
    return ErrorContext(
      operation: operation,
      feature: 'schedule',
      metadata: metadata ?? {},
      timestamp: DateTime.now(),
      sessionId: AppLogger.sessionId,
    );
  }
}
```

**Task 1.2: Add Schedule Error Messages to Localization**
```dart
// lib/l10n/app_en.arb
{
  "errorScheduleAssignVehicleTitle": "Vehicle Assignment Failed",
  "errorScheduleAssignVehicleMessage": "Could not assign vehicle to time slot. Please try again.",
  "errorScheduleRemoveVehicleTitle": "Vehicle Removal Failed",
  "errorScheduleRemoveVehicleMessage": "Could not remove vehicle from time slot. Please try again.",
  "errorScheduleCapacityTitle": "Capacity Exceeded",
  "errorScheduleCapacityMessage": "Vehicle capacity exceeded. Please adjust seat override or remove children.",
}
```

**Task 1.3: Update Handler Constructor Signatures**
```dart
// lib/features/schedule/data/repositories/handlers/vehicle_operations_handler.dart

class VehicleOperationsHandler {
  final ScheduleApiClient _apiClient;
  final ErrorHandlerService _errorHandler;  // ADD THIS

  VehicleOperationsHandler(this._apiClient, this._errorHandler);  // UPDATE THIS
}
```

---

### Phase 2: Handler Integration (Days 2-3)

**Task 2.1: Update VehicleOperationsHandler**

Before:
```dart
Future<Result<VehicleAssignment, ApiFailure>> assignVehicleToSlot(...) async {
  try {
    final scheduleSlotDto = await ApiResponseHelper.executeAndUnwrap<ScheduleSlotDto>(
      () => _apiClient.createScheduleSlot(groupId, request),
    );
    return Result.ok(vehicleAssignment);
  } on ServerException catch (e) {
    _logger.severe('Server error: ${e.message}');
    return Result.err(ApiFailure.serverError(message: e.message));
  }
}
```

After:
```dart
Future<Result<VehicleAssignment, ApiFailure>> assignVehicleToSlot(...) async {
  final context = ErrorContext.scheduleOperation(
    'assign_vehicle',
    metadata: {
      'groupId': groupId,
      'day': day,
      'time': time,
      'week': week,
      'vehicleId': vehicleId,
    },
  );

  try {
    AppLogger.info('[SCHEDULE] assign_vehicle: Starting for vehicle $vehicleId');

    final scheduleSlotDto = await ApiResponseHelper.executeAndUnwrap<ScheduleSlotDto>(
      () => _apiClient.createScheduleSlot(groupId, request),
    );

    AppLogger.info('[SCHEDULE] assign_vehicle: Success for vehicle $vehicleId');
    return Result.ok(vehicleAssignment);

  } on ServerException catch (e, stackTrace) {
    AppLogger.error('[SCHEDULE] assign_vehicle: Server error', e, stackTrace);
    final errorResult = await _errorHandler.handleError(e, context, stackTrace: stackTrace);
    return Result.err(errorResult.userMessage);

  } on NetworkException catch (e, stackTrace) {
    AppLogger.error('[SCHEDULE] assign_vehicle: Network error', e, stackTrace);
    final errorResult = await _errorHandler.handleError(e, context, stackTrace: stackTrace);
    return Result.err(errorResult.userMessage);

  } catch (e, stackTrace) {
    AppLogger.fatal('[SCHEDULE] assign_vehicle: Unexpected error', e, stackTrace);
    final errorResult = await _errorHandler.handleError(e, context, stackTrace: stackTrace);
    return Result.err(errorResult.userMessage);
  }
}
```

**Apply to all methods in:**
- ✅ `assignVehicleToSlot` (lines 102-185)
- ✅ `assignChildrenToVehicle` (lines 187-308)
- ✅ `removeVehicleFromSlot` (lines 310-351)
- ✅ `removeChildFromVehicle` (lines 353-393)
- ✅ `updateChildAssignmentStatus` (lines 395-453)
- ✅ `updateSeatOverride` (lines 455-501)

**Task 2.2: Update BasicSlotOperationsHandler**

Apply same pattern to:
- ✅ `getWeeklySchedule` (lines 50-120)
- ✅ `getAvailableChildren` (lines 123-165)
- ✅ `checkScheduleConflicts` (lines 167-213)
- ✅ `copyWeeklySchedule` (lines 215-272)
- ✅ `clearWeeklySchedule` (lines 274-334)

**Task 2.3: Update ScheduleConfigOperationsHandler**

Apply same pattern to all config operations.

**Task 2.4: Update AdvancedOperationsHandler**

Apply same pattern to all advanced operations.

---

### Phase 3: Repository Updates (Day 4)

**Task 3.1: Update ScheduleRepositoryImpl**

```dart
class ScheduleRepositoryImpl implements GroupScheduleRepository {
  final ScheduleApiClient _apiClient;
  final ScheduleLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  final ErrorHandlerService _errorHandler;  // ADD THIS

  // Update handlers to receive ErrorHandlerService
  late final handlers.BasicSlotOperationsHandler _basicSlotHandler;
  late final vehicle_handlers.VehicleOperationsHandler _vehicleHandler;
  late final config_handlers.ScheduleConfigOperationsHandler _configHandler;
  late final advanced_handlers.AdvancedOperationsHandler _advancedHandler;

  ScheduleRepositoryImpl(
    this._apiClient,
    this._localDataSource,
    this._networkInfo,
    this._errorHandler,  // ADD THIS
  ) {
    _basicSlotHandler = handlers.BasicSlotOperationsHandler(_apiClient, _errorHandler);
    _vehicleHandler = vehicle_handlers.VehicleOperationsHandler(_apiClient, _errorHandler);
    _configHandler = config_handlers.ScheduleConfigOperationsHandler(_apiClient, _errorHandler);
    _advancedHandler = advanced_handlers.AdvancedOperationsHandler(_apiClient, _errorHandler);
  }
}
```

**Task 3.2: Update Dependency Injection**

```dart
// Wherever ScheduleRepositoryImpl is provided
@module
abstract class ScheduleModule {
  @lazySingleton
  ScheduleRepositoryImpl provideScheduleRepository(
    ScheduleApiClient apiClient,
    ScheduleLocalDataSource localDataSource,
    NetworkInfo networkInfo,
    ErrorHandlerService errorHandler,  // ADD THIS
  ) {
    return ScheduleRepositoryImpl(
      apiClient,
      localDataSource,
      networkInfo,
      errorHandler,  // ADD THIS
    );
  }
}
```

---

### Phase 4: Testing & Validation (Day 5)

**Task 4.1: Update Unit Tests**

```dart
void main() {
  group('VehicleOperationsHandler with ErrorHandlerService', () {
    late VehicleOperationsHandler handler;
    late MockScheduleApiClient mockApiClient;
    late MockErrorHandlerService mockErrorHandler;

    setUp(() {
      mockApiClient = MockScheduleApiClient();
      mockErrorHandler = MockErrorHandlerService();
      handler = VehicleOperationsHandler(mockApiClient, mockErrorHandler);
    });

    test('should use ErrorHandlerService on ServerException', () async {
      // Arrange
      when(mockApiClient.createScheduleSlot(any, any))
          .thenThrow(ServerException('Server error'));
      when(mockErrorHandler.handleError(any, any, stackTrace: anyNamed('stackTrace')))
          .thenAnswer((_) async => ErrorHandlingResult(
                userMessage: UserErrorMessage(
                  titleKey: 'errorScheduleAssignVehicleTitle',
                  messageKey: 'errorScheduleAssignVehicleMessage',
                  canRetry: true,
                ),
                classification: ErrorClassification(...),
              ));

      // Act
      final result = await handler.assignVehicleToSlot(...);

      // Assert
      expect(result.isError, true);
      verify(mockErrorHandler.handleError(
        any,
        argThat(predicate((ErrorContext ctx) =>
          ctx.feature == 'schedule' &&
          ctx.operation == 'assign_vehicle'
        )),
        stackTrace: anyNamed('stackTrace'),
      )).called(1);
    });
  });
}
```

**Task 4.2: Integration Testing**

1. Test error flow: API error → ErrorHandlerService → UserMessageService → UI
2. Verify localized error messages displayed
3. Verify error logging with context
4. Verify retry functionality

**Task 4.3: Manual Testing Checklist**

- [ ] Assign vehicle with network error - verify user-friendly message
- [ ] Assign vehicle with capacity error - verify specific message
- [ ] Remove vehicle with server error - verify retry option
- [ ] Assign children with conflict - verify 409 handling
- [ ] Check error logs include full context

---

## Code Examples

### Example 1: Complete Handler Method with ErrorHandlerService

```dart
Future<Result<VehicleAssignment, ApiFailure>> assignVehicleToSlot(
  String groupId,
  String day,
  String time,
  String week,
  String vehicleId,
  Future<Result<ScheduleSlot, ApiFailure>> Function(String, String, String, String) upsertSlot,
) async {
  // Step 1: Create error context
  final context = ErrorContext.scheduleOperation(
    'assign_vehicle',
    metadata: {
      'groupId': groupId,
      'day': day,
      'time': time,
      'week': week,
      'vehicleId': vehicleId,
    },
  );

  try {
    // Step 2: Log operation start
    AppLogger.info('[SCHEDULE] assign_vehicle: Starting', metadata: context.metadata);

    // Step 3: Validate inputs
    if (groupId.isEmpty || day.isEmpty || time.isEmpty || week.isEmpty || vehicleId.isEmpty) {
      AppLogger.warning('[SCHEDULE] assign_vehicle: Validation failed');
      return Result.err(ApiFailure.validationError(
        message: 'All parameters must be non-empty',
      ));
    }

    // Step 4: Calculate datetime
    final datetime = _calculateDateTimeFromSlot(day, time, week);
    if (datetime == null) {
      AppLogger.warning('[SCHEDULE] assign_vehicle: Invalid datetime calculation');
      return Result.err(ApiFailure.validationError(
        message: 'Invalid datetime calculation',
      ));
    }

    // Step 5: Execute API call
    final request = CreateScheduleSlotRequest(
      datetime: datetime.toIso8601String(),
      vehicleId: vehicleId,
    );

    AppLogger.debug('[SCHEDULE] assign_vehicle: Calling API', metadata: {
      'datetime': request.datetime,
      'vehicleId': request.vehicleId,
    });

    final scheduleSlotDto = await ApiResponseHelper.executeAndUnwrap<ScheduleSlotDto>(
      () => _apiClient.createScheduleSlot(groupId, request),
    );

    // Step 6: Extract result
    final vehicleAssignments = scheduleSlotDto.vehicleAssignments;
    if (vehicleAssignments == null || vehicleAssignments.isEmpty) {
      AppLogger.severe('[SCHEDULE] assign_vehicle: No vehicle assignment in response');
      return Result.err(const ApiFailure(
        code: 'schedule.assign_vehicle_failed',
        message: 'No vehicle assignment returned',
        statusCode: 500,
      ));
    }

    final vehicleAssignment = _mapVehicleAssignmentDtoToDomain(vehicleAssignments.first);

    // Step 7: Log success
    AppLogger.info('[SCHEDULE] assign_vehicle: Success', metadata: {
      'assignmentId': vehicleAssignment.id,
    });

    return Result.ok(vehicleAssignment);

  } on ServerException catch (e, stackTrace) {
    // Step 8a: Handle server errors
    AppLogger.error('[SCHEDULE] assign_vehicle: Server error', e, stackTrace);
    final errorResult = await _errorHandler.handleError(e, context, stackTrace: stackTrace);
    return Result.err(errorResult.userMessage);

  } on NetworkException catch (e, stackTrace) {
    // Step 8b: Handle network errors
    AppLogger.error('[SCHEDULE] assign_vehicle: Network error', e, stackTrace);
    final errorResult = await _errorHandler.handleError(e, context, stackTrace: stackTrace);
    return Result.err(errorResult.userMessage);

  } on ValidationException catch (e, stackTrace) {
    // Step 8c: Handle validation errors
    AppLogger.warning('[SCHEDULE] assign_vehicle: Validation error', e, stackTrace);
    final errorResult = await _errorHandler.handleError(e, context, stackTrace: stackTrace);
    return Result.err(errorResult.userMessage);

  } catch (e, stackTrace) {
    // Step 8d: Handle unexpected errors
    AppLogger.fatal('[SCHEDULE] assign_vehicle: Unexpected error', e, stackTrace);
    final errorResult = await _errorHandler.handleError(e, context, stackTrace: stackTrace);
    return Result.err(errorResult.userMessage);
  }
}
```

---

## Success Metrics

### Before Implementation
- ❌ ErrorHandlerService usage: 0%
- ❌ ErrorContext usage: 0%
- ❌ UserMessageService usage: 0%
- ⚠️ Structured logging: 50%

### After Implementation (Target)
- ✅ ErrorHandlerService usage: 100%
- ✅ ErrorContext usage: 100%
- ✅ UserMessageService usage: 100%
- ✅ Structured logging: 90%

### User Experience Improvements
- ✅ User-friendly error messages (French & English)
- ✅ Actionable error messages with retry options
- ✅ Proper error severity indication
- ✅ Context-aware error messages

### Developer Experience Improvements
- ✅ Centralized error handling logic
- ✅ Consistent error patterns across features
- ✅ Rich debugging context in logs
- ✅ Easy to track error flows

---

## Risk Assessment

### Low Risk Changes
- Adding ErrorContext extension
- Adding localization keys
- Updating handler constructors

### Medium Risk Changes
- Updating handler error handling logic
- Updating repository constructor
- Updating dependency injection

### Mitigation Strategy
1. **Feature flag:** Consider adding feature flag for new error handling
2. **Gradual rollout:** Update one handler at a time
3. **Comprehensive testing:** Unit tests + integration tests + manual testing
4. **Monitoring:** Track error rates and user feedback
5. **Rollback plan:** Keep old implementation as fallback

---

## Dependencies

### Required Components (Already Exist)
- ✅ ErrorHandlerService
- ✅ UserMessageService
- ✅ ErrorContext base class
- ✅ AppLogger
- ✅ Result pattern
- ✅ ApiResponseHelper

### New Components (Need to Create)
- [ ] ErrorContext.scheduleOperation extension
- [ ] Schedule-specific error localization keys
- [ ] Updated handler constructors
- [ ] Updated tests

---

## Timeline

### Day 1: Foundation (4 hours)
- Morning: Add ErrorContext.scheduleOperation (1h)
- Morning: Add localization keys (1h)
- Afternoon: Update handler constructors (2h)

### Days 2-3: Handler Integration (12 hours)
- Day 2 AM: VehicleOperationsHandler (3h)
- Day 2 PM: BasicSlotOperationsHandler (3h)
- Day 3 AM: ConfigOperationsHandler (2h)
- Day 3 PM: AdvancedOperationsHandler + Repository (4h)

### Day 4: Testing (6 hours)
- Morning: Unit tests (3h)
- Afternoon: Integration tests (2h)
- Late afternoon: Manual testing (1h)

### Day 5: Polish & Documentation (2 hours)
- Morning: Fix any issues found in testing (1h)
- Morning: Update documentation (1h)

**Total Effort:** 24 hours (3 full days)

---

## Follow-Up Actions

After completing this action plan:

1. **Update other features** to use same error handling pattern
2. **Create architecture guide** for new features
3. **Add architecture tests** to enforce patterns
4. **Consider error analytics** dashboard for production monitoring

---

## Questions & Concerns

### Q: Will this break existing functionality?
**A:** No. We're enhancing error handling, not changing business logic. All API calls remain the same.

### Q: What about performance impact?
**A:** Minimal. ErrorHandlerService operations are fast, and error paths are not hot paths.

### Q: How do we test error scenarios?
**A:** Mock ErrorHandlerService in unit tests, simulate errors in integration tests.

### Q: What about backwards compatibility?
**A:** No backwards compatibility concerns - this is internal refactoring.

---

## Approval & Sign-off

- [ ] Architecture review approved
- [ ] Technical lead sign-off
- [ ] Timeline approved
- [ ] Testing strategy approved
- [ ] Ready to implement

---

**Document Owner:** Architecture Team
**Last Updated:** 2025-10-13
**Next Review:** After Phase 1 completion
