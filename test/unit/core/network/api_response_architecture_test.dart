import 'package:test/test.dart';
import 'package:edulift/core/network/models/common/api_response_wrapper.dart';
import 'package:edulift/core/network/api_response_helper.dart';
import 'package:edulift/core/errors/api_exception.dart';

/// State-of-the-Art API Architecture Test (2025 Best Practices)
///
/// This test validates the implementation of Gemini's recommended
/// "explicit wrapper with helper" approach for API communication.
void main() {
  group('State-of-the-Art API Architecture 2025 - Tests', () {
    group('ApiResponse<T> Generic Wrapper', () {
      test('should create successful response with data', () {
        // Arrange & Act
        final response = ApiResponse<String>.success('test data');

        // Assert
        expect(response.success, isTrue);
        expect(response.data, equals('test data'));
        expect(response.errorMessage, isNull);
        expect(response.errorCode, isNull);
        expect(response.statusCode, isNull);
      });

      test('should create error response with structured information', () {
        // Arrange & Act
        final response = ApiResponse<String>.error(
          'Test error message',
          errorCode: 'VALIDATION_FAILED',
          statusCode: 422,
          metadata: {'field': 'email'},
        );

        // Assert
        expect(response.success, isFalse);
        expect(response.data, isNull);
        expect(response.errorMessage, equals('Test error message'));
        expect(response.errorCode, equals('VALIDATION_FAILED'));
        expect(response.statusCode, equals(422));
        expect(response.metadata['field'], equals('email'));
      });

      test('should create response from backend wrapper pattern', () {
        // Arrange
        final wrapperData = {
          'success': true,
          'data': 'extracted data',
          'error': null,
        };

        // Act
        final response = ApiResponse<String>.fromBackendWrapper(
          wrapperData,
          (json) => json as String,
        );

        // Assert
        expect(response.success, isTrue);
        expect(response.data, equals('extracted data'));
        expect(response.errorMessage, isNull);
      });

      test('should create error response from backend wrapper pattern', () {
        // Arrange
        final wrapperData = {
          'success': false,
          'data': null,
          'error': 'Backend error message',
          'code': 'AUTH_FAILED',
        };

        // Act
        final response = ApiResponse<String>.fromBackendWrapper(
          wrapperData,
          (json) => json as String,
          statusCode: 401,
        );

        // Assert
        expect(response.success, isFalse);
        expect(response.data, isNull);
        expect(response.errorMessage, equals('Backend error message'));
        expect(response.errorCode, equals('AUTH_FAILED'));
        expect(response.statusCode, equals(401));
      });
    });

    group('unwrap() Extension for Clean Extraction', () {
      test('should unwrap successful response and return data', () {
        // Arrange
        final response = ApiResponse<String>.success('test data');

        // Act & Assert
        expect(response.unwrap(), equals('test data'));
      });

      test('should throw ApiException when unwrapping failed response', () {
        // Arrange
        final response = ApiResponse<String>.error(
          'Test error',
          errorCode: 'TEST_ERROR',
          statusCode: 400,
        );

        // Act & Assert
        expect(
          () => response.unwrap(),
          throwsA(
            isA<ApiException>()
                .having((e) => e.message, 'message', 'Test error')
                .having((e) => e.errorCode, 'errorCode', 'TEST_ERROR')
                .having((e) => e.statusCode, 'statusCode', 400),
          ),
        );
      });

      test('should return null with unwrapOrNull for failed response', () {
        // Arrange
        final response = ApiResponse<String>.error('Test error');

        // Act & Assert
        expect(response.unwrapOrNull(), isNull);
      });

      test('should return default value with unwrapOr for failed response', () {
        // Arrange
        final response = ApiResponse<String>.error('Test error');

        // Act & Assert
        expect(response.unwrapOr('default'), equals('default'));
      });

      test('should detect validation errors correctly', () {
        // Arrange
        final response422 = ApiResponse<String>.error(
          'Validation failed',
          statusCode: 422,
        );
        final responseValidation = ApiResponse<String>.error(
          'Invalid data',
          errorCode: 'VALIDATION_ERROR',
        );

        // Assert
        expect(response422.isValidationError, isTrue);
        expect(responseValidation.isValidationError, isTrue);
      });

      test('should detect authentication errors correctly', () {
        // Arrange
        final response401 = ApiResponse<String>.error(
          'Unauthorized',
          statusCode: 401,
        );
        final responseAuth = ApiResponse<String>.error(
          'Auth failed',
          errorCode: 'UNAUTHORIZED',
        );

        // Assert
        expect(response401.isAuthenticationError, isTrue);
        expect(responseAuth.isAuthenticationError, isTrue);
      });
    });

    group('ApiResponseHelper Utilities', () {
      test('should wrap successful API call result', () {
        // Arrange & Act
        final response = ApiResponseHelper.wrapSuccess('test result');

        // Assert
        expect(response.success, isTrue);
        expect(response.data, equals('test result'));
      });

      test('should execute successful API call and wrap result', () async {
        // Arrange
        Future<String> mockApiCall() async => 'api result';

        // Act
        final response = await ApiResponseHelper.execute<String>(mockApiCall);

        // Assert
        expect(response.success, isTrue);
        expect(response.data, equals('api result'));
      });

      test(
        'should execute failed API call and return error response',
        () async {
          // Arrange
          Future<String> mockApiCall() async {
            throw const ApiException(
              message: 'API call failed',
              statusCode: 500,
              errorCode: 'SERVER_ERROR',
            );
          }

          // Act
          final response = await ApiResponseHelper.execute<String>(mockApiCall);

          // Assert
          expect(response.success, isFalse);
          expect(response.errorMessage, equals('API call failed'));
          expect(response.statusCode, equals(500));
          expect(response.errorCode, equals('SERVER_ERROR'));
        },
      );

      test('should execute and unwrap successful API call', () async {
        // Arrange
        Future<String> mockApiCall() async => 'direct result';

        // Act
        final result = await ApiResponseHelper.executeAndUnwrap<String>(
          mockApiCall,
        );

        // Assert
        expect(result, equals('direct result'));
      });

      test(
        'should execute and unwrap failed API call with exception',
        () async {
          // Arrange
          Future<String> mockApiCall() async {
            throw const ApiException(
              message: 'Direct call failed',
              statusCode: 404,
            );
          }

          // Act & Assert
          await expectLater(
            () => ApiResponseHelper.executeAndUnwrap<String>(mockApiCall),
            throwsA(
              isA<ApiException>()
                  .having((e) => e.message, 'message', 'Direct call failed')
                  .having((e) => e.statusCode, 'statusCode', 404),
            ),
          );
        },
      );

      test('should handle ApiException in handleError', () {
        // Arrange
        const exception = ApiException(
          message: 'Test exception',
          statusCode: 403,
          errorCode: 'FORBIDDEN',
        );

        // Act
        final response = ApiResponseHelper.handleError<String>(exception);

        // Assert
        expect(response.success, isFalse);
        expect(response.errorMessage, equals('Test exception'));
        expect(response.statusCode, equals(403));
        expect(response.errorCode, equals('FORBIDDEN'));
      });
    });

    group('422 Auth Error Handling Preservation', () {
      test('should preserve 422 validation error information', () {
        // Arrange
        final response = ApiResponse<String>.error(
          'Email validation failed',
          errorCode: 'INVALID_EMAIL',
          statusCode: 422,
          metadata: {'field': 'email', 'pattern': 'email_format'},
        );

        // Act & Assert
        expect(response.isValidationError, isTrue);
        expect(response.requiresUserAction, isTrue);
        expect(response.isRetryable, isFalse);
        expect(response.statusCode, equals(422));
        expect(response.metadata['field'], equals('email'));

        // Validate unwrap throws with proper context
        expect(
          () => response.unwrap(),
          throwsA(
            isA<ApiException>()
                .having((e) => e.isValidationError, 'isValidationError', isTrue)
                .having((e) => e.statusCode, 'statusCode', 422),
          ),
        );
      });

      test('should maintain clean auth flow error handling', () {
        // Arrange: Simulate 422 error from auth verification
        final authErrorResponse = ApiResponse<Map<String, dynamic>>.error(
          'Invalid magic link token',
          errorCode: 'TOKEN_INVALID',
          statusCode: 422,
          metadata: {
            'endpoint': '/auth/verify',
            'timestamp': DateTime.now().toIso8601String(),
          },
        );

        // Act: Simulate service layer handling
        expect(authErrorResponse.isValidationError, isTrue);
        expect(authErrorResponse.statusCode, equals(422));

        try {
          authErrorResponse.unwrap();
          fail('Should have thrown ApiException');
        } catch (e) {
          // Assert: Clean error handling preserved
          expect(e, isA<ApiException>());
          final apiException = e as ApiException;
          expect(apiException.isValidationError, isTrue);
          expect(apiException.statusCode, equals(422));
          expect(apiException.message, contains('Invalid magic link token'));
        }
      });
    });

    group('Type Safety and Consistency', () {
      test('should maintain type safety across different data types', () {
        // Test with different types
        final stringResponse = ApiResponse<String>.success('string data');
        final intResponse = ApiResponse<int>.success(42);
        final mapResponse = ApiResponse<Map<String, dynamic>>.success({
          'key': 'value',
        });

        // Assert type safety
        expect(stringResponse.unwrap(), isA<String>());
        expect(intResponse.unwrap(), isA<int>());
        expect(mapResponse.unwrap(), isA<Map<String, dynamic>>());

        expect(stringResponse.unwrap(), equals('string data'));
        expect(intResponse.unwrap(), equals(42));
        expect(mapResponse.unwrap()['key'], equals('value'));
      });

      test('should provide consistent error pattern across types', () {
        // Test with different types
        final stringError = ApiResponse<String>.error('String error');
        final intError = ApiResponse<int>.error('Int error');
        final mapError = ApiResponse<Map<String, dynamic>>.error('Map error');

        // Assert consistent error behavior
        expect(() => stringError.unwrap(), throwsA(isA<ApiException>()));
        expect(() => intError.unwrap(), throwsA(isA<ApiException>()));
        expect(() => mapError.unwrap(), throwsA(isA<ApiException>()));

        expect(stringError.success, isFalse);
        expect(intError.success, isFalse);
        expect(mapError.success, isFalse);
      });
    });
  });
}
