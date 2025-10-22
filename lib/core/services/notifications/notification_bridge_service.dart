import 'dart:async';
import '../../network/websocket/realtime_websocket_service.dart';
import '../../utils/app_logger.dart';
import 'unified_notification_service.dart';

// Use alias to resolve naming conflict
import '../../network/websocket/realtime_websocket_service.dart'
    as ws
    show NotificationPriority;

/// Bridge service that connects WebSocket notifications to native notifications
///
/// This service listens to high-priority WebSocket notifications and triggers
/// corresponding native device notifications, providing a seamless notification
/// experience that bridges real-time communication with native platform features.
///
/// **PRESERVES EXISTING WEBSOCKET SYSTEM:**
/// - Maintains all existing WebSocket notification functionality
/// - Only adds native notification layer for high-priority events
/// - Uses existing RealtimeNotificationEvent system
/// - Preserves all existing navigation and deep linking
class NotificationBridgeService {
  final RealtimeWebSocketService _webSocketService;
  final UnifiedNotificationService _notificationService;

  StreamSubscription<RealtimeNotificationEvent>? _webSocketSubscription;
  bool _isBridgeActive = false;

  NotificationBridgeService({
    required RealtimeWebSocketService webSocketService,
    required UnifiedNotificationService notificationService,
  }) : _webSocketService = webSocketService,
       _notificationService = notificationService;

  /// Initialize the bridge service
  Future<void> initialize() async {
    if (_isBridgeActive) return;

    AppLogger.info('🌉 Initializing NotificationBridgeService...');

    // Initialize the unified notification service
    final initialized = await _notificationService.initialize();
    if (!initialized) {
      AppLogger.error('❌ Failed to initialize UnifiedNotificationService');
      return;
    }

    // Start listening to WebSocket notifications
    _startWebSocketBridge();
    _isBridgeActive = true;

    AppLogger.info('✅ NotificationBridgeService initialized and active');
  }

  /// Start bridging WebSocket notifications to native notifications
  void _startWebSocketBridge() {
    // Cancel any existing subscription
    unawaited(_webSocketSubscription?.cancel());

    // Listen to WebSocket notification events
    _webSocketSubscription = _webSocketService.notifications.listen(
      (event) => _handleWebSocketNotification(event),
      onError: (error) {
        AppLogger.error('❌ Error in WebSocket notification bridge', error);
      },
    );

    AppLogger.debug('🔄 WebSocket notification bridge activated');
  }

  /// Handle WebSocket notification events
  Future<void> _handleWebSocketNotification(
    RealtimeNotificationEvent event,
  ) async {
    try {
      AppLogger.debug(
        '📨 Bridge received WebSocket notification: ${event.title} (${event.priority.name})',
      );

      // Only bridge high-priority and urgent notifications to native system
      // This prevents notification spam while ensuring important messages get through
      if (event.priority == ws.NotificationPriority.high ||
          event.priority == ws.NotificationPriority.urgent) {
        await _notificationService.showNotificationFromWebSocket(
          id: event.id,
          type: event.type,
          title: event.title,
          message: event.message,
          priority: event.priority.name,
          actionUrl: event.actionUrl,
          metadata: event.metadata,
        );

        AppLogger.debug(
          '🔔 WebSocket notification bridged to native: ${event.title}',
        );
      } else {
        AppLogger.debug(
          '⏭️ WebSocket notification skipped (priority: ${event.priority.name})',
        );
      }
    } catch (e) {
      AppLogger.error('❌ Error bridging WebSocket notification', e);
    }
  }

  /// Stop the bridge service
  Future<void> stop() async {
    if (!_isBridgeActive) return;

    await _webSocketSubscription?.cancel();
    _webSocketSubscription = null;
    _isBridgeActive = false;

    AppLogger.info('🛑 NotificationBridgeService stopped');
  }

  /// Check if bridge is active
  bool get isActive => _isBridgeActive;

  /// Get bridge status information
  NotificationBridgeStatus get status {
    return NotificationBridgeStatus(
      isActive: _isBridgeActive,
      isWebSocketConnected: _webSocketService.isConnected,
      isNotificationServiceInitialized: _notificationService.isInitialized,
      joinedRooms: _webSocketService.joinedRooms.length,
    );
  }

  /// Dispose resources
  void dispose() {
    unawaited(stop());
    _notificationService.dispose();
  }
}

/// Bridge status information
class NotificationBridgeStatus {
  final bool isActive;
  final bool isWebSocketConnected;
  final bool isNotificationServiceInitialized;
  final int joinedRooms;

  const NotificationBridgeStatus({
    required this.isActive,
    required this.isWebSocketConnected,
    required this.isNotificationServiceInitialized,
    required this.joinedRooms,
  });

  bool get isFullyOperational =>
      isActive && isWebSocketConnected && isNotificationServiceInitialized;

  @override
  String toString() {
    return 'NotificationBridgeStatus('
        'active: $isActive, '
        'webSocketConnected: $isWebSocketConnected, '
        'notificationServiceInitialized: $isNotificationServiceInitialized, '
        'joinedRooms: $joinedRooms'
        ')';
  }
}
