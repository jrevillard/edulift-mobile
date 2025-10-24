// API Response Edge Case Testing
// Comprehensive unit tests for ApiResponse class handling edge cases
// Following FLUTTER_TESTING_RESEARCH_2025.md clean architecture patterns

import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/network/models/common/api_response_wrapper.dart';

void main() {
  group('ApiResponse Edge Cases', () {
    group('Backend Wrapper - Edge Cases', () {
      test('should handle empty array data gracefully', () {
        // ARRANGE - Empty array response that was causing crashes
        final wrapperData = {
          'success': true,
          'data': <dynamic>[], // Empty array - common API response
        };

        // ACT
        final apiResponse = ApiResponse.fromBackendWrapper(
          wrapperData,
          (json) => json as List<dynamic>,
        );

        // ASSERT - Should not crash and provide safe default
        expect(apiResponse.success, isTrue);
        expect(apiResponse.data, isA<List<dynamic>>());
        expect(apiResponse.data, isEmpty);
      });

      test('should handle null data gracefully', () {
        final wrapperData = {'success': true, 'data': null};

        final apiResponse = ApiResponse.fromBackendWrapper(
          wrapperData,
          (json) => json as Map<String, dynamic>?,
        );

        expect(apiResponse.success, isTrue);
        expect(apiResponse.data, isNull);
      });

      test('should handle missing data field', () {
        final wrapperData = {
          'success': true,
          // Missing data field
        };

        final apiResponse = ApiResponse.fromBackendWrapper(
          wrapperData,
          (json) => json as Map<String, dynamic>?,
        );

        expect(apiResponse.success, isTrue);
        expect(apiResponse.data, isNull);
      });

      test('should handle error responses', () {
        final wrapperData = {
          'success': false,
          'error': 'Something went wrong',
          'code': 'ERR_001',
        };

        final apiResponse = ApiResponse.fromBackendWrapper(
          wrapperData,
          (json) => json as Map<String, dynamic>?,
        );

        expect(apiResponse.success, isFalse);
        expect(apiResponse.data, isNull);
        expect(apiResponse.errorMessage, equals('Something went wrong'));
      });
    });

    group('Factory Methods - Edge Cases', () {
      test('should handle success with null data', () {
        final response = ApiResponse<String?>.success(null);

        expect(response.success, isTrue);
        expect(response.data, isNull);
        expect(response.errorMessage, isNull);
      });

      test('should handle error with all parameters', () {
        final response = ApiResponse<String>.error(
          'Test error',
          errorCode: 'TEST_001',
          statusCode: 400,
          metadata: {'context': 'test'},
        );

        expect(response.success, isFalse);
        expect(response.data, isNull);
        expect(response.errorMessage, equals('Test error'));
        expect(response.errorCode, equals('TEST_001'));
        expect(response.statusCode, equals(400));
        expect(response.metadata['context'], equals('test'));
      });
    });

    group('Unwrap Extension - Edge Cases', () {
      test('should unwrap successful response with data', () {
        final response = ApiResponse<String>.success('test data');

        expect(response.unwrap(), equals('test data'));
      });

      test('should throw on error response', () {
        final response = ApiResponse<String>.error('Test error');

        expect(() => response.unwrap(), throwsException);
      });

      test('should handle null data in successful response', () {
        final response = ApiResponse<String?>.success(null);

        expect(response.unwrap(), isNull);
      });
    });

    group('Complex Data Types', () {
      test('should handle nested maps correctly', () {
        final complexData = {
          'user': {
            'id': '123',
            'profile': {
              'name': 'Test User',
              'settings': {'theme': 'dark'},
            },
          },
        };

        final response = ApiResponse<Map<String, dynamic>>.success(complexData);

        expect(response.success, isTrue);
        expect(response.data!['user']['id'], equals('123'));
        expect(
          response.data!['user']['profile']['settings']['theme'],
          equals('dark'),
        );
      });

      test('should handle list of maps', () {
        final listData = [
          {'id': '1', 'name': 'Item 1'},
          {'id': '2', 'name': 'Item 2'},
        ];

        final response = ApiResponse<List<Map<String, dynamic>>>.success(
          listData,
        );

        expect(response.success, isTrue);
        expect(response.data, hasLength(2));
        expect(response.data![0]['name'], equals('Item 1'));
      });
    });
  });
}
