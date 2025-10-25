// EduLift - Group Data Factory
// Generates realistic group-related test data

import 'package:edulift/core/domain/entities/groups/group.dart';
import 'package:edulift/core/domain/entities/groups/group_family.dart';

import 'test_data_factory.dart';

/// Factory for generating realistic group test data
class GroupDataFactory {
  static int _groupCounter = 0;
  static int _memberCounter = 0;
  static int _familyCounter = 0;

  /// Create a realistic group with international name
  static Group createRealisticGroup({
    int? index,
    String? familyId,
    GroupStatus? status,
    int? familyCount,
    int? scheduleCount,
  }) {
    final i = index ?? _groupCounter++;
    final now = DateTime.now();

    return Group(
      id: 'group-${i + 1}',
      name: _generateGroupName(i),
      familyId: familyId ?? 'family-1',
      description: _generateGroupDescription(i),
      createdAt: TestDataFactory.randomPastDate(),
      updatedAt: now,
      settings: createRealisticGroupSettings(index: i),
      status: status ?? GroupStatus.active,
      memberCount: TestDataFactory.randomInt(3, 25),
      maxMembers: i % 3 == 0 ? null : TestDataFactory.randomInt(10, 30),
      scheduleConfig: createRealisticScheduleConfig(index: i),
      userRole: i == 0
          ? GroupMemberRole.owner
          : (i % 3 == 0 ? GroupMemberRole.admin : GroupMemberRole.member),
      familyCount: familyCount ?? TestDataFactory.randomInt(3, 8),
      scheduleCount: scheduleCount ?? TestDataFactory.randomInt(5, 20),
    );
  }

  /// Create realistic group settings
  static GroupSettings createRealisticGroupSettings({int? index}) {
    final i = index ?? 0;
    final colors = [
      '#2196F3',
      '#4CAF50',
      '#FF9800',
      '#9C27B0',
      '#F44336',
      '#00BCD4',
    ];

    return GroupSettings(
      allowAutoAssignment: i % 2 == 0,
      requireParentalApproval: i % 3 == 0,
      defaultPickupLocation: i % 2 == 0
          ? TestDataFactory.randomAddress()
          : null,
      defaultDropoffLocation: i % 2 == 1
          ? TestDataFactory.randomAddress()
          : null,
      groupColor: colors[i % colors.length],
      enableNotifications: i % 4 != 0,
      privacyLevel: i % 3 == 0
          ? GroupPrivacyLevel.coordinators
          : (i % 3 == 1 ? GroupPrivacyLevel.family : GroupPrivacyLevel.admins),
    );
  }

  /// Create realistic schedule configuration
  static GroupScheduleConfig createRealisticScheduleConfig({int? index}) {
    final i = index ?? 0;

    final activeDaysOptions = [
      [1, 2, 3, 4, 5], // Weekdays
      [1, 3, 5], // Mon, Wed, Fri
      [2, 4], // Tue, Thu
      [1, 2, 3, 4, 5, 6], // Weekdays + Saturday
      [1, 2, 3, 4, 5, 6, 7], // All week
    ];

    return GroupScheduleConfig(
      activeDays: activeDaysOptions[i % activeDaysOptions.length],
      defaultStartTime: i % 2 == 0 ? '08:00' : '08:30',
      defaultEndTime: i % 2 == 0 ? '17:00' : '18:00',
      timezone: 'Europe/Paris',
      advanceNoticeHours: i % 3 == 0 ? 12 : 24,
      allowSameDayScheduling: i % 4 == 0,
    );
  }

