# Vehicle and Child Assignment Flow - Mobile Implementation

## Overview

This document describes the complete vehicle and child assignment flow in the EduLift mobile app, implementing a mobile-first UX pattern that mirrors the web application's functionality while optimizing for touch interfaces.

**Implementation Date**: 2025-10-12
**Status**: ✅ 100% Complete
**Related Files**:
- `/lib/features/schedule/presentation/widgets/vehicle_selection_modal.dart`
- `/lib/features/schedule/presentation/widgets/child_assignment_sheet.dart`
- `/lib/features/schedule/presentation/providers/schedule_providers.dart`

---

## 🎯 User Flow

### 1. Vehicle Selection & Assignment

**Entry Point**: User taps on a schedule slot in the Schedule Grid

**Modal**: `VehicleSelectionModal` (DraggableScrollableSheet at 60-95%)

**Features**:
- ✅ Lists all available family vehicles
- ✅ Shows currently assigned vehicles with capacity bars
- ✅ Seat override per trip (adjustable capacity)
- ✅ Real-time UI refresh after assignment
- ✅ Child management button on assigned vehicles
- ✅ Remove vehicle button

**UI Components**:
```
┌─────────────────────────────────────┐
│ 🚗 Manage Vehicles             [─]  │
│ Friday - 17:30                      │
├─────────────────────────────────────┤
│ ⏰ 17:30                     [v]    │
│    ✓ 1 vehicle                      │
│                                     │
│    Currently Assigned:              │
│    ┌─────────────────────────────┐ │
│    │ 🚗 Alfa              👥  ❌  │ │
│    │ ▓▓▓░░ 2/5 seats (3 left)    │ │
│    │                             │ │
│    │ ⚙️ Seat Override      [v]   │ │
│    │   • Standard (5)            │ │
│    │   • Compact (4)             │ │
│    │   • Extended (6)            │ │
│    └─────────────────────────────┘ │
│                                     │
│    Available Vehicles:              │
│    ┌─────────────────────────────┐ │
│    │ 🚗 Beta                  [+] │ │
│    │ 👥 4 seats                   │ │
│    └─────────────────────────────┘ │
└─────────────────────────────────────┘
```

**Actions**:
1. **Add Vehicle**: Tap on available vehicle card → API call → UI auto-refreshes
2. **Manage Children**: Tap 👥 button → Opens ChildAssignmentSheet
3. **Adjust Capacity**: Expand "Seat Override" → Select preset or custom value
4. **Remove Vehicle**: Tap ❌ button → API call → UI auto-refreshes

---

### 2. Child Assignment to Vehicle

**Entry Point**: User taps 👥 (child_care icon) on assigned vehicle card

**Modal**: `ChildAssignmentSheet` (DraggableScrollableSheet at 90%)

**Features**:
- ✅ Vehicle-specific context (pre-selected vehicle)
- ✅ Real-time capacity indicator with progress bar
- ✅ List of all available children in group
- ✅ Multi-select with checkboxes
- ✅ Capacity validation (prevents over-assignment)
- ✅ Batch save operation
- ✅ Conflict error handling
- ✅ Auto-refresh after save

**UI Components**:
```
┌─────────────────────────────────────┐
│ 👶 Assign Children           [─]   │
│ Alfa (5 seats)                      │
├─────────────────────────────────────┤
│ Capacity: ▓▓▓░░ 3/5 seats          │
│                   2 remaining       │
├─────────────────────────────────────┤
│ Select Children:                    │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ ☑️ 👤 Alice (7 ans)      ✓     │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ ☑️ 👤 Bob (9 ans)        ✓     │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ ☐ 👤 Charlie (6 ans)            │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ ☐ 👤 Diana (8 ans)              │ │
│ └─────────────────────────────────┘ │
│                                     │
├─────────────────────────────────────┤
│ [Cancel]  [Save Assignments (3)] │
└─────────────────────────────────────┘
```

**Validation Rules**:
1. ✅ Cannot exceed effective capacity (base or override)
2. ✅ Cannot save if validation fails
3. ✅ Cannot save if no changes made
4. ✅ Prevents duplicate assignments

**Actions**:
1. **Toggle Child**: Tap checkbox or card → Updates selection
2. **Save**: Tap "Save Assignments" → Batch API calls → Auto-refresh → Close modal
3. **Cancel**: Tap "Cancel" → Discard changes → Close modal

---

## 🔧 Technical Implementation

### State Management (Riverpod)

**Providers Used**:

1. **`weeklyScheduleProvider(groupId, week)`**
   - Auto-fetch and cache weekly schedule
   - Invalidated after vehicle/child operations
   - Triggers UI refresh automatically

2. **`assignmentStateNotifierProvider`**
   - Handles child assign/unassign operations
   - Returns `Result<void, ScheduleFailure>`
   - Manages loading state

3. **`familyChildrenProvider`**
   - Provides list of available children
   - From family context

