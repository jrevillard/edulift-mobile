# Token Expiry Onboarding Redirect Bug Fix

## Executive Summary

**Bug:** User with expired token and existing family is redirected to **onboarding page** instead of **login page**.

**Root Cause:** Router family status check fails with 403 (expired token), but the error is misinterpreted as "user has no family" instead of "authentication failed".

**Fix:** Distinguish between authentication errors (401/403) and genuine "no family" errors at three levels:
1. **FamilyRepository**: Return distinct error codes for auth failures
2. **UserFamilyService**: Throw exception for auth errors so router knows it's not "no family"
3. **Router**: Catch auth exceptions and redirect to login instead of onboarding

---

## Bug Analysis

### Scenario

User `toto@toto.fr` logs in successfully but token expires 3 hours later (expired at 17:07:03, current time 20:05:09).

### Actual Behavior (Bug)

```
1. ✅ User authenticated: isAuthenticated=true, user=cmfliqfcb00009jkj2brjcuua
2. ✅ Router checks family status via cachedUserFamilyStatusProvider
3. ❌ API call to /families/current returns 403: "Invalid or expired token"
4. ❌ NetworkAuthInterceptor clears token and triggers logout
5. ❌ FamilyRepository returns ApiFailure.notFound(resource: 'Family')
6. ❌ UserFamilyService.hasFamily() returns false
7. ❌ Router logic: isAuthenticated=true + hasFamily=false → Redirect to /onboarding/wizard
8. ❌ User sees onboarding wizard even though they HAVE a family
```

### Expected Behavior

```
1. ✅ User authenticated: isAuthenticated=true, user=cmfliqfcb00009jkj2brjcuua
2. ✅ Router checks family status via cachedUserFamilyStatusProvider
3. ✅ API call to /families/current returns 403: "Invalid or expired token"
4. ✅ FamilyRepository detects auth error (403) and returns ApiFailure(code: 'family.auth_failed')
5. ✅ UserFamilyService.hasFamily() throws Exception('Authentication failed')
6. ✅ Router catches auth exception and redirects to /auth/login
7. ✅ User sees login page to re-authenticate
```

### Why This Matters

| Scenario | Expected Redirect | Actual Redirect (Bug) | User Experience Impact |
|----------|-------------------|----------------------|------------------------|
| Valid token + No family | → Onboarding | → Onboarding | ✅ Correct |
| Valid token + Has family | → Dashboard | → Dashboard | ✅ Correct |
| **Expired token + Has family** | **→ Login** | **→ Onboarding** | ❌ **Confusing!** User already has family setup |
| No token | → Login | → Login | ✅ Correct |

---

## Technical Root Cause

### 1. **FamilyRepository Level** (Before Fix)

```dart
// family_repository_impl.dart (OLD)
try {
  final response = await ApiResponseHelper.execute(
    () => _remoteDataSource.getCurrentFamily(),
  );
  // ... success handling
} catch (e) {
  // 403 auth error falls through to this generic handler
  if (e is ApiException && e.errorCode == 'api.not_found') {
    return Result.err(ApiFailure.notFound(resource: 'Family'));
  }
  // ❌ BUG: 403 auth errors treated same as "no family found"
  return Result.err(ApiFailure(...));
}
```

### 2. **UserFamilyService Level** (Before Fix)

```dart
// user_family_service.dart (OLD)
Future<bool> hasFamily(String? userId) async {
  final familyResult = await _ref.read(familyRepositoryProvider).getCurrentFamily();
  // ❌ BUG: All errors (including 403 auth) interpreted as "no family"
  return familyResult.isOk && familyResult.value != null;
}
```

### 3. **Router Level** (Before Fix)

```dart
// app_router.dart (OLD)
if (isAuthenticated && isSplashRoute) {
  final userHasFamily = await ref.read(cachedUserFamilyStatusProvider(currentUser?.id).future);
  if (!userHasFamily) {
    // ❌ BUG: Redirects to onboarding even if hasFamily=false due to auth error
    return '/onboarding/wizard';
  }
  return AppRoutes.dashboard;
}
```

---

## Solution Implementation

### Fix 1: FamilyRepository - Detect Auth Errors

**File:** `/workspace/mobile_app/lib/features/family/data/repositories/family_repository_impl.dart`

```dart
} catch (e) {
  // ... existing handlers for NoFamilyException and api.not_found ...

  // BUGFIX: Handle authentication/authorization errors (401/403) separately
  // These indicate token expiry/invalid, NOT "no family"
  if (e is ApiException) {
    if (e.isAuthenticationError || e.isAuthorizationError) {
      AppLogger.warning(
        '[FAMILY] Authentication/Authorization error (${e.statusCode}) - token likely expired/invalid',
      );
      // Return auth-specific error so router knows it's NOT "no family"
      return Result.err(
        ApiFailure(
          code: 'family.auth_failed',
          details: {
            'error': e.message,
            'statusCode': e.statusCode,
            'isAuthError': true,
          },
          statusCode: e.statusCode ?? 401,
        ),
      );
    }
  }

  // ... rest of error handling ...
}
```

