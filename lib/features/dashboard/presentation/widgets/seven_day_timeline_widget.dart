import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edulift/generated/l10n/app_localizations.dart';
import 'package:edulift/features/dashboard/presentation/providers/transport_providers.dart';
import 'package:edulift/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:edulift/features/dashboard/domain/entities/dashboard_transport_summary.dart';
import 'package:edulift/core/domain/entities/schedule/time_of_day.dart';
import 'package:edulift/core/domain/entities/schedule/vehicle_assignment.dart';

/// Seven Day Timeline Widget for dashboard transport overview
///
/// Displays a 7-day rolling view of transport schedules with expand/collapse
/// functionality. Shows transport counts and capacity status for quick overview
/// in collapsed state, detailed breakdown in expanded state.
///
/// Features:
/// - 7-day rolling window (Thursday → Thursday)
/// - Collapsed state: Day badges with transport count and status
/// - Expanded state: Detailed day-by-day transport breakdown
/// - Pull-to-refresh functionality
/// - Material 3 design with proper accessibility
class SevenDayTimelineWidget extends ConsumerWidget {
  const SevenDayTimelineWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final weeklyAsync = ref.watch(day7TransportSummaryProvider);
    final isExpanded = ref.watch(weekViewExpandedNotifierProvider);
    final refreshCallback = ref.read(dashboardRefreshProvider);

