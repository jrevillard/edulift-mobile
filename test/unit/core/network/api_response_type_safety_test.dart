// API Response Type Safety Testing
// Tests the current ApiResponse implementation for type safety
// Following FLUTTER_TESTING_RESEARCH_2025.md clean architecture patterns

import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/network/models/common/api_response_wrapper.dart';

void main() {
  group('ApiResponse Type Safety', () {
    group('Constructor Type Safety', () {
      test('should handle string response type safely', () {
        final response = ApiResponse<String>.success('test data');

        expect(response.success, isTrue);
        expect(response.data, isA<String>());
        expect(response.data, equals('test data'));
      });

      test('should handle map response type safely', () {
        final data = {'key': 'value', 'number': 42};
        final response = ApiResponse<Map<String, dynamic>>.success(data);

        expect(response.success, isTrue);
        expect(response.data, isA<Map<String, dynamic>>());
        expect(response.data!['key'], equals('value'));
      });

      test('should handle list response type safely', () {
        final data = ['item1', 'item2', 'item3'];
        final response = ApiResponse<List<String>>.success(data);

        expect(response.success, isTrue);
        expect(response.data, isA<List<String>>());
        expect(response.data, hasLength(3));
      });

      test('should handle nullable response type safely', () {
        final response = ApiResponse<String?>.success(null);

        expect(response.success, isTrue);
        expect(response.data, isNull);
      });
    });

    group('Error Response Type Safety', () {
      test('should handle error response safely', () {
        final response = ApiResponse<String>.error('Test error');

        expect(response.success, isFalse);
        expect(response.data, isNull);
        expect(response.errorMessage, equals('Test error'));
      });

      test('should handle error with code safely', () {
        final response = ApiResponse<Map<String, dynamic>>.error(
          'Validation failed',
          errorCode: 'VALIDATION_ERROR',
        );

        expect(response.success, isFalse);
        expect(response.data, isNull);
        expect(response.errorMessage, equals('Validation failed'));
        expect(response.errorCode, equals('VALIDATION_ERROR'));
      });
    });

    group('Backend Wrapper Type Safety', () {
      test('should handle wrapper with string data safely', () {
        final wrapperData = {'success': true, 'data': 'test string data'};

        final response = ApiResponse.fromBackendWrapper(
          wrapperData,
          (json) => json as String,
        );

        expect(response.success, isTrue);
        expect(response.data, isA<String>());
        expect(response.data, equals('test string data'));
      });

      test('should handle wrapper with map data safely', () {
        final wrapperData = {
          'success': true,
          'data': {'id': '123', 'name': 'Test'},
        };

        final response = ApiResponse.fromBackendWrapper(
          wrapperData,
          (json) => json as Map<String, dynamic>,
        );

        expect(response.success, isTrue);
        expect(response.data, isA<Map<String, dynamic>>());
        expect(response.data!['id'], equals('123'));
      });

      test('should handle wrapper with list data safely', () {
        final wrapperData = {
          'success': true,
          'data': [
            {'id': '1', 'name': 'Item 1'},
            {'id': '2', 'name': 'Item 2'},
          ],
        };

        final response = ApiResponse.fromBackendWrapper(
          wrapperData,
          (json) => (json as List).cast<Map<String, dynamic>>(),
        );

        expect(response.success, isTrue);
        expect(response.data, isA<List<Map<String, dynamic>>>());
        expect(response.data, hasLength(2));
      });

      test('should handle wrapper error response safely', () {
        final wrapperData = {
          'success': false,
          'error': 'Backend error occurred',
          'code': 'BACKEND_ERROR',
        };

        final response = ApiResponse.fromBackendWrapper(
          wrapperData,
          (json) => json as String?,
        );

        expect(response.success, isFalse);
        expect(response.data, isNull);
        expect(response.errorMessage, equals('Backend error occurred'));
      });
    });

    group('Unwrap Extension Type Safety', () {
      test('should unwrap string response safely', () {
        final response = ApiResponse<String>.success('unwrap test');

        final result = response.unwrap();
        expect(result, isA<String>());
        expect(result, equals('unwrap test'));
      });

      test('should throw on error response unwrap', () {
        final response = ApiResponse<String>.error('Cannot unwrap');

        expect(() => response.unwrap(), throwsException);
      });

      test('should unwrap nullable response safely', () {
        final response = ApiResponse<String?>.success(null);

        final result = response.unwrap();
        expect(result, isNull);
      });
    });

    group('Metadata Type Safety', () {
      test('should handle metadata safely', () {
        const response = ApiResponse<String>(
          success: true,
          data: 'test',
          metadata: {
            'timestamp': '2025-01-01T00:00:00Z',
            'version': '1.0.0',
            'count': 42,
          },
        );

        expect(response.metadata, isA<Map<String, dynamic>>());
        expect(response.metadata['timestamp'], isA<String>());
        expect(response.metadata['count'], isA<int>());
      });

      test('should handle empty metadata safely', () {
        const response = ApiResponse<String>(success: true, data: 'test');

        expect(response.metadata, isEmpty);
      });
    });
  });
}
