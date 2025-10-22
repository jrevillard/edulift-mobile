// EduLift Mobile - Family Invitation Entity
// Domain entity for family invitations with enhanced functionality

import 'package:equatable/equatable.dart';

// Import the shared InvitationStatus enum from invitation.dart
import '../../../../core/domain/entities/invitations/invitation.dart' show InvitationStatus;

/// Family invitation entity representing an invitation to join a family
class FamilyInvitation extends Equatable {
  /// Unique identifier for the invitation
  final String id;

  /// ID of the family extending the invitation
  final String familyId;

  /// Email address of the person being invited
  final String email;

  /// Role being offered (admin, member, etc.)
  final String role;

  /// ID of the user who created the invitation
  final String invitedBy;

  /// Name of the user who created the invitation
  final String invitedByName;

  /// ID of the user who created the invitation (from API)
  final String createdBy;

  /// When the invitation was created
  final DateTime createdAt;

  /// When the invitation expires
  final DateTime expiresAt;

  /// Current status of the invitation
  final InvitationStatus status;

  /// Optional personal message from the inviter
  final String? personalMessage;

  /// Invitation code for sharing
  final String inviteCode;

  /// When the invitation was accepted (if applicable)
  final DateTime? acceptedAt;

  /// ID of the user who accepted (if applicable)
  final String? acceptedBy;

  /// When the invitation was responded to (accepted/declined)
  final DateTime? respondedAt;

  /// When the invitation was last updated
  final DateTime updatedAt;

  /// Additional metadata
  final Map<String, dynamic>? metadata;

  const FamilyInvitation({
    required this.id,
    required this.familyId,
    required this.email,
    required this.role,
    required this.invitedBy,
    required this.invitedByName,
    required this.createdBy,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
    this.personalMessage,
    required this.inviteCode,
    this.acceptedAt,
    this.acceptedBy,
    this.respondedAt,
    required this.updatedAt, 
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

  /// Create a copy with updated fields
  FamilyInvitation copyWith({
    String? id,
    String? familyId,
    String? email,
    String? role,
    String? invitedBy,
    String? invitedByName,
    String? createdBy,
    DateTime? createdAt,
    DateTime? expiresAt,
    InvitationStatus? status,
    String? personalMessage,
    String? inviteCode,
    DateTime? acceptedAt,
    String? acceptedBy,
    DateTime? respondedAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return FamilyInvitation(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      email: email ?? this.email,
      role: role ?? this.role,
      invitedBy: invitedBy ?? this.invitedBy,
      invitedByName: invitedByName ?? this.invitedByName,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      personalMessage: personalMessage ?? this.personalMessage,
      inviteCode: inviteCode ?? this.inviteCode,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      acceptedBy: acceptedBy ?? this.acceptedBy,
      respondedAt: respondedAt ?? this.respondedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
    id,
    familyId,
    email,
    role,
    invitedBy,
    invitedByName,
    createdBy,
    createdAt,
    expiresAt,
    status,
    personalMessage,
    inviteCode,
    acceptedAt,
    acceptedBy,
    respondedAt,
    updatedAt, 
    metadata,
  ];

  @override
  String toString() {
    return 'FamilyInvitation(id: $id, familyId: $familyId, email: $email, status: ${status.displayName})';
  }
}

/// Family invitation validation result
/// Used to validate and process invitation codes before joining families
class FamilyInvitationValidation extends Equatable {
  /// Whether the invitation is valid and can be used
  final bool valid;

  /// The family ID associated with the invitation
  final String? familyId;

  /// The name of the family being invited to
  final String? familyName;

  /// The role the user will have in the family
  final String? role;

  /// Personal message from the inviter
  final String? personalMessage;

  /// Email associated with the invitation
  final String? email;

  /// Email of the person who sent the invitation
  final String? inviterEmail;

  /// Whether the user already exists in the system
  final bool? existingUser;

  /// The user's current family (if any)
  final dynamic userCurrentFamily; // Using dynamic to avoid circular import

  /// Error message if validation failed
  final String? error;

  /// Error code for programmatic error handling
  final String? errorCode;

  /// Name of the person who sent the invitation
  final String? invitedByName;

  /// When this invitation expires (legacy field for tests)
  final DateTime? expiresAt;

  /// Creates a new family invitation validation result
  const FamilyInvitationValidation({
    required this.valid,
    this.familyId,
    this.familyName,
    this.role,
    this.personalMessage,
    this.email,
    this.inviterEmail,
    this.expiresAt,
    this.existingUser,
    this.userCurrentFamily,
    this.error,
    this.errorCode,
    this.invitedByName,
  });

  /// Creates a successful validation result
  factory FamilyInvitationValidation.success({
    required String familyId,
    required String familyName,
    required String role,
    String? personalMessage,
    String? email,
    String? inviterEmail,
    DateTime? expiresAt,
    bool? existingUser,
    dynamic userCurrentFamily,
    String? invitedByName,
  }) {
    return FamilyInvitationValidation(
      valid: true,
      familyId: familyId,
      familyName: familyName,
      role: role,
      personalMessage: personalMessage,
      email: email,
      inviterEmail: inviterEmail,
      expiresAt: expiresAt,
      existingUser: existingUser,
      userCurrentFamily: userCurrentFamily,
      invitedByName: invitedByName,
    );
  }

  /// Creates a failed validation result
  factory FamilyInvitationValidation.failure({
    required String error,
    String? errorCode,
  }) {
    return FamilyInvitationValidation(
      valid: false,
      error: error,
      errorCode: errorCode,
    );
  }

  /// Creates a copy with updated values
  FamilyInvitationValidation copyWith({
    bool? valid,
    String? familyId,
    String? familyName,
    String? role,
    String? personalMessage,
    String? email,
    String? inviterEmail,
    DateTime? expiresAt,
    bool? existingUser,
    dynamic userCurrentFamily,
    String? error,
    String? errorCode,
    String? invitedByName,
  }) {
    return FamilyInvitationValidation(
      valid: valid ?? this.valid,
      familyId: familyId ?? this.familyId,
      familyName: familyName ?? this.familyName,
      role: role ?? this.role,
      personalMessage: personalMessage ?? this.personalMessage,
      email: email ?? this.email,
      inviterEmail: inviterEmail ?? this.inviterEmail,
      expiresAt: expiresAt ?? this.expiresAt,
      existingUser: existingUser ?? this.existingUser,
      userCurrentFamily: userCurrentFamily ?? this.userCurrentFamily,
      error: error ?? this.error,
      errorCode: errorCode ?? this.errorCode,
      invitedByName: invitedByName ?? this.invitedByName,
    );
  }

  @override
  List<Object?> get props => [
    valid,
    familyId,
    familyName,
    role,
    personalMessage,
    email,
    inviterEmail,
    expiresAt,
    existingUser,
    userCurrentFamily,
    error,
    errorCode,
    invitedByName,
  ];

  @override
  String toString() {
    return 'FamilyInvitationValidation('
        'valid: $valid, '
        'familyId: $familyId, '
        'familyName: $familyName, '
        'error: $error'
        ')';
  }
}
