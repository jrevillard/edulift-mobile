import 'dart:async';
import '../auth_service.dart';
import '../../utils/app_logger.dart';
import 'unified_notification_service.dart';
import 'notification_bridge_service.dart';
import 'notification_permission_service.dart';

/// Service that handles the complete initialization of the notification system
///
/// This service orchestrates the initialization of all notification components
/// in the correct order and manages their lifecycle throughout the app.
///
/// **INITIALIZATION SEQUENCE:**
/// 1. Check and request notification permissions
/// 2. Initialize UnifiedNotificationService
/// 3. Initialize NotificationBridgeService
/// 4. Subscribe to appropriate FCM topics based on user context
/// 5. Start monitoring notification events
class NotificationInitializationService {
  final UnifiedNotificationService _unifiedService;
  final NotificationBridgeService _bridgeService;
  final NotificationPermissionService _permissionService;
  final AuthServiceImpl _authService;

  bool _isInitialized = false;
  StreamSubscription<String?>? _tokenSubscription;

  NotificationInitializationService({
    required UnifiedNotificationService unifiedService,
    required NotificationBridgeService bridgeService,
    required NotificationPermissionService permissionService,
    required AuthServiceImpl authService,
  }) : _unifiedService = unifiedService,
       _bridgeService = bridgeService,
       _permissionService = permissionService,
       _authService = authService;

  /// Initialize the complete notification system
  Future<NotificationInitializationResult> initialize() async {
    if (_isInitialized) {
      return NotificationInitializationResult.alreadyInitialized();
    }

    try {
      AppLogger.info('🚀 Starting notification system initialization...');

      // Step 1: Check notification permissions
      final permissionStatus = await _permissionService.checkPermissionStatus();

      AppLogger.debug(
        '📋 Notification permission status: ${permissionStatus.name}',
      );

      // Step 2: Request permissions if not granted (but don't block initialization)
      NotificationPermissionResult? permissionResult;
      if (permissionStatus == NotificationPermissionStatus.notDetermined) {
        permissionResult = await _permissionService.requestPermissions();

        AppLogger.debug(
          '✅ Permission request result: ${permissionResult.status.name}',
        );
      }

      // Step 3: Initialize unified notification service
      final unifiedInitialized = await _unifiedService.initialize();
      if (!unifiedInitialized) {
        return NotificationInitializationResult.failed(
          'Failed to initialize UnifiedNotificationService',
        );
      }

      // Step 4: Initialize bridge service
      await _bridgeService.initialize();

      // Step 5: Setup FCM token monitoring
      _setupTokenMonitoring();

      // Step 6: Subscribe to user-specific topics if authenticated
      await _subscribeToUserTopics();

      _isInitialized = true;

      AppLogger.info(
        '✅ Notification system initialization completed successfully',
      );

      return NotificationInitializationResult.success(
        permissionStatus: permissionResult?.status ?? permissionStatus,
        fcmToken: _unifiedService.fcmToken,
        bridgeActive: _bridgeService.isActive,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        '❌ Notification system initialization failed',
        e,
        stackTrace,
      );

      return NotificationInitializationResult.failed(e.toString());
    }
  }

  /// Setup FCM token monitoring
  void _setupTokenMonitoring() {
    unawaited(_tokenSubscription?.cancel());
    _tokenSubscription = _unifiedService.onTokenRefresh.listen((newToken) {
      AppLogger.debug('🔄 FCM Token updated: ${newToken?.substring(0, 20)}...');

      // Notify listeners or update server with new token
      _handleTokenRefresh(newToken);
    });
  }

  /// Handle FCM token refresh
  void _handleTokenRefresh(String? newToken) {
    // TODO: Send new token to server for push notification targeting
    // This would typically involve calling an API endpoint to update the user's FCM token
    if (newToken != null) {
      AppLogger.debug('📱 New FCM token ready for server registration');
    }
  }

