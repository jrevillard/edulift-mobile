// EduLift Mobile - Enhanced WebSocket Test Utilities
// Provides advanced test abstraction and deterministic timing for WebSocket testing

import 'dart:async';
import 'package:edulift/core/network/websocket/websocket_service.dart';
import 'package:edulift/core/network/websocket/websocket_event_models.dart';
import 'package:edulift/core/network/websocket/websocket_schedule_events.dart';
import 'package:edulift/infrastructure/network/websocket/socket_events.dart';
import 'mock_websocket_service.dart';

/// Enhanced WebSocket test utilities with deterministic timing and better abstractions
class WebSocketTestUtilities {
  /// Create a realistic family update event with proper timing
  static FamilyUpdateEvent createFamilyUpdateEvent({
    required String eventType,
    required String familyId,
    Map<String, dynamic>? data,
    DateTime? timestamp,
  }) {
    return FamilyUpdateEvent(
      eventId: 'event-${DateTime.now().millisecondsSinceEpoch}',
      familyId: familyId,
      updateType: FamilyUpdateType.fromString(eventType),
      familyData: data ?? {},
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  /// Create a realistic schedule update event for testing
  static ScheduleUpdateEvent createScheduleUpdateEvent({
    required String scheduleSlotId,
    required String groupId,
    String? day,
    String? week,
    ScheduleEventType? eventType,
    DateTime? timestamp,
  }) {
    return ScheduleUpdateEvent(
      eventType: eventType ?? ScheduleEventType.scheduleSlotUpdated,
      scheduleSlotId: scheduleSlotId,
      groupId: groupId,
      day: day ?? 'Monday',
      time: '09:00',
      week: week ?? '2024-08-20',
      updatedBy: 'test-user-123',
      updatedByName: 'Test User',
      changeType: ScheduleChangeType.vehicleAssigned,
      changeDescription: 'Vehicle assigned to schedule slot',
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  /// Create a conflict event for testing conflict resolution
  static ConflictEvent createConflictEvent({
    required String conflictId,
    ConflictType? type,
    DateTime? timestamp,
  }) {
    return ConflictEvent(
      eventId: 'conflict-${DateTime.now().millisecondsSinceEpoch}',
      conflictId: conflictId,
      conflictType: type ?? ConflictType.schedule,
      groupId: 'test-group-123',
      scheduleSlotId: 'slot-456',
      description: 'Test conflict detected',
      conflictData: {
        'originalSlot': 'slot-456',
        'conflictingSlot': 'slot-789',
        'affectedChildren': ['child-1', 'child-2'],
      },
      severity: ConflictSeverity.medium,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  /// Create a notification event with proper structure
  static NotificationEvent createNotificationEvent({
    required String category,
    String? title,
    String? message,
    Map<String, dynamic>? data,
    DateTime? timestamp,
  }) {
    return NotificationEvent(
      eventId: 'notif-${DateTime.now().millisecondsSinceEpoch}',
      notificationId: 'notification-${DateTime.now().millisecondsSinceEpoch}',
      title: title ?? 'Test Notification',
      message: message ?? 'Test notification message',
      priority: NotificationPriority.medium,
      category: category,
      data: data ?? {},
      timestamp: timestamp ?? DateTime.now(),
    );
  }
}

/// WebSocket test controller with deterministic timing
class WebSocketTestController {
  final MockWebSocketService mockService;
  final List<String> _eventLog = [];
  final List<Exception> _errorLog = [];

  // Timing control
  Duration _processingDelay = const Duration(milliseconds: 10);
  bool _deterministicTiming = true;

  WebSocketTestController(this.mockService);

  /// Enable deterministic timing for predictable test behavior
  void enableDeterministicTiming({Duration? processingDelay}) {
    _deterministicTiming = true;
    _processingDelay = processingDelay ?? const Duration(milliseconds: 10);
  }

  /// Disable deterministic timing for real-time behavior
  void disableDeterministicTiming() {
    _deterministicTiming = false;
  }

  /// Emit family update and wait for processing
  Future<void> emitFamilyUpdate(FamilyUpdateEvent event) async {
    _eventLog.add('FAMILY_UPDATE: ${event.updateType}');
    mockService.emitFamilyUpdate(event);

    if (_deterministicTiming) {
      await Future.delayed(_processingDelay);
    }
  }

  /// Emit schedule update and wait for processing
  Future<void> emitScheduleUpdate(ScheduleUpdateEvent event) async {
    _eventLog.add('SCHEDULE_UPDATE: ${event.eventType}');
    mockService.emitScheduleUpdate(event);

    if (_deterministicTiming) {
      await Future.delayed(_processingDelay);
    }
  }

  /// Emit notification and wait for processing
  Future<void> emitNotification(NotificationEvent event) async {
    _eventLog.add('NOTIFICATION: ${event.category}');
    mockService.emitNotification(event);

    if (_deterministicTiming) {
      await Future.delayed(_processingDelay);
    }
  }

  /// Emit conflict and wait for processing
  Future<void> emitConflict(ConflictEvent event) async {
    _eventLog.add('CONFLICT: ${event.conflictType}');
    mockService.emitConflict(event);

    if (_deterministicTiming) {
      await Future.delayed(_processingDelay);
    }
  }

  /// Emit error and wait for processing
  Future<void> emitError(Exception error) async {
    _errorLog.add(error);
    _eventLog.add('ERROR: ${error.toString()}');
    mockService.emitError(error);

    if (_deterministicTiming) {
      await Future.delayed(_processingDelay);
    }
  }

  /// Simulate connection status change
  Future<void> simulateConnectionChange(ConnectionStatus status) async {
    _eventLog.add('CONNECTION: ${status.name}');
    mockService.emitConnectionStatus(status);

    if (_deterministicTiming) {
      await Future.delayed(_processingDelay);
    }
  }

  /// Get event log for test verification
  List<String> get eventLog => List.unmodifiable(_eventLog);

  /// Get error log for test verification
  List<Exception> get errorLog => List.unmodifiable(_errorLog);

  /// Clear all logs
  void clearLogs() {
    _eventLog.clear();
    _errorLog.clear();
  }

  /// Wait for all pending async operations
  Future<void> waitForProcessing() async {
    if (_deterministicTiming) {
      await Future.delayed(_processingDelay);
    } else {
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }
}

/// WebSocket subscription manager for test scenarios
class WebSocketSubscriptionManager {
  final List<StreamSubscription> _subscriptions = [];
  final Map<String, List<dynamic>> _receivedEvents = {};
  final Map<String, List<Exception>> _receivedErrors = {};

  /// Subscribe to family updates with event capture
  StreamSubscription<FamilyUpdateEvent> subscribeToFamilyUpdates(
    MockWebSocketService service, {
    Function(FamilyUpdateEvent)? onEvent,
    Function(Exception)? onError,
  }) {
    final subscription = service.familyUpdates.listen(
      (event) {
        _receivedEvents.putIfAbsent('family', () => []).add(event);
        onEvent?.call(event);
      },
      onError: (error) {
        _receivedErrors.putIfAbsent('family', () => []).add(error);
        onError?.call(error);
      },
    );

    _subscriptions.add(subscription);
    return subscription;
  }

  /// Subscribe to schedule updates with event capture
  StreamSubscription<ScheduleUpdateEvent> subscribeToScheduleUpdates(
    MockWebSocketService service, {
    Function(ScheduleUpdateEvent)? onEvent,
    Function(Exception)? onError,
  }) {
    final subscription = service.scheduleUpdates.listen(
      (event) {
        _receivedEvents.putIfAbsent('schedule', () => []).add(event);
        onEvent?.call(event);
      },
      onError: (error) {
        _receivedErrors.putIfAbsent('schedule', () => []).add(error);
        onError?.call(error);
      },
    );

    _subscriptions.add(subscription);
    return subscription;
  }

  /// Subscribe to notifications with event capture
  StreamSubscription<NotificationEvent> subscribeToNotifications(
    MockWebSocketService service, {
    Function(NotificationEvent)? onEvent,
    Function(Exception)? onError,
  }) {
    final subscription = service.notifications.listen(
      (event) {
        _receivedEvents.putIfAbsent('notifications', () => []).add(event);
        onEvent?.call(event);
      },
      onError: (error) {
        _receivedErrors.putIfAbsent('notifications', () => []).add(error);
        onError?.call(error);
      },
    );

    _subscriptions.add(subscription);
    return subscription;
  }

  /// Subscribe to conflicts with event capture
  StreamSubscription<ConflictEvent> subscribeToConflicts(
    MockWebSocketService service, {
    Function(ConflictEvent)? onEvent,
    Function(Exception)? onError,
  }) {
    final subscription = service.conflicts.listen(
      (event) {
        _receivedEvents.putIfAbsent('conflicts', () => []).add(event);
        onEvent?.call(event);
      },
      onError: (error) {
        _receivedErrors.putIfAbsent('conflicts', () => []).add(error);
        onError?.call(error);
      },
    );

    _subscriptions.add(subscription);
    return subscription;
  }

  /// Get received events by category
  List<T> getReceivedEvents<T>(String category) {
    return (_receivedEvents[category] ?? []).cast<T>();
  }

  /// Get received errors by category
  List<Exception> getReceivedErrors(String category) {
    return _receivedErrors[category] ?? [];
  }

  /// Check if events were received
  bool hasReceivedEvents(String category) {
    return (_receivedEvents[category]?.isNotEmpty) ?? false;
  }

  /// Check if errors were received
  bool hasReceivedErrors(String category) {
    return (_receivedErrors[category]?.isNotEmpty) ?? false;
  }

  /// Clear all received events and errors
  void clearAll() {
    _receivedEvents.clear();
    _receivedErrors.clear();
  }

  /// Cancel all subscriptions
  Future<void> cancelAll() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
  }

  /// Get subscription count
  int get activeSubscriptionCount => _subscriptions.length;
}

/// Connection lifecycle simulator for testing reconnection scenarios
class ConnectionLifecycleSimulator {
  final WebSocketTestController controller;
  final List<String> _connectionStates = [];

  ConnectionLifecycleSimulator(this.controller);

  /// Simulate full connection lifecycle
  Future<void> simulateFullLifecycle() async {
    await simulateConnecting();
    await simulateConnected();
    await simulateDisconnected();
    await simulateReconnecting();
    await simulateConnected();
  }

  /// Simulate connecting state
  Future<void> simulateConnecting() async {
    _connectionStates.add('connecting');
    await controller.simulateConnectionChange(ConnectionStatus.connecting);
  }

  /// Simulate connected state
  Future<void> simulateConnected() async {
    _connectionStates.add('connected');
    await controller.simulateConnectionChange(ConnectionStatus.connected);
  }

  /// Simulate disconnected state
  Future<void> simulateDisconnected() async {
    _connectionStates.add('disconnected');
    await controller.simulateConnectionChange(ConnectionStatus.disconnected);
  }

  /// Simulate reconnecting state
  Future<void> simulateReconnecting() async {
    _connectionStates.add('reconnecting');
    await controller.simulateConnectionChange(ConnectionStatus.connecting);
  }

  /// Simulate network interruption scenario
  Future<void> simulateNetworkInterruption({
    Duration? interruptionDuration,
    int? reconnectAttempts,
  }) async {
    // Connected -> Disconnected -> Reconnecting attempts -> Connected
    await simulateConnected();
    await simulateDisconnected();

    final attempts = reconnectAttempts ?? 3;
    for (var i = 0; i < attempts; i++) {
      await simulateReconnecting();
      await Future.delayed(
        interruptionDuration ?? const Duration(milliseconds: 100),
      );
    }

    await simulateConnected();
  }

  /// Get connection state history
  List<String> get connectionStateHistory =>
      List.unmodifiable(_connectionStates);

  /// Clear connection state history
  void clearHistory() {
    _connectionStates.clear();
  }
}

/// WebSocket test scenario builder for complex integration tests
class WebSocketTestScenarioBuilder {
  final WebSocketTestController controller;
  final WebSocketSubscriptionManager subscriptionManager;
  final List<String> _scenarioSteps = [];

  WebSocketTestScenarioBuilder(this.controller, this.subscriptionManager);

  /// Build a family collaboration scenario
  WebSocketTestScenarioBuilder buildFamilyCollaborationScenario() {
    _scenarioSteps.add('Family Collaboration Scenario');
    return this;
  }

  /// Add child addition to scenario
  Future<WebSocketTestScenarioBuilder> addChildAddition({
    required String childId,
    required String childName,
    String? familyId,
  }) async {
    _scenarioSteps.add('Add Child: $childName');

    final event = WebSocketTestUtilities.createFamilyUpdateEvent(
      eventType: SocketEvents.CHILD_ADDED,
      familyId: familyId ?? 'test-family-123',
      data: {
        'child': {
          'id': childId,
          'name': childName,
          'familyId': familyId ?? 'test-family-123',
          'age': 9,
          'createdAt': '2024-08-26T00:00:00.000Z',
          'updatedAt': '2024-08-26T00:00:00.000Z',
        },
      },
    );

    await controller.emitFamilyUpdate(event);
    return this;
  }

  /// Add schedule conflict to scenario
  Future<WebSocketTestScenarioBuilder> addScheduleConflict({
    required String scheduleSlotId,
    required String groupId,
  }) async {
    _scenarioSteps.add('Schedule Conflict: $scheduleSlotId');

    final conflictEvent = WebSocketTestUtilities.createConflictEvent(
      conflictId: 'conflict-$scheduleSlotId',
      type: ConflictType.schedule,
    );

    await controller.emitConflict(conflictEvent);
    return this;
  }

  /// Add data refresh notification to scenario
  Future<WebSocketTestScenarioBuilder> addDataRefreshTrigger() async {
    _scenarioSteps.add('Data Refresh Trigger');

    final notification = WebSocketTestUtilities.createNotificationEvent(
      category: 'DATA_REFRESH_TRIGGER',
      title: 'Data Refresh Required',
      message: 'Family data has been updated',
      data: {'dataType': 'family_data'},
    );

    await controller.emitNotification(notification);
    return this;
  }

  /// Execute the built scenario
  Future<WebSocketTestScenarioResult> execute() async {
    final startTime = DateTime.now();

    // Wait for all events to process
    await controller.waitForProcessing();

    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);

    return WebSocketTestScenarioResult(
      scenarioSteps: _scenarioSteps,
      eventLog: controller.eventLog,
      errorLog: controller.errorLog,
      executionDuration: duration,
      subscriptionManager: subscriptionManager,
    );
  }

  /// Get scenario steps
  List<String> get scenarioSteps => List.unmodifiable(_scenarioSteps);
}

/// Results from executing a WebSocket test scenario
class WebSocketTestScenarioResult {
  final List<String> scenarioSteps;
  final List<String> eventLog;
  final List<Exception> errorLog;
  final Duration executionDuration;
  final WebSocketSubscriptionManager subscriptionManager;

  const WebSocketTestScenarioResult({
    required this.scenarioSteps,
    required this.eventLog,
    required this.errorLog,
    required this.executionDuration,
    required this.subscriptionManager,
  });

  /// Check if scenario executed without errors
  bool get isSuccessful => errorLog.isEmpty;

  /// Get number of events processed
  int get eventCount => eventLog.length;

  /// Check if specific event type was processed
  bool hasProcessedEvent(String eventType) {
    return eventLog.any((log) => log.contains(eventType));
  }

  /// Get events of specific type
  List<String> getEventsOfType(String eventType) {
    return eventLog.where((log) => log.contains(eventType)).toList();
  }

  /// Verify scenario completed all steps
  bool verifyStepsCompleted() {
    return scenarioSteps.every(
      (step) =>
          eventLog.any((log) => log.toLowerCase().contains(step.toLowerCase())),
    );
  }
}
