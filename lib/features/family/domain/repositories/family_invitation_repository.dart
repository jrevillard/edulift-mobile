import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/domain/entities/family.dart';
import '../../../../core/network/models/family/family_invitation_validation_dto.dart';
import 'package:edulift/core/domain/failures/invitation_failure.dart';

/// Repository interface for managing invitations
abstract class InvitationRepository {
  // ========================================
  // CORE INVITATION METHODS
  // ========================================

  /// Get all pending invitations for the current user
  Future<Result<List<FamilyInvitation>, ApiFailure>> getPendingInvitations({
    required String familyId,
  });

  /// Invite a member with role specification
  Future<Result<FamilyInvitation, InvitationFailure>> inviteMember({
    required String familyId,
    required String email,
    required String role,
    String? personalMessage,
  });

  /// Send a family invitation to an email address
  Future<Result<FamilyInvitation, ApiFailure>> sendFamilyInvitation({
    required String email,
    required String familyId,
    String? message,
    String? role,
  });

  /// Accept a family invitation by its code
  Future<Result<FamilyInvitation, ApiFailure>> acceptFamilyInvitationByCode({
    required String inviteCode,
  });

  /// Cancel a sent family invitation by its ID
  Future<Result<void, ApiFailure>> cancelFamilyInvitation({
    required String invitationId,
    required String familyId,
  });

  /// Join using an invitation code
  Future<Result<FamilyInvitation, ApiFailure>> joinWithCode({
    required String code,
    String? role,
  });

  /// Get invitations by family ID
  Future<Result<List<FamilyInvitation>, ApiFailure>> getFamilyInvitations({
    required String familyId,
  });

  /// Revoke/cancel a family invitation by its ID (alias for cancelFamilyInvitation)
  Future<Result<void, ApiFailure>> revokeInvitation({
    required String familyId,
    required String invitationId,
  });

  /// Decline an invitation
  Future<Result<FamilyInvitation, ApiFailure>> declineInvitation({
    required String invitationId,
    String? reason,
  });

  /// Validate a family invitation code (returns validation details)
  Future<Result<FamilyInvitationValidationDto, ApiFailure>>
      validateFamilyInvitation({required String inviteCode});
}
