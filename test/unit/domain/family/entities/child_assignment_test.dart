import 'package:flutter_test/flutter_test.dart';

import 'package:edulift/core/domain/entities/family.dart';

void main() {
  group('ChildAssignment Entity Tests', () {
    late DateTime testDateTime;
    late DateTime testAssignmentDate;

    setUp(() {
      testDateTime = DateTime(2024, 1, 1, 10);
      testAssignmentDate = DateTime(2024, 1, 15, 8, 30);
    });

    group('Main Constructor', () {
      test('should create assignment with all required fields', () {
        // Arrange & Act
        final assignment = ChildAssignment(
          id: 'assignment-123',
          childId: 'child-456',
          assignmentType: 'transportation',
          assignmentId: 'transport-789',
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        // Assert
        expect(assignment.id, equals('assignment-123'));
        expect(assignment.childId, equals('child-456'));
        expect(assignment.assignmentType, equals('transportation'));
        expect(assignment.assignmentId, equals('transport-789'));
        expect(assignment.createdAt, equals(testDateTime));
        expect(assignment.updatedAt, equals(testDateTime));
        expect(assignment.isActive, isTrue);
      });

      test('should create assignment with optional fields', () {
        // Arrange & Act
        final assignment = ChildAssignment(
          id: 'assignment-123',
          childId: 'child-456',
          assignmentType: 'transportation',
          assignmentId: 'transport-789',
          createdAt: testDateTime,
          groupId: 'group-123',
          scheduleSlotId: 'slot-456',
          vehicleAssignmentId: 'vehicle-789',
          status: AssignmentStatus.confirmed,
          assignmentDate: testAssignmentDate,
          notes: 'Special pickup instructions',
          metadata: const {'priority': 'high', 'special_needs': true},
        );

        // Assert
        expect(assignment.groupId, equals('group-123'));
        expect(assignment.scheduleSlotId, equals('slot-456'));
        expect(assignment.vehicleAssignmentId, equals('vehicle-789'));
        expect(assignment.status, equals(AssignmentStatus.confirmed));
        expect(assignment.assignmentDate, equals(testAssignmentDate));
        expect(assignment.notes, equals('Special pickup instructions'));
        expect(assignment.metadata?['priority'], equals('high'));
        expect(assignment.metadata?['special_needs'], isTrue);
      });

      test('should create assignment with pickup/schedule fields', () {
        // Arrange & Act
        final assignment = ChildAssignment(
          id: 'assignment-123',
          childId: 'child-456',
          assignmentType: 'schedule',
          assignmentId: 'schedule-789',
          createdAt: testDateTime,
          childName: 'John Doe',
          familyId: 'family-123',
          familyName: 'Doe Family',
          pickupAddress: '123 Main St, City, State',
          pickupLat: 37.7749,
          pickupLng: -122.4194,
          pickupTime: testAssignmentDate.add(const Duration(minutes: 30)),
          dropoffTime: testAssignmentDate.add(const Duration(hours: 8)),
        );

        // Assert
        expect(assignment.childName, equals('John Doe'));
        expect(assignment.familyId, equals('family-123'));
        expect(assignment.familyName, equals('Doe Family'));
        expect(assignment.pickupAddress, equals('123 Main St, City, State'));
        expect(assignment.pickupLat, equals(37.7749));
        expect(assignment.pickupLng, equals(-122.4194));
        expect(
          assignment.pickupTime,
          equals(testAssignmentDate.add(const Duration(minutes: 30))),
        );
        expect(
          assignment.dropoffTime,
          equals(testAssignmentDate.add(const Duration(hours: 8))),
        );
      });

      test('should default isActive to true when not specified', () {
        // Arrange & Act
        final assignment = ChildAssignment(
          id: 'assignment-123',
          childId: 'child-456',
          assignmentType: 'transportation',
          assignmentId: 'transport-789',
          createdAt: testDateTime,
        );

        // Assert
        expect(assignment.isActive, isTrue);
      });

      test('should handle null optional fields', () {
        // Arrange & Act
        final assignment = ChildAssignment(
          id: 'assignment-123',
          childId: 'child-456',
          assignmentType: 'transportation',
          assignmentId: 'transport-789',
          createdAt: testDateTime,
        );

        // Assert
        expect(assignment.updatedAt, isNull);
        expect(assignment.metadata, isNull);
        expect(assignment.groupId, isNull);
        expect(assignment.scheduleSlotId, isNull);
        expect(assignment.vehicleAssignmentId, isNull);
        expect(assignment.status, isNull);
        expect(assignment.assignmentDate, isNull);
        expect(assignment.notes, isNull);
        expect(assignment.childName, isNull);
        expect(assignment.familyId, isNull);
        expect(assignment.familyName, isNull);
        expect(assignment.pickupAddress, isNull);
        expect(assignment.pickupLat, isNull);
        expect(assignment.pickupLng, isNull);
        expect(assignment.pickupTime, isNull);
        expect(assignment.dropoffTime, isNull);
      });
    });

    group('Transportation Factory Constructor', () {
      test('should create transportation assignment with all fields', () {
        // Arrange & Act
        final assignment = ChildAssignment.transportation(
          id: 'transport-assignment-123',
          childId: 'child-456',
          groupId: 'group-789',
          scheduleSlotId: 'slot-012',
          vehicleAssignmentId: 'vehicle-345',
          assignedAt: testDateTime,
          status: AssignmentStatus.confirmed,
          assignmentDate: testAssignmentDate,
          notes: 'Morning pickup route',
        );

        // Assert
        expect(assignment.id, equals('transport-assignment-123'));
        expect(assignment.childId, equals('child-456'));
        expect(assignment.assignmentType, equals('transportation'));
        expect(assignment.groupId, equals('group-789'));
        expect(assignment.scheduleSlotId, equals('slot-012'));
        expect(assignment.vehicleAssignmentId, equals('vehicle-345'));
        expect(assignment.createdAt, equals(testDateTime));
        expect(assignment.status, equals(AssignmentStatus.confirmed));
        expect(assignment.assignmentDate, equals(testAssignmentDate));
        expect(assignment.notes, equals('Morning pickup route'));
        expect(assignment.isActive, isTrue);
      });

      test('should create transportation assignment without notes', () {
        // Arrange & Act
        final assignment = ChildAssignment.transportation(
          id: 'transport-assignment-123',
          childId: 'child-456',
          groupId: 'group-789',
          scheduleSlotId: 'slot-012',
          vehicleAssignmentId: 'vehicle-345',
          assignedAt: testDateTime,
          status: AssignmentStatus.pending,
          assignmentDate: testAssignmentDate,
        );

        // Assert
        expect(assignment.notes, isNull);
        expect(assignment.status, equals(AssignmentStatus.pending));
      });

      test('should handle all assignment status types', () {
        final statuses = [
          AssignmentStatus.pending,
          AssignmentStatus.confirmed,
          AssignmentStatus.completed,
          AssignmentStatus.cancelled,
        ];

        for (final status in statuses) {
          // Arrange & Act
          final assignment = ChildAssignment.transportation(
            id: 'transport-$status',
            childId: 'child-456',
            groupId: 'group-789',
            scheduleSlotId: 'slot-012',
            vehicleAssignmentId: 'vehicle-345',
            assignedAt: testDateTime,
            status: status,
            assignmentDate: testAssignmentDate,
          );

          // Assert
          expect(assignment.status, equals(status));
        }
      });
    });

    group('Schedule Factory Constructor', () {
      test('should create schedule assignment with all required fields', () {
        // Arrange & Act
        final assignment = ChildAssignment.schedule(
          id: 'schedule-assignment-123',
          childId: 'child-456',
          childName: 'Alice Johnson',
          familyId: 'family-789',
          familyName: 'Johnson Family',
          pickupAddress: '456 Oak Ave, Downtown',
          pickupLat: 34.0522,
          pickupLng: -118.2437,
          status: 'scheduled',
          createdAt: testDateTime,
          pickupTime: testAssignmentDate,
          dropoffTime: testAssignmentDate.add(const Duration(hours: 9)),
        );

        // Assert
        expect(assignment.id, equals('schedule-assignment-123'));
        expect(assignment.childId, equals('child-456'));
        expect(assignment.assignmentType, equals('schedule'));
        expect(assignment.childName, equals('Alice Johnson'));
        expect(assignment.familyId, equals('family-789'));
        expect(assignment.familyName, equals('Johnson Family'));
        expect(assignment.pickupAddress, equals('456 Oak Ave, Downtown'));
        expect(assignment.pickupLat, equals(34.0522));
        expect(assignment.pickupLng, equals(-118.2437));
        expect(assignment.scheduleStatus, equals('scheduled'));
        expect(assignment.createdAt, equals(testDateTime));
        expect(assignment.pickupTime, equals(testAssignmentDate));
        expect(
          assignment.dropoffTime,
          equals(testAssignmentDate.add(const Duration(hours: 9))),
        );
      });

      test('should create schedule assignment with minimal fields', () {
        // Arrange & Act
        final assignment = ChildAssignment.schedule(
          id: 'schedule-assignment-123',
          childId: 'child-456',
          childName: 'Alice Johnson',
          familyId: 'family-789',
          familyName: 'Johnson Family',
          pickupAddress: '456 Oak Ave, Downtown',
          pickupLat: 34.0522,
          pickupLng: -118.2437,
          status: 'pending',
        );

        // Assert
        expect(assignment.scheduleStatus, equals('pending'));
        expect(assignment.createdAt, isNotNull); // Should have a default
        expect(assignment.pickupTime, isNull);
        expect(assignment.dropoffTime, isNull);
      });

      test('should handle various schedule statuses', () {
        final statuses = [
          'pending',
          'scheduled',
          'in_progress',
          'completed',
          'cancelled',
        ];

        for (final status in statuses) {
          // Arrange & Act
          final assignment = ChildAssignment.schedule(
            id: 'schedule-$status',
            childId: 'child-456',
            childName: 'Test Child',
            familyId: 'family-789',
            familyName: 'Test Family',
            pickupAddress: 'Test Address',
            pickupLat: 0.0,
            pickupLng: 0.0,
            status: status,
          );

          // Assert
          expect(assignment.scheduleStatus, equals(status));
        }
      });

      test('should handle coordinates at boundaries', () {
        final coordinates = [
          {'lat': 90.0, 'lng': 180.0}, // North pole, international date line
          {'lat': -90.0, 'lng': -180.0}, // South pole, opposite date line
          {'lat': 0.0, 'lng': 0.0}, // Null island
          {'lat': 37.7749, 'lng': -122.4194}, // San Francisco
        ];

        for (final coord in coordinates) {
          // Arrange & Act
          final assignment = ChildAssignment.schedule(
            id: 'coord-test-${coord['lat']}-${coord['lng']}',
            childId: 'child-456',
            childName: 'Coordinate Test Child',
            familyId: 'family-789',
            familyName: 'Test Family',
            pickupAddress: 'Coordinate Test Address',
            pickupLat: coord['lat']!,
            pickupLng: coord['lng']!,
            status: 'scheduled',
          );

          // Assert
          expect(assignment.pickupLat, equals(coord['lat']));
          expect(assignment.pickupLng, equals(coord['lng']));
        }
      });
    });

    group('copyWith Method', () {
      late ChildAssignment baseAssignment;

      setUp(() {
        baseAssignment = ChildAssignment(
          id: 'assignment-123',
          childId: 'child-456',
          assignmentType: 'transportation',
          assignmentId: 'transport-789',
          createdAt: testDateTime,
          updatedAt: testDateTime,
          groupId: 'group-123',
          status: AssignmentStatus.confirmed,
          notes: 'Original notes',
        );
      });

      test('should copy with updated id', () {
        // Act
        final updated = baseAssignment.copyWith(id: 'new-assignment-123');

        // Assert
        expect(updated.id, equals('new-assignment-123'));
        expect(updated.childId, equals(baseAssignment.childId));
        expect(updated.assignmentType, equals(baseAssignment.assignmentType));
        expect(updated.notes, equals(baseAssignment.notes));
      });

      test('should copy with updated childId', () {
        // Act
        final updated = baseAssignment.copyWith(childId: 'new-child-456');

        // Assert
        expect(updated.childId, equals('new-child-456'));
        expect(updated.id, equals(baseAssignment.id));
      });

      test('should copy with updated status', () {
        // Act
        final updated = baseAssignment.copyWith(
          status: AssignmentStatus.completed,
        );

        // Assert
        expect(updated.status, equals(AssignmentStatus.completed));
        expect(updated.id, equals(baseAssignment.id));
      });

      test('should copy with updated isActive', () {
        // Act
        final updated = baseAssignment.copyWith(isActive: false);

        // Assert
        expect(updated.isActive, isFalse);
        expect(updated.id, equals(baseAssignment.id));
      });

      test('should copy with updated notes', () {
        // Act
        final updated = baseAssignment.copyWith(notes: 'Updated notes');

        // Assert
        expect(updated.notes, equals('Updated notes'));
        expect(updated.id, equals(baseAssignment.id));
      });

      test('should copy with multiple updated fields', () {
        // Act
        final updated = baseAssignment.copyWith(
          childId: 'new-child-789',
          status: AssignmentStatus.pending,
          notes: 'Multiple updates',
          isActive: false,
        );

        // Assert
        expect(updated.childId, equals('new-child-789'));
        expect(updated.status, equals(AssignmentStatus.pending));
        expect(updated.notes, equals('Multiple updates'));
        expect(updated.isActive, isFalse);
        expect(updated.id, equals(baseAssignment.id)); // Unchanged
      });

      test('should preserve original when no changes provided', () {
        // Act
        final copied = baseAssignment.copyWith();

        // Assert
        expect(copied.id, equals(baseAssignment.id));
        expect(copied.childId, equals(baseAssignment.childId));
        expect(copied.assignmentType, equals(baseAssignment.assignmentType));
        expect(copied.status, equals(baseAssignment.status));
        expect(copied.notes, equals(baseAssignment.notes));
        expect(copied.isActive, equals(baseAssignment.isActive));
      });

      test('should copy schedule-specific fields', () {
        // Arrange
        final scheduleAssignment = ChildAssignment.schedule(
          id: 'schedule-123',
          childId: 'child-456',
          childName: 'Original Name',
          familyId: 'family-123',
          familyName: 'Original Family',
          pickupAddress: 'Original Address',
          pickupLat: 10.0,
          pickupLng: 20.0,
          status: 'pending',
        );

        // Act
        final updated = scheduleAssignment.copyWith(
          childName: 'Updated Name',
          pickupAddress: 'Updated Address',
          pickupLat: 30.0,
          pickupLng: 40.0,
        );

        // Assert
        expect(updated.childName, equals('Updated Name'));
        expect(updated.pickupAddress, equals('Updated Address'));
        expect(updated.pickupLat, equals(30.0));
        expect(updated.pickupLng, equals(40.0));
        expect(updated.familyId, equals('family-123')); // Unchanged
      });
    });

    group('Computed Properties', () {
      test(
        'isActiveTransportation should return true for active transportation assignments',
        () {
          // Arrange
          final assignment = ChildAssignment.transportation(
            id: 'transport-123',
            childId: 'child-456',
            groupId: 'group-789',
            scheduleSlotId: 'slot-012',
            vehicleAssignmentId: 'vehicle-345',
            assignedAt: testDateTime,
            status: AssignmentStatus.confirmed,
            assignmentDate: testAssignmentDate,
          );

          // Act & Assert
          expect(assignment.isActiveTransportation, isTrue);
        },
      );

      test(
        'isActiveTransportation should return false for inactive transportation assignments',
        () {
          // Arrange
          final assignment = ChildAssignment.transportation(
            id: 'transport-123',
            childId: 'child-456',
            groupId: 'group-789',
            scheduleSlotId: 'slot-012',
            vehicleAssignmentId: 'vehicle-345',
            assignedAt: testDateTime,
            status: AssignmentStatus.cancelled,
            assignmentDate: testAssignmentDate,
          );

          // Act & Assert
          expect(assignment.isActiveTransportation, isFalse);
        },
      );

      test('isFuture should return true for assignments in the future', () {
        // Arrange
        final futureDate = DateTime.now().add(const Duration(days: 1));
        final assignment = ChildAssignment(
          id: 'future-assignment',
          childId: 'child-456',
          assignmentType: 'transportation',
          assignmentId: 'transport-789',
          createdAt: testDateTime,
          assignmentDate: futureDate,
        );

        // Act & Assert
        expect(assignment.isFuture, isTrue);
      });

      test('isFuture should return false for assignments in the past', () {
        // Arrange
        final pastDate = DateTime.now().subtract(const Duration(days: 1));
        final assignment = ChildAssignment(
          id: 'past-assignment',
          childId: 'child-456',
          assignmentType: 'transportation',
          assignmentId: 'transport-789',
          createdAt: testDateTime,
          assignmentDate: pastDate,
        );

        // Act & Assert
        expect(assignment.isFuture, isFalse);
      });

      test(
        'scheduleStatus should return correct string status for schedule assignments',
        () {
          final statuses = ['pending', 'scheduled', 'in_progress', 'completed'];

          for (final status in statuses) {
            // Arrange
            final assignment = ChildAssignment.schedule(
              id: 'schedule-$status',
              childId: 'child-456',
              childName: 'Test Child',
              familyId: 'family-123',
              familyName: 'Test Family',
              pickupAddress: 'Test Address',
              pickupLat: 0.0,
              pickupLng: 0.0,
              status: status,
            );

            // Act & Assert
            expect(assignment.scheduleStatus, equals(status));
          }
        },
      );
    });

    group('Equality and Hash Code', () {
      test('should be equal when all properties match', () {
        // Arrange
        final assignment1 = ChildAssignment(
          id: 'assignment-123',
          childId: 'child-456',
          assignmentType: 'transportation',
          assignmentId: 'transport-789',
          createdAt: testDateTime,
          status: AssignmentStatus.confirmed,
        );
        final assignment2 = ChildAssignment(
          id: 'assignment-123',
          childId: 'child-456',
          assignmentType: 'transportation',
          assignmentId: 'transport-789',
          createdAt: testDateTime,
          status: AssignmentStatus.confirmed,
        );

        // Assert
        expect(assignment1, equals(assignment2));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        final assignment1 = ChildAssignment(
          id: 'assignment-123',
          childId: 'child-456',
          assignmentType: 'transportation',
          assignmentId: 'transport-789',
          createdAt: testDateTime,
        );
        final assignment2 = ChildAssignment(
          id: 'assignment-456', // Different ID
          childId: 'child-456',
          assignmentType: 'transportation',
          assignmentId: 'transport-789',
          createdAt: testDateTime,
        );

        // Assert
        expect(assignment1, isNot(equals(assignment2)));
      });

      test('should have same hash code when equal', () {
        // Arrange
        final assignment1 = ChildAssignment(
          id: 'assignment-123',
          childId: 'child-456',
          assignmentType: 'transportation',
          assignmentId: 'transport-789',
          createdAt: testDateTime,
        );
        final assignment2 = ChildAssignment(
          id: 'assignment-123',
          childId: 'child-456',
          assignmentType: 'transportation',
          assignmentId: 'transport-789',
          createdAt: testDateTime,
        );

        // Assert
        expect(assignment1.hashCode, equals(assignment2.hashCode));
      });
    });

    group('toString Method', () {
      test('should provide meaningful string representation', () {
        // Arrange
        final assignment = ChildAssignment(
          id: 'assignment-123',
          childId: 'child-456',
          assignmentType: 'transportation',
          assignmentId: 'transport-789',
          createdAt: testDateTime,
        );

        // Act
        final stringRepresentation = assignment.toString();

        // Assert
        expect(stringRepresentation, contains('assignment-123'));
        expect(stringRepresentation, contains('child-456'));
        expect(stringRepresentation, contains('transportation'));
        expect(stringRepresentation, contains('transport-789'));
        expect(stringRepresentation, contains('true'));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle very long string fields', () {
        // Arrange
        final longString = 'A' * 1000;
        final assignment = ChildAssignment(
          id: longString,
          childId: 'child-456',
          assignmentType: 'transportation',
          assignmentId: 'transport-789',
          createdAt: testDateTime,
          notes: longString,
        );

        // Assert
        expect(assignment.id, equals(longString));
        expect(assignment.notes, equals(longString));
        expect(assignment.id.length, equals(1000));
      });

      test('should handle special characters in string fields', () {
        // Arrange
        final assignment = ChildAssignment(
          id: 'assignment-éñ-123',
          childId: 'child-李小明',
          assignmentType: 'transportation',
          assignmentId: 'transport-مريم',
          createdAt: testDateTime,
          notes: 'Special pickup for José María O\'Connor',
        );

        // Assert
        expect(assignment.id, equals('assignment-éñ-123'));
        expect(assignment.childId, equals('child-李小明'));
        expect(assignment.assignmentId, equals('transport-مريم'));
        expect(
          assignment.notes,
          equals('Special pickup for José María O\'Connor'),
        );
      });

      test('should handle extreme coordinate values', () {
        // Arrange
        final assignment = ChildAssignment.schedule(
          id: 'extreme-coords',
          childId: 'child-456',
          childName: 'Test Child',
          familyId: 'family-123',
          familyName: 'Test Family',
          pickupAddress: 'Extreme Location',
          pickupLat: 90.0, // North pole
          pickupLng: -180.0, // International date line
          status: 'scheduled',
        );

        // Assert
        expect(assignment.pickupLat, equals(90.0));
        expect(assignment.pickupLng, equals(-180.0));
      });

      test('should handle very large metadata objects', () {
        // Arrange
        final largeMetadata = Map<String, dynamic>.fromEntries(
          List.generate(1000, (index) => MapEntry('key$index', 'value$index')),
        );
        final assignment = ChildAssignment(
          id: 'large-metadata',
          childId: 'child-456',
          assignmentType: 'transportation',
          assignmentId: 'transport-789',
          createdAt: testDateTime,
          metadata: largeMetadata,
        );

        // Assert
        expect(assignment.metadata!.length, equals(1000));
        expect(assignment.metadata!['key0'], equals('value0'));
        expect(assignment.metadata!['key999'], equals('value999'));
      });

      test('should handle concurrent copy operations', () async {
        // Arrange
        final baseAssignment = ChildAssignment(
          id: 'concurrent-test',
          childId: 'child-456',
          assignmentType: 'transportation',
          assignmentId: 'transport-789',
          createdAt: testDateTime,
        );

        // Act - Simulate concurrent copy operations
        final futures = List.generate(
          10,
          (index) => Future(
            () => baseAssignment.copyWith(notes: 'Concurrent update $index'),
          ),
        );
        final results = await Future.wait(futures);

        // Assert - All copies should be successful
        expect(results.length, equals(10));
        for (var i = 0; i < results.length; i++) {
          expect(results[i].notes, equals('Concurrent update $i'));
          expect(results[i].id, equals('concurrent-test'));
        }
      });

      test('should maintain type safety with bridge pattern', () {
        // Arrange & Act
        final assignment = ChildAssignment(
          id: 'type-safety-test',
          childId: 'child-456',
          assignmentType: 'transportation',
          assignmentId: 'transport-789',
          createdAt: testDateTime,
        );

        // Assert - Verify that internal bridge maintains type safety
        expect(assignment.composed, isNotNull);
        expect(() => assignment.isActiveTransportation, returnsNormally);
        expect(() => assignment.isFuture, returnsNormally);
        expect(() => assignment.scheduleStatus, returnsNormally);
      });
    });

    group('Business Logic Integration', () {
      test('should support transportation assignment workflow', () {
        // Arrange - Create transportation assignment
        var assignment = ChildAssignment.transportation(
          id: 'transport-workflow-123',
          childId: 'child-456',
          groupId: 'morning-group',
          scheduleSlotId: 'slot-8am',
          vehicleAssignmentId: 'bus-001',
          assignedAt: testDateTime,
          status: AssignmentStatus.pending,
          assignmentDate: testAssignmentDate,
          notes: 'Initial assignment',
        );

        // Act - Update to active status
        assignment = assignment.copyWith(
          status: AssignmentStatus.confirmed,
          notes: 'Confirmed for pickup',
          updatedAt: testDateTime.add(const Duration(hours: 1)),
        );

        // Assert
        expect(assignment.status, equals(AssignmentStatus.confirmed));
        expect(assignment.isActiveTransportation, isTrue);
        expect(assignment.notes, equals('Confirmed for pickup'));
      });

      test('should support schedule assignment workflow', () {
        // Arrange - Create schedule assignment
        var assignment = ChildAssignment.schedule(
          id: 'schedule-workflow-123',
          childId: 'child-456',
          childName: 'Alice Johnson',
          familyId: 'johnson-family',
          familyName: 'Johnson Family',
          pickupAddress: '123 Family Lane',
          pickupLat: 37.7749,
          pickupLng: -122.4194,
          status: 'pending',
          createdAt: testDateTime,
        );

        // Act - Update with pickup times
        assignment = assignment.copyWith(
          pickupTime: testAssignmentDate,
          dropoffTime: testAssignmentDate.add(const Duration(hours: 8)),
        );

        // Assert
        expect(assignment.scheduleStatus, equals('pending'));
        expect(assignment.pickupTime, equals(testAssignmentDate));
        expect(
          assignment.dropoffTime,
          equals(testAssignmentDate.add(const Duration(hours: 8))),
        );
        expect(assignment.childName, equals('Alice Johnson'));
      });

      test('should handle assignment lifecycle transitions', () {
        // Arrange
        var assignment = ChildAssignment.transportation(
          id: 'lifecycle-test',
          childId: 'child-456',
          groupId: 'test-group',
          scheduleSlotId: 'test-slot',
          vehicleAssignmentId: 'test-vehicle',
          assignedAt: testDateTime,
          status: AssignmentStatus.pending,
          assignmentDate: testAssignmentDate,
        );

        // Act - Simulate lifecycle: pending -> active -> completed
        assignment = assignment.copyWith(status: AssignmentStatus.confirmed);
        expect(assignment.status, equals(AssignmentStatus.confirmed));
        expect(assignment.isActiveTransportation, isTrue);

        assignment = assignment.copyWith(status: AssignmentStatus.completed);
        expect(assignment.status, equals(AssignmentStatus.completed));
        expect(assignment.isActiveTransportation, isFalse);
      });
    });
  });
}
