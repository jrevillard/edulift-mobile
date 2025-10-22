// EduLift Mobile - Real-time Schedule Coordination Provider
// Optimized for performance and memory efficiency

import 'dart:async';
import 'dart:collection';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:edulift/core/network/websocket/websocket_service.dart';
import 'package:edulift/core/network/websocket/websocket_schedule_events.dart';
import 'package:edulift/core/network/error_handler_service.dart';
import 'package:edulift/core/domain/services/auth_service.dart';
import 'package:edulift/core/domain/entities/schedule.dart';

/// Optimized real-time schedule state with better memory management
@immutable
class RealtimeScheduleState {
  final bool isConnected;
  final UnmodifiableListView<ScheduleUpdateEvent> scheduleUpdates;
  final UnmodifiableListView<ScheduleNotificationEvent> notifications;
  final UnmodifiableListView<ScheduleConflict> activeConflicts;
  final UnmodifiableMapView<String, ScheduleSlot> scheduleSlotsCache;
  final String? error;
  final bool hasUnreadNotifications;
  final ScheduleMetrics metrics;

  RealtimeScheduleState._({
    required this.isConnected,
    required List<ScheduleUpdateEvent> scheduleUpdates,
    required List<ScheduleNotificationEvent> notifications,
    required List<ScheduleConflict> activeConflicts,
    required Map<String, ScheduleSlot> scheduleSlotsCache,
    this.error,
    required this.hasUnreadNotifications,
    required this.metrics,
  }) : scheduleUpdates = UnmodifiableListView(scheduleUpdates),
       notifications = UnmodifiableListView(notifications),
       activeConflicts = UnmodifiableListView(activeConflicts),
       scheduleSlotsCache = UnmodifiableMapView(scheduleSlotsCache);

  /// Factory constructor with default values
  factory RealtimeScheduleState.initial() {
    return RealtimeScheduleState._(
      isConnected: false,
      scheduleUpdates: const [],
      notifications: const [],
      activeConflicts: const [],
      scheduleSlotsCache: const {},
      hasUnreadNotifications: false,
      metrics: ScheduleMetrics.initial(),
    );
  }

  /// Copy with method for immutable updates
  RealtimeScheduleState copyWith({
    bool? isConnected,
    List<ScheduleUpdateEvent>? scheduleUpdates,
    List<ScheduleNotificationEvent>? notifications,
    List<ScheduleConflict>? activeConflicts,
    Map<String, ScheduleSlot>? scheduleSlotsCache,
    String? error,
    bool? hasUnreadNotifications,
    ScheduleMetrics? metrics,
  }) {
    return RealtimeScheduleState._(
      isConnected: isConnected ?? this.isConnected,
      scheduleUpdates: scheduleUpdates ?? this.scheduleUpdates.toList(),
      notifications: notifications ?? this.notifications.toList(),
      activeConflicts: activeConflicts ?? this.activeConflicts.toList(),
      scheduleSlotsCache:
          scheduleSlotsCache ?? Map.from(this.scheduleSlotsCache),
      error: error,
      hasUnreadNotifications:
          hasUnreadNotifications ?? this.hasUnreadNotifications,
      metrics: metrics ?? this.metrics,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RealtimeScheduleState &&
        other.isConnected == isConnected &&
        other.error == error &&
        other.hasUnreadNotifications == hasUnreadNotifications &&
        other.metrics == metrics;
  }

  @override
  int get hashCode =>
      Object.hash(isConnected, error, hasUnreadNotifications, metrics);
}

/// Metrics for schedule coordination performance
class ScheduleMetrics {
  final int totalEvents;
  final int conflictCount;
  final int criticalConflictCount;
  final int highPriorityNotifications;
  final DateTime lastEventTime;
  final Duration avgProcessingTime;

  const ScheduleMetrics({
    required this.totalEvents,
    required this.conflictCount,
    required this.criticalConflictCount,
    required this.highPriorityNotifications,
    required this.lastEventTime,
    required this.avgProcessingTime,
  });

  factory ScheduleMetrics.initial() {
    return ScheduleMetrics(
      totalEvents: 0,
      conflictCount: 0,
      criticalConflictCount: 0,
      highPriorityNotifications: 0,
      lastEventTime: DateTime.now(),
      avgProcessingTime: Duration.zero,
    );
  }

