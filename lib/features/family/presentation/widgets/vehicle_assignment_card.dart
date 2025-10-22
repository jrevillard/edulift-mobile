import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import 'package:edulift/core/domain/entities/schedule.dart';

/// This widget uses the schedule domain VehicleAssignment (correct implementation)
/// Unlike the deprecated family domain VehicleAssignment, this is supported
class VehicleAssignmentCard extends ConsumerWidget {
  final VehicleAssignment assignment;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const VehicleAssignmentCard({
    super.key,
    required this.assignment,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              assignment.vehicleName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).vehicleAssignment(assignment.vehicleId),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (assignment.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(assignment.notes!),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onEdit != null)
                  TextButton(
                    onPressed: onEdit,
                    child: Text(AppLocalizations.of(context).edit),
                  ),
                if (onDelete != null)
                  TextButton(
                    onPressed: onDelete,
                    child: Text(AppLocalizations.of(context).delete),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}