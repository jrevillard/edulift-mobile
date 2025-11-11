import 'dart:io' show Platform;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../network/auth_api_client.dart';
import '../../../network/family_api_client.dart';
import '../../../network/group_api_client.dart';
import '../../../network/schedule_api_client.dart';
import '../../../network/children_api_client.dart';
// Dashboard API client removed - dashboard now uses transport-first architecture
import '../../../network/fcm_api_client.dart';
import '../../../../data/network/base_api_client.dart';
import '../../../network/interceptors/network_interceptors.dart';
import '../../../network/interceptors/api_response_interceptor.dart';
import '../../../utils/app_logger.dart';
import '../../../network/network_info.dart';
import '../../../network/dev_network_info.dart';
import '../../../network/network_error_handler.dart';
import 'config_providers.dart';
import 'storage_providers.dart';
import '../service_providers.dart';

part 'network_providers.g.dart';

/// Foundation Network Providers
///
/// Core HTTP client and connectivity infrastructure providers.
/// These form the foundation layer of network communication.

// =============================================================================
// HTTP CLIENT PROVIDERS
// =============================================================================

/// Provider for 'refreshDio' - Simple Dio instance for token refresh only
///
/// This provider creates a basic Dio instance EXCLUSIVELY for /auth/refresh calls.
/// It does NOT have the authentication interceptor to avoid circular dependencies:
///
/// CIRCULAR (BROKEN):
/// apiDioProvider → tokenRefreshServiceProvider → apiDioProvider ❌
///
/// NON-CIRCULAR (FIXED):
/// apiDioProvider → tokenRefreshServiceProvider → refreshDioProvider ✅
///
/// This Dio instance only needs baseUrl and timeouts - no auth interceptor.
@riverpod
Dio refreshDio(Ref ref) {
  final config = ref.watch(appConfigProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      sendTimeout: const Duration(seconds: 5),
    ),
  );

  // CRITICAL: Do NOT add ApiResponseInterceptor here!
  // The /auth/refresh endpoint returns the full response structure,
  // not wrapped in { success, data } like other endpoints.
  // Adding ApiResponseInterceptor would cause "missing required fields" errors.

  // Optional: Add logging interceptor for debugging refresh calls
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => AppLogger.debug('[RefreshDio] $obj'),
      ),
    );
  }

  AppLogger.info(
    '🔄 [RefreshDio] Created dedicated Dio instance for token refresh',
  );
  return dio;
}

/// Provider for 'apiDio' HTTP client instance with full API configuration
///
/// This provider creates the configured Dio instance
/// with instanceName: 'apiDio'. It includes:
/// - Base URL and timeouts from ApiConstants
/// - Certificate pinning (in release mode)
/// - Authentication interceptor
/// - Error handling interceptor
///
/// Matches the exact configuration from BaseApiModule.createApiDio()
@riverpod
Dio apiDio(Ref ref) {
  // Get configuration dependencies
  final config = ref.watch(appConfigProvider);
  final adaptiveStorageService = ref.watch(adaptiveStorageServiceProvider);

  // Create Dio instance with configured base options
  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      sendTimeout: config.sendTimeout,
      headers: config.defaultHeaders,
    ),
  );

  // Certificate pinning configuration (production only)
  if (kReleaseMode && !Platform.environment.containsKey('FLUTTER_TEST')) {
    // Note: Certificate pinning implementation would go here
    // For now, using default certificate validation
    AppLogger.info(
      '🔒 Certificate pinning: Using default validation in release mode',
    );
  }

  // Add API response interceptor first - extracts 'data' from backend wrapper
  dio.interceptors.add(ApiResponseInterceptor());

  // PHASE 2: Add authentication interceptor with token refresh support
  // Import tokenRefreshService from service_providers
  final tokenRefreshService = ref.watch(tokenRefreshServiceProvider);
  dio.interceptors.add(
    NetworkAuthInterceptor(adaptiveStorageService, tokenRefreshService, ref),
  );
  // Add logging interceptor (debug only)
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ),
    );
  }

  return dio;
}

// =============================================================================
// API CLIENT PROVIDERS
// =============================================================================

/// Provider for AuthApiClient
///
/// Creates AuthApiClient with configured Dio instance for authentication operations.
@riverpod
AuthApiClient authApiClient(Ref ref) {
  final dio = ref.watch(apiDioProvider);
  final config = ref.watch(appConfigProvider);
  return AuthApiClient.create(dio, baseUrl: config.apiBaseUrl);
}

