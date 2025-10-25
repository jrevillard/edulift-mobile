// EduLift Mobile - WebSocket Invitation Events
// Real-time invitation system event handling

import 'package:equatable/equatable.dart';
import '../models/websocket/websocket_dto.dart';
import '../../../infrastructure/network/websocket/socket_events.dart';

/// Invitation event types
enum InvitationEventType {
  received,
  accepted,
  declined,
  expired,
  cancelled,
  updated,
}

/// Family invitation event from WebSocket
class FamilyInvitationEvent extends Equatable {
  final String invitationId;
  final String familyId;
  final String? familyName;
  final String? invitedBy;
  final String? acceptedBy;
  final String? declinedBy;
  final String? role;
  final String? personalMessage;
  final String? declineReason;
  final InvitationEventType eventType;
  final InvitationTypeDto invitationType = InvitationTypeDto.family;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  const FamilyInvitationEvent({
    required this.invitationId,
    required this.familyId,
    this.familyName,
    this.invitedBy,
    this.acceptedBy,
    this.declinedBy,
    this.role,
    this.personalMessage,
    this.declineReason,
    required this.eventType,
    required this.timestamp,
    this.data,
  });

  factory FamilyInvitationEvent.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    InvitationEventType eventType;

    switch (type) {
      case SocketEvents.FAMILY_INVITATION_RECEIVED:
        eventType = InvitationEventType.received;
        break;
      case SocketEvents.FAMILY_INVITATION_ACCEPTED:
        eventType = InvitationEventType.accepted;
        break;
      case SocketEvents.FAMILY_INVITATION_DECLINED:
        eventType = InvitationEventType.declined;
        break;
      case SocketEvents.FAMILY_INVITATION_EXPIRED:
        eventType = InvitationEventType.expired;
        break;
      case SocketEvents.FAMILY_INVITATION_CANCELLED:
        eventType = InvitationEventType.cancelled;
        break;
      case SocketEvents.FAMILY_INVITATION_UPDATED:
        eventType = InvitationEventType.updated;
        break;
      default:
        eventType = InvitationEventType.updated;
    }

    return FamilyInvitationEvent(
      invitationId: json['invitationId'] as String,
      familyId: json['familyId'] as String,
      familyName: json['familyName'] as String?,
      invitedBy: json['invitedBy'] as String?,
      acceptedBy: json['acceptedBy'] as String?,
      declinedBy: json['declinedBy'] as String?,
      role: json['role'] as String?,
      personalMessage: json['personalMessage'] as String?,
      declineReason: json['reason'] as String?,
      eventType: eventType,
      timestamp: DateTime.parse(json['timestamp'] as String),
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [
    invitationId,
    familyId,
    familyName,
    invitedBy,
    acceptedBy,
    declinedBy,
    role,
    personalMessage,
    declineReason,
    eventType,
    timestamp,
    data,
  ];
}

/// Group invitation event from WebSocket
class GroupInvitationEvent extends Equatable {
  final String invitationId;
  final String groupId;
  final String? groupName;
  final String? targetFamilyId;
  final String? invitedBy;
  final String? acceptedBy;
  final String? role;
  final String? personalMessage;
  final int? membersAdded;
  final InvitationEventType eventType;
  final InvitationTypeDto invitationType = InvitationTypeDto.group;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  const GroupInvitationEvent({
    required this.invitationId,
    required this.groupId,
    this.groupName,
    this.targetFamilyId,
    this.invitedBy,
    this.acceptedBy,
    this.role,
    this.personalMessage,
    this.membersAdded,
    required this.eventType,
    required this.timestamp,
    this.data,
  });

  factory GroupInvitationEvent.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    InvitationEventType eventType;

