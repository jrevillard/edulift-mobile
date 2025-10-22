// EduLift Mobile - Group Domain Entity
// Group coordination and scheduling management

import 'package:equatable/equatable.dart';

/// Group domain entity for organizing children and transportation
class Group extends Equatable {
  /// Unique identifier for the group
  final String id;

  /// Group name
  final String name;

  /// Family ID this group belongs to
  final String familyId;

  /// Group description
  final String? description;

  /// Group creation timestamp
  final DateTime createdAt;

  /// Last updated timestamp
  final DateTime updatedAt;

  /// Group settings and configuration
  final GroupSettings settings;

  /// Current group status
  final GroupStatus status;

  /// Group member count
  final int memberCount;

  /// Maximum members allowed
  final int? maxMembers;

  /// Group schedule configuration
  final GroupScheduleConfig scheduleConfig;

  /// User's role in this group (from API response)
  final GroupMemberRole? userRole;

  /// Number of families in this group (from API response)
  final int familyCount;

  /// Number of schedules for this group (from API response)
  final int scheduleCount;

  const Group({
    required this.id,
    required this.name,
    required this.familyId,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.settings = const GroupSettings(),
    this.status = GroupStatus.active,
    this.memberCount = 0,
    this.maxMembers,
    this.scheduleConfig = const GroupScheduleConfig(),
    this.userRole,
    this.familyCount = 0,
    this.scheduleCount = 0,
  });

  /// Create a copy of Group with updated fields
  Group copyWith({
    String? id,
    String? name,
    String? familyId,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    GroupSettings? settings,
    GroupStatus? status,
    int? memberCount,
    int? maxMembers,
    GroupScheduleConfig? scheduleConfig,
    GroupMemberRole? userRole,
    int? familyCount,
    int? scheduleCount,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      familyId: familyId ?? this.familyId,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      settings: settings ?? this.settings,
      status: status ?? this.status,
      memberCount: memberCount ?? this.memberCount,
      maxMembers: maxMembers ?? this.maxMembers,
      scheduleConfig: scheduleConfig ?? this.scheduleConfig,
      userRole: userRole ?? this.userRole,
      familyCount: familyCount ?? this.familyCount,
      scheduleCount: scheduleCount ?? this.scheduleCount,
    );
  }

  /// Get group initials for display
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'G';
    if (parts.length == 1) {
      final firstPart = parts[0];
      if (firstPart.isEmpty) return 'G';
      return firstPart.substring(0, 1).toUpperCase();
    }
    final firstPart = parts[0];
    final secondPart = parts[1];
    if (firstPart.isEmpty || secondPart.isEmpty) return 'G';
    return '${firstPart.substring(0, 1)}${secondPart.substring(0, 1)}'
        .toUpperCase();
  }

  /// Check if group is active
  bool get isActive => status == GroupStatus.active;

  /// Check if group is at capacity
  bool get isAtCapacity => maxMembers != null && memberCount >= maxMembers!;

  /// Check if group can accept new members
  bool get canAcceptNewMembers => isActive && !isAtCapacity;

  /// Get available spots in group
  int get availableSpots {
    if (maxMembers == null) return 999; // No limit
    return (maxMembers! - memberCount).clamp(0, maxMembers!);
  }

  /// Get group utilization percentage
  double get utilizationPercentage {
    if (maxMembers == null || maxMembers == 0) return 0.0;
    return (memberCount / maxMembers!) * 100;
  }

  /// Get days since group was created
  int get daysSinceCreated => DateTime.now().difference(createdAt).inDays;

  @override
  List<Object?> get props => [
    id,
    name,
    familyId,
    description,
    createdAt,
    updatedAt,
    settings,
    status,
    memberCount,
    maxMembers,
    scheduleConfig,
    userRole,
    familyCount,
    scheduleCount,
  ];

  @override
  String toString() {
    return 'Group(id: $id, name: $name, members: $memberCount, status: $status)';
  }
}

