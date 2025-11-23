import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import 'package:edulift/core/domain/entities/schedule.dart';
import 'package:edulift/core/domain/entities/family/child.dart';
import 'package:edulift/core/domain/entities/family/vehicle.dart';
import 'package:edulift/core/domain/entities/family/family.dart'
    as family_entity;
import 'package:edulift/core/domain/extensions/time_of_day_timezone_extension.dart';
import 'package:edulift/core/presentation/widgets/vehicle_card.dart';
import 'package:edulift/core/presentation/themes/app_colors.dart';
import 'package:edulift/core/services/providers/auth_provider.dart';
import 'package:edulift/features/family/presentation/providers/family_provider.dart';
import 'package:edulift/core/utils/date/date_utils.dart' as app_date_utils;
import '../../models/displayable_time_slot.dart';

/// Enhanced time slot card - Multi-vehicle support with uncreated slot support
///
/// Level 1: Compact view in grid
/// Displays essential slot information:
/// - Header: time + status badge
/// - Multiple vehicles with action menus
/// - Add vehicle button when capacity available
/// - Create slot button for uncreated slots
///
/// Material 3 Features:
/// - Tertiary for family children
/// - Primary/Secondary/Error for capacity
/// - Surface containers for structure
/// - WCAG AA touch targets (48dp)
/// - PopupMenuButton for vehicle actions
///
/// Usage:
/// ```dart
/// EnhancedSlotCard(
///   displayableSlot: displayableSlot,
///   onAddVehicle: (slot) => handleAddVehicle(slot),
///   onVehicleAction: (vehicle, action) => handleAction(vehicle, action),
///   onVehicleTap: (vehicle) => handleVehicleTap(vehicle),
///   childrenMap: childrenIdToEntityMap,
/// )
/// ```
class EnhancedSlotCard extends ConsumerWidget {
  /// Displayable time slot data (handles both existing and uncreated slots)
  final DisplayableTimeSlot displayableSlot;

  /// Callback when add vehicle button is tapped (for both creating and adding)
  final Function(DisplayableTimeSlot)? onAddVehicle;

  /// Callback when vehicle action is selected (remove)
  final Function(VehicleAssignment vehicle, String action)? onVehicleAction;

  /// Callback when vehicle card is tapped (to assign children)
  final Function(VehicleAssignment vehicle)? onVehicleTap;

  /// Compact mode for reduced display
  final bool compact;

  /// Map of child IDs to Child entities for displaying names
  final Map<String, Child> childrenMap;

  /// Map of vehicle IDs to Vehicle entities for checking availability
  final Map<String, Vehicle?>? vehicles;

  /// Function to check if slot is in the past (for consistent UX and real-time updates)
  final bool Function(DisplayableTimeSlot)? isSlotInPast;

