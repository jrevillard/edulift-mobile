import 'package:permission_handler/permission_handler.dart' as permission;
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../utils/app_logger.dart';

/// Service for managing notification permissions across different platforms
///
/// Handles the complexity of notification permissions on iOS and Android,
/// providing a unified interface for permission requests and status checks.
class NotificationPermissionService {
  final FirebaseMessaging _firebaseMessaging;

  NotificationPermissionService({required FirebaseMessaging firebaseMessaging})
      : _firebaseMessaging = firebaseMessaging;

  /// Check current notification permission status
  Future<NotificationPermissionStatus> checkPermissionStatus() async {
    try {
      // Check Firebase messaging authorization
      final settings = await _firebaseMessaging.getNotificationSettings();

      // Check system notification permission
      final systemPermission = await permission.Permission.notification.status;

      AppLogger.debug('🔍 FCM Authorization: ${settings.authorizationStatus}');
      AppLogger.debug('🔍 System Permission: $systemPermission');

      // Determine overall permission status
      if (settings.authorizationStatus == AuthorizationStatus.authorized &&
          systemPermission == permission.PermissionStatus.granted) {
        return NotificationPermissionStatus.granted;
      } else if (settings.authorizationStatus == AuthorizationStatus.denied ||
          systemPermission == permission.PermissionStatus.permanentlyDenied) {
        return NotificationPermissionStatus.denied;
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        return NotificationPermissionStatus.provisional;
      } else {
        return NotificationPermissionStatus.notDetermined;
      }
    } catch (e) {
      AppLogger.error('❌ Error checking notification permissions', e);
      return NotificationPermissionStatus.error;
    }
  }

  /// Request notification permissions
  Future<NotificationPermissionResult> requestPermissions({
    bool requestProvisional = false,
  }) async {
    try {
      AppLogger.debug('📱 Requesting notification permissions...');

      // Request Firebase messaging permissions
      final settings = await _firebaseMessaging.requestPermission(
        provisional: requestProvisional,
      );

      // Request system notification permission
      final systemPermission =
          await permission.Permission.notification.request();

      AppLogger.debug(
        '✅ FCM Permission Result: ${settings.authorizationStatus}',
      );
      AppLogger.debug('✅ System Permission Result: $systemPermission');

      // Determine result
      final status = await checkPermissionStatus();

      return NotificationPermissionResult(
        status: status,
        firebaseAuthorizationStatus: settings.authorizationStatus,
        systemPermissionStatus: systemPermission,
        canShowSettings:
            await permission.Permission.notification.shouldShowRequestRationale,
      );
    } catch (e) {
      AppLogger.error('❌ Error requesting notification permissions', e);

      return NotificationPermissionResult(
        status: NotificationPermissionStatus.error,
        firebaseAuthorizationStatus: AuthorizationStatus.denied,
        systemPermissionStatus: permission.PermissionStatus.denied,
        canShowSettings: false,
        error: e.toString(),
      );
    }
  }

  /// Open app settings for notification permissions
  Future<bool> openAppSettings() async {
    try {
      return await permission.openAppSettings();
    } catch (e) {
      AppLogger.error('❌ Error opening app settings', e);
      return false;
    }
  }

  /// Check if we should show rationale for permission request
  Future<bool> shouldShowRequestRationale() async {
    try {
      return await permission
          .Permission.notification.shouldShowRequestRationale;
    } catch (e) {
      AppLogger.error('❌ Error checking rationale status', e);
      return false;
    }
  }

  /// Get detailed permission information
  Future<DetailedPermissionInfo> getDetailedPermissionInfo() async {
    try {
      final settings = await _firebaseMessaging.getNotificationSettings();
      final systemPermission = await permission.Permission.notification.status;

      return DetailedPermissionInfo(
        firebaseSettings: settings,
        systemPermissionStatus: systemPermission,
        alertSetting: settings.alert,
        badgeSetting: settings.badge,
        soundSetting: settings.sound,
        notificationCenterSetting: settings.notificationCenter,
        lockScreenSetting: settings.lockScreen,
        carPlaySetting: settings.carPlay,
        criticalAlertSetting: settings.criticalAlert,
        timeSensitiveSetting: settings.timeSensitive,
      );
    } catch (e) {
      AppLogger.error('❌ Error getting detailed permission info', e);

      return const DetailedPermissionInfo(
        firebaseSettings: NotificationSettings(
          authorizationStatus: AuthorizationStatus.denied,
          alert: AppleNotificationSetting.disabled,
          badge: AppleNotificationSetting.disabled,
          sound: AppleNotificationSetting.disabled,
          notificationCenter: AppleNotificationSetting.disabled,
          lockScreen: AppleNotificationSetting.disabled,
          carPlay: AppleNotificationSetting.disabled,
          criticalAlert: AppleNotificationSetting.disabled,
          announcement: AppleNotificationSetting.disabled,
          providesAppNotificationSettings: AppleNotificationSetting.disabled,
          showPreviews: AppleShowPreviewSetting.never,
          timeSensitive: AppleNotificationSetting.disabled,
        ),
        systemPermissionStatus: permission.PermissionStatus.denied,
      );
    }
  }

