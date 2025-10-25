// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userStatusServiceHash() => r'ee00ae4833adcd5e7550439333fa104dad13beba';

/// UserStatusService provider - working implementation
///
/// Copied from [userStatusService].
@ProviderFor(userStatusService)
final userStatusServiceProvider =
    AutoDisposeProvider<UserStatusService>.internal(
  userStatusService,
  name: r'userStatusServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userStatusServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserStatusServiceRef = AutoDisposeProviderRef<UserStatusService>;
String _$biometricAuthServiceHash() =>
    r'a1197b2958bc16f60caa6ce15948d3bff7dd03ad';

/// BiometricService provider - use foundation provider
///
/// Copied from [biometricAuthService].
@ProviderFor(biometricAuthService)
final biometricAuthServiceProvider =
    AutoDisposeProvider<BiometricService>.internal(
  biometricAuthService,
  name: r'biometricAuthServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$biometricAuthServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BiometricAuthServiceRef = AutoDisposeProviderRef<BiometricService>;
String _$serviceAdaptiveStorageHash() =>
    r'263f500dc1757ddde7290ee9b8b7ce63e44a3657';

/// AdaptiveStorageService provider - use foundation provider
///
/// Copied from [serviceAdaptiveStorage].
@ProviderFor(serviceAdaptiveStorage)
final serviceAdaptiveStorageProvider =
    AutoDisposeProvider<AdaptiveStorageService>.internal(
  serviceAdaptiveStorage,
  name: r'serviceAdaptiveStorageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$serviceAdaptiveStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ServiceAdaptiveStorageRef
    = AutoDisposeProviderRef<AdaptiveStorageService>;
String _$authServiceHash() => r'98e649cb8fd55402e624b797eb38c7fefe766aa3';

/// AuthService provider - fully implemented core service with error handling
///
/// Copied from [authService].
@ProviderFor(authService)
final authServiceProvider = AutoDisposeProvider<AuthService>.internal(
  authService,
  name: r'authServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthServiceRef = AutoDisposeProviderRef<AuthService>;
String _$coreErrorHandlerServiceHash() =>
    r'734f42781c815f77b675d59e579f96f317455cf7';

/// ErrorHandlerService provider - with actual UserMessageService
///
/// Copied from [coreErrorHandlerService].
@ProviderFor(coreErrorHandlerService)
final coreErrorHandlerServiceProvider =
    AutoDisposeProvider<ErrorHandlerService>.internal(
  coreErrorHandlerService,
  name: r'coreErrorHandlerServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$coreErrorHandlerServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CoreErrorHandlerServiceRef
    = AutoDisposeProviderRef<ErrorHandlerService>;
String _$tokenRefreshServiceHash() =>
    r'61d12771e94aa0d8031e581db1ae094cd3a6537c';

/// TokenRefreshService provider - handles automatic token refresh
///
/// Phase 2 Implementation: Automatic token refresh support with robust retry logic
/// - Refreshes tokens before expiration (preemptive)
/// - Retries on 401 errors (reactive)
/// - Prevents race conditions with queue management
/// - 5 automatic retries with exponential backoff via NetworkErrorHandler
/// - Circuit breaker pattern to protect backend from cascading failures
///
/// CRITICAL: Uses refreshDioProvider instead of apiDioProvider to break circular dependency:
/// - apiDioProvider → tokenRefreshServiceProvider → refreshDioProvider ✅
/// - refreshDioProvider is a simple Dio WITHOUT auth interceptor
///
/// Copied from [tokenRefreshService].
@ProviderFor(tokenRefreshService)
final tokenRefreshServiceProvider =
    AutoDisposeProvider<TokenRefreshService>.internal(
  tokenRefreshService,
  name: r'tokenRefreshServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tokenRefreshServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TokenRefreshServiceRef = AutoDisposeProviderRef<TokenRefreshService>;
String _$localizationServiceHash() =>
    r'8b695d58ccb3e56768368aa1317f9e9b19a7b5f1';

/// LocalizationService provider
///
/// Copied from [localizationService].
@ProviderFor(localizationService)
final localizationServiceProvider =
    AutoDisposeProvider<localization_interface.LocalizationService>.internal(
  localizationService,
  name: r'localizationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$localizationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocalizationServiceRef
    = AutoDisposeProviderRef<localization_interface.LocalizationService>;
String _$realtimeWebSocketServiceHash() =>
    r'3d17772a013438028a3db671644ecae748195dc1';

/// RealtimeWebSocketService provider
///
/// Copied from [realtimeWebSocketService].
@ProviderFor(realtimeWebSocketService)
final realtimeWebSocketServiceProvider =
    AutoDisposeProvider<RealtimeWebSocketService>.internal(
  realtimeWebSocketService,
  name: r'realtimeWebSocketServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$realtimeWebSocketServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RealtimeWebSocketServiceRef
    = AutoDisposeProviderRef<RealtimeWebSocketService>;
String _$comprehensiveFamilyDataServiceHash() =>
    r'3d66038d915914a59b866b933cb3fe808aee5f2f';

/// ComprehensiveFamilyDataService provider
///
/// Copied from [comprehensiveFamilyDataService].
@ProviderFor(comprehensiveFamilyDataService)
final comprehensiveFamilyDataServiceProvider =
    AutoDisposeProvider<ComprehensiveFamilyDataService>.internal(
  comprehensiveFamilyDataService,
  name: r'comprehensiveFamilyDataServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$comprehensiveFamilyDataServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ComprehensiveFamilyDataServiceRef
    = AutoDisposeProviderRef<ComprehensiveFamilyDataService>;
String _$webSocketServiceHash() => r'271db1b5e695eeb6193af02f35b5958138040a00';

/// WebSocketService provider - returns proper WebSocketService instance
///
/// Copied from [webSocketService].
@ProviderFor(webSocketService)
final webSocketServiceProvider = AutoDisposeProvider<WebSocketService>.internal(
  webSocketService,
  name: r'webSocketServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$webSocketServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WebSocketServiceRef = AutoDisposeProviderRef<WebSocketService>;
String _$getFamilyUsecaseHash() => r'57e2109aa0d9aa11eac8c4dddf855bd018a3c533';

/// GetFamilyUsecase provider - fully implemented with all dependencies
///
/// Copied from [getFamilyUsecase].
@ProviderFor(getFamilyUsecase)
final getFamilyUsecaseProvider = AutoDisposeProvider<GetFamilyUsecase>.internal(
  getFamilyUsecase,
  name: r'getFamilyUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getFamilyUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetFamilyUsecaseRef = AutoDisposeProviderRef<GetFamilyUsecase>;
String _$childrenServiceHash() => r'c460620843efa68243eb14c693d938852d3117bc';

/// ChildrenService provider - fully implemented
///
/// Copied from [childrenService].
@ProviderFor(childrenService)
final childrenServiceProvider = AutoDisposeProvider<ChildrenService>.internal(
  childrenService,
  name: r'childrenServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$childrenServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ChildrenServiceRef = AutoDisposeProviderRef<ChildrenService>;
String _$leaveFamilyUsecaseHash() =>
    r'695f0baeff103e06173cf216fdda7916e4919987';

/// LeaveFamilyUsecase provider - fully implemented with dependencies
///
/// Copied from [leaveFamilyUsecase].
@ProviderFor(leaveFamilyUsecase)
final leaveFamilyUsecaseProvider =
    AutoDisposeProvider<LeaveFamilyUsecase>.internal(
  leaveFamilyUsecase,
  name: r'leaveFamilyUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$leaveFamilyUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LeaveFamilyUsecaseRef = AutoDisposeProviderRef<LeaveFamilyUsecase>;
String _$clearAllFamilyDataUsecaseHash() =>
    r'5cc3c64e5f8486a2a1abb00e13a2b56faf9612ff';

/// ClearAllFamilyDataUsecase provider
///
/// Copied from [clearAllFamilyDataUsecase].
@ProviderFor(clearAllFamilyDataUsecase)
final clearAllFamilyDataUsecaseProvider =
    AutoDisposeProvider<ClearAllFamilyDataUsecase>.internal(
  clearAllFamilyDataUsecase,
  name: r'clearAllFamilyDataUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$clearAllFamilyDataUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ClearAllFamilyDataUsecaseRef
    = AutoDisposeProviderRef<ClearAllFamilyDataUsecase>;
String _$invitationUsecaseHash() => r'7b0c84833d97054513a90fc2d226731cfbc06ed1';

/// InvitationUsecase provider - domain layer invitation business logic
///
/// Copied from [invitationUsecase].
@ProviderFor(invitationUsecase)
final invitationUsecaseProvider =
    AutoDisposeProvider<InvitationUseCase>.internal(
  invitationUsecase,
  name: r'invitationUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$invitationUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InvitationUsecaseRef = AutoDisposeProviderRef<InvitationUseCase>;
String _$magicLinkServiceHash() => r'd834788158e71929f0598f91d8e7d832e834abec';

/// MagicLinkService provider - returns proper IMagicLinkService implementation
/// Migrated to NetworkErrorHandler for unified error handling
///
/// Copied from [magicLinkService].
@ProviderFor(magicLinkService)
final magicLinkServiceProvider =
    AutoDisposeProvider<IMagicLinkService>.internal(
  magicLinkService,
  name: r'magicLinkServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$magicLinkServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MagicLinkServiceRef = AutoDisposeProviderRef<IMagicLinkService>;
String _$flutterLocalNotificationsPluginHash() =>
    r'7ddacc6af7d67f7f1a34d7166a7d48420e7fa892';

/// Flutter Local Notifications Plugin provider
///
/// Copied from [flutterLocalNotificationsPlugin].
@ProviderFor(flutterLocalNotificationsPlugin)
final flutterLocalNotificationsPluginProvider =
    AutoDisposeProvider<FlutterLocalNotificationsPlugin>.internal(
  flutterLocalNotificationsPlugin,
  name: r'flutterLocalNotificationsPluginProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$flutterLocalNotificationsPluginHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FlutterLocalNotificationsPluginRef
    = AutoDisposeProviderRef<FlutterLocalNotificationsPlugin>;
String _$firebaseMessagingHash() => r'6abf9bf6d98c4ba311760139587b2995df4c1508';

/// Firebase Messaging provider
///
/// Copied from [firebaseMessaging].
@ProviderFor(firebaseMessaging)
final firebaseMessagingProvider =
    AutoDisposeProvider<FirebaseMessaging>.internal(
  firebaseMessaging,
  name: r'firebaseMessagingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseMessagingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseMessagingRef = AutoDisposeProviderRef<FirebaseMessaging>;
String _$unifiedNotificationServiceHash() =>
    r'42693478fbd0c4bbf54bab5fb5a66fdcc294e846';

/// Unified Notification Service - Bridges WebSocket → Native Notifications
///
/// Copied from [unifiedNotificationService].
@ProviderFor(unifiedNotificationService)
final unifiedNotificationServiceProvider =
    AutoDisposeProvider<UnifiedNotificationService>.internal(
  unifiedNotificationService,
  name: r'unifiedNotificationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unifiedNotificationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnifiedNotificationServiceRef
    = AutoDisposeProviderRef<UnifiedNotificationService>;
String _$notificationPermissionServiceHash() =>
    r'57d5bae8f53c4347a2bef76edd1eb63746b14bf6';

/// Notification Permission Service
///
/// Copied from [notificationPermissionService].
@ProviderFor(notificationPermissionService)
final notificationPermissionServiceProvider =
    AutoDisposeProvider<NotificationPermissionService>.internal(
  notificationPermissionService,
  name: r'notificationPermissionServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationPermissionServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationPermissionServiceRef
    = AutoDisposeProviderRef<NotificationPermissionService>;
String _$notificationBridgeServiceHash() =>
    r'68761358e3f962500a3ff0ffa873d4d082fb500d';

/// Notification Bridge Service - Connects WebSocket to Native Notifications
///
/// Copied from [notificationBridgeService].
@ProviderFor(notificationBridgeService)
final notificationBridgeServiceProvider =
    AutoDisposeProvider<NotificationBridgeService>.internal(
  notificationBridgeService,
  name: r'notificationBridgeServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationBridgeServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationBridgeServiceRef
    = AutoDisposeProviderRef<NotificationBridgeService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
