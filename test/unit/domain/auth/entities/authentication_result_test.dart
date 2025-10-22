import 'package:test/test.dart';
import 'package:edulift/features/auth/domain/repositories/auth_repository.dart';
import 'package:edulift/core/domain/entities/user.dart';

import '../../../../test_mocks/test_mocks.dart';

void main() {
  // Setup Mockito dummy values for Result types
  setUpAll(() {
    setupMockFallbacks();
  });

  group('AuthenticationResult', () {
    late DateTime testDateTime;
    late User testUser;

    setUp(() {
      testDateTime = DateTime(2024, 1, 1, 10);
      testUser = User(
        id: 'user-123',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: testDateTime,
        updatedAt: testDateTime,
        preferredLanguage: 'en',
        timezone: 'UTC',
        hasCompletedOnboarding: true,
      );
    });

    group('Construction', () {
      test('should create AuthenticationResult with all required fields', () {
        // Arrange
        final expiresAt = testDateTime.add(const Duration(hours: 1));

        // Act
        final result = AuthenticationResult(
          accessToken: 'access-token-123',
          refreshToken: 'refresh-token-456',
          user: testUser,
          expiresAt: expiresAt,
        );

        // Assert
        expect(result.accessToken, equals('access-token-123'));
        expect(result.refreshToken, equals('refresh-token-456'));
        expect(result.user, equals(testUser));
        expect(result.expiresAt, equals(expiresAt));
      });

      test('should create AuthenticationResult with minimal valid tokens', () {
        // Arrange
        final expiresAt = testDateTime.add(const Duration(minutes: 5));

        // Act
        final result = AuthenticationResult(
          accessToken: 'a',
          refreshToken: 'r',
          user: testUser,
          expiresAt: expiresAt,
        );

        // Assert
        expect(result.accessToken, equals('a'));
        expect(result.refreshToken, equals('r'));
        expect(result.user, equals(testUser));
        expect(result.expiresAt, equals(expiresAt));
      });

      test('should create AuthenticationResult with long tokens', () {
        // Arrange
        final longAccessToken = 'a' * 1000;
        final longRefreshToken = 'r' * 1000;
        final expiresAt = testDateTime.add(const Duration(days: 1));

        // Act
        final result = AuthenticationResult(
          accessToken: longAccessToken,
          refreshToken: longRefreshToken,
          user: testUser,
          expiresAt: expiresAt,
        );

        // Assert
        expect(result.accessToken, equals(longAccessToken));
        expect(result.refreshToken, equals(longRefreshToken));
        expect(result.user, equals(testUser));
        expect(result.expiresAt, equals(expiresAt));
      });
    });

    group('Equality', () {
      test('should be equal when all properties are the same', () {
        // Arrange
        final expiresAt = testDateTime.add(const Duration(hours: 1));

        final result1 = AuthenticationResult(
          accessToken: 'access-token-123',
          refreshToken: 'refresh-token-456',
          user: testUser,
          expiresAt: expiresAt,
        );

        final result2 = AuthenticationResult(
          accessToken: 'access-token-123',
          refreshToken: 'refresh-token-456',
          user: testUser,
          expiresAt: expiresAt,
        );

        // Act & Assert
        expect(result1, equals(result2));
        expect(result1.hashCode, equals(result2.hashCode));
      });

      test('should not be equal when access tokens differ', () {
        // Arrange
        final expiresAt = testDateTime.add(const Duration(hours: 1));

        final result1 = AuthenticationResult(
          accessToken: 'access-token-123',
          refreshToken: 'refresh-token-456',
          user: testUser,
          expiresAt: expiresAt,
        );

        final result2 = AuthenticationResult(
          accessToken: 'different-access-token',
          refreshToken: 'refresh-token-456',
          user: testUser,
          expiresAt: expiresAt,
        );

        // Act & Assert
        expect(result1, isNot(equals(result2)));
        expect(result1.hashCode, isNot(equals(result2.hashCode)));
      });

      test('should not be equal when refresh tokens differ', () {
        // Arrange
        final expiresAt = testDateTime.add(const Duration(hours: 1));

        final result1 = AuthenticationResult(
          accessToken: 'access-token-123',
          refreshToken: 'refresh-token-456',
          user: testUser,
          expiresAt: expiresAt,
        );

        final result2 = AuthenticationResult(
          accessToken: 'access-token-123',
          refreshToken: 'different-refresh-token',
          user: testUser,
          expiresAt: expiresAt,
        );

        // Act & Assert
        expect(result1, isNot(equals(result2)));
        expect(result1.hashCode, isNot(equals(result2.hashCode)));
      });

      test('should not be equal when users differ', () {
        // Arrange
        final expiresAt = testDateTime.add(const Duration(hours: 1));
        final differentUser = testUser.copyWith(id: 'different-user-id');

        final result1 = AuthenticationResult(
          accessToken: 'access-token-123',
          refreshToken: 'refresh-token-456',
          user: testUser,
          expiresAt: expiresAt,
        );

        final result2 = AuthenticationResult(
          accessToken: 'access-token-123',
          refreshToken: 'refresh-token-456',
          user: differentUser,
          expiresAt: expiresAt,
        );

        // Act & Assert
        expect(result1, isNot(equals(result2)));
        expect(result1.hashCode, isNot(equals(result2.hashCode)));
      });

      test('should not be equal when expiry dates differ', () {
        // Arrange
        final expiresAt1 = testDateTime.add(const Duration(hours: 1));
        final expiresAt2 = testDateTime.add(const Duration(hours: 2));

        final result1 = AuthenticationResult(
          accessToken: 'access-token-123',
          refreshToken: 'refresh-token-456',
          user: testUser,
          expiresAt: expiresAt1,
        );

        final result2 = AuthenticationResult(
          accessToken: 'access-token-123',
          refreshToken: 'refresh-token-456',
          user: testUser,
          expiresAt: expiresAt2,
        );

        // Act & Assert
        expect(result1, isNot(equals(result2)));
        expect(result1.hashCode, isNot(equals(result2.hashCode)));
      });
    });

    group('Business Logic Validation', () {
      test('should handle different user roles correctly', () {
        // Arrange
        final adminUser = testUser.copyWith(role: UserRole.admin);
        final expiresAt = testDateTime.add(const Duration(hours: 8));

        // Act
        final result = AuthenticationResult(
          accessToken: 'admin-access-token',
          refreshToken: 'admin-refresh-token',
          user: adminUser,
          expiresAt: expiresAt,
        );

        // Assert
        expect(result.user.role, equals(UserRole.admin));
        expect(result.user.isAdmin, isTrue);
      });

      test('should handle biometric-enabled users correctly', () {
        // Arrange
        final biometricUser = testUser.copyWith(isBiometricEnabled: true);
        final expiresAt = testDateTime.add(const Duration(hours: 1));

        // Act
        final result = AuthenticationResult(
          accessToken: 'biometric-access-token',
          refreshToken: 'biometric-refresh-token',
          user: biometricUser,
          expiresAt: expiresAt,
        );

        // Assert
        expect(result.user.isBiometricEnabled, isTrue);
      });

      test('should handle users with accessibility preferences', () {
        // Arrange
        final accessibilityUser = testUser.copyWith(
          accessibilityPreferences: const AccessibilityPreferences(
            highContrast: true,
            textScaleFactor: 1.5,
            largeTouchTargets: true,
          ),
        );
        final expiresAt = testDateTime.add(const Duration(hours: 1));

        // Act
        final result = AuthenticationResult(
          accessToken: 'accessible-access-token',
          refreshToken: 'accessible-refresh-token',
          user: accessibilityUser,
          expiresAt: expiresAt,
        );

        // Assert
        expect(
          result.user.accessibilityPreferences.hasAccessibilityFeatures,
          isTrue,
        );
        expect(result.user.accessibilityPreferences.highContrast, isTrue);
        expect(
          result.user.accessibilityPreferences.textScaleFactor,
          equals(1.5),
        );
      });

      test('should handle users in different timezones', () {
        // Arrange
        final internationalUser = testUser.copyWith(
          timezone: 'Asia/Tokyo',
          preferredLanguage: 'ja',
        );
        final expiresAt = testDateTime.add(const Duration(hours: 1));

        // Act
        final result = AuthenticationResult(
          accessToken: 'international-access-token',
          refreshToken: 'international-refresh-token',
          user: internationalUser,
          expiresAt: expiresAt,
        );

        // Assert
        expect(result.user.timezone, equals('Asia/Tokyo'));
        expect(result.user.preferredLanguage, equals('ja'));
      });
    });

    group('Edge Cases', () {
      test('should handle empty token strings', () {
        // Arrange
        final expiresAt = testDateTime.add(const Duration(hours: 1));

        // Act
        final result = AuthenticationResult(
          accessToken: '',
          refreshToken: '',
          user: testUser,
          expiresAt: expiresAt,
        );

        // Assert
        expect(result.accessToken, equals(''));
        expect(result.refreshToken, equals(''));
      });

      test('should handle past expiry dates', () {
        // Arrange
        final pastExpiresAt = testDateTime.subtract(const Duration(hours: 1));

        // Act
        final result = AuthenticationResult(
          accessToken: 'expired-access-token',
          refreshToken: 'expired-refresh-token',
          user: testUser,
          expiresAt: pastExpiresAt,
        );

        // Assert
        expect(result.expiresAt, equals(pastExpiresAt));
        expect(result.expiresAt.isBefore(testDateTime), isTrue);
      });

      test('should handle very far future expiry dates', () {
        // Arrange
        final farFutureExpiresAt = testDateTime.add(
          const Duration(days: 365 * 10),
        );

        // Act
        final result = AuthenticationResult(
          accessToken: 'long-lived-access-token',
          refreshToken: 'long-lived-refresh-token',
          user: testUser,
          expiresAt: farFutureExpiresAt,
        );

        // Assert
        expect(result.expiresAt, equals(farFutureExpiresAt));
        expect(
          result.expiresAt.isAfter(testDateTime.add(const Duration(days: 365))),
          isTrue,
        );
      });

      test('should handle tokens with special characters', () {
        // Arrange
        const specialAccessToken =
            'access-token-with-special!@#\$%^&*()_+={}[]|\\:";\'<>?,./';
        const specialRefreshToken =
            'refresh-token-with-special!@#\$%^&*()_+={}[]|\\:";\'<>?,./';
        final expiresAt = testDateTime.add(const Duration(hours: 1));

        // Act
        final result = AuthenticationResult(
          accessToken: specialAccessToken,
          refreshToken: specialRefreshToken,
          user: testUser,
          expiresAt: expiresAt,
        );

        // Assert
        expect(result.accessToken, equals(specialAccessToken));
        expect(result.refreshToken, equals(specialRefreshToken));
      });

      test('should handle users with minimal fields', () {
        // Arrange
        final minimalUser = User(
          id: 'minimal-id',
          email: 'minimal@example.com',
          name: 'Min',
          createdAt: testDateTime,
          updatedAt: testDateTime,
          // All other fields use defaults
        );
        final expiresAt = testDateTime.add(const Duration(hours: 1));

        // Act
        final result = AuthenticationResult(
          accessToken: 'minimal-access-token',
          refreshToken: 'minimal-refresh-token',
          user: minimalUser,
          expiresAt: expiresAt,
        );

        // Assert
        expect(result.user.hasCompletedOnboarding, isFalse);
        expect(result.user.isBiometricEnabled, isFalse);
        expect(result.user.role, equals(UserRole.user));
        expect(
          result.user.accessibilityPreferences.hasAccessibilityFeatures,
          isFalse,
        );
      });
    });

    group('Token Security Validation', () {
      test('should handle tokens with different formats', () {
        // Arrange
        const formats = [
          'jwt.header.payload.signature',
          'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9',
          'simple-token-12345',
          'UUID-like-token-12345678-1234-1234-1234-123456789012',
          'Base64Token==',
        ];
        final expiresAt = testDateTime.add(const Duration(hours: 1));

        for (var i = 0; i < formats.length; i++) {
          // Act
          final result = AuthenticationResult(
            accessToken: formats[i],
            refreshToken: 'refresh-${formats[i]}',
            user: testUser,
            expiresAt: expiresAt,
          );

          // Assert
          expect(result.accessToken, equals(formats[i]));
          expect(result.refreshToken, equals('refresh-${formats[i]}'));
        }
      });

      test('should handle concurrent authentication results', () {
        // Arrange
        final user1 = testUser.copyWith(id: 'user-1');
        final user2 = testUser.copyWith(id: 'user-2');
        final expiresAt = testDateTime.add(const Duration(hours: 1));

        // Act
        final result1 = AuthenticationResult(
          accessToken: 'access-token-user-1',
          refreshToken: 'refresh-token-user-1',
          user: user1,
          expiresAt: expiresAt,
        );

        final result2 = AuthenticationResult(
          accessToken: 'access-token-user-2',
          refreshToken: 'refresh-token-user-2',
          user: user2,
          expiresAt: expiresAt,
        );

        // Assert
        expect(result1.user.id, equals('user-1'));
        expect(result2.user.id, equals('user-2'));
        expect(result1.accessToken, equals('access-token-user-1'));
        expect(result2.accessToken, equals('access-token-user-2'));
        expect(result1, isNot(equals(result2)));
      });
    });
  });
}