  /// Check if notifications are effectively enabled
  /// (user has granted permissions and notifications are not disabled)
  Future<bool> areNotificationsEffectivelyEnabled() async {
    final status = await checkPermissionStatus();
    return status == NotificationPermissionStatus.granted ||
        status == NotificationPermissionStatus.provisional;
  }

  /// Get user-friendly permission status description
  String getPermissionStatusDescription(NotificationPermissionStatus status) {
    switch (status) {
      case NotificationPermissionStatus.granted:
        return 'Notifications are enabled';
      case NotificationPermissionStatus.denied:
        return 'Notifications are disabled. You can enable them in Settings.';
      case NotificationPermissionStatus.provisional:
        return 'Notifications are enabled with limited features';
      case NotificationPermissionStatus.notDetermined:
        return 'Notification permissions not yet requested';
      case NotificationPermissionStatus.error:
        return 'Unable to determine notification permission status';
    }
  }

  /// Get recommended action for current permission status
  NotificationPermissionAction getRecommendedAction(
    NotificationPermissionStatus status,
  ) {
    switch (status) {
      case NotificationPermissionStatus.granted:
      case NotificationPermissionStatus.provisional:
        return NotificationPermissionAction.none;
      case NotificationPermissionStatus.notDetermined:
        return NotificationPermissionAction.requestPermission;
      case NotificationPermissionStatus.denied:
        return NotificationPermissionAction.openSettings;
      case NotificationPermissionStatus.error:
        return NotificationPermissionAction.retry;
    }
  }
}

/// Notification permission status
enum NotificationPermissionStatus {
  granted,
  denied,
  provisional,
  notDetermined,
  error,
}

/// Notification permission result
class NotificationPermissionResult {
  final NotificationPermissionStatus status;
  final AuthorizationStatus firebaseAuthorizationStatus;
  final permission.PermissionStatus systemPermissionStatus;
  final bool canShowSettings;
  final String? error;

  const NotificationPermissionResult({
    required this.status,
    required this.firebaseAuthorizationStatus,
    required this.systemPermissionStatus,
    required this.canShowSettings,
    this.error,
  });

  bool get isGranted => status == NotificationPermissionStatus.granted;
  bool get isDenied => status == NotificationPermissionStatus.denied;
  bool get isProvisional => status == NotificationPermissionStatus.provisional;
  bool get isNotDetermined =>
      status == NotificationPermissionStatus.notDetermined;
  bool get hasError => status == NotificationPermissionStatus.error;
}

/// Detailed permission information
class DetailedPermissionInfo {
  final NotificationSettings firebaseSettings;
  final permission.PermissionStatus systemPermissionStatus;
  final AppleNotificationSetting? alertSetting;
  final AppleNotificationSetting? badgeSetting;
  final AppleNotificationSetting? soundSetting;
  final AppleNotificationSetting? notificationCenterSetting;
  final AppleNotificationSetting? lockScreenSetting;
  final AppleNotificationSetting? carPlaySetting;
  final AppleNotificationSetting? criticalAlertSetting;
  final AppleNotificationSetting? timeSensitiveSetting;

  const DetailedPermissionInfo({
    required this.firebaseSettings,
    required this.systemPermissionStatus,
    this.alertSetting,
    this.badgeSetting,
    this.soundSetting,
    this.notificationCenterSetting,
    this.lockScreenSetting,
    this.carPlaySetting,
    this.criticalAlertSetting,
    this.timeSensitiveSetting,
  });
}

/// Recommended actions for permission management
enum NotificationPermissionAction {
  none,
  requestPermission,
  openSettings,
  retry,
}
