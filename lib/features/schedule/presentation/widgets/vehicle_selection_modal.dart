import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import '../../domain/usecases/assign_vehicle_to_slot.dart';
import '../../domain/usecases/remove_vehicle_from_slot.dart';
import '../../../family/providers.dart' as family;
import '../../../family/presentation/providers/family_provider.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import '../providers/schedule_providers.dart';
import '../../../../core/presentation/themes/app_text_styles.dart';
import '../../../../core/presentation/themes/app_colors.dart';
import 'child_assignment_sheet.dart';
import 'package:edulift/core/domain/entities/schedule.dart';
import '../../../../core/domain/entities/schedule/vehicle_assignment.dart'
    as core_va;
import 'package:edulift/core/domain/entities/family.dart' as features_vehicle;
import '../../../../core/presentation/extensions/time_of_day_timezone_extension.dart';
import '../../../../core/services/providers/auth_provider.dart';
import '../../../../core/utils/weekday_localization.dart';

/// Simple, mobile-friendly vehicle selection modal
/// Easy-to-use interface for managing vehicles in time slots
class VehicleSelectionModal extends ConsumerStatefulWidget {
  final String groupId;
  final PeriodSlotData scheduleSlot;

  const VehicleSelectionModal({
    super.key,
    required this.groupId,
    required this.scheduleSlot,
  });

  @override
  ConsumerState<VehicleSelectionModal> createState() =>
      _VehicleSelectionModalState();
}

class _VehicleSelectionModalState extends ConsumerState<VehicleSelectionModal> {
  bool _isLoading = false;

  // Store TextEditingControllers per vehicle to prevent rebuild from resetting values
  final Map<String, TextEditingController> _capacityControllers = {};

  // Maximum capacity limit for seat override UI controls
  static const int _maxCapacityLimit = 50;

