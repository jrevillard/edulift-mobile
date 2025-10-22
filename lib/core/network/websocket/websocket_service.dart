import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import '../../../core/services/adaptive_storage_service.dart';
import '../../../core/config/base_config.dart';
import '../api_endpoints.dart';
import '../../../core/network/websocket/websocket_invitation_events.dart';
import 'websocket_schedule_events.dart';
import '../models/websocket/websocket_dto.dart';
import '../../../infrastructure/network/websocket/socket_events.dart';
import 'websocket_event_models.dart';

/// Real-time WebSocket service for live updates and collaboration
/// Implements reconnection logic and conflict detection

class WebSocketService {
  final AdaptiveStorageService _secureStorage;
  final BaseConfig _config;

  WebSocketService(this._secureStorage, this._config);
  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;

  bool _isConnected = false;
  bool _isReconnecting = false;
  int _reconnectAttempts = 0;

  static const int maxReconnectAttempts = 5;
  static const Duration reconnectDelay = Duration(seconds: 3);
  static const Duration heartbeatInterval = Duration(seconds: 30);

  // Stream controllers for different event types
  final StreamController<FamilyUpdateEvent> _familyUpdatesController =
      StreamController<FamilyUpdateEvent>.broadcast();
  final StreamController<GroupUpdateEvent> _groupUpdatesController =
      StreamController<GroupUpdateEvent>.broadcast();
  final StreamController<ScheduleUpdateEvent> _scheduleUpdatesController =
      StreamController<ScheduleUpdateEvent>.broadcast();
  final StreamController<ConflictEvent> _conflictController =
      StreamController<ConflictEvent>.broadcast();
  final StreamController<NotificationEvent> _notificationController =
      StreamController<NotificationEvent>.broadcast();
  final StreamController<ConnectionStatus> _connectionStatusController =
      StreamController<ConnectionStatus>.broadcast();

  // Invitation-specific stream controllers
  final StreamController<FamilyInvitationEvent> _familyInvitationController =
      StreamController<FamilyInvitationEvent>.broadcast();
  final StreamController<GroupInvitationEvent> _groupInvitationController =
      StreamController<GroupInvitationEvent>.broadcast();
  final StreamController<InvitationNotificationEvent>
  _invitationNotificationController =
      StreamController<InvitationNotificationEvent>.broadcast();
  final StreamController<InvitationStatusUpdateEvent>
  _invitationStatusUpdateController =
      StreamController<InvitationStatusUpdateEvent>.broadcast();

  // Schedule-specific stream controllers
  final StreamController<ScheduleUpdateEvent> _scheduleUpdateController =
      StreamController<ScheduleUpdateEvent>.broadcast();
  final StreamController<ScheduleNotificationEvent>
  _scheduleNotificationController =
      StreamController<ScheduleNotificationEvent>.broadcast();

  // NEW: Vehicle Management Controllers
  final StreamController<VehicleUpdateEvent> _vehicleUpdatesController =
      StreamController<VehicleUpdateEvent>.broadcast();

  // NEW: User Presence Controllers
  final StreamController<PresenceUpdateEvent> _presenceUpdatesController =
      StreamController<PresenceUpdateEvent>.broadcast();
  final StreamController<TypingIndicatorEvent> _typingIndicatorController =
      StreamController<TypingIndicatorEvent>.broadcast();

  // NEW: Enhanced Group Management Controllers (keeping existing one for compatibility)
  final StreamController<MembershipEvent> _membershipController =
      StreamController<MembershipEvent>.broadcast();

  // NEW: System Events Controllers
  final StreamController<ConnectionStatusEvent>
  _enhancedConnectionStatusController =
      StreamController<ConnectionStatusEvent>.broadcast();
  final StreamController<HeartbeatEvent> _heartbeatController =
      StreamController<HeartbeatEvent>.broadcast();
  final StreamController<SystemNotificationEvent>
  _systemNotificationController =
      StreamController<SystemNotificationEvent>.broadcast();
  final StreamController<SystemErrorEvent> _systemErrorController =
      StreamController<SystemErrorEvent>.broadcast();

  // NEW: Schedule Subscription Controllers
  final StreamController<ScheduleSubscriptionEvent>
  _scheduleSubscriptionController =
      StreamController<ScheduleSubscriptionEvent>.broadcast();
  final StreamController<CollaborationEvent> _collaborationController =
      StreamController<CollaborationEvent>.broadcast();

