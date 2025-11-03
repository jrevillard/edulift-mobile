import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import '../../../core/config/base_config.dart';
import '../../../infrastructure/network/websocket/socket_events.dart';
import '../../utils/app_logger.dart';
import '../certificate_error_monitor.dart';

/// Enhanced real-time WebSocket service for collaborative scheduling
/// Implements SPARC Phase 3 real-time features with presence and conflict detection

/// Realtime WebSocket service managed by Riverpod
///
/// RIVERPOD SINGLETON: @Riverpod(keepAlive: true) prevents multiple instances
/// that would cause conflicting WebSocket connections and duplicate event streams.
class RealtimeWebSocketService {
  final BaseConfig _config;
  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  Timer? _presenceTimer;

  bool _isConnected = false;
  bool _isReconnecting = false;
  int _reconnectAttempts = 0;
  String? _currentUserId;
  String? _currentSessionId;
  final Set<String> _joinedRooms = {};

  /// Constructor - Riverpod manages singleton via @riverpod
  ///
  /// RIVERPOD SINGLETON: No manual singleton pattern needed.
  /// Provider with keepAlive: true ensures only one WebSocket connection exists.
  RealtimeWebSocketService(this._config);

  static const int maxReconnectAttempts = 5;
  static const Duration initialReconnectDelay = Duration(seconds: 2);
  static const Duration maxReconnectDelay = Duration(seconds: 30);
  static const Duration heartbeatInterval = Duration(seconds: 30);
  static const Duration presenceUpdateInterval = Duration(seconds: 10);

  // Enhanced stream controllers for real-time collaboration
  final StreamController<ScheduleCollaborationEvent>
  _scheduleCollaborationController =
      StreamController<ScheduleCollaborationEvent>.broadcast();
  final StreamController<ConflictDetectionEvent> _conflictDetectionController =
      StreamController<ConflictDetectionEvent>.broadcast();
  final StreamController<PresenceUpdateEvent> _presenceUpdateController =
      StreamController<PresenceUpdateEvent>.broadcast();
  final StreamController<TypingIndicatorEvent> _typingIndicatorController =
      StreamController<TypingIndicatorEvent>.broadcast();
  final StreamController<ConnectionStatusEvent> _connectionStatusController =
      StreamController<ConnectionStatusEvent>.broadcast();
  final StreamController<RealtimeNotificationEvent> _notificationController =
      StreamController<RealtimeNotificationEvent>.broadcast();

  // Public streams for real-time features
  Stream<ScheduleCollaborationEvent> get scheduleCollaboration =>
      _scheduleCollaborationController.stream;
  Stream<ConflictDetectionEvent> get conflictDetection =>
      _conflictDetectionController.stream;
  Stream<PresenceUpdateEvent> get presenceUpdates =>
      _presenceUpdateController.stream;
  Stream<TypingIndicatorEvent> get typingIndicators =>
      _typingIndicatorController.stream;
  Stream<ConnectionStatusEvent> get connectionStatus =>
      _connectionStatusController.stream;
  Stream<RealtimeNotificationEvent> get notifications =>
      _notificationController.stream;

  bool get isConnected => _isConnected;
  Set<String> get joinedRooms => Set.unmodifiable(_joinedRooms);

  /// Connect to WebSocket server with enhanced authentication
  Future<void> connect(String userId, String? authToken) async {
    if (_isConnected || _isReconnecting) return;

    try {
      _currentUserId = userId;
      _currentSessionId = _generateSessionId();

      final uri = Uri.parse('${_config.websocketUrl}/realtime').replace(
        queryParameters: {
          'userId': userId,
          'sessionId': _currentSessionId!,
          if (authToken != null) 'token': authToken,
        },
      );

      _channel = IOWebSocketChannel.connect(uri);

      await _channel!.ready;
      _isConnected = true;
      _reconnectAttempts = 0;
      _isReconnecting = false;

      _connectionStatusController.add(
        ConnectionStatusEvent(
          status: RealtimeConnectionStatus.connected,
          userId: userId,
          sessionId: _currentSessionId!,
        ),
      );

      _setupMessageHandling();
      _startHeartbeat();
      _startPresenceUpdates();

      if (kDebugMode) {
        print('🔗 WebSocket connected for user: $userId');
      }
    } catch (e) {
      _handleConnectionError(e);
    }
  }

