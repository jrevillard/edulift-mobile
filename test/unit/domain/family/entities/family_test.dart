import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/domain/entities/family.dart';

void main() {
  group('Family Entity', () {
    late DateTime testCreatedAt;
    late DateTime testUpdatedAt;
    late FamilyMember testMember;
    late Child testChild;
    late Vehicle testVehicle;

    setUp(() {
      testCreatedAt = DateTime(2024, 1, 1, 10);
      testUpdatedAt = DateTime(2024, 1, 2, 10);

      testMember = FamilyMember(
        id: 'member-123',
        familyId: 'family-456',
        userId: 'user-789',
        role: FamilyRole.admin,
        status: 'ACTIVE',
        joinedAt: testCreatedAt,
      );

      testChild = Child(
        id: 'child-123',
        name: 'John Doe',
        age: 12,
        familyId: 'family-456',
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
      );

      testVehicle = Vehicle(
        id: 'vehicle-123',
        name: 'Family Van',
        familyId: 'family-456',
        capacity: 8,
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
      );
    });

    group('Construction and Property Validation', () {
      test('should create family with all required properties', () {
        // Arrange & Act
        final family = Family(
          id: 'family-456',
          name: 'The Smith Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          members: [testMember],
          children: [testChild],
          vehicles: [testVehicle],
          description: 'A loving family',
        );

        // Assert
        expect(family.id, equals('family-456'));
        expect(family.name, equals('The Smith Family'));
        expect(family.createdAt, equals(testCreatedAt));
        expect(family.updatedAt, equals(testUpdatedAt));
        expect(family.members, equals([testMember]));
        expect(family.children, equals([testChild]));
        expect(family.vehicles, equals([testVehicle]));
        expect(family.description, equals('A loving family'));
      });

      test('should create family with empty collections by default', () {
        // Arrange & Act
        final family = Family(
          id: 'family-456',
          name: 'The Smith Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Assert
        expect(family.members, isEmpty);
        expect(family.children, isEmpty);
        expect(family.vehicles, isEmpty);
        expect(family.description, isNull);
      });

      test('should create family with null description', () {
        // Arrange & Act
        final family = Family(
          id: 'family-456',
          name: 'The Smith Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          members: [testMember],
          children: [testChild],
          vehicles: [testVehicle],
        );

        // Assert
        expect(family.description, isNull);
        expect(family.members, isNotEmpty);
        expect(family.children, isNotEmpty);
        expect(family.vehicles, isNotEmpty);
      });
    });

    group('Computed Properties', () {
      late Family family;

      setUp(() {
        family = Family(
          id: 'family-456',
          name: 'The Smith Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          members: [
            testMember,
            FamilyMember(
              id: 'member-456',
              familyId: 'family-456',
              userId: 'user-012',
              role: FamilyRole.member,
              status: 'ACTIVE',
              joinedAt: testCreatedAt,
            ),
          ],
          children: [
            testChild,
            Child(
              id: 'child-456',
              name: 'Jane Doe',
              age: 10,
              familyId: 'family-456',
              createdAt: testCreatedAt,
              updatedAt: testUpdatedAt,
            ),
          ],
          vehicles: [
            testVehicle,
            Vehicle(
              id: 'vehicle-456',
              name: 'Sedan',
              familyId: 'family-456',
              capacity: 5,
              createdAt: testCreatedAt,
              updatedAt: testUpdatedAt,
            ),
          ],
        );
      });

      test('should calculate total members correctly', () {
        // Act & Assert
        expect(family.totalMembers, equals(2));
      });

      test('should calculate total children correctly', () {
        // Act & Assert
        expect(family.totalChildren, equals(2));
      });

      test('should calculate total vehicles correctly', () {
        // Act & Assert
        expect(family.totalVehicles, equals(2));
      });

      test('should handle empty collections in totals', () {
        // Arrange
        final emptyFamily = Family(
          id: 'family-456',
          name: 'Empty Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(emptyFamily.totalMembers, equals(0));
        expect(emptyFamily.totalChildren, equals(0));
        expect(emptyFamily.totalVehicles, equals(0));
      });
    });

    group('Member Role Filtering', () {
      late Family family;

      setUp(() {
        family = Family(
          id: 'family-456',
          name: 'The Smith Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          members: [
            FamilyMember(
              id: 'admin-1',
              familyId: 'family-456',
              userId: 'user-1',
              role: FamilyRole.admin,
              status: 'ACTIVE',
              joinedAt: testCreatedAt,
            ),
            FamilyMember(
              id: 'admin-2',
              familyId: 'family-456',
              userId: 'user-2',
              role: FamilyRole.admin,
              status: 'ACTIVE',
              joinedAt: testCreatedAt,
            ),
            FamilyMember(
              id: 'member-1',
              familyId: 'family-456',
              userId: 'user-3',
              role: FamilyRole.member,
              status: 'ACTIVE',
              joinedAt: testCreatedAt,
            ),
            FamilyMember(
              id: 'member-2',
              familyId: 'family-456',
              userId: 'user-4',
              role: FamilyRole.member,
              status: 'ACTIVE',
              joinedAt: testCreatedAt,
            ),
          ],
        );
      });

      test('should filter members by admin role', () {
        // Act
        final admins = family.getMembersByRole(FamilyRole.admin);

        // Assert
        expect(admins, hasLength(2));
        expect(
          admins.every((member) => member.role == FamilyRole.admin),
          isTrue,
        );
      });

      test('should filter members by member role', () {
        // Act
        final members = family.getMembersByRole(FamilyRole.member);

        // Assert
        expect(members, hasLength(2));
        expect(
          members.every((member) => member.role == FamilyRole.member),
          isTrue,
        );
      });

      test('should get administrators using convenience getter', () {
        // Act
        final admins = family.administrators;

        // Assert
        expect(admins, hasLength(2));
        expect(admins.every((member) => member.isAdmin), isTrue);
      });

      test('should get regular members using convenience getter', () {
        // Act
        final regularMembers = family.regularMembers;

        // Assert
        expect(regularMembers, hasLength(2));
        expect(regularMembers.every((member) => member.isMember), isTrue);
      });

      test('should return empty list when no members match role', () {
        // Arrange
        final familyWithOnlyAdmins = Family(
          id: 'family-456',
          name: 'Admin Only Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          members: [
            FamilyMember(
              id: 'admin-1',
              familyId: 'family-456',
              userId: 'user-1',
              role: FamilyRole.admin,
              status: 'ACTIVE',
              joinedAt: testCreatedAt,
            ),
          ],
        );

        // Act
        final regularMembers = familyWithOnlyAdmins.regularMembers;

        // Assert
        expect(regularMembers, isEmpty);
      });
    });

    group('Equality and Hash Code', () {
      late Family family1;
      late Family family2;

      setUp(() {
        family1 = Family(
          id: 'family-456',
          name: 'The Smith Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          members: [testMember],
          children: [testChild],
          vehicles: [testVehicle],
          description: 'A loving family',
        );

        family2 = Family(
          id: 'family-456',
          name: 'The Smith Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          members: [testMember],
          children: [testChild],
          vehicles: [testVehicle],
          description: 'A loving family',
        );
      });

      test('should be equal when all properties match', () {
        // Act & Assert
        expect(family1, equals(family2));
      });

      test('should not be equal when id differs', () {
        // Arrange
        final differentFamily = family2.copyWith(id: 'different-id');

        // Act & Assert
        expect(family1, isNot(equals(differentFamily)));
      });

      test('should not be equal when name differs', () {
        // Arrange
        final differentFamily = family2.copyWith(name: 'Different Family');

        // Act & Assert
        expect(family1, isNot(equals(differentFamily)));
      });

      test('should not be equal when members differ', () {
        // Arrange
        final differentFamily = family2.copyWith(members: <FamilyMember>[]);

        // Act & Assert
        expect(family1, isNot(equals(differentFamily)));
      });

      test('should not be equal when children differ', () {
        // Arrange
        final differentFamily = family2.copyWith(children: <Child>[]);

        // Act & Assert
        expect(family1, isNot(equals(differentFamily)));
      });

      test('should not be equal when vehicles differ', () {
        // Arrange
        final differentFamily = family2.copyWith(vehicles: <Vehicle>[]);

        // Act & Assert
        expect(family1, isNot(equals(differentFamily)));
      });

      test('should not be equal when description differs', () {
        // Arrange
        final differentFamily = family2.copyWith(
          description: 'Different description',
        );

        // Act & Assert
        expect(family1, isNot(equals(differentFamily)));
      });

      test('should have same hash code when equal', () {
        // Act & Assert
        expect(family1.hashCode, equals(family2.hashCode));
      });
    });

    group('Copy With Method', () {
      late Family originalFamily;

      setUp(() {
        originalFamily = Family(
          id: 'family-456',
          name: 'The Smith Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          members: [testMember],
          children: [testChild],
          vehicles: [testVehicle],
          description: 'A loving family',
        );
      });

      test('should copy with new id', () {
        // Act
        final updatedFamily = originalFamily.copyWith(id: 'new-id');

        // Assert
        expect(updatedFamily.id, equals('new-id'));
        expect(updatedFamily.name, equals(originalFamily.name));
        expect(updatedFamily.members, equals(originalFamily.members));
        expect(updatedFamily.children, equals(originalFamily.children));
        expect(updatedFamily.vehicles, equals(originalFamily.vehicles));
        expect(updatedFamily.description, equals(originalFamily.description));
      });

      test('should copy with new name', () {
        // Act
        final updatedFamily = originalFamily.copyWith(name: 'New Family Name');

        // Assert
        expect(updatedFamily.name, equals('New Family Name'));
        expect(updatedFamily.id, equals(originalFamily.id));
      });

      test('should copy with new members list', () {
        // Arrange
        final newMember = FamilyMember(
          id: 'new-member',
          familyId: 'family-456',
          userId: 'new-user',
          role: FamilyRole.member,
          status: 'ACTIVE',
          joinedAt: testCreatedAt,
        );

        // Act
        final updatedFamily = originalFamily.copyWith(members: [newMember]);

        // Assert
        expect(updatedFamily.members, equals([newMember]));
        expect(updatedFamily.totalMembers, equals(1));
      });

      test('should copy with new children list', () {
        // Arrange
        final newChild = Child(
          id: 'new-child',
          name: 'New Child',
          age: 8,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act
        final updatedFamily = originalFamily.copyWith(children: [newChild]);

        // Assert
        expect(updatedFamily.children, equals([newChild]));
        expect(updatedFamily.totalChildren, equals(1));
      });

      test('should copy with new vehicles list', () {
        // Arrange
        final newVehicle = Vehicle(
          id: 'new-vehicle',
          name: 'New Car',
          familyId: 'family-456',
          capacity: 4,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act
        final updatedFamily = originalFamily.copyWith(vehicles: [newVehicle]);

        // Assert
        expect(updatedFamily.vehicles, equals([newVehicle]));
        expect(updatedFamily.totalVehicles, equals(1));
      });

      test('should copy preserving all properties', () {
        // Act
        final updatedFamily = originalFamily.copyWith();

        // Assert
        expect(updatedFamily.description, equals(originalFamily.description));
      });

      test('should preserve original values when no changes provided', () {
        // Act
        final copiedFamily = originalFamily.copyWith();

        // Assert
        expect(copiedFamily, equals(originalFamily));
      });
    });

    // JSON Serialization removed - Domain entities should not have JSON methods
    // Use FamilyDto for JSON serialization/deserialization instead

    group('ToString Method', () {
      test('should provide meaningful string representation', () {
        // Arrange
        final family = Family(
          id: 'family-456',
          name: 'The Smith Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          members: [testMember],
          children: [testChild],
          vehicles: [testVehicle],
        );

        // Act
        final stringRepresentation = family.toString();

        // Assert
        expect(
          stringRepresentation,
          equals(
            'Family(id: family-456, name: The Smith Family, members: 1, children: 1, vehicles: 1)',
          ),
        );
      });

      test('should show correct counts in string representation', () {
        // Arrange
        final familyWithMultiple = Family(
          id: 'family-456',
          name: 'Large Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          members: [testMember, testMember],
          children: [testChild, testChild, testChild],
          vehicles: [testVehicle],
        );

        // Act
        final stringRepresentation = familyWithMultiple.toString();

        // Assert
        expect(stringRepresentation, contains('members: 2'));
        expect(stringRepresentation, contains('children: 3'));
        expect(stringRepresentation, contains('vehicles: 1'));
      });
    });

    group('Edge Cases and Business Logic', () {
      test('should handle extremely long family names gracefully', () {
        // Arrange
        final longName = 'A' * 1000; // Very long name
        final family = Family(
          id: 'family-456',
          name: longName,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(family.name, equals(longName));
        expect(family.totalMembers, equals(0));
      });

      test('should handle large collections efficiently', () {
        // Arrange
        final largeMembers = List.generate(
          100,
          (index) => FamilyMember(
            id: 'member-$index',
            familyId: 'family-456',
            userId: 'user-$index',
            role: index % 2 == 0 ? FamilyRole.admin : FamilyRole.member,
            status: 'ACTIVE',

            joinedAt: testCreatedAt,
          ),
        );

        final family = Family(
          id: 'family-456',
          name: 'Large Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          members: largeMembers,
        );

        // Act & Assert
        expect(family.totalMembers, equals(100));
        expect(family.administrators, hasLength(50)); // Every even index
        expect(family.regularMembers, hasLength(50)); // Every odd index
      });

      test('should handle mixed family member roles correctly', () {
        // Arrange
        final mixedMembers = [
          FamilyMember(
            id: 'admin-1',
            familyId: 'family-456',
            userId: 'user-1',
            role: FamilyRole.admin,
            status: 'ACTIVE',
            joinedAt: testCreatedAt,
          ),
          FamilyMember(
            id: 'member-1',
            familyId: 'family-456',
            userId: 'user-2',
            role: FamilyRole.member,
            status: 'ACTIVE',
            joinedAt: testCreatedAt,
          ),
          FamilyMember(
            id: 'admin-2',
            familyId: 'family-456',
            userId: 'user-3',
            role: FamilyRole.admin,
            status: 'ACTIVE',
            joinedAt: testCreatedAt,
          ),
        ];

        final family = Family(
          id: 'family-456',
          name: 'Mixed Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          members: mixedMembers,
        );

        // Act & Assert
        expect(family.administrators, hasLength(2));
        expect(family.regularMembers, hasLength(1));
        expect(family.getMembersByRole(FamilyRole.admin), hasLength(2));
        expect(family.getMembersByRole(FamilyRole.member), hasLength(1));
      });

      test('should handle special characters in family name', () {
        // Arrange
        final family = Family(
          id: 'family-456',
          name: 'The O\'Connor-Smith Family & Friends!',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(family.name, equals('The O\'Connor-Smith Family & Friends!'));
      });

      test('should handle unicode characters in family name', () {
        // Arrange
        final family = Family(
          id: 'family-456',
          name: '李家庭 (The Li Family)',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(family.name, equals('李家庭 (The Li Family)'));
      });

      test('should maintain referential integrity in collections', () {
        // Arrange
        final family = Family(
          id: 'family-456',
          name: 'Test Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          members: [testMember],
          children: [testChild],
          vehicles: [testVehicle],
        );

        // Act - Modify external references
        final modifiedMembers = List<FamilyMember>.from(family.members);
        modifiedMembers.clear();

        // Assert - Original family should be unchanged
        expect(family.members, hasLength(1));
        expect(family.totalMembers, equals(1));
      });
    });
  });
}
