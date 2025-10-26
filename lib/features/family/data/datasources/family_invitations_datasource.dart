// EduLift Mobile - Family Invitations Data Source Interface
// Focused interface for invitation operations only

import 'dart:async';

import 'package:edulift/core/domain/entities/family.dart';

/// Family invitation data operations (CRUD, caching, offline sync)
abstract class FamilyInvitationsDataSource {
  // ========================================
  // INVITATION CACHING OPERATIONS
  // ========================================

  /// Get pending invitations from local storage
  Future<List<FamilyInvitation>> getPendingInvitations();

  /// Cache single invitation locally
  Future<void> cacheInvitation(FamilyInvitation invitation);

  /// Cache multiple invitations locally
  Future<void> cacheInvitations(List<FamilyInvitation> invitations);

  /// Remove invitation from local storage
  Future<void> removeInvitation(String invitationId);

  /// Get cached invitations
  Future<List<FamilyInvitation>> getCachedInvitations();

  /// Clear all cached invitations
  Future<void> clearCachedInvitations();

  // ========================================
  // INVITATION OFFLINE SYNC OPERATIONS
  // ========================================

  /// Store pending invitation creation for sync
  Future<void> storePendingInvitationCreation(
    String email,
    String role,
    String? personalMessage,
  );

  /// Store pending invitation acceptance for sync
  Future<void> storePendingInvitationAcceptance(String invitationId);

  /// Store pending invitation decline for sync
  Future<void> storePendingInvitationDecline(
    String invitationId,
    String? reason,
  );

  /// Store pending invitation cancellation for sync
  Future<void> storePendingInvitationCancellation(String invitationId);

  /// Get pending invitation changes count
  Future<int> getPendingInvitationChangesCount();

  /// Clear pending invitation changes
  Future<void> clearPendingInvitationChanges();
}
