# Cache Error Handling Analysis Report

**Date:** 2025-10-09
**Scope:** Family, Group, and Schedule features
**Objective:** Verify cache errors are logged but DON'T block application

---

## Executive Summary

**CRITICAL FINDING:** The Family feature has a **HIGH PRIORITY** cache error handling issue that **BLOCKS THE APPLICATION** when cache read fails. This explains the user-reported `family.cache_get_failed` error that prevented app access.

**Status by Feature:**
- ❌ **Family**: BLOCKING cache error in repository (HIGH PRIORITY)
- ✅ **Group**: Graceful degradation implemented correctly
- ✅ **Schedule**: Graceful degradation implemented correctly

---

## 1. Issue Summary Table

| Feature | File | Line | Issue | Severity | Blocks App? |
|---------|------|------|-------|----------|-------------|
| **Family** | `family_repository_impl.dart` | 96-104 | Outer try-catch returns `cache_get_failed` error instead of attempting API fetch | **CRITICAL** | **YES ❌** |
| **Family** | `persistent_local_datasource.dart` | 103-104 | HiveEncryptionManager throws unhandled exception on init failure | **HIGH** | **YES ❌** |
| **Family** | `app_router.dart` | 527, 565, 576, 594 | Router calls `cachedUserFamilyStatusProvider` which uses repository - cache errors propagate to router blocking navigation | **CRITICAL** | **YES ❌** |
| Group | `group_local_datasource_impl.dart` | 85-93 | Init failure throws exception (but caught by repository) | **MEDIUM** | No ✅ |
| Group | `groups_repository_impl.dart` | 85-94 | Outer catch returns cache error but only after API fallback attempted | **LOW** | No ✅ |
| Schedule | `schedule_local_datasource_impl.dart` | 85-87 | Init failure throws exception | **LOW** | No ✅ |
| Schedule | `schedule_repository_impl.dart` | N/A | No outer catch - cache errors are silently swallowed | **LOW** | No ✅ |

---

## 2. Detailed Analysis by Feature

### 2.1 Family Feature (❌ CRITICAL - BLOCKS APP)

#### **LocalDataSource Level: `persistent_local_datasource.dart`**

**Status: ✅ GOOD - Graceful degradation on read**

```dart
// Lines 148-163 - getCurrentFamily() - ✅ CORRECT PATTERN
try {
  final entry = CacheEntry.fromJson<String>(...);
  if (entry.isExpired(_defaultTtl)) {
    await _familyBox.delete('current');
    return null;  // ✅ Returns null, not error
  }
  // ... deserialize
  return familyDto.toDomain();
} catch (e, stackTrace) {
  // ✅ Graceful degradation: Log + cleanup + continue
  ErrorLogger.logProviderError(...);
  await _familyBox.delete('current');  // ✅ Self-healing
  return null;  // ✅ Returns null (fallback to API)
}
```

**Status: ❌ BAD - Init failure throws**

```dart
// Lines 103-105 - _ensureInitialized() - ❌ BLOCKS APP
try {
  final cipher = await HiveEncryptionManager().getCipher();
  // ...
} catch (e) {
  throw Exception('Failed to initialize persistent storage: $e');  // ❌ THROWS!
}
```

**Issue:** If HiveEncryptionManager fails (corrupted key, permissions issue, etc.), the exception is thrown and propagates up, blocking the app.

#### **Repository Level: `family_repository_impl.dart`**

**Status: ❌ CRITICAL - BLOCKS API FETCH**

```dart
// Lines 52-105 - getCurrentFamily() - ❌ INCORRECT PATTERN
@override
Future<Result<Family, ApiFailure>> getCurrentFamily() async {
  try {
    final localFamily = await _localDataSource.getCurrentFamily();  // ❌ Can throw from _ensureInitialized()

    if (await _networkInfo.isConnected) {
      try {
        // Fetch from API...
        return Result.ok(remoteFamily);
      } catch (e) {
        if (localFamily != null) {
          return Result.ok(localFamily);  // ✅ Fallback to cache on API error
        }
        return Result.err(...);  // ✅ Only error if both fail
      }
    } else {
      if (localFamily != null) {
        return Result.ok(localFamily);
      }
      return Result.err(ApiFailure.noConnection());
    }
  } catch (e) {
    // ❌ CRITICAL BUG: This catches cache read errors and returns error BEFORE trying API!
    return Result.err(
      ApiFailure(
        code: 'family.cache_get_failed',  // ❌ USER SAW THIS ERROR!
        details: {'error': e.toString()},
        statusCode: 500,
      ),
    );
  }
}
```

