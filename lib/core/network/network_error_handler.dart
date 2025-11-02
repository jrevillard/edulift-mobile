import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../utils/app_logger.dart';
import '../utils/result.dart';
import '../errors/exceptions.dart';
import '../errors/api_exception.dart';
import '../errors/failures.dart';
import '../network/api_response_helper.dart';
import '../network/network_info.dart';
import '../network/models/common/api_response_wrapper.dart';
import '../config/feature_flags.dart';

/// Cache strategy patterns for repository operations
///
/// Defines how repositories should handle cache vs network data.
/// Each strategy provides different tradeoffs between freshness,
/// speed, and offline capability.
enum CacheStrategy {
  /// Network-only: Always fetch from network, no cache involved
  ///
  /// **Behavior:**
  /// - Fetch data from network
  /// - No cache read or write
  /// - Fails if network unavailable
  ///
  /// **Use cases:**
  /// - Write operations (POST, PUT, DELETE)
  /// - Operations that must be executed on server
  /// - When data must be absolutely fresh
  ///
  /// **Example:**
  /// ```dart
  /// strategy: CacheStrategy.networkOnly // For createFamily()
  /// ```
  networkOnly,

  /// Cache-only: Always use cache, never network
  ///
  /// **Behavior:**
  /// - Read data from cache only
  /// - No network request
  /// - Fails if cache is empty
  ///
  /// **Use cases:**
  /// - Offline mode
  /// - Testing with fixed data
  /// - When network is known to be unavailable
  ///
  /// **Example:**
  /// ```dart
  /// strategy: CacheStrategy.cacheOnly // For offline mode
  /// ```
  cacheOnly,

  /// Network-first: Try network first, fallback to cache on network error
  ///
  /// **Behavior:**
  /// 1. Try network first (with retry)
  /// 2. If network fails with connectivity error (HTTP 0, timeout):
  ///    - Fallback to cache
  /// 3. If network fails with server error (4xx, 5xx):
  ///    - Do NOT use cache, propagate error
  ///
  /// **Use cases:**
  /// - Critical data that should be fresh
  /// - When stale cache is acceptable only as fallback
  /// - Operations where freshness is important but offline support needed
  ///
  /// **Example:**
  /// ```dart
  /// strategy: CacheStrategy.networkFirst // For getPaymentMethods()
  /// ```
  networkFirst,

  /// Stale-While-Revalidate: Return cache immediately, then fetch fresh data
  ///
  /// **Behavior:**
  /// 1. Read cache first (fast, instant UI)
  /// 2. Try network in parallel/after
  /// 3. If network succeeds:
  ///    - Return fresh network data (replaces cache)
  ///    - Update cache in background
  /// 4. If network fails with connectivity error:
  ///    - Return stale cache (already read)
  /// 5. If network fails with server error:
  ///    - Do NOT return cache, propagate error
  ///
  /// **Use cases:**
  /// - Read operations for UI display
  /// - When instant UI response is critical
  /// - When eventual consistency is acceptable
  /// - Most GET operations
  ///
  /// **Example:**
  /// ```dart
  /// strategy: CacheStrategy.staleWhileRevalidate // For getCurrentFamily()
  /// ```
  staleWhileRevalidate,

  // NOTE: cacheThenNetwork is NOT implemented because it requires
  // Stream<Result<T>> instead of Future<Result<T>>.
  // This will be added in Phase 2 when we migrate to Stream-based repositories.
}

/// Configuration for retry behavior
class RetryConfig {
  final int maxAttempts;
  final Duration initialDelay;
  final double backoffMultiplier;
  final Duration maxDelay;
  final Set<int> retryableStatusCodes;

  const RetryConfig({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(milliseconds: 1000),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(seconds: 30),
    this.retryableStatusCodes = const {
      408, // Request Timeout
      429, // Too Many Requests
      502, // Bad Gateway
      503, // Service Unavailable
      504, // Gateway Timeout
    },
  });

  /// Default configuration for quick operations
  static const quick = RetryConfig(
    maxAttempts: 2,
    initialDelay: Duration(milliseconds: 500),
    maxDelay: Duration(seconds: 5),
  );

  /// Configuration for critical operations
  static const critical = RetryConfig(
    maxAttempts: 5,
    maxDelay: Duration(seconds: 60),
  );

  /// Configuration for background operations
  static const background = RetryConfig(
    maxAttempts: 10,
    initialDelay: Duration(seconds: 2),
    maxDelay: Duration(minutes: 5),
  );
}

/// Circuit breaker states
enum CircuitState {
  closed, // Normal operation
  open, // Rejecting requests
  halfOpen, // Testing if service has recovered
}