  /// Subscribe to user-specific FCM topics
  Future<void> _subscribeToUserTopics() async {
    try {
      // Get current auth state
      final user = _authService.currentUser;
      if (user == null) {
        AppLogger.warning(
          '⚠️ No authenticated user - skipping topic subscriptions',
        );
        return;
      }

      // Subscribe to user-specific topic
      await _unifiedService.subscribeToTopic('user_${user.id}');

      // TODO: Subscribe to family topic - requires UserFamilyService integration
      // Family notifications will be handled via separate service
      // CLEAN ARCHITECTURE: Removed direct familyId access from User entity

      AppLogger.info(
        '📡 Subscribed to notification topics for user: ${user.id}',
      );
    } catch (e) {
      AppLogger.warning('⚠️ Error subscribing to topics: $e');
    }
  }

  /// Update topic subscriptions when user context changes
  Future<void> updateTopicSubscriptions({
    String? previousFamilyId,
    String? newFamilyId,
  }) async {
    try {
      // Unsubscribe from previous family topic
      if (previousFamilyId != null) {
        await _unifiedService.unsubscribeFromTopic('family_$previousFamilyId');
      }

      // Subscribe to new family topic
      if (newFamilyId != null) {
        await _unifiedService.subscribeToTopic('family_$newFamilyId');
      }

      AppLogger.info(
        '🔄 Updated family topic subscriptions: $previousFamilyId → $newFamilyId',
      );
    } catch (e) {
      AppLogger.warning('⚠️ Error updating topic subscriptions: $e');
    }
  }

  /// Shutdown the notification system
  Future<void> shutdown() async {
    if (!_isInitialized) return;

    try {
      await _tokenSubscription?.cancel();
      await _bridgeService.stop();
      _unifiedService.dispose();

      _isInitialized = false;

      AppLogger.info('🛑 Notification system shutdown completed');
    } catch (e) {
      AppLogger.warning('⚠️ Error during notification system shutdown: $e');
    }
  }

  /// Check if the system is fully operational
  bool get isFullyOperational {
    return _isInitialized &&
        _unifiedService.isInitialized &&
        _bridgeService.isActive;
  }

  /// Get comprehensive status
  NotificationSystemStatus get status {
    return NotificationSystemStatus(
      isInitialized: _isInitialized,
      unifiedServiceInitialized: _unifiedService.isInitialized,
      bridgeServiceActive: _bridgeService.isActive,
      fcmToken: _unifiedService.fcmToken,
    );
  }
}

/// Result of notification system initialization
class NotificationInitializationResult {
  final bool success;
  final String? error;
  final NotificationPermissionStatus? permissionStatus;
  final String? fcmToken;
  final bool bridgeActive;

  const NotificationInitializationResult._({
    required this.success,
    this.error,
    this.permissionStatus,
    this.fcmToken,
    this.bridgeActive = false,
  });

  factory NotificationInitializationResult.success({
    required NotificationPermissionStatus permissionStatus,
    String? fcmToken,
    bool bridgeActive = false,
  }) {
    return NotificationInitializationResult._(
      success: true,
      permissionStatus: permissionStatus,
      fcmToken: fcmToken,
      bridgeActive: bridgeActive,
    );
  }

  factory NotificationInitializationResult.failed(String error) {
    return NotificationInitializationResult._(success: false, error: error);
  }

  factory NotificationInitializationResult.alreadyInitialized() {
    return const NotificationInitializationResult._(success: true);
  }
}

/// Comprehensive notification system status
class NotificationSystemStatus {
  final bool isInitialized;
  final bool unifiedServiceInitialized;
  final bool bridgeServiceActive;
  final String? fcmToken;

  const NotificationSystemStatus({
    required this.isInitialized,
    required this.unifiedServiceInitialized,
    required this.bridgeServiceActive,
    this.fcmToken,
  });

  bool get isFullyOperational =>
      isInitialized && unifiedServiceInitialized && bridgeServiceActive;

  @override
  String toString() {
    return 'NotificationSystemStatus('
        'initialized: $isInitialized, '
        'unifiedService: $unifiedServiceInitialized, '
        'bridge: $bridgeServiceActive, '
        'hasToken: ${fcmToken != null}'
        ')';
  }
}
