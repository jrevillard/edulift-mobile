import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulift/core/presentation/widgets/accessibility/accessible_button.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import 'package:edulift/core/utils/timezone_formatter.dart';
import 'package:edulift/core/services/providers/auth_provider.dart';

/// Schedule coordination screen with real-time updates and accessibility
class ScheduleCoordinationScreen extends ConsumerStatefulWidget {
  const ScheduleCoordinationScreen({super.key});

  @override
  ConsumerState<ScheduleCoordinationScreen> createState() =>
      _ScheduleCoordinationScreenState();
}

class _ScheduleCoordinationScreenState
    extends ConsumerState<ScheduleCoordinationScreen>
    with TickerProviderStateMixin {
  late AnimationController _refreshController;
  late Animation<double> _refreshAnimation;

  DateTime _selectedDate = DateTime.now();
  ScheduleView _currentView = ScheduleView.day;
  bool _isLoading = false;
  bool _hasConflicts = false;

  // Sample schedule data
  final List<ScheduleEvent> _events = [
    ScheduleEvent(
      id: '1',
      title: 'School Drop-off - Emma',
      startTime: DateTime.now().copyWith(hour: 8, minute: 0),
      endTime: DateTime.now().copyWith(hour: 8, minute: 30),
      type: ScheduleEventType.dropoff,
      childId: '1',
      childName: 'Emma Johnson',
      driverId: '1',
      driverName: 'Sarah Johnson',
      vehicleId: '1',
      vehicleName: 'Family SUV',
      location: 'Riverside Elementary School',
      status: ScheduleEventStatus.confirmed,
    ),
    ScheduleEvent(
      id: '2',
      title: 'Soccer Practice - Lucas',
      startTime: DateTime.now().copyWith(hour: 16, minute: 0),
      endTime: DateTime.now().copyWith(hour: 17, minute: 30),
      type: ScheduleEventType.activity,
      childId: '2',
      childName: 'Lucas Johnson',
      driverId: '2',
      driverName: 'Mike Johnson',
      vehicleId: '2',
      vehicleName: 'Compact Car',
      location: 'Central Park Soccer Field',
      status: ScheduleEventStatus.pending,
      hasConflict: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _refreshAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _refreshController, curve: Curves.easeInOut),
    );
    _checkForConflicts();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _checkForConflicts() {
    setState(() {
      _hasConflicts = _events.any((event) => event.hasConflict);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).scheduleCoordination),
        elevation: 0,
        actions: [
          if (_hasConflicts)
            AccessibleIconButton(
              onPressed: _showConflictResolution,
              icon: Badge(
                backgroundColor: colorScheme.error,
                child: const Icon(Icons.warning),
              ),
              semanticLabel: 'View schedule conflicts',
              tooltip: AppLocalizations.of(context).resolveScheduleConflicts,
            ),
          AccessibleIconButton(
            onPressed: _refreshSchedule,
            icon: AnimatedBuilder(
              animation: _refreshAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _refreshAnimation.value * 2 * 3.14159,
                  child: const Icon(Icons.refresh),
                );
              },
            ),
            semanticLabel: AppLocalizations.of(context).refreshSchedule,
            tooltip: AppLocalizations.of(context).refreshSchedule,
          ),
          AccessibleIconButton(
            onPressed: _showFilterOptions,
            icon: const Icon(Icons.filter_list),
            semanticLabel: 'Filter schedule',
            tooltip: AppLocalizations.of(context).filterAndSortOptions,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size(double.infinity, 120),
          child: Column(
            children: [
              _buildDateSelector(theme, colorScheme),
              _buildViewSelector(theme, colorScheme),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          if (_hasConflicts) _buildConflictBanner(theme, colorScheme),
          Expanded(child: _buildScheduleView(theme, colorScheme)),
        ],
      ),
      floatingActionButton: AccessibleFloatingActionButton(
        onPressed: _showAddEventDialog,
        semanticLabel: 'Add new schedule event',
        semanticHint: 'Tap to create a new transportation event',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDateSelector(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          AccessibleIconButton(
            onPressed: _previousDate,
            icon: const Icon(Icons.chevron_left),
            semanticLabel: 'Previous day',
          ),
          Expanded(
            child: Center(
              child: Semantics(
                label: 'Selected date: ${_formatDate(_selectedDate)}',
                hint: 'Tap to open date picker',
                child: InkWell(
                  onTap: _showDatePicker,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      _formatDate(_selectedDate),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
          AccessibleIconButton(
            onPressed: _nextDate,
            icon: const Icon(Icons.chevron_right),
            semanticLabel: 'Next day',
          ),
        ],
      ),
    );
  }

  Widget _buildViewSelector(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<ScheduleView>(
              segments: [
                ButtonSegment(
                  value: ScheduleView.day,
                  label: Text(AppLocalizations.of(context).dayLabel),
                  icon: const Icon(Icons.today),
                ),
                ButtonSegment(
                  value: ScheduleView.week,
                  label: Text(AppLocalizations.of(context).weekLabel),
                  icon: const Icon(Icons.view_week),
                ),
                ButtonSegment(
                  value: ScheduleView.month,
                  label: Text(AppLocalizations.of(context).monthLabel),
                  icon: const Icon(Icons.calendar_month),
                ),
              ],
              selected: {_currentView},
              onSelectionChanged: (selection) {
                setState(() {
                  _currentView = selection.first;
                });
                HapticFeedback.selectionClick();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConflictBanner(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      color: colorScheme.errorContainer,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(Icons.warning, color: colorScheme.onErrorContainer, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Schedule conflicts detected. Tap to resolve.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          AccessibleIconButton(
            onPressed: _showConflictResolution,
            icon: Icon(
              Icons.chevron_right,
              color: colorScheme.onErrorContainer,
            ),
            semanticLabel: 'View conflict details',
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleView(ThemeData theme, ColorScheme colorScheme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (_currentView) {
      case ScheduleView.day:
        return _buildDayView(theme, colorScheme);
      case ScheduleView.week:
        return _buildWeekView(theme, colorScheme);
      case ScheduleView.month:
        return _buildMonthView(theme, colorScheme);
    }
  }

  Widget _buildDayView(ThemeData theme, ColorScheme colorScheme) {
    final dayEvents = _events.where((event) {
      return event.startTime.day == _selectedDate.day &&
          event.startTime.month == _selectedDate.month &&
          event.startTime.year == _selectedDate.year;
    }).toList();

    dayEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
    if (dayEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 64,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No events scheduled',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add a new event',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dayEvents.length,
      itemBuilder: (context, index) {
        final event = dayEvents[index];
        return _buildEventCard(event, theme, colorScheme);
      },
    );
  }

  Widget _buildWeekView(ThemeData theme, ColorScheme colorScheme) {
    // Simplified week view - would be more complex in real implementation
    return Center(
      child: Text(AppLocalizations.of(context).weekViewImplementation),
    );
  }

  Widget _buildMonthView(ThemeData theme, ColorScheme colorScheme) {
    // Simplified month view - would be more complex in real implementation
    return Center(
      child: Text(AppLocalizations.of(context).monthViewImplementation),
    );
  }

  Widget _buildEventCard(
    ScheduleEvent event,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final hasConflict = event.hasConflict;
    final cardColor = hasConflict
        ? colorScheme.errorContainer
        : _getEventTypeColor(event.type, colorScheme);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: cardColor,
      child: Semantics(
        label: '${event.title} at ${_formatTime(event.startTime)}',
        hint: hasConflict
            ? 'Conflict detected. Tap to resolve.'
            : 'Tap to view details and edit',
        child: InkWell(
          onTap: () => _showEventDetails(event),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event header
                Row(
                  children: [
                    Icon(
                      _getEventTypeIcon(event.type),
                      color: hasConflict
                          ? colorScheme.onErrorContainer
                          : colorScheme.onSurface,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: hasConflict
                              ? colorScheme.onErrorContainer
                              : null,
                        ),
                      ),
                    ),
                    if (hasConflict)
                      Icon(Icons.warning, color: colorScheme.error, size: 20),
                    _buildStatusChip(event.status, theme, colorScheme),
                  ],
                ),
                const SizedBox(height: 8),

                // Time and location
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: hasConflict
                            ? colorScheme.onErrorContainer.withValues(
                                alpha: 0.8,
                              )
                            : colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: hasConflict
                              ? colorScheme.onErrorContainer.withValues(
                                  alpha: 0.8,
                                )
                              : colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Driver and vehicle info
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 16,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event.driverName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: hasConflict
                                  ? colorScheme.onErrorContainer.withValues(
                                      alpha: 0.8,
                                    )
                                  : colorScheme.onSurface.withValues(
                                      alpha: 0.7,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.directions_car,
                          size: 16,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event.vehicleName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: hasConflict
                                ? colorScheme.onErrorContainer.withValues(
                                    alpha: 0.8,
                                  )
                                : colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                if (hasConflict) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: colorScheme.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 14,
                          color: colorScheme.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Vehicle double-booked',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(
    ScheduleEventStatus status,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case ScheduleEventStatus.confirmed:
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green[700]!;
        label = 'Confirmed';
        break;
      case ScheduleEventStatus.pending:
        backgroundColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange[700]!;
        label = 'Pending';
        break;
      case ScheduleEventStatus.cancelled:
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red[700]!;
        label = 'Cancelled';
        break;
    }

    return Chip(
      label: Text(label),
      backgroundColor: backgroundColor,
      labelStyle: TextStyle(
        color: textColor,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Color _getEventTypeColor(ScheduleEventType type, ColorScheme colorScheme) {
    switch (type) {
      case ScheduleEventType.dropoff:
        return colorScheme.primaryContainer;
      case ScheduleEventType.pickup:
        return colorScheme.secondaryContainer;
      case ScheduleEventType.activity:
        return colorScheme.tertiaryContainer;
    }
  }

  IconData _getEventTypeIcon(ScheduleEventType type) {
    switch (type) {
      case ScheduleEventType.dropoff:
        return Icons.school;
      case ScheduleEventType.pickup:
        return Icons.home;
      case ScheduleEventType.activity:
        return Icons.sports_soccer;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return 'Today';
    } else if (date.day == now.add(const Duration(days: 1)).day &&
        date.month == now.add(const Duration(days: 1)).month &&
        date.year == now.add(const Duration(days: 1)).year) {
      return 'Tomorrow';
    } else if (date.day == now.subtract(const Duration(days: 1)).day &&
        date.month == now.subtract(const Duration(days: 1)).month &&
        date.year == now.subtract(const Duration(days: 1)).year) {
      return 'Yesterday';
    } else {
      final weekday = [
        '',
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ][date.weekday];
      final month = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ][date.month];
      return '$weekday, $month ${date.day}';
    }
  }

  String _formatTime(DateTime time) {
    // Get user timezone
    final currentUser = ref.read(currentUserProvider);
    final userTimezone = currentUser?.timezone;

    // Convert UTC time to user's timezone
    final displayTime = TimezoneFormatter.formatTimeOnly(time, userTimezone);

    // Parse to add AM/PM format
    try {
      final parts = displayTime.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = parts[1];
        final ampm = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '$displayHour:$minute $ampm';
      }
    } catch (e) {
      // If parsing fails, return the formatted time as-is
      return displayTime;
    }

    return displayTime;
  }

  void _previousDate() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
    HapticFeedback.selectionClick();
  }

  void _nextDate() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
    HapticFeedback.selectionClick();
  }

  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _refreshSchedule() async {
    await _refreshController.forward();
    setState(() {
      _isLoading = true;
    });
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
    _refreshController.reset();
    // Show feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).scheduleRefreshed),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _showConflictResolution() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ConflictResolutionSheet(),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const FilterOptionsSheet(),
    );
  }

  void _showAddEventDialog() {
    showDialog(context: context, builder: (context) => const AddEventDialog());
  }

  void _showEventDetails(ScheduleEvent event) {
    Navigator.pushNamed(context, '/event-details', arguments: event);
  }
}

// Enums and data classes
enum ScheduleView { day, week, month }

enum ScheduleEventType { dropoff, pickup, activity }

enum ScheduleEventStatus { confirmed, pending, cancelled }

class ScheduleEvent {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final ScheduleEventType type;
  final String childId;
  final String childName;
  final String driverId;
  final String driverName;
  final String vehicleId;
  final String vehicleName;
  final String location;
  final ScheduleEventStatus status;
  final bool hasConflict;

  ScheduleEvent({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.childId,
    required this.childName,
    required this.driverId,
    required this.driverName,
    required this.vehicleId,
    required this.vehicleName,
    required this.location,
    required this.status,
    this.hasConflict = false,
  });
}

// Placeholder widgets
class ConflictResolutionSheet extends StatelessWidget {
  const ConflictResolutionSheet({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.conflictResolution),
          Text(l10n.implementationComingSoon),
        ],
      ),
    );
  }
}

class FilterOptionsSheet extends StatelessWidget {
  const FilterOptionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.filterOptions),
          Text(l10n.implementationComingSoon),
        ],
      ),
    );
  }
}

class AddEventDialog extends StatelessWidget {
  const AddEventDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.addEvent),
      content: Text(l10n.implementationComingSoon),
    );
  }
}
