// EduLift Mobile - Family Permissions Entity
// Represents family access permissions and user roles

/// Represents a user's permissions within a family
/// Used to control access to family management features
class FamilyPermissions {
  /// Whether the user can manage family settings and metadata
  final bool canManageFamily;

  /// Whether the user can invite new members to the family
  final bool canInviteMembers;

  /// Whether the user can manage children profiles and data
  final bool canManageChildren;

  /// Whether the user can manage family vehicles
  final bool canManageVehicles;

  /// The user's role within the family (parent, guardian, child, etc.)
  final String role;

  /// Creates a new family permissions instance
  const FamilyPermissions({
    required this.canManageFamily,
    required this.canInviteMembers,
    required this.canManageChildren,
    required this.canManageVehicles,
    required this.role,
  });

  /// Creates a copy of this permissions object with updated values
  FamilyPermissions copyWith({
    bool? canManageFamily,
    bool? canInviteMembers,
    bool? canManageChildren,
    bool? canManageVehicles,
    String? role,
  }) {
    return FamilyPermissions(
      canManageFamily: canManageFamily ?? this.canManageFamily,
      canInviteMembers: canInviteMembers ?? this.canInviteMembers,
      canManageChildren: canManageChildren ?? this.canManageChildren,
      canManageVehicles: canManageVehicles ?? this.canManageVehicles,
      role: role ?? this.role,
    );
  }

  /// Checks if this user has admin-level permissions
  bool get isAdmin => canManageFamily && canInviteMembers;

  /// Checks if this user can perform any management actions
  bool get canPerformManagement =>
      canManageFamily ||
      canInviteMembers ||
      canManageChildren ||
      canManageVehicles;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FamilyPermissions &&
        other.canManageFamily == canManageFamily &&
        other.canInviteMembers == canInviteMembers &&
        other.canManageChildren == canManageChildren &&
        other.canManageVehicles == canManageVehicles &&
        other.role == role;
  }

  @override
  int get hashCode {
    return canManageFamily.hashCode ^
        canInviteMembers.hashCode ^
        canManageChildren.hashCode ^
        canManageVehicles.hashCode ^
        role.hashCode;
  }

  @override
  String toString() {
    return 'FamilyPermissions('
        'canManageFamily: $canManageFamily, '
        'canInviteMembers: $canInviteMembers, '
        'canManageChildren: $canManageChildren, '
        'canManageVehicles: $canManageVehicles, '
        'role: $role'
        ')';
  }
}
