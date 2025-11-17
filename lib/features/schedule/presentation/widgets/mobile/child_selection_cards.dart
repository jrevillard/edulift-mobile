import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulift/core/domain/entities/family/child.dart';
import 'package:edulift/core/domain/entities/schedule.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import '../../providers/schedule_providers.dart';
import '../../design/schedule_design.dart';
import '../../../../../core/presentation/themes/app_text_styles.dart';
import '../../../../../core/presentation/themes/app_colors.dart';

// Import for unawaited function
import 'dart:async' show unawaited;
import '../../../../../core/presentation/widgets/capacity_progress_bar.dart';
import '../../../../../core/presentation/widgets/family_colored_text.dart';

/// Mobile Child Selection Cards with 90% Bottom Sheet Design
///
/// Features:
/// - 90% bottom sheet design optimized for mobile
/// - Real-time capacity indicators with color coding
/// - Child selection with availability constraints
/// - Visual feedback for capacity limits
/// - Complete accessibility support
/// - Widget keys for comprehensive testing
class ChildSelectionCards extends ConsumerStatefulWidget {
  final String groupId;
  final String week;
  final String slotId;
  final VehicleAssignment vehicleAssignment;
  final List<Child> availableChildren;
  final List<String> currentlyAssignedChildIds;

  const ChildSelectionCards({
    super.key,
    required this.groupId,
    required this.week,
    required this.slotId,
    required this.vehicleAssignment,
    required this.availableChildren,
    required this.currentlyAssignedChildIds,
  });

  @override
  ConsumerState<ChildSelectionCards> createState() =>
      _ChildSelectionCardsState();
}

