import 'package:flutter/material.dart';
import 'package:edulift/core/domain/entities/schedule.dart';
import '../../../../../core/domain/entities/family/vehicle.dart';
import '../../../../../core/domain/entities/family/child.dart';
import 'enhanced_slot_card.dart';
import '../../models/displayable_time_slot.dart';

class PeriodCardWidget extends StatelessWidget {
  final String periodName;
  final List<DisplayableTimeSlot> displayableSlots;
  final Function(DisplayableTimeSlot) onSlotTap;
  final Function(DisplayableTimeSlot)? onAddVehicle;
  final Function(DisplayableTimeSlot, VehicleAssignment, String)?
  onVehicleAction;
  final Map<String, Vehicle?>? vehicles;
  final Map<String, Child> childrenMap;
  final bool Function(DisplayableTimeSlot)? isSlotInPast;

  const PeriodCardWidget({
    Key? key,
    required this.periodName,
    required this.displayableSlots,
    required this.onSlotTap,
    this.onAddVehicle,
    this.onVehicleAction,
    this.vehicles,
    required this.childrenMap,
    this.isSlotInPast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('period_card_${periodName.toLowerCase()}'),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodHeader(context),
          const SizedBox(height: 8),
          _buildTimeSlots(context),
        ],
      ),
    );
  }

  Widget _buildPeriodHeader(BuildContext context) {
    return Row(
      key: Key('period_header_${periodName.toLowerCase()}'),
      children: [
        Expanded(
          child: Text(
            periodName,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        _buildAvailabilitySummary(context),
      ],
    );
  }

  Widget _buildAvailabilitySummary(BuildContext context) {
    // Count slots with vehicles (only existing slots can have vehicles)
    final assigned = displayableSlots
        .where((s) => s.existsInBackend && s.hasVehicles)
        .length;
    final total = displayableSlots.length;

    return Container(
      key: Key('period_availability_${periodName.toLowerCase()}'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: assigned == total ? Colors.green : Colors.blue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$assigned/$total',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTimeSlots(BuildContext context) {
    // Use Column to adapt vertically without scroll
    return Column(
      key: Key('period_slots_${periodName.toLowerCase()}'),
      mainAxisSize: MainAxisSize.min,
      children: displayableSlots
          .map(
            (displayableSlot) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildEnhancedSlotCard(context, displayableSlot),
            ),
          )
          .toList(),
    );
  }

  Widget _buildEnhancedSlotCard(
    BuildContext context,
    DisplayableTimeSlot displayableSlot,
  ) {
    return GestureDetector(
      onTap: () => onSlotTap(displayableSlot),
      child: EnhancedSlotCard(
        key: Key('enhanced_slot_card_${displayableSlot.compositeKey}'),
        displayableSlot: displayableSlot,
        onVehicleAction: (vehicleAssignment, action) =>
            onVehicleAction?.call(displayableSlot, vehicleAssignment, action),
        onAddVehicle: onAddVehicle,
        childrenMap: childrenMap,
        vehicles: vehicles,
        isSlotInPast: isSlotInPast,
      ),
    );
  }
}
