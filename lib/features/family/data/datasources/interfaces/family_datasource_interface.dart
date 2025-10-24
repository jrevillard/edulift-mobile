// EduLift Mobile - Family Data Source Interface
// Abstract interface for all family data source implementations

// Entity imports - direct paths instead of index.dart
import 'package:edulift/core/domain/entities/family.dart';

/// Base interface for all family data sources
/// Ensures consistent API across remote and local implementations
abstract class IFamilyDataSource {
  // ========================================
  // FAMILY OPERATIONS
  // ========================================

  /// Get current user's family
  Future<Family> getCurrentFamily();

  /// Create a new family
  Future<Family> createFamily({required String name});

  /// Update family name
  Future<Family> updateFamilyName({required String name});

  /// Leave family with specific ID
  Future<void> leaveFamily(String familyId);

  // ========================================
  // CHILDREN OPERATIONS
  // ========================================

  /// Get all family children
  Future<List<Child>> getFamilyChildren();

  /// Add new child
  Future<Child> addChild({required String name, int? age});

  /// Update child information
  Future<Child> updateChild({required String childId, String? name, int? age});

  /// Delete child
  Future<void> deleteChild({required String childId});

  // ========================================
  // VEHICLE OPERATIONS
  // ========================================

  /// Get all family vehicles
  Future<List<Vehicle>> getFamilyVehicles();

  /// Add new vehicle
  Future<Vehicle> addVehicle({
    required String name,
    required int capacity,
    String? description,
  });

  /// Update vehicle information
  Future<Vehicle> updateVehicle({
    required String vehicleId,
    String? name,
    int? capacity,
    String? description,
  });

  /// Delete vehicle
  Future<void> deleteVehicle({required String vehicleId});
}

/// Interface for remote data source capabilities
abstract class IFamilyRemoteDataSource extends IFamilyDataSource {
  // ========================================
  // INVITATION OPERATIONS (Remote Only)
  // ========================================

  /// Validate family invitation code
  Future<FamilyInvitationValidation> validateInvitation({
    required String inviteCode,
  });

  /// Join family using invitation code
  Future<Family> joinFamily({required String inviteCode});

  /// Generate new invite code
  Future<String> generateInviteCode();

  /// Invite member to family
  Future<FamilyInvitation> inviteMember({
    required String email,
    required String role,
    String? personalMessage,
  });

  /// Get pending invitations
  Future<List<FamilyInvitation>> getPendingInvitations();

  /// Cancel invitation
  Future<void> cancelInvitation({required String invitationId});

  // ========================================
  // MEMBER OPERATIONS (Remote Only)
  // ========================================

  /// Update member role
  Future<FamilyMember> updateMemberRole({
    required String memberId,
    required String role,
  });

  /// Remove member from family
  Future<void> removeMember({required String memberId});
}

/// Interface for local data source capabilities
abstract class IFamilyLocalDataSource extends IFamilyDataSource {
  // ========================================
  // CACHING OPERATIONS (Local Only)
  // ========================================

  /// Cache family data
  Future<void> cacheFamily(Family family);

  /// Cache child data
  Future<void> cacheChild(Child child);

  /// Cache multiple children
  Future<void> cacheChildren(List<Child> children);

  /// Cache vehicle data
  Future<void> cacheVehicle(Vehicle vehicle);

  /// Cache multiple vehicles
  Future<void> cacheVehicles(List<Vehicle> vehicles);

  /// Clear all cached data
  Future<void> clearCache();

  /// Clear expired cache entries
  Future<void> clearExpiredCache();
}
