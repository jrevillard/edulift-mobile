// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationPermissionStatusHash() =>
    r'ea96f2db7448aa678cc433f18928cd6b3c50c8c9';

/// Provider for notification permission status
///
/// Copied from [notificationPermissionStatus].
@ProviderFor(notificationPermissionStatus)
final notificationPermissionStatusProvider =
    AutoDisposeFutureProvider<NotificationPermissionStatus>.internal(
      notificationPermissionStatus,
      name: r'notificationPermissionStatusProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationPermissionStatusHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationPermissionStatusRef =
    AutoDisposeFutureProviderRef<NotificationPermissionStatus>;
String _$notificationsEnabledHash() =>
    r'3191c4fb8c95f7738f392861ffd6c7d1ba55fb66';

/// Provider for checking if notifications are effectively enabled
///
/// Copied from [notificationsEnabled].
@ProviderFor(notificationsEnabled)
final notificationsEnabledProvider = AutoDisposeFutureProvider<bool>.internal(
  notificationsEnabled,
  name: r'notificationsEnabledProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationsEnabledHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationsEnabledRef = AutoDisposeFutureProviderRef<bool>;
String _$notificationBridgeStatusHash() =>
    r'5c3eaeff0c480b2629831f6ebee8c388da544965';

/// Provider for notification bridge status
///
/// Copied from [notificationBridgeStatus].
@ProviderFor(notificationBridgeStatus)
final notificationBridgeStatusProvider =
    AutoDisposeProvider<NotificationBridgeStatus>.internal(
      notificationBridgeStatus,
      name: r'notificationBridgeStatusProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationBridgeStatusHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationBridgeStatusRef =
    AutoDisposeProviderRef<NotificationBridgeStatus>;
String _$fcmTokenHash() => r'79f739517fbd7932d19a2170652573151e8066fe';

/// Provider for FCM token
///
/// Copied from [fcmToken].
@ProviderFor(fcmToken)
final fcmTokenProvider = AutoDisposeProvider<String?>.internal(
  fcmToken,
  name: r'fcmTokenProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fcmTokenHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FcmTokenRef = AutoDisposeProviderRef<String?>;
String _$notificationActionEventsHash() =>
    r'bbd13a4666a1a5c64fbbe6cce7ccbf16e3d49e1c';

/// Provider for notification action events stream
///
/// Copied from [notificationActionEvents].
@ProviderFor(notificationActionEvents)
final notificationActionEventsProvider =
    AutoDisposeStreamProvider<NotificationActionEvent>.internal(
      notificationActionEvents,
      name: r'notificationActionEventsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationActionEventsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationActionEventsRef =
    AutoDisposeStreamProviderRef<NotificationActionEvent>;
String _$fcmTokenRefreshHash() => r'a6ae2ab48dec461952ceba396a2b8e18a32fc23e';

/// Provider for FCM token refresh stream
///
/// Copied from [fcmTokenRefresh].
@ProviderFor(fcmTokenRefresh)
final fcmTokenRefreshProvider = AutoDisposeStreamProvider<String?>.internal(
  fcmTokenRefresh,
  name: r'fcmTokenRefreshProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fcmTokenRefreshHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FcmTokenRefreshRef = AutoDisposeStreamProviderRef<String?>;
String _$shouldShowNotificationRationaleHash() =>
    r'c3dd0caac44e80909f45d8fd49da831c8e1153c0';

/// Provider for showing notification permission rationale
///
/// Copied from [shouldShowNotificationRationale].
@ProviderFor(shouldShowNotificationRationale)
final shouldShowNotificationRationaleProvider =
    AutoDisposeFutureProvider<bool>.internal(
      shouldShowNotificationRationale,
      name: r'shouldShowNotificationRationaleProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$shouldShowNotificationRationaleHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShouldShowNotificationRationaleRef = AutoDisposeFutureProviderRef<bool>;
String _$detailedNotificationPermissionInfoHash() =>
    r'3be0616d40848ab5c1227d5ff1ec1240ce6f367a';

/// Provider for detailed permission information
///
/// Copied from [detailedNotificationPermissionInfo].
@ProviderFor(detailedNotificationPermissionInfo)
final detailedNotificationPermissionInfoProvider =
    AutoDisposeFutureProvider<DetailedPermissionInfo>.internal(
      detailedNotificationPermissionInfo,
      name: r'detailedNotificationPermissionInfoProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$detailedNotificationPermissionInfoHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DetailedNotificationPermissionInfoRef =
    AutoDisposeFutureProviderRef<DetailedPermissionInfo>;
String _$notificationPermissionControllerHash() =>
    r'c98c1cbfd16242eee97e9cc1ce264073cb9f90ff';

/// Provider for requesting notification permissions
///
/// Copied from [NotificationPermissionController].
@ProviderFor(NotificationPermissionController)
final notificationPermissionControllerProvider =
    AutoDisposeNotifierProvider<
      NotificationPermissionController,
      AsyncValue<NotificationPermissionResult?>
    >.internal(
      NotificationPermissionController.new,
      name: r'notificationPermissionControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationPermissionControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NotificationPermissionController =
    AutoDisposeNotifier<AsyncValue<NotificationPermissionResult?>>;
String _$notificationSystemControllerHash() =>
    r'd04d306c08e524e5e7950aa301ab3781c14d2a0e';

/// Provider for initializing the notification system
///
/// Copied from [NotificationSystemController].
@ProviderFor(NotificationSystemController)
final notificationSystemControllerProvider =
    AutoDisposeNotifierProvider<
      NotificationSystemController,
      AsyncValue<bool>
    >.internal(
      NotificationSystemController.new,
      name: r'notificationSystemControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationSystemControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NotificationSystemController = AutoDisposeNotifier<AsyncValue<bool>>;
String _$fCMTopicControllerHash() =>
    r'58df1fe5f896a78a9b64e36033fd9e44f585a4f2';

/// Provider for managing FCM topics
///
/// Copied from [FCMTopicController].
@ProviderFor(FCMTopicController)
final fCMTopicControllerProvider =
    AutoDisposeNotifierProvider<FCMTopicController, Set<String>>.internal(
      FCMTopicController.new,
      name: r'fCMTopicControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$fCMTopicControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FCMTopicController = AutoDisposeNotifier<Set<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
