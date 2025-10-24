import '../../../infrastructure/network/websocket/socket_events.dart';
import '../models/vehicle/vehicle_dto.dart';
import '../models/child/child_dto.dart';
import 'websocket_dto_extensions.dart';

/// Base WebSocket event interface
abstract class WebSocketEvent {
  String get eventId;
  DateTime get timestamp;
  Map<String, dynamic> toJson();
}

/// Vehicle management events
class VehicleUpdateEvent implements WebSocketEvent {
  @override
  final String eventId;
  final String vehicleId;
  final VehicleUpdateType updateType;
  final VehicleDto? vehicleData;
  final String? familyId;
  final String? updatedBy;
  @override
  final DateTime timestamp;

  const VehicleUpdateEvent({
    required this.eventId,
    required this.vehicleId,
    required this.updateType,
    this.vehicleData,
    this.familyId,
    this.updatedBy,
    required this.timestamp,
  });

  factory VehicleUpdateEvent.fromJson(Map<String, dynamic> json) {
    return VehicleUpdateEvent(
      eventId: json['eventId'] ?? json['id'] ?? 'unknown',
      vehicleId: json['vehicleId'] ?? json['data']?['vehicleId'] ?? '',
      updateType: VehicleUpdateType.fromString(
        json['updateType'] ?? json['type'] ?? 'updated',
      ),
      vehicleData: json['vehicleData'] != null
          ? VehicleWebSocketExtension.fromWebSocketEventData(
              json['vehicleData'] as Map<String, dynamic>,
            )
          : json['data'] != null
          ? VehicleWebSocketExtension.fromWebSocketEventData(
              json['data'] as Map<String, dynamic>,
            )
          : null,
      familyId: json['familyId'],
      updatedBy: json['updatedBy'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'vehicleId': vehicleId,
      'updateType': updateType.toString(),
      'vehicleData': vehicleData?.toWebSocketEventData(),
      'familyId': familyId,
      'updatedBy': updatedBy,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

enum VehicleUpdateType {
  added,
  updated,
  deleted;

  static VehicleUpdateType fromString(String value) {
    switch (value.toLowerCase()) {
      // Use SocketEvents constants for vehicle events
      case SocketEvents.VEHICLE_ADDED:
        return VehicleUpdateType.added;
      case SocketEvents.VEHICLE_UPDATED:
        return VehicleUpdateType.updated;
      case SocketEvents.VEHICLE_DELETED:
        return VehicleUpdateType.deleted;
      default:
        return VehicleUpdateType.updated;
    }
  }
}

/// User presence events
class PresenceUpdateEvent implements WebSocketEvent {
  @override
  final String eventId;
  final String userId;
  final PresenceStatus status;
  final String? groupId;
  final String? sessionId;
  final Map<String, dynamic>? metadata;
  @override
  final DateTime timestamp;

  const PresenceUpdateEvent({
    required this.eventId,
    required this.userId,
    required this.status,
    this.groupId,
    this.sessionId,
    this.metadata,
    required this.timestamp,
  });

  factory PresenceUpdateEvent.fromJson(Map<String, dynamic> json) {
    return PresenceUpdateEvent(
      eventId: json['eventId'] ?? json['id'] ?? 'unknown',
      userId: json['userId'] ?? json['data']?['userId'] ?? '',
      status: PresenceStatus.fromString(
        json['status'] ?? json['type'] ?? 'online',
      ),
      groupId: json['groupId'],
      sessionId: json['sessionId'],
      metadata: json['metadata'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'userId': userId,
      'status': status.toString(),
      'groupId': groupId,
      'sessionId': sessionId,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

enum PresenceStatus {
  joined,
  left,
  online,
  offline;

  static PresenceStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'joined':
      case SocketEvents.USER_JOINED:
        return PresenceStatus.joined;
      case 'left':
      case SocketEvents.USER_LEFT:
        return PresenceStatus.left;
      case 'online':
        return PresenceStatus.online;
      case 'offline':
        return PresenceStatus.offline;
      default:
        return PresenceStatus.online;
    }
  }
}

/// Typing indicator events
class TypingIndicatorEvent implements WebSocketEvent {
  @override
  final String eventId;
  final String userId;
  final String userName;
  final String? groupId;
  final String? chatId;
  final TypingState state;
  @override
  final DateTime timestamp;

  const TypingIndicatorEvent({
    required this.eventId,
    required this.userId,
    required this.userName,
    this.groupId,
    this.chatId,
    required this.state,
    required this.timestamp,
  });

  factory TypingIndicatorEvent.fromJson(Map<String, dynamic> json) {
    return TypingIndicatorEvent(
      eventId: json['eventId'] ?? json['id'] ?? 'unknown',
      userId: json['userId'] ?? json['data']?['userId'] ?? '',
      userName: json['userName'] ?? json['data']?['userName'] ?? 'Unknown User',
      groupId: json['groupId'],
      chatId: json['chatId'],
      state: TypingState.fromString(json['state'] ?? json['type'] ?? 'typing'),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'userId': userId,
      'userName': userName,
      'groupId': groupId,
      'chatId': chatId,
      'state': state.toString(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

enum TypingState {
  typing,
  stoppedTyping;

  static TypingState fromString(String value) {
    switch (value.toLowerCase()) {
      case SocketEvents.USER_TYPING:
        return TypingState.typing;
      case SocketEvents.USER_STOPPED_TYPING:
        return TypingState.stoppedTyping;
      default:
        return TypingState.typing;
    }
  }
}

/// Group management events
class GroupUpdateEvent implements WebSocketEvent {
  @override
  final String eventId;
  final String groupId;
  final GroupUpdateType updateType;
  final Map<String, dynamic> groupData;
  final String? updatedBy;
  final List<String>? affectedMembers;
  @override
  final DateTime timestamp;

  const GroupUpdateEvent({
    required this.eventId,
    required this.groupId,
    required this.updateType,
    required this.groupData,
    this.updatedBy,
    this.affectedMembers,
    required this.timestamp,
  });

  factory GroupUpdateEvent.fromJson(Map<String, dynamic> json) {
    return GroupUpdateEvent(
      eventId: json['eventId'] ?? json['id'] ?? 'unknown',
      groupId: json['groupId'] ?? json['data']?['groupId'] ?? '',
      updateType: GroupUpdateType.fromString(
        json['updateType'] ?? json['type'] ?? 'updated',
      ),
      groupData: json['groupData'] ?? json['data'] ?? {},
      updatedBy: json['updatedBy'],
      affectedMembers: (json['affectedMembers'] as List<dynamic>?)
          ?.cast<String>(),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'groupId': groupId,
      'updateType': updateType.toString(),
      'groupData': groupData,
      'updatedBy': updatedBy,
      'affectedMembers': affectedMembers,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

enum GroupUpdateType {
  join,
  leave,
  updated;

  static GroupUpdateType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'join':
      case SocketEvents.GROUP_JOIN:
        return GroupUpdateType.join;
      case 'leave':
      case SocketEvents.GROUP_LEAVE:
        return GroupUpdateType.leave;
      case 'updated':
      case SocketEvents.GROUP_UPDATED:
        return GroupUpdateType.updated;
      default:
        return GroupUpdateType.updated;
    }
  }
}

/// Membership events
class MembershipEvent implements WebSocketEvent {
  @override
  final String eventId;
  final String groupId;
  final String memberId;
  final String memberName;
  final MembershipAction action;
  final String? role;
  final Map<String, dynamic>? memberData;
  @override
  final DateTime timestamp;

  const MembershipEvent({
    required this.eventId,
    required this.groupId,
    required this.memberId,
    required this.memberName,
    required this.action,
    this.role,
    this.memberData,
    required this.timestamp,
  });

  factory MembershipEvent.fromJson(Map<String, dynamic> json) {
    return MembershipEvent(
      eventId: json['eventId'] ?? json['id'] ?? 'unknown',
      groupId: json['groupId'] ?? json['data']?['groupId'] ?? '',
      memberId: json['memberId'] ?? json['data']?['memberId'] ?? '',
      memberName:
          json['memberName'] ?? json['data']?['memberName'] ?? 'Unknown Member',
      action: MembershipAction.fromString(
        json['action'] ?? json['type'] ?? 'joined',
      ),
      role: json['role'],
      memberData: json['memberData'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'groupId': groupId,
      'memberId': memberId,
      'memberName': memberName,
      'action': action.toString(),
      'role': role,
      'memberData': memberData,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

enum MembershipAction {
  joined,
  left;

  static MembershipAction fromString(String value) {
    switch (value.toLowerCase()) {
      case 'joined':
      case SocketEvents.MEMBER_JOINED:
        return MembershipAction.joined;
      case 'left':
      case SocketEvents.MEMBER_LEFT:
        return MembershipAction.left;
      default:
        return MembershipAction.joined;
    }
  }
}

/// Connection status events
class ConnectionStatusEvent implements WebSocketEvent {
  @override
  final String eventId;
  final ConnectionState state;
  final String? reason;
  final Map<String, dynamic>? metadata;
  @override
  final DateTime timestamp;

  const ConnectionStatusEvent({
    required this.eventId,
    required this.state,
    this.reason,
    this.metadata,
    required this.timestamp,
  });

  factory ConnectionStatusEvent.fromJson(Map<String, dynamic> json) {
    return ConnectionStatusEvent(
      eventId: json['eventId'] ?? json['id'] ?? 'unknown',
      state: ConnectionState.fromString(
        json['state'] ?? json['type'] ?? 'connected',
      ),
      reason: json['reason'],
      metadata: json['metadata'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'state': state.toString(),
      'reason': reason,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

enum ConnectionState {
  connected,
  disconnected,
  reconnecting,
  error;

  static ConnectionState fromString(String value) {
    switch (value.toLowerCase()) {
      case 'connected':
        return ConnectionState.connected;
      case 'disconnected':
        return ConnectionState.disconnected;
      case 'reconnecting':
        return ConnectionState.reconnecting;
      case 'error':
        return ConnectionState.error;
      default:
        return ConnectionState.connected;
    }
  }
}

/// Heartbeat events
class HeartbeatEvent implements WebSocketEvent {
  @override
  final String eventId;
  final HeartbeatType type;
  final int? latency;
  final String? serverId;
  final Map<String, dynamic>? serverStats;
  @override
  final DateTime timestamp;

  const HeartbeatEvent({
    required this.eventId,
    required this.type,
    this.latency,
    this.serverId,
    this.serverStats,
    required this.timestamp,
  });

  factory HeartbeatEvent.fromJson(Map<String, dynamic> json) {
    return HeartbeatEvent(
      eventId: json['eventId'] ?? json['id'] ?? 'unknown',
      type: HeartbeatType.fromString(json['type'] ?? 'ping'),
      latency: json['latency'],
      serverId: json['serverId'],
      serverStats: json['serverStats'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'type': type.toString(),
      'latency': latency,
      'serverId': serverId,
      'serverStats': serverStats,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

enum HeartbeatType {
  ping,
  pong;

  static HeartbeatType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'ping':
      case 'heartbeat':
        return HeartbeatType.ping;
      case 'pong':
      case 'heartbeat-ack':
        return HeartbeatType.pong;
      default:
        return HeartbeatType.ping;
    }
  }
}

/// System notification events
class SystemNotificationEvent implements WebSocketEvent {
  @override
  final String eventId;
  final String notificationId;
  final String title;
  final String message;
  final NotificationPriority priority;
  final String? category;
  final String? targetUserId;
  final String? actionUrl;
  final Map<String, dynamic>? data;
  @override
  final DateTime timestamp;

  const SystemNotificationEvent({
    required this.eventId,
    required this.notificationId,
    required this.title,
    required this.message,
    required this.priority,
    this.category,
    this.targetUserId,
    this.actionUrl,
    this.data,
    required this.timestamp,
  });

  factory SystemNotificationEvent.fromJson(Map<String, dynamic> json) {
    return SystemNotificationEvent(
      eventId: json['eventId'] ?? json['id'] ?? 'unknown',
      notificationId:
          json['notificationId'] ?? json['data']?['notificationId'] ?? '',
      title: json['title'] ?? json['data']?['title'] ?? 'System Notification',
      message: json['message'] ?? json['data']?['message'] ?? '',
      priority: NotificationPriority.fromString(json['priority'] ?? 'medium'),
      category: json['category'],
      targetUserId: json['targetUserId'],
      actionUrl: json['actionUrl'],
      data: json['data'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'notificationId': notificationId,
      'title': title,
      'message': message,
      'priority': priority.toString(),
      'category': category,
      'targetUserId': targetUserId,
      'actionUrl': actionUrl,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

enum NotificationPriority {
  low,
  medium,
  high,
  critical;

  static NotificationPriority fromString(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return NotificationPriority.low;
      case 'medium':
        return NotificationPriority.medium;
      case 'high':
        return NotificationPriority.high;
      case 'critical':
        return NotificationPriority.critical;
      default:
        return NotificationPriority.medium;
    }
  }
}

/// System error events
class SystemErrorEvent implements WebSocketEvent {
  @override
  final String eventId;
  final String errorCode;
  final String errorMessage;
  final ErrorSeverity? severity;
  final String? stackTrace;
  final Map<String, dynamic>? context;
  @override
  final DateTime timestamp;

  const SystemErrorEvent({
    required this.eventId,
    required this.errorCode,
    required this.errorMessage,
    this.severity,
    this.stackTrace,
    this.context,
    required this.timestamp,
  });

  factory SystemErrorEvent.fromJson(Map<String, dynamic> json) {
    return SystemErrorEvent(
      eventId: json['eventId'] ?? json['id'] ?? 'unknown',
      errorCode: json['errorCode'] ?? json['code'] ?? SocketEvents.ERROR,
      errorMessage:
          json['errorMessage'] ?? json['message'] ?? 'Unknown error occurred',
      severity: json['severity'] != null
          ? ErrorSeverity.fromString(json['severity'])
          : null,
      stackTrace: json['stackTrace'],
      context: json['context'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'errorCode': errorCode,
      'errorMessage': errorMessage,
      'severity': severity?.toString(),
      'stackTrace': stackTrace,
      'context': context,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

enum ErrorSeverity {
  warning,
  error,
  critical;

  static ErrorSeverity fromString(String value) {
    switch (value.toLowerCase()) {
      case 'warning':
        return ErrorSeverity.warning;
      case 'error':
        return ErrorSeverity.error;
      case 'critical':
        return ErrorSeverity.critical;
      default:
        return ErrorSeverity.error;
    }
  }
}

/// Schedule subscription events
class ScheduleSubscriptionEvent implements WebSocketEvent {
  @override
  final String eventId;
  final String scheduleId;
  final SubscriptionAction action;
  final String? userId;
  final String? groupId;
  final Map<String, dynamic>? subscriptionData;
  @override
  final DateTime timestamp;

  const ScheduleSubscriptionEvent({
    required this.eventId,
    required this.scheduleId,
    required this.action,
    this.userId,
    this.groupId,
    this.subscriptionData,
    required this.timestamp,
  });

  factory ScheduleSubscriptionEvent.fromJson(Map<String, dynamic> json) {
    return ScheduleSubscriptionEvent(
      eventId: json['eventId'] ?? json['id'] ?? 'unknown',
      scheduleId: json['scheduleId'] ?? json['data']?['scheduleId'] ?? '',
      action: SubscriptionAction.fromString(
        json['action'] ?? json['type'] ?? 'subscribe',
      ),
      userId: json['userId'],
      groupId: json['groupId'],
      subscriptionData: json['subscriptionData'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'scheduleId': scheduleId,
      'action': action.toString(),
      'userId': userId,
      'groupId': groupId,
      'subscriptionData': subscriptionData,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

enum SubscriptionAction {
  subscribe,
  unsubscribe;

  static SubscriptionAction fromString(String value) {
    switch (value.toLowerCase()) {
      case 'subscribe':
      case SocketEvents.SCHEDULE_SUBSCRIBE:
        return SubscriptionAction.subscribe;
      case 'unsubscribe':
      case SocketEvents.SCHEDULE_UNSUBSCRIBE:
        return SubscriptionAction.unsubscribe;
      default:
        return SubscriptionAction.subscribe;
    }
  }
}

/// Real-time collaboration events
class CollaborationEvent implements WebSocketEvent {
  @override
  final String eventId;
  final String scheduleSlotId;
  final String userId;
  final String userName;
  final CollaborationAction action;
  final Map<String, dynamic>? actionData;
  @override
  final DateTime timestamp;

  const CollaborationEvent({
    required this.eventId,
    required this.scheduleSlotId,
    required this.userId,
    required this.userName,
    required this.action,
    this.actionData,
    required this.timestamp,
  });

  factory CollaborationEvent.fromJson(Map<String, dynamic> json) {
    return CollaborationEvent(
      eventId: json['eventId'] ?? json['id'] ?? 'unknown',
      scheduleSlotId:
          json['scheduleSlotId'] ?? json['data']?['scheduleSlotId'] ?? '',
      userId: json['userId'] ?? json['data']?['userId'] ?? '',
      userName: json['userName'] ?? json['data']?['userName'] ?? 'Unknown User',
      action: CollaborationAction.fromString(
        json['action'] ?? json['type'] ?? 'join',
      ),
      actionData: json['actionData'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'scheduleSlotId': scheduleSlotId,
      'userId': userId,
      'userName': userName,
      'action': action.toString(),
      'actionData': actionData,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

enum CollaborationAction {
  join,
  leave,
  edit,
  lock,
  unlock;

  static CollaborationAction fromString(String value) {
    switch (value.toLowerCase()) {
      case 'join':
      case SocketEvents.SCHEDULE_SLOT_JOIN:
        return CollaborationAction.join;
      case 'leave':
      case SocketEvents.SCHEDULE_SLOT_LEAVE:
        return CollaborationAction.leave;
      case 'edit':
        return CollaborationAction.edit;
      case 'lock':
        return CollaborationAction.lock;
      case 'unlock':
        return CollaborationAction.unlock;
      default:
        return CollaborationAction.join;
    }
  }
}

/// Child management events
class ChildUpdateEvent implements WebSocketEvent {
  @override
  final String eventId;
  final String childId;
  final ChildUpdateType updateType;
  final ChildDto? childData;
  final String? familyId;
  final String? updatedBy;
  @override
  final DateTime timestamp;

  const ChildUpdateEvent({
    required this.eventId,
    required this.childId,
    required this.updateType,
    this.childData,
    this.familyId,
    this.updatedBy,
    required this.timestamp,
  });

  factory ChildUpdateEvent.fromJson(Map<String, dynamic> json) {
    return ChildUpdateEvent(
      eventId: json['eventId'] ?? json['id'] ?? 'unknown',
      childId: json['childId'] ?? json['data']?['childId'] ?? '',
      updateType: ChildUpdateType.fromString(
        json['updateType'] ?? json['type'] ?? 'updated',
      ),
      childData: json['childData'] != null
          ? ChildWebSocketExtension.fromWebSocketEventData(
              json['childData'] as Map<String, dynamic>,
            )
          : json['data'] != null
          ? ChildWebSocketExtension.fromWebSocketEventData(
              json['data'] as Map<String, dynamic>,
            )
          : null,
      familyId: json['familyId'],
      updatedBy: json['updatedBy'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'childId': childId,
      'updateType': updateType.toString(),
      'childData': childData?.toWebSocketEventData(),
      'familyId': familyId,
      'updatedBy': updatedBy,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

enum ChildUpdateType {
  added,
  updated,
  deleted;

  static ChildUpdateType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'added':
      case SocketEvents.CHILD_ADDED:
        return ChildUpdateType.added;
      case 'updated':
      case SocketEvents.CHILD_UPDATED:
        return ChildUpdateType.updated;
      case 'deleted':
      case SocketEvents.CHILD_DELETED:
        return ChildUpdateType.deleted;
      default:
        return ChildUpdateType.updated;
    }
  }
}

/// Family management events
class FamilyUpdateEvent implements WebSocketEvent {
  @override
  final String eventId;
  final String? familyId;
  final FamilyUpdateType updateType;
  final Map<String, dynamic> familyData;
  final String? memberId;
  final String? memberName;
  final String? updatedBy;
  @override
  final DateTime timestamp;

  const FamilyUpdateEvent({
    required this.eventId,
    this.familyId,
    required this.updateType,
    this.familyData = const {},
    this.memberId,
    this.memberName,
    this.updatedBy,
    required this.timestamp,
  });

  factory FamilyUpdateEvent.fromJson(Map<String, dynamic> json) {
    return FamilyUpdateEvent(
      eventId: json['eventId'] ?? json['id'] ?? 'unknown',
      familyId: json['familyId'] ?? json['data']?['familyId'],
      updateType: FamilyUpdateType.fromString(
        json['updateType'] ?? json['type'] ?? 'updated',
      ),
      familyData: json['familyData'] ?? json['data'] ?? {},
      memberId: json['memberId'] ?? json['data']?['memberId'],
      memberName: json['memberName'] ?? json['data']?['memberName'],
      updatedBy: json['updatedBy'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'familyId': familyId,
      'updateType': updateType.toString(),
      'familyData': familyData,
      'memberId': memberId,
      'memberName': memberName,
      'updatedBy': updatedBy,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

enum FamilyUpdateType {
  updated,
  memberJoined,
  memberLeft,
  childAdded,
  childUpdated,
  childDeleted;

  static FamilyUpdateType fromString(String value) {
    switch (value.toLowerCase()) {
      case SocketEvents.FAMILY_UPDATED:
        return FamilyUpdateType.updated;
      case SocketEvents.FAMILY_MEMBER_JOINED:
        return FamilyUpdateType.memberJoined;
      case SocketEvents.FAMILY_MEMBER_LEFT:
        return FamilyUpdateType.memberLeft;
      case SocketEvents.CHILD_ADDED:
        return FamilyUpdateType.childAdded;
      case SocketEvents.CHILD_UPDATED:
        return FamilyUpdateType.childUpdated;
      case SocketEvents.CHILD_DELETED:
        return FamilyUpdateType.childDeleted;
      default:
        return FamilyUpdateType.updated;
    }
  }
}

/// Notification events
class NotificationEvent implements WebSocketEvent {
  @override
  final String eventId;
  final String notificationId;
  final String title;
  final String message;
  final NotificationPriority priority;
  final String? category;
  final String? targetUserId;
  final String? targetGroupId;
  final String? actionUrl;
  final Map<String, dynamic>? data;
  @override
  final DateTime timestamp;

  const NotificationEvent({
    required this.eventId,
    required this.notificationId,
    required this.title,
    required this.message,
    required this.priority,
    this.category,
    this.targetUserId,
    this.targetGroupId,
    this.actionUrl,
    this.data,
    required this.timestamp,
  });

  factory NotificationEvent.fromJson(Map<String, dynamic> json) {
    return NotificationEvent(
      eventId: json['eventId'] ?? json['id'] ?? 'unknown',
      notificationId:
          json['notificationId'] ?? json['data']?['notificationId'] ?? '',
      title: json['title'] ?? json['data']?['title'] ?? 'Notification',
      message: json['message'] ?? json['data']?['message'] ?? '',
      priority: NotificationPriority.fromString(json['priority'] ?? 'medium'),
      category: json['category'],
      targetUserId: json['targetUserId'],
      targetGroupId: json['targetGroupId'],
      actionUrl: json['actionUrl'],
      data: json['data'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'notificationId': notificationId,
      'title': title,
      'message': message,
      'priority': priority.toString(),
      'category': category,
      'targetUserId': targetUserId,
      'targetGroupId': targetGroupId,
      'actionUrl': actionUrl,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Conflict detection events
class ConflictEvent implements WebSocketEvent {
  @override
  final String eventId;
  final String conflictId;
  final ConflictType conflictType;
  final ConflictSeverity severity;
  final String description;
  final String? scheduleSlotId;
  final String? groupId;
  final List<String>? affectedUsers;
  final Map<String, dynamic> conflictData;
  final String? suggestedResolution;
  @override
  final DateTime timestamp;

  const ConflictEvent({
    required this.eventId,
    required this.conflictId,
    required this.conflictType,
    required this.severity,
    required this.description,
    this.scheduleSlotId,
    this.groupId,
    this.affectedUsers,
    required this.conflictData,
    this.suggestedResolution,
    required this.timestamp,
  });

  factory ConflictEvent.fromJson(Map<String, dynamic> json) {
    return ConflictEvent(
      eventId: json['eventId'] ?? json['id'] ?? 'unknown',
      conflictId: json['conflictId'] ?? json['data']?['conflictId'] ?? '',
      conflictType: ConflictType.fromString(
        json['conflictType'] ?? json['type'] ?? 'schedule',
      ),
      severity: ConflictSeverity.fromString(json['severity'] ?? 'medium'),
      description:
          json['description'] ?? json['message'] ?? 'Conflict detected',
      scheduleSlotId: json['scheduleSlotId'],
      groupId: json['groupId'],
      affectedUsers: (json['affectedUsers'] as List<dynamic>?)?.cast<String>(),
      conflictData: json['conflictData'] ?? json['data'] ?? {},
      suggestedResolution: json['suggestedResolution'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'conflictId': conflictId,
      'conflictType': conflictType.toString(),
      'severity': severity.toString(),
      'description': description,
      'scheduleSlotId': scheduleSlotId,
      'groupId': groupId,
      'affectedUsers': affectedUsers,
      'conflictData': conflictData,
      'suggestedResolution': suggestedResolution,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

enum ConflictType {
  schedule,
  resource,
  capacity,
  permission;

  static ConflictType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'schedule':
      case SocketEvents.SCHEDULE_CONFLICT: // Modern format
        return ConflictType.schedule;
      case 'resource':
      case SocketEvents.DRIVER_DOUBLE_BOOKING: // Modern format
      case SocketEvents.VEHICLE_DOUBLE_BOOKING: // Modern format
        return ConflictType.resource;
      case 'capacity':
      case SocketEvents.CAPACITY_EXCEEDED: // Modern format
        return ConflictType.capacity;
      case 'permission':
        return ConflictType.permission;
      default:
        return ConflictType.schedule;
    }
  }
}

enum ConflictSeverity {
  low,
  medium,
  high,
  critical;

  static ConflictSeverity fromString(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return ConflictSeverity.low;
      case 'medium':
        return ConflictSeverity.medium;
      case 'high':
        return ConflictSeverity.high;
      case 'critical':
        return ConflictSeverity.critical;
      default:
        return ConflictSeverity.medium;
    }
  }
}
