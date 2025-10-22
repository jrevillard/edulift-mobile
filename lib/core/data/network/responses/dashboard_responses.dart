// EduLift Mobile - Dashboard Response Models
// Matches backend /api/dashboard/* endpoints

/// Dashboard statistics response model
class DashboardStatsResponse {
  final int totalFamilies;
  final int totalChildren;
  final int totalVehicles;
  final int totalGroups;
  final int activeSchedules;
  final int pendingInvitations;
  final double utilizationRate;
  final List<String> recentAlerts;
  final Map<String, dynamic>? additionalMetrics;

  const DashboardStatsResponse({
    required this.totalFamilies,
    required this.totalChildren,
    required this.totalVehicles,
    required this.totalGroups,
    required this.activeSchedules,
    required this.pendingInvitations,
    required this.utilizationRate,
    required this.recentAlerts,
    this.additionalMetrics,
  });

  factory DashboardStatsResponse.fromJson(Map<String, dynamic> json) {
    return DashboardStatsResponse(
      totalFamilies: json['totalFamilies'] as int? ?? 0,
      totalChildren: json['totalChildren'] as int? ?? 0,
      totalVehicles: json['totalVehicles'] as int? ?? 0,
      totalGroups: json['totalGroups'] as int? ?? 0,
      activeSchedules: json['activeSchedules'] as int? ?? 0,
      pendingInvitations: json['pendingInvitations'] as int? ?? 0,
      utilizationRate: (json['utilizationRate'] as num?)?.toDouble() ?? 0.0,
      recentAlerts: List<String>.from(json['recentAlerts'] as List? ?? []),
      additionalMetrics: json['additionalMetrics'] as Map<String, dynamic>?,
    );
  }
}

/// Today's schedule response model
class TodayScheduleResponse {
  final List<UpcomingTripResponse> upcomingTrips;
  final DateTime date;
  final int totalTrips;
  final int completedTrips;
  final String status;

  const TodayScheduleResponse({
    required this.upcomingTrips,
    required this.date,
    required this.totalTrips,
    required this.completedTrips,
    required this.status,
  });

  factory TodayScheduleResponse.fromJson(Map<String, dynamic> json) {
    return TodayScheduleResponse(
      upcomingTrips: (json['upcomingTrips'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                UpcomingTripResponse.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      date: DateTime.parse(json['date'] as String),
      totalTrips: json['totalTrips'] as int? ?? 0,
      completedTrips: json['completedTrips'] as int? ?? 0,
      status: json['status'] as String? ?? 'active',
    );
  }
}

/// Weekly schedule response model
class WeeklyScheduleResponse {
  final Map<String, List<UpcomingTripResponse>> weeklyTrips;
  final DateTime startDate;
  final DateTime endDate;
  final int totalTrips;
  final double averageUtilization;

  const WeeklyScheduleResponse({
    required this.weeklyTrips,
    required this.startDate,
    required this.endDate,
    required this.totalTrips,
    required this.averageUtilization,
  });

  factory WeeklyScheduleResponse.fromJson(Map<String, dynamic> json) {
    final weeklyTripsJson = json['weeklyTrips'] as Map<String, dynamic>? ?? {};
    final weeklyTrips = <String, List<UpcomingTripResponse>>{};

    weeklyTripsJson.forEach((key, value) {
      weeklyTrips[key] = (value as List<dynamic>? ?? [])
          .map(
            (item) =>
                UpcomingTripResponse.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    });

    return WeeklyScheduleResponse(
      weeklyTrips: weeklyTrips,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalTrips: json['totalTrips'] as int? ?? 0,
      averageUtilization:
          (json['averageUtilization'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Upcoming trip response model
class UpcomingTripResponse {
  final String id;
  final String? title;
  final DateTime startTime;
  final DateTime endTime;
  final String? vehicleId;
  final String? vehicleName;
  final List<String> childIds;
  final List<String> childNames;
  final String status;
  final String? route;

  const UpcomingTripResponse({
    required this.id,
    this.title,
    required this.startTime,
    required this.endTime,
    this.vehicleId,
    this.vehicleName,
    required this.childIds,
    required this.childNames,
    required this.status,
    this.route,
  });

  factory UpcomingTripResponse.fromJson(Map<String, dynamic> json) {
    return UpcomingTripResponse(
      id: json['id'] as String,
      title: json['title'] as String?,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      vehicleId: json['vehicleId'] as String?,
      vehicleName: json['vehicleName'] as String?,
      childIds: List<String>.from(json['childIds'] as List? ?? []),
      childNames: List<String>.from(json['childNames'] as List? ?? []),
      status: json['status'] as String? ?? 'scheduled',
      route: json['route'] as String?,
    );
  }
}

/// Activity item response model
class ActivityItemResponse {
  final String id;
  final String type;
  final String description;
  final DateTime timestamp;
  final String? userId;
  final String? userName;
  final Map<String, dynamic>? metadata;
  final String severity;

  const ActivityItemResponse({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
    this.userId,
    this.userName,
    this.metadata,
    required this.severity,
  });

  factory ActivityItemResponse.fromJson(Map<String, dynamic> json) {
    return ActivityItemResponse(
      id: json['id'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      severity: json['severity'] as String? ?? 'info',
    );
  }
}
