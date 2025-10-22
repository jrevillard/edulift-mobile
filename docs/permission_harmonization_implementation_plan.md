# Permission Harmonization Implementation Plan

## Overview

This document provides step-by-step implementation instructions to harmonize permission patterns from the inconsistent `widget.isAdmin` parameter pattern to the unified `canPerformMemberActionsComposedProvider` pattern.

## Pre-Implementation Checklist

- [ ] Backup current working branch
- [ ] Ensure all existing E2E tests pass
- [ ] Review provider architecture documentation
- [ ] Verify `canPerformMemberActionsComposedProvider` is working correctly

## Implementation Steps

### Step 1: Update InvitationManagementWidget Constructor

#### Before:
```dart
class InvitationManagementWidget extends ConsumerStatefulWidget {
  final bool isAdmin;  // ❌ Remove this
  final String entityType;
  final String entityId;

  const InvitationManagementWidget({
    super.key,
    required this.isAdmin,  // ❌ Remove this
    required this.entityType,
    required this.entityId,
  });
}
```

#### After:
```dart
class InvitationManagementWidget extends ConsumerStatefulWidget {
  final String entityType;
  final String entityId;

  const InvitationManagementWidget({
    super.key,
    required this.entityType,
    required this.entityId,
  });
}
```

**File to modify**: `lib/features/family/presentation/widgets/invitation_management_widget.dart`

### Step 2: Add Direct Provider Access in Widget

#### Add at the top of `build()` method:
```dart
@override
Widget build(BuildContext context) {
  // HARMONIZATION: Use direct provider access instead of parameter
  final familyId = widget.entityId;
  final isAdmin = ref.watch(
    canPerformMemberActionsComposedProvider(familyId),
  );

  // DEBUG: Log isAdmin value for debugging E2E tests
  AppLogger.debug(
    'InvitationManagementWidget: isAdmin value: $isAdmin',
  );

  // Rest of existing build method...
}
```

### Step 3: Replace All `widget.isAdmin` References

#### Find and replace all occurrences:

**Location 1** - Line ~385 (Header actions):
```dart
// BEFORE:
if (widget.isAdmin) ...[

// AFTER:
if (isAdmin) ...[
```

**Location 2** - Line ~491 (Empty state text):
```dart
// BEFORE:
widget.isAdmin
    ? 'Invite members to get started'
    : 'Check back later for new invitations',

// AFTER:
isAdmin
    ? 'Invite members to get started'
    : 'Check back later for new invitations',
```

**Location 3** - Line ~533 (Card tap handler):
```dart
// BEFORE:
onTap: widget.isAdmin ? () => _toggleSelection(invitation.id) : null,

// AFTER:
onTap: isAdmin ? () => _toggleSelection(invitation.id) : null,
```

**Location 4** - Line ~543 (Selection checkbox):
```dart
// BEFORE:
if (widget.isAdmin) ...[

// AFTER:
if (isAdmin) ...[
```

**Location 5** - Line ~639 (Additional info and actions):
```dart
// BEFORE:
if (invitation.message != null || widget.isAdmin) ...[

// AFTER:
if (invitation.message != null || isAdmin) ...[
```

**Location 6** - Line ~662 (Actions section):
```dart
// BEFORE:
if (widget.isAdmin)

// AFTER:
if (isAdmin)
```

**Location 7** - Line ~685 (Show code menu item):
```dart
// BEFORE:
if (hasCode && widget.isAdmin) {

// AFTER:
if (hasCode && isAdmin) {
```

**Location 8** - Line ~704 (Cancel invitation menu item):
```dart
// BEFORE:
if (widget.isAdmin) {

// AFTER:
if (isAdmin) {
```

### Step 4: Update Parent Component (FamilyManagementScreen)

#### Remove parameter passing:

**Location**: `lib/features/family/presentation/pages/family_management_screen.dart` around line 276

```dart
// BEFORE:
InvitationManagementWidget(
  isAdmin: isAdmin,  // ❌ Remove this line
  entityType: 'family',
  entityId: familyState.family?.id ?? '',
),

// AFTER:
InvitationManagementWidget(
  entityType: 'family',
  entityId: familyState.family?.id ?? '',
),
```

