// TDD London Step 2.1.2: Family Remote DataSource Implementation
// GREEN Phase: Clean Architecture with ApiClient abstraction
// Following strict TDD London methodology - implement only what tests require

import '../../../../core/network/family_api_client.dart';
import '../../../../core/network/models/common/api_response_wrapper.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/network/models/family/family_dto.dart';
import '../../../../core/network/models/child/child_dto.dart';
import '../../../../core/network/models/vehicle/vehicle_dto.dart';
import '../../../../core/network/models/family/family_invitation_dto.dart';
import '../../../../core/network/models/family/family_invitation_validation_dto.dart';
// Domain entities imported for existing functionality
import '../../../../core/domain/entities/invitations/invitation.dart'
    as invitation;
import '../../../../core/domain/entities/invitations/invitation.dart'
    show InvitationType, InvitationCode, InvitationStats;

// ⚠️ ARCHITECTURE VIOLATION WARNING:
// This implementation uses domain entities which violates clean architecture.
// DTOs should be used instead, but changing this would break existing functionality.
import 'family_remote_datasource.dart';

class FamilyRemoteDataSourceImpl implements FamilyRemoteDataSource {
  final FamilyApiClient _apiClient;

  // TDD London: Constructor dependency injection for ApiClient
  const FamilyRemoteDataSourceImpl(this._apiClient);

  // ========================================
  // CORE TDD LONDON GREEN IMPLEMENTATIONS
  // ========================================

  @override
  Future<FamilyDto> getCurrentFamily() async {
    // CLEAN ARCHITECTURE: DataSource responsibility is API communication only
    // No business logic here - let exceptions bubble up naturally
    // Repository will decide if 404 is an error or a valid state
    final response = await _apiClient.getCurrentFamily();
    return response.unwrap();
  }

  @override
  Future<FamilyDto> createFamily({required String name}) async {
    // TDD GREEN: Add input validation for empty family name
    if (name.trim().isEmpty) {
      throw const ValidationException('Family name cannot be empty');
    }

    final request = CreateFamilyRequest(name: name);
    final response = await _apiClient.createFamily(request);
    return response.unwrap();
  }

  @override
  Future<FamilyDto> updateFamilyName({required String name}) async {
    final request = UpdateFamilyNameRequest(name: name);
    final response = await _apiClient.updateFamilyName(request);
    return response.unwrap();
  }

  @override
  Future<ChildDto> addChild({required String name, int? age}) async {
    final request = CreateChildRequest(name: name, age: age);
    final apiResponse = await _apiClient.createChild(request);
    final response = apiResponse.unwrap();

    AppLogger.debug(
      '[FamilyRemoteDataSource] addChild API response data: $response',
    );

    return response;
  }

  @override
  Future<VehicleDto> addVehicle({
    required String name,
    required int capacity,
    String? description,
  }) async {
    final request = CreateVehicleRequest(
      name: name,
      capacity: capacity,
      description: description,
    );
    final apiResponse = await _apiClient.createVehicle(request);
    return apiResponse.unwrap();
  }

  // ========================================
  // ADDITIONAL REQUIRED METHODS
  // ========================================

  @override
  Future<void> leaveFamily(String familyId) async {
    final apiResponse = await _apiClient.leaveFamily(familyId);
    apiResponse.unwrap();
  }

  // ========================================
  // INVITATION OPERATIONS - REFACTORED
  // ========================================