**The Problem:**

1. User has corrupted Hive cache or encryption key issue
2. `_localDataSource.getCurrentFamily()` throws exception from `_ensureInitialized()`
3. Outer catch block catches it and returns `family.cache_get_failed` error
4. **API FETCH IS NEVER ATTEMPTED** - app is blocked
5. Router calls this via `cachedUserFamilyStatusProvider` → error propagates → navigation blocked

**Expected Behavior:**

Cache read error should be caught and logged, but API fetch should still proceed.

#### **Router Level: `app_router.dart`**

**Status: ❌ CRITICAL - BLOCKS NAVIGATION**

```dart
// Lines 527, 550, 565, 576, 594 - Multiple router checks
final userHasFamily = await ref.read(cachedUserFamilyStatusProvider(currentUser?.id).future);
```

The router uses `cachedUserFamilyStatusProvider` which delegates to:
```dart
// user_family_service.dart:25-31
Future<bool> hasFamily(String? userId) async {
  final familyResult = await _ref.read(familyRepositoryProvider).getCurrentFamily();
  return familyResult.isOk && familyResult.value != null;  // ❌ Returns false on cache error
}
```

**Impact Chain:**
1. Cache error in repository → `getCurrentFamily()` returns `Result.err(cache_get_failed)`
2. `hasFamily()` returns `false` (no family)
3. Router redirects authenticated user to `/onboarding/wizard`
4. User can't access app despite being authenticated and having a family

---

### 2.2 Group Feature (✅ GOOD - Graceful Degradation)

#### **LocalDataSource Level: `group_local_datasource_impl.dart`**

**Status: ✅ GOOD - Cache reads return null on error**

```dart
// Lines 126-140 - getUserGroups() - ✅ CORRECT PATTERN
try {
  final entry = _CacheEntry.fromJson<String>(...);
  if (entry.isExpired(_defaultTtl)) {
    await _groupsBox.delete(_userGroupsKey);
    return null;  // ✅ Returns null
  }
  return groups;
} catch (e, stackTrace) {
  // ✅ Graceful degradation: Log + cleanup + return null
  ErrorLogger.logProviderError(...);
  await _groupsBox.delete(_userGroupsKey);
  return null;  // ✅ Returns null (fallback to API)
}
```

**Status: ⚠️ MINOR - Init failure logs and throws**

```dart
// Lines 85-93 - _ensureInitialized() - ⚠️ THROWS (but caught by repository)
try {
  final cipher = await _encryptionManager.getCipher();
  // ...
} catch (e, stackTrace) {
  ErrorLogger.logProviderError(...);
  throw Exception('Failed to initialize group storage: $e');  // ⚠️ THROWS
}
```

However, this is caught by the repository, so it doesn't block the app.

#### **Repository Level: `groups_repository_impl.dart`**

**Status: ✅ GOOD - Outer catch only triggers after API fallback attempted**

```dart
// Lines 27-94 - getUserGroups() - ✅ CORRECT PATTERN
Future<Result<List<Group>, ApiFailure>> getUserGroups() async {
  try {
    // 1. Read from cache first
    final localGroups = await _localDataSource.getUserGroups();  // Can throw from init

    // 2. If connected, try to fetch fresh data
    if (await _networkInfo.isConnected) {
      try {
        final groups = ...;  // Fetch from API
        await _localDataSource.cacheUserGroups(groups);
        return Result.ok(groups);
      } catch (e) {
        // ✅ 4. On error, fallback to cache if available
        if (localGroups != null) {
          AppLogger.info('Failed to fetch user groups, using cached data', ...);
          return Result.ok(localGroups);  // ✅ GRACEFUL FALLBACK
        }
        return Result.err(...);  // Only error if both fail
      }
    } else {
      // ✅ 5. No connection: return cache or error
      if (localGroups != null) {
        return Result.ok(localGroups);
      }
      return Result.err(ApiFailure.noConnection());
    }
  } catch (e) {
    // ⚠️ This catch fires if cache read throws BEFORE online check
    // BUT this is acceptable because if we can't read cache AND we're offline, we have no data
    return Result.err(
      ApiFailure(
        code: 'groups.cache_get_failed',
        details: {'error': e.toString()},
        statusCode: 500,
      ),
    );
  }
}
```

