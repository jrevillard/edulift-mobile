import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edulift/generated/l10n/app_localizations.dart';
import 'package:edulift/features/dashboard/presentation/providers/transport_providers.dart';
import 'package:edulift/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:edulift/features/dashboard/presentation/widgets/transport_horizontal_list.dart';
import 'package:edulift/features/dashboard/domain/entities/dashboard_transport_summary.dart';
import 'package:edulift/core/domain/entities/schedule/vehicle_assignment.dart';

/// Today's Transport Card for the dashboard
///
/// **DEPRECATED**: This widget is no longer used in the dashboard.
/// The SevenDayTimelineWidget now handles display of transport details for any selected day,
/// including today (selected by default), making this widget redundant.
///
/// Kept for reference and potential revert if needed.
///
/// Displays today's transport schedule in a horizontally scrollable card format.
/// Features pull-to-refresh, loading/error states, and Material 3 design.
@Deprecated('Use SevenDayTimelineWidget instead')
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
            height: 240,
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
    return TransportHorizontalList(
      transports: transports,
      semanticLabel: AppLocalizations.of(context).todayTransportList,
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
      height: 240,
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
              children: [
                Expanded(
                  child: Text(
                    l10n.seeFullSchedule,
                    key: const Key('see_full_schedule_text'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
}

/// Mini card displaying a single transport slot
///
/// Shows transport time, destination, and capacity status in a compact format.
/// Designed for horizontal scrolling in the TodayTransportCard.
/// Supports responsive width for mobile and tablet layouts.
class TransportMiniCard extends StatelessWidget {
  final TransportSlotSummary transport;
  final double? cardWidth;

  const TransportMiniCard({super.key, required this.transport, this.cardWidth});

  @override
  Widget build(BuildContext context) {
    // Use provided width or fall back to default constraints
    final effectiveWidth = cardWidth ?? 200.0;

    return Semantics(
      label:
          'Transport: ${transport.time} to ${transport.groupName} with ${transport.totalChildrenAssigned} children',
      child: SizedBox(
        width: effectiveWidth,
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
                  const SizedBox(height: 4),
                  _buildDestinationSection(context),
                  const SizedBox(height: 4),
                  _buildCapacitySection(context),
                  const SizedBox(height: 4),
                  // Vehicles section - all vehicles displayed
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
            transport.time,
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
      label: 'Group: ${transport.groupName}',
      child: Text(
        transport.groupName,
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
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    // Display ALL vehicles separately
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: transport.vehicleAssignmentSummaries
          .asMap()
          .entries
          .map(
            (entry) => Padding(
              padding: EdgeInsets.only(
                bottom:
                    entry.key < transport.vehicleAssignmentSummaries.length - 1
                    ? 10.0
                    : 0.0,
              ),
              child: _buildVehicleItem(context, entry.value, entry.key),
            ),
          )
          .toList(),
    );
  }

  /// Build a single vehicle item with all its information
  Widget _buildVehicleItem(
    BuildContext context,
    VehicleAssignmentSummary vehicle,
    int index,
  ) {
    final isFamilyVehicle = vehicle.isFamilyVehicle;

    return Container(
      key: Key('vehicle_item_$index'),
      padding: const EdgeInsets.all(8.0),
      decoration: isFamilyVehicle
          ? BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.tertiaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
            )
          : BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Vehicle header
          Row(
            children: [
              Icon(
                Icons.directions_car,
                size: 14,
                color: isFamilyVehicle
                    ? Theme.of(context).colorScheme.tertiary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  vehicle.vehicleName,
                  key: Key('vehicle_name_$index'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isFamilyVehicle
                        ? Theme.of(context).colorScheme.onTertiaryContainer
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // Children list
          if (vehicle.assignedChildrenCount > 0) ...[
            const SizedBox(height: 4),
            _buildChildrenText(context, vehicle),
          ],
          // Capacity bar
          const SizedBox(height: 6),
          _buildVehicleCapacity(context, vehicle),
        ],
      ),
    );
  }

  /// Build capacity section for a single vehicle
  Widget _buildVehicleCapacity(
    BuildContext context,
    VehicleAssignmentSummary vehicle,
  ) {
    final utilizationPercentage = vehicle.utilizationPercentage;
    final capacityColor = _getCapacityStatusColor(
      context,
      vehicle.capacityStatus,
    );

    return Row(
      children: [
        // Capacity text
        Text(
          '${vehicle.assignedChildrenCount}/${vehicle.vehicleCapacity} seats',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 6),
        // Progress bar
        Expanded(
          child: Container(
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
        ),
      ],
    );
  }

  /// Build children text with color highlighting for family children
  Widget _buildChildrenText(
    BuildContext context,
    VehicleAssignmentSummary vehicle,
  ) {
    if (vehicle.children.isEmpty) {
      return Text(
        '${vehicle.assignedChildrenCount} children',
        key: const Key('children_info'),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
          fontSize: 11,
          height: 1.3,
        ),
      );
    }

    // Build a rich text with different colors for family vs non-family children
    final textSpans = <TextSpan>[];
    for (var i = 0; i < vehicle.children.length; i++) {
      final child = vehicle.children[i];
      final childName =
          child.childFamilyName != null && child.childFamilyName!.isNotEmpty
          ? '${child.childName} (${child.childFamilyName})'
          : child.childName;

      final isFamilyChild = child.isFamilyChild;

      // Add bullet point prefix for each child
      if (i == 0) {
        textSpans.add(
          TextSpan(
            text: '• ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 11,
              height: 1.3,
            ),
          ),
        );
      }

      textSpans.add(
        TextSpan(
          text: childName,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isFamilyChild
                ? Theme.of(context).colorScheme.tertiary
                : Theme.of(context).colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
            fontSize: 11,
            height: 1.3,
            fontWeight: isFamilyChild ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      );

      if (i < vehicle.children.length - 1) {
        textSpans.add(
          TextSpan(
            text: '\n• ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 11,
              height: 1.3,
            ),
          ),
        );
      }
    }

    return RichText(
      key: const Key('children_info'),
      text: TextSpan(children: textSpans),
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
      case CapacityStatus.limited:
        statusColor = Theme.of(context).colorScheme.secondary;
        statusIcon = Icons.warning;
        break;
      case CapacityStatus.full:
        statusColor = Theme.of(context).colorScheme.error;
        statusIcon = Icons.error;
        break;
      case CapacityStatus.overcapacity:
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
      case CapacityStatus.limited:
        return Theme.of(context).colorScheme.secondary;
      case CapacityStatus.full:
        return Theme.of(context).colorScheme.error;
      case CapacityStatus.overcapacity:
        return Theme.of(context).colorScheme.error;
    }
  }
}