  // NEW: Child Management Controllers
  final StreamController<ChildUpdateEvent> _childUpdatesController =
      StreamController<ChildUpdateEvent>.broadcast();

  // Public streams
  Stream<FamilyUpdateEvent> get familyUpdates =>
      _familyUpdatesController.stream;
  Stream<GroupUpdateEvent> get groupUpdates => _groupUpdatesController.stream;
  Stream<ScheduleUpdateEvent> get scheduleUpdates =>
      _scheduleUpdatesController.stream;
  Stream<ConflictEvent> get conflicts => _conflictController.stream;
  Stream<NotificationEvent> get notifications => _notificationController.stream;
  Stream<ConnectionStatus> get connectionStatus =>
      _connectionStatusController.stream;

  // Invitation-specific public streams
  Stream<FamilyInvitationEvent> get familyInvitationEvents =>
      _familyInvitationController.stream;
  Stream<GroupInvitationEvent> get groupInvitationEvents =>
      _groupInvitationController.stream;
  Stream<InvitationNotificationEvent> get invitationNotificationEvents =>
      _invitationNotificationController.stream;
  Stream<InvitationStatusUpdateEvent> get invitationStatusUpdateEvents =>
      _invitationStatusUpdateController.stream;

  // Schedule-specific public streams
  Stream<ScheduleUpdateEvent> get scheduleUpdateEvents =>
      _scheduleUpdateController.stream;
  Stream<ScheduleNotificationEvent> get scheduleNotificationEvents =>
      _scheduleNotificationController.stream;

  // NEW: Vehicle Management Streams
  Stream<VehicleUpdateEvent> get vehicleUpdates =>
      _vehicleUpdatesController.stream;

  // NEW: User Presence Streams
  Stream<PresenceUpdateEvent> get presenceUpdates =>
      _presenceUpdatesController.stream;
  Stream<TypingIndicatorEvent> get typingIndicator =>
      _typingIndicatorController.stream;

  // NEW: Enhanced Group Membership Streams
  Stream<MembershipEvent> get membershipEvents => _membershipController.stream;

  // NEW: System Event Streams
  Stream<ConnectionStatusEvent> get enhancedConnectionStatus =>
      _enhancedConnectionStatusController.stream;
  Stream<HeartbeatEvent> get heartbeat => _heartbeatController.stream;
  Stream<SystemNotificationEvent> get systemNotifications =>
      _systemNotificationController.stream;
  Stream<SystemErrorEvent> get systemErrors => _systemErrorController.stream;

  // NEW: Schedule Subscription Streams
  Stream<ScheduleSubscriptionEvent> get scheduleSubscriptions =>
      _scheduleSubscriptionController.stream;
  Stream<CollaborationEvent> get collaboration =>
      _collaborationController.stream;

  // NEW: Child Management Streams
  Stream<ChildUpdateEvent> get childUpdates => _childUpdatesController.stream;

  bool get isConnected => _isConnected;

  /// Connect to WebSocket server
  Future<void> connect() async {
    if (_isConnected || _isReconnecting) return;

    try {
      _isReconnecting = true;
      _connectionStatusController.add(ConnectionStatus.connecting);

      final token = await _secureStorage.getToken();
      if (token == null) {
        throw Exception('No token available');
      }

      final wsUri = Uri.parse(
        '${_config.websocketUrl}${ApiEndpoints.websocketBase}',
      );

      _channel = IOWebSocketChannel.connect(
        wsUri,
        headers: {
          'Authorization': 'Bearer $token',
          'User-Agent': 'EduLift-Mobile/2.0.0',
        },
        protocols: ['echo-protocol'],
      );

      await _channel!.ready;

      _isConnected = true;
      _isReconnecting = false;
      _reconnectAttempts = 0;

      _connectionStatusController.add(ConnectionStatus.connected);

      // Set up message handling
      _setupMessageHandling();

      // Start heartbeat
      _startHeartbeat();

      // Send initial subscriptions
      await _sendInitialSubscriptions();

      if (kDebugMode) {
        print('WebSocket connected successfully');
      }
    } catch (e) {
      _isReconnecting = false;
      _connectionStatusController.add(ConnectionStatus.error);

      if (kDebugMode) {
        print('WebSocket connection failed: $e');
      }

      _scheduleReconnect();
    }
  }