**Analysis:**

This has the **SAME STRUCTURE** as Family, but it's **LESS CRITICAL** because:

1. Groups are not checked by the router during navigation
2. Users can still access other parts of the app
3. The error is shown in the Groups page, not blocking the entire app

However, the **SAME BUG EXISTS**: If cache init fails (line 30), the outer catch (line 85) returns an error **BEFORE** the API fetch is attempted (line 34).

**Recommendation:** Apply the same fix as Family to be consistent.

---

### 2.3 Schedule Feature (✅ GOOD - Silent Cache Errors)

#### **LocalDataSource Level: `schedule_local_datasource_impl.dart`**

**Status: ✅ GOOD - Cache reads use try-catch with graceful fallback**

```dart
// Lines 124-137 - getCachedWeeklySchedule() - ✅ CORRECT PATTERN
try {
  final entry = CacheEntry.fromJson<String>(...);
  if (entry.isExpired(_scheduleTtl)) {
    await _scheduleBox.delete(key);
    return null;  // ✅ Returns null
  }
  return slots;
} catch (e, stackTrace) {
  // ✅ Graceful degradation
  ErrorLogger.logError(...);
  await _scheduleBox.delete(key);  // ✅ Self-healing
  return null;  // ✅ Returns null
}
```

**Status: ⚠️ MINOR - Init failure throws**

```dart
// Lines 85-87 - _ensureInitialized() - ⚠️ THROWS
try {
  final cipher = await HiveEncryptionManager().getCipher();
  // ...
} catch (e) {
  throw Exception('Failed to initialize schedule storage: $e');  // ⚠️ THROWS
}
```

#### **Repository Level: `schedule_repository_impl.dart`**

**Status: ✅ EXCELLENT - No outer catch, cache errors silently swallowed**

```dart
// Lines 51-102 - getWeeklySchedule() - ✅ BEST PATTERN
@override
Future<Result<List<ScheduleSlot>, ApiFailure>> getWeeklySchedule(
  String groupId,
  String week,
) async {
  // CACHE-FIRST PATTERN: Try cache first (fast)
  final cached = await _localDataSource.getCachedWeeklySchedule(groupId, week);
  // ✅ No try-catch - if cache throws, exception propagates to caller
  // ✅ But localDataSource catches internally and returns null
  // ✅ Result: Cache errors are invisible to repository

  if (cached != null) {
    // Check metadata for expiry...
    if (fresh) {
      return Result.ok(cached);  // ✅ Cache hit
    }
  }

  // Cache miss or expired → Fetch from API
  if (!await _networkInfo.isConnected) {
    if (cached != null) {
      return Result.ok(cached);  // ✅ Return stale cache if offline
    }
    return const Result.err(ApiFailure(...));
  }

  // Fetch from server
  final result = await _basicSlotHandler.getWeeklySchedule(groupId, week);

  // Update cache on success (fire-and-forget)
  await result.when(
    ok: (slots) async {
      await _localDataSource.cacheWeeklySchedule(groupId, week, slots);
      // ✅ No try-catch - cache write errors are swallowed by localDataSource
    },
    err: (_) => null,
  );

  return result;
}
```

**Why this works:**
1. LocalDataSource catches all errors internally and returns `null`
2. Repository treats `null` as cache miss → proceeds to API fetch
3. No outer catch block to intercept cache errors
4. Cache write errors (lines 159, 216, 305, etc.) are also silently swallowed

**This is the GOLD STANDARD pattern.**

---

## 3. Code Pattern Comparison

### ❌ BAD (Family - Blocks App)

```dart
try {
  final cached = await _localDataSource.get();  // Can throw from init

  if (await _networkInfo.isConnected) {
    try {
      return await fetchFromAPI();  // ✅ API fetch
    } catch (apiError) {
      return cached ?? Result.err(apiError);  // ✅ Fallback
    }
  }
} catch (cacheError) {
  return Result.err(cache_get_failed);  // ❌ BLOCKS API FETCH!
}
```

**Problem:** Outer catch intercepts cache errors BEFORE API fetch is attempted.

