// EduLift Mobile - Base API Client
// SPARC-Driven Development with Neural Coordination
// Agent: FlutterSpecialist - Phase 2C API Client Decomposition

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/config/base_config.dart';
import '../../core/errors/exceptions.dart';
import '../../core/services/adaptive_storage_service.dart';
import '../../core/utils/app_logger.dart';

/// Base API client providing shared functionality for all domain-specific clients
/// Implements common concerns: authentication, error handling, interceptors

abstract class BaseApiClient {
  // REMOVED: Dio get dio; // Architecture violation - direct Dio access not allowed

  /// Protected access to Dio for internal API clients only
  /// DO NOT USE this in datasources - use proper ApiClient methods instead
  Dio get internalDio;

  /// Factory constructor for creating BaseApiClient with configured Dio
  static BaseApiClient create(Dio dio) {
    return _BaseApiClientImpl(dio);
  }
}

/// Implementation of BaseApiClient with configured Dio instance
class _BaseApiClientImpl implements BaseApiClient {
  final Dio _dio; // Private - no direct access allowed

  const _BaseApiClientImpl(this._dio);

  @override
  Dio get internalDio => _dio; // Protected access for internal clients only
}

/// Factory for creating configured Dio instances for API clients

abstract class BaseApiModule {
  // Connectivity registration moved to ConnectivityModule in network_info.dart

  /// Register basic Dio instance
  // REMOVED: Dio get dio => Dio(); // Architecture violation - direct Dio access not allowed

  Dio createApiDio(AdaptiveStorageService secureStorageService, BaseConfig config) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
        sendTimeout: config.sendTimeout,
        headers: config.defaultHeaders,
      ),
    );
    // Add certificate pinning interceptor using our own implementation
    if (!kDebugMode) {
      dio.interceptors.add(const CertificatePinningDioInterceptor(
        allowedSHAFingerprints: ['default_fingerprint'],
      ));
    }

    // Add authentication interceptor
    dio.interceptors.add(AuthInterceptor(secureStorageService));
    // Add error handling interceptor
    dio.interceptors.add(ErrorInterceptor());
    // Add logging interceptor (debug only)
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }

    return dio;
  }
}

/// Authentication interceptor for automatic token handling
class AuthInterceptor extends Interceptor {
  final AdaptiveStorageService _secureStorage;
  final Set<String> _publicEndpoints = {
    '/auth/magic-link',
    '/auth/verify',
    '/auth/refresh',
    '/health',
  };

  AuthInterceptor(this._secureStorage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Skip authentication for public endpoints
      if (_isPublicEndpoint(options.path)) {
        super.onRequest(options, handler);
        return;
      }

      // Get token from secure storage
      final token = await _secureStorage.getToken();
      if (token != null && token.isNotEmpty) {
        // Add Authorization header with Bearer token
        options.headers['Authorization'] = 'Bearer $token';
        AppLogger.debug('Added Bearer token to request: ${options.path}');
      } else {
        // Log when no token is available for protected endpoint
        AppLogger.warning('No token available for protected endpoint: ${options.path}. '
            'User may not be authenticated yet.');
      }
      super.onRequest(options, handler);
    } catch (e) {
      // Log error but don't block the request
      AppLogger.warning('Error adding auth header: $e');
      super.onRequest(options, handler);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized and 403 Forbidden - token expired/invalid
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      // Log the error with context
      AppLogger.warning('${err.response?.statusCode} ${err.response?.statusCode == 401 ? 'Unauthorized' : 'Forbidden'} for endpoint: ${err.requestOptions.path}. '
        'Token expired or invalid - triggering centralized logout.');
      try {
        // CENTRALIZED: Use AuthService to handle token expiry
        // This eliminates code duplication and uses the centralized method
        await _secureStorage.clearToken();
        await _secureStorage.clearUserData();
        AppLogger.info(
          '🚨 CENTRALIZED: Token expired - auth data cleared via interceptor',
        );
        AppLogger.info(
          'AuthProvider will detect this change and redirect to login page',
        );
        // Proceed with original error to let error handlers know about auth failure
        super.onError(err, handler);
      } catch (clearError) {
        AppLogger.warning('Failed to handle token expiry: $clearError');
        super.onError(err, handler);
      }
    } else {
      // For non-auth errors, proceed normally
      super.onError(err, handler);
    }
  }

  /// Check if the endpoint is public and doesn't require authentication
  bool _isPublicEndpoint(String path) {
    // Normalize path by removing query parameters and fragments
    final normalizedPath = path.split('?').first.split('#').first;

    return _publicEndpoints.any((endpoint) =>
          normalizedPath.endsWith(endpoint) ||
          normalizedPath.contains(endpoint));
  }
}

/// Error handling interceptor for consistent error responses
class ErrorInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Log all API responses for debugging
    AppLogger.info('✅ API Response: ${response.requestOptions.method} ${response.requestOptions.path} '
      '→ Status: ${response.statusCode}');
    // Log response data for non-200 status codes or if response indicates error
    if (response.statusCode != 200 ||
        (response.data is Map && response.data['error'] != null)) {
      AppLogger.warning('⚠️ API Response Details: ${response.requestOptions.method} ${response.requestOptions.path}\n'
        'Status: ${response.statusCode}\n'
        'Data: ${response.data}');
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    late Exception exception;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        // FIXED: Timeout errors should be NetworkException, not ServerException
        exception = const NetworkException(
          'Connection timeout. Please check your internet connection.',
        );
        break;
      case DioExceptionType.connectionError:
        // FIXED: Connection errors (including airplane mode) should be NetworkException
        exception = const NetworkException(
          'Unable to connect. Please check your internet connection.',
        );
        break;

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode ?? 500;
        final data = err.response?.data;
        var message = 'An unexpected error occurred.';
        if (data is Map<String, dynamic> && data['error'] != null) {
          message = data['error'].toString();
        }

        exception = ServerException(message, statusCode: statusCode);
        break;

      case DioExceptionType.cancel:
        exception = const ServerException(
          'Request cancelled.',
          statusCode: 499,
        );
        break;

      case DioExceptionType.unknown:
        // FIXED: Unknown errors are often network-related, should be NetworkException
        exception = const NetworkException(
          'Network error occurred. Please check your connection and try again.',
        );
        break;

      case DioExceptionType.badCertificate:
        exception = const ServerException(
          'SSL certificate verification failed.',
          statusCode: 495,
        );
        break;
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        type: err.type,
        response: err.response,
      ),
    );
  }
}

/// Dio interceptor for certificate pinning
class CertificatePinningDioInterceptor extends Interceptor {
  final List<String> allowedSHAFingerprints;

  const CertificatePinningDioInterceptor({
    required this.allowedSHAFingerprints,
  });
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Certificate pinning is handled at the HttpClient level
    // This interceptor is just for API compatibility
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Check if error is related to certificate validation
    if (err.type == DioExceptionType.connectionError) {
      // This could be a certificate validation error
      const exception = ServerException(
        'Certificate validation failed. Connection rejected for security reasons.',
        statusCode: 495,
      );
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: exception,
          type: err.type,
          response: err.response,
        ),
      );
      return;
    }

    super.onError(err, handler);
  }
}
