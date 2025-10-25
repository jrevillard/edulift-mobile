// EduLift Mobile - Group Invitation Entity
// Domain entity for group invitations with enhanced functionality

import 'package:equatable/equatable.dart';
import '../../../../core/domain/entities/invitations/invitation.dart';
// Import for shared InvitationStatus

/// Group invitation entity representing an invitation for a family to join a group
class GroupInvitation extends Equatable {
  /// Unique identifier for the invitation
  final String id;

  /// ID of the group extending the invitation
  final String groupId;

  /// Name of the group extending the invitation
  final String groupName;

  /// ID of the target family being invited
  final String targetFamilyId;

  /// Name of the target family being invited
  final String? targetFamilyName;

  /// Role being offered in the group (admin, member, etc.)
  final String role;

  /// ID of the user who created the invitation
  final String invitedBy;

  /// Name of the user who created the invitation
  final String invitedByName;

  /// When the invitation was created
  final DateTime createdAt;

  /// When the invitation expires
  final DateTime expiresAt;

  /// Current status of the invitation
  final InvitationStatus status;

  /// Optional personal message from the inviter
  final String? personalMessage;

  /// Invitation code for sharing
  final String? inviteCode;

  /// When the invitation was accepted (if applicable)
  final DateTime? acceptedAt;

  /// ID of the user who accepted (if applicable)
  final String? acceptedBy;

  /// When the invitation was last updated
  final DateTime? updatedAt;

  /// Group description for context
  final String? groupDescription;

  /// Owner family information
  final String? ownerFamilyName;

  /// Additional metadata
  final Map<String, dynamic>? metadata;

  const GroupInvitation({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.targetFamilyId,
    this.targetFamilyName,
    required this.role,
    required this.invitedBy,
    required this.invitedByName,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
    this.personalMessage,
    this.inviteCode,
    this.acceptedAt,
    this.acceptedBy,
    this.updatedAt,
    this.groupDescription,
    this.ownerFamilyName,
    this.metadata,
  });

  /// Check if invitation has expired
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt) ||
        status == InvitationStatus.expired;
  }

  /// Check if invitation is still pending and valid
  bool get isPendingAndValid {
    return status.isValid && !isExpired;
  }

  /// Get time remaining until expiration
  Duration? get timeUntilExpiration {
    if (isExpired) return null;
    return expiresAt.difference(DateTime.now());
  }

  /// Get formatted expiration time for display
  String get expirationDisplayText {
    if (isExpired) return 'Expired';

    final timeRemaining = timeUntilExpiration;
    if (timeRemaining == null) return 'Expired';

    final days = timeRemaining.inDays;
    final hours = timeRemaining.inHours % 24;

    if (days > 0) {
      return '$days day${days == 1 ? '' : 's'} remaining';
    } else if (hours > 0) {
      return '$hours hour${hours == 1 ? '' : 's'} remaining';
    } else {
      final minutes = timeRemaining.inMinutes;
      return '$minutes minute${minutes == 1 ? '' : 's'} remaining';
    }
  }

  /// Get display text for the invitation type
  String get invitationTypeDisplay {
    return 'Group Invitation';
  }

  /// Get formatted role display
  String get roleDisplay {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'member':
        return 'Member';
      default:
        return role;
    }
  }

  /// Check if invitation grants admin privileges
  bool get isAdminRole {
    return role.toLowerCase() == 'admin';
  }

  /// Create a copy with updated fields
  GroupInvitation copyWith({
    String? id,
    String? groupId,
    String? groupName,
    String? targetFamilyId,
    String? targetFamilyName,
    String? role,
    String? invitedBy,
    String? invitedByName,
    DateTime? createdAt,
    DateTime? expiresAt,
    InvitationStatus? status,
    String? personalMessage,
    String? inviteCode,
    DateTime? acceptedAt,
    String? acceptedBy,
    DateTime? updatedAt,
    String? groupDescription,
    String? ownerFamilyName,
    Map<String, dynamic>? metadata,
  }) {
    return GroupInvitation(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      targetFamilyId: targetFamilyId ?? this.targetFamilyId,
      targetFamilyName: targetFamilyName ?? this.targetFamilyName,
      role: role ?? this.role,
      invitedBy: invitedBy ?? this.invitedBy,
      invitedByName: invitedByName ?? this.invitedByName,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      personalMessage: personalMessage ?? this.personalMessage,
      inviteCode: inviteCode ?? this.inviteCode,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      acceptedBy: acceptedBy ?? this.acceptedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      groupDescription: groupDescription ?? this.groupDescription,
      ownerFamilyName: ownerFamilyName ?? this.ownerFamilyName,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        groupId,
        groupName,
        targetFamilyId,
        targetFamilyName,
        role,
        invitedBy,
        invitedByName,
        createdAt,
        expiresAt,
        status,
        personalMessage,
        inviteCode,
        acceptedAt,
        acceptedBy,
        updatedAt,
        groupDescription,
        ownerFamilyName,
        metadata,
      ];

  @override
  String toString() {
    return 'GroupInvitation(id: $id, groupName: $groupName, targetFamily: $targetFamilyName, status: ${status.displayName})';
  }
}
