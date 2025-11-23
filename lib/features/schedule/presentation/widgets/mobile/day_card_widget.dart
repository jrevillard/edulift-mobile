import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:edulift/core/domain/entities/schedule.dart';
import '../../../../../core/domain/entities/family/vehicle.dart';
import '../../../../../core/domain/entities/family/child.dart';
import '../../../../../generated/l10n/app_localizations.dart';
import '../../../../../core/utils/weekday_localization.dart';
import 'period_card_widget.dart';
import '../../models/displayable_time_slot.dart';

/// Data class for period grouping with displayable slots
class PeriodData {
  final String name;
  final List<DisplayableTimeSlot> displayableSlots;

  const PeriodData({required this.name, required this.displayableSlots});
}

class DayCardWidget extends StatelessWidget {
  final DateTime date;
  final List<DisplayableTimeSlot> displayableSlots;
  final Function(DisplayableTimeSlot) onSlotTap;
  final Function(DisplayableTimeSlot)? onAddVehicle;
  final Function(DisplayableTimeSlot, VehicleAssignment, String)?
  onVehicleAction;
  final Function(DisplayableTimeSlot, VehicleAssignment)? onVehicleTap;
  final Map<String, Vehicle?>? vehicles;
  final Map<String, Child> childrenMap;
  final bool Function(DisplayableTimeSlot)? isSlotInPast;

  const DayCardWidget({
    Key? key,
    required this.date,
    required this.displayableSlots,
    required this.onSlotTap,
    this.onAddVehicle,
    this.onVehicleAction,
    this.onVehicleTap,
    this.vehicles,
    required this.childrenMap,
    this.isSlotInPast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key('day_card_${date.millisecondsSinceEpoch}'),
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3, // Augmenté pour meilleure séparation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day header
            _buildDayHeader(context),
            const SizedBox(height: 12),
            // Period cards - adapt vertically without scroll
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _groupSlotsByPeriod(displayableSlots, context)
                  .map(
                    (period) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PeriodCardWidget(
                        periodName: period.name,
                        displayableSlots: period.displayableSlots,
                        onSlotTap: onSlotTap,
                        onAddVehicle: onAddVehicle,
                        onVehicleAction: onVehicleAction,
                        onVehicleTap: onVehicleTap,
                        vehicles: vehicles,
                        childrenMap: childrenMap,
                        isSlotInPast: isSlotInPast,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayHeader(BuildContext context) {
    return Row(
      key: Key('day_header_${date.millisecondsSinceEpoch}'),
      children: [
        Icon(
          Icons.calendar_today,
          size: 20,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _formatDate(context, date),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        _buildQuickSummary(context),
      ],
    );
  }

  Widget _buildQuickSummary(BuildContext context) {
    // Count slots with vehicles (only existing slots can have vehicles)
    final assignedSlots = displayableSlots
        .where((s) => s.existsInBackend && s.hasVehicles)
        .length;
    final totalSlots = displayableSlots.length;

    return Container(
      key: Key('day_quick_summary_${date.millisecondsSinceEpoch}'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: assignedSlots == totalSlots ? Colors.green : Colors.blue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$assignedSlots/$totalSlots',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<PeriodData> _groupSlotsByPeriod(
    List<DisplayableTimeSlot> displayableSlots,
    BuildContext context,
  ) {
    final l10n = AppLocalizations.of(context);

    // Group slots by Morning / Afternoon using time of day
    final morningSlots = displayableSlots.where((s) {
      final hour = s.timeOfDay.hour;
      return hour < 12;
    }).toList();

    final afternoonSlots = displayableSlots.where((s) {
      final hour = s.timeOfDay.hour;
      return hour >= 12;
    }).toList();

    final periods = <PeriodData>[];
    if (morningSlots.isNotEmpty) {
      periods.add(
        PeriodData(name: l10n.morning, displayableSlots: morningSlots),
      );
    }
    if (afternoonSlots.isNotEmpty) {
      periods.add(
        PeriodData(name: l10n.afternoon, displayableSlots: afternoonSlots),
      );
    }

    return periods;
  }
}

/// Format date for day card using existing utility to avoid code duplication
String _formatDate(BuildContext context, DateTime date) {
  final l10n = AppLocalizations.of(context);
  final shortLabels = getLocalizedWeekdayShortLabels(l10n);
  final dayName =
      shortLabels[date.weekday -
          1]; // Monday=1, so subtract 1 for 0-indexed array

  final monthFormat = DateFormat.MMM(l10n.localeName);
  final monthName = monthFormat.format(date);

  return '$dayName ${date.day} $monthName';
}