/// Group settings and configuration
class GroupSettings extends Equatable {
  /// Whether group allows automatic assignments
  final bool allowAutoAssignment;

  /// Whether group requires parental approval for assignments
  final bool requireParentalApproval;

  /// Default pickup location
  final String? defaultPickupLocation;

  /// Default dropoff location
  final String? defaultDropoffLocation;

  /// Group color for UI display
  final String groupColor;

  /// Whether to send notifications for this group
  final bool enableNotifications;

  /// Group privacy level
  final GroupPrivacyLevel privacyLevel;

  const GroupSettings({
    this.allowAutoAssignment = true,
    this.requireParentalApproval = false,
    this.defaultPickupLocation,
    this.defaultDropoffLocation,
    this.groupColor = '#2196F3',
    this.enableNotifications = true,
    this.privacyLevel = GroupPrivacyLevel.family,
  });

  GroupSettings copyWith({
    bool? allowAutoAssignment,
    bool? requireParentalApproval,
    String? defaultPickupLocation,
    String? defaultDropoffLocation,
    String? groupColor,
    bool? enableNotifications,
    GroupPrivacyLevel? privacyLevel,
  }) {
    return GroupSettings(
      allowAutoAssignment: allowAutoAssignment ?? this.allowAutoAssignment,
      requireParentalApproval:
          requireParentalApproval ?? this.requireParentalApproval,
      defaultPickupLocation:
          defaultPickupLocation ?? this.defaultPickupLocation,
      defaultDropoffLocation:
          defaultDropoffLocation ?? this.defaultDropoffLocation,
      groupColor: groupColor ?? this.groupColor,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      privacyLevel: privacyLevel ?? this.privacyLevel,
    );
  }

  @override
  List<Object?> get props => [
    allowAutoAssignment,
    requireParentalApproval,
    defaultPickupLocation,
    defaultDropoffLocation,
    groupColor,
    enableNotifications,
    privacyLevel,
  ];
}

/// Group schedule configuration
class GroupScheduleConfig extends Equatable {
  /// Days of week this group is active
  final List<int> activeDays;

  /// Default start time for group activities
  final String? defaultStartTime;

  /// Default end time for group activities
  final String? defaultEndTime;

  /// Time zone for schedule
  final String timezone;

  /// Advance notice required for changes (hours)
  final int advanceNoticeHours;

  /// Whether group allows same-day scheduling
  final bool allowSameDayScheduling;

  const GroupScheduleConfig({
    this.activeDays = const [1, 2, 3, 4, 5], // Monday-Friday
    this.defaultStartTime,
    this.defaultEndTime,
    this.timezone = 'UTC',
    this.advanceNoticeHours = 24,
    this.allowSameDayScheduling = false,
  });

  GroupScheduleConfig copyWith({
    List<int>? activeDays,
    String? defaultStartTime,
    String? defaultEndTime,
    String? timezone,
    int? advanceNoticeHours,
    bool? allowSameDayScheduling,
  }) {
    return GroupScheduleConfig(
      activeDays: activeDays ?? this.activeDays,
      defaultStartTime: defaultStartTime ?? this.defaultStartTime,
      defaultEndTime: defaultEndTime ?? this.defaultEndTime,
      timezone: timezone ?? this.timezone,
      advanceNoticeHours: advanceNoticeHours ?? this.advanceNoticeHours,
      allowSameDayScheduling:
          allowSameDayScheduling ?? this.allowSameDayScheduling,
    );
  }

  /// Check if group is active on specific day of week
  bool isActiveOnDay(int dayOfWeek) => activeDays.contains(dayOfWeek);

  /// Get active days as readable string
  String get activeDaysString {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return activeDays.map((day) => dayNames[day - 1]).join(', ');
  }

  @override
  List<Object?> get props => [
    activeDays,
    defaultStartTime,
    defaultEndTime,
    timezone,
    advanceNoticeHours,
    allowSameDayScheduling,
  ];
}

/// Group status enumeration
enum GroupStatus {
  /// Group is active and accepting assignments
  active,

