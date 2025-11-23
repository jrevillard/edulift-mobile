import 'package:edulift/core/constants/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:edulift/core/services/secure_token_storage.dart';
import 'package:edulift/core/security/tiered_storage_service.dart';

import '../../../../test_mocks/test_mocks.mocks.dart';

/// COMPREHENSIVE SECURE TOKEN STORAGE TEST SUITE
///
/// Following FLUTTER_TESTING_RESEARCH_2025.md standards:
/// - Tests ONLY functionality that actually exists in SecureTokenStorage
/// - Focuses on proper error handling and exception scenarios
/// - Validates secure storage interaction patterns
/// - Tests all public methods with success and failure scenarios
/// - Maintains 90%+ coverage target for infrastructure layer
/// - Uses proper mocking of AdaptiveSecureStorage dependency
///
/// CRITICAL FOCUS AREAS:
/// - Token storage and retrieval cycle integrity
/// - Error handling and exception propagation
/// - Proper logging behavior verification
/// - Edge cases with null, empty, and malformed tokens
/// - AdaptiveSecureStorage interaction consistency
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecureTokenStorage - Comprehensive Test Suite', () {
    late SecureTokenStorage tokenStorage;
    late MockTieredStorageService mockSecureStorage;

    // Test data - realistic token patterns
    const validJwtToken =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';
    const shortToken = 'abc123';
    const emptyToken = '';
    final longToken = 'very_long_token_' + 'x' * 1000;
    const tokenWithSpecialChars = 'token.with-special_chars+and/symbols=';
    // Use the same logic as SecureTokenStorage implementation
    const authTokenKey = kDebugMode
        ? '${AppConstants.tokenKey}_dev'
        : AppConstants.tokenKey;

    setUp(() {
      mockSecureStorage = MockTieredStorageService();
      tokenStorage = SecureTokenStorage(mockSecureStorage);

      // Reset mock interactions
      reset(mockSecureStorage);
    });

    group('storeToken() - Token Storage Operations', () {
      test('should store valid JWT token successfully', () async {
        // ARRANGE
        when(
          mockSecureStorage.store(
            authTokenKey,
            validJwtToken,
            DataSensitivity.medium,
          ),
        ).thenAnswer((_) async {});

        // ACT
        await tokenStorage.storeToken(validJwtToken);

        // ASSERT
        verify(
          mockSecureStorage.store(
            authTokenKey,
            validJwtToken,
            DataSensitivity.medium,
          ),
        ).called(1);
      });

      test('should store short token successfully', () async {
        // ARRANGE
        when(
          mockSecureStorage.store(
            authTokenKey,
            shortToken,
            DataSensitivity.medium,
          ),
        ).thenAnswer((_) async {});

        // ACT
        await tokenStorage.storeToken(shortToken);

        // ASSERT
        verify(
          mockSecureStorage.store(
            authTokenKey,
            shortToken,
            DataSensitivity.medium,
          ),
        ).called(1);
      });

      test('should store empty token without error', () async {
        // ARRANGE
        when(
          mockSecureStorage.store(
            authTokenKey,
            emptyToken,
            DataSensitivity.medium,
          ),
        ).thenAnswer((_) async {});

        // ACT
        await tokenStorage.storeToken(emptyToken);

        // ASSERT
        verify(
          mockSecureStorage.store(
            authTokenKey,
            emptyToken,
            DataSensitivity.medium,
          ),
        ).called(1);
      });

      test('should store long token successfully', () async {
        // ARRANGE
        when(
          mockSecureStorage.store(
            authTokenKey,
            longToken,
            DataSensitivity.medium,
          ),
        ).thenAnswer((_) async {});

        // ACT
        await tokenStorage.storeToken(longToken);

        // ASSERT
        verify(
          mockSecureStorage.store(
            authTokenKey,
            longToken,
            DataSensitivity.medium,
          ),
        ).called(1);
      });

      test('should store token with special characters', () async {
        // ARRANGE
        when(
          mockSecureStorage.store(
            authTokenKey,
            tokenWithSpecialChars,
            DataSensitivity.medium,
          ),
        ).thenAnswer((_) async {});

        // ACT
        await tokenStorage.storeToken(tokenWithSpecialChars);

        // ASSERT
        verify(
          mockSecureStorage.store(
            authTokenKey,
            tokenWithSpecialChars,
            DataSensitivity.medium,
          ),
        ).called(1);
      });

      test('should throw Exception when storage write fails', () async {
        // ARRANGE
        const errorMessage = 'Storage write failed';
        when(
          mockSecureStorage.store(
            authTokenKey,
            validJwtToken,
            DataSensitivity.medium,
          ),
        ).thenThrow(Exception(errorMessage));

        // ACT & ASSERT
        expect(
          () async => await tokenStorage.storeToken(validJwtToken),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to store authentication token'),
            ),
          ),
        );

        verify(
          mockSecureStorage.store(
            authTokenKey,
            validJwtToken,
            DataSensitivity.medium,
          ),
        ).called(1);
      });

      test('should handle storage timeout gracefully', () async {
        // ARRANGE
        when(
          mockSecureStorage.store(
            authTokenKey,
            validJwtToken,
            DataSensitivity.medium,
          ),
        ).thenThrow(
          TimeoutException(
            'Storage operation timed out',
            const Duration(seconds: 5),
          ),
        );

        // ACT & ASSERT
        expect(
          () async => await tokenStorage.storeToken(validJwtToken),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to store authentication token'),
            ),
          ),
        );
      });
    });

    group('getToken() - Token Retrieval Operations', () {
      test('should retrieve stored JWT token successfully', () async {
        // ARRANGE
        when(
          mockSecureStorage.read(authTokenKey, DataSensitivity.medium),
        ).thenAnswer((_) async => validJwtToken);

        // ACT
        final result = await tokenStorage.getToken();

        // ASSERT
        expect(result, equals(validJwtToken));
        verify(
          mockSecureStorage.read(authTokenKey, DataSensitivity.medium),
        ).called(1);
      });

      test('should return null when no token is stored', () async {
        // ARRANGE
        when(
          mockSecureStorage.read(authTokenKey, DataSensitivity.medium),
        ).thenAnswer((_) async => null);

        // ACT
        final result = await tokenStorage.getToken();

        // ASSERT
        expect(result, isNull);
        verify(
          mockSecureStorage.read(authTokenKey, DataSensitivity.medium),
        ).called(1);
      });

      test('should return empty string when empty token is stored', () async {
        // ARRANGE
        when(
          mockSecureStorage.read(authTokenKey, DataSensitivity.medium),
        ).thenAnswer((_) async => emptyToken);

        // ACT
        final result = await tokenStorage.getToken();

        // ASSERT
        expect(result, equals(emptyToken));
        verify(
          mockSecureStorage.read(authTokenKey, DataSensitivity.medium),
        ).called(1);
      });

      test('should retrieve long token successfully', () async {
        // ARRANGE
        when(
          mockSecureStorage.read(authTokenKey, DataSensitivity.medium),
        ).thenAnswer((_) async => longToken);

        // ACT
        final result = await tokenStorage.getToken();

        // ASSERT
        expect(result, equals(longToken));
        verify(
          mockSecureStorage.read(authTokenKey, DataSensitivity.medium),
        ).called(1);
      });

      test('should return null when storage read fails', () async {
        // ARRANGE
        when(
          mockSecureStorage.read(authTokenKey, DataSensitivity.medium),
        ).thenThrow(Exception('Storage read failed'));

        // ACT
        final result = await tokenStorage.getToken();

        // ASSERT
        expect(result, isNull);
        verify(
          mockSecureStorage.read(authTokenKey, DataSensitivity.medium),
        ).called(1);
      });

      test('should handle storage corruption gracefully', () async {
        // ARRANGE
        when(
          mockSecureStorage.read(authTokenKey, DataSensitivity.medium),
        ).thenThrow(const FormatException('Corrupted storage data'));

        // ACT
        final result = await tokenStorage.getToken();

        // ASSERT
        expect(result, isNull);
        verify(
          mockSecureStorage.read(authTokenKey, DataSensitivity.medium),
        ).called(1);
      });

      test('should handle concurrent read operations', () async {
        // ARRANGE
        when(
          mockSecureStorage.read(authTokenKey, DataSensitivity.medium),
        ).thenAnswer((_) async {
          // Simulate some processing delay
          await Future.delayed(const Duration(milliseconds: 10));
          return validJwtToken;
        });

        // ACT - Multiple concurrent reads
        final futures = List.generate(5, (_) => tokenStorage.getToken());
        final results = await Future.wait(futures);

        // ASSERT
        expect(results, hasLength(5));
        expect(results, everyElement(equals(validJwtToken)));
        verify(
          mockSecureStorage.read(authTokenKey, DataSensitivity.medium),
        ).called(5);
      });
    });

    group('clearToken() - Token Removal Operations', () {
      test('should clear stored token successfully', () async {
        // ARRANGE
        when(
          mockSecureStorage.delete(authTokenKey, DataSensitivity.medium),
        ).thenAnswer((_) async {});

        // ACT
        await tokenStorage.clearToken();

        // ASSERT
        verify(
          mockSecureStorage.delete(authTokenKey, DataSensitivity.medium),
        ).called(1);
      });

      test('should handle clearing non-existent token gracefully', () async {
        // ARRANGE
        when(
          mockSecureStorage.delete(authTokenKey, DataSensitivity.medium),
        ).thenAnswer((_) async {});

        // ACT
        await tokenStorage.clearToken();

        // ASSERT
        verify(
          mockSecureStorage.delete(authTokenKey, DataSensitivity.medium),
        ).called(1);
      });

      test('should throw Exception when storage delete fails', () async {
        // ARRANGE
        const errorMessage = 'Storage delete failed';
        when(
          mockSecureStorage.delete(authTokenKey, DataSensitivity.medium),
        ).thenThrow(Exception(errorMessage));

        // ACT & ASSERT
        expect(
          () async => await tokenStorage.clearToken(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to clear authentication token'),
            ),
          ),
        );

        verify(
          mockSecureStorage.delete(authTokenKey, DataSensitivity.medium),
        ).called(1);
      });

      test('should handle storage permission errors', () async {
        // ARRANGE
        when(
          mockSecureStorage.delete(authTokenKey, DataSensitivity.medium),
        ).thenThrow(SecurityException('Storage access denied'));

        // ACT & ASSERT
        expect(
          () async => await tokenStorage.clearToken(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to clear authentication token'),
            ),
          ),
        );
      });

      test('should handle multiple consecutive clear operations', () async {
        // ARRANGE
        when(
          mockSecureStorage.delete(authTokenKey, DataSensitivity.medium),
        ).thenAnswer((_) async {});

        // ACT
        await tokenStorage.clearToken();
        await tokenStorage.clearToken();
        await tokenStorage.clearToken();

        // ASSERT
        verify(
          mockSecureStorage.delete(authTokenKey, DataSensitivity.medium),
        ).called(3);
      });
    });

    group('hasToken() - Token Existence Verification', () {
      test('should return true when valid token exists', () async {
        // ARRANGE
        when(
          mockSecureStorage.read(authTokenKey, DataSensitivity.medium),
        ).thenAnswer((_) async => validJwtToken);

        // ACT
        final result = await tokenStorage.hasToken();

        // ASSERT
        expect(result, isTrue);
        verify(
          mockSecureStorage.read(authTokenKey, DataSensitivity.medium),
        ).called(1);
      });

      test('should return false when no token exists', () async {
        // ARRANGE
        when(
          mockSecureStorage.read(authTokenKey, DataSensitivity.medium),
        ).thenAnswer((_) async => null);

        // ACT
        final result = await tokenStorage.hasToken();

        // ASSERT
        expect(result, isFalse);
        verify(
          mockSecureStorage.read(authTokenKey, DataSensitivity.medium),
        ).called(1);
      });

      test('should return false when empty token exists', () async {
        // ARRANGE
        when(
          mockSecureStorage.read(authTokenKey, DataSensitivity.medium),
        ).thenAnswer((_) async => emptyToken);

        // ACT
        final result = await tokenStorage.hasToken();

        // ASSERT
        expect(result, isFalse);
        verify(
          mockSecureStorage.read(authTokenKey, DataSensitivity.medium),
        ).called(1);
      });

      test('should return true when token contains only whitespace', () async {
        // ARRANGE - Note: Based on implementation, only checks isNotEmpty, not trimmed
        const whitespaceToken = '   ';
        when(
          mockSecureStorage.read(authTokenKey, DataSensitivity.medium),
        ).thenAnswer((_) async => whitespaceToken);

        // ACT
        final result = await tokenStorage.hasToken();

        // ASSERT
        expect(
          result,
          isTrue,
        ); // Implementation uses isNotEmpty, not trimmed check
        verify(
          mockSecureStorage.read(authTokenKey, DataSensitivity.medium),
        ).called(1);
      });

      test('should return false when storage read fails', () async {
        // ARRANGE
        when(
          mockSecureStorage.read(authTokenKey, DataSensitivity.medium),
        ).thenThrow(Exception('Storage read failed'));

        // ACT
        final result = await tokenStorage.hasToken();

        // ASSERT
        expect(result, isFalse);
        verify(
          mockSecureStorage.read(authTokenKey, DataSensitivity.medium),
        ).called(1);
      });

      test('should handle storage access denial gracefully', () async {
        // ARRANGE
        when(
          mockSecureStorage.read(authTokenKey, DataSensitivity.medium),
        ).thenThrow(SecurityException('Storage access denied'));

        // ACT
        final result = await tokenStorage.hasToken();

        // ASSERT
        expect(result, isFalse);
        verify(
          mockSecureStorage.read(authTokenKey, DataSensitivity.medium),
        ).called(1);
      });
    });

    group('Integration Scenarios - End-to-End Token Lifecycle', () {
      test(
        'should complete full token lifecycle: store -> check -> retrieve -> clear',
        () async {
          // ARRANGE
          when(
            mockSecureStorage.store(
              authTokenKey,
              validJwtToken,
              DataSensitivity.medium,
            ),
          ).thenAnswer((_) async {});
          when(
            mockSecureStorage.read(authTokenKey, DataSensitivity.medium),
          ).thenAnswer((_) async => validJwtToken);
          when(
            mockSecureStorage.delete(authTokenKey, DataSensitivity.medium),
          ).thenAnswer((_) async {});

          // ACT & ASSERT - Store
          await tokenStorage.storeToken(validJwtToken);
          verify(
            mockSecureStorage.store(
              authTokenKey,
              validJwtToken,
              DataSensitivity.medium,
            ),
          ).called(1);

          // ACT & ASSERT - Check existence
          final hasTokenResult = await tokenStorage.hasToken();
          expect(hasTokenResult, isTrue);

          // ACT & ASSERT - Retrieve
          final retrievedToken = await tokenStorage.getToken();
          expect(retrievedToken, equals(validJwtToken));

          // ACT & ASSERT - Clear
          await tokenStorage.clearToken();
          verify(
            mockSecureStorage.delete(authTokenKey, DataSensitivity.medium),
          ).called(1);
        },
      );

      test('should handle token replacement correctly', () async {
        // ARRANGE
        const originalToken = 'original_token_123';
        const newToken = 'new_token_456';

        when(
          mockSecureStorage.store(any, any, DataSensitivity.medium),
        ).thenAnswer((_) async {});
        when(
          mockSecureStorage.read(authTokenKey, DataSensitivity.medium),
        ).thenAnswer((_) async => newToken);

        // ACT - Store original token
        await tokenStorage.storeToken(originalToken);

        // ACT - Replace with new token
        await tokenStorage.storeToken(newToken);

        // ACT - Retrieve token
        final retrievedToken = await tokenStorage.getToken();

        // ASSERT
        expect(retrievedToken, equals(newToken));
        verify(
          mockSecureStorage.store(
            authTokenKey,
            originalToken,
            DataSensitivity.medium,
          ),
        ).called(1);
        verify(
          mockSecureStorage.store(
            authTokenKey,
            newToken,
            DataSensitivity.medium,
          ),
        ).called(1);
      });

      test('should maintain consistency after storage errors', () async {
        // ARRANGE - First operation succeeds, second fails
        when(
          mockSecureStorage.store(
            authTokenKey,
            validJwtToken,
            DataSensitivity.medium,
          ),
        ).thenAnswer((_) async {});
        when(
          mockSecureStorage.read(authTokenKey, DataSensitivity.medium),
        ).thenThrow(Exception('Storage corrupted'));

        // ACT - Store token successfully
        await tokenStorage.storeToken(validJwtToken);

        // ACT - Try to retrieve (should return null due to error)
        final retrievedToken = await tokenStorage.getToken();

        // ASSERT
        expect(retrievedToken, isNull);
        verify(
          mockSecureStorage.store(
            authTokenKey,
            validJwtToken,
            DataSensitivity.medium,
          ),
        ).called(1);
        verify(
          mockSecureStorage.read(authTokenKey, DataSensitivity.medium),
        ).called(1);
      });
    });

    group('Edge Cases and Boundary Conditions', () {
      // Note: Null token test removed as it's a programming error scenario
      // The implementation expects non-null strings as per the interface contract

      test('should handle extremely long tokens', () async {
        // ARRANGE - Create a very long token (10KB)
        final extremelyLongToken = 'x' * 10240;
        when(
          mockSecureStorage.store(
            authTokenKey,
            extremelyLongToken,
            DataSensitivity.medium,
          ),
        ).thenAnswer((_) async {});
        when(
          mockSecureStorage.read(authTokenKey, DataSensitivity.medium),
        ).thenAnswer((_) async => extremelyLongToken);

        // ACT
        await tokenStorage.storeToken(extremelyLongToken);
        final retrievedToken = await tokenStorage.getToken();

        // ASSERT
        expect(retrievedToken, equals(extremelyLongToken));
        verify(
          mockSecureStorage.store(
            authTokenKey,
            extremelyLongToken,
            DataSensitivity.medium,
          ),
        ).called(1);
        verify(
          mockSecureStorage.read(authTokenKey, DataSensitivity.medium),
        ).called(1);
      });

      test('should handle Unicode characters in tokens', () async {
        // ARRANGE
        const unicodeToken = 'token_with_unicode_🔐_characters_测试_🚀';
        when(
          mockSecureStorage.store(
            authTokenKey,
            unicodeToken,
            DataSensitivity.medium,
          ),
        ).thenAnswer((_) async {});
        when(
          mockSecureStorage.read(authTokenKey, DataSensitivity.medium),
        ).thenAnswer((_) async => unicodeToken);

        // ACT
        await tokenStorage.storeToken(unicodeToken);
        final retrievedToken = await tokenStorage.getToken();

        // ASSERT
        expect(retrievedToken, equals(unicodeToken));
        verify(
          mockSecureStorage.store(
            authTokenKey,
            unicodeToken,
            DataSensitivity.medium,
          ),
        ).called(1);
        verify(
          mockSecureStorage.read(authTokenKey, DataSensitivity.medium),
        ).called(1);
      });
    });
  });
}

// Custom exception class for testing
class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}

class TimeoutException implements Exception {
  final String message;
  final Duration? duration;
  TimeoutException(this.message, [this.duration]);

  @override
  String toString() => 'TimeoutException: $message';
}
