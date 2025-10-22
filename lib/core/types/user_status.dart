// User Status Types and Enums
// Defines user status values and related types

import 'package:flutter/foundation.dart';

/// User status enumeration
enum UserStatus { active, inactive, pending, suspended, deleted }

/// Extension methods for UserStatus
extension UserStatusExtension on UserStatus {
  /// Get the string value of the status
  String get value {
    switch (this) {
      case UserStatus.active:
        return 'active';
      case UserStatus.inactive:
        return 'inactive';
      case UserStatus.pending:
        return 'pending';
      case UserStatus.suspended:
        return 'suspended';
      case UserStatus.deleted:
        return 'deleted';
    }
  }

  /// Get user-friendly display name
  String get displayName {
    switch (this) {
      case UserStatus.active:
        return 'Active';
      case UserStatus.inactive:
        return 'Inactive';
      case UserStatus.pending:
        return 'Pending';
      case UserStatus.suspended:
        return 'Suspended';
      case UserStatus.deleted:
        return 'Deleted';
    }
  }

  /// Check if user is active
  bool get isActive => this == UserStatus.active;

  /// Check if user can login
  bool get canLogin => this == UserStatus.active || this == UserStatus.inactive;
}

/// Parse UserStatus from string
UserStatus parseUserStatus(String value) {
  switch (value.toLowerCase()) {
    case 'active':
      return UserStatus.active;
    case 'inactive':
      return UserStatus.inactive;
    case 'pending':
      return UserStatus.pending;
    case 'suspended':
      return UserStatus.suspended;
    case 'deleted':
      return UserStatus.deleted;
    default:
      return UserStatus.inactive;
  }
}

/// User status data class
@immutable
class UserStatusData {
  final UserStatus status;
  final DateTime lastUpdated;
  final String? reason;
  final Map<String, dynamic>? metadata;

  const UserStatusData({
    required this.status,
    required this.lastUpdated,
    this.reason,
    this.metadata,
  });

  /// Create from JSON
  factory UserStatusData.fromJson(Map<String, dynamic> json) {
    return UserStatusData(
      status: parseUserStatus(json['status'] ?? 'inactive'),
      lastUpdated: DateTime.parse(
        json['lastUpdated'] ?? DateTime.now().toIso8601String(),
      ),
      reason: json['reason'],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status.value,
      'lastUpdated': lastUpdated.toIso8601String(),
      if (reason != null) 'reason': reason,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Copy with new values
  UserStatusData copyWith({
    UserStatus? status,
    DateTime? lastUpdated,
    String? reason,
    Map<String, dynamic>? metadata,
  }) {
    return UserStatusData(
      status: status ?? this.status,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      reason: reason ?? this.reason,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserStatusData &&
        other.status == status &&
        other.lastUpdated == lastUpdated &&
        other.reason == reason;
  }

  @override
  int get hashCode {
    return Object.hash(status, lastUpdated, reason);
  }

  @override
  String toString() {
    return 'UserStatusData(status: $status, lastUpdated: $lastUpdated, reason: $reason)';
  }
}
