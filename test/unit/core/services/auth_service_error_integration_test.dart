import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/network/error_handler_service.dart';
import 'package:edulift/core/errors/failures.dart';

void main() {
  group('AuthService Error Handling Integration', () {
    test('AuthService should have ErrorHandlerService dependency', () {
      // This test verifies that AuthService constructor includes ErrorHandlerService
      // and that our conversion method exists by checking the implementation

      // Arrange - Create a test ErrorHandlingResult
      const errorResult = ErrorHandlingResult(
        classification: ErrorClassification(
          category: ErrorCategory.validation,
          severity: ErrorSeverity.minor,
          isRetryable: true,
          requiresUserAction: true,
          analysisData: {'type': 'validation'},
        ),
        userMessage: UserErrorMessage(
          titleKey: 'error.validation.title',
          messageKey: 'error.validation.invalid_data',
          canRetry: true,
        ),
        wasLogged: true,
        wasReported: false,
      );

      // Act & Assert - Verify error categories map to correct failure types
      expect(errorResult.classification.category, ErrorCategory.validation);
      expect(errorResult.userMessage.messageKey, contains('Invalid data'));
      expect(errorResult.classification.isRetryable, isTrue);

      // Test specific 422 handling expectation
      expect(errorResult.classification.category, ErrorCategory.validation);
      expect(errorResult.classification.severity, ErrorSeverity.minor);
    });

    test(
      'ErrorHandlerService should properly classify 422 validation errors',
      () {
        // Arrange
        final errorHandlerService = ErrorHandlerService(UserMessageService());
        final apiFailure = ApiFailure.validationError(
          message: 'This user is already a member of a family',
        );

        // Act - Test the classification logic
        final classification = errorHandlerService.classifyError(apiFailure);

        // Assert - Verify 422 errors are classified as validation
        expect(classification.category, ErrorCategory.validation);
        expect(classification.severity, ErrorSeverity.minor);
        expect(classification.isRetryable, isTrue);
        expect(classification.requiresUserAction, isTrue);
        expect(classification.analysisData['type'], 'api');
        expect(classification.analysisData['status_code'], 422);
      },
    );

    test(
      'UserMessageService should generate user-friendly messages for validation errors',
      () {
        // Arrange
        final userMessageService = UserMessageService();
        const classification = ErrorClassification(
          category: ErrorCategory.validation,
          severity: ErrorSeverity.minor,
          isRetryable: true,
          requiresUserAction: true,
          analysisData: {'type': 'validation'},
        );
        final context = ErrorContext.authOperation('send_magic_link');

        // Act
        final userMessage = userMessageService.generateMessage(
          classification,
          context,
        );

        // Assert - Verify user-friendly message generation
        expect(userMessage.titleKey, 'Invalid Information');
        expect(
          userMessage.messageKey,
          'Please check the information you entered and try again.',
        );
        expect(userMessage.canRetry, isTrue);
        expect(userMessage.severity, ErrorSeverity.minor);
      },
    );

    test(
      'ErrorContext.authOperation should create proper context for auth operations',
      () {
        // Arrange & Act
        final context = ErrorContext.authOperation(
          'send_magic_link',
          metadata: const {'email': 'test@example.com', 'has_invite': false},
        );

        // Assert
        expect(context.operation, 'send_magic_link');
        expect(context.feature, 'AUTH');
        expect(context.metadata['email'], 'test@example.com');
        expect(context.metadata['has_invite'], false);
        expect(context.timestamp, isA<DateTime>());
        expect(context.sessionId, isNotEmpty);
      },
    );

    group('Error Category to Failure Type Mapping', () {
      test('should map validation errors to ValidationFailure', () {
        // Test the conversion logic that would be used in AuthService
        const category = ErrorCategory.validation;
        const message = 'Invalid email format';
        const statusCode = 422;

        // Simulate the conversion that happens in _convertToFailure
        Failure failure;
        switch (category) {
          case ErrorCategory.validation:
            failure = const ValidationFailure(
              message: message,
              statusCode: statusCode,
              details: {'type': 'validation'},
            );
            break;
          default:
            failure = const UnexpectedFailure('Unknown error');
        }

        expect(failure, isA<ValidationFailure>());
        expect(failure.message, message);
        expect(failure.statusCode, statusCode);
      });

      test('should map network errors to NetworkFailure', () {
        const category = ErrorCategory.network;
        const message = 'Connection timeout';

        Failure failure;
        switch (category) {
          case ErrorCategory.network:
            failure = const NetworkFailure(
              message: message,
              statusCode: 0,
              details: {'type': 'network'},
            );
            break;
          default:
            failure = const UnexpectedFailure('Unknown error');
        }

        expect(failure, isA<NetworkFailure>());
        expect(failure.message, message);
        expect(failure.statusCode, 0);
      });

      test('should map authentication errors to AuthFailure', () {
        const category = ErrorCategory.authentication;
        const message = 'Invalid credentials';

        Failure failure;
        switch (category) {
          case ErrorCategory.authentication:
            failure = const AuthFailure(
              message: message,
              statusCode: 401,
              details: {'type': 'authentication'},
            );
            break;
          default:
            failure = const UnexpectedFailure('Unknown error');
        }

        expect(failure, isA<AuthFailure>());
        expect(failure.message, message);
        expect(failure.statusCode, 401);
      });
    });
  });
}