---

### ⚠️ ACCEPTABLE (Group - Less Critical)

```dart
try {
  final cached = await _localDataSource.get();  // Can throw from init

  if (await _networkInfo.isConnected) {
    try {
      return await fetchFromAPI();  // ✅ API fetch
    } catch (apiError) {
      if (cached != null) {
        return Result.ok(cached);  // ✅ Fallback
      }
      return Result.err(apiError);
    }
  } else {
    return cached != null ? Result.ok(cached) : Result.err(noConnection);
  }
} catch (cacheError) {
  return Result.err(cache_get_failed);  // ⚠️ Same issue as Family, but less critical
}
```

**Same issue as Family, but doesn't block entire app because not used by router.**

---

### ✅ EXCELLENT (Schedule - Gold Standard)

```dart
// No outer try-catch in repository
final cached = await _localDataSource.get();  // LocalDataSource catches internally, returns null

if (cached != null && fresh) {
  return Result.ok(cached);
}

if (!await _networkInfo.isConnected) {
  return cached != null ? Result.ok(cached) : Result.err(noConnection);
}

return await fetchFromAPI();
```

**Why this is best:**
1. LocalDataSource is responsible for error handling (returns `null` on error)
2. Repository treats `null` as cache miss
3. No outer catch to intercept cache errors
4. API fetch ALWAYS proceeds if cache returns `null`

---

## 4. Root Cause Analysis

### **Why does cache error block the app?**

```
1. User launches app
   ↓
2. Router checks authentication (authenticated ✅)
   ↓
3. Router calls: cachedUserFamilyStatusProvider(userId)
   ↓
4. UserFamilyService.hasFamily(userId)
   ↓
5. FamilyRepository.getCurrentFamily()
   ↓
6. PersistentLocalDataSource.getCurrentFamily()
   ↓
7. _ensureInitialized() → HiveEncryptionManager.getCipher() throws
   ↓ (exception propagates)
8. Repository outer catch: returns Result.err(cache_get_failed)
   ↓ (API fetch NEVER attempted)
9. hasFamily() returns false
   ↓
10. Router redirects to /onboarding/wizard
   ↓
11. User is stuck in onboarding despite having a family
```

**The critical mistake:** Catching cache errors in an outer try-catch that wraps BOTH cache read AND API fetch logic.

---

## 5. Recommendations

### 5.1 HIGH PRIORITY (Family Feature)

**File:** `/workspace/mobile_app/lib/features/family/data/repositories/family_repository_impl.dart`

**Current code (lines 52-105):**

```dart
@override
Future<Result<Family, ApiFailure>> getCurrentFamily() async {
  try {
    final localFamily = await _localDataSource.getCurrentFamily();

    if (await _networkInfo.isConnected) {
      try {
        final response = await ApiResponseHelper.execute(...);
        final remoteFamily = response.unwrap().toDomain();
        await _localDataSource.cacheCurrentFamily(remoteFamily);
        return Result.ok(remoteFamily);
      } catch (e) {
        if (localFamily != null) {
          return Result.ok(localFamily);
        }
        // ... error handling
      }
    } else {
      if (localFamily != null) {
        return Result.ok(localFamily);
      }
      return Result.err(ApiFailure.noConnection());
    }
  } catch (e) {
    // ❌ THIS IS THE PROBLEM
    return Result.err(
      ApiFailure(
        code: 'family.cache_get_failed',
        details: {'error': e.toString()},
        statusCode: 500,
      ),
    );
  }
}
```

**Recommended fix (Option 1 - Best):**