**Note**: Keep the existing `isAdmin` variable in FamilyManagementScreen as it's still used for other screen-level functionality.

### Step 5: Import Required Provider

Ensure the import exists in `invitation_management_widget.dart`:

```dart
// ARCHITECTURE FIX: Import through composition root
import '../../providers.dart';
```

This should already exist, but verify `canPerformMemberActionsComposedProvider` is available.

## Implementation Verification

### Step 1: Compile Check
```bash
cd /workspace/mobile_app
flutter analyze
flutter build --debug
```

### Step 2: Test Verification
```bash
# Run unit tests
flutter test

# Run widget tests specifically
flutter test test/presentation/family/widgets/

# Run E2E tests
flutter test integration_test/family/
```

### Step 3: Manual Verification
1. Launch app in debug mode
2. Navigate to Family Management
3. Verify invitation management works correctly
4. Check debug logs show correct `isAdmin` values
5. Test admin vs non-admin user behaviors

## Code Quality Checklist

- [ ] All `widget.isAdmin` references removed
- [ ] Direct provider access implemented correctly
- [ ] Parameter removed from constructor
- [ ] Parent component updated to not pass parameter
- [ ] Debug logging updated to show correct values
- [ ] Import statements are clean
- [ ] No unused variables remain

## Testing Strategy

### Unit Tests to Update
```dart
// Before: Mock the isAdmin parameter
testWidget(
  'should show admin actions when isAdmin is true',
  (tester) async {
    await tester.pumpWidget(
      InvitationManagementWidget(
        isAdmin: true,  // ❌ Remove this
        entityType: 'family',
        entityId: 'family123',
      ),
    );
  },
);

// After: Mock the provider
testWidget(
  'should show admin actions when user has admin permissions',
  (tester) async {
    // Mock the provider to return true
    final container = ProviderContainer(
      overrides: [
        canPerformMemberActionsComposedProvider('family123')
            .overrideWith((ref) => true),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: InvitationManagementWidget(
          entityType: 'family',
          entityId: 'family123',
        ),
      ),
    );
  },
);
```

### E2E Test Updates
Ensure E2E tests that look for invitation management behavior still work correctly. The tests should not need changes since they test the UI behavior, not the internal implementation.

## Risk Mitigation

### Low Risk Areas
- Removing unused parameter
- Direct provider access (established pattern)
- Updating parent component calls

### Medium Risk Areas
- All `widget.isAdmin` replacements must be complete
- Provider must be correctly imported and available

### Rollback Plan
If issues arise:
1. Revert to backed-up branch
2. Debug specific failing tests
3. Implement fix and retry

## Post-Implementation Tasks

### Code Review Checklist
- [ ] No `isAdmin` parameters remain in widget constructors
- [ ] All widgets use direct provider access for permissions
- [ ] No parameter passing for permission data
- [ ] Provider chain works correctly
- [ ] Debug logging shows correct values
- [ ] Tests updated to mock providers instead of parameters

### Documentation Updates
- [ ] Update architecture documentation
- [ ] Add permission pattern guidelines to coding standards
- [ ] Document the canonical provider chain
- [ ] Update widget API documentation

## Future Recommendations

### Establish Pattern Guidelines
Create coding guidelines that specify:
1. Widgets should never accept permission parameters
2. All permission checks must use providers directly
3. Use `canPerformMemberActionsComposedProvider` for member actions
4. Follow the established provider composition pattern

### Architecture Evolution
Consider:
1. Creating a `PermissionAwareWidget` base class
2. Implementing permission-based widget visibility helpers
3. Adding permission debugging tools for development

## Success Criteria

✅ **Implementation is successful when**:
1. All tests pass (unit, integration, E2E)
2. App compiles without errors
3. Permission behavior is identical to before
4. Code is cleaner and more maintainable
5. Single source of truth for permissions established
6. No redundant parameter passing for permission data

This harmonization eliminates the architectural inconsistency and establishes a clean, maintainable pattern for permission handling throughout the application.