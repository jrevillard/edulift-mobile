import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import 'package:edulift/core/domain/entities/schedule.dart';
import '../../../../core/utils/timezone_formatter.dart';
import '../../../../core/services/providers/auth_provider.dart';
import '../../../../core/presentation/utils/responsive_breakpoints.dart';

String _getTimeSlotRange(
  Map<String, List<String>> scheduleHours,
  String? userTimezone,
) {
  final allSlots = <String>[];
  for (final daySlots in scheduleHours.values) {
    allSlots.addAll(daySlots);
  }

  if (allSlots.isEmpty) return '';

  // Sort time slots
  allSlots.sort();

  if (allSlots.isEmpty) return '';

  // Convert UTC times to user's timezone
  final firstTime = TimezoneFormatter.formatTimeSlot(
    allSlots.first,
    userTimezone,
  );
  final lastTime = TimezoneFormatter.formatTimeSlot(
    allSlots.last,
    userTimezone,
  );

  return '$firstTime - $lastTime';
}

/// Preview widget to visualize schedule configuration
class SchedulePreview extends ConsumerWidget {
  final ScheduleConfig config;
  final String groupId;

  const SchedulePreview({
    super.key,
    required this.config,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // Get user timezone
    final currentUser = ref.watch(currentUserProvider);
    final userTimezone = currentUser?.timezone;

    // Calculate stats
    final activeDays = config.scheduleHours.keys
        .where((day) => config.scheduleHours[day]!.isNotEmpty)
        .length;
    final totalActiveSlots = config.scheduleHours.values.fold<int>(
      0,
      (sum, slots) => sum + slots.length,
    );

    return Container(
      margin: context.getAdaptivePadding(
        mobileAll: 12,
        tabletAll: 16,
        desktopAll: 20,
      ),
      padding: context.getAdaptivePadding(
        mobileAll: 12,
        tabletAll: 16,
        desktopAll: 20,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(
          context.getAdaptiveBorderRadius(mobile: 10, tablet: 12, desktop: 14),
        ),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Icon(Icons.preview, color: theme.colorScheme.primary),
              SizedBox(
                width: context.getAdaptiveSpacing(
                  mobile: 6,
                  tablet: 8,
                  desktop: 10,
                ),
              ),
              Text(
                l10n.schedulePreview,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(
            height: context.getAdaptiveSpacing(
              mobile: 14,
              tablet: 16,
              desktop: 18,
            ),
          ),

          // Days active
          _buildSummaryRow(
            context: context,
            icon: Icons.calendar_today,
            label: l10n.activeDays,
            value: l10n.daysCount(activeDays),
            detail: activeDays > 0
                ? config.scheduleHours.keys
                      .where((day) => config.scheduleHours[day]!.isNotEmpty)
                      .join(', ')
                : l10n.noDaysConfigured,
            theme: theme,
          ),

          SizedBox(
            height: context.getAdaptiveSpacing(
              mobile: 6,
              tablet: 8,
              desktop: 10,
            ),
          ),

          // Time slots
          _buildSummaryRow(
            context: context,
            icon: Icons.access_time,
            label: l10n.timeSlots,
            value: l10n.slotsCount(totalActiveSlots),
            detail: totalActiveSlots > 0
                ? l10n.timeRange(
                    _getTimeSlotRange(config.scheduleHours, userTimezone),
                  )
                : l10n.noTimeSlotsConfigured,
            theme: theme,
          ),

          SizedBox(
            height: context.getAdaptiveSpacing(
              mobile: 6,
              tablet: 8,
              desktop: 10,
            ),
          ),

          // Configuration summary
          _buildSummaryRow(
            context: context,
            icon: Icons.schedule,
            label: l10n.configuration,
            value: l10n.slotsCount(totalActiveSlots),
            detail: l10n.weeklySlotTotal(totalActiveSlots * activeDays),
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required String detail,
    required ThemeData theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: context.getAdaptiveIconSize(
            mobile: 18,
            tablet: 20,
            desktop: 22,
          ),
          color: theme.colorScheme.primary,
        ),
        SizedBox(
          width: context.getAdaptiveSpacing(mobile: 8, tablet: 10, desktop: 12),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    width: context.getAdaptiveSpacing(
                      mobile: 6,
                      tablet: 8,
                      desktop: 10,
                    ),
                  ),
                  Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: context.getAdaptiveSpacing(
                  mobile: 3,
                  tablet: 4,
                  desktop: 5,
                ),
              ),
              Text(
                detail,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
