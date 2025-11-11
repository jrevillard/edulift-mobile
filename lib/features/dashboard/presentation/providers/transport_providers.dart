// CLEAN ARCHITECTURE COMPLIANT - Presentation layer providers for dashboard transport data
// Riverpod providers that bridge use cases with UI following existing architecture patterns

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:async';
import '../../../../core/services/providers/auth_provider.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/timezone_formatter.dart';
import '../../../../core/utils/date/iso_week_utils.dart';
import '../../../../core/utils/date/date_utils.dart';
import '../../../../core/domain/entities/schedule/vehicle_assignment.dart';
import '../../../../core/domain/entities/schedule/schedule_slot.dart';
import '../../../../core/domain/entities/schedule/day_of_week.dart';
import '../../../../core/domain/entities/family/vehicle.dart';
import '../../domain/entities/dashboard_transport_summary.dart';
import '../../../../features/family/presentation/providers/family_provider.dart';
import '../../../../features/schedule/presentation/providers/schedule_providers.dart';
import '../../../../core/di/providers/providers.dart';

part 'transport_providers.g.dart';

// =============================================================================
// PART 1: VEHICLE PROVIDERS
// =============================================================================

/// Provider for loading vehicles for family filtering logic
/// Uses FamilyState.vehicles directly - no async calls needed
@riverpod
Map<String, Vehicle> familyVehicles(Ref ref) {
  final familyState = ref.watch(familyProvider);

  if (familyState.family == null || familyState.vehicles.isEmpty) {
    return {};
  }

  // Convert FamilyState.vehicles list to a Map for easy lookup
  final vehiclesMap = <String, Vehicle>{};
  for (final vehicle in familyState.vehicles) {
    vehiclesMap[vehicle.id] = vehicle;
  }

  AppLogger.debug('Loaded family vehicles from FamilyState', {
    'familyId': familyState.family!.id,
    'vehicleCount': vehiclesMap.length,
  });

  return vehiclesMap;
}

