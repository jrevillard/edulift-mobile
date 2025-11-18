import 'package:flutter/material.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import 'package:edulift/core/presentation/utils/responsive_breakpoints.dart';

class GlobalLoadingOverlay extends StatelessWidget {
  const GlobalLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Get responsive dimensions
    final adaptivePadding = context.getAdaptivePadding(
      mobileAll: 20.0,
      tabletAll: 28.0,
      desktopAll: 36.0,
    );

    final adaptiveSpacing = context.getAdaptiveSpacing(
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
    );

    final adaptiveFontSize = context.getAdaptiveFontSize(
      mobile: 15.0,
      tablet: 16.0,
      desktop: 17.0,
    );

    final adaptiveElevation = context.isDesktop
        ? 12.0
        : context.isTablet
        ? 10.0
        : 8.0;

    final adaptiveBorderRadius = context.getAdaptiveBorderRadius(
      mobile: 12.0,
      tablet: 14.0,
      desktop: 16.0,
    );

    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          elevation: adaptiveElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(adaptiveBorderRadius),
          ),
          child: Padding(
            padding: adaptivePadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: context.getAdaptiveIconSize(
                    mobile: 24.0,
                    tablet: 28.0,
                    desktop: 32.0,
                  ),
                  height: context.getAdaptiveIconSize(
                    mobile: 24.0,
                    tablet: 28.0,
                    desktop: 32.0,
                  ),
                  child: const CircularProgressIndicator(),
                ),
                SizedBox(height: adaptiveSpacing),
                Text(
                  l10n.loading,
                  style: TextStyle(
                    fontSize: adaptiveFontSize,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