  /// Create a realistic group member
  static GroupMember createRealisticGroupMember({
    int? index,
    GroupMemberRole? role,
  }) {
    final i = index ?? _memberCounter++;

    return GroupMember(
      id: 'group-member-${i + 1}',
      name: TestDataFactory.randomName(),
      email: TestDataFactory.randomEmail(),
      role:
          role ??
          (i == 0
              ? GroupMemberRole.owner
              : (i % 3 == 0 ? GroupMemberRole.admin : GroupMemberRole.member)),
      joinedAt: TestDataFactory.randomPastDate(maxDaysAgo: 180),
      status: i % 10 == 0
          ? GroupMemberStatus.suspended
          : GroupMemberStatus.active,
      permissions: _generatePermissions(role ?? GroupMemberRole.member),
    );
  }

  /// Create a realistic group family
  static GroupFamily createRealisticGroupFamily({
    int? index,
    GroupFamilyRole? role,
    bool? isPending,
  }) {
    final i = index ?? _familyCounter++;
    final familyRole =
        role ??
        (i == 0
            ? GroupFamilyRole.owner
            : (i % 3 == 0 ? GroupFamilyRole.admin : GroupFamilyRole.member));
    final pending = isPending ?? (i % 5 == 4);

    final admins = List.generate(
      TestDataFactory.randomInt(1, 3),
      (j) => FamilyAdmin(
        name: TestDataFactory.randomName(),
        email: TestDataFactory.randomEmail(),
      ),
    );

    return GroupFamily(
      id: 'family-${i + 1}',
      name: _generateFamilyName(i),
      role: pending ? GroupFamilyRole.pending : familyRole,
      isMyFamily: i == 0,
      canManage: i == 0 || (i % 3 == 0),
      admins: admins,
      status: pending ? 'PENDING' : null,
      inviteCode: pending ? 'INV-${i + 1000}' : null,
      invitationId: pending ? 'invitation-${i + 1}' : null,
      invitedAt: pending ? TestDataFactory.randomPastDate(maxDaysAgo: 7) : null,
      expiresAt: pending
          ? TestDataFactory.randomFutureDate(maxDaysAhead: 7)
          : null,
    );
  }

  /// Create a large list of groups for scroll testing
  static List<Group> createLargeGroupList({int count = 15, String? familyId}) {
    return List.generate(
      count,
      (i) => createRealisticGroup(index: i, familyId: familyId),
    );
  }

  /// Create a large list of group members
  static List<GroupMember> createLargeGroupMemberList({int count = 20}) {
    return List.generate(count, (i) => createRealisticGroupMember(index: i));
  }

  /// Create a large list of group families
  static List<GroupFamily> createLargeGroupFamilyList({int count = 12}) {
    return List.generate(count, (i) => createRealisticGroupFamily(index: i));
  }

  // Edge cases

  /// Create group with very long name
  static Group createGroupWithLongName({String? familyId}) {
    return createRealisticGroup(familyId: familyId).copyWith(
      name:
          'Groupe de Covoiturage Scolaire pour les Enfants du Quartier Saint-Germain-des-Prés à Paris',
      description:
          'Un groupe de covoiturage très organisé pour les parents du quartier avec des règles strictes et des horaires bien définis pour assurer la sécurité et le confort de tous les enfants participants.',
    );
  }

  /// Create group with special characters
  static Group createGroupWithSpecialChars({String? familyId}) {
    return createRealisticGroup(familyId: familyId).copyWith(
      name: 'Covoiturage École Müller-O\'Brien & Søren',
      description:
          'Groupe international avec caractères spéciaux: é, è, ê, ñ, ö, ü, ø, å',
    );
  }

  /// Create group at maximum capacity
  static Group createGroupAtCapacity({String? familyId}) {
    return createRealisticGroup(
      familyId: familyId,
    ).copyWith(memberCount: 20, maxMembers: 20);
  }

  /// Create group with no capacity limit
  static Group createGroupWithNoLimit({String? familyId}) {
    return createRealisticGroup(familyId: familyId).copyWith(memberCount: 50);
  }

  /// Create paused group
  static Group createPausedGroup({String? familyId}) {
    return createRealisticGroup(
      familyId: familyId,
    ).copyWith(status: GroupStatus.paused);
  }