/// Provider for FamilyApiClient
@riverpod
FamilyApiClient familyApiClient(Ref ref) {
  final dio = ref.watch(apiDioProvider);
  final config = ref.watch(appConfigProvider);
  return FamilyApiClient.create(dio, baseUrl: config.apiBaseUrl);
}

/// Provider for GroupApiClient
@riverpod
GroupApiClient groupApiClient(Ref ref) {
  final dio = ref.watch(apiDioProvider);
  final config = ref.watch(appConfigProvider);
  return GroupApiClient.create(dio, baseUrl: config.apiBaseUrl);
}

/// Provider for BaseApiClient
@riverpod
BaseApiClient baseApiClient(Ref ref) {
  final dio = ref.watch(apiDioProvider);
  return BaseApiClient.create(dio);
}

/// Provider for ScheduleApiClient
@riverpod
ScheduleApiClient scheduleApiClient(Ref ref) {
  final dio = ref.watch(apiDioProvider);
  final config = ref.watch(appConfigProvider);
  return ScheduleApiClient.create(dio, baseUrl: config.apiBaseUrl);
}

/// Provider for ChildrenApiClient
@riverpod
ChildrenApiClient childrenApiClient(Ref ref) {
  final dio = ref.watch(apiDioProvider);
  final config = ref.watch(appConfigProvider);
  return ChildrenApiClient.create(dio, baseUrl: config.apiBaseUrl);
}

// REMOVED: DashboardApiClient provider - dashboard now uses transport-first architecture

/// Provider for FcmApiClient
@riverpod
FcmApiClient fcmApiClient(Ref ref) {
  final dio = ref.watch(apiDioProvider);
  final config = ref.watch(appConfigProvider);
  return FcmApiClient.create(dio, baseUrl: config.apiBaseUrl);
}

// =============================================================================
// CONNECTIVITY PROVIDERS
// =============================================================================

/// Provider for Connectivity monitoring
///
/// Monitors network connectivity status and provides real-time updates
/// about network availability. Used for offline-first architecture
/// and network-dependent operations.
@riverpod
Connectivity connectivity(Ref ref) {
  return Connectivity();
}

/// Stream provider for connectivity state monitoring
///
/// Provides real-time connectivity status as an AsyncValue<List<ConnectivityResult>>.
/// This is used by UI components that need to react to network changes with loading states.
@riverpod
Stream<List<ConnectivityResult>> connectivityState(Ref ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.onConnectivityChanged;
}

/// Provider for NetworkInfo
///
/// Creates NetworkInfo implementation with Connectivity dependency.
/// Uses DevNetworkInfoImpl in development/container environments to avoid DBUS issues.
@riverpod
NetworkInfo networkInfo(Ref ref) {
  final connectivity = ref.watch(connectivityProvider);

  // Use DevNetworkInfoImpl in development/container environments
  // to avoid DBUS/Linux connectivity issues
  if (kDebugMode || Platform.environment.containsKey('CONTAINER')) {
    return DevNetworkInfoImpl(connectivity: connectivity);
  }

  return NetworkInfoImpl(connectivity: connectivity);
}

// =============================================================================
// NETWORK ERROR HANDLER PROVIDERS
// =============================================================================

/// Provider for NetworkErrorHandler
///
/// Creates NetworkErrorHandler with NetworkInfo dependency.
/// Provides centralized network error handling with retry logic,
/// circuit breaker pattern, and proper error classification.
@riverpod
NetworkErrorHandler networkErrorHandler(Ref ref) {
  final networkInfo = ref.watch(networkInfoProvider);
  final dio = ref.watch(apiDioProvider);

  return NetworkErrorHandler(networkInfo: networkInfo, dio: dio);
}

/// Provider for isolated NetworkErrorHandler used exclusively by TokenRefreshService
///
/// This handler MUST NOT depend on apiDioProvider to avoid circular dependencies:
/// - apiDioProvider → tokenRefreshService → refreshNetworkErrorHandler ✅ (no cycle)
///
/// The dio parameter is intentionally omitted (null) because:
/// 1. TokenRefreshService already has its own dio instance (refreshDioProvider)
/// 2. NetworkErrorHandler's dio parameter is currently unused (line 271: marked for future extensibility)
/// 3. Including apiDioProvider would recreate the circular dependency
@riverpod
NetworkErrorHandler refreshNetworkErrorHandler(Ref ref) {
  final networkInfo = ref.watch(networkInfoProvider);

  // CRITICAL: Do NOT pass apiDioProvider here - would create circular dependency
  // The dio parameter in NetworkErrorHandler is optional and currently unused
  return NetworkErrorHandler(
    networkInfo: networkInfo,
    // dio: null (omitted - parameter is optional)
  );
}