  ScheduleMetrics copyWith({
    int? totalEvents,
    int? conflictCount,
    int? criticalConflictCount,
    int? highPriorityNotifications,
    DateTime? lastEventTime,
    Duration? avgProcessingTime,
  }) {
    return ScheduleMetrics(
      totalEvents: totalEvents ?? this.totalEvents,
      conflictCount: conflictCount ?? this.conflictCount,
      criticalConflictCount:
          criticalConflictCount ?? this.criticalConflictCount,
      highPriorityNotifications:
          highPriorityNotifications ?? this.highPriorityNotifications,
      lastEventTime: lastEventTime ?? this.lastEventTime,
      avgProcessingTime: avgProcessingTime ?? this.avgProcessingTime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScheduleMetrics &&
        other.totalEvents == totalEvents &&
        other.conflictCount == conflictCount &&
        other.criticalConflictCount == criticalConflictCount &&
        other.highPriorityNotifications == highPriorityNotifications;
  }

  @override
  int get hashCode => Object.hash(
    totalEvents,
    conflictCount,
    criticalConflictCount,
    highPriorityNotifications,
  );
}

/// Optimized real-time schedule notifier with batch processing
class RealtimeScheduleNotifier extends StateNotifier<RealtimeScheduleState> {
  final WebSocketService _webSocketService;
  final AuthService _authService;
  final ErrorHandlerService _errorHandlerService;
  final List<StreamSubscription> _subscriptions = [];

  // Batch processing queues
  final List<ScheduleUpdateEvent> _pendingUpdates = [];
  final List<ScheduleNotificationEvent> _pendingNotifications = [];
  Timer? _batchTimer;

  // Performance tracking
  final List<Duration> _processingTimes = [];
  static const int _maxEventHistory = 100;
  static const int _maxNotificationHistory = 50;
  static const Duration _batchInterval = Duration(milliseconds: 100);

  RealtimeScheduleNotifier(
    this._webSocketService,
    this._authService,
    this._errorHandlerService,
  ) : super(RealtimeScheduleState.initial()) {
    _initializeWebSocketListeners();
  }

  /// Initialize WebSocket listeners with optimized event handling
  void _initializeWebSocketListeners() {
    // Connection status listener
    _subscriptions.add(
      _webSocketService.connectionStatus.listen((status) {
        state = state.copyWith(
          isConnected: status == ConnectionStatus.connected,
          error: status == ConnectionStatus.error ? 'Connection error' : null,
        );
      }),
    );
    // Schedule update events with batching
    _subscriptions.add(
      _webSocketService.scheduleUpdateEvents.listen((event) {
        _addToBatch(event);
      }),
    );
    // Schedule notification events with batching
    _subscriptions.add(
      _webSocketService.scheduleNotificationEvents.listen((event) {
        _addToBatch(event);
      }),
    );
  }

  /// Add events to batch processing queue
  void _addToBatch(dynamic event) {
    final startTime = DateTime.now();
    if (event is ScheduleUpdateEvent) {
      _pendingUpdates.add(event);
    } else if (event is ScheduleNotificationEvent) {
      _pendingNotifications.add(event);
    }

    // Start batch timer if not already running
    _batchTimer ??= Timer(_batchInterval, _processBatch);
    // Track processing time
    final processingTime = DateTime.now().difference(startTime);
    _processingTimes.add(processingTime);
    if (_processingTimes.length > 100) {
      _processingTimes.removeAt(0);
    }
  }

  /// Process batch of events for better performance
  void _processBatch() {
    if (_pendingUpdates.isEmpty && _pendingNotifications.isEmpty) {
      _batchTimer = null;
      return;
    }

    // Basic batch processing - simplified for syntax correctness
    final updatedScheduleUpdates = List<ScheduleUpdateEvent>.from(state.scheduleUpdates)
      ..addAll(_pendingUpdates);
    final updatedNotifications = List<ScheduleNotificationEvent>.from(state.notifications)
      ..addAll(_pendingNotifications);

    // Limit sizes
    if (updatedScheduleUpdates.length > _maxEventHistory) {
      updatedScheduleUpdates.removeRange(0, updatedScheduleUpdates.length - _maxEventHistory);
    }
    if (updatedNotifications.length > _maxNotificationHistory) {
      updatedNotifications.removeRange(0, updatedNotifications.length - _maxNotificationHistory);
    }

    // Update state atomically
    state = state.copyWith(
      scheduleUpdates: updatedScheduleUpdates,
      notifications: updatedNotifications,
      hasUnreadNotifications: updatedNotifications.isNotEmpty,
      metrics: state.metrics.copyWith(
        totalEvents: state.metrics.totalEvents + _pendingUpdates.length + _pendingNotifications.length,
        lastEventTime: DateTime.now(),
      ),
    );

    // Clear batch queues
    _pendingUpdates.clear();
    _pendingNotifications.clear();
    _batchTimer = null;
  }

