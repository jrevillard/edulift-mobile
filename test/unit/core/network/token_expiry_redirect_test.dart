import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:edulift/core/network/interceptors/network_interceptors.dart';

import '../../../test_mocks/generated_mocks.dart';

/// TOKEN EXPIRY REDIRECT TEST SUITE
///
/// Tests the critical authentication flow where expired tokens (403/401 responses)
/// should trigger token clearing and redirect to login page.
///
/// ISSUE: User reported that 403 responses from expired tokens are not
/// redirecting to login page properly.
///
/// CRITICAL BEHAVIOR TESTED:
/// - 401 Unauthorized responses clear token and trigger re-authentication
/// - 403 Forbidden responses clear token and trigger re-authentication
/// - Token clearing works even when storage operations fail
/// - Other HTTP error codes do not trigger token clearing

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

void main() {
  group('Token Expiry Redirect - NetworkAuthInterceptor', () {
    late NetworkAuthInterceptor interceptor;
    late MockAdaptiveStorageService mockStorageService;
    late MockErrorInterceptorHandler mockHandler;

    setUp(() {
      mockStorageService = MockAdaptiveStorageService();
      interceptor = NetworkAuthInterceptor(
        mockStorageService,
      ); // No ref for unit tests
      mockHandler = MockErrorInterceptorHandler();
    });

    group('401 Unauthorized Token Expiry', () {
      test('should clear token when receiving 401 Unauthorized', () async {
        // ARRANGE
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/protected'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/protected'),
            statusCode: 401,
            statusMessage: 'Unauthorized',
            data: {'error': 'Token expired'},
          ),
          type: DioExceptionType.badResponse,
        );

        when(mockStorageService.clearToken()).thenAnswer((_) async {});

        // ACT
        interceptor.onError(dioException, mockHandler);

        // Allow async operation to complete
        await Future.delayed(Duration.zero);

        // ASSERT
        verify(mockStorageService.clearToken()).called(1);
        verify(mockHandler.next(dioException)).called(1);
      });

      test('should handle token clearing failure gracefully on 401', () async {
        // ARRANGE
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/protected'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/protected'),
            statusCode: 401,
            statusMessage: 'Unauthorized',
          ),
          type: DioExceptionType.badResponse,
        );

        when(
          mockStorageService.clearToken(),
        ).thenThrow(Exception('Storage failure'));

        // ACT & ASSERT
        expect(
          () => interceptor.onError(dioException, mockHandler),
          returnsNormally,
        );

        // Allow async operation to complete
        await Future.delayed(Duration.zero);

        verify(mockStorageService.clearToken()).called(1);
        verify(mockHandler.next(dioException)).called(1);
      });
    });

    group('403 Forbidden Token Expiry', () {
      test('should clear token when receiving 403 Forbidden', () async {
        // ARRANGE
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/protected'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/protected'),
            statusCode: 403,
            statusMessage: 'Forbidden',
            data: {'error': 'Access token expired'},
          ),
          type: DioExceptionType.badResponse,
        );

        when(mockStorageService.clearToken()).thenAnswer((_) async {});

        // ACT
        interceptor.onError(dioException, mockHandler);

        // Allow async operation to complete
        await Future.delayed(Duration.zero);

        // ASSERT
        verify(mockStorageService.clearToken()).called(1);
        verify(mockHandler.next(dioException)).called(1);
      });

      test('should handle token clearing failure gracefully on 403', () async {
        // ARRANGE
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/protected'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/protected'),
            statusCode: 403,
            statusMessage: 'Forbidden',
          ),
          type: DioExceptionType.badResponse,
        );

        when(
          mockStorageService.clearToken(),
        ).thenThrow(Exception('Storage failure'));

        // ACT & ASSERT
        expect(
          () => interceptor.onError(dioException, mockHandler),
          returnsNormally,
        );

        // Allow async operation to complete
        await Future.delayed(Duration.zero);

        verify(mockStorageService.clearToken()).called(1);
        verify(mockHandler.next(dioException)).called(1);
      });
    });

    group('Other HTTP Error Codes', () {
      test('should NOT clear token for 400 Bad Request', () async {
        // ARRANGE
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/protected'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/protected'),
            statusCode: 400,
            statusMessage: 'Bad Request',
          ),
          type: DioExceptionType.badResponse,
        );

        // ACT
        interceptor.onError(dioException, mockHandler);
        await Future.delayed(Duration.zero);

        // ASSERT
        verifyNever(mockStorageService.clearToken());
        verify(mockHandler.next(dioException)).called(1);
      });

      test('should NOT clear token for 500 Internal Server Error', () async {
        // ARRANGE
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/protected'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/protected'),
            statusCode: 500,
            statusMessage: 'Internal Server Error',
          ),
          type: DioExceptionType.badResponse,
        );

        // ACT
        interceptor.onError(dioException, mockHandler);
        await Future.delayed(Duration.zero);

        // ASSERT
        verifyNever(mockStorageService.clearToken());
        verify(mockHandler.next(dioException)).called(1);
      });

      test('should NOT clear token for 422 Validation Error', () async {
        // ARRANGE
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/protected'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/protected'),
            statusCode: 422,
            statusMessage: 'Unprocessable Entity',
          ),
          type: DioExceptionType.badResponse,
        );

        // ACT
        interceptor.onError(dioException, mockHandler);
        await Future.delayed(Duration.zero);

        // ASSERT
        verifyNever(mockStorageService.clearToken());
        verify(mockHandler.next(dioException)).called(1);
      });
    });

    group('Network Errors Without Response', () {
      test('should NOT clear token for connection timeout', () async {
        // ARRANGE
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/protected'),
          type: DioExceptionType.connectionTimeout,
          message: 'Connection timeout',
        );

        // ACT
        interceptor.onError(dioException, mockHandler);
        await Future.delayed(Duration.zero);

        // ASSERT
        verifyNever(mockStorageService.clearToken());
        verify(mockHandler.next(dioException)).called(1);
      });

      test('should NOT clear token for connection error', () async {
        // ARRANGE
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/protected'),
          type: DioExceptionType.connectionError,
          message: 'No internet connection',
        );

        // ACT
        interceptor.onError(dioException, mockHandler);
        await Future.delayed(Duration.zero);

        // ASSERT
        verifyNever(mockStorageService.clearToken());
        verify(mockHandler.next(dioException)).called(1);
      });
    });

    group('Edge Cases', () {
      test('should handle null response gracefully', () async {
        // ARRANGE
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/protected'),
          type: DioExceptionType.badResponse,
          message: 'Unknown error',
        );

        // ACT
        interceptor.onError(dioException, mockHandler);
        await Future.delayed(Duration.zero);

        // ASSERT
        verifyNever(mockStorageService.clearToken());
        verify(mockHandler.next(dioException)).called(1);
      });

      test('should handle null status code gracefully', () async {
        // ARRANGE
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/protected'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/protected'),
            statusMessage: 'Unknown',
          ),
          type: DioExceptionType.badResponse,
        );

        // ACT
        interceptor.onError(dioException, mockHandler);
        await Future.delayed(Duration.zero);

        // ASSERT
        verifyNever(mockStorageService.clearToken());
        verify(mockHandler.next(dioException)).called(1);
      });
    });

    group('Integration Scenarios', () {
      test('should clear token for both 401 and 403 in sequence', () async {
        // ARRANGE
        final exception401 = DioException(
          requestOptions: RequestOptions(path: '/api/endpoint1'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/endpoint1'),
            statusCode: 401,
            statusMessage: 'Unauthorized',
          ),
          type: DioExceptionType.badResponse,
        );

        final exception403 = DioException(
          requestOptions: RequestOptions(path: '/api/endpoint2'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/endpoint2'),
            statusCode: 403,
            statusMessage: 'Forbidden',
          ),
          type: DioExceptionType.badResponse,
        );

        when(mockStorageService.clearToken()).thenAnswer((_) async {});

        // ACT
        interceptor.onError(exception401, mockHandler);
        interceptor.onError(exception403, mockHandler);

        // Allow async operations to complete
        await Future.delayed(Duration.zero);

        // ASSERT
        verify(mockStorageService.clearToken()).called(2);
      });
    });
  });
}
