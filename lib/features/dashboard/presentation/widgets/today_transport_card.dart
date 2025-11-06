import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edulift/generated/l10n/app_localizations.dart';
import 'package:edulift/features/dashboard/presentation/providers/transport_providers.dart';
import 'package:edulift/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:edulift/features/dashboard/domain/entities/dashboard_transport_summary.dart';
import 'package:edulift/core/domain/entities/schedule/time_of_day.dart';
import 'package:edulift/core/domain/entities/schedule/vehicle_assignment.dart';

/// Today's Transport Card for the dashboard
///
/// Displays today's transport schedule in a horizontally scrollable card format.
/// Features pull-to-refresh, loading/error states, and Material 3 design.
class TodayTransportCard extends ConsumerWidget {
  const TodayTransportCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final todayAsync = ref.watch(todayTransportSummaryProvider);
    final refreshCallback = ref.read(dashboardRefreshProvider);

    return Semantics(
      label: l10n.todayTransports,
      child: Card(
        key: const Key('today_transport_card'),
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
                todayAsync,
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
    final currentDate = _formatCurrentDate();

    return Row(
      children: [
        Semantics(
          label: l10n.todayTransports,
          child: Icon(
            Icons.today,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              l10n.todayTransports,
              key: const Key('today_transports_title'),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            currentDate,
            key: const Key('current_date_badge'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRefreshableContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<DayTransportSummary?> todayAsync,
    VoidCallback? refreshCallback,
  ) {
    final l10n = AppLocalizations.of(context);

    // For empty, loading, and error states, we don't need refresh functionality
    return todayAsync.when(
      data: (summary) {
        if (summary == null || !summary.hasScheduledTransports) {
          return _buildEmptyState(context, l10n);
        }

        // Only wrap with refresh if we have actual content to refresh
        if (refreshCallback != null) {
          return SizedBox(
            height: 160,
            child: RefreshIndicator(
              onRefresh: () async {
                // Invalidate the provider to trigger a refresh
                ref.invalidate(todayTransportSummaryProvider);
                // Also call the dashboard refresh callback if available
                refreshCallback.call();
              },
              child: _buildTransportListView(context, summary.transports),
            ),
          );
        }

        return _buildTransportList(context, summary.transports);
      },
      loading: () => _buildLoadingState(context, l10n),
      error: (error, stack) => _buildErrorState(context, l10n, error, ref),
    );
  }

  Widget _buildTransportListView(
    BuildContext context,
    List<TransportSlotSummary> transports,
  ) {
    return Semantics(
      label: AppLocalizations.of(context).todayTransportList,
      child: ListView.separated(
        key: const Key('transport_list'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: transports.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final transport = transports[index];
          return TransportMiniCard(
            key: Key('transport_mini_card_$index'),
            transport: transport,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return SizedBox(
      key: const Key('no_transports_empty_state'),
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: l10n.noTripsScheduledIcon,
              child: Icon(
                Icons.schedule,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noTransportsToday,
              key: const Key('no_transports_message'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, AppLocalizations l10n) {
    return SizedBox(
      key: const Key('today_transports_loading'),
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(
              l10n.loadingTodayTransports,
              key: const Key('loading_transports_message'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
      key: const Key('today_transports_error'),
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
              label: l10n.errorLoadingTransports,
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
                key: const Key('error_loading_message'),
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
              key: const Key('retry_button'),
              onPressed: () {
                ref.invalidate(todayTransportSummaryProvider);
              },
              child: Text(
                l10n.actionTryAgain,
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

  Widget _buildTransportList(
    BuildContext context,
    List<TransportSlotSummary> transports,
  ) {
    if (transports.isEmpty) {
      return _buildEmptyState(context, AppLocalizations.of(context));
    }

    return SizedBox(
      height: 160,
      child: _buildTransportListView(context, transports),
    );
  }

  Widget _buildFooter(
    BuildContext context,
    AppLocalizations l10n,
    VoidCallback refreshCallback,
  ) {
    return Semantics(
      button: true,
      hint: l10n.seeFullSchedule,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 48, // WCAG AA minimum touch target
        ),
        child: InkWell(
          key: const Key('see_full_schedule_button'),
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
                  l10n.seeFullSchedule,
                  key: const Key('see_full_schedule_text'),
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

  String _formatCurrentDate() {
    final now = DateTime.now();
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
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

    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }
}

/// Mini card displaying a single transport slot
///
/// Shows transport time, destination, and capacity status in a compact format.
/// Designed for horizontal scrolling in the TodayTransportCard.
class TransportMiniCard extends StatelessWidget {
  final TransportSlotSummary transport;

  const TransportMiniCard({super.key, required this.transport});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Transport: ${_formatTime(transport.time)} to ${transport.destination} with ${transport.totalChildrenAssigned} children',
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280, minWidth: 200),
        child: Card(
          elevation: 2,
          child: InkWell(
            onTap: () {
              // Navigate to transport details
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTimeSection(context),
                  const SizedBox(height: 8),
                  _buildDestinationSection(context),
                  const SizedBox(height: 8),
                  _buildCapacitySection(context),
                  const Spacer(),
                  _buildVehiclesSection(context, AppLocalizations.of(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSection(BuildContext context) {
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
            key: const Key('transport_time'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Spacer(),
        _buildCapacityIndicator(context),
      ],
    );
  }

  Widget _buildDestinationSection(BuildContext context) {
    return Semantics(
      label: 'Destination: ${transport.destination}',
      child: Text(
        transport.destination,
        key: const Key('transport_destination'),
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildCapacitySection(BuildContext context) {
    final utilizationPercentage = transport.utilizationPercentage;
    final capacityColor = _getCapacityStatusColor(
      context,
      transport.overallCapacityStatus,
    );

    return Row(
      children: [
        Icon(
          Icons.people,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '${transport.totalChildrenAssigned}/${transport.totalCapacity} seats',
            key: const Key('transport_capacity'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: utilizationPercentage / 100,
            child: Container(
              decoration: BoxDecoration(
                color: capacityColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehiclesSection(BuildContext context, AppLocalizations l10n) {
    if (transport.vehicleAssignmentSummaries.isEmpty) {
      return Text(
        l10n.noVehiclesAssigned,
        key: const Key('no_vehicles_assigned'),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    final vehicleCount = transport.vehicleAssignmentSummaries.length;
    final firstVehicle = transport.vehicleAssignmentSummaries.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              Icons.directions_car,
              size: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              vehicleCount == 1
                  ? firstVehicle.vehicleName
                  : '$vehicleCount vehicles',
              key: const Key('vehicle_count'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        if (firstVehicle.assignedChildrenCount > 0) ...[
          const SizedBox(height: 4),
          Text(
            '${firstVehicle.assignedChildrenCount} children',
            key: const Key('children_count'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildCapacityIndicator(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (transport.overallCapacityStatus) {
      case CapacityStatus.available:
        statusColor = Theme.of(context).colorScheme.primary;
        statusIcon = Icons.check_circle;
        break;
      case CapacityStatus.nearFull:
        statusColor = Theme.of(context).colorScheme.secondary;
        statusIcon = Icons.warning;
        break;
      case CapacityStatus.full:
        statusColor = Theme.of(context).colorScheme.error;
        statusIcon = Icons.error;
        break;
      case CapacityStatus.exceeded:
        statusColor = Theme.of(context).colorScheme.error;
        statusIcon = Icons.error;
        break;
    }

    return Semantics(
      label: 'Capacity status: ${transport.overallCapacityStatus.name}',
      child: Icon(statusIcon, size: 16, color: statusColor),
    );
  }

  Color _getCapacityStatusColor(BuildContext context, CapacityStatus status) {
    switch (status) {
      case CapacityStatus.available:
        return Theme.of(context).colorScheme.primary;
      case CapacityStatus.nearFull:
        return Theme.of(context).colorScheme.secondary;
      case CapacityStatus.full:
        return Theme.of(context).colorScheme.error;
      case CapacityStatus.exceeded:
        return Theme.of(context).colorScheme.error;
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