  /// Group is temporarily paused
  paused,

  /// Group is archived (no longer active)
  archived,

  /// Group is being configured
  draft;

  /// Create GroupStatus from string
  static GroupStatus fromJson(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return GroupStatus.active;
      case 'paused':
        return GroupStatus.paused;
      case 'archived':
        return GroupStatus.archived;
      case 'draft':
        return GroupStatus.draft;
      default:
        return GroupStatus.active;
    }
  }
}

/// Group privacy level
enum GroupPrivacyLevel {
  /// Visible to all family members
  family,

  /// Visible to coordinators and admins only
  coordinators,

  /// Visible to admins only
  admins;

  /// Create GroupPrivacyLevel from string
  static GroupPrivacyLevel fromJson(String level) {
    switch (level.toLowerCase()) {
      case 'family':
        return GroupPrivacyLevel.family;
      case 'coordinators':
        return GroupPrivacyLevel.coordinators;
      case 'admins':
        return GroupPrivacyLevel.admins;
      default:
        return GroupPrivacyLevel.family;
    }
  }
}

/// Group member domain entity
class GroupMember extends Equatable {
  /// Unique identifier for the member
  final String id;

  /// Member display name
  final String name;

  /// Member email address
  final String email;

  /// Member role in the group
  final GroupMemberRole role;

  /// When the member joined the group
  final DateTime joinedAt;

  /// Member's status in the group
  final GroupMemberStatus status;

  /// Additional permissions for this member
  final List<GroupPermission> permissions;

  const GroupMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.joinedAt,
    this.status = GroupMemberStatus.active,
    this.permissions = const [],
  });

  /// Create a copy with updated fields
  GroupMember copyWith({
    String? id,
    String? name,
    String? email,
    GroupMemberRole? role,
    DateTime? joinedAt,
    GroupMemberStatus? status,
    List<GroupPermission>? permissions,
  }) {
    return GroupMember(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      status: status ?? this.status,
      permissions: permissions ?? this.permissions,
    );
  }

  /// Check if member has specific permission
  bool hasPermission(GroupPermission permission) {
    return permissions.contains(permission) || role.hasPermission(permission);
  }

  /// Check if member is active
  bool get isActive => status == GroupMemberStatus.active;

  /// Check if member is admin
  bool get isAdmin => role == GroupMemberRole.admin;

  /// Get member initials for display
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'M';
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'
        .toUpperCase();
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    role,
    joinedAt,
    status,
    permissions,
  ];

  @override
  String toString() {
    return 'GroupMember(id: $id, name: $name, role: $role, status: $status)';
  }
}

/// Create group domain command
class CreateGroupCommand extends Equatable {
  /// Group name
  final String name;

  /// Optional group description
  final String? description;

  /// Group settings
  final GroupSettings? settings;

  /// Maximum members allowed
  final int? maxMembers;

  /// Schedule configuration
  final GroupScheduleConfig? scheduleConfig;

  const CreateGroupCommand({
    required this.name,
    this.description,
    this.settings,
    this.maxMembers,
    this.scheduleConfig,
  });

  /// Validate command data
  bool get isValid {
    return name.trim().isNotEmpty && (maxMembers == null || maxMembers! > 0);
  }

  /// Get validation errors
  List<String> get validationErrors {
    final errors = <String>[];

    if (name.trim().isEmpty) {
      errors.add('Group name is required');
    }

    if (maxMembers != null && maxMembers! <= 0) {
      errors.add('Maximum members must be greater than 0');
    }

    return errors;
  }

  @override
  List<Object?> get props => [
    name,
    description,
    settings,
    maxMembers,
    scheduleConfig,
  ];
}

/// Update group domain command
class UpdateGroupCommand extends Equatable {
  /// Group ID to update
  final String groupId;

  /// Updated group name
  final String? name;

  /// Updated group description
  final String? description;

  /// Updated group settings
  final GroupSettings? settings;

  /// Updated maximum members
  final int? maxMembers;

