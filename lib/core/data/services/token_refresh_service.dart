import 'dart:async';
import 'package:dio/dio.dart';
import '../../storage/auth_local_datasource.dart';
import '../../utils/app_logger.dart';
import '../../network/network_error_handler.dart';
import '../../network/models/common/api_response_wrapper.dart';
import '../../network/models/auth/auth_dto.dart';

/// Service responsible for refreshing authentication tokens
///
/// This service handles:
/// - Automatic token refresh with the backend
/// - Race condition prevention with queue management
/// - Preemptive refresh before token expiration
///
/// Phase 2 Implementation - Following best practices:
/// - Refresh 5 minutes before expiration (66% of 15min lifetime)
/// - Single refresh even with concurrent requests
/// - Secure storage of new tokens
class TokenRefreshService {
  final Dio _dio;
  final AuthLocalDatasource _storage;
  final NetworkErrorHandler _networkErrorHandler;

  /// Flag to prevent concurrent refresh operations
  bool _isRefreshing = false;

  /// Queue of pending operations waiting for refresh to complete
  final List<Completer<void>> _refreshQueue = [];

  TokenRefreshService(this._dio, this._storage, this._networkErrorHandler) {
    // CRITICAL: Validate that Dio has baseUrl configured
    // This prevents "No host specified in URI /auth/refresh" errors
    if (_dio.options.baseUrl.isEmpty) {
      throw ArgumentError(
        '[TokenRefresh] CRITICAL ERROR: Dio instance has no baseUrl configured. '
        'TokenRefreshService requires Dio with baseUrl to make /auth/refresh requests. '
        'Current baseUrl: "${_dio.options.baseUrl}". '
        'Use apiDioProvider instead of dioProvider in service_providers.dart',
      );
    }
    AppLogger.info(
      '[TokenRefresh] Service initialized with baseUrl: ${_dio.options.baseUrl}',
    );
  }

  /// Refresh the access token using the refresh token
  ///
  /// This method:
  /// 1. Prevents concurrent refresh operations using a flag
  /// 2. Queues additional requests if refresh is in progress
  /// 3. Calls /auth/refresh endpoint WITHOUT interceptors (prevents infinite loop)
  /// 4. Stores new tokens on success
  /// 5. Clears tokens and forces logout on failure
  ///
  /// Returns: Future that completes when refresh is done
  /// Throws: Exception if refresh fails
  Future<void> refreshToken() async {
    // If refresh is already in progress, queue this request
    if (_isRefreshing) {
      AppLogger.info(
        '[TokenRefresh] Refresh already in progress, queuing request',
      );
      final completer = Completer<void>();
      _refreshQueue.add(completer);
      return completer.future;
    }

    _isRefreshing = true;
    AppLogger.info('[TokenRefresh] Starting token refresh...');

    try {
      // Get the stored refresh token
      final refreshTokenResult = await _storage.getRefreshToken();
      if (refreshTokenResult.isErr || refreshTokenResult.value == null) {
        throw Exception('No refresh token available');
      }

      final refreshToken = refreshTokenResult.value!;
      AppLogger.info('[TokenRefresh] Found refresh token, calling backend...');

      // PHASE 2: Use NetworkErrorHandler for robust retry logic + Explicit DTO with unwrap()
      // This provides:
      // - Automatic retries (5 attempts with exponential backoff)
      // - Circuit breaker pattern to protect backend
      // - Network connectivity checks before retry
      // - Proper error classification
      // - Type-safe DTO parsing with compile-time guarantees
      // - Explicit unwrap() pattern (2025 best practices)
      final result = await _networkErrorHandler
          .executeRepositoryOperation<ApiResponse<TokenRefreshResponseDto>>(
            () async {
              // CRITICAL: Use the injected Dio instance (refreshDioProvider)
              // which does NOT have auth interceptor to prevent infinite loop
              final response = await _dio.post(
                '/auth/refresh',
                data: {'refreshToken': refreshToken},
              );

              if (response.statusCode != 200) {
                throw Exception(
                  'Refresh failed with status ${response.statusCode}',
                );
              }

              // Backend returns: { success: true, data: { accessToken, refreshToken, expiresIn, tokenType } }
              // Use ApiResponse.fromBackendWrapper to parse and extract the DTO
              return ApiResponse<TokenRefreshResponseDto>.fromBackendWrapper(
                response.data as Map<String, dynamic>,
                (json) => TokenRefreshResponseDto.fromJson(
                  json as Map<String, dynamic>,
                ),
                statusCode: response.statusCode,
              );
            },
            operationName: 'auth.refreshToken',
            strategy: CacheStrategy.networkOnly,
            serviceName: 'auth',
            config: RetryConfig
                .critical, // 5 automatic retries with exponential backoff
          );

      // Handle success - use explicit unwrap() pattern
      if (result.isOk) {
        // EXPLICIT UNWRAP: Extract DTO from ApiResponse wrapper
        // This is the 2025 best practice "explicit wrapper with helper" pattern
        // Benefits:
        // - Type-safe: compile-time guarantees about TokenRefreshResponseDto structure
        // - Transparent: clear data flow from backend → ApiResponse → DTO
        // - Maintainable: easy to debug, no magic extraction
        // - Reusable: same pattern across entire codebase
        final tokenResponse = result.value!.unwrap();

        // Extract tokens from strongly-typed DTO (all fields guaranteed by Freezed)
        final newAccessToken = tokenResponse.accessToken;
        final newRefreshToken = tokenResponse.refreshToken;
        final expiresIn = tokenResponse.expiresIn;

        // Calculate expiration time
        final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));

        // Store the new tokens
        final storeResult = await _storage.storeTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
          expiresAt: expiresAt,
        );

