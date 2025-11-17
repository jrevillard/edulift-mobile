// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'displayable_slots_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$displayableSlotsHash() => r'1df8ca87bd6fecc50fd9ae3494d967afe484406d';

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

/// Provider for getting displayable time slots by merging configuration with actual slots
///
/// This provider solves the "configured but not created" problem by combining:
/// 1. ScheduleConfig.scheduleHours (what SHOULD exist)
/// 2. WeeklySchedule slots (what DOES exist)
///
/// **Result:** A unified list of DisplayableTimeSlot objects for ALL configured time slots,
/// regardless of whether they exist in the backend yet.
///
/// **Architecture Decision:**
/// - This is a PRESENTATION LAYER concern (view model pattern)
/// - Configuration defines the "shape" of the schedule (days/times)
/// - Backend slots contain the actual data (vehicles, assignments)
/// - UI should render ALL configured slots, marking uncreated ones as "add vehicle"
///
/// **Auto-dispose Pattern:**
/// - Watches both groupScheduleConfigProvider and weeklyScheduleProvider
/// - Automatically refreshes when either config or slots change
/// - Disposes when no longer needed
///
/// **Error Handling:**
/// - Returns AsyncValue.error if config is missing or invalid
/// - Returns AsyncValue.error if slots fail to load
/// - Returns empty list if config exists but has no schedule hours
///
/// **Usage Example:**
/// ```dart
/// final displayableSlotsAsync = ref.watch(
///   displayableSlotsProvider('group-123', '2025-W46')
/// );
/// displayableSlotsAsync.when(
///   data: (slots) => ScheduleGrid(displayableSlots: slots),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => ErrorWidget(err),
/// );
/// ```
///
/// **Parameters:**
/// - [groupId] - The unique identifier of the group
/// - [week] - ISO week format (YYYY-WW, e.g., "2025-W46")
///
/// **Returns:**
/// A Future that resolves to a list of [DisplayableTimeSlot] objects
///
/// Copied from [displayableSlots].
@ProviderFor(displayableSlots)
const displayableSlotsProvider = DisplayableSlotsFamily();

