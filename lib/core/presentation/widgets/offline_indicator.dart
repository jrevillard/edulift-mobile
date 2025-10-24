import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/app_state_provider.dart';
import '../../../../core/presentation/themes/app_colors.dart';
import '../utils/responsive_breakpoints.dart';

class OfflineIndicator extends ConsumerWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);

    // Adaptive height based on screen density and size
    final screenDensity = MediaQuery.of(context).devicePixelRatio;
    final adaptiveHeight = _getAdaptiveHeight(context, screenDensity);

    // Adaptive icon and text sizes
    final iconSize = context.getAdaptiveIconSize(
      mobile: 16,
      tablet: 18,
      desktop: 20,
    );

    final fontSize = context.isTablet ? 13.0 : 12.0;
    final spacing = context.getAdaptiveSpacing(
      mobile: 8,
      tablet: 10,
      desktop: 12,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: adaptiveHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: context.getAdaptivePadding(
            mobileHorizontal: 16,
            tabletHorizontal: 24,
            desktopHorizontal: 32,
          ),
          child: _buildContent(context, appState, iconSize, fontSize, spacing),
        ),
      ),
    );
  }

  /// Calculate adaptive height based on screen density and size
  double _getAdaptiveHeight(BuildContext context, double screenDensity) {
    final baseHeight = context.isTablet ? 40.0 : 32.0;

    // Adapt to screen density for better visibility on high-DPI screens
    final densityAdjustment = (screenDensity - 1.0) * 4.0;
    final adaptiveHeight = (baseHeight + densityAdjustment).clamp(28.0, 48.0);

    return adaptiveHeight;
  }

  Widget _buildContent(
    BuildContext context,
    dynamic appState,
    double iconSize,
    double fontSize,
    double spacing,
  ) {
    // Use LayoutBuilder to handle content overflow on narrow screens
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrowScreen = constraints.maxWidth < 400;

        if (isNarrowScreen) {
          return _buildCompactLayout(
            context,
            appState,
            iconSize,
            fontSize,
            spacing,
          );
        } else {
          return _buildFullLayout(
            context,
            appState,
            iconSize,
            fontSize,
            spacing,
          );
        }
      },
    );
  }

  Widget _buildFullLayout(
    BuildContext context,
    dynamic appState,
    double iconSize,
    double fontSize,
    double spacing,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.cloud_off,
          color: Theme.of(context).colorScheme.onError,
          size: iconSize,
          semanticLabel: 'Offline mode indicator',
        ),
        SizedBox(width: spacing),
        Flexible(
          child: Text(
            appState.isSyncing
                ? 'Synchronisation en cours...'
                : 'Mode hors ligne - ${appState.pendingSyncItems} élément(s) en attente',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onError,
              fontSize: fontSize * context.fontScale,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        if (appState.isSyncing) ...[
          SizedBox(width: spacing),
          SizedBox(
            width: iconSize * 0.75,
            height: iconSize * 0.75,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.onError,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompactLayout(
    BuildContext context,
    dynamic appState,
    double iconSize,
    double fontSize,
    double spacing,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.cloud_off,
          color: Theme.of(context).colorScheme.onError,
          size: iconSize * 0.9, // Slightly smaller on compact screens
          semanticLabel: 'Offline mode indicator',
        ),
        SizedBox(width: spacing * 0.75),
        Expanded(
          child: Text(
            appState.isSyncing
                ? 'Synchronisation...'
                : 'Hors ligne - ${appState.pendingSyncItems} en attente',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onError,
              fontSize: (fontSize - 1) * context.fontScale,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        if (appState.isSyncing) ...[
          SizedBox(width: spacing * 0.5),
          SizedBox(
            width: iconSize * 0.6,
            height: iconSize * 0.6,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.onError,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
