import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/index.dart';

void main() {
  group('ErrorHandlerService Message Filtering', () {
    late ErrorHandlerService errorHandler;
    late UserMessageService messageService;

    setUp(() {
      messageService = UserMessageService();
      errorHandler = ErrorHandlerService(messageService);
    });

    group('_isCleanUserMessage', () {
      test('should accept legitimate user-friendly messages', () {
        final testCases = [
          // Previously wrongly excluded messages
          'Failed to join family',
          'Connection timeout',
          'Request failed',
          'Unable to join family',
          'Could not send invitation',
          'Operation timeout',

          // Common user-friendly phrases
          'Invalid email address',
          'Permission denied',
          'Account not found',
          'Session expired',
          'Please try again',
          'Something went wrong',
          'Email already exists',
          'Access denied',
          'Login required',

          // Family-specific user messages
          'This invitation was sent to a different email address',
          'Family name already exists',
          'You are already a member of this family',
          'Invalid invitation code',
        ];

        for (final message in testCases) {
          final isClean = errorHandler.testIsCleanUserMessage(message);
          expect(isClean, isTrue, reason: 'Message "$message" should be accepted as user-friendly');
        }
      });

      test('should reject technical jargon messages', () {
        final testCases = [
          // Strong technical terms
          'ApiException occurred',
          'ServerException in middleware',
          'Stacktrace shows error',
          'Null pointer exception',
          'Buffer overflow detected',
          'JSON parse error',
          'Database connection failed',
          'SQL query timeout',

          // Contextual technical patterns
          'Failed to connect to server',
          'Failed to authenticate user',
          'Failed to initialize system',
          'Failed to parse JSON',
          'Socket timeout occurred',
          'Read timeout exception',
          'Gateway timeout error',
          'Null reference in object',
          'Null pointer dereferenced',

          // Mixed technical/user content
          'Request failed: HTTP 500 Internal Server Error',
          'DioException: Connection timeout',
          'Error: Failed to deserialize response',
        ];

        for (final message in testCases) {
          final isClean = errorHandler.testIsCleanUserMessage(message);
          expect(isClean, isFalse, reason: 'Message "$message" should be rejected as technical');
        }
      });

      test('should handle edge cases correctly', () {
        // Too short
        expect(errorHandler.testIsCleanUserMessage('Bad'), isFalse);

        // Too long (over 200 chars)
        const longMessage = 'This is a very long message that exceeds the maximum length limit for user-friendly messages and should be rejected because it is too verbose and might contain technical details that are not suitable for end users to see in the application interface';
        expect(errorHandler.testIsCleanUserMessage(longMessage), isFalse);

        // Empty
        expect(errorHandler.testIsCleanUserMessage(''), isFalse);
        expect(errorHandler.testIsCleanUserMessage('   '), isFalse);

        // No capital letter
        expect(errorHandler.testIsCleanUserMessage('failed to join family'), isFalse);

        // Single word technical terms (should still be rejected)
        expect(errorHandler.testIsCleanUserMessage('Exception'), isFalse);
        expect(errorHandler.testIsCleanUserMessage('Stacktrace'), isFalse);
      });

      test('should prioritize user-friendly patterns over technical terms', () {
        // These contain both user-friendly and technical patterns
        // User-friendly patterns should take precedence
        final testCases = [
          'Failed to join family - timeout', // Has "timeout" but "failed to join" is user-friendly
          'Unable to create account - request failed', // "request" is technical but "unable to create" is user-friendly
          'Connection timeout while joining', // "timeout" is user-friendly in this context
        ];

        for (final message in testCases) {
          final isClean = errorHandler.testIsCleanUserMessage(message);
          expect(isClean, isTrue, reason: 'Message "$message" should prioritize user-friendly pattern');
        }
      });
    });

    group('Real-world message extraction scenarios', () {
      test('should extract clean user messages from complex error strings', () {
        final complexErrors = [
          'ApiException: ServerException(500): Failed to join family: ApiException: This invitation was sent to a different email address (Status: 400)',
          'DioException: Request failed: Family name already exists (Status: 422)',
          'ValidationException: Unable to create family: Name is required (Status: 400)',
        ];

        final expectedMessages = [
          'This invitation was sent to a different email address',
          'Family name already exists',
          'Name is required',
        ];

        for (var i = 0; i < complexErrors.length; i++) {
          final extracted = errorHandler.testExtractUserFriendlyMessage(complexErrors[i]);
          expect(extracted, equals(expectedMessages[i]),
                reason: 'Should extract "${expectedMessages[i]}" from "${complexErrors[i]}"');
        }
      });
    });
  });
}