/// Circuit breaker for preventing cascading failures
class NetworkCircuitBreaker {
  final int failureThreshold;
  final Duration recoveryTimeout;
  final String serviceName;

  int _failureCount = 0;
  CircuitState _state = CircuitState.closed;
  DateTime? _lastFailureTime;

  NetworkCircuitBreaker({
    required this.serviceName,
    this.failureThreshold = 5,
    this.recoveryTimeout = const Duration(minutes: 1),
  });

  /// Execute operation with circuit breaker protection
  Future<T> execute<T>(
    Future<T> Function() operation, {
    Duration? timeout,
  }) async {
    if (_state == CircuitState.open) {
      if (_shouldAttemptReset()) {
        _state = CircuitState.halfOpen;
        AppLogger.info('[CIRCUIT] Half-open state for $serviceName');
      } else {
        throw NetworkException(
          'Circuit breaker is OPEN for $serviceName. Service temporarily unavailable.',
        );
      }
    }

    try {
      final result = await _executeWithTimeout(operation, timeout);
      _onSuccess();
      return result;
    } catch (error) {
      _onFailure();
      rethrow;
    }
  }

  bool _shouldAttemptReset() {
    return _lastFailureTime != null &&
        DateTime.now().difference(_lastFailureTime!) >= recoveryTimeout;
  }

  Future<T> _executeWithTimeout<T>(
    Future<T> Function() operation,
    Duration? timeout,
  ) async {
    if (timeout != null) {
      return await operation().timeout(timeout);
    }
    return await operation();
  }

  void _onSuccess() {
    _failureCount = 0;
    if (_state == CircuitState.halfOpen) {
      _state = CircuitState.closed;
      AppLogger.info('[CIRCUIT] Circuit closed again for $serviceName');
    }
  }

  void _onFailure() {
    _failureCount++;
    _lastFailureTime = DateTime.now();

    if (_failureCount >= failureThreshold) {
      _state = CircuitState.open;
      AppLogger.warning(
        '[CIRCUIT] Circuit opened for $serviceName after $_failureCount failures',
      );
    }
  }

  /// Get current circuit state
  CircuitState get state => _state;

  /// Reset circuit breaker manually
  void reset() {
    _failureCount = 0;
    _state = CircuitState.closed;
    _lastFailureTime = null;
    AppLogger.info('[CIRCUIT] Circuit manually reset for $serviceName');
  }

  /// Get circuit status for monitoring
  Map<String, dynamic> get status => {
    'service': serviceName,
    'state': _state.name,
    'failureCount': _failureCount,
    'failureThreshold': failureThreshold,
    'lastFailureTime': _lastFailureTime?.toIso8601String(),
    'isOpen': _state == CircuitState.open,
  };
}

/// Centralized network error handling service
///
/// This service provides a unified approach to handling network errors with:
/// - Automatic retry with exponential backoff
/// - Circuit breaker pattern for resilience
/// - Clear error classification and user-friendly messages
/// - Proper error propagation following Clean Architecture
/// - Comprehensive logging and monitoring
class NetworkErrorHandler {
  final NetworkInfo _networkInfo;
  final Map<String, NetworkCircuitBreaker> _circuitBreakers = {};

  NetworkErrorHandler({
    required NetworkInfo networkInfo,
    Dio? dio, // Currently unused but kept for future extensibility
  }) : _networkInfo = networkInfo;

