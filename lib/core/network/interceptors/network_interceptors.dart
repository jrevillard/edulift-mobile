// =============================================================================
// NETWORK INTERCEPTORS - DEDICATED INFRASTRUCTURE LAYER
// =============================================================================

/// Dedicated network interceptors for the foundation layer.
/// These are separate from API client interceptors to avoid architectural violations.

import 'package:dio/dio.dart';
import '../../services/adaptive_storage_service.dart';
import '../../services/providers/token_expiry_provider.dart';
import '../../data/services/token_refresh_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/app_logger.dart';

// =============================================================================
// NETWORK AUTHENTICATION INTERCEPTOR
// =============================================================================

/// Network layer authentication interceptor with automatic token refresh
///
/// This interceptor is specifically for the foundation layer network providers.
/// It's separate from the API client interceptors to maintain clear boundaries.
///
/// Phase 2 Implementation Features:
/// - Preemptive token refresh (before expiration)
/// - Automatic retry on 401 errors after refresh
/// - Queue management to prevent concurrent refresh operations
/// - Clean integration with TokenRefreshService
class NetworkAuthInterceptor extends QueuedInterceptor {
  final AdaptiveStorageService _secureStorage;
  final TokenRefreshService? _tokenRefreshService;
  final Ref? _ref; // Optional ref for triggering auth state updates

  NetworkAuthInterceptor(
    this._secureStorage, [
    this._tokenRefreshService,
    this._ref,
  ]);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // PHASE 2: Preemptive refresh if token expires soon (5 min before)
      if (_tokenRefreshService != null) {
        final shouldRefresh = await _tokenRefreshService.shouldRefreshToken();
        if (shouldRefresh) {
          AppLogger.info('[AuthInterceptor] Token expires soon, refreshing preemptively...');
          try {
            await _tokenRefreshService.refreshToken();
            AppLogger.info('[AuthInterceptor] ✅ Preemptive refresh successful');
          } catch (e) {
            AppLogger.warning('[AuthInterceptor] ⚠️ Preemptive refresh failed', e);
            // Continue with existing token, onError will handle 401 if needed
          }
        }
      }

      // Add token to request headers
      final token = await _secureStorage.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      // Continue without auth header if storage fails
      AppLogger.warning('[AuthInterceptor] Failed to read token', e);
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;

    // ✅ 401 = Unauthorized (token expired/invalid) → automatic refresh attempt
    // This allows the app to recover from temporary token expiration
    if (statusCode == 401) {
      AppLogger.info('[AuthInterceptor] 401 detected, attempting automatic refresh...');

      // Try to refresh token if service is available
      if (_tokenRefreshService != null) {
        try {
          await _tokenRefreshService.refreshToken();
          AppLogger.info('[AuthInterceptor] ✅ Token refreshed, retrying original request');

          // Retry the original request with new token
          final token = await _secureStorage.getToken();
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $token';

          // Create a new Dio instance with baseUrl to retry
          // This ensures relative paths work correctly
          final dio = Dio(BaseOptions(
            baseUrl: err.requestOptions.baseUrl,
            connectTimeout: err.requestOptions.connectTimeout,
            receiveTimeout: err.requestOptions.receiveTimeout,
          ));
          final response = await dio.fetch(opts);

          // Resolve with the retried response
          handler.resolve(response);
          return;
        } catch (refreshError, stackTrace) {
          AppLogger.error(
            '[AuthInterceptor] ❌ Refresh failed, forcing logout',
            refreshError,
            stackTrace,
          );

          // Refresh failed → clear tokens and notify logout
          try {
            await _secureStorage.clearToken();

            // Notify token expiry (SKIP for logout endpoint to prevent cascade)
            final isLogoutEndpoint = err.requestOptions.path.contains('/auth/logout');
            if (_ref != null && !isLogoutEndpoint) {
              try {
                TokenExpiryNotifier.notifyTokenExpired(
                  _ref,
                  statusCode: 401,
                  endpoint: err.requestOptions.path,
                );
              } catch (e, st) {
                AppLogger.warning(
                  '[AuthInterceptor] Failed to notify token expiry',
                  e,
                  st,
                );
              }
            } else if (isLogoutEndpoint) {
              AppLogger.info(
                '[AuthInterceptor] Skipping token expiry notification for logout endpoint (prevents cascade)',
              );
            }
          } catch (e, st) {
            AppLogger.warning(
              '[AuthInterceptor] Failed to clear token',
              e,
              st,
            );
          }

          // Continue with original error
          handler.next(err);
          return;
        }
      } else {
        // No refresh service available → fallback to old behavior
        try {
          await _secureStorage.clearToken();
          AppLogger.info('[AuthInterceptor] Cleared expired token (HTTP 401)');

          // Notify token expiry (SKIP for logout endpoint to prevent cascade)
          final isLogoutEndpoint = err.requestOptions.path.contains('/auth/logout');
          if (_ref != null && !isLogoutEndpoint) {
            try {
              TokenExpiryNotifier.notifyTokenExpired(
                _ref,
                statusCode: 401,
                endpoint: err.requestOptions.path,
              );
            } catch (e, st) {
              AppLogger.warning(
                '[AuthInterceptor] Failed to notify token expiry',
                e,
                st,
              );
            }
          } else if (isLogoutEndpoint) {
            AppLogger.info(
              '[AuthInterceptor] Skipping token expiry notification for logout endpoint (prevents cascade)',
            );
          }
        } catch (e, st) {
          AppLogger.warning(
            '[AuthInterceptor] Failed to clear token',
            e,
            st,
          );
        }
      }
    }

