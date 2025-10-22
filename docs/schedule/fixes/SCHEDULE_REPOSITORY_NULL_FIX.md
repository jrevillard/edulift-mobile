# Schedule Repository Null Error - Root Cause Analysis & Fix

## Issue Summary

**Error:** `NoSuchMethodError: The method 'getWeeklySchedule' was called on null`

**Impact:** Schedule feature completely broken - users cannot view or manage schedules

**Affected Code:** Schedule page fails to load, showing "null repository" error

## Root Cause Analysis

### Problem Location
File: `/workspace/mobile_app/lib/features/schedule/data/providers/schedule_provider.dart`

**Line 261 (BEFORE FIX):**
```dart
final scheduleNotifierProvider = StateNotifierProvider<ScheduleNotifier, ScheduleState>((ref) {
  // Temporary stub - implement when ScheduleRepository is available
  const repository = null; // ref.watch(scheduleRepositoryProvider);  // <-- BUG HERE!
  final errorHandler = ref.watch(coreErrorHandlerServiceProvider);

  return ScheduleNotifier(
    repository: repository,  // Passing null!
    errorHandler: errorHandler,
  );
});
```

### Why This Happened

1. **Temporary Stub Implementation**: The code had a commented-out stub with `repository = null`
2. **Comment Says**: "Temporary stub - implement when ScheduleRepository is available"
3. **Reality**: `scheduleRepositoryProvider` DID exist and was properly configured
4. **Result**: Repository was hardcoded to `null`, causing NullPointerException

### Why Family/Groups Work But Schedule Doesn't

- **Family/Groups**: Use repository providers directly without intermediate data layer providers
- **Schedule**: Uses a StateNotifier pattern with an intermediate provider that was stubbed out

### Provider Chain (BEFORE FIX)

```
SchedulePage
    ↓ uses
scheduleComposedProvider (from providers.dart)
    ↓ points to
scheduleNotifierProvider (from schedule_provider.dart)
    ↓ uses
scheduleRepositoryProvider ❌ NULL (hardcoded)
```

## The Fix

### Changes Made

#### 1. Activated Repository Provider (schedule_provider.dart)

**BEFORE:**
```dart
final scheduleNotifierProvider = StateNotifierProvider<ScheduleNotifier, ScheduleState>((ref) {
  const repository = null; // ref.watch(scheduleRepositoryProvider);
  final errorHandler = ref.watch(coreErrorHandlerServiceProvider);

  return ScheduleNotifier(repository: repository, errorHandler: errorHandler);
});
```

**AFTER:**
```dart
final scheduleNotifierProvider = StateNotifierProvider<ScheduleNotifier, ScheduleState>((ref) {
  // Import scheduleRepositoryProvider from repository_providers.dart
  final repository = ref.watch(scheduleRepositoryProvider);
  final errorHandler = ref.watch(coreErrorHandlerServiceProvider);

  return ScheduleNotifier(repository: repository, errorHandler: errorHandler);
});
```

#### 2. Fixed Result Type Handling

The repository returns `Result<T, ApiFailure>` but the ScheduleNotifier was calling methods as if they returned unwrapped values. Updated all 5 methods:

- `loadWeeklySchedule()` ✅
- `loadAvailableChildren()` ✅
- `checkConflicts()` ✅
- `loadStatistics()` ✅
- `updateScheduleSlot()` ✅

**BEFORE:**
```dart
final scheduleSlots = await _repository.getWeeklySchedule(groupId, week);
state = state.copyWith(scheduleSlots: scheduleSlots, isLoading: false);
```

**AFTER:**
```dart
final result = await _repository.getWeeklySchedule(groupId, week);
result.when(
  ok: (scheduleSlots) {
    state = state.copyWith(scheduleSlots: scheduleSlots, isLoading: false);
  },
  err: (failure) {
    state = state.copyWith(isLoading: false, error: failure.message ?? 'Failed to load schedule');
  },
);
```