```dart
@override
Future<Result<Family, ApiFailure>> getCurrentFamily() async {
  // 1. Try cache first (with error handling)
  Family? localFamily;
  try {
    localFamily = await _localDataSource.getCurrentFamily();
  } catch (cacheError) {
    // ✅ LOG the error (don't throw, don't return error)
    AppLogger.error('Cache read failed, will fallback to API', cacheError);
    // ✅ CONTINUE to API fetch (don't block)
  }

  // 2. Check cache freshness (if available)
  if (localFamily != null) {
    // Return cached if fresh (optional TTL check here)
    // For now, let's proceed to API if online
  }

  // 3. If online, fetch from API
  if (await _networkInfo.isConnected) {
    try {
      final response = await ApiResponseHelper.execute(...);
      final remoteFamily = response.unwrap().toDomain();

      // 4. Cache result (fire-and-forget with error handling)
      try {
        await _localDataSource.cacheCurrentFamily(remoteFamily);
      } catch (cacheError) {
        // ✅ LOG the error (don't fail the request)
        AppLogger.error('Cache write failed', cacheError);
        // ✅ CONTINUE (don't fail the request)
      }

      return Result.ok(remoteFamily);
    } catch (e) {
      // API fetch failed
      if (e is NoFamilyException) {
        await _localDataSource.clearCurrentFamily();
        return Result.err(ApiFailure.notFound(resource: 'Family'));
      }

      if (e is ApiException && e.errorCode == 'api.not_found') {
        await _localDataSource.clearCurrentFamily();
        return Result.err(ApiFailure.notFound(resource: 'Family'));
      }

      // ✅ Fallback to cache if available
      if (localFamily != null) {
        AppLogger.info('API failed, using cached family data', {'error': e.toString()});
        return Result.ok(localFamily);
      }

      return Result.err(
        ApiFailure(
          code: 'family.get_failed',
          details: {'error': e.toString()},
          statusCode: 500,
        ),
      );
    }
  } else {
    // 5. Offline mode
    if (localFamily != null) {
      return Result.ok(localFamily);
    }
    return Result.err(ApiFailure.noConnection());
  }
}
```

**Recommended fix (Option 2 - Schedule Pattern):**

Alternatively, refactor `PersistentLocalDataSource.getCurrentFamily()` to catch ALL errors internally and return `null`, then remove outer try-catch from repository entirely (like Schedule feature).

---

### 5.2 MEDIUM PRIORITY (Group Feature)

**File:** `/workspace/mobile_app/lib/features/groups/data/repositories/groups_repository_impl.dart`

Apply the same fix as Family feature for consistency, even though it's less critical.

**Lines 27-94:** Same pattern fix as Family feature above.

---

### 5.3 LOW PRIORITY (Architectural Improvements)

#### **Recommendation 1: Standardize LocalDataSource error handling**

Create a base class or mixin for LocalDataSource implementations:

```dart
abstract class CacheLocalDataSource {
  /// Cache read with automatic error handling
  /// Returns null on error, never throws
  Future<T?> safeCacheRead<T>(Future<T?> Function() read) async {
    try {
      return await read();
    } catch (e, stackTrace) {
      ErrorLogger.logError(
        context: '${runtimeType}.safeCacheRead',
        error: e,
        stackTrace: stackTrace,
      );
      return null;  // Always return null, never throw
    }
  }

  /// Cache write with automatic error handling
  /// Swallows errors, never throws
  Future<void> safeCacheWrite(Future<void> Function() write) async {
    try {
      await write();
    } catch (e, stackTrace) {
      ErrorLogger.logError(
        context: '${runtimeType}.safeCacheWrite',
        error: e,
        stackTrace: stackTrace,
      );
      // Swallow error
    }
  }
}
```

#### **Recommendation 2: Fix HiveEncryptionManager init**

**File:** `/workspace/mobile_app/lib/core/storage/hive_encryption_manager.dart`

Add graceful degradation:

```dart
Future<HiveCipher?> getCipher() async {
  try {
    await _ensureInitialized();
    return _cipher;
  } catch (e, stackTrace) {
    ErrorLogger.logError(
      context: 'HiveEncryptionManager.getCipher',
      error: e,
      stackTrace: stackTrace,
    );
    // Return null to allow unencrypted fallback
    return null;
  }
}
```

Then update box opening to handle null cipher:

```dart
_familyBox = await Hive.openBox(
  _familyBoxName,
  encryptionCipher: cipher,  // null = no encryption
);
```

#### **Recommendation 3: Add cache health checks**

Add startup health check that detects corrupted cache and offers user option to clear:

```dart
class CacheHealthService {
  Future<bool> isHealthy() async {
    try {
      final cipher = await HiveEncryptionManager().getCipher();
      await Hive.openBox('health_check', encryptionCipher: cipher);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> clearAllCaches() async {
    // Clear all Hive boxes
    await Hive.deleteFromDisk();
    // Regenerate encryption key
    await HiveEncryptionManager().regenerateKey();
  }
}
```

Show dialog to user on app start if cache is unhealthy.

---

