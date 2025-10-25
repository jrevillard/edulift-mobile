// EduLift Mobile - Mock WebSocket Service for Testing
// Provides controllable mock WebSocket functionality for comprehensive testing

import 'dart:async';
import 'package:edulift/core/network/websocket/websocket_service.dart';
import 'package:edulift/core/network/websocket/websocket_invitation_events.dart';
import 'package:edulift/core/network/websocket/websocket_schedule_events.dart';
import 'package:edulift/core/network/websocket/websocket_event_models.dart';
import 'package:edulift/core/network/models/websocket/websocket_dto.dart'; // Correct path for WebSocket DTOs

/// Mock WebSocket Service that provides controllable streams for testing
class MockWebSocketService implements WebSocketService {
  // Stream controllers for all event types
  final StreamController<FamilyUpdateEvent> _familyUpdatesController =
      StreamController<FamilyUpdateEvent>.broadcast();
  final StreamController<GroupUpdateEvent> _groupUpdatesController =
      StreamController<GroupUpdateEvent>.broadcast();
  final StreamController<ScheduleUpdateEvent> _scheduleUpdatesController =
      StreamController<ScheduleUpdateEvent>.broadcast();
  final StreamController<ConflictEvent> _conflictController =
      StreamController<ConflictEvent>.broadcast();
  final StreamController<NotificationEvent> _notificationController =
      StreamController<NotificationEvent>.broadcast();
  final StreamController<ConnectionStatus> _connectionStatusController =
      StreamController<ConnectionStatus>.broadcast();

  // Invitation-specific stream controllers
  final StreamController<FamilyInvitationEvent> _familyInvitationController =
      StreamController<FamilyInvitationEvent>.broadcast();
  final StreamController<GroupInvitationEvent> _groupInvitationController =
      StreamController<GroupInvitationEvent>.broadcast();
  final StreamController<InvitationNotificationEvent>
  _invitationNotificationController =
      StreamController<InvitationNotificationEvent>.broadcast();
  final StreamController<InvitationStatusUpdateEvent>
  _invitationStatusUpdateController =
      StreamController<InvitationStatusUpdateEvent>.broadcast();

  // Schedule-specific stream controllers
  final StreamController<ScheduleUpdateEvent> _scheduleUpdateController =
      StreamController<ScheduleUpdateEvent>.broadcast();
  final StreamController<ScheduleNotificationEvent>
  _scheduleNotificationController =
      StreamController<ScheduleNotificationEvent>.broadcast();

  // Tracking flags for testing
  bool familyUpdatesStreamAccessed = false;
  bool notificationsStreamAccessed = false;
  bool hasActiveSubscriptions = false;
  bool subscriptionsClosed = false;

  @override
  Stream<FamilyUpdateEvent> get familyUpdates {
    familyUpdatesStreamAccessed = true;
    hasActiveSubscriptions = true;
    return _familyUpdatesController.stream;
  }

  @override
  Stream<GroupUpdateEvent> get groupUpdates => _groupUpdatesController.stream;

  @override
  Stream<ScheduleUpdateEvent> get scheduleUpdates =>
      _scheduleUpdatesController.stream;

  @override
  Stream<ConflictEvent> get conflicts => _conflictController.stream;

  @override
  Stream<NotificationEvent> get notifications {
    notificationsStreamAccessed = true;
    hasActiveSubscriptions = true;
    return _notificationController.stream;
  }

  @override
  Stream<ConnectionStatus> get connectionStatus =>
      _connectionStatusController.stream;

  @override
  Stream<FamilyInvitationEvent> get familyInvitationEvents =>
      _familyInvitationController.stream;

  @override
  Stream<GroupInvitationEvent> get groupInvitationEvents =>
      _groupInvitationController.stream;

  @override
  Stream<InvitationNotificationEvent> get invitationNotificationEvents =>
      _invitationNotificationController.stream;

  @override
  Stream<InvitationStatusUpdateEvent> get invitationStatusUpdateEvents =>
      _invitationStatusUpdateController.stream;

  @override
  Stream<ScheduleUpdateEvent> get scheduleUpdateEvents =>
      _scheduleUpdateController.stream;

  @override
  Stream<ScheduleNotificationEvent> get scheduleNotificationEvents =>
      _scheduleNotificationController.stream;

  @override
  bool get isConnected => true;

  // Additional required getters for WebSocketService interface compliance
  @override
  Stream<VehicleUpdateEvent> get vehicleUpdates => const Stream.empty();

  @override
  Stream<PresenceUpdateEvent> get presenceUpdates => const Stream.empty();

  @override
  Stream<TypingIndicatorEvent> get typingIndicator => const Stream.empty();

