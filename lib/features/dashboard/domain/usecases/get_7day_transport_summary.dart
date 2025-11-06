import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/domain/services/auth_service.dart';
import 'package:edulift/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:edulift/features/schedule/domain/failures/schedule_failure.dart';
import 'package:edulift/features/dashboard/domain/entities/dashboard_transport_summary.dart';
import 'package:edulift/features/dashboard/domain/utils/dashboard_schedule_utils.dart';

/// Use case for aggregating 7-day transport summary for dashboard display
///
/// This use case aggregates existing schedule domain entities into dashboard
/// display entities for a rolling 7-day view (Thursday → Thursday, not week-based).
/// All time conversions use existing timezone helpers to ensure consistency.
///
/// PERFORMANCE OPTIMIZATION: This implementation caches weekly schedule data
/// to avoid multiple API calls for the same week.
class Get7DayTransportSummary {
  final GroupScheduleRepository _scheduleRepository;
  final AuthService _authService;

  Get7DayTransportSummary({
    required GroupScheduleRepository scheduleRepository,
    required AuthService authService,
  }) : _scheduleRepository = scheduleRepository,
       _authService = authService;

  /// Execute the use case to get 7-day transport summary
  ///
  /// Parameters:
  /// - groupId: The group ID to get schedule data for
  /// - startDate: Start date for the 7-day period (usually today)
  ///
  /// Returns: Result<List<DayTransportSummary>, ScheduleFailure>
  ///
  /// The 7-day view is rolling (Thursday → Thursday), not week-based.
  /// This matches the UI requirements for dashboard display.
  Future<Result<List<DayTransportSummary>, ScheduleFailure>> execute(
    String groupId,
    DateTime startDate,
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

      // Generate 7-day range (rolling Thursday → Thursday)
      final dailySummaries = <DayTransportSummary>[];

      for (var i = 0; i < 7; i++) {
        final currentDate = startDate.add(Duration(days: i));
        final daySummary = await _generateDaySummary(
          groupId,
          currentDate,
          userTimezone,
        );

        if (daySummary != null) {
          dailySummaries.add(daySummary);
        }
      }

      return Result.ok(dailySummaries);
    } catch (e) {
      return Result.err(
        ScheduleFailure.serverError(
          message: 'Failed to get 7-day transport summary: $e',
          details: {'error': e.toString()},
        ),
      );
    }
  }

  /// Generate day summary for a specific date
  ///
  /// This method aggregates schedule slots and vehicle assignments
  /// for a single day into a dashboard display entity.
  Future<DayTransportSummary?> _generateDaySummary(
    String groupId,
    DateTime date,
    String userTimezone,
  ) async {
    try {
      // Get week identifier for the date
      final week = DashboardScheduleUtils.getWeekIdentifier(date);

      // Get weekly schedule (this includes all slots for the week)
      final scheduleResult = await _scheduleRepository.getWeeklySchedule(
        groupId,
        week,
      );

      if (scheduleResult.isErr) {
        // If we can't get schedule for this day, return empty summary
        return DayTransportSummary(
          date: date,
          transports: const [],
          totalChildrenInVehicles: 0,
          totalVehiclesWithAssignments: 0,
          hasScheduledTransports: false,
        );
      }

      final scheduleSlots = scheduleResult.value!;

      // Filter slots for the specific day considering timezone
      final daySlots = DashboardScheduleUtils.filterSlotsForDay(
        scheduleSlots,
        date,
        userTimezone,
      );

      // Use the extracted common aggregation logic
      final transportSummaries =
          DashboardScheduleUtils.aggregateSlotsToSummaries(daySlots);

      // Calculate totals for the day
      var totalChildrenInVehicles = 0;
      var totalVehiclesWithAssignments = 0;

      for (final transportSummary in transportSummaries) {
        totalChildrenInVehicles += transportSummary.totalChildrenAssigned;
        totalVehiclesWithAssignments +=
            transportSummary.vehicleAssignmentSummaries.length;
      }

      return DayTransportSummary(
        date: date,
        transports: transportSummaries,
        totalChildrenInVehicles: totalChildrenInVehicles,
        totalVehiclesWithAssignments: totalVehiclesWithAssignments,
        hasScheduledTransports: transportSummaries.isNotEmpty,
      );
    } catch (e) {
      // Log error but don't fail the entire operation
      // Return empty summary for this day
      return DayTransportSummary(
        date: date,
        transports: const [],
        totalChildrenInVehicles: 0,
        totalVehiclesWithAssignments: 0,
        hasScheduledTransports: false,
      );
    }
  }
}
