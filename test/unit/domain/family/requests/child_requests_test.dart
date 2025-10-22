import 'package:flutter_test/flutter_test.dart';

import 'package:edulift/features/family/domain/requests/child_requests.dart';

void main() {
  group('Child Request Models Tests', () {
    group('CreateChildRequest', () {
      test('should create request with required name and optional age', () {
        // Arrange & Act
        const request = CreateChildRequest(name: 'John Doe', age: 10);

        // Assert
        expect(request.name, equals('John Doe'));
        expect(request.age, equals(10));
      });

      test('should create request with name only', () {
        // Arrange & Act
        const request = CreateChildRequest(name: 'Jane Doe');

        // Assert
        expect(request.name, equals('Jane Doe'));
        expect(request.age, isNull);
      });

      test('should handle empty name gracefully', () {
        // Arrange & Act
        const request = CreateChildRequest(name: '');

        // Assert
        expect(request.name, equals(''));
        expect(request.age, isNull);
      });

      test('should handle special characters in name', () {
        // Arrange & Act
        const request = CreateChildRequest(name: 'José María O\'Connor-Smith');

        // Assert
        expect(request.name, equals('José María O\'Connor-Smith'));
      });

      test('should handle unicode characters in name', () {
        // Arrange & Act
        const request = CreateChildRequest(name: '李小明');

        // Assert
        expect(request.name, equals('李小明'));
      });

      test('should handle extreme age values', () {
        // Arrange & Act
        const zeroAgeRequest = CreateChildRequest(name: 'Baby', age: 0);
        const highAgeRequest = CreateChildRequest(name: 'Teen', age: 18);
        const negativeAgeRequest = CreateChildRequest(name: 'Invalid', age: -1);

        // Assert
        expect(zeroAgeRequest.age, equals(0));
        expect(highAgeRequest.age, equals(18));
        expect(negativeAgeRequest.age, equals(-1));
      });

      test('should be equal when all properties match', () {
        // Arrange
        const request1 = CreateChildRequest(name: 'John Doe', age: 10);
        const request2 = CreateChildRequest(name: 'John Doe', age: 10);

        // Assert
        expect(request1, equals(request2));
      });

      test('should not be equal when name differs', () {
        // Arrange
        const request1 = CreateChildRequest(name: 'John Doe', age: 10);
        const request2 = CreateChildRequest(name: 'Jane Doe', age: 10);

        // Assert
        expect(request1, isNot(equals(request2)));
      });

      test('should not be equal when age differs', () {
        // Arrange
        const request1 = CreateChildRequest(name: 'John Doe', age: 10);
        const request2 = CreateChildRequest(name: 'John Doe', age: 11);

        // Assert
        expect(request1, isNot(equals(request2)));
      });

      test('should not be equal when age is null vs non-null', () {
        // Arrange
        const request1 = CreateChildRequest(name: 'John Doe', age: 10);
        const request2 = CreateChildRequest(name: 'John Doe');

        // Assert
        expect(request1, isNot(equals(request2)));
      });

      test('should have same hash code when equal', () {
        // Arrange
        const request1 = CreateChildRequest(name: 'John Doe', age: 10);
        const request2 = CreateChildRequest(name: 'John Doe', age: 10);

        // Assert
        expect(request1.hashCode, equals(request2.hashCode));
      });

      test('should handle very long names', () {
        // Arrange
        final longName = 'A' * 1000;
        final request = CreateChildRequest(name: longName, age: 10);

        // Assert
        expect(request.name, equals(longName));
        expect(request.name.length, equals(1000));
      });
    });

    group('UpdateChildRequest', () {
      test('should create request with all optional properties', () {
        // Arrange & Act
        const request = UpdateChildRequest(name: 'Updated Name', age: 12);

        // Assert
        expect(request.name, equals('Updated Name'));
        expect(request.age, equals(12));
      });

      test('should create request with only name', () {
        // Arrange & Act
        const request = UpdateChildRequest(name: 'Only Name');

        // Assert
        expect(request.name, equals('Only Name'));
        expect(request.age, isNull);
      });

      test('should create request with only age', () {
        // Arrange & Act
        const request = UpdateChildRequest(age: 15);

        // Assert
        expect(request.name, isNull);
        expect(request.age, equals(15));
      });

      test('should create empty request', () {
        // Arrange & Act
        const request = UpdateChildRequest();

        // Assert
        expect(request.name, isNull);
        expect(request.age, isNull);
      });

      test('should handle special characters in name', () {
        // Arrange & Act
        const request = UpdateChildRequest(name: 'مريم أحمد');

        // Assert
        expect(request.name, equals('مريم أحمد'));
      });

      test('should handle edge age values', () {
        // Arrange & Act
        const zeroAge = UpdateChildRequest(age: 0);
        const negativeAge = UpdateChildRequest(age: -5);
        const highAge = UpdateChildRequest(age: 100);

        // Assert
        expect(zeroAge.age, equals(0));
        expect(negativeAge.age, equals(-5));
        expect(highAge.age, equals(100));
      });

      test('should be equal when all properties match', () {
        // Arrange
        const request1 = UpdateChildRequest(name: 'Test', age: 10);
        const request2 = UpdateChildRequest(name: 'Test', age: 10);

        // Assert
        expect(request1, equals(request2));
      });

      test('should be equal when both have null properties', () {
        // Arrange
        const request1 = UpdateChildRequest();
        const request2 = UpdateChildRequest();

        // Assert
        expect(request1, equals(request2));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        const request1 = UpdateChildRequest(name: 'Test', age: 10);
        const request2 = UpdateChildRequest(name: 'Different', age: 10);
        const request3 = UpdateChildRequest(name: 'Test', age: 11);
        const request4 = UpdateChildRequest(name: 'Test');

        // Assert
        expect(request1, isNot(equals(request2)));
        expect(request1, isNot(equals(request3)));
        expect(request1, isNot(equals(request4)));
      });

      test('should have same hash code when equal', () {
        // Arrange
        const request1 = UpdateChildRequest(name: 'Test', age: 10);
        const request2 = UpdateChildRequest(name: 'Test', age: 10);

        // Assert
        expect(request1.hashCode, equals(request2.hashCode));
      });

      test('should handle empty string vs null name differently', () {
        // Arrange
        const emptyStringRequest = UpdateChildRequest(name: '');
        const nullNameRequest = UpdateChildRequest();

        // Assert
        expect(emptyStringRequest.name, equals(''));
        expect(nullNameRequest.name, isNull);
        expect(emptyStringRequest, isNot(equals(nullNameRequest)));
      });
    });

    group('UpdateChildParams', () {
      test('should create params with childId and request', () {
        // Arrange
        const childId = 'child-123';
        const request = UpdateChildRequest(name: 'Updated Name');

        // Act
        const params = UpdateChildParams(childId: childId, request: request);

        // Assert
        expect(params.childId, equals(childId));
        expect(params.request, equals(request));
      });

      test('should be equal when all properties match', () {
        // Arrange
        const request = UpdateChildRequest(name: 'Test Child');
        const params1 = UpdateChildParams(
          childId: 'child-123',
          request: request,
        );
        const params2 = UpdateChildParams(
          childId: 'child-123',
          request: request,
        );

        // Assert
        expect(params1, equals(params2));
      });

      test('should not be equal when childId differs', () {
        // Arrange
        const request = UpdateChildRequest(name: 'Test Child');
        const params1 = UpdateChildParams(
          childId: 'child-123',
          request: request,
        );
        const params2 = UpdateChildParams(
          childId: 'child-456',
          request: request,
        );

        // Assert
        expect(params1, isNot(equals(params2)));
      });

      test('should not be equal when request differs', () {
        // Arrange
        const request1 = UpdateChildRequest(name: 'Test Child 1');
        const request2 = UpdateChildRequest(name: 'Test Child 2');
        const params1 = UpdateChildParams(
          childId: 'child-123',
          request: request1,
        );
        const params2 = UpdateChildParams(
          childId: 'child-123',
          request: request2,
        );

        // Assert
        expect(params1, isNot(equals(params2)));
      });

      test('should have same hash code when equal', () {
        // Arrange
        const request = UpdateChildRequest(name: 'Test Child');
        const params1 = UpdateChildParams(
          childId: 'child-123',
          request: request,
        );
        const params2 = UpdateChildParams(
          childId: 'child-123',
          request: request,
        );

        // Assert
        expect(params1.hashCode, equals(params2.hashCode));
      });

      test('should handle various childId formats', () {
        // Arrange
        const request = UpdateChildRequest(name: 'Test');
        final childIds = [
          'child-123',
          'child_456',
          'CHILD-789',
          '123e4567-e89b-12d3-a456-426614174000',
          '',
          'very-long-child-id-with-many-characters',
        ];

        // Act & Assert
        for (final childId in childIds) {
          final params = UpdateChildParams(childId: childId, request: request);
          expect(params.childId, equals(childId));
          expect(params.request, equals(request));
        }
      });

      test('should handle empty request', () {
        // Arrange
        const emptyRequest = UpdateChildRequest();
        const params = UpdateChildParams(
          childId: 'child-123',
          request: emptyRequest,
        );

        // Assert
        expect(params.request.name, isNull);
        expect(params.request.age, isNull);
      });
    });

    group('RemoveChildParams', () {
      test('should create params with childId', () {
        // Arrange & Act
        const params = RemoveChildParams(childId: 'child-123');

        // Assert
        expect(params.childId, equals('child-123'));
      });

      test('should be equal when childId matches', () {
        // Arrange
        const params1 = RemoveChildParams(childId: 'child-123');
        const params2 = RemoveChildParams(childId: 'child-123');

        // Assert
        expect(params1, equals(params2));
      });

      test('should not be equal when childId differs', () {
        // Arrange
        const params1 = RemoveChildParams(childId: 'child-123');
        const params2 = RemoveChildParams(childId: 'child-456');

        // Assert
        expect(params1, isNot(equals(params2)));
      });

      test('should have same hash code when equal', () {
        // Arrange
        const params1 = RemoveChildParams(childId: 'child-123');
        const params2 = RemoveChildParams(childId: 'child-123');

        // Assert
        expect(params1.hashCode, equals(params2.hashCode));
      });

      test('should handle various childId formats', () {
        // Arrange
        final childIds = [
          'child-123',
          'child_456',
          'CHILD-789',
          '123e4567-e89b-12d3-a456-426614174000',
          '',
          '  whitespace  ',
          'special-chars-!@#\$%',
          'unicode-李小明',
          'very-long-${'id' * 100}',
        ];

        // Act & Assert
        for (final childId in childIds) {
          final params = RemoveChildParams(childId: childId);
          expect(params.childId, equals(childId));
          expect(params.props, contains(childId));
        }
      });
    });

    group('BulkUpdateChildRequest', () {
      test('should create request with all properties', () {
        // Arrange & Act
        const request = BulkUpdateChildRequest(
          childId: 'child-123',
          name: 'Bulk Updated Name',
          age: 15,
        );

        // Assert
        expect(request.childId, equals('child-123'));
        expect(request.name, equals('Bulk Updated Name'));
        expect(request.age, equals(15));
      });

      test('should create request with required childId only', () {
        // Arrange & Act
        const request = BulkUpdateChildRequest(childId: 'child-123');

        // Assert
        expect(request.childId, equals('child-123'));
        expect(request.name, isNull);
        expect(request.age, isNull);
      });

      test('should create request with childId and name only', () {
        // Arrange & Act
        const request = BulkUpdateChildRequest(
          childId: 'child-123',
          name: 'New Name Only',
        );

        // Assert
        expect(request.childId, equals('child-123'));
        expect(request.name, equals('New Name Only'));
        expect(request.age, isNull);
      });

      test('should create request with childId and age only', () {
        // Arrange & Act
        const request = BulkUpdateChildRequest(childId: 'child-123', age: 16);

        // Assert
        expect(request.childId, equals('child-123'));
        expect(request.name, isNull);
        expect(request.age, equals(16));
      });

      test('should be equal when all properties match', () {
        // Arrange
        const request1 = BulkUpdateChildRequest(
          childId: 'child-123',
          name: 'Test',
          age: 10,
        );
        const request2 = BulkUpdateChildRequest(
          childId: 'child-123',
          name: 'Test',
          age: 10,
        );

        // Assert
        expect(request1, equals(request2));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        const baseRequest = BulkUpdateChildRequest(
          childId: 'child-123',
          name: 'Test',
          age: 10,
        );
        const differentId = BulkUpdateChildRequest(
          childId: 'child-456',
          name: 'Test',
          age: 10,
        );
        const differentName = BulkUpdateChildRequest(
          childId: 'child-123',
          name: 'Different',
          age: 10,
        );
        const differentAge = BulkUpdateChildRequest(
          childId: 'child-123',
          name: 'Test',
          age: 11,
        );

        // Assert
        expect(baseRequest, isNot(equals(differentId)));
        expect(baseRequest, isNot(equals(differentName)));
        expect(baseRequest, isNot(equals(differentAge)));
      });

      test('should have same hash code when equal', () {
        // Arrange
        const request1 = BulkUpdateChildRequest(
          childId: 'child-123',
          name: 'Test',
          age: 10,
        );
        const request2 = BulkUpdateChildRequest(
          childId: 'child-123',
          name: 'Test',
          age: 10,
        );

        // Assert
        expect(request1.hashCode, equals(request2.hashCode));
      });

      test('should handle special characters and unicode', () {
        // Arrange & Act
        const request = BulkUpdateChildRequest(
          childId: 'special-çhild-123',
          name: 'José María 李小明',
          age: 10,
        );

        // Assert
        expect(request.childId, equals('special-çhild-123'));
        expect(request.name, equals('José María 李小明'));
      });
    });

    group('SearchChildrenRequest', () {
      test('should create request with required query', () {
        // Arrange & Act
        const request = SearchChildrenRequest(query: 'John');

        // Assert
        expect(request.query, equals('John'));
        expect(request.groupId, isNull);
        expect(request.minAge, isNull);
        expect(request.maxAge, isNull);
        expect(request.requirements, isNull);
        expect(request.hasRequirements, isNull);
      });

      test('should create request with all optional parameters', () {
        // Arrange & Act
        const request = SearchChildrenRequest(
          query: 'test query',
          groupId: 'group-123',
          minAge: 8,
          maxAge: 15,
          requirements: ['special_needs', 'dietary_restrictions'],
          hasRequirements: true,
        );

        // Assert
        expect(request.query, equals('test query'));
        expect(request.groupId, equals('group-123'));
        expect(request.minAge, equals(8));
        expect(request.maxAge, equals(15));
        expect(
          request.requirements,
          equals(['special_needs', 'dietary_restrictions']),
        );
        expect(request.hasRequirements, isTrue);
      });

      test('should create request with partial parameters', () {
        // Arrange & Act
        const request = SearchChildrenRequest(
          query: 'partial',
          minAge: 10,
          hasRequirements: false,
        );

        // Assert
        expect(request.query, equals('partial'));
        expect(request.minAge, equals(10));
        expect(request.hasRequirements, isFalse);
        expect(request.groupId, isNull);
        expect(request.maxAge, isNull);
        expect(request.requirements, isNull);
      });

      test('should handle empty query string', () {
        // Arrange & Act
        const request = SearchChildrenRequest(query: '');

        // Assert
        expect(request.query, equals(''));
      });

      test('should handle special characters in query', () {
        // Arrange & Act
        const request = SearchChildrenRequest(
          query: 'José María O\'Connor',
          groupId: 'special-group-éñ',
        );

        // Assert
        expect(request.query, equals('José María O\'Connor'));
        expect(request.groupId, equals('special-group-éñ'));
      });

      test('should handle unicode in query', () {
        // Arrange & Act
        const request = SearchChildrenRequest(query: '李小明 мريم');

        // Assert
        expect(request.query, equals('李小明 мريم'));
      });

      test('should handle edge age values', () {
        // Arrange & Act
        const request = SearchChildrenRequest(
          query: 'age test',
          minAge: -1,
          maxAge: 100,
        );

        // Assert
        expect(request.minAge, equals(-1));
        expect(request.maxAge, equals(100));
      });

      test('should handle empty requirements list', () {
        // Arrange & Act
        const request = SearchChildrenRequest(
          query: 'test',
          requirements: [],
          hasRequirements: false,
        );

        // Assert
        expect(request.requirements, equals([]));
        expect(request.hasRequirements, isFalse);
      });

      test('should handle various requirement types', () {
        // Arrange & Act
        const request = SearchChildrenRequest(
          query: 'requirements test',
          requirements: [
            'special_needs',
            'dietary_restrictions',
            'medical_conditions',
            'transportation_assistance',
            'after_school_care',
          ],
        );

        // Assert
        expect(request.requirements!.length, equals(5));
        expect(request.requirements, contains('special_needs'));
        expect(request.requirements, contains('medical_conditions'));
      });

      test('should be equal when all properties match', () {
        // Arrange
        const request1 = SearchChildrenRequest(
          query: 'test',
          groupId: 'group-1',
          minAge: 5,
          maxAge: 15,
          requirements: ['req1'],
          hasRequirements: true,
        );
        const request2 = SearchChildrenRequest(
          query: 'test',
          groupId: 'group-1',
          minAge: 5,
          maxAge: 15,
          requirements: ['req1'],
          hasRequirements: true,
        );

        // Assert
        expect(request1, equals(request2));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        const baseRequest = SearchChildrenRequest(
          query: 'test',
          groupId: 'group-1',
          minAge: 5,
        );
        const differentQuery = SearchChildrenRequest(
          query: 'different',
          groupId: 'group-1',
          minAge: 5,
        );
        const differentGroup = SearchChildrenRequest(
          query: 'test',
          groupId: 'group-2',
          minAge: 5,
        );
        const differentAge = SearchChildrenRequest(
          query: 'test',
          groupId: 'group-1',
          minAge: 6,
        );

        // Assert
        expect(baseRequest, isNot(equals(differentQuery)));
        expect(baseRequest, isNot(equals(differentGroup)));
        expect(baseRequest, isNot(equals(differentAge)));
      });

      test('should have same hash code when equal', () {
        // Arrange
        const request1 = SearchChildrenRequest(
          query: 'test',
          requirements: ['req1', 'req2'],
        );
        const request2 = SearchChildrenRequest(
          query: 'test',
          requirements: ['req1', 'req2'],
        );

        // Assert
        expect(request1.hashCode, equals(request2.hashCode));
      });

      test('should handle inverted age ranges', () {
        // Arrange & Act
        const request = SearchChildrenRequest(
          query: 'inverted',
          minAge: 15,
          maxAge: 5, // Invalid range
        );

        // Assert - Should still create the object (validation elsewhere)
        expect(request.minAge, equals(15));
        expect(request.maxAge, equals(5));
      });

      test('should handle very long query strings', () {
        // Arrange
        final longQuery = 'search query ' * 100;
        final request = SearchChildrenRequest(query: longQuery);

        // Assert
        expect(request.query, equals(longQuery));
        expect(request.query.length, greaterThan(1000));
      });

      test('should handle large requirements list', () {
        // Arrange
        final largeRequirements = List.generate(
          100,
          (index) => 'requirement_$index',
        );
        final request = SearchChildrenRequest(
          query: 'large list',
          requirements: largeRequirements,
        );

        // Assert
        expect(request.requirements!.length, equals(100));
        expect(request.requirements!.first, equals('requirement_0'));
        expect(request.requirements!.last, equals('requirement_99'));
      });
    });

    group('Request Models Integration', () {
      test('should work together in typical workflows', () {
        // Arrange - Create child workflow
        const createRequest = CreateChildRequest(
          name: 'Workflow Child',
          age: 8,
        );

        // Update workflow
        const updateRequest = UpdateChildRequest(
          name: 'Updated Workflow Child',
        );
        const updateParams = UpdateChildParams(
          childId: 'workflow-child-123',
          request: updateRequest,
        );

        // Remove workflow
        const removeParams = RemoveChildParams(childId: 'workflow-child-123');

        // Search workflow
        const searchRequest = SearchChildrenRequest(
          query: 'Workflow',
          minAge: 5,
          maxAge: 10,
        );

        // Assert - All requests should be properly formed
        expect(createRequest.name, equals('Workflow Child'));
        expect(updateParams.childId, equals('workflow-child-123'));
        expect(removeParams.childId, equals('workflow-child-123'));
        expect(searchRequest.query, equals('Workflow'));
      });

      test('should handle bulk operations with multiple requests', () {
        // Arrange
        final createRequests = [
          const CreateChildRequest(name: 'Bulk Child 1', age: 8),
          const CreateChildRequest(name: 'Bulk Child 2', age: 10),
          const CreateChildRequest(name: 'Bulk Child 3', age: 12),
        ];

        final bulkUpdateRequests = [
          const BulkUpdateChildRequest(
            childId: 'bulk-1',
            name: 'Updated Bulk 1',
          ),
          const BulkUpdateChildRequest(childId: 'bulk-2', age: 11),
          const BulkUpdateChildRequest(
            childId: 'bulk-3',
            name: 'Updated Bulk 3',
            age: 13,
          ),
        ];

        // Assert
        expect(createRequests.length, equals(3));
        expect(bulkUpdateRequests.length, equals(3));
        expect(
          createRequests.every((r) => r.name.startsWith('Bulk Child')),
          isTrue,
        );
        expect(
          bulkUpdateRequests.every((r) => r.childId.startsWith('bulk-')),
          isTrue,
        );
      });

      test('should maintain consistency across request types', () {
        // Arrange
        const childName = 'Consistency Test Child';
        const childAge = 10;

        const createRequest = CreateChildRequest(
          name: childName,
          age: childAge,
        );
        const updateRequest = UpdateChildRequest(
          name: childName,
          age: childAge,
        );
        const bulkRequest = BulkUpdateChildRequest(
          childId: 'consistency-child',
          name: childName,
          age: childAge,
        );

        // Assert - Same values should be handled consistently
        expect(createRequest.name, equals(updateRequest.name));
        expect(createRequest.age, equals(updateRequest.age));
        expect(updateRequest.name, equals(bulkRequest.name));
        expect(updateRequest.age, equals(bulkRequest.age));
      });
    });
  });
}