  /// Setup enhanced message handling for collaborative features
  void _setupMessageHandling() {
    _channel!.stream.listen(
      (message) {
        try {
          final data = jsonDecode(message as String);
          _handleIncomingMessage(data);
        } catch (e) {
          if (kDebugMode) {
            print('❌ Error parsing WebSocket message: $e');
          }
        }
      },
      onError: _handleConnectionError,
      onDone: () => _handleDisconnection(),
    );
  }

  /// Enhanced message handling for all real-time events
  void _handleIncomingMessage(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final payload = data['payload'] as Map<String, dynamic>?;

    if (type == null || payload == null) return;

    switch (type) {
      // Schedule collaboration events
      case SocketMessageTypes.VEHICLE_ASSIGNMENT_UPDATE:
        _scheduleCollaborationController.add(
          ScheduleCollaborationEvent(
            type: CollaborationType.vehicleAssigned,
            scheduleSlotId: payload['scheduleSlotId'] as String,
            vehicleId: payload['vehicleId'] as String,
            vehicleName: payload['vehicleName'] as String,
            assignedBy: payload['assignedBy'] as String,
            assignedByName: payload['assignedByName'] as String,
            timestamp: DateTime.parse(payload['timestamp'] as String),
            metadata: payload['metadata'] as Map<String, dynamic>?,
          ),
        );
        break;

      case SocketEvents.CHILD_ASSIGNMENT_UPDATED:
        _scheduleCollaborationController.add(
          ScheduleCollaborationEvent(
            type: CollaborationType.childAssigned,
            scheduleSlotId: payload['scheduleSlotId'] as String,
            childId: payload['childId'] as String,
            childName: payload['childName'] as String,
            vehicleId: payload['vehicleId'] as String,
            assignedBy: payload['assignedBy'] as String,
            assignedByName: payload['assignedByName'] as String,
            timestamp: DateTime.parse(payload['timestamp'] as String),
            metadata: payload['metadata'] as Map<String, dynamic>?,
          ),
        );
        break;

      case SocketEvents.SCHEDULE_SLOT_UPDATED_LEGACY:
        _scheduleCollaborationController.add(
          ScheduleCollaborationEvent(
            type: CollaborationType.scheduleUpdated,
            scheduleSlotId: payload['scheduleSlotId'] as String,
            updatedBy: payload['updatedBy'] as String,
            updatedByName: payload['updatedByName'] as String,
            changes: payload['changes'] as Map<String, dynamic>,
            timestamp: DateTime.parse(payload['timestamp'] as String),
          ),
        );
        break;

      // Conflict detection events
      case SocketEvents.SCHEDULE_CONFLICT:
        _conflictDetectionController.add(
          ConflictDetectionEvent(
            conflictId: payload['conflictId'] as String,
            type: ConflictType.values.firstWhere(
              (e) => e.name == payload['conflictType'],
              orElse: () => ConflictType.scheduleOverlap,
            ),
            scheduleSlotId: payload['scheduleSlotId'] as String,
            conflictingSlotId: payload['conflictingSlotId'] as String?,
            vehicleId: payload['vehicleId'] as String?,
            childId: payload['childId'] as String?,
            description: payload['description'] as String,
            severity: ConflictSeverity.values.firstWhere(
              (e) => e.name == payload['severity'],
              orElse: () => ConflictSeverity.medium,
            ),
            suggestedResolution: payload['suggestedResolution'] as String?,
            timestamp: DateTime.parse(payload['timestamp'] as String),
          ),
        );
        break;

      // Presence system events
      case SocketEvents.USER_JOINED:
        _presenceUpdateController.add(
          PresenceUpdateEvent(
            type: PresenceType.userJoined,
            userId: payload['userId'] as String,
            userName: payload['userName'] as String,
            scheduleSlotId: payload['scheduleSlotId'] as String?,
            groupId: payload['groupId'] as String?,
            timestamp: DateTime.parse(payload['timestamp'] as String),
          ),
        );
        break;

      case SocketEvents.USER_LEFT:
        _presenceUpdateController.add(
          PresenceUpdateEvent(
            type: PresenceType.userLeft,
            userId: payload['userId'] as String,
            userName: payload['userName'] as String,
            scheduleSlotId: payload['scheduleSlotId'] as String?,
            groupId: payload['groupId'] as String?,
            timestamp: DateTime.parse(payload['timestamp'] as String),
          ),
        );
        break;

      case SocketEvents.USER_TYPING:
        _typingIndicatorController.add(
          TypingIndicatorEvent(
            userId: payload['userId'] as String,
            userName: payload['userName'] as String,
            scheduleSlotId: payload['scheduleSlotId'] as String,
            isTyping: payload['isTyping'] as bool,
            timestamp: DateTime.parse(payload['timestamp'] as String),
          ),
        );
        break;

      // Real-time notifications
      case SocketEvents.NOTIFICATION:
        _notificationController.add(
          RealtimeNotificationEvent(
            id: payload['id'] as String,
            type: payload['notificationType'] as String,
            title: payload['title'] as String,
            message: payload['message'] as String,
            priority: NotificationPriority.values.firstWhere(
              (e) => e.name == payload['priority'],
              orElse: () => NotificationPriority.medium,
            ),
            actionUrl: payload['actionUrl'] as String?,
            metadata: payload['metadata'] as Map<String, dynamic>?,
            timestamp: DateTime.parse(payload['timestamp'] as String),
          ),
        );
        break;

      case SocketEvents.HEARTBEAT_ACK:
        // Server acknowledged our heartbeat
        break;

      default:
        if (kDebugMode) {
          print('📨 Unknown WebSocket message type: $type');
        }
    }
  }

