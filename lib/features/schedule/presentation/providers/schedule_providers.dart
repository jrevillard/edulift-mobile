// EduLift Mobile - Schedule Providers
// Riverpod providers for managing schedule state using code generation
// PHASE 2: State Management & Providers

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/entities/schedule/schedule_slot.dart';
import '../../../../core/domain/entities/schedule/vehicle_assignment.dart';
import '../../../../core/domain/entities/family/child_assignment.dart';
import '../../../../features/schedule/domain/failures/schedule_failure.dart';
import '../../../../core/di/providers/repository_providers.dart';
import '../../../../core/services/providers/auth_provider.dart';
import '../../../../core/utils/result.dart';
import '../../data/repositories/schedule_repository_impl.dart';

part 'schedule_providers.g.dart';

// =============================================================================
// PART 1: WEEKLY SCHEDULE PROVIDERS
// =============================================================================

/// Provider for fetching weekly schedule for a specific group and week
///
/// This provider automatically fetches and caches the weekly schedule slots
/// for a given group ID and week (ISO week format: "YYYY-WW").
///
/// **Auto-dispose Pattern:**
/// - Automatically disposes when user logs out (watches currentUserProvider)
/// - Invalidates cache when auth state changes
///
/// **Error Handling:**
/// - Throws [Exception] on failure, which Riverpod will catch and expose
///   through AsyncValue error state
/// - UI should handle AsyncValue states: loading, data, error
///
/// **Usage Example:**
/// ```dart
/// final slotsAsync = ref.watch(weeklyScheduleProvider('group-123', '2025-W15'));
/// slotsAsync.when(
///   data: (slots) => ScheduleGrid(slots: slots),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => ErrorWidget(err),
/// );
/// ```
///
/// **Parameters:**
/// - [groupId] - The unique identifier of the group
/// - [week] - ISO week format (YYYY-WW, e.g., "2025-W15")
///
/// **Returns:**
/// A Future that resolves to a list of [ScheduleSlot] entities
@riverpod
Future<List<ScheduleSlot>> weeklySchedule(
  Ref ref,
  String groupId,
  String week,
) async {
  // Auto-dispose when auth changes
  ref.watch(currentUserProvider);

  final repository = ref.watch(scheduleRepositoryProvider);
  final result = await repository.getWeeklySchedule(groupId, week);

  return result.when(
    ok: (slots) {
      // Slots are ready to use, no processing needed
      return slots;
    },
    err: (failure) {
      // Convert ApiFailure to Exception for Riverpod error handling
      throw Exception(failure.message ?? 'Failed to load weekly schedule');
    },
  );
}

// =============================================================================
// PART 2: ASSIGNMENT STATE PROVIDERS
// =============================================================================

/// Provider for fetching vehicle assignments for a specific schedule slot
///
/// This provider extracts vehicle assignments from a specific schedule slot
/// by fetching the weekly schedule and finding the target slot.
///
/// **Auto-dispose Pattern:**
/// - Automatically disposes when user logs out
///
/// **Error Handling:**
/// - Throws [Exception] if slot is not found in the weekly schedule
/// - Throws [Exception] on repository failure
///
/// **Parameters:**
/// - [groupId] - The unique identifier of the group
/// - [week] - ISO week format (YYYY-WW, e.g., "2025-W15")
/// - [slotId] - The unique identifier of the schedule slot
///
/// **Returns:**
/// A Future that resolves to a list of [VehicleAssignment] entities
///
/// **Usage Example:**
/// ```dart
/// final assignmentsAsync = ref.watch(
///   vehicleAssignmentsProvider('group-123', '2025-W15', 'slot-456')
/// );
/// assignmentsAsync.when(
///   data: (assignments) => VehicleList(assignments: assignments),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => ErrorWidget(err),
/// );
/// ```
@riverpod
Future<List<VehicleAssignment>> vehicleAssignments(
  Ref ref,
  String groupId,
  String week,
  String slotId,
) async {
  ref.watch(currentUserProvider);

  // Fetch weekly schedule to get the slot
  final slots = await ref.watch(weeklyScheduleProvider(groupId, week).future);

  // Find the specific slot
  final slot = slots.firstWhere(
    (s) => s.id == slotId,
    orElse: () => throw Exception('Schedule slot not found: $slotId'),
  );

  // Return vehicle assignments from the slot
  return slot.vehicleAssignments;
}

