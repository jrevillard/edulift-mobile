import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:edulift/core/network/error_handler_service.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/core/errors/exceptions.dart';
import '../../../test_mocks/test_mocks.mocks.dart';

/// Comprehensive unit tests for ErrorHandlerService
///
/// Tests focus on error classification, message generation, and the specific
/// family invite error scenario: "This user is already a member of your family."
///
/// Following Flutter Testing Research 2025 standards with:
/// - AAA pattern (Arrange, Act, Assert)
/// - Mockito with @GenerateNiceMocks
/// - Clean architecture compliance
/// - 90%+ coverage target
void main() {
  group('ErrorHandlerService', () {
    late ErrorHandlerService errorHandlerService;
    late MockUserMessageService mockUserMessageService;

    setUp(() {
      mockUserMessageService = MockUserMessageService();
      errorHandlerService = ErrorHandlerService(mockUserMessageService);
    });

    group('classifyError', () {
      group('ApiFailure classification tests', () {
        test('classifies 400 status code as validation category', () {
          // ARRANGE
          const failure = ApiFailure(
            message: 'This user is already a member of your family.',
            statusCode: 400,
          );

          // ACT
          final result = errorHandlerService.classifyError(failure);

          // ASSERT
          expect(result.category, ErrorCategory.validation);
          expect(result.severity, ErrorSeverity.minor);
          expect(
            result.analysisData['original_message'],
            'This user is already a member of your family.',
          );
          expect(result.analysisData['status_code'], 400);
          expect(result.isRetryable, false); // 400 errors are not retryable
          expect(result.requiresUserAction, true);
        });

        test('preserves original message in analysisData for API failures', () {
          // ARRANGE
          const failure = ApiFailure(
            message: 'Custom validation error message',
            statusCode: 400,
          );

          // ACT
          final result = errorHandlerService.classifyError(failure);

          // ASSERT
          expect(
            result.analysisData['original_message'],
            'Custom validation error message',
          );
          expect(result.analysisData['type'], 'api');
        });

        test('classifies 422 validation errors correctly', () {
          // ARRANGE
          const failure = ApiFailure(
            message: 'Validation failed: email format invalid',
            statusCode: 422,
          );

          // ACT
          final result = errorHandlerService.classifyError(failure);

          // ASSERT
          expect(result.category, ErrorCategory.validation);
          expect(result.severity, ErrorSeverity.minor);
          expect(
            result.analysisData['original_message'],
            'Validation failed: email format invalid',
          );
        });

        test('classifies 500 server errors as critical and retryable', () {
          // ARRANGE
          const failure = ApiFailure(
            message: 'Internal server error',
            statusCode: 500,
          );

          // ACT
          final result = errorHandlerService.classifyError(failure);

          // ASSERT
          expect(result.category, ErrorCategory.server);
          expect(result.severity, ErrorSeverity.critical);
          expect(result.isRetryable, true); // 500 errors are retryable
          expect(result.requiresUserAction, false);
        });

        test(
          'classifies 404 not found errors as server with major severity',
          () {
            // ARRANGE
            const failure = ApiFailure(
              message: 'Resource not found',
              statusCode: 404,
            );

            // ACT
            final result = errorHandlerService.classifyError(failure);

            // ASSERT
            expect(result.category, ErrorCategory.server);
            expect(result.severity, ErrorSeverity.major);
            expect(
              result.isRetryable,
              false,
            ); // 400-level errors are not retryable
            expect(result.requiresUserAction, true);
          },
        );
      });

      group('ValidationFailure classification tests', () {
        test(
          'classifies ValidationFailure correctly with original message',
          () {
            // ARRANGE
            const failure = ValidationFailure(
              message: 'Email format is invalid',
              statusCode: 400,
            );

            // ACT
            final result = errorHandlerService.classifyError(failure);

            // ASSERT
            expect(result.category, ErrorCategory.validation);
            expect(result.severity, ErrorSeverity.minor);
            expect(result.isRetryable, true);
            expect(result.requiresUserAction, true);
            expect(
              result.analysisData['original_message'],
              'Email format is invalid',
            );
            expect(result.analysisData['type'], 'validation');
          },
        );

        test('handles ValidationException correctly', () {
          // ARRANGE
          const exception = ValidationException('Invalid input data');

          // ACT
          final result = errorHandlerService.classifyError(exception);

          // ASSERT
          expect(result.category, ErrorCategory.validation);
          expect(result.severity, ErrorSeverity.minor);
          expect(
            result.analysisData['original_message'],
            contains('Invalid input data'),
          );
        });
      });

      group('Network error classification tests', () {
        test('classifies NetworkFailure as network category', () {
          // ARRANGE
          const failure = NetworkFailure(
            message: 'Connection timeout',
            statusCode: 408,
          );

          // ACT
          final result = errorHandlerService.classifyError(failure);

          // ASSERT
          expect(result.category, ErrorCategory.network);
          expect(result.severity, ErrorSeverity.major);
          expect(result.isRetryable, true);
          expect(result.requiresUserAction, false);
        });

        test('classifies NetworkException as network category', () {
          // ARRANGE
          const exception = NetworkException('No internet connection');

          // ACT
          final result = errorHandlerService.classifyError(exception);

          // ASSERT
          expect(result.category, ErrorCategory.network);
          expect(result.severity, ErrorSeverity.major);
        });
      });

      group('Unexpected error classification tests', () {
        test('classifies unknown errors as unexpected', () {
          // ARRANGE
          final unknownError = Exception('Unexpected runtime error');

          // ACT
          final result = errorHandlerService.classifyError(unknownError);

          // ASSERT
          expect(result.category, ErrorCategory.unexpected);
          expect(result.severity, ErrorSeverity.critical);
          expect(result.isRetryable, false);
          expect(result.requiresUserAction, true);
        });

        test('classifies null errors as unexpected', () {
          // ARRANGE & ACT
          final result = errorHandlerService.classifyError(null);

          // ASSERT
          expect(result.category, ErrorCategory.unexpected);
          expect(result.severity, ErrorSeverity.critical);
        });
      });
    });

    group('handleError', () {
      setUp(() {
        // Setup default mock behavior
        when(mockUserMessageService.generateMessage(any, any)).thenReturn(
          const UserErrorMessage(
            titleKey: 'error.test.title',
            messageKey: 'error.test.message',
          ),
        );
      });

      test('processes ApiFailure end-to-end correctly', () async {
        // ARRANGE
        const failure = ApiFailure(
          message: 'This user is already a member of your family.',
          statusCode: 400,
        );
        final context = ErrorContext.familyOperation(
          'invite_member',
          metadata: const {'email': 'existing@test.com'},
        );

        // ACT
        final result = await errorHandlerService.handleError(failure, context);

        // ASSERT
        expect(result.classification.category, ErrorCategory.validation);
        expect(
          result.classification.analysisData['original_message'],
          'This user is already a member of your family.',
        );
        expect(result.wasLogged, true);
        expect(
          result.wasReported,
          false,
        ); // Minor severity should not be reported

        // Verify UserMessageService was called with correct parameters
        verify(
          mockUserMessageService.generateMessage(
            argThat(
              predicate<ErrorClassification>(
                (classification) =>
                    classification.category == ErrorCategory.validation &&
                    classification.analysisData['original_message'] ==
                        'This user is already a member of your family.',
              ),
            ),
            argThat(
              predicate<ErrorContext>(
                (ctx) =>
                    ctx.operation == 'invite_member' && ctx.feature == 'FAMILY',
              ),
            ),
          ),
        ).called(1);
      });

      test('handles critical errors with reporting', () async {
        // ARRANGE
        const failure = ApiFailure(
          message: 'Database connection failed',
          statusCode: 500,
        );
        final context = ErrorContext.familyOperation('invite_member');

        // ACT
        final result = await errorHandlerService.handleError(failure, context);

        // ASSERT
        expect(result.classification.severity, ErrorSeverity.critical);
        expect(result.wasLogged, true);
        // Note: wasReported will be false in test mode (not kReleaseMode)
        expect(result.wasReported, false);
      });

      test('handles exceptions in error handling gracefully', () async {
        // ARRANGE
        when(
          mockUserMessageService.generateMessage(any, any),
        ).thenThrow(Exception('UserMessageService failed'));

        const failure = ApiFailure(message: 'Test error', statusCode: 400);
        final context = ErrorContext.familyOperation('invite_member');

        // ACT
        final result = await errorHandlerService.handleError(failure, context);

        // ASSERT - Should return fallback error handling result
        expect(result.classification.category, ErrorCategory.unexpected);
        expect(result.classification.severity, ErrorSeverity.critical);
        expect(result.userMessage.titleKey, 'errorSystemTitle');
        expect(result.userMessage.messageKey, 'errorSystemMessage');
        expect(result.wasLogged, true);
        expect(result.wasReported, false);
      });
    });

    group('Edge cases and error boundaries', () {
      test('handles malformed ApiFailure without message', () {
        // ARRANGE
        const failure = ApiFailure(statusCode: 400);

        // ACT
        final result = errorHandlerService.classifyError(failure);

        // ASSERT
        expect(result.category, ErrorCategory.validation);
        expect(result.analysisData.containsKey('original_message'), false);
      });

      test('handles ApiFailure without status code', () {
        // ARRANGE
        const failure = ApiFailure(message: 'Network error occurred');

        // ACT
        final result = errorHandlerService.classifyError(failure);

        // ASSERT
        expect(result.category, ErrorCategory.server); // Default category
        expect(result.severity, ErrorSeverity.major); // Default severity
      });

      test('preserves request context in ApiFailure classification', () {
        // ARRANGE
        const failure = ApiFailure(
          message: 'Request failed',
          statusCode: 400,
          requestUrl: '/api/families/invite',
          requestMethod: 'POST',
        );

        // ACT
        final result = errorHandlerService.classifyError(failure);

        // ASSERT
        expect(result.analysisData['url'], '/api/families/invite');
        expect(result.analysisData['method'], 'POST');
      });
    });
  });

  group('ErrorContext factory methods', () {
    test('familyOperation creates correct context', () {
      // ARRANGE & ACT
      final context = ErrorContext.familyOperation(
        'invite_member',
        metadata: const {'email': 'test@test.com'},
        userId: 'user123',
      );

      // ASSERT
      expect(context.operation, 'invite_member');
      expect(context.feature, 'FAMILY');
      expect(context.userId, 'user123');
      expect(context.metadata['email'], 'test@test.com');
      expect(context.timestamp, isNotNull);
      expect(context.sessionId, isNotNull);
    });

    test('ErrorContext is equatable', () {
      // ARRANGE
      final timestamp = DateTime.now();
      final context1 = ErrorContext(
        operation: 'test',
        feature: 'TEST',
        metadata: const {'key': 'value'},
        timestamp: timestamp,
        sessionId: 'session123',
      );
      final context2 = ErrorContext(
        operation: 'test',
        feature: 'TEST',
        metadata: const {'key': 'value'},
        timestamp: timestamp,
        sessionId: 'session123',
      );

      // ACT & ASSERT
      expect(context1, equals(context2));
      expect(context1.hashCode, equals(context2.hashCode));
    });
  });

  group('ErrorClassification equatable behavior', () {
    test('ErrorClassification with same properties are equal', () {
      // ARRANGE
      const classification1 = ErrorClassification(
        category: ErrorCategory.validation,
        severity: ErrorSeverity.minor,
        isRetryable: true,
        requiresUserAction: true,
        analysisData: {'key': 'value'},
      );
      const classification2 = ErrorClassification(
        category: ErrorCategory.validation,
        severity: ErrorSeverity.minor,
        isRetryable: true,
        requiresUserAction: true,
        analysisData: {'key': 'value'},
      );

      // ACT & ASSERT
      expect(classification1, equals(classification2));
      expect(classification1.hashCode, equals(classification2.hashCode));
    });

    test('ErrorClassification with different properties are not equal', () {
      // ARRANGE
      const classification1 = ErrorClassification(
        category: ErrorCategory.validation,
        severity: ErrorSeverity.minor,
        isRetryable: true,
        requiresUserAction: true,
        analysisData: {'key': 'value1'},
      );
      const classification2 = ErrorClassification(
        category: ErrorCategory.validation,
        severity: ErrorSeverity.minor,
        isRetryable: true,
        requiresUserAction: true,
        analysisData: {'key': 'value2'},
      );

      // ACT & ASSERT
      expect(classification1, isNot(equals(classification2)));
    });
  });

  group('DioException airplane mode fix validation', () {
    late ErrorHandlerService errorHandlerService;
    late MockUserMessageService mockUserMessageService;

    setUp(() {
      mockUserMessageService = MockUserMessageService();
      errorHandlerService = ErrorHandlerService(mockUserMessageService);
    });

    test(
      'DioException connectionError should be classified as network failure',
      () {
        // ARRANGE
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/test'),
          error: const NetworkException(
            'Unable to connect. Please check your internet connection.',
          ),
          type: DioExceptionType.connectionError,
        );

        // ACT
        final result = errorHandlerService.classifyError(dioException);

        // ASSERT
        expect(result.category, ErrorCategory.network);
        expect(result.severity, ErrorSeverity.major);
        expect(result.isRetryable, true);
        expect(result.requiresUserAction, false);
        expect(result.analysisData['type'], 'dio_network_error');
        expect(
          result.analysisData['dio_type'],
          'DioExceptionType.connectionError',
        );
      },
    );

    test('DioException timeout should be classified as network failure', () {
      // ARRANGE
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        error: const NetworkException(
          'Connection timeout. Please check your internet connection.',
        ),
        type: DioExceptionType.connectionTimeout,
      );

      // ACT
      final result = errorHandlerService.classifyError(dioException);

      // ASSERT
      expect(result.category, ErrorCategory.network);
      expect(result.severity, ErrorSeverity.major);
      expect(result.isRetryable, true);
      expect(result.requiresUserAction, false);
      expect(result.analysisData['type'], 'dio_network_error');
      expect(
        result.analysisData['dio_type'],
        'DioExceptionType.connectionTimeout',
      );
    });

    test('DioException unknown should be classified as network failure', () {
      // ARRANGE
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        error: const NetworkException(
          'Network error occurred. Please check your connection and try again.',
        ),
      );

      // ACT
      final result = errorHandlerService.classifyError(dioException);

      // ASSERT
      expect(result.category, ErrorCategory.network);
      expect(result.severity, ErrorSeverity.major);
      expect(result.isRetryable, true);
      expect(result.requiresUserAction, false);
      expect(result.analysisData['type'], 'dio_network_error');
      expect(result.analysisData['dio_type'], 'DioExceptionType.unknown');
    });

    test(
      'NetworkException directly should be classified as network failure',
      () {
        // ARRANGE
        const networkException = NetworkException(
          'Unable to connect. Please check your internet connection.',
        );

        // ACT
        final result = errorHandlerService.classifyError(networkException);

        // ASSERT
        expect(result.category, ErrorCategory.network);
        expect(result.severity, ErrorSeverity.major);
        expect(result.isRetryable, true);
        expect(result.requiresUserAction, false);
        expect(result.analysisData['type'], 'network');
      },
    );
  });
}
