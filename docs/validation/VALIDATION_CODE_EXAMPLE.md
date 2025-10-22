# 🎓 Validation Implementation - Annotated Code Example

**Date**: 2025-10-09
**Purpose**: Educational reference for implementing validation in widgets
**File**: `child_assignment_sheet.dart`

---

## 📚 Complete Implementation with Annotations

### 1. State Variables

```dart
class _ChildAssignmentSheetState extends ConsumerState<ChildAssignmentSheet> {
  // EXISTING: Track selected children (Set prevents duplicates)
  final Set<String> _selectedChildIds = {};

  // EXISTING: Loading state for async operations
  bool _isLoading = false;

  // ⭐ NEW: Track validation errors
  // null = No error
  // non-null = Error message to display
  String? _conflictError;

  @override
  void initState() {
    super.initState();
    // Initialize with current assignments
    _selectedChildIds.addAll(widget.currentlyAssignedChildIds);
  }
}
```

**Key Points**:
- `_conflictError` is nullable for clean "no error" state
- Using `String?` allows descriptive error messages
- Initialization sets up the "before" state for change detection

---

### 2. The Core Validation Getter - `_canSave`

```dart
/// Check if save operation is allowed (PRODUCTION QUALITY)
///
/// Ensures data integrity by blocking save when:
/// - No changes detected (_hasChanges = false)
/// - Conflict error present (_conflictError != null)
/// - Validation failed (_isValid() = false)
/// - Loading in progress (_isLoading = true)
///
/// This prevents:
/// - Accidental overwrites
/// - Data corruption
/// - Silent failures
/// - Invalid state persistence
bool get _canSave {
  // ❌ RULE 1: Never allow save during loading
  // Prevents double-submission, race conditions
  if (_isLoading) return false;

  // ❌ RULE 2: Never allow save when conflict exists
  // This is THE critical check - blocks invalid data
  if (_conflictError != null && _conflictError!.isNotEmpty) return false;

  // ❌ RULE 3: No changes = no save needed
  // Prevents unnecessary server calls, improves UX
  if (!_hasChanges) return false;

  // ❌ RULE 4: Validation must pass
  // Business logic validation (capacity, etc.)
  if (!_isValid()) return false;

  // ✅ ALL CHECKS PASSED - Safe to save
  return true;
}
```

**Why this pattern?**
- **Early returns** = Clear, readable logic
- **Guard clauses** = Fail-fast approach
- **Order matters** = Check cheapest conditions first (loading, error) before expensive validation
- **Single responsibility** = One getter for all save-blocking logic

---

### 3. Change Detection - `_hasChanges`

```dart
/// Check if there are changes compared to initial state
bool get _hasChanges {
  // Convert to Sets for efficient comparison
  final currentIds = _selectedChildIds.toSet();
  final initialIds = widget.currentlyAssignedChildIds.toSet();

  // Set difference operations:
  // - currentIds.difference(initialIds) = newly added children
  // - initialIds.difference(currentIds) = removed children
  // If either is non-empty → changes exist
  return currentIds.difference(initialIds).isNotEmpty ||
      initialIds.difference(currentIds).isNotEmpty;
}
```

**Why Sets?**
- **O(1) lookup** vs O(n) for Lists
- **Built-in difference** operation
- **Automatic deduplication**

**Alternative Implementation** (simpler but less efficient):
```dart
bool get _hasChanges {
  // Works but O(n²) complexity
  if (_selectedChildIds.length != widget.currentlyAssignedChildIds.length) {
    return true;
  }
  return !_selectedChildIds.every(
    (id) => widget.currentlyAssignedChildIds.contains(id)
  );
}
```

---

### 4. Business Logic Validation - `_isValid()`

```dart
/// Validate current assignment state
bool _isValid() {
  // Extract values
  final selectedCount = _selectedChildIds.length;
  final effectiveCapacity = widget.vehicleAssignment.effectiveCapacity;

  // RULE: Cannot exceed vehicle capacity
  if (selectedCount > effectiveCapacity) {
    // ⚠️ CRITICAL: Set _conflictError for UI display
    _conflictError =
        'Capacity exceeded: $selectedCount children selected, but only $effectiveCapacity seats available';
    return false;
  }

  // ✅ All validations passed
  // NOTE: _conflictError is NOT cleared here
  // It's cleared in _toggleChildSelection when user fixes the issue
  return true;
}
```

**Design Decision**: Why not clear error here?
```dart
// ❌ BAD: Clearing here causes UI flicker
bool _isValid() {
  _conflictError = null;  // DON'T DO THIS
  if (selectedCount > capacity) {
    _conflictError = "...";
    return false;
  }
  return true;
}

// ✅ GOOD: Clear error when user takes action
void _toggleChildSelection(Child child) {
  setState(() {
    if (valid_action) {
      _conflictError = null;  // Clear on valid action
    }
  });
}
```

**Why?**
- Error persists until user fixes it
- Clear on user action = better UX
- Prevents error flashing on/off

---

### 5. UI Integration - Save Button