  /// Updated schedule configuration
  final GroupScheduleConfig? scheduleConfig;

  const UpdateGroupCommand({
    required this.groupId,
    this.name,
    this.description,
    this.settings,
    this.maxMembers,
    this.scheduleConfig,
  });

  /// Check if command has any updates
  bool get hasUpdates {
    return name != null ||
        description != null ||
        settings != null ||
        maxMembers != null ||
        scheduleConfig != null;
  }

  /// Validate command data
  bool get isValid {
    return (name?.trim().isNotEmpty ?? true) &&
        (maxMembers == null || maxMembers! > 0);
  }

  /// Get validation errors
  List<String> get validationErrors {
    final errors = <String>[];

    if (name != null && name!.trim().isEmpty) {
      errors.add('Group name cannot be empty');
    }

    if (maxMembers != null && maxMembers! <= 0) {
      errors.add('Maximum members must be greater than 0');
    }

    return errors;
  }

  @override
  List<Object?> get props => [
    groupId,
    name,
    description,
    settings,
    maxMembers,
    scheduleConfig,
  ];
}

/// Group member role enumeration
enum GroupMemberRole {
  /// Group owner with full permissions
  owner,

  /// Group administrator with management permissions
  admin,

  /// Regular group member
  member;

  /// Create GroupMemberRole from string
  static GroupMemberRole? fromJson(String? role) {
    if (role == null) return null;

    switch (role.toUpperCase()) {
      case 'OWNER':
        return GroupMemberRole.owner;
      case 'ADMIN':
        return GroupMemberRole.admin;
      case 'MEMBER':
        return GroupMemberRole.member;
      default:
        return null; // Unknown role - return null for safety
    }
  }

  /// Check if role has specific permission
  bool hasPermission(GroupPermission permission) {
    switch (this) {
      case GroupMemberRole.owner:
        return true; // Owners have all permissions
      case GroupMemberRole.admin:
        return permission != GroupPermission.deleteGroup &&
            permission != GroupPermission.transferOwnership;
      case GroupMemberRole.member:
        return permission == GroupPermission.viewGroup ||
            permission == GroupPermission.viewMembers ||
            permission == GroupPermission.leaveGroup;
    }
  }

  /// Get human-readable role name
  String get displayName {
    switch (this) {
      case GroupMemberRole.owner:
        return 'Owner';
      case GroupMemberRole.admin:
        return 'Administrator';
      case GroupMemberRole.member:
        return 'Member';
    }
  }
}

/// Group member status enumeration
enum GroupMemberStatus {
  /// Member is active in the group
  active,

  /// Member is temporarily suspended
  suspended,

  /// Member has left the group
  left,

  /// Member was removed from group
  removed;

  /// Get human-readable status name
  String get displayName {
    switch (this) {
      case GroupMemberStatus.active:
        return 'Active';
      case GroupMemberStatus.suspended:
        return 'Suspended';
      case GroupMemberStatus.left:
        return 'Left';
      case GroupMemberStatus.removed:
        return 'Removed';
    }
  }
}

/// Group invitation validation result
/// Used to validate and process invitation codes before joining groups
class GroupInvitationValidation extends Equatable {
  /// Whether the invitation is valid and can be used
  final bool valid;

  /// The group ID associated with the invitation
  final String? groupId;

  /// The name of the group being invited to
  final String? groupName;

  /// Personal message from the inviter
  final String? personalMessage;

  /// Description of the group
  final String? description;

  /// Email associated with the invitation
  final String? email;

  /// Email of the person who sent the invitation
  final String? inviterEmail;

  /// Whether the user already exists in the system
  final bool? existingUser;

  /// Name of the family that owns the group
  final String? ownerFamily;

  /// Error message if validation failed
  final String? error;

  /// Error code for programmatic error handling
  final String? errorCode;

  /// Name of the person who sent the invitation
  final String? invitedByName;

  /// When this invitation expires
  final DateTime? expiresAt;

