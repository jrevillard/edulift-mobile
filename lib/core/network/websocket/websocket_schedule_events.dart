// EduLift Mobile - WebSocket Schedule Events
// Real-time schedule coordination events for group collaboration

import 'package:equatable/equatable.dart';
// Unused import removed
// import '../../features/schedule/domain/entities/schedule_slot.dart';
import '../../../core/network/models/schedule/vehicle_assignment_dto.dart';
import '../../../core/network/models/schedule/child_assignment_dto.dart';
import 'websocket_dto_extensions.dart';
// ignore: unused_import
import '../../../infrastructure/network/websocket/socket_events.dart'; // Required for WebSocket architecture compliance

/// Real-time schedule update event
class ScheduleUpdateEvent extends Equatable {
  final ScheduleEventType eventType;
  final String scheduleSlotId;
  final String groupId;
  final String day;
  final String time;
  final String week;
  final String updatedBy;
  final String updatedByName;
  final ScheduleChangeType changeType;
  final String changeDescription;
  final List<VehicleAssignmentDto> vehicleAssignments;
  final String? vehicleAssignmentId;
  final List<ChildAssignmentDto>? childAssignments;
  final Map<String, dynamic>? conflictDetails;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const ScheduleUpdateEvent({
    required this.eventType,
    required this.scheduleSlotId,
    required this.groupId,
    required this.day,
    required this.time,
    required this.week,
    required this.updatedBy,
    required this.updatedByName,
    required this.changeType,
    required this.changeDescription,
    this.vehicleAssignments = const [],
    this.vehicleAssignmentId,
    this.childAssignments,
    this.conflictDetails,
    required this.timestamp,
    this.metadata = const {},
  });

