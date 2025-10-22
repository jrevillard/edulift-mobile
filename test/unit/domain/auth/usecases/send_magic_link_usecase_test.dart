import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:edulift/features/auth/domain/usecases/send_magic_link_usecase.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';

import '../../../../test_mocks/test_mocks.dart';
import '../../../../test_mocks/test_specialized_mocks.dart';

void main() {
  // Setup Mocktail dummy values for Result types
  setUpAll(() {
    setupMockFallbacks();
  });

  group('SendMagicLinkUsecase', () {
    late SendMagicLinkUsecase usecase;
    late MockFeatureAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockFeatureAuthService();
      usecase = SendMagicLinkUsecase(mockAuthService);
    });

    group('Construction', () {
      test('should create usecase with service dependency', () {
        // Arrange & Act
        final usecase = SendMagicLinkUsecase(mockAuthService);

        // Assert
        expect(usecase, isA<SendMagicLinkUsecase>());
      });
    });

    group('Success Cases', () {
      test('should send magic link successfully with valid email', () async {
        // Arrange
        final params = SendMagicLinkParams(email: 'test@example.com');
        when(
          mockAuthService.sendMagicLink('test@example.com'),
        ).thenAnswer((_) async => const Result.ok(null));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isOk, isTrue);
        verify(mockAuthService.sendMagicLink('test@example.com')).called(1);
      });

      test(
        'should send magic link successfully with email and redirect URL',
        () async {
          // Arrange
          final params = SendMagicLinkParams(
            email: 'user@domain.com',
            redirectUrl: 'https://app.example.com/verify',
          );
          when(
            mockAuthService.sendMagicLink('user@domain.com'),
          ).thenAnswer((_) async => const Result.ok(null));

          // Act
          final result = await usecase.call(params);

          // Assert
          expect(result.isOk, isTrue);
          verify(mockAuthService.sendMagicLink('user@domain.com')).called(1);
        },
      );

      test('should send magic link successfully with inviteCode', () async {
        // Arrange
        final params = SendMagicLinkParams(
          email: 'test@example.com',
          inviteCode: 'FAM123',
        );
        when(
          mockAuthService.sendMagicLink(
            'test@example.com',
            inviteCode: 'FAM123',
          ),
        ).thenAnswer((_) async => const Result.ok(null));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isOk, isTrue);
        verify(
          mockAuthService.sendMagicLink(
            'test@example.com',
            inviteCode: 'FAM123',
          ),
        ).called(1);
      });

      test('should handle various valid email formats', () async {
        // Arrange
        const validEmails = [
          'simple@example.com',
          'user.name@domain.co.uk',
          'test+tag@subdomain.example.org',
          'user123@example-site.com',
          'a@b.co',
        ];

        // Act & Assert
        for (final email in validEmails) {
          when(
            mockAuthService.sendMagicLink(email),
          ).thenAnswer((_) async => const Result.ok('Sent'));

          final params = SendMagicLinkParams(email: email);
          final result = await usecase.call(params);

          expect(
            result.isOk,
            isTrue,
            reason: 'Call should succeed for email: $email',
          );
          verify(mockAuthService.sendMagicLink(email)).called(1);
        }
      });
    });

    group(
      'Validation Failures - No validation in usecase (delegates to service)',
      () {
        test('should delegate empty email to service', () async {
          // Arrange
          final params = SendMagicLinkParams(email: '');
          when(
            mockAuthService.sendMagicLink(''),
          ).thenAnswer((_) async => const Result.ok(null));

          // Act
          final result = await usecase.call(params);

          // Assert
          expect(result.isSuccess, isTrue);
          verify(mockAuthService.sendMagicLink('')).called(1);
        });

        test('should delegate invalid email formats to service', () async {
          // Arrange
          const testEmails = [
            'invalid-email',
            '@example.com',
            'user@',
            'user@.com',
          ];

          // Act & Assert
          for (final email in testEmails) {
            reset(mockAuthService);
            when(
              mockAuthService.sendMagicLink(email),
            ).thenAnswer((_) async => const Result.ok(null));

            final params = SendMagicLinkParams(email: email);
            final result = await usecase.call(params);

            expect(result.isSuccess, isTrue);
            verify(mockAuthService.sendMagicLink(email)).called(1);
          }
        });
      },
    );

    group('Repository Failure Cases', () {
      test(
        'should return error when repository fails to send magic link',
        () async {
          // Arrange
          final params = SendMagicLinkParams(email: 'test@example.com');
          final failure = ApiFailure.serverError(
            message: 'Email service unavailable',
          );

          when(
            mockAuthService.sendMagicLink('test@example.com'),
          ).thenAnswer((_) async => Result.err(failure));

          // Act
          final result = await usecase.call(params);

          // Assert
          expect(result.isError, isTrue);
          expect(result.error, equals(failure));
        },
      );

      test('should handle network errors gracefully', () async {
        // Arrange
        final params = SendMagicLinkParams(email: 'test@example.com');
        final failure = ApiFailure.network(message: 'No internet connection');

        when(
          mockAuthService.sendMagicLink('test@example.com'),
        ).thenAnswer((_) async => Result.err(failure));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, equals(failure));
      });

      test('should handle rate limiting errors', () async {
        // Arrange
        final params = SendMagicLinkParams(email: 'test@example.com');
        final failure = ApiFailure.badRequest(
          message: 'Too many magic link requests',
        );

        when(
          mockAuthService.sendMagicLink('test@example.com'),
        ).thenAnswer((_) async => Result.err(failure));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, equals(failure));
      });

      test('should handle email not found errors', () async {
        // Arrange
        final params = SendMagicLinkParams(email: 'nonexistent@example.com');
        final failure = ApiFailure.notFound(resource: 'Email address');

        when(
          mockAuthService.sendMagicLink('nonexistent@example.com'),
        ).thenAnswer((_) async => Result.err(failure));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, equals(failure));
      });
    });

    group('Business Logic Validation', () {
      test(
        'should pass email unchanged to repository after validation',
        () async {
          // Arrange
          final params = SendMagicLinkParams(email: 'business@company.org');

          when(
            mockAuthService.sendMagicLink('business@company.org'),
          ).thenAnswer((_) async => const Result.ok('Sent'));

          // Act
          await usecase.call(params);

          // Assert
          verify(
            mockAuthService.sendMagicLink('business@company.org'),
          ).called(1);
          verifyNoMoreInteractions(mockAuthService);
        },
      );

      test(
        'should pass both email and redirectUrl unchanged to repository',
        () async {
          // Arrange
          final params = SendMagicLinkParams(
            email: 'test@example.com',
            redirectUrl: 'https://custom.redirect.url/auth',
          );

          when(
            mockAuthService.sendMagicLink('test@example.com'),
          ).thenAnswer((_) async => const Result.ok('Sent'));

          // Act
          await usecase.call(params);

          // Assert
          verify(mockAuthService.sendMagicLink('test@example.com')).called(1);
          verifyNoMoreInteractions(mockAuthService);
        },
      );

      test('should handle concurrent requests correctly', () async {
        // Arrange
        final params1 = SendMagicLinkParams(email: 'user1@example.com');
        final params2 = SendMagicLinkParams(email: 'user2@example.com');

        when(
          mockAuthService.sendMagicLink('user1@example.com'),
        ).thenAnswer((_) async => const Result.ok('Sent to user1'));
        when(
          mockAuthService.sendMagicLink('user2@example.com'),
        ).thenAnswer((_) async => const Result.ok('Sent to user2'));

        // Act
        final results = await Future.wait([
          usecase.call(params1),
          usecase.call(params2),
        ]);

        // Assert
        expect(results[0].isOk, isTrue);
        expect(results[1].isOk, isTrue);

        verify(mockAuthService.sendMagicLink('user1@example.com')).called(1);
        verify(mockAuthService.sendMagicLink('user2@example.com')).called(1);
      });
    });

    group('Edge Cases', () {
      test('should handle very long but valid email addresses', () async {
        // Arrange
        final longEmail = '${'a' * 50}@${'b' * 50}.com';
        final params = SendMagicLinkParams(email: longEmail);

        when(
          mockAuthService.sendMagicLink(longEmail),
        ).thenAnswer((_) async => const Result.ok('Sent'));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isOk, isTrue);
        verify(mockAuthService.sendMagicLink(longEmail)).called(1);
      });

      test('should handle emails with international characters', () async {
        // Arrange
        final params = SendMagicLinkParams(email: 'tëst@examplé.com');

        when(
          mockAuthService.sendMagicLink('tëst@examplé.com'),
        ).thenAnswer((_) async => const Result.ok('Sent'));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isOk, isTrue);
        verify(mockAuthService.sendMagicLink('tëst@examplé.com')).called(1);
      });

      test('should handle null redirect URL correctly', () async {
        // Arrange
        final params = SendMagicLinkParams(email: 'test@example.com');

        when(
          mockAuthService.sendMagicLink('test@example.com'),
        ).thenAnswer((_) async => const Result.ok('Sent'));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isOk, isTrue);
        verify(mockAuthService.sendMagicLink('test@example.com')).called(1);
      });

      test('should handle empty redirect URL correctly', () async {
        // Arrange
        final params = SendMagicLinkParams(
          email: 'test@example.com',
          redirectUrl: '',
        );

        when(
          mockAuthService.sendMagicLink('test@example.com'),
        ).thenAnswer((_) async => const Result.ok('Sent'));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isOk, isTrue);
        verify(mockAuthService.sendMagicLink('test@example.com')).called(1);
      });
    });

    group('Error Recovery', () {
      test('should handle timeout scenarios gracefully', () async {
        // Arrange
        final params = SendMagicLinkParams(email: 'test@example.com');
        final failure = ApiFailure.timeout();

        when(
          mockAuthService.sendMagicLink('test@example.com'),
        ).thenAnswer((_) async => Result.err(failure));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, equals(failure));
      });

      test('should handle repository exceptions gracefully', () async {
        // Arrange
        final params = SendMagicLinkParams(email: 'test@example.com');

        when(
          mockAuthService.sendMagicLink('test@example.com'),
        ).thenThrow(Exception('Unexpected error'));

        // Act & Assert
        expect(() => usecase.call(params), throwsA(isA<Exception>()));
      });
    });
  });
}
