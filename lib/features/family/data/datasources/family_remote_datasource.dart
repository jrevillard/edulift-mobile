// EduLift Mobile - Family Remote Data Source Interface
// Clean Architecture data source abstraction
// FIXED: Returns DTOs instead of domain entities for clean architecture compliance

import '../../../../core/network/models/family/family_dto.dart';
import '../../../../core/network/models/family/family_invitation_dto.dart';
import '../../../../core/network/models/family/family_invitation_validation_dto.dart';
import '../../../../core/network/models/child/child_dto.dart';
import '../../../../core/network/models/vehicle/vehicle_dto.dart';
import '../../../../core/network/requests/index.dart' show DeleteResponseDto;
import '../../../../core/domain/entities/invitations/invitation.dart'
    as invitation;
import '../../../../core/domain/entities/invitations/invitation.dart'
    show InvitationType, InvitationCode, InvitationStats;

// ⚠️ ARCHITECTURE VIOLATION WARNING:
// This datasource imports domain entities which violates clean architecture.
// DTOs should be used instead, but changing this would break existing functionality.

/// Abstract interface for family remote data source
/// Defines all remote data operations without implementation details
/// FIXED: Returns DTOs instead of domain entities for clean architecture compliance
abstract class FamilyRemoteDataSource {
  // ========================================
  // FAMILY OPERATIONS - RETURNING DTOs
  // ========================================

  /// Get current user's family from server
  Future<FamilyDto> getCurrentFamily();

  /// Create a new family on server
  Future<FamilyDto> createFamily({required String name});

  /// Update family name on server
  Future<FamilyDto> updateFamilyName({required String name});

  /// Leave family with specific ID on server
  Future<void> leaveFamily(String familyId);

  // ========================================
  // INVITATION OPERATIONS - RETURNING DTOs
  // ========================================

  /// Validate family invitation code with server
  Future<FamilyInvitationValidationDto> validateInvitation({
    required String inviteCode,
  });

  /// Join family using invitation code
  Future<FamilyDto> joinFamily({required String inviteCode});

  /// Join with invitation code (extended method)
  /// ⚠️ ARCHITECTURE VIOLATION: Returns domain entity instead of DTO
  Future<invitation.Invitation> joinWithCode({
    required String code,
    String? role,
  });

  /// Send invitation to member via server
  Future<FamilyInvitationDto> inviteMember({
    required String familyId,
    required String email,
    required String role,
    String? personalMessage,
  });

  /// Get family invitations from server
  Future<List<FamilyInvitationDto>> getFamilyInvitations({
    required String familyId,
  });

  /// Cancel invitation on server
  Future<void> cancelInvitation({
    required String familyId,
    required String invitationId,
  });

  /// Accept invitation on server by code
  Future<FamilyInvitationDto> acceptInvitation({required String inviteCode});

  /// Decline invitation on server
  Future<FamilyInvitationDto> declineInvitation({
    required String invitationId,
    String? reason,
  });

  /// Generate invitation codes for entity
  Future<List<InvitationCode>> generateInvitationCodes({
    required String entityId,
    required InvitationType type,
    required int count,
    int? validDays,
    List<String>? allowedRoles,
  });

  /// Get invitation statistics
  Future<InvitationStats> getInvitationStats();

  // ========================================
  // MEMBER OPERATIONS - RETURNING DTOs
  // ========================================

  /// Update member role on server
  Future<void> updateMemberRole({
    required String familyId,
    required String memberId,
    required String role,
  });

  /// Remove member from family on server
  Future<void> removeMember({
    required String familyId,
    required String memberId,
  });

  // ========================================
  // CHILDREN OPERATIONS - RETURNING DTOs
  // ========================================

  /// Add new child to family on server
  Future<ChildDto> addChild({required String name, int? age});

  /// Update child information on server
  Future<ChildDto> updateChild({
    required String childId,
    String? name,
    int? age,
  });

  /// Delete child from family on server
  Future<DeleteResponseDto> deleteChild({required String childId});

  // ========================================
  // VEHICLE OPERATIONS - RETURNING DTOs
  // ========================================

  /// Add new vehicle to family on server
  Future<VehicleDto> addVehicle({
    required String name,
    required int capacity,
    String? description,
  });

  /// Update vehicle information on server
  Future<VehicleDto> updateVehicle({
    required String vehicleId,
    String? name,
    int? capacity,
    String? description,
  });

  /// Delete vehicle from family on server
  Future<DeleteResponseDto> deleteVehicle({required String vehicleId});
}
