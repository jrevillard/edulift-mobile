# Notification Service Interface Definitions

## Core Service Interfaces

### 1. UnifiedNotificationService Interface

```dart
// /lib/core/services/notifications/unified_notification_service.dart
abstract class IUnifiedNotificationService {
  /// Initialize the unified notification system
  Future<void> initialize();
  
  /// Check and request permissions if needed
  Future<NotificationPermissionStatus> ensurePermissions();
  
  /// Show a native notification from a WebSocket event
  Future<void> showNotification(RealtimeNotificationEvent event);
  
  /// Handle notification tap/action
  Future<void> handleNotificationAction(String notificationId, Map<String, String>? payload);
  
  /// Get current notification permission status
  Stream<NotificationPermissionStatus> get permissionStatus;
  
  /// Get unread notification count
  Stream<int> get unreadCount;
  
  /// Clear all notifications
  Future<void> clearAllNotifications();
  
  /// Dispose resources
  Future<void> dispose();
}

class UnifiedNotificationService implements IUnifiedNotificationService {
  final RealtimeWebSocketService _webSocketService;
  final INotificationPermissionService _permissionService;
  final INotificationDeliveryService _deliveryService;
  final INotificationActionService _actionService;
  final INotificationPersistenceService _persistenceService;
  final INotificationBadgeService _badgeService;
  final IBackgroundNotificationService _backgroundService;
  
  StreamSubscription<RealtimeNotificationEvent>? _webSocketSubscription;
  StreamSubscription<BackgroundNotificationEvent>? _backgroundSubscription;
  
  UnifiedNotificationService({
    required RealtimeWebSocketService webSocketService,
    required INotificationPermissionService permissionService,
    required INotificationDeliveryService deliveryService,
    required INotificationActionService actionService,
    required INotificationPersistenceService persistenceService,
    required INotificationBadgeService badgeService,
    required IBackgroundNotificationService backgroundService,
  })  : _webSocketService = webSocketService,
        _permissionService = permissionService,
        _deliveryService = deliveryService,
        _actionService = actionService,
        _persistenceService = persistenceService,
        _badgeService = badgeService,
        _backgroundService = backgroundService;

  @override
  Future<void> initialize() async {
    // Initialize all sub-services
    await _permissionService.initialize();
    await _deliveryService.initialize();
    await _actionService.initialize();
    await _persistenceService.initialize();
    await _badgeService.initialize();
    await _backgroundService.initialize();
    
    // Subscribe to WebSocket notifications
    _webSocketSubscription = _webSocketService.notifications.listen(_handleWebSocketNotification);
    
    // Subscribe to background notifications
    _backgroundSubscription = _webSocketService.backgroundNotifications?.listen(_handleBackgroundNotification);
    
    // Update badge count on startup
    final unreadCount = await _persistenceService.getUnreadCount();
    await _badgeService.updateBadgeCount(unreadCount);
  }
  
  Future<void> _handleWebSocketNotification(RealtimeNotificationEvent event) async {
    // Save notification for persistence
    await _persistenceService.saveNotification(event);
    
    // Show native notification if app is in background or high priority
    if (_shouldShowNativeNotification(event)) {
      await showNotification(event);
    }
    
    // Update badge count
    final unreadCount = await _persistenceService.getUnreadCount();
    await _badgeService.updateBadgeCount(unreadCount);
  }
  
  Future<void> _handleBackgroundNotification(BackgroundNotificationEvent event) async {
    if (event.shouldShowNative) {
      await showNotification(event.originalEvent);
    }
  }
  
  bool _shouldShowNativeNotification(RealtimeNotificationEvent event) {
    // Show native notifications for high-priority events or when app is backgrounded
    return event.priority == NotificationPriority.high ||
           event.priority == NotificationPriority.urgent ||
           _backgroundService.isAppInBackground;
  }
  
  @override
  Future<void> showNotification(RealtimeNotificationEvent event) async {
    final permissionStatus = await _permissionService.checkPermissions();
    if (permissionStatus != NotificationPermissionStatus.authorized) {
      return;
    }
    
    await _deliveryService.showNotification(event);
  }
}
```

### 2. Notification Permission Service

