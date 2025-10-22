// EduLift Mobile - WebSocket Event Generators for Testing
// Provides utility methods to generate test WebSocket events

import 'package:edulift/core/network/websocket/websocket_event_models.dart';

/// Utility class to generate WebSocket events for testing
class WebSocketEventGenerators {
  /// Generate a FamilyUpdateEvent for testing
  static FamilyUpdateEvent familyUpdateEvent(
    String updateType,
    Map<String, dynamic> data,
  ) {
    return FamilyUpdateEvent(
      eventId: 'event-${DateTime.now().millisecondsSinceEpoch}',
      familyId: 'family-123',
      updateType: FamilyUpdateType.fromString(updateType),
      familyData: data,
      timestamp: DateTime.now(),
    );
  }

  /// Generate child added event data
  static Map<String, dynamic> childAddedEvent(
    String childId,
    String childName,
  ) {
    return {
      'child': {
        'id': childId,
        'familyId': 'family-123',
        'name': childName,
        'age': 14,
        'createdAt': '2024-08-26T00:00:00.000Z',
        'updatedAt': '2024-08-26T00:00:00.000Z',
      },
    };
  }

  /// Generate child updated event data
  static Map<String, dynamic> childUpdatedEvent(
    String childId,
    String newName,
  ) {
    return {
      'childId': childId,
      'child': {
        'id': childId,
        'familyId': 'family-123',
        'name': newName,
        'age': 14,
        'createdAt': '2024-08-26T00:00:00.000Z',
        'updatedAt': '2024-08-26T00:00:00.000Z',
      },
    };
  }

  /// Generate child deleted event data
  static Map<String, dynamic> childDeletedEvent(String childId) {
    return {'childId': childId};
  }

  /// Generate family updated event data
  static Map<String, dynamic> familyUpdatedEvent(String newName) {
    return {
      'familyId': 'family-123',
      'family': {
        'id': 'family-123',
        'name': newName,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    };
  }

  /// Generate family member joined event data
  static Map<String, dynamic> familyMemberJoinedEvent(
    String email,
    String name,
  ) {
    return {
      'familyId': 'family-123',
      'member': {
        'id': 'member-new',
        'email': email,
        'name': name,
        'role': 'parent',
        'joinedAt': DateTime.now().toIso8601String(),
      },
    };
  }

  /// Generate family member left event data
  static Map<String, dynamic> familyMemberLeftEvent(String memberId) {
    return {'familyId': 'family-123', 'memberId': memberId};
  }

  /// Generate data refresh notification event
  static NotificationEvent dataRefreshNotificationEvent() {
    return NotificationEvent(
      eventId: 'event-${DateTime.now().millisecondsSinceEpoch}',
      notificationId: 'notif-refresh-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Data Refresh',
      message: 'Family data needs to be refreshed',
      priority: NotificationPriority.medium,
      category: 'DATA_REFRESH_TRIGGER',
      data: {'dataType': 'family_data'},
      timestamp: DateTime.now(),
    );
  }
}

// Using production event classes from WebSocketService
