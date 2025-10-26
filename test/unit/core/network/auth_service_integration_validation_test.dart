import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:edulift/core/services/auth_service.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/network/models/auth/auth_dto.dart';
import 'package:edulift/core/network/models/user/user_profile_dto.dart';
import 'package:edulift/core/network/models/user/user_current_family_dto.dart';
import 'package:edulift/core/errors/api_exception.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/core/network/error_handler_service.dart';

import '../../../test_mocks/test_mocks.mocks.dart';
import '../../../support/test_di_config.dart';

/// FINAL VALIDATION: AuthService Integration with New Architecture
///
/// This test validates that the completed AuthService migration:
/// 1. Uses proper DTOs (AuthDto, UserProfileDto) with ApiResponseHelper.execute()
/// 2. Handles 422 validation errors correctly through the new pattern
/// 3. Maintains all security validations
/// 4. Preserves clean architecture principles
void main() {
  group('AuthService + AuthApiClient Integration Validation', () {
    late MockAuthApiClient mockAuthApiClient;
    late AuthServiceImpl authService;
    late MockIAuthLocalDatasource mockLocalDatasource;
    late MockUserStatusService mockUserStatusService;
    // MockComprehensiveFamilyDataService removed - Clean Architecture: auth domain separated from family domain
    late MockErrorHandlerService mockErrorHandlerService;

    setUpAll(() {
      TestDIConfig.setupTestDependencies();
    });

    setUp(() {
      mockAuthApiClient = MockAuthApiClient();
      mockLocalDatasource = MockIAuthLocalDatasource();
      mockUserStatusService = MockUserStatusService();
      // mockFamilyCacheService removed - Clean Architecture separation
      mockErrorHandlerService = MockErrorHandlerService();

      // REMOVED: UserFamilyServiceInjector.setService - class doesn't exist
      // TODO: Adapt to use familyRepositoryProvider

      authService = AuthServiceImpl(
        mockAuthApiClient,
        mockLocalDatasource,
        mockUserStatusService,
        mockErrorHandlerService,
      );
    });

    tearDown(() {
      // REMOVED: UserFamilyServiceInjector.clearService - class doesn't exist
    });

    group('FINAL: DTO Usage Validation', () {
      test(
        'verifyMagicLink should use AuthDto correctly with ApiResponseHelper',
        () async {
          // Arrange: Proper AuthDto from AuthApiClient
          const mockAuthDto = AuthDto(
            accessToken: 'jwt-token-12345',
            refreshToken: 'mock_refresh_token',
            expiresIn: 900,
            user: UserCurrentFamilyDto(
              id: 'user-456',
              email: 'verified@example.com',
              name: 'Verified User',
              isBiometricEnabled: true,
            ),
          );

          // Mock all required dependencies for successful flow
          when(
            mockLocalDatasource.getMagicLinkEmail(),
          ).thenAnswer((_) async => const Ok('verified@example.com'));
          when(
            mockLocalDatasource.getPKCEVerifier(),
          ).thenAnswer((_) async => const Ok('code-verifier-123'));
          when(
            mockAuthApiClient.verifyMagicLink(any, any),
          ).thenAnswer((_) async => mockAuthDto);
          when(
            mockLocalDatasource.clearPKCEVerifier(),
          ).thenAnswer((_) async => const Ok(null));
          when(
            mockLocalDatasource.clearMagicLinkEmail(),
          ).thenAnswer((_) async => const Ok(null));
          when(
            mockLocalDatasource.storeToken(any),
          ).thenAnswer((_) async => const Ok(null));
          // cacheFamilyData() call removed - Clean Architecture: auth service no longer manages family caching
          when(
            mockLocalDatasource.storeUserData(any),
          ).thenAnswer((_) async => const Ok(null));

          // REMOVED: mockUserFamilyService.getCachedFamilyId - method doesn't exist
          // TODO: Adapt to use familyRepositoryProvider

          // Act: Execute the method that now uses ApiResponseHelper.execute<AuthDto>()
          final result = await authService.authenticateWithMagicLink(
            'test-token',
          );

          // Assert: Should successfully process AuthDto through new pattern
          expect(result.isSuccess, isTrue);
          expect(result.value!.token, 'jwt-token-12345');
          expect(result.value!.user.email, 'verified@example.com');
          expect(result.value!.user.isBiometricEnabled, true);
          // REMOVED: user.familyId assertion - field doesn't exist

          // Verify AuthApiClient was called correctly
          verify(mockAuthApiClient.verifyMagicLink(any, any)).called(1);
        },
      );

      test('enableBiometricAuth should use UserProfileDto correctly', () async {
        // Arrange: Proper UserProfileDto from AuthApiClient
        final mockUserProfileDto = UserProfileDto(
          id: 'user-789',
          email: 'biometric@example.com',
          name: 'Biometric User',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Mock dependencies
        when(
          mockAuthApiClient.enableBiometricAuth(any),
        ).thenAnswer((_) async => mockUserProfileDto);
        // cacheFamilyData() call removed - Clean Architecture: auth service no longer manages family caching

        // REMOVED: mockUserFamilyService.getCachedFamilyId - method doesn't exist
        // TODO: Adapt to use familyRepositoryProvider

        // Act: Execute method that uses ApiResponseHelper.execute<UserProfileDto>()
        final result = await authService.enableBiometricAuth();

        // Assert: Should process UserProfileDto correctly
        expect(result.isSuccess, isTrue);
        expect(result.value!.id, 'user-789');
        expect(result.value!.email, 'biometric@example.com');
        expect(result.value!.name, 'Biometric User');
        expect(result.value!.isBiometricEnabled, true);
        // REMOVED: user.familyId assertion - field doesn't exist

        // Verify API client was called
        verify(mockAuthApiClient.enableBiometricAuth({})).called(1);
      });
    });

    group('FINAL: 422 Error Handling with DTOs', () {
      test(
        'should handle 422 validation error correctly in new DTO pattern',
        () async {
          // Arrange: Create proper 422 error that would occur during DTO parsing
          const apiException = ApiException(
            message: 'Magic link token has expired',
            statusCode: 422,
            errorCode: 'TOKEN_EXPIRED',
            details: {
              'expired_at': '2025-09-19T10:00:00Z',
              'current_time': '2025-09-19T11:30:00Z',
            },
            endpoint: '/auth/verify',
            method: 'POST',
          );

          // Mock dependencies for failed verification
          when(
            mockLocalDatasource.getMagicLinkEmail(),
          ).thenAnswer((_) async => const Ok('test@example.com'));
          when(
            mockLocalDatasource.getPKCEVerifier(),
          ).thenAnswer((_) async => const Ok('verifier'));
          when(
            mockAuthApiClient.verifyMagicLink(any, any),
          ).thenThrow(apiException);

          // Mock error handler response
          when(
            mockErrorHandlerService.handleError(
              any,
              any,
              stackTrace: anyNamed('stackTrace'),
            ),
          ).thenAnswer(
            (_) async => const ErrorHandlingResult(
              classification: ErrorClassification(
                category: ErrorCategory.validation,
                severity: ErrorSeverity.minor,
                isRetryable: true,
                requiresUserAction: true,
                analysisData: {
                  'status_code': 422,
                  'error_code': 'TOKEN_EXPIRED',
                },
              ),
              userMessage: UserErrorMessage(
                titleKey: 'error.auth.token_expired.title',
                messageKey: 'error.auth.token_expired.message',
                canRetry: true,
              ),
              wasLogged: true,
              wasReported: false,
            ),
          );

          // Act: Execute method with 422 error
          final result = await authService.authenticateWithMagicLink(
            'expired-token',
          );

          // Assert: Should handle 422 error correctly through DTO pattern
          // FIXED: 422 is a validation error, not a generic API error
          // HTTP 422 "Unprocessable Entity" should return ValidationFailure
          expect(result.isError, isTrue);
          expect(result.error, isA<ValidationFailure>());
          expect(result.error!.statusCode, 422);
          expect(result.error!.message, contains('expired'));

          // Verify error was processed through the system
          verify(
            mockErrorHandlerService.handleError(
              any,
              any,
              stackTrace: anyNamed('stackTrace'),
            ),
          ).called(1);
        },
      );
    });

    group('FINAL: Security Validation with New Pattern', () {
      test(
        'should maintain email security validation with AuthDto pattern',
        () async {
          // Arrange: Create AuthDto with different email (security attack scenario)
          const maliciousAuthDto = AuthDto(
            accessToken: 'stolen-token',
            refreshToken: 'mock_refresh_token',
            expiresIn: 900,
            user: UserCurrentFamilyDto(
              id: 'attacker-123',
              email: 'attacker@evil.com', // Different email
              name: 'Attacker',
            ),
          );

          // Mock stored email (victim's email)
          when(
            mockLocalDatasource.getMagicLinkEmail(),
          ).thenAnswer((_) async => const Ok('victim@example.com'));
          when(
            mockLocalDatasource.getPKCEVerifier(),
          ).thenAnswer((_) async => const Ok('verifier'));
          when(
            mockAuthApiClient.verifyMagicLink(any, any),
          ).thenAnswer((_) async => maliciousAuthDto);
          when(
            mockLocalDatasource.clearMagicLinkEmail(),
          ).thenAnswer((_) async => const Ok(null));
          when(
            mockLocalDatasource.clearPKCEVerifier(),
          ).thenAnswer((_) async => const Ok(null));

          // Act: Attempt authentication with cross-user token
          final result = await authService.authenticateWithMagicLink(
            'malicious-token',
          );

          // Assert: Should block cross-user attack even with new DTO pattern
          expect(result.isError, isTrue);
          expect(result.error, isA<ApiFailure>());
          expect(result.error!.message, contains('Security validation failed'));

          // Verify security cleanup was performed
          verify(mockLocalDatasource.clearMagicLinkEmail()).called(1);
          verify(mockLocalDatasource.clearPKCEVerifier()).called(1);
        },
      );
    });

    group('FINAL: Complete Architecture Validation', () {
      test('should demonstrate complete new architecture pattern working', () async {
        // This test demonstrates the complete flow working with the new pattern:
        // AuthApiClient (DTOs) → ApiResponseHelper.execute<DTO>() → response.unwrap() → AuthService

        // Arrange: Complete successful flow
        const authDto = AuthDto(
          accessToken: 'complete-test-token',
          refreshToken: 'mock_refresh_token',
          expiresIn: 900,
          user: UserCurrentFamilyDto(
            id: 'complete-user-123',
            email: 'complete@test.com',
            name: 'Complete Test User',
          ),
        );

        // Mock complete dependency chain
        when(mockUserStatusService.isValidEmail(any)).thenReturn(true);
        when(
          mockLocalDatasource.storePKCEVerifier(any),
        ).thenAnswer((_) async => const Ok(null));
        when(
          mockLocalDatasource.storeMagicLinkEmail(any),
        ).thenAnswer((_) async => const Ok(null));
        when(
          mockAuthApiClient.sendMagicLink(any),
        ).thenAnswer((_) async => 'Magic link sent successfully');

        when(
          mockLocalDatasource.getMagicLinkEmail(),
        ).thenAnswer((_) async => const Ok('complete@test.com'));
        when(
          mockLocalDatasource.getPKCEVerifier(),
        ).thenAnswer((_) async => const Ok('complete-verifier'));
        when(
          mockAuthApiClient.verifyMagicLink(any, any),
        ).thenAnswer((_) async => authDto);
        when(
          mockLocalDatasource.clearPKCEVerifier(),
        ).thenAnswer((_) async => const Ok(null));
        when(
          mockLocalDatasource.clearMagicLinkEmail(),
        ).thenAnswer((_) async => const Ok(null));
        when(
          mockLocalDatasource.storeToken(any),
        ).thenAnswer((_) async => const Ok(null));
        // cacheFamilyData() call removed - Clean Architecture: auth service no longer manages family caching
        when(
          mockLocalDatasource.storeUserData(any),
        ).thenAnswer((_) async => const Ok(null));

        // REMOVED: mockUserFamilyService.getCachedFamilyId - method doesn't exist
        // TODO: Adapt to use familyRepositoryProvider

        // Act: Execute complete magic link flow
        final sendResult = await authService.sendMagicLink('complete@test.com');
        final verifyResult = await authService.authenticateWithMagicLink(
          'magic-link-token',
        );

        // Assert: Complete flow should work with new architecture
        expect(sendResult.isSuccess, isTrue);
        expect(verifyResult.isSuccess, isTrue);
        expect(verifyResult.value!.token, 'complete-test-token');
        expect(verifyResult.value!.user.email, 'complete@test.com');
        // REMOVED: user.familyId assertion - field doesn't exist

        // Verify complete API client usage
        verify(mockAuthApiClient.sendMagicLink(any)).called(1);
        verify(mockAuthApiClient.verifyMagicLink(any, any)).called(1);
      });
    });
  });
}