    return Semantics(
      label:
          '${l10n.next7Days}, ${isExpanded ? l10n.weekViewExpanded : 'collapsed'}',
      child: Card(
        key: const Key('seven_day_timeline_widget'),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context, ref, l10n, isExpanded),
              const SizedBox(height: 16),
              _buildRefreshableContent(
                context,
                ref,
                weeklyAsync,
                isExpanded,
                refreshCallback,
              ),
              if (refreshCallback != null && !isExpanded) ...[
                const SizedBox(height: 16),
                _buildFooter(context, l10n, refreshCallback),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    bool isExpanded,
  ) {
    return Row(
      children: [
        Semantics(
          label: l10n.next7Days,
          child: Icon(
            Icons.date_range,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              l10n.next7Days,
              key: const Key('next_7_days_title'),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Semantics(
          button: true,
          label: isExpanded ? l10n.collapseWeekView : l10n.expandWeekView,
          hint: isExpanded ? 'Collapse week view' : 'Expand week view',
          child: IconButton(
            key: const Key('week_view_toggle_button'),
            onPressed: () {
              ref.read(weekViewExpandedNotifierProvider.notifier).toggle();
            },
            tooltip: isExpanded ? l10n.collapseWeekView : l10n.expandWeekView,
            icon: AnimatedRotation(
              turns: isExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.expand_more,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRefreshableContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<DayTransportSummary>> weeklyAsync,
    bool isExpanded,
    VoidCallback? refreshCallback,
  ) {
    final l10n = AppLocalizations.of(context);

    // For empty, loading, and error states, we don't need refresh functionality
    return weeklyAsync.when(
      data: (summaries) {
        if (summaries.isEmpty) {
          return _buildEmptyState(context, l10n);
        }

        // Only wrap with refresh if we have actual content to refresh
        if (refreshCallback != null) {
          return RefreshIndicator(
            onRefresh: () async {
              // Invalidate the provider to trigger a refresh
              ref.invalidate(day7TransportSummaryProvider);
              // Also call the dashboard refresh callback if available
              refreshCallback.call();
            },
            child: isExpanded
                ? _buildExpandedView(context, summaries, l10n)
                : _buildCollapsedView(context, summaries, l10n),
          );
        }

        return isExpanded
            ? _buildExpandedView(context, summaries, l10n)
            : _buildCollapsedView(context, summaries, l10n);
      },
      loading: () => _buildLoadingState(context, l10n),
      error: (error, stack) => _buildErrorState(context, l10n, error, ref),
    );
  }

  Widget _buildCollapsedView(
    BuildContext context,
    List<DayTransportSummary> summaries,
    AppLocalizations l10n,
  ) {
    // Generate 7-day rolling window starting from today
    final weekDays = _generateWeekDays();

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 80,
        maxHeight: _calculateCollapsedViewHeight(context),
      ),
      child: Semantics(
        label: 'Week overview with transport counts',
        child: ListView.separated(
          key: const Key('week_overview_list'),
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          itemCount: weekDays.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final dayDate = weekDays[index];
            final summary = summaries
                .where((s) => _isSameDay(s.date, dayDate))
                .firstOrNull;

            return DayBadge(
              key: Key('day_badge_$index'),
              date: dayDate,
              summary: summary,
              isToday: _isSameDay(dayDate, DateTime.now()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildExpandedView(
    BuildContext context,
    List<DayTransportSummary> summaries,
    AppLocalizations l10n,
  ) {
    // Generate 7-day rolling window starting from today
    final weekDays = _generateWeekDays();

    return Semantics(
      label: 'Detailed week view with transport information',
      child: ListView.separated(
        key: const Key('week_detail_list'),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: weekDays.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final dayDate = weekDays[index];
          final summary = summaries
              .where((s) => _isSameDay(s.date, dayDate))
              .firstOrNull;

          return DayDetailCard(
            key: Key('day_detail_card_$index'),
            date: dayDate,
            summary: summary,
            isToday: _isSameDay(dayDate, DateTime.now()),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return ConstrainedBox(
      key: const Key('no_transports_week_empty_state'),
      constraints: BoxConstraints(
        minHeight: 120,
        maxHeight: _calculateMaxContentHeight(context),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: 'No transports this week icon',
              child: Icon(
                Icons.date_range_outlined,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: Text(
                l10n.noTransportsWeek,
                key: const Key('no_transports_week_message'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, AppLocalizations l10n) {
    return ConstrainedBox(
      key: const Key('week_timeline_loading'),
      constraints: BoxConstraints(
        minHeight: 120,
        maxHeight: _calculateMaxContentHeight(context),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Flexible(
              child: Text(
                'Loading week schedule...',
                key: const Key('loading_week_message'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    AppLocalizations l10n,
    Object error,
    WidgetRef ref,
  ) {
    return ConstrainedBox(
      key: const Key('week_timeline_error'),
      constraints: BoxConstraints(
        minHeight: 140, // Increased minimum height to prevent overflow
        maxHeight: _calculateMaxContentHeight(
          context,
        ), // Dynamic max height based on screen size
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: 'Error loading week data',
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: Text(
                l10n.refreshFailed,
                key: const Key('week_error_message'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              key: const Key('week_retry_button'),
              onPressed: () {
                ref.invalidate(day7TransportSummaryProvider);
              },
              child: Text(
                'Try Again',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(
    BuildContext context,
    AppLocalizations l10n,
    VoidCallback refreshCallback,
  ) {
    return Semantics(
      button: true,
      hint: 'View full week schedule',
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 48, // WCAG AA minimum touch target
        ),
        child: InkWell(
          key: const Key('see_week_schedule_button'),
          onTap: refreshCallback,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View Full Week',
                  key: const Key('see_week_schedule_text'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Generate 7-day rolling window starting from today
  List<DateTime> _generateWeekDays() {
    final today = DateTime.now();
    final weekDays = <DateTime>[];

    for (var i = 0; i < 7; i++) {
      weekDays.add(today.add(Duration(days: i)));
    }

    return weekDays;
  }

  /// Helper method to compare dates without time components
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Calculate maximum content height based on screen size and content requirements
  double _calculateMaxContentHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final availableHeight = screenHeight - safeAreaTop - safeAreaBottom;

    // For error/loading/empty states, use a reasonable portion of available height
    // but not too much to dominate the screen
    return math.min(200, availableHeight * 0.25);
  }

  /// Calculate appropriate height for collapsed week view
  double _calculateCollapsedViewHeight(BuildContext context) {
    // DayBadge has minHeight of 48, so calculate based on that plus padding
    const baseHeight = 48.0; // Minimum touch target for DayBadge
    const verticalPadding = 16.0; // 8px top + 8px bottom padding
    return baseHeight + verticalPadding;
  }
}

/// Day badge for collapsed week view
///
/// Shows day name, transport count, and capacity status in a compact badge.
class DayBadge extends StatelessWidget {
  final DateTime date;
  final DayTransportSummary? summary;
  final bool isToday;

  const DayBadge({
    super.key,
    required this.date,
    this.summary,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dayName = _formatDayName(date);
    final transportCount = summary?.transports.length ?? 0;
    final hasTransports = transportCount > 0;

    return Semantics(
      label: hasTransports
          ? l10n.dayWithTransports(dayName, transportCount)
          : '$dayName, no transports',
      selected: isToday,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 60,
          maxWidth: 80,
          minHeight: 48, // WCAG AA minimum touch target
        ),
        child: Card(
          elevation: isToday ? 4 : 2,
          color: isToday
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
          child: InkWell(
            onTap: () {
              // Handle day selection - could expand to that day
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dayName,
                    key: const Key('day_name'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isToday
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (hasTransports) ...[
                    Text(
                      '$transportCount',
                      key: const Key('transport_count'),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: isToday
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    _buildCapacityIndicator(context),
                  ] else ...[
                    Text(
                      '0',
                      key: const Key('no_transports'),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: isToday
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      width: 16,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCapacityIndicator(BuildContext context) {
    if (summary == null || summary!.transports.isEmpty) {
      return Container(
        width: 16,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }

    // Get overall capacity status from all transports
    final transports = summary!.transports;
    final hasFull = transports.any(
      (t) => t.overallCapacityStatus == CapacityStatus.full,
    );
    final hasAvailable = transports.any(
      (t) => t.overallCapacityStatus == CapacityStatus.available,
    );

    Color color;
    if (hasFull) {
      color = Colors.red;
    } else if (hasAvailable) {
      color = Colors.green;
    } else {
      color = Colors.orange;
    }

    return Container(
      width: 16,
      height: 4,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  String _formatDayName(DateTime date) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return dayNames[date.weekday - 1];
  }
}

/// Day detail card for expanded week view
///
/// Shows comprehensive transport information for a single day.
class DayDetailCard extends StatelessWidget {
  final DateTime date;
  final DayTransportSummary? summary;
  final bool isToday;

  const DayDetailCard({
    super.key,
    required this.date,
    this.summary,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dayName = _formatFullDayName(date);
    final dateStr = _formatDate(date);

    return Semantics(
      label: '$dayName $dateStr transport details',
      child: Card(
        key: const Key('day_detail_card'),
        elevation: isToday ? 4 : 2,
        color: isToday
            ? Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.1)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDayHeader(context, dayName, dateStr),
              const SizedBox(height: 12),
              if (summary != null && summary!.hasScheduledTransports)
                _buildTransportsList(context, summary!.transports)
              else
                _buildNoTransportsMessage(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayHeader(BuildContext context, String dayName, String dateStr) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isToday
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            dayName,
            key: const Key('day_name_header'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isToday
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            dateStr,
            key: const Key('date_header'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isToday) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Today',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onTertiaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTransportsList(
    BuildContext context,
    List<TransportSlotSummary> transports,
  ) {
    if (transports.isEmpty) {
      return _buildNoTransportsMessage(context, AppLocalizations.of(context));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: transports
          .asMap()
          .entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TransportTimeSlot(
                key: Key('transport_slot_${entry.key}'),
                transport: entry.value,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildNoTransportsMessage(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            Icons.schedule_outlined,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            'No transports scheduled',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  String _formatFullDayName(DateTime date) {
    const dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return dayNames[date.weekday - 1];
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

/// Transport time slot display for expanded view
///
/// Shows detailed information about a single transport time slot.
class TransportTimeSlot extends StatelessWidget {
  final TransportSlotSummary transport;

  const TransportTimeSlot({super.key, required this.transport});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Transport at ${_formatTime(transport.time)} to ${transport.destination}',
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTimeAndDestination(context),
            const SizedBox(height: 8),
            _buildCapacityInfo(context),
            const SizedBox(height: 8),
            _buildVehiclesList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeAndDestination(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            _formatTime(transport.time),
            key: const Key('transport_time_slot'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            transport.destination,
            key: const Key('transport_destination_slot'),
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _buildStatusIcon(context),
      ],
    );
  }

  Widget _buildCapacityInfo(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.people,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          '${transport.totalChildrenAssigned}/${transport.totalCapacity} seats',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: transport.utilizationPercentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: _getCapacityColor(
                    context,
                    transport.overallCapacityStatus,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${transport.utilizationPercentage.toStringAsFixed(0)}%',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVehiclesList(BuildContext context) {
    if (transport.vehicleAssignmentSummaries.isEmpty) {
      return Text(
        'No vehicles assigned',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: transport.vehicleAssignmentSummaries
          .take(3) // Limit to first 3 vehicles for space
          .map(
            (vehicle) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: VehicleInfoRow(vehicle: vehicle),
            ),
          )
          .toList(),
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    IconData icon;
    Color color;

    switch (transport.overallCapacityStatus) {
      case CapacityStatus.available:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case CapacityStatus.nearFull:
        icon = Icons.warning;
        color = Colors.orange;
        break;
      case CapacityStatus.full:
        icon = Icons.error;
        color = Colors.red;
        break;
      case CapacityStatus.exceeded:
        icon = Icons.error;
        color = Colors.red;
        break;
    }

    return Icon(icon, size: 16, color: color);
  }

  Color _getCapacityColor(BuildContext context, CapacityStatus status) {
    switch (status) {
      case CapacityStatus.available:
        return Colors.green;
      case CapacityStatus.nearFull:
        return Colors.orange;
      case CapacityStatus.full:
        return Colors.red;
      case CapacityStatus.exceeded:
        return Colors.red;
    }
  }

  String _formatTime(TimeOfDayValue time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12
        ? hour - 12
        : hour == 0
        ? 12
        : hour;
    final minuteStr = minute.toString().padLeft(2, '0');

    return '$displayHour:$minuteStr $period';
  }
}

/// Vehicle information row for transport details
class VehicleInfoRow extends StatelessWidget {
  final VehicleAssignmentSummary vehicle;

  const VehicleInfoRow({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.directions_car,
          size: 14,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            vehicle.vehicleName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${vehicle.assignedChildrenCount}/${vehicle.vehicleCapacity}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
