import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/domain/entities/family.dart';

void main() {
  group('FamilyMember Entity', () {
    late DateTime testJoinedAt;

    setUp(() {
      testJoinedAt = DateTime(2024, 1, 1, 10);
    });

    group('FamilyRole Enum', () {
      test('should have correct string values', () {
        // Act & Assert
        expect(FamilyRole.admin.value, equals('ADMIN'));
        expect(FamilyRole.member.value, equals('MEMBER'));
      });

      test('should convert from string correctly', () {
        // Act & Assert
        expect(FamilyRole.fromString('ADMIN'), equals(FamilyRole.admin));
        expect(FamilyRole.fromString('MEMBER'), equals(FamilyRole.member));
      });

      test('should handle case insensitive conversion', () {
        // Act & Assert
        expect(FamilyRole.fromString('admin'), equals(FamilyRole.admin));
        expect(FamilyRole.fromString('member'), equals(FamilyRole.member));
        expect(FamilyRole.fromString('Admin'), equals(FamilyRole.admin));
        expect(FamilyRole.fromString('Member'), equals(FamilyRole.member));
      });

      test('should throw ArgumentError for invalid role string', () {
        // Act & Assert
        expect(() => FamilyRole.fromString('INVALID'), throwsArgumentError);
        expect(() => FamilyRole.fromString(''), throwsArgumentError);
        expect(() => FamilyRole.fromString('USER'), throwsArgumentError);
      });

      test('should provide correct toString representation', () {
        // Act & Assert
        expect(FamilyRole.admin.toString(), equals('ADMIN'));
        expect(FamilyRole.member.toString(), equals('MEMBER'));
      });
    });

    group('Construction and Property Validation', () {
      test('should create family member with admin role', () {
        // Arrange & Act
        final member = FamilyMember(
          id: 'member-123',
          familyId: 'family-456',
          userId: 'user-789',
          role: FamilyRole.admin,
          status: 'ACTIVE',
          joinedAt: testJoinedAt,
        );

        // Assert
        expect(member.id, equals('member-123'));
        expect(member.familyId, equals('family-456'));
        expect(member.userId, equals('user-789'));
        expect(member.role, equals(FamilyRole.admin));
        expect(member.joinedAt, equals(testJoinedAt));
      });

      test('should create family member with member role', () {
        // Arrange & Act
        final member = FamilyMember(
          id: 'member-123',
          familyId: 'family-456',
          userId: 'user-789',
          role: FamilyRole.member,
          status: 'ACTIVE',
          joinedAt: testJoinedAt,
        );

        // Assert
        expect(member.role, equals(FamilyRole.member));
      });
    });

    group('Role Helper Methods', () {
      test('isAdmin should return true for admin role', () {
        // Arrange
        final adminMember = FamilyMember(
          id: 'member-123',
          familyId: 'family-456',
          userId: 'user-789',
          role: FamilyRole.admin,
          status: 'ACTIVE',
          joinedAt: testJoinedAt,
        );

        // Act & Assert
        expect(adminMember.isAdmin, isTrue);
        expect(adminMember.isMember, isFalse);
      });

      test('isMember should return true for member role', () {
        // Arrange
        final regularMember = FamilyMember(
          id: 'member-123',
          familyId: 'family-456',
          userId: 'user-789',
          role: FamilyRole.member,
          status: 'ACTIVE',
          joinedAt: testJoinedAt,
        );

        // Act & Assert
        expect(regularMember.isMember, isTrue);
        expect(regularMember.isAdmin, isFalse);
      });

      test('roleDisplayName should return correct display names', () {
        // Arrange
        final adminMember = FamilyMember(
          id: 'member-123',
          familyId: 'family-456',
          userId: 'user-789',
          role: FamilyRole.admin,
          status: 'ACTIVE',
          joinedAt: testJoinedAt,
        );

        final regularMember = FamilyMember(
          id: 'member-456',
          familyId: 'family-456',
          userId: 'user-789',
          role: FamilyRole.member,
          status: 'ACTIVE',
          joinedAt: testJoinedAt,
        );

        // Act & Assert
        expect(adminMember.roleDisplayName, equals('Administrator'));
        expect(regularMember.roleDisplayName, equals('Member'));
      });
    });

    group('Equality and Hash Code', () {
      late FamilyMember member1;
      late FamilyMember member2;

      setUp(() {
        member1 = FamilyMember(
          id: 'member-123',
          familyId: 'family-456',
          userId: 'user-789',
          role: FamilyRole.admin,
          status: 'ACTIVE',
          joinedAt: testJoinedAt,
        );

        member2 = FamilyMember(
          id: 'member-123',
          familyId: 'family-456',
          userId: 'user-789',
          role: FamilyRole.admin,
          status: 'ACTIVE',
          joinedAt: testJoinedAt,
        );
      });

      test('should be equal when all properties match', () {
        // Act & Assert
        expect(member1, equals(member2));
      });

      test('should not be equal when id differs', () {
        // Arrange
        final differentMember = member2.copyWith(id: 'different-id');

        // Act & Assert
        expect(member1, isNot(equals(differentMember)));
      });

      test('should not be equal when familyId differs', () {
        // Arrange
        final differentMember = member2.copyWith(familyId: 'different-family');

        // Act & Assert
        expect(member1, isNot(equals(differentMember)));
      });

      test('should not be equal when userId differs', () {
        // Arrange
        final differentMember = member2.copyWith(userId: 'different-user');

        // Act & Assert
        expect(member1, isNot(equals(differentMember)));
      });

      test('should not be equal when role differs', () {
        // Arrange
        final differentMember = member2.copyWith(role: FamilyRole.member);

        // Act & Assert
        expect(member1, isNot(equals(differentMember)));
      });

      test('should not be equal when joinedAt differs', () {
        // Arrange
        final differentDate = DateTime(2024, 2, 1, 10);
        final differentMember = member2.copyWith(joinedAt: differentDate);

        // Act & Assert
        expect(member1, isNot(equals(differentMember)));
      });

      test('should have same hash code when equal', () {
        // Act & Assert
        expect(member1.hashCode, equals(member2.hashCode));
      });
    });

    group('Copy With Method', () {
      late FamilyMember originalMember;

      setUp(() {
        originalMember = FamilyMember(
          id: 'member-123',
          familyId: 'family-456',
          userId: 'user-789',
          role: FamilyRole.admin,
          status: 'ACTIVE',
          joinedAt: testJoinedAt,
        );
      });

      test('should copy with new id', () {
        // Act
        final updatedMember = originalMember.copyWith(id: 'new-id');

        // Assert
        expect(updatedMember.id, equals('new-id'));
        expect(updatedMember.familyId, equals(originalMember.familyId));
        expect(updatedMember.userId, equals(originalMember.userId));
        expect(updatedMember.role, equals(originalMember.role));
        expect(updatedMember.joinedAt, equals(originalMember.joinedAt));
      });

      test('should copy with new familyId', () {
        // Act
        final updatedMember = originalMember.copyWith(familyId: 'new-family');

        // Assert
        expect(updatedMember.familyId, equals('new-family'));
        expect(updatedMember.id, equals(originalMember.id));
      });

      test('should copy with new userId', () {
        // Act
        final updatedMember = originalMember.copyWith(userId: 'new-user');

        // Assert
        expect(updatedMember.userId, equals('new-user'));
        expect(updatedMember.id, equals(originalMember.id));
      });

      test('should copy with new role', () {
        // Act
        final updatedMember = originalMember.copyWith(role: FamilyRole.member);

        // Assert
        expect(updatedMember.role, equals(FamilyRole.member));
        expect(updatedMember.isAdmin, isFalse);
        expect(updatedMember.isMember, isTrue);
      });

      test('should copy with new joinedAt', () {
        // Arrange
        final newDate = DateTime(2024, 2, 1, 10);

        // Act
        final updatedMember = originalMember.copyWith(joinedAt: newDate);

        // Assert
        expect(updatedMember.joinedAt, equals(newDate));
        expect(updatedMember.id, equals(originalMember.id));
      });

      test('should preserve original values when no changes provided', () {
        // Act
        final copiedMember = originalMember.copyWith();

        // Assert
        expect(copiedMember, equals(originalMember));
      });
    });

    group('Data Validation', () {
      late FamilyMember member;

      setUp(() {
        member = FamilyMember(
          id: 'member-123',
          familyId: 'family-456',
          userId: 'user-789',
          role: FamilyRole.admin,
          status: 'ACTIVE',
          joinedAt: testJoinedAt,
        );
      });

      test('should validate basic member properties', () {
        // Assert
        expect(member.id, isNotEmpty);
        expect(member.familyId, isNotEmpty);
        expect(member.userId, isNotEmpty);
        expect(member.role, isNotNull);
        expect(member.joinedAt, isNotNull);
      });

      test('should handle role validation correctly', () {
        // Arrange
        final adminMember = FamilyMember(
          id: 'admin-123',
          familyId: 'family-456',
          userId: 'user-789',
          role: FamilyRole.admin,
          status: 'ACTIVE',
          joinedAt: testJoinedAt,
        );

        final regularMember = FamilyMember(
          id: 'member-456',
          familyId: 'family-456',
          userId: 'user-789',
          role: FamilyRole.member,
          status: 'ACTIVE',
          joinedAt: testJoinedAt,
        );

        // Assert
        expect(adminMember.role, equals(FamilyRole.admin));
        expect(adminMember.isAdmin, isTrue);
        expect(adminMember.isMember, isFalse);

        expect(regularMember.role, equals(FamilyRole.member));
        expect(regularMember.isMember, isTrue);
        expect(regularMember.isAdmin, isFalse);
      });

      test('should validate role consistency', () {
        // Arrange - member with admin role
        final adminMember = member.copyWith(role: FamilyRole.admin);
        final demotedMember = adminMember.copyWith(role: FamilyRole.member);

        // Assert
        expect(adminMember.isAdmin, isTrue);
        expect(demotedMember.isMember, isTrue);
        expect(demotedMember.isAdmin, isFalse);
      });

      test('should handle role string representations correctly', () {
        // Assert role display names
        expect(FamilyRole.admin.value, equals('ADMIN'));
        expect(FamilyRole.member.value, equals('MEMBER'));
        expect(member.roleDisplayName, equals('Administrator'));
      });

      test('should validate role conversion from strings', () {
        // Assert case insensitive conversion
        expect(FamilyRole.fromString('ADMIN'), equals(FamilyRole.admin));
        expect(FamilyRole.fromString('admin'), equals(FamilyRole.admin));
        expect(FamilyRole.fromString('MEMBER'), equals(FamilyRole.member));
        expect(FamilyRole.fromString('member'), equals(FamilyRole.member));
      });

      test('should throw error for invalid role strings', () {
        // Act & Assert
        expect(
          () => FamilyRole.fromString('INVALID_ROLE'),
          throwsArgumentError,
        );
        expect(() => FamilyRole.fromString(''), throwsArgumentError);
        expect(() => FamilyRole.fromString('USER'), throwsArgumentError);
      });
    });

    group('ToString Method', () {
      test('should provide meaningful string representation', () {
        // Arrange
        final member = FamilyMember(
          id: 'member-123',
          familyId: 'family-456',
          userId: 'user-789',
          role: FamilyRole.admin,
          status: 'ACTIVE',
          joinedAt: testJoinedAt,
        );

        // Act
        final stringRepresentation = member.toString();

        // Assert
        expect(
          stringRepresentation,
          equals(
            'FamilyMember(id: member-123, userId: user-789, familyId: family-456, role: ADMIN)',
          ),
        );
      });

      test('should show member role correctly in string representation', () {
        // Arrange
        final member = FamilyMember(
          id: 'member-123',
          familyId: 'family-456',
          userId: 'user-789',
          role: FamilyRole.member,
          status: 'ACTIVE',
          joinedAt: testJoinedAt,
        );

        // Act
        final stringRepresentation = member.toString();

        // Assert
        expect(stringRepresentation, contains('role: MEMBER'));
      });
    });

    group('Edge Cases and Business Logic', () {
      test('should handle extremely long IDs gracefully', () {
        // Arrange
        final longId = 'x' * 1000;
        final member = FamilyMember(
          id: longId,
          familyId: 'family-456',
          userId: 'user-789',
          role: FamilyRole.admin,
          status: 'ACTIVE',
          joinedAt: testJoinedAt,
        );

        // Act & Assert
        expect(member.id, equals(longId));
        expect(member.isAdmin, isTrue);
      });

      test('should maintain role consistency through copy operations', () {
        // Arrange
        final adminMember = FamilyMember(
          id: 'member-123',
          familyId: 'family-456',
          userId: 'user-789',
          role: FamilyRole.admin,
          status: 'ACTIVE',
          joinedAt: testJoinedAt,
        );

        // Act
        final promotedMember = adminMember.copyWith();
        final demotedMember = adminMember.copyWith(role: FamilyRole.member);

        // Assert
        expect(promotedMember.isAdmin, isTrue);
        expect(demotedMember.isMember, isTrue);
        expect(demotedMember.isAdmin, isFalse);
      });

      test('should handle future and past join dates', () {
        // Arrange
        final pastDate = DateTime(2020);
        final futureDate = DateTime(2030);

        final pastMember = FamilyMember(
          id: 'member-123',
          familyId: 'family-456',
          userId: 'user-789',
          role: FamilyRole.admin,
          status: 'ACTIVE',
          joinedAt: pastDate,
        );

        final futureMember = FamilyMember(
          id: 'member-456',
          familyId: 'family-456',
          userId: 'user-789',
          role: FamilyRole.member,
          status: 'ACTIVE',
          joinedAt: futureDate,
        );

        // Act & Assert
        expect(pastMember.joinedAt, equals(pastDate));
        expect(futureMember.joinedAt, equals(futureDate));
      });

      test('should handle same user in different families', () {
        // Arrange
        final member1 = FamilyMember(
          id: 'member-123',
          familyId: 'family-1',
          userId: 'user-789',
          role: FamilyRole.admin,
          status: 'ACTIVE',
          joinedAt: testJoinedAt,
        );

        final member2 = FamilyMember(
          id: 'member-456',
          familyId: 'family-2',
          userId: 'user-789',
          role: FamilyRole.member,
          status: 'ACTIVE',
          joinedAt: testJoinedAt,
        );

        // Act & Assert
        expect(member1.userId, equals(member2.userId));
        expect(member1.familyId, isNot(equals(member2.familyId)));
        expect(member1.isAdmin, isTrue);
        expect(member2.isMember, isTrue);
        expect(
          member1,
          isNot(equals(member2)),
        ); // Different members despite same user
      });
    });
  });
}
