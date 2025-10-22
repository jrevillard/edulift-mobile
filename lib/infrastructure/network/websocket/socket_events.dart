/// Centralized WebSocket event constants
/// MUST match backend src/shared/events.ts exactly
class SocketEvents {
  // Connection Events
  static const String CONNECTED = 'connected';
  static const String DISCONNECTED = 'disconnected';

  // Group Management Events
  static const String GROUP_JOIN = 'group:join';
  static const String GROUP_LEAVE = 'group:leave';
  static const String GROUP_UPDATED = 'group:updated';
  static const String MEMBER_JOINED = 'member:joined';
  static const String MEMBER_LEFT = 'member:left';

  // User Presence Events
  static const String USER_JOINED = 'user:joined';
  static const String USER_LEFT = 'user:left';
  static const String USER_TYPING = 'user:typing';
  static const String USER_STOPPED_TYPING = 'user:stopped_typing';

  // Schedule Events
  static const String SCHEDULE_UPDATED = 'schedule:updated';
  static const String SCHEDULE_SLOT_UPDATED = 'schedule:slot:updated';
  static const String SCHEDULE_SLOT_CREATED = 'schedule:slot:created';
  static const String SCHEDULE_SLOT_DELETED = 'schedule:slot:deleted';

  // Schedule Capacity Events
  static const String SCHEDULE_SLOT_CAPACITY_FULL =
      'scheduleSlot:capacity:full';
  static const String SCHEDULE_SLOT_CAPACITY_WARNING =
      'scheduleSlot:capacity:warning';

  // Schedule Subscription Events
  static const String SCHEDULE_SUBSCRIBE = 'schedule:subscribe';
  static const String SCHEDULE_UNSUBSCRIBE = 'schedule:unsubscribe';
  static const String SCHEDULE_SLOT_JOIN = 'scheduleSlot:join';
  static const String SCHEDULE_SLOT_LEAVE = 'scheduleSlot:leave';

  // Child Management Events
  static const String CHILD_ADDED = 'child:added';
  static const String CHILD_UPDATED = 'child:updated';
  static const String CHILD_DELETED = 'child:deleted';

  // Vehicle Management Events
  static const String VEHICLE_ADDED = 'vehicle:added';
  static const String VEHICLE_UPDATED = 'vehicle:updated';
  static const String VEHICLE_DELETED = 'vehicle:deleted';

  // Family Events (MODERN FORMAT ONLY)
  static const String FAMILY_MEMBER_JOINED = 'family:member:joined';
  static const String FAMILY_MEMBER_LEFT = 'family:member:left';
  static const String FAMILY_UPDATED = 'family:updated';

  // Notification Events
  static const String NOTIFICATION = 'notification';

  // Conflict Detection Events
  static const String CONFLICT_DETECTED = 'conflict:detected';
  static const String SCHEDULE_CONFLICT = 'schedule:conflict';
  static const String DRIVER_DOUBLE_BOOKING = 'driver:double_booking';
  static const String VEHICLE_DOUBLE_BOOKING = 'vehicle:double_booking';
  static const String CAPACITY_EXCEEDED = 'capacity:exceeded';

  // Error Events
  static const String ERROR = 'error';

  // Heartbeat Events
  static const String HEARTBEAT = 'heartbeat';
  static const String HEARTBEAT_ACK = 'heartbeat-ack';

  // Legacy event mappings for backward compatibility (DEPRECATED - will be removed)
  @deprecated
  static const String FAMILY_UPDATE = 'family_update';
  @deprecated
  static const String GROUP_UPDATE = 'group_update';
  @deprecated
  static const String SCHEDULE_UPDATE = 'schedule_update';

  // ==== CURRENT WEBSOCKET SERVICE EVENTS (to be replaced in Phase 3) ====
  // These are the hardcoded strings currently in use - will be systematically replaced

  // Invitation events (legacy format)
  static const String FAMILY_INVITATION_RECEIVED = 'family_invitation_received';
  static const String FAMILY_INVITATION_ACCEPTED = 'family_invitation_accepted';
  static const String FAMILY_INVITATION_DECLINED = 'family_invitation_declined';
  static const String FAMILY_INVITATION_EXPIRED = 'family_invitation_expired';
  static const String FAMILY_INVITATION_CANCELLED =
      'family_invitation_cancelled';
  static const String FAMILY_INVITATION_UPDATED = 'family_invitation_updated';