  /// Disconnect from WebSocket server
  Future<void> disconnect() async {
    _isConnected = false;
    _isReconnecting = false;

    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();

    await _channel?.sink.close();
    _channel = null;

    _connectionStatusController.add(ConnectionStatus.disconnected);

    if (kDebugMode) {
      print('WebSocket disconnected');
    }
  }

  /// Subscribe to family updates
  Future<void> subscribeToFamily(String familyId) async {
    if (!_isConnected) return;

    final message = {
      'type': SocketMessageTypes.SUBSCRIBE,
      'channel': SocketChannels.FAMILY,
      'familyId': familyId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _sendMessage(message);
  }

  /// Subscribe to group updates
  Future<void> subscribeToGroup(String groupId) async {
    if (!_isConnected) return;

    final message = {
      'type': SocketMessageTypes.SUBSCRIBE,
      'channel': SocketChannels.GROUP,
      'groupId': groupId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _sendMessage(message);
  }

  /// Subscribe to schedule updates
  Future<void> subscribeToSchedule(String scheduleId) async {
    if (!_isConnected) return;

    final message = {
      'type': SocketMessageTypes.SUBSCRIBE,
      'channel': SocketChannels.SCHEDULE,
      'scheduleId': scheduleId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _sendMessage(message);
  }

  /// Subscribe to real-time schedule updates for a specific group and week
  Future<void> subscribeToGroupSchedule({
    required String groupId,
    required String week,
  }) async {
    if (!_isConnected) return;

    final message = {
      'type': SocketMessageTypes.SUBSCRIBE,
      'channel': SocketChannels.GROUP_SCHEDULE,
      'groupId': groupId,
      'week': week,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _sendMessage(message);
  }

  /// Subscribe to vehicle assignment updates
  Future<void> subscribeToVehicleAssignments(String vehicleId) async {
    if (!_isConnected) return;

    final message = {
      'type': SocketMessageTypes.SUBSCRIBE,
      'channel': SocketChannels.VEHICLE_ASSIGNMENTS,
      'vehicleId': vehicleId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _sendMessage(message);
  }

  /// Subscribe to child assignment updates
  Future<void> subscribeToChildAssignments(String childId) async {
    if (!_isConnected) return;

    final message = {
      'type': SocketMessageTypes.SUBSCRIBE,
      'channel': SocketChannels.CHILD_ASSIGNMENTS,
      'childId': childId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _sendMessage(message);
  }

  /// Send schedule update to other users
  Future<void> sendScheduleUpdate({
    required String scheduleSlotId,
    required String groupId,
    required String updateType,
    required Map<String, dynamic> updateData,
  }) async {
    if (!_isConnected) return;

    final message = {
      'type': SocketMessageTypes.SCHEDULE_UPDATE,
      'scheduleSlotId': scheduleSlotId,
      'groupId': groupId,
      'updateType': updateType,
      'updateData': updateData,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _sendMessage(message);
  }

  /// Send vehicle assignment update
  Future<void> sendVehicleAssignmentUpdate({
    required String vehicleAssignmentId,
    required String scheduleSlotId,
    required String action, // 'assign', 'remove', 'update'
    Map<String, dynamic>? assignmentData,
  }) async {
    if (!_isConnected) return;

    final message = {
      'type': SocketMessageTypes.VEHICLE_ASSIGNMENT_UPDATE,
      'vehicleAssignmentId': vehicleAssignmentId,
      'scheduleSlotId': scheduleSlotId,
      'action': action,
      'assignmentData': assignmentData ?? {},
      'timestamp': DateTime.now().toIso8601String(),
    };

    _sendMessage(message);
  }

  /// Send child assignment update
  Future<void> sendChildAssignmentUpdate({
    required String childId,
    required String vehicleAssignmentId,
    required String action, // 'assign', 'remove'
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isConnected) return;

    final message = {
      'type': SocketMessageTypes.CHILD_ASSIGNMENT_UPDATE,
      'childId': childId,
      'vehicleAssignmentId': vehicleAssignmentId,
      'action': action,
      'metadata': metadata ?? {},
      'timestamp': DateTime.now().toIso8601String(),
    };

    _sendMessage(message);
  }

  /// Unsubscribe from a channel
  Future<void> unsubscribe(String channel, String id) async {
    if (!_isConnected) return;

    final message = {
      'type': SocketMessageTypes.UNSUBSCRIBE,
      'channel': channel,
      'id': id,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _sendMessage(message);
  }

  /// Send a real-time update
  Future<void> sendUpdate(Map<String, dynamic> update) async {
    if (!_isConnected) return;

    final message = {
      'type': SocketMessageTypes.UPDATE,
      'data': update,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _sendMessage(message);
  }

  /// Set up message handling
  void _setupMessageHandling() {
    _channel!.stream.listen(
      (message) {
        try {
          final Map<String, dynamic> data = jsonDecode(message);
          _handleMessage(data);
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing WebSocket message: $e');
          }
        }
      },
      onError: (error) {
        if (kDebugMode) {
          print('WebSocket error: $error');
        }
        _handleConnectionError();
      },
      onDone: () {
        if (kDebugMode) {
          print('WebSocket connection closed');
        }
        _handleConnectionClosed();
      },
    );
  }

  /// Handle incoming messages
  void _handleMessage(Map<String, dynamic> data) {
    final String? type = data['type'];

    // Validate event type
    if (type == null) {
      if (kDebugMode) {
        print('WebSocket: Received message with no type field');
      }
      return;
    }

    if (!SocketEventValidator.isValidEvent(type)) {
      if (kDebugMode) {
        print(
          'WebSocket: Received unknown event type: $type (Category: ${SocketEventValidator.getEventCategory(type)})',
        );
      }
      // Still continue processing for legacy events or new events not yet added to constants
    }

    switch (type) {
      case SocketEvents.FAMILY_UPDATED:
        _handleFamilyUpdate(data);
        break;
      case SocketEvents.GROUP_UPDATED:
        _handleGroupUpdate(data);
        break;
      case SocketEvents.SCHEDULE_UPDATED:
        _handleScheduleUpdate(data);
        break;
      case SocketEvents.CONFLICT_DETECTED:
        _handleConflictDetected(data);
        break;
      case SocketEvents.NOTIFICATION:
        _handleNotification(data);
        break;
      // Family invitation events
      case SocketEvents.FAMILY_INVITATION_RECEIVED:
      case SocketEvents.FAMILY_INVITATION_ACCEPTED:
      case SocketEvents.FAMILY_INVITATION_DECLINED:
      case SocketEvents.FAMILY_INVITATION_EXPIRED:
      case SocketEvents.FAMILY_INVITATION_CANCELLED:
      case SocketEvents.FAMILY_INVITATION_UPDATED:
        _handleFamilyInvitationEvent(data);
        break;
      // Group invitation events
      case SocketEvents.GROUP_INVITATION_RECEIVED:
      case SocketEvents.GROUP_INVITATION_ACCEPTED:
      case SocketEvents.GROUP_INVITATION_DECLINED:
      case SocketEvents.GROUP_INVITATION_EXPIRED:
      case SocketEvents.GROUP_INVITATION_CANCELLED:
      case SocketEvents.GROUP_INVITATION_UPDATED:
        _handleGroupInvitationEvent(data);
        break;
      // Invitation notification events
      case SocketEvents.INVITATION_NOTIFICATION:
      case SocketEvents.INVITATION_REMINDER:
        _handleInvitationNotification(data);
        break;
      // Invitation status updates
      case SocketEvents.INVITATION_STATUS_UPDATE:
        _handleInvitationStatusUpdate(data);
        break;
      // Schedule coordination events
      case SocketEvents.SCHEDULE_SLOT_UPDATED_LEGACY:
      case SocketEvents.SCHEDULE_CONFLICT_DETECTED:
      case SocketEvents.CHILD_ASSIGNMENT_UPDATED:
      case SocketEvents.SCHEDULE_OPTIMIZED:
      case SocketEvents.SCHEDULE_PUBLISHED:
        _handleScheduleUpdateEvent(data);
        break;
      // Schedule notification events
      case SocketEvents.SCHEDULE_CHANGE:
      case SocketEvents.SCHEDULE_CONFLICT:
      case SocketEvents.SCHEDULE_REMINDER:
      case SocketEvents.SCHEDULE_APPROVAL_NEEDED:
        _handleScheduleNotificationEvent(data);
        break;
      case SocketMessageTypes.PONG:
        // Heartbeat response
        break;
      case SocketEvents.ERROR:
        _handleServerError(data);
        break;
      default:
        if (kDebugMode) {
          print('Unknown message type: $type');
        }
    }
  }

  /// Handle family update events
  void _handleFamilyUpdate(Map<String, dynamic> data) {
    try {
      final event = FamilyUpdateEvent.fromJson(data);
      _familyUpdatesController.add(event);
    } catch (e) {
      if (kDebugMode) {
        print('Error handling family update: $e');
      }
    }
  }

  /// Handle group update events
  void _handleGroupUpdate(Map<String, dynamic> data) {
    try {
      final event = GroupUpdateEvent.fromJson(data);
      _groupUpdatesController.add(event);
    } catch (e) {
      if (kDebugMode) {
        print('Error handling group update: $e');
      }
    }
  }

  /// Handle schedule update events
  void _handleScheduleUpdate(Map<String, dynamic> data) {
    try {
      final event = ScheduleUpdateEvent.fromJson(data);
      _scheduleUpdatesController.add(event);
    } catch (e) {
      if (kDebugMode) {
        print('Error handling schedule update: $e');
      }
    }
  }

  /// Handle conflict detection events
  void _handleConflictDetected(Map<String, dynamic> data) {
    try {
      final event = ConflictEvent.fromJson(data);
      _conflictController.add(event);
    } catch (e) {
      if (kDebugMode) {
        print('Error handling conflict event: $e');
      }
    }
  }

  /// Handle notification events
  void _handleNotification(Map<String, dynamic> data) {
    try {
      final event = NotificationEvent.fromJson(data);
      _notificationController.add(event);
    } catch (e) {
      if (kDebugMode) {
        print('Error handling notification: $e');
      }
    }
  }

  /// Handle server errors
  void _handleServerError(Map<String, dynamic> data) {
    final String? message = data['message'];
    if (kDebugMode) {
      print('Server error: $message');
    }

    // Handle specific error types
    final String? errorCode = data['code'];
    if (errorCode == ErrorCodes.UNAUTHORIZED) {
      _connectionStatusController.add(ConnectionStatus.unauthorized);
    }
  }

  /// Send a message to the server
  void _sendMessage(Map<String, dynamic> message) {
    if (_channel?.sink != null) {
      _channel!.sink.add(jsonEncode(message));
    }
  }

  /// Start heartbeat timer
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(heartbeatInterval, (timer) {
      _sendMessage({
        'type': SocketMessageTypes.PING,
        'timestamp': DateTime.now().toIso8601String(),
      });
    });
  }

  /// Handle connection errors
  void _handleConnectionError() {
    _isConnected = false;
    _connectionStatusController.add(ConnectionStatus.error);
    _scheduleReconnect();
  }

  /// Handle connection closed
  void _handleConnectionClosed() {
    _isConnected = false;
    _connectionStatusController.add(ConnectionStatus.disconnected);

    if (!_isReconnecting) {
      _scheduleReconnect();
    }
  }

  /// Schedule reconnection attempt
  void _scheduleReconnect() {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      _connectionStatusController.add(ConnectionStatus.failed);
      return;
    }

    _reconnectAttempts++;
    final delay = Duration(
      seconds: reconnectDelay.inSeconds * _reconnectAttempts,
    );

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      if (!_isConnected) {
        connect();
      }
    });
  }

  /// Send initial subscriptions after connection
  Future<void> _sendInitialSubscriptions() async {
    // Subscribe to user-specific channels based on stored data
    final userId = await _secureStorage.getUserId();
    if (userId != null) {
      _sendMessage({
        'type': SocketMessageTypes.SUBSCRIBE,
        'channel': SocketChannels.USER,
        'userId': userId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Subscribe to a channel for real-time updates
  void subscribe(String channel) {
    if (!_isConnected) return;

    final message = {
      'type': SocketMessageTypes.SUBSCRIBE,
      'channel': channel,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _sendMessage(message);
  }

  /// Get stream for a specific channel
  Stream<Map<String, dynamic>> getStream(String channel) {
    // Return a stream that filters messages for the specific channel
    return _scheduleUpdatesController.stream
        .where((event) => event.scheduleSlotId == channel)
        .map((event) => event.metadata);
  }

  /// Emit data to a channel
  void emit(String channel, Map<String, dynamic> data) {
    if (!_isConnected) return;

    final message = {
      'type': SocketMessageTypes.EMIT,
      'channel': channel,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _sendMessage(message);
  }

  /// Handle schedule update events
  void _handleScheduleUpdateEvent(Map<String, dynamic> data) {
    try {
      // Create a ScheduleUpdateEvent from the data using factory method
      final event = ScheduleUpdateEvent.fromJson(data);

      // Add to both the generic and schedule-specific streams
      if (!_scheduleUpdatesController.isClosed) {
        _scheduleUpdatesController.add(event);
      }
      if (!_scheduleUpdateController.isClosed) {
        _scheduleUpdateController.add(event);
      }

      // Trigger additional processing based on event type
      _processScheduleUpdateEvent(event);

      if (kDebugMode) {
        print(
          'WebSocket: Schedule update event processed for schedule ${event.scheduleSlotId}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('WebSocket: Error handling schedule update event: $e');
      }
    }
  }

  /// Handle schedule notification events
  void _handleScheduleNotificationEvent(Map<String, dynamic> data) {
    try {
      // Create a schedule notification event
      final event = ScheduleNotificationEvent.fromJson(data);

      // Add to the notification stream
      if (!_scheduleNotificationController.isClosed) {
        _scheduleNotificationController.add(event);
      }

      // Also create a general notification if high priority
      if (event.isHighPriority) {
        final generalNotification = NotificationEvent(
          eventId: 'event-${DateTime.now().millisecondsSinceEpoch}',
          notificationId: event.notificationId,
          title: event.title,
          message: event.message,
          priority: NotificationPriority.high,
          category: event.notificationType.name,
          data: {
            'scheduleSlotId': event.scheduleSlotId,
            'groupId': event.groupId,
            'priority': event.priority,
            'actionRequired': event.actionRequired,
          },
          timestamp: event.timestamp,
        );

        if (!_notificationController.isClosed) {
          _notificationController.add(generalNotification);
        }
      }

      if (kDebugMode) {
        print(
          'WebSocket: Schedule notification event processed: ${event.title}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('WebSocket: Error handling schedule notification event: $e');
      }
    }
  }

  /// Process schedule update events for additional side effects
  void _processScheduleUpdateEvent(ScheduleUpdateEvent event) {
    // Handle conflict detection
    if (event.isConflictEvent) {
      final conflictEvent = ConflictEvent(
        eventId: 'event-${DateTime.now().millisecondsSinceEpoch}',
        conflictId: event.scheduleSlotId,
        conflictType: ConflictType.schedule,
        severity: ConflictSeverity.medium,
        description: 'Schedule conflict detected',
        scheduleSlotId: event.scheduleSlotId,
        groupId: event.groupId,
        conflictData: {
          'scheduleSlotId': event.scheduleSlotId,
          'groupId': event.groupId,
          'conflictDetails': event.conflictDetails,
          'affectedVehicles': event.vehicleAssignments
              .map((v) => v.vehicle.id)
              .toList(),
          'affectedChildren':
              event.childAssignments?.map((c) => c.childId).toList() ?? [],
        },
        timestamp: event.timestamp,
      );

      if (!_conflictController.isClosed) {
        _conflictController.add(conflictEvent);
      }
    }

    // Handle capacity warnings for vehicle assignments
    if (event.affectsVehicles) {
      for (final vehicleAssignment in event.vehicleAssignments) {
        const assignedChildren =
            0; // TODO: Get children count from proper source
        // Get capacity from vehicle relation or use seatOverride
        final capacity =
            vehicleAssignment.seatOverride ??
            vehicleAssignment.vehicle.capacity;

        if (assignedChildren >= capacity * 0.9) {
          // 90% capacity warning
          final vehicleId = vehicleAssignment.vehicle.id;
          final warning = NotificationEvent(
            eventId: 'event-${DateTime.now().millisecondsSinceEpoch}',
            notificationId: 'capacity_${vehicleAssignment.id}',
            title: 'Vehicle Near Capacity',
            message:
                'Vehicle $vehicleId is at $assignedChildren/$capacity capacity',
            priority: NotificationPriority.medium,
            category: NotificationTypes.CAPACITY_WARNING,
            data: {
              'vehicleAssignmentId': vehicleAssignment.id,
              'vehicleId': vehicleId,
              'scheduleSlotId': event.scheduleSlotId,
              'currentCapacity': assignedChildren,
              'maxCapacity': capacity,
            },
            timestamp: DateTime.now(),
          );

          if (!_notificationController.isClosed) {
            _notificationController.add(warning);
          }
        }
      }
    }
  }

  // === INVITATION-SPECIFIC METHODS ===

  /// Subscribe to family invitation events
  Future<void> subscribeToFamilyInvitations(String familyId) async {
    if (!_isConnected) return;

    final message = {
      'type': SocketMessageTypes.SUBSCRIBE,
      'channel': SocketChannels.FAMILY_INVITATIONS,
      'familyId': familyId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _sendMessage(message);
  }

  /// Subscribe to group invitation events
  Future<void> subscribeToGroupInvitations(String groupId) async {
    if (!_isConnected) return;

    final message = {
      'type': SocketMessageTypes.SUBSCRIBE,
      'channel': SocketChannels.GROUP_INVITATIONS,
      'groupId': groupId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _sendMessage(message);
  }

  /// Unsubscribe from invitation events
  Future<void> unsubscribeFromInvitations(
    String id,
    InvitationTypeDto type,
  ) async {
    if (!_isConnected) return;

    final channel = type == InvitationTypeDto.family
        ? SocketChannels.FAMILY_INVITATIONS
        : SocketChannels.GROUP_INVITATIONS;
    final message = {
      'type': SocketMessageTypes.UNSUBSCRIBE,
      'channel': channel,
      'id': id,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _sendMessage(message);
  }

  /// Send invitation update
  Future<void> sendInvitationUpdate({
    required String invitationId,
    required InvitationStatusDto status,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isConnected) return;

    final message = {
      'type': SocketMessageTypes.INVITATION_UPDATE,
      'invitationId': invitationId,
      'status': status.name,
      'metadata': metadata ?? {},
      'timestamp': DateTime.now().toIso8601String(),
    };

    _sendMessage(message);
  }

  /// Handle family invitation events
  void _handleFamilyInvitationEvent(Map<String, dynamic> data) {
    try {
      final event = FamilyInvitationEvent.fromJson(data);

      // Add to family invitation stream
      if (!_familyInvitationController.isClosed) {
        _familyInvitationController.add(event);
      }

      // Process invitation event for additional side effects
      _processFamilyInvitationEvent(event);

      if (kDebugMode) {
        print(
          'WebSocket: Family invitation event processed: ${event.eventType.name}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling family invitation event: $e');
      }
    }
  }

  /// Handle group invitation events
  void _handleGroupInvitationEvent(Map<String, dynamic> data) {
    try {
      final event = GroupInvitationEvent.fromJson(data);

      // Add to group invitation stream
      if (!_groupInvitationController.isClosed) {
        _groupInvitationController.add(event);
      }

      // Process invitation event for additional side effects
      _processGroupInvitationEvent(event);

      if (kDebugMode) {
        print(
          'WebSocket: Group invitation event processed: ${event.eventType.name}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling group invitation event: $e');
      }
    }
  }

  /// Handle invitation notification events
  void _handleInvitationNotification(Map<String, dynamic> data) {
    try {
      final event = InvitationNotificationEvent.fromJson(data);

      // Add to invitation notification stream
      if (!_invitationNotificationController.isClosed) {
        _invitationNotificationController.add(event);
      }

      // Create general notification for UI alerts
      final generalNotification = NotificationEvent(
        eventId: 'event-${DateTime.now().millisecondsSinceEpoch}',
        notificationId: event.notificationId,
        title: event.title,
        message: event.message,
        priority: NotificationPriority.medium,
        category: NotificationTypes.INVITATION_NOTIFICATION,
        data: {
          'invitationId': event.invitationId,
          'invitationType': event.invitationType.name,
          'actionRequired': event.actionRequired,
          'isReminder': event.isReminder,
          'deepLink': event.deepLink,
        },
        timestamp: event.timestamp,
      );

      if (!_notificationController.isClosed) {
        _notificationController.add(generalNotification);
      }

      if (kDebugMode) {
        print('WebSocket: Invitation notification processed: ${event.title}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling invitation notification: $e');
      }
    }
  }

  /// Handle invitation status update events
  void _handleInvitationStatusUpdate(Map<String, dynamic> data) {
    try {
      final event = InvitationStatusUpdateEvent.fromJson(data);

      // Add to invitation status update stream
      if (!_invitationStatusUpdateController.isClosed) {
        _invitationStatusUpdateController.add(event);
      }

      // Process status update for UI refresh triggers
      _processInvitationStatusUpdate(event);

      if (kDebugMode) {
        print(
          'WebSocket: Invitation status update processed: ${event.invitationId}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling invitation status update: $e');
      }
    }
  }

  /// Process family invitation events for additional side effects
  void _processFamilyInvitationEvent(FamilyInvitationEvent event) {
    // Trigger family list refresh for accepted invitations
    if (event.eventType == InvitationEventType.accepted) {
      // Could trigger a family data refresh in the app state
      _sendRefreshTrigger(SocketChannels.FAMILY, {
        'reason': SocketEvents.FAMILY_INVITATION_ACCEPTED,
        'familyId': event.familyId,
        'invitationId': event.invitationId,
      });
    }

    // Handle expired invitations
    if (event.eventType == InvitationEventType.expired) {
      final expiredNotification = NotificationEvent(
        eventId: 'event-${DateTime.now().millisecondsSinceEpoch}',
        notificationId: 'expired_${event.invitationId}',
        title: 'Family Invitation Expired',
        message:
            'Your invitation to ${event.familyName ?? 'a family'} has expired',
        priority: NotificationPriority.medium,
        category: NotificationTypes.INVITATION_EXPIRED,
        data: {
          'invitationId': event.invitationId,
          'familyId': event.familyId,
          'familyName': event.familyName,
        },
        timestamp: DateTime.now(),
      );

      if (!_notificationController.isClosed) {
        _notificationController.add(expiredNotification);
      }
    }
  }

  /// Process group invitation events for additional side effects
  void _processGroupInvitationEvent(GroupInvitationEvent event) {
    // Trigger group list refresh for accepted invitations
    if (event.eventType == InvitationEventType.accepted) {
      _sendRefreshTrigger(SocketChannels.GROUP, {
        'reason': SocketEvents.GROUP_INVITATION_ACCEPTED,
        'groupId': event.groupId,
        'invitationId': event.invitationId,
      });
    }

    // Handle group invitation with member count updates
    if (event.eventType == InvitationEventType.accepted &&
        event.membersAdded != null) {
      final memberNotification = NotificationEvent(
        eventId: 'event-${DateTime.now().millisecondsSinceEpoch}',
        notificationId: 'members_${event.invitationId}',
        title: 'Group Membership Updated',
        message:
            '${event.membersAdded} new members added to ${event.groupName ?? 'the group'}',
        priority: NotificationPriority.medium,
        category: NotificationTypes.GROUP_MEMBERS_UPDATED,
        data: {
          'groupId': event.groupId,
          'groupName': event.groupName,
          'membersAdded': event.membersAdded,
        },
        timestamp: DateTime.now(),
      );

      if (!_notificationController.isClosed) {
        _notificationController.add(memberNotification);
      }
    }
  }

  /// Process invitation status updates for UI refresh triggers
  void _processInvitationStatusUpdate(InvitationStatusUpdateEvent event) {
    // Trigger appropriate data refresh based on status change
    final refreshTriggers = <String>['invitations'];

    // Add specific refresh triggers based on status
    if (event.newStatus.name == 'accepted') {
      refreshTriggers.addAll([SocketChannels.FAMILY, SocketChannels.GROUP]);
    } else if (event.newStatus.name == 'declined' ||
        event.newStatus.name == 'cancelled') {
      refreshTriggers.add(SocketChannels.FAMILY_INVITATIONS);
    }

    for (final trigger in refreshTriggers) {
      _sendRefreshTrigger(trigger, {
        'reason': SocketEvents.INVITATION_STATUS_UPDATE,
        'invitationId': event.invitationId,
        'oldStatus': event.oldStatus.name,
        'newStatus': event.newStatus.name,
      });
    }
  }

  /// Send refresh trigger for UI state management
  void _sendRefreshTrigger(String dataType, Map<String, dynamic> context) {
    final refreshEvent = NotificationEvent(
      eventId: 'event-${DateTime.now().millisecondsSinceEpoch}',
      notificationId:
          'refresh_${dataType}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Data Refresh',
      message: 'Refresh $dataType due to real-time update',
      priority: NotificationPriority.low,
      category: NotificationTypes.DATA_REFRESH_TRIGGER,
      data: {
        'dataType': dataType,
        'context': context,
        'timestamp': DateTime.now().toIso8601String(),
      },
      timestamp: DateTime.now(),
    );

    if (!_notificationController.isClosed) {
      _notificationController.add(refreshEvent);
    }
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _familyUpdatesController.close();
    _groupUpdatesController.close();
    _scheduleUpdatesController.close();
    _conflictController.close();
    _notificationController.close();
    _connectionStatusController.close();
    // Close invitation-specific controllers
    _familyInvitationController.close();
    _groupInvitationController.close();
    _invitationNotificationController.close();
    _invitationStatusUpdateController.close();
  }
}

/// Connection status enum
enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
  unauthorized,
  failed,
}
