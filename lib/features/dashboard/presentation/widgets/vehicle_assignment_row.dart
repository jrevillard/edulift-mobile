import 'package:flutter/material.dart';

import 'package:edulift/generated/l10n/app_localizations.dart';
import 'package:edulift/features/dashboard/domain/entities/dashboard_transport_summary.dart';
import 'package:edulift/core/domain/entities/schedule/vehicle_assignment.dart';

/// Vehicle Assignment Row Widget for dashboard display
///
/// Displays vehicle assignment information in a compact, accessible row format.
/// Shows vehicle name, capacity status, assigned children count, and utilization
/// with Material 3 design and proper accessibility support.
///
/// Features:
/// - Vehicle icon with capacity status color coding
/// - Vehicle name and capacity information
/// - Assigned children count with proper pluralization
/// - Capacity utilization progress indicator
/// - Touch targets meeting WCAG AA standards (≥48dp)
/// - Material 3 color scheme for capacity status
/// - Semantic labels for screen readers
class VehicleAssignmentRow extends StatelessWidget {
  const VehicleAssignmentRow({
    super.key,
    required this.vehicleAssignment,
    required this.capacityStatus,
  });

  /// Vehicle assignment summary data for display
  final VehicleAssignmentSummary vehicleAssignment;

  /// Capacity status for color coding and icon selection
  final CapacityStatus capacityStatus;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Semantics(
      label:
          'Vehicle: ${vehicleAssignment.vehicleName}, ${vehicleAssignment.assignedChildrenCount} of ${vehicleAssignment.vehicleCapacity} seats assigned, status: ${capacityStatus.name}',
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 48, // WCAG AA minimum touch target
        ),
        child: InkWell(
          onTap: () {
            // Handle row tap - navigate to vehicle details or edit assignment
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                _buildVehicleIcon(context),
                const SizedBox(width: 12),
                Expanded(child: _buildVehicleInfo(context, l10n)),
                const SizedBox(width: 12),
                _buildCapacityStatus(context, l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the vehicle icon with capacity status color
  Widget _buildVehicleIcon(BuildContext context) {
    return Semantics(
      label: 'Vehicle status: ${capacityStatus.name}',
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _getCapacityStatusColor(context).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          Icons.directions_car,
          size: 20,
          color: _getCapacityStatusColor(context),
        ),
      ),
    );
  }

  /// Builds the vehicle information section (name + capacity)
  Widget _buildVehicleInfo(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          vehicleAssignment.vehicleName,
          key: const Key('vehicle_name'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          l10n.seatsCount(vehicleAssignment.vehicleCapacity),
          key: const Key('vehicle_capacity'),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Builds the capacity status section with progress indicator
  Widget _buildCapacityStatus(BuildContext context, AppLocalizations l10n) {
    final utilizationPercentage = vehicleAssignment.utilizationPercentage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getCapacityStatusIcon(),
              size: 16,
              color: _getCapacityStatusColor(context),
            ),
            const SizedBox(width: 4),
            Text(
              '${vehicleAssignment.assignedChildrenCount}/${vehicleAssignment.vehicleCapacity}',
              key: const Key('capacity_ratio'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: _getCapacityStatusColor(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 60,
          height: 4,
          child: LinearProgressIndicator(
            value: utilizationPercentage / 100,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getCapacityStatusColor(context),
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  /// Returns the appropriate color for capacity status based on Material 3
  Color _getCapacityStatusColor(BuildContext context) {
    switch (capacityStatus) {
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

  /// Returns the appropriate icon for capacity status
  IconData _getCapacityStatusIcon() {
    switch (capacityStatus) {
      case CapacityStatus.available:
        return Icons.check_circle;
      case CapacityStatus.limited:
        return Icons.warning;
      case CapacityStatus.full:
        return Icons.error;
      case CapacityStatus.overcapacity:
        return Icons.error;
    }
  }
}
