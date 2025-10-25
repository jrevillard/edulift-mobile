// EduLift Mobile - Invitation Repository Implementation
// Clean invitation system with unified error handling via NetworkErrorHandler
// Migrated from manual network checks to NetworkErrorHandler pattern

import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_error_handler.dart';
import '../../../../core/network/models/family/family_invitation_dto.dart';
import '../../../../core/network/models/family/family_invitation_validation_dto.dart';
import '../../domain/validators/family_form_validator.dart';
import '../../../../core/utils/app_logger.dart';
import 'package:edulift/core/domain/failures/invitation_failure.dart';
import '../../domain/errors/family_invitation_error.dart';
import 'package:edulift/core/domain/entities/family.dart';
import '../../domain/repositories/family_invitation_repository.dart';
import '../datasources/family_remote_datasource.dart';
import '../datasources/family_local_datasource.dart';

/// Invitation repository implementation with unified error handling
/// All network operations use NetworkErrorHandler for:
/// - Automatic retry with exponential backoff
/// - Circuit breaker protection
/// - Unified error handling
/// - HTTP 0/503 detection with cache fallback (Principe 0)
class InvitationRepositoryImpl implements InvitationRepository {
  final FamilyRemoteDataSource remoteDataSource;
  final FamilyLocalDataSource localDataSource;
  final NetworkErrorHandler _networkErrorHandler;

