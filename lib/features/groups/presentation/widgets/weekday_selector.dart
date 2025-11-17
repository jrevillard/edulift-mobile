import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import '../../../../core/presentation/utils/responsive_breakpoints.dart';
import '../../../../core/presentation/themes/app_colors.dart';

/// Interactive weekday selector with visual indicators
class WeekdaySelector extends StatefulWidget {
  final List<String> selectedDays;
  final ValueChanged<List<String>> onSelectionChanged;
  final bool allowEmpty;

  const WeekdaySelector({
    super.key,
    required this.selectedDays,
    required this.onSelectionChanged,
    this.allowEmpty = false,
  });

  @override
  State<WeekdaySelector> createState() => _WeekdaySelectorState();
}

class _WeekdaySelectorState extends State<WeekdaySelector> {
  static const List<String> _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> _weekdayAbbreviations = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const List<IconData> _weekdayIcons = [
    Icons.work_outline, // Monday
    Icons.work_outline, // Tuesday
    Icons.work_outline, // Wednesday
    Icons.work_outline, // Thursday
    Icons.work_outline, // Friday
    Icons.weekend_outlined, // Saturday
    Icons.weekend_outlined, // Sunday
  ];

  late List<String> _selectedDays;

  @override
  void initState() {
    super.initState();
    _selectedDays = List.from(widget.selectedDays);
  }

