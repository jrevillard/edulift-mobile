import 'package:flutter/material.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import '../design/schedule_design.dart';
import '../../../../core/presentation/themes/app_text_styles.dart';
import '../../../../core/presentation/themes/app_colors.dart';
import '../../../../core/domain/entities/schedule/vehicle_assignment.dart'
    as core_va;
import 'package:edulift/core/domain/entities/schedule.dart';

/// Simple, mobile-friendly schedule slot widget
/// Shows vehicles and children in an easy-to-understand format
class ScheduleSlotWidget extends StatelessWidget {
  final String groupId;
  final String day;
  final String time;
  final String week;
  final PeriodSlotData? scheduleSlot;
  final VoidCallback onTap;
  final Function(String) onVehicleDrop;

  const ScheduleSlotWidget({
    super.key,
    required this.groupId,
    required this.day,
    required this.time,
    required this.week,
    required this.scheduleSlot,
    required this.onTap,
    required this.onVehicleDrop,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onAcceptWithDetails: (details) => onVehicleDrop(details.data),
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: ScheduleAnimations.getDuration(
            context,
            ScheduleAnimations.fast,
          ),
          curve: ScheduleAnimations.getCurve(context, ScheduleAnimations.entry),
          constraints: BoxConstraints(
            minHeight: ScheduleDimensions.minimumTouchConstraints.minHeight,
            minWidth: ScheduleDimensions.minimumTouchConstraints.minWidth,
          ),
          decoration: BoxDecoration(
            borderRadius: ScheduleDimensions.cardRadius,
            border: Border.all(
              color: isHighlighted
                  ? Theme.of(context).primaryColor
                  : AppColors.borderThemed(context),
              width: isHighlighted ? 2 : 1,
            ),
            color: isHighlighted
                ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                : _getSlotBackgroundColor(context),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: ScheduleDimensions.cardRadius,
              child: Semantics(
                label: _buildSemanticLabel(context),
                button: true,
                enabled: true,
                child: Padding(
                  padding: const EdgeInsets.all(ScheduleDimensions.spacingMd),
                  child: _buildSlotContent(context),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSlotContent(BuildContext context) {
    if (scheduleSlot == null) {
      return _buildEmptySlot(context);
    } else {
      return _buildFilledSlot(context);
    }
  }

  Widget _buildEmptySlot(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_circle_outline,
          color: AppColors.textSecondaryThemed(context),
          size: ScheduleDimensions.iconSize,
        ),
        const SizedBox(height: ScheduleDimensions.spacingXs),
        Text(
          AppLocalizations.of(context).addVehicleToSlot,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondaryThemed(context),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFilledSlot(BuildContext context) {
    // Get all vehicle assignments from period slots
    final vehicles = _getVehicleAssignments();
    final vehicleCount = vehicles.length;

    if (vehicleCount == 0) {
      return _buildEmptySlot(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Vehicle count header - shows aggregated count for period slots
        Row(
          children: [
            Icon(
              Icons.directions_car,
              size: ScheduleDimensions.iconSizeSmall,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: ScheduleDimensions.spacingXs),
            Expanded(
              child: Text(
                AppLocalizations.of(context).vehicleCount(vehicleCount),
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Offline indicator
            if (_hasOfflineChanges()) ...[
              const SizedBox(width: 4),
              const Tooltip(
                message: 'Offline changes pending',
                child: Icon(
                  Icons.cloud_off,
                  size: 12,
                  color: AppColors.warning,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: ScheduleDimensions.spacingXs),

        // Vehicle list (only shown if we have actual vehicle data)
        if (vehicles.isNotEmpty)
          vehicles.length == 1
              ? _buildSingleVehicle(context, vehicles.first)
              : _buildMultipleVehicles(context, vehicles)
        else
          // For aggregated period slots, show a simple indicator
          Text(
            AppLocalizations.of(context).viewDetails,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondaryThemed(context),
              fontStyle: FontStyle.italic,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Widget _buildSingleVehicle(
    BuildContext context,
    core_va.VehicleAssignment vehicle,
  ) {
    final vehicleName = vehicle.vehicleName;
    final childCount = vehicle.childAssignments.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          vehicleName,
          style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: ScheduleDimensions.spacingXs / 2),
        if (childCount > 0) ...[
          Row(
            children: [
              const Icon(
                Icons.child_care,
                size: ScheduleDimensions.iconSizeSmall,
                color: AppColors.success,
              ),
              const SizedBox(width: ScheduleDimensions.spacingXs / 2),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).childrenCount(childCount),
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ] else ...[
          Text(
            AppLocalizations.of(context).noChildren,
            style: AppTextStyles.overline.copyWith(
              color: AppColors.textSecondaryThemed(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildMultipleVehicles(
    BuildContext context,
    List<core_va.VehicleAssignment> vehicles,
  ) {
    final totalChildren = vehicles.fold<int>(
      0,
      (sum, vehicle) => sum + vehicle.childAssignments.length,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppLocalizations.of(context).vehiclesPlural(vehicles.length),
          style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: ScheduleDimensions.spacingXs / 2),
        if (totalChildren > 0) ...[
          Row(
            children: [
              const Icon(
                Icons.child_care,
                size: ScheduleDimensions.iconSizeSmall,
                color: AppColors.success,
              ),
              const SizedBox(width: ScheduleDimensions.spacingXs / 2),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).childrenCount(totalChildren),
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ] else ...[
          Text(
            AppLocalizations.of(context).noChildrenAssigned,
            style: AppTextStyles.overline.copyWith(
              color: AppColors.textSecondaryThemed(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: ScheduleDimensions.spacingXs),
        // Show first few vehicle names with proper overflow handling
        // Use a simple Column with ellipsis to avoid unbounded constraints
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ...vehicles.take(2).map(
                  (vehicle) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: ScheduleDimensions.spacingXs / 4,
                    ),
                    child: Text(
                      vehicle.vehicleName,
                      style: AppTextStyles.overline.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            if (vehicles.length > 2)
              Text(
                AppLocalizations.of(context).moreItems(vehicles.length - 2),
                style: AppTextStyles.overline.copyWith(
                  color: AppColors.textSecondaryThemed(context),
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ],
    );
  }

  /// Get semantic background color based on slot state
  Color _getSlotBackgroundColor(BuildContext context) {
    if (scheduleSlot == null) {
      return AppColors.statusEmpty(context);
    }

    final vehicles = _getVehicleAssignments();
    if (vehicles.isEmpty) {
      return AppColors.statusEmpty(context);
    }

    // Check if there are any conflicts or issues
    final hasIssues = _hasScheduleIssues();
    if (hasIssues) {
      return AppColors.statusPartial(context);
    }

    return AppColors.statusAvailable(context);
  }

  List<core_va.VehicleAssignment> _getVehicleAssignments() {
    if (scheduleSlot == null) return [];

    // Get all vehicle assignments from all slots in the period
    return scheduleSlot!.slots
        .expand((slot) => slot.vehicleAssignments)
        .toList();
  }

  bool _hasScheduleIssues() {
    final vehicles = _getVehicleAssignments();

    for (final vehicle in vehicles) {
      // Check for conflicts, over-capacity, etc.
      if (vehicle.childAssignments.length > vehicle.effectiveCapacity) {
        return true;
      }
    }

    return false;
  }

  String _buildSemanticLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (scheduleSlot == null) {
      return 'Empty slot, $day $time, tap to add vehicle';
    }

    final vehicleCount = _getVehicleAssignments().length;

    if (vehicleCount == 0) {
      return 'Empty slot, $day $time, tap to add vehicle';
    }

    return '$day $time, ${l10n.vehicleCount(vehicleCount)}, tap to manage';
  }

  bool _hasOfflineChanges() {
    // PeriodSlotData doesn't have offline changes tracking at the aggregate level
    // Check if any of the individual slots have offline changes
    if (scheduleSlot == null) return false;

    // Note: ScheduleSlot entities don't currently have hasOfflineChanges property
    // This would need to be added if offline support is implemented
    return false;
  }
}
