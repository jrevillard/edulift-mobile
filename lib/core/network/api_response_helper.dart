import 'package:dio/dio.dart';
import 'models/common/api_response_wrapper.dart';
import '../errors/api_exception.dart';
import '../errors/exceptions.dart';

/// State-of-the-Art API Response Helper (2025 Best Practices)
///
/// This helper enables the "explicit wrapper with helper" pattern recommended by Gemini.
/// Services use this to get explicit ApiResponse objects for both success and error cases,
/// replacing the previous "magic interceptor" pattern.
///
/// **Key Benefits:**
/// - Explicit: Services clearly see when they're handling ApiResponse objects
/// - Transparent: No hidden data extraction or magic behavior
/// - Maintainable: Easy to debug and understand data flow
/// - Type-safe: Compile-time guarantees about response structure
/// - Reusable: Same pattern across entire application
///
/// **Usage Pattern:**
/// ```dart
/// try {
///   final dto = await authApiClient.verifyMagicLink(request);
///   final response = ApiResponseHelper.wrapSuccess(dto);
///   return response.unwrap(); // Explicit unwrap
/// } catch (e) {
///   final errorResponse = ApiResponseHelper.handleError<AuthDto>(e);
///   return errorResponse.unwrap(); // Will throw ApiException with full context
/// }
/// ```
class ApiResponseHelper {
  /// Wraps a successful API response in an explicit ApiResponse
  ///
  /// **When to use:**
  /// - When API call succeeded and returned DTO directly
  /// - Provides explicit ApiResponse wrapper for consistency
  /// - Enables uniform error handling patterns
  ///
  /// **Example:**
  /// ```dart
  /// final authDto = await authApiClient.verifyMagicLink(request);
  /// final response = ApiResponseHelper.wrapSuccess(authDto);
  /// return response.unwrap(); // Explicit, clear, reusable
  /// ```
  static ApiResponse<T> wrapSuccess<T>(
    T data, {
    Map<String, dynamic>? metadata,
  }) {
    return ApiResponse<T>.success(data, metadata: metadata);
  }

  /// Handles exceptions and extracts explicit ApiResponse information
  ///
  /// **When to use:**
  /// - In catch blocks to handle API errors explicitly
  /// - Extracts enhanced exception information from interceptor
  /// - Provides explicit ApiResponse for error handling
  ///
  /// **What it handles:**
  /// - Enhanced API exceptions with ApiResponse context
  /// - Regular API exceptions from interceptor
  /// - DioExceptions with enhanced error information
  /// - Network errors, timeouts, etc.
  ///
  /// **Example:**
  /// ```dart
  /// } catch (e) {
  ///   final errorResponse = ApiResponseHelper.handleError<AuthDto>(e);
  ///   try {
  ///     return errorResponse.unwrap(); // Will throw ApiException
  ///   } catch (apiException) {
  ///     // Handle specific error types
  ///     if (apiException.isValidationError) { ... }
  ///   }
  /// }
  /// ```
  static ApiResponse<T> handleError<T>(dynamic error) {
    // Handle DioException with regular ApiException in error field
    if (error is DioException && error.error is ApiException) {
      final apiException = error.error as ApiException;
      return ApiResponse<T>.error(
        apiException.message,
        errorCode: apiException.errorCode,
        statusCode: apiException.statusCode,
        metadata: apiException.details ?? {},
      );
    }

    // Handle regular ApiException
    if (error is ApiException) {
      return ApiResponse<T>.error(
        error.message,
        errorCode: error.errorCode,
        statusCode: error.statusCode,
        metadata: error.details ?? {},
      );
    }

    // CLEAN ARCHITECTURE FIX: Handle NoFamilyException as 404 not found
    if (error is NoFamilyException) {
      return ApiResponse<T>.error(
        error.message,
        errorCode: 'api.not_found',
        statusCode: 404,
        metadata: {'type': 'no_family', 'resource': 'Family'},
      );
    }

    // Handle DioException without enhanced error information
    if (error is DioException) {
      final statusCode = error.response?.statusCode ?? 0;

      // ENHANCED: Better message handling for network errors vs HTTP errors
      var message = 'Network error';
      var errorCode = 'network.error';

      if (statusCode == 0) {
        // HTTP 0 = Network connectivity error (connection failed, timeout, etc.)
        message = error.message ?? 'Connection failed';
        errorCode = 'network.connection_failed';
      } else if (error.response?.data != null) {
        // HTTP 4xx/5xx = Server/API errors
        final responseData = error.response!.data;
        if (responseData is Map) {
          // Try common backend error message fields
          message =
              responseData['error']?.toString() ??
              responseData['message']?.toString() ??
              responseData['detail']?.toString() ??
              'API error';
          errorCode = responseData['code']?.toString() ?? 'api.error';
        } else if (responseData is String) {
          message = responseData;
          errorCode = 'api.error';
        }
      } else {
        message = error.message ?? 'Network error';
        errorCode = statusCode >= 400 && statusCode < 500
            ? 'api.client_error'
            : statusCode >= 500
            ? 'api.server_error'
            : 'network.error';
      }

      return ApiResponse<T>.error(
        message,
        errorCode: errorCode,
        statusCode: statusCode,
        metadata: {
          'type': error.type.toString(),
          'original_error': error.toString(),
          'response_data': error.response?.data, // Preserve for debugging
          'is_network_error':
              statusCode == 0, // Explicit flag for network errors
        },
      );
    }

    // Handle any other exception
    return ApiResponse<T>.error(
      error.toString(),
      metadata: {
        'original_error': error.toString(),
        'error_type': error.runtimeType.toString(),
      },
    );
  }

  /// Executes an API call with explicit ApiResponse handling
  ///
  /// **When to use:**
  /// - To standardize API call patterns across services
  /// - Automatically handles success wrapping and error extraction
  /// - Provides consistent explicit ApiResponse handling
  ///
  /// **Example:**
  /// ```dart
  /// final response = await ApiResponseHelper.execute<AuthDto>(
  ///   () => authApiClient.verifyMagicLink(request),
  /// );
  /// return response.unwrap(); // Explicit unwrap with full error context
  /// ```
  static Future<ApiResponse<T>> execute<T>(Future<T> Function() apiCall) async {
    try {
      final result = await apiCall();
      return wrapSuccess(result);
    } catch (error) {
      // Certificate errors are now handled by NetworkErrorHandler before reaching API calls
      // No duplicate detection needed here

      return handleError<T>(error);
    }
  }

  /// Executes an API call and automatically unwraps with enhanced error context
  ///
  /// **When to use:**
  /// - When you want the direct DTO but with enhanced error handling
  /// - Provides the explicit pattern benefits while reducing boilerplate
  /// - Still throws ApiException but with full context
  ///
  /// **Example:**
  /// ```dart
  /// try {
  ///   final authDto = await ApiResponseHelper.executeAndUnwrap<AuthDto>(
  ///     () => authApiClient.verifyMagicLink(request),
  ///   );
  ///   return authDto; // Direct DTO access
  /// } catch (apiException) {
  ///   // Enhanced ApiException with full context
  ///   if (apiException.isValidationError) { ... }
  /// }
  /// ```
  static Future<T> executeAndUnwrap<T>(Future<T> Function() apiCall) async {
    final response = await execute<T>(apiCall);
    return response.unwrap(); // Will throw ApiException with full context
  }
}