```dart
// /lib/core/services/notifications/notification_permission_service.dart
enum NotificationPermissionStatus {
  notDetermined,
  denied,
  authorized,
  provisional, // iOS only
  restricted, // iOS only
}

abstract class INotificationPermissionService {
  Future<void> initialize();
  Future<NotificationPermissionStatus> checkPermissions();
  Future<NotificationPermissionStatus> requestPermissions();
  Future<bool> openAppSettings();
  Stream<NotificationPermissionStatus> get statusStream;
}

class NotificationPermissionService implements INotificationPermissionService {
  final FlutterLocalNotificationsPlugin _plugin;
  final StreamController<NotificationPermissionStatus> _statusController;
  
  NotificationPermissionService()
      : _plugin = FlutterLocalNotificationsPlugin(),
        _statusController = StreamController<NotificationPermissionStatus>.broadcast();
  
  @override
  Stream<NotificationPermissionStatus> get statusStream => _statusController.stream;
  
  @override
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _plugin.initialize(initSettings);
  }
  
  @override
  Future<NotificationPermissionStatus> checkPermissions() async {
    if (Platform.isIOS) {
      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final result = await iosPlugin.checkPermissions();
        return _mapIOSPermissions(result);
      }
    } else if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final result = await androidPlugin.areNotificationsEnabled();
        return result ?? false 
            ? NotificationPermissionStatus.authorized 
            : NotificationPermissionStatus.denied;
      }
    }
    
    return NotificationPermissionStatus.notDetermined;
  }
  
  @override
  Future<NotificationPermissionStatus> requestPermissions() async {
    if (Platform.isIOS) {
      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final result = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        final status = _mapIOSPermissions(result);
        _statusController.add(status);
        return status;
      }
    } else if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final result = await androidPlugin.requestNotificationsPermission();
        final status = result ?? false 
            ? NotificationPermissionStatus.authorized 
            : NotificationPermissionStatus.denied;
        _statusController.add(status);
        return status;
      }
    }
    
    return NotificationPermissionStatus.denied;
  }
  
  NotificationPermissionStatus _mapIOSPermissions(IOSPermissionRequestResult? result) {
    if (result == null) return NotificationPermissionStatus.notDetermined;
    
    if (result.alert && result.badge && result.sound) {
      return NotificationPermissionStatus.authorized;
    } else if (result.alert || result.badge || result.sound) {
      return NotificationPermissionStatus.provisional;
    } else {
      return NotificationPermissionStatus.denied;
    }
  }
}
```

### 3. Notification Delivery Service

```dart
// /lib/core/services/notifications/notification_delivery_service.dart
abstract class INotificationDeliveryService {
  Future<void> initialize();
  Future<void> showNotification(RealtimeNotificationEvent event);
  Future<void> cancelNotification(String notificationId);
  Future<void> cancelAllNotifications();
}

class NotificationDeliveryService implements INotificationDeliveryService {
  final FlutterLocalNotificationsPlugin _plugin;
  final INotificationChannelManager _channelManager;
  
  NotificationDeliveryService({
    required INotificationChannelManager channelManager,
  })  : _plugin = FlutterLocalNotificationsPlugin(),
        _channelManager = channelManager;
  
  @override
  Future<void> initialize() async {
    await _channelManager.createChannels();
  }
  
  @override
  Future<void> showNotification(RealtimeNotificationEvent event) async {
    final channelConfig = _channelManager.getChannelForEvent(event);
    final notificationId = event.id.hashCode;
    
    final androidDetails = AndroidNotificationDetails(
      channelConfig.channelId,
      channelConfig.channelName,
      channelDescription: channelConfig.channelDescription,
      importance: channelConfig.importance,
      priority: channelConfig.priority,
      enableVibration: channelConfig.enableVibration,
      enableLights: true,
      ledColor: channelConfig.ledColor,
      showBadge: channelConfig.showBadge,
      actions: _buildAndroidActions(event),
    );
    
    final iosDetails = DarwinNotificationDetails(
      presentAlert: channelConfig.presentAlert,
      presentBadge: channelConfig.presentBadge,
      presentSound: channelConfig.presentSound,
      sound: channelConfig.soundAsset,
      categoryIdentifier: channelConfig.channelId,
    );
    
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    final payload = _buildNotificationPayload(event);
    
    await _plugin.show(
      notificationId,
      event.title,
      event.message,
      notificationDetails,
      payload: jsonEncode(payload),
    );
  }
  
  List<AndroidNotificationAction> _buildAndroidActions(RealtimeNotificationEvent event) {
    final actions = <AndroidNotificationAction>[];
    
    // Add action buttons based on notification type
    switch (event.type) {
      case 'INVITATION_NOTIFICATION':
        actions.addAll([
          const AndroidNotificationAction(
            'accept_invitation',
            'Accept',
            allowGeneratedReplies: false,
          ),
          const AndroidNotificationAction(
            'decline_invitation', 
            'Decline',
            allowGeneratedReplies: false,
          ),
        ]);
        break;
      case 'SCHEDULE_CONFLICT':
        actions.add(
          const AndroidNotificationAction(
            'view_conflict',
            'View Details',
            allowGeneratedReplies: false,
          ),
        );
        break;
    }
    
    return actions;
  }
  
  Map<String, String> _buildNotificationPayload(RealtimeNotificationEvent event) {
    return {
      'notificationId': event.id,
      'eventType': event.type,
      'actionUrl': event.actionUrl ?? '',
      'priority': event.priority.name,
      if (event.metadata != null)
        ...event.metadata!.map((key, value) => MapEntry(key, value.toString())),
    };
  }
}
```

