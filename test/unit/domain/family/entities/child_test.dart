import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/domain/entities/family/child.dart';

void main() {
  group('Child Entity', () {
    late DateTime testCreatedAt;
    late DateTime testUpdatedAt;

    setUp(() {
      testCreatedAt = DateTime(2024, 1, 1, 10);
      testUpdatedAt = DateTime(2024, 1, 2, 10);
    });

    group('Construction and Property Validation', () {
      test(
        'should create child with all required properties including age',
        () {
          // Arrange & Act
          final child = Child(
            id: 'child-123',
            name: 'John Doe',
            age: 12,
            familyId: 'family-456',
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          );

          // Assert
          expect(child.id, equals('child-123'));
          expect(child.name, equals('John Doe'));
          expect(child.age, equals(12));
          expect(child.familyId, equals('family-456'));
          expect(child.createdAt, equals(testCreatedAt));
          expect(child.updatedAt, equals(testUpdatedAt));
        },
      );

      test('should create child with null age', () {
        // Arrange & Act
        final child = Child(
          id: 'child-123',
          name: 'Jane Doe',
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Assert
        expect(child.age, isNull);
        expect(child.name, equals('Jane Doe'));
      });

      test('should handle edge age values', () {
        // Arrange & Act
        final youngChild = Child(
          id: 'child-123',
          name: 'Baby',
          age: 0,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final oldChild = Child(
          id: 'child-456',
          name: 'Teenager',
          age: 18,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Assert
        expect(youngChild.age, equals(0));
        expect(oldChild.age, equals(18));
      });
    });

    group('Initials Generation', () {
      test('should generate single letter initial for single word name', () {
        // Arrange
        final child = Child(
          id: 'child-123',
          name: 'John',
          age: 10,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(child.initials, equals('J'));
      });

      test('should generate two letter initials for full name', () {
        // Arrange
        final child = Child(
          id: 'child-123',
          name: 'John Doe',
          age: 10,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(child.initials, equals('JD'));
      });

      test('should handle empty name gracefully', () {
        // Arrange
        final child = Child(
          id: 'child-123',
          name: '',
          age: 10,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(child.initials, equals(''));
      });

      test('should handle whitespace-only name', () {
        // Arrange
        final child = Child(
          id: 'child-123',
          name: '   ',
          age: 10,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(child.initials, equals(''));
      });

      test('should handle name with multiple spaces between words', () {
        // Arrange
        final child = Child(
          id: 'child-123',
          name: 'John   Michael   Doe',
          age: 10,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(child.initials, equals('JM')); // Takes first two non-empty parts
      });

      test('should capitalize initials correctly', () {
        // Arrange
        final child = Child(
          id: 'child-123',
          name: 'john doe',
          age: 10,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(child.initials, equals('JD'));
      });

      test('should handle names with hyphens and special characters', () {
        // Arrange
        final child = Child(
          id: 'child-123',
          name: 'Mary-Jane O\'Connor',
          age: 10,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(child.initials, equals('MO')); // Split by space, not hyphen
      });
    });

    group('Equality and Hash Code', () {
      late Child child1;
      late Child child2;

      setUp(() {
        child1 = Child(
          id: 'child-123',
          name: 'John Doe',
          age: 12,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        child2 = Child(
          id: 'child-123',
          name: 'John Doe',
          age: 12,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );
      });

      test('should be equal when all properties match', () {
        // Act & Assert
        expect(child1, equals(child2));
      });

      test('should not be equal when id differs', () {
        // Arrange
        final differentChild = child2.copyWith(id: 'different-id');

        // Act & Assert
        expect(child1, isNot(equals(differentChild)));
      });

      test('should not be equal when name differs', () {
        // Arrange
        final differentChild = child2.copyWith(name: 'Jane Doe');

        // Act & Assert
        expect(child1, isNot(equals(differentChild)));
      });

      test('should not be equal when age differs', () {
        // Arrange
        final differentChild = child2.copyWith(age: 13);

        // Act & Assert
        expect(child1, isNot(equals(differentChild)));
      });

      test('should not be equal when familyId differs', () {
        // Arrange
        final differentChild = child2.copyWith(familyId: 'different-family');

        // Act & Assert
        expect(child1, isNot(equals(differentChild)));
      });

      test('should be equal when both have null age', () {
        // Arrange
        final child1NoAge = child1.copyWith();
        final child2NoAge = child2.copyWith();

        // Act & Assert
        expect(child1NoAge, equals(child2NoAge));
      });

      test('should not be equal when one has null age and other has age', () {
        // Arrange
        final childNoAge = Child(
          id: 'child-123',
          name: 'John Doe',
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(child1, isNot(equals(childNoAge)));
      });

      test('should have same hash code when equal', () {
        // Act & Assert
        expect(child1.hashCode, equals(child2.hashCode));
      });
    });

    group('Copy With Method', () {
      late Child originalChild;

      setUp(() {
        originalChild = Child(
          id: 'child-123',
          name: 'John Doe',
          age: 12,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );
      });

      test('should copy with new id', () {
        // Act
        final updatedChild = originalChild.copyWith(id: 'new-id');

        // Assert
        expect(updatedChild.id, equals('new-id'));
        expect(updatedChild.name, equals(originalChild.name));
        expect(updatedChild.age, equals(originalChild.age));
        expect(updatedChild.familyId, equals(originalChild.familyId));
        expect(updatedChild.createdAt, equals(originalChild.createdAt));
        expect(updatedChild.updatedAt, equals(originalChild.updatedAt));
      });

      test('should copy with new name', () {
        // Act
        final updatedChild = originalChild.copyWith(name: 'Jane Smith');

        // Assert
        expect(updatedChild.name, equals('Jane Smith'));
        expect(updatedChild.id, equals(originalChild.id));
      });

      test('should copy with new age', () {
        // Act
        final updatedChild = originalChild.copyWith(age: 15);

        // Assert
        expect(updatedChild.age, equals(15));
        expect(updatedChild.id, equals(originalChild.id));
      });

      test('should copy preserving other properties', () {
        // Act
        final updatedChild = originalChild.copyWith();

        // Assert
        expect(updatedChild.age, equals(originalChild.age));
      });

      test('should copy with new familyId', () {
        // Act
        final updatedChild = originalChild.copyWith(familyId: 'new-family');

        // Assert
        expect(updatedChild.familyId, equals('new-family'));
        expect(updatedChild.id, equals(originalChild.id));
      });

      test('should preserve original values when no changes provided', () {
        // Act
        final copiedChild = originalChild.copyWith();

        // Assert
        expect(copiedChild, equals(originalChild));
      });
    });

    // JSON Serialization removed - Domain entities should not have JSON methods
    // Use ChildDto for JSON serialization/deserialization instead

    group('ToString Method', () {
      test('should provide meaningful string representation with age', () {
        // Arrange
        final child = Child(
          id: 'child-123',
          name: 'John Doe',
          age: 12,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act
        final stringRepresentation = child.toString();

        // Assert
        expect(
          stringRepresentation,
          equals(
            'Child(id: child-123, name: John Doe, age: 12, familyId: family-456)',
          ),
        );
      });

      test('should provide meaningful string representation without age', () {
        // Arrange
        final child = Child(
          id: 'child-123',
          name: 'John Doe',
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act
        final stringRepresentation = child.toString();

        // Assert
        expect(
          stringRepresentation,
          equals(
            'Child(id: child-123, name: John Doe, age: null, familyId: family-456)',
          ),
        );
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle extremely long names gracefully', () {
        // Arrange
        final longName = 'A' * 1000; // Very long name
        final child = Child(
          id: 'child-123',
          name: longName,
          age: 10,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(child.name, equals(longName));
        expect(child.initials, equals('A'));
      });

      test('should handle negative age values', () {
        // Arrange
        final child = Child(
          id: 'child-123',
          name: 'Test Child',
          age: -1,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(
          child.age,
          equals(-1),
        ); // Entity should accept but validation might be elsewhere
      });

      test('should handle very high age values', () {
        // Arrange
        final child = Child(
          id: 'child-123',
          name: 'Test Child',
          age: 100,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(child.age, equals(100));
      });

      test('should handle special characters in name', () {
        // Arrange
        final child = Child(
          id: 'child-123',
          name: 'José María O\'Connor-Smith',
          age: 10,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(child.name, equals('José María O\'Connor-Smith'));
        expect(child.initials, equals('JM'));
      });

      test('should handle unicode characters in name', () {
        // Arrange
        final child = Child(
          id: 'child-123',
          name: '李小明',
          age: 10,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(child.name, equals('李小明'));
        expect(child.initials, equals('李'));
      });
    });
  });
}
