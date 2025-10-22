import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/errors/api_exception.dart';

void main() {
  group('ApiException 400 Validation Fix', () {
    test('should classify 400 status as validation error', () {
      // ARRANGE: Create ApiException with 400 status (invitation validation)
      const exception = ApiException(
        message: 'Invalid or expired invite code',
        statusCode: 400,
        endpoint: '/api/families/validate-invitation',
        method: 'POST',
      );

      // ACT & ASSERT: Should now be classified as validation error
      expect(
        exception.isValidationError,
        isTrue,
        reason:
            'Status 400 should be classified as validation error for invitation validation',
      );
    });

    test('should maintain existing 422 validation classification', () {
      // ARRANGE: Create ApiException with 422 status
      const exception = ApiException(
        message: 'Name is required',
        statusCode: 422,
        endpoint: '/api/auth/register',
        method: 'POST',
      );

      // ACT & ASSERT: Should still be classified as validation error
      expect(
        exception.isValidationError,
        isTrue,
        reason: 'Status 422 should remain classified as validation error',
      );
    });

    test('should not classify other 4xx errors as validation errors', () {
      // ARRANGE: Create ApiException with 404 status
      const exception = ApiException(
        message: 'Not found',
        statusCode: 404,
        endpoint: '/api/families/123',
        method: 'GET',
      );

      // ACT & ASSERT: Should NOT be classified as validation error
      expect(
        exception.isValidationError,
        isFalse,
        reason: 'Status 404 should not be classified as validation error',
      );
    });

    test(
      'should classify errors with VALIDATION error code as validation errors',
      () {
        // ARRANGE: Create ApiException with validation error code
        const exception = ApiException(
          message: 'Validation failed',
          statusCode: 500,
          errorCode: 'VALIDATION_ERROR',
          endpoint: '/api/test',
          method: 'POST',
        );

        // ACT & ASSERT: Should be classified as validation error due to error code
        expect(
          exception.isValidationError,
          isTrue,
          reason:
              'Error code VALIDATION should be classified as validation error',
        );
      },
    );

    test(
      'should classify errors with INVALID error code as validation errors',
      () {
        // ARRANGE: Create ApiException with invalid error code
        const exception = ApiException(
          message: 'Invalid input',
          statusCode: 500,
          errorCode: 'INVALID_DATA',
          endpoint: '/api/test',
          method: 'POST',
        );

        // ACT & ASSERT: Should be classified as validation error due to error code
        expect(
          exception.isValidationError,
          isTrue,
          reason: 'Error code INVALID should be classified as validation error',
        );
      },
    );
  });
}