**Provider Invalidation Pattern**:
```dart
// After successful vehicle assignment
ref.invalidate(weeklyScheduleProvider(groupId, week));

// After successful child assignment
ref.invalidate(weeklyScheduleProvider(groupId, week));
```

---

### API Integration

**Repository Methods**:

1. **Assign Vehicle to Slot**:
```dart
Future<Result<VehicleAssignment, ApiFailure>> assignVehicleToSlot(
  String groupId,
  String day,
  String time,
  String week,
  String vehicleId,
)
```

2. **Assign Children to Vehicle**:
```dart
Future<Result<VehicleAssignment, ApiFailure>> assignChildrenToVehicle(
  String groupId,
  String slotId,
  String vehicleAssignmentId,
  List<String> childIds,
)
```

3. **Remove Child from Vehicle**:
```dart
Future<Result<void, ApiFailure>> removeChildFromVehicle(
  String groupId,
  String slotId,
  String vehicleAssignmentId,
  String childAssignmentId,
)
```

4. **Update Seat Override**:
```dart
Future<Result<VehicleAssignment, ApiFailure>> updateSeatOverride(
  String vehicleAssignmentId,
  int? seatOverride,
)
```

---

### Critical Fix: UI Refresh After Vehicle Assignment

**Problem**: After successful vehicle assignment (201 response), vehicle didn't appear in UI until manual refresh.

**Root Cause**: Provider invalidation was missing after successful API response.

**Solution** (implemented in `vehicle_selection_modal.dart`):
```dart
// After successful vehicle assignment
if (mounted) {
  // ✅ CRITICAL FIX: Refresh schedule data
  ref.invalidate(weeklyScheduleProvider(widget.groupId, week));

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Vehicle added successfully'),
      backgroundColor: AppColors.success,
    ),
  );
}
```

**Applied to**:
- ✅ `_addVehicle()` - After vehicle assignment
- ✅ `_removeVehicle()` - After vehicle removal
- ✅ `_saveSeatOverride()` - Already present in original code
- ✅ `_manageChildren()` - Invalidates after modal closes

---

## 📱 Mobile-First Design Principles

### 1. Touch Targets
- ✅ Minimum 48x48dp for all interactive elements
- ✅ 96dp for primary actions (vehicle cards)
- ✅ Adequate spacing between elements (12-16dp)

### 2. Progressive Disclosure
- ✅ Collapsed ExpansionTiles for seat override (power user feature)
- ✅ DraggableScrollableSheet for modals (adjustable height)
- ✅ Single slot auto-expanded, multiple slots collapsed

### 3. Visual Hierarchy
- ✅ Color-coded capacity bars (green/yellow/red)
- ✅ Icons for quick recognition (🚗, 👥, ⚙️)
- ✅ Bold text for primary info, secondary for metadata

### 4. Feedback & Affordances
- ✅ Haptic feedback on actions (light/medium/heavy)
- ✅ Loading spinners during async operations
- ✅ Success/error snackbars with contextual colors
- ✅ Disabled states when action unavailable

### 5. Error Handling
- ✅ HTTP 409 Conflict → "Vehicle capacity changed. Refresh and try again."
- ✅ HTTP 400 Validation → "Invalid assignment. Check your selection."
- ✅ HTTP 403 Permission → "You don't have permission."
- ✅ Generic → "An error occurred. Please try again."

---

## 🎨 Capacity Visualization

**Formula**:
```dart
effectiveCapacity = seatOverride ?? baseCapacity
usedSeats = childAssignments.length
remainingSeats = effectiveCapacity - usedSeats
percentage = usedSeats / effectiveCapacity
```

**Color Coding**:
- 🟢 Green (0-79%): Comfortable capacity
- 🟡 Yellow (80-99%): Nearly full
- 🔴 Red (100%+): Over capacity / Full

**Progress Bar**:
```
▓▓▓░░ 3/5 seats (2 remaining)
```

**Override Indicator**:
```
⚠️ Override: 3 (5 base)
```

---

## 🔐 Validation & Business Rules

### Vehicle Assignment
1. ✅ Vehicle must exist in family
2. ✅ Vehicle not already assigned to same slot
3. ✅ User has permission to manage schedule

### Child Assignment
1. ✅ Child must be in group
2. ✅ Cannot exceed effective capacity
3. ✅ Child not already assigned to another vehicle in same slot
4. ✅ Validation happens on both client and server

### Seat Override
1. ✅ Must be positive integer (1-50)
2. ✅ Applied per trip (not permanent)
3. ✅ Null value = use base capacity
4. ✅ Can be adjusted after vehicle assignment

---

## 📊 Performance Optimizations

1. **Provider Invalidation**:
   - ✅ Targeted invalidation (specific week only)
   - ✅ No full app refresh
   - ✅ Automatic cache update

2. **Lazy Loading**:
   - ✅ Family data loaded on modal open
   - ✅ Children fetched only when needed
   - ✅ Scroll-based rendering for long lists