  @override
  Stream<MembershipEvent> get membershipEvents => const Stream.empty();

  @override
  Stream<ConnectionStatusEvent> get enhancedConnectionStatus =>
      const Stream.empty();

  @override
  Stream<HeartbeatEvent> get heartbeat => const Stream.empty();

  @override
  Stream<SystemNotificationEvent> get systemNotifications =>
      const Stream.empty();

  @override
  Stream<SystemErrorEvent> get systemErrors => const Stream.empty();

  @override
  Stream<ScheduleSubscriptionEvent> get scheduleSubscriptions =>
      const Stream.empty();

  @override
  Stream<CollaborationEvent> get collaboration => const Stream.empty();

  @override
  Stream<ChildUpdateEvent> get childUpdates => const Stream.empty();

  // Test helper methods to emit events
  void emitFamilyUpdate(FamilyUpdateEvent event) {
    _familyUpdatesController.add(event);
  }

  void emitGroupUpdate(GroupUpdateEvent event) {
    _groupUpdatesController.add(event);
  }

  void emitScheduleUpdate(ScheduleUpdateEvent event) {
    _scheduleUpdatesController.add(event);
  }

  void emitConflict(ConflictEvent event) {
    _conflictController.add(event);
  }

  void emitNotification(NotificationEvent event) {
    _notificationController.add(event);
  }

  void emitConnectionStatus(ConnectionStatus status) {
    _connectionStatusController.add(status);
  }

  void emitError(Exception error) {
    _familyUpdatesController.addError(error);
    _notificationController.addError(error);
  }

  // Unimplemented methods (not needed for family provider testing)
  @override
  Future<void> connect() async {}

  @override
  Future<void> disconnect() async {}

  @override
  void dispose() {
    subscriptionsClosed = true;
    _familyUpdatesController.close();
    _groupUpdatesController.close();
    _scheduleUpdatesController.close();
    _conflictController.close();
    _notificationController.close();
    _connectionStatusController.close();
    _familyInvitationController.close();
    _groupInvitationController.close();
    _invitationNotificationController.close();
    _invitationStatusUpdateController.close();
    _scheduleUpdateController.close();
    _scheduleNotificationController.close();
  }

  @override
  Stream<Map<String, dynamic>> getStream(String eventType) {
    throw UnimplementedError();
  }

  @override
  void subscribe(String eventType) {}

  @override
  Future<void> subscribeToFamily(String familyId) async {}

  @override
  Future<void> subscribeToGroup(String groupId) async {}

  @override
  Future<void> subscribeToSchedule(String scheduleId) async {}

  @override
  Future<void> subscribeToGroupSchedule({
    required String groupId,
    required String week,
  }) async {}

  @override
  Future<void> subscribeToVehicleAssignments(String vehicleId) async {}

  @override
  Future<void> subscribeToChildAssignments(String childId) async {}

  @override
  Future<void> subscribeToFamilyInvitations(String familyId) async {}

  @override
  Future<void> subscribeToGroupInvitations(String groupId) async {}

  @override
  Future<void> sendScheduleUpdate({
    required String scheduleSlotId,
    required String groupId,
    required String updateType,
    required Map<String, dynamic> updateData,
  }) async {}

  @override
  Future<void> sendVehicleAssignmentUpdate({
    required String vehicleAssignmentId,
    required String scheduleSlotId,
    required String action,
    Map<String, dynamic>? assignmentData,
  }) async {}

  @override
  Future<void> sendChildAssignmentUpdate({
    required String childId,
    required String vehicleAssignmentId,
    required String action,
    Map<String, dynamic>? metadata,
  }) async {}

  @override
  Future<void> sendInvitationUpdate({
    required String invitationId,
    required InvitationStatusDto status, // Fixed - enum imported correctly
    Map<String, dynamic>? metadata,
  }) async {}

  @override
  Future<void> unsubscribe(String channel, String id) async {}

  @override
  Future<void> unsubscribeFromInvitations(
    String id,
    InvitationTypeDto type, // Fixed - enum imported correctly
  ) async {}

  @override
  Future<void> sendUpdate(Map<String, dynamic> update) async {}

  @override
  void emit(String channel, Map<String, dynamic> data) {}
}

// Mock classes for dependencies that don't exist yet
class MockGetFamilyUsecase {}

// REMOVED: MockAddChildUsecase, MockUpdateChildUsecase, MockRemoveChildUsecase per consolidation plan
// These have been replaced with ChildrenService
class MockFamilyRepository {}

class MockChildrenRepository {}

class MockInvitationRepository {}

class MockAppStateNotifier {}

class MockErrorHandlerService {}
