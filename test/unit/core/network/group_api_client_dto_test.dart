import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/network/group_api_client.dart';
import 'package:edulift/core/network/models/group/group_dto.dart';

/// CRITICAL REGRESSION PREVENTION: GroupDto DTO Parsing Tests
///
/// These tests validate that GroupDto correctly parses the actual API response format.
/// This prevents regressions after the fix for matching the real API format.
///
/// Context: GroupDto was fixed to match actual API response which includes:
/// - userRole (not role)
/// - joinedAt timestamp
/// - ownerFamily nested object
/// - familyCount and scheduleCount integers
void main() {
  group('GroupDto DTO Parsing Tests', () {
    group('Complete API Response', () {
      test('should parse actual API response with all fields', () {
        // Arrange: This is the EXACT format returned by the backend API
        final json = {
          'id': 'cmfo27ec3000gv2unmp3729r5',
          'name': 'MON GROUPE',
          'familyId': 'cmfliu6zy00069jkjott1u91k',
          'createdAt': '2025-09-17T14:10:37.778Z',
          'updatedAt': '2025-09-17T14:10:37.778Z',
          'userRole': 'ADMIN',
          'joinedAt': '2025-10-02T19:44:16.667Z',
          'ownerFamily': {'id': 'cmfliu6zy00069jkjott1u91k', 'name': 'Toto'},
          'familyCount': 0,
          'scheduleCount': 0,
        };

        // Act
        final groupData = GroupDto.fromJson(json);

        // Assert: Verify all fields parsed correctly
        expect(groupData.id, 'cmfo27ec3000gv2unmp3729r5');
        expect(groupData.name, 'MON GROUPE');
        expect(groupData.familyId, 'cmfliu6zy00069jkjott1u91k');
        expect(groupData.createdAt, '2025-09-17T14:10:37.778Z');
        expect(groupData.updatedAt, '2025-09-17T14:10:37.778Z');
        expect(groupData.userRole, 'ADMIN');
        expect(groupData.joinedAt, '2025-10-02T19:44:16.667Z');
        expect(groupData.ownerFamily, isNotNull);
        expect(groupData.ownerFamily!['id'], 'cmfliu6zy00069jkjott1u91k');
        expect(groupData.ownerFamily!['name'], 'Toto');
        expect(groupData.familyCount, 0);
        expect(groupData.scheduleCount, 0);
      });

      test('should parse group with description', () {
        // Arrange
        final json = {
          'id': 'group-123',
          'name': 'Test Group',
          'description': 'A group for testing',
          'familyId': 'family-456',
          'createdAt': '2025-09-17T14:10:37.778Z',
          'updatedAt': '2025-09-17T14:10:37.778Z',
          'userRole': 'MEMBER',
          'joinedAt': '2025-10-02T19:44:16.667Z',
          'ownerFamily': {'id': 'family-456', 'name': 'Owner Family'},
          'familyCount': 5,
          'scheduleCount': 3,
        };

        // Act
        final groupData = GroupDto.fromJson(json);

        // Assert
        expect(groupData.id, 'group-123');
        expect(groupData.name, 'Test Group');
        expect(groupData.description, 'A group for testing');
        expect(groupData.familyId, 'family-456');
        expect(groupData.userRole, 'MEMBER');
        expect(groupData.joinedAt, '2025-10-02T19:44:16.667Z');
        expect(groupData.ownerFamily, isNotNull);
        expect(groupData.familyCount, 5);
        expect(groupData.scheduleCount, 3);
      });

      test('should parse group with invite code', () {
        // Arrange
        final json = {
          'id': 'group-789',
          'name': 'Test Group',
          'familyId': 'family-456',
          'invite_code': 'ABCD1234',
          'createdAt': '2025-09-17T14:10:37.778Z',
          'updatedAt': '2025-09-17T14:10:37.778Z',
        };

        // Act
        final groupData = GroupDto.fromJson(json);

        // Assert
        expect(groupData.id, 'group-789');
        expect(groupData.inviteCode, 'ABCD1234');
      });
    });

    group('Minimal Required Fields', () {
      test('should parse with only required fields', () {
        // Arrange: Minimum valid response
        final json = {
          'id': 'group-minimal',
          'name': 'Minimal Group',
          'familyId': 'family-minimal',
          'createdAt': '2025-09-17T14:10:37.778Z',
          'updatedAt': '2025-09-17T14:10:37.778Z',
        };

        // Act
        final groupData = GroupDto.fromJson(json);

        // Assert: Required fields present
        expect(groupData.id, 'group-minimal');
        expect(groupData.name, 'Minimal Group');
        expect(groupData.familyId, 'family-minimal');
        expect(groupData.createdAt, '2025-09-17T14:10:37.778Z');
        expect(groupData.updatedAt, '2025-09-17T14:10:37.778Z');

        // Assert: Optional fields are null
        expect(groupData.description, isNull);
        expect(groupData.inviteCode, isNull);
        expect(groupData.userRole, isNull);
        expect(groupData.joinedAt, isNull);
        expect(groupData.ownerFamily, isNull);
        expect(groupData.familyCount, isNull);
        expect(groupData.scheduleCount, isNull);
      });
    });

    group('Null Optional Fields', () {
      test('should handle null description', () {
        // Arrange
        final json = {
          'id': 'group-123',
          'name': 'Test Group',
          'description': null,
          'familyId': 'family-456',
          'createdAt': '2025-09-17T14:10:37.778Z',
          'updatedAt': '2025-09-17T14:10:37.778Z',
        };

        // Act
        final groupData = GroupDto.fromJson(json);

        // Assert
        expect(groupData.description, isNull);
      });

      test('should handle null userRole', () {
        // Arrange
        final json = {
          'id': 'group-123',
          'name': 'Test Group',
          'familyId': 'family-456',
          'userRole': null,
          'createdAt': '2025-09-17T14:10:37.778Z',
          'updatedAt': '2025-09-17T14:10:37.778Z',
        };

        // Act
        final groupData = GroupDto.fromJson(json);

        // Assert
        expect(groupData.userRole, isNull);
      });

      test('should handle null joinedAt', () {
        // Arrange
        final json = {
          'id': 'group-123',
          'name': 'Test Group',
          'familyId': 'family-456',
          'joinedAt': null,
          'createdAt': '2025-09-17T14:10:37.778Z',
          'updatedAt': '2025-09-17T14:10:37.778Z',
        };

        // Act
        final groupData = GroupDto.fromJson(json);

        // Assert
        expect(groupData.joinedAt, isNull);
      });

      test('should handle null ownerFamily', () {
        // Arrange
        final json = {
          'id': 'group-123',
          'name': 'Test Group',
          'familyId': 'family-456',
          'ownerFamily': null,
          'createdAt': '2025-09-17T14:10:37.778Z',
          'updatedAt': '2025-09-17T14:10:37.778Z',
        };

        // Act
        final groupData = GroupDto.fromJson(json);

        // Assert
        expect(groupData.ownerFamily, isNull);
      });

      test('should handle null familyCount and scheduleCount', () {
        // Arrange
        final json = {
          'id': 'group-123',
          'name': 'Test Group',
          'familyId': 'family-456',
          'familyCount': null,
          'scheduleCount': null,
          'createdAt': '2025-09-17T14:10:37.778Z',
          'updatedAt': '2025-09-17T14:10:37.778Z',
        };

        // Act
        final groupData = GroupDto.fromJson(json);

        // Assert
        expect(groupData.familyCount, isNull);
        expect(groupData.scheduleCount, isNull);
      });

      test('should handle null invite_code', () {
        // Arrange
        final json = {
          'id': 'group-123',
          'name': 'Test Group',
          'familyId': 'family-456',
          'invite_code': null,
          'createdAt': '2025-09-17T14:10:37.778Z',
          'updatedAt': '2025-09-17T14:10:37.778Z',
        };

        // Act
        final groupData = GroupDto.fromJson(json);

        // Assert
        expect(groupData.inviteCode, isNull);
      });
    });

    group('Edge Cases', () {
      test('should handle zero counts', () {
        // Arrange
        final json = {
          'id': 'group-123',
          'name': 'Test Group',
          'familyId': 'family-456',
          'familyCount': 0,
          'scheduleCount': 0,
          'createdAt': '2025-09-17T14:10:37.778Z',
          'updatedAt': '2025-09-17T14:10:37.778Z',
        };

        // Act
        final groupData = GroupDto.fromJson(json);

        // Assert
        expect(groupData.familyCount, 0);
        expect(groupData.scheduleCount, 0);
      });

      test('should handle large counts', () {
        // Arrange
        final json = {
          'id': 'group-123',
          'name': 'Test Group',
          'familyId': 'family-456',
          'familyCount': 999,
          'scheduleCount': 1000,
          'createdAt': '2025-09-17T14:10:37.778Z',
          'updatedAt': '2025-09-17T14:10:37.778Z',
        };

        // Act
        final groupData = GroupDto.fromJson(json);

        // Assert
        expect(groupData.familyCount, 999);
        expect(groupData.scheduleCount, 1000);
      });

      test('should handle empty ownerFamily object', () {
        // Arrange: Use explicit Map<String, dynamic> type to avoid cast issues
        final json = {
          'id': 'group-123',
          'name': 'Test Group',
          'familyId': 'family-456',
          'ownerFamily': <String, dynamic>{},
          'createdAt': '2025-09-17T14:10:37.778Z',
          'updatedAt': '2025-09-17T14:10:37.778Z',
        };

        // Act
        final groupData = GroupDto.fromJson(json);

        // Assert
        expect(groupData.ownerFamily, isNotNull);
        expect(groupData.ownerFamily, isEmpty);
      });

      test('should handle ownerFamily with extra fields', () {
        // Arrange
        final json = {
          'id': 'group-123',
          'name': 'Test Group',
          'familyId': 'family-456',
          'ownerFamily': {
            'id': 'family-owner',
            'name': 'Owner Family',
            'extraField1': 'value1',
            'extraField2': 123,
          },
          'createdAt': '2025-09-17T14:10:37.778Z',
          'updatedAt': '2025-09-17T14:10:37.778Z',
        };

        // Act
        final groupData = GroupDto.fromJson(json);

        // Assert: Should parse without issues, extra fields preserved in Map
        expect(groupData.ownerFamily, isNotNull);
        expect(groupData.ownerFamily!['id'], 'family-owner');
        expect(groupData.ownerFamily!['name'], 'Owner Family');
        expect(groupData.ownerFamily!['extraField1'], 'value1');
        expect(groupData.ownerFamily!['extraField2'], 123);
      });

      test('should handle empty string values', () {
        // Arrange
        final json = {
          'id': 'group-123',
          'name': '',
          'description': '',
          'familyId': 'family-456',
          'userRole': '',
          'createdAt': '2025-09-17T14:10:37.778Z',
          'updatedAt': '2025-09-17T14:10:37.778Z',
        };

        // Act
        final groupData = GroupDto.fromJson(json);

        // Assert: Should parse empty strings as valid values
        expect(groupData.name, '');
        expect(groupData.description, '');
        expect(groupData.userRole, '');
      });

      test('should handle special characters in strings', () {
        // Arrange
        final json = {
          'id': 'group-123',
          'name': "Groupe d'école 🚌 École #1",
          'description': 'Test with special chars: @#\$%^&*()',
          'familyId': 'family-456',
          'createdAt': '2025-09-17T14:10:37.778Z',
          'updatedAt': '2025-09-17T14:10:37.778Z',
          'ownerFamily': {
            'id': 'family-owner',
            'name': "Famille D'Éléphant 🐘",
          },
        };

        // Act
        final groupData = GroupDto.fromJson(json);

        // Assert
        expect(groupData.name, "Groupe d'école 🚌 École #1");
        expect(groupData.description, 'Test with special chars: @#\$%^&*()');
        expect(groupData.ownerFamily!['name'], "Famille D'Éléphant 🐘");
      });
    });

    group('Round-trip Serialization', () {
      test('should serialize and deserialize with all fields', () {
        // Arrange
        final originalJson = {
          'id': 'group-123',
          'name': 'Test Group',
          'description': 'Description',
          'familyId': 'family-456',
          'invite_code': 'ABC123',
          'createdAt': '2025-09-17T14:10:37.778Z',
          'updatedAt': '2025-09-17T14:10:37.778Z',
          'userRole': 'ADMIN',
          'joinedAt': '2025-10-02T19:44:16.667Z',
          'ownerFamily': {'id': 'family-owner', 'name': 'Owner'},
          'familyCount': 5,
          'scheduleCount': 3,
        };

        // Act: Parse then serialize
        final groupData = GroupDto.fromJson(originalJson);
        final serializedJson = groupData.toJson();

        // Assert: Should contain all non-null fields
        expect(serializedJson['id'], 'group-123');
        expect(serializedJson['name'], 'Test Group');
        expect(serializedJson['description'], 'Description');
        expect(serializedJson['familyId'], 'family-456');
        expect(serializedJson['invite_code'], 'ABC123');
        expect(serializedJson['userRole'], 'ADMIN');
        expect(serializedJson['joinedAt'], '2025-10-02T19:44:16.667Z');
        expect(serializedJson['ownerFamily'], isNotNull);
        expect(serializedJson['familyCount'], 5);
        expect(serializedJson['scheduleCount'], 3);
      });

      test(
        'should not include null fields in serialization (includeIfNull: false)',
        () {
          // Arrange
          final minimalJson = {
            'id': 'group-123',
            'name': 'Test Group',
            'familyId': 'family-456',
            'createdAt': '2025-09-17T14:10:37.778Z',
            'updatedAt': '2025-09-17T14:10:37.778Z',
          };

          // Act: Parse then serialize
          final groupData = GroupDto.fromJson(minimalJson);
          final serializedJson = groupData.toJson();

          // Assert: Null fields should not be present due to includeIfNull: false
          expect(serializedJson.containsKey('description'), isFalse);
          expect(serializedJson.containsKey('invite_code'), isFalse);
          expect(serializedJson.containsKey('userRole'), isFalse);
          expect(serializedJson.containsKey('joinedAt'), isFalse);
          expect(serializedJson.containsKey('ownerFamily'), isFalse);
          expect(serializedJson.containsKey('familyCount'), isFalse);
          expect(serializedJson.containsKey('scheduleCount'), isFalse);
        },
      );
    });

    group('API Response Wrapper Integration', () {
      test('should work with GroupResponse wrapper', () {
        // Arrange
        final json = {
          'success': true,
          'data': {
            'id': 'group-123',
            'name': 'Test Group',
            'familyId': 'family-456',
            'createdAt': '2025-09-17T14:10:37.778Z',
            'updatedAt': '2025-09-17T14:10:37.778Z',
          },
        };

        // Act
        final response = GroupResponse.fromJson(json);

        // Assert
        expect(response.success, isTrue);
        expect(response.data.id, 'group-123');
        expect(response.data.name, 'Test Group');
      });

      test('should work with GroupListResponse wrapper', () {
        // Arrange
        final json = {
          'success': true,
          'data': [
            {
              'id': 'group-1',
              'name': 'Group 1',
              'familyId': 'family-1',
              'createdAt': '2025-09-17T14:10:37.778Z',
              'updatedAt': '2025-09-17T14:10:37.778Z',
              'userRole': 'ADMIN',
              'familyCount': 3,
              'scheduleCount': 2,
            },
            {
              'id': 'group-2',
              'name': 'Group 2',
              'familyId': 'family-2',
              'createdAt': '2025-09-18T14:10:37.778Z',
              'updatedAt': '2025-09-18T14:10:37.778Z',
              'userRole': 'MEMBER',
              'familyCount': 1,
              'scheduleCount': 0,
            },
          ],
        };

        // Act
        final response = GroupListResponse.fromJson(json);

        // Assert
        expect(response.success, isTrue);
        expect(response.data, hasLength(2));
        expect(response.data[0].id, 'group-1');
        expect(response.data[0].userRole, 'ADMIN');
        expect(response.data[1].id, 'group-2');
        expect(response.data[1].userRole, 'MEMBER');
      });
    });
  });
}
