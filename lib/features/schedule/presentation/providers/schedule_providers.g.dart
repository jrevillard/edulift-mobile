// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$weeklyScheduleHash() => r'b3583491520da907ad6cc92cf1864bd34ae467fd';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

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
///
/// Copied from [weeklySchedule].
@ProviderFor(weeklySchedule)
const weeklyScheduleProvider = WeeklyScheduleFamily();

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
///
/// Copied from [weeklySchedule].
class WeeklyScheduleFamily extends Family<AsyncValue<List<ScheduleSlot>>> {
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
  ///
  /// Copied from [weeklySchedule].
  const WeeklyScheduleFamily();

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
  ///
  /// Copied from [weeklySchedule].
  WeeklyScheduleProvider call(String groupId, String week) {
    return WeeklyScheduleProvider(groupId, week);
  }

  @override
  WeeklyScheduleProvider getProviderOverride(
    covariant WeeklyScheduleProvider provider,
  ) {
    return call(provider.groupId, provider.week);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'weeklyScheduleProvider';
}

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
///
/// Copied from [weeklySchedule].
class WeeklyScheduleProvider
    extends AutoDisposeFutureProvider<List<ScheduleSlot>> {
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
  ///
  /// Copied from [weeklySchedule].
  WeeklyScheduleProvider(String groupId, String week)
      : this._internal(
          (ref) => weeklySchedule(ref as WeeklyScheduleRef, groupId, week),
          from: weeklyScheduleProvider,
          name: r'weeklyScheduleProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$weeklyScheduleHash,
          dependencies: WeeklyScheduleFamily._dependencies,
          allTransitiveDependencies:
              WeeklyScheduleFamily._allTransitiveDependencies,
          groupId: groupId,
          week: week,
        );

  WeeklyScheduleProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupId,
    required this.week,
  }) : super.internal();

  final String groupId;
  final String week;

  @override
  Override overrideWith(
    FutureOr<List<ScheduleSlot>> Function(WeeklyScheduleRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WeeklyScheduleProvider._internal(
        (ref) => create(ref as WeeklyScheduleRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupId: groupId,
        week: week,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ScheduleSlot>> createElement() {
    return _WeeklyScheduleProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WeeklyScheduleProvider &&
        other.groupId == groupId &&
        other.week == week;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);
    hash = _SystemHash.combine(hash, week.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WeeklyScheduleRef on AutoDisposeFutureProviderRef<List<ScheduleSlot>> {
  /// The parameter `groupId` of this provider.
  String get groupId;

  /// The parameter `week` of this provider.
  String get week;
}

class _WeeklyScheduleProviderElement
    extends AutoDisposeFutureProviderElement<List<ScheduleSlot>>
    with WeeklyScheduleRef {
  _WeeklyScheduleProviderElement(super.provider);

  @override
  String get groupId => (origin as WeeklyScheduleProvider).groupId;
  @override
  String get week => (origin as WeeklyScheduleProvider).week;
}

String _$vehicleAssignmentsHash() =>
    r'0628a75e5df8ea45cc8fe7baebd477d066c4d3da';

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
///
/// Copied from [vehicleAssignments].
@ProviderFor(vehicleAssignments)
const vehicleAssignmentsProvider = VehicleAssignmentsFamily();

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
///
/// Copied from [vehicleAssignments].
class VehicleAssignmentsFamily
    extends Family<AsyncValue<List<VehicleAssignment>>> {
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
  ///
  /// Copied from [vehicleAssignments].
  const VehicleAssignmentsFamily();

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
  ///
  /// Copied from [vehicleAssignments].
  VehicleAssignmentsProvider call(String groupId, String week, String slotId) {
    return VehicleAssignmentsProvider(groupId, week, slotId);
  }

  @override
  VehicleAssignmentsProvider getProviderOverride(
    covariant VehicleAssignmentsProvider provider,
  ) {
    return call(provider.groupId, provider.week, provider.slotId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'vehicleAssignmentsProvider';
}

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
///
/// Copied from [vehicleAssignments].
class VehicleAssignmentsProvider
    extends AutoDisposeFutureProvider<List<VehicleAssignment>> {
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
  ///
  /// Copied from [vehicleAssignments].
  VehicleAssignmentsProvider(String groupId, String week, String slotId)
      : this._internal(
          (ref) => vehicleAssignments(
            ref as VehicleAssignmentsRef,
            groupId,
            week,
            slotId,
          ),
          from: vehicleAssignmentsProvider,
          name: r'vehicleAssignmentsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$vehicleAssignmentsHash,
          dependencies: VehicleAssignmentsFamily._dependencies,
          allTransitiveDependencies:
              VehicleAssignmentsFamily._allTransitiveDependencies,
          groupId: groupId,
          week: week,
          slotId: slotId,
        );

  VehicleAssignmentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupId,
    required this.week,
    required this.slotId,
  }) : super.internal();

  final String groupId;
  final String week;
  final String slotId;

  @override
  Override overrideWith(
    FutureOr<List<VehicleAssignment>> Function(VehicleAssignmentsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VehicleAssignmentsProvider._internal(
        (ref) => create(ref as VehicleAssignmentsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupId: groupId,
        week: week,
        slotId: slotId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<VehicleAssignment>> createElement() {
    return _VehicleAssignmentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VehicleAssignmentsProvider &&
        other.groupId == groupId &&
        other.week == week &&
        other.slotId == slotId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);
    hash = _SystemHash.combine(hash, week.hashCode);
    hash = _SystemHash.combine(hash, slotId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin VehicleAssignmentsRef
    on AutoDisposeFutureProviderRef<List<VehicleAssignment>> {
  /// The parameter `groupId` of this provider.
  String get groupId;

  /// The parameter `week` of this provider.
  String get week;

  /// The parameter `slotId` of this provider.
  String get slotId;
}

class _VehicleAssignmentsProviderElement
    extends AutoDisposeFutureProviderElement<List<VehicleAssignment>>
    with VehicleAssignmentsRef {
  _VehicleAssignmentsProviderElement(super.provider);

  @override
  String get groupId => (origin as VehicleAssignmentsProvider).groupId;
  @override
  String get week => (origin as VehicleAssignmentsProvider).week;
  @override
  String get slotId => (origin as VehicleAssignmentsProvider).slotId;
}

String _$childAssignmentsHash() => r'c3f86693e62b218fc888e7d8e698153a72157aa7';

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
///
/// Copied from [childAssignments].
@ProviderFor(childAssignments)
const childAssignmentsProvider = ChildAssignmentsFamily();

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
///
/// Copied from [childAssignments].
class ChildAssignmentsFamily extends Family<AsyncValue<List<ChildAssignment>>> {
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
  ///
  /// Copied from [childAssignments].
  const ChildAssignmentsFamily();

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
  ///
  /// Copied from [childAssignments].
  ChildAssignmentsProvider call(
    String groupId,
    String week,
    String slotId,
    String vehicleAssignmentId,
  ) {
    return ChildAssignmentsProvider(groupId, week, slotId, vehicleAssignmentId);
  }

  @override
  ChildAssignmentsProvider getProviderOverride(
    covariant ChildAssignmentsProvider provider,
  ) {
    return call(
      provider.groupId,
      provider.week,
      provider.slotId,
      provider.vehicleAssignmentId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'childAssignmentsProvider';
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
///
/// Copied from [childAssignments].
class ChildAssignmentsProvider
    extends AutoDisposeFutureProvider<List<ChildAssignment>> {
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
  ///
  /// Copied from [childAssignments].
  ChildAssignmentsProvider(
    String groupId,
    String week,
    String slotId,
    String vehicleAssignmentId,
  ) : this._internal(
          (ref) => childAssignments(
            ref as ChildAssignmentsRef,
            groupId,
            week,
            slotId,
            vehicleAssignmentId,
          ),
          from: childAssignmentsProvider,
          name: r'childAssignmentsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$childAssignmentsHash,
          dependencies: ChildAssignmentsFamily._dependencies,
          allTransitiveDependencies:
              ChildAssignmentsFamily._allTransitiveDependencies,
          groupId: groupId,
          week: week,
          slotId: slotId,
          vehicleAssignmentId: vehicleAssignmentId,
        );

  ChildAssignmentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupId,
    required this.week,
    required this.slotId,
    required this.vehicleAssignmentId,
  }) : super.internal();

  final String groupId;
  final String week;
  final String slotId;
  final String vehicleAssignmentId;

  @override
  Override overrideWith(
    FutureOr<List<ChildAssignment>> Function(ChildAssignmentsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChildAssignmentsProvider._internal(
        (ref) => create(ref as ChildAssignmentsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupId: groupId,
        week: week,
        slotId: slotId,
        vehicleAssignmentId: vehicleAssignmentId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ChildAssignment>> createElement() {
    return _ChildAssignmentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChildAssignmentsProvider &&
        other.groupId == groupId &&
        other.week == week &&
        other.slotId == slotId &&
        other.vehicleAssignmentId == vehicleAssignmentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);
    hash = _SystemHash.combine(hash, week.hashCode);
    hash = _SystemHash.combine(hash, slotId.hashCode);
    hash = _SystemHash.combine(hash, vehicleAssignmentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChildAssignmentsRef
    on AutoDisposeFutureProviderRef<List<ChildAssignment>> {
  /// The parameter `groupId` of this provider.
  String get groupId;

  /// The parameter `week` of this provider.
  String get week;

  /// The parameter `slotId` of this provider.
  String get slotId;

  /// The parameter `vehicleAssignmentId` of this provider.
  String get vehicleAssignmentId;
}

class _ChildAssignmentsProviderElement
    extends AutoDisposeFutureProviderElement<List<ChildAssignment>>
    with ChildAssignmentsRef {
  _ChildAssignmentsProviderElement(super.provider);

  @override
  String get groupId => (origin as ChildAssignmentsProvider).groupId;
  @override
  String get week => (origin as ChildAssignmentsProvider).week;
  @override
  String get slotId => (origin as ChildAssignmentsProvider).slotId;
  @override
  String get vehicleAssignmentId =>
      (origin as ChildAssignmentsProvider).vehicleAssignmentId;
}

String _$assignmentStateNotifierHash() =>
    r'f35f42a188cdee477dd9856a711bba955e908506';

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
///
/// Copied from [AssignmentStateNotifier].
@ProviderFor(AssignmentStateNotifier)
final assignmentStateNotifierProvider =
    AutoDisposeAsyncNotifierProvider<AssignmentStateNotifier, void>.internal(
  AssignmentStateNotifier.new,
  name: r'assignmentStateNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$assignmentStateNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AssignmentStateNotifier = AutoDisposeAsyncNotifier<void>;
String _$slotStateNotifierHash() => r'42f8f3ef215393885be4d9612ce3b399f04074f1';

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
///
/// Copied from [SlotStateNotifier].
@ProviderFor(SlotStateNotifier)
final slotStateNotifierProvider =
    AutoDisposeAsyncNotifierProvider<SlotStateNotifier, void>.internal(
  SlotStateNotifier.new,
  name: r'slotStateNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$slotStateNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SlotStateNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
