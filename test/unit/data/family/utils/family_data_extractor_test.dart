// EduLift Mobile - FamilyDataExtractor Unit Tests
// Following FLUTTER_TESTING_RESEARCH_2025.md - Data Layer Testing
// TRUTH: Tests NEW utility class that replaces redundant datasource methods
// Coverage Target: 95%+ for data layer utilities

import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/features/family/data/utils/family_data_extractor.dart';
import 'package:edulift/core/network/models/family/family_dto.dart';
import 'package:edulift/core/network/models/family/family_member_dto.dart';
import 'package:edulift/core/network/models/child/child_dto.dart';
import 'package:edulift/core/network/models/vehicle/vehicle_dto.dart';

void main() {
  group('FamilyDataExtractor', () {
    group('extractChildren', () {
      test('should return empty list when family.children is null', () {
        // ARRANGE
        const family = FamilyDto(id: 'test-family-id', name: 'Test Family');

        // ACT
        final result = FamilyDataExtractor.extractChildren(family);

        // ASSERT
        expect(result, isEmpty);
        expect(result, isA<List<ChildDto>>());
      });

      test('should return empty list when family.children is empty', () {
        // ARRANGE
        const family = FamilyDto(
          id: 'test-family-id',
          name: 'Test Family',
          children: [], // EMPTY CASE
        );

        // ACT
        final result = FamilyDataExtractor.extractChildren(family);

        // ASSERT
        expect(result, isEmpty);
        expect(result, isA<List<ChildDto>>());
      });

      test('should return populated list when family.children has data', () {
        // ARRANGE
        const childDto1 = ChildDto(
          id: 'child-1',
          name: 'Alice',
          age: 8,
          familyId: 'test-family-id',
        );
        const childDto2 = ChildDto(
          id: 'child-2',
          name: 'Bob',
          age: 10,
          familyId: 'test-family-id',
        );
        const family = FamilyDto(
          id: 'test-family-id',
          name: 'Test Family',
          children: [childDto1, childDto2], // POPULATED CASE
        );

        // ACT
        final result = FamilyDataExtractor.extractChildren(family);

        // ASSERT
        expect(result, hasLength(2));
        expect(result[0], equals(childDto1));
        expect(result[1], equals(childDto2));
        expect(result, isA<List<ChildDto>>());
      });

      test('should handle single child in list', () {
        // ARRANGE
        const singleChild = ChildDto(
          id: 'child-1',
          name: 'Single Child',
          age: 5,
          familyId: 'test-family-id',
        );
        const family = FamilyDto(
          id: 'test-family-id',
          name: 'Test Family',
          children: [singleChild], // SINGLE ITEM CASE
        );

        // ACT
        final result = FamilyDataExtractor.extractChildren(family);

        // ASSERT
        expect(result, hasLength(1));
        expect(result.first, equals(singleChild));
      });

      test('should preserve original list order', () {
        // ARRANGE
        final children = [
          const ChildDto(
            id: 'child-1',
            name: 'Alice',
            age: 8,
            familyId: 'test-family-id',
          ),
          const ChildDto(
            id: 'child-2',
            name: 'Bob',
            age: 10,
            familyId: 'test-family-id',
          ),
          const ChildDto(
            id: 'child-3',
            name: 'Charlie',
            age: 6,
            familyId: 'test-family-id',
          ),
        ];
        final family = FamilyDto(
          id: 'test-family-id',
          name: 'Test Family',
          children: children,
        );

        // ACT
        final result = FamilyDataExtractor.extractChildren(family);

        // ASSERT
        expect(result, hasLength(3));
        expect(result[0].name, equals('Alice'));
        expect(result[1].name, equals('Bob'));
        expect(result[2].name, equals('Charlie'));
      });
    });

    group('extractVehicles', () {
      test('should return empty list when family.vehicles is null', () {
        // ARRANGE
        const family = FamilyDto(id: 'test-family-id', name: 'Test Family');

        // ACT
        final result = FamilyDataExtractor.extractVehicles(family);

        // ASSERT
        expect(result, isEmpty);
        expect(result, isA<List<VehicleDto>>());
      });

      test('should return empty list when family.vehicles is empty', () {
        // ARRANGE
        const family = FamilyDto(
          id: 'test-family-id',
          name: 'Test Family',
          vehicles: [], // EMPTY CASE
        );

        // ACT
        final result = FamilyDataExtractor.extractVehicles(family);

        // ASSERT
        expect(result, isEmpty);
        expect(result, isA<List<VehicleDto>>());
      });

      test('should return populated list when family.vehicles has data', () {
        // ARRANGE
        const vehicleDto1 = VehicleDto(
          id: 'vehicle-1',
          name: 'Family Van',
          capacity: 8,
          familyId: 'test-family-id',
        );
        const vehicleDto2 = VehicleDto(
          id: 'vehicle-2',
          name: 'Sedan',
          capacity: 5,
          familyId: 'test-family-id',
        );
        const family = FamilyDto(
          id: 'test-family-id',
          name: 'Test Family',
          vehicles: [vehicleDto1, vehicleDto2], // POPULATED CASE
        );

        // ACT
        final result = FamilyDataExtractor.extractVehicles(family);

        // ASSERT
        expect(result, hasLength(2));
        expect(result[0], equals(vehicleDto1));
        expect(result[1], equals(vehicleDto2));
        expect(result, isA<List<VehicleDto>>());
      });

      test('should handle single vehicle in list', () {
        // ARRANGE
        const singleVehicle = VehicleDto(
          id: 'vehicle-1',
          name: 'Single Car',
          capacity: 4,
          familyId: 'test-family-id',
        );
        const family = FamilyDto(
          id: 'test-family-id',
          name: 'Test Family',
          vehicles: [singleVehicle], // SINGLE ITEM CASE
        );

        // ACT
        final result = FamilyDataExtractor.extractVehicles(family);

        // ASSERT
        expect(result, hasLength(1));
        expect(result.first, equals(singleVehicle));
      });

      test('should preserve original list order', () {
        // ARRANGE
        final vehicles = [
          const VehicleDto(
            id: 'vehicle-1',
            name: 'Van',
            capacity: 8,
            familyId: 'test-family-id',
          ),
          const VehicleDto(
            id: 'vehicle-2',
            name: 'Sedan',
            capacity: 5,
            familyId: 'test-family-id',
          ),
          const VehicleDto(
            id: 'vehicle-3',
            name: 'SUV',
            capacity: 7,
            familyId: 'test-family-id',
          ),
        ];
        final family = FamilyDto(
          id: 'test-family-id',
          name: 'Test Family',
          vehicles: vehicles,
        );

        // ACT
        final result = FamilyDataExtractor.extractVehicles(family);

        // ASSERT
        expect(result, hasLength(3));
        expect(result[0].name, equals('Van'));
        expect(result[1].name, equals('Sedan'));
        expect(result[2].name, equals('SUV'));
      });
    });

    group('extractMembers', () {
      test('should return empty list when family.members is null', () {
        // ARRANGE
        const family = FamilyDto(id: 'test-family-id', name: 'Test Family');

        // ACT
        final result = FamilyDataExtractor.extractMembers(family);

        // ASSERT
        expect(result, isEmpty);
        expect(result, isA<List<FamilyMemberDto>>());
      });

      test('should return empty list when family.members is empty', () {
        // ARRANGE
        const family = FamilyDto(
          id: 'test-family-id',
          name: 'Test Family',
          members: [], // EMPTY CASE
        );

        // ACT
        final result = FamilyDataExtractor.extractMembers(family);

        // ASSERT
        expect(result, isEmpty);
        expect(result, isA<List<FamilyMemberDto>>());
      });

      test('should return populated list when family.members has data', () {
        // ARRANGE
        final memberDto1 = FamilyMemberDto(
          id: 'member-1',
          userId: 'user-1',
          familyId: 'test-family-id',
          role: 'admin',
          joinedAt: DateTime.now(),
          user: const UserDto(
            id: 'user-1',
            name: 'John Doe',
            email: 'john@example.com',
          ),
        );
        final memberDto2 = FamilyMemberDto(
          id: 'member-2',
          userId: 'user-2',
          familyId: 'test-family-id',
          role: 'member',
          joinedAt: DateTime.now(),
          user: const UserDto(
            id: 'user-2',
            name: 'Jane Doe',
            email: 'jane@example.com',
          ),
        );
        final family = FamilyDto(
          id: 'test-family-id',
          name: 'Test Family',
          members: [memberDto1, memberDto2], // POPULATED CASE
        );

        // ACT
        final result = FamilyDataExtractor.extractMembers(family);

        // ASSERT
        expect(result, hasLength(2));
        expect(result[0], equals(memberDto1));
        expect(result[1], equals(memberDto2));
        expect(result, isA<List<FamilyMemberDto>>());
      });

      test('should handle single member in list', () {
        // ARRANGE
        final singleMember = FamilyMemberDto(
          id: 'member-1',
          userId: 'user-1',
          familyId: 'test-family-id',
          role: 'admin',
          joinedAt: DateTime.now(),
          user: const UserDto(
            id: 'user-1',
            name: 'Solo Parent',
            email: 'solo@example.com',
          ),
        );
        final family = FamilyDto(
          id: 'test-family-id',
          name: 'Test Family',
          members: [singleMember], // SINGLE ITEM CASE
        );

        // ACT
        final result = FamilyDataExtractor.extractMembers(family);

        // ASSERT
        expect(result, hasLength(1));
        expect(result.first, equals(singleMember));
      });

      test('should preserve original list order', () {
        // ARRANGE
        final members = [
          FamilyMemberDto(
            id: 'member-1',
            userId: 'user-1',
            familyId: 'test-family-id',
            role: 'admin',
            joinedAt: DateTime.now(),
            user: const UserDto(
              id: 'user-1',
              name: 'Admin',
              email: 'admin@example.com',
            ),
          ),
          FamilyMemberDto(
            id: 'member-2',
            userId: 'user-2',
            familyId: 'test-family-id',
            role: 'member',
            joinedAt: DateTime.now(),
            user: const UserDto(
              id: 'user-2',
              name: 'Member',
              email: 'member@example.com',
            ),
          ),
          FamilyMemberDto(
            id: 'member-3',
            userId: 'user-3',
            familyId: 'test-family-id',
            role: 'guest',
            joinedAt: DateTime.now(),
            user: const UserDto(
              id: 'user-3',
              name: 'Guest',
              email: 'guest@example.com',
            ),
          ),
        ];
        final family = FamilyDto(
          id: 'test-family-id',
          name: 'Test Family',
          members: members,
        );

        // ACT
        final result = FamilyDataExtractor.extractMembers(family);

        // ASSERT
        expect(result, hasLength(3));
        expect(result[0].user?.name, equals('Admin'));
        expect(result[1].user?.name, equals('Member'));
        expect(result[2].user?.name, equals('Guest'));
      });
    });

    group('utility class behavior', () {
      test('should not be instantiable (private constructor)', () {
        // TRUTH: Verify static utility pattern
        // The class has a private constructor FamilyDataExtractor._()
        // This test documents the design intent

        // We cannot directly test private constructor instantiation failure
        // but we can verify all methods are static
        expect(FamilyDataExtractor.extractChildren, isA<Function>());
        expect(FamilyDataExtractor.extractVehicles, isA<Function>());
        expect(FamilyDataExtractor.extractMembers, isA<Function>());
      });

      test('should handle complex family DTO with all null lists', () {
        // ARRANGE
        final family = FamilyDto(
          id: 'test-family-id',
          name: 'Empty Family',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // ACT & ASSERT
        expect(FamilyDataExtractor.extractChildren(family), isEmpty);
        expect(FamilyDataExtractor.extractVehicles(family), isEmpty);
        expect(FamilyDataExtractor.extractMembers(family), isEmpty);
      });

      test(
        'should handle complex family DTO with mixed null and populated lists',
        () {
          // ARRANGE
          const family = FamilyDto(
            id: 'test-family-id',
            name: 'Mixed Family',
            children: [
              ChildDto(
                id: 'child-1',
                name: 'Alice',
                age: 8,
                familyId: 'test-family-id',
              ),
            ],
          );

          // ACT & ASSERT
          expect(FamilyDataExtractor.extractChildren(family), hasLength(1));
          expect(FamilyDataExtractor.extractVehicles(family), isEmpty);
          expect(FamilyDataExtractor.extractMembers(family), isEmpty);
        },
      );
    });

    group('edge cases and error conditions', () {
      test('should handle family with all properties populated', () {
        // ARRANGE - COMPREHENSIVE TEST CASE
        final family = FamilyDto(
          id: 'comprehensive-family-id',
          name: 'Comprehensive Family',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          children: [
            const ChildDto(
              id: 'child-1',
              name: 'Alice',
              age: 8,
              familyId: 'comprehensive-family-id',
            ),
            const ChildDto(
              id: 'child-2',
              name: 'Bob',
              age: 10,
              familyId: 'comprehensive-family-id',
            ),
          ],
          vehicles: [
            const VehicleDto(
              id: 'vehicle-1',
              name: 'Van',
              capacity: 8,
              familyId: 'comprehensive-family-id',
            ),
          ],
          members: [
            FamilyMemberDto(
              id: 'member-1',
              userId: 'user-1',
              familyId: 'comprehensive-family-id',
              role: 'admin',
              joinedAt: DateTime.now(),
              user: const UserDto(
                id: 'user-1',
                name: 'Parent 1',
                email: 'parent1@example.com',
              ),
            ),
            FamilyMemberDto(
              id: 'member-2',
              userId: 'user-2',
              familyId: 'comprehensive-family-id',
              role: 'member',
              joinedAt: DateTime.now(),
              user: const UserDto(
                id: 'user-2',
                name: 'Parent 2',
                email: 'parent2@example.com',
              ),
            ),
          ],
        );

        // ACT
        final children = FamilyDataExtractor.extractChildren(family);
        final vehicles = FamilyDataExtractor.extractVehicles(family);
        final members = FamilyDataExtractor.extractMembers(family);

        // ASSERT
        expect(children, hasLength(2));
        expect(vehicles, hasLength(1));
        expect(members, hasLength(2));

        // Verify data integrity
        expect(children[0].name, equals('Alice'));
        expect(children[1].name, equals('Bob'));
        expect(vehicles[0].name, equals('Van'));
        expect(members[0].role, equals('admin'));
        expect(members[1].role, equals('member'));
      });

      test('should return new list instances (not references)', () {
        // ARRANGE
        final originalChildren = [
          const ChildDto(
            id: 'child-1',
            name: 'Original',
            age: 8,
            familyId: 'test-family-id',
          ),
        ];
        final family = FamilyDto(
          id: 'test-family-id',
          name: 'Test Family',
          children: originalChildren,
        );

        // ACT
        final extractedChildren = FamilyDataExtractor.extractChildren(family);

        // ASSERT - TRUTH: Verify we get a new list, not a reference
        expect(extractedChildren, isNot(same(originalChildren)));
        expect(extractedChildren, equals(originalChildren)); // Same content
        expect(extractedChildren, isA<List<ChildDto>>());
      });
    });
  });
}