class _ChildSelectionCardsState extends ConsumerState<ChildSelectionCards>
    with TickerProviderStateMixin {
  final Set<String> _selectedChildIds = {};
  bool _isLoading = false;
  String? _conflictError;
  late AnimationController _capacityAnimationController;
  late AnimationController _selectionAnimationController;
  late Animation<double> _capacityAnimation;

  // Widget keys for testing
  static const bottomSheetKey = Key('child_selection_bottom_sheet');
  static const dragHandleKey = Key('child_selection_drag_handle');
  static const headerKey = Key('child_selection_header');
  static const capacityBarKey = Key('child_selection_capacity_bar');
  static const childListKey = Key('child_selection_list');
  static const saveButtonKey = Key('child_selection_save_button');
  static const cancelButtonKey = Key('child_selection_cancel_button');
  static const conflictErrorKey = Key('child_selection_conflict_error');

  @override
  void initState() {
    super.initState();
    _selectedChildIds.addAll(widget.currentlyAssignedChildIds);

    // Initialize capacity animation controller
    _capacityAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Initialize selection animation controller
    _selectionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _capacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _capacityAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start capacity animation
    _capacityAnimationController.forward();
  }

  @override
  void dispose() {
    _capacityAnimationController.dispose();
    _selectionAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      key: bottomSheetKey,
      initialChildSize: 0.9,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle with visual feedback
              _buildDragHandle(context),

              // Header section
              _buildHeader(context),

              // Animated capacity bar
              AnimatedBuilder(
                animation: _capacityAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _capacityAnimation.value,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ScheduleDimensions.spacingLg,
                        vertical: ScheduleDimensions.spacingMd,
                      ),
                      child: _buildCapacityBar(),
                    ),
                  );
                },
              ),

              // Conflict error banner with shake animation
              if (_conflictError != null && _conflictError!.isNotEmpty)
                _buildConflictError(),

              // Scrollable child list
              Expanded(
                child: ListView.builder(
                  key: childListKey,
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: ScheduleDimensions.spacingLg,
                    vertical: ScheduleDimensions.spacingMd,
                  ),
                  itemCount:
                      widget.availableChildren.length + 1, // +1 for header
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Section header
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: ScheduleDimensions.spacingMd,
                        ),
                        child: Text(
                          'Select Children to Assign',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimaryThemed(context),
                              ),
                        ),
                      );
                    }

                    final childIndex = index - 1;
                    final child = widget.availableChildren[childIndex];
                    return _buildChildCard(child, childIndex);
                  },
                ),
              ),

              // Bottom action buttons with safe area
              _buildBottomActions(context),
            ],
          ),
        );
      },
    );
  }

  /// Build drag handle with enhanced visual feedback
  Widget _buildDragHandle(BuildContext context) {
    return Container(
      key: dragHandleKey,
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
    );
  }

  /// Build enhanced header section
  Widget _buildHeader(BuildContext context) {
    return Container(
      key: headerKey,
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
          // Vehicle icon with background
          Container(
            padding: const EdgeInsets.all(ScheduleDimensions.spacingSm),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.directions_car,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              size: ScheduleDimensions.iconSizeSmall,
            ),
          ),
          const SizedBox(width: ScheduleDimensions.spacingMd),

          // Vehicle information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assign Children',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryThemed(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.vehicleAssignment.vehicleName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryThemed(context),
                  ),
                ),
              ],
            ),
          ),

          // Capacity badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ScheduleDimensions.spacingSm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: _getCapacityColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getCapacityIcon(), color: _getCapacityColor(), size: 16),
                const SizedBox(width: 4),
                Text(
                  '${_selectedChildIds.length}/${widget.vehicleAssignment.effectiveCapacity}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: _getCapacityColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build enhanced capacity bar with real-time indicators
  Widget _buildCapacityBar() {
    return Container(
      key: capacityBarKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Use shared CapacityProgressBar component
          CapacityProgressBar(
            assigned: _selectedChildIds.length,
            capacity: widget.vehicleAssignment.effectiveCapacity,
          ),

          const SizedBox(height: ScheduleDimensions.spacingXs),

          // Override indicator
          if (widget.vehicleAssignment.hasOverride)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.warningThemed(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit,
                    size: 12,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Override',
                    style: AppTextStyles.overline.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Build child selection card with enhanced features
  Widget _buildChildCard(Child child, int index) {
    final isSelected = _selectedChildIds.contains(child.id);
    final canAssign = _canAssignChild(child);
    final cardKey = Key('child_card_${child.id}');

    return AnimatedContainer(
      key: cardKey,
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: ScheduleDimensions.spacingSm),
      curve: Curves.easeInOut,
      child: Card(
        elevation: isSelected ? 4 : 2,
        shadowColor: isSelected
            ? AppColors.primaryThemed(context).withValues(alpha: 0.2)
            : Theme.of(context).shadowColor.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: _getCardBorderColor(isSelected, canAssign),
            width: isSelected ? 2 : 1,
          ),
        ),
        color: _getCardBackgroundColor(isSelected, canAssign),
        child: InkWell(
          onTap: (canAssign || isSelected)
              ? () => _toggleChildSelection(child, index)
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(ScheduleDimensions.spacingMd),
            child: Row(
              children: [
                // Animated checkbox with accessibility
                Semantics(
                  label: isSelected
                      ? 'Selected, ${child.name}. Tap to deselect.'
                      : canAssign
                      ? 'Not selected, ${child.name}. Tap to select.'
                      : '${child.name}. Cannot select, vehicle at full capacity.',
                  checked: isSelected,
                  enabled: canAssign || isSelected,
                  button: true,
                  onTap: (canAssign || isSelected)
                      ? () => _toggleChildSelection(child, index)
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (canAssign || isSelected)
                          ? (_) => _toggleChildSelection(child, index)
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: ScheduleDimensions.spacingMd),

                // Child avatar with initial
                Hero(
                  tag: 'child_avatar_${child.id}',
                  child: CircleAvatar(
                    backgroundColor: isSelected
                        ? AppColors.primaryThemed(
                            context,
                          ).withValues(alpha: 0.1)
                        : AppColors.childBadge(context),
                    radius: 24,
                    child: Text(
                      child.initials,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primaryThemed(context)
                            : Theme.of(
                                context,
                              ).colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: ScheduleDimensions.spacingMd),

                // Child information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Use FamilyColoredText for child name
                      FamilyColoredText(
                        text: child.name,
                        isFamilyMember: child.familyId == widget.groupId,
                        baseStyle: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.primaryThemed(context)
                              : null, // Let FamilyColoredText handle color
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (!canAssign && !isSelected)
                        Text(
                          'Vehicle at full capacity',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.errorThemed(context),
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else if (isSelected)
                        Text(
                          'Selected for assignment',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primaryThemed(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),

                // Status indicator with animation
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isSelected
                      ? Icon(
                          Icons.check_circle,
                          key: ValueKey('selected_${child.id}'),
                          color: AppColors.primaryThemed(context),
                          size: ScheduleDimensions.iconSizeSmall,
                        )
                      : canAssign
                      ? Icon(
                          Icons.add_circle_outline,
                          key: ValueKey('available_${child.id}'),
                          color: AppColors.textSecondaryThemed(context),
                          size: ScheduleDimensions.iconSizeSmall,
                        )
                      : Icon(
                          Icons.block,
                          key: ValueKey('blocked_${child.id}'),
                          color: AppColors.errorThemed(context),
                          size: ScheduleDimensions.iconSizeSmall,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build conflict error banner with shake animation
  Widget _buildConflictError() {
    return Container(
      key: conflictErrorKey,
      margin: const EdgeInsets.symmetric(
        horizontal: ScheduleDimensions.spacingLg,
        vertical: ScheduleDimensions.spacingSm,
      ),
      padding: const EdgeInsets.all(ScheduleDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.errorThemed(context),
        border: Border.all(
          color: AppColors.errorThemed(context).withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.onErrorContainer,
            size: ScheduleDimensions.iconSizeSmall,
          ),
          const SizedBox(width: ScheduleDimensions.spacingSm),
          Expanded(
            child: Text(
              _conflictError!,
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _conflictError = null),
            icon: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.onErrorContainer,
              size: 18,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  /// Build bottom action buttons with enhanced styling
  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ScheduleDimensions.spacingLg),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: AppColors.borderThemed(context))),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Cancel button
            Expanded(
              child: OutlinedButton(
                key: cancelButtonKey,
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: ScheduleDimensions.spacingMd,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: AppColors.borderStrong(context)),
                ),
                child: Text(
                  'Cancel',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textSecondaryThemed(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: ScheduleDimensions.spacingMd),

            // Save button with enhanced styling
            Expanded(
              flex: 2,
              child: ElevatedButton(
                key: saveButtonKey,
                onPressed: _canSave ? _saveAssignments : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: ScheduleDimensions.spacingMd,
                  ),
                  backgroundColor: _canSave
                      ? AppColors.primaryThemed(context)
                      : AppColors.textSecondaryThemed(
                          context,
                        ).withValues(alpha: 0.5),
                  foregroundColor: _canSave
                      ? Theme.of(context).colorScheme.onPrimary
                      : AppColors.textDisabled(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: _canSave ? 2 : 0,
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                    : Text(
                        AppLocalizations.of(
                          context,
                        ).saveAssignments(_selectedChildIds.length),
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for capacity calculation and styling

  double _getCapacityPercentage() {
    final usedSeats = _selectedChildIds.length;
    final effectiveCapacity = widget.vehicleAssignment.effectiveCapacity;
    return effectiveCapacity > 0 ? usedSeats / effectiveCapacity : 0.0;
  }

  Color _getCapacityColor() {
    final percentage = _getCapacityPercentage();

    if (percentage >= 1.0) {
      return AppColors.errorThemed(context);
    } else if (percentage >= 0.8) {
      return AppColors.warningThemed(context);
    } else {
      return AppColors.successThemed(context);
    }
  }

  IconData _getCapacityIcon() {
    final percentage = _getCapacityPercentage();

    if (percentage >= 1.0) {
      return Icons.error;
    } else if (percentage >= 0.8) {
      return Icons.warning;
    } else {
      return Icons.check_circle;
    }
  }

  Color _getCardBorderColor(bool isSelected, bool canAssign) {
    if (isSelected) {
      return AppColors.primaryThemed(context);
    } else if (!canAssign) {
      return AppColors.errorThemed(context).withValues(alpha: 0.3);
    } else {
      return AppColors.borderThemed(context);
    }
  }

  Color _getCardBackgroundColor(bool isSelected, bool canAssign) {
    if (isSelected) {
      return Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: 0.05);
    } else if (!canAssign) {
      return AppColors.errorThemed(context).withValues(alpha: 0.1);
    } else {
      return Theme.of(context).colorScheme.surface;
    }
  }

  bool _canAssignChild(Child child) {
    // Already selected children can always be unassigned
    if (_selectedChildIds.contains(child.id)) {
      return true;
    }

    final currentAssignmentCount = _selectedChildIds.length;
    final effectiveCapacity = widget.vehicleAssignment.effectiveCapacity;

    return currentAssignmentCount < effectiveCapacity;
  }

  Future<void> _toggleChildSelection(Child child, int index) async {
    await HapticFeedback.lightImpact();

    // Play selection animation (fire and forget - no need to await)
    unawaited(_selectionAnimationController.forward());
    unawaited(_selectionAnimationController.reverse());

    setState(() {
      if (_selectedChildIds.contains(child.id)) {
        _selectedChildIds.remove(child.id);
        _conflictError = null;
      } else {
        if (_canAssignChild(child)) {
          _selectedChildIds.add(child.id);
          _conflictError = null;
        } else {
          _conflictError = AppLocalizations.of(context).vehicleCapacityFull;
          _showCapacityFullFeedback();
        }
      }
    });

    // Animate capacity bar changes (fire and forget)
    _capacityAnimationController.reset();
    unawaited(_capacityAnimationController.forward());
  }

  void _showCapacityFullFeedback() {
    // Show snackbar for capacity full
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(AppLocalizations.of(context).vehicleCapacityFull),
            ),
          ],
        ),
        backgroundColor: AppColors.errorThemed(context),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  bool get _canSave {
    if (_isLoading) return false;
    if (_conflictError != null && _conflictError!.isNotEmpty) return false;
    if (!_hasChanges) return false;
    if (!_isValid()) return false;
    return true;
  }

  bool get _hasChanges {
    final currentIds = _selectedChildIds.toSet();
    final initialIds = widget.currentlyAssignedChildIds.toSet();

    return currentIds.difference(initialIds).isNotEmpty ||
        initialIds.difference(currentIds).isNotEmpty;
  }

  bool _isValid() {
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
        _handleAssignmentError(error, context);
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
            slotId: widget.slotId,
            childAssignmentId: childId,
          );

      if (result.isErr) {
        setState(() => _isLoading = false);
        if (!mounted) return;

        final error = result.unwrapErr();
        _handleUnassignmentError(error, context);
        hasError = true;
        return;
      }
    }

    setState(() => _isLoading = false);

    if (!hasError) {
      await HapticFeedback.heavyImpact();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).assignmentsSavedSuccessfully,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.successThemed(context),
          duration: const Duration(seconds: 3),
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  void _handleAssignmentError(dynamic error, BuildContext context) {
    var errorMessage = '';
    var errorColor = AppColors.errorThemed(context);
    var errorIcon = Icons.error;
    var canRetry = false;

    switch (error.statusCode) {
      case 409:
        if (error.code == 'schedule.child_already_assigned') {
          errorMessage =
              error.message ??
              'This child is already assigned to another vehicle for this time slot.';
          errorColor = AppColors.warningThemed(context);
          errorIcon = Icons.warning_amber_rounded;
          canRetry = true;
        } else {
          errorMessage =
              error.message ??
              'Conflict detected. Please refresh and try again.';
          errorColor = AppColors.warningThemed(context);
          errorIcon = Icons.warning_amber_rounded;
          canRetry = true;
        }
        break;
      case 400:
        errorMessage =
            error.message ?? 'Invalid assignment. Please check your selection.';
        errorIcon = Icons.error_outline;
        break;
      case 403:
        errorMessage =
            'You don\'t have permission to assign children to this vehicle.';
        errorIcon = Icons.block;
        break;
      default:
        errorMessage = error.message ?? 'An error occurred. Please try again.';
    }

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
  }

  void _handleUnassignmentError(dynamic error, BuildContext context) {
    var errorMessage = '';
    var errorColor = AppColors.errorThemed(context);
    var errorIcon = Icons.error;
    var canRetry = false;

    switch (error.statusCode) {
      case 409:
        errorMessage =
            'Assignment changed while editing. Please refresh and try again.';
        errorColor = AppColors.warningThemed(context);
        errorIcon = Icons.warning_amber_rounded;
        canRetry = true;
        break;
      case 400:
        errorMessage = error.message ?? 'Invalid unassignment operation.';
        errorIcon = Icons.error_outline;
        break;
      case 403:
        errorMessage = 'You don\'t have permission to unassign this child.';
        errorIcon = Icons.block;
        break;
      default:
        errorMessage =
            error.message ?? 'Failed to unassign child. Please try again.';
    }

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
  }
}
