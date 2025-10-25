// EduLift Mobile - WebSocket Event Models
// Comprehensive event models for real-time WebSocket communication

import 'package:equatable/equatable.dart';
import '../../../core/utils/safe_casting_utils.dart';
import '../../../infrastructure/network/websocket/socket_events.dart';

/// Base WebSocket event interface
abstract class WebSocketEvent extends Equatable {
  final String eventId;
  final String eventType;
  final DateTime timestamp;
  final String? userId;
  final Map<String, dynamic>? metadata;

  const WebSocketEvent({
    required this.eventId,
    required this.eventType,
    required this.timestamp,
    this.userId,
    this.metadata,
  });
}

/// Real-time vehicle assignment update event
class VehicleAssignmentUpdateEvent extends WebSocketEvent {
  final String vehicleAssignmentId;
  final String scheduleSlotId;
  final String groupId;
  final VehicleAssignmentAction action;
  final Map<String, dynamic>? vehicleAssignmentData;
  final Map<String, dynamic> assignmentData;
  final String updatedBy;
  final String updatedByName;

  const VehicleAssignmentUpdateEvent({
    required String eventId,
    required DateTime timestamp,
    required this.vehicleAssignmentId,
    required this.scheduleSlotId,
    required this.groupId,
    required this.action,
    this.vehicleAssignmentData,
    this.assignmentData = const {},
    required this.updatedBy,
    required this.updatedByName,
    String? userId,
    Map<String, dynamic>? metadata,
  }) : super(
         eventId: eventId,
         eventType: 'vehicle_assignment_update',
         timestamp: timestamp,
         userId: userId,
         metadata: metadata,
       );