### 4. Notification Channel Manager

```dart
// /lib/core/services/notifications/notification_channel_manager.dart
enum NotificationChannelType {
  invitations,
  scheduleUpdates,
  conflicts,
  emergencyAlerts,
  systemNotifications,
}

class NotificationChannelConfig {
  final String channelId;
  final String channelName;
  final String channelDescription;
  final Importance importance;
  final Priority priority;
  final bool enableVibration;
  final bool enableSound;
  final String? soundAsset;
  final Color? ledColor;
  final bool showBadge;
  
  // iOS-specific
  final bool presentAlert;
  final bool presentBadge;
  final bool presentSound;
  
  const NotificationChannelConfig({
    required this.channelId,
    required this.channelName,
    required this.channelDescription,
    required this.importance,
    required this.priority,
    this.enableVibration = true,
    this.enableSound = true,
    this.soundAsset,
    this.ledColor,
    this.showBadge = true,
    this.presentAlert = true,
    this.presentBadge = true,
    this.presentSound = true,
  });
}

abstract class INotificationChannelManager {
  Future<void> createChannels();
  NotificationChannelConfig getChannelForEvent(RealtimeNotificationEvent event);
  Future<void> updateChannelSettings(String channelId, NotificationChannelConfig config);
}

class NotificationChannelManager implements INotificationChannelManager {
  final FlutterLocalNotificationsPlugin _plugin;
  
  static const Map<NotificationChannelType, NotificationChannelConfig> _channelConfigs = {
    NotificationChannelType.invitations: NotificationChannelConfig(
      channelId: 'invitations',
      channelName: 'Invitations',
      channelDescription: 'Family and group invitations that require your attention',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      enableSound: true,
      ledColor: Colors.blue,
    ),
    NotificationChannelType.scheduleUpdates: NotificationChannelConfig(
      channelId: 'schedule_updates',
      channelName: 'Schedule Updates', 
      channelDescription: 'Updates to family and group schedules',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      enableVibration: true,
      enableSound: true,
      ledColor: Colors.green,
    ),
    NotificationChannelType.conflicts: NotificationChannelConfig(
      channelId: 'conflicts',
      channelName: 'Schedule Conflicts',
      channelDescription: 'Urgent notifications about scheduling conflicts',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      enableSound: true,
      ledColor: Colors.red,
    ),
    NotificationChannelType.emergencyAlerts: NotificationChannelConfig(
      channelId: 'emergency_alerts',
      channelName: 'Emergency Alerts',
      channelDescription: 'Critical emergency notifications',
      importance: Importance.max,
      priority: Priority.max,
      enableVibration: true,
      enableSound: true,
      ledColor: Colors.red,
    ),
    NotificationChannelType.systemNotifications: NotificationChannelConfig(
      channelId: 'system_notifications',
      channelName: 'System Notifications',
      channelDescription: 'General system notifications and updates',
      importance: Importance.low,
      priority: Priority.low,
      enableVibration: false,
      enableSound: false,
      ledColor: Colors.grey,
    ),
  };
  
  NotificationChannelManager() : _plugin = FlutterLocalNotificationsPlugin();
  
  @override
  Future<void> createChannels() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final androidChannels = _channelConfigs.values.map((config) {
        return AndroidNotificationChannel(
          config.channelId,
          config.channelName,
          description: config.channelDescription,
          importance: config.importance,
          enableVibration: config.enableVibration,
          enableLights: true,
          ledColor: config.ledColor,
          showBadge: config.showBadge,
          sound: config.soundAsset != null 
              ? RawResourceAndroidNotificationSound(config.soundAsset!)
              : null,
        );
      }).toList();
      
      for (final channel in androidChannels) {
        await androidPlugin.createNotificationChannel(channel);
      }
    }
    
    // iOS notification categories
    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final iosCategories = _buildIOSCategories();
      await iosPlugin.setNotificationCategories(iosCategories);
    }
  }
  
  List<DarwinNotificationCategory> _buildIOSCategories() {
    return [
      DarwinNotificationCategory(
        'invitations',
        actions: [
          DarwinNotificationAction.plain(
            'accept_invitation',
            'Accept',
            options: {DarwinNotificationActionOption.foreground},
          ),
          DarwinNotificationAction.plain(
            'decline_invitation',
            'Decline',
            options: {DarwinNotificationActionOption.destructive},
          ),
        ],
        options: {DarwinNotificationCategoryOption.customDismissAction},
      ),
      DarwinNotificationCategory(
        'conflicts',
        actions: [
          DarwinNotificationAction.plain(
            'view_conflict',
            'View Details',
            options: {DarwinNotificationActionOption.foreground},
          ),
        ],
      ),
    ];
  }
  
  @override
  NotificationChannelConfig getChannelForEvent(RealtimeNotificationEvent event) {
    final channelType = _getChannelTypeFromEvent(event);
    return _channelConfigs[channelType]!;
  }
  
  NotificationChannelType _getChannelTypeFromEvent(RealtimeNotificationEvent event) {
    // Map WebSocket event types to notification channels
    switch (event.type) {
      case 'INVITATION_NOTIFICATION':
      case NotificationTypes.INVITATION_NOTIFICATION:
        return NotificationChannelType.invitations;
      case 'SCHEDULE_CONFLICT':
      case NotificationTypes.SCHEDULE_CONFLICT:
        return NotificationChannelType.conflicts;
      case 'SCHEDULE_PUBLISHED':
      case NotificationTypes.SCHEDULE_PUBLISHED:
        return NotificationChannelType.scheduleUpdates;
      case NotificationTypes.CAPACITY_WARNING:
        return NotificationChannelType.conflicts;
      default:
        return NotificationChannelType.systemNotifications;
    }
  }
}
```

