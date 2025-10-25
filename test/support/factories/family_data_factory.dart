// EduLift - Family Data Factory
// Generates realistic family-related test data with international names

import 'package:edulift/core/domain/entities/family.dart';

import 'test_data_factory.dart';

/// Factory for generating realistic family test data
class FamilyDataFactory {
  static int _memberCounter = 0;
  static int _childCounter = 0;
  static int _vehicleCounter = 0;
  static int _invitationCounter = 0;

  /// Create a realistic family member with international name
  static FamilyMember createRealisticMember({
    int? index,
    String? familyId,
    FamilyRole? role,
  }) {
    final i = index ?? _memberCounter++;
    final memberRole = role ?? (i == 0 ? FamilyRole.admin : FamilyRole.member);

    return FamilyMember(
      id: 'member-${i + 1}',
      familyId: familyId ?? 'family-1',
      userId: 'user-${i + 1}',
      role: memberRole,
      status: 'ACTIVE',
      joinedAt: TestDataFactory.randomPastDate(),
      userName: TestDataFactory.randomName(),
      userEmail: TestDataFactory.randomEmail(),
    );
  }

  /// Create a realistic child with international name
  static Child createRealisticChild({int? index, String? familyId}) {
    final i = index ?? _childCounter++;
    final now = DateTime.now();

    return Child(
      id: 'child-${i + 1}',
      name: TestDataFactory.randomFirstName(),
      age: TestDataFactory.randomInt(5, 18),
      familyId: familyId ?? 'family-1',
      createdAt: TestDataFactory.randomPastDate(),
      updatedAt: now,
    );
  }

  /// Create a realistic vehicle
  static Vehicle createRealisticVehicle({int? index, String? familyId}) {
    final i = index ?? _vehicleCounter++;
    final brand = TestDataFactory.randomVehicleBrand();
    final model = TestDataFactory.randomVehicleModel();
    final color = TestDataFactory.randomColor();
    final plate = TestDataFactory.randomLicensePlate();
    final now = DateTime.now();

    return Vehicle(
      id: 'vehicle-${i + 1}',
      name: '$brand $model',
      familyId: familyId ?? 'family-1',
      capacity: TestDataFactory.randomSeats(),
      description: '$color - $plate',
      createdAt: TestDataFactory.randomPastDate(),
      updatedAt: now,
    );
  }

  /// Create a realistic family invitation
  static FamilyInvitation createRealisticInvitation({
    int? index,
    String? familyId,
    InvitationStatus? status,
  }) {
    final i = index ?? _invitationCounter++;
    final inviteStatus = status ?? InvitationStatus.pending;

    return FamilyInvitation(
      id: 'invitation-${i + 1}',
      familyId: familyId ?? 'family-1',
      email: TestDataFactory.randomEmail(),
      role: 'MEMBER',
      invitedBy: 'user-1',
      invitedByName: TestDataFactory.randomName(),
      createdBy: 'user-1',
      inviteCode: 'INV-${i + 1000}',
      status: inviteStatus,
      createdAt: TestDataFactory.randomPastDate(maxDaysAgo: 30),
      expiresAt: TestDataFactory.randomFutureDate(maxDaysAhead: 7),
      updatedAt: DateTime.now(),
    );
  }

  /// Create a large list of family members for scroll testing
  static List<FamilyMember> createLargeMemberList({
    int count = 20,
    String? familyId,
  }) {
    return List.generate(
      count,
      (i) => createRealisticMember(
        index: i,
        familyId: familyId,
        role: i < 2 ? FamilyRole.admin : FamilyRole.member,
      ),
    );
  }

  /// Create a large list of children for scroll testing
  static List<Child> createLargeChildList({int count = 15, String? familyId}) {
    return List.generate(
      count,
      (i) => createRealisticChild(index: i, familyId: familyId),
    );
  }

  /// Create a large list of vehicles for scroll testing
  static List<Vehicle> createLargeVehicleList({
    int count = 10,
    String? familyId,
  }) {
    return List.generate(
      count,
      (i) => createRealisticVehicle(index: i, familyId: familyId),
    );
  }

  /// Create a large list of invitations
  static List<FamilyInvitation> createLargeInvitationList({
    int count = 12,
    String? familyId,
  }) {
    return List.generate(
      count,
      (i) => createRealisticInvitation(
        index: i,
        familyId: familyId,
        status: i % 3 == 0
            ? InvitationStatus.pending
            : i % 3 == 1
                ? InvitationStatus.accepted
                : InvitationStatus.declined,
      ),
    );
  }

  // Edge cases

  /// Create member with very long name
  static FamilyMember createMemberWithLongName({String? familyId}) {
    return FamilyMember(
      id: 'member-long-name',
      familyId: familyId ?? 'family-1',
      userId: 'user-long-name',
      role: FamilyRole.member,
      status: 'ACTIVE',
      joinedAt: DateTime.now(),
      userName: TestDataFactory.veryLongName(),
      userEmail: TestDataFactory.randomEmail(),
    );
  }