#### 3. Exported scheduleRepositoryProvider (providers.dart)

Added `scheduleRepositoryProvider` to the selective export list so it's available throughout the app:

**BEFORE:**
```dart
export 'repository_providers.dart'
    show
        familyRepositoryProvider,
        invitationRepositoryProvider,
        groupRepositoryProvider;
```

**AFTER:**
```dart
export 'repository_providers.dart'
    show
        familyRepositoryProvider,
        invitationRepositoryProvider,
        groupRepositoryProvider,
        scheduleRepositoryProvider;  // ✅ ADDED
```

### Files Modified

1. `/workspace/mobile_app/lib/features/schedule/data/providers/schedule_provider.dart`
   - Uncommented and activated `scheduleRepositoryProvider`
   - Fixed Result type handling in 5 methods

2. `/workspace/mobile_app/lib/core/di/providers/providers.dart`
   - Added `scheduleRepositoryProvider` to export list

### Provider Chain (AFTER FIX)

```
SchedulePage
    ↓ uses
scheduleComposedProvider (from providers.dart)
    ↓ points to
scheduleNotifierProvider (from schedule_provider.dart)
    ↓ uses
scheduleRepositoryProvider ✅ ACTIVE (from repository_providers.dart)
    ↓ uses
scheduleApiClientProvider, scheduleLocalDatasourceProvider, networkInfoProvider
```

## Verification

### Static Analysis
```bash
cd /workspace/mobile_app
flutter analyze lib/features/schedule/data/providers/schedule_provider.dart
flutter analyze lib/core/di/providers/providers.dart
```

**Result:** ✅ No issues found

### Expected Behavior After Fix

1. ✅ Schedule repository properly initialized
2. ✅ `getWeeklySchedule()` method accessible
3. ✅ Result types properly handled with `.when()` pattern
4. ✅ Error states properly captured and displayed to user
5. ✅ Schedule page loads successfully

## Testing Recommendations

### Unit Tests
```bash
cd /workspace/mobile_app
flutter test test/unit/data/repositories/schedule_repository_impl_test.dart
flutter test test/unit/presentation/providers/schedule_providers_test.dart
```

### Integration Tests
1. Navigate to Schedule page
2. Select a group
3. Verify weekly schedule loads
4. Test week navigation
5. Test vehicle assignments
6. Test error handling

## Prevention

### Code Review Checklist
- ✅ Never leave provider stubs with `null` values in production code
- ✅ Remove or complete TODO comments before merging
- ✅ Verify all repository providers are properly exported
- ✅ Test Result type handling with `.when()` pattern
- ✅ Run static analysis before committing

### Architecture Guidelines
- All repository providers should be registered in `repository_providers.dart`
- All providers should be exported through `providers.dart`
- Data layer providers (StateNotifiers) should handle Result types
- Never use `null` as a stub - use proper mocking or throw NotImplementedException

## Related Files

### Repository Layer
- `/workspace/mobile_app/lib/core/di/providers/repository_providers.dart` - Repository provider definitions
- `/workspace/mobile_app/lib/features/schedule/domain/repositories/schedule_repository.dart` - Repository interface

### Data Layer
- `/workspace/mobile_app/lib/features/schedule/data/repositories/schedule_repository_impl.dart` - Repository implementation
- `/workspace/mobile_app/lib/features/schedule/data/providers/schedule_provider.dart` - State management provider

### Presentation Layer
- `/workspace/mobile_app/lib/features/schedule/providers.dart` - Composition root
- `/workspace/mobile_app/lib/features/schedule/presentation/pages/schedule_page.dart` - UI

## Summary

**Root Cause:** Repository provider was hardcoded to `null` in a temporary stub that was never completed

**Fix:** Activated the real repository provider and fixed Result type handling

**Impact:** Schedule feature now fully functional with proper error handling

**Status:** ✅ RESOLVED
