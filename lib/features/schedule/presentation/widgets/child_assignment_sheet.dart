import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulift/core/domain/entities/schedule.dart';
import 'package:edulift/core/domain/entities/family/child.dart';
import 'package:edulift/core/domain/entities/family/child_assignment.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import '../providers/schedule_providers.dart';
import '../design/schedule_design.dart';
import '../../../../core/presentation/themes/app_text_styles.dart';
import '../../../../core/presentation/themes/app_colors.dart';

/// Child Assignment Sheet with Validation
/// Level 3 DraggableScrollableSheet at 90%
class ChildAssignmentSheet extends ConsumerStatefulWidget {
  final String groupId;
  final String week;
  final String slotId;
  final VehicleAssignment vehicleAssignment;
  final List<Child> availableChildren;
  final List<String> currentlyAssignedChildIds;

  const ChildAssignmentSheet({
    super.key,
    required this.groupId,
    required this.week,
    required this.slotId,
    required this.vehicleAssignment,
    required this.availableChildren,
    required this.currentlyAssignedChildIds,
  });

  @override
  ConsumerState<ChildAssignmentSheet> createState() =>
      _ChildAssignmentSheetState();
}

class _ChildAssignmentSheetState extends ConsumerState<ChildAssignmentSheet> {
  final Set<String> _selectedChildIds = {};
  bool _isLoading = false;
  String? _conflictError;

  @override
  void initState() {
    super.initState();
    // Initialize with currently assigned children
    _selectedChildIds.addAll(widget.currentlyAssignedChildIds);
  }

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
                  color: AppColors.onSurfaceVariant(
                    context,
                  ).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              _buildHeader(context),

