# Unified Invitation System - Architecture Summary

**Date**: 2025-09-30
**Status**: ✅ **IMPLEMENTATION COMPLETE**

## Overview

This document describes the unified invitation system architecture that handles both family and group invitations identically, following clean architecture principles and existing patterns.

## Key Architectural Decisions

### 1. Unified Error Context: `ErrorContext.invitationOperation()`

**Problem**: Both family and group invitations were using `ErrorContext.familyOperation()`, which was architecturally incorrect.

**Solution**: Created and implemented `ErrorContext.invitationOperation()` for both invitation types.

**Implementation**:
```dart
// lib/core/errors/error_handler_service.dart (lines 137-150)
factory ErrorContext.invitationOperation(
  String operation, {
  Map<String, dynamic>? metadata,
  String? userId,
}) {
  return ErrorContext(
    operation: operation,
    feature: 'INVITATION',  // Unified feature flag
    userId: userId,
    metadata: metadata ?? {},
    timestamp: DateTime.now(),
    sessionId: _generateSessionId(),
  );
}
```

**Usage**:
- Family invitations: `metadata: {'inviteCode': code, 'type': 'family'}`
- Group invitations: `metadata: {'inviteCode': code, 'type': 'group'}`

---

### 2. Critical Pattern: Backend Returns HTTP 200 for `valid: false`

**Backend Design**: The backend intentionally returns HTTP 200 for ALL validation responses, with a `valid` boolean field to indicate success/failure.

**Critical Implementation Pattern**:
```dart
// Provider handles valid=false in the RIGHT fold (success branch)
result.fold(
  (failure) {
    // Only TRUE HTTP errors (500, network, etc.)
    final errorKey = _mapFailureToErrorKey(failure);
    state = state.copyWith(error: errorKey);
  },
  (validation) {
    // Backend returns 200 for valid=false - handle here
    if (validation.valid == false) {
      // Map errorCode to localization key
      final errorKey = _mapValidationErrorToKey(validation);
      state = state.copyWith(error: errorKey);
    } else {
      // Validation succeeded
      state = state.copyWith(validation: validation);
    }
  },
);
```

**Why This Matters**:
- ❌ **WRONG**: Handling `valid: false` in the error fold (Left)
- ✅ **CORRECT**: Handling `valid: false` in the success fold (Right)
- This pattern is **ALREADY CORRECT** in `FamilyInvitationProvider` (lines 166-175)
- This pattern is **NOW IMPLEMENTED** in `GroupInvitationProvider`

---

## Implementation Summary

### Files Modified

#### 1. Core Service Layer
**File**: `lib/core/services/unified_invitation_service.dart`

**Changes**:
- ✅ Line 66: Family validation now uses `ErrorContext.invitationOperation()` with `type: 'family'`
- ✅ Line 120: Group validation now uses `ErrorContext.invitationOperation()` with `type: 'group'`
- ✅ Removed incorrect `ErrorContext.familyOperation()` usage
- ✅ Both invitation types now share identical error handling architecture

**Impact**: Unified error context for all invitation operations

---

#### 2. Group Invitation Provider (NEW FILE)
**File**: `lib/features/groups/presentation/providers/group_invitation_provider.dart` (280 lines)

**Architecture**:
- ✅ Follows **EXACT** pattern from `FamilyInvitationProvider`
- ✅ Uses `StateNotifierProvider.autoDispose` for automatic cleanup
- ✅ Implements reactive auth state listening with `_ref.listen(currentUserProvider)`
- ✅ **CRITICAL**: Handles `valid: false` in Right fold (success branch)
- ✅ Maps error codes to localization keys identically

**Key Methods**:
```dart
class GroupInvitationNotifier extends StateNotifier<GroupInvitationState> {
  // Validate invitation (handles valid=false in Right fold)
  Future<void> validateInvitation(String inviteCode);

  // Accept invitation
  Future<bool> acceptInvitation(String inviteCode);

  // Error mapping (same codes as family)
  String _mapValidationErrorToKey(validation);
  String _mapFailureToErrorKey(Failure failure);
}
```

**Error Code Mapping** (Unified across family and group):
- `EMAIL_MISMATCH` → `errorInvitationEmailMismatch`
- `EXPIRED` → `errorInvitationExpired`
- `ALREADY_USED` → `errorInvitationAlreadyUsed`
- `INVALID_CODE` → `errorInvitationCodeInvalid`
- `CANCELLED` → `errorInvitationCancelled`

