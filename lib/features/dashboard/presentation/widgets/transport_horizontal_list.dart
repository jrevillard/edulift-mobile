import 'package:flutter/material.dart';
import 'package:edulift/features/dashboard/domain/entities/dashboard_transport_summary.dart';
import 'package:edulift/features/dashboard/presentation/widgets/today_transport_card.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import 'package:edulift/core/presentation/utils/responsive_breakpoints.dart';

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

    // Responsive layout parameters using established Phase 1 patterns
    // Mobile: larger cards, more spacing, more padding
    // Tablet: compact design for space efficiency
    // Desktop: optimal layout for larger screens
    final cardWidth = context.getAdaptiveSpacing(
      mobile: 230.0,
      tablet: 200.0,
      desktop: 220.0,
    );
    final separatorWidth = context.getAdaptiveSpacing(
      mobile: 16.0,
      tablet: 12.0,
      desktop: 14.0,
    );
    final horizontalPaddingValue = context.getAdaptiveSpacing(
      mobile: 12.0,
      tablet: 4.0,
      desktop: 8.0,
    );
    // Height must be unconstrained to let cards grow based on content

    return Semantics(
      label: semanticLabel ?? 'Transport list',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        // Use bouncing physics on mobile for native feel, clamping on larger screens
        physics: context.isMobile
            ? const BouncingScrollPhysics()
            : const ClampingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: horizontalPaddingValue),
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
      height: context.getAdaptiveSpacing(
        mobile: 120.0,
        tablet: 100.0,
        desktop: 110.0,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule_outlined,
              size: context.getAdaptiveIconSize(
                mobile: 32.0,
                tablet: 28.0,
                desktop: 30.0,
              ),
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 8.0,
                tablet: 6.0,
                desktop: 7.0,
              ),
            ),
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
