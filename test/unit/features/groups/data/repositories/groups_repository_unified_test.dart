import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'dart:async';

import 'package:edulift/core/domain/entities/groups/group_family.dart';
import 'package:edulift/features/groups/data/repositories/groups_repository_impl.dart';
import 'package:edulift/features/groups/data/datasources/group_remote_datasource.dart';
import 'package:edulift/features/groups/data/datasources/group_local_datasource.dart';
import 'package:edulift/core/network/network_info.dart';
import 'package:edulift/core/network/network_error_handler.dart';
import 'package:edulift/core/network/group_api_client.dart';

/// Tests unifiés pour GroupsRepository avec approche HTTP-level
/// Migrated to NetworkErrorHandler pattern - NetworkInfo no longer passed directly to repository
///
/// Ce fichier remplace et améliore:
/// - groups_repository_network_error_regression_test.dart
///
/// Couverture complète avec une seule approche propre et maintenable
void main() {
  group('GroupsRepositoryImpl - Unified HTTP Level Tests', () {
    late GroupsRepositoryImpl repository;
    late MockHttpGroupRemoteDataSource mockRemoteDataSource;
    late FakeGroupLocalDataSource fakeLocalDataSource;
    late FakeNetworkInfo fakeNetworkInfo;
    late NetworkErrorHandler networkErrorHandler;

    const testGroupId = 'test-group-123';
    const testRealGroupId =
        'cmgrv9cyp009kitmdjfesrlpr'; // From patrol test logs

    const testGroupFamily = GroupFamily(
      id: 'test-family-123',
      name: 'Test Family',
      role: GroupFamilyRole.owner,
      isMyFamily: true,
      canManage: true,
      admins: [],
    );

    final testGroupFamilyData = GroupFamilyData(
      id: 'test-family-123',
      name: 'Test Family',
      role: 'owner',
      isMyFamily: true,
      canManage: true,
      admins: [],
    );

    setUp(() {
      // Create mocks
      mockRemoteDataSource = MockHttpGroupRemoteDataSource();
      fakeLocalDataSource = FakeGroupLocalDataSource();
      fakeNetworkInfo = FakeNetworkInfo();

      // Create NetworkErrorHandler with fake NetworkInfo
      networkErrorHandler = NetworkErrorHandler(networkInfo: fakeNetworkInfo);

      // Repository no longer receives NetworkInfo directly - only NetworkErrorHandler
      repository = GroupsRepositoryImpl(
        mockRemoteDataSource,
        fakeLocalDataSource,
        networkErrorHandler,
      );
    });

    group('HTTP Success Scenarios', () {
      test('should return group families when HTTP 200 response', () async {
        // Arrange - Mock successful HTTP 200 response
        mockRemoteDataSource.setHttpResponse(
          groupId: testGroupId,
          statusCode: 200,
          data: [testGroupFamilyData],
        );

        // Act
        final result = await repository.getGroupFamilies(testGroupId);

        // Assert
        expect(result.isOk, true);
        expect(result.value!.length, equals(1));
        expect(result.value!.first.id, equals(testGroupFamily.id));
        expect(result.value!.first.name, equals(testGroupFamily.name));
      });
    });

    group('Network Error Scenarios - Cache Fallback', () {
      test(
        'REGRESSION: should use cached group families when SocketException occurs',
        () async {
          // Arrange - Simulate the exact error from patrol logs
          // "SocketException: Connection failed (OS Error: Network is unreachable, errno = 101)"
          mockRemoteDataSource.setSocketException(
            groupId: testRealGroupId,
            message:
                'Connection failed (OS Error: Network is unreachable, errno = 101)',
          );

          fakeLocalDataSource.setCachedFamilies(testRealGroupId, [
            testGroupFamily,
          ]);

          // Act
          final result = await repository.getGroupFamilies(testRealGroupId);

          // Assert - Should return cached group families to prevent patrol test failure
          expect(
            result.isOk,
            true,
            reason:
                'Should return cached group families for network errors to prevent patrol test failure',
          );
          expect(
            result.value!.first.id,
            equals(testGroupFamily.id),
            reason:
                'Cached group families should be returned to maintain user session',
          );
        },
      );

      test(
        'should return failure when HTTP 500 server error (not network error)',
        () async {
          // Arrange - Simulate HTTP 500 server error
          mockRemoteDataSource.setHttpException(
            groupId: testGroupId,
            statusCode: 500,
            message: 'Internal Server Error',
            isNetworkError: false, // Server error, not network error
          );

          fakeLocalDataSource.setCachedFamilies(testGroupId, [testGroupFamily]);

          // Act
          final result = await repository.getGroupFamilies(testGroupId);

          // Assert
          expect(
            result.isErr,
            true,
            reason: 'HTTP 500 is server error, should not use cache fallback',
          );
          expect(result.error!.code, equals('server'));
        },
      );

      test(
        'should return error when timeout error and no cache exists',
        () async {
          // Arrange - Simulate timeout error with empty cache
          mockRemoteDataSource.setTimeoutException(
            groupId: testGroupId,
            message: 'Connection timeout',
          );

          fakeLocalDataSource.setCachedFamilies(testGroupId, []);

          // Act
          final result = await repository.getGroupFamilies(testGroupId);

          // Assert - Timeout is network error, but empty cache means no fallback possible
          expect(
            result.isErr,
            true,
            reason:
                'Timeout is network error, but empty cache means no fallback data available',
          );
        },
      );

      test(
        'should handle timeout as network error with cache fallback',
        () async {
          // Arrange - Simulate timeout
          mockRemoteDataSource.setTimeoutException(
            groupId: testGroupId,
            message: 'Connection timeout',
          );

          fakeLocalDataSource.setCachedFamilies(testGroupId, [testGroupFamily]);

          // Act
          final result = await repository.getGroupFamilies(testGroupId);

          // Assert
          expect(result.isOk, true);
          expect(result.value!.first.id, equals(testGroupFamily.id));
        },
      );
    });

    group('REGRESSION: Specific Network Error Messages', () {
      test(
        'REGRESSION: should handle "Network is unreachable" exact message',
        () async {
          // Arrange - Exact message from patrol logs
          mockRemoteDataSource.setSocketException(
            groupId: testGroupId,
            message: 'Network is unreachable',
          );

          fakeLocalDataSource.setCachedFamilies(testGroupId, [testGroupFamily]);

          // Act
          final result = await repository.getGroupFamilies(testGroupId);

          // Assert
          expect(
            result.isOk,
            true,
            reason:
                'Should handle exact "Network is unreachable" message from patrol logs',
          );
          expect(result.value!.first.id, equals(testGroupFamily.id));
        },
      );

      test('REGRESSION: should handle real group ID from patrol test', () async {
        // Arrange - Use the exact group ID from failing patrol test
        mockRemoteDataSource.setSocketException(
          groupId: testRealGroupId,
          message: 'Network is unreachable',
        );

        fakeLocalDataSource.setCachedFamilies(testRealGroupId, [
          testGroupFamily,
        ]);

        // Act
        final result = await repository.getGroupFamilies(testRealGroupId);

        // Assert
        expect(
          result.isOk,
          true,
          reason:
              'Should handle real group ID from patrol test: $testRealGroupId',
        );
        expect(result.value!.first.id, equals(testGroupFamily.id));
      });
    });
  });
}

