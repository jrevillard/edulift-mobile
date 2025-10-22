import 'package:flutter_test/flutter_test.dart';

import 'package:edulift/core/network/error_handler_service.dart';
import 'package:edulift/core/errors/failures.dart';

import '../../../test_mocks/test_mocks.mocks.dart';
import '../../../support/mock_fallbacks.dart';

void main() {
  setUpAll(() {
    setupMockFallbacks();
  });

  group('ErrorHandlerService - Family Error Code Handling', () {
    late ErrorHandlerService errorHandlerService;

    setUp(() {
      // Create with mock message service for testing error messages only
      errorHandlerService = ErrorHandlerService(MockUserMessageService());
    });

    test(
      'should return user-friendly message for LAST_ADMIN error using error code',
      () {
        // Arrange - Create ApiFailure with LAST_ADMIN error code in details (new backend format)
        const apiFailure = ApiFailure(
          message:
              'Cannot leave family as you are the last administrator. Please appoint another admin first.',
          statusCode: 400,
          details: {'code': 'LAST_ADMIN'},
        );

        // Act
        final userMessage = errorHandlerService.getErrorMessage(apiFailure);

        // Assert
        expect(
          userMessage,
          equals(
            'Cannot leave family as you are the last administrator. Please appoint another admin first.',
          ),
        );
      },
    );

    test(
      'should return user-friendly message for LAST_ADMIN error with different format',
      () {
        // Arrange - Create ApiFailure with just LAST_ADMIN in message
        const apiFailure = ApiFailure(
          message:
              'LAST_ADMIN: Cannot leave family as you are the last administrator',
          statusCode: 400,
        );

        // Act
        final userMessage = errorHandlerService.getErrorMessage(apiFailure);

        // Assert
        expect(
          userMessage,
          equals(
            'Cannot leave family as you are the last administrator. Please appoint another admin first.',
          ),
        );
      },
    );

    test('should fall back to generic message for other ApiFailures', () {
      // Arrange - Create regular ApiFailure without LAST_ADMIN
      const apiFailure = ApiFailure(
        message: 'Some other error occurred',
        statusCode: 500,
      );

      // Act
      final userMessage = errorHandlerService.getErrorMessage(apiFailure);

      // Assert
      expect(userMessage, equals('Some other error occurred'));
    });

    test('should handle UNAUTHORIZED admin error with error code', () {
      // Arrange - Using new error code format
      const apiFailure = ApiFailure(
        message:
            'You don\'t have permission to perform this action. Only family admins can manage members.',
        statusCode: 403,
        details: {'code': 'UNAUTHORIZED'},
      );

      // Act
      final userMessage = errorHandlerService.getErrorMessage(apiFailure);

      // Assert
      expect(
        userMessage,
        equals(
          'You don\'t have permission to perform this action. Only family admins can manage members.',
        ),
      );
    });

    test('should handle MEMBER_NOT_FOUND error with error code', () {
      // Arrange - Using new error code format
      const apiFailure = ApiFailure(
        message:
            'This family member was not found. They may have already left the family.',
        statusCode: 404,
        details: {'code': 'MEMBER_NOT_FOUND'},
      );

      // Act
      final userMessage = errorHandlerService.getErrorMessage(apiFailure);

      // Assert
      expect(
        userMessage,
        equals(
          'This family member was not found. They may have already left the family.',
        ),
      );
    });

    test('should handle CANNOT_DEMOTE_SELF error with error code', () {
      // Arrange - Using new error code format
      const apiFailure = ApiFailure(
        message:
            'You cannot change your own admin role. Ask another admin to do this.',
        statusCode: 400,
        details: {'code': 'CANNOT_DEMOTE_SELF'},
      );

      // Act
      final userMessage = errorHandlerService.getErrorMessage(apiFailure);

      // Assert
      expect(
        userMessage,
        equals(
          'You cannot change your own admin role. Ask another admin to do this.',
        ),
      );
    });

    test('should handle ApiFailure with null message but valid error code', () {
      // Arrange - ApiFailure with null message but valid error code
      const apiFailure = ApiFailure(
        statusCode: 400,
        details: {'type': 'family_error', 'code': 'LAST_ADMIN'},
      );

      // Act
      final userMessage = errorHandlerService.getErrorMessage(apiFailure);

      // Assert - Should use error code even when message is null
      expect(
        userMessage,
        equals(
          'Cannot leave family as you are the last administrator. Please appoint another admin first.',
        ),
      );
    });

    test(
      'should fall back to generic message when both message and code are missing',
      () {
        // Arrange - ApiFailure with null message and no error code
        const apiFailure = ApiFailure(
          statusCode: 400,
          details: {'type': 'family_error'},
        );

        // Act
        final userMessage = errorHandlerService.getErrorMessage(apiFailure);

        // Assert - Should fall back to generic message
        expect(userMessage, equals('Something went wrong. Please try again.'));
      },
    );
  });
}