  static const String GROUP_INVITATION_RECEIVED = 'group_invitation_received';
  static const String GROUP_INVITATION_ACCEPTED = 'group_invitation_accepted';
  static const String GROUP_INVITATION_DECLINED = 'group_invitation_declined';
  static const String GROUP_INVITATION_EXPIRED = 'group_invitation_expired';
  static const String GROUP_INVITATION_CANCELLED = 'group_invitation_cancelled';
  static const String GROUP_INVITATION_UPDATED = 'group_invitation_updated';

  static const String INVITATION_NOTIFICATION = 'invitation_notification';
  static const String INVITATION_REMINDER = 'invitation_reminder';
  static const String INVITATION_STATUS_UPDATE = 'invitation_status_update';

  // Schedule coordination events (legacy format)
  static const String SCHEDULE_SLOT_UPDATED_LEGACY = 'schedule_slot_updated';
  static const String SCHEDULE_CONFLICT_DETECTED = 'schedule_conflict_detected';
  static const String CHILD_ASSIGNMENT_UPDATED = 'child_assignment_updated';
  static const String SCHEDULE_OPTIMIZED = 'schedule_optimized';
  static const String SCHEDULE_PUBLISHED = 'schedule_published';

  // Schedule notification events (legacy format)
  static const String SCHEDULE_CHANGE = 'schedule_change';
  static const String SCHEDULE_CONFLICT_LEGACY =
      'schedule_conflict'; // Use SCHEDULE_CONFLICT instead
  static const String SCHEDULE_REMINDER = 'schedule_reminder';
  static const String SCHEDULE_APPROVAL_NEEDED = 'schedule_approval_needed';
}

/// Event categories for organized handling
class SocketEventCategories {
  static const List<String> CONNECTION_EVENTS = [
    SocketEvents.CONNECTED,
    SocketEvents.DISCONNECTED,
  ];

  static const List<String> FAMILY_EVENTS = [
    SocketEvents.FAMILY_MEMBER_JOINED,
    SocketEvents.FAMILY_MEMBER_LEFT,
    SocketEvents.FAMILY_UPDATED,
  ];

  static const List<String> CHILD_EVENTS = [
    SocketEvents.CHILD_ADDED,
    SocketEvents.CHILD_UPDATED,
    SocketEvents.CHILD_DELETED,
  ];

  static const List<String> VEHICLE_EVENTS = [
    SocketEvents.VEHICLE_ADDED,
    SocketEvents.VEHICLE_UPDATED,
    SocketEvents.VEHICLE_DELETED,
  ];

  static const List<String> SCHEDULE_EVENTS = [
    SocketEvents.SCHEDULE_UPDATED,
    SocketEvents.SCHEDULE_SLOT_CREATED,
    SocketEvents.SCHEDULE_SLOT_UPDATED,
    SocketEvents.SCHEDULE_SLOT_DELETED,
    SocketEvents.SCHEDULE_SLOT_CAPACITY_FULL,
    SocketEvents.SCHEDULE_SLOT_CAPACITY_WARNING,
  ];

  static const List<String> PRESENCE_EVENTS = [
    SocketEvents.USER_JOINED,
    SocketEvents.USER_LEFT,
    SocketEvents.USER_TYPING,
    SocketEvents.USER_STOPPED_TYPING,
  ];

  static const List<String> GROUP_EVENTS = [
    SocketEvents.GROUP_JOIN,
    SocketEvents.GROUP_LEAVE,
    SocketEvents.GROUP_UPDATED,
    SocketEvents.MEMBER_JOINED,
    SocketEvents.MEMBER_LEFT,
  ];

  static const List<String> SUBSCRIPTION_EVENTS = [
    SocketEvents.SCHEDULE_SUBSCRIBE,
    SocketEvents.SCHEDULE_UNSUBSCRIBE,
    SocketEvents.SCHEDULE_SLOT_JOIN,
    SocketEvents.SCHEDULE_SLOT_LEAVE,
  ];

  static const List<String> SYSTEM_EVENTS = [
    SocketEvents.NOTIFICATION,
    SocketEvents.CONFLICT_DETECTED,
    SocketEvents.SCHEDULE_CONFLICT,
    SocketEvents.DRIVER_DOUBLE_BOOKING,
    SocketEvents.VEHICLE_DOUBLE_BOOKING,
    SocketEvents.CAPACITY_EXCEEDED,
    SocketEvents.ERROR,
    SocketEvents.HEARTBEAT,
    SocketEvents.HEARTBEAT_ACK,
  ];
}

/// Event validation utilities
class SocketEventValidator {
  static final Set<String> _allEvents = {
    ...SocketEventCategories.CONNECTION_EVENTS,
    ...SocketEventCategories.FAMILY_EVENTS,
    ...SocketEventCategories.CHILD_EVENTS,
    ...SocketEventCategories.VEHICLE_EVENTS,
    ...SocketEventCategories.SCHEDULE_EVENTS,
    ...SocketEventCategories.PRESENCE_EVENTS,
    ...SocketEventCategories.GROUP_EVENTS,
    ...SocketEventCategories.SUBSCRIPTION_EVENTS,
    ...SocketEventCategories.SYSTEM_EVENTS,
  };

