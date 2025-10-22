// TRUTH: Clean Vehicle Entity Tests
// Tests Vehicle domain entity WITHOUT JSON methods (use VehicleDto for JSON)

import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/domain/entities/family.dart';

void main() {
  group('Vehicle Domain Entity', () {
    late DateTime testCreatedAt;
    late DateTime testUpdatedAt;

    setUp(() {
      testCreatedAt = DateTime.parse('2024-01-10T08:00:00.000Z');
      testUpdatedAt = DateTime.parse('2024-01-15T10:30:00.000Z');
    });

    group('Constructor and Basic Properties', () {
      test('should create vehicle with all required fields', () {
        // Act
        final vehicle = Vehicle(
          id: 'vehicle-123',
          name: 'Family Van',
          capacity: 7,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Assert
        expect(vehicle.id, equals('vehicle-123'));
        expect(vehicle.name, equals('Family Van'));
        expect(vehicle.capacity, equals(7));
        expect(vehicle.familyId, equals('family-456'));
        expect(vehicle.createdAt, equals(testCreatedAt));
        expect(vehicle.updatedAt, equals(testUpdatedAt));
        expect(vehicle.description, isNull);
      });

      test('should create vehicle with optional description', () {
        // Act
        final vehicle = Vehicle(
          id: 'vehicle-123',
          name: 'Family Van',
          capacity: 7,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          description: 'Blue Toyota Sienna',
        );

        // Assert
        expect(vehicle.description, equals('Blue Toyota Sienna'));
      });
    });

    group('Equality and Hash Code', () {
      test('should be equal when all properties match', () {
        // Arrange
        final vehicle1 = Vehicle(
          id: 'vehicle-123',
          name: 'Family Van',
          capacity: 7,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          description: 'Blue Toyota',
        );

        final vehicle2 = Vehicle(
          id: 'vehicle-123',
          name: 'Family Van',
          capacity: 7,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          description: 'Blue Toyota',
        );

        // Assert
        expect(vehicle1, equals(vehicle2));
        expect(vehicle1.hashCode, equals(vehicle2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        final vehicle1 = Vehicle(
          id: 'vehicle-123',
          name: 'Family Van',
          capacity: 7,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final vehicle2 = Vehicle(
          id: 'vehicle-124', // Different ID
          name: 'Family Van',
          capacity: 7,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Assert
        expect(vehicle1, isNot(equals(vehicle2)));
      });
    });

    group('Copy With Method', () {
      late Vehicle originalVehicle;

      setUp(() {
        originalVehicle = Vehicle(
          id: 'vehicle-123',
          name: 'Family Van',
          capacity: 7,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          description: 'Blue Toyota',
        );
      });

      test('should create copy with updated name', () {
        // Act
        final updatedVehicle = originalVehicle.copyWith(name: 'Updated Van');

        // Assert
        expect(updatedVehicle.name, equals('Updated Van'));
        expect(updatedVehicle.id, equals(originalVehicle.id));
        expect(updatedVehicle.capacity, equals(originalVehicle.capacity));
        expect(
          originalVehicle.name,
          equals('Family Van'),
        ); // Original unchanged
      });

      test('should create copy with updated capacity', () {
        // Act
        final updatedVehicle = originalVehicle.copyWith(capacity: 8);

        // Assert
        expect(updatedVehicle.capacity, equals(8));
        expect(updatedVehicle.name, equals(originalVehicle.name));
        expect(originalVehicle.capacity, equals(7)); // Original unchanged
      });

      test('should create copy with updated description', () {
        // Act
        final updatedVehicle = originalVehicle.copyWith(
          description: 'Red Honda',
        );

        // Assert
        expect(updatedVehicle.description, equals('Red Honda'));
        expect(updatedVehicle.id, equals(originalVehicle.id));
        expect(
          originalVehicle.description,
          equals('Blue Toyota'),
        ); // Original unchanged
      });

      test('should create identical copy when no parameters provided', () {
        // Act
        final copiedVehicle = originalVehicle.copyWith();

        // Assert
        expect(copiedVehicle, equals(originalVehicle));
      });
    });

    group('toString Method', () {
      test('should provide meaningful string representation', () {
        // Arrange
        final vehicle = Vehicle(
          id: 'vehicle-123',
          name: 'Family Van',
          capacity: 7,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act
        final result = vehicle.toString();

        // Assert
        expect(result, contains('Vehicle('));
        expect(result, contains('id: vehicle-123'));
        expect(result, contains('name: Family Van'));
        expect(result, contains('capacity: 7'));
      });
    });

    group('Business Logic Methods', () {
      test('should validate capacity constraints', () {
        // Should handle realistic capacity values
        final validCapacities = [1, 5, 7, 8, 12, 15, 50];

        for (final capacity in validCapacities) {
          final vehicle = Vehicle(
            id: 'vehicle-$capacity',
            name: 'Test Vehicle',
            capacity: capacity,
            familyId: 'family-123',
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          );

          expect(vehicle.capacity, equals(capacity));
        }
      });

      test('should handle edge case capacities', () {
        // Test with edge cases (0 and negative values if allowed by business rules)
        final edgeCases = [0, -1]; // Adjust based on business requirements

        for (final capacity in edgeCases) {
          final vehicle = Vehicle(
            id: 'vehicle-edge',
            name: 'Edge Case Vehicle',
            capacity: capacity,
            familyId: 'family-123',
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          );

          expect(vehicle.capacity, equals(capacity));
        }
      });
    });

    group('Data Integrity', () {
      test('should maintain data integrity through transformations', () {
        // Arrange
        final originalVehicle = Vehicle(
          id: 'vehicle-123',
          name: 'Family Van',
          capacity: 7,
          familyId: 'family-123',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          description: 'Toyota 2020',
        );

        // Act - multiple transformations
        final transformed = originalVehicle
            .copyWith(name: 'Updated Van')
            .copyWith(capacity: 8)
            .copyWith(name: originalVehicle.name);

        // Assert - only capacity should be different
        expect(transformed.id, equals(originalVehicle.id));
        expect(transformed.name, equals(originalVehicle.name)); // Reverted back
        expect(transformed.capacity, equals(8)); // Should be updated
        expect(transformed.familyId, equals(originalVehicle.familyId));
        expect(
          transformed.description,
          equals(originalVehicle.description),
        ); // Preserved
        expect(transformed.createdAt, equals(originalVehicle.createdAt));
        expect(transformed.updatedAt, equals(originalVehicle.updatedAt));
      });

      test('should handle realistic vehicle data combinations', () {
        // Arrange & act
        final realisticVehicles = [
          Vehicle(
            id: 'v1',
            name: 'Honda Civic',
            capacity: 5,
            familyId: 'family-123',
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
            description: 'Honda Civic 2020 Silver',
          ),
          Vehicle(
            id: 'v2',
            name: 'Toyota Sienna',
            capacity: 8,
            familyId: 'family-123',
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
            description: 'Toyota Sienna 2019 Blue',
          ),
          Vehicle(
            id: 'v3',
            name: 'School Bus',
            capacity: 50,
            familyId: 'family-123',
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
            description: 'Blue Bird Vision 2019 Yellow',
          ),
        ];

        for (final vehicle in realisticVehicles) {
          // Assert - should handle all realistic scenarios
          expect(vehicle.id, isNotEmpty);
          expect(vehicle.name, isNotEmpty);
          expect(vehicle.capacity, greaterThan(0));
          expect(vehicle.familyId, isNotEmpty);
          expect(vehicle.toString(), isNotEmpty);
        }
      });
    });
  });
}
