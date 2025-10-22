import 'dart:async';
import 'package:flutter/foundation.dart';
import '../websocket/websocket_event_models.dart';
import '../websocket/websocket_service.dart';

/// Provider for managing user presence (online/offline status) in real-time
class PresenceProvider extends ChangeNotifier {
  final WebSocketService _websocketService;

  StreamSubscription<PresenceUpdateEvent>? _presenceSubscription;

  // Presence state
  final Map<String, PresenceStatus> _userPresenceMap = {};
  final Map<String, DateTime> _lastSeenMap = {};
  String? _currentGroupId;

  PresenceProvider(this._websocketService) {
    _initializePresenceListening();
  }

  /// Get current presence status for a user
  PresenceStatus? getUserPresence(String userId) => _userPresenceMap[userId];

  /// Get all online users in current group
  List<String> get onlineUsers => _userPresenceMap.entries
      .where((entry) => entry.value == PresenceStatus.online)
      .map((entry) => entry.key)
      .toList();

  /// Get total online user count
  int get onlineUserCount => onlineUsers.length;

  /// Get last seen timestamp for a user
  DateTime? getLastSeen(String userId) => _lastSeenMap[userId];

  /// Check if a specific user is online
  bool isUserOnline(String userId) =>
      _userPresenceMap[userId] == PresenceStatus.online;

  /// Subscribe to presence updates for a specific group
  Future<void> subscribeToGroup(String groupId) async {
    if (_currentGroupId == groupId) return;

    // Unsubscribe from previous group
    if (_currentGroupId != null) {
      await _websocketService.unsubscribe('group', _currentGroupId!);
      _userPresenceMap.clear();
      _lastSeenMap.clear();
    }

    _currentGroupId = groupId;
    await _websocketService.subscribeToGroup(groupId);

    if (kDebugMode) {
      print('PresenceProvider: Subscribed to presence for group $groupId');
    }

    notifyListeners();
  }

  /// Unsubscribe from current group presence
  Future<void> unsubscribeFromCurrentGroup() async {
    if (_currentGroupId != null) {
      await _websocketService.unsubscribe('group', _currentGroupId!);
      _userPresenceMap.clear();
      _lastSeenMap.clear();
      _currentGroupId = null;

      if (kDebugMode) {
        print('PresenceProvider: Unsubscribed from presence');
      }

      notifyListeners();
    }
  }

  /// Manually update user presence (for optimistic updates)
  void updateUserPresence(String userId, PresenceStatus status) {
    _userPresenceMap[userId] = status;
    _lastSeenMap[userId] = DateTime.now();

    if (kDebugMode) {
      print('PresenceProvider: Updated presence for $userId: $status');
    }

    notifyListeners();
  }

  /// Initialize WebSocket presence listening
  void _initializePresenceListening() {
    _presenceSubscription?.cancel();
    _presenceSubscription = _websocketService.presenceUpdates.listen(
      _handlePresenceUpdate,
      onError: (error) {
        if (kDebugMode) {
          print(
            'PresenceProvider: Error listening to presence updates: $error',
          );
        }
      },
    );
  }

  /// Handle incoming presence update events
  void _handlePresenceUpdate(PresenceUpdateEvent event) {
    try {
      // Only process events for current group
      if (_currentGroupId != null && event.groupId != _currentGroupId) {
        return;
      }

      _userPresenceMap[event.userId] = event.status;
      _lastSeenMap[event.userId] = event.timestamp;

      if (kDebugMode) {
        print('PresenceProvider: User ${event.userId} is now ${event.status}');
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('PresenceProvider: Error handling presence update: $e');
      }
    }
  }

  /// Get presence summary for debugging
  Map<String, dynamic> getPresenceSummary() {
    return {
      'currentGroupId': _currentGroupId,
      'totalUsers': _userPresenceMap.length,
      'onlineUsers': onlineUserCount,
      'userPresence': _userPresenceMap.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  @override
  void dispose() {
    _presenceSubscription?.cancel();
    if (_currentGroupId != null) {
      // Note: Can't await in dispose, so we'll just cancel
      _websocketService.unsubscribe('group', _currentGroupId!);
    }
    super.dispose();
  }
}