### 5. Notification Action Service

```dart
// /lib/core/services/notifications/notification_action_service.dart
abstract class INotificationActionService {
  Future<void> initialize();
  Future<void> handleNotificationTap(String notificationId, Map<String, String>? payload);
  Future<void> handleNotificationAction(String actionId, String notificationId, Map<String, String>? payload);
}

class NotificationActionService implements INotificationActionService {
  final Ref _ref;
  
  NotificationActionService(this._ref);
  
  @override
  Future<void> initialize() async {
    // Set up notification tap handler
    final plugin = FlutterLocalNotificationsPlugin();
    
    // Handle notification taps when app is running
    await plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
  }
  
  void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      final payloadMap = Map<String, String>.from(jsonDecode(payload));
      
      if (response.actionId != null) {
        handleNotificationAction(response.actionId!, response.id.toString(), payloadMap);
      } else {
        handleNotificationTap(response.id.toString(), payloadMap);
      }
    }
  }
  
  @override
  Future<void> handleNotificationTap(String notificationId, Map<String, String>? payload) async {
    if (payload == null) return;
    
    final eventType = payload['eventType'];
    final actionUrl = payload['actionUrl'];
    
    // Convert to NavigationIntent and trigger navigation
    final navigationIntent = _mapToNavigationIntent(eventType, payload);
    if (navigationIntent != null) {
      _ref.read(authStateProvider.notifier).setNavigationIntent(
        navigationIntent,
        param: _extractNavigationParam(eventType, payload),
      );
    }
    
    // Mark notification as read
    // await _persistenceService.markAsRead(notificationId);
  }
  
  @override
  Future<void> handleNotificationAction(String actionId, String notificationId, Map<String, String>? payload) async {
    if (payload == null) return;
    
    final eventType = payload['eventType'];
    
    switch (actionId) {
      case 'accept_invitation':
        await _handleAcceptInvitation(payload);
        break;
      case 'decline_invitation':
        await _handleDeclineInvitation(payload);
        break;
      case 'view_conflict':
        await _handleViewConflict(payload);
        break;
      default:
        // Fallback to regular notification tap handling
        await handleNotificationTap(notificationId, payload);
    }
  }
  
  NavigationIntent? _mapToNavigationIntent(String? eventType, Map<String, String> payload) {
    switch (eventType) {
      case 'INVITATION_NOTIFICATION':
        final invitationType = payload['invitationType'];
        return invitationType == 'family' 
            ? NavigationIntent.toFamilyJoin
            : NavigationIntent.toGroups;
      case 'SCHEDULE_CONFLICT':
        return NavigationIntent.toSchedule;
      case 'SCHEDULE_PUBLISHED':
        return NavigationIntent.toSchedule;
      case 'GROUP_MEMBERS_UPDATED':
        return NavigationIntent.toGroups;
      default:
        return NavigationIntent.toDashboard;
    }
  }
  
  String? _extractNavigationParam(String? eventType, Map<String, String> payload) {
    switch (eventType) {
      case 'INVITATION_NOTIFICATION':
        return payload['invitationId'];
      case 'SCHEDULE_CONFLICT':
        return payload['scheduleSlotId'];
      default:
        return payload['actionUrl'];
    }
  }
  
  Future<void> _handleAcceptInvitation(Map<String, String> payload) async {
    final invitationId = payload['invitationId'];
    if (invitationId != null) {
      // Navigate to invitation acceptance flow
      _ref.read(authStateProvider.notifier).setNavigationIntent(
        NavigationIntent.toFamilyJoin,
        param: invitationId,
      );
    }
  }
  
  Future<void> _handleDeclineInvitation(Map<String, String> payload) async {
    final invitationId = payload['invitationId'];
    // Could show decline reason dialog or handle silently
    // For now, just navigate to family page
    _ref.read(authStateProvider.notifier).setNavigationIntent(
      NavigationIntent.toFamily,
    );
  }
  
  Future<void> _handleViewConflict(Map<String, String> payload) async {
    final scheduleSlotId = payload['scheduleSlotId'];
    _ref.read(authStateProvider.notifier).setNavigationIntent(
      NavigationIntent.toSchedule,
      param: scheduleSlotId,
    );
  }
}
```