/// Provider for fetching child assignments for a specific vehicle assignment
///
/// This provider extracts child assignments from a specific vehicle assignment
/// by fetching the vehicle assignments for the slot and finding the target assignment.
///
/// **Auto-dispose Pattern:**
/// - Automatically disposes when user logs out
///
/// **Error Handling:**
/// - Throws [Exception] if vehicle assignment is not found
/// - Throws [Exception] on repository failure (propagated from vehicleAssignmentsProvider)
///
/// **Parameters:**
/// - [groupId] - The unique identifier of the group
/// - [week] - ISO week format (YYYY-WW, e.g., "2025-W15")
/// - [slotId] - The unique identifier of the schedule slot
/// - [vehicleAssignmentId] - The unique identifier of the vehicle assignment
///
/// **Returns:**
/// A Future that resolves to a list of [ChildAssignment] entities
///
/// **Usage Example:**
/// ```dart
/// final childrenAsync = ref.watch(
///   childAssignmentsProvider('group-123', '2025-W15', 'slot-456', 'vehicle-789')
/// );
/// childrenAsync.when(
///   data: (children) => ChildList(children: children),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => ErrorWidget(err),
/// );
/// ```
@riverpod
Future<List<ChildAssignment>> childAssignments(
  Ref ref,
  String groupId,
  String week,
  String slotId,
  String vehicleAssignmentId,
) async {
  ref.watch(currentUserProvider);

  // Fetch vehicle assignments for the slot
  final vehicleAssignments = await ref.watch(
    vehicleAssignmentsProvider(groupId, week, slotId).future,
  );

  // Find the specific vehicle assignment
  final vehicleAssignment = vehicleAssignments.firstWhere(
    (va) => va.id == vehicleAssignmentId,
    orElse: () =>
        throw Exception('Vehicle assignment not found: $vehicleAssignmentId'),
  );

  // Return child assignments from the vehicle assignment
  return vehicleAssignment.childAssignments;
}

// =============================================================================
// PART 3: ASSIGNMENT STATE NOTIFIER (for mutations)
// =============================================================================

/// StateNotifier for managing child assignment operations (assign/unassign/update)
///
/// **Responsibilities:**
/// - Client-side validation using ValidateChildAssignmentUseCase
/// - Optimistic UI state management
/// - Provider invalidation after mutations for reactivity
/// - Error state management with domain-specific ScheduleFailure types
///
/// **Pattern:**
/// - Uses Riverpod code generation (@riverpod class)
/// - Auto-disposes on auth changes
/// - Returns Result<T, ScheduleFailure> for type-safe error handling
///
/// **Usage Example:**
/// ```dart
/// final notifier = ref.read(assignmentStateNotifierProvider.notifier);
/// final result = await notifier.assignChild(
///   assignmentId: 'vehicle-123',
///   childId: 'child-456',
///   vehicleAssignment: vehicleAssignment,
///   currentlyAssignedChildIds: ['child-789'],
/// );
///
/// result.when(
///   ok: (_) => showSuccess('Child assigned successfully'),
///   err: (failure) => showError(failure.message),
/// );
/// ```
@riverpod
class AssignmentStateNotifier extends _$AssignmentStateNotifier {
  @override
  FutureOr<void> build() {
    // Auto-dispose on auth change
    ref.watch(currentUserProvider);
    return null;
  }