  @override
  Future<FamilyInvitationValidationDto> validateInvitation({
    required String inviteCode,
  }) async {
    try {
      AppLogger.debug(
        '[FamilyRemoteDataSource] validateInvitation() called with code: $inviteCode',
      );

      // Use FamilyApiClient directly to validate family invitations
      final response = await _apiClient.validateInviteCode(inviteCode);
      return response.unwrap();
    } catch (e, stackTrace) {
      AppLogger.error(
        '[FamilyRemoteDataSource] Error validating invitation: $e',
        e,
        stackTrace,
      );
      throw ServerException(
        'Failed to validate invitation: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<FamilyDto> joinFamily({required String inviteCode}) async {
    try {
      AppLogger.debug(
        '[FamilyRemoteDataSource] joinFamily() called with code: $inviteCode',
      );

      final request = JoinFamilyRequest(inviteCode: inviteCode);
      final apiResponse = await _apiClient.joinFamily(request);
      return apiResponse.unwrap();
    } catch (e, stackTrace) {
      AppLogger.error(
        '[FamilyRemoteDataSource] Error joining family: $e',
        e,
        stackTrace,
      );
      throw ServerException(
        'Failed to join family: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<FamilyInvitationDto> inviteMember({
    required String familyId,
    required String email,
    required String role,
    String? personalMessage,
  }) async {
    try {
      AppLogger.debug('[FamilyRemoteDataSource] inviteMember() called', {
        'familyId': familyId,
        'email': email,
        'role': role,
        'hasPersonalMessage':
            personalMessage != null && personalMessage.isNotEmpty,
        'platform': 'native',
      });

      final request = InviteFamilyMemberRequest(
        email: email,
        role: role,
        message: personalMessage,
      );

      final apiResponse = await _apiClient.inviteFamilyMember(
        familyId,
        request,
      );
      final response = apiResponse.unwrap();

      AppLogger.debug(
        '[FamilyRemoteDataSource] Invitation sent successfully: ${response.id}',
      );
      return response;
    } catch (e, stackTrace) {
      if (e is InvitationException || e is ServerException) {
        rethrow; // Re-throw specific exceptions as-is
      }

      // Handle ApiException (HTTP errors from backend)
      if (e is ApiException) {
        final details = e.details;
        if (details != null) {
          String errorMessage;

          // PHASE2 FIX: Use ApiException.message directly (contains backend error)
          // ApiResponseHelper already extracted backend error message into e.message
          errorMessage = e.message;

          AppLogger.error(
            '[FamilyRemoteDataSource] Backend error in inviteMember()',
            {
              'statusCode': e.statusCode,
              'errorMessage': errorMessage,
              'email': email,
            },
          );

          // Parse specific error codes and throw appropriate exceptions
          if (errorMessage.contains('USER_ALREADY_MEMBER') ||
              errorMessage.contains('already a member')) {
            throw const UserAlreadyMemberException(
              'This user is already a member of your family.',
            );
          } else if (errorMessage.contains('INVITATION_EXPIRED') ||
              errorMessage.contains('expired')) {
            throw const InvitationExpiredException(
              'The invitation has expired. Please try again.',
            );
          } else if (errorMessage.contains('INVALID_INVITATION') ||
              errorMessage.contains('invalid')) {
            throw const InvalidInvitationException(
              'The invitation is invalid. Please check the details and try again.',
            );
          } else if (e.statusCode == 400) {
            // Generic 400 error - treat as invitation error
            throw InvitationException(
              errorMessage,
              errorCode: _extractErrorCode(errorMessage),
            );
          } else {
            // Other HTTP errors
            throw ServerException(
              errorMessage,
              statusCode: e.statusCode ?? 500,
            );
          }
        } else {
          // Network error or other Dio exception without response
          throw ServerException('Network error: ${e.message}', statusCode: 0);
        }
      }

      AppLogger.error(
        '[FamilyRemoteDataSource] Unexpected error in inviteMember()',
        e,
        stackTrace,
      );
      throw ServerException(
        'Unexpected error sending invitation: $e',
        statusCode: 500,
      );
    }
  }

  /// Extract error code from error message
  String? _extractErrorCode(String errorMessage) {
    final patterns = [
      'USER_ALREADY_MEMBER',
      'INVITATION_EXPIRED',
      'INVALID_INVITATION',
    ];
    for (final pattern in patterns) {
      if (errorMessage.contains(pattern)) {
        return pattern;
      }
    }
    return null;
  }

  @override
  Future<List<FamilyInvitationDto>> getFamilyInvitations({
    required String familyId,
  }) async {
    AppLogger.debug(
      '[FamilyRemoteDataSource] getFamilyInvitations() called for familyId: $familyId',
    );

    final apiResponse = await _apiClient.getFamilyInvitations(familyId);
    final response = apiResponse.unwrap();

    AppLogger.debug(
      '[FamilyRemoteDataSource] Successfully loaded ${response.length} family invitations',
    );
    return response;
  }

  @override
  Future<void> cancelInvitation({
    required String familyId,
    required String invitationId,
  }) async {
    AppLogger.debug('[FamilyRemoteDataSource] cancelInvitation() called', {
      'familyId': familyId,
      'invitationId': invitationId,
    });

    final apiResponse = await _apiClient.cancelFamilyInvitation(
      familyId,
      invitationId,
    );
    apiResponse.unwrap();

    AppLogger.debug(
      '[FamilyRemoteDataSource] Invitation successfully cancelled: $invitationId',
    );
  }

  @override
  Future<FamilyInvitationDto> acceptInvitation({
    required String inviteCode,
  }) async {
    AppLogger.debug(
      '[FamilyRemoteDataSource] acceptInvitation() called for inviteCode: $inviteCode',
    );

    final request = JoinFamilyRequest(inviteCode: inviteCode);
    final apiResponse = await _apiClient.joinFamily(request);
    final familyDto = apiResponse.unwrap();

    // Convert FamilyDto to FamilyInvitationDto (this is a workaround)
    // In a proper implementation, this method should return FamilyDto instead
    final invitationDto = FamilyInvitationDto(
      id: inviteCode,
      familyId: familyDto.id,
      email: '',
      role: 'member',
      invitedBy: '',
      createdBy: '',
      status: 'accepted',
      inviteCode: inviteCode,
      expiresAt: DateTime.now().add(const Duration(days: 7)),
      acceptedAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      invitedByUser: const InvitedByUser(id: '', name: 'Unknown', email: ''),
    );

    AppLogger.debug(
      '[FamilyRemoteDataSource] Invitation accepted successfully: ${invitationDto.id}',
    );
    return invitationDto;
  }

  // ========================================
  // MEMBER OPERATIONS - REFACTORED
  // ========================================

  @override
  Future<void> updateMemberRole({
    required String familyId,
    required String memberId,
    required String role,
  }) async {
    AppLogger.debug('[FamilyRemoteDataSource] updateMemberRole() called', {
      'familyId': familyId,
      'memberId': memberId,
      'role': role,
    });

    final request = UpdateMemberRoleRequest(role: role);
    final apiResponse = await _apiClient.updateMemberRole(memberId, request);
    apiResponse.unwrap();

    AppLogger.debug(
      '[FamilyRemoteDataSource] Member role updated successfully',
    );
  }

  @override
  Future<void> removeMember({
    required String familyId,
    required String memberId,
  }) async {
    AppLogger.debug('[FamilyRemoteDataSource] removeMember() called', {
      'familyId': familyId,
      'memberId': memberId,
    });

    final apiResponse = await _apiClient.removeFamilyMember(familyId, memberId);
    apiResponse.unwrap();

    AppLogger.debug(
      '[FamilyRemoteDataSource] Member successfully removed: $memberId',
    );
  }

  // ========================================
  // CHILD OPERATIONS - EXISTING IMPLEMENTATION
  // ========================================

  @override
  Future<ChildDto> updateChild({
    required String childId,
    String? name,
    int? age,
  }) async {
    AppLogger.debug('[FamilyRemoteDataSource] updateChild() called', {
      'childId': childId,
      'name': name ?? 'null',
      'age': age?.toString() ?? 'null',
    });

    final request = UpdateChildRequest(name: name, age: age);
    final apiResponse = await _apiClient.updateChild(childId, request);
    final response = apiResponse.unwrap();

    AppLogger.debug(
      '[FamilyRemoteDataSource] updateChild API response data: $response',
    );

    AppLogger.debug(
      '[FamilyRemoteDataSource] Child successfully updated: ${response.id}',
    );

    return response;
  }

  @override
  Future<DeleteResponseDto> deleteChild({required String childId}) async {
    AppLogger.debug(
      '[FamilyRemoteDataSource] deleteChild() called for childId: $childId',
    );

    final apiResponse = await _apiClient.deleteChild(childId);
    final deleteResponse = apiResponse.unwrap();

    AppLogger.debug(
      '[FamilyRemoteDataSource] Child successfully deleted: $childId',
    );

    return deleteResponse;
  }

  // ========================================
  // VEHICLE OPERATIONS - EXISTING IMPLEMENTATION
  // ========================================

  @override
  Future<VehicleDto> updateVehicle({
    required String vehicleId,
    String? name,
    int? capacity,
    String? description,
  }) async {
    AppLogger.debug('[FamilyRemoteDataSource] updateVehicle() called', {
      'vehicleId': vehicleId,
      'name': name ?? 'null',
      'capacity': capacity?.toString() ?? 'null',
      'description': description ?? 'null',
    });

    final request = UpdateVehicleRequest(
      name: name,
      capacity: capacity,
      description: description,
    );

    final apiResponse = await _apiClient.updateVehicle(vehicleId, request);
    final response = apiResponse.unwrap();

    AppLogger.debug(
      '[FamilyRemoteDataSource] Vehicle successfully updated: ${response.id}',
    );
    return response;
  }

  @override
  Future<DeleteResponseDto> deleteVehicle({required String vehicleId}) async {
    AppLogger.debug(
      '[FamilyRemoteDataSource] deleteVehicle() called for vehicleId: $vehicleId',
    );

    final apiResponse = await _apiClient.deleteVehicle(vehicleId);
    final deleteResponse = apiResponse.unwrap();

    AppLogger.debug(
      '[FamilyRemoteDataSource] Vehicle successfully deleted: $vehicleId',
    );

    return deleteResponse;
  }

  // ========================================
  // UNUSED INTERFACE METHODS - CLEANUP
  // ========================================

  @override
  Future<invitation.Invitation> joinWithCode({
    required String code,
    String? role,
  }) async {
    throw UnimplementedError(
      'joinWithCode not yet implemented - use joinFamily instead',
    );
  }

  @override
  Future<FamilyInvitationDto> declineInvitation({
    required String invitationId,
    String? reason,
  }) async {
    throw UnimplementedError('declineInvitation not yet implemented');
  }

  @override
  Future<List<InvitationCode>> generateInvitationCodes({
    required String entityId,
    required InvitationType type,
    required int count,
    int? validDays,
    List<String>? allowedRoles,
  }) async {
    throw UnimplementedError('generateInvitationCodes not yet implemented');
  }

  @override
  Future<InvitationStats> getInvitationStats() async {
    throw UnimplementedError('getInvitationStats not yet implemented');
  }
}
