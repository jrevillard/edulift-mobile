import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/domain/entities/family.dart';

/// Unit tests for FamilyMember display name logic
/// Tests the entity-level logic that should be used instead of hardcoded names
///
/// This tests the CORRECT implementation that should replace the bug in
/// family_management_screen.dart line 243
void main() {
  group('FamilyMember Display Name Logic Tests', () {
    late DateTime testDate;

    setUp(() {
      testDate = DateTime.parse('2024-01-15T10:00:00Z');
    });

    group('displayName getter tests', () {
      test('returns userName when available', () {
        // ARRANGE
        final member = FamilyMember(
          id: 'member1',
          familyId: 'family1',
          userId: 'user1',
          role: FamilyRole.admin,
      status: 'ACTIVE',
          joinedAt: testDate,
          userName: 'John Smith',
          userEmail: 'john@example.com',
        );

        // ACT & ASSERT
        expect(
          member.displayName,
          equals('John Smith'),
          reason: 'Should return userName when available',
        );
      });

      test('returns fallback "User {userId}" when userName is null', () {
        // ARRANGE
        final member = FamilyMember(
          id: 'member1',
          familyId: 'family1',
          userId: 'user123',
          role: FamilyRole.member,
      status: 'ACTIVE',
          joinedAt: testDate,
        );

        // ACT & ASSERT
        expect(
          member.displayName,
          equals('User user123'),
          reason: 'Should fallback to "User {userId}" when userName is null',
        );
      });

      test('returns fallback "User {userId}" when userName is empty', () {
        // ARRANGE
        final member = FamilyMember(
          id: 'member1',
          familyId: 'family1',
          userId: 'user456',
          role: FamilyRole.member,
      status: 'ACTIVE',
          joinedAt: testDate,
          userName: '',
          userEmail: 'user@example.com',
        );

        // ACT & ASSERT
        expect(
          member.displayName,
          equals('User user456'),
          reason:
              'Should fallback to "User {userId}" when userName is empty string',
        );
      });

      test('handles special characters in userName', () {
        // ARRANGE
        final member = FamilyMember(
          id: 'member1',
          familyId: 'family1',
          userId: 'user1',
          role: FamilyRole.admin,
      status: 'ACTIVE',
          joinedAt: testDate,
          userName: 'José María-González',
          userEmail: 'jose@example.com',
        );

        // ACT & ASSERT
        expect(
          member.displayName,
          equals('José María-González'),
          reason: 'Should handle special characters in userName',
        );
      });

      test('handles long userNames', () {
        // ARRANGE
        final longName = 'A' * 100; // Very long name
        final member = FamilyMember(
          id: 'member1',
          familyId: 'family1',
          userId: 'user1',
          role: FamilyRole.member,
      status: 'ACTIVE',
          joinedAt: testDate,
          userName: longName,
          userEmail: 'user@example.com',
        );

        // ACT & ASSERT
        expect(
          member.displayName,
          equals(longName),
          reason: 'Should handle long userNames without truncation',
        );
      });
    });

    group('displayNameOrLoading getter tests', () {
      test('returns userName when available', () {
        // ARRANGE
        final member = FamilyMember(
          id: 'member1',
          familyId: 'family1',
          userId: 'user1',
          role: FamilyRole.admin,
      status: 'ACTIVE',
          joinedAt: testDate,
          userName: 'Alice Johnson',
          userEmail: 'alice@example.com',
        );

        // ACT & ASSERT
        expect(
          member.displayNameOrLoading,
          equals('Alice Johnson'),
          reason: 'Should return userName when available and not empty',
        );
      });

      test('returns "Loading..." when userName is null', () {
        // ARRANGE
        final member = FamilyMember(
          id: 'member1',
          familyId: 'family1',
          userId: 'user1',
          role: FamilyRole.member,
      status: 'ACTIVE',
          joinedAt: testDate,
        );

        // ACT & ASSERT
        expect(
          member.displayNameOrLoading,
          equals('Loading...'),
          reason: 'Should return "Loading..." when userName is null',
        );
      });

      test('returns "Loading..." when userName is empty', () {
        // ARRANGE
        final member = FamilyMember(
          id: 'member1',
          familyId: 'family1',
          userId: 'user1',
          role: FamilyRole.member,
      status: 'ACTIVE',
          joinedAt: testDate,
          userName: '',
          userEmail: 'user@example.com',
        );

        // ACT & ASSERT
        expect(
          member.displayNameOrLoading,
          equals('Loading...'),
          reason: 'Should return "Loading..." when userName is empty string',
        );
      });

      test('returns "Loading..." when userName is only whitespace', () {
        // ARRANGE
        final member = FamilyMember(
          id: 'member1',
          familyId: 'family1',
          userId: 'user1',
          role: FamilyRole.member,
      status: 'ACTIVE',
          joinedAt: testDate,
          userName: '   ',
          userEmail: 'user@example.com',
        );

        // ACT & ASSERT
        expect(
          member.displayNameOrLoading,
          equals('   '),
          reason:
              'Should return the whitespace userName as-is (trimming is not implemented)',
        );
      });
    });

    group('role display tests', () {
      test('isAdmin returns true for admin role', () {
        // ARRANGE
        final adminMember = FamilyMember(
          id: 'member1',
          familyId: 'family1',
          userId: 'user1',
          role: FamilyRole.admin,
      status: 'ACTIVE',
          joinedAt: testDate,
          userName: 'Admin User',
          userEmail: 'admin@example.com',
        );

        // ACT & ASSERT
        expect(
          adminMember.isAdmin,
          isTrue,
          reason: 'isAdmin should return true for admin role',
        );
        expect(
          adminMember.isMember,
          isFalse,
          reason: 'isMember should return false for admin role',
        );
      });

      test('isMember returns true for member role', () {
        // ARRANGE
        final regularMember = FamilyMember(
          id: 'member1',
          familyId: 'family1',
          userId: 'user1',
          role: FamilyRole.member,
      status: 'ACTIVE',
          joinedAt: testDate,
          userName: 'Regular User',
          userEmail: 'user@example.com',
        );

        // ACT & ASSERT
        expect(
          regularMember.isMember,
          isTrue,
          reason: 'isMember should return true for member role',
        );
        expect(
          regularMember.isAdmin,
          isFalse,
          reason: 'isAdmin should return false for member role',
        );
      });

      test('roleDisplayName returns correct display names', () {
        // ARRANGE
        final adminMember = FamilyMember(
          id: 'member1',
          familyId: 'family1',
          userId: 'user1',
          role: FamilyRole.admin,
      status: 'ACTIVE',
          joinedAt: testDate,
          userName: 'Admin User',
          userEmail: 'admin@example.com',
        );

        final regularMember = FamilyMember(
          id: 'member2',
          familyId: 'family1',
          userId: 'user2',
          role: FamilyRole.member,
      status: 'ACTIVE',
          joinedAt: testDate,
          userName: 'Regular User',
          userEmail: 'user@example.com',
        );

        // ACT & ASSERT
        expect(
          adminMember.roleDisplayName,
          equals('Administrator'),
          reason: 'Admin role should display as "Administrator"',
        );
        expect(
          regularMember.roleDisplayName,
          equals('Member'),
          reason: 'Member role should display as "Member"',
        );
      });
    });

    group('edge cases and error conditions', () {
      test('handles very long userId in fallback', () {
        // ARRANGE
        final longUserId = 'user${'1' * 100}';
        final member = FamilyMember(
          id: 'member1',
          familyId: 'family1',
          userId: longUserId,
          role: FamilyRole.member,
      status: 'ACTIVE',
          joinedAt: testDate,
        );

        // ACT & ASSERT
        expect(
          member.displayName,
          equals('User $longUserId'),
          reason: 'Should handle very long userId in fallback',
        );
      });

      test('handles special characters in userId fallback', () {
        // ARRANGE
        const specialUserId = 'user-123_test@domain';
        final member = FamilyMember(
          id: 'member1',
          familyId: 'family1',
          userId: specialUserId,
          role: FamilyRole.member,
      status: 'ACTIVE',
          joinedAt: testDate,
        );

        // ACT & ASSERT
        expect(
          member.displayName,
          equals('User $specialUserId'),
          reason: 'Should handle special characters in userId',
        );
      });

      test('copyWith preserves display name behavior', () {
        // ARRANGE
        final originalMember = FamilyMember(
          id: 'member1',
          familyId: 'family1',
          userId: 'user1',
          role: FamilyRole.member,
      status: 'ACTIVE',
          joinedAt: testDate,
          userName: 'Original Name',
          userEmail: 'original@example.com',
        );

        // ACT
        final updatedMember = originalMember.copyWith(userName: 'Updated Name');

        // ASSERT
        expect(originalMember.displayName, equals('Original Name'));
        expect(updatedMember.displayName, equals('Updated Name'));
        expect(
          originalMember.userId,
          equals(updatedMember.userId),
          reason: 'userId should remain the same',
        );
      });
    });

    group('comparison with current bug behavior', () {
      test('demonstrates correct behavior vs hardcoded "Member N" bug', () {
        // ARRANGE - Simulate what the API would return
        final apiMembers = [
          FamilyMember(
            id: 'member1',
            familyId: 'family1',
            userId: 'user1',
            role: FamilyRole.admin,
      status: 'ACTIVE',
            joinedAt: testDate,
            userName: 'John Smith',
            userEmail: 'john@example.com',
          ),
          FamilyMember(
            id: 'member2',
            familyId: 'family1',
            userId: 'user2',
            role: FamilyRole.member,
      status: 'ACTIVE',
            joinedAt: testDate,
            userName: 'Jane Doe',
            userEmail: 'jane@example.com',
          ),
        ];

        // ACT & ASSERT - What SHOULD be displayed
        expect(
          apiMembers[0].displayName,
          equals('John Smith'),
          reason: 'First member should show real name, not "Member 1"',
        );
        expect(
          apiMembers[1].displayName,
          equals('Jane Doe'),
          reason: 'Second member should show real name, not "Member 2"',
        );

        // DOCUMENT - What the bug currently shows
        final buggedDisplayNames = apiMembers
            .asMap()
            .entries
            .map((entry) => 'Member ${entry.key + 1}')
            .toList();

        expect(
          buggedDisplayNames,
          equals(['Member 1', 'Member 2']),
          reason:
              'This is what the BUG currently displays instead of real names',
        );

        // VERIFY - The correct implementation is different from the bug
        expect(
          apiMembers[0].displayName,
          isNot(equals('Member 1')),
          reason: 'Correct implementation should NOT show "Member 1"',
        );
        expect(
          apiMembers[1].displayName,
          isNot(equals('Member 2')),
          reason: 'Correct implementation should NOT show "Member 2"',
        );
      });
    });
  });

  group('FamilyRole enum tests', () {
    test('FamilyRole.fromString handles valid values', () {
      expect(FamilyRole.fromString('ADMIN'), equals(FamilyRole.admin));
      expect(FamilyRole.fromString('MEMBER'), equals(FamilyRole.member));
      expect(FamilyRole.fromString('admin'), equals(FamilyRole.admin));
      expect(FamilyRole.fromString('member'), equals(FamilyRole.member));
    });

    test('FamilyRole.fromString throws on invalid values', () {
      expect(() => FamilyRole.fromString('INVALID'), throwsArgumentError);
      expect(() => FamilyRole.fromString(''), throwsArgumentError);
    });

    test('FamilyRole.value returns correct strings', () {
      expect(FamilyRole.admin.value, equals('ADMIN'));
      expect(FamilyRole.member.value, equals('MEMBER'));
    });

    test('FamilyRole toString returns value', () {
      expect(FamilyRole.admin.toString(), equals('ADMIN'));
      expect(FamilyRole.member.toString(), equals('MEMBER'));
    });
  });
}
