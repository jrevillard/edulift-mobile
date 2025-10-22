import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:edulift/features/auth/domain/usecases/verify_magic_link_usecase.dart';
import 'package:edulift/core/domain/entities/user.dart';
import 'package:edulift/core/domain/services/auth_service.dart' as core;
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';

import '../../../../test_mocks/test_mocks.dart';
import '../../../../test_mocks/test_specialized_mocks.dart';

void main() {
  // Setup Mockito dummy values for Result types
  setUpAll(() {
    setupMockFallbacks();
  });

  group('VerifyMagicLinkUsecase', () {
    late VerifyMagicLinkUsecase usecase;
    late MockFeatureAuthService mockAuthService;
    late DateTime testDateTime;

    setUp(() {
      mockAuthService = MockFeatureAuthService();
      reset(mockAuthService); // This clears all interactions and stubbing
      usecase = VerifyMagicLinkUsecase(mockAuthService);
      testDateTime = DateTime(2024, 1, 1, 10);
    });

    tearDown(() {
      // FIXED: Only clear interactions, not reset (which would clear stubs mid-test)
      clearInteractions(mockAuthService);
    });

    group('Construction', () {
      test('should create usecase with service dependency', () {
        // Arrange & Act
        final usecase = VerifyMagicLinkUsecase(mockAuthService);

        // Assert
        expect(usecase, isNotNull);
      });
    });

    group('Success Cases', () {
      test('should verify magic link token successfully', () async {
        // Arrange
        final params = VerifyMagicLinkParams(
          token: 'valid-magic-link-token-123456789',
        );

        final expectedUser = User(
          id: 'user-123',
          email: 'test@example.com',
          name: 'Test User',
          createdAt: testDateTime,
          updatedAt: testDateTime,
          preferredLanguage: 'en',
          timezone: 'UTC',
          hasCompletedOnboarding: true,
        );

        final expectedResult = core.AuthResult(
          user: expectedUser,
          token: 'access-token-123',
        );

        when(
          mockAuthService.authenticateWithMagicLink(
            'valid-magic-link-token-123456789',
          ),
        ).thenAnswer((_) async => Result.ok(expectedResult));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.value, equals(expectedResult));
        expect(result.value!.user, equals(expectedUser));
        verify(
          mockAuthService.authenticateWithMagicLink(
            'valid-magic-link-token-123456789',
          ),
        ).called(1);
      });

      test('should handle various valid token formats', () async {
        // Arrange
        const validTokens = [
          'abcdefghij', // Minimum 10 characters
          'token-with-dashes-and-numbers-123',
          'VeryLongTokenWithMany()CharactersAndNumbers123456789',
          'token_with_underscores_123',
          'TOKEN.WITH.DOTS.123',
        ];

        final mockUser = User(
          id: 'user-123',
          email: 'test@example.com',
          name: 'Test User',
          createdAt: testDateTime,
          updatedAt: testDateTime,
          preferredLanguage: 'en',
          timezone: 'UTC',
          hasCompletedOnboarding: true,
        );

        final mockResult = core.AuthResult(
          user: mockUser,
          token: 'access-token',
        );

        // Act & Assert
        for (final token in validTokens) {
          when(
            mockAuthService.authenticateWithMagicLink(token),
          ).thenAnswer((_) async => Result.ok(mockResult));

          final params = VerifyMagicLinkParams(token: token);
          final result = await usecase.call(params);

          expect(
            result.value,
            equals(mockResult),
            reason: 'Failed for token: $token',
          );
          verify(mockAuthService.authenticateWithMagicLink(token)).called(1);
        }
      });
    });

    group(
      'Validation Failures - No validation in usecase (delegates to service)',
      () {
        test('should delegate empty token to service', () async {
          // Arrange
          final params = VerifyMagicLinkParams(token: '');
          final expectedUser = User(
            id: 'user-123',
            email: 'test@example.com',
            name: 'Test User',
            createdAt: testDateTime,
            updatedAt: testDateTime,
            preferredLanguage: 'en',
            timezone: 'UTC',
            hasCompletedOnboarding: true,
          );

          final expectedResult = core.AuthResult(
            user: expectedUser,
            token: 'access-token-123',
          );

          when(
            mockAuthService.authenticateWithMagicLink(''),
          ).thenAnswer((_) async => Result.ok(expectedResult));

          // Act
          final result = await usecase.call(params);

          // Assert
          expect(result.isSuccess, isTrue);
          verify(mockAuthService.authenticateWithMagicLink('')).called(1);
        });

        test('should delegate short tokens to service', () async {
          // Arrange
          const testTokens = [
            '123', // 3 characters - too short
            'abcd', // 4 characters - too short
            'shorttkn', // 9 characters - too short
          ];

          final expectedUser = User(
            id: 'user-123',
            email: 'test@example.com',
            name: 'Test User',
            createdAt: testDateTime,
            updatedAt: testDateTime,
            preferredLanguage: 'en',
            timezone: 'UTC',
            hasCompletedOnboarding: true,
          );

          final expectedResult = core.AuthResult(
            user: expectedUser,
            token: 'access-token-123',
          );

          // Act & Assert
          for (final token in testTokens) {
            reset(mockAuthService);
            when(
              mockAuthService.authenticateWithMagicLink(token),
            ).thenAnswer((_) async => Result.ok(expectedResult));

            final params = VerifyMagicLinkParams(token: token);
            final result = await usecase.call(params);

            expect(result.isSuccess, isTrue);
            verify(mockAuthService.authenticateWithMagicLink(token)).called(1);
          }
        });
      },
    );

    group('Repository Failure Cases', () {
      test('should return error when token is expired', () async {
        // Arrange
        final params = VerifyMagicLinkParams(token: 'expired-token-123456789');
        final failure = ApiFailure.unauthorized();

        when(
          mockAuthService.authenticateWithMagicLink('expired-token-123456789'),
        ).thenAnswer((_) async => Result.err(failure));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, equals(failure));
      });

      test('should return error when token is invalid', () async {
        // Arrange
        final params = VerifyMagicLinkParams(token: 'invalid-token-123456789');
        final failure = ApiFailure.unauthorized();

        when(
          mockAuthService.authenticateWithMagicLink('invalid-token-123456789'),
        ).thenAnswer((_) async => Result.err(failure));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, equals(failure));
      });

      test('should return error when token has already been used', () async {
        // Arrange
        final params = VerifyMagicLinkParams(token: 'used-token-123456789');
        final failure = ApiFailure.badRequest(
          message: 'Magic link token has already been used',
        );

        when(
          mockAuthService.authenticateWithMagicLink('used-token-123456789'),
        ).thenAnswer((_) async => Result.err(failure));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, equals(failure));
      });

      test('should handle network errors gracefully', () async {
        // Arrange
        final params = VerifyMagicLinkParams(token: 'valid-token-123456789');
        final failure = ApiFailure.network(message: 'No internet connection');

        when(
          mockAuthService.authenticateWithMagicLink('valid-token-123456789'),
        ).thenAnswer((_) async => Result.err(failure));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, equals(failure));
      });

      test('should handle server errors gracefully', () async {
        // Arrange
        final params = VerifyMagicLinkParams(token: 'valid-token-123456789');
        final failure = ApiFailure.serverError(
          message: 'Authentication service unavailable',
        );

        when(
          mockAuthService.authenticateWithMagicLink('valid-token-123456789'),
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
        'should pass token unchanged to repository after validation',
        () async {
          // Arrange
          final params = VerifyMagicLinkParams(
            token: 'business-token-123456789',
          );

          final mockUser = User(
            id: 'user-456',
            email: 'business@example.com',
            name: 'Business User',
            createdAt: testDateTime,
            updatedAt: testDateTime,
            preferredLanguage: 'en',
            timezone: 'UTC',
            role: UserRole.admin,
            hasCompletedOnboarding: true,
            isBiometricEnabled: true,
          );

          final mockResult = core.AuthResult(
            user: mockUser,
            token: 'business-access-token',
          );

          when(
            mockAuthService.authenticateWithMagicLink(
              'business-token-123456789',
            ),
          ).thenAnswer((_) async => Result.ok(mockResult));

          // Act
          await usecase.call(params);

          // Assert
          verify(
            mockAuthService.authenticateWithMagicLink(
              'business-token-123456789',
            ),
          ).called(1);
          verifyNoMoreInteractions(mockAuthService);
        },
      );

      test('should handle concurrent token verifications correctly', () async {
        // Arrange
        final params1 = VerifyMagicLinkParams(token: 'token1-123456789');
        final params2 = VerifyMagicLinkParams(token: 'token2-987654321');

        final user1 = User(
          id: 'user-1',
          email: 'user1@example.com',
          name: 'User 1',
          createdAt: testDateTime,
          updatedAt: testDateTime,
          preferredLanguage: 'en',
          timezone: 'UTC',
          // hasCompletedOnboarding defaults to false
        );

        final user2 = User(
          id: 'user-2',
          email: 'user2@example.com',
          name: 'User 2',
          createdAt: testDateTime,
          updatedAt: testDateTime,
          preferredLanguage: 'es',
          timezone: 'PST',
          hasCompletedOnboarding: true,
          accessibilityPreferences: const AccessibilityPreferences(
            highContrast: true,
          ),
          isBiometricEnabled: true,
        );

        final result1 = core.AuthResult(user: user1, token: 'access1');

        final result2 = core.AuthResult(user: user2, token: 'access2');

        when(
          mockAuthService.authenticateWithMagicLink('token1-123456789'),
        ).thenAnswer((_) async => Result.ok(result1));
        when(
          mockAuthService.authenticateWithMagicLink('token2-987654321'),
        ).thenAnswer((_) async => Result.ok(result2));

        // Act
        final results = await Future.wait([
          usecase.call(params1),
          usecase.call(params2),
        ]);

        // Assert
        expect(results[0].value, equals(result1));
        expect(results[1].value, equals(result2));

        verify(
          mockAuthService.authenticateWithMagicLink('token1-123456789'),
        ).called(1);
        verify(
          mockAuthService.authenticateWithMagicLink('token2-987654321'),
        ).called(1);
      });
    });

    group('Edge Cases', () {
      test('should handle very long tokens correctly', () async {
        // Arrange
        final longToken = 'a' * 1000;
        final params = VerifyMagicLinkParams(token: longToken);

        final mockUser = User(
          id: 'user-long',
          email: 'long@example.com',
          name: 'Long Token User',
          createdAt: testDateTime,
          updatedAt: testDateTime,
          preferredLanguage: 'en',
          timezone: 'UTC',
          hasCompletedOnboarding: true,
        );

        final mockResult = core.AuthResult(
          user: mockUser,
          token: 'long-access-token',
        );

        when(
          mockAuthService.authenticateWithMagicLink(longToken),
        ).thenAnswer((_) async => Result.ok(mockResult));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.value, equals(mockResult));
        verify(mockAuthService.authenticateWithMagicLink(longToken)).called(1);
      });

      test('should handle tokens with special characters', () async {
        // Arrange
        const specialToken =
            'token-with-special!@#\$%^&*()_+={}[]|\\:";\'<>?,./';
        final params = VerifyMagicLinkParams(token: specialToken);

        final mockUser = User(
          id: 'user-special',
          email: 'special@example.com',
          name: 'Special Token User',
          createdAt: testDateTime,
          updatedAt: testDateTime,
          preferredLanguage: 'en',
          timezone: 'UTC',
          hasCompletedOnboarding: true,
        );

        final mockResult = core.AuthResult(
          user: mockUser,
          token: 'special-access-token',
        );

        when(
          mockAuthService.authenticateWithMagicLink(specialToken),
        ).thenAnswer((_) async => Result.ok(mockResult));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.value, equals(mockResult));
        verify(
          mockAuthService.authenticateWithMagicLink(specialToken),
        ).called(1);
      });
    });

    group('Error Recovery', () {
      test('should handle timeout scenarios gracefully', () async {
        // Arrange
        final params = VerifyMagicLinkParams(token: 'timeout-token-123456789');
        final failure = ApiFailure.timeout();

        when(
          mockAuthService.authenticateWithMagicLink('timeout-token-123456789'),
        ).thenAnswer((_) async => Result.err(failure));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, equals(failure));
      });

      test('should handle repository exceptions gracefully', () async {
        // Arrange
        final params = VerifyMagicLinkParams(
          token: 'exception-token-123456789',
        );

        when(
          mockAuthService.authenticateWithMagicLink(
            'exception-token-123456789',
          ),
        ).thenThrow(Exception('Unexpected database error'));

        // Act & Assert
        expect(() => usecase.call(params), throwsA(isA<Exception>()));
      });
    });
  });
}