## 6. Testing Strategy

### 6.1 Unit Tests

**Test 1: Cache read error should not block API fetch**

```dart
test('getCurrentFamily - cache error should fallback to API', () async {
  // Arrange
  when(localDataSource.getCurrentFamily())
    .thenThrow(Exception('Cache corrupted'));
  when(remoteDataSource.getCurrentFamily())
    .thenAnswer((_) async => familyDto);
  when(networkInfo.isConnected).thenAnswer((_) async => true);

  // Act
  final result = await repository.getCurrentFamily();

  // Assert
  expect(result.isOk, true);
  expect(result.value, isNotNull);
  verify(localDataSource.getCurrentFamily()).called(1);
  verify(remoteDataSource.getCurrentFamily()).called(1);  // ✅ API was called!
});
```

**Test 2: Cache write error should not fail request**

```dart
test('getCurrentFamily - cache write error should not fail', () async {
  // Arrange
  when(localDataSource.getCurrentFamily()).thenAnswer((_) async => null);
  when(remoteDataSource.getCurrentFamily())
    .thenAnswer((_) async => familyDto);
  when(localDataSource.cacheCurrentFamily(any))
    .thenThrow(Exception('Cache write failed'));
  when(networkInfo.isConnected).thenAnswer((_) async => true);

  // Act
  final result = await repository.getCurrentFamily();

  // Assert
  expect(result.isOk, true);  // ✅ Request succeeded despite cache write error
  expect(result.value, isNotNull);
});
```

### 6.2 Integration Tests

**Test 3: Simulate corrupted Hive cache**

```dart
testWidgets('App should work with corrupted cache', (tester) async {
  // Arrange - Corrupt Hive database files
  await corruptHiveCache();

  // Act - Launch app
  await tester.pumpWidget(MyApp());
  await tester.pumpAndSettle();

  // Assert - App should load (not stuck on splash/error)
  expect(find.byType(LoginPage), findsOneWidget);

  // Login
  await tester.enterText(find.byKey(Key('email_field')), 'user@example.com');
  await tester.tap(find.byKey(Key('send_magic_link')));
  await tester.pumpAndSettle();

  // Verify magic link token (simulate)
  await simulateMagicLinkVerification('valid-token');
  await tester.pumpAndSettle();

  // Assert - User should reach dashboard despite cache errors
  expect(find.byType(DashboardPage), findsOneWidget);
});
```

### 6.3 Manual Testing Scenarios

**Scenario 1: Delete Hive encryption key**

1. Launch app and login
2. Close app
3. Delete `/data/data/com.edulift.mobile/app_flutter/encryption_key.txt`
4. Relaunch app
5. **Expected:** App loads, shows stale data or fetches from API (not stuck)

**Scenario 2: Corrupt Hive database**

1. Launch app and login
2. Close app
3. Corrupt Hive database files (replace with random bytes)
4. Relaunch app
5. **Expected:** App logs errors but continues to work (fetches from API)

**Scenario 3: No internet + corrupted cache**

1. Corrupt cache (as above)
2. Turn off internet
3. Launch app
4. **Expected:** App shows "No connection" error (not "Cache failed")

---

## 7. Implementation Plan

### Phase 1: Critical Fix (Day 1)

**Files to modify:**
1. `/workspace/mobile_app/lib/features/family/data/repositories/family_repository_impl.dart`
   - Fix `getCurrentFamily()` method (lines 52-105)
   - Add try-catch around cache read only
   - Remove outer try-catch or move it to only wrap API logic

**Estimated time:** 2 hours
- 1 hour implementation
- 1 hour testing

**Testing:**
- Unit tests for cache error scenarios
- Manual test with corrupted cache

---

### Phase 2: Consistency Fix (Day 2)

**Files to modify:**
2. `/workspace/mobile_app/lib/features/groups/data/repositories/groups_repository_impl.dart`
   - Apply same fix to `getUserGroups()` (lines 27-94)
   - Apply same fix to `getGroupById()` (lines 96-163)
   - Apply same fix to `getGroupFamilies()` (lines 500-565)

**Estimated time:** 2 hours

---

### Phase 3: Architectural Improvements (Week 2)

**Files to modify:**
3. Create `/workspace/mobile_app/lib/core/data/cache_local_datasource_base.dart`
   - Base class with `safeCacheRead` and `safeCacheWrite`