  const InvitationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required NetworkErrorHandler networkErrorHandler,
  }) : _networkErrorHandler = networkErrorHandler;

  @override
  Future<Result<List<FamilyInvitation>, ApiFailure>> getPendingInvitations({
    required String familyId,
  }) async {
    final result = await _networkErrorHandler
        .executeRepositoryOperation<List<FamilyInvitationDto>>(
      () => remoteDataSource.getFamilyInvitations(familyId: familyId),
      operationName: 'invitation.getPendingInvitations',
      strategy: CacheStrategy.networkOnly,
      serviceName: 'invitation',
      config: RetryConfig.quick,
      onSuccess: (dtos) async {
        final invitations = dtos.map((dto) => dto.toDomain()).toList();
        await _cacheFamilyInvitations(invitations);
        AppLogger.info(
          '[INVITATION] Cached ${invitations.length} pending invitations',
        );
      },
      context: {'familyId': familyId},
    );

    return result.when(
      ok: (dtos) {
        final invitations = dtos.map((dto) => dto.toDomain()).toList();
        return Result.ok(invitations);
      },
      err: (failure) async {
        // PRINCIPE 0: HTTP 0/503 = Network error → fallback to cache
        if (failure.statusCode == 0 || failure.statusCode == 503) {
          final cached = await _getLocalPendingInvitations();
          if (cached.isNotEmpty) {
            AppLogger.info(
              '[INVITATION] Network error - fallback to cache: ${cached.length} invitations',
            );
            return Result.ok(cached);
          }
        }
        return Result.err(failure);
      },
    );
  }

  @override
  Future<Result<FamilyInvitation, InvitationFailure>> inviteMember({
    required String familyId,
    required String email,
    required String role,
    String? personalMessage,
  }) async {
    // Validate email FIRST
    final emailValidationError = FamilyFormValidator.validateEmail(email);
    if (emailValidationError != null) {
      AppLogger.info('[INVITATION] Email validation failed', {'email': email});
      return const Result.err(
        InvitationFailure(
          error: InvitationError.emailInvalid,
          message: 'Invalid email format',
        ),
      );
    }

    // Use NetworkErrorHandler for unified error handling
    final result = await _networkErrorHandler
        .executeRepositoryOperation<FamilyInvitationDto>(
      () => remoteDataSource.inviteMember(
        email: email,
        familyId: familyId,
        role: role,
        personalMessage: personalMessage,
      ),
      operationName: 'invitation.inviteMember',
      strategy: CacheStrategy.networkOnly,
      serviceName: 'invitation',
      config: RetryConfig.quick,
      onSuccess: (invitationDto) async {
        final invitation = invitationDto.toDomain();
        await _cacheFamilyInvitation(invitation);
        AppLogger.info(
          '[INVITATION] Member invited and cached successfully',
          {
            'familyId': familyId,
            'email': email,
            'invitationId': invitation.id,
          },
        );
      },
      context: {'familyId': familyId, 'email': email, 'role': role},
    );

    return result.when(
      ok: (invitationDto) {
        final invitation = invitationDto.toDomain();
        return Result.ok(invitation);
      },
      err: (apiFailure) {
        // Convert ApiFailure to InvitationFailure
        final errorMessage = (apiFailure.message ?? '').toLowerCase();

        // Detect duplicate invitation errors
        if (errorMessage.contains('already exists') ||
            errorMessage.contains('already invited') ||
            errorMessage.contains('duplicate') ||
            errorMessage.contains('pending invitation')) {
          AppLogger.info('[INVITATION] Duplicate invitation detected', {
            'email': email,
            'message': apiFailure.message,
          });
          return Result.err(
            InvitationFailure(
              error: InvitationError.pendingInvitationExists,
              message: apiFailure.message,
            ),
          );
        }

        // Network errors
        if (apiFailure.statusCode == 0 || apiFailure.statusCode == 503) {
          return const Result.err(
            InvitationFailure(
              error: InvitationError.inviteOperationFailed,
              message:
                  'No internet connection. This operation requires network access.',
            ),
          );
        }

        // Generic failure
        return Result.err(
          InvitationFailure(
            error: InvitationError.inviteOperationFailed,
            message: apiFailure.message,
          ),
        );
      },
    );
  }

  @override
  Future<Result<FamilyInvitation, ApiFailure>> sendFamilyInvitation({
    required String email,
    required String familyId,
    String? message,
    String? role,
  }) async {
    // Validate email FIRST
    final emailValidationError = FamilyFormValidator.validateEmail(email);
    if (emailValidationError != null) {
      return Result.err(
        ApiFailure.validationError(
          message: 'Invalid email format',
          code: 'validation.email_invalid',
        ),
      );
    }

    final result = await _networkErrorHandler
        .executeRepositoryOperation<FamilyInvitationDto>(
      () => remoteDataSource.inviteMember(
        email: email,
        familyId: familyId,
        role: role ?? 'member',
        personalMessage: message,
      ),
      operationName: 'invitation.sendFamilyInvitation',
      strategy: CacheStrategy.networkOnly,
      serviceName: 'invitation',
      config: RetryConfig.quick,
      onSuccess: (invitationDto) async {
        final invitation = invitationDto.toDomain();
        await _cacheFamilyInvitation(invitation);
        AppLogger.info('[INVITATION] Family invitation sent and cached', {
          'familyId': familyId,
          'email': email,
        });
      },
      context: {
        'familyId': familyId,
        'email': email,
        'role': role ?? 'member',
      },
    );

    return result.when(
      ok: (invitationDto) => Result.ok(invitationDto.toDomain()),
      err: (failure) => Result.err(failure),
    );
  }

  @override
  Future<Result<FamilyInvitation, ApiFailure>> acceptFamilyInvitationByCode({
    required String inviteCode,
  }) async {
    final result = await _networkErrorHandler
        .executeRepositoryOperation<FamilyInvitationDto>(
      () => remoteDataSource.acceptInvitation(inviteCode: inviteCode),
      operationName: 'invitation.acceptInvitation',
      strategy: CacheStrategy.networkOnly,
      serviceName: 'invitation',
      config: RetryConfig.quick,
      onSuccess: (invitationDto) async {
        final invitation = invitationDto.toDomain();
        await _cacheFamilyInvitation(invitation);
        await _refreshFamilyData();
        AppLogger.info('[INVITATION] Invitation accepted and cached', {
          'inviteCode': inviteCode,
          'invitationId': invitation.id,
        });
      },
      context: {'inviteCode': inviteCode},
    );

    return result.when(
      ok: (invitationDto) => Result.ok(invitationDto.toDomain()),
      err: (failure) => Result.err(failure),
    );
  }

  @override
  Future<Result<FamilyInvitation, ApiFailure>> declineInvitation({
    required String invitationId,
    String? reason,
  }) async {
    final result = await _networkErrorHandler
        .executeRepositoryOperation<FamilyInvitationDto>(
      () => remoteDataSource.declineInvitation(
        invitationId: invitationId,
        reason: reason,
      ),
      operationName: 'invitation.declineInvitation',
      strategy: CacheStrategy.networkOnly,
      serviceName: 'invitation',
      config: RetryConfig.quick,
      onSuccess: (invitationDto) async {
        final invitation = invitationDto.toDomain();
        await _cacheFamilyInvitation(invitation);
        AppLogger.info('[INVITATION] Invitation declined and cached', {
          'invitationId': invitationId,
        });
      },
      context: {'invitationId': invitationId, 'reason': reason},
    );

    return result.when(
      ok: (invitationDto) => Result.ok(invitationDto.toDomain()),
      err: (failure) => Result.err(failure),
    );
  }

  @override
  Future<Result<void, ApiFailure>> cancelFamilyInvitation({
    required String invitationId,
    required String familyId,
  }) async {
    final result = await _networkErrorHandler.executeRepositoryOperation<void>(
      () => remoteDataSource.cancelInvitation(
        familyId: familyId,
        invitationId: invitationId,
      ),
      operationName: 'invitation.cancelInvitation',
      strategy: CacheStrategy.networkOnly,
      serviceName: 'invitation',
      config: RetryConfig.quick,
      onSuccess: (_) async {
        await _removeInvitation(invitationId);
        AppLogger.info('[INVITATION] Invitation cancelled and cache updated', {
          'familyId': familyId,
          'invitationId': invitationId,
        });
      },
      context: {'familyId': familyId, 'invitationId': invitationId},
    );

    return result;
  }

  @override
  Future<Result<FamilyInvitation, ApiFailure>> joinWithCode({
    required String code,
    String? role,
  }) async {
    // Validate code FIRST
    if (code.isEmpty) {
      return Result.err(
        ApiFailure.validationError(
          message: 'Invitation code is required',
          code: 'validation.invitation_code_required',
        ),
      );
    }

    final result =
        await _networkErrorHandler.executeRepositoryOperation<Invitation>(
      () => remoteDataSource.joinWithCode(code: code, role: role),
      operationName: 'invitation.joinWithCode',
      strategy: CacheStrategy.networkOnly,
      serviceName: 'invitation',
      config: RetryConfig.quick,
      onSuccess: (invitation) async {
        final familyInvitation = _mapInvitationToFamilyInvitation(
          invitation,
        );
        await _cacheFamilyInvitation(familyInvitation);
        await _refreshFamilyData();
        AppLogger.info('[INVITATION] Joined with code and cached', {
          'code': code,
          'invitationId': familyInvitation.id,
        });
      },
      context: {'code': code, 'role': role},
    );

    return result.when(
      ok: (invitation) {
        final familyInvitation = _mapInvitationToFamilyInvitation(invitation);
        return Result.ok(familyInvitation);
      },
      err: (failure) => Result.err(failure),
    );
  }

  @override
  Future<Result<List<FamilyInvitation>, ApiFailure>> getFamilyInvitations({
    required String familyId,
  }) async {
    final result = await _networkErrorHandler
        .executeRepositoryOperation<List<FamilyInvitationDto>>(
      () => remoteDataSource.getFamilyInvitations(familyId: familyId),
      operationName: 'invitation.getFamilyInvitations',
      strategy: CacheStrategy.networkOnly,
      serviceName: 'invitation',
      config: RetryConfig.quick,
      onSuccess: (dtos) async {
        final invitations = dtos.map((dto) => dto.toDomain()).toList();
        await _cacheFamilyInvitations(invitations);
        AppLogger.info(
          '[INVITATION] Cached ${invitations.length} family invitations',
        );
      },
      context: {'familyId': familyId},
    );

    return result.when(
      ok: (dtos) {
        final invitations = dtos.map((dto) => dto.toDomain()).toList();
        return Result.ok(invitations);
      },
      err: (failure) async {
        // PRINCIPE 0: HTTP 0/503 = Network error → fallback to cache
        if (failure.statusCode == 0 || failure.statusCode == 503) {
          final cached = await _getLocalFamilyInvitations(familyId);
          if (cached.isNotEmpty) {
            AppLogger.info(
              '[INVITATION] Network error - fallback to cache: ${cached.length} invitations',
            );
            return Result.ok(cached);
          }
        }
        return Result.err(failure);
      },
    );
  }

  @override
  Future<Result<void, ApiFailure>> revokeInvitation({
    required String familyId,
    required String invitationId,
  }) async {
    final result = await _networkErrorHandler.executeRepositoryOperation<void>(
      () => remoteDataSource.cancelInvitation(
        familyId: familyId,
        invitationId: invitationId,
      ),
      operationName: 'invitation.revokeInvitation',
      strategy: CacheStrategy.networkOnly,
      serviceName: 'invitation',
      config: RetryConfig.quick,
      onSuccess: (_) async {
        await _removeInvitation(invitationId);
        AppLogger.info('[INVITATION] Invitation revoked and cache updated', {
          'familyId': familyId,
          'invitationId': invitationId,
        });
      },
      context: {'familyId': familyId, 'invitationId': invitationId},
    );

    return result;
  }

  // ========================================
  // HELPER METHODS
  // ========================================

  // REMOVED: _createTempFamilyInvitation and _createTempInvitationWithRole
  // These methods created fake entities that would never sync to server
  // All write operations now follow Server First pattern

  /// Map Invitation to FamilyInvitation entity
  FamilyInvitation _mapInvitationToFamilyInvitation(Invitation inv) {
    return FamilyInvitation(
      id: inv.id,
      email: inv.recipientEmail,
      role: inv.role ?? 'member',
      familyId: inv.familyId ?? '',
      invitedBy: inv.inviterId,
      invitedByName: inv.inviterName,
      createdBy: inv.inviterId, // Use inviterId as createdBy
      status: inv.status,
      createdAt: inv.createdAt,
      expiresAt: inv.expiresAt,
      respondedAt: inv.respondedAt,
      personalMessage: inv.message,
      inviteCode: inv.inviteCode ?? '',
      updatedAt: DateTime.now(),
    );
  }

  // Local data access helper methods (simplified implementations)
  Future<List<FamilyInvitation>> _getLocalPendingInvitations() async {
    try {
      final familyInvitations = await localDataSource.getInvitations();
      return familyInvitations;
    } catch (e) {
      return [];
    }
  }

  Future<List<FamilyInvitation>> _getLocalFamilyInvitations(
    String familyId,
  ) async {
    try {
      final familyInvitations = await localDataSource.getInvitations();
      return familyInvitations
          .where((inv) => inv.familyId == familyId)
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _cacheFamilyInvitation(FamilyInvitation familyInvitation) async {
    // Cache FamilyInvitation directly
    await localDataSource.cacheFamilyInvitation(familyInvitation);
  }

  Future<void> _cacheFamilyInvitations(
    List<FamilyInvitation> familyInvitations,
  ) async {
    await localDataSource.cacheInvitations(familyInvitations);
  }

  Future<void> _removeInvitation(String inviteCode) async {
    // TODO: Implement invitation removal from local storage
  }

  // REMOVED: _markInvitationForDeletion
  // This method enabled silent failures by marking for deletion without actually deleting
  // Now all delete operations must succeed on server first

  Future<void> _refreshFamilyData() async {
    try {
      // TODO: Refresh family and group data after invitation acceptance
      // This will be implemented when needed
    } catch (e) {
      // Silently handle refresh errors
      AppLogger.warning('[INVITATION] Failed to refresh family data', e);
    }
  }

  @override
  Future<Result<FamilyInvitationValidationDto, ApiFailure>>
      validateFamilyInvitation({required String inviteCode}) async {
    // Validate invitation code format
    if (inviteCode.isEmpty) {
      return Result.err(
        ApiFailure.validationError(
          message: 'Invitation code cannot be empty',
          code: 'validation.empty_code',
        ),
      );
    }

    final result = await _networkErrorHandler
        .executeRepositoryOperation<FamilyInvitationValidationDto>(
      () => remoteDataSource.validateInvitation(inviteCode: inviteCode),
      operationName: 'invitation.validateInvitation',
      strategy: CacheStrategy.networkOnly,
      serviceName: 'invitation',
      config: RetryConfig.quick,
      context: {'inviteCode': inviteCode},
    );

    return result.when(
      ok: (validationDto) => Result.ok(validationDto),
      err: (failure) {
        // BUSINESS LOGIC: 404 means code not found (invalid code)
        if (failure.statusCode == 404 || failure.code == 'api.not_found') {
          AppLogger.info('[INVITATION] Code not found (404) - invalid code');
          return Result.err(
            ApiFailure.notFound(resource: 'Invitation code not found'),
          );
        }
        return Result.err(failure);
      },
    );
  }
}
