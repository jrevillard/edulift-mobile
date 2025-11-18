import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulift/core/domain/entities/family.dart' as entities;
import 'package:edulift/core/domain/entities/user.dart';
import 'package:edulift/core/services/providers/auth_provider.dart';
import 'package:edulift/features/family/presentation/providers/family_provider.dart'
    as family_providers;
import 'package:edulift/core/di/providers/repository_providers.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/features/family/domain/repositories/family_repository.dart';
import 'package:edulift/features/family/domain/requests/child_requests.dart';

/// Mock FamilyRepository that prevents all network calls
class MockFamilyRepository implements FamilyRepository {
  @override
  Future<Result<entities.Family?, ApiFailure>> getCurrentFamily() async {
    // Return null to prevent network calls
    return const Result.ok(null);
  }

  @override
  Future<Result<entities.Family?, ApiFailure>> getFamily() async {
    // Return null to prevent network calls
    return const Result.ok(null);
  }

  @override
  Future<Result<entities.Family, ApiFailure>> createFamily({
    required String name,
  }) async {
    throw UnimplementedError('Mock not needed for tests');
  }

  @override
  Future<Result<entities.Family, ApiFailure>> updateFamilyName({
    required String familyId,
    required String name,
  }) async {
    throw UnimplementedError('Mock not needed for tests');
  }

  @override
  Future<Result<entities.Vehicle, ApiFailure>> addVehicle({
    required String name,
    required int capacity,
    String? description,
  }) async {
    throw UnimplementedError('Mock not needed for tests');
  }

  @override
  Future<Result<entities.Vehicle, ApiFailure>> updateVehicle({
    required String vehicleId,
    String? name,
    int? capacity,
    String? description,
  }) async {
    throw UnimplementedError('Mock not needed for tests');
  }

  @override
  Future<Result<void, ApiFailure>> deleteVehicle({
    required String vehicleId,
  }) async {
    return const Result.ok(null);
  }

  @override
  Future<Result<void, ApiFailure>> removeMember({
    required String familyId,
    required String memberId,
  }) async {
    return const Result.ok(null);
  }

  @override
  Future<Result<entities.FamilyMember, ApiFailure>> updateMemberRole({
    required String familyId,
    required String memberId,
    required String role,
  }) async {
    throw UnimplementedError('Mock not needed for tests');
  }

  @override
  Future<Result<void, ApiFailure>> cancelInvitation({
    required String familyId,
    required String invitationId,
  }) async {
    return const Result.ok(null);
  }

  @override
  Future<Result<entities.Child, ApiFailure>> addChildFromRequest(
    String familyId,
    CreateChildRequest request,
  ) async {
    throw UnimplementedError('Mock not needed for tests');
  }

  @override
  Future<Result<void, ApiFailure>> deleteChild({
    required String familyId,
    required String childId,
  }) async {
    return const Result.ok(null);
  }

  @override
  Future<Result<List<entities.FamilyInvitation>, ApiFailure>>
  getPendingInvitations({required String familyId}) async {
    return const Result.ok([]);
  }

  @override
  Future<Result<entities.FamilyInvitation, ApiFailure>> inviteMember({
    required String familyId,
    required String email,
    required String role,
    String? personalMessage,
  }) async {
    throw UnimplementedError('Mock not needed for tests');
  }

  @override
  Future<Result<entities.Family, ApiFailure>> joinFamily({
    required String inviteCode,
  }) async {
    throw UnimplementedError('Mock not needed for tests');
  }

  @override
  Future<Result<void, ApiFailure>> leaveFamily({
    required String familyId,
  }) async {
    throw UnimplementedError('Mock not needed for tests');
  }

  @override
  Future<Result<entities.FamilyInvitationValidation, ApiFailure>>
  validateInvitation({required String inviteCode}) async {
    throw UnimplementedError('Mock not needed for tests');
  }

  @override
  Future<Result<entities.Child, ApiFailure>> updateChildFromRequest(
    String familyId,
    String childId,
    UpdateChildRequest request,
  ) async {
    throw UnimplementedError('Mock not needed for tests');
  }
}

/// Test providers configuration to avoid network calls
class TestProvidersSetup {
  static List<Override> createMockOverrides(User mockUser) {
    final mockFamilyRepository = MockFamilyRepository();

    return [
      currentUserProvider.overrideWithValue(mockUser),
      // Mock the underlying repository to prevent network calls at the source
      familyRepositoryProvider.overrideWithValue(mockFamilyRepository),
      // Override related providers to use mock data
      family_providers.familyChildrenProvider.overrideWith((ref) => const []),
      family_providers.familyVehiclesProvider.overrideWith((ref) => const []),
      family_providers.familyDataProvider.overrideWith((ref) => null),
    ];
  }

  /// Create a mock user for tests
  static User createMockUser({
    String id = 'test-user-id',
    String email = 'test@example.com',
    String name = 'Test User',
    String? timezone = 'America/New_York',
  }) {
    return User(
      id: id,
      email: email,
      name: name,
      timezone: timezone,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create a mock family for tests
  static entities.Family createMockFamily({
    String id = 'test-family-id',
    String name = 'Test Family',
  }) {
    return entities.Family(
      id: id,
      name: name,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      members: const [],
      children: const [],
      vehicles: const [],
      description: null,
    );
  }
}

/// Mock FamilyNotifier that extends StateNotifier<FamilyState> directly
/// This prevents all network calls while maintaining the same interface
class MockFamilyStateNotifier
    extends StateNotifier<family_providers.FamilyState> {
  MockFamilyStateNotifier() : super(const family_providers.FamilyState());

  // Override all methods to prevent network calls
  Future<void> loadFamily() async {
    // Mock implementation - no network calls
    // Keep empty state to prevent any further network attempts
  }

  Future<void> addChild(dynamic request) async {}

  Future<void> updateChild(String childId, dynamic request) async {}

  Future<void> removeChild(String childId) async {}

  Future<void> loadVehicles() async {}

  Future<void> addVehicle({
    required String name,
    required int capacity,
    String? description,
  }) async {}

  Future<void> updateVehicle({
    required String vehicleId,
    String? name,
    int? capacity,
    String? description,
  }) async {}

  Future<void> deleteVehicle(String vehicleId) async {}

  Future<void> selectVehicle(String vehicleId) async {}

  void clearSelectedVehicle() {}

  Future<void> leaveFamily() async {}

  Future<void> updateFamilyName(String newName) async {}

  Future<void> updateMemberRole({
    required String memberId,
    required entities.FamilyRole role,
  }) async {}

  Future<void> removeMember({
    required String familyId,
    required String memberId,
  }) async {}

  Future<void> sendFamilyInvitationToMember({
    required String familyId,
    required String email,
    required String role,
    String? personalMessage,
  }) async {}

  Future<List<entities.FamilyInvitation>> getPendingInvitations() async {
    return [];
  }

  Future<void> cancelInvitation(String invitationId) async {}

  void clearError() {}

  entities.Child? getChild(String childId) => null;
}
