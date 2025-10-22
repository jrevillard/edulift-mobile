// UpdateGroupRequest DTO Unit Tests
// Tests JSON serialization and validation for UpdateGroupRequest

import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/network/requests/group_requests.dart';

void main() {
  group('UpdateGroupRequest', () {
    group('JSON Serialization', () {
      test('should serialize with name only', () {
        // Arrange
        const request = UpdateGroupRequest(name: 'Updated Group');

        // Act
        final json = request.toJson();

        // Assert
        expect(json, equals({'name': 'Updated Group'}));
        expect(json.containsKey('description'), isFalse);
      });

      test('should serialize with name and description', () {
        // Arrange
        const request = UpdateGroupRequest(
          name: 'Updated Group',
          description: 'Updated Description',
        );

        // Act
        final json = request.toJson();

        // Assert
        expect(json, equals({
          'name': 'Updated Group',
          'description': 'Updated Description',
        }));
      });

      test('should serialize with description only', () {
        // Arrange
        const request = UpdateGroupRequest(description: 'Updated Description');

        // Act
        final json = request.toJson();

        // Assert
        expect(json, equals({'description': 'Updated Description'}));
        expect(json.containsKey('name'), isFalse);
      });

      test('should exclude null fields from JSON', () {
        // Arrange
        const request = UpdateGroupRequest(name: 'Updated Group');

        // Act
        final json = request.toJson();

        // Assert - Only name should be in JSON
        expect(json.length, equals(1));
        expect(json.containsKey('name'), isTrue);
        expect(json.containsKey('description'), isFalse);
      });

      test('should handle empty request', () {
        // Arrange
        const request = UpdateGroupRequest();

        // Act
        final json = request.toJson();

        // Assert - Empty JSON when all fields are null
        expect(json, isEmpty);
      });
    });

    group('JSON Deserialization', () {
      test('should deserialize from JSON with name only', () {
        // Arrange
        final json = {'name': 'Updated Group'};

        // Act
        final request = UpdateGroupRequest.fromJson(json);

        // Assert
        expect(request.name, equals('Updated Group'));
        expect(request.description, isNull);
      });

      test('should deserialize from JSON with name and description', () {
        // Arrange
        final json = {
          'name': 'Updated Group',
          'description': 'Updated Description',
        };

        // Act
        final request = UpdateGroupRequest.fromJson(json);

        // Assert
        expect(request.name, equals('Updated Group'));
        expect(request.description, equals('Updated Description'));
      });

      test('should deserialize from JSON with description only', () {
        // Arrange
        final json = {'description': 'Updated Description'};

        // Act
        final request = UpdateGroupRequest.fromJson(json);

        // Assert
        expect(request.name, isNull);
        expect(request.description, equals('Updated Description'));
      });

      test('should deserialize from empty JSON', () {
        // Arrange
        final json = <String, dynamic>{};

        // Act
        final request = UpdateGroupRequest.fromJson(json);

        // Assert
        expect(request.name, isNull);
        expect(request.description, isNull);
      });
    });

    group('Dead Fields Verification', () {
      test('should not contain settings field', () {
        // Arrange
        const request = UpdateGroupRequest(name: 'Test');

        // Act
        final json = request.toJson();

        // Assert - Verify dead field is not present
        expect(json.containsKey('settings'), isFalse);
      });

      test('should not contain maxMembers field', () {
        // Arrange
        const request = UpdateGroupRequest(name: 'Test');

        // Act
        final json = request.toJson();

        // Assert - Verify dead field is not present
        expect(json.containsKey('maxMembers'), isFalse);
      });

      test('should not contain scheduleConfig field', () {
        // Arrange
        const request = UpdateGroupRequest(name: 'Test');

        // Act
        final json = request.toJson();

        // Assert - Verify dead field is not present
        expect(json.containsKey('scheduleConfig'), isFalse);
      });

      test('should only allow name and description fields', () {
        // Arrange
        const request = UpdateGroupRequest(
          name: 'Test',
          description: 'Description',
        );

        // Act
        final json = request.toJson();

        // Assert - Only name and description should be present
        expect(json.keys.toSet(), equals({'name', 'description'}));
        expect(json.length, equals(2));
      });
    });

    group('Equatable', () {
      test('should be equal with same values', () {
        // Arrange
        const request1 = UpdateGroupRequest(
          name: 'Test Group',
          description: 'Test Description',
        );
        const request2 = UpdateGroupRequest(
          name: 'Test Group',
          description: 'Test Description',
        );

        // Assert
        expect(request1, equals(request2));
        expect(request1.hashCode, equals(request2.hashCode));
      });

      test('should not be equal with different names', () {
        // Arrange
        const request1 = UpdateGroupRequest(name: 'Group A');
        const request2 = UpdateGroupRequest(name: 'Group B');

        // Assert
        expect(request1, isNot(equals(request2)));
      });

      test('should not be equal with different descriptions', () {
        // Arrange
        const request1 = UpdateGroupRequest(
          name: 'Test',
          description: 'Description A',
        );
        const request2 = UpdateGroupRequest(
          name: 'Test',
          description: 'Description B',
        );

        // Assert
        expect(request1, isNot(equals(request2)));
      });

      test('should handle null equality correctly', () {
        // Arrange
        const request1 = UpdateGroupRequest(name: 'Test');
        const request2 = UpdateGroupRequest(name: 'Test');

        // Assert - Both should be equal (explicit null equals implicit null)
        expect(request1, equals(request2));
      });
    });

    group('Edge Cases', () {
      test('should handle empty strings', () {
        // Arrange
        const request = UpdateGroupRequest(name: '', description: '');

        // Act
        final json = request.toJson();

        // Assert - Empty strings should still be serialized
        expect(json, equals({'name': '', 'description': ''}));
      });

      test('should handle whitespace-only strings', () {
        // Arrange
        const request = UpdateGroupRequest(
          name: '   ',
          description: '\n\t  ',
        );

        // Act
        final json = request.toJson();

        // Assert - Whitespace strings should be preserved
        expect(json['name'], equals('   '));
        expect(json['description'], equals('\n\t  '));
      });

      test('should handle special characters', () {
        // Arrange
        const request = UpdateGroupRequest(
          name: 'Group "Special" & <Test>',
          description: 'Line 1\nLine 2\tTabbed',
        );

        // Act
        final json = request.toJson();

        // Assert - Special characters should be preserved
        expect(json['name'], equals('Group "Special" & <Test>'));
        expect(json['description'], equals('Line 1\nLine 2\tTabbed'));
      });

      test('should handle very long strings', () {
        // Arrange
        final longName = 'A' * 1000;
        final longDescription = 'B' * 5000;
        final request = UpdateGroupRequest(
          name: longName,
          description: longDescription,
        );

        // Act
        final json = request.toJson();

        // Assert - Long strings should be preserved
        expect(json['name'], equals(longName));
        expect(json['description'], equals(longDescription));
      });

      test('should handle unicode characters', () {
        // Arrange
        const request = UpdateGroupRequest(
          name: 'Test 测试 テスト 🎉',
          description: 'Emoji: 😀 🚀 Arabic: مرحبا',
        );

        // Act
        final json = request.toJson();

        // Assert - Unicode should be preserved
        expect(json['name'], equals('Test 测试 テスト 🎉'));
        expect(json['description'], equals('Emoji: 😀 🚀 Arabic: مرحبا'));
      });
    });

    group('Round-trip Serialization', () {
      test('should maintain data through serialization round-trip', () {
        // Arrange
        const original = UpdateGroupRequest(
          name: 'Test Group',
          description: 'Test Description',
        );

        // Act - Serialize and deserialize
        final json = original.toJson();
        final deserialized = UpdateGroupRequest.fromJson(json);

        // Assert - Should be equal to original
        expect(deserialized, equals(original));
      });

      test('should maintain null values through round-trip', () {
        // Arrange
        const original = UpdateGroupRequest(name: 'Test Group');

        // Act - Serialize and deserialize
        final json = original.toJson();
        final deserialized = UpdateGroupRequest.fromJson(json);

        // Assert - Should preserve null description
        expect(deserialized, equals(original));
        expect(deserialized.description, isNull);
      });
    });
  });
}
