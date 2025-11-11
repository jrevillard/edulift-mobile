import 'package:flutter/material.dart';
import 'package:edulift/features/dashboard/domain/entities/dashboard_transport_summary.dart';
import 'package:edulift/features/dashboard/presentation/widgets/today_transport_card.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';

/// Reusable horizontal list of transport mini cards
///
/// Used by both TodayTransportCard and SevenDayTimelineWidget
/// for consistent transport display across the dashboard
class TransportHorizontalList extends StatelessWidget {
  final List<TransportSlotSummary> transports;
  final String? semanticLabel;

  const TransportHorizontalList({
    super.key,
    required this.transports,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (transports.isEmpty) {
      return _buildEmptyState(context);
    }

    return SizedBox(
      height: 180, // Fixed height for horizontal list
      child: Semantics(
        label: semanticLabel ?? 'Transport list',
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          itemCount: transports.length,
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final transport = transports[index];
            return TransportMiniCard(
              key: Key('transport_mini_card_$index'),
              transport: transport,
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 32,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noTransportsToday,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