  /// Execute API call with comprehensive error handling
  ///
  /// This is the main method that should be used for all network operations.
  /// It handles:
  /// - Network connectivity checks
  /// - Automatic retries with exponential backoff
  /// - Circuit breaker protection
  /// - Error classification and transformation
  /// - Proper logging and monitoring
  ///
  /// Usage:
  /// ```dart
  /// final result = await networkErrorHandler.executeWithRetry(
  ///   () => apiClient.getData(),
  ///   operation: 'fetch_user_data',
  ///   config: RetryConfig.quick,
  /// );
  /// ```
  Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    required String operationName,
    String? serviceName,
    RetryConfig config = const RetryConfig(),
    Duration? timeout,
    Map<String, dynamic>? context,
  }) async {
    final effectiveServiceName = serviceName ?? 'default';
    final circuitBreaker = _getOrCreateCircuitBreaker(effectiveServiceName);

    // Check network connectivity first
    if (!await _networkInfo.isConnected) {
      throw const NetworkException(
        'No internet connection. Please check your network settings and try again.',
      );
    }

    try {
      AppLogger.debug('[NETWORK] Starting operation: $operationName', {
        'service': effectiveServiceName,
        'config': {
          'maxAttempts': config.maxAttempts,
          'initialDelay': config.initialDelay.inMilliseconds,
          'backoffMultiplier': config.backoffMultiplier,
        },
        'context': context ?? {},
      });

      final result = await circuitBreaker.execute(
        () => _executeWithRetryLogic<T>(
          operation,
          config: config,
          operationName: operationName,
          context: context,
        ),
        timeout: timeout,
      );

      AppLogger.info(
        '[NETWORK] Operation completed successfully: $operationName',
        {'service': effectiveServiceName, 'context': context ?? {}},
      );

      return result;
    } on NetworkException {
      // Re-throw network exceptions as-is (already user-friendly)
      rethrow;
    } on SocketException catch (e) {
      AppLogger.warning('[NETWORK] Socket error in $operationName', e);
      throw const NetworkException(
        'Unable to connect to the server. Please check your internet connection.',
      );
    } on TimeoutException catch (e) {
      AppLogger.warning('[NETWORK] Timeout in $operationName', e);
      throw const NetworkException(
        'Request timed out. The server is taking too long to respond.',
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        '[NETWORK] Unexpected error in $operationName',
        error,
        stackTrace,
      );

      // Transform unknown errors into NetworkException
      if (error is DioException) {
        final transformedError = _transformDioException(error, operationName);

        // Report critical errors to Crashlytics
        if (_isCriticalError(transformedError)) {
          await _reportCriticalError(
            transformedError,
            operationName,
            stackTrace,
            context,
          );
        }

        throw transformedError;
      }

      // Wrap other errors in NetworkException
      throw const NetworkException(
        'An unexpected network error occurred. Please try again.',
      );
    }
  }

  /// Execute API call using ApiResponseHelper pattern with retry logic
  ///
  /// This method integrates with existing ApiResponseHelper while adding
  /// retry capabilities and better error handling.
  ///
  /// Usage:
  /// ```dart
  /// final response = await networkErrorHandler.executeApiCall(
  ///   () => apiClient.verifyMagicLink(request),
  ///   operation: 'verify_magic_link',
  /// );
  /// return response.unwrap(); // Will throw NetworkException on error
  /// ```
  Future<ApiResponse<T>> executeApiCall<T>(
    Future<T> Function() apiCall, {
    required String operationName,
    String? serviceName,
    RetryConfig config = const RetryConfig(),
    Map<String, dynamic>? context,
  }) async {
    try {
      final result = await executeWithRetry<T>(
        apiCall,
        operationName: operationName,
        serviceName: serviceName,
        config: config,
        context: context,
      );

      return ApiResponseHelper.wrapSuccess(result, metadata: context);
    } catch (error) {
      // Transform the error using ApiResponseHelper for consistency
      return ApiResponseHelper.handleError<T>(error);
    }
  }

  /// Execute operation with retry logic (exponential backoff)
  Future<T> _executeWithRetryLogic<T>(
    Future<T> Function() operation, {
    required RetryConfig config,
    required String operationName,
    Map<String, dynamic>? context,
  }) async {
    dynamic lastError;
    var attempt = 0;

    while (attempt < config.maxAttempts) {
      attempt++;

      try {
        AppLogger.debug(
          '[NETWORK] Attempt $attempt/$config.maxAttempts for $operationName',
        );
        return await operation();
      } catch (error) {
        lastError = error;

        // Check if error is retryable
        if (!_isRetryableError(error, config)) {
          AppLogger.warning(
            '[NETWORK] Non-retryable error in $operationName (attempt $attempt)',
            error,
          );
          rethrow;
        }

        // Check if we have more attempts available
        if (attempt >= config.maxAttempts) {
          AppLogger.error(
            '[NETWORK] Max retries exceeded for $operationName',
            error,
          );
          rethrow;
        }

        // Calculate delay for next attempt
        final delay = _calculateRetryDelay(attempt, config);

        AppLogger.warning(
          '[NETWORK] Retry $attempt/$config.maxAttempts for $operationName in ${delay.inMilliseconds}ms',
          error,
        );

        await Future.delayed(delay);
      }
    }

    // This should never be reached, but just in case
    throw lastError;
  }

  /// Calculate exponential backoff delay
  Duration _calculateRetryDelay(int attempt, RetryConfig config) {
    final exponentialDelay =
        config.initialDelay * (config.backoffMultiplier * (attempt - 1));
    final cappedDelay = Duration(
      milliseconds:
          exponentialDelay.inMilliseconds > config.maxDelay.inMilliseconds
          ? config.maxDelay.inMilliseconds
          : exponentialDelay.inMilliseconds,
    );

    // Add jitter to prevent thundering herd
    final jitter = Duration(
      milliseconds:
          (cappedDelay.inMilliseconds * 0.1 * (DateTime.now().millisecond % 10))
              .toInt(),
    );

    return Duration(
      milliseconds: cappedDelay.inMilliseconds + jitter.inMilliseconds,
    );
  }

  /// Check if error is retryable based on configuration
  bool _isRetryableError(dynamic error, RetryConfig config) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;

      // Network errors are always retryable
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.unknown) {
        return true;
      }

      // Check status code
      if (statusCode != null &&
          config.retryableStatusCodes.contains(statusCode)) {
        return true;
      }
    }

    if (error is NetworkException || error is ApiException) {
      return error is ApiException ? error.isRetryable : true;
    }

    return false;
  }

  /// Transform DioException into appropriate exception type
  Exception _transformDioException(DioException error, String operation) {
    final statusCode = error.response?.statusCode;

    // Network-related errors
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const NetworkException(
        'Request timeout. Please check your internet connection and try again.',
      );
    }

    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.unknown) {
      return const NetworkException(
        'Unable to connect to the server. Please check your internet connection.',
      );
    }

    // HTTP errors
    if (statusCode != null) {
      if (statusCode == 401) {
        return const AuthenticationException(
          'Your session has expired. Please sign in again.',
          authCode: 'SESSION_EXPIRED',
        );
      }

      if (statusCode == 403) {
        return const AuthorizationException(
          'You don\'t have permission to perform this action.',
          requiredPermission: 'UNKNOWN',
        );
      }

      if (statusCode == 404) {
        return ServerException(
          'The requested resource was not found.',
          statusCode: statusCode,
        );
      }

      if (statusCode == 422) {
        return ValidationException(
          _extractValidationMessage(error),
          fieldErrors: _extractFieldErrors(error),
        );
      }

      // Server errors (5xx)
      if (statusCode >= 500) {
        return ServerException(
          'The server is experiencing issues. Please try again later.',
          statusCode: statusCode,
        );
      }
    }

    // Default to generic network exception
    return const NetworkException(
      'A network error occurred. Please try again.',
    );
  }

  /// Extract validation message from DioException
  String _extractValidationMessage(DioException error) {
    final responseData = error.response?.data;

    if (responseData is Map<String, dynamic>) {
      return responseData['error']?.toString() ??
          responseData['message']?.toString() ??
          'Invalid input. Please check your information and try again.';
    }

    return 'Invalid input. Please check your information and try again.';
  }

  /// Extract field errors from DioException
  Map<String, String>? _extractFieldErrors(DioException error) {
    final responseData = error.response?.data;

    if (responseData is Map<String, dynamic>) {
      final fields = responseData['fields'] as Map<String, dynamic>?;
      if (fields != null) {
        return fields.map((key, value) => MapEntry(key, value.toString()));
      }
    }

    return null;
  }

  /// Check if error is critical and should be reported
  bool _isCriticalError(Exception error) {
    // Report all server errors (5xx)
    if (error is ServerException &&
        error.statusCode != null &&
        error.statusCode! >= 500) {
      return true;
    }

    // Report authentication errors (might indicate token issues)
    if (error is AuthenticationException) {
      return true;
    }

    // Report unexpected network errors
    if (error is NetworkException) {
      return true;
    }

    return false;
  }

  /// Report critical errors to Crashlytics
  Future<void> _reportCriticalError(
    Exception error,
    String operation,
    StackTrace stackTrace,
    Map<String, dynamic>? context,
  ) async {
    try {
      // Only report when crash reporting is enabled
      if (!FeatureFlags.crashReporting) {
        return;
      }

      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        information: [
          'Network operation failed: $operation',
          'Error type: ${error.runtimeType}',
          'Error message: ${error.toString()}',
          if (context != null) 'Context: $context',
        ],
      );

      AppLogger.info(
        '[NETWORK] Critical error reported to Crashlytics: $operation',
      );
    } catch (e) {
      AppLogger.warning('[NETWORK] Failed to report error to Crashlytics', e);
    }
  }

  /// Get or create circuit breaker for service
  NetworkCircuitBreaker _getOrCreateCircuitBreaker(String serviceName) {
    return _circuitBreakers.putIfAbsent(
      serviceName,
      () => NetworkCircuitBreaker(serviceName: serviceName),
    );
  }

  /// Get status of all circuit breakers for monitoring
  Map<String, dynamic> getCircuitStatus() {
    return {
      'circuitBreakers': _circuitBreakers.map(
        (key, value) => MapEntry(key, value.status),
      ),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Reset all circuit breakers (for testing or recovery)
  void resetAllCircuitBreakers() {
    for (final breaker in _circuitBreakers.values) {
      breaker.reset();
    }
    AppLogger.info('[NETWORK] All circuit breakers reset');
  }

  /// Reset specific circuit breaker
  void resetCircuitBreaker(String serviceName) {
    final breaker = _circuitBreakers[serviceName];
    if (breaker != null) {
      breaker.reset();
      AppLogger.info('[NETWORK] Circuit breaker reset for $serviceName');
    }
  }
}

/// Extension to integrate NetworkErrorHandler with existing repositories
extension NetworkErrorHandlerExtension on NetworkErrorHandler {
  /// Determine if an error should trigger cache fallback based on error type
  ///
  /// Network errors (connectivity issues) should use cache fallback
  /// Server errors (HTTP 5xx, 4xx) should NOT use cache fallback
  bool _isNetworkErrorForCacheFallback(dynamic error) {
    // SocketException, TimeoutException are network errors
    if (error is SocketException || error is TimeoutException) {
      return true;
    }

    // Check for nested exceptions in ApiException message
    if (error is ApiException) {
      // Check if the ApiException message contains SocketException or TimeoutException
      if (error.message.contains('SocketException') ||
          error.message.contains('TimeoutException') ||
          error.message.contains('Connection refused') ||
          error.message.contains('Network is unreachable') ||
          error.message.contains('Connection timeout')) {
        return true;
      }

      // ApiException with retryable status (5xx) indicates server errors, not network errors
      if (error.isRetryable) {
        return false; // Server errors should not use cache fallback
      }

      // HTTP status codes that indicate server issues (not network issues)
      // These should NOT use cache fallback
      if (error.statusCode != null && error.statusCode! >= 400) {
        return false; // All 4xx and 5xx are server/client errors, not network errors
      }

      // HTTP status 0 indicates network connectivity issues (not server errors)
      // These SHOULD use cache fallback
      if (error.statusCode != null && error.statusCode == 0) {
        return true;
      }
    }

    // DioException network-related types
    if (error is DioException) {
      // Network errors are always retryable, regardless of statusCode
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.unknown) {
        return true;
      }

      // HTTP status codes that indicate server issues (not network issues)
      // These should NOT use cache fallback
      final statusCode = error.response?.statusCode;
      if (statusCode != null && statusCode >= 400) {
        return false; // All 4xx and 5xx are server/client errors, not network errors
      }

      // HTTP status 0 or null indicates network connectivity issues
      // These SHOULD use cache fallback (Connection failed, Network unreachable)
      if (statusCode == null || statusCode == 0) {
        return true;
      }
    }

    // NetworkException typically indicates connectivity issues
    if (error is NetworkException) {
      return true;
    }

    // Check if error message contains network-related keywords
    final errorString = error.toString();
    if (errorString.contains('SocketException') ||
        errorString.contains('Connection refused') ||
        errorString.contains('Network is unreachable') ||
        errorString.contains('Connection timeout') ||
        errorString.contains('TimeoutException')) {
      return true;
    }

    // Default to false for unknown errors
    return false;
  }

  /// Execute repository operation with standard error handling pattern
  ///
  /// This method provides a bridge between the new NetworkErrorHandler
  /// and existing repository patterns.
  ///
  /// Usage in repository:
  /// ```dart
  /// final result = await networkErrorHandler.executeRepositoryOperation(
  ///   () => _remoteDataSource.getData(),
  ///   operationName: 'get_user_data',
  ///   strategy: CacheStrategy.staleWhileRevalidate,
  ///   cacheOperation: () => _localDataSource.getCachedData(),
  ///   onSuccess: (data) async {
  ///     await _localDataSource.cacheData(data);
  ///   },
  /// );
  /// ```
  Future<Result<T, ApiFailure>> executeRepositoryOperation<T>(
    Future<T> Function() operation, {
    required String operationName,
    required CacheStrategy strategy,
    String? serviceName,
    RetryConfig config = const RetryConfig(),
    Future<T> Function()? cacheOperation,
    Future<void> Function(T data)? onSuccess,
    Map<String, dynamic>? context,
    Set<int> nonErrorStatusCodes =
        const {}, // Status codes that are not errors for this operation
  }) async {
    switch (strategy) {
      case CacheStrategy.networkOnly:
        return _executeNetworkOnly<T>(
          operation,
          operationName: operationName,
          serviceName: serviceName,
          config: config,
          context: context,
          nonErrorStatusCodes: nonErrorStatusCodes,
          onSuccess: onSuccess,
        );

      case CacheStrategy.cacheOnly:
        return _executeCacheOnly<T>(
          cacheOperation,
          operationName: operationName,
          onSuccess: onSuccess,
        );

      case CacheStrategy.networkFirst:
        return _executeNetworkFirst<T>(
          operation,
          cacheOperation: cacheOperation,
          operationName: operationName,
          serviceName: serviceName,
          config: config,
          context: context,
          nonErrorStatusCodes: nonErrorStatusCodes,
          onSuccess: onSuccess,
        );

      case CacheStrategy.staleWhileRevalidate:
        return _executeStaleWhileRevalidate<T>(
          operation,
          cacheOperation: cacheOperation,
          operationName: operationName,
          serviceName: serviceName,
          config: config,
          context: context,
          nonErrorStatusCodes: nonErrorStatusCodes,
          onSuccess: onSuccess,
        );
    }
  }

  /// Execute operation with retry logic and operation-specific error handling
  Future<T> _executeWithRetryForOperation<T>(
    Future<T> Function() operation, {
    required RetryConfig config,
    required String operationName,
    String? serviceName,
    Map<String, dynamic>? context,
    Set<int> nonErrorStatusCodes = const {},
  }) async {
    dynamic lastError;
    var attempt = 0;

    while (attempt < config.maxAttempts) {
      attempt++;

      try {
        AppLogger.debug(
          '[NETWORK] Attempt $attempt/$config.maxAttempts for $operationName',
        );
        return await operation();
      } catch (error) {
        lastError = error;

        // Check if error is retryable (considering non-error status codes)
        if (!_isRetryableErrorForOperation(
          error,
          config,
          nonErrorStatusCodes,
        )) {
          AppLogger.warning(
            '[NETWORK] Non-retryable error in $operationName (attempt $attempt)',
            error,
          );
          rethrow;
        }

        // Check if we have more attempts available
        if (attempt >= config.maxAttempts) {
          AppLogger.error(
            '[NETWORK] Max retries exceeded for $operationName',
            error,
          );
          rethrow;
        }

        // Calculate delay for next attempt
        final delay = _calculateRetryDelay(attempt, config);

        AppLogger.warning(
          '[NETWORK] Retry $attempt/$config.maxAttempts for $operationName in ${delay.inMilliseconds}ms',
          error,
        );

        await Future.delayed(delay);
      }
    }

    // This should never be reached, but just in case
    throw lastError;
  }

  /// Check if error is retryable based on configuration and operation-specific non-error status codes
  bool _isRetryableErrorForOperation(
    dynamic error,
    RetryConfig config,
    Set<int> nonErrorStatusCodes,
  ) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;

      // If this status code is considered "non-error" for this operation, it's not retryable
      if (statusCode != null && nonErrorStatusCodes.contains(statusCode)) {
        AppLogger.info(
          '[NETWORK] Status code $statusCode is not an error for this operation, not retrying',
        );
        return false;
      }

      // Network errors are always retryable, regardless of statusCode
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.unknown) {
        return true;
      }

      // HTTP status 0 or null indicates network connectivity issues (Connection failed, Network unreachable)
      // These SHOULD be retryable
      if (statusCode == null || statusCode == 0) {
        return true;
      }

      // Check status code
      if (config.retryableStatusCodes.contains(statusCode)) {
        return true;
      }
    }

    if (error is NetworkException || error is ApiException) {
      return error is ApiException ? error.isRetryable : true;
    }

    return false;
  }

  /// Execute network-only strategy: No cache involved
  Future<Result<T, ApiFailure>> _executeNetworkOnly<T>(
    Future<T> Function() operation, {
    required String operationName,
    String? serviceName,
    required RetryConfig config,
    Map<String, dynamic>? context,
    required Set<int> nonErrorStatusCodes,
    Future<void> Function(T data)? onSuccess,
  }) async {
    try {
      AppLogger.info('[NETWORK] Network-only strategy for $operationName');

      final result = await _executeWithRetryForOperation<T>(
        operation,
        operationName: operationName,
        serviceName: serviceName,
        config: config,
        context: context,
        nonErrorStatusCodes: nonErrorStatusCodes,
      );

      // Call onSuccess callback after network success
      if (onSuccess != null) {
        try {
          await onSuccess(result);
          AppLogger.debug(
            '[NETWORK] onSuccess callback executed for $operationName',
          );
        } catch (cacheError) {
          // Cache failure should NOT fail the operation
          AppLogger.warning(
            '[NETWORK] onSuccess callback failed for $operationName (operation still succeeded)',
            cacheError,
          );
        }
      }

      return Result.ok(result);
    } catch (error) {
      AppLogger.warning(
        '[NETWORK] Network-only failed for $operationName',
        error,
      );
      return Result.err(_transformExceptionToApiFailure(error));
    }
  }

  /// Execute cache-only strategy: No network involved
  Future<Result<T, ApiFailure>> _executeCacheOnly<T>(
    Future<T> Function()? cacheOperation, {
    required String operationName,
    Future<void> Function(T data)? onSuccess,
  }) async {
    if (cacheOperation == null) {
      AppLogger.error(
        '[NETWORK] Cache-only strategy requires cacheOperation for $operationName',
      );
      return Result.err(
        const ApiFailure(
          code: 'cache.not_configured',
          message: 'Cache operation not provided for cache-only strategy',
          statusCode: 0,
        ),
      );
    }

    try {
      AppLogger.info('[NETWORK] Cache-only strategy for $operationName');
      final result = await cacheOperation();

      // NOTE: For cache-only, we generally don't call onSuccess
      // since we're reading from cache, not writing to it.
      // But we keep it for API consistency if needed.
      if (onSuccess != null) {
        try {
          await onSuccess(result);
          AppLogger.debug(
            '[NETWORK] onSuccess callback executed for $operationName',
          );
        } catch (error) {
          AppLogger.warning(
            '[NETWORK] onSuccess callback failed for $operationName (operation still succeeded)',
            error,
          );
        }
      }

      return Result.ok(result);
    } catch (error) {
      AppLogger.warning(
        '[NETWORK] Cache-only failed for $operationName',
        error,
      );
      return Result.err(_transformExceptionToApiFailure(error));
    }
  }

  /// Execute network-first strategy: Try network, fallback to cache on network error
  Future<Result<T, ApiFailure>> _executeNetworkFirst<T>(
    Future<T> Function() operation, {
    Future<T> Function()? cacheOperation,
    required String operationName,
    String? serviceName,
    required RetryConfig config,
    Map<String, dynamic>? context,
    required Set<int> nonErrorStatusCodes,
    Future<void> Function(T data)? onSuccess,
  }) async {
    try {
      AppLogger.info(
        '[NETWORK] Network-first strategy: trying network for $operationName',
      );

      final result = await _executeWithRetryForOperation<T>(
        operation,
        operationName: operationName,
        serviceName: serviceName,
        config: config,
        context: context,
        nonErrorStatusCodes: nonErrorStatusCodes,
      );

      AppLogger.info(
        '[NETWORK] Network-first: network succeeded for $operationName',
      );

      // Call onSuccess callback after network success
      if (onSuccess != null) {
        try {
          await onSuccess(result);
          AppLogger.debug(
            '[NETWORK] onSuccess callback executed for $operationName',
          );
        } catch (cacheError) {
          AppLogger.warning(
            '[NETWORK] onSuccess callback failed for $operationName (operation still succeeded)',
            cacheError,
          );
        }
      }

      return Result.ok(result);
    } catch (networkError) {
      // Check if this is a network connectivity error (should use cache)
      // or a server error (should NOT use cache)
      if (_isNetworkErrorForCacheFallback(networkError) &&
          cacheOperation != null) {
        try {
          AppLogger.info(
            '[NETWORK] Network-first: network error, trying cache for $operationName',
          );
          final cachedResult = await cacheOperation();
          AppLogger.info(
            '[NETWORK] Network-first: returning cached data for $operationName',
          );

          // NOTE: We do NOT call onSuccess for cache fallback
          // because it's already cached data, not new data to cache

          return Result.ok(cachedResult);
        } catch (cacheError) {
          AppLogger.warning(
            '[NETWORK] Network-first: cache also failed for $operationName',
            cacheError,
          );
        }
      } else {
        AppLogger.warning(
          '[NETWORK] Network-first: server error, not using cache for $operationName',
          networkError,
        );
      }

      return Result.err(_transformExceptionToApiFailure(networkError));
    }
  }

  /// Execute stale-while-revalidate strategy: Return cache, then fetch fresh data
  Future<Result<T, ApiFailure>> _executeStaleWhileRevalidate<T>(
    Future<T> Function() operation, {
    Future<T> Function()? cacheOperation,
    required String operationName,
    String? serviceName,
    required RetryConfig config,
    Map<String, dynamic>? context,
    required Set<int> nonErrorStatusCodes,
    Future<void> Function(T data)? onSuccess,
  }) async {
    // If no cache configured, fall back to network-only
    if (cacheOperation == null) {
      AppLogger.info(
        '[NETWORK] Stale-While-Revalidate: no cache, using network-only for $operationName',
      );
      return _executeNetworkOnly<T>(
        operation,
        operationName: operationName,
        serviceName: serviceName,
        config: config,
        context: context,
        nonErrorStatusCodes: nonErrorStatusCodes,
        onSuccess: onSuccess,
      );
    }

    try {
      AppLogger.info(
        '[NETWORK] Stale-While-Revalidate: reading cache for $operationName',
      );
      final cachedResult = await cacheOperation();

      // Try network for fresh data
      try {
        AppLogger.info(
          '[NETWORK] Stale-While-Revalidate: fetching fresh data for $operationName',
        );
        final freshResult = await _executeWithRetryForOperation<T>(
          operation,
          operationName: operationName,
          serviceName: serviceName,
          config: config,
          context: context,
          nonErrorStatusCodes: nonErrorStatusCodes,
        );

        AppLogger.info(
          '[NETWORK] Stale-While-Revalidate: returning fresh data for $operationName',
        );

        // Call onSuccess callback after receiving fresh data
        if (onSuccess != null) {
          try {
            await onSuccess(freshResult);
            AppLogger.debug(
              '[NETWORK] onSuccess callback executed for $operationName',
            );
          } catch (cacheError) {
            AppLogger.warning(
              '[NETWORK] onSuccess callback failed for $operationName (operation still succeeded)',
              cacheError,
            );
          }
        }

        return Result.ok(freshResult); // Fresh data wins
      } catch (networkError) {
        // Check if this is a network error (use cache) or server error (don't use cache)
        if (_isNetworkErrorForCacheFallback(networkError)) {
          AppLogger.info(
            '[NETWORK] Stale-While-Revalidate: network error, using stale cache for $operationName',
          );

          // NOTE: We do NOT call onSuccess for stale cache
          // because it's already cached data, not new data to cache

          return Result.ok(cachedResult); // Fallback to stale cache
        } else {
          // Server error - do NOT use cache fallback
          AppLogger.warning(
            '[NETWORK] Stale-While-Revalidate: server error, not using cache for $operationName',
            networkError,
          );
          rethrow;
        }
      }
    } catch (cacheError) {
      // Cache failed, try network normally
      AppLogger.warning(
        '[NETWORK] Stale-While-Revalidate: cache failed, trying network for $operationName',
        cacheError,
      );
      return _executeNetworkOnly<T>(
        operation,
        operationName: operationName,
        serviceName: serviceName,
        config: config,
        context: context,
        nonErrorStatusCodes: nonErrorStatusCodes,
        onSuccess: onSuccess,
      );
    }
  }

  /// Transform any exception to ApiFailure for consistency
  ApiFailure _transformExceptionToApiFailure(dynamic error) {
    if (error is ApiFailure) {
      return error;
    }

    if (error is ApiException) {
      // Extract HTTP status code for generic classification
      final errorMessage = error.message;
      final match = RegExp(r'HTTP (\d{3})').firstMatch(errorMessage);
      final statusCode = match != null
          ? int.parse(match.group(1)!)
          : error.statusCode;

      // Use generic error code based on HTTP status classification
      var errorCode = 'api';
      if (statusCode != null) {
        if (statusCode >= 400 && statusCode < 500) {
          errorCode = 'api'; // Client errors
        } else if (statusCode >= 500) {
          errorCode = 'server'; // Server errors
        }
      }

      return ApiFailure(
        message: error.message,
        code: errorCode,
        statusCode: statusCode,
        details: error.details,
        requestUrl: error.endpoint,
        requestMethod: error.method,
      );
    }

    if (error is NetworkException) {
      return ApiFailure.network(message: error.message);
    }

    if (error is ServerException) {
      return ApiFailure.serverError(
        message: error.message,
        code: error.errorCode,
      );
    }

    if (error is ValidationException) {
      return ApiFailure.validationError(
        message: error.message,
        code: 'validation.error',
      );
    }

    if (error is AuthenticationException) {
      return ApiFailure.unauthorized();
    }

    if (error is AuthorizationException) {
      return ApiFailure(
        code: 'api.forbidden',
        statusCode: 403,
        message: error.message,
        details: {'required_permission': error.requiredPermission},
      );
    }

    // Handle standard Dart exceptions
    if (error is TimeoutException) {
      return const ApiFailure(
        code: 'timeout',
        message: 'Request timed out',
        statusCode: 408,
      );
    }

    if (error is SocketException) {
      return ApiFailure.network(message: error.message);
    }

    // Default case - check if error message contains HTTP status code for generic classification
    final errorString = error.toString();
    final match = RegExp(r'HTTP (\d{3})').firstMatch(errorString);
    if (match != null) {
      final statusCode = int.parse(match.group(1)!);

      // Use generic error code based on HTTP status classification
      var errorCode = 'api';
      if (statusCode >= 400 && statusCode < 500) {
        errorCode = 'api'; // Client errors
      } else if (statusCode >= 500) {
        errorCode = 'server'; // Server errors
      }

      return ApiFailure(
        code: errorCode,
        message: errorString,
        statusCode: statusCode,
      );
    }

    return ApiFailure(
      code: 'network.unknown_error',
      message: errorString,
      statusCode: 0,
    );
  }
}