  /// Assign a child to a vehicle
  ///
  /// **Note:** Client-side validation should be done in the UI layer before calling this method.
  /// This method directly calls the repository to persist the assignment.
  ///
  /// **Parameters:**
  /// - [groupId] - The ID of the group (required for repository call)
  /// - [week] - ISO week format (YYYY-WW) for targeted cache invalidation
  /// - [assignmentId] - Vehicle assignment ID (NOT child assignment ID)
  /// - [childId] - ID of child to assign
  /// - [vehicleAssignment] - Vehicle assignment entity (optional, for future validation)
  /// - [currentlyAssignedChildIds] - List of child IDs currently assigned to this vehicle (optional, for future validation)
  ///
  /// **Returns:**
  /// Result<void, ScheduleFailure> - Success or domain-specific failure
  Future<Result<void, ScheduleFailure>> assignChild({
    required String groupId,
    required String week,
    required String assignmentId,
    required String childId,
    VehicleAssignment? vehicleAssignment,
    List<String>? currentlyAssignedChildIds,
  }) async {
    // DO NOT set state = loading() manually!
    // AsyncNotifier automatically manages loading state for async methods

    try {
      // Call repository to persist (validation done in UI layer)
      // Note: Repository interface uses assignChildrenToVehicle (bulk operation)
      // We need to call it with a single-item list
      final repository = ref.read(scheduleRepositoryProvider);
      final slotId = vehicleAssignment?.scheduleSlotId ?? '';

      // 🛡️ GUARD CLAUSE: Prevent API call with empty slotId
      if (slotId.isEmpty) {
        final failure = ScheduleFailure.validationError(
          message:
              'Cannot complete operation: Schedule Slot ID is missing. The data may be out of date. Please refresh the schedule and try again.',
        );
        state = AsyncValue.error(failure, StackTrace.current);
        return Result.err(failure);
      }

      final result = await repository.assignChildrenToVehicle(
        groupId,
        slotId,
        assignmentId,
        [childId], // Single child as list
      );

      // Single result.when() to handle both state update and return value
      return result.when(
        ok: (_) {
          // Update state first
          state = const AsyncValue.data(null);
          // Targeted invalidation - only invalidate this specific week
          ref.invalidate(weeklyScheduleProvider(groupId, week));
          // Then return success
          return const Result.ok(null);
        },
        err: (failure) {
          // Update state first
          state = AsyncValue.error(failure, StackTrace.current);

          // CLEAN APPROACH: No artificial delays

          // Then return failure
          return Result.err(
            ScheduleFailure(
              message: failure.message,
              code: failure.code,
              statusCode: failure.statusCode,
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return Result.err(ScheduleFailure.serverError(message: e.toString()));
    }
  }

  /// Unassign a child from a vehicle
  ///
  /// **Parameters:**
  /// - [groupId] - The ID of the group (required for repository call)
  /// - [week] - ISO week format (YYYY-WW) for targeted cache invalidation
  /// - [assignmentId] - Vehicle assignment ID
  /// - [childId] - ID of child to unassign
  /// - [slotId] - Schedule slot ID
  /// - [childAssignmentId] - Child assignment ID to remove
  ///
  /// **Returns:**
  /// Result<void, ScheduleFailure> - Success or domain-specific failure
  Future<Result<void, ScheduleFailure>> unassignChild({
    required String groupId,
    required String week,
    required String assignmentId,
    required String childId,
    required String slotId,
    required String childAssignmentId,
  }) async {
    // DO NOT set state = loading() manually!
    // AsyncNotifier automatically manages loading state for async methods

    try {
      final repository = ref.read(scheduleRepositoryProvider);
      final result = await repository.removeChildFromVehicle(
        groupId,
        slotId,
        assignmentId,
        childAssignmentId,
      );

      // Single result.when() to handle both state update and return value
      return result.when(
        ok: (_) {
          // Update state first
          state = const AsyncValue.data(null);
          // Targeted invalidation - only invalidate this specific week
          ref.invalidate(weeklyScheduleProvider(groupId, week));
          // Then return success
          return const Result.ok(null);
        },
        err: (failure) {
          // Update state first
          state = AsyncValue.error(failure, StackTrace.current);

          // CLEAN APPROACH: No artificial delays

          // Then return failure
          return Result.err(
            ScheduleFailure(
              message: failure.message,
              code: failure.code,
              statusCode: failure.statusCode,
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return Result.err(ScheduleFailure.serverError(message: e.toString()));
    }
  }

  /// Update seat override for a vehicle assignment
  ///
  /// **Parameters:**
  /// - [groupId] - The ID of the group (required for provider invalidation)
  /// - [week] - ISO week format (YYYY-WW) for targeted cache invalidation
  /// - [assignmentId] - Vehicle assignment ID
  /// - [seatOverride] - New seat override value (null to remove override)
  ///
  /// **Returns:**
  /// Result<void, ScheduleFailure> - Success or domain-specific failure
  Future<Result<void, ScheduleFailure>> updateSeatOverride({
    required String groupId,
    required String week,
    required String assignmentId,
    required int? seatOverride,
  }) async {
    // DO NOT set state = loading() manually!
    // AsyncNotifier automatically manages loading state for async methods
    // Setting it manually causes "Future already completed" errors

    try {
      final repository = ref.read(scheduleRepositoryProvider);
      final result = await (repository as ScheduleRepositoryImpl)
          .updateSeatOverrideWithWeek(
        groupId, // Pass groupId for cache invalidation
        assignmentId,
        seatOverride,
        week, // Pass week for reliable cache updates
      );

      // Single result.when() to handle both state update and return value
      return result.when(
        ok: (_) {
          // Update state on success
          state = const AsyncValue.data(null);

          // Targeted invalidation - only invalidate this specific week
          // Cache updates are handled properly in the repository layer
          ref.invalidate(weeklyScheduleProvider(groupId, week));

          // Then return success
          return const Result.ok(null);
        },
        err: (failure) {
          // Update state on error
          state = AsyncValue.error(failure, StackTrace.current);

          // CLEAN APPROACH: No artificial delays

          // Then return failure
          return Result.err(
            ScheduleFailure(
              message: failure.message,
              code: failure.code,
              statusCode: failure.statusCode,
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return Result.err(ScheduleFailure.serverError(message: e.toString()));
    }
  }
}

// =============================================================================
// PART 4: SLOT STATE NOTIFIER (for slot mutations)
// =============================================================================

/// StateNotifier for managing schedule slot operations (create/update/delete)
///
/// **Responsibilities:**
/// - Creating and updating schedule slots
/// - Deleting schedule slots
/// - Provider invalidation after mutations
/// - Error state management
///
/// **Pattern:**
/// - Uses Riverpod code generation (@riverpod class)
/// - Auto-disposes on auth changes
/// - Returns Result<T, ScheduleFailure> for type-safe error handling
@riverpod
class SlotStateNotifier extends _$SlotStateNotifier {
  @override
  FutureOr<void> build() {
    ref.watch(currentUserProvider);
    return null;
  }

  /// Upsert (create or update) a schedule slot
  ///
  /// **Parameters:**
  /// - [groupId] - Group ID for the schedule
  /// - [day] - Day of week (e.g., "Monday", "Tuesday")
  /// - [time] - Time slot (e.g., "08:00", "15:00")
  /// - [week] - ISO week format (YYYY-WW)
  ///
  /// **Returns:**
  /// Result<ScheduleSlot, ScheduleFailure> - Updated slot or failure
  Future<Result<ScheduleSlot, ScheduleFailure>> upsertSlot({
    required String groupId,
    required String day,
    required String time,
    required String week,
  }) async {
    // DO NOT set state = loading() manually!
    // AsyncNotifier automatically manages loading state for async methods

    try {
      final repository = ref.read(scheduleRepositoryProvider);
      final result = await repository.upsertScheduleSlot(
        groupId,
        day,
        time,
        week,
      );

      // Single result.when() to handle both state update and return value
      return result.when(
        ok: (updatedSlot) {
          // Update state first
          state = const AsyncValue.data(null);
          // Targeted invalidation - only invalidate this specific week
          ref.invalidate(weeklyScheduleProvider(groupId, week));

          // CLEAN APPROACH: No artificial delays
          // Cache updates are handled properly in the repository layer

          // Then return success with the slot
          return Result.ok(updatedSlot);
        },
        err: (failure) {
          // Update state first
          state = AsyncValue.error(failure, StackTrace.current);

          // CLEAN APPROACH: No artificial delays

          // Then return failure
          return Result.err(
            ScheduleFailure(
              message: failure.message,
              code: failure.code,
              statusCode: failure.statusCode,
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return Result.err(ScheduleFailure.serverError(message: e.toString()));
    }
  }

  // Note: Schedule slot deletion is handled automatically by the backend.
  // When the last vehicle is removed from a slot, the backend automatically
  // deletes the slot. There is no explicit deleteScheduleSlot endpoint.
  // To clear a weekly schedule, use the repository's clearWeeklySchedule method,
  // which removes all vehicles from slots, triggering automatic deletion.
}
