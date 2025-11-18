import 'package:flutter/material.dart';

import 'package:edulift/generated/l10n/app_localizations.dart';
import 'package:edulift/features/dashboard/domain/entities/dashboard_transport_summary.dart';
import 'package:edulift/core/domain/entities/schedule/vehicle_assignment.dart';
import 'package:edulift/core/presentation/utils/responsive_breakpoints.dart';

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

    // Responsive layout parameters using established Phase 2 patterns
    // Mobile: larger touch targets, more spacing, more padding
    // Tablet: balanced design for space efficiency
    // Desktop: optimal layout for larger screens with precise spacing
    final minTouchTarget = context.getAdaptiveButtonHeight(
      mobile: 48,
      tablet: 44,
      desktop: 40,
    );
    final horizontalSpacing = context.getAdaptiveSpacing(
      mobile: 12,
      tablet: 10,
      desktop: 12,
    );
    final rowPadding = context.getAdaptivePadding(
      mobileHorizontal: 8,
      mobileVertical: 6,
      tabletHorizontal: 6,
      tabletVertical: 4,
      desktopHorizontal: 8,
      desktopVertical: 5,
    );
    final borderRadius = context.getAdaptiveBorderRadius(
      mobile: 8,
      tablet: 6,
      desktop: 8,
    );

    return Semantics(
      label:
          'Vehicle: ${vehicleAssignment.vehicleName}, ${vehicleAssignment.assignedChildrenCount} of ${vehicleAssignment.vehicleCapacity} seats assigned, status: ${capacityStatus.name}',
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: minTouchTarget, // Responsive WCAG AA minimum touch target
        ),
        child: InkWell(
          onTap: () {
            // Handle row tap - navigate to vehicle details or edit assignment
          },
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: rowPadding,
            child: Row(
              children: [
                _buildVehicleIcon(context),
                SizedBox(width: horizontalSpacing),
                Expanded(child: _buildVehicleInfo(context, l10n)),
                SizedBox(width: horizontalSpacing),
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
    // Responsive icon container parameters
    final iconContainerPadding = context.getAdaptivePadding(
      mobileAll: 6,
      tabletAll: 5,
      desktopAll: 6,
    );
    final iconContainerRadius = context.getAdaptiveBorderRadius(
      mobile: 6,
      tablet: 4,
      desktop: 6,
    );
    final vehicleIconSize = context.getAdaptiveIconSize(
      mobile: 20,
      tablet: 18,
      desktop: 20,
    );

    return Semantics(
      label: 'Vehicle status: ${capacityStatus.name}',
      child: Container(
        padding: iconContainerPadding,
        decoration: BoxDecoration(
          color: _getCapacityStatusColor(context).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(iconContainerRadius),
        ),
        child: Icon(
          Icons.directions_car,
          size: vehicleIconSize,
          color: _getCapacityStatusColor(context),
        ),
      ),
    );
  }

  /// Builds the vehicle information section (name + capacity + children)
  Widget _buildVehicleInfo(BuildContext context, AppLocalizations l10n) {
    // Format children names with family names in parentheses
    final childrenText = _formatChildrenNames();

    // Responsive vertical spacing for vehicle information
    final infoSpacing = context.getAdaptiveSpacing(
      mobile: 2,
      tablet: 1.5,
      desktop: 2,
    );

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
        SizedBox(height: infoSpacing),
        Text(
          l10n.seatsCount(vehicleAssignment.vehicleCapacity),
          key: const Key('vehicle_capacity'),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (childrenText.isNotEmpty) ...[
          SizedBox(height: infoSpacing),
          Text(
            childrenText,
            key: const Key('children_names'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
            // No maxLines limit - show all children
            overflow: TextOverflow.visible,
            softWrap: true,
          ),
        ],
      ],
    );
  }

  /// Formats children names with family names in parentheses
  /// Example: "Emmie (Smith), John (Doe), Sarah (Brown)"
  /// Shows ALL children with their family names
  String _formatChildrenNames() {
    if (vehicleAssignment.children.isEmpty) {
      return '';
    }

    return vehicleAssignment.children
        .map((child) {
          final familyName = child.childFamilyName;
          if (familyName != null && familyName.isNotEmpty) {
            return '${child.childName} ($familyName)';
          }
          return child.childName;
        })
        .join(', ');
  }

  /// Builds the capacity status section with progress indicator
  Widget _buildCapacityStatus(BuildContext context, AppLocalizations l10n) {
    final utilizationPercentage = vehicleAssignment.utilizationPercentage;

    // Responsive capacity status parameters
    final statusIconSize = context.getAdaptiveIconSize(
      mobile: 16,
      tablet: 14,
      desktop: 16,
    );
    final statusIconSpacing = context.getAdaptiveSpacing(
      mobile: 4,
      tablet: 3,
      desktop: 4,
    );
    final progressBarSpacing = context.getAdaptiveSpacing(
      mobile: 4,
      tablet: 3,
      desktop: 4,
    );
    final progressBarWidth = context.getAdaptiveSpacing(
      mobile: 60,
      tablet: 50,
      desktop: 60,
    );
    final progressBarHeight = context.getAdaptiveSpacing(
      mobile: 4,
      tablet: 3,
      desktop: 4,
    );
    final progressBarRadius = context.getAdaptiveBorderRadius(
      mobile: 2,
      tablet: 1.5,
      desktop: 2,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getCapacityStatusIcon(),
              size: statusIconSize,
              color: _getCapacityStatusColor(context),
            ),
            SizedBox(width: statusIconSpacing),
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
        SizedBox(height: progressBarSpacing),
        SizedBox(
          width: progressBarWidth,
          height: progressBarHeight,
          child: LinearProgressIndicator(
            value: utilizationPercentage / 100,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getCapacityStatusColor(context),
            ),
            borderRadius: BorderRadius.circular(progressBarRadius),
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
