// EduLift Mobile - Invitation Use Case
// Clean Architecture implementation for invitation business logic
// Domain layer - orchestrates invitation operations

import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/domain/entities/family.dart';
import '../../../../core/network/models/family/family_invitation_validation_dto.dart';
import '../repositories/family_invitation_repository.dart';
import 'package:edulift/core/domain/failures/invitation_failure.dart';
import '../errors/family_invitation_error.dart';

/// Use case for managing invitations
///
/// This use case orchestrates invitation-related business logic and validation.
/// It sits between the presentation layer (Providers) and the data layer (Repository).
/// All business rules and validation should be implemented here.
class InvitationUseCase {
  final InvitationRepository _repository;

  const InvitationUseCase({required InvitationRepository repository})
      : _repository = repository;

  // ========================================
  // CORE INVITATION OPERATIONS
  // ========================================

  /// Get all pending invitations for the current user
  ///
  /// Business rules:
  /// - Only return invitations that are still pending
  /// - Filter out expired invitations
  Future<Result<List<FamilyInvitation>, Failure>> getPendingInvitations(
    String familyId,
  ) async {
    AppLogger.debug('[InvitationUseCase] Getting pending invitations');
    final result = await _repository.getPendingInvitations(familyId: familyId);

    if (result.isOk) {
      final invitations = result.value!;
      // Apply business rules: filter out expired invitations
      final now = DateTime.now();
      final validInvitations =
          invitations.where((inv) => inv.expiresAt.isAfter(now)).toList();
      AppLogger.debug(
        '[InvitationUseCase] Retrieved ${validInvitations.length} valid pending invitations',
      );
      return Result.ok(validInvitations);
    }

    AppLogger.error(
      '[InvitationUseCase] Failed to get pending invitations: ${result.error!.message}',
    );
    return Result.err(result.error!);
  }

  /// Invite a member with role specification and validation
  ///
  /// Business rules:
  /// - Email must be valid format
  /// - Role must be from allowed roles
  /// - Cannot invite same email twice to same entity
  Future<Result<FamilyInvitation, Failure>> inviteMember({
    required String familyId,
    required String email,
    required String role,
    String? personalMessage,
  }) async {
    AppLogger.debug(
      '[InvitationUseCase] Inviting member: $email with role: $role',
    );

    // Validate email format
    if (!_isValidEmail(email)) {
      return const Result.err(
        InvitationFailure(error: InvitationError.emailInvalid),
      );
    }

    // Validate role
    if (!_isValidRole(role)) {
      return const Result.err(
        InvitationFailure(error: InvitationError.roleInvalid),
      );
    }

    // Validate personal message length
    if (personalMessage != null && personalMessage.length > 500) {
      return const Result.err(
        InvitationFailure(error: InvitationError.messageTooLong),
      );
    }

    final result = await _repository.inviteMember(
      familyId: familyId,
      email: email,
      role: role,
      personalMessage: personalMessage,
    );

    if (result.isOk) {
      final invitation = result.value!;
      AppLogger.debug(
        '[InvitationUseCase] Successfully invited member: ${invitation.id}',
      );
      return Result.ok(invitation);
    }

    AppLogger.error(
      '[InvitationUseCase] Failed to invite member: ${result.error!.message}',
    );
    return Result.err(result.error!);
  }

  /// Send a family invitation with validation
  Future<Result<FamilyInvitation, Failure>> sendFamilyInvitation({
    required String email,
    required String familyId,
    String? message,
    String? role,
  }) async {
    AppLogger.debug(
      '[InvitationUseCase] Sending family invitation to: $email for family: $familyId',
    );

    // Validate email format
    if (!_isValidEmail(email)) {
      return const Result.err(
        InvitationFailure(error: InvitationError.emailInvalid),
      );
    }

    // Validate familyId
    if (familyId.isEmpty) {
      return const Result.err(
        InvitationFailure(error: InvitationError.familyIdRequired),
      );
    }

    // Validate role if provided
    if (role != null && !_isValidRole(role)) {
      return const Result.err(
        InvitationFailure(error: InvitationError.roleInvalid),
      );
    }

    final result = await _repository.sendFamilyInvitation(
      email: email,
      familyId: familyId,
      message: message,
      role: role,
    );

    if (result.isOk) {
      final invitation = result.value!;
      AppLogger.debug(
        '[InvitationUseCase] Successfully sent family invitation: ${invitation.id}',
      );
      return Result.ok(invitation);
    }

    AppLogger.error(
      '[InvitationUseCase] Failed to send family invitation: ${result.error!.message}',
    );
    return Result.err(result.error!);
  }

