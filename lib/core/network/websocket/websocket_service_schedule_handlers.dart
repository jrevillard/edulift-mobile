// EduLift Mobile - WebSocket Schedule Event Handlers Extension
// Additional handlers for schedule coordination events

import 'package:flutter/foundation.dart';
import 'websocket_schedule_events.dart';

/// Extension to add schedule event handling to WebSocketService
extension WebSocketScheduleHandlers on dynamic {
  /// Handle schedule update events
  void handleScheduleUpdateEvent(Map<String, dynamic> data) {
    try {
      final event = ScheduleUpdateEvent.fromJson(data);
      // Add to schedule update controller
      if (this.scheduleUpdateController != null) {
        this.scheduleUpdateController.add(event);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing schedule update event: $e');
      }
    }
  }

  /// Handle schedule notification events
  void handleScheduleNotificationEvent(Map<String, dynamic> data) {
    try {
      final event = ScheduleNotificationEvent.fromJson(data);
      // Add to schedule notification controller
      if (this.scheduleNotificationController != null) {
        this.scheduleNotificationController.add(event);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing schedule notification event: $e');
      }
    }
  }
}
