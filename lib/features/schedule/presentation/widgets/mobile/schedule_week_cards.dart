import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulift/core/domain/entities/schedule.dart';
import '../../../../../core/domain/entities/family/vehicle.dart';
import '../../../../../core/domain/entities/family/child.dart';
import '../../../../../core/presentation/themes/app_colors.dart';
import 'day_card_widget.dart';
import '../../models/displayable_time_slot.dart';

/// Mobile-optimized week view for schedule display using DisplayableTimeSlot
/// UPDATED: Now uses DisplayableTimeSlot to show both existing and uncreated slots
/// FIXED: Removed internal PageView to prevent nested PageView conflicts with parent
/// FIXED: Simplified to use single week display - parent controls all week navigation
class ScheduleWeekCards extends ConsumerWidget {
  /// All displayable slots for the week (includes configured-but-not-created slots)
  final List<DisplayableTimeSlot> displayableSlots;

  /// Callback when slot is tapped
  final Function(DisplayableTimeSlot) onSlotTap;

  /// Callback to add vehicle to slot (creates slot if needed)
  final Function(DisplayableTimeSlot)? onAddVehicle;

  /// Callback for vehicle actions (remove)
  final Function(DisplayableTimeSlot, VehicleAssignment, String)?
  onVehicleAction;

  /// Days to display (filtered from config)
  final List<DayOfWeek> configuredDays;

  /// Vehicle data for slots
  final Map<String, Vehicle?> vehicles;

  /// Children data for display
  final Map<String, Child> childrenMap;

  /// Function to check if slot is in the past
  final bool Function(DisplayableTimeSlot) isSlotInPast;

  const ScheduleWeekCards({
    Key? key,
    required this.displayableSlots,
    required this.onSlotTap,
    this.onAddVehicle,
    this.onVehicleAction,
    this.configuredDays = DayOfWeek.values,
    required this.vehicles,
    required this.childrenMap,
    required this.isSlotInPast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // FIXED: Remove internal PageView and onWeekChanged callback to prevent conflicts
    // Parent SchedulePage now controls all week navigation through unified state management
    return WeekViewPage(
      displayableSlots: displayableSlots,
      onSlotTap: onSlotTap,
      onAddVehicle: onAddVehicle,
      onVehicleAction: onVehicleAction,
      configuredDays: configuredDays,
      vehicles: vehicles,
      childrenMap: childrenMap,
      isSlotInPast: isSlotInPast,
    );
  }
}

class WeekViewPage extends StatelessWidget {
  final List<DisplayableTimeSlot> displayableSlots;
  final Function(DisplayableTimeSlot) onSlotTap;
  final Function(DisplayableTimeSlot)? onAddVehicle;
  final Function(DisplayableTimeSlot, VehicleAssignment, String)?
  onVehicleAction;
  final List<DayOfWeek> configuredDays;
  final Map<String, Vehicle?> vehicles;
  final Map<String, Child> childrenMap;

  /// Function to check if slot is in the past
  final bool Function(DisplayableTimeSlot) isSlotInPast;

  const WeekViewPage({
    Key? key,
    required this.displayableSlots,
    required this.onSlotTap,
    this.onAddVehicle,
    this.onVehicleAction,
    required this.configuredDays,
    required this.vehicles,
    required this.childrenMap,
    required this.isSlotInPast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Only display configured days, not all 7 days
    // This prevents showing empty days that aren't configured in the schedule
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(children: _buildConfiguredDayCards(context)),
      ),
    );
  }

  List<Widget> _buildConfiguredDayCards(BuildContext context) {
    final dayCards = <Widget>[];

    // Sort configured days by weekday (Monday=1 to Sunday=7)
    final sortedConfiguredDays = List<DayOfWeek>.from(configuredDays)
      ..sort((a, b) => a.weekday.compareTo(b.weekday));

    // Group displayable slots by day
    final slotsByDay = <DayOfWeek, List<DisplayableTimeSlot>>{};
    for (final slot in displayableSlots) {
      slotsByDay.putIfAbsent(slot.dayOfWeek, () => []).add(slot);
    }

    // Create day cards only for configured days
    for (var dayIndex = 0; dayIndex < sortedConfiguredDays.length; dayIndex++) {
      final dayOfWeek = sortedConfiguredDays[dayIndex];

      // Get displayable slots for this day (empty list if none)
      final dayDisplayableSlots = slotsByDay[dayOfWeek] ?? [];

      // Calculate date for this day (approximate from first slot's week)
      final week = displayableSlots.isNotEmpty
          ? displayableSlots.first.week
          : '';
      final date = _calculateDateForDay(week, dayOfWeek);

      dayCards.add(
        DayCardWidget(
          key: Key('week_day_card_$dayIndex'),
          date: date,
          displayableSlots: dayDisplayableSlots,
          onSlotTap: onSlotTap,
          onAddVehicle: onAddVehicle,
          onVehicleAction: onVehicleAction,
          vehicles: vehicles,
          childrenMap: childrenMap,
          isSlotInPast: isSlotInPast,
        ),
      );
    }

    // If no days are configured, show a message
    if (dayCards.isEmpty) {
      dayCards.add(
        Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 64,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.38),
              ),
              const SizedBox(height: 16),
              Text(
                'No days configured for this schedule',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondaryThemed(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return dayCards;
  }

  /// Calculate the actual date for a given day of week within an ISO week
  ///
  /// @param week - ISO week string (e.g., "2025-W46")
  /// @param dayOfWeek - Day of the week enum
  /// @returns DateTime for that specific day
  DateTime _calculateDateForDay(String week, DayOfWeek dayOfWeek) {
    // Parse ISO week to get Monday
    final weekParts = week.split('-W');
    if (weekParts.length != 2) {
      // Fallback to current date if parsing fails
      return DateTime.now();
    }

    final year = int.tryParse(weekParts[0]);
    final weekNumber = int.tryParse(weekParts[1]);

    if (year == null || weekNumber == null) {
      return DateTime.now();
    }

    // Calculate Monday of that week (ISO 8601)
    // Week 1 is the week with the first Thursday of the year
    final jan4 = DateTime(year, 1, 4);
    final daysFromMonday = jan4.weekday - 1;
    final firstMonday = jan4.subtract(Duration(days: daysFromMonday));
    final targetMonday = firstMonday.add(Duration(days: (weekNumber - 1) * 7));

    // Add day offset (Monday=1, so subtract 1 to get 0-indexed offset)
    final dayOffset = dayOfWeek.weekday - 1;
    return targetMonday.add(Duration(days: dayOffset));
  }
}
