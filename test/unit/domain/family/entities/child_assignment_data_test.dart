import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/domain/entities/family.dart';

void main() {
  group('ChildAssignmentData', () {
    late ChildAssignmentData testAssignmentData;
    late DateTime testCreatedAt;
    late DateTime testAssignmentDate;
    late DateTime testUpdatedAt;

    setUp(() {
      testCreatedAt = DateTime.now().subtract(const Duration(hours: 1));
      testAssignmentDate = DateTime.now().add(const Duration(hours: 2));
      testUpdatedAt = DateTime.now().subtract(const Duration(minutes: 30));

      testAssignmentData = ChildAssignmentData(
        id: 'assignment-123',
        childId: 'child-456',
        assignmentType: 'transportation',
        assignmentId: 'vehicle-789',
        status: 'pending',
        assignmentDate: testAssignmentDate,
        metadata: const {'priority': 'high', 'driver': 'parent'},
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
      );
    });

    group('Constructor and Properties', () {
      test('should create instance with all required fields', () {
        expect(testAssignmentData.id, equals('assignment-123'));
        expect(testAssignmentData.childId, equals('child-456'));
        expect(testAssignmentData.assignmentType, equals('transportation'));
        expect(testAssignmentData.assignmentId, equals('vehicle-789'));
        expect(testAssignmentData.status, equals('pending'));
        expect(testAssignmentData.createdAt, equals(testCreatedAt));
      });

      test('should create instance with optional fields as null', () {
        final minimalAssignment = ChildAssignmentData(
          id: 'test-id',
          childId: 'child-id',
          assignmentType: 'test',
          assignmentId: 'assignment-id',
          status: 'active',
          createdAt: DateTime.now(),
        );

        expect(minimalAssignment.assignmentDate, isNull);
        expect(minimalAssignment.metadata, isNull);
        expect(minimalAssignment.updatedAt, isNull);
      });

      test('should handle empty metadata map', () {
        final assignment = ChildAssignmentData(
          id: 'test-id',
          childId: 'child-id',
          assignmentType: 'test',
          assignmentId: 'assignment-id',
          status: 'active',
          createdAt: DateTime.now(),
          metadata: const {},
        );

        expect(assignment.metadata, isEmpty);
      });
    });

    group('Status Parsing', () {
      test('should parse pending status correctly', () {
        final assignment = testAssignmentData.copyWith(status: 'pending');
        final fullAssignment = assignment.toAssignment();
        expect(fullAssignment.status, equals(AssignmentStatus.pending));
      });

      test('should parse confirmed status correctly', () {
        final assignment = testAssignmentData.copyWith(status: 'confirmed');
        final fullAssignment = assignment.toAssignment();
        expect(fullAssignment.status, equals(AssignmentStatus.confirmed));
      });

      test('should parse cancelled status correctly', () {
        final assignment = testAssignmentData.copyWith(status: 'cancelled');
        final fullAssignment = assignment.toAssignment();
        expect(fullAssignment.status, equals(AssignmentStatus.cancelled));
      });

      test('should parse completed status correctly', () {
        final assignment = testAssignmentData.copyWith(status: 'completed');
        final fullAssignment = assignment.toAssignment();
        expect(fullAssignment.status, equals(AssignmentStatus.completed));
      });

      test('should default to pending for unknown status', () {
        final assignment = testAssignmentData.copyWith(
          status: 'unknown_status',
        );
        final fullAssignment = assignment.toAssignment();
        expect(fullAssignment.status, equals(AssignmentStatus.pending));
      });

      test('should handle case insensitive status parsing', () {
        final assignment = testAssignmentData.copyWith(status: 'CONFIRMED');
        final fullAssignment = assignment.toAssignment();
        expect(fullAssignment.status, equals(AssignmentStatus.confirmed));
      });
    });

    group('Active Status Logic', () {
      test('should return true for pending status', () {
        final assignment = testAssignmentData.copyWith(status: 'pending');
        expect(assignment.isActive, isTrue);
      });

      test('should return true for confirmed status', () {
        final assignment = testAssignmentData.copyWith(status: 'confirmed');
        expect(assignment.isActive, isTrue);
      });

      test('should return false for cancelled status', () {
        final assignment = testAssignmentData.copyWith(status: 'cancelled');
        expect(assignment.isActive, isFalse);
      });

      test('should return false for completed status', () {
        final assignment = testAssignmentData.copyWith(status: 'completed');
        expect(assignment.isActive, isFalse);
      });

      test('should return true for custom active status', () {
        final assignment = testAssignmentData.copyWith(status: 'in_progress');
        expect(assignment.isActive, isTrue);
      });
    });

    group('Future Assignment Logic', () {
      test('should return true when assignment date is in future', () {
        final futureDate = DateTime.now().add(const Duration(hours: 1));
        final assignment = testAssignmentData.copyWith(
          assignmentDate: futureDate,
        );
        expect(assignment.isFuture, isTrue);
      });

      test('should return false when assignment date is in past', () {
        final pastDate = DateTime.now().subtract(const Duration(hours: 1));
        final assignment = testAssignmentData.copyWith(
          assignmentDate: pastDate,
        );
        expect(assignment.isFuture, isFalse);
      });

      test('should return false when assignment date is null', () {
        final assignment = ChildAssignmentData(
          id: 'test-id',
          childId: 'child-id',
          assignmentType: 'test',
          assignmentId: 'assignment-id',
          status: 'active',
          createdAt: DateTime.now(),
        );
        expect(assignment.isFuture, isFalse);
      });

      test('should return false when assignment date is now', () {
        final now = DateTime.now();
        final assignment = testAssignmentData.copyWith(assignmentDate: now);
        // Should be false since now is not "after" now
        expect(assignment.isFuture, isFalse);
      });
    });

    group('toAssignment Conversion', () {
      test('should convert to ChildAssignment with all fields', () {
        final assignment = testAssignmentData.toAssignment();

        expect(assignment.id, equals(testAssignmentData.id));
        expect(assignment.childId, equals(testAssignmentData.childId));
        expect(
          assignment.assignmentType,
          equals(testAssignmentData.assignmentType),
        );
        expect(
          assignment.assignmentId,
          equals(testAssignmentData.assignmentId),
        );
        expect(assignment.createdAt, equals(testAssignmentData.createdAt));
        expect(assignment.updatedAt, equals(testAssignmentData.updatedAt));
        expect(
          assignment.assignmentDate,
          equals(testAssignmentData.assignmentDate),
        );
      });

      test('should set isActive based on status', () {
        final activeAssignment = testAssignmentData.copyWith(
          status: 'confirmed',
        );
        expect(activeAssignment.toAssignment().isActive, isTrue);

        final inactiveAssignment = testAssignmentData.copyWith(
          status: 'cancelled',
        );
        expect(inactiveAssignment.toAssignment().isActive, isFalse);
      });

      test('should merge status into metadata', () {
        final assignment = testAssignmentData.toAssignment();
        expect(assignment.metadata?['status'], equals('pending'));
        expect(assignment.metadata?['priority'], equals('high'));
        expect(assignment.metadata?['driver'], equals('parent'));
      });

      test('should handle null metadata correctly', () {
        final assignmentWithoutMetadata = testAssignmentData.copyWith();
        final fullAssignment = assignmentWithoutMetadata.toAssignment();

        expect(fullAssignment.metadata?['status'], equals('pending'));
      });
    });

    group('copyWith Method', () {
      test('should create copy with updated fields', () {
        final updatedAssignment = testAssignmentData.copyWith(
          status: 'confirmed',
          assignmentType: 'schedule',
        );

        expect(updatedAssignment.status, equals('confirmed'));
        expect(updatedAssignment.assignmentType, equals('schedule'));
        expect(updatedAssignment.id, equals(testAssignmentData.id));
        expect(updatedAssignment.childId, equals(testAssignmentData.childId));
      });

      test('should preserve original values when no updates provided', () {
        final copiedAssignment = testAssignmentData.copyWith();

        expect(copiedAssignment.id, equals(testAssignmentData.id));
        expect(copiedAssignment.status, equals(testAssignmentData.status));
        expect(copiedAssignment.metadata, equals(testAssignmentData.metadata));
      });

      test('should handle null values in copyWith', () {
        // Cannot set non-nullable field to null, so test with new instance
        final assignmentWithNulls = ChildAssignmentData(
          id: testAssignmentData.id,
          childId: testAssignmentData.childId,
          assignmentType: testAssignmentData.assignmentType,
          assignmentId: testAssignmentData.assignmentId,
          status: testAssignmentData.status,
          createdAt: testAssignmentData.createdAt,
        );

        expect(assignmentWithNulls.assignmentDate, isNull);
        expect(assignmentWithNulls.metadata, isNull);
        expect(assignmentWithNulls.updatedAt, isNull);
      });
    });

    group('Equality and Props', () {
      test('should be equal when all properties match', () {
        final assignment1 = ChildAssignmentData(
          id: 'test-id',
          childId: 'child-id',
          assignmentType: 'test',
          assignmentId: 'assignment-id',
          status: 'active',
          createdAt: testCreatedAt,
        );

        final assignment2 = ChildAssignmentData(
          id: 'test-id',
          childId: 'child-id',
          assignmentType: 'test',
          assignmentId: 'assignment-id',
          status: 'active',
          createdAt: testCreatedAt,
        );

        expect(assignment1, equals(assignment2));
        expect(assignment1.hashCode, equals(assignment2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final assignment1 = testAssignmentData;
        final assignment2 = testAssignmentData.copyWith(status: 'cancelled');

        expect(assignment1, isNot(equals(assignment2)));
      });

      test('should include all fields in props', () {
        final props = testAssignmentData.props;

        expect(props, contains(testAssignmentData.id));
        expect(props, contains(testAssignmentData.childId));
        expect(props, contains(testAssignmentData.assignmentType));
        expect(props, contains(testAssignmentData.assignmentId));
        expect(props, contains(testAssignmentData.status));
        expect(props, contains(testAssignmentData.assignmentDate));
        expect(props, contains(testAssignmentData.metadata));
        expect(props, contains(testAssignmentData.createdAt));
        expect(props, contains(testAssignmentData.updatedAt));
      });
    });

    group('toString Method', () {
      test('should return formatted string representation', () {
        final stringRep = testAssignmentData.toString();

        expect(stringRep, contains('ChildAssignmentData'));
        expect(stringRep, contains('assignment-123'));
        expect(stringRep, contains('child-456'));
        expect(stringRep, contains('transportation'));
        expect(stringRep, contains('pending'));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle very old dates', () {
        final oldDate = DateTime(1990);
        final assignment = testAssignmentData.copyWith(
          createdAt: oldDate,
          assignmentDate: oldDate,
        );

        expect(assignment.createdAt, equals(oldDate));
        expect(assignment.assignmentDate, equals(oldDate));
        expect(assignment.isFuture, isFalse);
      });

      test('should handle far future dates', () {
        final futureDate = DateTime(2030, 12, 31);
        final assignment = testAssignmentData.copyWith(
          assignmentDate: futureDate,
        );

        expect(assignment.assignmentDate, equals(futureDate));
        expect(assignment.isFuture, isTrue);
      });

      test('should handle empty string status', () {
        final assignment = testAssignmentData.copyWith(status: '');
        final fullAssignment = assignment.toAssignment();
        expect(fullAssignment.status, equals(AssignmentStatus.pending));
      });

      test('should handle complex metadata', () {
        final complexMetadata = {
          'nested': {'level': 2, 'data': true},
          'list': [1, 2, 3],
          'null_value': null,
          'boolean': false,
        };

        final assignment = testAssignmentData.copyWith(
          metadata: complexMetadata,
        );
        final fullAssignment = assignment.toAssignment();

        expect(
          fullAssignment.metadata?['nested'],
          equals(complexMetadata['nested']),
        );
        expect(
          fullAssignment.metadata?['list'],
          equals(complexMetadata['list']),
        );
        expect(fullAssignment.metadata?['status'], equals('pending'));
      });
    });
  });
}