  /// Create member with maximum special characters
  static FamilyMember createMemberWithSpecialChars({String? familyId}) {
    return FamilyMember(
      id: 'member-special-chars',
      familyId: familyId ?? 'family-1',
      userId: 'user-special-chars',
      role: FamilyRole.member,
      status: 'ACTIVE',
      joinedAt: DateTime.now(),
      userName: TestDataFactory.nameWithMaxSpecialChars(),
      userEmail: TestDataFactory.complexEmail(),
    );
  }

  /// Create member with empty name
  static FamilyMember createMemberWithEmptyName({String? familyId}) {
    return FamilyMember(
      id: 'member-empty-name',
      familyId: familyId ?? 'family-1',
      userId: 'user-empty-name',
      role: FamilyRole.member,
      status: 'ACTIVE',
      joinedAt: DateTime.now(),
      userName: '',
      userEmail: 'empty@example.com',
    );
  }

  /// Create child with very long name
  static Child createChildWithLongName({String? familyId}) {
    return Child(
      id: 'child-long-name',
      name: TestDataFactory.veryLongName(),
      age: 10,
      familyId: familyId ?? 'family-1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create child with special characters
  static Child createChildWithSpecialChars({String? familyId}) {
    return Child(
      id: 'child-special-chars',
      name: TestDataFactory.nameWithMaxSpecialChars(),
      age: 8,
      familyId: familyId ?? 'family-1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create child with minimum age
  static Child createChildWithMinAge({String? familyId}) {
    return Child(
      id: 'child-min-age',
      name: TestDataFactory.randomFirstName(),
      age: 3,
      familyId: familyId ?? 'family-1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create child with maximum age
  static Child createChildWithMaxAge({String? familyId}) {
    return Child(
      id: 'child-max-age',
      name: TestDataFactory.randomFirstName(),
      age: 18,
      familyId: familyId ?? 'family-1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create child without age
  static Child createChildWithoutAge({String? familyId}) {
    return Child(
      id: 'child-no-age',
      name: TestDataFactory.randomFirstName(),
      familyId: familyId ?? 'family-1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create vehicle with very long name
  static Vehicle createVehicleWithLongName({String? familyId}) {
    return Vehicle(
      id: 'vehicle-long-name',
      name: 'Mercedes-Benz GLE 350 d 4MATIC Coupé AMG Line Premium Plus',
      familyId: familyId ?? 'family-1',
      capacity: 5,
      description: 'Very long vehicle name with detailed specifications',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create vehicle with minimum capacity
  static Vehicle createVehicleWithMinCapacity({String? familyId}) {
    return Vehicle(
      id: 'vehicle-min-capacity',
      name: 'Smart ForTwo',
      familyId: familyId ?? 'family-1',
      capacity: 2,
      description: 'Minimum capacity vehicle',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create vehicle with maximum capacity
  static Vehicle createVehicleWithMaxCapacity({String? familyId}) {
    return Vehicle(
      id: 'vehicle-max-capacity',
      name: 'Mercedes-Benz Sprinter',
      familyId: familyId ?? 'family-1',
      capacity: 9,
      description: 'Maximum capacity vehicle',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create expired invitation
  static FamilyInvitation createExpiredInvitation({String? familyId}) {
    return FamilyInvitation(
      id: 'invitation-expired',
      familyId: familyId ?? 'family-1',
      email: TestDataFactory.randomEmail(),
      role: 'MEMBER',
      invitedBy: 'user-1',
      invitedByName: TestDataFactory.randomName(),
      createdBy: 'user-1',
      inviteCode: 'EXPIRED-TOKEN',
      status: InvitationStatus.expired,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
    );
  }

  /// Create accepted invitation
  static FamilyInvitation createAcceptedInvitation({String? familyId}) {
    return FamilyInvitation(
      id: 'invitation-accepted',
      familyId: familyId ?? 'family-1',
      email: TestDataFactory.randomEmail(),
      role: 'MEMBER',
      invitedBy: 'user-1',
      invitedByName: TestDataFactory.randomName(),
      createdBy: 'user-1',
      inviteCode: 'ACCEPTED-TOKEN',
      status: InvitationStatus.accepted,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      expiresAt: DateTime.now().add(const Duration(days: 2)),
      updatedAt: DateTime.now(),
      acceptedAt: DateTime.now().subtract(const Duration(days: 1)),
    );
  }

  /// Create declined invitation
  static FamilyInvitation createDeclinedInvitation({String? familyId}) {
    return FamilyInvitation(
      id: 'invitation-declined',
      familyId: familyId ?? 'family-1',
      email: TestDataFactory.randomEmail(),
      role: 'MEMBER',
      invitedBy: 'user-1',
      invitedByName: TestDataFactory.randomName(),
      createdBy: 'user-1',
      inviteCode: 'DECLINED-TOKEN',
      status: InvitationStatus.declined,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      expiresAt: DateTime.now().add(const Duration(days: 4)),
      updatedAt: DateTime.now(),
    );
  }

  /// Reset all counters for test isolation
  static void resetCounters() {
    _memberCounter = 0;
    _childCounter = 0;
    _vehicleCounter = 0;
    _invitationCounter = 0;
  }
}
