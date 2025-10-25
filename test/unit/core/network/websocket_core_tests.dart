// EduLift Mobile - Core WebSocket Tests
// Essential WebSocket functionality tests focusing on business-critical features

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/network/websocket/websocket_event_models.dart';
import 'package:edulift/core/network/websocket/websocket_schedule_events.dart';
import 'package:edulift/infrastructure/network/websocket/socket_events.dart';
import 'mock_websocket_service.dart';

void main() {
  group('Core WebSocket Tests - BUSINESS CRITICAL FUNCTIONALITY', () {
    late MockWebSocketService mockWebSocketService;

    setUp(() {
      mockWebSocketService = MockWebSocketService();
    });

    tearDown(() {
      mockWebSocketService.dispose();
    });

    group('Schedule Update Processing - HIGH PRIORITY', () {
      test('should process vehicle assignment updates correctly', () async {
        // Arrange
        final receivedEvents = <ScheduleUpdateEvent>[];
        final subscription = mockWebSocketService.scheduleUpdates.listen(
          (event) => receivedEvents.add(event),
        );

        // Act - Create and emit schedule update
        final scheduleUpdate = ScheduleUpdateEvent(
          eventType: ScheduleEventType.scheduleSlotUpdated,
          scheduleSlotId: 'slot-monday-09-00',
          groupId: 'group-eastside-primary',
          day: 'Monday',
          time: '09:00',
          week: '2024-08-26',
          updatedBy: 'parent-user-123',
          updatedByName: 'Sarah Wilson',
          changeType: ScheduleChangeType.vehicleAssigned,
          changeDescription: 'Vehicle assigned to Monday morning slot',
          timestamp: DateTime.now(),
        );

        mockWebSocketService.emitScheduleUpdate(scheduleUpdate);

        // Wait for processing
        await Future.delayed(const Duration(milliseconds: 10));

        // Assert
        expect(receivedEvents, hasLength(1));
        expect(
          receivedEvents.first.scheduleSlotId,
          equals('slot-monday-09-00'),
        );
        expect(receivedEvents.first.groupId, equals('group-eastside-primary'));
        expect(
          receivedEvents.first.changeType,
          equals(ScheduleChangeType.vehicleAssigned),
        );
        expect(receivedEvents.first.updatedByName, equals('Sarah Wilson'));

        await subscription.cancel();
      });

      test('should handle schedule conflicts correctly', () async {
        // Arrange
        final receivedScheduleEvents = <ScheduleUpdateEvent>[];
        final receivedConflicts = <ConflictEvent>[];

        final scheduleSubscription = mockWebSocketService.scheduleUpdates
            .listen((event) => receivedScheduleEvents.add(event));

        final conflictSubscription = mockWebSocketService.conflicts.listen(
          (event) => receivedConflicts.add(event),
        );

        // Act - Create conflict scenario
        final conflictScheduleUpdate = ScheduleUpdateEvent(
          eventType: ScheduleEventType.scheduleConflictDetected,
          scheduleSlotId: 'slot-conflict-test',
          groupId: 'group-conflict-test',
          day: 'Tuesday',
          time: '14:30',
          week: '2024-08-26',
          updatedBy: 'system',
          updatedByName: 'System Scheduler',
          changeType: ScheduleChangeType.conflictDetected,
          changeDescription: 'Double booking detected',
          timestamp: DateTime.now(),
        );

        final conflictEvent = ConflictEvent(
          eventId: 'conflict-event-123',
          conflictId: 'conflict-double-booking-456',
          conflictType: ConflictType.resource,
          severity: ConflictSeverity.high,
          description: 'Vehicle double booking detected',
          groupId: 'group-conflict-test',
          scheduleSlotId: 'slot-conflict-test',
          conflictData: {
            'originalSlot': 'slot-conflict-test',
            'conflictingSlot': 'slot-conflict-other',
            'vehicleId': 'vehicle-123',
          },
          timestamp: DateTime.now(),
        );

        mockWebSocketService.emitScheduleUpdate(conflictScheduleUpdate);
        mockWebSocketService.emitConflict(conflictEvent);

        await Future.delayed(const Duration(milliseconds: 10));

        // Assert
        expect(receivedScheduleEvents, hasLength(1));
        expect(receivedConflicts, hasLength(1));

        expect(receivedScheduleEvents.first.isConflictEvent, isTrue);
        expect(
          receivedConflicts.first.conflictType,
          equals(ConflictType.resource),
        );
        expect(receivedConflicts.first.severity, equals(ConflictSeverity.high));

        await scheduleSubscription.cancel();
        await conflictSubscription.cancel();
      });

      test('should process child assignment changes', () async {
        // Arrange
        final receivedEvents = <ScheduleUpdateEvent>[];
        final subscription = mockWebSocketService.scheduleUpdates.listen(
          (event) => receivedEvents.add(event),
        );

        // Act
        final childAssignmentEvent = ScheduleUpdateEvent(
          eventType: ScheduleEventType.childAssignmentUpdated,
          scheduleSlotId: 'slot-child-assignment',
          groupId: 'group-child-test',
          day: 'Wednesday',
          time: '15:30',
          week: '2024-08-26',
          updatedBy: 'parent-456',
          updatedByName: 'Mike Johnson',
          changeType: ScheduleChangeType.childAssigned,
          changeDescription: 'Emma assigned to Wednesday pickup',
          timestamp: DateTime.now(),
        );

        mockWebSocketService.emitScheduleUpdate(childAssignmentEvent);
        await Future.delayed(const Duration(milliseconds: 10));

        // Assert
        expect(receivedEvents, hasLength(1));
        expect(
          receivedEvents.first.eventType,
          equals(ScheduleEventType.childAssignmentUpdated),
        );
        expect(
          receivedEvents.first.changeType,
          equals(ScheduleChangeType.childAssigned),
        );
        expect(receivedEvents.first.updatedByName, equals('Mike Johnson'));

        await subscription.cancel();
      });
    });

    group('Family Event Processing - HIGH PRIORITY', () {
      test('should process child addition events', () async {
        // Arrange
        final receivedEvents = <FamilyUpdateEvent>[];
        final subscription = mockWebSocketService.familyUpdates.listen(
          (event) => receivedEvents.add(event),
        );

        // Act
        final childAddedEvent = FamilyUpdateEvent(
          eventId: 'family-event-123',
          familyId: 'family-wilson-456',
          updateType: FamilyUpdateType.fromString(SocketEvents.CHILD_ADDED),
          familyData: {
            'child': {
              'id': 'child-new-emma',
              'familyId': 'family-wilson-456',
              'name': 'Emma Wilson',
              'age': 6,
              'createdAt': '2024-08-26T00:00:00.000Z',
              'updatedAt': '2024-08-26T00:00:00.000Z',
              'createdBy': 'parent-sarah-wilson',
            },
          },
          timestamp: DateTime.now(),
        );

        mockWebSocketService.emitFamilyUpdate(childAddedEvent);
        await Future.delayed(const Duration(milliseconds: 10));

        // Assert
        expect(receivedEvents, hasLength(1));
        expect(receivedEvents.first.familyId, equals('family-wilson-456'));
        expect(
          receivedEvents.first.updateType,
          equals(FamilyUpdateType.childAdded),
        );

        final childData =
            receivedEvents.first.familyData['child'] as Map<String, dynamic>;
        expect(childData['name'], equals('Emma Wilson'));
        expect(childData['createdBy'], equals('parent-sarah-wilson'));

        await subscription.cancel();
      });

      test('should process family member joined events', () async {
        // Arrange
        final receivedEvents = <FamilyUpdateEvent>[];
        final subscription = mockWebSocketService.familyUpdates.listen(
          (event) => receivedEvents.add(event),
        );

        // Act
        final memberJoinedEvent = FamilyUpdateEvent(
          eventId: 'family-member-event-456',
          familyId: 'family-johnson-123',
          updateType: FamilyUpdateType.fromString(
            SocketEvents.FAMILY_MEMBER_JOINED,
          ),
          familyData: {
            'member': {
              'id': 'member-new-789',
              'email': 'newparent@example.com',
              'name': 'Alex Johnson',
              'role': 'parent',
              'joinedAt': DateTime.now().toIso8601String(),
            },
          },
          timestamp: DateTime.now(),
        );

        mockWebSocketService.emitFamilyUpdate(memberJoinedEvent);
        await Future.delayed(const Duration(milliseconds: 10));

        // Assert
        expect(receivedEvents, hasLength(1));
        expect(receivedEvents.first.familyId, equals('family-johnson-123'));
        expect(
          receivedEvents.first.updateType.toString(),
          contains('memberJoined'),
        );

        final memberData =
            receivedEvents.first.familyData['member'] as Map<String, dynamic>;
        expect(memberData['name'], equals('Alex Johnson'));
        expect(memberData['role'], equals('parent'));

        await subscription.cancel();
      });

      test('should handle child deletion with immediate response', () async {
        // Arrange
        final receivedEvents = <FamilyUpdateEvent>[];
        final subscription = mockWebSocketService.familyUpdates.listen(
          (event) => receivedEvents.add(event),
        );

        // Act
        final childDeletedEvent = FamilyUpdateEvent(
          eventId: 'family-delete-event-789',
          familyId: 'family-wilson-456',
          updateType: FamilyUpdateType.fromString(SocketEvents.CHILD_DELETED),
          familyData: {
            'childId': 'child-to-remove-123',
            'deletedBy': 'parent-sarah-wilson',
            'deletedAt': DateTime.now().toIso8601String(),
          },
          timestamp: DateTime.now(),
        );

        mockWebSocketService.emitFamilyUpdate(childDeletedEvent);
        await Future.delayed(const Duration(milliseconds: 10));

        // Assert - Immediate deletion processed
        expect(receivedEvents, hasLength(1));
        expect(
          receivedEvents.first.updateType,
          equals(FamilyUpdateType.childDeleted),
        );
        expect(
          receivedEvents.first.familyData['childId'],
          equals('child-to-remove-123'),
        );
        expect(
          receivedEvents.first.familyData['deletedBy'],
          equals('parent-sarah-wilson'),
        );

        await subscription.cancel();
      });
    });

    group('Notification Processing - REAL-TIME ALERTS', () {
      test('should process data refresh notifications', () async {
        // Arrange
        final receivedNotifications = <NotificationEvent>[];
        final subscription = mockWebSocketService.notifications.listen(
          (event) => receivedNotifications.add(event),
        );

        // Act
        final dataRefreshNotification = NotificationEvent(
          eventId: 'notification-event-123',
          notificationId: 'data-refresh-456',
          title: 'Family Data Updated',
          message: 'Child Emma added to family',
          priority: NotificationPriority.medium,
          category: 'DATA_REFRESH_TRIGGER',
          data: {
            'dataType': 'family_data',
            'childId': 'child-new-emma',
            'action': 'child_added',
          },
          timestamp: DateTime.now(),
        );

        mockWebSocketService.emitNotification(dataRefreshNotification);
        await Future.delayed(const Duration(milliseconds: 10));

        // Assert
        expect(receivedNotifications, hasLength(1));
        expect(
          receivedNotifications.first.category,
          equals('DATA_REFRESH_TRIGGER'),
        );
        expect(
          receivedNotifications.first.title,
          equals('Family Data Updated'),
        );

        final notificationData = receivedNotifications.first.data ?? {};
        expect(notificationData['childId'], equals('child-new-emma'));
        expect(notificationData['action'], equals('child_added'));

        await subscription.cancel();
      });

      test('should process schedule conflict notifications', () async {
        // Arrange
        final receivedNotifications = <NotificationEvent>[];
        final subscription = mockWebSocketService.notifications.listen(
          (event) => receivedNotifications.add(event),
        );

        // Act
        final conflictNotification = NotificationEvent(
          eventId: 'conflict-notification-789',
          notificationId: 'schedule-conflict-123',
          title: 'Schedule Conflict Detected',
          message: 'Double booking detected for Tuesday 2:30 PM slot',
          priority: NotificationPriority.high,
          category: 'SCHEDULE_CONFLICT',
          data: {
            'conflictType': 'double_booking',
            'affectedSlots': ['slot-tuesday-14-30', 'slot-tuesday-14-45'],
            'groupId': 'group-conflict-demo',
          },
          timestamp: DateTime.now(),
        );

        mockWebSocketService.emitNotification(conflictNotification);
        await Future.delayed(const Duration(milliseconds: 10));

        // Assert
        expect(receivedNotifications, hasLength(1));
        expect(
          receivedNotifications.first.category,
          equals('SCHEDULE_CONFLICT'),
        );
        expect(
          receivedNotifications.first.priority,
          equals(NotificationPriority.high),
        );
        expect(receivedNotifications.first.title, contains('Conflict'));

        final notificationData = receivedNotifications.first.data ?? {};
        expect(notificationData['conflictType'], equals('double_booking'));
        expect(notificationData['groupId'], equals('group-conflict-demo'));

        await subscription.cancel();
      });
    });

    group('Error Handling and Resilience - RELIABILITY', () {
      test('should handle stream errors gracefully', () async {
        // Arrange
        final receivedEvents = <FamilyUpdateEvent>[];
        var errorCount = 0;

        final subscription = mockWebSocketService.familyUpdates.listen(
          (event) => receivedEvents.add(event),
          onError: (error) => errorCount++,
        );

        // Act - Send valid event, then error, then valid event
        final validEvent1 = FamilyUpdateEvent(
          eventId: 'valid-event-1',
          familyId: 'family-test',
          updateType: FamilyUpdateType.fromString(SocketEvents.CHILD_ADDED),
          familyData: {
            'child': {'id': 'child-1', 'name': 'First Child'},
          },
          timestamp: DateTime.now(),
        );

        final validEvent2 = FamilyUpdateEvent(
          eventId: 'valid-event-2',
          familyId: 'family-test',
          updateType: FamilyUpdateType.fromString(SocketEvents.CHILD_ADDED),
          familyData: {
            'child': {'id': 'child-2', 'name': 'Second Child'},
          },
          timestamp: DateTime.now(),
        );

        mockWebSocketService.emitFamilyUpdate(validEvent1);
        mockWebSocketService.emitError(Exception('Test error'));
        mockWebSocketService.emitFamilyUpdate(validEvent2);

        await Future.delayed(const Duration(milliseconds: 10));

        // Assert - Error handled, stream continues
        expect(receivedEvents, hasLength(2));
        expect(errorCount, equals(1));

        final firstChild =
            receivedEvents.first.familyData['child'] as Map<String, dynamic>;
        final secondChild =
            receivedEvents.last.familyData['child'] as Map<String, dynamic>;
        expect(firstChild['name'], equals('First Child'));
        expect(secondChild['name'], equals('Second Child'));

        await subscription.cancel();
      });

      test('should handle concurrent events without data loss', () async {
        // Arrange
        final receivedEvents = <ScheduleUpdateEvent>[];
        final subscription = mockWebSocketService.scheduleUpdates.listen(
          (event) => receivedEvents.add(event),
        );

        // Act - Send multiple concurrent events
        final events = List.generate(
          10,
          (i) => ScheduleUpdateEvent(
            eventType: ScheduleEventType.scheduleSlotUpdated,
            scheduleSlotId: 'slot-concurrent-$i',
            groupId: 'group-concurrent-test',
            day: 'Monday',
            time: '09:${i.toString().padLeft(2, '0')}',
            week: '2024-08-26',
            updatedBy: 'user-$i',
            updatedByName: 'User $i',
            changeType: ScheduleChangeType.vehicleAssigned,
            changeDescription: 'Concurrent update $i',
            timestamp: DateTime.now(),
          ),
        );

        // Emit all events concurrently
        for (final event in events) {
          mockWebSocketService.emitScheduleUpdate(event);
        }

        await Future.delayed(const Duration(milliseconds: 50));

        // Assert - All events processed without loss
        expect(receivedEvents, hasLength(10));

        // Verify all unique slot IDs received
        final receivedSlotIds =
            receivedEvents.map((e) => e.scheduleSlotId).toSet();
        expect(receivedSlotIds, hasLength(10));

        // Verify all events are from concurrent test
        expect(
          receivedEvents.every((e) => e.groupId == 'group-concurrent-test'),
          isTrue,
        );

        await subscription.cancel();
      });
    });

    group('Memory Management - RESOURCE SAFETY', () {
      test('should properly dispose resources', () async {
        // Arrange
        final subscriptions = <StreamSubscription>[];

        // Act - Create multiple subscriptions
        subscriptions.add(mockWebSocketService.familyUpdates.listen((_) {}));
        subscriptions.add(mockWebSocketService.scheduleUpdates.listen((_) {}));
        subscriptions.add(mockWebSocketService.notifications.listen((_) {}));
        subscriptions.add(mockWebSocketService.conflicts.listen((_) {}));

        // Verify subscriptions are active
        expect(subscriptions, hasLength(4));

        // Cancel all subscriptions
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }

        // Dispose service
        mockWebSocketService.dispose();

        // Assert - Resources cleaned up
        expect(mockWebSocketService.subscriptionsClosed, isTrue);
      });

      test(
        'should handle rapid subscription creation and cancellation',
        () async {
          // Arrange & Act - Rapidly create and cancel subscriptions
          const subscriptionCount = 50;
          final subscriptions = <StreamSubscription>[];

          for (var i = 0; i < subscriptionCount; i++) {
            final subscription = mockWebSocketService.familyUpdates.listen(
              (_) {},
            );
            subscriptions.add(subscription);

            // Immediately cancel every other subscription
            if (i % 2 == 0) {
              await subscription.cancel();
            }
          }

          // Cancel remaining subscriptions
          for (final subscription in subscriptions) {
            await subscription.cancel();
          }

          // Assert - No memory leaks or exceptions
          expect(() => mockWebSocketService.dispose(), returnsNormally);
        },
      );
    });
  });
}
