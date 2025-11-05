import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import 'time_picker.dart';

/// Widget for configuring departure hours for a specific day
class PerDayTimeSlotConfig extends StatefulWidget {
  final String weekday;
  final String weekdayLabel;
  final List<String> timeSlots;
  final ValueChanged<List<String>> onTimeSlotsChanged;
  final int maxSlots;
  final int minIntervalMinutes;
  final VoidCallback? onAddTimeSlotRequested;

  const PerDayTimeSlotConfig({
    super.key,
    required this.weekday,
    required this.weekdayLabel,
    required this.timeSlots,
    required this.onTimeSlotsChanged,
    this.maxSlots = 20,
    this.minIntervalMinutes = 15,
    this.onAddTimeSlotRequested,
  });

  @override
  State<PerDayTimeSlotConfig> createState() => _PerDayTimeSlotConfigState();

  /// Check if more departure hours can be added
  bool canAddDepartureHour() {
    return timeSlots.length < maxSlots;
  }

  /// Get current departure hour count for context-aware FAB
  int get currentDepartureHourCount => timeSlots.length;
}

class _PerDayTimeSlotConfigState extends State<PerDayTimeSlotConfig> {
  late List<String> _workingSlots;

  /// Public method to add departure hour (called from unified FAB)
  void addDepartureHour() {
    _addDepartureHour();
  }

  @override
  void initState() {
    super.initState();
    _workingSlots = List.from(widget.timeSlots);
    _sortTimeSlots();
  }

  @override
  void didUpdateWidget(PerDayTimeSlotConfig oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timeSlots != widget.timeSlots) {
      _workingSlots = List.from(widget.timeSlots);
      _sortTimeSlots();
    }
  }

  void _addDepartureHour() {
    if (_workingSlots.length >= widget.maxSlots) {
      _showErrorSnackBar(
        AppLocalizations.of(context).maximumTimeSlotsAllowed(widget.maxSlots),
      );
      return;
    }

    _showModernDepartureHourPicker();
  }

  void _editDepartureHour(int index) {
    _showModernDepartureHourPicker();
  }

  void _deleteDepartureHour(int index) {
    setState(() {
      _workingSlots.removeAt(index);
      _sortTimeSlots();
    });
    widget.onTimeSlotsChanged(_workingSlots);
  }

  void _sortTimeSlots() {
    _workingSlots.sort((a, b) => a.compareTo(b));
  }

  void _showModernDepartureHourPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.7,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => ScheduleTimePicker(
          selectedTimeSlots: List.from(_workingSlots),
          weekdayLabel: widget.weekdayLabel,
          maxSlots: widget.maxSlots,
          onTimeSlotsChanged: (newTimeSlots) {
            setState(() {
              _workingSlots = List.from(newTimeSlots);
              _sortTimeSlots();
            });
            widget.onTimeSlotsChanged(_workingSlots);
            HapticFeedback.lightImpact();
          },
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    // Detect small screens including Oppo Find X2 Neo (360x800)
    final isSmallScreen = screenHeight < 700 || screenWidth < 380;

    // Use SingleChildScrollView for small screens to prevent overflow
    if (isSmallScreen) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header - simplified without scattered add button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  '${widget.weekdayLabel} ${AppLocalizations.of(context).departureHours}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),

              // Usage info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  AppLocalizations.of(context).slotsConfigured(
                    _workingSlots.length,
                    widget.maxSlots,
                    _workingSlots.length,
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Time slots content - no Expanded for small screens
              if (_workingSlots.isEmpty)
                _buildEmptyState(theme)
              else
                _buildTimeSlotsList(theme),

              // Add bottom padding for scroll space
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    }

    // Original layout for larger screens
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header - simplified without scattered add button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '${widget.weekdayLabel} ${AppLocalizations.of(context).departureHours}',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Usage info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppLocalizations.of(context).slotsConfigured(
              _workingSlots.length,
              widget.maxSlots,
              _workingSlots.length,
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Time slots content
        Expanded(
          child: _workingSlots.isEmpty
              ? _buildEmptyState(theme)
              : _buildTimeSlotsList(theme),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    final iconSize = isSmallScreen ? 60.0 : 80.0;
    final spacing = isSmallScreen ? 16.0 : 24.0;
    final padding = isSmallScreen ? 16.0 : 24.0;

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: isSmallScreen ? 100 : 150),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.schedule_outlined,
                  size: iconSize,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                SizedBox(height: spacing),
                Text(
                  AppLocalizations.of(context).noTimeSlotsConfigured,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 16 : null,
                  ),
                ),
                SizedBox(height: spacing * 0.5),
                Text(
                  AppLocalizations.of(context).tapToAddFirstTimeSlot,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: isSmallScreen ? 14 : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlotsList(ThemeData theme) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    if (isSmallScreen) {
      // For small screens, use Column to avoid ListView height constraints
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: _workingSlots.asMap().entries.map((entry) {
            final index = entry.key;
            final timeSlot = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                dense: true,
                leading: Icon(
                  Icons.schedule,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                title: Text(
                  timeSlot,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _editDepartureHour(index),
                      icon: const Icon(Icons.edit, size: 20),
                      tooltip: AppLocalizations.of(context).editTime,
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      onPressed: () => _deleteDepartureHour(index),
                      icon: const Icon(Icons.delete, size: 20),
                      tooltip: AppLocalizations.of(context).deleteTime,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
    }

    // Original ListView for larger screens
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight:
            MediaQuery.of(context).size.height *
            0.6, // Max 60% of screen height
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _workingSlots.length,
        itemBuilder: (context, index) {
          final timeSlot = _workingSlots[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(Icons.schedule, color: theme.colorScheme.primary),
              title: Text(
                timeSlot,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _editDepartureHour(index),
                    icon: const Icon(Icons.edit),
                    tooltip: AppLocalizations.of(context).editTime,
                  ),
                  IconButton(
                    onPressed: () => _deleteDepartureHour(index),
                    icon: const Icon(Icons.delete),
                    tooltip: AppLocalizations.of(context).deleteTime,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
