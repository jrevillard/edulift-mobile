import 'package:equatable/equatable.dart';

/// Represents the type of invitation in the system
enum InvitationType {
  family('family'),
  group('group'),
  universal('universal'),
  code('code');

  const InvitationType(this.value);
  final String value;

  /// Create InvitationType from string value
  static InvitationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'family':
        return InvitationType.family;
      case 'group':
        return InvitationType.group;
      case 'universal':
        return InvitationType.universal;
      case 'code':
        return InvitationType.code;
      default:
        return InvitationType.family;
    }
  }
}

/// Represents the status of an invitation
enum InvitationStatus {
  pending('pending'),
  accepted('accepted'),
  declined('declined'),
  expired('expired'),
  cancelled('cancelled'),
  revoked('revoked'),
  failed('failed'),
  invalid('invalid');

  const InvitationStatus(this.value);
  final String value;

  /// Create InvitationStatus from string value
  static InvitationStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return InvitationStatus.pending;
      case 'accepted':
        return InvitationStatus.accepted;
      case 'declined':
        return InvitationStatus.declined;
      case 'expired':
        return InvitationStatus.expired;
      case 'cancelled':
        return InvitationStatus.cancelled;
      case 'revoked':
        return InvitationStatus.revoked;
      case 'failed':
        return InvitationStatus.failed;
      case 'invalid':
        return InvitationStatus.invalid;
      default:
        return InvitationStatus.pending;
    }
  }

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case InvitationStatus.pending:
        return 'Pending';
      case InvitationStatus.accepted:
        return 'Accepted';
      case InvitationStatus.declined:
        return 'Declined';
      case InvitationStatus.expired:
        return 'Expired';
      case InvitationStatus.cancelled:
        return 'Cancelled';
      case InvitationStatus.revoked:
        return 'Revoked';
      case InvitationStatus.failed:
        return 'Failed';
      case InvitationStatus.invalid:
        return 'Invalid';
    }
  }

  /// Check if invitation can be acted upon
  bool get isActionable => this == InvitationStatus.pending;

  /// Check if invitation is still valid
  bool get isValid => this == InvitationStatus.pending;
}

/// Represents the direction of an invitation (sent or received)
enum InvitationDirection {
  sent('sent'),
  received('received');

  const InvitationDirection(this.value);
  final String value;

  /// Create InvitationDirection from string value
  static InvitationDirection fromString(String value) {
    switch (value.toLowerCase()) {
      case 'sent':
        return InvitationDirection.sent;
      case 'received':
        return InvitationDirection.received;
      default:
        return InvitationDirection.received;
    }
  }
}

/// Domain entity representing an invitation to join a family or group
class Invitation extends Equatable {
  final String id;
  final InvitationType type;
  final InvitationStatus status;
  final InvitationDirection direction;
  final String inviterId;
  final String inviterName;
  final String inviterEmail;
  final String recipientEmail;
  final String? recipientId;
  final String? role;
  final String? familyId;
  final String? familyName;
  final String? groupId;
  final String? groupName;
  final String? message;
  final String? inviteCode;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? acceptedAt;
  final DateTime? declinedAt;
  final DateTime? respondedAt; // Unified field for response timestamp
  final Map<String, dynamic>? metadata;

  const Invitation({
    required this.id,
    required this.type,
    required this.status,
    required this.direction,
    required this.inviterId,
    required this.inviterName,
    required this.inviterEmail,
    required this.recipientEmail,
    this.recipientId,
    this.role,
    this.familyId,
    this.familyName,
    this.groupId,
    this.groupName,
    this.message,
    this.inviteCode,
    required this.createdAt,
    required this.expiresAt,
    this.acceptedAt,
    this.declinedAt,
    this.respondedAt,
    this.metadata,
  });

  /// Check if invitation is still valid
  bool get isValid =>
      status == InvitationStatus.pending && expiresAt.isAfter(DateTime.now());

  /// Check if invitation has expired
  bool get isExpired => expiresAt.isBefore(DateTime.now());

  /// Get email for display purposes (recipientEmail is the primary email)
  String get email => recipientEmail;

  /// Get days until expiration
  int get daysUntilExpiration => expiresAt.difference(DateTime.now()).inDays;

