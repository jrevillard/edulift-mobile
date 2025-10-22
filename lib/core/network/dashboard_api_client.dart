import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'models/dashboard/index.dart';

part 'dashboard_api_client.g.dart';

@RestApi()
abstract class DashboardApiClient {
  factory DashboardApiClient(Dio dio, {String baseUrl}) = _DashboardApiClient;

  /// Factory constructor for creating DashboardApiClient with configured Dio
  static DashboardApiClient create(Dio dio) {
    return _DashboardApiClient(dio, baseUrl: dio.options.baseUrl);
  }

  /// Get dashboard statistics
  @GET('/api/dashboard/stats')
  Future<DashboardStatsDto> getDashboardStats();

  /// Get today's schedule
  @GET('/api/dashboard/today')
  Future<TodayScheduleListDto> getTodaySchedule();

  /// Get weekly schedule
  @GET('/api/dashboard/weekly')
  Future<WeeklyScheduleDto> getWeeklySchedule();
}