```dart
Widget _buildBottomActions(BuildContext context) {
  return Container(
    child: SafeArea(
      child: Row(
        children: [
          // Cancel button (always enabled except during loading)
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).cancel),
            ),
          ),
          const SizedBox(width: 12),

          // Save button - THE CRITICAL PART
          Expanded(
            flex: 2,
            child: ElevatedButton(
              // ⭐ CRITICAL LINE: Use _canSave, NOT just _hasChanges
              onPressed: _canSave ? _saveAssignments : null,

              // Visual feedback: Color changes based on state
              style: ElevatedButton.styleFrom(
                backgroundColor: _canSave
                    ? Theme.of(context).primaryColor  // Blue = Can save
                    : Colors.grey[400],                // Grey = Blocked
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              // Content: Loading spinner or text
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text('Save (${_selectedChildIds.length})'),
            ),
          ),
        ],
      ),
    ),
  );
}
```

**Key Design Patterns**:

1. **Ternary for onPressed**
   ```dart
   onPressed: _canSave ? _saveAssignments : null,
   // null = Flutter automatically disables button
   ```

2. **Visual feedback matches state**
   ```dart
   backgroundColor: _canSave ? Blue : Grey
   // User sees at a glance if action is possible
   ```

3. **Loading state takes priority**
   ```dart
   child: _isLoading ? Spinner : Text
   // Clear feedback during async operation
   ```

**Common Mistakes to Avoid**:

```dart
// ❌ BAD: Only checks _hasChanges
onPressed: _hasChanges ? _saveAssignments : null,
// Problem: Allows save even with capacity exceeded

// ❌ BAD: Always enabled
onPressed: _saveAssignments,
// Problem: No validation, always clickable

// ❌ BAD: Inline validation
onPressed: (_hasChanges && _conflictError == null && !_isLoading)
    ? _saveAssignments : null,
// Problem: Logic duplicated, hard to maintain

// ✅ GOOD: Use _canSave getter
onPressed: _canSave ? _saveAssignments : null,
// Single source of truth, maintainable
```

---

### 6. Error Display - Conflict Banner

```dart
Widget build(BuildContext context) {
  return Container(
    child: Column(
      children: [
        // ... header, capacity bar ...

        // ⭐ Conditional error display
        if (_conflictError != null && _conflictError!.isNotEmpty)
          _buildConflictError(),

        // ... rest of UI ...
      ],
    ),
  );
}

/// Build conflict error warning banner
Widget _buildConflictError() {
  return Container(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.red[50],                    // Light red background
      border: Border.all(color: Colors.red.shade300),  // Red border
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(Icons.error_outline, color: Colors.red[700], size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _conflictError!,
            style: TextStyle(
              color: Colors.red[900],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}
```

**Design Principles**:

1. **Persistent Display**
   ```dart
   if (_conflictError != null) _buildConflictError(),
   // Error stays visible until resolved
   // NOT a Snackbar (transient, easy to miss)
   ```

2. **Visual Hierarchy**
   ```dart
   // Placed between capacity bar and child list
   // User sees error BEFORE trying to save
   ```

3. **Clear Communication**
   ```dart
   Text(_conflictError!)  // Descriptive message
   // "Capacity exceeded: 6 children, only 5 seats"
   // NOT just "Error" or "Invalid"
   ```

**Error Banner Best Practices**:
- ✅ Use semantic colors (red = error)
- ✅ Include icon for quick recognition
- ✅ Descriptive message (not generic)
- ✅ Persistent (not dismissible until fixed)
- ✅ Positioned near relevant content

---

### 7. User Interaction - Toggle Selection

```dart
void _toggleChildSelection(Child child) async {
  // Haptic feedback for better UX
  await HapticFeedback.lightImpact();

  setState(() {
    if (_selectedChildIds.contains(child.id)) {
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      // DESELECT PATH
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      _selectedChildIds.remove(child.id);

      // ⭐ Clear error when user takes corrective action
      _conflictError = null;

    } else {
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      // SELECT PATH
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

      // Check if selection is allowed (capacity check)
      if (_canAssignChild(child)) {
        // ✅ VALID: Add to selection
        _selectedChildIds.add(child.id);

        // Clear error on valid selection
        _conflictError = null;

      } else {
        // ❌ INVALID: Block selection

        // Set persistent error for UI
        _conflictError = 'Cannot assign child: vehicle is full';

        // Also show transient feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cannot assign child: vehicle full'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    }
  });
  // setState triggers rebuild → _canSave re-evaluated → UI updates
}
```

**Why this pattern works**:

1. **Immediate validation**
   ```dart
   if (_canAssignChild(child))
   // Check BEFORE adding to set
   // Prevents invalid state from ever existing
   ```

2. **Error clearing on fix**
   ```dart
   _selectedChildIds.remove(child.id);
   _conflictError = null;  // ⭐ Clear error
   // User sees immediate feedback that problem is resolved
   ```

3. **Dual feedback for errors**
   ```dart
   _conflictError = "...";           // Persistent banner
   ScaffoldMessenger.showSnackBar(); // Transient notification
   // Banner = stays visible
   // Snackbar = confirms action was attempted
   ```

