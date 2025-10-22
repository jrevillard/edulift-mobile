import 'dart:async';
import 'package:flutter/foundation.dart';
import '../websocket/websocket_event_models.dart';
import '../websocket/websocket_service.dart';
import '../../../infrastructure/network/websocket/socket_events.dart';

/// Provider for managing real-time typing indicators
class TypingIndicatorProvider extends ChangeNotifier {
  final WebSocketService _websocketService;

  StreamSubscription<TypingIndicatorEvent>? _typingSubscription;

  // Typing state
  final Map<String, TypingIndicatorData> _typingUsers = {};
  final Map<String, Timer> _typingTimeouts = {};
  String? _currentGroupId;

  static const Duration typingTimeout = Duration(seconds: 3);

  TypingIndicatorProvider(this._websocketService) {
    _initializeTypingListening();
  }

  /// Get all currently typing users
  List<TypingIndicatorData> get typingUsers =>
      _typingUsers.values.where((data) => data.isTyping).toList();

  /// Get typing users as a formatted string
  String get typingUsersText {
    final users = typingUsers;
    if (users.isEmpty) return '';

    if (users.length == 1) {
      return '${users.first.userName} is typing...';
    } else if (users.length == 2) {
      return '${users.first.userName} and ${users.last.userName} are typing...';
    } else {
      return '${users.first.userName} and ${users.length - 1} others are typing...';
    }
  }

  /// Check if any users are typing
  bool get hasTypingUsers => typingUsers.isNotEmpty;

  /// Check if a specific user is typing
  bool isUserTyping(String userId) => _typingUsers[userId]?.isTyping == true;

  /// Subscribe to typing indicators for a specific group/chat
  Future<void> subscribeToGroup(String groupId) async {
    if (_currentGroupId == groupId) return;

    // Clear previous state
    _clearAllTyping();
    _currentGroupId = groupId;

    // Note: In a real implementation, you might need to subscribe
    // to a specific typing channel for the group

    if (kDebugMode) {
      print('TypingIndicatorProvider: Subscribed to typing for group $groupId');
    }

    notifyListeners();
  }

  /// Unsubscribe from current group typing indicators
  Future<void> unsubscribeFromCurrentGroup() async {
    _clearAllTyping();
    _currentGroupId = null;

    if (kDebugMode) {
      print('TypingIndicatorProvider: Unsubscribed from typing indicators');
    }

    notifyListeners();
  }

  /// Manually trigger typing indicator (when current user starts typing)
  void startTyping(String? chatId) {
    if (_currentGroupId == null) return;

    // Send typing event to server
    _websocketService.sendUpdate({
      'type': SocketEvents.USER_TYPING,
      'groupId': _currentGroupId,
      'chatId': chatId,
      'timestamp': DateTime.now().toIso8601String(),
    });

    if (kDebugMode) {
      print(
        'TypingIndicatorProvider: Started typing in group $_currentGroupId',
      );
    }
  }

  /// Stop typing indicator (when current user stops typing)
  void stopTyping(String? chatId) {
    if (_currentGroupId == null) return;

    // Send stop typing event to server
    _websocketService.sendUpdate({
      'type': SocketEvents.USER_STOPPED_TYPING,
      'groupId': _currentGroupId,
      'chatId': chatId,
      'timestamp': DateTime.now().toIso8601String(),
    });

    if (kDebugMode) {
      print(
        'TypingIndicatorProvider: Stopped typing in group $_currentGroupId',
      );
    }
  }

  /// Initialize WebSocket typing listening
  void _initializeTypingListening() {
    _typingSubscription?.cancel();
    _typingSubscription = _websocketService.typingIndicator.listen(
      _handleTypingUpdate,
      onError: (error) {
        if (kDebugMode) {
          print(
            'TypingIndicatorProvider: Error listening to typing updates: $error',
          );
        }
      },
    );
  }

  /// Handle incoming typing indicator events
  void _handleTypingUpdate(TypingIndicatorEvent event) {
    try {
      // Only process events for current group
      if (_currentGroupId != null && event.groupId != _currentGroupId) {
        return;
      }

      final userId = event.userId;

      // Cancel existing timeout for this user
      _typingTimeouts[userId]?.cancel();

      final typingState = event.state;
      if (typingState == TypingState.typing) {
        // User started typing
        _typingUsers[userId] = TypingIndicatorData(
          userId: userId,
          userName: event.userName,
          isTyping: true,
          timestamp: event.timestamp,
        );

        // Set timeout to automatically stop typing after timeout duration
        _typingTimeouts[userId] = Timer(typingTimeout, () {
          _removeTypingUser(userId);
        });

        if (kDebugMode) {
          print('TypingIndicatorProvider: ${event.userName} started typing');
        }
      } else {
        // User stopped typing
        _removeTypingUser(userId);

        if (kDebugMode) {
          print('TypingIndicatorProvider: ${event.userName} stopped typing');
        }
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('TypingIndicatorProvider: Error handling typing update: $e');
      }
    }
  }

  /// Remove a user from typing state
  void _removeTypingUser(String userId) {
    _typingUsers.remove(userId);
    _typingTimeouts[userId]?.cancel();
    _typingTimeouts.remove(userId);
    notifyListeners();
  }

  /// Clear all typing indicators
  void _clearAllTyping() {
    _typingUsers.clear();
    for (final timer in _typingTimeouts.values) {
      timer.cancel();
    }
    _typingTimeouts.clear();
  }

  /// Get typing summary for debugging
  Map<String, dynamic> getTypingSummary() {
    return {
      'currentGroupId': _currentGroupId,
      'typingUserCount': typingUsers.length,
      'typingUsers': typingUsers
          .map(
            (data) => {
              'userId': data.userId,
              'userName': data.userName,
              'timestamp': data.timestamp.toIso8601String(),
            },
          )
          .toList(),
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  @override
  void dispose() {
    _typingSubscription?.cancel();
    _clearAllTyping();
    super.dispose();
  }
}

/// Data class for typing indicator information
@immutable
class TypingIndicatorData {
  final String userId;
  final String userName;
  final bool isTyping;
  final DateTime timestamp;

  const TypingIndicatorData({
    required this.userId,
    required this.userName,
    required this.isTyping,
    required this.timestamp,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TypingIndicatorData &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() =>
      'TypingIndicatorData(userId: $userId, userName: $userName, isTyping: $isTyping)';
}