  @override
  void didUpdateWidget(WeekdaySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDays != widget.selectedDays) {
      _selectedDays = List.from(widget.selectedDays);
    }
  }

  void _toggleDay(String day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        // Don't allow removing the last day unless allowEmpty is true
        if (!widget.allowEmpty && _selectedDays.length == 1) {
          final l10n = AppLocalizations.of(context);
          _showWarningSnackBar(l10n.atLeastOneDayRequired);
          return;
        }
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
    widget.onSelectionChanged(List.from(_selectedDays));
    HapticFeedback.selectionClick();
  }

  void _selectWeekdays() {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    setState(() {
      _selectedDays = List.from(weekdays);
    });
    widget.onSelectionChanged(List.from(_selectedDays));
    HapticFeedback.lightImpact();
  }

  void _selectWeekends() {
    const weekends = ['Saturday', 'Sunday'];
    setState(() {
      _selectedDays = List.from(weekends);
    });
    widget.onSelectionChanged(List.from(_selectedDays));
    HapticFeedback.lightImpact();
  }

  void _selectAllDays() {
    setState(() {
      _selectedDays = List.from(_weekdays);
    });
    widget.onSelectionChanged(List.from(_selectedDays));
    HapticFeedback.lightImpact();
  }

  void _clearSelection() {
    if (!widget.allowEmpty) {
      final l10n = AppLocalizations.of(context);
      _showWarningSnackBar(l10n.atLeastOneDayRequired);
      return;
    }
    setState(() {
      _selectedDays.clear();
    });
    widget.onSelectionChanged(List.from(_selectedDays));
    HapticFeedback.lightImpact();
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.warningThemed(context),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool _isWeekend(String day) {
    final l10n = AppLocalizations.of(context);
    return day == l10n.saturday || day == l10n.sunday;
  }

  String _getWeekdayAbbreviation(BuildContext context, int index) {
    final l10n = AppLocalizations.of(context);
    switch (index) {
      case 0:
        return l10n.weekdayAbbrevMon;
      case 1:
        return l10n.weekdayAbbrevTue;
      case 2:
        return l10n.weekdayAbbrevWed;
      case 3:
        return l10n.weekdayAbbrevThu;
      case 4:
        return l10n.weekdayAbbrevFri;
      case 5:
        return l10n.weekdayAbbrevSat;
      case 6:
        return l10n.weekdayAbbrevSun;
      default:
        return _weekdayAbbreviations[index];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = context.isTablet;
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.activeScheduleDays,
                  style:
                      (isTablet
                              ? theme.textTheme.headlineSmall
                              : theme.textTheme.titleLarge)
                          ?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: (isTablet ? 26 : 22) * context.fontScale,
                          ),
                ),
              ),
              // Quick selection menu
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  size: context.getAdaptiveIconSize(
                    mobile: 24,
                    tablet: 26,
                    desktop: 28,
                  ),
                ),
                tooltip: l10n.quickSelectionOptions,
                onSelected: (value) {
                  switch (value) {
                    case 'weekdays':
                      _selectWeekdays();
                      break;
                    case 'weekends':
                      _selectWeekends();
                      break;
                    case 'all':
                      _selectAllDays();
                      break;
                    case 'clear':
                      _clearSelection();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'weekdays',
                    child: ListTile(
                      leading: const Icon(Icons.work_outline),
                      title: Text(AppLocalizations.of(context).weekdaysOnly),
                      subtitle: Text(
                        AppLocalizations.of(context).mondayToFridayShort,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'weekends',
                    child: ListTile(
                      leading: const Icon(Icons.weekend_outlined),
                      title: Text(AppLocalizations.of(context).weekendsOnly),
                      subtitle: Text(
                        AppLocalizations.of(context).saturdayToSundayShort,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'all',
                    child: ListTile(
                      leading: const Icon(Icons.select_all),
                      title: Text(AppLocalizations.of(context).allDays),
                      subtitle: Text(
                        AppLocalizations.of(context).allDaysSubtitle,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  if (widget.allowEmpty)
                    PopupMenuItem(
                      value: 'clear',
                      child: ListTile(
                        leading: const Icon(Icons.clear_all),
                        title: Text(AppLocalizations.of(context).clearAll),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                ],
              ),
            ],
          ),

          SizedBox(
            height: context.getAdaptiveSpacing(
              mobile: 8,
              tablet: 10,
              desktop: 12,
            ),
          ),

          // Selection info
          Text(
            l10n.daysSelected(_selectedDays.length),
            style:
                (isTablet
                        ? theme.textTheme.bodyMedium
                        : theme.textTheme.bodySmall)
                    ?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: (isTablet ? 16 : 14) * context.fontScale,
                    ),
          ),

          SizedBox(
            height: context.getAdaptiveSpacing(
              mobile: 24,
              tablet: 28,
              desktop: 32,
            ),
          ),

          // Weekday grid - Allow it to size naturally
          _buildWeekdayGrid(theme),

          SizedBox(
            height: context.getAdaptiveSpacing(
              mobile: 16,
              tablet: 20,
              desktop: 24,
            ),
          ),

          // Selection summary
          _buildSelectionSummary(theme),
        ],
      ),
    );
  }

  Widget _buildWeekdayGrid(ThemeData theme) {
    final isTablet = context.isTablet;
    final isDesktop = context.isDesktop;

    // Responsive grid following established patterns
    final crossAxisCount = context.getGridColumns(
      mobile: 2,
      tablet: 4,
      desktop: 4,
      wide: 7, // Show all days in one row on wide screens
    );

    // Reduced aspect ratios to make cells taller and prevent overflow
    final childAspectRatio = isDesktop ? 2.0 : (isTablet ? 1.2 : 0.95);

    return GridView.builder(
      shrinkWrap: true, // Allow grid to size to content
      physics: const NeverScrollableScrollPhysics(), // Disable grid scrolling
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: context.getAdaptiveSpacing(
          mobile: 12,
          tablet: 16,
          desktop: 20,
        ),
        mainAxisSpacing: context.getAdaptiveSpacing(
          mobile: 12,
          tablet: 16,
          desktop: 20,
        ),
      ),
      itemCount: _weekdays.length,
      itemBuilder: (context, index) {
        final day = _weekdays[index];
        final abbreviation = _getWeekdayAbbreviation(context, index);
        final icon = _weekdayIcons[index];
        final isSelected = _selectedDays.contains(day);
        final isWeekend = _isWeekend(day);

        return InkWell(
          onTap: () => _toggleDay(day),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : theme.colorScheme.surface,
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.dividerColor,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(context.isTablet ? 16 : 12),
            ),
            padding: context.getAdaptivePadding(
              mobileHorizontal: 16,
              mobileVertical: 12,
              tabletHorizontal: 20,
              tabletVertical: 16,
              desktopHorizontal: 24,
              desktopVertical: 18,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  size: context.getAdaptiveIconSize(
                    mobile: 24,
                    tablet: 28,
                    desktop: 32,
                  ),
                ),
                SizedBox(
                  height: context.getAdaptiveSpacing(
                    mobile: 8,
                    tablet: 10,
                    desktop: 12,
                  ),
                ),
                Text(
                  abbreviation,
                  style:
                      (context.isTablet
                              ? theme.textTheme.bodyMedium
                              : theme.textTheme.bodySmall)
                          ?.copyWith(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            fontSize:
                                (context.isTablet ? 14 : 12) *
                                context.fontScale,
                          ),
                ),
                Text(
                  day,
                  style:
                      (context.isTablet
                              ? theme.textTheme.titleMedium
                              : theme.textTheme.bodyLarge)
                          ?.copyWith(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            fontSize:
                                (context.isTablet ? 18 : 16) *
                                context.fontScale,
                          ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isWeekend)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warningThemed(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      AppLocalizations.of(context).weekendLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onTertiaryContainer,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectionSummary(ThemeData theme) {
    final l10n = AppLocalizations.of(context);

    if (_selectedDays.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.warningThemed(context),
          border: Border.all(color: AppColors.warningThemed(context)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning,
              color: Theme.of(context).colorScheme.tertiary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.noDaysSelectedWarning,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Group selected days
    final weekdayCount = _selectedDays.where((day) => !_isWeekend(day)).length;
    final weekendCount = _selectedDays.where((day) => _isWeekend(day)).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.scheduleActive,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          if (weekdayCount > 0) ...[
            Row(
              children: [
                const Icon(Icons.work_outline, size: 16),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).weekdaysCount(weekdayCount),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],

          if (weekendCount > 0) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.weekend_outlined, size: 16),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).weekendDaysCount(weekendCount),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],

          const SizedBox(height: 8),

          // Selected days list - responsive for small screens
          if (_selectedDays.length > 4)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _selectedDays.map((day) {
                  final index = _weekdays.indexOf(day);
                  final abbreviation = _getWeekdayAbbreviation(context, index);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Chip(
                      label: Text(abbreviation),
                      backgroundColor: theme.colorScheme.primary.withValues(
                        alpha: 0.1,
                      ),
                      side: BorderSide(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                      labelStyle: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 12,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                }).toList(),
              ),
            )
          else
            Wrap(
              spacing: _selectedDays.length > 3 ? 6 : 8,
              runSpacing: 4,
              children: _selectedDays.map((day) {
                final index = _weekdays.indexOf(day);
                final abbreviation = _getWeekdayAbbreviation(context, index);
                return Chip(
                  label: Text(abbreviation),
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.1,
                  ),
                  side: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                  labelStyle: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 12,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
