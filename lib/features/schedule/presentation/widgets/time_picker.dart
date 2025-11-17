import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import '../design/schedule_design.dart';
import '../../../../core/presentation/themes/app_colors.dart';
import '../../../../core/services/providers/auth_provider.dart';

/// Hybrid time picker with grid interface and custom time selection
/// Primary: Grid of buttons for common times (30min intervals 6h-22h)
/// Secondary: Custom time button for Flutter's native TimePicker
class ScheduleTimePicker extends ConsumerStatefulWidget {
  final List<String> selectedTimeSlots;
  final ValueChanged<List<String>> onTimeSlotsChanged;
  final int maxSlots;
  final String weekdayLabel;

  const ScheduleTimePicker({
    super.key,
    required this.selectedTimeSlots,
    required this.onTimeSlotsChanged,
    this.maxSlots = 20,
    required this.weekdayLabel,
  });

  @override
  ConsumerState<ScheduleTimePicker> createState() => _ScheduleTimePickerState();
}

class _ScheduleTimePickerState extends ConsumerState<ScheduleTimePicker>
    with TickerProviderStateMixin {
  // Time configuration for hybrid approach
  static const int _startHour = 6; // 6 AM
  static const int _endHour = 22; // 10 PM
  static const int _intervalMinutes = 30; // 30-minute intervals
  static const int _slotsPerHour = 60 ~/ _intervalMinutes; // 2 slots per hour

  // State management
  final Set<String> _selectedTimes = <String>{};
  late AnimationController _selectionAnimController;
  late Animation<double> _selectionAnimation;

  @override
  void initState() {
    super.initState();
    _initializeSelectedTimes();
    _setupAnimations();
  }

  void _setupAnimations() {
    _selectionAnimController = AnimationController(
      duration: ScheduleAnimations.fast,
      vsync: this,
    );
    _selectionAnimation = CurvedAnimation(
      parent: _selectionAnimController,
      curve: ScheduleAnimations.standard,
    );
  }

  void _initializeSelectedTimes() {
    _selectedTimes.clear();
    _selectedTimes.addAll(widget.selectedTimeSlots);
  }

  @override
  void didUpdateWidget(ScheduleTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedTimeSlots != widget.selectedTimeSlots) {
      _initializeSelectedTimes();
    }
  }

  /// Generate list of common times for grid (6:00-22:00, 30min intervals)
  List<String> _generateCommonTimes() {
    final times = <String>[];
    for (var hour = _startHour; hour < _endHour; hour++) {
      for (var slot = 0; slot < _slotsPerHour; slot++) {
        final minutes = slot * _intervalMinutes;
        final timeString =
            '${hour.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
        times.add(timeString);
      }
    }
    return times;
  }

  /// Toggle time selection in grid
  void _toggleTime(String time) {
    if (_selectedTimes.contains(time)) {
      setState(() {
        _selectedTimes.remove(time);
      });
    } else {
      if (_selectedTimes.length >= widget.maxSlots) {
        _showMaxSlotsError();
        return;
      }
      setState(() {
        _selectedTimes.add(time);
      });
    }

    _updateSelectedTimeSlots();
    _triggerSelectionFeedback();
  }

  /// Show native time picker for custom time
  Future<void> _showCustomTimePicker() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).colorScheme.surface,
              hourMinuteTextColor: Theme.of(context).colorScheme.onSurface,
              dialHandColor: Theme.of(context).colorScheme.primary,
              dialBackgroundColor: Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.3),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final timeString =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';

      if (_selectedTimes.contains(timeString)) {
        _showDuplicateTimeError(timeString);
        return;
      }

      if (_selectedTimes.length >= widget.maxSlots) {
        _showMaxSlotsError();
        return;
      }

      setState(() {
        _selectedTimes.add(timeString);
      });

      _updateSelectedTimeSlots();
      _triggerSelectionFeedback();
    }
  }

  void _updateSelectedTimeSlots() {
    final sortedTimes = _selectedTimes.toList()..sort();
    widget.onTimeSlotsChanged(sortedTimes);
  }

  void _triggerSelectionFeedback() {
    HapticFeedback.lightImpact();
    _selectionAnimController.forward().then((_) {
      _selectionAnimController.reverse();
    });
  }

  void _showMaxSlotsError() {
    final l10n = AppLocalizations.of(context);
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.maximumTimeSlotsAllowed(widget.maxSlots)),
        backgroundColor: AppColors.errorThemed(context),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDuplicateTimeError(String time) {
    final l10n = AppLocalizations.of(context);
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.timeAlreadySelected(time)),
        backgroundColor: AppColors.warningThemed(context),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clearAllTimes() {
    setState(() {
      _selectedTimes.clear();
    });

    _updateSelectedTimeSlots();
    _triggerSelectionFeedback();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final commonTimes = _generateCommonTimes();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    // Detect small screens including Oppo Find X2 Neo (360x800)
    final isSmallScreen = screenHeight < 700 || screenWidth < 380;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        _buildHeader(theme, l10n),

        // Grid and custom time picker
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildGridHeader(theme, l10n),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  Flexible(child: _buildTimeGrid(theme, commonTimes)),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  _buildCustomTimeButton(theme, l10n),
                ],
              ),
            ),
          ),
        ),

        // Status footer
        _buildStatusFooter(theme, l10n),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    // Get user timezone for display
    final currentUser = ref.watch(currentUserProvider);
    final userTimezone = currentUser?.timezone;
    // Show timezone name instead of offset since times are already in user timezone
    final timezoneDisplay = userTimezone ?? 'UTC';
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    // Detect small screens including Oppo Find X2 Neo (360x800)
    final isSmallScreen = screenHeight < 700 || screenWidth < 380;

    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.configureWeekdaySchedule(widget.weekdayLabel),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: isSmallScreen ? 20 : null,
            ),
          ),
          SizedBox(height: isSmallScreen ? 4 : 8),

          // Enhanced instruction with visual cues + timezone indicator
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.touch_app,
                      size: isSmallScreen ? 16 : 20,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: isSmallScreen ? 6 : 8),
                    Expanded(
                      child: Text(
                        l10n.timePickerInstructions,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.8,
                          ),
                          fontSize: isSmallScreen ? 12 : null,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 2 : 4),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: isSmallScreen ? 14 : 16,
                      color: theme.colorScheme.primary.withValues(alpha: 0.7),
                    ),
                    SizedBox(width: isSmallScreen ? 3 : 4),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(
                          context,
                        ).timesShownInTimezone(timezoneDisplay),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                          fontSize: isSmallScreen ? 10 : 11,
                          fontStyle: FontStyle.italic,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 16),

          // Clear all button
          ElevatedButton.icon(
            onPressed: _selectedTimes.isNotEmpty ? _clearAllTimes : null,
            icon: Icon(Icons.clear_all, size: isSmallScreen ? 16 : 18),
            label: Text(l10n.clearAll),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorThemed(
                context,
              ).withValues(alpha: 0.1),
              foregroundColor: AppColors.errorThemed(context),
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 6 : 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridHeader(ThemeData theme, AppLocalizations l10n) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use shorter text on very small screens
        final isVerySmallScreen = constraints.maxWidth < 300;
        final headerText = isVerySmallScreen
            ? 'Times'
            : l10n.commonDepartureTimes;

        return Row(
          children: [
            Expanded(
              child: Text(
                headerText,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (!isVerySmallScreen) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_selectedTimes.length}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_selectedTimes.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildTimeGrid(ThemeData theme, List<String> commonTimes) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 4 columns for good mobile layout
        childAspectRatio: 2.0, // Balanced ratio for ≥48dp touch target
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: commonTimes.length,
      itemBuilder: (context, index) {
        final time = commonTimes[index];
        final isSelected = _selectedTimes.contains(time);

        // Times are already in user's timezone (generated by _generateCommonTimes)
        // No conversion needed - display as-is
        final displayTime = time;

        return AnimatedContainer(
          duration: ScheduleAnimations.getDuration(
            context,
            ScheduleAnimations.fast,
          ),
          child: Material(
            color: isSelected
                ? theme.colorScheme.primary.withValues(
                    alpha: 0.8 + (_selectionAnimation.value * 0.2),
                  )
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            elevation: isSelected ? 2 : 0,
            child: InkWell(
              onTap: () => _toggleTime(time),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    displayTime,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomTimeButton(ThemeData theme, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _showCustomTimePicker,
        icon: const Icon(Icons.access_time, size: 20),
        label: Text(l10n.customTime),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
          foregroundColor: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildStatusFooter(ThemeData theme, AppLocalizations l10n) {
    final selectedCount = _selectedTimes.length;
    final hasSelection = selectedCount > 0;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    // Detect small screens including Oppo Find X2 Neo (360x800)
    final isSmallScreen = screenHeight < 700 || screenWidth < 380;

    String getTimeRangeText() {
      if (_selectedTimes.isEmpty) return l10n.noDepartureTimesSelected;

      return l10n.departureTimesSelected(selectedCount);
    }

    return AnimatedContainer(
      duration: ScheduleAnimations.getDuration(
        context,
        ScheduleAnimations.normal,
      ),
      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
      decoration: BoxDecoration(
        color: hasSelection
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: hasSelection
                ? theme.colorScheme.primary.withValues(alpha: 0.3)
                : theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                hasSelection ? Icons.schedule : Icons.info_outline,
                size: isSmallScreen ? 14 : 16,
                color: hasSelection
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Expanded(
                child: Text(
                  getTimeRangeText(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: hasSelection
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: hasSelection
                        ? FontWeight.w600
                        : FontWeight.normal,
                    fontSize: isSmallScreen ? 12 : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasSelection) ...[
                Icon(
                  selectedCount == widget.maxSlots
                      ? Icons.warning
                      : Icons.check_circle,
                  size: isSmallScreen ? 14 : 16,
                  color: selectedCount == widget.maxSlots
                      ? AppColors.warningThemed(context)
                      : AppColors.successThemed(context),
                ),
              ],
            ],
          ),
          if (hasSelection) ...[
            SizedBox(height: isSmallScreen ? 4 : 8),
            // Selected times as chips - limit height to prevent overflow
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: isSmallScreen ? 40 : 60),
              child: Wrap(
                spacing: isSmallScreen ? 4 : 6,
                runSpacing: 2,
                children: (_selectedTimes.toList()..sort())
                    .take(isSmallScreen ? 6 : 8) // Limit chips on small screen
                    .map((time) {
                      // Times are already in user's timezone - display as-is
                      final displayTime = time;

                      return Chip(
                        label: Text(
                          displayTime,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: isSmallScreen ? 9 : 10,
                          ),
                        ),
                        backgroundColor: theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.5),
                        deleteIcon: Icon(
                          Icons.close,
                          size: isSmallScreen ? 12 : 14,
                        ),
                        onDeleted: () => _toggleTime(time),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 6 : 8,
                          vertical: isSmallScreen ? 2 : 4,
                        ),
                      );
                    })
                    .toList(),
              ),
            ),
            if (_selectedTimes.length >
                (isSmallScreen ? 6 : 8)) // Show indicator if more items
              Padding(
                padding: EdgeInsets.only(top: isSmallScreen ? 2 : 4),
                child: Text(
                  '+${_selectedTimes.length - (isSmallScreen ? 6 : 8)} more...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: isSmallScreen ? 9 : 10,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _selectionAnimController.dispose();
    super.dispose();
  }
}
