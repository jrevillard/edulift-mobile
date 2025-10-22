// EduLift Mobile - API Constants
// Centralized API endpoint path definitions
// Note: Configuration values (URLs, timeouts) moved to EnvironmentConfig/AppConfig system

/// API endpoint path constants for EduLift mobile application
/// Contains only endpoint path definitions - no configuration values
/// Configuration values like URLs and timeouts are now handled by EnvironmentConfig/AppConfig
class ApiConstants {
  // Private constructor to prevent instantiation
  ApiConstants._();

  // ========================================
  // AUTHENTICATION ENDPOINTS
  // ========================================

  static const String authMagicLink = '/auth/magic-link';
  static const String authVerify = '/auth/verify';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  static const String authProfile = '/auth/profile';
  static const String authTestConfig = '/auth/test-config';

  // ========================================
  // DASHBOARD ENDPOINTS
  // ========================================

  static const String dashboardStats = '/dashboard/stats';
  static const String dashboardTodaySchedule = '/dashboard/today-schedule';
  static const String dashboardWeeklySchedule = '/dashboard/weekly-schedule';
  static const String dashboardRecentActivity = '/dashboard/recent-activity';

  // ========================================
  // FAMILY MANAGEMENT ENDPOINTS
  // ========================================

  static const String families = '/families';
  static const String familiesCurrent = '/families/current';
  static const String familiesJoin = '/families/join';
  static const String familiesInviteCode = '/families/invite-code';
  static const String familiesName = '/families/name';

  // Dynamic family endpoints
  static String familyPermissions(String familyId) =>
      '/families/$familyId/permissions';
  static String familyInvite(String familyId) => '/families/$familyId/invite';
  static String familyInvitations(String familyId) =>
      '/families/$familyId/invitations';
  static String familyInvitationCancel(String familyId, String invitationId) =>
      '/families/$familyId/invitations/$invitationId';
  static String familyMemberRole(String memberId) =>
      '/families/members/$memberId/role';
  static String familyMemberRemove(String familyId, String memberId) =>
      '/families/$familyId/members/$memberId';
  static String familyLeave(String familyId) => '/families/$familyId/leave';

  // ========================================
  // CHILDREN MANAGEMENT ENDPOINTS
  // ========================================

  static const String children = '/children';

  static String childDetails(String childId) => '/children/$childId';
  static String childAssignments(String childId) =>
      '/children/$childId/assignments';
  static String childGroups(String childId) => '/children/$childId/groups';
  static String childGroupAdd(String childId, String groupId) =>
      '/children/$childId/groups/$groupId';
  static String childGroupRemove(String childId, String groupId) =>
      '/children/$childId/groups/$groupId';

  // ========================================
  // VEHICLE MANAGEMENT ENDPOINTS
  // ========================================

  static const String vehicles = '/vehicles';

  static String vehicleDetails(String vehicleId) => '/vehicles/$vehicleId';
  static String vehicleSchedule(String vehicleId) =>
      '/vehicles/$vehicleId/schedule';
  static String vehiclesAvailable(String groupId, String timeSlotId) =>
      '/vehicles/available/$groupId/$timeSlotId';

  // ========================================
  // GROUP MANAGEMENT ENDPOINTS
  // ========================================

  static const String groups = '/groups';
  static const String groupsMyGroups = '/groups/my-groups';
  static const String groupsJoin = '/groups/join';

  // Group schedule configuration
  static const String groupsScheduleConfigDefault =
      '/groups/schedule-config/default';
  static const String groupsScheduleConfigInitialize =
      '/groups/schedule-config/initialize';

  // Dynamic group endpoints
  static String groupDetails(String groupId) => '/groups/$groupId';
  static String groupFamilies(String groupId) => '/groups/$groupId/families';
  static String groupLeave(String groupId) => '/groups/$groupId/leave';
  static String groupFamilyRole(String groupId, String familyId) =>
      '/groups/$groupId/families/$familyId/role';
  static String groupFamilyRemove(String groupId, String familyId) =>
      '/groups/$groupId/families/$familyId';
  static String groupSearchFamilies(String groupId) =>
      '/groups/$groupId/search-families';
  static String groupInvite(String groupId) => '/groups/$groupId/invite';
  static String groupInvitations(String groupId) =>
      '/groups/$groupId/invitations';
  static String groupInvitationCancel(String groupId, String invitationId) =>
      '/groups/$groupId/invitations/$invitationId';