**Key Changes:**
- Check if `ApiException` has `isAuthenticationError` or `isAuthorizationError` (401/403)
- Return `ApiFailure` with code `'family.auth_failed'` to distinguish from genuine "no family"
- Include `isAuthError: true` in details for debugging

### Fix 2: UserFamilyService - Throw on Auth Errors

**File:** `/workspace/mobile_app/lib/core/services/user_family_service.dart`

```dart
/// BUGFIX: Throws exception for auth errors (401/403) so router knows
/// it's token expiry, not "no family". Router will redirect to login.
Future<bool> hasFamily(String? userId) async {
  if (userId == null) return false;

  final familyResult = await _ref.read(familyRepositoryProvider).getCurrentFamily();

  // BUGFIX: Check if this is an auth error (token expired/invalid)
  if (familyResult.isErr) {
    final error = familyResult.error!;
    if (error.code == 'family.auth_failed' ||
        (error.statusCode == 401 || error.statusCode == 403)) {
      // This is an auth error - let it bubble up
      // Router will detect this and redirect to login instead of onboarding
      throw Exception('Authentication failed: ${error.code}');
    }
    // Other errors (like "not found") mean user genuinely has no family
    return false;
  }

  return familyResult.value != null;
}
```

**Key Changes:**
- Check error code `'family.auth_failed'` or status codes 401/403
- Throw `Exception` to signal auth failure (not a normal "no family" case)
- Other errors still return `false` (genuine "no family")

### Fix 3: Router - Catch Auth Exceptions

**File:** `/workspace/mobile_app/lib/core/router/app_router.dart`

Applied to **6 locations** where `cachedUserFamilyStatusProvider` is checked:

```dart
// Handle authenticated users on splash screen
if (isAuthenticated && isSplashRoute) {
  // BUGFIX: Catch auth errors (token expired) separately from "no family"
  try {
    final userHasFamily = await ref.read(cachedUserFamilyStatusProvider(currentUser?.id).future);
    if (!userHasFamily) {
      return '/onboarding/wizard';
    }
    return AppRoutes.dashboard;
  } catch (e) {
    // BUGFIX: If family check throws auth error, redirect to login
    if (e.toString().contains('Authentication failed')) {
      core_logger.AppLogger.warning(
        '🔄 [GoRouter Redirect] DECISION: Auth error during family check (token likely expired) - redirecting to login\n'
        '   - Error: $e\n'
        '   - This prevents users with expired tokens from seeing onboarding');
      return AppRoutes.login;
    }
    rethrow;
  }
}
```

**Locations Fixed:**
1. ✅ Splash route handler (line ~526)
2. ✅ Login/auth page handler (line ~559)
3. ✅ Dashboard access check (line ~589)
4. ✅ Family creation page check (line ~614)
5. ✅ Protected routes check (line ~639)
6. ✅ `_checkFamilyStatusAndGetRoute` helper (line ~36)
7. ✅ Magic link success handler (line ~518)
8. ✅ Auth page redirect handler (line ~543)

---

## Error Flow Comparison

### Before Fix (Bug)

```
User with expired token arrives at splash page
  ↓
Router: isAuthenticated=true → Check family status
  ↓
FamilyRepository.getCurrentFamily()
  ↓
API: GET /families/current → 403 "Invalid or expired token"
  ↓
FamilyRepository catch block: ApiException (statusCode=403)
  ↓
❌ Return: Result.err(ApiFailure.notFound(resource: 'Family'))
  ↓
UserFamilyService.hasFamily() → false
  ↓
Router: isAuthenticated=true + hasFamily=false
  ↓
❌ Redirect: /onboarding/wizard (WRONG!)
```

### After Fix (Correct)

```
User with expired token arrives at splash page
  ↓
Router: isAuthenticated=true → Check family status
  ↓
FamilyRepository.getCurrentFamily()
  ↓
API: GET /families/current → 403 "Invalid or expired token"
  ↓
FamilyRepository catch block: ApiException (statusCode=403)
  ↓
✅ Detect: e.isAuthorizationError == true
  ↓
✅ Return: Result.err(ApiFailure(code: 'family.auth_failed', statusCode: 403))
  ↓
UserFamilyService.hasFamily()
  ↓
✅ Detect: error.code == 'family.auth_failed'
  ↓
✅ Throw: Exception('Authentication failed: family.auth_failed')
  ↓
Router catch block
  ↓
✅ Detect: e.toString().contains('Authentication failed')
  ↓
✅ Redirect: /auth/login (CORRECT!)
```

