import 'dart:io';
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:edulift/core/domain/entities/family.dart';
import 'package:edulift/core/network/models/family/family_dto.dart';
import 'package:edulift/features/family/data/repositories/family_repository_impl.dart';
import 'package:edulift/features/family/data/datasources/family_remote_datasource.dart';
import 'package:edulift/features/family/data/datasources/family_local_datasource.dart';
import 'package:edulift/core/network/network_info.dart';
import 'package:edulift/core/network/network_error_handler.dart';
import 'package:edulift/features/family/domain/repositories/family_invitation_repository.dart';

/// Tests unifiés pour FamilyRepository avec approche HTTP-level
/// Migrated to NetworkErrorHandler pattern - NetworkInfo no longer passed directly to repository
void main() {
  group('FamilyRepositoryImpl - Unified HTTP Level Tests', () {
    late FamilyRepositoryImpl repository;
    late MockHttpFamilyRemoteDataSource mockRemoteDataSource;
    late FakeFamilyLocalDataSource fakeLocalDataSource;
    late FakeNetworkInfo fakeNetworkInfo;
    late NetworkErrorHandler networkErrorHandler;
    late MockInvitationRepository mockInvitationRepository;

    final testFamily = Family(
      id: 'test-family-123',
      name: 'Test Family',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final testFamilyDto = FamilyDto(
      id: 'test-family-123',
      name: 'Test Family',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setUp(() {
      mockRemoteDataSource = MockHttpFamilyRemoteDataSource();
      fakeLocalDataSource = FakeFamilyLocalDataSource();
      fakeNetworkInfo = FakeNetworkInfo();
      mockInvitationRepository = MockInvitationRepository();

      // Create NetworkErrorHandler with fake NetworkInfo
      networkErrorHandler = NetworkErrorHandler(networkInfo: fakeNetworkInfo);

      // Repository no longer receives NetworkInfo directly
      repository = FamilyRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        localDataSource: fakeLocalDataSource,
        invitationsRepository: mockInvitationRepository,
        networkErrorHandler: networkErrorHandler,
      );
    });

    group('HTTP Success Scenarios', () {
      test('should return family when HTTP 200 response', () async {
        mockRemoteDataSource.setHttpResponse(
          statusCode: 200,
          data: testFamilyDto,
        );

        final result = await repository.getCurrentFamily();

        expect(result.isOk, true);
        expect(result.value!.id, equals(testFamilyDto.id));
        expect(result.value!.name, equals(testFamilyDto.name));
      });
    });

    group('Network Error Scenarios - Cache Fallback', () {
      test(
        'REGRESSION: should use cached family when SocketException occurs',
        () async {
          mockRemoteDataSource.setSocketException(
            'Connection failed (OS Error: Network is unreachable, errno = 101)',
          );
          fakeLocalDataSource.setCachedFamily(testFamily);

          final result = await repository.getCurrentFamily();

          expect(
            result.isOk,
            true,
            reason:
                'Should return cached family for network errors to prevent onboarding redirect',
          );
          expect(
            result.value!.id,
            equals(testFamily.id),
            reason: 'Cached family should be returned to maintain user session',
          );
        },
      );

      test(
        'should return failure when HTTP 500 server error (not network error)',
        () async {
          mockRemoteDataSource.setHttpException(
            statusCode: 500,
            message: 'Internal Server Error',
            isNetworkError: false, // Server error, not network error
          );
          fakeLocalDataSource.setCachedFamily(testFamily);

          final result = await repository.getCurrentFamily();

          expect(
            result.isErr,
            true,
            reason: 'HTTP 500 is server error, should not use cache fallback',
          );
          expect(result.error!.code, equals('server'));
        },
      );

      test(
        'should return success when timeout error with cache fallback',
        () async {
          mockRemoteDataSource.setTimeoutException('Connection timeout');
          fakeLocalDataSource.setCachedFamily(testFamily);

          final result = await repository.getCurrentFamily();

          expect(result.isOk, true);
          expect(result.value!.id, equals(testFamily.id));
        },
      );
    });

    group('HTTP Error Scenarios - No Cache Fallback', () {
      test(
        'should return success when HTTP 404 (user has no family - valid state)',
        () async {
          // Arrange - Simulate HTTP 404 response (user has no family)
          mockRemoteDataSource.setHttpException(
            statusCode: 404,
            message: 'Family not found',
            isNetworkError: false, // 404 is not a network error
          );
          fakeLocalDataSource.setCachedFamily(testFamily);

          // Act
          final result = await repository.getCurrentFamily();

          // Assert - 404 means user has no family, which is a valid response
          expect(
            result.isOk,
            true,
            reason:
                'HTTP 404 means user has no family - this is a valid state, not an error',
          );
          expect(
            result.value,
            equals(null),
          ); // Should return null for no family
        },
      );
    });

    group('REGRESSION: Specific Network Error Messages', () {
      test(
        'REGRESSION: should handle "Network is unreachable" exact message',
        () async {
          mockRemoteDataSource.setSocketException('Network is unreachable');
          fakeLocalDataSource.setCachedFamily(testFamily);

          final result = await repository.getCurrentFamily();

          expect(
            result.isOk,
            true,
            reason:
                'Should handle exact "Network is unreachable" message from patrol logs',
          );
          expect(result.value!.id, equals(testFamily.id));
        },
      );

      test(
        'REGRESSION: should handle "Connection refused" network error',
        () async {
          mockRemoteDataSource.setSocketException('Connection refused');
          fakeLocalDataSource.setCachedFamily(testFamily);

          final result = await repository.getCurrentFamily();

          expect(
            result.isOk,
            true,
            reason: 'Should handle "Connection refused" network error',
          );
          expect(result.value!.id, equals(testFamily.id));
        },
      );
    });
  });
}

// Manual fake for NetworkInfo to avoid Mockito conflicts
class FakeNetworkInfo implements NetworkInfo {
  bool _isConnected = true;

  void setConnected(bool isConnected) {
    _isConnected = isConnected;
  }

  @override
  Future<bool> get isConnected => Future.value(_isConnected);

  @override
  Stream<bool> get connectionStream => Stream.value(_isConnected);
}

// Fake for LocalDataSource to avoid Mockito conflicts
class FakeFamilyLocalDataSource implements FamilyLocalDataSource {
  Family? _cachedFamily;

  void setCachedFamily(Family family) {
    _cachedFamily = family;
  }

  @override
  Future<void> clearCache() async {
    _cachedFamily = null;
  }

  @override
  Future<Family?> getCurrentFamily() async {
    return _cachedFamily;
  }

  // Implement all other methods with noSuchMethod
  @override
  dynamic noSuchMethod(Invocation invocation) {
    // Return appropriate defaults for async methods
    if (invocation.isMethod && invocation.isGetter) {
      return Future.value();
    }
    if (invocation.isMethod &&
        invocation.memberName.toString().contains('clear')) {
      return Future.value();
    }
    return Future.value();
  }
}

// Mock classes using Mockito
class MockInvitationRepository extends Mock implements InvitationRepository {}

// Mock HTTP-level RemoteDataSource that simulates HTTP responses
class MockHttpFamilyRemoteDataSource extends Mock
    implements FamilyRemoteDataSource {
  HttpSimulatedResponse? _response;

  void setHttpResponse({required int statusCode, required FamilyDto data}) {
    _response = HttpSimulatedResponse.success(statusCode, data);
  }

  void setHttpException({
    required int statusCode,
    required String message,
    required bool isNetworkError,
  }) {
    _response = HttpSimulatedResponse.httpError(
      statusCode,
      message,
      isNetworkError,
    );
  }

  void setSocketException(String message) {
    _response = HttpSimulatedResponse.socketError(message);
  }

  void setTimeoutException(String message) {
    _response = HttpSimulatedResponse.timeoutError(message);
  }

  @override
  Future<FamilyDto> getCurrentFamily() async {
    if (_response == null) {
      throw Exception('No response configured. Call set*Response() first.');
    }

    return _response!.execute();
  }
}

// Helper class to simulate different HTTP response scenarios (same pattern as groups)
class HttpSimulatedResponse {
  final int statusCode;
  final String message;
  final FamilyDto? data;
  final Exception? exception;
  final bool isNetworkError;

  HttpSimulatedResponse.success(this.statusCode, this.data)
      : message = 'OK',
        exception = null,
        isNetworkError = false;

  HttpSimulatedResponse.httpError(
    this.statusCode,
    this.message,
    this.isNetworkError,
  )   : data = null,
        exception = Exception('HTTP $statusCode: $message');

  HttpSimulatedResponse.socketError(this.message)
      : statusCode = 0,
        data = null,
        exception = SocketException(message),
        isNetworkError = true;

  HttpSimulatedResponse.timeoutError(this.message)
      : statusCode = 0,
        data = null,
        exception = TimeoutException(message, const Duration(seconds: 30)),
        isNetworkError = true;

  Future<FamilyDto> execute() async {
    if (exception != null) {
      throw exception!;
    }
    return data!;
  }
}
