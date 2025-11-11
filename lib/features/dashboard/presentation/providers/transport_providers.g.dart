// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transport_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$familyVehiclesHash() => r'1ae7f9721fa94673f4740f56a7cd86246355bea5';

/// Provider for loading vehicles for family filtering logic
/// Uses FamilyState.vehicles directly - no async calls needed
///
/// Copied from [familyVehicles].
@ProviderFor(familyVehicles)
final familyVehiclesProvider =
    AutoDisposeProvider<Map<String, Vehicle>>.internal(
      familyVehicles,
      name: r'familyVehiclesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$familyVehiclesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FamilyVehiclesRef = AutoDisposeProviderRef<Map<String, Vehicle>>;
String _$day7TransportSummaryHash() =>
    r'9042fe63f2538883cf57466e1740284664ca0d77';

/// Provider for fetching 7-day transport summary for dashboard display
///
/// This provider implements the real family filtering logic according to the
/// backend dashboard API specification. It aggregates transport data from all
/// family groups and applies intelligent filtering based on family relevance.
///
/// **Auto-dispose Pattern:**
/// - Automatically disposes when user logs out (watches currentUserProvider)
/// - Invalidates cache when auth state changes
/// - Invalidates when family state changes
///
/// **Family Filtering Logic:**
/// - Vehicles from the family are always included
/// - Vehicles from other families are included ONLY if they contain family children
/// - Aggregates data from all family groups
/// - Applies 7-day rolling window logic
///
/// **Usage Example:**
/// ```dart
/// final transportAsync = ref.watch(day7TransportSummaryProvider);
/// transportAsync.when(
///   data: (summaries) => TransportWeekView(summaries: summaries),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => ErrorWidget(err),
/// );
/// ```
///
/// Copied from [day7TransportSummary].
@ProviderFor(day7TransportSummary)
final day7TransportSummaryProvider =
    AutoDisposeFutureProvider<List<DayTransportSummary>>.internal(
      day7TransportSummary,
      name: r'day7TransportSummaryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$day7TransportSummaryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef Day7TransportSummaryRef =
    AutoDisposeFutureProviderRef<List<DayTransportSummary>>;
String _$todayTransportsHash() => r'e0f1f0850ccf0addfe99aac587c69eec6bffe7b8';

/// Provider for extracting today's transport data from the 7-day summary
///
/// This provider watches the 7-day transport provider and extracts only
/// today's data for optimized dashboard display.
///
/// **Auto-dispose Pattern:**
/// - Automatically disposes when user logs out
/// - Reactive to 7-day provider changes
///
/// **Caching:**
/// - 5-minute cache for today's data (more frequent refresh for current day)
/// - Benefits from 7-day provider cache for efficiency
///
/// **Usage Example:**
/// ```dart
/// final todayAsync = ref.watch(todayTransportsProvider);
/// todayAsync.when(
///   data: (transports) => TodayTransportGrid(transports: transports),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => ErrorWidget(err),
/// );
/// ```
///
/// Copied from [todayTransports].
@ProviderFor(todayTransports)
final todayTransportsProvider =
    AutoDisposeFutureProvider<List<TransportSlotSummary>>.internal(
      todayTransports,
      name: r'todayTransportsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$todayTransportsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayTransportsRef =
    AutoDisposeFutureProviderRef<List<TransportSlotSummary>>;
String _$todayTransportSummaryHash() =>
    r'6183e2648172e1a094de7950e11b82017d91c664';

/// Provider for today's transport summary with full day context
///
/// This provides the complete DayTransportSummary for today, including
/// aggregate statistics like total children and vehicles.
///
/// **Usage:**
/// ```dart
/// final todaySummaryAsync = ref.watch(todayTransportSummaryProvider);
/// todaySummaryAsync.when(
///   data: (summary) => TodayStatsCard(summary: summary),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => ErrorWidget(err),
/// );
/// ```
///
/// Copied from [todayTransportSummary].
@ProviderFor(todayTransportSummary)
final todayTransportSummaryProvider =
    AutoDisposeFutureProvider<DayTransportSummary?>.internal(
      todayTransportSummary,
      name: r'todayTransportSummaryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$todayTransportSummaryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayTransportSummaryRef =
    AutoDisposeFutureProviderRef<DayTransportSummary?>;
String _$hasTransportsTodayHash() =>
    r'299b60160a60f8651c91bb4003e437a02326044c';

/// Convenience provider for checking if today has scheduled transports
///
/// This provider provides a simple boolean that can be used to show/hide
/// transport-related UI elements based on whether there are transports today.
///
/// **Usage Example:**
/// ```dart
/// final hasTransportsToday = ref.watch(hasTransportsTodayProvider);
///
/// if (hasTransportsToday) {
///   return TransportWidget();
/// } else {
///   return NoTransportsWidget();
/// }
/// ```
///
/// Copied from [hasTransportsToday].
@ProviderFor(hasTransportsToday)
final hasTransportsTodayProvider = AutoDisposeFutureProvider<bool>.internal(
  hasTransportsToday,
  name: r'hasTransportsTodayProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasTransportsTodayHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasTransportsTodayRef = AutoDisposeFutureProviderRef<bool>;
String _$todayTransportCountHash() =>
    r'f2946882aaec53ec80ba1b58331754f38de5ca8b';

/// Convenience provider for getting transport count for today
///
/// Returns the number of transport slots scheduled for today.
///
/// **Usage Example:**
/// ```dart
/// final transportCount = ref.watch(todayTransportCountProvider);
///
/// return Badge(
///   count: transportCount,
///   child: TransportIcon(),
/// );
/// ```
///
/// Copied from [todayTransportCount].
@ProviderFor(todayTransportCount)
final todayTransportCountProvider = AutoDisposeFutureProvider<int>.internal(
  todayTransportCount,
  name: r'todayTransportCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todayTransportCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayTransportCountRef = AutoDisposeFutureProviderRef<int>;
String _$selectedDayNotifierHash() =>
    r'1c9d097d8cf5851be9af00c9d89cb31b80c3d6fe';

/// Provider for managing the selected day in the dashboard UI
///
/// This provider tracks which day the user has selected for detailed view.
/// Defaults to today's date.
///
/// **Auto-dispose Pattern:**
/// - Automatically disposes when user logs out
///
/// **Usage Example:**
/// ```dart
/// final selectedDay = ref.watch(selectedDayProvider);
/// final notifier = ref.read(selectedDayProvider.notifier);
///
/// // Update selected day
/// notifier.state = DateTime.now().add(Duration(days: 1));
/// ```
///
/// Copied from [SelectedDayNotifier].
@ProviderFor(SelectedDayNotifier)
final selectedDayNotifierProvider =
    AutoDisposeNotifierProvider<SelectedDayNotifier, DateTime>.internal(
      SelectedDayNotifier.new,
      name: r'selectedDayNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedDayNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedDayNotifier = AutoDisposeNotifier<DateTime>;
String _$weekViewExpandedNotifierHash() =>
    r'a9c4cbdd4eb6965d350392817de9f69e2b9ee278';

/// Provider for managing the expanded/collapsed state of the week view
///
/// This provider tracks whether the week view should be expanded to show
/// all 7 days or collapsed to show only a summary.
///
/// **Auto-dispose Pattern:**
/// - Automatically disposes when user logs out
///
/// **Usage Example:**
/// ```dart
/// final isExpanded = ref.watch(weekViewExpandedProvider);
/// final notifier = ref.read(weekViewExpandedProvider.notifier);
///
/// // Toggle expanded state
/// notifier.toggle();
/// ```
///
/// Copied from [WeekViewExpandedNotifier].
@ProviderFor(WeekViewExpandedNotifier)
final weekViewExpandedNotifierProvider =
    AutoDisposeNotifierProvider<WeekViewExpandedNotifier, bool>.internal(
      WeekViewExpandedNotifier.new,
      name: r'weekViewExpandedNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$weekViewExpandedNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$WeekViewExpandedNotifier = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