  factory VehicleAssignmentUpdateEvent.fromJson(Map<String, dynamic> json) {
    return VehicleAssignmentUpdateEvent(
      eventId: json['eventId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      vehicleAssignmentId: json['vehicleAssignmentId'] as String,
      scheduleSlotId: json['scheduleSlotId'] as String,
      groupId: json['groupId'] as String,
      action: VehicleAssignmentAction.values.firstWhere(
        (a) => a.name == json['action'],
        orElse: () => VehicleAssignmentAction.update,
      ),
      vehicleAssignmentData:
          json['vehicleAssignmentData'] as Map<String, dynamic>?,
      assignmentData: json['assignmentData'] as Map<String, dynamic>? ?? {},
      updatedBy: json['updatedBy'] as String,
      updatedByName: json['updatedByName'] as String,
      userId: json['userId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'eventType': eventType,
      'timestamp': timestamp.toIso8601String(),
      'vehicleAssignmentId': vehicleAssignmentId,
      'scheduleSlotId': scheduleSlotId,
      'groupId': groupId,
      'action': action.name,
      'vehicleAssignmentData': vehicleAssignmentData,
      'assignmentData': assignmentData,
      'updatedBy': updatedBy,
      'updatedByName': updatedByName,
      'userId': userId,
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [
    eventId,
    eventType,
    timestamp,
    vehicleAssignmentId,
    scheduleSlotId,
    groupId,
    action,
    vehicleAssignmentData,
    assignmentData,
    updatedBy,
    updatedByName,
    userId,
    metadata,
  ];
}

/// Real-time child assignment update event
class ChildAssignmentUpdateEvent extends WebSocketEvent {
  final String childId;
  final String? childName;
  final String vehicleAssignmentId;
  final String scheduleSlotId;
  final String groupId;
  final ChildAssignmentAction action;
  final Map<String, dynamic>? childAssignmentData;
  final String updatedBy;
  final String updatedByName;
  final String? familyId;

  const ChildAssignmentUpdateEvent({
    required String eventId,
    required DateTime timestamp,
    required this.childId,
    this.childName,
    required this.vehicleAssignmentId,
    required this.scheduleSlotId,
    required this.groupId,
    required this.action,
    this.childAssignmentData,
    required this.updatedBy,
    required this.updatedByName,
    this.familyId,
    String? userId,
    Map<String, dynamic>? metadata,
  }) : super(
         eventId: eventId,
         eventType: SocketMessageTypes.CHILD_ASSIGNMENT_UPDATE,
         timestamp: timestamp,
         userId: userId,
         metadata: metadata,
       );

  factory ChildAssignmentUpdateEvent.fromJson(Map<String, dynamic> json) {
    return ChildAssignmentUpdateEvent(
      eventId: json['eventId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      childId: json['childId'] as String,
      childName: json['childName'] as String?,
      vehicleAssignmentId: json['vehicleAssignmentId'] as String,
      scheduleSlotId: json['scheduleSlotId'] as String,
      groupId: json['groupId'] as String,
      action: ChildAssignmentAction.values.firstWhere(
        (a) => a.name == json['action'],
        orElse: () => ChildAssignmentAction.assign,
      ),
      childAssignmentData: json['childAssignmentData'] as Map<String, dynamic>?,
      updatedBy: json['updatedBy'] as String,
      updatedByName: json['updatedByName'] as String,
      familyId: json['familyId'] as String?,
      userId: json['userId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'eventType': eventType,
      'timestamp': timestamp.toIso8601String(),
      'childId': childId,
      'childName': childName,
      'vehicleAssignmentId': vehicleAssignmentId,
      'scheduleSlotId': scheduleSlotId,
      'groupId': groupId,
      'action': action.name,
      'childAssignmentData': childAssignmentData,
      'updatedBy': updatedBy,
      'updatedByName': updatedByName,
      'familyId': familyId,
      'userId': userId,
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [
    eventId,
    eventType,
    timestamp,
    childId,
    childName,
    vehicleAssignmentId,
    scheduleSlotId,
    groupId,
    action,
    childAssignmentData,
    updatedBy,
    updatedByName,
    familyId,
    userId,
    metadata,
  ];
}

/// Real-time schedule conflict event
class ScheduleConflictEvent extends WebSocketEvent {
  final String conflictId;
  final String groupId;
  final ScheduleConflictType conflictType;
  final List<String> affectedScheduleSlots;
  final List<String> affectedVehicles;
  final List<String> affectedChildren;
  final Map<String, dynamic> conflictDetails;
  final String detectedBy;
  final List<ConflictResolution> suggestedResolutions;

  const ScheduleConflictEvent({
    required String eventId,
    required DateTime timestamp,
    required this.conflictId,
    required this.groupId,
    required this.conflictType,
    required this.affectedScheduleSlots,
    required this.affectedVehicles,
    required this.affectedChildren,
    required this.conflictDetails,
    required this.detectedBy,
    this.suggestedResolutions = const [],
    String? userId,
    Map<String, dynamic>? metadata,
  }) : super(
         eventId: eventId,
         eventType: SocketEvents.SCHEDULE_CONFLICT,
         timestamp: timestamp,
         userId: userId,
         metadata: metadata,
       );

  factory ScheduleConflictEvent.fromJson(Map<String, dynamic> json) {
    return ScheduleConflictEvent(
      eventId: json['eventId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      conflictId: json['conflictId'] as String,
      groupId: json['groupId'] as String,
      conflictType: ScheduleConflictType.values.firstWhere(
        (t) => t.name == json['conflictType'],
        orElse: () => ScheduleConflictType.vehicleDoubleBooking,
      ),
      affectedScheduleSlots: SafeCastingUtils.safeCastToStringList(
        json['affectedScheduleSlots'],
      ),
      affectedVehicles: SafeCastingUtils.safeCastToStringList(
        json['affectedVehicles'],
      ),
      affectedChildren: SafeCastingUtils.safeCastToStringList(
        json['affectedChildren'],
      ),
      conflictDetails: json['conflictDetails'] as Map<String, dynamic>,
      detectedBy: json['detectedBy'] as String,
      suggestedResolutions: SafeCastingUtils.safeCastToList<ConflictResolution>(
        json['suggestedResolutions'],
        (item) => ConflictResolution.fromJson(
          SafeCastingUtils.safeCastToStringDynamicMap(item),
        ),
      ),
      userId: json['userId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [
    eventId,
    eventType,
    timestamp,
    conflictId,
    groupId,
    conflictType,
    affectedScheduleSlots,
    affectedVehicles,
    affectedChildren,
    conflictDetails,
    detectedBy,
    suggestedResolutions,
    userId,
    metadata,
  ];
}

/// Real-time typing indicator event
class TypingIndicatorEvent extends WebSocketEvent {
  final String context; // e.g., 'schedule-slot-123', 'invitation-456'
  final String userName;
  final bool isTyping;
  final String? action; // 'editing', 'assigning', 'creating'

  const TypingIndicatorEvent({
    required String eventId,
    required DateTime timestamp,
    required this.context,
    required this.userName,
    required this.isTyping,
    this.action,
    String? userId,
    Map<String, dynamic>? metadata,
  }) : super(
         eventId: eventId,
         eventType: 'typing_indicator',
         timestamp: timestamp,
         userId: userId,
         metadata: metadata,
       );

  factory TypingIndicatorEvent.fromJson(Map<String, dynamic> json) {
    return TypingIndicatorEvent(
      eventId: json['eventId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      context: json['context'] as String,
      userName: json['userName'] as String,
      isTyping: json['isTyping'] as bool,
      action: json['action'] as String?,
      userId: json['userId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [
    eventId,
    eventType,
    timestamp,
    context,
    userName,
    isTyping,
    action,
    userId,
    metadata,
  ];
}

/// Presence update event for user online/offline status
class PresenceUpdateEvent extends WebSocketEvent {
  final String targetUserId;
  final String userName;
  final PresenceStatus status;
  final String? lastSeen;
  final String? activity; // 'viewing-schedule', 'editing-invitation'

  const PresenceUpdateEvent({
    required String eventId,
    required DateTime timestamp,
    required this.targetUserId,
    required this.userName,
    required this.status,
    this.lastSeen,
    this.activity,
    String? userId,
    Map<String, dynamic>? metadata,
  }) : super(
         eventId: eventId,
         eventType: 'presence_update',
         timestamp: timestamp,
         userId: userId,
         metadata: metadata,
       );

  factory PresenceUpdateEvent.fromJson(Map<String, dynamic> json) {
    return PresenceUpdateEvent(
      eventId: json['eventId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      targetUserId: json['targetUserId'] as String,
      userName: json['userName'] as String,
      status: PresenceStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => PresenceStatus.offline,
      ),
      lastSeen: json['lastSeen'] as String?,
      activity: json['activity'] as String?,
      userId: json['userId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [
    eventId,
    eventType,
    timestamp,
    targetUserId,
    userName,
    status,
    lastSeen,
    activity,
    userId,
    metadata,
  ];
}

/// Action enums
enum VehicleAssignmentAction { assign, remove, update, confirm, cancel }

enum ChildAssignmentAction { assign, remove, move, confirm }

enum ScheduleConflictType {
  vehicleDoubleBooking,
  capacityExceeded,
  driverUnavailable,
  childDoubleBooking,
  timeSlotConflict,
}

enum PresenceStatus { online, offline, away, busy }

/// Conflict resolution suggestion
class ConflictResolution extends Equatable {
  final String resolutionId;
  final String type; // 'reassign_vehicle', 'split_assignments', 'reschedule'
  final String description;
  final Map<String, dynamic> resolutionData;
  final int? priority; // 1-10, higher is better

  const ConflictResolution({
    required this.resolutionId,
    required this.type,
    required this.description,
    required this.resolutionData,
    this.priority,
  });

  factory ConflictResolution.fromJson(Map<String, dynamic> json) {
    return ConflictResolution(
      resolutionId: json['resolutionId'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      resolutionData: json['resolutionData'] as Map<String, dynamic>,
      priority: json['priority'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resolutionId': resolutionId,
      'type': type,
      'description': description,
      'resolutionData': resolutionData,
      'priority': priority,
    };
  }

  @override
  List<Object?> get props => [
    resolutionId,
    type,
    description,
    resolutionData,
    priority,
  ];
}
