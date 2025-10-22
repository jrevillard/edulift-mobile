// EduLift Mobile - Safe Casting Utils Unit Tests
// Pure Dart tests for type-safe casting operations

import 'package:test/test.dart';
import 'package:edulift/core/utils/safe_casting_utils.dart';

void main() {
  group('SafeCastingUtils Unit Tests', () {
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

      test('should handle family API response with mixed types', () {
        final familyApiResponse = {
          'id': 'f1',
          'name': 'Test Family',
          'members': [
            {'id': 'm1', 'name': 'Parent 1'},
            {'id': 'm2', 'name': 'Parent 2'},
          ],
          'children': [
            {'id': 'c1', 'name': 'Child 1'},
            'invalid_child', // Invalid entry should be skipped
            {'id': 'c2', 'name': 'Child 2'},
          ],
          'vehicles': [
            {'id': 'v1', 'name': 'Family Car'},
            null, // Null entry should be skipped
            {'id': 'v2', 'name': 'SUV'},
          ],
        };

        // Test that safe casting handles the mixed data correctly
        final safeMembers = SafeCastingUtils.safeCastToMapList(
          familyApiResponse['members'],
        );
        final safeChildren = SafeCastingUtils.safeCastToMapList(
          familyApiResponse['children'],
        );
        final safeVehicles = SafeCastingUtils.safeCastToMapList(
          familyApiResponse['vehicles'],
        );

        expect(safeMembers.length, equals(2));
        expect(
          safeChildren.length,
          equals(2),
        ); // Invalid entry should be filtered out
        expect(
          safeVehicles.length,
          equals(2),
        ); // Null entry should be filtered out

        expect(safeMembers[0]['id'], equals('m1'));
        expect(safeChildren[0]['id'], equals('c1'));
        expect(safeChildren[1]['id'], equals('c2'));
        expect(safeVehicles[0]['id'], equals('v1'));
        expect(safeVehicles[1]['id'], equals('v2'));
      });

      test(
        'should handle conflict events with mixed affected entity types',
        () {
          final conflictEventJson = {
            'affectedScheduleSlots': [
              'slot1',
              'slot2',
              123,
              null,
              'slot3',
            ], // Mixed types
            'affectedVehicles': [null, 'v1', 'v2', 456], // Mixed types
            'affectedChildren': ['c1', true, 'c2', 'c3'], // Mixed types
          };

          // Test safe casting for WebSocket event data
          final safeSlots = SafeCastingUtils.safeCastToStringList(
            conflictEventJson['affectedScheduleSlots'],
          );
          final safeVehicles = SafeCastingUtils.safeCastToStringList(
            conflictEventJson['affectedVehicles'],
          );
          final safeChildren = SafeCastingUtils.safeCastToStringList(
            conflictEventJson['affectedChildren'],
          );

          // Should filter out invalid types and keep only strings
          expect(safeSlots, equals(['slot1', 'slot2', 'slot3']));
          expect(safeVehicles, equals(['v1', 'v2']));
          expect(safeChildren, equals(['c1', 'c2', 'c3']));
        },
      );
    });

    group('Edge Cases', () {
      test('should handle completely null/empty API responses', () {
        expect(SafeCastingUtils.safeCastToMapList(null), equals([]));
        expect(SafeCastingUtils.safeCastToStringList(null), equals([]));
        expect(SafeCastingUtils.safeCastToIntList(null), equals([]));
      });

      test('should handle unexpected data types gracefully', () {
        expect(SafeCastingUtils.safeCastToMapList(42), equals([]));
        expect(SafeCastingUtils.safeCastToStringList('not_a_list'), equals([]));
        expect(SafeCastingUtils.safeCastToIntList(true), equals([]));
      });

      test('should handle mixed numeric types in int list', () {
        final input = [1, 2.5, '3', 4, null, 5.7];
        final result = SafeCastingUtils.safeCastToIntList(input);

        expect(
          result,
          equals([1, 2, 4, 5]),
        ); // Should convert doubles to ints and filter out invalid types
      });

      test('should handle basic type conversions', () {
        expect(SafeCastingUtils.safeCastToString(null), equals(''));
        expect(SafeCastingUtils.safeCastToString(42), equals('42'));
        expect(SafeCastingUtils.safeCastToString('test'), equals('test'));

        expect(SafeCastingUtils.safeCastToInt(null), equals(0));
        expect(SafeCastingUtils.safeCastToInt('42'), equals(42));
        expect(SafeCastingUtils.safeCastToInt(42.7), equals(42));
        expect(SafeCastingUtils.safeCastToInt('invalid'), equals(0));

        expect(SafeCastingUtils.safeCastToBool(null), equals(false));
        expect(SafeCastingUtils.safeCastToBool(true), equals(true));
        expect(SafeCastingUtils.safeCastToBool('true'), equals(true));
        expect(SafeCastingUtils.safeCastToBool('false'), equals(false));
        expect(SafeCastingUtils.safeCastToBool(1), equals(true));
        expect(SafeCastingUtils.safeCastToBool(0), equals(false));
      });
    });
  });
}
