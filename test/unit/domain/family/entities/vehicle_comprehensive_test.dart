import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/domain/entities/family.dart';

/// Comprehensive Vehicle Entity Tests
/// Tests all business logic methods and edge cases for Vehicle domain entity
void main() {
  group('Vehicle Business Logic - Comprehensive Tests', () {
    late DateTime testCreatedAt;
    late DateTime testUpdatedAt;

    setUp(() {
      testCreatedAt = DateTime.parse('2024-01-10T08:00:00.000Z');
      testUpdatedAt = DateTime.parse('2024-01-15T10:30:00.000Z');
    });

    group('Initials Generation', () {
      test('should generate single initial for single word name', () {
        // Arrange
        final vehicle = Vehicle(
          id: 'vehicle-123',
          name: 'Sedan',
          capacity: 5,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(vehicle.initials, equals('S'));
      });

      test('should generate two initials for two word name', () {
        // Arrange
        final vehicle = Vehicle(
          id: 'vehicle-123',
          name: 'Family Van',
          capacity: 7,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(vehicle.initials, equals('FV'));
      });

      test('should generate two initials for multi-word name', () {
        // Arrange
        final vehicle = Vehicle(
          id: 'vehicle-123',
          name: 'Honda Civic Sedan Sport',
          capacity: 5,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(vehicle.initials, equals('HC')); // First two words
      });

      test('should handle empty name with default V', () {
        // Arrange
        final vehicle = Vehicle(
          id: 'vehicle-123',
          name: '',
          capacity: 5,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(vehicle.initials, equals('V'));
      });

      test('should handle whitespace-only name with default V', () {
        // Arrange
        final vehicle = Vehicle(
          id: 'vehicle-123',
          name: '   ',
          capacity: 5,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(vehicle.initials, equals('V'));
      });

      test('should handle names with multiple spaces', () {
        // Arrange
        final vehicle = Vehicle(
          id: 'vehicle-123',
          name: 'Blue   Honda   Civic',
          capacity: 5,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(vehicle.initials, equals('BH')); // First two non-empty parts
      });

      test('should capitalize initials correctly', () {
        // Arrange
        final vehicle = Vehicle(
          id: 'vehicle-123',
          name: 'family van',
          capacity: 7,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(vehicle.initials, equals('FV'));
      });

      test('should handle special characters in name', () {
        // Arrange
        final vehicle = Vehicle(
          id: 'vehicle-123',
          name: 'Mom\'s Car-Van',
          capacity: 7,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(
          vehicle.initials,
          equals('MC'),
        ); // Split by space, not hyphen/apostrophe
      });
    });

    group('Available Passenger Seats Logic', () {
      test('should calculate available passenger seats correctly', () {
        // Test cases: capacity -> expected passenger seats
        // IMPORTANT: capacity = child seats only (driver NOT included)
        final testCases = {
          1: 1, // 1 child seat
          2: 2, // 2 child seats
          5: 5, // Standard sedan - 5 child seats
          7: 7, // Family van - 7 child seats
          8: 8, // Large van - 8 child seats
          15: 15, // Mini bus - 15 child seats
          50: 50, // Bus - 50 child seats
        };

        testCases.forEach((capacity, expectedPassengerSeats) {
          // Arrange
          final vehicle = Vehicle(
            id: 'vehicle-$capacity',
            name: 'Test Vehicle',
            capacity: capacity,
            familyId: 'family-456',
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          );

          // Act & Assert
          expect(
            vehicle.availablePassengerSeats,
            equals(expectedPassengerSeats),
            reason:
                'Vehicle with capacity $capacity should have $expectedPassengerSeats passenger seats',
          );
        });
      });

      test('should handle edge cases for passenger seat calculation', () {
        // Arrange - Zero capacity vehicle
        final zeroCapacityVehicle = Vehicle(
          id: 'vehicle-0',
          name: 'Zero Capacity',
          capacity: 0,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(zeroCapacityVehicle.availablePassengerSeats, equals(0));
      });

      test('should handle negative capacity gracefully', () {
        // Arrange
        final negativeVehicle = Vehicle(
          id: 'vehicle-neg',
          name: 'Negative Vehicle',
          capacity: -1,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(negativeVehicle.availablePassengerSeats, equals(-1));
      });
    });

    group('Can Accommodate Logic', () {
      test(
        'should correctly determine if vehicle can accommodate children',
        () {
          // Arrange
          final familyVan = Vehicle(
            id: 'vehicle-van',
            name: 'Family Van',
            capacity: 7, // 7 child seats (driver NOT included)
            familyId: 'family-456',
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          );

          // Act & Assert - Test various child counts
          expect(familyVan.canAccommodate(0), isTrue); // No children
          expect(familyVan.canAccommodate(1), isTrue); // 1 child
          expect(familyVan.canAccommodate(3), isTrue); // 3 children
          expect(familyVan.canAccommodate(7), isTrue); // Exactly max capacity
          expect(familyVan.canAccommodate(8), isFalse); // Over capacity
          expect(familyVan.canAccommodate(10), isFalse); // Way over capacity
        },
      );

      test('should handle edge case vehicles for accommodation', () {
        // Arrange - Single child seat vehicle
        final singleSeat = Vehicle(
          id: 'vehicle-single',
          name: 'Small Car',
          capacity: 1,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(singleSeat.canAccommodate(0), isTrue); // No passengers
        expect(singleSeat.canAccommodate(1), isTrue); // Can accommodate 1 child
        expect(
          singleSeat.canAccommodate(2),
          isFalse,
        ); // Cannot accommodate 2 children

        // Arrange - Two child seat vehicle
        final twoSeat = Vehicle(
          id: 'vehicle-two',
          name: 'Sports Car',
          capacity: 2,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(twoSeat.canAccommodate(0), isTrue);
        expect(twoSeat.canAccommodate(1), isTrue);
        expect(twoSeat.canAccommodate(2), isTrue); // 2 child seats available
        expect(twoSeat.canAccommodate(3), isFalse);
      });

      test('should handle negative child count', () {
        // Arrange
        final vehicle = Vehicle(
          id: 'vehicle-test',
          name: 'Test Vehicle',
          capacity: 5,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(
          vehicle.canAccommodate(-1),
          isTrue,
        ); // Negative count should return true
        expect(vehicle.canAccommodate(-5), isTrue);
      });

      test('should handle zero capacity vehicle accommodation', () {
        // Arrange
        final zeroCapacity = Vehicle(
          id: 'vehicle-zero',
          name: 'No Capacity',
          capacity: 0,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(
          zeroCapacity.canAccommodate(0),
          isTrue,
        ); // Zero capacity can accommodate zero children
        expect(
          zeroCapacity.canAccommodate(1),
          isFalse,
        ); // Cannot accommodate any children
      });
    });

    group('Display Name With Capacity', () {
      test('should format display name with capacity correctly', () {
        // Test various name and capacity combinations
        final testCases = [
          {
            'name': 'Honda Civic',
            'capacity': 5,
            'expected': 'Honda Civic (5 places enfants)',
          },
          {
            'name': 'Family Van',
            'capacity': 7,
            'expected': 'Family Van (7 places enfants)',
          },
          {
            'name': 'School Bus',
            'capacity': 50,
            'expected': 'School Bus (50 places enfants)',
          },
          {
            'name': 'Small Car',
            'capacity': 1,
            'expected': 'Small Car (1 places enfants)',
          },
        ];

        for (final testCase in testCases) {
          // Arrange
          final vehicle = Vehicle(
            id: 'vehicle-test',
            name: testCase['name'] as String,
            capacity: testCase['capacity'] as int,
            familyId: 'family-456',
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          );

          // Act & Assert
          expect(
            vehicle.displayNameWithCapacity,
            equals(testCase['expected']),
            reason:
                'Display name should format correctly for ${testCase['name']}',
          );
        }
      });

      test('should handle empty name in display', () {
        // Arrange
        final vehicle = Vehicle(
          id: 'vehicle-empty',
          name: '',
          capacity: 5,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(vehicle.displayNameWithCapacity, equals(' (5 places enfants)'));
      });

      test('should handle zero capacity in display', () {
        // Arrange
        final vehicle = Vehicle(
          id: 'vehicle-zero',
          name: 'No Capacity Vehicle',
          capacity: 0,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(
          vehicle.displayNameWithCapacity,
          equals('No Capacity Vehicle (0 places enfants)'),
        );
      });

      test('should handle long names in display', () {
        // Arrange
        const longName =
            'Super Long Vehicle Name With Many Words That Describes Everything';
        final vehicle = Vehicle(
          id: 'vehicle-long',
          name: longName,
          capacity: 8,
          familyId: 'family-456',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(
          vehicle.displayNameWithCapacity,
          equals('$longName (8 places enfants)'),
        );
      });
    });

    group('Business Logic Integration Tests', () {
      test('should maintain consistent business logic across methods', () {
        // Arrange - Create a variety of realistic vehicles
        final vehicles = [
          Vehicle(
            id: 'compact-car',
            name: 'Honda Civic',
            capacity: 5,
            familyId: 'family-1',
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
            description: '2020 Honda Civic Sedan',
          ),
          Vehicle(
            id: 'family-van',
            name: 'Toyota Sienna',
            capacity: 8,
            familyId: 'family-1',
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
            description: '2019 Toyota Sienna Minivan',
          ),
          Vehicle(
            id: 'school-bus',
            name: 'Blue Bird Vision',
            capacity: 35,
            familyId: 'family-school',
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
            description: 'School District Bus #123',
          ),
        ];

        for (final vehicle in vehicles) {
          // Test consistency between capacity and passenger seats
          expect(
            vehicle.availablePassengerSeats,
            equals(vehicle.capacity),
            reason:
                'Passenger seats equals capacity (driver NOT included in capacity)',
          );

          // Test that canAccommodate is consistent with passenger seats
          expect(
            vehicle.canAccommodate(vehicle.availablePassengerSeats),
            isTrue,
            reason:
                'Should be able to accommodate exactly the available passenger seats',
          );

          expect(
            vehicle.canAccommodate(vehicle.availablePassengerSeats + 1),
            isFalse,
            reason:
                'Should not accommodate more than available passenger seats',
          );

          // Test display name consistency
          expect(
            vehicle.displayNameWithCapacity,
            contains(vehicle.name),
            reason: 'Display name should contain the vehicle name',
          );

          expect(
            vehicle.displayNameWithCapacity,
            contains('${vehicle.capacity} places enfants'),
            reason: 'Display name should contain the capacity',
          );

          // Test initials are not empty (unless name is empty)
          if (vehicle.name.trim().isNotEmpty) {
            expect(
              vehicle.initials,
              isNotEmpty,
              reason: 'Initials should not be empty for non-empty names',
            );

            expect(
              vehicle.initials.length,
              isIn([1, 2]),
              reason: 'Initials should be 1 or 2 characters',
            );
          }
        }
      });

      test('should handle realistic family scenarios', () {
        // Arrange - Typical family vehicles
        final familyCar = Vehicle(
          id: 'family-sedan',
          name: 'Toyota Camry',
          capacity: 5, // 5 child seats (driver NOT included)
          familyId: 'family-smith',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final familyVan = Vehicle(
          id: 'family-van',
          name: 'Honda Odyssey',
          capacity: 8, // 8 child seats (driver NOT included)
          familyId: 'family-smith',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert - Typical family scenarios

        // Small family (2 children)
        expect(familyCar.canAccommodate(2), isTrue);
        expect(familyVan.canAccommodate(2), isTrue);

        // Medium family (4 children)
        expect(familyCar.canAccommodate(4), isTrue);
        expect(familyVan.canAccommodate(4), isTrue);

        // Medium family (5 children)
        expect(familyCar.canAccommodate(5), isTrue); // Exactly fits
        expect(familyVan.canAccommodate(5), isTrue);

        // Large family (6 children)
        expect(familyCar.canAccommodate(6), isFalse); // Doesn't fit
        expect(familyVan.canAccommodate(6), isTrue);

        // Large family (8 children)
        expect(familyCar.canAccommodate(8), isFalse);
        expect(familyVan.canAccommodate(8), isTrue); // Exactly fits

        // Very large family (9 children)
        expect(familyCar.canAccommodate(9), isFalse);
        expect(familyVan.canAccommodate(9), isFalse); // Over van capacity

        // Test display information is helpful
        expect(
          familyCar.displayNameWithCapacity,
          equals('Toyota Camry (5 places enfants)'),
        );
        expect(
          familyVan.displayNameWithCapacity,
          equals('Honda Odyssey (8 places enfants)'),
        );

        // Test initials are generated
        expect(familyCar.initials, equals('TC'));
        expect(familyVan.initials, equals('HO'));
      });
    });

    group('Edge Cases and Error Boundaries', () {
      test('should handle extreme capacity values', () {
        // Arrange - Very large capacity
        final largeBus = Vehicle(
          id: 'large-bus',
          name: 'Mega Bus',
          capacity: 100,
          familyId: 'transport-company',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(largeBus.availablePassengerSeats, equals(100));
        expect(largeBus.canAccommodate(100), isTrue);
        expect(largeBus.canAccommodate(101), isFalse);
        expect(
          largeBus.displayNameWithCapacity,
          equals('Mega Bus (100 places enfants)'),
        );
        expect(largeBus.initials, equals('MB'));
      });

      test('should handle unusual but valid names', () {
        final specialNames = [
          'Car #1',
          'Mom\'s Vehicle',
          'Family Car & Van',
          'Vehicle (New)',
          '2020 Honda Civic',
          'Car-Van Hybrid',
        ];

        for (final name in specialNames) {
          // Arrange
          final vehicle = Vehicle(
            id: 'special-$name',
            name: name,
            capacity: 5,
            familyId: 'family-test',
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          );

          // Act & Assert - Should not throw errors
          expect(() => vehicle.initials, returnsNormally);
          expect(() => vehicle.displayNameWithCapacity, returnsNormally);
          expect(() => vehicle.availablePassengerSeats, returnsNormally);
          expect(() => vehicle.canAccommodate(3), returnsNormally);

          // Verify basic properties
          expect(vehicle.name, equals(name));
          expect(vehicle.initials, isA<String>());
          expect(vehicle.displayNameWithCapacity, contains(name));
        }
      });

      test('should handle maximum integer capacity', () {
        // This tests the theoretical limit - not practically useful but tests robustness
        const maxInt = 2147483647; // Max 32-bit integer

        // Arrange
        final extremeVehicle = Vehicle(
          id: 'extreme',
          name: 'Extreme Vehicle',
          capacity: maxInt,
          familyId: 'test-family',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert - Should handle without overflow
        expect(extremeVehicle.capacity, equals(maxInt));
        expect(extremeVehicle.availablePassengerSeats, equals(maxInt));
        expect(extremeVehicle.canAccommodate(maxInt), isTrue);
        expect(extremeVehicle.canAccommodate(maxInt + 1), isFalse);
      });
    });
  });
}
