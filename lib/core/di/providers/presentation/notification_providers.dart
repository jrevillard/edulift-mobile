// =============================================================================
// NOTIFICATION PRESENTATION PROVIDERS
// =============================================================================

/// Notification-related presentation layer providers following Clean Architecture
///
/// This file contains all notification-related UI state providers for managing
/// notification permissions, status, and user interactions within the presentation layer.

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/notifications/unified_notification_service.dart';
import '../../../services/notifications/notification_permission_service.dart';
import '../../../services/notifications/notification_bridge_service.dart';
import '../service_providers.dart';

part 'notification_providers.g.dart';

// =============================================================================
// NOTIFICATION STATUS PROVIDERS
// =============================================================================

/// Provider for notification permission status
@riverpod
Future<NotificationPermissionStatus> notificationPermissionStatus(
  Ref ref,
) async {
  final permissionService = ref.read(notificationPermissionServiceProvider);
  return await permissionService.checkPermissionStatus();
}

/// Provider for checking if notifications are effectively enabled
@riverpod
Future<bool> notificationsEnabled(Ref ref) async {
  final permissionService = ref.read(notificationPermissionServiceProvider);
  return await permissionService.areNotificationsEffectivelyEnabled();
}

/// Provider for notification bridge status
@riverpod
NotificationBridgeStatus notificationBridgeStatus(Ref ref) {
  final bridgeService = ref.read(notificationBridgeServiceProvider);
  return bridgeService.status;
}

/// Provider for FCM token
@riverpod
String? fcmToken(Ref ref) {
  final notificationService = ref.read(unifiedNotificationServiceProvider);
  return notificationService.fcmToken;
}

// =============================================================================
// NOTIFICATION ACTION PROVIDERS
// =============================================================================

/// Provider for requesting notification permissions
@riverpod
class NotificationPermissionController
    extends _$NotificationPermissionController {
  @override
  AsyncValue<NotificationPermissionResult?> build() {
    return const AsyncValue.data(null);
  }

  /// Request notification permissions
  Future<void> requestPermissions({bool requestProvisional = false}) async {
    state = const AsyncValue.loading();

    try {
      final permissionService = ref.read(notificationPermissionServiceProvider);
      final result = await permissionService.requestPermissions(
        requestProvisional: requestProvisional,
      );

      state = AsyncValue.data(result);

      // Refresh other permission-related providers
      ref.invalidate(notificationPermissionStatusProvider);
      ref.invalidate(notificationsEnabledProvider);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Open app settings for notification permissions
  Future<void> openAppSettings() async {
    final permissionService = ref.read(notificationPermissionServiceProvider);
    await permissionService.openAppSettings();
  }
}

/// Provider for initializing the notification system
@riverpod
class NotificationSystemController extends _$NotificationSystemController {
  @override
  AsyncValue<bool> build() {
    return const AsyncValue.data(false);
  }

  /// Initialize the entire notification system
  Future<void> initialize() async {
    state = const AsyncValue.loading();

    try {
      // Initialize unified notification service
      final notificationService = ref.read(unifiedNotificationServiceProvider);
      final initialized = await notificationService.initialize();

      if (initialized) {
        // Initialize and start the bridge service
        final bridgeService = ref.read(notificationBridgeServiceProvider);
        await bridgeService.initialize();

        state = const AsyncValue.data(true);
      } else {
        state = const AsyncValue.data(false);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Stop the notification system
  Future<void> stop() async {
    try {
      final bridgeService = ref.read(notificationBridgeServiceProvider);
      await bridgeService.stop();

      state = const AsyncValue.data(false);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

/// Provider for managing FCM topics
@riverpod
class FCMTopicController extends _$FCMTopicController {
  @override
  Set<String> build() {
    return <String>{};
  }

  /// Subscribe to FCM topic
  Future<void> subscribeToTopic(String topic) async {
    final notificationService = ref.read(unifiedNotificationServiceProvider);
    await notificationService.subscribeToTopic(topic);

    state = {...state, topic};
  }

  /// Unsubscribe from FCM topic
  Future<void> unsubscribeFromTopic(String topic) async {
    final notificationService = ref.read(unifiedNotificationServiceProvider);
    await notificationService.unsubscribeFromTopic(topic);

    state = state.where((t) => t != topic).toSet();
  }

  /// Subscribe to family topic
  Future<void> subscribeToFamily(String familyId) async {
    await subscribeToTopic('family_$familyId');
  }

  /// Subscribe to group topic
  Future<void> subscribeToGroup(String groupId) async {
    await subscribeToTopic('group_$groupId');
  }

  /// Unsubscribe from family topic
  Future<void> unsubscribeFromFamily(String familyId) async {
    await unsubscribeFromTopic('family_$familyId');
  }

  /// Unsubscribe from group topic
  Future<void> unsubscribeFromGroup(String groupId) async {
    await unsubscribeFromTopic('group_$groupId');
  }
}

// =============================================================================
// NOTIFICATION UI STATE PROVIDERS
// =============================================================================

/// Provider for notification action events stream
@riverpod
Stream<NotificationActionEvent> notificationActionEvents(Ref ref) {
  final notificationService = ref.read(unifiedNotificationServiceProvider);
  return notificationService.onNotificationAction;
}

/// Provider for FCM token refresh stream
@riverpod
Stream<String?> fcmTokenRefresh(Ref ref) {
  final notificationService = ref.read(unifiedNotificationServiceProvider);
  return notificationService.onTokenRefresh;
}

/// Provider for showing notification permission rationale
@riverpod
Future<bool> shouldShowNotificationRationale(Ref ref) async {
  final permissionService = ref.read(notificationPermissionServiceProvider);
  return await permissionService.shouldShowRequestRationale();
}

/// Provider for detailed permission information
@riverpod
Future<DetailedPermissionInfo> detailedNotificationPermissionInfo(
  Ref ref,
) async {
  final permissionService = ref.read(notificationPermissionServiceProvider);
  return await permissionService.getDetailedPermissionInfo();
}