  factory ScheduleUpdateEvent.fromJson(Map<String, dynamic> json) {
    try {
      return ScheduleUpdateEvent(
        eventType: _parseScheduleEventType(json['eventType'] as String?),
        scheduleSlotId: json['scheduleSlotId'] as String,
        groupId: json['groupId'] as String,
        day: json['day'] as String,
        time: json['time'] as String,
        week: json['week'] as String,
        updatedBy: json['updatedBy'] as String,
        updatedByName: json['updatedByName'] as String,
        changeType: _parseScheduleChangeType(json['changeType'] as String?),
        changeDescription: json['changeDescription'] as String,
        vehicleAssignments:
            (json['vehicleAssignments'] as List<dynamic>?)
                ?.map(
                  (item) => VehicleAssignmentDto.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList() ??
            [],
        vehicleAssignmentId: json['vehicleAssignmentId'] as String?,
        childAssignments: (json['childAssignments'] as List<dynamic>?)
            ?.map(
              (item) =>
                  ChildAssignmentDto.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
        conflictDetails: json['conflictDetails'] != null
            ? Map<String, dynamic>.from(json['conflictDetails'] as Map)
            : null,
        timestamp: DateTime.parse(json['timestamp'] as String),
        metadata: json['metadata'] != null
            ? Map<String, dynamic>.from(json['metadata'] as Map)
            : {},
      );
    } catch (e) {
      throw Exception('Failed to parse ScheduleUpdateEvent: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'eventType': eventType.name,
      'scheduleSlotId': scheduleSlotId,
      'groupId': groupId,
      'day': day,
      'time': time,
      'week': week,
      'updatedBy': updatedBy,
      'updatedByName': updatedByName,
      'changeType': changeType.name,
      'changeDescription': changeDescription,
      'vehicleAssignments': vehicleAssignments
          .map((e) => e.toWebSocketEventData())
          .toList(),
      'vehicleAssignmentId': vehicleAssignmentId,
      'childAssignments': childAssignments
          ?.map((e) => e.toWebSocketEventData())
          .toList(),
      'conflictDetails': conflictDetails,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Check if this is a conflict-related event
  bool get isConflictEvent =>
      eventType == ScheduleEventType.scheduleConflictDetected;

  /// Check if this affects vehicle assignments
  bool get affectsVehicles =>
      vehicleAssignments.isNotEmpty || vehicleAssignmentId != null;

  /// Check if this affects child assignments
  bool get affectsChildren => childAssignments?.isNotEmpty ?? false;

  @override
  List<Object?> get props => [
    eventType,
    scheduleSlotId,
    groupId,
    day,
    time,
    week,
    updatedBy,
    updatedByName,
    changeType,
    changeDescription,
    vehicleAssignments,
    vehicleAssignmentId,
    childAssignments,
    conflictDetails,
    timestamp,
    metadata,
  ];
}

/// Schedule notification event
class ScheduleNotificationEvent extends Equatable {
  final String notificationId;
  final String recipientUserId;
  final ScheduleNotificationType notificationType;
  final String title;
  final String message;
  final String priority;
  final bool actionRequired;
  final String? scheduleSlotId;
  final String? groupId;
  final List<String> affectedChildren;
  final String? conflictId;
  final List<String> affectedSlots;
  final String? reminderType;
  final int? reminderTime;
  final String? deepLink;
  final DateTime timestamp;
  final DateTime? expiresAt;
  final Map<String, dynamic> metadata;

  const ScheduleNotificationEvent({
    required this.notificationId,
    required this.recipientUserId,
    required this.notificationType,
    required this.title,
    required this.message,
    required this.priority,
    required this.actionRequired,
    this.scheduleSlotId,
    this.groupId,
    this.affectedChildren = const [],
    this.conflictId,
    this.affectedSlots = const [],
    this.reminderType,
    this.reminderTime,
    this.deepLink,
    required this.timestamp,
    this.expiresAt,
    this.metadata = const {},
  });

  factory ScheduleNotificationEvent.fromJson(Map<String, dynamic> json) {
    return ScheduleNotificationEvent(
      notificationId: json['notificationId'] as String,
      recipientUserId: json['recipientUserId'] as String,
      notificationType: _parseScheduleNotificationType(
        json['notificationType'] as String?,
      ),
      title: json['title'] as String,
      message: json['message'] as String,
      priority: json['priority'] as String,
      actionRequired: json['actionRequired'] as bool,
      scheduleSlotId: json['scheduleSlotId'] as String?,
      groupId: json['groupId'] as String?,
      affectedChildren:
          (json['affectedChildren'] as List<dynamic>?)?.cast<String>() ?? [],
      conflictId: json['conflictId'] as String?,
      affectedSlots:
          (json['affectedSlots'] as List<dynamic>?)?.cast<String>() ?? [],
      reminderType: json['reminderType'] as String?,
      reminderTime: json['reminderTime'] as int?,
      deepLink: json['deepLink'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'recipientUserId': recipientUserId,
      'notificationType': notificationType.name,
      'title': title,
      'message': message,
      'priority': priority,
      'actionRequired': actionRequired,
      'scheduleSlotId': scheduleSlotId,
      'groupId': groupId,
      'affectedChildren': affectedChildren,
      'conflictId': conflictId,
      'affectedSlots': affectedSlots,
      'reminderType': reminderType,
      'reminderTime': reminderTime,
      'deepLink': deepLink,
      'timestamp': timestamp.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Check if notification is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if this is a conflict notification
  bool get isConflictNotification =>
      notificationType == ScheduleNotificationType.scheduleConflict;

  /// Check if this is a reminder notification
  bool get isReminder =>
      notificationType == ScheduleNotificationType.scheduleReminder;

  /// Check if notification is high priority
  bool get isHighPriority => priority == 'high' || priority == 'critical';

  @override
  List<Object?> get props => [
    notificationId,
    recipientUserId,
    notificationType,
    title,
    message,
    priority,
    actionRequired,
    scheduleSlotId,
    groupId,
    affectedChildren,
    conflictId,
    affectedSlots,
    reminderType,
    reminderTime,
    deepLink,
    timestamp,
    expiresAt,
    metadata,
  ];
}

/// Schedule event types
enum ScheduleEventType {
  scheduleSlotUpdated,
  scheduleConflictDetected,
  childAssignmentUpdated,
  scheduleOptimized,
  schedulePublished,
}

/// Schedule change types
enum ScheduleChangeType {
  vehicleAssigned,
  vehicleRemoved,
  childAssigned,
  childRemoved,
  conflictDetected,
  conflictResolved,
  scheduleOptimized,
}

/// Schedule notification types
enum ScheduleNotificationType {
  scheduleChange,
  scheduleConflict,
  scheduleReminder,
  scheduleApprovalNeeded,
}

/// Helper functions for parsing enums
ScheduleEventType _parseScheduleEventType(String? value) {
  if (value == null) return ScheduleEventType.scheduleSlotUpdated;

  // Convert from snake_case to enum name
  final enumName = value.replaceAll('_', '').toLowerCase();

  switch (enumName) {
    case 'scheduleslotupdated':
      return ScheduleEventType.scheduleSlotUpdated;
    case 'scheduleconflictdetected':
      return ScheduleEventType.scheduleConflictDetected;
    case 'childassignmentupdated':
      return ScheduleEventType.childAssignmentUpdated;
    case 'scheduleoptimized':
      return ScheduleEventType.scheduleOptimized;
    case 'schedulepublished':
      return ScheduleEventType.schedulePublished;
    default:
      return ScheduleEventType.scheduleSlotUpdated;
  }
}

ScheduleChangeType _parseScheduleChangeType(String? value) {
  if (value == null) return ScheduleChangeType.vehicleAssigned;

  // Convert from snake_case to enum name
  final enumName = value.replaceAll('_', '').toLowerCase();

  switch (enumName) {
    case 'vehicleassigned':
      return ScheduleChangeType.vehicleAssigned;
    case 'vehicleremoved':
      return ScheduleChangeType.vehicleRemoved;
    case 'childassigned':
      return ScheduleChangeType.childAssigned;
    case 'childremoved':
      return ScheduleChangeType.childRemoved;
    case 'conflictdetected':
      return ScheduleChangeType.conflictDetected;
    case 'conflictresolved':
      return ScheduleChangeType.conflictResolved;
    case 'scheduleoptimized':
      return ScheduleChangeType.scheduleOptimized;
    default:
      return ScheduleChangeType.vehicleAssigned;
  }
}

ScheduleNotificationType _parseScheduleNotificationType(String? value) {
  if (value == null) return ScheduleNotificationType.scheduleChange;

  // Convert from snake_case to enum name
  final enumName = value.replaceAll('_', '').toLowerCase();

  switch (enumName) {
    case 'schedulechange':
      return ScheduleNotificationType.scheduleChange;
    case 'scheduleconflict':
      return ScheduleNotificationType.scheduleConflict;
    case 'schedulereminder':
      return ScheduleNotificationType.scheduleReminder;
    case 'scheduleapprovalneeded':
      return ScheduleNotificationType.scheduleApprovalNeeded;
    default:
      return ScheduleNotificationType.scheduleChange;
  }
}