  const EnhancedSlotCard({
    Key? key,
    required this.displayableSlot,
    this.onAddVehicle,
    this.onVehicleAction,
    this.onVehicleTap,
    this.compact = false,
    required this.childrenMap,
    this.vehicles,
    this.isSlotInPast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    // Get current family for child star badge logic
    final currentFamily = ref.watch(
      familyProvider.select((state) => state.family),
    );

    // Slot doesn't exist in backend yet - show create/add vehicle card
    if (!displayableSlot.existsInBackend) {
      // Get user timezone for display
      final currentUser = ref.watch(currentUserProvider);
      final userTimezone = currentUser?.timezone;
      return _buildUncreatedSlotCard(context, l10n, userTimezone);
    }

    // Slot exists - show normal card with vehicles
    return _buildExistingSlotCard(context, ref, l10n, currentFamily);
  }

  /// Build card for uncreated slots (configured but not in backend)
  Widget _buildUncreatedSlotCard(
    BuildContext context,
    AppLocalizations l10n,
    String? userTimezone,
  ) {
    // Determine if slot is in past using centralized logic
    final isPast = isSlotInPast?.call(displayableSlot) ?? false;

    return Card(
      key: Key('enhanced_slot_card_uncreated_${displayableSlot.compositeKey}'),
      elevation: isPast ? 1 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(compact ? 8 : 12),
        side: isPast
            ? BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
              )
            : BorderSide.none,
      ),
      color: isPast
          ? Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
          : null,
      child: InkWell(
        key: const Key('add_vehicle_uncreated_slot'),
        onTap: isPast ? null : () => onAddVehicle?.call(displayableSlot),
        borderRadius: BorderRadius.circular(compact ? 8 : 12),
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 16),
          child: Opacity(
            opacity: isPast ? 0.6 : 1.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Time header
                _buildUncreatedSlotHeader(context, userTimezone ?? ''),
                const SizedBox(height: 12),

                // Add vehicle prompt
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          size: compact ? 24 : 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.addVehicle,
                          key: const Key('add_vehicle_text'),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build header for uncreated slot
  Widget _buildUncreatedSlotHeader(BuildContext context, String userTimezone) {
    // Display time in user's timezone using existing extension
    final timeStr = displayableSlot.timeOfDay.toLocalTimeString(
      userTimezone.isEmpty ? 'UTC' : userTimezone,
    );
    // Use the same logic as in _buildUncreatedSlotCard for consistency
    final isPast = isSlotInPast?.call(displayableSlot) ?? false;

    return Row(
      children: [
        // Time
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 6 : 8,
            vertical: compact ? 3 : 4,
          ),
          decoration: BoxDecoration(
            color: isPast
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(compact ? 4 : 6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeStr,
                key: const Key('slot_time'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isPast
                      ? Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7)
                      : Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                  fontSize: compact ? 10 : 11,
                ),
              ),
              if (isPast) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.lock_outline,
                  size: compact ? 10 : 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ],
            ],
          ),
        ),
        const Spacer(),
        // Empty status badge
        Container(
          key: const Key('status_badge'),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 4 : 6,
            vertical: compact ? 2 : 3,
          ),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(compact ? 3 : 4),
          ),
          child: Icon(
            Icons.circle_outlined,
            size: compact ? 12 : 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Build card for existing slots (with vehicle assignments)
  Widget _buildExistingSlotCard(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    family_entity.Family? currentFamily,
  ) {
    final scheduleSlot = displayableSlot.scheduleSlot;

    // If scheduleSlot is null despite existsInBackend being true,
    // treat as empty slot (no vehicles assigned yet)
    if (scheduleSlot == null) {
      return _buildEmptyState(context, l10n, false);
    }

    // Get user timezone for past slot detection
    final currentUser = ref.watch(currentUserProvider);
    final userTimezone = currentUser?.timezone;

    // Check if slot is in the past using centralized logic (for real-time updates)
    // If no function provided, fall back to local logic for backward compatibility
    final isPast =
        isSlotInPast?.call(displayableSlot) ??
        _isSlotInPast(_calculateSlotStartTime(), userTimezone);

    final hasVehicles = scheduleSlot.vehicleAssignments.isNotEmpty;
    final canAddMore =
        scheduleSlot.vehicleAssignments.length < scheduleSlot.maxVehicles;

    // Calculate available vehicles (not assigned to this slot)
    final hasAvailableVehicles =
        vehicles?.values.any(
          (vehicle) =>
              vehicle != null &&
              !scheduleSlot.vehicleAssignments.any(
                (assigned) => assigned.vehicleId == vehicle.id,
              ),
        ) ??
        false;

    return Card(
      key: Key('enhanced_slot_card_${scheduleSlot.id}'),
      elevation: isPast ? 1 : 3, // Augmenté pour meilleure séparation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(compact ? 8 : 12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerLow, // Couleur de base explicite
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 16),
        child: Opacity(
          opacity: isPast ? 0.6 : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(
                context,
                l10n,
                isPast,
                scheduleSlot,
                userTimezone ?? '',
              ),
              if (!compact) const SizedBox(height: 12),

              // Show all vehicles or empty state
              if (hasVehicles)
                ..._buildVehiclesList(
                  context,
                  l10n,
                  isPast,
                  scheduleSlot,
                  currentFamily,
                )
              else
                _buildEmptyState(context, l10n, isPast),

              // Add another vehicle button (if not past, capacity available, and vehicles available)
              if (!isPast &&
                  hasVehicles &&
                  canAddMore &&
                  hasAvailableVehicles) ...[
                const SizedBox(height: 12),
                _buildAddAnotherVehicleButton(context, l10n),
              ],

              // Max capacity reached or no vehicles available badge
              if (!isPast && hasVehicles && !canAddMore) ...[
                const SizedBox(height: 8),
                _buildMaxCapacityBadge(context, l10n),
              ],
              if (!isPast &&
                  hasVehicles &&
                  canAddMore &&
                  !hasAvailableVehicles) ...[
                const SizedBox(height: 8),
                _buildNoVehiclesAvailableBadge(context, l10n),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Header: time + status badge
  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    bool isPast,
    ScheduleSlot scheduleSlot,
    String? userTimezone,
  ) {
    // Display time in user's timezone using existing extension
    final timeStr = scheduleSlot.timeOfDay.toLocalTimeString(
      userTimezone?.isNotEmpty == true ? userTimezone : 'UTC',
    );
    final status = _getSlotStatus(scheduleSlot);

    return Row(
      children: [
        // Time
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 6 : 8,
            vertical: compact ? 3 : 4,
          ),
          decoration: BoxDecoration(
            color: isPast
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(compact ? 4 : 6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeStr,
                key: const Key('slot_time'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isPast
                      ? Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7)
                      : Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                  fontSize: compact ? 10 : 11,
                ),
              ),
              if (isPast) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.lock_outline,
                  size: compact ? 10 : 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ],
            ],
          ),
        ),
        const Spacer(),
        // Status badge
        _buildStatusBadge(context, status, isPast),
      ],
    );
  }

  /// Build list of vehicle cards with action menus
  List<Widget> _buildVehiclesList(
    BuildContext context,
    AppLocalizations l10n,
    bool isPast,
    ScheduleSlot scheduleSlot,
    family_entity.Family? currentFamily,
  ) {
    final vehicles = <Widget>[];

    for (var i = 0; i < scheduleSlot.vehicleAssignments.length; i++) {
      final vehicle = scheduleSlot.vehicleAssignments[i];

      if (i > 0) {
        vehicles.add(const SizedBox(height: 12));
      }

      vehicles.add(
        _buildVehicleCardWithMenu(
          context,
          l10n,
          vehicle,
          isPast,
          currentFamily,
        ),
      );
    }

    return vehicles;
  }

  /// Build single vehicle card with popup menu overlay
  Widget _buildVehicleCardWithMenu(
    BuildContext context,
    AppLocalizations l10n,
    VehicleAssignment vehicle,
    bool isPast,
    family_entity.Family? currentFamily,
  ) {
    // Extract child names and family flags from childrenMap
    final childrenNames = <String>[];
    final isFamilyFlags = <bool>[];

    for (final assignment in vehicle.childAssignments) {
      final child = childrenMap[assignment.childId];
      if (child != null) {
        childrenNames.add(child.name);
        // Only children from the current family get the star badge
        isFamilyFlags.add(child.familyId == currentFamily?.id);
      }
    }

    return Stack(
      children: [
        // Shared VehicleCard component (from dashboard)
        // Padding-right reserves space for remove button to prevent overlap with capacity badge
        // Wrapped in InkWell to make it tappable for child assignment
        Padding(
          padding: const EdgeInsets.only(right: 40),
          child: InkWell(
            key: Key('vehicle_card_tap_${vehicle.vehicleId}'),
            onTap: isPast ? null : () => onVehicleTap?.call(vehicle),
            borderRadius: BorderRadius.circular(12),
            child: VehicleCard(
              vehicleName: vehicle.vehicleName,
              childrenNames: childrenNames,
              isFamilyFlags: isFamilyFlags,
              assignedCount: vehicle.childAssignments.length,
              capacity: vehicle.effectiveCapacity,
              compact: compact,
              isDisabled: isPast,
            ),
          ),
        ),

        // Remove button overlay (bottom-right corner to avoid overlapping with capacity gauge)
        if (!isPast)
          Positioned(
            bottom: 4,
            right: 4,
            child: _buildRemoveVehicleButton(context, l10n, vehicle),
          ),
      ],
    );
  }

  /// Simple remove button for vehicle
  Widget _buildRemoveVehicleButton(
    BuildContext context,
    AppLocalizations l10n,
    VehicleAssignment vehicle,
  ) {
    return IconButton(
      key: Key('vehicle_remove_${vehicle.vehicleId}'),
      tooltip: l10n.removeVehicle,
      onPressed: () => onVehicleAction?.call(vehicle, 'remove'),
      icon: Icon(
        Icons.remove_circle,
        color: AppColors.errorThemed(context),
        size: 20,
      ),
      style: IconButton.styleFrom(
        padding: const EdgeInsets.all(4),
        minimumSize: const Size(32, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  /// Empty state: slot without assigned vehicles
  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations l10n,
    bool isPast,
  ) {
    if (isPast) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history,
                size: compact ? 20 : 24,
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 4),
              Text(
                'Time slot passed',
                key: const Key('past_slot_text'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  fontSize: compact ? 10 : 11,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      key: const Key('add_vehicle_empty_state'),
      onTap: () => onAddVehicle?.call(displayableSlot),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_circle_outline,
                size: compact ? 24 : 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.addVehicle,
                key: const Key('add_vehicle_text'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Button to add another vehicle when slot already has vehicles
  Widget _buildAddAnotherVehicleButton(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return SizedBox(
      key: const Key('add_another_vehicle_button'),
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => onAddVehicle?.call(displayableSlot),
        icon: const Icon(Icons.add),
        label: Text(l10n.addVehicle),
      ),
    );
  }

  /// Badge showing maximum capacity reached
  Widget _buildMaxCapacityBadge(BuildContext context, AppLocalizations l10n) {
    return Container(
      key: const Key('max_capacity_badge'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          const SizedBox(height: 4),
          Text(
            'Maximum vehicles reached',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Badge showing no vehicles available
  Widget _buildNoVehiclesAvailableBadge(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Container(
        key: const Key('no_vehicles_available_badge'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.tertiaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.tertiary.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.car_rental_outlined,
              size: 16,
              color: Theme.of(context).colorScheme.onTertiaryContainer,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.allVehiclesAssigned,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onTertiaryContainer,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Slot status badge (available, limited, full)
  Widget _buildStatusBadge(
    BuildContext context,
    SlotStatus status,
    bool isPast,
  ) {
    Color statusColor;
    IconData statusIcon;

    if (isPast) {
      statusColor = Theme.of(
        context,
      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5);
      statusIcon = Icons.lock;
    } else {
      switch (status) {
        case SlotStatus.available:
          statusColor = Theme.of(context).colorScheme.primary;
          statusIcon = Icons.check_circle;
          break;
        case SlotStatus.limited:
          statusColor = Theme.of(context).colorScheme.secondary;
          statusIcon = Icons.warning;
          break;
        case SlotStatus.full:
          statusColor = Theme.of(context).colorScheme.error;
          statusIcon = Icons.error;
          break;
        case SlotStatus.empty:
          statusColor = Theme.of(context).colorScheme.onSurfaceVariant;
          statusIcon = Icons.circle_outlined;
          break;
      }
    }

    return Container(
      key: const Key('status_badge'),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 4 : 6,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: isPast
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(compact ? 3 : 4),
      ),
      child: Icon(statusIcon, size: compact ? 12 : 14, color: statusColor),
    );
  }

  /// Calculate slot start time from dayOfWeek and timeOfDay
  DateTime _calculateSlotStartTime() {
    // Parse week string (e.g., "2025-W46")
    final now = DateTime.now();

    // For past detection, use current week as approximation
    // TODO: Proper week parsing if displayableSlot.week format is different
    final dayOffset = displayableSlot.dayOfWeek.weekday - now.weekday;
    final slotDate = now.add(Duration(days: dayOffset));

    return DateTime(
      slotDate.year,
      slotDate.month,
      slotDate.day,
      displayableSlot.timeOfDay.hour,
      displayableSlot.timeOfDay.minute,
    );
  }

  /// Check if a slot is in the past (more than 5 minutes ago)
  bool _isSlotInPast(DateTime slotStartTime, String? userTimezone) {
    if (userTimezone == null || userTimezone.isEmpty) {
      // Fallback: simple UTC comparison if no timezone available
      final now = DateTime.now();
      final comparisonTime = now.subtract(const Duration(minutes: 5));
      final slotUtc = slotStartTime.isUtc
          ? slotStartTime
          : slotStartTime.toUtc();
      final comparisonUtc = comparisonTime.isUtc
          ? comparisonTime
          : comparisonTime.toUtc();
      return slotUtc.isBefore(comparisonUtc);
    }

    // Use DateUtils utility with 5-minute buffer
    return app_date_utils.DateUtils.isPastInUserTimezone(
      slotStartTime,
      userTimezone,
      minutesBuffer: 5,
    );
  }

  /// Calculate slot status based on capacity across all vehicles
  SlotStatus _getSlotStatus(ScheduleSlot scheduleSlot) {
    if (scheduleSlot.vehicleAssignments.isEmpty) {
      return SlotStatus.empty;
    }

    var totalAssigned = 0;
    var totalCapacity = 0;

    for (final vehicle in scheduleSlot.vehicleAssignments) {
      totalAssigned += vehicle.childAssignments.length;
      totalCapacity += vehicle.effectiveCapacity;
    }

    if (totalAssigned == 0) {
      return SlotStatus.empty;
    } else if (totalAssigned >= totalCapacity) {
      return SlotStatus.full;
    } else if (totalAssigned >= (totalCapacity * 0.8)) {
      return SlotStatus.limited;
    } else {
      return SlotStatus.available;
    }
  }
}

/// Time slot status
enum SlotStatus { empty, available, limited, full }
