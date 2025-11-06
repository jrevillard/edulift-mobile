import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/domain/services/auth_service.dart';
import 'package:edulift/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:edulift/features/schedule/domain/failures/schedule_failure.dart';
import 'package:edulift/core/domain/entities/schedule.dart'
    as schedule_entities;
import 'package:edulift/features/dashboard/domain/entities/dashboard_transport_summary.dart';
import 'package:edulift/features/dashboard/domain/utils/dashboard_schedule_utils.dart';

/// Use case for aggregating today's transport summary for dashboard display
///
/// This use case focuses specifically on today's transport data with timezone-aware
/// time formatting using the TimeOfDayValue.toLocalTimeString() extension.
/// All business logic stays in the core domain - this is a display-only aggregation.
class GetTodayTransportSummary {
  final GroupScheduleRepository _scheduleRepository;
  final AuthService _authService;

  GetTodayTransportSummary({
    required GroupScheduleRepository scheduleRepository,
    required AuthService authService,
  }) : _scheduleRepository = scheduleRepository,
       _authService = authService;

  /// Execute the use case to get today's transport summary
  ///
  /// Parameters:
  /// - groupId: The group ID to get schedule data for
  ///
  /// Returns: Result<List<TransportSlotSummary>, ScheduleFailure>
  ///
  /// This use case:
  /// - Gets today's transport data specifically
  /// - Converts times using TimeOfDayValue.toLocalTimeString() extension
  /// - Aggregates vehicle assignments with capacity calculations
  Future<Result<List<TransportSlotSummary>, ScheduleFailure>> execute(
    String groupId,
  ) async {
    try {
      // Get current user to determine timezone
      final userResult = await _authService.getCurrentUser();
      if (userResult.isErr) {
        return Result.err(
          ScheduleFailure.serverError(
            message:
                'Failed to get user timezone: ${userResult.error?.message}',
          ),
        );
      }

      final user = userResult.value!;
      final userTimezone = user.timezone ?? 'UTC';

      // Get today's date (without time component)
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      // Get week identifier for today
      final week = DashboardScheduleUtils.getWeekIdentifier(today);

      // Get weekly schedule from repository
      final scheduleResult = await _scheduleRepository.getWeeklySchedule(
        groupId,
        week,
      );

      if (scheduleResult.isErr) {
        return Result.err(
          ScheduleFailure.serverError(
            message:
                'Failed to get weekly schedule: ${scheduleResult.error?.message}',
          ),
        );
      }

      final scheduleSlots = scheduleResult.value!;

      // Filter and aggregate today's slots
      final todayTransportSummaries = await _aggregateTodayTransports(
        scheduleSlots,
        todayDate,
        userTimezone,
      );

      return Result.ok(todayTransportSummaries);
    } catch (e) {
      return Result.err(
        ScheduleFailure.serverError(
          message: 'Failed to get today transport summary: $e',
          details: {'error': e.toString()},
        ),
      );
    }
  }

  /// Aggregate today's transport slots into dashboard summaries
  ///
  /// This method processes schedule slots and converts them into
  /// TransportSlotSummary entities with proper timezone formatting.
  Future<List<TransportSlotSummary>> _aggregateTodayTransports(
    List<schedule_entities.ScheduleSlot> scheduleSlots,
    DateTime todayDate,
    String userTimezone,
  ) async {
    // Filter slots for today considering timezone conversions
    final todaySlots = DashboardScheduleUtils.filterSlotsForDay(
      scheduleSlots,
      todayDate,
      userTimezone,
    );

    // Use the extracted common aggregation logic
    return DashboardScheduleUtils.aggregateSlotsToSummaries(todaySlots);
  }
}