              // Capacity bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ScheduleDimensions.spacingLg,
                  vertical: ScheduleDimensions.spacingMd,
                ),
                child: _buildCapacityBar(),
              ),

              // Conflict error display
              if (_conflictError != null && _conflictError!.isNotEmpty)
                _buildConflictError(),

              // Scrollable child list
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(ScheduleDimensions.spacingLg),
                  children: [
                    Text(
                      'Select Children',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: ScheduleDimensions.spacingMd),
                    ...widget.availableChildren.map(
                      (child) => _buildChildCard(child),
                    ),
                    const SizedBox(
                      height: 80,
                    ), // Space for bottom buttons (fixed height needed)
                  ],
                ),
              ),

              // Bottom action buttons
              _buildBottomActions(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
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
              Icons.child_care,
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
                  'Assign Children',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  widget.vehicleAssignment.vehicleName,
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

  Widget _buildCapacityBar() {
    final usedSeats = _selectedChildIds.length;
    final effectiveCapacity = widget.vehicleAssignment.effectiveCapacity;
    final baseCapacity = widget.vehicleAssignment.capacity;
    final hasOverride = widget.vehicleAssignment.hasOverride;

    final percentage = effectiveCapacity > 0
        ? usedSeats / effectiveCapacity
        : 0.0;

    // Use domain logic through temporary vehicle assignment for capacity status
    final tempAssignment = widget.vehicleAssignment.copyWith(
      childAssignments: _selectedChildIds
          .map(
            (id) => ChildAssignment(
              id: id,
              childId: id,
              assignmentType: 'temp',
              assignmentId: 'temp',
              status: AssignmentStatus.pending,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          )
          .toList(),
    );
    final status = tempAssignment.capacityStatus();

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
            const SizedBox(width: ScheduleDimensions.spacingSm),
            if (hasOverride)
              const Tooltip(
                message: 'Seat override active',
                child: Icon(
                  Icons.edit,
                  size: ScheduleDimensions.iconSizeSmall,
                  color: AppColors.warning,
                ),
              ),
          ],
        ),
        const SizedBox(height: ScheduleDimensions.spacingXs),
        Row(
          children: [
            Expanded(
              child: Text(
                '$usedSeats / $effectiveCapacity seats',
                style: AppTextStyles.bodySmall.copyWith(
                  color: barColor,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (hasOverride) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Override: $effectiveCapacity ($baseCapacity base)',
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.warning,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildChildCard(Child child) {
    final isSelected = _selectedChildIds.contains(child.id);
    final canAssign = _canAssignChild(child);

    return Card(
      margin: const EdgeInsets.only(bottom: ScheduleDimensions.spacingSm),
      elevation: isSelected ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: ScheduleDimensions.cardRadius,
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).primaryColor
              : AppColors.borderThemed(context),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: canAssign || isSelected
            ? () => _toggleChildSelection(child)
            : null,
        borderRadius: ScheduleDimensions.cardRadius,
        child: Padding(
          padding: const EdgeInsets.all(ScheduleDimensions.spacingMd),
          child: Row(
            children: [
              // Checkbox with semantic label
              Semantics(
                label: isSelected
                    ? 'Selected, ${child.name}'
                    : 'Not selected, ${child.name}',
                checked: isSelected,
                enabled: canAssign || isSelected,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (canAssign || isSelected)
                      ? (_) => _toggleChildSelection(child)
                      : null,
                ),
              ),
              const SizedBox(width: ScheduleDimensions.spacingMd),

              // Child avatar
              CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withValues(alpha: 0.1),
                child: Text(
                  child.initials,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: ScheduleDimensions.spacingMd),

              // Child info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!canAssign && !isSelected)
                      Text(
                        'Vehicle full',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                  ],
                ),
              ),

              // Status indicator
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                  size: ScheduleDimensions.iconSizeSmall,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ScheduleDimensions.spacingLg),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: AppColors.borderThemed(context))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: ScheduleDimensions.spacingMd,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: ScheduleDimensions.cardRadius,
                  ),
                ),
                child: Text(AppLocalizations.of(context).cancel),
              ),
            ),
            const SizedBox(width: ScheduleDimensions.spacingMd),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _canSave ? _saveAssignments : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: ScheduleDimensions.spacingMd,
                  ),
                  backgroundColor: _canSave
                      ? Theme.of(context).primaryColor
                      : AppColors.textSecondaryThemed(context),
                  shape: const RoundedRectangleBorder(
                    borderRadius: ScheduleDimensions.cardRadius,
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        AppLocalizations.of(
                          context,
                        ).saveAssignments(_selectedChildIds.length),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build conflict error warning banner
  Widget _buildConflictError() {
    return Container(
      padding: const EdgeInsets.all(ScheduleDimensions.spacingMd),
      margin: const EdgeInsets.symmetric(
        horizontal: ScheduleDimensions.spacingLg,
        vertical: ScheduleDimensions.spacingSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: ScheduleDimensions.iconSizeSmall,
          ),
          const SizedBox(width: ScheduleDimensions.spacingSm),
          Expanded(
            child: Text(
              _conflictError!,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canAssignChild(Child child) {
    // Already selected children can always be unassigned
    if (_selectedChildIds.contains(child.id)) {
      return true;
    }

    // Use effectiveCapacity check (same validation as ValidateChildAssignmentUseCase)
    // Note: Use case expects Future<Result> which isn't suitable for synchronous UI check
    final currentAssignmentCount = _selectedChildIds.length;
    final effectiveCapacity = widget.vehicleAssignment.effectiveCapacity;

    return currentAssignmentCount < effectiveCapacity;
  }

  void _toggleChildSelection(Child child) async {
    await HapticFeedback.lightImpact();

    setState(() {
      if (_selectedChildIds.contains(child.id)) {
        _selectedChildIds.remove(child.id);
        // Clear conflict error when user makes changes
        _conflictError = null;
      } else {
        if (_canAssignChild(child)) {
          _selectedChildIds.add(child.id);
          // Clear conflict error on valid selection
          _conflictError = null;
        } else {
          // Set conflict error instead of showing snackbar
          _conflictError = AppLocalizations.of(context).vehicleCapacityFull;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).vehicleCapacityFull),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    });
  }

  /// Check if save operation is allowed (PRODUCTION QUALITY)
  ///
  /// Ensures data integrity by blocking save when:
  /// - No changes detected (_hasChanges = false)
  /// - Conflict error present (_conflictError != null)
  /// - Validation failed (_isValid() = false)
  /// - Loading in progress (_isLoading = true)
  ///
  /// This prevents:
  /// - Accidental overwrites
  /// - Data corruption
  /// - Silent failures
  /// - Invalid state persistence
  bool get _canSave {
    // Loading in progress = block save
    if (_isLoading) return false;

    // Conflict detected = block save
    if (_conflictError != null && _conflictError!.isNotEmpty) return false;

    // No changes = no save needed
    if (!_hasChanges) return false;

    // Validation failed = block save
    if (!_isValid()) return false;

    return true;
  }

  /// Check if there are changes compared to initial state
  bool get _hasChanges {
    // Compare current selection with initial assignments
    final currentIds = _selectedChildIds.toSet();
    final initialIds = widget.currentlyAssignedChildIds.toSet();

    // Check if sets are different (additions or removals)
    return currentIds.difference(initialIds).isNotEmpty ||
        initialIds.difference(currentIds).isNotEmpty;
  }

  /// Validate current assignment state
  bool _isValid() {
    // Check capacity constraint
    final selectedCount = _selectedChildIds.length;
    final effectiveCapacity = widget.vehicleAssignment.effectiveCapacity;

    if (selectedCount > effectiveCapacity) {
      _conflictError =
          'Capacity exceeded: $selectedCount children selected, but only $effectiveCapacity seats available';
      return false;
    }

    return true;
  }

  Future<void> _saveAssignments() async {
    setState(() => _isLoading = true);

    await HapticFeedback.mediumImpact();

    // Determine children to add/remove
    final childrenToAdd = _selectedChildIds
        .where((id) => !widget.currentlyAssignedChildIds.contains(id))
        .toList();
    final childrenToRemove = widget.currentlyAssignedChildIds
        .where((id) => !_selectedChildIds.contains(id))
        .toList();

    var hasError = false;

    // Assign new children
    for (final childId in childrenToAdd) {
      final result = await ref
          .read(assignmentStateNotifierProvider.notifier)
          .assignChild(
            groupId: widget.groupId,
            week: widget.week,
            assignmentId: widget.vehicleAssignment.id,
            childId: childId,
            vehicleAssignment: widget.vehicleAssignment,
          );

      if (result.isErr) {
        setState(() => _isLoading = false);
        if (!mounted) return;

        final error = result.unwrapErr();

        // ✅ Messages spécifiques selon statusCode et error code
        var errorMessage = '';
        var errorColor = AppColors.error;
        var errorIcon = Icons.error;
        var canRetry = false;

        switch (error.statusCode) {
          case 409:
            // Conflict - Check specific error code for targeted messaging
            if (error.code == 'schedule.child_already_assigned') {
              // Child already assigned to another vehicle
              errorMessage =
                  error.message ??
                  'This child is already assigned to another vehicle for this time slot. '
                      'Please check the schedule and try again.';
              errorColor = AppColors.warning;
              errorIcon = Icons.warning_amber_rounded;
              canRetry = true;
            } else if (error.code == 'schedule.capacity_exceeded_race') {
              // Capacity race condition
              errorMessage =
                  'Vehicle capacity changed. Another parent just assigned a child. '
                  'Please refresh and try again.';
              errorColor = AppColors.warning;
              errorIcon = Icons.warning_amber_rounded;
              canRetry = true;
            } else {
              // Generic 409 conflict
              errorMessage =
                  error.message ??
                  'Conflict detected. Please refresh and try again.';
              errorColor = AppColors.warning;
              errorIcon = Icons.warning_amber_rounded;
              canRetry = true;
            }
            break;

          case 400:
            // Validation error
            errorMessage =
                error.message ??
                'Invalid assignment. Please check your selection.';
            errorColor = AppColors.error;
            errorIcon = Icons.error_outline;
            break;

          case 403:
            // Permission denied
            errorMessage =
                'You don\'t have permission to assign children to this vehicle.';
            errorColor = AppColors.error;
            errorIcon = Icons.block;
            break;

          default:
            // Generic server error
            errorMessage =
                error.message ?? 'An error occurred. Please try again.';
            errorColor = AppColors.error;
            errorIcon = Icons.error;
        }

        // Afficher SnackBar avec action Refresh si retryable
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(errorIcon, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: errorColor,
            action: canRetry
                ? SnackBarAction(
                    label: 'Refresh',
                    textColor: Colors.white,
                    onPressed: () {
                      // Refresh et fermer
                      ref.invalidate(weeklyScheduleProvider);
                      Navigator.pop(context);
                    },
                  )
                : null,
            duration: canRetry
                ? const Duration(seconds: 8)
                : const Duration(seconds: 4),
          ),
        );

        hasError = true;
        return;
      }
    }

    // Unassign removed children
    for (final childId in childrenToRemove) {
      final result = await ref
          .read(assignmentStateNotifierProvider.notifier)
          .unassignChild(
            groupId: widget.groupId,
            week: widget.week,
            assignmentId: widget.vehicleAssignment.id,
            childId: childId,
            slotId: widget.slotId, // Use reliable slotId from widget parameter
            childAssignmentId:
                childId, // Use childId as the assignment identifier
          );

      if (result.isErr) {
        setState(() => _isLoading = false);
        if (!mounted) return;

        final error = result.unwrapErr();

        // ✅ Messages spécifiques selon statusCode
        var errorMessage = '';
        var errorColor = AppColors.error;
        var errorIcon = Icons.error;
        var canRetry = false;

        switch (error.statusCode) {
          case 409:
            // Conflict - Child no longer assigned
            errorMessage =
                'Assignment changed while editing. Please refresh and try again.';
            errorColor = AppColors.warning;
            errorIcon = Icons.warning_amber_rounded;
            canRetry = true;
            break;

          case 400:
            // Validation error
            errorMessage = error.message ?? 'Invalid unassignment operation.';
            errorColor = AppColors.error;
            errorIcon = Icons.error_outline;
            break;

          case 403:
            // Permission denied
            errorMessage = 'You don\'t have permission to unassign this child.';
            errorColor = AppColors.error;
            errorIcon = Icons.block;
            break;

          default:
            // Generic server error
            errorMessage =
                error.message ?? 'Failed to unassign child. Please try again.';
            errorColor = AppColors.error;
            errorIcon = Icons.error;
        }

        // Afficher SnackBar avec action Refresh si retryable
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(errorIcon, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: errorColor,
            action: canRetry
                ? SnackBarAction(
                    label: 'Refresh',
                    textColor: Colors.white,
                    onPressed: () {
                      // Refresh et fermer
                      ref.invalidate(weeklyScheduleProvider);
                      Navigator.pop(context);
                    },
                  )
                : null,
            duration: canRetry
                ? const Duration(seconds: 8)
                : const Duration(seconds: 4),
          ),
        );

        hasError = true;
        return;
      }
    }

    setState(() => _isLoading = false);

    if (!hasError) {
      await HapticFeedback.heavyImpact(); // Success feedback

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).assignmentsSavedSuccessfully,
          ),
          backgroundColor: AppColors.success,
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }
}