// Manual fake for NetworkInfo to avoid Mockito conflicts with getters
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
class FakeGroupLocalDataSource implements GroupLocalDataSource {
  final Map<String, List<GroupFamily>> _cachedFamilies = {};

  void setCachedFamilies(String groupId, List<GroupFamily> families) {
    _cachedFamilies[groupId] = families;
  }

  @override
  Future<List<GroupFamily>?> getGroupFamilies(String groupId) async {
    return _cachedFamilies[groupId];
  }

  // Implement other required methods with noSuchMethod
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

// Mock HTTP-level RemoteDataSource that simulates HTTP responses
class MockHttpGroupRemoteDataSource extends Mock
    implements GroupRemoteDataSource {
  final Map<String, HttpSimulatedResponse> _responses = {};

  void setHttpResponse({
    required String groupId,
    required int statusCode,
    required List<GroupFamilyData> data,
  }) {
    final dataMaps = data.map((dto) => dto.toJson()).toList();
    _responses[groupId] = HttpSimulatedResponse.success(statusCode, dataMaps);
  }

  void setHttpException({
    required String groupId,
    required int statusCode,
    required String message,
    required bool isNetworkError,
  }) {
    _responses[groupId] = HttpSimulatedResponse.httpError(
      statusCode,
      message,
      isNetworkError,
    );
  }

  void setSocketException({required String groupId, required String message}) {
    _responses[groupId] = HttpSimulatedResponse.socketError(message);
  }

  void setTimeoutException({required String groupId, required String message}) {
    _responses[groupId] = HttpSimulatedResponse.timeoutError(message);
  }

  @override
  Future<List<GroupFamilyData>> getGroupFamilies(String groupId) async {
    final response = _responses[groupId];
    if (response == null) {
      throw Exception(
        'No response configured for group $groupId. Call set*Response() first.',
      );
    }

    return response.execute();
  }
}

// Helper class to simulate different HTTP response scenarios
class HttpSimulatedResponse {
  final int statusCode;
  final String message;
  final List<Map<String, dynamic>>? data;
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
  ) : data = null,
      exception = Exception('HTTP $statusCode: $message');

  HttpSimulatedResponse.socketError(this.message)
    : statusCode = 0,
      data = null,
      exception = SocketException(message),
      isNetworkError = true;

  HttpSimulatedResponse.timeoutError(this.message)
    : statusCode = 0,
      data = null,
      exception = Exception(message),
      isNetworkError = true;

  Future<List<GroupFamilyData>> execute() async {
    if (exception != null) {
      throw exception!;
    }
    return data!.map((json) => GroupFamilyData.fromJson(json)).toList();
  }
}