// =============================================================================
// PART 2: 7-DAY TRANSPORT DATA PROVIDERS
// =============================================================================

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
    // Return empty data instead of throwing - dashboard can handle empty state
    AppLogger.debug('No family selected - returning empty transport summary');
    return [];
  }

  final familyId = familyState.family!.id;

  // Get user timezone - CRITICAL: Use user timezone, not device timezone
  final userTimezone = user.timezone ?? 'UTC';
  AppLogger.debug('Fetching 7-day transport summary with family filtering', {
    'familyId': familyId,
    'userTimezone': userTimezone,
  });

  // Load vehicles for family filtering logic (now synchronous)
  final vehiclesMap = ref.watch(familyVehiclesProvider);

  try {
    // Get all groups for the family
    final groupRepository = ref.read(groupRepositoryProvider);
    final groupsResult = await groupRepository.getGroups();

    if (!groupsResult.isOk) {
      AppLogger.error('Failed to fetch family groups', {
        'error': groupsResult.error.toString(),
      });
      return [];
    }

    final familyGroups = groupsResult.value!;
    if (familyGroups.isEmpty) {
      AppLogger.debug(
        'No groups found for family - returning empty transport summary',
      );
      return [];
    }

    // Track all family-relevant schedule slots
    final allFamilyRelevantSlots = <ScheduleSlot>[];

    // Generate the 7-day rolling period starting from today in USER timezone
    // CRITICAL FIX: Use timezone-aware date calculations, not device timezone
    final startDate = DateUtils.getTodayInUserTimezone(userTimezone);
    final weekFormat = getISOWeekString(startDate, userTimezone);

    AppLogger.debug('Fetching schedules for 7-day period', {
      'startDate': startDate.toIso8601String(),
      'weekFormat': weekFormat,
      'groupCount': familyGroups.length,
    });

    // For each family group, fetch the weekly schedule
    // IMPORTANT: Watch the schedule provider to enable auto-refresh
    // When schedule changes, this provider will automatically re-run
    for (final group in familyGroups) {
      try {
        // Watch schedule provider instead of calling repository directly
        // This creates a dependency that enables automatic refresh
        final weeklySlots = await ref.watch(
          weeklyScheduleProvider(group.id, weekFormat).future,
        );

        // Filter slots to include only those within our 7-day window
        final relevantSlots = weeklySlots.where((slot) {
          final slotDateTime = _convertScheduleSlotToDateTime(slot, startDate);
          return slotDateTime != null &&
              slotDateTime.isAfter(
                startDate.subtract(const Duration(days: 1)),
              ) &&
              slotDateTime.isBefore(startDate.add(const Duration(days: 7)));
        }).toList();

        // Apply family filtering to the slots
        final filteredSlots = _filterFamilyRelevantSlots(
          relevantSlots,
          familyId,
          vehiclesMap,
        );

        allFamilyRelevantSlots.addAll(filteredSlots);

        AppLogger.debug('Processed group schedules', {
          'groupId': group.id,
          'groupName': group.name,
          'totalSlots': weeklySlots.length,
          'relevantSlots': relevantSlots.length,
          'filteredSlots': filteredSlots.length,
        });
      } catch (e) {
        AppLogger.error('Error processing group schedule', {
          'groupId': group.id,
          'groupName': group.name,
          'error': e.toString(),
        });
        // Continue with other groups even if one fails
      }
    }

    // Group filtered slots by day and create DayTransportSummary objects
    final daySummaries = _createDaySummariesFromSlots(
      allFamilyRelevantSlots,
      startDate,
      familyId,
      vehiclesMap,
      userTimezone,
    );

    AppLogger.debug('Successfully generated 7-day transport summary', {
      'familyId': familyId,
      'totalSlots': allFamilyRelevantSlots.length,
      'daysWithData': daySummaries
          .where((d) => d.hasScheduledTransports)
          .length,
    });

    return daySummaries;
  } catch (e) {
    AppLogger.error('Error generating 7-day transport summary', {
      'familyId': familyId,
      'error': e.toString(),
    });

    // Return empty list on error rather than throwing - dashboard can handle empty state
    return [];
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
      // Get current user for timezone
      final user = ref.read(currentUserProvider);
      if (user == null) {
        return [];
      }

      // Find today's summary using USER timezone
      final userTimezone = user.timezone ?? 'UTC';
      final todayInUserTimezone = DateUtils.getTodayInUserTimezone(
        userTimezone,
      );
      final todaySummary = summaries.where((summary) {
        return _isSameDay(summary.date, todayInUserTimezone);
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
      // Get current user for timezone
      final user = ref.read(currentUserProvider);
      if (user == null) {
        return null;
      }

      // Find today's summary using USER timezone
      final userTimezone = user.timezone ?? 'UTC';
      final todayInUserTimezone = DateUtils.getTodayInUserTimezone(
        userTimezone,
      );
      return summaries.where((summary) {
        return _isSameDay(summary.date, todayInUserTimezone);
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

    // Get current user for timezone-aware date
    final user = ref.read(currentUserProvider);
    final userTimezone = user?.timezone ?? 'UTC';

    // Return today's date in USER timezone
    return DateUtils.getTodayInUserTimezone(userTimezone);
  }

  /// Select a specific day
  void selectDay(DateTime day) {
    state = DateTime(day.year, day.month, day.day);
  }

  /// Select today
  void selectToday() {
    // Get current user for timezone-aware date
    final user = ref.read(currentUserProvider);
    final userTimezone = user?.timezone ?? 'UTC';

    // Set today's date in USER timezone
    state = DateUtils.getTodayInUserTimezone(userTimezone);
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
// PART 5: FAMILY FILTERING UTILITIES
// =============================================================================

/// Filter schedule slots to include only family-relevant transports
///
/// This implements the core business logic from the backend API specification:
/// - Vehicles from the family are always included (even if empty)
/// - Vehicles from other families are included ONLY if they contain family children
///
/// [allSlots] All schedule slots for the family groups
/// [familyId] The ID of the authenticated family
/// Returns filtered list of slots containing only family-relevant transports
List<ScheduleSlot> _filterFamilyRelevantSlots(
  List<ScheduleSlot> allSlots,
  String familyId,
  Map<String, Vehicle> vehiclesMap,
) {
  return allSlots.where((slot) {
    // Check if this slot has any family-relevant vehicle assignments
    final hasFamilyRelevantVehicles = slot.vehicleAssignments.any((
      vehicleAssignment,
    ) {
      return _isVehicleFamilyRelevant(vehicleAssignment, familyId, vehiclesMap);
    });

    if (!hasFamilyRelevantVehicles) {
      AppLogger.debug('Filtering out slot - no family-relevant vehicles', {
        'slotId': slot.id,
        'groupId': slot.groupId,
        'vehicleCount': slot.vehicleAssignments.length,
      });
    }

    return hasFamilyRelevantVehicles;
  }).toList();
}

/// Check if a vehicle assignment is relevant to the family
///
/// Returns true if:
/// - The vehicle belongs to the family (always shown)
/// - OR the vehicle contains children from the family (shown for those children)
bool _isVehicleFamilyRelevant(
  VehicleAssignment vehicleAssignment,
  String familyId,
  Map<String, Vehicle> vehiclesMap,
) {
  // Case 1: Check if this is a family vehicle
  final vehicle = vehiclesMap[vehicleAssignment.vehicleId];
  if (vehicle != null && vehicle.familyId == familyId) {
    AppLogger.debug('Vehicle relevant - family vehicle', {
      'vehicleId': vehicleAssignment.vehicleId,
      'vehicleName': vehicleAssignment.vehicleName,
      'familyId': vehicle.familyId,
    });
    return true; // Always show family vehicles
  }

  // Case 2: Check if this vehicle has any children from the family
  final hasFamilyChildren = vehicleAssignment.childAssignments.any((
    childAssignment,
  ) {
    return childAssignment.familyId == familyId;
  });

  if (hasFamilyChildren) {
    AppLogger.debug('Vehicle relevant - contains family children', {
      'vehicleId': vehicleAssignment.vehicleId,
      'vehicleName': vehicleAssignment.vehicleName,
      'familyChildren': vehicleAssignment.childAssignments
          .where((ca) => ca.familyId == familyId)
          .length,
    });
  }

  return hasFamilyChildren;
}

/// Convert ScheduleSlot to DateTime for date comparisons
///
/// This converts the day-of-week and time into a concrete DateTime
/// based on a reference date (typically the start of the 7-day period)
DateTime? _convertScheduleSlotToDateTime(
  ScheduleSlot slot,
  DateTime referenceDate,
) {
  try {
    // Map DayOfWeek enum to actual day offset from reference
    final dayOffset = _getDayOffsetFromReference(slot.dayOfWeek, referenceDate);

    // Combine reference date with the time from timeOfDay
    final slotDate = referenceDate.add(Duration(days: dayOffset));

    return DateTime(
      slotDate.year,
      slotDate.month,
      slotDate.day,
      slot.timeOfDay.hour,
      slot.timeOfDay.minute,
    );
  } catch (e) {
    AppLogger.warning('Failed to convert ScheduleSlot to DateTime', {
      'slotId': slot.id,
      'dayOfWeek': slot.dayOfWeek.toString(),
      'timeOfDay': slot.timeOfDay.toString(),
      'error': e.toString(),
    });
    return null;
  }
}

/// Get the day offset for a DayOfWeek relative to a reference date
int _getDayOffsetFromReference(DayOfWeek dayOfWeek, DateTime referenceDate) {
  final referenceDay = referenceDate.weekday; // 1=Monday, 7=Sunday

  final slotDayValue = _convertDayOfWeekToInt(dayOfWeek);

  // Calculate offset (could be negative if slot day is before reference day)
  final offset = slotDayValue - referenceDay;

  // Handle week wrap-around: if offset is too negative, adjust to next week
  if (offset < -3) {
    // More than 3 days before reference, assume next week
    return offset + 7;
  }

  return offset;
}

/// Convert DayOfWeek enum to int (1=Monday, 7=Sunday)
int _convertDayOfWeekToInt(DayOfWeek dayOfWeek) {
  switch (dayOfWeek) {
    case DayOfWeek.monday:
      return 1;
    case DayOfWeek.tuesday:
      return 2;
    case DayOfWeek.wednesday:
      return 3;
    case DayOfWeek.thursday:
      return 4;
    case DayOfWeek.friday:
      return 5;
    case DayOfWeek.saturday:
      return 6;
    case DayOfWeek.sunday:
      return 7;
  }
}

/// Create DayTransportSummary objects from filtered schedule slots
List<DayTransportSummary> _createDaySummariesFromSlots(
  List<ScheduleSlot> slots,
  DateTime startDate,
  String familyId,
  Map<String, Vehicle> vehiclesMap,
  String userTimezone,
) {
  final summaries = <DayTransportSummary>[];

  // Create 7 days from startDate
  for (var dayOffset = 0; dayOffset < 7; dayOffset++) {
    final currentDate = startDate.add(Duration(days: dayOffset));
    final dateString = _formatDateAsIso(currentDate);

    // Find slots for this specific day
    final daySlots = slots.where((slot) {
      final slotDateTime = _convertScheduleSlotToDateTime(slot, startDate);
      return slotDateTime != null && _isSameDay(slotDateTime, currentDate);
    }).toList();

    // Convert slots to transport summaries
    final transports = daySlots
        .map(
          (slot) => _convertSlotToTransportSummary(
            slot,
            familyId,
            vehiclesMap,
            userTimezone,
          ),
        )
        .toList();

    // Calculate aggregate statistics
    final totalChildren = transports.fold(
      0,
      (sum, transport) => sum + transport.totalChildrenAssigned,
    );
    final totalVehicles = transports.fold(
      0,
      (sum, transport) => sum + transport.vehicleAssignmentSummaries.length,
    );

    summaries.add(
      DayTransportSummary(
        date: dateString,
        transports: transports,
        totalChildrenInVehicles: totalChildren,
        totalVehiclesWithAssignments: totalVehicles,
        hasScheduledTransports: transports.isNotEmpty,
      ),
    );
  }

  return summaries;
}

/// Convert ScheduleSlot to TransportSlotSummary
TransportSlotSummary _convertSlotToTransportSummary(
  ScheduleSlot slot,
  String familyId,
  Map<String, Vehicle> vehiclesMap,
  String userTimezone,
) {
  // Convert vehicle assignments to summaries
  final vehicleSummaries = slot.vehicleAssignments
      .where((va) => _isVehicleFamilyRelevant(va, familyId, vehiclesMap))
      .map(
        (va) => _convertVehicleAssignmentToSummary(va, familyId, vehiclesMap),
      )
      .toList();

  // Calculate totals
  final totalChildren = vehicleSummaries.fold(
    0,
    (sum, vehicle) => sum + vehicle.assignedChildrenCount,
  );
  final totalCapacity = vehicleSummaries.fold(
    0,
    (sum, vehicle) => sum + vehicle.vehicleCapacity,
  );

  // Determine overall capacity status
  final overallStatus = _calculateOverallCapacityStatus(vehicleSummaries);

  // Format time using TimezoneFormatter for consistent timezone-aware display
  // Create a UTC DateTime from the time of day for proper timezone conversion
  final nowUtc = DateTime.now().toUtc();
  final slotUtcDateTime = DateTime.utc(
    nowUtc.year,
    nowUtc.month,
    nowUtc.day,
    slot.timeOfDay.hour,
    slot.timeOfDay.minute,
  );

  final formattedTime = TimezoneFormatter.formatTimeOnly(
    slotUtcDateTime,
    userTimezone,
  );

  return TransportSlotSummary(
    time: formattedTime,
    groupId: slot.groupId,
    groupName: 'Group ${slot.groupId}', // TODO: Get actual group name
    scheduleSlotId: slot.id,
    vehicleAssignmentSummaries: vehicleSummaries,
    totalChildrenAssigned: totalChildren,
    totalCapacity: totalCapacity,
    overallCapacityStatus: overallStatus,
  );
}

/// Convert VehicleAssignment to VehicleAssignmentSummary
VehicleAssignmentSummary _convertVehicleAssignmentToSummary(
  VehicleAssignment vehicleAssignment,
  String familyId,
  Map<String, Vehicle> vehiclesMap,
) {
  // Convert ALL children to VehicleChild entities
  // Note: Backend already filters which vehicles are relevant to the family
  // The isFamilyChild flag is for UI highlighting only, NOT for filtering
  final allChildren = vehicleAssignment.childAssignments
      .map(
        (ca) => VehicleChild(
          childId: ca.childId,
          childName: ca.childName ?? 'Unknown Child',
          childFamilyId: ca.familyId ?? '',
          childFamilyName: ca.familyName, // Include family name for display
          isFamilyChild: ca.familyId == familyId, // Flag for UI highlighting
        ),
      )
      .toList();

  // Use total child count for accurate capacity display
  // This matches the schedule feature's behavior and shows correct availability
  final totalChildrenCount = allChildren.length;

  // Determine capacity status
  final capacityStatus = vehicleAssignment.capacityStatus();

  // Check if this is a family vehicle
  final vehicle = vehiclesMap[vehicleAssignment.vehicleId];
  final vehicleFamilyId = vehicle?.familyId ?? '';
  final isFamilyVehicle = vehicleFamilyId == familyId;

  return VehicleAssignmentSummary(
    vehicleId: vehicleAssignment.vehicleId,
    vehicleName: vehicleAssignment.vehicleName,
    vehicleCapacity: vehicleAssignment.effectiveCapacity,
    assignedChildrenCount: totalChildrenCount, // Correct total count
    availableSeats: vehicleAssignment.effectiveCapacity - totalChildrenCount,
    capacityStatus: capacityStatus,
    vehicleFamilyId: vehicleFamilyId,
    isFamilyVehicle: isFamilyVehicle,
    driver: vehicleAssignment.driverName != null
        ? VehicleDriver(
            id: vehicleAssignment.driverId ?? '',
            name: vehicleAssignment.driverName!,
          )
        : null,
    children: allChildren, // Include all children with isFamilyChild flag
  );
}

/// Calculate overall capacity status for a transport slot
CapacityStatus _calculateOverallCapacityStatus(
  List<VehicleAssignmentSummary> vehicles,
) {
  if (vehicles.isEmpty) return CapacityStatus.available;

  // Check if any vehicle is overcapacity
  if (vehicles.any((v) => v.capacityStatus == CapacityStatus.overcapacity)) {
    return CapacityStatus.overcapacity;
  }

  // Check if all vehicles are full
  if (vehicles.every((v) => v.capacityStatus == CapacityStatus.full)) {
    return CapacityStatus.full;
  }

  // Check if any vehicle has limited availability
  if (vehicles.any((v) => v.capacityStatus == CapacityStatus.limited)) {
    return CapacityStatus.limited;
  }

  // Otherwise, there's available capacity
  return CapacityStatus.available;
}

/// Format DateTime as ISO date string (YYYY-MM-DD)
String _formatDateAsIso(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

// =============================================================================
// PART 7: LEGACY UTILITY FUNCTIONS
// =============================================================================

/// Helper method to compare dates without time components
bool _isSameDay(dynamic date1, DateTime date2) {
  if (date1 is String) {
    // Parse ISO date string (YYYY-MM-DD)
    final parts = date1.split('-');
    if (parts.length != 3) return false;

    try {
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      return year == date2.year && month == date2.month && day == date2.day;
    } catch (e) {
      return false;
    }
  } else if (date1 is DateTime) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
  return false;
}

// =============================================================================
// END OF TRANSPORT PROVIDERS
// =============================================================================