  @override
  void initState() {
    super.initState();
    // Ensure family data (including vehicles) is loaded when modal opens
    // This is critical because AutoLoadFamilyNotifier has auto-loading disabled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(family.familyComposedProvider.notifier).loadFamily();
    });
  }

  @override
  void dispose() {
    // Clean up all controllers
    for (final controller in _capacityControllers.values) {
      controller.dispose();
    }
    _capacityControllers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final familyState = ref.watch(family.familyComposedProvider);
    final vehicles = familyState.family?.vehicles ?? [];

    // Watch weekly schedule provider for fresh data after updates
    final scheduleAsync = ref.watch(
      weeklyScheduleProvider(widget.groupId, widget.scheduleSlot.week),
    );

    // Build fresh PeriodSlotData from watched schedule
    final currentSlotData = scheduleAsync.when(
      data: (slots) {
        // Filter slots that match the current period (day + times)
        final matchingSlots = slots.where((slot) {
          return slot.dayOfWeek == widget.scheduleSlot.dayOfWeek &&
              widget.scheduleSlot.times.any((t) => t.isSameAs(slot.timeOfDay));
        }).toList();

        // Create fresh PeriodSlotData with updated slots
        return widget.scheduleSlot.copyWith(slots: matchingSlots);
      },
      loading: () => widget.scheduleSlot, // Use original data while loading
      error: (_, __) =>
          widget.scheduleSlot, // Fallback to original data on error
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      snap: true,
      snapSizes: const [0.4, 0.6, 0.95],
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
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.onSurfaceVariant(
                    context,
                  ).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: _buildHeader(context, currentSlotData),
              ),

              // Scrollable content
              Expanded(
                child: familyState.isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : familyState.error != null
                    ? _buildErrorState(context, familyState.error!)
                    : ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(20),
                        children: [
                          _buildContentChildren(
                            context,
                            vehicles,
                            currentSlotData,
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCapacityBar({
    required int usedSeats,
    required int effectiveCapacity,
    required int baseCapacity,
    required bool hasOverride,
    required CapacityStatus status,
  }) {
    final percentage = effectiveCapacity > 0
        ? usedSeats / effectiveCapacity
        : 0.0;

    // Use domain-provided status to determine color (no business logic here)
    Color barColor;
    switch (status) {
      case CapacityStatus.exceeded:
        barColor = AppColors.error;
      case CapacityStatus.full:
      case CapacityStatus.nearFull:
        barColor = AppColors.warning;
      case CapacityStatus.available:
        barColor = AppColors.success;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage.clamp(0.0, 1.0),
                  backgroundColor: AppColors.borderThemed(context),
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  minHeight: 8,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (hasOverride)
              Tooltip(
                message: AppLocalizations.of(context).seatOverrideActive,
                child: const Icon(
                  Icons.edit,
                  size: 16,
                  color: AppColors.warning,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '$usedSeats / $effectiveCapacity ${AppLocalizations.of(context).seats}',
                style: TextStyle(
                  fontSize: 12,
                  color: barColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (hasOverride)
              Flexible(
                child: Text(
                  AppLocalizations.of(
                    context,
                  ).overrideDetails(effectiveCapacity, baseCapacity),
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSeatOverrideSection({
    required String vehicleId,
    required String vehicleName,
    required int baseCapacity,
    required int? currentOverride,
  }) {
    final effectiveValue = currentOverride ?? baseCapacity;
    final hasOverride = currentOverride != null;

    // Get or create controller for this vehicle
    // Controller is user-controlled: only updated by direct user actions
    // (typing, +/- buttons, reset button), never by build() rebuilds
    final controller = _capacityControllers.putIfAbsent(
      vehicleId,
      () => TextEditingController(text: effectiveValue.toString()),
    );
    // No automatic sync with server state!
    // Server state is displayed separately via "Personalisé: X (Y de base)" text

    // Auto-save when editing finishes (on keyboard dismiss or focus loss)
    void saveValue() {
      final value = controller.text;
      final override = value.isEmpty || value == baseCapacity.toString()
          ? null
          : int.tryParse(value);
      _saveSeatOverride(vehicleId, override);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(context).adjustCapacityForTrip,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondaryThemed(context),
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Reset button (only show if override is active)
            if (hasOverride)
              TextButton.icon(
                onPressed: () {
                  controller.text = baseCapacity.toString();
                  _saveSeatOverride(vehicleId, null);
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: Text(
                  AppLocalizations.of(context).reset,
                  style: const TextStyle(fontSize: 12),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Decrease button
            IconButton(
              onPressed: effectiveValue > 0
                  ? () {
                      final newValue = effectiveValue - 1;
                      controller.text = newValue.toString();
                      final override = newValue == baseCapacity
                          ? null
                          : newValue;
                      _saveSeatOverride(vehicleId, override);
                    }
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
              color: Theme.of(context).primaryColor,
              tooltip: 'Decrease capacity',
            ),

            // TextField in the middle (read-only, only +/- buttons can modify)
            Expanded(
              child: TextField(
                controller: controller,
                readOnly:
                    true, // Disable manual editing - only +/- buttons update the value
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: baseCapacity.toString(),
                  suffixText: AppLocalizations.of(context).seats,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onSubmitted: (_) => saveValue(),
                onEditingComplete: saveValue,
              ),
            ),

            // Increase button
            IconButton(
              onPressed: effectiveValue < _maxCapacityLimit
                  ? () {
                      final newValue = effectiveValue + 1;
                      controller.text = newValue.toString();
                      final override = newValue == baseCapacity
                          ? null
                          : newValue;
                      _saveSeatOverride(vehicleId, override);
                    }
                  : null,
              icon: const Icon(Icons.add_circle_outline),
              color: Theme.of(context).primaryColor,
              tooltip: 'Increase capacity',
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _saveSeatOverride(String assignmentId, int? override) async {
    await HapticFeedback.mediumImpact();

    final week = widget.scheduleSlot.week;
    if (week.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).cannotDetermineWeek),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final result = await ref
        .read(assignmentStateNotifierProvider.notifier)
        .updateSeatOverride(
          groupId: widget.groupId,
          week: week,
          assignmentId: assignmentId,
          seatOverride: override,
        );

    result.when(
      ok: (_) {
        // Success feedback via haptics only - no SnackBar needed since UI updates immediately
        HapticFeedback.heavyImpact(); // Success feedback (fire and forget)
        // Note: Provider invalidation is handled by updateSeatOverride() method
        // The modal will automatically reflect the new capacity through ref.watch()
      },
      err: (failure) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              ).seatOverrideUpdateFailed(failure.message ?? 'Unknown error'),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, PeriodSlotData slotData) {
    // Use TYPE-SAFE domain entities
    final dayOfWeek = slotData.dayOfWeek;
    final period = slotData.period;

    // Get actual time slots to show (instead of period label)
    final timeSlots = slotData.times;

    // Get user timezone for display
    final currentUser = ref.watch(currentUserProvider);
    final userTimezone = currentUser?.timezone;

    // Get localized day name
    final l10n = AppLocalizations.of(context);
    final localizedDay = getLocalizedDayName(dayOfWeek.fullName, l10n);

    // Build time display using pattern matching on SchedulePeriod
    final String timeDisplay;
    if (timeSlots.isNotEmpty) {
      if (timeSlots.length == 1) {
        // Single time slot: show time with timezone in header (e.g., "08:30 (UTC+2)")
        timeDisplay = timeSlots.first.toLocalTimeStringWithTz(userTimezone);
      } else {
        // Multiple time slots: show range with timezone in header
        final firstTime = timeSlots.first.toLocalTimeStringWithTz(userTimezone);
        final lastTime = timeSlots.last.toLocalTimeStringWithTz(userTimezone);
        final timezoneOffset = timeSlots.first.getTimezoneOffset(userTimezone);
        timeDisplay = '$firstTime - $lastTime ($timezoneOffset)';
      }
    } else {
      // Fallback to period display string
      timeDisplay = period.displayString;
    }

    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderThemed(context)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.directions_car,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).manageVehicles,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '$localizedDay - $timeDisplay',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryThemed(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentChildren(
    BuildContext context,
    List<features_vehicle.Vehicle> vehicles,
    PeriodSlotData slotData,
  ) {
    final timeSlots = slotData.times;

    if (timeSlots.isEmpty) {
      return _buildEmptyState(context);
    }

    // Always use ExpansionTile (Solution D) for consistency
    // Single slot: expanded by default
    // Multiple slots: collapsed by default
    return _buildEnhancedTimeSlotList(context, vehicles, timeSlots, slotData);
  }

  /// Enhanced vertical list with ExpansionTile for multiple time slots
  /// Mobile-first design with 96px touch targets and lazy loading
  /// Single slot: expanded by default, Multiple slots: collapsed by default
  Widget _buildEnhancedTimeSlotList(
    BuildContext context,
    List<features_vehicle.Vehicle> vehicles,
    List<TimeOfDayValue> timeSlots,
    PeriodSlotData slotData,
  ) {
    // Single slot should be expanded by default for better UX
    final isSingleSlot = timeSlots.length == 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time slot list
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: timeSlots.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final timeSlot = timeSlots[index];
            // Convert UTC time to user's timezone for display (without timezone to avoid redundancy)
            final currentUser = ref.watch(currentUserProvider);
            final userTimezone = currentUser?.timezone;

            // Convert UTC time to user's timezone for display (no timezone indicator - already shown in header)
            final timeSlotString = timeSlot.toLocalTimeString(userTimezone);
            final assignedVehicles = _getAssignedVehiclesForTime(
              timeSlot,
              slotData,
            );

            return Semantics(
              label: assignedVehicles.isEmpty
                  ? AppLocalizations.of(context).expandTimeSlot(timeSlotString)
                  : '$timeSlotString, ${AppLocalizations.of(context).vehicleCount(assignedVehicles.length)}',
              button: true,
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: assignedVehicles.isNotEmpty
                        ? AppColors.success.withValues(alpha: 0.3)
                        : AppColors.borderThemed(context),
                  ),
                ),
                child: ExpansionTile(
                  initiallyExpanded:
                      isSingleSlot, // Auto-expand for single slot
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: assignedVehicles.isNotEmpty
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.borderThemed(
                              context,
                            ).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.access_time,
                      color: assignedVehicles.isNotEmpty
                          ? AppColors.success
                          : AppColors.textSecondaryThemed(context),
                    ),
                  ),
                  title: Text(
                    timeSlotString,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        if (assignedVehicles.isNotEmpty) ...[
                          const Icon(
                            Icons.check_circle,
                            size: 16,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(
                                context,
                              ).vehicleCount(assignedVehicles.length),
                              style: const TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ] else
                          Text(
                            AppLocalizations.of(
                              context,
                            ).noVehiclesAssignedToTimeSlot,
                            style: TextStyle(
                              color: AppColors.textSecondaryThemed(context),
                            ),
                          ),
                      ],
                    ),
                  ),
                  children: [
                    _buildSingleSlotContent(
                      context,
                      vehicles,
                      timeSlot,
                      slotData,
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        // Close button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(AppLocalizations.of(context).close),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleSlotContent(
    BuildContext context,
    List<features_vehicle.Vehicle> vehicles,
    TimeOfDayValue timeSlot,
    PeriodSlotData slotData,
  ) {
    // Filter by specific timeSlot to ensure UI consistency
    final assignedVehicles = _getAssignedVehiclesForTime(timeSlot, slotData);
    final availableVehicles = vehicles.where((vehicle) {
      return !assignedVehicles.any(
        (assigned) => assigned.vehicleId == vehicle.id,
      );
    }).toList();

    // SORT available vehicles for stable order - prevent UI reorganization during manipulation
    availableVehicles.sort((a, b) {
      final nameComparison = a.name.compareTo(b.name);
      if (nameComparison != 0) return nameComparison;
      return a.id.compareTo(b.id);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Currently assigned vehicles
        if (assignedVehicles.isNotEmpty) ...[
          Text(
            AppLocalizations.of(context).currentlyAssigned,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...assignedVehicles.map(
            (vehicle) => _buildAssignedVehicleCard(context, vehicle),
          ),
          const SizedBox(height: 24),
        ],

        // Available vehicles to add
        if (availableVehicles.isNotEmpty) ...[
          Text(
            AppLocalizations.of(context).availableVehicles,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...availableVehicles.map(
            (vehicle) => _buildAvailableVehicleCard(context, vehicle),
          ),
        ] else if (assignedVehicles.isEmpty) ...[
          _buildEmptyState(context),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.info, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).allVehiclesAssigned,
                    style: const TextStyle(
                      color: AppColors.info,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        // Note: Close button is in parent _buildEnhancedTimeSlotList()
        // No duplicate close button needed here
      ],
    );
  }

  Widget _buildAssignedVehicleCard(
    BuildContext context,
    core_va.VehicleAssignment vehicle,
  ) {
    final vehicleName = vehicle.vehicleName;
    final vehicleId = vehicle.id;
    final seatOverride = vehicle.seatOverride;
    final effectiveCapacity = vehicle.effectiveCapacity;
    final childCount = vehicle.childAssignments.length;
    final hasOverride = vehicle.hasOverride;

    // Get original vehicle from family data to ensure correct base capacity
    final familyState = ref.read(family.familyComposedProvider);
    final familyVehicles = familyState.family?.vehicles ?? [];

    // Find the original vehicle by ID to get true base capacity
    // NO FALLBACK: Vehicle not found is a BUG that should be visible!
    features_vehicle.Vehicle originalVehicle;
    try {
      originalVehicle = familyVehicles.firstWhere(
        (v) => v.id == vehicle.vehicleId,
      );
    } catch (e) {
      // Vehicle assigned to slot but not found in family - this is a data inconsistency!
      return Card(
        elevation: 1,
        color: AppColors.error.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.error),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).errorTitle,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).vehicleNotFoundInFamily(
                  vehicle.vehicleName,
                  vehicle.vehicleId,
                ),
                style: const TextStyle(color: AppColors.error, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).contactSupportOrRemoveAssignment,
                style: TextStyle(
                  color: AppColors.error.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _removeVehicle(vehicle),
                icon: const Icon(Icons.delete, size: 16),
                label: Text(
                  AppLocalizations.of(context).removeAssignment,
                  style: const TextStyle(fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 36),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Use original vehicle's capacity as the true base capacity
    final baseCapacity = originalVehicle.capacity;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Vehicle info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getVehicleIcon(),
                              color: AppColors.success,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                vehicleName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Actions
                  Column(
                    children: [
                      IconButton(
                        onPressed: () => _manageChildren(vehicle),
                        icon: Icon(
                          Icons.child_care,
                          color: Theme.of(context).primaryColor,
                        ),
                        tooltip: AppLocalizations.of(context).manageChildren,
                      ),
                      IconButton(
                        onPressed: _isLoading
                            ? null
                            : () => _removeVehicle(vehicle),
                        icon: const Icon(
                          Icons.remove_circle,
                          color: AppColors.error,
                        ),
                        tooltip: AppLocalizations.of(context).removeVehicle,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Capacity bar (replaces old text display)
              _buildCapacityBar(
                usedSeats: childCount,
                effectiveCapacity: effectiveCapacity,
                baseCapacity: baseCapacity,
                hasOverride: hasOverride,
                status: vehicle.capacityStatus(), // Use domain logic
              ),

              // Capacity warning
              if (childCount > effectiveCapacity) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning,
                        color: AppColors.error,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(
                            context,
                          ).capacityExceeded(childCount - effectiveCapacity),
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 8),

              // Seat override section - CRITICAL: use vehicleId (assignment ID) for API calls!
              _buildSeatOverrideSection(
                vehicleId: vehicleId,
                vehicleName: vehicleName,
                baseCapacity: baseCapacity,
                currentOverride: seatOverride,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableVehicleCard(
    BuildContext context,
    features_vehicle.Vehicle vehicle, {
    TimeOfDayValue? timeSlot,
  }) {
    final vehicleName = vehicle.name;
    final capacity = vehicle.capacity;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.borderThemed(context)),
        ),
        child: InkWell(
          onTap: _isLoading
              ? null
              : () => _addVehicle(vehicle, timeSlot: timeSlot),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Vehicle info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getVehicleIcon(),
                            color: AppColors.textSecondaryThemed(context),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              vehicleName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 14,
                            color: AppColors.textSecondaryThemed(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppLocalizations.of(context).seatsCount(capacity),
                            style: TextStyle(
                              color: AppColors.textSecondaryThemed(context),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Add button
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
              ],
            ),
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

  Widget _buildErrorState(BuildContext context, String error) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).errorLoadingVehicles,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondaryThemed(context),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).close),
            ),
          ],
        ),
      ),
    );
  }

  /// Add vehicle to slot with TYPE-SAFE parameters
  ///
  /// Converts typed domain entities to API format (strings) only at boundary.
  /// **No validation needed** - types guarantee correctness!
  /// Backend handler is idempotent and will handle duplicates gracefully.
  Future<void> _addVehicle(
    features_vehicle.Vehicle vehicle, {
    TimeOfDayValue? timeSlot,
  }) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final vehicleId = vehicle.id;

      // Use TYPE-SAFE domain entities - convert to API format at boundary
      final dayOfWeek = widget.scheduleSlot.dayOfWeek;
      final timeOfDay =
          timeSlot ??
          widget.scheduleSlot.times.firstOrNull ??
          TimeOfDayValue.midnight;

      // Convert to API format (strings) ONLY at this boundary
      final day = dayOfWeek.fullName; // "Monday", "Tuesday", etc.
      final time = timeOfDay.toApiFormat(); // "07:30", "14:00", etc.
      final week = widget.scheduleSlot.week;

      final useCase = ref.read(assignVehicleToSlotUsecaseProvider);
      final result = await useCase.call(
        AssignVehicleToSlotParams(
          groupId: widget.groupId,
          day: day,
          time: time,
          week: week,
          vehicleId: vehicleId,
        ),
      );

      if (result.isError) {
        throw Exception(result.error.toString());
      }

      // Refresh provider to reflect changes
      ref.invalidate(weeklyScheduleProvider(widget.groupId, week));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).vehicleAddedSuccess(vehicle.name),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );

        // Note: Child assignment is now OPTIONAL
        // Users can manually open it via the child_care icon button in the vehicle card
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).vehicleFailedToAdd(e.toString()),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeVehicle(core_va.VehicleAssignment vehicle) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use vehicleId (the vehicle's ID) not id (the assignment's ID)
      final vehicleId = vehicle.vehicleId;

      // Find the correct slot that contains this vehicle
      final slotContainingVehicle = widget.scheduleSlot.slots.firstWhere(
        (slot) =>
            slot.vehicleAssignments.any((va) => va.vehicleId == vehicleId),
        orElse: () => throw Exception(
          'Vehicle $vehicleId not found in any slot. This should never happen.',
        ),
      );

      final slotId = slotContainingVehicle.id;

      final useCase = ref.read(removeVehicleFromSlotUsecaseProvider);
      final result = await useCase.call(
        RemoveVehicleFromSlotParams(
          groupId: widget.groupId,
          slotId: slotId,
          vehicleAssignmentId: vehicleId,
        ),
      );

      if (result.isError) {
        throw Exception(result.error.toString());
      }

      // Check if this was the last vehicle in the period BEFORE invalidation
      // If so, close the modal as the slot no longer exists
      final assignedVehicles = _getAssignedVehicles(widget.scheduleSlot);
      final isLastVehicle =
          assignedVehicles.length == 1 &&
          assignedVehicles.first.vehicleId == vehicleId;

      // Refresh provider to reflect changes
      final week = widget.scheduleSlot.week;
      ref.invalidate(weeklyScheduleProvider(widget.groupId, week));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              ).vehicleRemovedSuccess(vehicle.vehicleName),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );

        // Close modal if this was the last vehicle
        if (isLastVehicle) {
          // Small delay to let the user see the success message
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).vehicleFailedToRemove(e.toString()),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _manageChildren(core_va.VehicleAssignment vehicle) async {
    // Extract week from schedule slot
    final week = widget.scheduleSlot.week;
    if (week.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).cannotDetermineWeek),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Extract currently assigned child IDs - convert to List<String>
    final currentlyAssignedChildIds = vehicle.childAssignments
        .map((ca) => ca.childId)
        .where((id) => id.isNotEmpty)
        .toList();

    // Get available children from family provider
    final allFamilyChildren = ref.read(familyChildrenProvider);

    // Find the correct slotId using the new helper method.
    final slotId = _findSlotIdForVehicle(vehicle);

    // BUSINESS RULE: A child cannot be in 2 vehicles at the same time for the same slot
    // Filter out children who are already assigned to ANY vehicle in this slot
    final currentSlot = widget.scheduleSlot.slots.firstWhere(
      (slot) => slot.id == slotId,
      orElse: () =>
          throw StateError('Slot $slotId not found. This should never happen.'),
    );

    // Get all child IDs already assigned in this slot (across all vehicles)
    final assignedChildIdsInSlot = currentSlot.vehicleAssignments
        .expand((va) => va.childAssignments)
        .map((ca) => ca.childId)
        .where((id) => id.isNotEmpty)
        .toSet();

    // Filter available children to exclude those already assigned in the slot
    final availableChildren = allFamilyChildren
        .where((child) => !assignedChildIdsInSlot.contains(child.id))
        .toList();

    // Show the child assignment sheet - pass the core VehicleAssignment and slotId
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChildAssignmentSheet(
        groupId: widget.groupId,
        week: week,
        slotId: slotId,
        vehicleAssignment: vehicle,
        availableChildren: availableChildren,
        currentlyAssignedChildIds: currentlyAssignedChildIds,
      ),
    );

    // Refresh schedule data after closing the sheet
    if (mounted) {
      ref.invalidate(weeklyScheduleProvider(widget.groupId, week));
    }
  }

  // Helper methods

  /// Finds the schedule slot ID associated with a given vehicle in the current context.
  /// Throws a StateError if not found, as this indicates a logic error.
  String _findSlotIdForVehicle(core_va.VehicleAssignment vehicle) {
    try {
      final slotContainingVehicle = widget.scheduleSlot.slots.firstWhere(
        (slot) => slot.vehicleAssignments.any(
          (va) => va.vehicleId == vehicle.vehicleId,
        ),
        orElse: () => throw StateError(
          'Vehicle ${vehicle.vehicleId} not found in any slot. This should never happen.',
        ),
      );
      return slotContainingVehicle.id;
    } catch (e) {
      // This should never happen in this flow. If it does, it's a critical state error.
      throw StateError(
        'Could not find a slot for vehicle ${vehicle.vehicleId} in scheduleSlot ${widget.scheduleSlot.week}',
      );
    }
  }

  List<core_va.VehicleAssignment> _getAssignedVehicles(
    PeriodSlotData slotData,
  ) {
    // Get all vehicle assignments from all slots in this period
    return slotData.slots.expand((slot) => slot.vehicleAssignments).toList();
  }

  /// Get vehicles assigned to a specific time slot with TYPE-SAFETY
  ///
  /// Uses [TimeOfDayValue] for matching instead of strings.
  /// Filters vehicles from period slots by matching time.
  List<core_va.VehicleAssignment> _getAssignedVehiclesForTime(
    TimeOfDayValue timeSlot,
    PeriodSlotData slotData,
  ) {
    // Find the slot that matches this specific time using typed comparison
    final matchingSlot = slotData.slots
        .where((slot) => slot.timeOfDay.isSameAs(timeSlot))
        .firstOrNull;

    if (matchingSlot == null) {
      // No slot found for this time - time slot has no vehicles assigned yet
      return [];
    }

    // Return vehicles for this specific time slot - SORTED for stable order!
    final vehicles = matchingSlot.vehicleAssignments.toList();
    // Sort by vehicle name first, then by vehicle ID as tie-breaker for guaranteed stability
    vehicles.sort((a, b) {
      final nameComparison = a.vehicleName.compareTo(b.vehicleName);
      if (nameComparison != 0) return nameComparison;
      return a.vehicleId.compareTo(b.vehicleId);
    });
    return vehicles;
  }

  IconData _getVehicleIcon() {
    // Vehicle type no longer available - use default car icon
    return Icons.directions_car;
  }
}
