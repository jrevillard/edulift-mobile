// EduLift Mobile - Conflict Indicator Widget
// Shows schedule conflicts with alert indicators

import 'package:flutter/material.dart';

import 'package:edulift/core/domain/entities/schedule.dart';

class ConflictIndicator extends StatelessWidget {
  final List<ScheduleConflict> conflicts;
  final VoidCallback? onTap;

  const ConflictIndicator({super.key, required this.conflicts, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (conflicts.isEmpty) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning,
              size: 16,
              color: Theme.of(context).colorScheme.onError,
            ),
            const SizedBox(width: 4),
            Text(
              '${conflicts.length}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onError,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
