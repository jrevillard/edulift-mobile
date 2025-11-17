import 'package:flutter/material.dart';
import '../../../../../../core/domain/entities/schedule/time_slot.dart';
import '../../../../../../core/domain/entities/family/vehicle.dart';
import '../../../../../../core/presentation/themes/app_colors.dart';

/// Enum representing different availability states
enum SlotAvailabilityStatus { available, assigned, full, overcapacity }

/// Widget for displaying slot availability status with color coding
class SlotAvailabilityIndicator extends StatelessWidget {
  final SlotAvailabilityStatus status;
  final int assignedCount;
  final int capacity;
  final double size;
  final bool showLabel;
  final String? customLabel;

  const SlotAvailabilityIndicator({
    Key? key,
    required this.status,
    this.assignedCount = 0,
    this.capacity = 0,
    this.size = 16.0,
    this.showLabel = false,
    this.customLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(context);
    final label = customLabel ?? _getStatusLabel(context);

    if (showLabel) {
      return Row(
        key: const Key('slot_availability_indicator_with_label'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            key: const Key('slot_availability_indicator_dot'),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.24)
                    : Colors.black.withValues(alpha: 0.12),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Tooltip(
      message: label,
      child: Container(
        key: const Key('slot_availability_indicator'),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.24)
                : Colors.black.withValues(alpha: 0.12),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(BuildContext context) {
    switch (status) {
      case SlotAvailabilityStatus.available:
        return AppColors.successThemed(context);
      case SlotAvailabilityStatus.assigned:
        return AppColors.infoThemed(context);
      case SlotAvailabilityStatus.full:
        return AppColors.warningThemed(context);
      case SlotAvailabilityStatus.overcapacity:
        return AppColors.errorThemed(context);
    }
  }

  String _getStatusLabel(BuildContext context) {
    switch (status) {
      case SlotAvailabilityStatus.available:
        return 'Disponible';
      case SlotAvailabilityStatus.assigned:
        if (capacity > 0) {
          return '$assignedCount/$capacity places';
        }
        return 'Assigné';
      case SlotAvailabilityStatus.full:
        return 'Complet ($assignedCount/$capacity)';
      case SlotAvailabilityStatus.overcapacity:
        return 'Surcapacité ($assignedCount/$capacity)';
    }
  }
}

/// Get the availability status for a time slot
SlotAvailabilityStatus getSlotAvailabilityStatus(
  TimeSlot slot,
  Vehicle? vehicle,
) {
  if (slot.assignedVehicleId == null) {
    return SlotAvailabilityStatus.available;
  }

  final assignedCount = slot.assignedChildIds.length;
  final capacity = vehicle?.capacity ?? 0;

  if (assignedCount > capacity) {
    return SlotAvailabilityStatus.overcapacity;
  }

  if (assignedCount == capacity && capacity > 0) {
    return SlotAvailabilityStatus.full;
  }

  return SlotAvailabilityStatus.assigned;
}

/// Enhanced time slot chip with availability indicators
class EnhancedTimeSlotChip extends StatelessWidget {
  final TimeSlot slot;
  final Vehicle? vehicle;
  final VoidCallback? onTap;
  final bool showAvailabilityIndicator;

  const EnhancedTimeSlotChip({
    Key? key,
    required this.slot,
    this.vehicle,
    this.onTap,
    this.showAvailabilityIndicator = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = getSlotAvailabilityStatus(slot, vehicle);
    final assignedCount = slot.assignedChildIds.length;
    final capacity = vehicle?.capacity ?? 0;

    return GestureDetector(
      key: Key('time_slot_chip_${slot.id}'),
      onTap: onTap,
      child: Container(
        key: Key('time_slot_chip_container_${slot.id}'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _getChipColor(context, status),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _getBorderColor(context, status)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatTime(slot.startTime),
              key: Key('time_slot_time_${slot.id}'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            if (slot.assignedVehicleId != null) ...[
              const SizedBox(height: 2),
              Text(
                '$assignedCount/${capacity > 0 ? capacity : '?'}',
                key: Key('time_slot_capacity_${slot.id}'),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getChipColor(BuildContext context, SlotAvailabilityStatus status) {
    switch (status) {
      case SlotAvailabilityStatus.available:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38);
      case SlotAvailabilityStatus.assigned:
        return AppColors.infoThemed(context);
      case SlotAvailabilityStatus.full:
        return AppColors.successThemed(context);
      case SlotAvailabilityStatus.overcapacity:
        return AppColors.errorThemed(context);
    }
  }

  Color _getBorderColor(BuildContext context, SlotAvailabilityStatus status) {
    switch (status) {
      case SlotAvailabilityStatus.available:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
      case SlotAvailabilityStatus.assigned:
        return AppColors.infoThemed(context);
      case SlotAvailabilityStatus.full:
        return AppColors.successThemed(context);
      case SlotAvailabilityStatus.overcapacity:
        return AppColors.errorThemed(context);
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
