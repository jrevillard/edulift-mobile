// EduLift Mobile - Enhanced WebSocket Tests
// Critical business functionality tests with improved reliability

import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/network/websocket/websocket_event_models.dart';
import 'package:edulift/core/network/websocket/websocket_schedule_events.dart';
import 'package:edulift/infrastructure/network/websocket/socket_events.dart';
import 'websocket_test_utilities.dart';
import 'mock_websocket_service.dart';

void main() {
  group('Enhanced WebSocket Tests - CRITICAL BUSINESS FUNCTIONALITY', () {
    late MockWebSocketService mockWebSocketService;
    late WebSocketTestController testController;
    late WebSocketSubscriptionManager subscriptionManager;

    setUp(() {
      mockWebSocketService = MockWebSocketService();
      testController = WebSocketTestController(mockWebSocketService);
      subscriptionManager = WebSocketSubscriptionManager();

      // Enable deterministic timing for predictable tests
      testController.enableDeterministicTiming();
    });

    tearDown(() async {
      await subscriptionManager.cancelAll();
      mockWebSocketService.dispose();
    });

    group('Schedule Update Event Processing - HIGH PRIORITY', () {
      test(
        'should process schedule slot updates with vehicle assignments',
        () async {
          // Arrange - Real schedule update scenario
          final receivedEvents = <ScheduleUpdateEvent>[];

          subscriptionManager.subscribeToScheduleUpdates(
            mockWebSocketService,
            onEvent: (event) => receivedEvents.add(event),
          );

          // Act - Emit schedule update with vehicle assignment
          final scheduleUpdate =
              WebSocketTestUtilities.createScheduleUpdateEvent(
                scheduleSlotId: 'slot-monday-09-00',
                groupId: 'group-eastside-primary',
                day: 'Monday',
                week: '2024-08-26',
                eventType: ScheduleEventType.scheduleSlotUpdated,
              );

          await testController.emitScheduleUpdate(scheduleUpdate);

          // Assert - Event processed correctly
          expect(receivedEvents, hasLength(1));
          expect(
            receivedEvents.first.scheduleSlotId,
            equals('slot-monday-09-00'),
          );
          expect(
            receivedEvents.first.groupId,
            equals('group-eastside-primary'),
          );
          expect(receivedEvents.first.day, equals('Monday'));
          expect(
            receivedEvents.first.changeType,
            equals(ScheduleChangeType.vehicleAssigned),
          );

          // Verify event log
          expect(
            testController.eventLog,
            contains('SCHEDULE_UPDATE: ScheduleEventType.scheduleSlotUpdated'),
          );
        },
      );

      test('should handle schedule conflict detection events', () async {
        // Arrange - Conflict detection scenario
        final receivedScheduleEvents = <ScheduleUpdateEvent>[];
        final receivedConflicts = <ConflictEvent>[];

        subscriptionManager.subscribeToScheduleUpdates(
          mockWebSocketService,
          onEvent: (event) => receivedScheduleEvents.add(event),
        );

        subscriptionManager.subscribeToConflicts(
          mockWebSocketService,
          onEvent: (event) => receivedConflicts.add(event),
        );

        // Act - Create conflict scenario
        final conflictScheduleUpdate =
            WebSocketTestUtilities.createScheduleUpdateEvent(
              scheduleSlotId: 'slot-conflict-test',
              groupId: 'group-conflict-test',
              eventType: ScheduleEventType.scheduleConflictDetected,
            );

        final conflictEvent = WebSocketTestUtilities.createConflictEvent(
          conflictId: 'conflict-double-booking-123',
          type: ConflictType.resource,
        );

        await testController.emitScheduleUpdate(conflictScheduleUpdate);
        await testController.emitConflict(conflictEvent);

        // Assert - Both events processed
        expect(receivedScheduleEvents, hasLength(1));
        expect(receivedConflicts, hasLength(1));

        expect(receivedScheduleEvents.first.isConflictEvent, isTrue);
        expect(
          receivedConflicts.first.conflictType,
          equals(ConflictType.resource),
        );

        // Verify proper event logging
        expect(
          testController.eventLog,
          contains(
            'SCHEDULE_UPDATE: ScheduleEventType.scheduleConflictDetected',
          ),
        );
        expect(
          testController.eventLog,
          contains('CONFLICT: ConflictType.resource'),
        );
      });

      test('should process child assignment updates via WebSocket', () async {
        // Arrange - Child assignment scenario
        final receivedEvents = <ScheduleUpdateEvent>[];

        subscriptionManager.subscribeToScheduleUpdates(
          mockWebSocketService,
          onEvent: (event) => receivedEvents.add(event),
        );

        // Act - Child assignment update
        final childAssignmentUpdate = ScheduleUpdateEvent(
          eventType: ScheduleEventType.childAssignmentUpdated,
          scheduleSlotId: 'slot-child-assignment-test',
          groupId: 'group-child-test',
          day: 'Tuesday',
          time: '14:30',
          week: '2024-08-26',
          updatedBy: 'parent-user-456',
          updatedByName: 'Sarah Johnson',
          changeType: ScheduleChangeType.childAssigned,
          changeDescription: 'Child assigned to afternoon slot',
          timestamp: DateTime.now(),
        );

        await testController.emitScheduleUpdate(childAssignmentUpdate);

        // Assert - Child assignment processed
        expect(receivedEvents, hasLength(1));
        expect(
          receivedEvents.first.eventType,
          equals(ScheduleEventType.childAssignmentUpdated),
        );
        expect(
          receivedEvents.first.changeType,
          equals(ScheduleChangeType.childAssigned),
        );
        expect(receivedEvents.first.updatedByName, equals('Sarah Johnson'));
      });
    });

    group('Family Event Management - HIGH PRIORITY', () {
      test('should process family member joined events correctly', () async {
        // Arrange - Family member joining scenario
        final receivedFamilyEvents = <FamilyUpdateEvent>[];

        subscriptionManager.subscribeToFamilyUpdates(
          mockWebSocketService,
          onEvent: (event) => receivedFamilyEvents.add(event),
        );

        // Act - Family member joins
        final memberJoinedEvent =
            WebSocketTestUtilities.createFamilyUpdateEvent(
              eventType: SocketEvents.FAMILY_MEMBER_JOINED,
              familyId: 'family-johnson-123',
              data: {
                'member': {
                  'id': 'member-new-456',
                  'email': 'newparent@example.com',
                  'name': 'Alex Johnson',
                  'role': 'parent',
                  'joinedAt': DateTime.now().toIso8601String(),
                },
              },
            );

        await testController.emitFamilyUpdate(memberJoinedEvent);

        // Assert - Member joined event processed
        expect(receivedFamilyEvents, hasLength(1));
        expect(
          receivedFamilyEvents.first.familyId,
          equals('family-johnson-123'),
        );
        expect(
          receivedFamilyEvents.first.updateType.toString(),
          contains('memberJoined'),
        );

        final memberData =
            receivedFamilyEvents.first.familyData['member']
                as Map<String, dynamic>;
        expect(memberData['name'], equals('Alex Johnson'));
        expect(memberData['role'], equals('parent'));

        // Verify event tracking
        expect(
          testController.eventLog,
          contains('FAMILY_UPDATE: FamilyUpdateType.memberJoined'),
        );
      });

      test(
        'should process child addition events with immediate state update',
        () async {
          // Arrange - Child addition scenario (real EduLift workflow)
          final receivedFamilyEvents = <FamilyUpdateEvent>[];
          final receivedNotifications = <NotificationEvent>[];

          subscriptionManager.subscribeToFamilyUpdates(
            mockWebSocketService,
            onEvent: (event) => receivedFamilyEvents.add(event),
          );

          subscriptionManager.subscribeToNotifications(
            mockWebSocketService,
            onEvent: (event) => receivedNotifications.add(event),
          );

          // Act - Child added to family
          final childAddedEvent =
              WebSocketTestUtilities.createFamilyUpdateEvent(
                eventType: SocketEvents.CHILD_ADDED,
                familyId: 'family-wilson-456',
                data: {
                  'child': {
                    'id': 'child-new-emma',
                    'familyId': 'family-wilson-456',
                    'name': 'Emma Wilson',
                    'age': 6,
                    'createdAt': DateTime.now().toIso8601String(),
                    'updatedAt': '2024-08-26T00:00:00.000Z',
                    'createdBy': 'parent-sarah-wilson',
                  },
                },
              );

          await testController.emitFamilyUpdate(childAddedEvent);

          // Simulate data refresh notification (as per actual implementation)
          final dataRefreshNotification =
              WebSocketTestUtilities.createNotificationEvent(
                category: 'DATA_REFRESH_TRIGGER',
                title: 'Family Data Updated',
                message: 'Child Emma added to family',
                data: {
                  'dataType': 'family_data',
                  'childId': 'child-new-emma',
                  'action': 'child_added',
                },
              );

          await testController.emitNotification(dataRefreshNotification);

          // Assert - Both events processed correctly
          expect(receivedFamilyEvents, hasLength(1));
          expect(receivedNotifications, hasLength(1));

          // Verify child data structure
          final childData =
              receivedFamilyEvents.first.familyData['child']
                  as Map<String, dynamic>;
          expect(childData['name'], equals('Emma Wilson'));
          expect(childData['familyId'], equals('family-wilson-456'));
          expect(childData['createdBy'], equals('parent-sarah-wilson'));

          // Verify data refresh notification
          expect(
            receivedNotifications.first.category,
            equals('DATA_REFRESH_TRIGGER'),
          );
          final notificationData = receivedNotifications.first.data ?? {};
          expect(notificationData['childId'], equals('child-new-emma'));
          expect(notificationData['action'], equals('child_added'));
        },
      );

      test(
        'should process child deletion with immediate UI response',
        () async {
          // Arrange - Child deletion scenario (immediate UI update pattern)
          final receivedFamilyEvents = <FamilyUpdateEvent>[];

          subscriptionManager.subscribeToFamilyUpdates(
            mockWebSocketService,
            onEvent: (event) => receivedFamilyEvents.add(event),
          );

          // Act - Child deleted from family
          final childDeletedEvent =
              WebSocketTestUtilities.createFamilyUpdateEvent(
                eventType: SocketEvents.CHILD_DELETED,
                familyId: 'family-wilson-456',
                data: {
                  'childId': 'child-to-remove-789',
                  'deletedAt': DateTime.now().toIso8601String(),
                  'deletedBy': 'parent-sarah-wilson',
                },
              );

          await testController.emitFamilyUpdate(childDeletedEvent);

          // Assert - Immediate deletion processed (no REST API call needed)
          expect(receivedFamilyEvents, hasLength(1));
          expect(
            receivedFamilyEvents.first.updateType.toString(),
            contains('deleted'),
          );
          expect(
            receivedFamilyEvents.first.familyData['childId'],
            equals('child-to-remove-789'),
          );
          expect(
            receivedFamilyEvents.first.familyData['deletedBy'],
            equals('parent-sarah-wilson'),
          );

          // Verify immediate processing (per actual implementation pattern)
          expect(
            testController.eventLog,
            contains('FAMILY_UPDATE: FamilyUpdateType.deleted'),
          );
        },
      );
    });

    group('Real-time Collaboration Scenarios - BUSINESS CRITICAL', () {
      test(
        'should handle concurrent schedule updates from multiple users',
        () async {
          // Arrange - Concurrent updates scenario
          final receivedUpdates = <ScheduleUpdateEvent>[];

          subscriptionManager.subscribeToScheduleUpdates(
            mockWebSocketService,
            onEvent: (event) => receivedUpdates.add(event),
          );

          // Act - Send concurrent updates
          final updates = [
            WebSocketTestUtilities.createScheduleUpdateEvent(
              scheduleSlotId: 'slot-user1-update',
              groupId: 'group-concurrent-test',
              eventType: ScheduleEventType.scheduleSlotUpdated,
            ),
            WebSocketTestUtilities.createScheduleUpdateEvent(
              scheduleSlotId: 'slot-user2-update',
              groupId: 'group-concurrent-test',
              eventType: ScheduleEventType.scheduleSlotUpdated,
            ),
            WebSocketTestUtilities.createScheduleUpdateEvent(
              scheduleSlotId: 'slot-user3-update',
              groupId: 'group-concurrent-test',
              eventType: ScheduleEventType.scheduleSlotUpdated,
            ),
          ];

          // Emit all updates concurrently
          await Future.wait([
            testController.emitScheduleUpdate(updates[0]),
            testController.emitScheduleUpdate(updates[1]),
            testController.emitScheduleUpdate(updates[2]),
          ]);

          // Wait for all processing to complete
          await testController.waitForProcessing();

          // Assert - All concurrent updates processed
          expect(receivedUpdates, hasLength(3));
          expect(
            receivedUpdates.map((e) => e.scheduleSlotId).toSet(),
            hasLength(3),
          );
          expect(
            receivedUpdates.every((e) => e.groupId == 'group-concurrent-test'),
            isTrue,
          );

          // Verify no events were lost
          expect(
            testController.eventLog.where(
              (log) => log.contains('SCHEDULE_UPDATE'),
            ),
            hasLength(3),
          );
        },
      );
    });

    group('Error Recovery and Fault Tolerance - RELIABILITY', () {
      test('should handle malformed schedule update events gracefully', () async {
        // Arrange - Error handling scenario
        final receivedUpdates = <ScheduleUpdateEvent>[];
        var errorCount = 0;

        subscriptionManager.subscribeToScheduleUpdates(
          mockWebSocketService,
          onEvent: (event) => receivedUpdates.add(event),
          onError: (error) => errorCount++,
        );

        // Act - Send valid update, then cause error, then send another valid update
        await testController.emitScheduleUpdate(
          WebSocketTestUtilities.createScheduleUpdateEvent(
            scheduleSlotId: 'slot-valid-1',
            groupId: 'group-error-test',
          ),
        );

        // Emit error
        await testController.emitError(Exception('Malformed schedule update'));

        await testController.emitScheduleUpdate(
          WebSocketTestUtilities.createScheduleUpdateEvent(
            scheduleSlotId: 'slot-valid-2',
            groupId: 'group-error-test',
          ),
        );

        // Assert - Error handled gracefully, valid updates still processed
        expect(receivedUpdates, hasLength(2));
        expect(errorCount, equals(1));
        expect(testController.errorLog, hasLength(1));
        expect(testController.errorLog.first.toString(), contains('Malformed'));

        // Verify stream continues working after error
        final slotIds = receivedUpdates.map((e) => e.scheduleSlotId).toList();
        expect(slotIds, equals(['slot-valid-1', 'slot-valid-2']));
      });

      test('should recover from family event processing errors', () async {
        // Arrange - Error recovery scenario
        final receivedEvents = <FamilyUpdateEvent>[];
        var errorCount = 0;

        subscriptionManager.subscribeToFamilyUpdates(
          mockWebSocketService,
          onEvent: (event) => receivedEvents.add(event),
          onError: (error) => errorCount++,
        );

        // Act - Send valid event, error, then valid event again
        await testController.emitFamilyUpdate(
          WebSocketTestUtilities.createFamilyUpdateEvent(
            eventType: SocketEvents.CHILD_ADDED,
            familyId: 'family-recovery-test',
            data: {
              'child': {'id': 'child-1', 'name': 'First Child'},
            },
          ),
        );

        // Cause error
        await testController.emitError(
          Exception('Family event processing error'),
        );

        await testController.emitFamilyUpdate(
          WebSocketTestUtilities.createFamilyUpdateEvent(
            eventType: SocketEvents.CHILD_ADDED,
            familyId: 'family-recovery-test',
            data: {
              'child': {'id': 'child-2', 'name': 'Second Child'},
            },
          ),
        );

        // Assert - Service recovered and continued processing
        expect(receivedEvents, hasLength(2));
        expect(errorCount, equals(1));

        final firstChildData =
            receivedEvents.first.familyData['child'] as Map<String, dynamic>;
        final lastChildData =
            receivedEvents.last.familyData['child'] as Map<String, dynamic>;
        expect(firstChildData['name'], equals('First Child'));
        expect(lastChildData['name'], equals('Second Child'));

        // Verify error was logged but didn't break the stream
        expect(testController.errorLog, hasLength(1));
        expect(
          testController.errorLog.first.toString(),
          contains('Family event processing error'),
        );
      });
    });

    group('Performance Tests - SCALABILITY', () {
      test(
        'should process schedule updates within acceptable time limits',
        () async {
          // Arrange - Performance test scenario
          testController.disableDeterministicTiming(); // Use real timing
          final receivedUpdates = <ScheduleUpdateEvent>[];

          subscriptionManager.subscribeToScheduleUpdates(
            mockWebSocketService,
            onEvent: (event) => receivedUpdates.add(event),
          );

          // Act - Send multiple updates and measure timing
          final startTime = DateTime.now();
          const updateCount = 25; // Reduced for faster test execution

          for (var i = 0; i < updateCount; i++) {
            await testController.emitScheduleUpdate(
              WebSocketTestUtilities.createScheduleUpdateEvent(
                scheduleSlotId: 'slot-perf-$i',
                groupId: 'group-performance-test',
              ),
            );
          }

          // Wait for all updates to process
          await Future.delayed(const Duration(milliseconds: 100));

          final endTime = DateTime.now();
          final processingDuration = endTime.difference(startTime);

          // Assert - All updates processed within reasonable time
          expect(receivedUpdates, hasLength(updateCount));
          expect(
            processingDuration.inMilliseconds,
            lessThan(500),
          ); // <500ms for 25 updates

          // Verify unique slot IDs
          final uniqueSlotIds = receivedUpdates
              .map((e) => e.scheduleSlotId)
              .toSet();
          expect(uniqueSlotIds, hasLength(updateCount));
        },
      );

      test('should handle family event bursts without memory leaks', () async {
        // Arrange - Memory leak prevention test
        // Memory leak prevention test

        // Act - Create and cancel multiple subscriptions rapidly
        for (var i = 0; i < 20; i++) {
          // Reduced iterations
          final subscription = subscriptionManager.subscribeToFamilyUpdates(
            mockWebSocketService,
          );

          // Send a few events
          await testController.emitFamilyUpdate(
            WebSocketTestUtilities.createFamilyUpdateEvent(
              eventType: SocketEvents.CHILD_UPDATED,
              familyId: 'family-memory-test-$i',
              data: {'testIndex': i},
            ),
          );

          await subscription.cancel();
        }

        // Clean up remaining subscriptions
        await subscriptionManager.cancelAll();

        // Assert - No memory leaks (subscriptions properly cleaned up)
        expect(subscriptionManager.activeSubscriptionCount, equals(0));

        // Verify service is still functional
        subscriptionManager.subscribeToFamilyUpdates(mockWebSocketService);
        await testController.emitFamilyUpdate(
          WebSocketTestUtilities.createFamilyUpdateEvent(
            eventType: SocketEvents.FAMILY_UPDATED,
            familyId: 'family-cleanup-test',
            data: {'verified': true},
          ),
        );

        expect(subscriptionManager.hasReceivedEvents('family'), isTrue);
      });
    });
  });
}
