// EduLift Mobile - Schedule Response Models
// Matches backend /api/schedule/* endpoints

/// Schedule slot response model
class ScheduleSlotResponse {
  final String id;
  final String? title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String? vehicleId;
  final String? vehicleName;
  final List<String> childIds;
  final String status;
  final Map<String, dynamic>? metadata;

  const ScheduleSlotResponse({
    required this.id,
    this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.vehicleId,
    this.vehicleName,
    required this.childIds,
    required this.status,
    this.metadata,
  });

  factory ScheduleSlotResponse.fromJson(Map<String, dynamic> json) {
    return ScheduleSlotResponse(
      id: json['id'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      vehicleId: json['vehicleId'] as String?,
      vehicleName: json['vehicleName'] as String?,
      childIds: List<String>.from(json['childIds'] as List? ?? []),
      status: json['status'] as String? ?? 'active',
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// Schedule response model
class ScheduleResponse {
  final String id;
  final String name;
  final String familyId;
  final String? description;
  final List<ScheduleSlotResponse> slots;
  final Map<String, dynamic>? settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ScheduleResponse({
    required this.id,
    required this.name,
    required this.familyId,
    this.description,
    required this.slots,
    this.settings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ScheduleResponse.fromJson(Map<String, dynamic> json) {
    return ScheduleResponse(
      id: json['id'] as String,
      name: json['name'] as String,
      familyId: json['familyId'] as String,
      description: json['description'] as String?,
      slots: (json['slots'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                ScheduleSlotResponse.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      settings: json['settings'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// Child assignment response model
class ChildAssignmentResponse {
  final String id;
  final String childId;
  final String childName;
  final String vehicleAssignmentId;
  final String vehicleId;
  final String vehicleName;
  final DateTime assignedAt;
  final String? notes;
  final String status;

  const ChildAssignmentResponse({
    required this.id,
    required this.childId,
    required this.childName,
    required this.vehicleAssignmentId,
    required this.vehicleId,
    required this.vehicleName,
    required this.assignedAt,
    this.notes,
    required this.status,
  });

  factory ChildAssignmentResponse.fromJson(Map<String, dynamic> json) {
    return ChildAssignmentResponse(
      id: json['id'] as String,
      childId: json['childId'] as String,
      childName: json['childName'] as String,
      vehicleAssignmentId: json['vehicleAssignmentId'] as String,
      vehicleId: json['vehicleId'] as String,
      vehicleName: json['vehicleName'] as String,
      assignedAt: DateTime.parse(json['assignedAt'] as String),
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'active',
    );
  }
}

/// Schedule conflict response model
class ScheduleConflictResponse {
  final String id;
  final String type;
  final String description;
  final DateTime conflictTime;
  final List<String> affectedEntities;
  final String severity;
  final Map<String, dynamic>? resolutionOptions;

  const ScheduleConflictResponse({
    required this.id,
    required this.type,
    required this.description,
    required this.conflictTime,
    required this.affectedEntities,
    required this.severity,
    this.resolutionOptions,
  });

  factory ScheduleConflictResponse.fromJson(Map<String, dynamic> json) {
    return ScheduleConflictResponse(
      id: json['id'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      conflictTime: DateTime.parse(json['conflictTime'] as String),
      affectedEntities: List<String>.from(
        json['affectedEntities'] as List? ?? [],
      ),
      severity: json['severity'] as String? ?? 'medium',
      resolutionOptions: json['resolutionOptions'] as Map<String, dynamic>?,
    );
  }
}

/// Vehicle schedule response model
class VehicleScheduleResponse {
  final String vehicleId;
  final String vehicleName;
  final List<ScheduleSlotResponse> schedule;
  final double utilizationRate;
  final DateTime? nextAvailableTime;

  const VehicleScheduleResponse({
    required this.vehicleId,
    required this.vehicleName,
    required this.schedule,
    required this.utilizationRate,
    this.nextAvailableTime,
  });

  factory VehicleScheduleResponse.fromJson(Map<String, dynamic> json) {
    return VehicleScheduleResponse(
      vehicleId: json['vehicleId'] as String,
      vehicleName: json['vehicleName'] as String,
      schedule: (json['schedule'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                ScheduleSlotResponse.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      utilizationRate: (json['utilizationRate'] as num?)?.toDouble() ?? 0.0,
      nextAvailableTime: json['nextAvailableTime'] != null
          ? DateTime.parse(json['nextAvailableTime'] as String)
          : null,
    );
  }
}
