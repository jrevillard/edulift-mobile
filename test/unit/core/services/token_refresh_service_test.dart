import 'package:dio/dio.dart';
import 'package:edulift/core/data/services/token_refresh_service.dart';
import 'package:edulift/core/storage/auth_local_datasource.dart';
import 'package:edulift/core/network/network_error_handler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:edulift/core/utils/result.dart';

import 'token_refresh_service_test.mocks.dart';

@GenerateMocks([Dio, AuthLocalDatasource, NetworkErrorHandler])
void main() {
  late MockDio mockDio;
  late MockAuthLocalDatasource mockStorage;
  late MockNetworkErrorHandler mockNetworkErrorHandler;
  late TokenRefreshService service;

  setUp(() {
    mockDio = MockDio();
    mockStorage = MockAuthLocalDatasource();
    mockNetworkErrorHandler = MockNetworkErrorHandler();
    service = TokenRefreshService(
      mockDio,
      mockStorage,
      mockNetworkErrorHandler,
    );
  });

  group('TokenRefreshService - refreshToken', () {
    test('should successfully refresh token', () async {
      // Arrange
      const refreshToken = 'old_refresh_token';
      const newAccessToken = 'new_access_token';
      const newRefreshToken = 'new_refresh_token';
      const expiresIn = 900;

      when(
        mockStorage.getRefreshToken(),
      ).thenAnswer((_) async => const Result.ok(refreshToken));

      // Mock Dio response
      final responseData = {
        'accessToken': newAccessToken,
        'refreshToken': newRefreshToken,
        'expiresIn': expiresIn,
      };

      final response = Response<Map<String, dynamic>>(
        data: responseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/auth/refresh'),
      );

      when(
        mockDio.post('/auth/refresh', data: {'refreshToken': refreshToken}),
      ).thenAnswer((_) async => response);

      when(
        mockStorage.storeTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
          expiresAt: any,
        ),
      ).thenAnswer((_) async => const Result.ok(null));

      // Act
      await service.refreshToken();

      // Assert
      verify(mockStorage.getRefreshToken()).called(1);
      verify(
        mockDio.post('/auth/refresh', data: {'refreshToken': refreshToken}),
      ).called(1);
      verify(
        mockStorage.storeTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
          expiresAt: any,
        ),
      ).called(1);
    });

    test('should handle concurrent refresh requests with queue', () async {
      // Arrange
      const refreshToken = 'old_refresh_token';
      const newAccessToken = 'new_access_token';
      const newRefreshToken = 'new_refresh_token';
      const expiresIn = 900;

      when(
        mockStorage.getRefreshToken(),
      ).thenAnswer((_) async => const Result.ok(refreshToken));

      final responseData = {
        'accessToken': newAccessToken,
        'refreshToken': newRefreshToken,
        'expiresIn': expiresIn,
      };

      final response = Response<Map<String, dynamic>>(
        data: responseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/auth/refresh'),
      );

      // Add delay to simulate slow network
      when(
        mockDio.post('/auth/refresh', data: {'refreshToken': refreshToken}),
      ).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return response;
      });

      when(
        mockStorage.storeTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
          expiresAt: any,
        ),
      ).thenAnswer((_) async => const Result.ok(null));

      // Act - Launch 5 concurrent refresh requests
      final futures = List.generate(5, (_) => service.refreshToken());

      await Future.wait(futures);

      // Assert - Should only call backend ONCE despite 5 concurrent requests
      verify(
        mockDio.post('/auth/refresh', data: {'refreshToken': refreshToken}),
      ).called(1);

      verify(
        mockStorage.storeTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
          expiresAt: any,
        ),
      ).called(1);
    });

    test('should force logout when refresh fails', () async {
      // Arrange
      const refreshToken = 'old_refresh_token';

      when(
        mockStorage.getRefreshToken(),
      ).thenAnswer((_) async => const Result.ok(refreshToken));

      when(
        mockDio.post('/auth/refresh', data: {'refreshToken': refreshToken}),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/refresh'),
          response: Response(
            statusCode: 401,
            requestOptions: RequestOptions(path: '/auth/refresh'),
          ),
        ),
      );

      when(
        mockStorage.clearTokens(),
      ).thenAnswer((_) async => const Result.ok(null));

      // Act & Assert
      expect(() => service.refreshToken(), throwsA(isA<DioException>()));

      await Future.delayed(const Duration(milliseconds: 50));

      // Verify clearTokens was called for logout
      verify(mockStorage.clearTokens()).called(1);
    });

    test('should throw when no refresh token available', () async {
      // Arrange
      when(
        mockStorage.getRefreshToken(),
      ).thenAnswer((_) async => const Result.ok(null));

      // Act & Assert
      expect(() => service.refreshToken(), throwsA(isA<Exception>()));
    });
  });

  group('TokenRefreshService - shouldRefreshToken', () {
    test(
      'should return true when token expires in less than 5 minutes',
      () async {
        // Arrange - Token expires in 4 minutes
        final expiresAt = DateTime.now().add(const Duration(minutes: 4));
        when(
          mockStorage.getTokenExpiry(),
        ).thenAnswer((_) async => Result.ok(expiresAt));

        // Act
        final result = await service.shouldRefreshToken();

        // Assert
        expect(result, true);
      },
    );

    test(
      'should return false when token expires in more than 5 minutes',
      () async {
        // Arrange - Token expires in 6 minutes
        final expiresAt = DateTime.now().add(const Duration(minutes: 6));
        when(
          mockStorage.getTokenExpiry(),
        ).thenAnswer((_) async => Result.ok(expiresAt));

        // Act
        final result = await service.shouldRefreshToken();

        // Assert
        expect(result, false);
      },
    );

    test('should return false when no token expiry available', () async {
      // Arrange
      when(
        mockStorage.getTokenExpiry(),
      ).thenAnswer((_) async => const Result.ok(null));

      // Act
      final result = await service.shouldRefreshToken();

      // Assert
      expect(result, false);
    });

    test('should return true when token already expired', () async {
      // Arrange - Token expired 1 minute ago
      final expiresAt = DateTime.now().subtract(const Duration(minutes: 1));
      when(
        mockStorage.getTokenExpiry(),
      ).thenAnswer((_) async => Result.ok(expiresAt));

      // Act
      final result = await service.shouldRefreshToken();

      // Assert
      expect(result, true);
    });
  });
}
