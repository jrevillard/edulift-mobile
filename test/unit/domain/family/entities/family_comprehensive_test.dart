import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/domain/entities/family.dart';

/// Comprehensive Family Entity Tests
/// Tests all business logic methods, relationships, and edge cases for Family domain entity
void main() {
  group('Family Entity - Comprehensive Tests', () {
    late DateTime testCreatedAt;
    late DateTime testUpdatedAt;
    late FamilyMember adminMember;
    late FamilyMember regularMember1;
    late FamilyMember regularMember2;
    late Child child1;
    late Child child2;
    late Vehicle vehicle1;
    late Vehicle vehicle2;

    setUp(() {
      testCreatedAt = DateTime.parse('2024-01-10T08:00:00.000Z');
      testUpdatedAt = DateTime.parse('2024-01-15T10:30:00.000Z');

      adminMember = FamilyMember(
        id: 'member-admin-1',
        familyId: 'family-test',
        userId: 'user-admin',
        role: FamilyRole.admin,
      status: 'ACTIVE',
        joinedAt: testCreatedAt,
        userName: 'John Admin',
        userEmail: 'admin@example.com',
      );

      regularMember1 = FamilyMember(
        id: 'member-regular-1',
        familyId: 'family-test',
        userId: 'user-regular-1',
        role: FamilyRole.member,
      status: 'ACTIVE',
        joinedAt: testCreatedAt.add(const Duration(days: 1)),
        userName: 'Jane Member',
        userEmail: 'member1@example.com',
      );

      regularMember2 = FamilyMember(
        id: 'member-regular-2',
        familyId: 'family-test',
        userId: 'user-regular-2',
        role: FamilyRole.member,
      status: 'ACTIVE',
        joinedAt: testCreatedAt.add(const Duration(days: 2)),
        userName: 'Bob Member',
        userEmail: 'member2@example.com',
      );

      child1 = Child(
        id: 'child-1',
        name: 'Emma Smith',
        age: 8,
        familyId: 'family-test',
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
      );

      child2 = Child(
        id: 'child-2',
        name: 'Liam Smith',
        age: 12,
        familyId: 'family-test',
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
      );

      vehicle1 = Vehicle(
        id: 'vehicle-1',
        name: 'Family Van',
        capacity: 7,
        familyId: 'family-test',
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
        description: 'Honda Odyssey 2020',
      );

      vehicle2 = Vehicle(
        id: 'vehicle-2',
        name: 'Sedan',
        capacity: 5,
        familyId: 'family-test',
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
        description: 'Toyota Camry 2021',
      );
    });

    group('Constructor and Basic Properties', () {
      test('should create family with required fields only', () {
        // Act
        final family = Family(
          id: 'family-123',
          name: 'Smith Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Assert
        expect(family.id, equals('family-123'));
        expect(family.name, equals('Smith Family'));
        expect(family.createdAt, equals(testCreatedAt));
        expect(family.updatedAt, equals(testUpdatedAt));
        expect(family.members, isEmpty);
        expect(family.children, isEmpty);
        expect(family.vehicles, isEmpty);
        expect(family.description, isNull);
      });

      test('should create family with all fields populated', () {
        // Act
        final family = Family(
          id: 'family-123',
          name: 'Smith Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          members: [adminMember, regularMember1],
          children: [child1, child2],
          vehicles: [vehicle1],
          description: 'The Smith family household',
        );

        // Assert
        expect(family.id, equals('family-123'));
        expect(family.name, equals('Smith Family'));
        expect(family.members, hasLength(2));
        expect(family.children, hasLength(2));
        expect(family.vehicles, hasLength(1));
        expect(family.description, equals('The Smith family household'));
      });

      test('should handle empty collections gracefully', () {
        // Act
        final family = Family(
          id: 'family-empty',
          name: 'Empty Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Assert
        expect(family.members, isEmpty);
        expect(family.children, isEmpty);
        expect(family.vehicles, isEmpty);
        expect(family.totalMembers, equals(0));
        expect(family.totalChildren, equals(0));
        expect(family.totalVehicles, equals(0));
      });
    });

    group('Total Count Properties', () {
      test('should calculate total members correctly', () {
        final testCases = [
          {'members': <FamilyMember>[], 'expected': 0},
          {
            'members': [adminMember],
            'expected': 1,
          },
          {
            'members': [adminMember, regularMember1],
            'expected': 2,
          },
          {
            'members': [adminMember, regularMember1, regularMember2],
            'expected': 3,
          },
        ];

        for (final testCase in testCases) {
          // Arrange
          final family = Family(
            id: 'family-test',
            name: 'Test Family',
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
            members: testCase['members'] as List<FamilyMember>,
          );

          // Act & Assert
          expect(
            family.totalMembers,
            equals(testCase['expected']),
            reason:
                'Should calculate correct total for ${(testCase['members'] as List<FamilyMember>).length} members',
          );
        }
      });

      test('should calculate total children correctly', () {
        final testCases = [
          {'children': <Child>[], 'expected': 0},
          {
            'children': [child1],
            'expected': 1,
          },
          {
            'children': [child1, child2],
            'expected': 2,
          },
        ];

        for (final testCase in testCases) {
          // Arrange
          final family = Family(
            id: 'family-test',
            name: 'Test Family',
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
            children: testCase['children'] as List<Child>,
          );

          // Act & Assert
          expect(
            family.totalChildren,
            equals(testCase['expected']),
            reason:
                'Should calculate correct total for ${(testCase['children'] as List<Child>).length} children',
          );
        }
      });

      test('should calculate total vehicles correctly', () {
        final testCases = [
          {'vehicles': <Vehicle>[], 'expected': 0},
          {
            'vehicles': [vehicle1],
            'expected': 1,
          },
          {
            'vehicles': [vehicle1, vehicle2],
            'expected': 2,
          },
        ];

        for (final testCase in testCases) {
          // Arrange
          final family = Family(
            id: 'family-test',
            name: 'Test Family',
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
            vehicles: testCase['vehicles'] as List<Vehicle>,
          );

          // Act & Assert
          expect(
            family.totalVehicles,
            equals(testCase['expected']),
            reason:
                'Should calculate correct total for ${(testCase['vehicles'] as List<Vehicle>).length} vehicles',
          );
        }
      });
    });

    group('Members by Role Logic', () {
      test('should filter members by role correctly', () {
        // Arrange
        final family = Family(
          id: 'family-test',
          name: 'Test Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          members: [adminMember, regularMember1, regularMember2],
        );

        // Act & Assert - Filter by admin role
        final admins = family.getMembersByRole(FamilyRole.admin);
        expect(admins, hasLength(1));
        expect(admins.first.id, equals('member-admin-1'));
        expect(admins.first.role, equals(FamilyRole.admin));

        // Act & Assert - Filter by member role
        final members = family.getMembersByRole(FamilyRole.member);
        expect(members, hasLength(2));
        expect(
          members.map((m) => m.id),
          containsAll(['member-regular-1', 'member-regular-2']),
        );
        expect(members.every((m) => m.role == FamilyRole.member), isTrue);
      });

      test('should return empty list when no members match role', () {
        // Arrange - Family with only regular members
        final family = Family(
          id: 'family-test',
          name: 'Test Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          members: [regularMember1, regularMember2],
        );

        // Act & Assert
        final admins = family.getMembersByRole(FamilyRole.admin);
        expect(admins, isEmpty);
      });

      test('should handle family with no members', () {
        // Arrange
        final family = Family(
          id: 'family-test',
          name: 'Test Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(family.getMembersByRole(FamilyRole.admin), isEmpty);
        expect(family.getMembersByRole(FamilyRole.member), isEmpty);
      });
    });

    group('Administrators Property', () {
      test('should return all administrators', () {
        // Arrange - Create another admin
        final adminMember2 = FamilyMember(
          id: 'member-admin-2',
          familyId: 'family-test',
          userId: 'user-admin-2',
          role: FamilyRole.admin,
      status: 'ACTIVE',
          joinedAt: testCreatedAt,
          userName: 'Sarah Admin',
          userEmail: 'admin2@example.com',
        );

        final family = Family(
          id: 'family-test',
          name: 'Test Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          members: [adminMember, adminMember2, regularMember1],
        );

        // Act
        final administrators = family.administrators;

        // Assert
        expect(administrators, hasLength(2));
        expect(
          administrators.map((a) => a.id),
          containsAll(['member-admin-1', 'member-admin-2']),
        );
        expect(administrators.every((a) => a.role == FamilyRole.admin), isTrue);
      });

      test('should return empty list when no administrators', () {
        // Arrange
        final family = Family(
          id: 'family-test',
          name: 'Test Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          members: [regularMember1, regularMember2],
        );

        // Act & Assert
        expect(family.administrators, isEmpty);
      });
    });

    group('Regular Members Property', () {
      test('should return all regular members', () {
        // Arrange
        final family = Family(
          id: 'family-test',
          name: 'Test Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          members: [adminMember, regularMember1, regularMember2],
        );

        // Act
        final regulars = family.regularMembers;

        // Assert
        expect(regulars, hasLength(2));
        expect(
          regulars.map((r) => r.id),
          containsAll(['member-regular-1', 'member-regular-2']),
        );
        expect(regulars.every((r) => r.role == FamilyRole.member), isTrue);
      });

      test('should return empty list when no regular members', () {
        // Arrange
        final family = Family(
          id: 'family-test',
          name: 'Test Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          members: [adminMember],
        );

        // Act & Assert
        expect(family.regularMembers, isEmpty);
      });
    });

    group('CopyWith Method', () {
      late Family originalFamily;

      setUp(() {
        originalFamily = Family(
          id: 'family-original',
          name: 'Original Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          members: [adminMember],
          children: [child1],
          vehicles: [vehicle1],
          description: 'Original description',
        );
      });

      test('should create copy with updated basic fields', () {
        // Act
        final updatedFamily = originalFamily.copyWith(
          id: 'family-updated',
          name: 'Updated Family',
          description: 'Updated description',
        );

        // Assert
        expect(updatedFamily.id, equals('family-updated'));
        expect(updatedFamily.name, equals('Updated Family'));
        expect(updatedFamily.description, equals('Updated description'));

        // Original values preserved
        expect(updatedFamily.createdAt, equals(originalFamily.createdAt));
        expect(updatedFamily.updatedAt, equals(originalFamily.updatedAt));
        expect(updatedFamily.members, equals(originalFamily.members));
        expect(updatedFamily.children, equals(originalFamily.children));
        expect(updatedFamily.vehicles, equals(originalFamily.vehicles));
      });

      test('should create copy with updated collections', () {
        // Act
        final updatedFamily = originalFamily.copyWith(
          members: [adminMember, regularMember1],
          children: [child1, child2],
          vehicles: [vehicle1, vehicle2],
        );

        // Assert
        expect(updatedFamily.members, hasLength(2));
        expect(updatedFamily.children, hasLength(2));
        expect(updatedFamily.vehicles, hasLength(2));

        // Other fields preserved
        expect(updatedFamily.id, equals(originalFamily.id));
        expect(updatedFamily.name, equals(originalFamily.name));
        expect(updatedFamily.description, equals(originalFamily.description));
      });

      test('should create copy with empty collections', () {
        // Act
        final updatedFamily = originalFamily.copyWith(
          members: <FamilyMember>[],
          children: <Child>[],
          vehicles: <Vehicle>[],
        );

        // Assert
        expect(updatedFamily.members, isEmpty);
        expect(updatedFamily.children, isEmpty);
        expect(updatedFamily.vehicles, isEmpty);
        expect(updatedFamily.totalMembers, equals(0));
        expect(updatedFamily.totalChildren, equals(0));
        expect(updatedFamily.totalVehicles, equals(0));
      });

      test('should preserve original when no parameters provided', () {
        // Act
        final copiedFamily = originalFamily.copyWith();

        // Assert
        expect(copiedFamily, equals(originalFamily));
      });

      test('should handle null description properly', () {
        // Act - copyWith with no parameters should preserve description
        final familyWithSameDescription = originalFamily.copyWith();

        // Assert
        expect(
          familyWithSameDescription.description,
          equals(originalFamily.description),
        );
        expect(familyWithSameDescription.id, equals(originalFamily.id));
      });
    });

    group('Equality and Hash Code', () {
      test('should be equal when all properties match', () {
        // Arrange
        final family1 = Family(
          id: 'family-123',
          name: 'Smith Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          members: [adminMember],
          children: [child1],
          vehicles: [vehicle1],
          description: 'Test family',
        );

        final family2 = Family(
          id: 'family-123',
          name: 'Smith Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          members: [adminMember],
          children: [child1],
          vehicles: [vehicle1],
          description: 'Test family',
        );

        // Assert
        expect(family1, equals(family2));
        expect(family1.hashCode, equals(family2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        final family1 = Family(
          id: 'family-123',
          name: 'Smith Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final family2 = Family(
          id: 'family-124', // Different ID
          name: 'Smith Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Assert
        expect(family1, isNot(equals(family2)));
      });

      test('should not be equal when collections differ', () {
        // Arrange
        final family1 = Family(
          id: 'family-123',
          name: 'Smith Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          members: [adminMember],
        );

        final family2 = Family(
          id: 'family-123',
          name: 'Smith Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          members: [adminMember, regularMember1], // Different members
        );

        // Assert
        expect(family1, isNot(equals(family2)));
      });

      test('should be equal when both have empty collections', () {
        // Arrange
        final family1 = Family(
          id: 'family-123',
          name: 'Smith Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final family2 = Family(
          id: 'family-123',
          name: 'Smith Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Assert
        expect(family1, equals(family2));
      });
    });

    group('ToString Method', () {
      test('should provide meaningful string representation', () {
        // Arrange
        final family = Family(
          id: 'family-123',
          name: 'Smith Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          members: [adminMember, regularMember1],
          children: [child1, child2],
          vehicles: [vehicle1],
        );

        // Act
        final stringRepresentation = family.toString();

        // Assert
        expect(stringRepresentation, contains('Family('));
        expect(stringRepresentation, contains('id: family-123'));
        expect(stringRepresentation, contains('name: Smith Family'));
        expect(stringRepresentation, contains('members: 2'));
        expect(stringRepresentation, contains('children: 2'));
        expect(stringRepresentation, contains('vehicles: 1'));
      });

      test('should show zero counts for empty family', () {
        // Arrange
        final family = Family(
          id: 'family-empty',
          name: 'Empty Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act
        final stringRepresentation = family.toString();

        // Assert
        expect(stringRepresentation, contains('members: 0'));
        expect(stringRepresentation, contains('children: 0'));
        expect(stringRepresentation, contains('vehicles: 0'));
      });
    });

    group('Business Logic Integration Tests', () {
      test('should maintain consistent counts across operations', () {
        // Arrange - Start with empty family
        var family = Family(
          id: 'family-growing',
          name: 'Growing Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(family.totalMembers, equals(0));
        expect(family.totalChildren, equals(0));
        expect(family.totalVehicles, equals(0));

        // Act - Add members
        family = family.copyWith(members: [adminMember]);
        expect(family.totalMembers, equals(1));
        expect(family.administrators, hasLength(1));
        expect(family.regularMembers, isEmpty);

        // Act - Add regular member
        family = family.copyWith(members: [adminMember, regularMember1]);
        expect(family.totalMembers, equals(2));
        expect(family.administrators, hasLength(1));
        expect(family.regularMembers, hasLength(1));

        // Act - Add children
        family = family.copyWith(children: [child1, child2]);
        expect(family.totalChildren, equals(2));

        // Act - Add vehicles
        family = family.copyWith(vehicles: [vehicle1, vehicle2]);
        expect(family.totalVehicles, equals(2));
      });

      test('should handle realistic family composition scenarios', () {
        // Scenario 1: Nuclear family (2 parents, 2 children, 1 vehicle)
        final nuclearFamily = Family(
          id: 'nuclear-family',
          name: 'Nuclear Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          members: [adminMember, regularMember1], // Mom and Dad
          children: [child1, child2], // Two children
          vehicles: [vehicle1], // Family car
          description: 'Traditional nuclear family',
        );

        expect(nuclearFamily.totalMembers, equals(2));
        expect(nuclearFamily.totalChildren, equals(2));
        expect(nuclearFamily.totalVehicles, equals(1));
        expect(nuclearFamily.administrators, hasLength(1));
        expect(nuclearFamily.regularMembers, hasLength(1));

        // Scenario 2: Single parent family
        final singleParentFamily = Family(
          id: 'single-parent',
          name: 'Single Parent Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          members: [adminMember], // Single parent
          children: [child1], // One child
        );

        expect(singleParentFamily.totalMembers, equals(1));
        expect(singleParentFamily.totalChildren, equals(1));
        expect(singleParentFamily.totalVehicles, equals(0));
        expect(singleParentFamily.administrators, hasLength(1));
        expect(singleParentFamily.regularMembers, isEmpty);

        // Scenario 3: Extended family
        final extendedFamily = Family(
          id: 'extended-family',
          name: 'Extended Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          members: [
            adminMember,
            regularMember1,
            regularMember2,
          ], // Multiple adults
          children: [child1, child2], // Multiple children
          vehicles: [vehicle1, vehicle2], // Multiple vehicles
          description: 'Grandparents living with family',
        );

        expect(extendedFamily.totalMembers, equals(3));
        expect(extendedFamily.totalChildren, equals(2));
        expect(extendedFamily.totalVehicles, equals(2));
        expect(extendedFamily.administrators, hasLength(1));
        expect(extendedFamily.regularMembers, hasLength(2));
      });

      test('should support family growth and changes over time', () {
        // Arrange - Start with couple
        var family = Family(
          id: 'evolving-family',
          name: 'Evolving Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          members: [adminMember, regularMember1],
        );

        // Stage 1: Couple without children
        expect(family.totalMembers, equals(2));
        expect(family.totalChildren, equals(0));
        expect(family.totalVehicles, equals(0));

        // Stage 2: First child born, need a vehicle
        family = family.copyWith(
          children: [child1],
          vehicles: [vehicle2], // Start with sedan
          updatedAt: testUpdatedAt.add(const Duration(days: 365)),
        );

        expect(family.totalChildren, equals(1));
        expect(family.totalVehicles, equals(1));

        // Stage 3: Second child, upgrade to larger vehicle
        family = family.copyWith(
          children: [child1, child2],
          vehicles: [vehicle1], // Upgrade to van
          updatedAt: testUpdatedAt.add(const Duration(days: 730)),
        );

        expect(family.totalChildren, equals(2));
        expect(family.totalVehicles, equals(1));

        // Stage 4: Grandparent moves in
        family = family.copyWith(
          members: [adminMember, regularMember1, regularMember2],
          vehicles: [vehicle1, vehicle2], // Need second vehicle
          updatedAt: testUpdatedAt.add(const Duration(days: 1095)),
        );

        expect(family.totalMembers, equals(3));
        expect(family.totalVehicles, equals(2));
        expect(family.regularMembers, hasLength(2));
      });
    });

    group('Edge Cases and Error Boundaries', () {
      test('should handle large families gracefully', () {
        // Create large collections
        final manyMembers = List.generate(
          20,
          (i) => FamilyMember(
            id: 'member-$i',
            familyId: 'large-family',
            userId: 'user-$i',
            role: i == 0 ? FamilyRole.admin : FamilyRole.member,            status: 'ACTIVE',
            
            joinedAt: testCreatedAt.add(Duration(days: i)),
          ),
        );

        final manyChildren = List.generate(
          15,
          (i) => Child(
            id: 'child-$i',
            name: 'Child $i',
            age: i + 5,
            familyId: 'large-family',
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          ),
        );

        final manyVehicles = List.generate(
          5,
          (i) => Vehicle(
            id: 'vehicle-$i',
            name: 'Vehicle $i',
            capacity: 5 + i,
            familyId: 'large-family',
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          ),
        );

        // Arrange
        final largeFamily = Family(
          id: 'large-family',
          name: 'Large Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          members: manyMembers,
          children: manyChildren,
          vehicles: manyVehicles,
        );

        // Assert - Should handle large collections without issues
        expect(largeFamily.totalMembers, equals(20));
        expect(largeFamily.totalChildren, equals(15));
        expect(largeFamily.totalVehicles, equals(5));
        expect(largeFamily.administrators, hasLength(1));
        expect(largeFamily.regularMembers, hasLength(19));

        // Performance test - should be reasonably fast
        final stopwatch = Stopwatch()..start();
        for (var i = 0; i < 1000; i++) {
          largeFamily.getMembersByRole(FamilyRole.member);
        }
        stopwatch.stop();
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(100),
        ); // Should be under 100ms
      });

      test('should handle unusual but valid names and descriptions', () {
        final unusualNames = [
          'Family #1',
          'The Smith-Johnson Family',
          'Familie Müller',
          'Family (Extended)',
          '张家',
          'Family & Friends',
        ];

        for (final name in unusualNames) {
          // Arrange
          final family = Family(
            id: 'unusual-$name',
            name: name,
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
            description: 'Description for $name',
          );

          // Assert - Should handle without errors
          expect(family.name, equals(name));
          expect(family.toString(), contains(name));
          expect(() => family.copyWith(), returnsNormally);
        }
      });

      test('should maintain immutability of collections', () {
        // Arrange
        final originalMembers = [adminMember];
        final family = Family(
          id: 'immutable-test',
          name: 'Immutable Family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          members: originalMembers,
        );

        // Act - Try to modify the original list
        originalMembers.add(regularMember1);

        // Assert - Family should not be affected
        expect(family.members, hasLength(1));
        expect(family.totalMembers, equals(1));
      });

      test('should handle DateTime edge cases', () {
        // Test with edge dates
        final edgeDates = [
          DateTime.utc(1970), // Unix epoch
          DateTime.utc(2038, 1, 19), // Future date near 32-bit limit
          DateTime.now(),
          DateTime.now().add(
            const Duration(days: 365 * 10),
          ), // 10 years in future
        ];

        for (final date in edgeDates) {
          // Arrange
          final family = Family(
            id: 'edge-date-family',
            name: 'Edge Date Family',
            createdAt: date,
            updatedAt: date.add(const Duration(hours: 1)),
          );

          // Assert - Should handle edge dates without issues
          expect(family.createdAt, equals(date));
          expect(family.updatedAt.isAfter(family.createdAt), isTrue);
          expect(() => family.toString(), returnsNormally);
        }
      });
    });
  });
}