  /// Create a copy with updated fields
  Invitation copyWith({
    String? id,
    InvitationType? type,
    InvitationStatus? status,
    InvitationDirection? direction,
    String? inviterId,
    String? inviterName,
    String? inviterEmail,
    String? recipientEmail,
    String? recipientId,
    String? role,
    String? familyId,
    String? familyName,
    String? groupId,
    String? groupName,
    String? message,
    String? inviteCode,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? acceptedAt,
    DateTime? declinedAt,
    DateTime? respondedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Invitation(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      direction: direction ?? this.direction,
      inviterId: inviterId ?? this.inviterId,
      inviterName: inviterName ?? this.inviterName,
      inviterEmail: inviterEmail ?? this.inviterEmail,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      recipientId: recipientId ?? this.recipientId,
      role: role ?? this.role,
      familyId: familyId ?? this.familyId,
      familyName: familyName ?? this.familyName,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      message: message ?? this.message,
      inviteCode: inviteCode ?? this.inviteCode,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      declinedAt: declinedAt ?? this.declinedAt,
      respondedAt: respondedAt ?? this.respondedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    status,
    direction,
    inviterId,
    inviterName,
    inviterEmail,
    recipientEmail,
    recipientId,
    role,
    familyId,
    familyName,
    groupId,
    groupName,
    message,
    inviteCode,
    createdAt,
    expiresAt,
    acceptedAt,
    declinedAt,
    respondedAt,
    metadata,
  ];
}

/// Represents an invitation code for quick access
class InvitationCode extends Equatable {
  final String code;
  final InvitationType type;
  final String targetId; // familyId or groupId
  final String targetName;
  final String createdById;
  final String createdByName;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int? usageLimit;
  final int usageCount;
  final bool isActive;

  const InvitationCode({
    required this.code,
    required this.type,
    required this.targetId,
    required this.targetName,
    required this.createdById,
    required this.createdByName,
    required this.createdAt,
    required this.expiresAt,
    this.usageLimit,
    this.usageCount = 0,
    this.isActive = true,
  });

  /// Check if code is still valid for use
  bool get isValid =>
      isActive &&
      expiresAt.isAfter(DateTime.now()) &&
      (usageLimit == null || usageCount < usageLimit!);

  /// Get remaining uses
  int? get remainingUses =>
      usageLimit != null ? usageLimit! - usageCount : null;

  @override
  List<Object?> get props => [
    code,
    type,
    targetId,
    targetName,
    createdById,
    createdByName,
    createdAt,
    expiresAt,
    usageLimit,
    usageCount,
    isActive,
  ];
}

/// Statistics about invitations
class InvitationStats extends Equatable {
  final int totalSent;
  final int totalReceived;
  final int pendingSent;
  final int pendingReceived;
  final int acceptedSent;
  final int acceptedReceived;
  final int declinedSent;
  final int declinedReceived;
  final int expiredSent;
  final int expiredReceived;
  final DateTime? lastInvitationSent;
  final DateTime? lastInvitationReceived;

  const InvitationStats({
    required this.totalSent,
    required this.totalReceived,
    required this.pendingSent,
    required this.pendingReceived,
    required this.acceptedSent,
    required this.acceptedReceived,
    required this.declinedSent,
    required this.declinedReceived,
    required this.expiredSent,
    required this.expiredReceived,
    this.lastInvitationSent,
    this.lastInvitationReceived,
  });

  /// Total invitations across all statuses
  int get totalInvitations => totalSent + totalReceived;

  /// Total pending invitations
  int get totalPending => pendingSent + pendingReceived;

  /// Total accepted invitations
  int get totalAccepted => acceptedSent + acceptedReceived;

  /// Acceptance rate as a percentage (0.0 to 1.0)
  double get acceptanceRate => totalSent > 0 ? acceptedSent / totalSent : 0.0;

  @override
  List<Object?> get props => [
    totalSent,
    totalReceived,
    pendingSent,
    pendingReceived,
    acceptedSent,
    acceptedReceived,
    declinedSent,
    declinedReceived,
    expiredSent,
    expiredReceived,
    lastInvitationSent,
    lastInvitationReceived,
  ];
}