import 'package:equatable/equatable.dart';

/// Family role enumeration matching backend
enum FamilyRole {
  admin('ADMIN'),
  member('MEMBER');

  const FamilyRole(this.value);
  final String value;

  static FamilyRole fromString(String value) {
    switch (value.toUpperCase()) {
      case 'ADMIN':
        return FamilyRole.admin;
      case 'MEMBER':
        return FamilyRole.member;
      default:
        throw ArgumentError('Invalid FamilyRole value: $value');
    }
  }

  @override
  String toString() => value;
}

/// Core Family Member domain entity
class FamilyMember extends Equatable {
  final String id;
  final String familyId;
  final String userId;
  final FamilyRole role;
  final String status;
  final DateTime joinedAt;
  final DateTime? updatedAt;

  // User details (from relation)
  final String? userName;
  final String? userEmail;
  final String? userPhone;

  const FamilyMember({
    required this.id,
    required this.familyId,
    required this.userId,
    required this.role,
    required this.status,
    required this.joinedAt,
    this.updatedAt,
    this.userName,
    this.userEmail,
    this.userPhone,
  });

  FamilyMember copyWith({
    String? id,
    String? familyId,
    String? userId,
    FamilyRole? role,
    String? status,
    DateTime? joinedAt,
    DateTime? updatedAt,
    String? userName,
    String? userEmail,
    String? userPhone,
  }) {
    return FamilyMember(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
    );
  }

  /// Check if member is an admin
  bool get isAdmin => role == FamilyRole.admin;

  /// Check if member is a regular member
  bool get isMember => role == FamilyRole.member;

  /// Get role display name for UI
  String get roleDisplayName {
    switch (role) {
      case FamilyRole.admin:
        return 'Administrator';
      case FamilyRole.member:
        return 'Member';
    }
  }

  /// Get display name for UI (falls back to user ID if name not available)
  String get displayName {
    return (userName?.isNotEmpty == true) ? userName! : 'User $userId';
  }

  /// Get display name or loading state for UI
  String get displayNameOrLoading {
    if (userName != null && userName!.isNotEmpty) {
      return userName!;
    }
    return 'Loading...';
  }

  @override
  List<Object?> get props => [
    id,
    familyId,
    userId,
    role,
    status,
    joinedAt,
    updatedAt,
    userName,
    userEmail,
    userPhone,
  ];
}
