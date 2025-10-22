// EduLift Mobile - Family Local Data Source (CLEANED)
// Clean Architecture local storage abstraction - STUBS REMOVED

import 'dart:async';

import 'package:edulift/core/domain/entities/family.dart';

/// Abstract interface for family local data source - ESSENTIAL METHODS ONLY
abstract class FamilyLocalDataSource {
  // CORE FAMILY OPERATIONS
  Future<Family?> getCurrentFamily();
  Future<void> clearCache();

  // ESSENTIAL INVITATION OPERATIONS
  Future<List<FamilyInvitation>> getInvitations();
  Future<List<Map<String, dynamic>>> getInvitationHistory({
    String? type,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
  });
  Future<Map<String, dynamic>?> getInvitation(String invitationId);
  Future<void> cacheInvitations(List<FamilyInvitation> invitations);

  /// Cache a core invitation
  Future<void> cacheInvitation(Invitation invitation);

  /// Cache a family invitation
  Future<void> cacheFamilyInvitation(FamilyInvitation invitation);

  Future<void> cacheInvitationCode(
    String code,
    Map<String, dynamic> invitation,
  );

  // ESSENTIAL CACHE OPERATIONS
  Future<void> cacheCurrentFamily(Family family);
  Future<void> clearCurrentFamily();
  Future<void> cacheChild(Child child);
  Future<void> cacheVehicle(Vehicle vehicle);
  Future<void> removeChild(String childId);
  Future<void> removeVehicle(String vehicleId);
  Future<void> clearExpiredCache();
}

// Implementation is in PersistentLocalDataSource - no duplicate needed
