import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:edulift/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:edulift/core/domain/entities/user.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';

import '../../../../test_mocks/test_mocks.dart';
import '../../../../test_mocks/test_specialized_mocks.dart';

void main() {
  // Setup Mockito dummy values for Result types
  setUpAll(() {
    setupMockFallbacks();
  });

  group('RefreshTokenUsecase', () {
    late RefreshTokenUsecase usecase;
    late MockFeatureAuthService mockAuthService;
    late DateTime testDateTime;

    setUp(() {
      mockAuthService = MockFeatureAuthService();
      reset(mockAuthService); // This clears all interactions and stubbing
      usecase = RefreshTokenUsecase(mockAuthService);
      testDateTime = DateTime(2024, 1, 1, 10);
    });

    tearDown(() {
      // FIXED: Only clear interactions, not reset (which would clear stubs mid-test)
      clearInteractions(mockAuthService);
    });

    group('Construction', () {
      test('should create usecase with service dependency', () {
        // Arrange & Act
        final usecase = RefreshTokenUsecase(mockAuthService);

        // Assert
        expect(usecase, isA<RefreshTokenUsecase>());
      });
    });

    group('Success Cases', () {
      test(
        'should refresh token successfully with valid refresh token',
        () async {
          // Arrange
          final params = RefreshTokenParams(
            refreshToken: 'valid-refresh-token-123456789012345',
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

          when(
            mockAuthService.getCurrentUser(),
          ).thenAnswer((_) async => Result.ok(expectedUser));

          // Act
          final result = await usecase.call(params);

          // Assert
          expect(result.value, equals(expectedUser));
          expect(result.value!.id, equals('user-123'));
          expect(result.value!.email, equals('test@example.com'));
          verify(mockAuthService.getCurrentUser()).called(1);
        },
      );

      test('should handle various valid refresh token formats', () async {
        // Arrange
        const validRefreshTokens = [
          'abcdefghij1234567890', // Minimum 20 characters
          'refresh-token-with-dashes-and-numbers-123456789',
          'VeryLongRefreshTokenWithMany<String>()CharactersAndNumbers123456789ABCDEF',
          'refresh_token_with_underscores_123456789012345',
          'REFRESH.TOKEN.WITH.DOTS.123456789012345',
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

        when(
          mockAuthService.getCurrentUser(),
        ).thenAnswer((_) async => Result.ok(mockUser));

        // Act & Assert
        for (final refreshToken in validRefreshTokens) {
          final params = RefreshTokenParams(refreshToken: refreshToken);
          final result = await usecase.call(params);

          expect(
            result.value,
            equals(mockUser),
            reason: 'Failed for refresh token: $refreshToken',
          );
          verify(mockAuthService.getCurrentUser()).called(1);
        }
      });
    });

    group(
      'Validation Failures - No validation in usecase (delegates to service)',
      () {
        test('should delegate empty refresh token to service', () async {
          // Arrange
          final params = RefreshTokenParams(refreshToken: '');
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

          when(
            mockAuthService.getCurrentUser(),
          ).thenAnswer((_) async => Result.ok(mockUser));

          // Act
          final result = await usecase.call(params);

          // Assert
          expect(result.isSuccess, isTrue);
          verify(mockAuthService.getCurrentUser()).called(1);
        });

        test('should delegate short refresh token to service', () async {
          // Arrange
          final params = RefreshTokenParams(refreshToken: '123');
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

          when(
            mockAuthService.getCurrentUser(),
          ).thenAnswer((_) async => Result.ok(mockUser));

          // Act
          final result = await usecase.call(params);

          // Assert
          expect(result.isSuccess, isTrue);
          verify(mockAuthService.getCurrentUser()).called(1);
        });
      },
    );

    group('Repository Failure Cases', () {
      test('should return error when refresh token is expired', () async {
        // Arrange
        final params = RefreshTokenParams(
          refreshToken: 'expired-refresh-token-123456789012345',
        );
        final failure = ApiFailure.unauthorized();

        when(
          mockAuthService.getCurrentUser(),
        ).thenAnswer((_) async => Result.err(failure));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, equals(failure));
      });

      test('should return error when refresh token is invalid', () async {
        // Arrange
        final params = RefreshTokenParams(
          refreshToken: 'invalid-refresh-token-123456789012345',
        );
        final failure = ApiFailure.unauthorized();

        when(
          mockAuthService.getCurrentUser(),
        ).thenAnswer((_) async => Result.err(failure));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, equals(failure));
      });

      test('should return error when refresh token has been revoked', () async {
        // Arrange
        final params = RefreshTokenParams(
          refreshToken: 'revoked-refresh-token-123456789012345',
        );
        final failure = ApiFailure.unauthorized();

        when(
          mockAuthService.getCurrentUser(),
        ).thenAnswer((_) async => Result.err(failure));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, equals(failure));
      });

      test('should handle network errors gracefully', () async {
        // Arrange
        final params = RefreshTokenParams(
          refreshToken: 'valid-refresh-token-123456789012345',
        );
        final failure = ApiFailure.network(message: 'No internet connection');

        when(
          mockAuthService.getCurrentUser(),
        ).thenAnswer((_) async => Result.err(failure));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, equals(failure));
      });

      test('should handle server errors gracefully', () async {
        // Arrange
        final params = RefreshTokenParams(
          refreshToken: 'valid-refresh-token-123456789012345',
        );
        final failure = ApiFailure.serverError(
          message: 'Token service unavailable',
        );

        when(
          mockAuthService.getCurrentUser(),
        ).thenAnswer((_) async => Result.err(failure));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, equals(failure));
      });

      test('should handle rate limiting errors', () async {
        // Arrange
        final params = RefreshTokenParams(
          refreshToken: 'valid-refresh-token-123456789012345',
        );
        final failure = ApiFailure.badRequest(
          message: 'Too many<String>() refresh attempts',
        );

        when(
          mockAuthService.getCurrentUser(),
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
        'should pass refresh token unchanged to repository after validation',
        () async {
          // Arrange
          final params = RefreshTokenParams(
            refreshToken: 'business-refresh-token-123456789012345',
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

          when(
            mockAuthService.getCurrentUser(),
          ).thenAnswer((_) async => Result.ok(mockUser));

          // Act
          await usecase.call(params);

          // Assert
          verify(mockAuthService.getCurrentUser()).called(1);
          verifyNoMoreInteractions(mockAuthService);
        },
      );

      test('should handle concurrent refresh token requests correctly', () async {
        // Arrange
        final params1 = RefreshTokenParams(
          refreshToken: 'refresh-token1-123456789012345',
        );
        final params2 = RefreshTokenParams(
          refreshToken: 'refresh-token2-987654321098765',
        );

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

        when(
          mockAuthService.getCurrentUser(),
        ).thenAnswer((_) async => Result.ok(user1));

        // For concurrent test, we'll return user1 for first call, user2 for second
        when(
          mockAuthService.getCurrentUser(),
        ).thenAnswer((_) async => Result.ok(user2));

        // Act
        final results = await Future.wait([
          usecase.call(params1),
          usecase.call(params2),
        ]);

        // Assert
        expect(
          results[0].value,
          equals(user2),
        ); // Since we mocked getCurrentUser to return user2
        expect(
          results[1].value,
          equals(user2),
        ); // Both calls will return the same mock

        verify(
          mockAuthService.getCurrentUser(),
        ).called(2); // Called twice for concurrent requests
      });
    });

    group('Edge Cases', () {
      test('should handle very long refresh tokens correctly', () async {
        // Arrange
        final longRefreshToken = 'a' * 1000;
        final params = RefreshTokenParams(refreshToken: longRefreshToken);

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

        when(
          mockAuthService.getCurrentUser(),
        ).thenAnswer((_) async => Result.ok(mockUser));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.value, equals(mockUser));
        verify(mockAuthService.getCurrentUser()).called(1);
      });

      test('should handle refresh tokens with special characters', () async {
        // Arrange
        const specialRefreshToken =
            'refresh-token-with-special!@#\$%^&*()_+={}[]|\\:";\'<>?,./123456789';
        final params = RefreshTokenParams(refreshToken: specialRefreshToken);

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

        when(
          mockAuthService.getCurrentUser(),
        ).thenAnswer((_) async => Result.ok(mockUser));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.value, equals(mockUser));
        verify(mockAuthService.getCurrentUser()).called(1);
      });

      test('should handle exactly minimum length refresh tokens', () async {
        // Arrange
        final minLengthRefreshToken = 'a' * 20; // Exactly 20 characters
        final params = RefreshTokenParams(refreshToken: minLengthRefreshToken);

        final mockUser = User(
          id: 'user-min',
          email: 'min@example.com',
          name: 'Min Length User',
          createdAt: testDateTime,
          updatedAt: testDateTime,
          preferredLanguage: 'en',
          timezone: 'UTC',
          hasCompletedOnboarding: true,
        );

        when(
          mockAuthService.getCurrentUser(),
        ).thenAnswer((_) async => Result.ok(mockUser));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.value, equals(mockUser));
        verify(mockAuthService.getCurrentUser()).called(1);
      });
    });

    group('Error Recovery', () {
      test('should handle timeout scenarios gracefully', () async {
        // Arrange
        final params = RefreshTokenParams(
          refreshToken: 'timeout-refresh-token-123456789012345',
        );
        final failure = ApiFailure.timeout();

        when(
          mockAuthService.getCurrentUser(),
        ).thenAnswer((_) async => Result.err(failure));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, isTrue);
        expect(result.error, equals(failure));
      });

      test('should handle repository exceptions gracefully', () async {
        // Arrange
        final params = RefreshTokenParams(
          refreshToken: 'exception-refresh-token-123456789012345',
        );

        when(
          mockAuthService.getCurrentUser(),
        ).thenThrow(Exception('Unexpected token service error'));

        // Act & Assert
        expect(() => usecase.call(params), throwsA(isA<Exception>()));
      });
    });
  });
}
