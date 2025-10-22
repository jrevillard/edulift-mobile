// EduLift Mobile - Dio API Client Implementation
// DATA LAYER INFRASTRUCTURE IMPLEMENTATION
// Implements the pure interface with concrete Dio dependency

import 'package:dio/dio.dart';

import '../../core/network/api_client_interface.dart';

/// Concrete implementation of ApiClientInterface using Dio
/// Lives in data layer - can import infrastructure packages

class DioApiClient implements ApiClientInterface {
  final Dio _dio;

  DioApiClient(this._dio);

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: params);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Network timeout');
      case DioExceptionType.badResponse:
        return Exception('Server error: ${e.response?.statusCode}');
      case DioExceptionType.connectionError:
        return Exception('Connection error');
      default:
        return Exception('Network error: ${e.message}');
    }
  }
}