        if (storeResult.isErr) {
          throw Exception('Failed to store new tokens: ${storeResult.error}');
        }

        AppLogger.info(
          '[TokenRefresh] ✅ Token refreshed successfully with ${RetryConfig.critical.maxAttempts} retry protection',
        );
        AppLogger.info('[TokenRefresh] New expiration: $expiresAt');

        // Complete all queued requests with success
        for (final completer in _refreshQueue) {
          if (!completer.isCompleted) {
            completer.complete();
          }
        }
        _refreshQueue.clear();
      } else {
        // NetworkErrorHandler returned error after all retries
        throw Exception('Refresh failed after retries: ${result.error}');
      }
    } catch (e) {
      AppLogger.error('[TokenRefresh] ❌ Refresh failed: $e');

      // Force logout by clearing tokens
      await _storage.clearTokens();
      AppLogger.warning('[TokenRefresh] Cleared tokens after refresh failure');

      // Complete all queued requests with error
      for (final completer in _refreshQueue) {
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      }
      _refreshQueue.clear();

      rethrow;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Check if the token should be refreshed preemptively
  ///
  /// Returns true if the token:
  /// - Exists
  /// - Will expire in less than 5 minutes (safety margin)
  ///
  /// Calculation: 15min token → refresh at 10min (66%) → 5min margin
  /// This allows 3 retries if network is slow (3× 10s = 30s)
  /// while maintaining 4+ minutes of buffer
  Future<bool> shouldRefreshToken() async {
    try {
      final expiryResult = await _storage.getTokenExpiry();

      if (expiryResult.isErr || expiryResult.value == null) {
        return false;
      }

      final expiresAt = expiryResult.value!;
      final now = DateTime.now();

      // Refresh if expires in less than 5 minutes
      final refreshThreshold = now.add(const Duration(minutes: 5));
      final shouldRefresh = refreshThreshold.isAfter(expiresAt);

      if (shouldRefresh) {
        final minutesLeft = expiresAt.difference(now).inMinutes;

        // Handle already-expired tokens
        if (minutesLeft < 0) {
          AppLogger.warning(
            '[TokenRefresh] ⚠️ Token already expired ${minutesLeft.abs()} minutes ago. '
            'This may indicate the app was suspended or clock changed. '
            'Forcing immediate refresh.',
          );
        } else {
          AppLogger.info(
            '[TokenRefresh] Token expires soon ($minutesLeft minutes left), should refresh',
          );
        }
      }

      return shouldRefresh;
    } catch (e) {
      AppLogger.error('[TokenRefresh] Error checking token expiry: $e');
      return false;
    }
  }

  /// Get the number of seconds until the token expires
  /// Returns null if no token or error
  Future<int?> getSecondsUntilExpiry() async {
    try {
      final expiryResult = await _storage.getTokenExpiry();

      if (expiryResult.isErr || expiryResult.value == null) {
        return null;
      }

      final expiresAt = expiryResult.value!;
      final now = DateTime.now();
      final secondsLeft = expiresAt.difference(now).inSeconds;

      return secondsLeft > 0 ? secondsLeft : 0;
    } catch (e) {
      AppLogger.error(
        '[TokenRefresh] Error calculating seconds until expiry: $e',
      );
      return null;
    }
  }
}
