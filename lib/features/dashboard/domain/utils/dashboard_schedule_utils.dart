// Dashboard schedule utilities - shared between use cases
// Provides common functionality for schedule aggregation and timezone handling

import 'package:edulift/core/domain/entities/schedule.dart'
    as schedule_entities;
import 'package:edulift/core/presentation/extensions/time_of_day_timezone_extension.dart';
import 'package:edulift/features/dashboard/domain/entities/dashboard_transport_summary.dart';

/// Utility class for dashboard schedule operations
///
/// This class contains shared methods used by multiple dashboard use cases
/// to avoid code duplication and ensure consistent behavior.
class DashboardScheduleUtils {
  DashboardScheduleUtils._(); // Private constructor for utility class

  /// Get week identifier for a date (YYYY-WNN format)
  ///
  /// Uses Thursday as the anchor for consistent week identification.
  /// This ensures that the rolling 7-day view is consistent across use cases.
  static String getWeekIdentifier(DateTime date) {
    // Find Thursday of the week for consistent week identification
    final thursday = getThursdayOfWeek(date);

    // Calculate ISO week number
    final startOfYear = DateTime(thursday.year);
    final daysDifference = thursday.difference(startOfYear).inDays;
    final weekNumber = ((daysDifference + startOfYear.weekday) / 7).floor() + 1;

    return '${thursday.year}-W${weekNumber.toString().padLeft(2, '0')}';
  }

  /// Get Thursday of the week for the given date
  ///
  /// This ensures consistent week boundaries for the rolling 7-day view.
  /// DateTime.weekday: Monday=1, Tuesday=2, ..., Thursday=4, ..., Sunday=7
  static DateTime getThursdayOfWeek(DateTime date) {
    final daysToThursday = 4 - date.weekday;
    return date.add(Duration(days: daysToThursday));
  }

  /// Check if two dates are the same day (ignoring time)
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Extract destination information from a schedule slot
  ///
  /// In a complete implementation, this would extract destination from:
  /// - Group configuration (school name, destination address)
  /// - Schedule slot metadata (route information)
  /// - Vehicle route details
  static String extractDestinationFromSlot(
    schedule_entities.ScheduleSlot slot,
  ) {
    // Default destination for now
    // This can be enhanced when group/route configuration is available
    return 'School';
  }

  /// Calculate overall capacity status for a group of vehicle assignments
  ///
  /// This method aggregates capacity status across multiple vehicles
  /// to determine the overall status for a time slot.
  static schedule_entities.CapacityStatus calculateOverallCapacityStatus(
    int totalChildren,
    int totalCapacity,
  ) {
    if (totalCapacity <= 0) {
      return schedule_entities.CapacityStatus.available;
    }

    if (totalChildren > totalCapacity) {
      return schedule_entities.CapacityStatus.exceeded;
    }

    if (totalChildren == totalCapacity) {
      return schedule_entities.CapacityStatus.full;
    }

    final utilizationPercentage = (totalChildren / totalCapacity) * 100;
    if (utilizationPercentage >= 80) {
      return schedule_entities.CapacityStatus.nearFull;
    }

    return schedule_entities.CapacityStatus.available;
  }

  /// Filter schedule slots for a specific day considering timezone
  ///
  /// This method ensures that slots are properly assigned to the correct
  /// calendar day when converted to the user's timezone.
  static List<schedule_entities.ScheduleSlot> filterSlotsForDay(
    List<schedule_entities.ScheduleSlot> slots,
    DateTime targetDate,
    String userTimezone,
  ) {
    final filteredSlots = <schedule_entities.ScheduleSlot>[];

    for (final slot in slots) {
      // Convert the slot time to user's timezone
      final localTimeString = slot.timeOfDay.toLocalTimeString(
        userTimezone,
        referenceDate: targetDate,
      );

      // Parse the local time
      final timeParts = localTimeString.split(':');
      if (timeParts.length != 2) continue;

      final localHour = int.tryParse(timeParts[0]);
      final localMinute = int.tryParse(timeParts[1]);

      if (localHour == null || localMinute == null) continue;

      // Create local datetime with the slot time
      final slotLocalDateTime = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        localHour,
        localMinute,
      );

      // Check if this slot falls on the target date
      if (isSameDay(slotLocalDateTime, targetDate)) {
        filteredSlots.add(slot);
      }
    }

    return filteredSlots;
  }

  /// Aggregate schedule slots to transport slot summaries for dashboard display
  ///
  /// This method extracts common aggregation logic used by both today and 7-day use cases.
  /// It processes filtered schedule slots and creates TransportSlotSummary entities.
  static List<TransportSlotSummary> aggregateSlotsToSummaries(
    List<schedule_entities.ScheduleSlot> filteredSlots,
  ) {
    final transportSummaries = <TransportSlotSummary>[];

    // Group slots by time to avoid duplicates
    final slotsByTime = <String, List<schedule_entities.ScheduleSlot>>{};

    for (final slot in filteredSlots) {
      // Create a unique key for grouping by time
      final timeKey =
          '${slot.timeOfDay.hour.toString().padLeft(2, '0')}:${slot.timeOfDay.minute.toString().padLeft(2, '0')}';

      if (!slotsByTime.containsKey(timeKey)) {
        slotsByTime[timeKey] = [];
      }
      slotsByTime[timeKey]!.add(slot);
    }

    // Process each time slot
    for (final entry in slotsByTime.entries) {
      final timeSlots = entry.value;
      if (timeSlots.isEmpty) continue;

      // Use the first slot to get the time (they should have the same timeOfDay)
      final representativeSlot = timeSlots.first;

      // Aggregate all vehicle assignments for this time slot
      final vehicleSummaries = <VehicleAssignmentSummary>[];
      var totalChildrenAssigned = 0;
      var totalCapacity = 0;

      for (final slot in timeSlots) {
        for (final vehicleAssignment in slot.vehicleAssignments) {
          if (vehicleAssignment.isActive) {
            final capacityStatus = vehicleAssignment.capacityStatus();
            final effectiveCapacity = vehicleAssignment.effectiveCapacity;
            final assignedCount = vehicleAssignment.childAssignments.length;
            final availableSeats = effectiveCapacity - assignedCount;

            // Create vehicle assignment summary for dashboard display
            final vehicleSummary = VehicleAssignmentSummary(
              vehicleId: vehicleAssignment.vehicleId,
              vehicleName: vehicleAssignment.vehicleName,
              vehicleCapacity: effectiveCapacity,
              assignedChildrenCount: assignedCount,
              availableSeats: availableSeats,
              capacityStatus: capacityStatus,
            );

            vehicleSummaries.add(vehicleSummary);
            totalChildrenAssigned += assignedCount;
            totalCapacity += effectiveCapacity;
          }
        }
      }

      if (vehicleSummaries.isNotEmpty) {
        // Determine overall capacity status for this time slot
        final overallStatus = calculateOverallCapacityStatus(
          totalChildrenAssigned,
          totalCapacity,
        );

        // Create transport slot summary
        final transportSummary = TransportSlotSummary(
          time: representativeSlot.timeOfDay,
          destination: extractDestinationFromSlot(representativeSlot),
          vehicleAssignmentSummaries: vehicleSummaries,
          totalChildrenAssigned: totalChildrenAssigned,
          totalCapacity: totalCapacity,
          overallCapacityStatus: overallStatus,
        );

        transportSummaries.add(transportSummary);
      }
    }

    // Sort transport summaries by time (using TimeOfDayValue comparison)
    transportSummaries.sort((a, b) => a.time.compareTo(b.time));

    return transportSummaries;
  }
}
