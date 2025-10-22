// EduLift Mobile - Safe Casting Utils Tests
// Comprehensive tests to validate type-safe casting operations

import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/utils/safe_casting_utils.dart';

void main() {
  group('SafeCastingUtils', () {
    group('safeCastToMapList', () {
      test('should cast List<Map<String,dynamic>> correctly', () {
        final input = [
          {'id': '1', 'name': 'Test'},
          {'id': '2', 'name': 'Test2'},
        ];

        final result = SafeCastingUtils.safeCastToMapList(input);

        expect(result, isA<List<Map<String, dynamic>>>());
        expect(result.length, equals(2));
        expect(result[0]['id'], equals('1'));
      });

      test('should handle List<dynamic> with mixed Map types', () {
        final input = [
          {'id': '1', 'name': 'Test'}, // Map<String, dynamic>
          <String, String>{'id': '2', 'name': 'Test2'}, // Map<String, String>
          'invalid', // Invalid item should be skipped
        ];

        final result = SafeCastingUtils.safeCastToMapList(input);

        expect(result, isA<List<Map<String, dynamic>>>());
        expect(result.length, equals(2));
        expect(result[0]['id'], equals('1'));
        expect(result[1]['id'], equals('2'));
      });

      test('should return empty list for null input', () {
        final result = SafeCastingUtils.safeCastToMapList(null);

        expect(result, isA<List<Map<String, dynamic>>>());
        expect(result.length, equals(0));
      });

      test('should return empty list for non-list input', () {
        final result = SafeCastingUtils.safeCastToMapList('invalid');

        expect(result, isA<List<Map<String, dynamic>>>());
        expect(result.length, equals(0));
      });
    });

    group('safeCastToStringList', () {
      test('should cast List<String> correctly', () {
        final input = ['test1', 'test2', 'test3'];

        final result = SafeCastingUtils.safeCastToStringList(input);

        expect(result, isA<List<String>>());
        expect(result.length, equals(3));
        expect(result[0], equals('test1'));
      });

      test('should filter out non-string items from List<dynamic>', () {
        final input = ['test1', 123, 'test2', null, 'test3'];

        final result = SafeCastingUtils.safeCastToStringList(input);

        expect(result, isA<List<String>>());
        expect(result.length, equals(3));
        expect(result, equals(['test1', 'test2', 'test3']));
      });

      test('should return empty list for null input', () {
        final result = SafeCastingUtils.safeCastToStringList(null);

        expect(result, isA<List<String>>());
        expect(result.length, equals(0));
      });
    });

    group('safeCastToList', () {
      test('should convert items using provided converter', () {
        final input = [
          {'id': '1', 'value': 10},
          {'id': '2', 'value': 20},
        ];

        final result = SafeCastingUtils.safeCastToList<TestModel>(
          input,
          (item) => TestModel.fromJson(
            SafeCastingUtils.safeCastToStringDynamicMap(item),
          ),
        );

        expect(result, isA<List<TestModel>>());
        expect(result.length, equals(2));
        expect(result[0].id, equals('1'));
        expect(result[0].value, equals(10));
      });

      test('should skip items that fail conversion', () {
        final input = [
          {'id': '1', 'value': 10},
          'invalid', // Should be skipped
          {'id': '2', 'value': 20},
        ];

        final result = SafeCastingUtils.safeCastToList<TestModel>(
          input,
          (item) => TestModel.fromJson(
            SafeCastingUtils.safeCastToStringDynamicMap(item),
          ),
        );

        expect(result, isA<List<TestModel>>());
        expect(result.length, equals(2));
        expect(result[0].id, equals('1'));
        expect(result[1].id, equals('2'));
      });
    });

    group('validateApiResponse', () {
      test('should validate Map<String, dynamic> correctly', () {
        final input = {'id': '1', 'name': 'Test'};

        final result = SafeCastingUtils.validateApiResponse(input);

        expect(result, isA<Map<String, dynamic>>());
        expect(result['id'], equals('1'));
      });

      test('should convert Map to Map<String, dynamic>', () {
        final input = <String, String>{'id': '1', 'name': 'Test'};

        final result = SafeCastingUtils.validateApiResponse(input);

        expect(result, isA<Map<String, dynamic>>());
        expect(result['id'], equals('1'));
      });

      test('should throw ArgumentError for null input', () {
        expect(
          () => SafeCastingUtils.validateApiResponse(null),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError for invalid input type', () {
        expect(
          () => SafeCastingUtils.validateApiResponse('invalid'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Extension methods', () {
      test('asMapList extension should work correctly', () {
        final input = [
          {'id': '1', 'name': 'Test'},
          {'id': '2', 'name': 'Test2'},
        ];

        final result = input.asMapList;

        expect(result, isA<List<Map<String, dynamic>>>());
        expect(result.length, equals(2));
        expect(result[0]['id'], equals('1'));
      });

      test('asStringList extension should work correctly', () {
        final input = ['test1', 'test2', 'test3'];

        final result = input.asStringList;

        expect(result, isA<List<String>>());
        expect(result.length, equals(3));
        expect(result[0], equals('test1'));
      });
    });

    group('Real-world API response simulation', () {
      test('should handle typical schedule API response', () {
        // Simulate an API response that might cause casting errors
        final apiResponse = {
          'scheduleSlots': [
            {'day': 'Monday', 'time': 'Morning', 'id': '1'},
            {'day': 'Tuesday', 'time': 'Afternoon', 'id': '2'},
          ],
          'memberIds': ['mem1', 'mem2', 'mem3'],
          'childIds': ['child1', 'child2'],
        };

        // Test the methods that would be used in real parsing
        final slots = SafeCastingUtils.safeCastToMapList(
          apiResponse['scheduleSlots'],
        );
        final memberIds = SafeCastingUtils.safeCastToStringList(
          apiResponse['memberIds'],
        );
        final childIds = SafeCastingUtils.safeCastToStringList(
          apiResponse['childIds'],
        );

        expect(slots.length, equals(2));
        expect(slots[0]['day'], equals('Monday'));
        expect(memberIds.length, equals(3));
        expect(childIds.length, equals(2));
      });

      test('should handle malformed API response gracefully', () {
        // Simulate malformed response that used to cause crashes
        final apiResponse = {
          'scheduleSlots': 'invalid', // Should be a list
          'memberIds': null, // Null value
          'childIds': [123, 'child1', null, 'child2'], // Mixed types
        };

        final slots = SafeCastingUtils.safeCastToMapList(
          apiResponse['scheduleSlots'],
        );
        final memberIds = SafeCastingUtils.safeCastToStringList(
          apiResponse['memberIds'],
        );
        final childIds = SafeCastingUtils.safeCastToStringList(
          apiResponse['childIds'],
        );

        expect(
          slots.length,
          equals(0),
        ); // Should return empty list for invalid data
        expect(
          memberIds.length,
          equals(0),
        ); // Should return empty list for null
        expect(childIds.length, equals(2)); // Should filter out non-strings
        expect(childIds, equals(['child1', 'child2']));
      });

      test('should handle deeply nested API response', () {
        final apiResponse = {
          'family': {
            'members': [
              {'id': '1', 'name': 'Parent 1'},
              {'id': '2', 'name': 'Parent 2'},
            ],
            'children': [
              {
                'id': 'c1',
                'name': 'Child 1',
                'groupIds': ['g1', 'g2'],
              },
            ],
          },
          'groups': [
            {
              'id': 'g1',
              'name': 'Group 1',
              'memberIds': ['1', '2'],
              'childIds': ['c1'],
            },
          ],
        };

        // Test nested parsing
        final familyData = SafeCastingUtils.safeCastToStringDynamicMap(
          apiResponse['family'],
        );
        final members = SafeCastingUtils.safeCastToMapList(
          familyData['members'],
        );
        final children = SafeCastingUtils.safeCastToMapList(
          familyData['children'],
        );
        final groups = SafeCastingUtils.safeCastToMapList(
          apiResponse['groups'],
        );

        expect(members.length, equals(2));
        expect(children.length, equals(1));
        expect(groups.length, equals(1));

        // Test child's groupIds
        final child = children[0];
        final childGroupIds = SafeCastingUtils.safeCastToStringList(
          child['groupIds'],
        );
        expect(childGroupIds, equals(['g1', 'g2']));

        // Test group's member and child IDs
        final group = groups[0];
        final groupMemberIds = SafeCastingUtils.safeCastToStringList(
          group['memberIds'],
        );
        final groupChildIds = SafeCastingUtils.safeCastToStringList(
          group['childIds'],
        );
        expect(groupMemberIds, equals(['1', '2']));
        expect(groupChildIds, equals(['c1']));
      });
    });
  });
}

// Test model for converter tests
class TestModel {
  final String id;
  final int value;

  TestModel({required this.id, required this.value});

  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(id: json['id'] as String, value: json['value'] as int);
  }
}