4. **State update triggers validation**
   ```dart
   setState(() { /* changes */ });
   // Flutter rebuilds → _canSave re-evaluated → Button state updates
   ```

---

## 🎯 Complete Flow Example

### Scenario: User tries to exceed capacity

```dart
// INITIAL STATE
_selectedChildIds = {child1, child2, child3, child4}  // 4 children
effectiveCapacity = 5
_conflictError = null
_canSave = FALSE (no changes)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// USER CLICKS: Add child5
_toggleChildSelection(child5) called
  ↓
  _canAssignChild(child5) returns TRUE (4 < 5)
  ↓
  _selectedChildIds.add(child5)  // Now: {child1, child2, child3, child4, child5}
  _conflictError = null
  ↓
  setState() called
  ↓
  Widget rebuilds
  ↓
  _canSave evaluated:
    _isLoading = FALSE ✓
    _conflictError = null ✓
    _hasChanges = TRUE ✓ (5 children vs 4 initial)
    _isValid():
      selectedCount (5) <= effectiveCapacity (5) ✓
    → return TRUE
  ↓
  Save button: ENABLED (BLUE)
  No error banner

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// USER CLICKS: Add child6 (EXCEEDS CAPACITY)
_toggleChildSelection(child6) called
  ↓
  _canAssignChild(child6) returns FALSE (5 >= 5, at capacity)
  ↓
  _conflictError = "Cannot assign child: vehicle is full"
  Show snackbar
  _selectedChildIds NOT modified (still 5 children)
  ↓
  setState() called
  ↓
  Widget rebuilds
  ↓
  _canSave evaluated:
    _isLoading = FALSE ✓
    _conflictError = "Cannot..." ❌ FAILS HERE
    → return FALSE
  ↓
  Save button: DISABLED (GREY)
  Red error banner visible: "Cannot assign child: vehicle is full"

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// USER CLICKS: Remove child5 (FIX)
_toggleChildSelection(child5) called
  ↓
  _selectedChildIds.remove(child5)  // Now: {child1, child2, child3, child4}
  _conflictError = null  // ⭐ CLEAR ERROR
  ↓
  setState() called
  ↓
  Widget rebuilds
  ↓
  _canSave evaluated:
    _isLoading = FALSE ✓
    _conflictError = null ✓
    _hasChanges = FALSE ❌ (4 children = initial state)
    → return FALSE
  ↓
  Save button: DISABLED (GREY)
  No error banner (error cleared)

  NOTE: Button still disabled because no changes from initial state
```

---

## 📋 Implementation Checklist

When adding validation to a new widget:

- [ ] **State Variables**
  - [ ] Add `String? _conflictError`
  - [ ] Add `bool _isLoading` (if async operations)
  - [ ] Track initial state for change detection

- [ ] **Validation Logic**
  - [ ] Implement `bool get _canSave`
  - [ ] Implement `bool get _hasChanges`
  - [ ] Implement `bool _isValid()`

- [ ] **UI Integration**
  - [ ] Update button: `onPressed: _canSave ? _handleSave : null`
  - [ ] Add visual feedback: `backgroundColor: _canSave ? Blue : Grey`
  - [ ] Add error banner: `if (_conflictError != null) ...`

- [ ] **User Interactions**
  - [ ] Clear `_conflictError` on valid actions
  - [ ] Set `_conflictError` on invalid actions
  - [ ] Trigger `setState()` to update UI

- [ ] **Testing**
  - [ ] Test: No changes → Button disabled
  - [ ] Test: Valid changes → Button enabled
  - [ ] Test: Invalid state → Button disabled + error
  - [ ] Test: Loading → Button disabled + spinner
  - [ ] Test: Error recovery → Error clears, button enables

---

## 🚀 Quick Reference

### The Three Critical Lines

```dart
// 1. Validation in getter
bool get _canSave {
  if (_conflictError != null) return false;  // ⭐ CRITICAL
  // ... other checks ...
}

// 2. Button uses validation
ElevatedButton(
  onPressed: _canSave ? _saveAssignments : null,  // ⭐ CRITICAL
  // ...
)

// 3. Error displayed in UI
if (_conflictError != null) _buildConflictError(),  // ⭐ CRITICAL
```

### Common Pitfalls

```dart
// ❌ WRONG
onPressed: _hasChanges ? _save : null,

// ✅ RIGHT
onPressed: _canSave ? _save : null,
```

```dart
// ❌ WRONG: Logic in UI
onPressed: (_hasChanges && _error == null && !_loading) ? _save : null,

// ✅ RIGHT: Logic in getter
onPressed: _canSave ? _save : null,
```

```dart
// ❌ WRONG: Never clear error
void _onAction() {
  _selectedIds.add(id);
}

// ✅ RIGHT: Clear error on valid action
void _onAction() {
  _selectedIds.add(id);
  _conflictError = null;  // ⭐ CLEAR
}
```

---

**Last Updated**: 2025-10-09
**Status**: ✅ PRODUCTION READY
**Next Steps**: Review, test, deploy
