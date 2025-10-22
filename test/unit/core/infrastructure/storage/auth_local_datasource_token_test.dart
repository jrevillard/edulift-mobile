import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:edulift/core/storage/auth_local_datasource.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';

import '../../../../test_mocks/generated_mocks.dart';

/// AUTH LOCAL DATASOURCE TOKEN TESTING
///
/// Tests the middle layer of token storage that validates and delegates to AdaptiveStorageService.
/// Focuses on:
/// - Token validation logic (empty token rejection)
/// - Error handling and Result pattern usage
/// - Integration between service layer and storage layer
/// - Timestamp tracking for token expiration
void main() {
  group('AuthLocalDatasource Token Management', () {
    late AuthLocalDatasource datasource;
    late MockAdaptiveStorageService mockStorageService;

    // Test data
    const validToken =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.abc123';
    const emptyToken = '';
    const whitespaceToken = '   ';
    const shortToken = 'abc';

    setUp(() {
      mockStorageService = MockAdaptiveStorageService();
      datasource = AuthLocalDatasource(mockStorageService);
    });

    group('Token Storage Validation', () {
      test('should store valid token successfully', () async {
        // ARRANGE
        when(
          mockStorageService.storeToken(validToken),
        ).thenAnswer((_) async => {});
        when(mockStorageService.write(any, any)).thenAnswer((_) async => {});

        // ACT
        final result = await datasource.storeToken(validToken);

        // ASSERT
        expect(result, isA<Ok<void, ApiFailure>>());
        verify(mockStorageService.storeToken(validToken)).called(1);
        verify(
          mockStorageService.write(any, any),
        ).called(1); // Timestamp storage
      });

      test(
        'CRITICAL: should reject empty token with validation error',
        () async {
          // ARRANGE - No storage calls should be made

          // ACT
          final result = await datasource.storeToken(emptyToken);

          // ASSERT
          expect(result, isA<Err<void, ApiFailure>>());
          expect(
            result.unwrapErr().message,
            contains('Cannot store empty access token'),
          );
          verifyNever(mockStorageService.storeToken(any));
          verifyNever(mockStorageService.write(any, any));
        },
      );

      test('should reject whitespace-only token', () async {
        // ARRANGE - No storage calls should be made

        // ACT
        final result = await datasource.storeToken(whitespaceToken);

        // ASSERT
        expect(result, isA<Err<void, ApiFailure>>());
        expect(
          result.unwrapErr().message,
          contains('Cannot store empty access token'),
        );
        verifyNever(mockStorageService.storeToken(any));
      });

      test('should accept short but non-empty token', () async {
        // ARRANGE
        when(
          mockStorageService.storeToken(shortToken),
        ).thenAnswer((_) async => {});
        when(mockStorageService.write(any, any)).thenAnswer((_) async => {});

        // ACT
        final result = await datasource.storeToken(shortToken);

        // ASSERT
        expect(result, isA<Ok<void, ApiFailure>>());
        verify(mockStorageService.storeToken(shortToken)).called(1);
      });
    });

    group('Token Storage Error Handling', () {
      test('should handle storage service exceptions', () async {
        // ARRANGE
        when(
          mockStorageService.storeToken(validToken),
        ).thenThrow(Exception('Storage backend failure'));

        // ACT
        final result = await datasource.storeToken(validToken);

        // ASSERT
        expect(result, isA<Err<void, ApiFailure>>());
        expect(
          result.unwrapErr().message,
          contains('Failed to save access token'),
        );
      });

      test('should handle timestamp storage failure', () async {
        // ARRANGE
        when(
          mockStorageService.storeToken(validToken),
        ).thenAnswer((_) async => {});
        when(
          mockStorageService.write(any, any),
        ).thenThrow(Exception('Timestamp storage failure'));

        // ACT
        final result = await datasource.storeToken(validToken);

        // ASSERT
        expect(result, isA<Err<void, ApiFailure>>());
        verify(mockStorageService.storeToken(validToken)).called(1);
      });
    });

    group('Token Retrieval', () {
      test('should retrieve stored token successfully', () async {
        // ARRANGE
        when(mockStorageService.getToken()).thenAnswer((_) async => validToken);

        // ACT
        final result = await datasource.getToken();

        // ASSERT
        expect(result, isA<Ok<String?, ApiFailure>>());
        expect(result.value, equals(validToken));
        verify(mockStorageService.getToken()).called(1);
      });

      test('should handle null token from storage', () async {
        // ARRANGE
        when(mockStorageService.getToken()).thenAnswer((_) async => null);

        // ACT
        final result = await datasource.getToken();

        // ASSERT
        expect(result, isA<Ok<String?, ApiFailure>>());
        expect(result.value, isNull);
      });

      test('should handle storage retrieval exceptions', () async {
        // ARRANGE
        when(
          mockStorageService.getToken(),
        ).thenThrow(Exception('Storage read failure'));

        // ACT
        final result = await datasource.getToken();

        // ASSERT
        expect(result, isA<Err<String?, ApiFailure>>());
        expect(
          result.unwrapErr().message,
          contains('Failed to retrieve token:'),
        );
      });
    });

    group('Token Cleanup', () {
      test('should clear token successfully', () async {
        // ARRANGE
        when(mockStorageService.clearToken()).thenAnswer((_) async => {});

        // ACT
        final result = await datasource.clearToken();

        // ASSERT
        expect(result, isA<Ok<void, ApiFailure>>());
        verify(mockStorageService.clearToken()).called(1);
      });

      test('should handle clear token exceptions', () async {
        // ARRANGE
        when(
          mockStorageService.clearToken(),
        ).thenThrow(Exception('Clear token failure'));

        // ACT
        final result = await datasource.clearToken();

        // ASSERT
        expect(result, isA<Err<void, ApiFailure>>());
        expect(result.unwrapErr().message, contains('Failed to clear token:'));
      });
    });

    // Note: Removed invalid test groups that called non-existent methods
    // on MockAdaptiveStorageService. These methods exist in AuthLocalDatasource
    // itself and don't need to be mocked on the storage service.
  });
}