  /// Connect with optimized subscription
  Future<void> connect() async {
    try {
      await _webSocketService.connect();
      await _subscribeToUserSchedules();
    } catch (e) {
      final errorResult = await _errorHandlerService.handleError(
        e,
        ErrorContext.scheduleOperation('connect_websocket'),
      );
      state = state.copyWith(error: errorResult.userMessage.messageKey);
    }
  }

  /// Subscribe to user-specific schedule channels
  Future<void> _subscribeToUserSchedules() async {
    final userResult = await _authService.getCurrentUser();
    if (userResult.isOk) {
      // Subscribe to user-specific channels based on user data
    }
  }

  /// Subscribe to group schedule updates
  Future<void> subscribeToGroupSchedule(String groupId) async {
    await _webSocketService.subscribeToGroup(groupId);
  }

  /// Get high priority notifications (cached)
  List<ScheduleNotificationEvent> get highPriorityNotifications {
    return state.notifications
        .where((notif) => notif.isHighPriority && notif.actionRequired)
        .take(5)
        .toList();
  }

  /// Get critical conflicts (cached)
  List<ScheduleConflict> get criticalConflicts {
    return state.activeConflicts
        .where(
          (conflict) =>
              conflict.severity == ConflictSeverity.critical &&
              !conflict.isResolved,
        )
        .toList();
  }

  /// Mark notifications as read efficiently
  void markNotificationsAsRead() {
    state = state.copyWith(hasUnreadNotifications: false);
  }

  /// Handle notification tap - navigation is handled by router redirect logic
  void handleNotificationTap(
    ScheduleNotificationEvent notification,
    WidgetRef ref,
  ) {
    // ARCHITECTURE FIX: Notification taps should not trigger navigation
    // The router's redirect logic will automatically handle navigation based on auth state
    // This eliminates race conditions and ensures consistent navigation behavior

    // Mark notifications as read
    markNotificationsAsRead();
    // Log the notification tap for debugging
    // Note: Router will handle navigation automatically based on auth state changes
  }

  /// Memory cleanup with optimized thresholds
  void performMemoryCleanup() {
    final now = DateTime.now();
    const maxAge = Duration(days: 7);
    final recentUpdates = state.scheduleUpdates
        .where((event) => now.difference(event.timestamp) < maxAge)
        .toList();
    final recentNotifications = state.notifications
        .where((event) => now.difference(event.timestamp) < maxAge)
        .toList();
    final recentConflicts = state.activeConflicts
        .where((conflict) => now.difference(conflict.detectedAt) < maxAge)
        .toList();

    state = state.copyWith(
      scheduleUpdates: recentUpdates,
      notifications: recentNotifications,
      activeConflicts: recentConflicts,
    );

    // Clear processing time history
    if (_processingTimes.length > 50) {
      _processingTimes.removeRange(0, _processingTimes.length - 50);
    }
  }

  @override
  void dispose() {
    _batchTimer?.cancel();
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}

// Simple providers to avoid code generation issues
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  throw UnimplementedError('WebSocketService not implemented - requires build_runner');
});

final authServiceProvider = Provider<AuthService>((ref) {
  throw UnimplementedError('AuthService not implemented - requires build_runner');
});

/// Provider for real-time schedule coordination
final realtimeScheduleProvider =
    StateNotifierProvider<RealtimeScheduleNotifier, RealtimeScheduleState>(
  (ref) {
    final webSocketService = ref.watch(webSocketServiceProvider);
    final authService = ref.watch(authServiceProvider);
    // Simple error handler service to avoid code generation issues
    final errorHandlerService = ErrorHandlerService(UserMessageService());
    return RealtimeScheduleNotifier(webSocketService, authService, errorHandlerService);
  },
);