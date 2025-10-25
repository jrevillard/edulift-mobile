import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/config_time_slot.dart';
import '../../../../core/presentation/utils/responsive_breakpoints.dart';
import '../../../../core/presentation/themes/app_colors.dart';
import '/generated/l10n/app_localizations.dart';
import '../../../../core/utils/timezone_formatter.dart';
import '../../../../core/services/providers/auth_provider.dart';

/// Interactive time slot grid with drag-and-drop and validation
class TimeSlotGrid extends ConsumerStatefulWidget {
  final List<ConfigTimeSlot> timeSlots;
  final ValueChanged<List<ConfigTimeSlot>> onTimeSlotsChanged;
  final int maxSlots;
  final int minIntervalMinutes;

  const TimeSlotGrid({
    super.key,
    required this.timeSlots,
    required this.onTimeSlotsChanged,
    this.maxSlots = 20,
    this.minIntervalMinutes = 15,
  });

  @override
  ConsumerState<TimeSlotGrid> createState() => _TimeSlotGridState();
}

class _TimeSlotGridState extends ConsumerState<TimeSlotGrid> {
  late List<ConfigTimeSlot> _workingSlots;
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _labelController = TextEditingController();
  String? _validationError;
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _workingSlots = List.from(widget.timeSlots);
  }

  @override
  void didUpdateWidget(TimeSlotGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timeSlots != widget.timeSlots) {
      _workingSlots = List.from(widget.timeSlots);
    }
  }

  void _addTimeSlot() {
    if (_workingSlots.length >= widget.maxSlots) {
      _showErrorSnackBar(
        AppLocalizations.of(context).maximumTimeSlotsAllowed(widget.maxSlots),
      );
      return;
    }

    setState(() {
      _editingIndex = _workingSlots.length;
      _timeController.clear();
      _labelController.clear();
      _validationError = null;
    });

    _showAddTimeSlotDialog();
  }

  void _editTimeSlot(int index) {
    final slot = _workingSlots[index];
    setState(() {
      _editingIndex = index;
      _timeController.text = slot.time;
      _labelController.text = slot.label;
      _validationError = null;
    });

    _showAddTimeSlotDialog();
  }

  void _deleteTimeSlot(int index) {
    setState(() {
      _workingSlots.removeAt(index);
      _sortTimeSlots();
    });
    widget.onTimeSlotsChanged(_workingSlots);
  }

  void _toggleTimeSlot(int index) {
    setState(() {
      _workingSlots[index] = _workingSlots[index].copyWith(
        isActive: !_workingSlots[index].isActive,
      );
    });
    widget.onTimeSlotsChanged(_workingSlots);
  }

  void _sortTimeSlots() {
    _workingSlots.sort((a, b) => a.time.compareTo(b.time));
  }

  String? _validateTimeSlot(String time, String label) {
    // Validate time format
    if (!RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(time)) {
      return AppLocalizations.of(context).invalidTimeFormat;
    }

    // Parse time
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    // Validate 15-minute intervals
    if (minute % 15 != 0) {
      return AppLocalizations.of(context).timeIntervalError;
    }

    // Check for duplicate times (excluding current editing slot)
    for (var i = 0; i < _workingSlots.length; i++) {
      if (i == _editingIndex) continue;
      if (_workingSlots[i].time == time) {
        return AppLocalizations.of(context).timeSlotExists;
      }
    }

    // Validate label
    if (label.trim().isEmpty) {
      return AppLocalizations.of(context).labelRequired;
    }

    if (label.length > 50) {
      return AppLocalizations.of(context).labelTooLong;
    }

    // Check minimum interval with existing slots
    final newTime = DateTime(2000, 1, 1, hour, minute);
    for (var i = 0; i < _workingSlots.length; i++) {
      if (i == _editingIndex) continue;

      final existingSlot = _workingSlots[i];
      final existingParts = existingSlot.time.split(':');
      final existingTime = DateTime(
        2000,
        1,
        1,
        int.parse(existingParts[0]),
        int.parse(existingParts[1]),
      );

      final diffMinutes = (newTime.difference(existingTime).inMinutes).abs();
      if (diffMinutes < widget.minIntervalMinutes) {
        return AppLocalizations.of(
          context,
        ).minimumIntervalRequired(widget.minIntervalMinutes);
      }
    }

    return null;
  }

  void _saveTimeSlot() {
    final time = _timeController.text.trim();
    final label = _labelController.text.trim();

    final error = _validateTimeSlot(time, label);
    if (error != null) {
      setState(() {
        _validationError = error;
      });
      return;
    }

    final newSlot = ConfigTimeSlot(time: time, label: label, isActive: true);

    setState(() {
      if (_editingIndex! < _workingSlots.length) {
        // Editing existing slot
        _workingSlots[_editingIndex!] = newSlot;
      } else {
        // Adding new slot
        _workingSlots.add(newSlot);
      }
      _sortTimeSlots();
      _editingIndex = null;
      _validationError = null;
    });

    Navigator.of(context).pop();
    widget.onTimeSlotsChanged(_workingSlots);
    HapticFeedback.lightImpact();
  }

  void _showAddTimeSlotDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          contentPadding: context.getAdaptivePadding(
            mobileAll: 16,
            tabletAll: 20,
            desktopAll: 24,
          ),
          title: Text(
            _editingIndex! < _workingSlots.length
                ? l10n.editTimeSlot
                : l10n.addTimeSlot,
            style: TextStyle(fontSize: 20 * context.fontScale),
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.isDesktop ? 400 : 300,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Time input
                TextFormField(
                  controller: _timeController,
                  decoration: InputDecoration(
                    labelText: l10n.timeLabel,
                    hintText: l10n.timeHint,
                    prefixIcon: const Icon(Icons.access_time),
                  ),
                  keyboardType: TextInputType.datetime,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                    LengthLimitingTextInputFormatter(5),
                    _TimeInputFormatter(),
                  ],
                  autofocus: true,
                ),

                const SizedBox(height: 16),

                // Label input
                TextFormField(
                  controller: _labelController,
                  decoration: InputDecoration(
                    labelText: l10n.labelFieldLabel,
                    hintText: l10n.labelHint,
                    prefixIcon: const Icon(Icons.label),
                  ),
                  maxLength: 50,
                  textCapitalization: TextCapitalization.words,
                ),

                // Validation error
                if (_validationError != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer(context),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.errorThemed(context)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error,
                          color: AppColors.errorThemed(context),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _validationError!,
                            style: TextStyle(
                              color: AppColors.onErrorContainer(context),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _editingIndex = null;
                  _validationError = null;
                });
                Navigator.of(context).pop();
              },
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                setDialogState(() {
                  _saveTimeSlot();
                });
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorThemed(context),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header with add button
        Row(
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(context).configureTimeSlots,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed:
                  _workingSlots.length < widget.maxSlots ? _addTimeSlot : null,
              icon: Icon(
                Icons.add,
                size: context.getAdaptiveIconSize(
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                ),
              ),
              label: Text(AppLocalizations.of(context).addSlot),
              style: ElevatedButton.styleFrom(
                padding: context.getAdaptivePadding(
                  mobileHorizontal: 12,
                  mobileVertical: 6,
                  tabletHorizontal: 16,
                  tabletVertical: 8,
                  desktopHorizontal: 20,
                  desktopVertical: 10,
                ),
                minimumSize: Size(
                  context.getAdaptiveSpacing(
                    mobile: 120,
                    tablet: 140,
                    desktop: 160,
                  ),
                  context.getAdaptiveButtonHeight(
                    mobile: 40,
                    tablet: 44,
                    desktop: 48,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Usage info
        Text(
          AppLocalizations.of(context).slotsConfigured(
            _workingSlots.length,
            widget.maxSlots,
            _workingSlots.where((s) => s.isActive).length,
          ),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),

        const SizedBox(height: 16),

        // Time slots grid
        Expanded(
          child: _workingSlots.isEmpty
              ? _buildEmptyState(theme)
              : _buildTimeSlotsList(theme),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule_outlined,
            size: 80,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).noTimeSlotsConfigured,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).addTimeSlotsDescription,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addTimeSlot,
            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context).addFirstTimeSlot),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotsList(ThemeData theme) {
    // Use responsive grid layout for better utilization of space
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = context.getGridColumns(
          mobile: 1,
          tablet: 2,
          desktop: 3,
          wide: 4,
        );

        if (columns == 1) {
          // Single column layout for mobile
          return ListView.builder(
            itemCount: _workingSlots.length,
            itemBuilder: (context, index) {
              final slot = _workingSlots[index];
              return _buildTimeSlotCard(slot, index, theme);
            },
          );
        } else {
          // Grid layout for tablet and desktop
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: context.getAdaptiveSpacing(
                mobile: 8,
                tablet: 12,
                desktop: 16,
              ),
              mainAxisSpacing: context.getAdaptiveSpacing(
                mobile: 8,
                tablet: 12,
                desktop: 16,
              ),
              childAspectRatio: context.isDesktop ? 2.5 : 2.0,
            ),
            itemCount: _workingSlots.length,
            itemBuilder: (context, index) {
              final slot = _workingSlots[index];
              return _buildTimeSlotCard(slot, index, theme);
            },
          );
        }
      },
    );
  }

  Widget _buildTimeSlotCard(ConfigTimeSlot slot, int index, ThemeData theme) {
    // Get user timezone and convert time for display
    final currentUser = ref.watch(currentUserProvider);
    final userTimezone = currentUser?.timezone;
    final displayTime = TimezoneFormatter.formatTimeSlot(
      slot.time,
      userTimezone,
    );

    return Card(
      margin: EdgeInsets.only(
        bottom: context.getAdaptiveSpacing(mobile: 6, tablet: 8, desktop: 12),
      ),
      child: ListTile(
        contentPadding: context.getAdaptivePadding(
          mobileHorizontal: 12,
          mobileVertical: 8,
          tabletHorizontal: 16,
          tabletVertical: 12,
          desktopHorizontal: 20,
          desktopVertical: 16,
        ),
        leading: CircleAvatar(
          radius: context.getAdaptiveIconSize(
            mobile: 18,
            tablet: 20,
            desktop: 22,
          ),
          backgroundColor: slot.isActive
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
          child: Icon(
            Icons.access_time,
            color: slot.isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.5),
            size: context.getAdaptiveIconSize(
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
          ),
        ),
        title: Text(
          displayTime,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16 * context.fontScale,
            color: slot.isActive
                ? null
                : theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        subtitle: Text(
          slot.label,
          style: TextStyle(
            fontSize: 14 * context.fontScale,
            color: slot.isActive
                ? null
                : theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Active toggle
            Switch(
              value: slot.isActive,
              onChanged: (_) => _toggleTimeSlot(index),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),

            // Edit button
            IconButton(
              onPressed: () => _editTimeSlot(index),
              icon: const Icon(Icons.edit, size: 20),
              tooltip: AppLocalizations.of(context).editTimeSlotTooltip,
            ),

            // Delete button
            IconButton(
              onPressed: () => _deleteTimeSlot(index),
              icon: const Icon(Icons.delete, size: 20),
              color: AppColors.errorThemed(context),
              tooltip: AppLocalizations.of(context).deleteTimeSlotTooltip,
            ),
          ],
        ),
        onTap: () => _editTimeSlot(index),
      ),
    );
  }

  @override
  void dispose() {
    _timeController.dispose();
    _labelController.dispose();
    super.dispose();
  }
}

/// Custom input formatter for time (HH:MM)
class _TimeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.length <= 2) {
      return newValue;
    }

    if (text.length == 3 && !text.contains(':')) {
      return TextEditingValue(
        text: '${text.substring(0, 2)}:${text.substring(2)}',
        selection: const TextSelection.collapsed(offset: 4),
      );
    }

    if (text.length > 5) {
      return oldValue;
    }

    return newValue;
  }
}
