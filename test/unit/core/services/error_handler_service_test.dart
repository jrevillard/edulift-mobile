import 'package:test/test.dart';
import 'package:edulift/core/network/error_handler_service.dart';
import 'package:edulift/core/errors/failures.dart';

void main() {
  late ErrorHandlerService errorHandlerService;
  late UserMessageService userMessageService;

  setUp(() {
    userMessageService = UserMessageService();
    errorHandlerService = ErrorHandlerService(userMessageService);
  });

  group('ErrorHandlerService', () {
    group('isNameRequiredError', () {
      test(
        'should return true for exact backend message "Name is required for new users"',
        () {
          // Arrange
          const failure = ValidationFailure(
            message: 'Name is required for new users',
            statusCode: 422,
          );

          // Act
          final result = errorHandlerService.isNameRequiredError(failure);

          // Assert
          expect(result, isTrue);
        },
      );

      test('should return true for case variations of the message', () {
        // Arrange
        const failure = ValidationFailure(
          message: 'NAME IS REQUIRED FOR NEW USERS',
          statusCode: 422,
        );

        // Act
        final result = errorHandlerService.isNameRequiredError(failure);

        // Assert
        expect(result, isTrue);
      });

      test('should return true for partial message "name required"', () {
        // Arrange
        const failure = ValidationFailure(
          message: 'name required',
          statusCode: 422,
        );

        // Act
        final result = errorHandlerService.isNameRequiredError(failure);

        // Assert
        expect(result, isTrue);
      });

      test('should return true for message containing "Name Required"', () {
        // Arrange
        const failure = ValidationFailure(
          message: 'Error: Name Required for account creation',
          statusCode: 422,
        );

        // Act
        final result = errorHandlerService.isNameRequiredError(failure);

        // Assert
        expect(result, isTrue);
      });

      test('should return false for different validation messages', () {
        // Arrange
        const failure = ValidationFailure(
          message: 'Email is invalid',
          statusCode: 422,
        );

        // Act
        final result = errorHandlerService.isNameRequiredError(failure);

        // Assert
        expect(result, isFalse);
      });

      test('should return false for ValidationFailure with null message', () {
        // Arrange
        const failure = ValidationFailure();

        // Act
        final result = errorHandlerService.isNameRequiredError(failure);

        // Assert
        expect(result, isFalse);
      });

      test('should return false for ValidationFailure with empty message', () {
        // Arrange
        const failure = ValidationFailure(message: '', statusCode: 422);

        // Act
        final result = errorHandlerService.isNameRequiredError(failure);

        // Assert
        expect(result, isFalse);
      });

      test('should return false for non-ValidationFailure errors', () {
        // Arrange
        const failure = ServerFailure(
          message: 'Name is required for new users',
        );

        // Act
        final result = errorHandlerService.isNameRequiredError(failure);

        // Assert
        expect(result, isFalse);
      });

      test(
        'should return false for NetworkFailure even with matching message',
        () {
          // Arrange
          const failure = NetworkFailure(
            message: 'Name is required for new users',
          );

          // Act
          final result = errorHandlerService.isNameRequiredError(failure);

          // Assert
          expect(result, isFalse);
        },
      );

      test(
        'should return false for AuthFailure even with matching message',
        () {
          // Arrange
          const failure = AuthFailure(
            message: 'Name is required for new users',
          );

          // Act
          final result = errorHandlerService.isNameRequiredError(failure);

          // Assert
          expect(result, isFalse);
        },
      );

      test('should handle real API response structure from backend 422', () {
        // Arrange - Simulating the actual error from AuthService.sendMagicLink
        const failure = ValidationFailure(
          message: 'Name is required for new users',
          statusCode: 422,
          details: {'type': 'missing_name_for_new_user'},
        );

        // Act
        final result = errorHandlerService.isNameRequiredError(failure);

        // Assert
        expect(result, isTrue);
      });
    });

    group('getErrorMessage', () {
      test('should return server error message for ServerFailure', () {
        // Arrange
        const failure = ServerFailure(message: 'Server error occurred');

        // Act
        final result = errorHandlerService.getErrorMessage(failure);

        // Assert
        expect(result, equals('Server error occurred'));
      });

      test(
        'should return default message for ServerFailure with null message',
        () {
          // Arrange
          const failure = ServerFailure();

          // Act
          final result = errorHandlerService.getErrorMessage(failure);

          // Assert
          expect(result, equals('SERVER_ERROR_GENERAL'));
        },
      );

      test('should return validation error message for ValidationFailure', () {
        // Arrange
        const failure = ValidationFailure(
          message: 'Name is required for new users',
        );

        // Act
        final result = errorHandlerService.getErrorMessage(failure);

        // Assert
        expect(result, equals('Name is required for new users'));
      });

      test(
        'should return default message for ValidationFailure with null message',
        () {
          // Arrange
          const failure = ValidationFailure();

          // Act
          final result = errorHandlerService.getErrorMessage(failure);

          // Assert
          expect(result, equals('VALIDATION_ERROR_GENERAL'));
        },
      );
    });

    group('getErrorCategory', () {
      test('should return validation category for ValidationFailure', () {
        // Arrange
        const failure = ValidationFailure(message: 'Name is required');

        // Act
        final result = errorHandlerService.classifyError(failure);

        // Assert
        expect(result.category, equals(ErrorCategory.validation));
      });

      test('should return network category for NetworkFailure', () {
        // Arrange
        const failure = NetworkFailure(message: 'Connection failed');

        // Act
        final result = errorHandlerService.classifyError(failure);

        // Assert
        expect(result.category, equals(ErrorCategory.network));
      });

      test('should return authentication category for AuthFailure', () {
        // Arrange
        const failure = AuthFailure(message: 'Invalid token');

        // Act
        final result = errorHandlerService.classifyError(failure);

        // Assert
        expect(result.category, equals(ErrorCategory.authentication));
      });

      test('should return server category for ServerFailure', () {
        // Arrange
        const failure = ServerFailure(message: 'Internal server error');

        // Act
        final result = errorHandlerService.classifyError(failure);

        // Assert
        expect(result.category, equals(ErrorCategory.server));
      });

      test('should return server category for ApiFailure', () {
        // Arrange
        const failure = ApiFailure(message: 'API error');

        // Act
        final result = errorHandlerService.classifyError(failure);

        // Assert
        expect(result.category, equals(ErrorCategory.server));
      });
    });

    group('helper methods', () {
      test('isNetworkError should return true for NetworkFailure', () {
        // Arrange
        const failure = NetworkFailure(message: 'No internet');

        // Act
        final result = errorHandlerService.classifyError(failure).category == ErrorCategory.network;

        // Assert
        expect(result, isTrue);
      });

      test('isNetworkError should return false for non-NetworkFailure', () {
        // Arrange
        const failure = ValidationFailure(message: 'Name required');

        // Act
        final result = errorHandlerService.classifyError(failure).category == ErrorCategory.network;

        // Assert
        expect(result, isFalse);
      });

      test('isAuthError should return true for AuthFailure', () {
        // Arrange
        const failure = AuthFailure(message: 'Unauthorized');

        // Act
        final result = errorHandlerService.classifyError(failure).category == ErrorCategory.authentication;

        // Assert
        expect(result, isTrue);
      });

      test('isAuthError should return false for non-AuthFailure', () {
        // Arrange
        const failure = ValidationFailure(message: 'Name required');

        // Act
        final result = errorHandlerService.classifyError(failure).category == ErrorCategory.authentication;

        // Assert
        expect(result, isFalse);
      });

      test('isValidationError should return true for ValidationFailure', () {
        // Arrange
        const failure = ValidationFailure(message: 'Name required');

        // Act
        final result = errorHandlerService.classifyError(failure).category == ErrorCategory.validation;

        // Assert
        expect(result, isTrue);
      });

      test(
        'isValidationError should return false for non-ValidationFailure',
        () {
          // Arrange
          const failure = NetworkFailure(message: 'No connection');

          // Act
          final result = errorHandlerService.classifyError(failure).category == ErrorCategory.validation;

          // Assert
          expect(result, isFalse);
        },
      );
    });
  });
}
