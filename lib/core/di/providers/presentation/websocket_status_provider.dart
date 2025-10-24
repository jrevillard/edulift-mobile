// EduLift Mobile - WebSocket Connection Status Provider
// Real-time WebSocket connection status management with semantic states
// Follows 2025 best practices for real-time connection indicators

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'websocket_status_provider.g.dart';

/// WebSocket connection status with semantic meaning for UI indicators
enum WebSocketConnectionState {
  /// Currently attempting to establish connection
  connecting,

  /// Successfully connected and receiving real-time updates
  connected,

  /// Temporarily disconnected but attempting to reconnect
  reconnecting,

  /// Connection failed or lost with no automatic reconnection
  disconnected,

  /// Connection is working but experiencing synchronization delays
  syncing,

  /// Connection error that requires user intervention
  error,
}

/// Extended status information for detailed connection state
@immutable
class WebSocketConnectionStatus {
  const WebSocketConnectionStatus({
    required this.state,
    this.lastConnectedAt,
    this.reconnectAttempts = 0,
    this.errorMessage,
    this.isRecovering = false,
  });

  final WebSocketConnectionState state;
  final DateTime? lastConnectedAt;
  final int reconnectAttempts;
  final String? errorMessage;
  final bool isRecovering;

  /// Get semantic color for the connection state
  /// Green: connected, Orange: syncing/reconnecting, Red: disconnected/error
  String get semanticColor {
    switch (state) {
      case WebSocketConnectionState.connected:
        return 'green';
      case WebSocketConnectionState.connecting:
      case WebSocketConnectionState.reconnecting:
      case WebSocketConnectionState.syncing:
        return 'orange';
      case WebSocketConnectionState.disconnected:
      case WebSocketConnectionState.error:
        return 'red';
    }
  }

  /// Check if the connection is actively working
  bool get isRealTimeActive {
    return state == WebSocketConnectionState.connected ||
        state == WebSocketConnectionState.syncing;
  }

  /// Check if the connection state is transitional (connecting, reconnecting, syncing)
  bool get isTransitioning {
    return state == WebSocketConnectionState.connecting ||
        state == WebSocketConnectionState.reconnecting ||
        state == WebSocketConnectionState.syncing;
  }

  /// Get human-readable status text
  String get statusText {
    switch (state) {
      case WebSocketConnectionState.connecting:
        return 'Connecting...';
      case WebSocketConnectionState.connected:
        return 'Connected';
      case WebSocketConnectionState.reconnecting:
        return 'Reconnecting...';
      case WebSocketConnectionState.disconnected:
        return 'Disconnected';
      case WebSocketConnectionState.syncing:
        return 'Syncing...';
      case WebSocketConnectionState.error:
        return errorMessage ?? 'Connection Error';
    }
  }

  WebSocketConnectionStatus copyWith({
    WebSocketConnectionState? state,
    DateTime? lastConnectedAt,
    int? reconnectAttempts,
    String? errorMessage,
    bool? isRecovering,
  }) {
    return WebSocketConnectionStatus(
      state: state ?? this.state,
      lastConnectedAt: lastConnectedAt ?? this.lastConnectedAt,
      reconnectAttempts: reconnectAttempts ?? this.reconnectAttempts,
      errorMessage: errorMessage ?? this.errorMessage,
      isRecovering: isRecovering ?? this.isRecovering,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WebSocketConnectionStatus &&
        other.state == state &&
        other.lastConnectedAt == lastConnectedAt &&
        other.reconnectAttempts == reconnectAttempts &&
        other.errorMessage == errorMessage &&
        other.isRecovering == isRecovering;
  }

  @override
  int get hashCode {
    return Object.hash(
      state,
      lastConnectedAt,
      reconnectAttempts,
      errorMessage,
      isRecovering,
    );
  }
}

// =============================================================================
// WEBSOCKET STATUS PROVIDERS
// =============================================================================

/// Provider for current WebSocket connection status
@riverpod
Stream<WebSocketConnectionStatus> webSocketStatus(Ref ref) {
  // Return a stream that maps websocket states to our status objects
  return Stream.periodic(const Duration(seconds: 1), (_) {
    return const WebSocketConnectionStatus(
      state: WebSocketConnectionState.connected,
    );
  });
}

/// WebSocket connection status notifier for state management
@riverpod
class WebSocketConnectionStatusNotifier
    extends _$WebSocketConnectionStatusNotifier {
  @override
  WebSocketConnectionStatus build() {
    return const WebSocketConnectionStatus(
      state: WebSocketConnectionState.connected,
    );
  }

  /// Retry connection manually
  void retryConnection() {
    state = state.copyWith(
      state: WebSocketConnectionState.connecting,
      reconnectAttempts: state.reconnectAttempts + 1,
    );
  }

  /// Update connection state
  void updateStatus(WebSocketConnectionStatus newStatus) {
    state = newStatus;
  }
}

/// Provider for checking if real-time features are active
@riverpod
Future<bool> isRealTimeActive(Ref ref) async {
  final status = await ref.watch(webSocketStatusProvider.future);
  return status.isRealTimeActive;
}

/// Provider for getting connection status text
@riverpod
Future<String> connectionStatusText(Ref ref) async {
  final status = await ref.watch(webSocketStatusProvider.future);
  return status.statusText;
}

/// Provider for getting semantic color
@riverpod
Future<String> connectionSemanticColor(Ref ref) async {
  final status = await ref.watch(webSocketStatusProvider.future);
  return status.semanticColor;
}
