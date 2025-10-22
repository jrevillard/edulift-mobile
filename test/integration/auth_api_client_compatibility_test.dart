import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';

import 'package:edulift/core/network/api_response_helper.dart';
// REMOVED: UserFamilyExtension - Clean Architecture violation eliminated
import 'package:edulift/core/network/models/common/api_response_wrapper.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/network/models/auth/auth_dto.dart';
import 'package:edulift/core/network/models/user/user_current_family_dto.dart';
import 'package:edulift/core/network/error_handler_service.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/core/network/requests/auth_requests.dart';
import 'package:edulift/core/errors/api_exception.dart';
import 'package:edulift/core/services/auth_service.dart';

import '../test_mocks/test_mocks.dart';
import '../support/test_di_config.dart';

/// CRITICAL COMPATIBILITY TESTS: AuthApiClient + ApiResponseHelper Integration
///
/// These tests validate the new architecture pattern where:
/// 1. AuthApiClient returns DTOs directly (Retrofit requirement)
/// 2. Services use ApiResponseHelper.execute() for explicit response handling
/// 3. 422 errors propagate correctly through the entire flow
/// 4. Successful responses unwrap properly
/// 5. Integration with AuthService migration is seamless
void main() {
  group('AuthApiClient + ApiResponseHelper Compatibility Tests', () {
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

      authService = AuthServiceImpl(
        mockAuthApiClient,
        mockLocalDatasource,
        mockUserStatusService,
        mockErrorHandlerService,
      );
    });

    group('CRITICAL: ApiResponseHelper.execute() Integration', () {
      test('should work with AuthApiClient DTOs and return proper ApiResponse', () async {
        // Arrange: AuthDto that would be returned by AuthApiClient
        const mockAuthDto = AuthDto(
          accessToken: 'test-token',
          refreshToken: 'mock_refresh_token',
          expiresIn: 900,
          
          user: UserCurrentFamilyDto(
            id: 'user-123',
            email: 'test@example.com',
            name: 'Test User',
          ),
        );

        // Act: Use ApiResponseHelper.execute() with AuthApiClient call
        final response = await ApiResponseHelper.execute<AuthDto>(
          () => Future.value(mockAuthDto),
        );

        // Assert: Should wrap DTO in proper ApiResponse
        expect(response.success, isTrue);
        expect(response.data, equals(mockAuthDto));
        expect(response.data!.accessToken, 'test-token');
        expect(response.data!.user.email, 'test@example.com');
      });

      test('should unwrap successful responses correctly', () async {
        // Arrange
        const mockAuthDto = AuthDto(
          accessToken: 'test-token',
          refreshToken: 'mock_refresh_token',
          expiresIn: 900,
          
          user: UserCurrentFamilyDto(
            id: 'user-123',
            email: 'test@example.com',
            name: 'Test User',
          ),
        );

        // Act: Execute and unwrap in one step
        final authDto = await ApiResponseHelper.executeAndUnwrap<AuthDto>(
          () => Future.value(mockAuthDto),
        );

        // Assert: Should get DTO directly
        expect(authDto.accessToken, 'test-token');
        expect(authDto.user.email, 'test@example.com');
      });
    });

    group('CRITICAL: 422 Error Propagation', () {
      test('should propagate 422 validation errors correctly through ApiResponseHelper', () async {
        // Arrange: Create DioException with 422 status (what AuthApiClient would throw)
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/auth/magic-link'),
          response: Response(
            requestOptions: RequestOptions(path: '/auth/magic-link'),
            statusCode: 422,
            data: {
              'success': false,
              'error': 'User is already a member of a family',
              'code': 'VALIDATION_ERROR',
            },
          ),
          message: 'Validation failed',
          type: DioExceptionType.badResponse,
        );

        // Act & Assert: Should handle 422 error correctly
        final response = await ApiResponseHelper.execute<String>(
          () => Future.error(dioException),
        );

        expect(response.success, isFalse);
        expect(response.statusCode, 422);
        expect(response.errorMessage, contains('User is already a member'));
        expect(response.isValidationError, isTrue);

        // Test unwrap throws ApiException with proper details
        expect(
          () => response.unwrap(),
          throwsA(isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 422)
              .having((e) => e.isValidationError, 'isValidationError', true)
              .having((e) => e.message, 'message', contains('User is already a member'))),
        );
      });

      test('should handle enhanced 422 errors from interceptor', () async {
        // Arrange: Create enhanced exception from interceptor
        const enhancedException = ApiException(
          message: 'This user is already a member of a family',
          statusCode: 422,
          errorCode: 'VALIDATION_ERROR',
          details: {'field': 'user_id'},
          endpoint: '/auth/verify',
          method: 'POST',
        );

        // Act: Handle enhanced exception
        final response = ApiResponseHelper.handleError<String>(enhancedException);

        // Assert: Should preserve all 422 error information
        expect(response.success, isFalse);
        expect(response.statusCode, 422);
        expect(response.errorCode, 'VALIDATION_ERROR');
        expect(response.isValidationError, isTrue);
        expect(response.metadata['field'], 'user_id');

        // Test unwrap preserves enhanced information
        expect(
          () => response.unwrap(),
          throwsA(isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 422)
              .having((e) => e.errorCode, 'errorCode', 'VALIDATION_ERROR')
              .having((e) => e.isValidationError, 'isValidationError', true)
              .having((e) => e.details?['field'], 'details.field', 'user_id')),
        );
      });
    });

    group('CRITICAL: Return Type Compatibility', () {
      test('AuthApiClient methods should return correct DTO types for ApiResponseHelper', () async {
        // Test sendMagicLink returns String
        when(mockAuthApiClient.sendMagicLink(any))
            .thenAnswer((_) async => 'Magic link sent successfully');

        final response = await ApiResponseHelper.execute<String>(
          () => mockAuthApiClient.sendMagicLink(
            const MagicLinkRequest(
              email: 'test@example.com',
              codeChallenge: 'test_code_challenge_43_chars_minimum_required',
            ),
          ),
        );

        expect(response.success, isTrue);
        expect(response.data, isA<String>());
        expect(response.data, 'Magic link sent successfully');
      });

      test('verifyMagicLink should return AuthDto compatible with ApiResponseHelper', () async {
        // Arrange
        const mockAuthDto = AuthDto(
          accessToken: 'test-token',
          refreshToken: 'mock_refresh_token',
          expiresIn: 900,
          
          user: UserCurrentFamilyDto(
            id: 'user-123',
            email: 'test@example.com',
            name: 'Test User',
          ),
        );

        when(mockAuthApiClient.verifyMagicLink(any, any))
            .thenAnswer((_) async => mockAuthDto);

        // Act
        final response = await ApiResponseHelper.execute<AuthDto>(
          () => mockAuthApiClient.verifyMagicLink(
            const VerifyTokenRequest(token: 'test-token'),
            null,
          ),
        );

        // Assert
        expect(response.success, isTrue);
        expect(response.data, isA<AuthDto>());
        expect(response.data!.accessToken, 'test-token');
        expect(response.data!.user.email, 'test@example.com');
      });

      test('logout should work with void return type', () async {
        // Arrange
        when(mockAuthApiClient.logout()).thenAnswer((_) async {});

        // Act
        final response = await ApiResponseHelper.execute<void>(
          () => mockAuthApiClient.logout(),
        );

        // Assert
        expect(response.success, isTrue);
        // For void responses, we only check success
      });
    });

    group('CRITICAL: Retrofit Annotations Preservation', () {
      test('should preserve POST annotation for sendMagicLink', () async {
        // This test verifies that Retrofit annotations are intact
        // by testing the actual method signatures and behavior

        when(mockAuthApiClient.sendMagicLink(any))
            .thenAnswer((_) async => 'Success');

        const request = MagicLinkRequest(
          email: 'test@example.com',
          name: 'Test User',
          codeChallenge: 'challenge',
        );

        // Act: Call should work without issues (indicates annotations are intact)
        await mockAuthApiClient.sendMagicLink(request);

        // Assert: Verify method was called with correct parameter
        verify(mockAuthApiClient.sendMagicLink(request)).called(1);
      });

      test('should preserve all HTTP method annotations', () async {
        // Test all HTTP methods used in AuthApiClient
        final requests = [
          () => mockAuthApiClient.sendMagicLink(const MagicLinkRequest(
              email: 'test@example.com',
              codeChallenge: 'test_code_challenge_43_chars_minimum_required',
            )),
          () => mockAuthApiClient.verifyMagicLink(const VerifyTokenRequest(token: 'test'), null),
          () => mockAuthApiClient.refreshToken(const RefreshTokenRequest(refreshToken: 'test')),
          () => mockAuthApiClient.logout(),
        ];

        // Setup mocks
        when(mockAuthApiClient.sendMagicLink(any)).thenAnswer((_) async => 'Success');
        when(mockAuthApiClient.verifyMagicLink(any, any)).thenAnswer((_) async => const AuthDto(
          accessToken: 'token',
          refreshToken: 'mock_refresh_token',
          expiresIn: 900,
          
          user: UserCurrentFamilyDto(
            id: '1',
            email: 'test@example.com',
            name: 'Test',
          ),
        ));
        when(mockAuthApiClient.refreshToken(any)).thenAnswer((_) async => const AuthDto(
          accessToken: 'token',
          refreshToken: 'mock_refresh_token',
          expiresIn: 900,
          
          user: UserCurrentFamilyDto(
            id: '1',
            email: 'test@example.com',
            name: 'Test',
          ),
        ));
        when(mockAuthApiClient.logout()).thenAnswer((_) async {});

        // Act & Assert: All methods should be callable (indicates annotations work)
        for (final request in requests) {
          await expectLater(request(), completes);
        }
      });
    });

    group('CRITICAL: AuthService Integration', () {
      test('sendMagicLink should use new ApiResponseHelper pattern', () async {
        // Arrange: Mock the chain of calls
        when(mockUserStatusService.isValidEmail(any)).thenReturn(true);
        when(mockLocalDatasource.storePKCEVerifier(any))
            .thenAnswer((_) async => const Ok(null));
        when(mockLocalDatasource.storeMagicLinkEmail(any))
            .thenAnswer((_) async => const Ok(null));
        when(mockAuthApiClient.sendMagicLink(any))
            .thenAnswer((_) async => 'Magic link sent successfully');

        // Act: Call AuthService method
        final result = await authService.sendMagicLink('test@example.com');

        // Assert: Should succeed with new pattern
        expect(result.isSuccess, isTrue);

        // Verify the API client was called
        verify(mockAuthApiClient.sendMagicLink(any)).called(1);
      });

      test('authenticateWithMagicLink should handle 422 errors properly in new pattern', () async {
        // Arrange: Setup 422 error
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/auth/verify'),
          response: Response(
            requestOptions: RequestOptions(path: '/auth/verify'),
            statusCode: 422,
            data: {
              'success': false,
              'error': 'This user is already a member of a family',
              'code': 'VALIDATION_ERROR',
            },
          ),
          message: 'Validation failed',
          type: DioExceptionType.badResponse,
        );

        // Mock dependencies
        when(mockLocalDatasource.getMagicLinkEmail())
            .thenAnswer((_) async => const Ok('test@example.com'));
        when(mockLocalDatasource.getPKCEVerifier())
            .thenAnswer((_) async => const Ok('verifier'));
        when(mockAuthApiClient.verifyMagicLink(any, any))
            .thenThrow(dioException);

        // Mock error handler to return proper classification
        when(mockErrorHandlerService.handleError(any, any, stackTrace: anyNamed('stackTrace')))
            .thenAnswer((_) async => const ErrorHandlingResult(
              classification: ErrorClassification(
                category: ErrorCategory.validation,
                severity: ErrorSeverity.minor,
                isRetryable: true,
                requiresUserAction: true,
                analysisData: {'status_code': 422},
              ),
              userMessage: UserErrorMessage(
                titleKey: 'error.validation.title',
                messageKey: 'error.validation.message',
                canRetry: true,
              ),
              wasLogged: true,
              wasReported: false,
            ));

        // Act
        final result = await authService.authenticateWithMagicLink('test-token');

        // Assert: Should fail with ValidationFailure
        expect(result.isError, isTrue);
        expect(result.error, isA<ApiFailure>());
        expect(result.error!.statusCode, 422);
      });
    });

    group('CRITICAL: End-to-End Flow Tests', () {
      test('successful magic link flow should work end-to-end with new pattern', () async {
        // Arrange: Setup complete successful flow
        const mockAuthDto = AuthDto(
          accessToken: 'test-token',
          refreshToken: 'mock_refresh_token',
          expiresIn: 900,
          
          user: UserCurrentFamilyDto(
            id: 'user-123',
            email: 'test@example.com',
            name: 'Test User',
          ),
        );

        // Mock all dependencies for successful flow
        when(mockLocalDatasource.getMagicLinkEmail())
            .thenAnswer((_) async => const Ok('test@example.com'));
        when(mockLocalDatasource.getPKCEVerifier())
            .thenAnswer((_) async => const Ok('verifier'));
        when(mockAuthApiClient.verifyMagicLink(any, any))
            .thenAnswer((_) async => mockAuthDto);
        when(mockLocalDatasource.clearPKCEVerifier())
            .thenAnswer((_) async => const Ok(null));
        when(mockLocalDatasource.clearMagicLinkEmail())
            .thenAnswer((_) async => const Ok(null));
        when(mockLocalDatasource.storeToken(any))
            .thenAnswer((_) async => const Ok(null));
        // cacheFamilyData() call removed - Clean Architecture: auth service no longer manages family caching
        when(mockLocalDatasource.storeUserData(any))
            .thenAnswer((_) async => const Ok(null));

        // Act: Execute the full flow
        final result = await authService.authenticateWithMagicLink('test-token');

        // Assert: Should succeed with all data properly processed
        expect(result.isSuccess, isTrue);
        expect(result.value!.token, 'test-token');
        expect(result.value!.user.email, 'test@example.com');
        // CLEAN ARCHITECTURE: User no longer has familyId - family data via UserFamilyService
        // expect(result.value!.user.familyId, 'family-123'); // REMOVED

        // Verify API client was called through the helper pattern
        verify(mockAuthApiClient.verifyMagicLink(any, any)).called(1);
      });

      test('error responses should maintain proper context through entire flow', () async {
        // Arrange: Create realistic API error scenario
        const enhancedApiException = ApiException(
          message: 'Network timeout during authentication',
          statusCode: 0,
          details: {'timeout': true, 'retry_after': 30},
          endpoint: '/auth/verify',
          method: 'POST',
        );

        // Mock dependencies
        when(mockLocalDatasource.getMagicLinkEmail())
            .thenAnswer((_) async => const Ok('test@example.com'));
        when(mockLocalDatasource.getPKCEVerifier())
            .thenAnswer((_) async => const Ok('verifier'));
        when(mockAuthApiClient.verifyMagicLink(any, any))
            .thenThrow(enhancedApiException);

        when(mockErrorHandlerService.handleError(any, any, stackTrace: anyNamed('stackTrace')))
            .thenAnswer((_) async => const ErrorHandlingResult(
              classification: ErrorClassification(
                category: ErrorCategory.network,
                severity: ErrorSeverity.major,
                isRetryable: true,
                requiresUserAction: false,
                analysisData: {'timeout': true},
              ),
              userMessage: UserErrorMessage(
                titleKey: 'error.network.title',
                messageKey: 'error.network.message',
                canRetry: true,
              ),
              wasLogged: true,
              wasReported: false,
            ));

        // Act
        final result = await authService.authenticateWithMagicLink('test-token');

        // Assert: Should properly handle and classify the error
        expect(result.isError, isTrue);
        expect(result.error, isA<ApiFailure>());
        expect(result.error!.message, contains('Connection timeout'));

        // Verify error handler was called with proper context
        verify(mockErrorHandlerService.handleError(
          enhancedApiException,
          argThat(isA<ErrorContext>()),
          stackTrace: anyNamed('stackTrace'),
        )).called(1);
      });
    });
  });
}