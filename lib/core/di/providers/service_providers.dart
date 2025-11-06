// =============================================================================
// CORE SERVICE PROVIDERS - RIVERPOD MIGRATION
// =============================================================================

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/services/magic_link_service.dart';
import '../../services/user_family_service.dart';
import '../../services/user_status_service.dart';
import '../../network/error_handler_service.dart';
import '../../data/services/token_refresh_service.dart';
import '../../services/localization_service.dart';
import '../../domain/services/localization_service.dart'
    as localization_interface;
import '../../services/notifications/unified_notification_service.dart';
import '../../services/notifications/notification_permission_service.dart';
import '../../services/notifications/notification_bridge_service.dart';
import '../../network/websocket/realtime_websocket_service.dart';
import '../../network/websocket/websocket_service.dart';
// Note: ComprehensiveFamilyDataService interface doesn't exist yet, using stub
import '../../services/adaptive_storage_service.dart';
import '../../security/biometric_service.dart';
import 'foundation/network_providers.dart';
import 'foundation/storage_providers.dart';
import 'foundation/config_providers.dart';
import 'foundation/platform_providers.dart';
// Service implementations
import '../../services/auth_service.dart' as impl;
import '../../../data/auth/repositories/magic_link_repository.dart';
import '../../domain/services/comprehensive_family_data_service.dart';
import '../../../features/family/data/services/comprehensive_family_data_service_impl.dart';
// Repository imports removed - accessed via repository_providers
// UseCase imports
import '../../../features/family/domain/usecases/get_family_usecase.dart';
import '../../../features/family/domain/usecases/leave_family_usecase.dart';
import '../../../features/family/domain/usecases/clear_all_family_data_usecase.dart';
import '../../../features/family/domain/usecases/family_invitation_usecase.dart';
import '../../../features/dashboard/domain/usecases/get_7day_transport_summary.dart';
// Service imports
import '../../../features/family/domain/services/children_service.dart';
import '../../../features/family/domain/services/children_service_impl.dart';
// Data providers
import 'data/datasource_providers.dart';
import 'repository_providers.dart';
// Additional imports removed - not needed in providers
// import '../../domain/entities/family/family.dart' as domain; // Not used in stubs
// import '../../network/requests/family_requests.dart'; // Not needed
// Note: UserMessageService exists in ErrorHandlerService

part 'service_providers.g.dart';

// =============================================================================
// CORE AUTH SERVICE
// =============================================================================

/// UserStatusService provider - working implementation
@riverpod
UserStatusService userStatusService(Ref ref) {
  final authApiClient = ref.watch(authApiClientProvider);
  return UserStatusService(authApiClient);
}

/// BiometricService provider - use foundation provider
@riverpod
BiometricService biometricAuthService(Ref ref) {
  return ref.watch(biometricServiceProvider);
}

/// AdaptiveStorageService provider - use foundation provider
@riverpod
AdaptiveStorageService serviceAdaptiveStorage(Ref ref) {
  return ref.watch(adaptiveStorageServiceProvider);
}

/// AuthService provider - fully implemented core service with error handling
@riverpod
AuthService authService(Ref ref) {
  final authApiClient = ref.watch(authApiClientProvider);
  final authDatasource = ref.watch(authLocalDatasourceProvider);
  final userStatusService = ref.watch(userStatusServiceProvider);
  // BiometricService removed - will be added to AuthService constructor later if needed

  // CRITICAL: Add ErrorHandlerService for proper error handling
  final errorHandlerService = ref.watch(coreErrorHandlerServiceProvider);

  return impl.AuthServiceImpl(
    authApiClient,
    authDatasource,
    userStatusService,
    errorHandlerService,
  );
}

/// ErrorHandlerService provider - with actual UserMessageService
@riverpod
ErrorHandlerService coreErrorHandlerService(Ref ref) {
  final userMessageService = UserMessageService();
  return ErrorHandlerService(userMessageService);
}

// =============================================================================
// TOKEN REFRESH SERVICE (PHASE 2)
// =============================================================================

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
@riverpod
TokenRefreshService tokenRefreshService(Ref ref) {
  // CRITICAL FIX: Use refreshDioProvider to break circular dependency
  // refreshDioProvider is a dedicated Dio instance for /auth/refresh calls ONLY
  // It does NOT have the auth interceptor, which depends on this service
  final dio = ref.watch(refreshDioProvider);
  final authDatasource = ref.watch(authLocalDatasourceProvider);

  // CRITICAL FIX #2: Use refreshNetworkErrorHandlerProvider to break circular dependency
  // refreshNetworkErrorHandlerProvider does NOT depend on apiDioProvider
  // This completes the cycle break: apiDio → tokenRefreshService → refreshNetworkErrorHandler ✅
  final networkErrorHandler = ref.watch(refreshNetworkErrorHandlerProvider);

  return TokenRefreshService(dio, authDatasource, networkErrorHandler);
}

// =============================================================================
// MISSING SERVICE PROVIDERS - ADDING NOW
// =============================================================================

// OfflineSyncService REMOVED - obsolete code after Server-First migration
// See commit 9255710b: "migration Server First + suppression queue offline"

/// LocalizationService provider
@riverpod
localization_interface.LocalizationService localizationService(Ref ref) {
  final storage = ref.watch(adaptiveStorageServiceProvider);
  return LocalizationServiceImpl(storage);
}

