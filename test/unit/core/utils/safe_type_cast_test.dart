// Comprehensive tests for ApiResponse wrapper and type casting utilities
// Tests the current ApiResponse implementation for safe type handling

import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/network/models/common/api_response_wrapper.dart';

void main() {
  group('ApiResponse Type Safety Tests', () {
    group('Constructor Tests', () {
      test('should create successful response with data', () {
        const response = ApiResponse<String>(success: true, data: 'test data');

        expect(response.success, isTrue);
        expect(response.data, equals('test data'));
        expect(response.errorMessage, isNull);
      });

      test('should create error response', () {
        const response = ApiResponse<String>(
          success: false,
          errorMessage: 'Something went wrong',
          errorCode: 'ERR_001',
        );

        expect(response.success, isFalse);
        expect(response.data, isNull);
        expect(response.errorMessage, equals('Something went wrong'));
        expect(response.errorCode, equals('ERR_001'));
      });

      test('should handle null data gracefully', () {
        const response = ApiResponse<Map<String, dynamic>>(success: true);

        expect(response.success, isTrue);
        expect(response.data, isNull);
        expect(response.errorMessage, isNull);
      });
    });

    group('Factory Constructor Tests', () {
      test('should create success response with factory', () {
        final response = ApiResponse<String>.success('test data');

        expect(response.success, isTrue);
        expect(response.data, equals('test data'));
        expect(response.errorMessage, isNull);
      });

      test('should create error response with factory', () {
        final response = ApiResponse<String>.error(
          'Something went wrong',
          errorCode: 'ERR_001',
          statusCode: 400,
        );

        expect(response.success, isFalse);
        expect(response.data, isNull);
        expect(response.errorMessage, equals('Something went wrong'));
        expect(response.errorCode, equals('ERR_001'));
        expect(response.statusCode, equals(400));
      });
    });

    group('Backend Wrapper Tests', () {
      test('should handle successful backend response', () {
        final wrapperData = {
          'success': true,
          'data': {'id': '123', 'name': 'test'},
        };

        final response = ApiResponse.fromBackendWrapper(
          wrapperData,
          (json) => json as Map<String, dynamic>,
        );

        expect(response.success, isTrue);
        expect(response.data, isNotNull);
        expect(response.data!['id'], equals('123'));
      });

      test('should handle error backend response', () {
        final wrapperData = {
          'success': false,
          'error': 'Backend error',
          'code': 'ERR_BACKEND',
        };

        final response = ApiResponse.fromBackendWrapper(
          wrapperData,
          (json) => json as Map<String, dynamic>,
        );

        expect(response.success, isFalse);
        expect(response.data, isNull);
        expect(response.errorMessage, equals('Backend error'));
      });
    });

    group('Type Safety Edge Cases', () {
      test('should handle complex nested data types', () {
        final complexData = {
          'user': {
            'id': 'user-123',
            'preferences': {'theme': 'light', 'notifications': true},
          },
          'metadata': {'timestamp': '2025-01-01T00:00:00Z', 'version': '1.0.0'},
        };

        final response = ApiResponse<Map<String, dynamic>>(
          success: true,
          data: complexData,
        );

        expect(response.success, isTrue);
        expect(response.data, isNotNull);
        expect(response.data!['user'], isA<Map<String, dynamic>>());
        expect(response.data!['metadata'], isA<Map<String, dynamic>>());
      });

      test('should handle empty metadata correctly', () {
        const response = ApiResponse<String>(success: true, data: 'test');

        expect(response.success, isTrue);
        expect(response.metadata, isEmpty);
      });

      test('should handle response with custom metadata', () {
        const response = ApiResponse<String>(
          success: true,
          data: 'test',
          metadata: {'custom': 'value', 'count': 42},
        );

        expect(response.success, isTrue);
        expect(response.metadata['custom'], equals('value'));
        expect(response.metadata['count'], equals(42));
      });
    });

    group('Extension Methods Tests', () {
      test('unwrap should return data for successful response', () {
        final response = ApiResponse<String>.success('test data');

        expect(() => response.unwrap(), returnsNormally);
        expect(response.unwrap(), equals('test data'));
      });

      test('unwrap should throw for error response', () {
        final response = ApiResponse<String>.error('Test error');

        expect(() => response.unwrap(), throwsException);
      });

      test('should handle null data in successful response', () {
        const response = ApiResponse<String?>(success: true);

        expect(response.success, isTrue);
        expect(response.data, isNull);
      });
    });

    group('Realistic API Response Scenarios', () {
      test('should handle user profile response', () {
        final profileData = {
          'id': 'user-456',
          'email': 'test@example.com',
          'familyRole': 'parent',
          'preferences': {'theme': 'dark'},
        };

        final response = ApiResponse<Map<String, dynamic>>.success(profileData);

        expect(response.success, isTrue);
        expect(response.data!['familyRole'], equals('parent'));
        expect(response.data!['preferences'], isNotNull);
      });

      test('should handle empty list responses', () {
        final response = ApiResponse<List<dynamic>>.success([]);

        expect(response.success, isTrue);
        expect(response.data, isEmpty);
      });

      test('should handle pagination metadata', () {
        const response = ApiResponse<List<String>>(
          success: true,
          data: ['item1', 'item2'],
          metadata: {'page': 1, 'total': 2, 'hasNext': false},
        );

        expect(response.success, isTrue);
        expect(response.data, hasLength(2));
        expect(response.metadata['total'], equals(2));
        expect(response.metadata['hasNext'], isFalse);
      });
    });
  });
}