---

#### 3. Group Invitation Page (IMPLEMENTED)
**File**: `lib/features/groups/presentation/pages/group_invitation_page.dart`

**Changes**:
- ✅ Replaced `UnimplementedError` with full implementation
- ✅ Uses `GroupInvitationProvider` for state management
- ✅ Follows same UI pattern as `FamilyInvitationPage`
- ✅ Proper error display with localization keys
- ✅ Widget keys for E2E testing: `invitation_error_${errorKey}`
- ✅ Respects existing widget patterns (AccessibleButton, LoadingIndicator)

**UI Flow**:
1. Manual code input (if no code provided)
2. Loading state during validation
3. Error state (if validation fails)
4. Success state with invitation details
5. Authentication handling (magic link for new/existing users)
6. Join action (authenticated users)

---

#### 4. Localization Files
**Files**:
- `lib/l10n/app_en.arb` (line 3366-3369)
- `lib/l10n/app_fr.arb` (line 3390-3393)

**Changes**:
- ✅ Added `errorInvitationCancelled` key (English: "This invitation has been cancelled")
- ✅ Added `errorInvitationCancelled` key (French: "Cette invitation a été annulée")
- ✅ Maintains consistent formatting with existing error keys

---

#### 5. Feature Composition Root (NEW FILE)
**File**: `lib/features/groups/providers.dart`

**Purpose**: Clean Architecture composition root
```dart
// Single entry point for all Groups-related providers
export 'presentation/providers/group_invitation_provider.dart'
    show GroupInvitationState, groupInvitationProvider;
```

**Usage**:
```dart
// ✅ CORRECT: Import from composition root
import 'package:edulift/features/groups/providers.dart';

// ❌ WRONG: Direct import from data layer
import 'package:edulift/features/groups/presentation/providers/group_invitation_provider.dart';
```

---

### Files Reviewed (No Changes Needed)

#### `lib/features/family/data/datasources/family_remote_datasource_impl.dart`

**Analysis**: The `validateInvitation()` method (lines 169-192) is properly thin:
```dart
Future<FamilyInvitationValidationDto> validateInvitation({
  required String inviteCode,
}) async {
  try {
    final response = await _apiClient.validateInviteCode(inviteCode);
    return response.unwrap();
  } catch (e, stackTrace) {
    throw ServerException('Failed to validate invitation', statusCode: 500);
  }
}
```

**Conclusion**: ✅ **NO DUPLICATION FOUND**
- Datasource correctly delegates to API client
- Business logic properly resides in `UnifiedInvitationService`
- Clean architecture separation maintained

---

## Architectural Patterns Followed

### 1. Clean Architecture Layers
```
┌─────────────────────────────────────┐
│   Presentation Layer                │
│   - GroupInvitationPage             │
│   - GroupInvitationProvider         │
└──────────────┬──────────────────────┘
               │
               ↓
┌─────────────────────────────────────┐
│   Core Services Layer               │
│   - UnifiedInvitationService        │
│   - ErrorHandlerService             │
│   - ErrorContext.invitationOperation│
└──────────────┬──────────────────────┘
               │
               ↓
┌─────────────────────────────────────┐
│   Infrastructure Layer              │
│   - GroupApiClient                  │
│   - FamilyApiClient                 │
└─────────────────────────────────────┘
```

### 2. Error Handling Architecture
```
Backend HTTP 200 (valid: false)
    ↓
UnifiedInvitationService.validateXXXInvitation()
    ↓
Returns Right(ValidationDTO) [Success fold]
    ↓
Provider checks validation.valid
    ↓
If false: _mapValidationErrorToKey(validation.errorCode)
    ↓
UI displays localized error with key
```

### 3. State Management Pattern
```dart
// State
class GroupInvitationState {
  final bool isLoading;
  final bool isValidating;
  final ValidationDTO? validation;
  final String? error;  // Localization key, not raw message
}

// Provider
class GroupInvitationNotifier extends StateNotifier<GroupInvitationState> {
  // Reactive auth listening
  _ref.listen(currentUserProvider, (previous, next) { ... });

  // Auto-cleanup on logout
  void _onUserLoggedOut() { state = const GroupInvitationState(); }
}
```

---

## Unified Invitation Error Codes

Both family and group invitations use **identical** error codes:

