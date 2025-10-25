// EduLift Mobile - Assignment Card Widget
// Displays assignment details in schedule interface

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/utils/timezone_formatter.dart';
import '../../../../core/services/providers/auth_provider.dart';

import 'package:edulift/core/domain/entities/schedule.dart';
import 'package:edulift/core/domain/entities/family.dart';

class AssignmentCard extends ConsumerWidget {
  final Assignment assignment;
  final TimeSlot timeSlot;
  final Vehicle vehicle;
  final bool isLoading;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AssignmentCard({
    super.key,
    required this.assignment,
    required this.timeSlot,
    required this.vehicle,
    this.isLoading = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get user timezone
    final currentUser = ref.watch(currentUserProvider);
    final userTimezone = currentUser?.timezone;

    // Format start and end times with timezone awareness
    final startTimeStr = TimezoneFormatter.formatTimeSlot(
      '${timeSlot.startTime.hour.toString().padLeft(2, '0')}:${timeSlot.startTime.minute.toString().padLeft(2, '0')}',
      userTimezone,
    );
    final endTimeStr = TimezoneFormatter.formatTimeSlot(
      '${timeSlot.endTime.hour.toString().padLeft(2, '0')}:${timeSlot.endTime.minute.toString().padLeft(2, '0')}',
      userTimezone,
    );
    final displayTime = '$startTimeStr - $endTimeStr';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      displayTime,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (isLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                vehicle.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onEdit != null)
                    IconButton(
                      onPressed: isLoading ? null : onEdit,
                      icon: const Icon(Icons.edit),
                      tooltip: AppLocalizations.of(
                        context,
                      ).editAssignmentTooltip,
                    ),
                  if (onDelete != null)
                    IconButton(
                      onPressed: isLoading ? null : onDelete,
                      icon: const Icon(Icons.delete),
                      tooltip: AppLocalizations.of(
                        context,
                      ).deleteAssignmentTooltip,
                      iconSize: 20,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