  // Group schedule configuration
  static String groupScheduleConfig(String groupId) =>
      '/groups/$groupId/schedule-config';
  static String groupScheduleConfigTimeSlots(String groupId) =>
      '/groups/$groupId/schedule-config/time-slots';
  static String groupScheduleConfigReset(String groupId) =>
      '/groups/$groupId/schedule-config/reset';

  // ========================================
  // SCHEDULE MANAGEMENT ENDPOINTS
  // ========================================

  // Schedule slot creation
  static String groupScheduleSlots(String groupId) =>
      '/groups/$groupId/schedule-slots';
  static String groupSchedule(String groupId) => '/groups/$groupId/schedule';

  // Schedule slot management
  static String scheduleSlotDetails(String slotId) => '/schedule-slots/$slotId';
  static String scheduleSlotVehicles(String slotId) =>
      '/schedule-slots/$slotId/vehicles';
  static String scheduleSlotVehicleDriver(String slotId, String vehicleId) =>
      '/schedule-slots/$slotId/vehicles/$vehicleId/driver';

  // Children assignment endpoints
  static String scheduleSlotChildren(String slotId) =>
      '/schedule-slots/$slotId/children';
  static String scheduleSlotChildRemove(String slotId, String childId) =>
      '/schedule-slots/$slotId/children/$childId';

  // Advanced schedule features
  static String scheduleSlotAvailableChildren(String slotId) =>
      '/schedule-slots/$slotId/available-children';
  static String scheduleSlotConflicts(String slotId) =>
      '/schedule-slots/$slotId/conflicts';

  // Vehicle assignment management
  static String vehicleAssignmentSeatOverride(String vehicleAssignmentId) =>
      '/vehicle-assignments/$vehicleAssignmentId/seat-override';

  // ========================================
  // UNIFIED INVITATIONS SYSTEM
  // ========================================

  static const String invitationsValidate = '/invitations/validate';
  static String invitationValidateCode(String code) =>
      '/invitations/validate/$code';
  static String invitationFamilyValidate(String code) =>
      '/invitations/family/$code/validate';
  static String invitationGroupValidate(String code) =>
      '/invitations/group/$code/validate';

  static const String invitationsFamily = '/invitations/family';
  static String invitationFamilyAccept(String code) =>
      '/invitations/family/$code/accept';

  static const String invitationsGroup = '/invitations/group';
  static String invitationGroupAccept(String code) =>
      '/invitations/group/$code/accept';

  static const String invitationsUser = '/invitations/user';
  static String invitationFamilyCancel(String invitationId) =>
      '/invitations/family/$invitationId';
  static String invitationGroupCancel(String invitationId) =>
      '/invitations/group/$invitationId';

  // ========================================
  // HEALTH & MONITORING ENDPOINTS
  // ========================================

  static const String health = '/health';
  static const String healthDatabase = '/health/database';

  // ========================================
  // WEBSOCKET EVENTS
  // ========================================

  // Client events (emit)
  static const String wsJoinSchedule = 'join-schedule';
  static const String wsUpdateVehicleAssignment = 'update-vehicle-assignment';
  static const String wsAssignChild = 'assign-child';
  static const String wsTypingStart = 'typing-start';
  static const String wsTypingStop = 'typing-stop';

  // Server events (listen)
  static const String wsVehicleAssignmentUpdated = 'vehicle-assignment-updated';
  static const String wsChildAssignmentUpdated = 'child-assignment-updated';
  static const String wsCapacityWarning = 'capacity-warning';
  static const String wsConflictDetected = 'conflict-detected';
  static const String wsUserTyping = 'user-typing';
  static const String wsConnect = 'connect';
  static const String wsDisconnect = 'disconnect';
  static const String wsConnectError = 'connect_error';

  // ========================================
  // HTTP HEADERS (Moved to BaseConfig)
  // ========================================
  // Note: Default headers moved to BaseConfig implementations
  // This ensures headers are properly configured per environment

  // ========================================
  // RATE LIMITING
  // ========================================

  static const int maxRequestsPerMinute = 300;
  static const Duration rateLimitWindow = Duration(minutes: 1);
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // ========================================
  // REQUEST PRIORITIES
  // ========================================

  /// Request priority levels for different endpoints
  static const Map<String, String> endpointPriority = {
    // Critical endpoints requiring immediate response
    'auth': 'critical',
    'dashboard': 'high',
    'schedule': 'high',

    // Important but less time-sensitive
    'family': 'medium',
    'groups': 'medium',
    'children': 'medium',
    'vehicles': 'medium',

    // Background/monitoring
    'invitations': 'low',
    'health': 'low',
  };
}