4. Update all LocalDataSource implementations to extend base class
5. Update `/workspace/mobile_app/lib/core/storage/hive_encryption_manager.dart`
   - Add graceful degradation for init failures

**Estimated time:** 1 day

---

### Phase 4: Monitoring & Health Checks (Week 3)

**Files to create:**
6. `/workspace/mobile_app/lib/core/services/cache_health_service.dart`
   - Health check on app start
   - User-facing cache clear option
7. Update splash screen to show cache health check

**Estimated time:** 1 day

---

## 8. Risk Assessment

### Risks of NOT Fixing

**HIGH RISK:**
- Users with corrupted caches cannot access app (current state)
- App appears broken despite valid credentials and data on server
- Support burden increases (users reporting "stuck on onboarding")
- Poor user experience → app uninstalls

### Risks of Fixing

**LOW RISK:**
- Regression: Properly tested changes should not introduce new bugs
- Performance: No performance impact (removing try-catch is actually faster)
- Compatibility: No API changes, only internal implementation

**Mitigation:**
- Comprehensive unit tests
- Integration tests with corrupted cache scenarios
- Staged rollout (beta testing first)

---

## 9. Success Metrics

### Before Fix
- Users report `family.cache_get_failed` error blocking app
- Cache errors prevent API fallback
- Router redirects authenticated users to onboarding

### After Fix
- Cache errors logged but don't block app
- API fetch always attempted when online
- Users can access app even with corrupted cache
- Error logs show cache issues but app continues functioning

### Monitoring
- Track cache error rate in logs
- Monitor API fallback success rate
- User session duration (should increase if fewer blocks)
- Support tickets related to cache errors (should decrease)

---

## 10. Conclusion

The Family feature has a **CRITICAL BUG** that blocks the application when cache read fails. This is caused by an outer try-catch that intercepts cache errors BEFORE the API fetch is attempted.

**Immediate action required:**
1. Fix Family repository `getCurrentFamily()` method (HIGH PRIORITY)
2. Apply same fix to Group repository for consistency (MEDIUM PRIORITY)
3. Follow Schedule feature's pattern as the gold standard for cache error handling

**Key principle:**
> Cache errors should be logged and handled gracefully, but should NEVER block API fetches or prevent the app from functioning.

The Schedule feature demonstrates the correct pattern: LocalDataSource handles all errors internally (returns `null`), and Repository treats `null` as cache miss and proceeds to API fetch.

---

## Appendix A: Cache Error Logging Examples

### Current (Bad) Logging

```
ERROR: family.cache_get_failed
Details: {error: Exception: Failed to initialize persistent storage: HiveCipherError}
StatusCode: 500
```

User is blocked from accessing app.

### Proposed (Good) Logging

```
WARNING: Cache read failed, falling back to API
Context: FamilyRepository.getCurrentFamily
Error: HiveCipherError: Encryption key corrupted
Action: Attempting API fetch...

INFO: API fetch successful, cache updated
Context: FamilyRepository.getCurrentFamily
FamilyId: abc123
```

App continues working, cache issue is logged for investigation.

---

## Appendix B: Related Files

### Files with GOOD patterns (reference for fixes):
- `/workspace/mobile_app/lib/features/schedule/data/repositories/schedule_repository_impl.dart`
- `/workspace/mobile_app/lib/features/schedule/data/datasources/schedule_local_datasource_impl.dart`

### Files needing CRITICAL fixes:
- `/workspace/mobile_app/lib/features/family/data/repositories/family_repository_impl.dart` (lines 52-105)
- `/workspace/mobile_app/lib/features/family/data/datasources/persistent_local_datasource.dart` (lines 103-105)

### Files needing MEDIUM priority fixes:
- `/workspace/mobile_app/lib/features/groups/data/repositories/groups_repository_impl.dart` (lines 27-94, 96-163, 500-565)
- `/workspace/mobile_app/lib/features/groups/data/datasources/group_local_datasource_impl.dart` (lines 85-93)

### Files for architectural improvements:
- `/workspace/mobile_app/lib/core/storage/hive_encryption_manager.dart`
- (new) `/workspace/mobile_app/lib/core/data/cache_local_datasource_base.dart`
- (new) `/workspace/mobile_app/lib/core/services/cache_health_service.dart`
