// EduLift Mobile - Group Family Domain Entity
// Represents families within a group with role and permissions

import 'package:equatable/equatable.dart';
import 'package:edulift/core/network/group_api_client.dart';

/// Group family role enumeration
enum GroupFamilyRole {
  /// Family owns the group (creator)
  owner,

  /// Family has administrative permissions
  admin,

  /// Regular family member of the group
  member,

  /// Family has pending invitation to join
  pending;

  /// Get human-readable role name
  String get displayName {
    switch (this) {
      case GroupFamilyRole.owner:
        return 'Owner';
      case GroupFamilyRole.admin:
        return 'Administrator';
      case GroupFamilyRole.member:
        return 'Member';
      case GroupFamilyRole.pending:
        return 'Pending';
    }
  }

  /// Parse role from string (case-insensitive)
  static GroupFamilyRole fromString(String role) {
    switch (role.toUpperCase()) {
      case 'OWNER':
        return GroupFamilyRole.owner;
      case 'ADMIN':
        return GroupFamilyRole.admin;
      case 'MEMBER':
        return GroupFamilyRole.member;
      case 'PENDING':
        return GroupFamilyRole.pending;
      default:
        throw ArgumentError('Invalid GroupFamilyRole: $role');
    }
  }
}

/// Family admin user data
class FamilyAdmin extends Equatable {
  /// Admin user name
  final String name;

  /// Admin user email
  final String email;

  const FamilyAdmin({
    required this.name,
    required this.email,
  });

  /// Create FamilyAdmin from DTO
  factory FamilyAdmin.fromDto(FamilyAdminData dto) {
    return FamilyAdmin(
      name: dto.name,
      email: dto.email,
    );
  }

  @override
  List<Object?> get props => [name, email];

  @override
  String toString() => 'FamilyAdmin(name: $name, email: $email)';
}

/// Group family domain entity
///
/// Represents a family within a group with role, permissions, and admin information.
/// For PENDING families, includes invitation metadata.
class GroupFamily extends Equatable {
  /// Family unique identifier
  final String id;

  /// Family name
  final String name;

  /// Family role in the group
  final GroupFamilyRole role;

  /// Is this the current user's family?
  final bool isMyFamily;

  /// Can the current user manage this family? (promote/demote/remove)
  final bool canManage;

  /// List of admin users in this family
  final List<FamilyAdmin> admins;

  /// Invitation status (only for pending invitations): PENDING, ACCEPTED, REJECTED, EXPIRED
  final String? status;

  /// Invitation code (only for pending invitations)
  final String? inviteCode;

  /// Invitation ID (only for pending invitations)
  final String? invitationId;

  /// Invitation creation date (only for pending invitations)
  final DateTime? invitedAt;

  /// Invitation expiration date (only for pending invitations)
  final DateTime? expiresAt;

  const GroupFamily({
    required this.id,
    required this.name,
    required this.role,
    required this.isMyFamily,
    required this.canManage,
    required this.admins,
    this.status,
    this.inviteCode,
    this.invitationId,
    this.invitedAt,
    this.expiresAt,
  });

  /// Create GroupFamily from DTO
  factory GroupFamily.fromDto(GroupFamilyData dto) {
    return GroupFamily(
      id: dto.id,
      name: dto.name,
      role: GroupFamilyRole.fromString(dto.role),
      isMyFamily: dto.isMyFamily,
      canManage: dto.canManage,
      admins: dto.admins.map((admin) => FamilyAdmin.fromDto(admin)).toList(),
      status: dto.status,
      inviteCode: dto.inviteCode,
      invitationId: dto.invitationId,
      invitedAt: dto.invitedAt != null ? DateTime.parse(dto.invitedAt!) : null,
      expiresAt: dto.expiresAt != null ? DateTime.parse(dto.expiresAt!) : null,
    );
  }

  /// Create a copy with updated fields
  GroupFamily copyWith({
    String? id,
    String? name,
    GroupFamilyRole? role,
    bool? isMyFamily,
    bool? canManage,
    List<FamilyAdmin>? admins,
    String? status,
    String? inviteCode,
    String? invitationId,
    DateTime? invitedAt,
    DateTime? expiresAt,
  }) {
    return GroupFamily(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      isMyFamily: isMyFamily ?? this.isMyFamily,
      canManage: canManage ?? this.canManage,
      admins: admins ?? this.admins,
      status: status ?? this.status,
      inviteCode: inviteCode ?? this.inviteCode,
      invitationId: invitationId ?? this.invitationId,
      invitedAt: invitedAt ?? this.invitedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  /// Check if family is in PENDING state
  bool get isPending => status == 'PENDING';

  /// Check if invitation is expired (only valid for PENDING families)
  bool get isExpired {
    if (!isPending || expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if family can be promoted to ADMIN
  bool get canPromote => role == GroupFamilyRole.member && canManage;

  /// Check if family can be demoted to MEMBER
  bool get canDemote => role == GroupFamilyRole.admin && canManage;

  /// Check if family can be removed from the group
  bool get canRemove => role != GroupFamilyRole.owner && canManage;

  @override
  List<Object?> get props => [
        id,
        name,
        role,
        isMyFamily,
        canManage,
        admins,
        status,
        inviteCode,
        invitationId,
        invitedAt,
        expiresAt,
      ];

  @override
  String toString() {
    return 'GroupFamily(id: $id, name: $name, role: $role, isMyFamily: $isMyFamily, canManage: $canManage, isPending: $isPending)';
  }
}