    // ✅ 403 = Forbidden (user lacks permissions for this specific resource)
    // This is NOT an authentication issue - the user is authenticated but not authorized
    // DO NOT logout, DO NOT refresh, DO NOT clear tokens
    // Just let the error propagate to the UI to display "Access Denied" message
    // Example: Regular user tries to access /admin/users → 403 → Show error, keep user logged in
    if (statusCode == 403) {
      AppLogger.info('[AuthInterceptor] 403 Forbidden - letting error propagate to UI');
      handler.next(err);
      return;
    }

    // For all other errors, just propagate
    handler.next(err);
  }
}

// =============================================================================
// NETWORK ERROR INTERCEPTOR
// =============================================================================

/// Network layer error handling interceptor
///
/// Handles common network errors at the foundation layer.
class NetworkErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.debug('[NetworkErrorInterceptor] ${err.type} - ${err.message}');
    if (err.response != null) {
      AppLogger.debug('[NetworkErrorInterceptor] Response status: ${err.response?.statusCode}');
      AppLogger.debug('[NetworkErrorInterceptor] Response data: ${err.response?.data}');
    }

    // Transform common network errors
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        handler.next(
          DioException(
            requestOptions: err.requestOptions,
            error: 'Network timeout. Please check your connection.',
            type: err.type,
          ),
        );
        break;
      case DioExceptionType.connectionError:
        handler.next(
          DioException(
            requestOptions: err.requestOptions,
            error: 'No internet connection. Please check your network.',
            type: err.type,
          ),
        );
        break;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode ?? 500;
        final data = err.response?.data;

        var message = 'An unexpected error occurred.';
        if (data is Map<String, dynamic> && data['error'] != null) {
          message = data['error'].toString();
        }

        // Special handling for /auth/magic-link endpoint - preserve validation errors
        if (err.requestOptions.path.contains('/auth/magic-link') &&
            data is Map<String, dynamic>) {
          // Create a proper error response that the generated code can handle
          final errorResponse = {
            'success': false,
            'error': data['error'] ?? message,
            'message': data['message'],
            'statusCode': statusCode,
            'data': null,
          };

          // Create a successful Response with the error data
          final successfulResponse = Response<Map<String, dynamic>>(
            requestOptions: err.requestOptions,
            data: errorResponse,
            statusCode: 200, // Make it appear successful to avoid exception
            statusMessage: 'OK',
          );

          // Resolve with the successful response containing error info
          handler.resolve(successfulResponse);
          return;
        }

        // For other badResponse cases, pass through the original error
        handler.next(err);
        break;
      default:
        handler.next(err);
    }
  }
}

// =============================================================================
// NETWORK CERTIFICATE PINNING INTERCEPTOR
// =============================================================================

/// Network layer certificate pinning interceptor
///
/// Handles certificate validation at the foundation layer.
class NetworkCertificatePinningInterceptor extends Interceptor {
  final List<String> allowedSHAFingerprints;

  const NetworkCertificatePinningInterceptor({
    required this.allowedSHAFingerprints,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Certificate pinning logic would go here
    // For now, just pass through the error
    AppLogger.debug(
      '[CertificatePinning] Checking certificate for ${err.requestOptions.uri}',
    );

    handler.next(err);
  }
}
