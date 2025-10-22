import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/domain/entities/family.dart';

void main() {
  group('ChildAssignmentData Entity', () {
    const testId = 'assign-123';
    const testChildId = 'child-456';
    const testAssignmentType = 'transportation';
    const testAssignmentId = 'vehicle-789';
    const testStatus = 'confirmed';
    final testCreatedAt = DateTime(2025, 1, 15, 10);
    final testUpdatedAt = DateTime(2025, 1, 15, 12);
    final testAssignmentDate = DateTime(2025, 1, 16, 8);
    const testMetadata = {'priority': 'high', 'notes': 'Test assignment'};

    group('Construction and Properties', () {
      test(
        'should create ChildAssignmentData with all required properties',
        () {
          final assignment = ChildAssignmentData(
            id: testId,
            childId: testChildId,
            assignmentType: testAssignmentType,
            assignmentId: testAssignmentId,
            status: testStatus,
            assignmentDate: testAssignmentDate,
            metadata: testMetadata,
            createdAt: testCreatedAt,
            updatedAt: testUpdatedAt,
          );

          expect(assignment.id, testId);
          expect(assignment.childId, testChildId);
          expect(assignment.assignmentType, testAssignmentType);
          expect(assignment.assignmentId, testAssignmentId);
          expect(assignment.status, testStatus);
          expect(assignment.assignmentDate, testAssignmentDate);
          expect(assignment.metadata, testMetadata);
          expect(assignment.createdAt, testCreatedAt);
          expect(assignment.updatedAt, testUpdatedAt);
        },
      );

      test(
        'should create ChildAssignmentData with minimal required properties',
        () {
          final assignment = ChildAssignmentData(
            id: testId,
            childId: testChildId,
            assignmentType: testAssignmentType,
            assignmentId: testAssignmentId,
            status: testStatus,
            createdAt: testCreatedAt,
          );

          expect(assignment.id, testId);
          expect(assignment.childId, testChildId);
          expect(assignment.assignmentType, testAssignmentType);
          expect(assignment.assignmentId, testAssignmentId);
          expect(assignment.status, testStatus);
          expect(assignment.assignmentDate, null);
          expect(assignment.metadata, null);
          expect(assignment.createdAt, testCreatedAt);
          expect(assignment.updatedAt, null);
        },
      );
    });

    group('Status Parsing Logic', () {
      test('should parse pending status correctly', () {
        final assignment = ChildAssignmentData(
          id: testId,
          childId: testChildId,
          assignmentType: testAssignmentType,
          assignmentId: testAssignmentId,
          status: 'pending',
          createdAt: testCreatedAt,
        );

        final domainAssignment = assignment.toAssignment();
        expect(domainAssignment.status, AssignmentStatus.pending);
      });

      test('should parse confirmed status correctly', () {
        final assignment = ChildAssignmentData(
          id: testId,
          childId: testChildId,
          assignmentType: testAssignmentType,
          assignmentId: testAssignmentId,
          status: 'confirmed',
          createdAt: testCreatedAt,
        );

        final domainAssignment = assignment.toAssignment();
        expect(domainAssignment.status, AssignmentStatus.confirmed);
      });

      test('should parse cancelled status correctly', () {
        final assignment = ChildAssignmentData(
          id: testId,
          childId: testChildId,
          assignmentType: testAssignmentType,
          assignmentId: testAssignmentId,
          status: 'cancelled',
          createdAt: testCreatedAt,
        );

        final domainAssignment = assignment.toAssignment();
        expect(domainAssignment.status, AssignmentStatus.cancelled);
      });

      test('should parse completed status correctly', () {
        final assignment = ChildAssignmentData(
          id: testId,
          childId: testChildId,
          assignmentType: testAssignmentType,
          assignmentId: testAssignmentId,
          status: 'completed',
          createdAt: testCreatedAt,
        );

        final domainAssignment = assignment.toAssignment();
        expect(domainAssignment.status, AssignmentStatus.completed);
      });

      test('should default to pending for unknown status', () {
        final assignment = ChildAssignmentData(
          id: testId,
          childId: testChildId,
          assignmentType: testAssignmentType,
          assignmentId: testAssignmentId,
          status: 'unknown-status',
          createdAt: testCreatedAt,
        );

        final domainAssignment = assignment.toAssignment();
        expect(domainAssignment.status, AssignmentStatus.pending);
      });

      test('should handle case-insensitive status parsing', () {
        final assignment = ChildAssignmentData(
          id: testId,
          childId: testChildId,
          assignmentType: testAssignmentType,
          assignmentId: testAssignmentId,
          status: 'CONFIRMED',
          createdAt: testCreatedAt,
        );

        final domainAssignment = assignment.toAssignment();
        expect(domainAssignment.status, AssignmentStatus.confirmed);
      });
    });

    group('Domain Entity Conversion', () {
      test('should convert to ChildAssignment with all properties', () {
        final assignment = ChildAssignmentData(
          id: testId,
          childId: testChildId,
          assignmentType: testAssignmentType,
          assignmentId: testAssignmentId,
          status: testStatus,
          assignmentDate: testAssignmentDate,
          metadata: testMetadata,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final domainAssignment = assignment.toAssignment();

        expect(domainAssignment.id, testId);
        expect(domainAssignment.childId, testChildId);
        expect(domainAssignment.assignmentType, testAssignmentType);
        expect(domainAssignment.assignmentId, testAssignmentId);
        expect(domainAssignment.assignmentDate, testAssignmentDate);
        expect(domainAssignment.createdAt, testCreatedAt);
        expect(domainAssignment.updatedAt, testUpdatedAt);
        expect(domainAssignment.isActive, true);
        expect(domainAssignment.metadata, contains('status'));
        expect(domainAssignment.metadata!['priority'], 'high');
        expect(domainAssignment.metadata!['notes'], 'Test assignment');
      });

      test('should set isActive to false for cancelled status', () {
        final assignment = ChildAssignmentData(
          id: testId,
          childId: testChildId,
          assignmentType: testAssignmentType,
          assignmentId: testAssignmentId,
          status: 'cancelled',
          createdAt: testCreatedAt,
        );

        final domainAssignment = assignment.toAssignment();
        expect(domainAssignment.isActive, false);
      });

      test('should set isActive to false for completed status', () {
        final assignment = ChildAssignmentData(
          id: testId,
          childId: testChildId,
          assignmentType: testAssignmentType,
          assignmentId: testAssignmentId,
          status: 'completed',
          createdAt: testCreatedAt,
        );

        final domainAssignment = assignment.toAssignment();
        expect(domainAssignment.isActive, false);
      });

      test('should preserve metadata and add status', () {
        final assignment = ChildAssignmentData(
          id: testId,
          childId: testChildId,
          assignmentType: testAssignmentType,
          assignmentId: testAssignmentId,
          status: testStatus,
          metadata: testMetadata,
          createdAt: testCreatedAt,
        );

        final domainAssignment = assignment.toAssignment();
        expect(domainAssignment.metadata!['status'], testStatus);
        expect(domainAssignment.metadata!['priority'], 'high');
        expect(domainAssignment.metadata!['notes'], 'Test assignment');
      });

      test('should handle null metadata correctly', () {
        final assignment = ChildAssignmentData(
          id: testId,
          childId: testChildId,
          assignmentType: testAssignmentType,
          assignmentId: testAssignmentId,
          status: testStatus,
          createdAt: testCreatedAt,
        );

        final domainAssignment = assignment.toAssignment();
        expect(domainAssignment.metadata!['status'], testStatus);
        expect(domainAssignment.metadata!.length, 1);
      });
    });

    group('isActive Property', () {
      test('should return true for pending status', () {
        final assignment = ChildAssignmentData(
          id: testId,
          childId: testChildId,
          assignmentType: testAssignmentType,
          assignmentId: testAssignmentId,
          status: 'pending',
          createdAt: testCreatedAt,
        );

        expect(assignment.isActive, true);
      });

      test('should return true for confirmed status', () {
        final assignment = ChildAssignmentData(
          id: testId,
          childId: testChildId,
          assignmentType: testAssignmentType,
          assignmentId: testAssignmentId,
          status: 'confirmed',
          createdAt: testCreatedAt,
        );

        expect(assignment.isActive, true);
      });

      test('should return false for cancelled status', () {
        final assignment = ChildAssignmentData(
          id: testId,
          childId: testChildId,
          assignmentType: testAssignmentType,
          assignmentId: testAssignmentId,
          status: 'cancelled',
          createdAt: testCreatedAt,
        );

        expect(assignment.isActive, false);
      });

      test('should return false for completed status', () {
        final assignment = ChildAssignmentData(
          id: testId,
          childId: testChildId,
          assignmentType: testAssignmentType,
          assignmentId: testAssignmentId,
          status: 'completed',
          createdAt: testCreatedAt,
        );

        expect(assignment.isActive, false);
      });

      test('should return true for unknown status', () {
        final assignment = ChildAssignmentData(
          id: testId,
          childId: testChildId,
          assignmentType: testAssignmentType,
          assignmentId: testAssignmentId,
          status: 'unknown',
          createdAt: testCreatedAt,
        );

        expect(assignment.isActive, true);
      });
    });

    group('isFuture Property', () {
      test('should return true when assignment date is in the future', () {
        final futureDate = DateTime.now().add(const Duration(days: 1));
        final assignment = ChildAssignmentData(
          id: testId,
          childId: testChildId,
          assignmentType: testAssignmentType,
          assignmentId: testAssignmentId,
          status: testStatus,
          assignmentDate: futureDate,
          createdAt: testCreatedAt,
        );

        expect(assignment.isFuture, true);
      });

      test('should return false when assignment date is in the past', () {
        final pastDate = DateTime.now().subtract(const Duration(days: 1));
        final assignment = ChildAssignmentData(
          id: testId,
          childId: testChildId,
          assignmentType: testAssignmentType,
          assignmentId: testAssignmentId,
          status: testStatus,
          assignmentDate: pastDate,
          createdAt: testCreatedAt,
        );

        expect(assignment.isFuture, false);
      });

      test('should return false when assignment date is null', () {
        final assignment = ChildAssignmentData(
          id: testId,
          childId: testChildId,
          assignmentType: testAssignmentType,
          assignmentId: testAssignmentId,
          status: testStatus,
          createdAt: testCreatedAt,
        );

        expect(assignment.isFuture, false);
      });
    });

    group('copyWith Method', () {
      late ChildAssignmentData original;

      setUp(() {
        original = ChildAssignmentData(
          id: testId,
          childId: testChildId,
          assignmentType: testAssignmentType,
          assignmentId: testAssignmentId,
          status: testStatus,
          assignmentDate: testAssignmentDate,
          metadata: testMetadata,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );
      });

      test('should copy with new id', () {
        const newId = 'new-id';
        final copied = original.copyWith(id: newId);

        expect(copied.id, newId);
        expect(copied.childId, testChildId);
        expect(copied.assignmentType, testAssignmentType);
        expect(copied.assignmentId, testAssignmentId);
        expect(copied.status, testStatus);
      });

      test('should copy with new status', () {
        const newStatus = 'cancelled';
        final copied = original.copyWith(status: newStatus);

        expect(copied.status, newStatus);
        expect(copied.id, testId);
        expect(copied.childId, testChildId);
      });

      test('should copy with new metadata', () {
        const newMetadata = {'updated': 'true'};
        final copied = original.copyWith(metadata: newMetadata);

        expect(copied.metadata, newMetadata);
        expect(copied.id, testId);
        expect(copied.childId, testChildId);
      });

      test('should copy with new assignment date', () {
        final newDate = DateTime(2025, 2, 1, 9);
        final copied = original.copyWith(assignmentDate: newDate);

        expect(copied.assignmentDate, newDate);
        expect(copied.id, testId);
        expect(copied.childId, testChildId);
      });

      test('should copy with new updated timestamp', () {
        final newUpdatedAt = DateTime(2025, 1, 16, 14);
        final copied = original.copyWith(updatedAt: newUpdatedAt);

        expect(copied.updatedAt, newUpdatedAt);
        expect(copied.id, testId);
        expect(copied.childId, testChildId);
      });

      test('should preserve original values when no changes provided', () {
        final copied = original.copyWith();

        expect(copied.id, testId);
        expect(copied.childId, testChildId);
        expect(copied.assignmentType, testAssignmentType);
        expect(copied.assignmentId, testAssignmentId);
        expect(copied.status, testStatus);
        expect(copied.assignmentDate, testAssignmentDate);
        expect(copied.metadata, testMetadata);
        expect(copied.createdAt, testCreatedAt);
        expect(copied.updatedAt, testUpdatedAt);
      });
    });

    group('Equality and Hash Code', () {
      test('should be equal when all properties match', () {
        final assignment1 = ChildAssignmentData(
          id: testId,
          childId: testChildId,
          assignmentType: testAssignmentType,
          assignmentId: testAssignmentId,
          status: testStatus,
          assignmentDate: testAssignmentDate,
          metadata: testMetadata,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final assignment2 = ChildAssignmentData(
          id: testId,
          childId: testChildId,
          assignmentType: testAssignmentType,
          assignmentId: testAssignmentId,
          status: testStatus,
          assignmentDate: testAssignmentDate,
          metadata: testMetadata,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(assignment1, assignment2);
        expect(assignment1.hashCode, assignment2.hashCode);
      });

      test('should not be equal when id differs', () {
        final assignment1 = ChildAssignmentData(
          id: testId,
          childId: testChildId,
          assignmentType: testAssignmentType,
          assignmentId: testAssignmentId,
          status: testStatus,
          createdAt: testCreatedAt,
        );

        final assignment2 = ChildAssignmentData(
          id: 'different-id',
          childId: testChildId,
          assignmentType: testAssignmentType,
          assignmentId: testAssignmentId,
          status: testStatus,
          createdAt: testCreatedAt,
        );

        expect(assignment1, isNot(assignment2));
      });

      test('should not be equal when status differs', () {
        final assignment1 = ChildAssignmentData(
          id: testId,
          childId: testChildId,
          assignmentType: testAssignmentType,
          assignmentId: testAssignmentId,
          status: 'pending',
          createdAt: testCreatedAt,
        );

        final assignment2 = ChildAssignmentData(
          id: testId,
          childId: testChildId,
          assignmentType: testAssignmentType,
          assignmentId: testAssignmentId,
          status: 'confirmed',
          createdAt: testCreatedAt,
        );

        expect(assignment1, isNot(assignment2));
      });

      test('should not be equal when metadata differs', () {
        final assignment1 = ChildAssignmentData(
          id: testId,
          childId: testChildId,
          assignmentType: testAssignmentType,
          assignmentId: testAssignmentId,
          status: testStatus,
          metadata: const {'key': 'value1'},
          createdAt: testCreatedAt,
        );

        final assignment2 = ChildAssignmentData(
          id: testId,
          childId: testChildId,
          assignmentType: testAssignmentType,
          assignmentId: testAssignmentId,
          status: testStatus,
          metadata: const {'key': 'value2'},
          createdAt: testCreatedAt,
        );

        expect(assignment1, isNot(assignment2));
      });
    });

    group('toString Method', () {
      test('should provide meaningful string representation', () {
        final assignment = ChildAssignmentData(
          id: testId,
          childId: testChildId,
          assignmentType: testAssignmentType,
          assignmentId: testAssignmentId,
          status: testStatus,
          createdAt: testCreatedAt,
        );

        final result = assignment.toString();

        expect(result, contains(testId));
        expect(result, contains(testChildId));
        expect(result, contains(testAssignmentType));
        expect(result, contains(testStatus));
        expect(result, contains('ChildAssignmentData'));
      });
    });

    group('Edge Cases', () {
      test('should handle empty metadata map', () {
        final assignment = ChildAssignmentData(
          id: testId,
          childId: testChildId,
          assignmentType: testAssignmentType,
          assignmentId: testAssignmentId,
          status: testStatus,
          metadata: const {},
          createdAt: testCreatedAt,
        );

        final domainAssignment = assignment.toAssignment();
        expect(domainAssignment.metadata!['status'], testStatus);
        expect(domainAssignment.metadata!.length, 1);
      });

      test('should handle special characters in string fields', () {
        const specialId = 'test-123_\$@#';
        const specialType = 'special/type-with_chars';

        final assignment = ChildAssignmentData(
          id: specialId,
          childId: testChildId,
          assignmentType: specialType,
          assignmentId: testAssignmentId,
          status: testStatus,
          createdAt: testCreatedAt,
        );

        expect(assignment.id, specialId);
        expect(assignment.assignmentType, specialType);

        final domainAssignment = assignment.toAssignment();
        expect(domainAssignment.id, specialId);
        expect(domainAssignment.assignmentType, specialType);
      });

      test('should handle minimum DateTime values', () {
        final minDate = DateTime.fromMillisecondsSinceEpoch(0);
        final assignment = ChildAssignmentData(
          id: testId,
          childId: testChildId,
          assignmentType: testAssignmentType,
          assignmentId: testAssignmentId,
          status: testStatus,
          assignmentDate: minDate,
          createdAt: minDate,
          updatedAt: minDate,
        );

        expect(assignment.assignmentDate, minDate);
        expect(assignment.createdAt, minDate);
        expect(assignment.updatedAt, minDate);
      });

      test('should handle complex nested metadata', () {
        const complexMetadata = <String, dynamic>{
          'nested': {
            'level1': {'level2': 'value'},
          },
          'array': [1, 2, 3],
          'bool': true,
          'null_value': null,
        };

        final assignment = ChildAssignmentData(
          id: testId,
          childId: testChildId,
          assignmentType: testAssignmentType,
          assignmentId: testAssignmentId,
          status: testStatus,
          metadata: complexMetadata,
          createdAt: testCreatedAt,
        );

        expect(assignment.metadata, complexMetadata);

        final domainAssignment = assignment.toAssignment();
        expect(domainAssignment.metadata!['nested'], complexMetadata['nested']);
        expect(domainAssignment.metadata!['array'], complexMetadata['array']);
        expect(domainAssignment.metadata!['bool'], complexMetadata['bool']);
        expect(domainAssignment.metadata!['null_value'], null);
      });
    });
  });
}