3. **Debouncing**:
   - ✅ Haptic feedback throttled
   - ✅ API calls batched where possible

---

## 🧪 Testing Checklist

### Functional Tests
- [x] Vehicle appears in UI after assignment
- [x] Vehicle removed from UI after unassignment
- [x] Seat override updates capacity bar
- [x] Child assignment modal opens on tap
- [x] Children can be added to vehicle
- [x] Children can be removed from vehicle
- [x] Capacity validation prevents over-assignment
- [x] UI refreshes after all operations
- [x] Error messages displayed correctly

### Edge Cases
- [x] Network failure during assignment
- [x] Concurrent modifications (409 conflict)
- [x] Permission denied (403 forbidden)
- [x] Empty vehicle list
- [x] Empty children list
- [x] Capacity override edge values (0, negative, > 50)

### UX Tests
- [x] Touch targets adequate (48dp+)
- [x] Haptic feedback responsive
- [x] Loading indicators shown
- [x] Snackbars auto-dismiss
- [x] Modal scroll smooth
- [x] Drag handle visible

---

## 🌍 Internationalization

**Keys Added** (already present in app_en.arb & app_fr.arb):
- ✅ `vehicleCapacityFull`
- ✅ `saveAssignments`
- ✅ `assignmentsSavedSuccessfully`
- ✅ `seatOverrideActive`
- ✅ `overrideDetails`
- ✅ `cannotDetermineWeek`
- ✅ `seatOverride`
- ✅ `seatOverrideUpdated`
- ✅ `manageChildren`
- ✅ `removeVehicle`

**Usage Example**:
```dart
AppLocalizations.of(context).vehicleAddedSuccess(vehicleName)
AppLocalizations.of(context).saveAssignments(childCount)
```

---

## 🐛 Known Issues & Limitations

### None (as of 2025-10-12)

All critical issues have been resolved:
- ✅ Vehicle UI refresh fixed
- ✅ Child assignment fully functional
- ✅ Seat override working
- ✅ Capacity validation implemented

### Future Enhancements

1. **Drag-and-Drop**:
   - Drag children between vehicles
   - Reorder children within vehicle

2. **Bulk Operations**:
   - Assign all children to vehicle
   - Copy assignments from previous week

3. **Smart Suggestions**:
   - Suggest optimal vehicle based on route
   - Highlight children near capacity

4. **Real-time Updates**:
   - WebSocket integration
   - Live presence indicators

---

## 📚 Related Documentation

- [Type-Safe Schedule Domain ADR](./architecture/TYPE_SAFE_SCHEDULE_DOMAIN.md)
- [API Client Vehicle Assignment Fix](./fixes/API_CLIENT_VEHICLE_ASSIGNMENT_FIX.md)
- [Timezone Handling ADR](./architecture/TIMEZONE_HANDLING_ADR.md)

---

## 🤝 Developer Guide

### How to Add a New Vehicle Operation

1. **Add Repository Method**:
```dart
// In schedule_repository.dart (interface)
Future<Result<T, ApiFailure>> newOperation(...);

// In schedule_repository_impl.dart (implementation)
@override
Future<Result<T, ApiFailure>> newOperation(...) async {
  return _vehicleHandler.newOperation(...);
}

// In vehicle_operations_handler.dart (handler)
Future<Result<T, ApiFailure>> newOperation(...) async {
  // Implementation
}
```

2. **Add Provider Method** (if needed):
```dart
// In schedule_providers.dart
@riverpod
class MyStateNotifier extends _$MyStateNotifier {
  Future<Result<void, ScheduleFailure>> newOperation(...) async {
    // Call repository
    // Invalidate providers
    ref.invalidate(weeklyScheduleProvider(groupId, week));
  }
}
```

3. **Add UI Action**:
```dart
// In vehicle_selection_modal.dart or child_assignment_sheet.dart
Future<void> _handleNewOperation() async {
  final result = await ref.read(myNotifierProvider.notifier).newOperation(...);

  result.when(
    ok: (_) {
      ref.invalidate(weeklyScheduleProvider(groupId, week));
      showSuccessSnackbar();
    },
    err: (failure) => showErrorSnackbar(failure),
  );
}
```

4. **Add I18n Keys**:
```json
// In app_en.arb & app_fr.arb
"newOperationSuccess": "Operation successful",
"newOperationFailed": "Operation failed: {error}"
```

---

## ✅ Implementation Checklist (100% Complete)

- [x] Fix vehicle UI refresh after assignment
- [x] Verify child assignment modal functionality
- [x] Test complete vehicle and child assignment flow
- [x] Verify all I18n keys present
- [x] Run flutter analyze (no errors in modified files)
- [x] Create comprehensive documentation
- [x] Verify all business rules enforced
- [x] Test error handling scenarios
- [x] Verify mobile-first UX patterns
- [x] Document API integration points

---

**Last Updated**: 2025-10-12
**Author**: Claude (AI Code Implementation Agent)
**Status**: ✅ Production Ready