  /// Create archived group
  static Group createArchivedGroup({String? familyId}) {
    return createRealisticGroup(
      familyId: familyId,
    ).copyWith(status: GroupStatus.archived);
  }

  /// Create draft group
  static Group createDraftGroup({String? familyId}) {
    return createRealisticGroup(
      familyId: familyId,
    ).copyWith(status: GroupStatus.draft);
  }

  /// Create group member with long name
  static GroupMember createGroupMemberWithLongName() {
    return createRealisticGroupMember().copyWith(
      name: TestDataFactory.veryLongName(),
    );
  }

  /// Create group member with special characters
  static GroupMember createGroupMemberWithSpecialChars() {
    return createRealisticGroupMember().copyWith(
      name: TestDataFactory.nameWithMaxSpecialChars(),
      email: TestDataFactory.complexEmail(),
    );
  }

  /// Create suspended group member
  static GroupMember createSuspendedGroupMember() {
    return createRealisticGroupMember().copyWith(
      status: GroupMemberStatus.suspended,
    );
  }

  /// Create group family with pending invitation
  static GroupFamily createPendingGroupFamily() {
    return createRealisticGroupFamily(isPending: true);
  }

  /// Create expired group family invitation
  static GroupFamily createExpiredGroupFamily() {
    return createRealisticGroupFamily(
      isPending: true,
    ).copyWith(expiresAt: DateTime.now().subtract(const Duration(days: 1)));
  }

  /// Create group family with long name
  static GroupFamily createGroupFamilyWithLongName() {
    return createRealisticGroupFamily().copyWith(
      name: 'Famille De la Fontaine-Dupont-Martin-Lefèvre-Bernard',
    );
  }

  /// Reset all counters for test isolation
  static void resetCounters() {
    _groupCounter = 0;
    _memberCounter = 0;
    _familyCounter = 0;
  }

  // Private helper methods

  static String _generateGroupName(int index) {
    final prefixes = [
      'Covoiturage',
      'Transport',
      'École',
      'Groupe',
      'Carpool',
      'Transporte',
    ];

    final suffixes = [
      'du Matin',
      'du Soir',
      'Primaire',
      'Collège',
      'Lycée',
      'Quartier Nord',
      'Centre-Ville',
      'Saint-Germain',
      'de José García',
      'von Müller',
    ];

    final prefix = prefixes[index % prefixes.length];
    final suffix = suffixes[index % suffixes.length];

    return '$prefix $suffix';
  }

  static String _generateGroupDescription(int index) {
    final descriptions = [
      'Groupe de covoiturage pour le trajet école',
      'Organisation des transports scolaires du quartier',
      'Carpool group for morning school runs',
      'Transporte escolar compartido - José García',
      'Gruppe für Schulfahrten - Müller Familie',
      'Covoiturage partagé pour économies et écologie',
      'School carpool with rotating drivers',
      'Groupe familial pour trajets quotidiens',
    ];

    return descriptions[index % descriptions.length];
  }

  static String _generateFamilyName(int index) {
    final lastNames = [
      'Dupont',
      'Martin',
      'García',
      'Müller',
      'O\'Brien',
      'Søren',
      'van der Berg',
      'Kowalski',
      'Al-Hassan',
      'Li',
    ];

    return 'Famille ${lastNames[index % lastNames.length]}';
  }

  static List<GroupPermission> _generatePermissions(GroupMemberRole role) {
    switch (role) {
      case GroupMemberRole.owner:
        return GroupPermission.values;
      case GroupMemberRole.admin:
        return [
          GroupPermission.viewGroup,
          GroupPermission.viewMembers,
          GroupPermission.editGroup,
          GroupPermission.manageMembers,
          GroupPermission.removeMember,
          GroupPermission.generateInvitation,
          GroupPermission.manageSchedules,
        ];
      case GroupMemberRole.member:
        return [
          GroupPermission.viewGroup,
          GroupPermission.viewMembers,
          GroupPermission.leaveGroup,
        ];
    }
  }
}