  /// Join a room for real-time collaboration (family or group specific)
  Future<void> joinRoom(String roomId, String roomType) async {
    if (!_isConnected) {
      throw Exception('WebSocket not connected');
    }

    final message = {
      'type': SocketEvents.SCHEDULE_SLOT_JOIN,
      'payload': {
        'roomId': roomId,
        'roomType': roomType, // 'family' or 'group'
        'userId': _currentUserId,
        'sessionId': _currentSessionId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    };

    _channel!.sink.add(jsonEncode(message));
    _joinedRooms.add(roomId);

    if (kDebugMode) {
      print('🚪 Joined room: $roomId ($roomType)');
    }
  }

  /// Leave a room
  Future<void> leaveRoom(String roomId) async {
    if (!_isConnected) return;

    final message = {
      'type': SocketEvents.SCHEDULE_SLOT_LEAVE,
      'payload': {
        'roomId': roomId,
        'userId': _currentUserId,
        'sessionId': _currentSessionId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    };

    _channel!.sink.add(jsonEncode(message));
    _joinedRooms.remove(roomId);

    if (kDebugMode) {
      print('🚪 Left room: $roomId');
    }
  }

  /// Emit vehicle assignment event
  void emitVehicleAssigned({
    required String scheduleSlotId,
    required String vehicleId,
    required String vehicleName,
    Map<String, dynamic>? metadata,
  }) {
    _emitScheduleEvent(SocketMessageTypes.VEHICLE_ASSIGNMENT_UPDATE, {
      'scheduleSlotId': scheduleSlotId,
      'vehicleId': vehicleId,
      'vehicleName': vehicleName,
      'assignedBy': _currentUserId,
      'metadata': metadata,
    });
  }

  /// Emit child assignment event
  void emitChildAssigned({
    required String scheduleSlotId,
    required String childId,
    required String childName,
    required String vehicleId,
    Map<String, dynamic>? metadata,
  }) {
    _emitScheduleEvent(SocketEvents.CHILD_ASSIGNMENT_UPDATED, {
      'scheduleSlotId': scheduleSlotId,
      'childId': childId,
      'childName': childName,
      'vehicleId': vehicleId,
      'assignedBy': _currentUserId,
      'metadata': metadata,
    });
  }

  /// Emit schedule update event
  void emitScheduleUpdated({
    required String scheduleSlotId,
    required Map<String, dynamic> changes,
    Map<String, dynamic>? metadata,
  }) {
    _emitScheduleEvent(SocketEvents.SCHEDULE_SLOT_UPDATED_LEGACY, {
      'scheduleSlotId': scheduleSlotId,
      'changes': changes,
      'updatedBy': _currentUserId,
      'metadata': metadata,
    });
  }

  /// Emit typing indicator
  void emitTypingIndicator({
    required String scheduleSlotId,
    required bool isTyping,
  }) {
    _emitMessage(SocketEvents.USER_TYPING, {
      'scheduleSlotId': scheduleSlotId,
      'userId': _currentUserId,
      'isTyping': isTyping,
    });
  }

  /// Helper method to emit schedule-related events
  void _emitScheduleEvent(String eventType, Map<String, dynamic> payload) {
    _emitMessage(eventType, {
      ...payload,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Generic method to emit WebSocket messages
  void _emitMessage(String type, Map<String, dynamic> payload) {
    if (!_isConnected) {
      if (kDebugMode) {
        print('⚠️ Cannot emit $type: WebSocket not connected');
      }
      return;
    }

    final message = {'type': type, 'payload': payload};

    _channel!.sink.add(jsonEncode(message));

    if (kDebugMode) {
      print('📤 Emitted: $type');
    }
  }

  /// Start heartbeat to maintain connection
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(heartbeatInterval, (_) {
      if (_isConnected) {
        _emitMessage(SocketEvents.HEARTBEAT, {
          'userId': _currentUserId,
          'sessionId': _currentSessionId,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    });
  }

  /// Start presence updates
  void _startPresenceUpdates() {
    _presenceTimer?.cancel();
    _presenceTimer = Timer.periodic(presenceUpdateInterval, (_) {
      if (_isConnected && _joinedRooms.isNotEmpty) {
        _emitMessage(SocketEvents.USER_JOINED, {
          'userId': _currentUserId,
          'sessionId': _currentSessionId,
          'activeRooms': _joinedRooms.toList(),
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    });
  }

  /// Handle connection errors with exponential backoff
  void _handleConnectionError(dynamic error) {
    AppLogger.error('WebSocket connection error', error);

    // 🚨 CHECK FOR CERTIFICATE ERRORS
    if (error is WebSocketChannelException && _isCertificateError(error)) {
      AppLogger.error(
        'WebSocket certificate validation failed - NOT retrying to prevent ANR',
        error,
      );

      // Log to monitoring
      CertificateErrorMonitor.recordError(
        operation: 'WebSocket Connection',
        url: Uri.parse('${_config.websocketUrl}/realtime'),
        errorMessage: error.message ?? 'WebSocket certificate error',
        osError: error.toString(),
      );

      // Don't retry certificate errors - they will always fail
      return;
    }

    _isConnected = false;
    _connectionStatusController.add(
      ConnectionStatusEvent(
        status: RealtimeConnectionStatus.error,
        error: error.toString(),
      ),
    );

    _scheduleReconnection();
  }

  /// Check if WebSocket error is certificate-related
  bool _isCertificateError(WebSocketChannelException error) {
    final message = error.message?.toLowerCase() ?? '';
    return message.contains('certificate') ||
        message.contains('handshake') ||
        message.contains('ssl') ||
        message.contains('tls');
  }

  /// Handle disconnection
  void _handleDisconnection() {
    if (kDebugMode) {
      print('🔌 WebSocket disconnected');
    }

    _isConnected = false;
    _connectionStatusController.add(
      const ConnectionStatusEvent(
        status: RealtimeConnectionStatus.disconnected,
      ),
    );

    if (!_isReconnecting) {
      _scheduleReconnection();
    }
  }

  /// Schedule reconnection with exponential backoff
  void _scheduleReconnection() {
    if (_isReconnecting || _reconnectAttempts >= maxReconnectAttempts) {
      return;
    }

    _isReconnecting = true;
    _reconnectAttempts++;

    // Exponential backoff with jitter
    final baseDelay =
        initialReconnectDelay.inMilliseconds * pow(2, _reconnectAttempts - 1);
    final jitter = Random().nextInt(1000); // Add random jitter
    final delay = Duration(
      milliseconds: min(
        baseDelay.toInt() + jitter,
        maxReconnectDelay.inMilliseconds,
      ),
    );

    if (kDebugMode) {
      print(
        '🔄 Scheduling reconnection attempt $_reconnectAttempts in ${delay.inSeconds}s',
      );
    }

    _connectionStatusController.add(
      ConnectionStatusEvent(
        status: RealtimeConnectionStatus.reconnecting,
        reconnectAttempt: _reconnectAttempts,
        nextAttemptIn: delay,
      ),
    );

    _reconnectTimer = Timer(delay, () async {
      if (_currentUserId != null) {
        await connect(_currentUserId!, null);

        // Rejoin all previously joined rooms
        final roomsToRejoin = Set.from(_joinedRooms);
        _joinedRooms.clear();

        for (final roomId in roomsToRejoin) {
          await joinRoom(roomId, 'group'); // Default to group type
        }
      }
    });
  }

  /// Generate unique session ID
  String _generateSessionId() {
    return '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9999).toString().padLeft(4, '0')}';
  }

  /// Disconnect and cleanup
  Future<void> disconnect() async {
    _heartbeatTimer?.cancel();
    _presenceTimer?.cancel();
    _reconnectTimer?.cancel();

    _isConnected = false;
    _isReconnecting = false;
    _joinedRooms.clear();

    await _channel?.sink.close();
    _channel = null;

    _connectionStatusController.add(
      const ConnectionStatusEvent(
        status: RealtimeConnectionStatus.disconnected,
      ),
    );

    if (kDebugMode) {
      print('🔌 WebSocket disconnected and cleaned up');
    }
  }

  /// Bridge high-priority notifications to native system
  ///
  /// This method is called by NotificationBridgeService to trigger
  /// native device notifications for high-priority WebSocket events.
  /// It preserves all existing functionality while adding native bridging.
  void bridgeHighPriorityNotificationsToNative({
    required Function(RealtimeNotificationEvent) onHighPriorityNotification,
  }) {
    // Listen to notification stream and bridge high-priority notifications
    notifications.listen((notification) {
      if (notification.priority == NotificationPriority.high ||
          notification.priority == NotificationPriority.urgent) {
        onHighPriorityNotification(notification);
      }
    });
  }

  /// Dispose all resources
  void dispose() {
    disconnect();
    _scheduleCollaborationController.close();
    _conflictDetectionController.close();
    _presenceUpdateController.close();
    _typingIndicatorController.close();
    _connectionStatusController.close();
    _notificationController.close();
  }
}

// Event classes for real-time collaboration

/// Schedule collaboration events
class ScheduleCollaborationEvent {
  final CollaborationType type;
  final String scheduleSlotId;
  final String? vehicleId;
  final String? vehicleName;
  final String? childId;
  final String? childName;
  final String? assignedBy;
  final String? assignedByName;
  final String? updatedBy;
  final String? updatedByName;
  final Map<String, dynamic>? changes;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  const ScheduleCollaborationEvent({
    required this.type,
    required this.scheduleSlotId,
    this.vehicleId,
    this.vehicleName,
    this.childId,
    this.childName,
    this.assignedBy,
    this.assignedByName,
    this.updatedBy,
    this.updatedByName,
    this.changes,
    this.metadata,
    required this.timestamp,
  });
}

enum CollaborationType {
  vehicleAssigned,
  childAssigned,
  scheduleUpdated,
  slotCreated,
  slotDeleted,
}

/// Conflict detection events
class ConflictDetectionEvent {
  final String conflictId;
  final ConflictType type;
  final String scheduleSlotId;
  final String? conflictingSlotId;
  final String? vehicleId;
  final String? childId;
  final String description;
  final ConflictSeverity severity;
  final String? suggestedResolution;
  final DateTime timestamp;

  const ConflictDetectionEvent({
    required this.conflictId,
    required this.type,
    required this.scheduleSlotId,
    this.conflictingSlotId,
    this.vehicleId,
    this.childId,
    required this.description,
    required this.severity,
    this.suggestedResolution,
    required this.timestamp,
  });
}

enum ConflictType {
  scheduleOverlap,
  vehicleDoubleBooking,
  childDoubleBooking,
  driverUnavailable,
  capacityExceeded,
}

enum ConflictSeverity { low, medium, high, critical }

/// Presence update events
class PresenceUpdateEvent {
  final PresenceType type;
  final String userId;
  final String userName;
  final String? scheduleSlotId;
  final String? groupId;
  final DateTime timestamp;

  const PresenceUpdateEvent({
    required this.type,
    required this.userId,
    required this.userName,
    this.scheduleSlotId,
    this.groupId,
    required this.timestamp,
  });
}

enum PresenceType { userJoined, userLeft, userActive, userIdle }

/// Typing indicator events
class TypingIndicatorEvent {
  final String userId;
  final String userName;
  final String scheduleSlotId;
  final bool isTyping;
  final DateTime timestamp;

  const TypingIndicatorEvent({
    required this.userId,
    required this.userName,
    required this.scheduleSlotId,
    required this.isTyping,
    required this.timestamp,
  });
}

/// Connection status events
class ConnectionStatusEvent {
  final RealtimeConnectionStatus status;
  final String? userId;
  final String? sessionId;
  final String? error;
  final int? reconnectAttempt;
  final Duration? nextAttemptIn;

  const ConnectionStatusEvent({
    required this.status,
    this.userId,
    this.sessionId,
    this.error,
    this.reconnectAttempt,
    this.nextAttemptIn,
  });
}

enum RealtimeConnectionStatus {
  connecting,
  connected,
  disconnected,
  reconnecting,
  error,
}

/// Real-time notification events
class RealtimeNotificationEvent {
  final String id;
  final String type;
  final String title;
  final String message;
  final NotificationPriority priority;
  final String? actionUrl;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  const RealtimeNotificationEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.priority,
    this.actionUrl,
    this.metadata,
    required this.timestamp,
  });
}

enum NotificationPriority { low, medium, high, urgent }