    switch (type) {
      case SocketEvents.GROUP_INVITATION_RECEIVED:
        eventType = InvitationEventType.received;
        break;
      case SocketEvents.GROUP_INVITATION_ACCEPTED:
        eventType = InvitationEventType.accepted;
        break;
      case SocketEvents.GROUP_INVITATION_DECLINED:
        eventType = InvitationEventType.declined;
        break;
      case SocketEvents.GROUP_INVITATION_EXPIRED:
        eventType = InvitationEventType.expired;
        break;
      case SocketEvents.GROUP_INVITATION_CANCELLED:
        eventType = InvitationEventType.cancelled;
        break;
      case SocketEvents.GROUP_INVITATION_UPDATED:
        eventType = InvitationEventType.updated;
        break;
      default:
        eventType = InvitationEventType.updated;
    }

    return GroupInvitationEvent(
      invitationId: json['invitationId'] as String,
      groupId: json['groupId'] as String,
      groupName: json['groupName'] as String?,
      targetFamilyId: json['targetFamilyId'] as String?,
      invitedBy: json['invitedBy'] as String?,
      acceptedBy: json['acceptedBy'] as String?,
      role: json['role'] as String?,
      personalMessage: json['personalMessage'] as String?,
      membersAdded: json['membersAdded'] as int?,
      eventType: eventType,
      timestamp: DateTime.parse(json['timestamp'] as String),
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [
    invitationId,
    groupId,
    groupName,
    targetFamilyId,
    invitedBy,
    acceptedBy,
    role,
    personalMessage,
    membersAdded,
    eventType,
    timestamp,
    data,
  ];
}

/// Invitation notification event from WebSocket
class InvitationNotificationEvent extends Equatable {
  final String notificationId;
  final String invitationId;
  final InvitationTypeDto invitationType;
  final String title;
  final String message;
  final String priority;
  final bool actionRequired;
  final bool isReminder;
  final String? deepLink;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  const InvitationNotificationEvent({
    required this.notificationId,
    required this.invitationId,
    required this.invitationType,
    required this.title,
    required this.message,
    required this.priority,
    required this.actionRequired,
    this.isReminder = false,
    this.deepLink,
    required this.timestamp,
    this.data,
  });

  factory InvitationNotificationEvent.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    final invitationTypeStr = json['invitationType'] as String;

    InvitationTypeDto invitationType;
    switch (invitationTypeStr) {
      case 'family':
        invitationType = InvitationTypeDto.family;
        break;
      case 'group':
        invitationType = InvitationTypeDto.group;
        break;
      default:
        invitationType = InvitationTypeDto.family;
    }

    return InvitationNotificationEvent(
      notificationId: json['notificationId'] as String,
      invitationId: json['invitationId'] as String,
      invitationType: invitationType,
      title: json['title'] as String,
      message: json['message'] as String,
      priority: json['priority'] as String? ?? 'medium',
      actionRequired: json['actionRequired'] as bool? ?? false,
      isReminder: type == SocketEvents.INVITATION_REMINDER,
      deepLink: json['data']?['deepLink'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [
    notificationId,
    invitationId,
    invitationType,
    title,
    message,
    priority,
    actionRequired,
    isReminder,
    deepLink,
    timestamp,
    data,
  ];
}

/// Invitation status update event from WebSocket
class InvitationStatusUpdateEvent extends Equatable {
  final String invitationId;
  final InvitationStatusDto oldStatus;
  final InvitationStatusDto newStatus;
  final String? updatedBy;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const InvitationStatusUpdateEvent({
    required this.invitationId,
    required this.oldStatus,
    required this.newStatus,
    this.updatedBy,
    required this.timestamp,
    this.metadata,
  });

  factory InvitationStatusUpdateEvent.fromJson(Map<String, dynamic> json) {
    return InvitationStatusUpdateEvent(
      invitationId: json['invitationId'] as String,
      oldStatus: InvitationStatusDto.values.firstWhere(
        (e) => e.name == json['oldStatus'],
        orElse: () => InvitationStatusDto.pending,
      ),
      newStatus: InvitationStatusDto.values.firstWhere(
        (e) => e.name == json['newStatus'],
        orElse: () => InvitationStatusDto.pending,
      ),
      updatedBy: json['updatedBy'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [
    invitationId,
    oldStatus,
    newStatus,
    updatedBy,
    timestamp,
    metadata,
  ];
}
