import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../errors/api_exception.dart';

part 'api_response_wrapper.freezed.dart';

/// State-of-the-art API Response Wrapper for 2025 best practices
///
/// This class implements Gemini's recommended "explicit wrapper with helper" approach
/// to replace the previous "magic interceptor" pattern. Key benefits:
/// - Explicit: Every API call clearly returns ApiResponse<T>
/// - Transparent: No hidden data extraction in interceptors
/// - Maintainable: Easy to debug and understand data flow
/// - Type-safe: Compile-time guarantees about response structure
///
/// **Architecture Pattern:**
/// ```dart
/// // API Client returns explicit wrapper
/// Future<ApiResponse<AuthDto>> verifyMagicLink(request) async { ... }
///
/// // Repository uses explicit unwrap()
/// final response = await authApiClient.verifyMagicLink(request);
/// return response.unwrap(); // Clear, explicit, reusable
/// ```
@freezed
abstract class ApiResponse<T> with _$ApiResponse<T> {
  const ApiResponse._();

  const factory ApiResponse({
    required bool success,
    T? data,
    String? errorMessage,
    String? errorCode,
    int? statusCode,
    @Default({}) Map<String, dynamic> metadata,
  }) = _ApiResponse<T>;

  /// Factory constructor for successful responses with data
  factory ApiResponse.success(T data, {Map<String, dynamic>? metadata}) {
    return ApiResponse<T>(success: true, data: data, metadata: metadata ?? {});
  }

  /// Factory constructor for error responses
  factory ApiResponse.error(
    String errorMessage, {
    String? errorCode,
    int? statusCode,
    Map<String, dynamic>? metadata,
  }) {
    return ApiResponse<T>(
      success: false,
      errorMessage: errorMessage,
      errorCode: errorCode,
      statusCode: statusCode,
      metadata: metadata ?? {},
    );
  }

  /// Factory constructor from HTTP error response
  factory ApiResponse.fromHttpError(
    int statusCode,
    String message, {
    Map<String, dynamic>? responseData,
  }) {
    return ApiResponse<T>(
      success: false,
      errorMessage: message,
      statusCode: statusCode,
      metadata: responseData ?? {},
    );
  }

  /// Factory constructor from backend wrapper pattern
  /// Handles: { success: bool, data: T, error?: string, code?: string }
  factory ApiResponse.fromBackendWrapper(
    Map<String, dynamic> wrapperData,
    T Function(dynamic json) fromJsonT, {
    int? statusCode,
  }) {
    return ApiResponseUtils.fromBackendWrapper(
      wrapperData,
      fromJsonT,
      statusCode: statusCode,
    );
  }
}

/// Extension for clean data extraction with explicit error handling
///
/// This replaces the "magic interceptor" approach with explicit, transparent unwrapping:
/// ```dart
/// // Old approach (hidden magic in interceptor):
/// final authDto = await authApiClient.verifyMagicLink(request); // Magic extraction
///
/// // New approach (explicit wrapper with helper):
/// final response = await authApiClient.verifyMagicLink(request);
/// final authDto = response.unwrap(); // Explicit, clear, reusable
/// ```
extension ApiResponseUnwrapper<T> on ApiResponse<T> {
  /// Extracts data from successful response or throws ApiException
  ///
  /// **Key Benefits:**
  /// - Explicit: Developer clearly sees when unwrapping happens
  /// - Transparent: No hidden data extraction logic
  /// - Type-safe: Compile-time guarantees about data availability
  /// - Reusable: Same pattern across entire codebase
  /// - Maintainable: Easy to debug and understand
  ///
  /// **Special handling for void responses:**
  /// - For `ApiResponse<void>`, if success=true, returns null (cast as void)
  /// - This allows DELETE/PUT endpoints that return JSON bodies but have void return type
  /// - Example: `{"success": true, "message": "..."}` on DELETE endpoint
  T unwrap() {
    // Error case first: throw if not successful
    if (!success) {
      throw ApiException(
        message: errorMessage ?? 'Unknown API error',
        statusCode: statusCode,
        errorCode: errorCode,
        details: metadata.isNotEmpty ? metadata : null,
      );
    }

    // Success case: return data if present
    if (data != null) {
      return data!;
    }

    // Success but no data: acceptable for void/nullable types only
    // For void: null is the valid return value
    // For String?: null is acceptable
    // For String: this will cause a type error at compile time, not runtime
    return null as T;
  }

  /// Extracts data or returns null for optional unwrapping
  T? unwrapOrNull() {
    return success ? data : null;
  }

  /// Extracts data or returns default value
  T unwrapOr(T defaultValue) {
    return (success && data != null) ? data! : defaultValue;
  }

  /// Safely extracts data with custom error handling
  T unwrapOrElse(T Function(String? errorMessage, String? errorCode) onError) {
    if (success && data != null) {
      return data!;
    }
    return onError(errorMessage, errorCode);
  }

  /// Checks if the response contains a specific error code
  bool hasErrorCode(String code) {
    return !success && errorCode == code;
  }

  /// Checks if this is a validation error (422 or validation-related code)
  bool get isValidationError {
    return statusCode == 422 ||
        errorCode?.toUpperCase().contains('VALIDATION') == true ||
        errorCode?.toUpperCase().contains('INVALID') == true;
  }

  /// Checks if this is an authentication error (401)
  bool get isAuthenticationError {
    return statusCode == 401 ||
        errorCode?.toUpperCase().contains('UNAUTHORIZED') == true ||
        errorCode?.toUpperCase().contains('AUTH') == true;
  }

  /// Checks if this is an authorization error (403)
  bool get isAuthorizationError {
    return statusCode == 403 ||
        errorCode?.toUpperCase().contains('FORBIDDEN') == true ||
        errorCode?.toUpperCase().contains('PERMISSION') == true;
  }

  /// Checks if this error is retryable (5xx errors)
  bool get isRetryable {
    return statusCode != null && statusCode! >= 500;
  }

  /// Checks if this requires user action (4xx errors)
  bool get requiresUserAction {
    return statusCode != null && statusCode! >= 400 && statusCode! < 500;
  }
}

/// Utility methods for API response handling
class ApiResponseUtils {
  /// Factory constructor from JSON for API responses
  static ApiResponse<T> fromApiJson<T>(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    if (json['success'] == true) {
      return ApiResponse<T>(
        success: true,
        data: json['data'] != null ? fromJsonT(json['data']) : null,
        errorMessage: json['error']?.toString(),
        errorCode: json['code']?.toString(),
        statusCode: json['statusCode'] as int?,
        metadata: Map<String, dynamic>.from(json)
          ..removeWhere(
            (key, value) => [
              'success',
              'data',
              'error',
              'code',
              'statusCode',
            ].contains(key),
          ),
      );
    }

    return ApiResponse<T>(
      success: false,
      errorMessage: json['error']?.toString() ?? 'Unknown API error',
      errorCode: json['code']?.toString(),
      statusCode: json['statusCode'] as int?,
      metadata: Map<String, dynamic>.from(json)
        ..removeWhere(
          (key, value) =>
              ['success', 'data', 'error', 'code', 'statusCode'].contains(key),
        ),
    );
  }

  /// Factory constructor from backend wrapper pattern
  /// Handles: { success: bool, data: T, error?: string, code?: string }
  static ApiResponse<T> fromBackendWrapper<T>(
    Map<String, dynamic> wrapperData,
    T Function(dynamic json) fromJsonT, {
    int? statusCode,
  }) => fromApiJson(wrapperData, fromJsonT);
}