/// RealtimeWebSocketService provider
@riverpod
RealtimeWebSocketService realtimeWebSocketService(Ref ref) {
  final config = ref.watch(appConfigProvider);
  return RealtimeWebSocketService(config);
}

/// ComprehensiveFamilyDataService provider
@riverpod
ComprehensiveFamilyDataService comprehensiveFamilyDataService(Ref ref) {
  final getFamilyUsecase = ref.watch(getFamilyUsecaseProvider);
  final clearAllFamilyDataUsecase = ref.watch(
    clearAllFamilyDataUsecaseProvider,
  );

  return ComprehensiveFamilyDataServiceImpl(
    getFamilyUsecase,
    clearAllFamilyDataUsecase,
  );
}

/// WebSocketService provider - returns proper WebSocketService instance
@riverpod
WebSocketService webSocketService(Ref ref) {
  final storage = ref.watch(adaptiveStorageServiceProvider);
  final config = ref.watch(appConfigProvider);
  return WebSocketService(storage, config);
}

// =============================================================================
// USE CASE PROVIDERS
// =============================================================================

/// GetFamilyUsecase provider - fully implemented with all dependencies
@riverpod
GetFamilyUsecase getFamilyUsecase(Ref ref) {
  final familyRepository = ref.watch(familyRepositoryProvider);
  // FamilyMembersRepository removed - family members accessed via family.members
  return GetFamilyUsecase(familyRepository);
}

/// ChildrenService provider - fully implemented
@riverpod
ChildrenService childrenService(Ref ref) {
  final repository = ref.watch(familyRepositoryProvider);
  return ChildrenServiceImpl(repository);
}

/// LeaveFamilyUsecase provider - fully implemented with dependencies
@riverpod
LeaveFamilyUsecase leaveFamilyUsecase(Ref ref) {
  final repository = ref.watch(familyRepositoryProvider);
  final familyDataService = ref.watch(comprehensiveFamilyDataServiceProvider);
  return LeaveFamilyUsecase(repository, familyDataService);
}

/// ClearAllFamilyDataUsecase provider
@riverpod
ClearAllFamilyDataUsecase clearAllFamilyDataUsecase(Ref ref) {
  final userFamilyService = ref.watch(userFamilyServiceProvider);
  // FamilyMembersRepository removed - family members accessed via family.members
  return ClearAllFamilyDataUsecase(userFamilyService);
}

/// InvitationUsecase provider - domain layer invitation business logic
@riverpod
InvitationUseCase invitationUsecase(Ref ref) {
  final repository = ref.watch(invitationRepositoryProvider);
  return InvitationUseCase(repository: repository);
}

/// Get7DayTransportSummary use case provider - dashboard transport aggregation
@riverpod
Get7DayTransportSummary get7DayTransportSummary(Ref ref) {
  final scheduleRepository = ref.watch(scheduleRepositoryProvider);
  final authService = ref.watch(authServiceProvider);
  return Get7DayTransportSummary(
    scheduleRepository: scheduleRepository,
    authService: authService,
  );
}

// NOTE: Repository providers moved to repository_providers.dart
// Import them from the main providers export

// =============================================================================
// MAGIC LINK SERVICES - ADDITIONAL PROVIDERS NEEDED
// =============================================================================

/// MagicLinkService provider - returns proper IMagicLinkService implementation
/// Migrated to NetworkErrorHandler for unified error handling
@riverpod
IMagicLinkService magicLinkService(Ref ref) {
  final authApiClient = ref.watch(authApiClientProvider);
  final authLocalDatasource = ref.watch(authLocalDatasourceProvider);
  final familyRepository = ref.watch(familyRepositoryProvider);
  final networkErrorHandler = ref.watch(networkErrorHandlerProvider);
  return MagicLinkRepositoryImpl(
    authApiClient,
    authLocalDatasource,
    familyRepository,
    networkErrorHandler,
  );
}

// =============================================================================
// FAMILY MEMBERS SERVICES - ADDITIONAL PROVIDERS NEEDED
// =============================================================================

// NOTE: Repository providers moved to repository_providers.dart
// Import them from the main providers export

// All stubs removed - using real implementations

// =============================================================================
// UNIFIED NOTIFICATION SYSTEM PROVIDERS
// =============================================================================

/// Flutter Local Notifications Plugin provider
@riverpod
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin(Ref ref) {
  return FlutterLocalNotificationsPlugin();
}

/// Firebase Messaging provider
@riverpod
FirebaseMessaging firebaseMessaging(Ref ref) {
  return FirebaseMessaging.instance;
}

/// Unified Notification Service - Bridges WebSocket → Native Notifications
@riverpod
UnifiedNotificationService unifiedNotificationService(Ref ref) {
  return UnifiedNotificationService(
    flutterLocalNotificationsPlugin: ref.read(
      flutterLocalNotificationsPluginProvider,
    ),
    firebaseMessaging: ref.read(firebaseMessagingProvider),
  );
}

/// Notification Permission Service
@riverpod
NotificationPermissionService notificationPermissionService(Ref ref) {
  return NotificationPermissionService(
    firebaseMessaging: ref.read(firebaseMessagingProvider),
  );
}

/// Notification Bridge Service - Connects WebSocket to Native Notifications
@riverpod
NotificationBridgeService notificationBridgeService(Ref ref) {
  return NotificationBridgeService(
    webSocketService: ref.read(realtimeWebSocketServiceProvider),
    notificationService: ref.read(unifiedNotificationServiceProvider),
  );
}
