// EduLift Mobile - Member Status Enum
// Defines status levels for family members

/// Enum representing family member status
enum MemberStatus {
  active('active', 'Active', 'Member is active and can access all features'),
  pending('pending', 'Pending', 'Member invitation is pending acceptance'),
  inactive('inactive', 'Inactive', 'Member is temporarily inactive'),
  suspended('suspended', 'Suspended', 'Member access has been suspended'),
  removed('removed', 'Removed', 'Member has been removed from the family');

  const MemberStatus(this.value, this.label, this.description);

  final String value;
  final String label;
  final String description;

  /// Get status from string value
  static MemberStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return MemberStatus.active;
      case 'pending':
        return MemberStatus.pending;
      case 'inactive':
        return MemberStatus.inactive;
      case 'suspended':
        return MemberStatus.suspended;
      case 'removed':
        return MemberStatus.removed;
      default:
        return MemberStatus.inactive;
    }
  }

  /// Check if member can access family features
  bool get canAccess => this == MemberStatus.active;

  /// Check if member can be assigned to tasks
  bool get canBeAssigned => this == MemberStatus.active;

  /// Check if member needs action (pending status)
  bool get needsAction => this == MemberStatus.pending;

  /// Check if member is effectively unavailable
  bool get isUnavailable =>
      this == MemberStatus.suspended ||
      this == MemberStatus.removed ||
      this == MemberStatus.inactive;

  @override
  String toString() => label;
}