  /// Accept an invitation with validation
  ///
  /// Business rules:
  /// - Invitation must exist and be pending
  /// - Invitation must not be expired
  /// - User must not already be member of target entity
  Future<Result<FamilyInvitation, Failure>> acceptInvitation({
    required String inviteCode,
  }) async {
    AppLogger.debug('[InvitationUseCase] Accepting invitation: $inviteCode');

    // Validate inviteCode
    if (inviteCode.isEmpty) {
      return const Result.err(
        InvitationFailure(error: InvitationError.invitationIdRequired),
      );
    }

    final result = await _repository.acceptFamilyInvitationByCode(
      inviteCode: inviteCode,
    );

    if (result.isOk) {
      final invitation = result.value!;
      AppLogger.debug(
        '[InvitationUseCase] Successfully accepted invitation: ${invitation.id}',
      );
      return Result.ok(invitation);
    }

    AppLogger.error(
      '[InvitationUseCase] Failed to accept invitation: ${result.error!.message}',
    );
    return Result.err(result.error!);
  }

  /// Cancel a sent invitation with validation
  Future<Result<void, Failure>> cancelInvitation({
    required String invitationId,
    required String familyId,
  }) async {
    AppLogger.debug('[InvitationUseCase] Cancelling invitation: $invitationId');

    // Validate invitationId
    if (invitationId.isEmpty) {
      return const Result.err(
        InvitationFailure(error: InvitationError.invitationIdRequired),
      );
    }

    final result = await _repository.cancelFamilyInvitation(
      invitationId: invitationId,
      familyId: familyId,
    );

    if (result.isOk) {
      AppLogger.debug(
        '[InvitationUseCase] Successfully cancelled invitation: $invitationId',
      );
      return const Result.ok(null);
    }

    AppLogger.error(
      '[InvitationUseCase] Failed to cancel invitation: ${result.error!.message}',
    );
    return Result.err(result.error!);
  }

  // ========================================
  // PRIVATE VALIDATION HELPERS
  // ========================================

  /// Validate email format using regex
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2}$',
    );
    return emailRegex.hasMatch(email) && email.length <= 254;
  }

  /// Validate a family invitation code
  ///
  /// Business rules:
  /// - Invitation code must not be empty
  /// - Returns validation details from backend
  Future<Result<FamilyInvitationValidationDto, Failure>>
      validateFamilyInvitation({required String inviteCode}) async {
    AppLogger.debug(
      '[InvitationUseCase] Validating family invitation code: $inviteCode',
    );

    // Validate inviteCode
    if (inviteCode.isEmpty) {
      return const Result.err(
        InvitationFailure(error: InvitationError.invitationIdRequired),
      );
    }

    final result = await _repository.validateFamilyInvitation(
      inviteCode: inviteCode,
    );

    if (result.isOk) {
      final validation = result.value!;
      AppLogger.debug(
        '[InvitationUseCase] Validation result: valid=${validation.valid}',
      );
      return Result.ok(validation);
    }

    AppLogger.error(
      '[InvitationUseCase] Failed to validate invitation: ${result.error!.message}',
    );
    return Result.err(result.error!);
  }

  /// Validate role against allowed roles
  bool _isValidRole(String role) {
    const allowedRoles = [
      'admin',
      'member',
      'parent',
      'child',
      'driver',
      'observer',
      'moderator',
    ];
    return allowedRoles.contains(role.toLowerCase());
  }
}