  /// Creates a new group invitation validation result
  const GroupInvitationValidation({
    required this.valid,
    this.groupId,
    this.groupName,
    this.personalMessage,
    this.description,
    this.email,
    this.inviterEmail,
    this.expiresAt,
    this.existingUser,
    this.ownerFamily,
    this.error,
    this.errorCode,
    this.invitedByName,
  });

  /// Creates a successful validation result
  factory GroupInvitationValidation.success({
    required String groupId,
    required String groupName,
    String? personalMessage,
    String? description,
    String? email,
    String? inviterEmail,
    DateTime? expiresAt,
    bool? existingUser,
    String? ownerFamily,
    String? invitedByName,
  }) {
    return GroupInvitationValidation(
      valid: true,
      groupId: groupId,
      groupName: groupName,
      personalMessage: personalMessage,
      description: description,
      email: email,
      inviterEmail: inviterEmail,
      expiresAt: expiresAt,
      existingUser: existingUser,
      ownerFamily: ownerFamily,
      invitedByName: invitedByName,
    );
  }

  /// Creates a failed validation result
  factory GroupInvitationValidation.failure({
    required String error,
    String? errorCode,
  }) {
    return GroupInvitationValidation(
      valid: false,
      error: error,
      errorCode: errorCode,
    );
  }

  /// Creates a copy with updated values
  GroupInvitationValidation copyWith({
    bool? valid,
    String? groupId,
    String? groupName,
    String? personalMessage,
    String? description,
    String? email,
    String? inviterEmail,
    DateTime? expiresAt,
    bool? existingUser,
    String? ownerFamily,
    String? error,
    String? errorCode,
    String? invitedByName,
  }) {
    return GroupInvitationValidation(
      valid: valid ?? this.valid,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      personalMessage: personalMessage ?? this.personalMessage,
      description: description ?? this.description,
      email: email ?? this.email,
      inviterEmail: inviterEmail ?? this.inviterEmail,
      expiresAt: expiresAt ?? this.expiresAt,
      existingUser: existingUser ?? this.existingUser,
      ownerFamily: ownerFamily ?? this.ownerFamily,
      error: error ?? this.error,
      errorCode: errorCode ?? this.errorCode,
      invitedByName: invitedByName ?? this.invitedByName,
    );
  }

  @override
  List<Object?> get props => [
    valid,
    groupId,
    groupName,
    personalMessage,
    description,
    email,
    inviterEmail,
    expiresAt,
    existingUser,
    ownerFamily,
    error,
    errorCode,
    invitedByName,
  ];

  @override
  String toString() {
    return 'GroupInvitationValidation('
        'valid: $valid, '
        'groupId: $groupId, '
        'groupName: $groupName, '
        'error: $error'
        ')';
  }
}

/// Group permission enumeration
enum GroupPermission {
  /// View group details
  viewGroup,

  /// View group members
  viewMembers,

  /// Edit group settings
  editGroup,

  /// Manage group members
  manageMembers,

  /// Remove members from group
  removeMember,

  /// Generate invitation codes
  generateInvitation,

  /// Delete the group
  deleteGroup,

  /// Transfer group ownership
  transferOwnership,

  /// Leave the group
  leaveGroup,

  /// Manage group schedules
  manageSchedules;

  /// Get human-readable permission name
  String get displayName {
    switch (this) {
      case GroupPermission.viewGroup:
        return 'View Group';
      case GroupPermission.viewMembers:
        return 'View Members';
      case GroupPermission.editGroup:
        return 'Edit Group';
      case GroupPermission.manageMembers:
        return 'Manage Members';
      case GroupPermission.removeMember:
        return 'Remove Members';
      case GroupPermission.generateInvitation:
        return 'Generate Invitations';
      case GroupPermission.deleteGroup:
        return 'Delete Group';
      case GroupPermission.transferOwnership:
        return 'Transfer Ownership';
      case GroupPermission.leaveGroup:
        return 'Leave Group';
      case GroupPermission.manageSchedules:
        return 'Manage Schedules';
    }
  }
}