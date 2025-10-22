import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';

import 'package:edulift/core/network/network_error_handler.dart';
import 'package:edulift/core/errors/exceptions.dart';

import '../../../test_mocks/test_mocks.dart';

/// Comprehensive unit tests for NetworkErrorHandler
///
/// This test suite covers:
/// - Retry logic with exponential backoff
/// - Circuit breaker patterns
/// - Cache strategies (networkOnly, cacheOnly, networkFirst, staleWhileRevalidate)
/// - HTTP 0 detection as network error
/// - onSuccess callback for automatic cache management
/// - Error transformation and classification
///
/// Following Principe 0: "L'utilisateur doit TOUJOURS pouvoir utiliser l'application, même en mode offline"
void main() {
  group('NetworkErrorHandler - Unit Tests', () {
    late NetworkErrorHandler handler;
    late MockNetworkInfo mockNetworkInfo;

    setUp(() {
      mockNetworkInfo = MockNetworkInfo();
      handler = NetworkErrorHandler(networkInfo: mockNetworkInfo);

      // Default: network is connected
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
    });

    group('Retry Logic', () {
      test('should succeed on first attempt when operation succeeds', () async {
        // Arrange
        var attemptCount = 0;
        Future<String> operation() async {
          attemptCount++;
          return 'success';
        }

        // Act
        final result = await handler.executeWithRetry(
          operation,
          operationName: 'test_operation',
        );

        // Assert
        expect(result, equals('success'));
        expect(
          attemptCount,
          equals(1),
          reason: 'Should succeed on first attempt',
        );
      });

      test('should retry retryable errors up to maxAttempts', () async {
        // Arrange
        var attemptCount = 0;
        Future<String> operation() async {
          attemptCount++;
          if (attemptCount < 3) {
            throw DioException(
              requestOptions: RequestOptions(path: '/test'),
              response: Response(
                requestOptions: RequestOptions(path: '/test'),
                statusCode: 503, // Service Unavailable - retryable
              ),
            );
          }
          return 'success';
        }

        // Act
        final result = await handler.executeWithRetry(
          operation,
          operationName: 'test_operation',
          config: const RetryConfig(initialDelay: Duration(milliseconds: 10)),
        );

        // Assert
        expect(result, equals('success'));
        expect(attemptCount, equals(3), reason: 'Should retry until success');
      });

      test('should stop retrying after maxAttempts', () async {
        // Arrange
        var attemptCount = 0;
        Future<String> operation() async {
          attemptCount++;
          throw DioException(
            requestOptions: RequestOptions(path: '/test'),
            response: Response(
              requestOptions: RequestOptions(path: '/test'),
              statusCode: 503, // Service Unavailable - retryable
            ),
          );
        }

        // Act & Assert
        await expectLater(
          handler.executeWithRetry(
            operation,
            operationName: 'test_operation',
            config: const RetryConfig(
              maxAttempts: 2,
              initialDelay: Duration(milliseconds: 10),
            ),
          ),
          throwsA(isA<Exception>()),
        );

        expect(
          attemptCount,
          equals(2),
          reason: 'Should stop after maxAttempts',
        );
      });

      test('should calculate exponential backoff correctly', () async {
        // Arrange
        var attemptCount = 0;

        Future<String> operation() async {
          attemptCount++;
          if (attemptCount < 4) {
            throw DioException(
              requestOptions: RequestOptions(path: '/test'),
              response: Response(
                requestOptions: RequestOptions(path: '/test'),
                statusCode: 503,
              ),
            );
          }
          return 'success';
        }

        // Capture delays by overriding the retry logic indirectly
        // We can only verify behavior through timing
        final startTime = DateTime.now();

        // Act
        await handler.executeWithRetry(
          operation,
          operationName: 'test_operation',
          config: const RetryConfig(
            maxAttempts: 4,
            initialDelay: Duration(milliseconds: 100),
          ),
        );

        final elapsedTime = DateTime.now().difference(startTime);

        // Assert
        expect(attemptCount, equals(4));
        // With exponential backoff: 100ms + 200ms + 400ms = 700ms minimum
        // We allow some margin for execution time
        expect(
          elapsedTime.inMilliseconds,
          greaterThan(600),
          reason: 'Should have exponential delays',
        );
      });

      group('Retryable Errors', () {
        test('should retry HTTP 408 (Request Timeout)', () async {
          // Arrange
          var attemptCount = 0;
          Future<String> operation() async {
            attemptCount++;
            if (attemptCount < 2) {
              throw DioException(
                requestOptions: RequestOptions(path: '/test'),
                response: Response(
                  requestOptions: RequestOptions(path: '/test'),
                  statusCode: 408,
                ),
              );
            }
            return 'success';
          }

          // Act
          final result = await handler.executeWithRetry(
            operation,
            operationName: 'test_operation',
            config: const RetryConfig(
              maxAttempts: 2,
              initialDelay: Duration(milliseconds: 10),
            ),
          );

          // Assert
          expect(result, equals('success'));
          expect(attemptCount, equals(2));
        });

        test('should retry HTTP 429 (Too Many Requests)', () async {
          // Arrange
          var attemptCount = 0;
          Future<String> operation() async {
            attemptCount++;
            if (attemptCount < 2) {
              throw DioException(
                requestOptions: RequestOptions(path: '/test'),
                response: Response(
                  requestOptions: RequestOptions(path: '/test'),
                  statusCode: 429,
                ),
              );
            }
            return 'success';
          }

          // Act
          final result = await handler.executeWithRetry(
            operation,
            operationName: 'test_operation',
            config: const RetryConfig(
              maxAttempts: 2,
              initialDelay: Duration(milliseconds: 10),
            ),
          );

          // Assert
          expect(result, equals('success'));
          expect(attemptCount, equals(2));
        });

        test('should retry HTTP 502 (Bad Gateway)', () async {
          // Arrange
          var attemptCount = 0;
          Future<String> operation() async {
            attemptCount++;
            if (attemptCount < 2) {
              throw DioException(
                requestOptions: RequestOptions(path: '/test'),
                response: Response(
                  requestOptions: RequestOptions(path: '/test'),
                  statusCode: 502,
                ),
              );
            }
            return 'success';
          }

          // Act
          final result = await handler.executeWithRetry(
            operation,
            operationName: 'test_operation',
            config: const RetryConfig(
              maxAttempts: 2,
              initialDelay: Duration(milliseconds: 10),
            ),
          );

          // Assert
          expect(result, equals('success'));
          expect(attemptCount, equals(2));
        });

        test('should retry HTTP 503 (Service Unavailable)', () async {
          // Arrange
          var attemptCount = 0;
          Future<String> operation() async {
            attemptCount++;
            if (attemptCount < 2) {
              throw DioException(
                requestOptions: RequestOptions(path: '/test'),
                response: Response(
                  requestOptions: RequestOptions(path: '/test'),
                  statusCode: 503,
                ),
              );
            }
            return 'success';
          }

          // Act
          final result = await handler.executeWithRetry(
            operation,
            operationName: 'test_operation',
            config: const RetryConfig(
              maxAttempts: 2,
              initialDelay: Duration(milliseconds: 10),
            ),
          );

          // Assert
          expect(result, equals('success'));
          expect(attemptCount, equals(2));
        });

        test('should retry HTTP 504 (Gateway Timeout)', () async {
          // Arrange
          var attemptCount = 0;
          Future<String> operation() async {
            attemptCount++;
            if (attemptCount < 2) {
              throw DioException(
                requestOptions: RequestOptions(path: '/test'),
                response: Response(
                  requestOptions: RequestOptions(path: '/test'),
                  statusCode: 504,
                ),
              );
            }
            return 'success';
          }

          // Act
          final result = await handler.executeWithRetry(
            operation,
            operationName: 'test_operation',
            config: const RetryConfig(
              maxAttempts: 2,
              initialDelay: Duration(milliseconds: 10),
            ),
          );

          // Assert
          expect(result, equals('success'));
          expect(attemptCount, equals(2));
        });

        test(
          'should transform SocketException to NetworkException (not retryable)',
          () async {
            // Arrange
            var attemptCount = 0;
            Future<String> operation() async {
              attemptCount++;
              throw const SocketException('Network is unreachable');
            }

            // Act & Assert - SocketException should be transformed to NetworkException
            // Note: SocketException itself is NOT retryable in the retry logic
            // It gets caught and transformed at the executeWithRetry level
            await expectLater(
              handler.executeWithRetry(
                operation,
                operationName: 'test_operation',
                config: const RetryConfig(
                  maxAttempts: 2,
                  initialDelay: Duration(milliseconds: 10),
                ),
              ),
              throwsA(isA<NetworkException>()),
            );

            expect(
              attemptCount,
              equals(1),
              reason: 'SocketException is not retryable directly',
            );
          },
        );

        test(
          'should transform TimeoutException to NetworkException (not retryable)',
          () async {
            // Arrange
            var attemptCount = 0;
            Future<String> operation() async {
              attemptCount++;
              throw TimeoutException('Connection timeout');
            }

            // Act & Assert - TimeoutException should be transformed to NetworkException
            // Note: TimeoutException itself is NOT retryable in the retry logic
            // It gets caught and transformed at the executeWithRetry level
            await expectLater(
              handler.executeWithRetry(
                operation,
                operationName: 'test_operation',
                config: const RetryConfig(
                  maxAttempts: 2,
                  initialDelay: Duration(milliseconds: 10),
                ),
              ),
              throwsA(isA<NetworkException>()),
            );

            expect(
              attemptCount,
              equals(1),
              reason: 'TimeoutException is not retryable directly',
            );
          },
        );

        test('should retry HTTP 0 (network error)', () async {
          // Arrange
          var attemptCount = 0;
          Future<String> operation() async {
            attemptCount++;
            if (attemptCount < 2) {
              throw DioException(
                requestOptions: RequestOptions(path: '/test'),
                response: Response(
                  requestOptions: RequestOptions(path: '/test'),
                  statusCode: 0, // HTTP 0 indicates network error
                ),
              );
            }
            return 'success';
          }

          // Act
          final result = await handler.executeWithRetry(
            operation,
            operationName: 'test_operation',
            config: const RetryConfig(
              maxAttempts: 2,
              initialDelay: Duration(milliseconds: 10),
            ),
          );

          // Assert
          expect(result, equals('success'));
          expect(attemptCount, equals(2), reason: 'HTTP 0 should be retryable');
        });
      });

      group('Non-Retryable Errors', () {
        test('should NOT retry HTTP 400 (Bad Request)', () async {
          // Arrange
          var attemptCount = 0;
          Future<String> operation() async {
            attemptCount++;
            throw DioException(
              requestOptions: RequestOptions(path: '/test'),
              response: Response(
                requestOptions: RequestOptions(path: '/test'),
                statusCode: 400,
              ),
              type: DioExceptionType.badResponse,
            );
          }

          // Act & Assert
          await expectLater(
            handler.executeWithRetry(
              operation,
              operationName: 'test_operation',
              config: const RetryConfig(
                initialDelay: Duration(milliseconds: 10),
              ),
            ),
            throwsA(isA<NetworkException>()),
          );

          expect(attemptCount, equals(1), reason: 'Should not retry HTTP 400');
        });

        test('should NOT retry HTTP 401 (Unauthorized)', () async {
          // Arrange
          var attemptCount = 0;
          Future<String> operation() async {
            attemptCount++;
            throw DioException(
              requestOptions: RequestOptions(path: '/test'),
              response: Response(
                requestOptions: RequestOptions(path: '/test'),
                statusCode: 401,
              ),
              type: DioExceptionType.badResponse,
            );
          }

          // Act & Assert
          await expectLater(
            handler.executeWithRetry(
              operation,
              operationName: 'test_operation',
              config: const RetryConfig(
                initialDelay: Duration(milliseconds: 10),
              ),
            ),
            throwsA(isA<AuthenticationException>()),
          );

          expect(attemptCount, equals(1), reason: 'Should not retry HTTP 401');
        });

        test('should NOT retry HTTP 403 (Forbidden)', () async {
          // Arrange
          var attemptCount = 0;
          Future<String> operation() async {
            attemptCount++;
            throw DioException(
              requestOptions: RequestOptions(path: '/test'),
              response: Response(
                requestOptions: RequestOptions(path: '/test'),
                statusCode: 403,
              ),
              type: DioExceptionType.badResponse,
            );
          }

          // Act & Assert
          await expectLater(
            handler.executeWithRetry(
              operation,
              operationName: 'test_operation',
              config: const RetryConfig(
                initialDelay: Duration(milliseconds: 10),
              ),
            ),
            throwsA(isA<AuthorizationException>()),
          );

          expect(attemptCount, equals(1), reason: 'Should not retry HTTP 403');
        });

        test('should NOT retry HTTP 404 (Not Found)', () async {
          // Arrange
          var attemptCount = 0;
          Future<String> operation() async {
            attemptCount++;
            throw DioException(
              requestOptions: RequestOptions(path: '/test'),
              response: Response(
                requestOptions: RequestOptions(path: '/test'),
                statusCode: 404,
              ),
              type: DioExceptionType.badResponse,
            );
          }

          // Act & Assert
          await expectLater(
            handler.executeWithRetry(
              operation,
              operationName: 'test_operation',
              config: const RetryConfig(
                initialDelay: Duration(milliseconds: 10),
              ),
            ),
            throwsA(isA<ServerException>()),
          );

          expect(attemptCount, equals(1), reason: 'Should not retry HTTP 404');
        });
      });
    });

    group('Circuit Breaker', () {
      test('should be closed initially (normal operation)', () async {
        // Arrange
        Future<String> operation() async => 'success';

        // Act
        final result = await handler.executeWithRetry(
          operation,
          operationName: 'test_operation',
          serviceName: 'test_service',
        );

        // Assert
        expect(result, equals('success'));
        final status = handler.getCircuitStatus();
        expect(
          status['circuitBreakers']['test_service']['state'],
          equals('closed'),
        );
      });

      test('should open circuit after failure threshold', () async {
        // Arrange
        Future<String> operation() async {
          throw DioException(
            requestOptions: RequestOptions(path: '/test'),
            response: Response(
              requestOptions: RequestOptions(path: '/test'),
              statusCode: 500,
            ),
          );
        }

        // Act - Execute 5 times to trigger circuit breaker (threshold = 5)
        for (var i = 0; i < 5; i++) {
          try {
            await handler.executeWithRetry(
              operation,
              operationName: 'test_operation',
              serviceName: 'test_service',
              config: const RetryConfig(
                maxAttempts: 1,
                initialDelay: Duration(milliseconds: 10),
              ),
            );
          } catch (_) {
            // Expected to fail
          }
        }

        // Assert
        final status = handler.getCircuitStatus();
        expect(
          status['circuitBreakers']['test_service']['state'],
          equals('open'),
          reason: 'Circuit should open after 5 failures',
        );
        expect(
          status['circuitBreakers']['test_service']['failureCount'],
          equals(5),
        );
      });

      test('should reject requests when circuit is open', () async {
        // Arrange - Open the circuit
        Future<String> failingOperation() async {
          throw DioException(
            requestOptions: RequestOptions(path: '/test'),
            response: Response(
              requestOptions: RequestOptions(path: '/test'),
              statusCode: 500,
            ),
          );
        }

        for (var i = 0; i < 5; i++) {
          try {
            await handler.executeWithRetry(
              failingOperation,
              operationName: 'test_operation',
              serviceName: 'test_service',
              config: const RetryConfig(
                maxAttempts: 1,
                initialDelay: Duration(milliseconds: 10),
              ),
            );
          } catch (_) {
            // Expected to fail
          }
        }

        // Act & Assert - Next request should be rejected immediately
        await expectLater(
          handler.executeWithRetry(
            () async => 'success',
            operationName: 'test_operation',
            serviceName: 'test_service',
          ),
          throwsA(
            isA<NetworkException>().having(
              (e) => e.message,
              'message',
              contains('Circuit breaker is OPEN'),
            ),
          ),
        );
      });

      test('should transition to half-open after recovery timeout', () async {
        // Arrange - Open the circuit
        Future<String> failingOperation() async {
          throw DioException(
            requestOptions: RequestOptions(path: '/test'),
            response: Response(
              requestOptions: RequestOptions(path: '/test'),
              statusCode: 500,
            ),
          );
        }

        // Manually create and configure circuit breaker with short timeout
        final breaker = NetworkCircuitBreaker(
          serviceName: 'test_service',
          failureThreshold: 2,
          recoveryTimeout: const Duration(milliseconds: 100),
        );

        // Trigger failures to open circuit
        for (var i = 0; i < 2; i++) {
          try {
            await breaker.execute(() => failingOperation());
          } catch (_) {
            // Expected to fail
          }
        }

        expect(breaker.state, equals(CircuitState.open));

        // Wait for recovery timeout
        await Future.delayed(const Duration(milliseconds: 150));

        // Act - Execute successful operation
        final result = await breaker.execute(() async => 'success');

        // Assert
        expect(result, equals('success'));
        expect(
          breaker.state,
          equals(CircuitState.closed),
          reason: 'Circuit should close after successful half-open test',
        );
      });

      test('should reset circuit breaker manually', () async {
        // Arrange - Open the circuit
        Future<String> failingOperation() async {
          throw DioException(
            requestOptions: RequestOptions(path: '/test'),
            response: Response(
              requestOptions: RequestOptions(path: '/test'),
              statusCode: 500,
            ),
          );
        }

        for (var i = 0; i < 5; i++) {
          try {
            await handler.executeWithRetry(
              failingOperation,
              operationName: 'test_operation',
              serviceName: 'test_service',
              config: const RetryConfig(
                maxAttempts: 1,
                initialDelay: Duration(milliseconds: 10),
              ),
            );
          } catch (_) {
            // Expected to fail
          }
        }

        var status = handler.getCircuitStatus();
        expect(
          status['circuitBreakers']['test_service']['state'],
          equals('open'),
        );

        // Act - Reset circuit breaker
        handler.resetCircuitBreaker('test_service');

        // Assert
        status = handler.getCircuitStatus();
        expect(
          status['circuitBreakers']['test_service']['state'],
          equals('closed'),
          reason: 'Circuit should be closed after manual reset',
        );
        expect(
          status['circuitBreakers']['test_service']['failureCount'],
          equals(0),
        );
      });
    });

    group('CacheStrategy - networkOnly', () {
      test('should return data on network success', () async {
        // Arrange
        final testData = {'id': '123', 'name': 'Test'};
        Future<Map<String, dynamic>> remoteOperation() async => testData;

        // Act
        final result = await handler.executeRepositoryOperation(
          remoteOperation,
          operationName: 'test_operation',
          strategy: CacheStrategy.networkOnly,
        );

        // Assert
        expect(result.isOk, true);
        expect(result.value, equals(testData));
      });

      test('should fail without cache fallback on network error', () async {
        // Arrange
        Future<Map<String, dynamic>> remoteOperation() async {
          throw const SocketException('Network is unreachable');
        }

        Future<Map<String, dynamic>> cacheOperation() async {
          return {'id': 'cached', 'name': 'Cached Data'};
        }

        // Act
        final result = await handler.executeRepositoryOperation(
          remoteOperation,
          operationName: 'test_operation',
          strategy: CacheStrategy.networkOnly,
          cacheOperation: cacheOperation,
        );

        // Assert
        expect(
          result.isErr,
          true,
          reason: 'networkOnly should not use cache fallback',
        );
        expect(result.error!.code, contains('network'));
      });

      test('should call onSuccess after network success', () async {
        // Arrange
        final testData = {'id': '123', 'name': 'Test'};
        var onSuccessCalled = false;
        Map<String, dynamic>? cachedData;

        Future<Map<String, dynamic>> remoteOperation() async => testData;

        Future<void> onSuccess(Map<String, dynamic> data) async {
          onSuccessCalled = true;
          cachedData = data;
        }

        // Act
        final result = await handler.executeRepositoryOperation(
          remoteOperation,
          operationName: 'test_operation',
          strategy: CacheStrategy.networkOnly,
          onSuccess: onSuccess,
        );

        // Assert
        expect(result.isOk, true);
        expect(onSuccessCalled, true, reason: 'onSuccess should be called');
        expect(cachedData, equals(testData));
      });

      test('should not fail operation if onSuccess throws error', () async {
        // Arrange
        final testData = {'id': '123', 'name': 'Test'};

        Future<Map<String, dynamic>> remoteOperation() async => testData;

        Future<void> onSuccess(Map<String, dynamic> data) async {
          throw Exception('Cache write failed');
        }

        // Act
        final result = await handler.executeRepositoryOperation(
          remoteOperation,
          operationName: 'test_operation',
          strategy: CacheStrategy.networkOnly,
          onSuccess: onSuccess,
        );

        // Assert
        expect(
          result.isOk,
          true,
          reason: 'Operation should succeed even if cache write fails',
        );
        expect(result.value, equals(testData));
      });
    });

    group('CacheStrategy - cacheOnly', () {
      test('should return cached data successfully', () async {
        // Arrange
        final cachedData = {'id': 'cached', 'name': 'Cached Data'};

        Future<Map<String, dynamic>> cacheOperation() async => cachedData;

        // Act
        final result = await handler.executeRepositoryOperation(
          () async => throw Exception('Should not call network'),
          operationName: 'test_operation',
          strategy: CacheStrategy.cacheOnly,
          cacheOperation: cacheOperation,
        );

        // Assert
        expect(result.isOk, true);
        expect(result.value, equals(cachedData));
      });

      test('should fail when cache is empty', () async {
        // Arrange
        Future<Map<String, dynamic>> cacheOperation() async {
          throw Exception('Cache miss');
        }

        // Act
        final result = await handler.executeRepositoryOperation(
          () async => {'id': 'network', 'name': 'Network Data'},
          operationName: 'test_operation',
          strategy: CacheStrategy.cacheOnly,
          cacheOperation: cacheOperation,
        );

        // Assert
        expect(result.isErr, true, reason: 'Should fail when cache is empty');
      });

      test('should fail when cacheOperation is not provided', () async {
        // Act
        final result = await handler.executeRepositoryOperation(
          () async => {'id': 'network', 'name': 'Network Data'},
          operationName: 'test_operation',
          strategy: CacheStrategy.cacheOnly,
          // No cacheOperation provided
        );

        // Assert
        expect(result.isErr, true);
        expect(result.error!.code, equals('cache.not_configured'));
      });
    });

    group('CacheStrategy - networkFirst', () {
      test('should return network data on success', () async {
        // Arrange
        final networkData = {'id': 'network', 'name': 'Network Data'};

        Future<Map<String, dynamic>> remoteOperation() async => networkData;

        Future<Map<String, dynamic>> cacheOperation() async {
          return {'id': 'cached', 'name': 'Cached Data'};
        }

        // Act
        final result = await handler.executeRepositoryOperation(
          remoteOperation,
          operationName: 'test_operation',
          strategy: CacheStrategy.networkFirst,
          cacheOperation: cacheOperation,
        );

        // Assert
        expect(result.isOk, true);
        expect(result.value, equals(networkData));
      });

      test('should fallback to cache on network error (HTTP 0)', () async {
        // Arrange
        final cachedData = {'id': 'cached', 'name': 'Cached Data'};

        Future<Map<String, dynamic>> remoteOperation() async {
          throw DioException(
            requestOptions: RequestOptions(path: '/test'),
            response: Response(
              requestOptions: RequestOptions(path: '/test'),
              statusCode: 0, // HTTP 0 = network error
            ),
          );
        }

        Future<Map<String, dynamic>> cacheOperation() async => cachedData;

        // Act
        final result = await handler.executeRepositoryOperation(
          remoteOperation,
          operationName: 'test_operation',
          strategy: CacheStrategy.networkFirst,
          cacheOperation: cacheOperation,
          config: const RetryConfig(
            maxAttempts: 1,
            initialDelay: Duration(milliseconds: 10),
          ),
        );

        // Assert
        expect(
          result.isOk,
          true,
          reason: 'HTTP 0 should trigger cache fallback',
        );
        expect(result.value, equals(cachedData));
      });

      test('should fallback to cache on SocketException', () async {
        // Arrange
        final cachedData = {'id': 'cached', 'name': 'Cached Data'};

        Future<Map<String, dynamic>> remoteOperation() async {
          throw const SocketException('Network is unreachable');
        }

        Future<Map<String, dynamic>> cacheOperation() async => cachedData;

        // Act
        final result = await handler.executeRepositoryOperation(
          remoteOperation,
          operationName: 'test_operation',
          strategy: CacheStrategy.networkFirst,
          cacheOperation: cacheOperation,
          config: const RetryConfig(
            maxAttempts: 1,
            initialDelay: Duration(milliseconds: 10),
          ),
        );

        // Assert
        expect(result.isOk, true);
        expect(result.value, equals(cachedData));
      });

      test('should NOT fallback to cache on server error (HTTP 500)', () async {
        // Arrange - Use ServerException directly since that's what executeWithRetry produces
        Future<Map<String, dynamic>> remoteOperation() async {
          throw const ServerException(
            'The server is experiencing issues. Please try again later.',
            statusCode: 500,
          );
        }

        Future<Map<String, dynamic>> cacheOperation() async {
          return {'id': 'cached', 'name': 'Cached Data'};
        }

        // Act
        final result = await handler.executeRepositoryOperation(
          remoteOperation,
          operationName: 'test_operation',
          strategy: CacheStrategy.networkFirst,
          cacheOperation: cacheOperation,
          config: const RetryConfig(
            maxAttempts: 1,
            initialDelay: Duration(milliseconds: 10),
          ),
        );

        // Assert
        expect(
          result.isErr,
          true,
          reason: 'HTTP 500 should NOT use cache fallback',
        );
        expect(result.error!.code, equals('api.server_error'));
      });

      test('should call onSuccess after network success', () async {
        // Arrange
        final networkData = {'id': 'network', 'name': 'Network Data'};
        var onSuccessCalled = false;

        Future<Map<String, dynamic>> remoteOperation() async => networkData;

        Future<void> onSuccess(Map<String, dynamic> data) async {
          onSuccessCalled = true;
        }

        // Act
        final result = await handler.executeRepositoryOperation(
          remoteOperation,
          operationName: 'test_operation',
          strategy: CacheStrategy.networkFirst,
          onSuccess: onSuccess,
        );

        // Assert
        expect(result.isOk, true);
        expect(
          onSuccessCalled,
          true,
          reason: 'onSuccess should be called after network success',
        );
      });

      test('should NOT call onSuccess when using cache fallback', () async {
        // Arrange
        final cachedData = {'id': 'cached', 'name': 'Cached Data'};
        var onSuccessCalled = false;

        Future<Map<String, dynamic>> remoteOperation() async {
          throw const SocketException('Network is unreachable');
        }

        Future<Map<String, dynamic>> cacheOperation() async => cachedData;

        Future<void> onSuccess(Map<String, dynamic> data) async {
          onSuccessCalled = true;
        }

        // Act
        final result = await handler.executeRepositoryOperation(
          remoteOperation,
          operationName: 'test_operation',
          strategy: CacheStrategy.networkFirst,
          cacheOperation: cacheOperation,
          onSuccess: onSuccess,
          config: const RetryConfig(
            maxAttempts: 1,
            initialDelay: Duration(milliseconds: 10),
          ),
        );

        // Assert
        expect(result.isOk, true);
        expect(
          onSuccessCalled,
          false,
          reason: 'onSuccess should NOT be called for cache fallback',
        );
      });
    });

    group('CacheStrategy - staleWhileRevalidate', () {
      test('should return fresh data when network succeeds', () async {
        // Arrange
        final cachedData = {'id': 'cached', 'name': 'Cached Data'};
        final freshData = {'id': 'fresh', 'name': 'Fresh Data'};

        Future<Map<String, dynamic>> remoteOperation() async => freshData;

        Future<Map<String, dynamic>> cacheOperation() async => cachedData;

        // Act
        final result = await handler.executeRepositoryOperation(
          remoteOperation,
          operationName: 'test_operation',
          strategy: CacheStrategy.staleWhileRevalidate,
          cacheOperation: cacheOperation,
        );

        // Assert
        expect(result.isOk, true);
        expect(
          result.value,
          equals(freshData),
          reason: 'Should return fresh data when network succeeds',
        );
      });

      test('should return stale cache on network error', () async {
        // Arrange
        final cachedData = {'id': 'cached', 'name': 'Cached Data'};

        Future<Map<String, dynamic>> remoteOperation() async {
          throw const SocketException('Network is unreachable');
        }

        Future<Map<String, dynamic>> cacheOperation() async => cachedData;

        // Act
        final result = await handler.executeRepositoryOperation(
          remoteOperation,
          operationName: 'test_operation',
          strategy: CacheStrategy.staleWhileRevalidate,
          cacheOperation: cacheOperation,
          config: const RetryConfig(
            maxAttempts: 1,
            initialDelay: Duration(milliseconds: 10),
          ),
        );

        // Assert
        expect(result.isOk, true);
        expect(
          result.value,
          equals(cachedData),
          reason: 'Should return stale cache on network error',
        );
      });

      test('should NOT return cache on server error', () async {
        // Arrange
        final cachedData = {'id': 'cached', 'name': 'Cached Data'};

        Future<Map<String, dynamic>> remoteOperation() async {
          throw DioException(
            requestOptions: RequestOptions(path: '/test'),
            response: Response(
              requestOptions: RequestOptions(path: '/test'),
              statusCode: 500,
            ),
            type: DioExceptionType
                .badResponse, // Required to prevent treating as network error
          );
        }

        Future<Map<String, dynamic>> cacheOperation() async => cachedData;

        // Act
        final result = await handler.executeRepositoryOperation(
          remoteOperation,
          operationName: 'test_operation',
          strategy: CacheStrategy.staleWhileRevalidate,
          cacheOperation: cacheOperation,
          config: const RetryConfig(
            maxAttempts: 1,
            initialDelay: Duration(milliseconds: 10),
          ),
        );

        // Assert
        expect(
          result.isErr,
          true,
          reason: 'Server error should NOT return stale cache',
        );
      });

      test('should fallback to network-only when cache fails', () async {
        // Arrange
        final freshData = {'id': 'fresh', 'name': 'Fresh Data'};

        Future<Map<String, dynamic>> remoteOperation() async => freshData;

        Future<Map<String, dynamic>> cacheOperation() async {
          throw Exception('Cache read failed');
        }

        // Act
        final result = await handler.executeRepositoryOperation(
          remoteOperation,
          operationName: 'test_operation',
          strategy: CacheStrategy.staleWhileRevalidate,
          cacheOperation: cacheOperation,
        );

        // Assert
        expect(result.isOk, true);
        expect(
          result.value,
          equals(freshData),
          reason: 'Should fetch from network when cache fails',
        );
      });

      test('should call onSuccess with fresh data', () async {
        // Arrange
        final cachedData = {'id': 'cached', 'name': 'Cached Data'};
        final freshData = {'id': 'fresh', 'name': 'Fresh Data'};
        var onSuccessCalled = false;
        Map<String, dynamic>? savedData;

        Future<Map<String, dynamic>> remoteOperation() async => freshData;

        Future<Map<String, dynamic>> cacheOperation() async => cachedData;

        Future<void> onSuccess(Map<String, dynamic> data) async {
          onSuccessCalled = true;
          savedData = data;
        }

        // Act
        final result = await handler.executeRepositoryOperation(
          remoteOperation,
          operationName: 'test_operation',
          strategy: CacheStrategy.staleWhileRevalidate,
          cacheOperation: cacheOperation,
          onSuccess: onSuccess,
        );

        // Assert
        expect(result.isOk, true);
        expect(
          onSuccessCalled,
          true,
          reason: 'onSuccess should be called with fresh data',
        );
        expect(savedData, equals(freshData));
      });

      test('should NOT call onSuccess when returning stale cache', () async {
        // Arrange
        final cachedData = {'id': 'cached', 'name': 'Cached Data'};
        var onSuccessCalled = false;

        Future<Map<String, dynamic>> remoteOperation() async {
          throw const SocketException('Network is unreachable');
        }

        Future<Map<String, dynamic>> cacheOperation() async => cachedData;

        Future<void> onSuccess(Map<String, dynamic> data) async {
          onSuccessCalled = true;
        }

        // Act
        final result = await handler.executeRepositoryOperation(
          remoteOperation,
          operationName: 'test_operation',
          strategy: CacheStrategy.staleWhileRevalidate,
          cacheOperation: cacheOperation,
          onSuccess: onSuccess,
          config: const RetryConfig(
            maxAttempts: 1,
            initialDelay: Duration(milliseconds: 10),
          ),
        );

        // Assert
        expect(result.isOk, true);
        expect(
          onSuccessCalled,
          false,
          reason: 'onSuccess should NOT be called for stale cache',
        );
      });
    });

    group('HTTP 0 Detection', () {
      test('should detect HTTP 0 as network error', () async {
        // Arrange
        final cachedData = {'id': 'cached', 'name': 'Cached Data'};

        Future<Map<String, dynamic>> remoteOperation() async {
          throw DioException(
            requestOptions: RequestOptions(path: '/test'),
            response: Response(
              requestOptions: RequestOptions(path: '/test'),
              statusCode: 0,
            ),
          );
        }

        Future<Map<String, dynamic>> cacheOperation() async => cachedData;

        // Act
        final result = await handler.executeRepositoryOperation(
          remoteOperation,
          operationName: 'test_operation',
          strategy: CacheStrategy.networkFirst,
          cacheOperation: cacheOperation,
          config: const RetryConfig(
            maxAttempts: 1,
            initialDelay: Duration(milliseconds: 10),
          ),
        );

        // Assert
        expect(
          result.isOk,
          true,
          reason:
              'HTTP 0 should be treated as network error with cache fallback',
        );
        expect(result.value, equals(cachedData));
      });

      test('should be retryable', () async {
        // Arrange
        var attemptCount = 0;

        Future<String> operation() async {
          attemptCount++;
          if (attemptCount < 2) {
            throw DioException(
              requestOptions: RequestOptions(path: '/test'),
              response: Response(
                requestOptions: RequestOptions(path: '/test'),
                statusCode: 0,
              ),
            );
          }
          return 'success';
        }

        // Act
        final result = await handler.executeWithRetry(
          operation,
          operationName: 'test_operation',
          config: const RetryConfig(
            maxAttempts: 2,
            initialDelay: Duration(milliseconds: 10),
          ),
        );

        // Assert
        expect(result, equals('success'));
        expect(attemptCount, equals(2), reason: 'HTTP 0 should be retryable');
      });
    });

    group('Error Transformation', () {
      test('should transform SocketException to NetworkException', () async {
        // Arrange
        Future<String> operation() async {
          throw const SocketException('Connection failed');
        }

        // Act & Assert
        await expectLater(
          handler.executeWithRetry(
            operation,
            operationName: 'test_operation',
            config: const RetryConfig(maxAttempts: 1),
          ),
          throwsA(
            isA<NetworkException>().having(
              (e) => e.message,
              'message',
              contains('Unable to connect to the server'),
            ),
          ),
        );
      });

      test('should transform TimeoutException to NetworkException', () async {
        // Arrange
        Future<String> operation() async {
          throw TimeoutException('Request timeout');
        }

        // Act & Assert
        await expectLater(
          handler.executeWithRetry(
            operation,
            operationName: 'test_operation',
            config: const RetryConfig(maxAttempts: 1),
          ),
          throwsA(
            isA<NetworkException>().having(
              (e) => e.message,
              'message',
              contains('Request timed out'),
            ),
          ),
        );
      });

      test('should transform HTTP 401 to AuthenticationException', () async {
        // Arrange
        Future<String> operation() async {
          throw DioException(
            requestOptions: RequestOptions(path: '/test'),
            response: Response(
              requestOptions: RequestOptions(path: '/test'),
              statusCode: 401,
            ),
            type: DioExceptionType.badResponse,
          );
        }

        // Act & Assert - Use executeWithRetry for proper transformation
        await expectLater(
          handler.executeWithRetry(
            operation,
            operationName: 'test_operation',
            config: const RetryConfig(maxAttempts: 1),
          ),
          throwsA(
            isA<AuthenticationException>().having(
              (e) => e.message,
              'message',
              contains('session has expired'),
            ),
          ),
        );
      });

      test('should transform HTTP 403 to AuthorizationException', () async {
        // Arrange
        Future<String> operation() async {
          throw DioException(
            requestOptions: RequestOptions(path: '/test'),
            response: Response(
              requestOptions: RequestOptions(path: '/test'),
              statusCode: 403,
            ),
            type: DioExceptionType.badResponse,
          );
        }

        // Act & Assert - Use executeWithRetry for proper transformation
        await expectLater(
          handler.executeWithRetry(
            operation,
            operationName: 'test_operation',
            config: const RetryConfig(maxAttempts: 1),
          ),
          throwsA(
            isA<AuthorizationException>().having(
              (e) => e.message,
              'message',
              contains('permission'),
            ),
          ),
        );
      });

      test('should transform HTTP 404 to ServerException', () async {
        // Arrange
        Future<String> operation() async {
          throw DioException(
            requestOptions: RequestOptions(path: '/test'),
            response: Response(
              requestOptions: RequestOptions(path: '/test'),
              statusCode: 404,
            ),
            type: DioExceptionType.badResponse,
          );
        }

        // Act & Assert - Use executeWithRetry for proper transformation
        await expectLater(
          handler.executeWithRetry(
            operation,
            operationName: 'test_operation',
            config: const RetryConfig(maxAttempts: 1),
          ),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              contains('not found'),
            ),
          ),
        );
      });

      test('should transform HTTP 500+ to ServerException', () async {
        // Arrange
        Future<String> operation() async {
          throw DioException(
            requestOptions: RequestOptions(path: '/test'),
            response: Response(
              requestOptions: RequestOptions(path: '/test'),
              statusCode: 500,
            ),
            type: DioExceptionType.badResponse,
          );
        }

        // Act & Assert - Use executeWithRetry for proper transformation
        await expectLater(
          handler.executeWithRetry(
            operation,
            operationName: 'test_operation',
            config: const RetryConfig(maxAttempts: 1),
          ),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              contains('server'),
            ),
          ),
        );
      });
    });

    group('Network Connectivity', () {
      test(
        'should throw NetworkException when no internet connection',
        () async {
          // Arrange
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

          Future<String> operation() async => 'success';

          // Act & Assert
          await expectLater(
            handler.executeWithRetry(
              operation,
              operationName: 'test_operation',
            ),
            throwsA(
              isA<NetworkException>().having(
                (e) => e.message,
                'message',
                contains('No internet connection'),
              ),
            ),
          );
        },
      );
    });
  });
}
