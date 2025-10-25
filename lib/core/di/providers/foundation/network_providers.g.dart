// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$refreshDioHash() => r'b7df499e2b4a4a8fd80b48c5cfd6ea5e2993594d';

/// Foundation Network Providers
///
/// Core HTTP client and connectivity infrastructure providers.
/// These form the foundation layer of network communication.
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
///
/// Copied from [refreshDio].
@ProviderFor(refreshDio)
final refreshDioProvider = AutoDisposeProvider<Dio>.internal(
  refreshDio,
  name: r'refreshDioProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$refreshDioHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RefreshDioRef = AutoDisposeProviderRef<Dio>;
String _$apiDioHash() => r'c22bed161665709b0764e6ca3b4e30c6a3f9ca77';

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
///
/// Copied from [apiDio].
@ProviderFor(apiDio)
final apiDioProvider = AutoDisposeProvider<Dio>.internal(
  apiDio,
  name: r'apiDioProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$apiDioHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ApiDioRef = AutoDisposeProviderRef<Dio>;
String _$authApiClientHash() => r'2d0b0572cf75c861464cd050e008911d358ec18c';

/// Provider for AuthApiClient
///
/// Creates AuthApiClient with configured Dio instance for authentication operations.
///
/// Copied from [authApiClient].
@ProviderFor(authApiClient)
final authApiClientProvider = AutoDisposeProvider<AuthApiClient>.internal(
  authApiClient,
  name: r'authApiClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authApiClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthApiClientRef = AutoDisposeProviderRef<AuthApiClient>;
String _$familyApiClientHash() => r'ef799a004c60388c8c21693023f52ac9e1fcc4de';

/// Provider for FamilyApiClient
///
/// Copied from [familyApiClient].
@ProviderFor(familyApiClient)
final familyApiClientProvider = AutoDisposeProvider<FamilyApiClient>.internal(
  familyApiClient,
  name: r'familyApiClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$familyApiClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FamilyApiClientRef = AutoDisposeProviderRef<FamilyApiClient>;
String _$groupApiClientHash() => r'64cf78d38b28efaba3d829c4a75ddd838ec0f772';

/// Provider for GroupApiClient
///
/// Copied from [groupApiClient].
@ProviderFor(groupApiClient)
final groupApiClientProvider = AutoDisposeProvider<GroupApiClient>.internal(
  groupApiClient,
  name: r'groupApiClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$groupApiClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GroupApiClientRef = AutoDisposeProviderRef<GroupApiClient>;
String _$baseApiClientHash() => r'eaafc9c193960e024fcb90e156eba15e4ddffcf9';

/// Provider for BaseApiClient
///
/// Copied from [baseApiClient].
@ProviderFor(baseApiClient)
final baseApiClientProvider = AutoDisposeProvider<BaseApiClient>.internal(
  baseApiClient,
  name: r'baseApiClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$baseApiClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BaseApiClientRef = AutoDisposeProviderRef<BaseApiClient>;
String _$scheduleApiClientHash() => r'd54ec245546233f45fd90848197818f3f7e270c9';

/// Provider for ScheduleApiClient
///
/// Copied from [scheduleApiClient].
@ProviderFor(scheduleApiClient)
final scheduleApiClientProvider =
    AutoDisposeProvider<ScheduleApiClient>.internal(
      scheduleApiClient,
      name: r'scheduleApiClientProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$scheduleApiClientHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ScheduleApiClientRef = AutoDisposeProviderRef<ScheduleApiClient>;
String _$childrenApiClientHash() => r'20e69516d85307215a658e1df24c68922b165e15';

/// Provider for ChildrenApiClient
///
/// Copied from [childrenApiClient].
@ProviderFor(childrenApiClient)
final childrenApiClientProvider =
    AutoDisposeProvider<ChildrenApiClient>.internal(
      childrenApiClient,
      name: r'childrenApiClientProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$childrenApiClientHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ChildrenApiClientRef = AutoDisposeProviderRef<ChildrenApiClient>;
String _$dashboardApiClientHash() =>
    r'3e0222bc358856b65773c2f0c11b41b63c51d623';

/// Provider for DashboardApiClient
///
/// Copied from [dashboardApiClient].
@ProviderFor(dashboardApiClient)
final dashboardApiClientProvider =
    AutoDisposeProvider<DashboardApiClient>.internal(
      dashboardApiClient,
      name: r'dashboardApiClientProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dashboardApiClientHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DashboardApiClientRef = AutoDisposeProviderRef<DashboardApiClient>;
String _$fcmApiClientHash() => r'865dc4ed9fe9ed13bc9b6cf51c79b08a60d87ffc';

/// Provider for FcmApiClient
///
/// Copied from [fcmApiClient].
@ProviderFor(fcmApiClient)
final fcmApiClientProvider = AutoDisposeProvider<FcmApiClient>.internal(
  fcmApiClient,
  name: r'fcmApiClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fcmApiClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FcmApiClientRef = AutoDisposeProviderRef<FcmApiClient>;
String _$connectivityHash() => r'6d67af0ea4110f6ee0246dd332f90f8901380eda';

/// Provider for Connectivity monitoring
///
/// Monitors network connectivity status and provides real-time updates
/// about network availability. Used for offline-first architecture
/// and network-dependent operations.
///
/// Copied from [connectivity].
@ProviderFor(connectivity)
final connectivityProvider = AutoDisposeProvider<Connectivity>.internal(
  connectivity,
  name: r'connectivityProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$connectivityHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConnectivityRef = AutoDisposeProviderRef<Connectivity>;
String _$connectivityStateHash() => r'6d8c05a5cf7e89b3015aa5df30e6057a32c24fc2';

/// Stream provider for connectivity state monitoring
///
/// Provides real-time connectivity status as an AsyncValue<List<ConnectivityResult>>.
/// This is used by UI components that need to react to network changes with loading states.
///
/// Copied from [connectivityState].
@ProviderFor(connectivityState)
final connectivityStateProvider =
    AutoDisposeStreamProvider<List<ConnectivityResult>>.internal(
      connectivityState,
      name: r'connectivityStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$connectivityStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConnectivityStateRef =
    AutoDisposeStreamProviderRef<List<ConnectivityResult>>;
String _$networkInfoHash() => r'b067d74786c4d58577cb8b822d0ce688d41fe44d';

/// Provider for NetworkInfo
///
/// Creates NetworkInfo implementation with Connectivity dependency.
/// Uses DevNetworkInfoImpl in development/container environments to avoid DBUS issues.
///
/// Copied from [networkInfo].
@ProviderFor(networkInfo)
final networkInfoProvider = AutoDisposeProvider<NetworkInfo>.internal(
  networkInfo,
  name: r'networkInfoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$networkInfoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NetworkInfoRef = AutoDisposeProviderRef<NetworkInfo>;
String _$networkErrorHandlerHash() =>
    r'c6519adc9513975a67b10f9fd0a8322733ab1ed9';

/// Provider for NetworkErrorHandler
///
/// Creates NetworkErrorHandler with NetworkInfo dependency.
/// Provides centralized network error handling with retry logic,
/// circuit breaker pattern, and proper error classification.
///
/// Copied from [networkErrorHandler].
@ProviderFor(networkErrorHandler)
final networkErrorHandlerProvider =
    AutoDisposeProvider<NetworkErrorHandler>.internal(
      networkErrorHandler,
      name: r'networkErrorHandlerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$networkErrorHandlerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NetworkErrorHandlerRef = AutoDisposeProviderRef<NetworkErrorHandler>;
String _$refreshNetworkErrorHandlerHash() =>
    r'e8cb97a328ae276f56e275b89b918ca723c54e98';

/// Provider for isolated NetworkErrorHandler used exclusively by TokenRefreshService
///
/// This handler MUST NOT depend on apiDioProvider to avoid circular dependencies:
/// - apiDioProvider → tokenRefreshService → refreshNetworkErrorHandler ✅ (no cycle)
///
/// The dio parameter is intentionally omitted (null) because:
/// 1. TokenRefreshService already has its own dio instance (refreshDioProvider)
/// 2. NetworkErrorHandler's dio parameter is currently unused (line 271: marked for future extensibility)
/// 3. Including apiDioProvider would recreate the circular dependency
///
/// Copied from [refreshNetworkErrorHandler].
@ProviderFor(refreshNetworkErrorHandler)
final refreshNetworkErrorHandlerProvider =
    AutoDisposeProvider<NetworkErrorHandler>.internal(
      refreshNetworkErrorHandler,
      name: r'refreshNetworkErrorHandlerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$refreshNetworkErrorHandlerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RefreshNetworkErrorHandlerRef =
    AutoDisposeProviderRef<NetworkErrorHandler>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