  static bool isValidEvent(String eventName) {
    return _allEvents.contains(eventName);
  }

  static String getEventCategory(String eventName) {
    if (SocketEventCategories.FAMILY_EVENTS.contains(eventName)) {
      return 'FAMILY';
    }
    if (SocketEventCategories.CHILD_EVENTS.contains(eventName)) {
      return 'CHILD';
    }
    if (SocketEventCategories.VEHICLE_EVENTS.contains(eventName)) {
      return 'VEHICLE';
    }
    if (SocketEventCategories.SCHEDULE_EVENTS.contains(eventName)) {
      return 'SCHEDULE';
    }
    if (SocketEventCategories.PRESENCE_EVENTS.contains(eventName)) {
      return 'PRESENCE';
    }
    if (SocketEventCategories.GROUP_EVENTS.contains(eventName)) {
      return 'GROUP';
    }
    if (SocketEventCategories.SUBSCRIPTION_EVENTS.contains(eventName)) {
      return 'SUBSCRIPTION';
    }
    if (SocketEventCategories.SYSTEM_EVENTS.contains(eventName)) {
      return 'SYSTEM';
    }
    if (SocketEventCategories.CONNECTION_EVENTS.contains(eventName)) {
      return 'CONNECTION';
    }
    return 'UNKNOWN';
  }

  static List<String> getAllEvents() => _allEvents.toList();

  static int getTotalEventCount() => _allEvents.length;
}

/// Channel name constants for subscription management
class SocketChannels {
  static const String FAMILY = 'family';
  static const String GROUP = 'group';
  static const String SCHEDULE = 'schedule';
  static const String GROUP_SCHEDULE = 'group_schedule';
  static const String VEHICLE_ASSIGNMENTS = 'vehicle_assignments';
  static const String CHILD_ASSIGNMENTS = 'child_assignments';
  static const String FAMILY_INVITATIONS = 'family_invitations';
  static const String GROUP_INVITATIONS = 'group_invitations';
  static const String USER = 'user';
}

/// Message type constants for WebSocket communication
class SocketMessageTypes {
  static const String SUBSCRIBE = 'subscribe';
  static const String UNSUBSCRIBE = 'unsubscribe';
  static const String EMIT = 'emit';
  static const String UPDATE = 'update';
  static const String PING = 'ping';
  static const String PONG = 'pong';
  static const String SCHEDULE_UPDATE = 'schedule_update';
  static const String VEHICLE_ASSIGNMENT_UPDATE = 'vehicle_assignment_update';
  static const String CHILD_ASSIGNMENT_UPDATE = 'child_assignment_update';
  static const String INVITATION_UPDATE = 'invitation_update';
}

/// Notification type constants for consistency
class NotificationTypes {
  // Capacity and warning notifications
  static const String CAPACITY_WARNING = 'CAPACITY_WARNING';

  // Invitation-related notifications
  static const String INVITATION_NOTIFICATION = 'INVITATION_NOTIFICATION';
  static const String INVITATION_EXPIRED = 'INVITATION_EXPIRED';

  // Group management notifications
  static const String GROUP_MEMBERS_UPDATED = 'GROUP_MEMBERS_UPDATED';

  // System notifications
  static const String DATA_REFRESH_TRIGGER = 'DATA_REFRESH_TRIGGER';

  // Schedule-related notifications
  static const String SCHEDULE_CONFLICT = 'SCHEDULE_CONFLICT';
  static const String SCHEDULE_PUBLISHED = 'SCHEDULE_PUBLISHED';
  static const String MEMBER_JOINED_NOTIFICATION = 'MEMBER_JOINED';
  static const String MEMBER_LEFT_NOTIFICATION = 'MEMBER_LEFT';
}

/// Error code constants
class ErrorCodes {
  static const String UNAUTHORIZED = 'UNAUTHORIZED';
}

/// Conflict type constants
class ConflictTypes {
  static const String SCHEDULE_CONFLICT = 'SCHEDULE_CONFLICT';
  static const String DRIVER_DOUBLE_BOOKING = 'DRIVER_DOUBLE_BOOKING';
  static const String VEHICLE_DOUBLE_BOOKING = 'VEHICLE_DOUBLE_BOOKING';
  static const String CAPACITY_EXCEEDED = 'CAPACITY_EXCEEDED';
}
