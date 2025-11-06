// Clean Architecture - Domain entities for dashboard transport display
// Aggregates existing schedule entities for dashboard consumption

import 'package:equatable/equatable.dart';
import 'package:edulift/core/domain/entities/schedule/time_of_day.dart';
import 'package:edulift/core/domain/entities/schedule/vehicle_assignment.dart';

/// Dashboard-specific aggregation of transport information for a single day
///
/// This is a display-focused entity that aggregates existing schedule domain entities
/// for dashboard consumption. It should NOT contain business logic - only pre-calculated
/// display values derived from core domain entities.
class DayTransportSummary extends Equatable {
  /// The calendar date (not week-based)
  final DateTime date;

  /// All transport slots for this day (dashboard summaries, not domain entities)
  final List<TransportSlotSummary> transports;

  /// Total number of children assigned to vehicles on this day (pre-calculated)
  final int totalChildrenInVehicles;

  /// Total number of vehicles with assignments on this day (pre-calculated)
  final int totalVehiclesWithAssignments;

  /// Whether this day has any scheduled transports (pre-calculated)
  final bool hasScheduledTransports;

  const DayTransportSummary({
    required this.date,
    required this.transports,
    required this.totalChildrenInVehicles,
    required this.totalVehiclesWithAssignments,
    required this.hasScheduledTransports,
  });

  @override
  List<Object?> get props => [
    date,
    transports,
    totalChildrenInVehicles,
    totalVehiclesWithAssignments,
    hasScheduledTransports,
  ];

  DayTransportSummary copyWith({
    DateTime? date,
    List<TransportSlotSummary>? transports,
    int? totalChildrenInVehicles,
    int? totalVehiclesWithAssignments,
    bool? hasScheduledTransports,
  }) {
    return DayTransportSummary(
      date: date ?? this.date,
      transports: transports ?? this.transports,
      totalChildrenInVehicles:
          totalChildrenInVehicles ?? this.totalChildrenInVehicles,
      totalVehiclesWithAssignments:
          totalVehiclesWithAssignments ?? this.totalVehiclesWithAssignments,
      hasScheduledTransports:
          hasScheduledTransports ?? this.hasScheduledTransports,
    );
  }
}

/// Summary of a single transport time slot for dashboard display
///
/// This entity aggregates data from core schedule domain entities for dashboard display.
/// All values should be pre-calculated to avoid business logic in the presentation layer.
class TransportSlotSummary extends Equatable {
  /// Time of the transport slot (from domain entity)
  final TimeOfDayValue time;

  /// Destination location (display string, not domain entity)
  final String destination;

  /// Vehicle assignment summaries for this time slot (dashboard-specific)
  final List<VehicleAssignmentSummary> vehicleAssignmentSummaries;

  /// Total children assigned across all vehicles (pre-calculated)
  final int totalChildrenAssigned;

  /// Total capacity across all vehicles (pre-calculated)
  final int totalCapacity;

  /// Overall capacity status for this time slot (from domain calculation)
  final CapacityStatus overallCapacityStatus;

  const TransportSlotSummary({
    required this.time,
    required this.destination,
    required this.vehicleAssignmentSummaries,
    required this.totalChildrenAssigned,
    required this.totalCapacity,
    required this.overallCapacityStatus,
  });

  @override
  List<Object?> get props => [
    time,
    destination,
    vehicleAssignmentSummaries,
    totalChildrenAssigned,
    totalCapacity,
    overallCapacityStatus,
  ];

  /// Calculates utilization percentage for this time slot
  double get utilizationPercentage =>
      totalCapacity > 0 ? (totalChildrenAssigned / totalCapacity) * 100 : 0.0;

  /// Check if this time slot is at full capacity
  bool get isFull => overallCapacityStatus == CapacityStatus.full;
}

/// Simplified vehicle assignment representation for dashboard display
/// This is a dashboard-specific aggregation, not the core domain VehicleAssignment
class VehicleAssignmentSummary extends Equatable {
  /// Vehicle information (basic display data)
  final String vehicleId;
  final String vehicleName;
  final int vehicleCapacity;

  /// Number of children assigned to this vehicle (pre-calculated)
  final int assignedChildrenCount;

  /// Number of available seats
  final int availableSeats;

  /// Capacity status (calculated from domain logic, stored for display)
  final CapacityStatus capacityStatus;

  const VehicleAssignmentSummary({
    required this.vehicleId,
    required this.vehicleName,
    required this.vehicleCapacity,
    required this.assignedChildrenCount,
    required this.availableSeats,
    required this.capacityStatus,
  });

  @override
  List<Object?> get props => [
    vehicleId,
    vehicleName,
    vehicleCapacity,
    assignedChildrenCount,
    availableSeats,
    capacityStatus,
  ];

  /// Check if this vehicle assignment is full
  bool get isFull => availableSeats == 0;

  /// Get utilization percentage for this vehicle (display calculation)
  double get utilizationPercentage => vehicleCapacity > 0
      ? (assignedChildrenCount / vehicleCapacity) * 100
      : 0.0;

  VehicleAssignmentSummary copyWith({
    String? vehicleId,
    String? vehicleName,
    int? vehicleCapacity,
    int? assignedChildrenCount,
    int? availableSeats,
    CapacityStatus? capacityStatus,
  }) {
    return VehicleAssignmentSummary(
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleName: vehicleName ?? this.vehicleName,
      vehicleCapacity: vehicleCapacity ?? this.vehicleCapacity,
      assignedChildrenCount:
          assignedChildrenCount ?? this.assignedChildrenCount,
      availableSeats: availableSeats ?? this.availableSeats,
      capacityStatus: capacityStatus ?? this.capacityStatus,
    );
  }
}

/// Dashboard-specific transport summary for 7-day view
///
/// This entity provides aggregated dashboard data for a week view.
/// All aggregate values should be pre-calculated from daily summaries.
class SevenDayTransportSummary extends Equatable {
  /// Start date of the 7-day period
  final DateTime startDate;

  /// End date of the 7-day period
  final DateTime endDate;

  /// Daily transport summaries (already aggregated display data)
  final List<DayTransportSummary> dailySummaries;

  /// Total children across all 7 days (pre-calculated)
  final int totalChildrenAcrossWeek;

  /// Total vehicles with assignments across week (pre-calculated)
  final int totalVehiclesAcrossWeek;

  /// Number of days with scheduled transports (pre-calculated)
  final int daysWithTransports;

  const SevenDayTransportSummary({
    required this.startDate,
    required this.endDate,
    required this.dailySummaries,
    required this.totalChildrenAcrossWeek,
    required this.totalVehiclesAcrossWeek,
    required this.daysWithTransports,
  });

  @override
  List<Object?> get props => [
    startDate,
    endDate,
    dailySummaries,
    totalChildrenAcrossWeek,
    totalVehiclesAcrossWeek,
    daysWithTransports,
  ];

  /// Get summary for a specific date
  DayTransportSummary? getSummaryForDate(DateTime date) {
    try {
      return dailySummaries.firstWhere(
        (summary) => _isSameDay(summary.date, date),
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if a date has transports
  bool hasTransportsOnDate(DateTime date) {
    final summary = getSummaryForDate(date);
    return summary?.hasScheduledTransports ?? false;
  }

  /// Helper method to compare dates without time
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
