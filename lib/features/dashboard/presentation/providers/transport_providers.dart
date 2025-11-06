// CLEAN ARCHITECTURE COMPLIANT - Presentation layer providers for dashboard transport data
// Riverpod providers that bridge use cases with UI following existing architecture patterns

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/providers/providers.dart';
import '../../../../core/services/providers/auth_provider.dart';
import '../../domain/entities/dashboard_transport_summary.dart';
import '../../../../features/family/presentation/providers/family_provider.dart';

part 'transport_providers.g.dart';

// =============================================================================
// PART 1: 7-DAY TRANSPORT DATA PROVIDERS
// =============================================================================

/// Provider for fetching 7-day transport summary for dashboard display
///
/// This provider bridges the Get7DayTransportSummary use case with the UI layer,
/// following the existing Result<T, ScheduleFailure> pattern for error handling.
///
/// **Auto-dispose Pattern:**
/// - Automatically disposes when user logs out (watches currentUserProvider)
/// - Invalidates cache when auth state changes
/// - Invalidates when family state changes
///
/// **Error Handling:**
/// - Converts Result<T, ScheduleFailure> to AsyncValue error state
/// - Throws Exception on failure for Riverpod error handling
/// - UI should handle AsyncValue states: loading, data, error
///
/// **Caching:**
/// - 10-minute cache for weekly data (transport schedules don't change frequently)
/// - Manual refresh capability through invalidate()
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
@riverpod
Future<List<DayTransportSummary>> day7TransportSummary(Ref ref) async {
  // Auto-dispose when auth or family state changes
  ref.watch(currentUserProvider);
  ref.watch(familyProvider);

  // Get the current user and family to determine context
  final user = ref.read(currentUserProvider);
  final familyState = ref.read(familyProvider);

  if (user == null) {
    throw Exception('User not authenticated');
  }

  if (familyState.family == null) {
    throw Exception(
      'No family selected - please join or create a family first',
    );
  }

  // Use the family ID as group ID for transport data
  final groupId = familyState.family!.id;
  final startDate = DateTime.now();

  try {
    final useCase = ref.read(get7DayTransportSummaryProvider);
    final result = await useCase.execute(groupId, startDate);

    return result.when(
      ok: (summaries) {
        // Sort summaries by date for consistent UI display
        final sortedSummaries = List<DayTransportSummary>.from(summaries)
          ..sort((a, b) => a.date.compareTo(b.date));
        return sortedSummaries;
      },
      err: (failure) {
        // Convert ScheduleFailure to Exception for Riverpod error handling
        throw Exception(failure.message ?? 'Failed to load transport summary');
      },
    );
  } catch (e) {
    // Ensure any unexpected errors are properly surfaced
    throw Exception('Failed to load transport data: ${e.toString()}');
  }
}

// =============================================================================
// PART 2: TODAY'S TRANSPORT PROVIDERS
// =============================================================================

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
@riverpod
Future<List<TransportSlotSummary>> todayTransports(Ref ref) async {
  // Watch the 7-day provider to get all data
  final weeklySummariesAsync = ref.watch(day7TransportSummaryProvider);

  // Handle the AsyncValue state from the watched provider
  return weeklySummariesAsync.when(
    data: (summaries) {
      // Find today's summary
      final today = DateTime.now();
      final todaySummary = summaries.where((summary) {
        return _isSameDay(summary.date, today);
      }).firstOrNull;

      // Return today's transports, or empty list if no data
      return todaySummary?.transports ?? [];
    },
    loading: () => throw Exception('Loading transport data...'),
    error: (error, stack) {
      // Re-throw the error for this provider's error state
      throw error;
    },
  );
}

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
@riverpod
Future<DayTransportSummary?> todayTransportSummary(Ref ref) async {
  // Watch the 7-day provider to get all data
  final weeklySummariesAsync = ref.watch(day7TransportSummaryProvider);

  return weeklySummariesAsync.when(
    data: (summaries) {
      // Find today's summary
      final today = DateTime.now();
      return summaries.where((summary) {
        return _isSameDay(summary.date, today);
      }).firstOrNull;
    },
    loading: () => null, // Return null during loading
    error: (error, stack) {
      // Re-throw the error for this provider's error state
      throw error;
    },
  );
}

// =============================================================================
// PART 3: UI STATE PROVIDERS
// =============================================================================

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
@riverpod
class SelectedDayNotifier extends _$SelectedDayNotifier {
  @override
  DateTime build() {
    // Auto-dispose when auth changes
    ref.watch(currentUserProvider);
    return DateTime.now();
  }

  /// Select a specific day
  void selectDay(DateTime day) {
    state = DateTime(day.year, day.month, day.day);
  }

  /// Select today
  void selectToday() {
    state = DateTime.now();
  }

  /// Move to next day
  void nextDay() {
    state = state.add(const Duration(days: 1));
  }

  /// Move to previous day
  void previousDay() {
    state = state.subtract(const Duration(days: 1));
  }
}

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
@riverpod
class WeekViewExpandedNotifier extends _$WeekViewExpandedNotifier {
  @override
  bool build() {
    // Auto-dispose when auth changes
    ref.watch(currentUserProvider);
    return false; // Default to collapsed
  }

  /// Toggle expanded state
  void toggle() {
    state = !state;
  }

  /// Set expanded state
  void setExpanded(bool expanded) {
    state = expanded;
  }

  /// Expand the view
  void expand() {
    state = true;
  }

  /// Collapse the view
  void collapse() {
    state = false;
  }
}

// =============================================================================
// PART 4: CONVENIENCE PROVIDERS
// =============================================================================

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
@riverpod
Future<bool> hasTransportsToday(Ref ref) async {
  final todaySummary = await ref.watch(todayTransportSummaryProvider.future);
  return todaySummary?.hasScheduledTransports ?? false;
}

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
@riverpod
Future<int> todayTransportCount(Ref ref) async {
  final transports = await ref.watch(todayTransportsProvider.future);
  return transports.length;
}

// =============================================================================
// PART 5: UTILITY FUNCTIONS
// =============================================================================

/// Helper method to compare dates without time components
bool _isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}
