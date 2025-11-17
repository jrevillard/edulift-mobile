import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:edulift/generated/l10n/app_localizations.dart';
import 'package:edulift/features/dashboard/presentation/providers/transport_providers.dart';
import 'package:edulift/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:edulift/features/dashboard/domain/entities/dashboard_transport_summary.dart';
import 'package:edulift/features/dashboard/presentation/widgets/transport_horizontal_list.dart';
import 'package:edulift/core/utils/weekday_localization.dart';

/// Seven Day Timeline Widget for dashboard transport overview
///
/// Displays a 7-day rolling view of transport schedules with day selection.
/// Shows transport details for the selected day.
///
/// Features:
/// - 7-day rolling window (today → today+6)
/// - Interactive day badges with transport indicators
/// - Selected day shows full transport details in horizontal scrollable cards
/// - Pull-to-refresh functionality
/// - Material 3 design with proper accessibility
/// - Responsive design (mobile/tablet)
class SevenDayTimelineWidget extends ConsumerStatefulWidget {
  const SevenDayTimelineWidget({super.key});

  @override
  ConsumerState<SevenDayTimelineWidget> createState() =>
      _SevenDayTimelineWidgetState();
}

class _SevenDayTimelineWidgetState
    extends ConsumerState<SevenDayTimelineWidget> {
  int _selectedDayIndex = 0; // Today by default

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final weeklyAsync = ref.watch(day7TransportSummaryProvider);
    final refreshCallback = ref.read(dashboardRefreshProvider);

    return Semantics(
      label: l10n.weeklySchedule,
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
          label: l10n.weeklySchedule,
          child: Icon(
            Icons.calendar_view_week,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              l10n.weeklySchedule,
              key: const Key('weekly_schedule_title'),
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

  Widget _buildCollapsedView(
    BuildContext context,
    List<DayTransportSummary> summaries,
    AppLocalizations l10n,
  ) {
    // Generate 7-day rolling window starting from today
    final weekDays = _generateWeekDays();
    final selectedDate = weekDays[_selectedDayIndex];
    final selectedSummary = summaries
        .where((s) => _isSameDay(s.date, selectedDate))
        .firstOrNull;

    // Responsive layout parameters
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    // Badge sizing - larger on mobile, compact on tablet
    final badgeWidth = isTablet ? 56.0 : 64.0;
    final badgeHeight = isTablet ? 64.0 : 72.0;
    final badgeSpacing = isTablet ? 8.0 : 12.0;
    final horizontalPadding = isTablet ? 4.0 : 8.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Day badges (horizontal selector)
        SizedBox(
          height: badgeHeight,
          child: Semantics(
            label: 'Week day selector',
            child: ListView.separated(
              key: const Key('week_day_selector'),
              scrollDirection: Axis.horizontal,
              // Use snap-to-center physics on mobile for better UX
              physics: isTablet
                  ? const ClampingScrollPhysics()
                  : const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              itemCount: weekDays.length,
              separatorBuilder: (context, index) =>
                  SizedBox(width: badgeSpacing),
              itemBuilder: (context, index) {
                final dayDate = weekDays[index];
                final summary = summaries
                    .where((s) => _isSameDay(s.date, dayDate))
                    .firstOrNull;
                final isSelected = _selectedDayIndex == index;

                return SelectableDayBadge(
                  key: Key('day_badge_$index'),
                  date: dayDate,
                  summary: summary,
                  isToday: _isSameDay(dayDate, DateTime.now()),
                  isSelected: isSelected,
                  isTablet: isTablet,
                  badgeWidth: badgeWidth,
                  onTap: () {
                    setState(() {
                      _selectedDayIndex = index;
                    });
                  },
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),

        // Selected day header
        Text(
          _formatSelectedDayHeader(context, selectedDate),
          key: const Key('selected_day_header'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        // Transport mini cards for selected day
        if (selectedSummary != null && selectedSummary.hasScheduledTransports)
          TransportHorizontalList(
            key: const Key('selected_day_transports'),
            transports: selectedSummary.transports,
            semanticLabel:
                'Transports for ${_formatSelectedDayHeader(context, selectedDate)}',
          )
        else
          _buildNoTransportsForDay(context, l10n),
      ],
    );
  }

  /// Build message when selected day has no transports
  Widget _buildNoTransportsForDay(BuildContext context, AppLocalizations l10n) {
    return SizedBox(
      key: const Key('no_transports_selected_day'),
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule,
              size: 40,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noTransportsToday,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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

/// Format day name using existing utility to avoid code duplication
String _formatDayName(BuildContext context, DateTime date) {
  final l10n = AppLocalizations.of(context);
  final shortLabels = getLocalizedWeekdayShortLabels(l10n);
  return shortLabels[date.weekday -
      1]; // Monday=1, so subtract 1 for 0-indexed array
}

/// Format date using locale-aware DateFormat
String _formatDate(BuildContext context, DateTime date) {
  final l10n = AppLocalizations.of(context);
  final formatter = DateFormat('d MMM', l10n.localeName);
  return formatter.format(date);
}

/// Format selected day header combining day name and date
String _formatSelectedDayHeader(BuildContext context, DateTime date) {
  final dayName = _formatDayName(context, date);
  final dateStr = _formatDate(context, date);
  return '$dayName, $dateStr';
}

/// Selectable day badge for week view
///
/// Shows day name with transport indicator and selection state.
/// Shows first letter of day name + dot indicator if has transports.
/// Supports tap to select the day.
/// Responsive design: larger touch targets on mobile, compact on tablet.
class SelectableDayBadge extends StatelessWidget {
  final DateTime date;
  final DayTransportSummary? summary;
  final bool isToday;
  final bool isSelected;
  final bool isTablet;
  final double badgeWidth;
  final VoidCallback onTap;

  const SelectableDayBadge({
    super.key,
    required this.date,
    this.summary,
    this.isToday = false,
    this.isSelected = false,
    this.isTablet = false,
    this.badgeWidth = 56.0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dayName = _formatDayName(context, date);
    final transportCount = summary?.transports.length ?? 0;
    final hasTransports = transportCount > 0;

    // Responsive text sizing
    final textStyle = isTablet
        ? Theme.of(context).textTheme.bodySmall
        : Theme.of(context).textTheme.bodyMedium;

    // Responsive indicator sizing
    final indicatorSize = isTablet ? 6.0 : 8.0;
    final indicatorSpacing = isTablet ? 4.0 : 6.0;

    return Semantics(
      label: hasTransports
          ? '$dayName, $transportCount transports'
          : '$dayName, no transports',
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: badgeWidth,
          // Minimum touch target of 48x48 for accessibility
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : (isToday
                      ? Theme.of(context).colorScheme.surfaceContainerHighest
                      : Theme.of(context).colorScheme.surface),
            borderRadius: BorderRadius.circular(isTablet ? 12 : 16),
            border: isSelected
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : (isToday
                      ? Border.all(
                          color: Theme.of(context).colorScheme.outline,
                          width: 1.5,
                        )
                      : null),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Day short name (e.g., Mon, Tue, Wed)
              Text(
                dayName,
                style: textStyle?.copyWith(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (hasTransports) ...[
                SizedBox(height: indicatorSpacing),
                Container(
                  width: indicatorSize,
                  height: indicatorSize,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
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
    final dayName = _formatDayName(context, date);
    final dateStr = _formatDate(context, date);

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
}
