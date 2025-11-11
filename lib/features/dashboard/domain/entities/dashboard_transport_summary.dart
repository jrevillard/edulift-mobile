// Clean Architecture - Domain entities for dashboard transport display
// Aggregates existing schedule entities for dashboard consumption

import 'package:equatable/equatable.dart';
import 'package:edulift/core/domain/entities/schedule/vehicle_assignment.dart';

/// Dashboard-specific aggregation of transport information for a single day
///
/// This entity matches the backend API specification for DayTransportSummary.
/// It aggregates transport data for dashboard display with pre-calculated values.
class DayTransportSummary extends Equatable {
  /// The calendar date in ISO format (YYYY-MM-DD)
  final String date;

  /// All transport slots for this day
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
    String? date,
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
/// This entity matches the backend API specification for TransportSlotSummary.
/// All values should be pre-calculated to avoid business logic in the presentation layer.
class TransportSlotSummary extends Equatable {
  /// Time of the transport slot in HH:mm format
  final String time;

  /// Group ID for this transport slot
  final String groupId;

  /// Group name for identification
  final String groupName;

  /// Unique schedule slot ID
  final String scheduleSlotId;

  /// Vehicle assignment summaries for this time slot
  final List<VehicleAssignmentSummary> vehicleAssignmentSummaries;

  /// Total children assigned across all vehicles (pre-calculated)
  final int totalChildrenAssigned;

  /// Total capacity across all vehicles (pre-calculated)
  final int totalCapacity;

  /// Overall capacity status for this time slot
  final CapacityStatus overallCapacityStatus;

  const TransportSlotSummary({
    required this.time,
    required this.groupId,
    required this.groupName,
    required this.scheduleSlotId,
    required this.vehicleAssignmentSummaries,
    required this.totalChildrenAssigned,
    required this.totalCapacity,
    required this.overallCapacityStatus,
  });

  @override
  List<Object?> get props => [
    time,
    groupId,
    groupName,
    scheduleSlotId,
    vehicleAssignmentSummaries,
    totalChildrenAssigned,
    totalCapacity,
    overallCapacityStatus,
  ];

  /// Calculates utilization percentage for this time slot
  double get utilizationPercentage =>
      totalCapacity > 0 ? (totalChildrenAssigned / totalCapacity) * 100 : 0.0;

  /// Check if this time slot is at full capacity or overcapacity
  bool get isFull =>
      overallCapacityStatus == CapacityStatus.full ||
      overallCapacityStatus == CapacityStatus.overcapacity;

  TransportSlotSummary copyWith({
    String? time,
    String? groupId,
    String? groupName,
    String? scheduleSlotId,
    List<VehicleAssignmentSummary>? vehicleAssignmentSummaries,
    int? totalChildrenAssigned,
    int? totalCapacity,
    CapacityStatus? overallCapacityStatus,
  }) {
    return TransportSlotSummary(
      time: time ?? this.time,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      scheduleSlotId: scheduleSlotId ?? this.scheduleSlotId,
      vehicleAssignmentSummaries:
          vehicleAssignmentSummaries ?? this.vehicleAssignmentSummaries,
      totalChildrenAssigned:
          totalChildrenAssigned ?? this.totalChildrenAssigned,
      totalCapacity: totalCapacity ?? this.totalCapacity,
      overallCapacityStatus:
          overallCapacityStatus ?? this.overallCapacityStatus,
    );
  }
}

/// Simplified vehicle assignment representation for dashboard display
/// This entity matches the backend API specification for VehicleAssignmentSummary.
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

  /// Vehicle family ID
  final String vehicleFamilyId;

  /// Whether this is a family vehicle
  final bool isFamilyVehicle;

  /// Driver information (optional)
  final VehicleDriver? driver;

  /// Children assigned to this vehicle
  final List<VehicleChild> children;

  const VehicleAssignmentSummary({
    required this.vehicleId,
    required this.vehicleName,
    required this.vehicleCapacity,
    required this.assignedChildrenCount,
    required this.availableSeats,
    required this.capacityStatus,
    required this.vehicleFamilyId,
    required this.isFamilyVehicle,
    this.driver,
    required this.children,
  });

  @override
  List<Object?> get props => [
    vehicleId,
    vehicleName,
    vehicleCapacity,
    assignedChildrenCount,
    availableSeats,
    capacityStatus,
    vehicleFamilyId,
    isFamilyVehicle,
    driver,
    children,
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
    String? vehicleFamilyId,
    bool? isFamilyVehicle,
    VehicleDriver? driver,
    List<VehicleChild>? children,
  }) {
    return VehicleAssignmentSummary(
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleName: vehicleName ?? this.vehicleName,
      vehicleCapacity: vehicleCapacity ?? this.vehicleCapacity,
      assignedChildrenCount:
          assignedChildrenCount ?? this.assignedChildrenCount,
      availableSeats: availableSeats ?? this.availableSeats,
      capacityStatus: capacityStatus ?? this.capacityStatus,
      vehicleFamilyId: vehicleFamilyId ?? this.vehicleFamilyId,
      isFamilyVehicle: isFamilyVehicle ?? this.isFamilyVehicle,
      driver: driver ?? this.driver,
      children: children ?? this.children,
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
  bool _isSameDay(String dateStr, DateTime date) {
    try {
      final parts = dateStr.split('-');
      if (parts.length != 3) return false;

      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      return year == date.year && month == date.month && day == date.day;
    } catch (e) {
      return false;
    }
  }
}

/// Vehicle driver information for dashboard display
class VehicleDriver extends Equatable {
  final String id;
  final String name;

  const VehicleDriver({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

/// Vehicle child information for dashboard display
class VehicleChild extends Equatable {
  final String childId;
  final String childName;
  final String childFamilyId;
  final String? childFamilyName;
  final bool isFamilyChild;

  const VehicleChild({
    required this.childId,
    required this.childName,
    required this.childFamilyId,
    this.childFamilyName,
    required this.isFamilyChild,
  });

  @override
  List<Object?> get props => [
    childId,
    childName,
    childFamilyId,
    childFamilyName,
    isFamilyChild,
  ];
}
