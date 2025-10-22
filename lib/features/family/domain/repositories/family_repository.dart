// EduLift Mobile - Family Repository Interface
// SPARC-Driven Development with Neural Coordination
// Agent: flutter-architect-lead

import '../../../../core/utils/result.dart';
// REMOVED: import '../failures/family_failure.dart' - reverted for compilation
import '../../../../core/errors/failures.dart';
// TODO: Migrate all methods to FamilyFailure for Clean Architecture
import 'package:edulift/core/domain/entities/family.dart';
import '../requests/child_requests.dart';

/// Family repository interface following Clean Architecture principles
/// Defines all family-related operations without implementation details
abstract class FamilyRepository {
  // ========================================
  // FAMILY OPERATIONS
  // ========================================

  /// Get current user's family
  Future<Result<Family?, ApiFailure>> getCurrentFamily();

  /// Get current user's family (alias for compatibility)
  Future<Result<Family?, ApiFailure>> getFamily() => getCurrentFamily();

  /// Create a new family
  Future<Result<Family, ApiFailure>> createFamily({required String name});

  /// Update family name
  Future<Result<Family, ApiFailure>> updateFamilyName({
    required String familyId,
    required String name,
  });

  /// Leave current family
  Future<Result<void, ApiFailure>> leaveFamily({required String familyId});

  // ========================================
  // INVITATION OPERATIONS
  // ========================================

  /// Validate family invitation code
  Future<Result<FamilyInvitationValidation, ApiFailure>> validateInvitation({
    required String inviteCode,
  });

  /// Join family using invitation code
  Future<Result<Family, ApiFailure>> joinFamily({required String inviteCode});

  /// Invite member to family
  Future<Result<FamilyInvitation, ApiFailure>> inviteMember({
    required String familyId,
    required String email,
    required String role,
    String? personalMessage,
  });

  /// Get pending invitations
  Future<Result<List<FamilyInvitation>, ApiFailure>> getPendingInvitations({
    required String familyId,
  });

  /// Cancel invitation
  Future<Result<void, ApiFailure>> cancelInvitation({
    required String familyId,
    required String invitationId,
  });

  // ========================================
  // MEMBER OPERATIONS
  // ========================================

  /// Update member role
  Future<Result<FamilyMember, ApiFailure>> updateMemberRole({
    required String familyId,
    required String memberId,
    required String role,
  });

  /// Remove member from family
  Future<Result<void, ApiFailure>> removeMember({
    required String familyId,
    required String memberId,
  });

  // ========================================
  // CHILDREN OPERATIONS (ENHANCED)
  // ========================================

  /// Add new child to family (from request)
  Future<Result<Child, ApiFailure>> addChildFromRequest(
    String familyId,
    CreateChildRequest request,
  );

  /// Update child information (from request)
  Future<Result<Child, ApiFailure>> updateChildFromRequest(
    String familyId,
    String childId,
    UpdateChildRequest request,
  );

  /// Delete child from family
  Future<Result<void, ApiFailure>> deleteChild({
    required String familyId,
    required String childId,
  });

  // ========================================
  // VEHICLE OPERATIONS (ENHANCED)
  // ========================================

  /// Add new vehicle to family
  Future<Result<Vehicle, ApiFailure>> addVehicle({
    required String name,
    required int capacity,
    String? description,
  });

  /// Update vehicle information
  Future<Result<Vehicle, ApiFailure>> updateVehicle({
    required String vehicleId,
    String? name,
    int? capacity,
    String? description,
  });

  /// Delete vehicle from family
  Future<Result<void, ApiFailure>> deleteVehicle({required String vehicleId});
}

// GroupMembership entity removed - using Map<String, dynamic> instead
// Remove duplicate definition to avoid conflicts

// VehicleSchedule entity is now imported from ../entities/vehicle_schedule.dart
// to avoid type conflicts between repository and entity definitions