| Error Code       | Localization Key                  | Meaning                                    |
|------------------|-----------------------------------|--------------------------------------------|
| `EMAIL_MISMATCH` | `errorInvitationEmailMismatch`    | Email doesn't match invitation             |
| `EXPIRED`        | `errorInvitationExpired`          | Invitation has expired                     |
| `ALREADY_USED`   | `errorInvitationAlreadyUsed`      | Invitation code already accepted           |
| `INVALID_CODE`   | `errorInvitationCodeInvalid`      | Code doesn't exist or is malformed         |
| `CANCELLED`      | `errorInvitationCancelled`        | Invitation cancelled by sender             |

**Backend Behavior**: All validation errors return HTTP 200 with `valid: false` and `errorCode` field.

---

## Testing Considerations

### E2E Test Keys
- `invitation_error_${errorKey}` - Error message display
- `sign_in_to_join_button` - Authentication trigger
- `back-to-login-button` - Navigation fallback

### Test Scenarios
1. ✅ Valid invitation code → Show invitation details
2. ✅ Invalid code → Show error with correct localization
3. ✅ Expired invitation → Show `errorInvitationExpired`
4. ✅ Email mismatch → Show `errorInvitationEmailMismatch`
5. ✅ Cancelled invitation → Show `errorInvitationCancelled`
6. ✅ Already used → Show `errorInvitationAlreadyUsed`
7. ✅ Network error → Show `errorNetworkGeneral`
8. ✅ Server error (500) → Show `errorServerGeneral`

---

## Migration Path for Existing Code

### Before (Family Invitations Only)
```dart
// ❌ Incorrect error context
final context = ErrorContext.familyOperation(
  'validateGroupInvitation',
  metadata: {'inviteCode': inviteCode},
);
```

### After (Unified for Both Types)
```dart
// ✅ Correct unified context
final context = ErrorContext.invitationOperation(
  'validateGroupInvitation',
  metadata: {'inviteCode': inviteCode, 'type': 'group'},
);
```

---

## Future Enhancements

### Potential Unification Opportunities
1. **Shared Invitation State**: Extract common state fields into `BaseInvitationState`
2. **Shared Error Mapping**: Create `InvitationErrorMapper` utility
3. **Shared UI Components**: Extract `InvitationErrorDisplay` widget
4. **Unified E2E Tests**: Create `invitation_test_suite.dart` for both types

### Current Status
- ✅ Backend: Already unified (UnifiedInvitationService)
- ✅ Error Context: Now unified (ErrorContext.invitationOperation)
- ✅ Error Codes: Already identical (same validation logic)
- ✅ UI Pattern: Now consistent (group follows family)

---

## Summary of Architectural Improvements

### What Was Mutualized
1. **Error Context**: Both types now use `ErrorContext.invitationOperation()`
2. **Error Codes**: Unified set of validation error codes
3. **Localization Keys**: Shared i18n keys for all invitation errors
4. **State Management Pattern**: Identical provider structure
5. **UI Pattern**: Consistent page flow and widget usage
6. **HTTP 200 Handling**: Both handle `valid: false` in Right fold

### What Remains Type-Specific
1. **Validation DTOs**: `FamilyInvitationValidationDto` vs `GroupInvitationValidationData`
2. **API Clients**: `FamilyApiClient` vs `GroupApiClient`
3. **Navigation Targets**: Different post-acceptance flows
4. **Business Rules**: Groups require family membership

### Architecture Benefits
- ✅ **DRY**: No duplicated validation logic
- ✅ **Consistency**: Identical patterns reduce cognitive load
- ✅ **Maintainability**: Changes to invitation flow affect both types
- ✅ **Testability**: Shared patterns mean shared test strategies
- ✅ **Type Safety**: Compile-time enforcement of error handling

---

## Conclusion

The unified invitation system successfully eliminates duplication while maintaining type safety and clean architecture boundaries. Both family and group invitations now share:

1. Error handling architecture
2. Validation logic
3. UI patterns
4. State management approach
5. Localization infrastructure

**All deliverables completed**:
- ✅ UnifiedInvitationService updated with correct error context
- ✅ GroupInvitationProvider created with valid=false handling
- ✅ GroupInvitationPage implemented with full validation flow
- ✅ Localization keys added (errorInvitationCancelled)
- ✅ Family datasource reviewed (no duplication found)
- ✅ Providers export file created
- ✅ Architectural summary documented

**No breaking changes** to existing family invitation flow.