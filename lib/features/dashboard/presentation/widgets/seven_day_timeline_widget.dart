import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edulift/generated/l10n/app_localizations.dart';
import 'package:edulift/features/dashboard/presentation/providers/transport_providers.dart';
import 'package:edulift/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:edulift/features/dashboard/domain/entities/dashboard_transport_summary.dart';
import 'package:edulift/features/dashboard/presentation/widgets/transport_horizontal_list.dart';

/// Seven Day Timeline Widget for dashboard transport overview
///
/// Displays a 7-day rolling view of transport schedules in collapsed state.
/// Shows transport counts and capacity status for quick overview.
///
/// Features:
/// - 7-day rolling window (today → today+6)
/// - Day badges with transport count and status
/// - Pull-to-refresh functionality
/// - Material 3 design with proper accessibility
/// - Responsive design (mobile/tablet)
class SevenDayTimelineWidget extends ConsumerWidget {
  const SevenDayTimelineWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final weeklyAsync = ref.watch(day7TransportSummaryProvider);
    final refreshCallback = ref.read(dashboardRefreshProvider);

    return Semantics(
      label: l10n.next7Days,
      child: Card(
        key: const Key('seven_day_timeline_widget'),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context, l10n),
              const SizedBox(height: 16),
              _buildRefreshableContent(
                context,
                ref,
                weeklyAsync,
                refreshCallback,
              ),
              if (refreshCallback != null) ...[
                const SizedBox(height: 16),
                _buildFooter(context, l10n, refreshCallback),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
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
      ],
    );
  }

  Widget _buildRefreshableContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<DayTransportSummary>> weeklyAsync,
    VoidCallback? refreshCallback,
  ) {
    final l10n = AppLocalizations.of(context);

    // For empty, loading, and error states, we don't need refresh functionality
    return weeklyAsync.when(
      data: (summaries) {
        if (summaries.isEmpty) {
          return _buildEmptyState(context, l10n);
        }

        // Always use collapsed view (no expanded state)
        return _buildCollapsedView(context, summaries, l10n);
      },
      loading: () => _buildLoadingState(context, l10n),
      error: (error, stackTrace) =>
          _buildErrorState(context, l10n, error, stackTrace),
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
  bool _isSameDay(dynamic date1, DateTime date2) {
    if (date1 is String) {
      // Parse ISO date string (YYYY-MM-DD)
      final parts = date1.split('-');
      if (parts.length != 3) return false;

      try {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        return year == date2.year && month == date2.month && day == date2.day;
      } catch (e) {
        return false;
      }
    } else if (date1 is DateTime) {
      return date1.year == date2.year &&
          date1.month == date2.month &&
          date1.day == date2.day;
    }
    return false;
  }

  /// Check if current device is a tablet based on screen width
  static bool _isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width > 768;
  }

  /// Calculate appropriate height for collapsed week view
  double _calculateCollapsedViewHeight(BuildContext context) {
    // DayBadge has minHeight of 48, so calculate based on that plus padding
    const baseHeight = 48.0; // Minimum touch target for DayBadge
    const verticalPadding = 16.0; // 8px top + 8px bottom padding
    return baseHeight + verticalPadding;
  }

  Widget _buildCollapsedView(
    BuildContext context,
    List<DayTransportSummary> summaries,
    AppLocalizations l10n,
  ) {
    // Generate 7-day rolling window starting from today
    final weekDays = _generateWeekDays();
    final isTablet = SevenDayTimelineWidget._isTablet(context);
    final calculatedHeight = _calculateCollapsedViewHeight(context);

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: calculatedHeight,
        maxHeight: calculatedHeight,
      ),
      child: Semantics(
        label: 'Week overview with transport counts',
        child: ListView.separated(
          key: const Key('week_overview_list'),
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 16.0 : 8.0,
            vertical: isTablet ? 12.0 : 4.0,
          ),
          itemCount: weekDays.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8.0),
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

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return ConstrainedBox(
      key: const Key('week_timeline_empty'),
      constraints: const BoxConstraints(minHeight: 120),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
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
      constraints: const BoxConstraints(minHeight: 120),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.loadingTodayTransports,
              key: const Key('loading_transports_message'),
              style: Theme.of(context).textTheme.bodyMedium,
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
    StackTrace stackTrace,
  ) {
    return ConstrainedBox(
      key: const Key('week_timeline_error'),
      constraints: const BoxConstraints(minHeight: 120),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 40,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.errorLoadingTransports,
              key: const Key('error_transports_message'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text('Tap to retry', style: Theme.of(context).textTheme.bodySmall),
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
      label: l10n.seeFullSchedule,
      child: TextButton(
        key: const Key('see_full_schedule_button'),
        onPressed: refreshCallback,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                l10n.seeFullSchedule,
                key: const Key('see_full_schedule_text'),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Day badge for collapsed week view
///
/// Shows day name with transport count and capacity status in a compact badge.
/// Shows first letter of day name + dot indicator if has transports
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
    final dayName = _formatDayName(date);
    final transportCount = summary?.transports.length ?? 0;
    final hasTransports = transportCount > 0;
    final isTablet = SevenDayTimelineWidget._isTablet(context);

    return Semantics(
      label: hasTransports
          ? '$dayName, $transportCount transports'
          : '$dayName, no transports',
      selected: isToday,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: isTablet ? 80 : 60,
          maxWidth: isTablet ? 100 : 80,
          minHeight: isTablet ? 60 : 48,
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
              padding: const EdgeInsets.all(2.0), // Minimal padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Simple day name with transport indicator
                  Text(
                    dayName.substring(
                      0,
                      1,
                    ), // Just first letter: M, T, W, T, F, S, S
                    key: const Key('day_name'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isToday
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (hasTransports) ...[
                    const SizedBox(height: 1),
                    Container(
                      width: 6,
                      height: 3,
                      decoration: BoxDecoration(
                        color: isToday
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(1.5),
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
    final dayName = _formatDayName(date);
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
                _buildNoTransportsMessage(context),
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
      return _buildNoTransportsMessage(context);
    }

    return TransportHorizontalList(
      transports: transports,
      semanticLabel: 'Transport list for day',
    );
  }

  Widget _buildNoTransportsMessage(BuildContext context) {
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

  String _formatDayName(DateTime date) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