## Integration Pattern Summary

### WebSocket Bridge Pattern
```dart
// Enhanced RealtimeWebSocketService (minimal addition)
class RealtimeWebSocketService {
  // ... existing 737+ lines preserved ...
  
  // Add this stream for background notifications
  final StreamController<BackgroundNotificationEvent> _backgroundNotificationController =
      StreamController<BackgroundNotificationEvent>.broadcast();
  
  Stream<BackgroundNotificationEvent> get backgroundNotifications =>
      _backgroundNotificationController.stream;
  
  // Modify existing _handleIncomingMessage method (add 3 lines)
  void _handleIncomingMessage(Map<String, dynamic> data) {
    // ... existing code preserved ...
    
    // NEW: For high-priority notifications, also emit background event
    if (type == SocketEvents.NOTIFICATION) {
      final event = RealtimeNotificationEvent(/* ... existing parsing ... */);
      _notificationController.add(event); // EXISTING
      
      // NEW: Background notification handling
      if (event.priority == NotificationPriority.high || 
          event.priority == NotificationPriority.urgent) {
        _backgroundNotificationController.add(
          BackgroundNotificationEvent(
            originalEvent: event,
            shouldShowNative: !_isAppInForeground(),
          ),
        );
      }
    }
  }
  
  // NEW: Helper method
  bool _isAppInForeground() {
    return WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
  }
}

class BackgroundNotificationEvent {
  final RealtimeNotificationEvent originalEvent;
  final bool shouldShowNative;
  
  const BackgroundNotificationEvent({
    required this.originalEvent,
    required this.shouldShowNative,
  });
}
```

This architecture preserves the existing 737+ lines of WebSocket infrastructure while adding a complete native notification system that integrates seamlessly with the existing NavigationIntent system and badge infrastructure.