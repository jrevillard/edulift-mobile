// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'websocket_status_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$webSocketStatusHash() => r'a4f8ee8ffca16d52dcf1cc7717057001994f9d84';

/// Provider for current WebSocket connection status
///
/// Copied from [webSocketStatus].
@ProviderFor(webSocketStatus)
final webSocketStatusProvider =
    AutoDisposeStreamProvider<WebSocketConnectionStatus>.internal(
  webSocketStatus,
  name: r'webSocketStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$webSocketStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WebSocketStatusRef
    = AutoDisposeStreamProviderRef<WebSocketConnectionStatus>;
String _$isRealTimeActiveHash() => r'65dd083b088997ff28150cbbfbe6e4b7bb890175';

/// Provider for checking if real-time features are active
///
/// Copied from [isRealTimeActive].
@ProviderFor(isRealTimeActive)
final isRealTimeActiveProvider = AutoDisposeFutureProvider<bool>.internal(
  isRealTimeActive,
  name: r'isRealTimeActiveProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isRealTimeActiveHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsRealTimeActiveRef = AutoDisposeFutureProviderRef<bool>;
String _$connectionStatusTextHash() =>
    r'422946a2097e112649a5c18e4e1e1b8494cd1fc2';

/// Provider for getting connection status text
///
/// Copied from [connectionStatusText].
@ProviderFor(connectionStatusText)
final connectionStatusTextProvider = AutoDisposeFutureProvider<String>.internal(
  connectionStatusText,
  name: r'connectionStatusTextProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$connectionStatusTextHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConnectionStatusTextRef = AutoDisposeFutureProviderRef<String>;
String _$connectionSemanticColorHash() =>
    r'3bc6e3071f6c44e2516b376711b413a2d1ca5301';

/// Provider for getting semantic color
///
/// Copied from [connectionSemanticColor].
@ProviderFor(connectionSemanticColor)
final connectionSemanticColorProvider =
    AutoDisposeFutureProvider<String>.internal(
  connectionSemanticColor,
  name: r'connectionSemanticColorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$connectionSemanticColorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConnectionSemanticColorRef = AutoDisposeFutureProviderRef<String>;
String _$webSocketConnectionStatusNotifierHash() =>
    r'2d31f0368d20118acfff9f7687da0358544dde54';

/// WebSocket connection status notifier for state management
///
/// Copied from [WebSocketConnectionStatusNotifier].
@ProviderFor(WebSocketConnectionStatusNotifier)
final webSocketConnectionStatusNotifierProvider = AutoDisposeNotifierProvider<
    WebSocketConnectionStatusNotifier, WebSocketConnectionStatus>.internal(
  WebSocketConnectionStatusNotifier.new,
  name: r'webSocketConnectionStatusNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$webSocketConnectionStatusNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$WebSocketConnectionStatusNotifier
    = AutoDisposeNotifier<WebSocketConnectionStatus>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
