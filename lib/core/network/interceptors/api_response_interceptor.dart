import 'package:dio/dio.dart';

/// API Response Interceptor - Extracts 'data' from backend wrapper
///
/// Backend returns: {success: true, data: {token: "...", user: {...}}}
/// Mobile expects: {token: "...", user: {...}}
///
/// This interceptor automatically extracts the 'data' field for successful responses.
class ApiResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Only process successful responses (2xx)
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {

      // Check if response has the backend wrapper structure
      if (response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data;

        // Extract 'data' field if it exists and success is true
        if (responseData['success'] == true && responseData.containsKey('data')) {
          response.data = responseData['data'];
        }
      }
    }

    handler.next(response);
  }
}