---

## Testing Scenarios

### Scenario 1: User with Expired Token
**Given:** User authenticated with token that expired 3 hours ago
**When:** User navigates to splash page
**Then:** User should be redirected to login page (not onboarding)

### Scenario 2: New User Without Family
**Given:** User authenticated with valid token but no family
**When:** User navigates to splash page
**Then:** User should be redirected to onboarding wizard

### Scenario 3: Existing User With Family
**Given:** User authenticated with valid token and existing family
**When:** User navigates to splash page
**Then:** User should be redirected to dashboard

### Scenario 4: Dashboard Access With Expired Token
**Given:** User authenticated with expired token
**When:** User tries to access `/dashboard`
**Then:** User should be redirected to login page

### Scenario 5: Protected Route With Expired Token
**Given:** User authenticated with expired token
**When:** User tries to access `/family`, `/groups`, or `/schedule`
**Then:** User should be redirected to login page

---

## Files Modified

### 1. `/workspace/mobile_app/lib/features/family/data/repositories/family_repository_impl.dart`
**Changes:**
- Added auth error detection in `getCurrentFamily()` catch block (lines 105-127)
- Return `ApiFailure(code: 'family.auth_failed')` for 401/403 errors

### 2. `/workspace/mobile_app/lib/core/services/user_family_service.dart`
**Changes:**
- Updated `hasFamily()` to throw exception for auth errors (lines 23-49)
- Added detailed documentation explaining auth error handling

### 3. `/workspace/mobile_app/lib/core/router/app_router.dart`
**Changes:**
- Added try-catch blocks around all `cachedUserFamilyStatusProvider` calls
- Added auth exception handling in 8 locations
- Updated `_checkFamilyStatusAndGetRoute` helper to detect and throw auth errors
- All auth errors now redirect to login page instead of onboarding

---

## Benefits

### 1. **Correct User Experience**
- Users with expired tokens see login page (not confusing onboarding)
- Onboarding only shows for genuine new users without families

### 2. **Clear Error Classification**
```dart
// Before: All errors looked the same
ApiFailure.notFound(resource: 'Family')

// After: Distinct error types
ApiFailure.notFound(resource: 'Family')        // Genuine "no family"
ApiFailure(code: 'family.auth_failed')         // Token expired/invalid
```

### 3. **Maintainability**
- Clear separation of concerns:
  - Repository: Detect and classify errors
  - Service: Propagate auth errors as exceptions
  - Router: Handle exceptions with appropriate redirects

### 4. **Debugging**
- Detailed logging at each level shows exact error flow
- Easy to trace why user was redirected to login vs onboarding

---

## Related Components

### Token Expiry Flow

The fix integrates with existing token expiry handling:

1. **NetworkAuthInterceptor** (lines 52-61):
   - Clears token on 401/403
   - Notifies via `tokenExpiredProvider`

2. **AuthNotifier** (lines 148-172):
   - Listens to `tokenExpiredProvider`
   - Triggers logout on token expiry

3. **Router** (this fix):
   - Now correctly distinguishes auth errors from "no family"
   - Redirects to login instead of onboarding

### Error Handling Architecture

```
API 403 Response
  ↓
NetworkAuthInterceptor
  ├─ Clears token
  └─ Notifies tokenExpiredProvider
       ↓
AuthNotifier (async)
  └─ Triggers logout()
       ↓
FamilyRepository (this fix)
  └─ Returns ApiFailure(code: 'family.auth_failed')
       ↓
UserFamilyService (this fix)
  └─ Throws Exception('Authentication failed')
       ↓
Router (this fix)
  └─ Catches exception → Redirects to login
```

---

## Conclusion

This fix ensures users with expired tokens are **always redirected to login**, not onboarding, by:
1. **Classifying** auth errors separately from "no family" errors at repository level
2. **Propagating** auth errors as exceptions at service level
3. **Handling** auth exceptions with login redirects at router level

The fix maintains clean architecture while providing clear, user-friendly navigation for expired token scenarios.

---

## Verification Steps

To verify the fix works:

1. **Simulate Expired Token:**
   - Log in successfully
   - Wait for token to expire (or manually set expired token in storage)
   - Navigate to any protected route

2. **Expected Behavior:**
   - Family API call returns 403
   - Router redirects to `/auth/login`
   - User can re-authenticate

3. **Check Logs:**
   ```
   [FAMILY] Authentication/Authorization error (403) - token likely expired/invalid
   🔄 [GoRouter Redirect] DECISION: Auth error during family check (token likely expired) - redirecting to login
   ```

4. **Verify Onboarding Still Works:**
   - Create new user account
   - Complete magic link verification
   - Should see onboarding wizard (not login page)
