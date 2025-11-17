import 'package:flutter/material.dart';
import 'package:edulift/core/presentation/widgets/vehicle_capacity_badge.dart';
import 'package:edulift/core/presentation/widgets/family_colored_text.dart';
import 'package:edulift/core/domain/entities/schedule/vehicle_assignment.dart';

/// Shared vehicle card component for visual consistency across dashboard and schedule
///
/// This component displays:
/// - Optional group name badge (shown in dashboard, hidden in schedule)
/// - Vehicle icon + name
/// - Children using FamilyChildrenChips (chips with family star badges)
/// - Capacity using ONLY VehicleCapacityBadge (no progress bar for space efficiency)
///
/// Material 3 Design Features:
/// - Tertiary color scheme for family children
/// - Primary/Secondary/Error for capacity status
/// - Surface containers for structure
/// - WCAG AA compliant touch targets (48dp minimum)
///
/// Usage:
/// ```dart
/// // Dashboard usage (with group name)
/// VehicleCard(
///   vehicleName: 'Toyota Camry',
///   groupName: 'École Primaire Nord',  // Shown prominently
///   childrenNames: ['Alice', 'Bob'],
///   isFamilyFlags: [true, false],
///   assignedCount: 2,
///   capacity: 4,
///   onTap: () => handleTap(),
/// )
///
/// // Schedule usage (no group name)
/// VehicleCard(
///   vehicleName: 'Toyota Camry',
///   groupName: null,  // Not shown
///   childrenNames: ['Alice', 'Bob'],
///   isFamilyFlags: [true, false],
///   assignedCount: 2,
///   capacity: 4,
///   compact: true,
/// )
/// ```
class VehicleCard extends StatelessWidget {
  /// Vehicle name to display
  final String vehicleName;

  /// Optional group name - shown in dashboard, null in schedule
  final String? groupName;

  /// List of children names
  final List<String> childrenNames;

  /// List of family flags (same length as childrenNames)
  final List<bool> isFamilyFlags;

  /// Number of assigned children
  final int assignedCount;

  /// Total vehicle capacity
  final int capacity;

  /// Optional explicit capacity status (calculated if null)
  final CapacityStatus? capacityStatus;

  /// Compact mode for mobile display
  final bool compact;

  /// Optional tap callback
  final VoidCallback? onTap;

  /// Optional vehicle icon color (defaults to primary)
  final Color? iconColor;

  /// Optional background highlight for family vehicles
  final bool isFamilyVehicle;

  /// Whether the card should appear disabled/grayed out
  final bool isDisabled;

  const VehicleCard({
    Key? key,
    required this.vehicleName,
    this.groupName,
    required this.childrenNames,
    required this.isFamilyFlags,
    required this.assignedCount,
    required this.capacity,
    this.capacityStatus,
    this.compact = false,
    this.onTap,
    this.iconColor,
    this.isFamilyVehicle = false,
    this.isDisabled = false,
  }) : assert(
         childrenNames.length == isFamilyFlags.length,
         'childrenNames and isFamilyFlags must have same length',
       ),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor =
        iconColor ??
        (isFamilyVehicle
            ? Theme.of(context).colorScheme.tertiary
            : Theme.of(context).colorScheme.primary);

    // Container with optional family vehicle highlighting and improved contrast
    final containerDecoration = isFamilyVehicle
        ? BoxDecoration(
            color: isDisabled
                ? Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2)
                : Theme.of(
                    context,
                  ).colorScheme.tertiaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(compact ? 6 : 8),
            border: Border.all(
              color: isDisabled
                  ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)
                  : Theme.of(
                      context,
                    ).colorScheme.tertiary.withValues(alpha: 0.3),
            ),
          )
        : BoxDecoration(
            color: isDisabled
                ? Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2)
                : Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(compact ? 6 : 8),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
            ),
          );

    final content = Container(
      key: const Key('vehicle_card_container'),
      padding: EdgeInsets.all(compact ? 8.0 : 12.0),
      decoration: containerDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Optional group name badge
          if (groupName != null) ...[
            _buildGroupNameBadge(context),
            SizedBox(height: compact ? 6 : 8),
          ],
          // Vehicle header: icon + name + capacity badge
          _buildVehicleHeader(context, effectiveIconColor),
          // Children chips
          if (childrenNames.isNotEmpty) ...[
            SizedBox(height: compact ? 6 : 10),
            _buildChildrenSection(context),
          ],
        ],
      ),
    );

    // Apply opacity for disabled state
    final wrappedContent = Opacity(
      opacity: isDisabled ? 0.6 : 1.0,
      child: content,
    );

    // Wrap with InkWell if onTap is provided and not disabled
    if (onTap != null && !isDisabled) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(compact ? 6 : 8),
        child: wrappedContent,
      );
    }

    return wrappedContent;
  }

  /// Build optional group name badge
  Widget _buildGroupNameBadge(BuildContext context) {
    return Container(
      key: const Key('group_name_badge'),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(compact ? 4 : 6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.school,
            size: compact ? 12 : 14,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          SizedBox(width: compact ? 3 : 4),
          Flexible(
            child: Text(
              groupName!,
              key: const Key('group_name_text'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w600,
                fontSize: compact ? 10 : 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Build vehicle header: icon + name + capacity badge
  Widget _buildVehicleHeader(BuildContext context, Color effectiveIconColor) {
    return Row(
      children: [
        // Vehicle icon
        Icon(
          Icons.directions_car,
          size: compact ? 14 : 16,
          color: effectiveIconColor,
        ),
        SizedBox(width: compact ? 4 : 6),
        // Vehicle name
        Expanded(
          child: Text(
            vehicleName,
            key: const Key('vehicle_name'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isFamilyVehicle
                  ? Theme.of(context).colorScheme.onTertiaryContainer
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: compact ? 11 : 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: compact ? 4 : 6),
        // Capacity badge (replaces progress bar for space efficiency)
        VehicleCapacityBadge(
          assigned: assignedCount,
          capacity: capacity,
          capacityStatus: capacityStatus,
          compact: compact,
        ),
      ],
    );
  }

  /// Build children section using FamilyChildrenChips
  Widget _buildChildrenSection(BuildContext context) {
    return FamilyChildrenChips(
      key: const Key('children_chips'),
      childrenNames: childrenNames,
      isFamilyFlags: isFamilyFlags,
      compact: compact,
    );
  }
}
