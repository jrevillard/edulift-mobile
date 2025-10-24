import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/errors/api_exception.dart';

void main() {
  group('ApiException Validation Error Detection Tests', () {
    test(
      'should detect 422 status code as validation error for name required',
      () {
        // Test the specific case mentioned in the mission
        const nameRequiredException = ApiException(
          message: 'name is required for new users',
          statusCode: 422,
          errorCode: 'VALIDATION_ERROR',
          details: {'field': 'name', 'code': 'required'},
        );

        expect(nameRequiredException.isValidationError, isTrue);
        expect(nameRequiredException.requiresUserAction, isTrue);
        expect(nameRequiredException.isRetryable, isFalse);
        expect(nameRequiredException.message, contains('name is required'));
      },
    );

    test('should detect 422 status code as validation error', () {
      const exception = ApiException(
        message: 'Validation failed',
        statusCode: 422,
      );

      expect(exception.isValidationError, isTrue);
      expect(exception.requiresUserAction, isTrue);
      expect(exception.isRetryable, isFalse);
    });

    test('should detect VALIDATION error code as validation error', () {
      const exception = ApiException(
        message: 'Input validation failed',
        errorCode: 'VALIDATION_ERROR',
        statusCode: 400,
      );

      expect(exception.isValidationError, isTrue);
    });

    test('should detect INVALID error code as validation error', () {
      const exception = ApiException(
        message: 'Invalid input format',
        errorCode: 'INVALID_FORMAT',
        statusCode: 400,
      );

      expect(exception.isValidationError, isTrue);
    });

    test('should not detect non-validation errors as validation', () {
      const serverException = ApiException(
        message: 'Internal server error',
        statusCode: 500,
      );

      const authException = ApiException(
        message: 'Unauthorized',
        statusCode: 401,
      );

      expect(serverException.isValidationError, isFalse);
      expect(authException.isValidationError, isFalse);
    });
  });
}
