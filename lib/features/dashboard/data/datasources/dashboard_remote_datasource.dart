import 'package:dio/dio.dart';
import '../../../../core/network/dashboard_api_client.dart';
import '../../../../core/network/models/dashboard/index.dart';

/// Remote data source for dashboard following 2025 clean architecture pattern
/// Returns DTOs directly instead of converting to models
abstract class DashboardRemoteDataSource {
  Future<DashboardStatsDto> getDashboardStats();
  Future<TodayScheduleListDto> getTodaySchedule();
  Future<WeeklyScheduleDto> getWeeklySchedule({String? week});
  Future<List<ActivityItemDto>> getRecentActivity({int? limit});
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final DashboardApiClient apiClient;

  DashboardRemoteDataSourceImpl({required this.apiClient});

  /// Get dashboard stats from /dashboard/stats - Returns DTO directly
  @override
  Future<DashboardStatsDto> getDashboardStats() async {
    try {
      return await apiClient.getDashboardStats();
    } on DioException catch (e) {
      throw _handleApiException(e, 'Failed to fetch dashboard stats');
    } catch (e) {
      throw Exception('Unexpected error fetching dashboard stats: $e');
    }
  }

  /// Get today's schedule from /dashboard/today - Returns DTO directly
  @override
  Future<TodayScheduleListDto> getTodaySchedule() async {
    try {
      return await apiClient.getTodaySchedule();
    } on DioException catch (e) {
      throw _handleApiException(e, 'Failed to fetch today\'s schedule');
    } catch (e) {
      throw Exception('Unexpected error fetching today\'s schedule: $e');
    }
  }

  /// Get weekly schedule from /dashboard/weekly - Returns DTO directly
  @override
  Future<WeeklyScheduleDto> getWeeklySchedule({String? week}) async {
    try {
      return await apiClient.getWeeklySchedule();
    } on DioException catch (e) {
      throw _handleApiException(e, 'Failed to fetch weekly schedule');
    } catch (e) {
      throw Exception('Unexpected error fetching weekly schedule: $e');
    }
  }

  /// Get recent activity - Placeholder implementation
  /// TODO: Implement when API client method is available
  @override
  Future<List<ActivityItemDto>> getRecentActivity({int? limit}) async {
    try {
      // TODO: Implement when API client method is available
      // return await apiClient.getRecentActivity(limit: limit);
      // Placeholder implementation - return empty list
      return <ActivityItemDto>[];
    } on DioException catch (e) {
      throw _handleApiException(e, 'Failed to fetch recent activity');
    } catch (e) {
      throw Exception('Unexpected error fetching recent activity: $e');
    }
  }

  /// Handle API exceptions with detailed error messages
  Exception _handleApiException(DioException error, String operation) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('$operation: Connection timeout');
      case DioExceptionType.sendTimeout:
        return Exception('$operation: Send timeout');
      case DioExceptionType.receiveTimeout:
        return Exception('$operation: Receive timeout');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Unknown error';
        switch (statusCode) {
          case 400:
            return Exception('$operation: Bad request - $message');
          case 401:
            return Exception('$operation: Unauthorized - Please login again');
          case 403:
            return Exception(
              '$operation: Forbidden - Insufficient permissions',
            );
          case 404:
            return Exception('$operation: Data not found');
          case 429:
            return Exception(
              '$operation: Too many requests - Please try again later',
            );
          case 500:
            return Exception(
              '$operation: Server error - Please try again later',
            );
          case 502:
            return Exception(
              '$operation: Bad gateway - Service temporarily unavailable',
            );
          case 503:
            return Exception(
              '$operation: Service unavailable - Please try again later',
            );
          default:
            return Exception('$operation: HTTP $statusCode - $message');
        }
      case DioExceptionType.cancel:
        return Exception('$operation: Request cancelled');
      case DioExceptionType.connectionError:
        return Exception('$operation: No internet connection');
      case DioExceptionType.badCertificate:
        return Exception('$operation: Invalid SSL certificate');
      case DioExceptionType.unknown:
        return Exception('$operation: Unknown error - ${error.message}');
    }
  }
}