/// Provider for getting displayable time slots by merging configuration with actual slots
///
/// This provider solves the "configured but not created" problem by combining:
/// 1. ScheduleConfig.scheduleHours (what SHOULD exist)
/// 2. WeeklySchedule slots (what DOES exist)
///
/// **Result:** A unified list of DisplayableTimeSlot objects for ALL configured time slots,
/// regardless of whether they exist in the backend yet.
///
/// **Architecture Decision:**
/// - This is a PRESENTATION LAYER concern (view model pattern)
/// - Configuration defines the "shape" of the schedule (days/times)
/// - Backend slots contain the actual data (vehicles, assignments)
/// - UI should render ALL configured slots, marking uncreated ones as "add vehicle"
///
/// **Auto-dispose Pattern:**
/// - Watches both groupScheduleConfigProvider and weeklyScheduleProvider
/// - Automatically refreshes when either config or slots change
/// - Disposes when no longer needed
///
/// **Error Handling:**
/// - Returns AsyncValue.error if config is missing or invalid
/// - Returns AsyncValue.error if slots fail to load
/// - Returns empty list if config exists but has no schedule hours
///
/// **Usage Example:**
/// ```dart
/// final displayableSlotsAsync = ref.watch(
///   displayableSlotsProvider('group-123', '2025-W46')
/// );
/// displayableSlotsAsync.when(
///   data: (slots) => ScheduleGrid(displayableSlots: slots),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => ErrorWidget(err),
/// );
/// ```
///
/// **Parameters:**
/// - [groupId] - The unique identifier of the group
/// - [week] - ISO week format (YYYY-WW, e.g., "2025-W46")
///
/// **Returns:**
/// A Future that resolves to a list of [DisplayableTimeSlot] objects
///
/// Copied from [displayableSlots].
class DisplayableSlotsFamily
    extends Family<AsyncValue<List<DisplayableTimeSlot>>> {
  /// Provider for getting displayable time slots by merging configuration with actual slots
  ///
  /// This provider solves the "configured but not created" problem by combining:
  /// 1. ScheduleConfig.scheduleHours (what SHOULD exist)
  /// 2. WeeklySchedule slots (what DOES exist)
  ///
  /// **Result:** A unified list of DisplayableTimeSlot objects for ALL configured time slots,
  /// regardless of whether they exist in the backend yet.
  ///
  /// **Architecture Decision:**
  /// - This is a PRESENTATION LAYER concern (view model pattern)
  /// - Configuration defines the "shape" of the schedule (days/times)
  /// - Backend slots contain the actual data (vehicles, assignments)
  /// - UI should render ALL configured slots, marking uncreated ones as "add vehicle"
  ///
  /// **Auto-dispose Pattern:**
  /// - Watches both groupScheduleConfigProvider and weeklyScheduleProvider
  /// - Automatically refreshes when either config or slots change
  /// - Disposes when no longer needed
  ///
  /// **Error Handling:**
  /// - Returns AsyncValue.error if config is missing or invalid
  /// - Returns AsyncValue.error if slots fail to load
  /// - Returns empty list if config exists but has no schedule hours
  ///
  /// **Usage Example:**
  /// ```dart
  /// final displayableSlotsAsync = ref.watch(
  ///   displayableSlotsProvider('group-123', '2025-W46')
  /// );
  /// displayableSlotsAsync.when(
  ///   data: (slots) => ScheduleGrid(displayableSlots: slots),
  ///   loading: () => CircularProgressIndicator(),
  ///   error: (err, stack) => ErrorWidget(err),
  /// );
  /// ```
  ///
  /// **Parameters:**
  /// - [groupId] - The unique identifier of the group
  /// - [week] - ISO week format (YYYY-WW, e.g., "2025-W46")
  ///
  /// **Returns:**
  /// A Future that resolves to a list of [DisplayableTimeSlot] objects
  ///
  /// Copied from [displayableSlots].
  const DisplayableSlotsFamily();

  /// Provider for getting displayable time slots by merging configuration with actual slots
  ///
  /// This provider solves the "configured but not created" problem by combining:
  /// 1. ScheduleConfig.scheduleHours (what SHOULD exist)
  /// 2. WeeklySchedule slots (what DOES exist)
  ///
  /// **Result:** A unified list of DisplayableTimeSlot objects for ALL configured time slots,
  /// regardless of whether they exist in the backend yet.
  ///
  /// **Architecture Decision:**
  /// - This is a PRESENTATION LAYER concern (view model pattern)
  /// - Configuration defines the "shape" of the schedule (days/times)
  /// - Backend slots contain the actual data (vehicles, assignments)
  /// - UI should render ALL configured slots, marking uncreated ones as "add vehicle"
  ///
  /// **Auto-dispose Pattern:**
  /// - Watches both groupScheduleConfigProvider and weeklyScheduleProvider
  /// - Automatically refreshes when either config or slots change
  /// - Disposes when no longer needed
  ///
  /// **Error Handling:**
  /// - Returns AsyncValue.error if config is missing or invalid
  /// - Returns AsyncValue.error if slots fail to load
  /// - Returns empty list if config exists but has no schedule hours
  ///
  /// **Usage Example:**
  /// ```dart
  /// final displayableSlotsAsync = ref.watch(
  ///   displayableSlotsProvider('group-123', '2025-W46')
  /// );
  /// displayableSlotsAsync.when(
  ///   data: (slots) => ScheduleGrid(displayableSlots: slots),
  ///   loading: () => CircularProgressIndicator(),
  ///   error: (err, stack) => ErrorWidget(err),
  /// );
  /// ```
  ///
  /// **Parameters:**
  /// - [groupId] - The unique identifier of the group
  /// - [week] - ISO week format (YYYY-WW, e.g., "2025-W46")
  ///
  /// **Returns:**
  /// A Future that resolves to a list of [DisplayableTimeSlot] objects
  ///
  /// Copied from [displayableSlots].
  DisplayableSlotsProvider call(String groupId, String week) {
    return DisplayableSlotsProvider(groupId, week);
  }

  @override
  DisplayableSlotsProvider getProviderOverride(
    covariant DisplayableSlotsProvider provider,
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
  String? get name => r'displayableSlotsProvider';
}

/// Provider for getting displayable time slots by merging configuration with actual slots
///
/// This provider solves the "configured but not created" problem by combining:
/// 1. ScheduleConfig.scheduleHours (what SHOULD exist)
/// 2. WeeklySchedule slots (what DOES exist)
///
/// **Result:** A unified list of DisplayableTimeSlot objects for ALL configured time slots,
/// regardless of whether they exist in the backend yet.
///
/// **Architecture Decision:**
/// - This is a PRESENTATION LAYER concern (view model pattern)
/// - Configuration defines the "shape" of the schedule (days/times)
/// - Backend slots contain the actual data (vehicles, assignments)
/// - UI should render ALL configured slots, marking uncreated ones as "add vehicle"
///
/// **Auto-dispose Pattern:**
/// - Watches both groupScheduleConfigProvider and weeklyScheduleProvider
/// - Automatically refreshes when either config or slots change
/// - Disposes when no longer needed
///
/// **Error Handling:**
/// - Returns AsyncValue.error if config is missing or invalid
/// - Returns AsyncValue.error if slots fail to load
/// - Returns empty list if config exists but has no schedule hours
///
/// **Usage Example:**
/// ```dart
/// final displayableSlotsAsync = ref.watch(
///   displayableSlotsProvider('group-123', '2025-W46')
/// );
/// displayableSlotsAsync.when(
///   data: (slots) => ScheduleGrid(displayableSlots: slots),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => ErrorWidget(err),
/// );
/// ```
///
/// **Parameters:**
/// - [groupId] - The unique identifier of the group
/// - [week] - ISO week format (YYYY-WW, e.g., "2025-W46")
///
/// **Returns:**
/// A Future that resolves to a list of [DisplayableTimeSlot] objects
///
/// Copied from [displayableSlots].
class DisplayableSlotsProvider
    extends AutoDisposeFutureProvider<List<DisplayableTimeSlot>> {
  /// Provider for getting displayable time slots by merging configuration with actual slots
  ///
  /// This provider solves the "configured but not created" problem by combining:
  /// 1. ScheduleConfig.scheduleHours (what SHOULD exist)
  /// 2. WeeklySchedule slots (what DOES exist)
  ///
  /// **Result:** A unified list of DisplayableTimeSlot objects for ALL configured time slots,
  /// regardless of whether they exist in the backend yet.
  ///
  /// **Architecture Decision:**
  /// - This is a PRESENTATION LAYER concern (view model pattern)
  /// - Configuration defines the "shape" of the schedule (days/times)
  /// - Backend slots contain the actual data (vehicles, assignments)
  /// - UI should render ALL configured slots, marking uncreated ones as "add vehicle"
  ///
  /// **Auto-dispose Pattern:**
  /// - Watches both groupScheduleConfigProvider and weeklyScheduleProvider
  /// - Automatically refreshes when either config or slots change
  /// - Disposes when no longer needed
  ///
  /// **Error Handling:**
  /// - Returns AsyncValue.error if config is missing or invalid
  /// - Returns AsyncValue.error if slots fail to load
  /// - Returns empty list if config exists but has no schedule hours
  ///
  /// **Usage Example:**
  /// ```dart
  /// final displayableSlotsAsync = ref.watch(
  ///   displayableSlotsProvider('group-123', '2025-W46')
  /// );
  /// displayableSlotsAsync.when(
  ///   data: (slots) => ScheduleGrid(displayableSlots: slots),
  ///   loading: () => CircularProgressIndicator(),
  ///   error: (err, stack) => ErrorWidget(err),
  /// );
  /// ```
  ///
  /// **Parameters:**
  /// - [groupId] - The unique identifier of the group
  /// - [week] - ISO week format (YYYY-WW, e.g., "2025-W46")
  ///
  /// **Returns:**
  /// A Future that resolves to a list of [DisplayableTimeSlot] objects
  ///
  /// Copied from [displayableSlots].
  DisplayableSlotsProvider(String groupId, String week)
    : this._internal(
        (ref) => displayableSlots(ref as DisplayableSlotsRef, groupId, week),
        from: displayableSlotsProvider,
        name: r'displayableSlotsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$displayableSlotsHash,
        dependencies: DisplayableSlotsFamily._dependencies,
        allTransitiveDependencies:
            DisplayableSlotsFamily._allTransitiveDependencies,
        groupId: groupId,
        week: week,
      );

  DisplayableSlotsProvider._internal(
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
    FutureOr<List<DisplayableTimeSlot>> Function(DisplayableSlotsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DisplayableSlotsProvider._internal(
        (ref) => create(ref as DisplayableSlotsRef),
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
  AutoDisposeFutureProviderElement<List<DisplayableTimeSlot>> createElement() {
    return _DisplayableSlotsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DisplayableSlotsProvider &&
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
mixin DisplayableSlotsRef
    on AutoDisposeFutureProviderRef<List<DisplayableTimeSlot>> {
  /// The parameter `groupId` of this provider.
  String get groupId;

  /// The parameter `week` of this provider.
  String get week;
}

class _DisplayableSlotsProviderElement
    extends AutoDisposeFutureProviderElement<List<DisplayableTimeSlot>>
    with DisplayableSlotsRef {
  _DisplayableSlotsProviderElement(super.provider);

  @override
  String get groupId => (origin as DisplayableSlotsProvider).groupId;
  @override
  String get week => (origin as DisplayableSlotsProvider).week;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
