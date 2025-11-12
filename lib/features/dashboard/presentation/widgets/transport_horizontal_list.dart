import 'package:flutter/material.dart';
import 'package:edulift/features/dashboard/domain/entities/dashboard_transport_summary.dart';
import 'package:edulift/features/dashboard/presentation/widgets/today_transport_card.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';

/// Reusable horizontal list of transport mini cards
///
/// Used by SevenDayTimelineWidget to display transport slots
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

    // Responsive layout parameters (600px breakpoint)
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    // Mobile: larger cards (230px), more spacing (16px), more padding (12px)
    // Tablet: compact design (200px cards, 12px spacing, 4px padding)
    // Sufficient height to display 2-3 vehicles with all children without overflow
    final cardWidth = isTablet ? 200.0 : 230.0;
    final separatorWidth = isTablet ? 12.0 : 16.0;
    final horizontalPadding = isTablet ? 4.0 : 12.0;
    // Height must be unconstrained to let cards grow based on content

    return Semantics(
      label: semanticLabel ?? 'Transport list',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        // Use bouncing physics on mobile for native feel, clamping on tablet
        physics: isTablet
            ? const ClampingScrollPhysics()
            : const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < transports.length; i++) ...[
              TransportMiniCard(
                key: Key('transport_mini_card_$i'),
                transport: transports[i],
                cardWidth: cardWidth,
              ),
              if (i < transports.length - 1) SizedBox(width: separatorWidth),
            ],
          ],
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
