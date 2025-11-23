import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulift/core/domain/entities/family/vehicle.dart';
import 'package:edulift/core/domain/entities/schedule/schedule_slot.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import 'package:edulift/core/domain/extensions/time_of_day_timezone_extension.dart';
import '../../../../core/services/providers/auth_provider.dart';
import '../../../../core/utils/weekday_localization.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/presentation/themes/app_colors.dart';
import '../../../../core/presentation/themes/app_text_styles.dart';
import '../design/schedule_design.dart';
import 'child_assignment_sheet.dart';
import '../../../family/presentation/providers/family_provider.dart';

/// Simple Vehicle Selection Sheet
///
/// Follows the same UX pattern as ChildAssignmentSheet:
/// - 90% DraggableScrollableSheet
/// - Simple list of available vehicles as cards
/// - Immediate selection (tap vehicle = assign + close)
/// - No Save button needed (iOS-style immediate action)
class VehicleSelectionSheet extends ConsumerStatefulWidget {
  final String groupId;
  final ScheduleSlot scheduleSlot;
  final List<Vehicle> availableVehicles;

  const VehicleSelectionSheet({
    super.key,
    required this.groupId,
    required this.scheduleSlot,
    required this.availableVehicles,
  });

  @override
  ConsumerState<VehicleSelectionSheet> createState() =>
      _VehicleSelectionSheetState();
}

class _VehicleSelectionSheetState extends ConsumerState<VehicleSelectionSheet> {
  final bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(
                  vertical: ScheduleDimensions.spacingMd,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              _buildHeader(context),

              // Scrollable vehicle list
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(
                          ScheduleDimensions.spacingLg,
                        ),
                        children: [
                          if (widget.availableVehicles.isEmpty)
                            _buildEmptyState(context)
                          else ...[
                            const SizedBox(
                              height: ScheduleDimensions.spacingMd,
                            ),
                            ...widget.availableVehicles.map(
                              (vehicle) => _buildVehicleCard(vehicle),
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Get current user timezone
    final currentUser = ref.watch(currentUserProvider);
    final userTimezone = currentUser?.timezone;

    // Get schedule slot info
    final dayOfWeek = widget.scheduleSlot.dayOfWeek;
    final timeOfDay = widget.scheduleSlot.timeOfDay;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ScheduleDimensions.spacingLg,
        vertical: ScheduleDimensions.spacingMd,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderThemed(context)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(ScheduleDimensions.spacingSm),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.directions_car,
              color: Theme.of(context).primaryColor,
              size: ScheduleDimensions.iconSizeSmall,
            ),
          ),
          const SizedBox(width: ScheduleDimensions.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).assignVehicleToSlot,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${getLocalizedDayName(dayOfWeek.fullName, l10n)} - ${timeOfDay.toLocalTimeString(userTimezone)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryThemed(context),
                  ),
                ),
              ],
            ),
          ),
          // Close button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            tooltip: AppLocalizations.of(context).close,
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    return Card(
      margin: const EdgeInsets.only(bottom: ScheduleDimensions.spacingSm),
      elevation: 1,
      shape: const RoundedRectangleBorder(
        borderRadius: ScheduleDimensions.cardRadius,
      ),
      child: InkWell(
        onTap: _isLoading ? null : () => _selectVehicleWithChildren(vehicle),
        borderRadius: ScheduleDimensions.cardRadius,
        child: Padding(
          padding: const EdgeInsets.all(ScheduleDimensions.spacingMd),
          child: Row(
            children: [
              // Vehicle avatar
              CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withValues(alpha: 0.1),
                child: Icon(
                  Icons.directions_car,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: ScheduleDimensions.spacingMd),

              // Vehicle info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 16,
                          color: AppColors.textSecondaryThemed(context),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppLocalizations.of(
                            context,
                          ).seatsCount(vehicle.capacity),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondaryThemed(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Chevron indicator
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondaryThemed(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 64,
              color: AppColors.textSecondaryThemed(context),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).noVehiclesAvailable,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondaryThemed(context),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).addVehiclesToFamily,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondaryThemed(context),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Select vehicle and open ChildAssignmentSheet with vehicle (NEW FLOW)
  Future<void> _selectVehicleWithChildren(Vehicle vehicle) async {
    try {
      // Get family children for assignment
      final familyState = ref.watch(familyProvider);
      final allChildren = familyState.children;

      if (allChildren.isEmpty) {
        if (mounted) {
          _handleSuccessState(
            AppLocalizations.of(context).vehicleAddedSuccess(vehicle.name),
            widget.scheduleSlot.week,
          );
        }
        return;
      }

      // Get child IDs already assigned to OTHER vehicles in this same slot
      // (filter out children assigned to existing vehicles when adding a new vehicle to the slot)
      final childIdsAssignedToOtherVehicles = widget
          .scheduleSlot
          .vehicleAssignments
          .expand((va) => va.childAssignments)
          .map((assignment) => assignment.childId)
          .toSet();

      // Filter out children already assigned to other vehicles in this slot
      final availableChildren = allChildren
          .where((child) => !childIdsAssignedToOtherVehicles.contains(child.id))
          .toList();

      // Open ChildAssignmentSheet with vehicleToCreate parameter
      if (mounted) {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => ChildAssignmentSheet(
            groupId: widget.groupId,
            week: widget.scheduleSlot.week,
            slotId: 'temp-slot', // Temporary slot ID for creation
            vehicleToCreate: vehicle, // Vehicle to create slot with
            availableChildren: availableChildren,
            currentlyAssignedChildIds: const [],
            day: widget.scheduleSlot.dayOfWeek.name,
            time: widget.scheduleSlot.timeOfDay.toApiFormat(),
            shouldCloseParentOnSuccess: true, // Close vehicle sheet on success
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _handleErrorState(
          AppLocalizations.of(context).vehicleFailedToAdd(e.toString()),
        );
      }
    }
  }

  /// Create slot with vehicle assignment (iOS-style)

  void _handleSuccessState(String vehicleName, String week) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).vehicleAddedSuccess(vehicleName),
        ),
        backgroundColor: AppColors.successThemed(context),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    // Close sheet immediately after success (iOS-style)
    Navigator.of(context).pop();
  }

  void _handleErrorState(String error) {
    if (!mounted) return;

    AppLogger.error('VehicleSelectionSheet: Error state triggered', {
      'error': error,
      'groupId': widget.groupId,
      'week': widget.scheduleSlot.week,
    });

    // Map technical errors to user-friendly messages
    String userFriendlyMessage;
    try {
      if (error.contains('Schedule slot ID is missing') ||
          error.contains('temp-slot')) {
        userFriendlyMessage = AppLocalizations.of(context).scheduleSlotError;
      } else if (error.contains('Network') || error.contains('Connection')) {
        userFriendlyMessage = AppLocalizations.of(context).networkError;
      } else if (error.contains('permission') ||
          error.contains('Unauthorized')) {
        userFriendlyMessage = AppLocalizations.of(context).permissionError;
      } else if (error.contains('Vehicle') &&
          (error.contains('not found') || error.contains('exists'))) {
        userFriendlyMessage = AppLocalizations.of(context).vehicleNotFoundError;
      } else {
        userFriendlyMessage = AppLocalizations.of(
          context,
        ).vehicleFailedToAdd('');
      }
    } catch (e) {
      // Fallback in case localization keys are missing
      userFriendlyMessage = AppLocalizations.of(context).vehicleFailedToAdd('');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(userFriendlyMessage),
        backgroundColor: AppColors.errorThemed(context),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
