import 'package:flutter/material.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import 'package:edulift/core/presentation/themes/app_colors.dart';

class GlobalLoadingOverlay extends StatelessWidget {
  const GlobalLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      color: AppColors.scrim(context),
      child: Center(
        child: Card(
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(l10n.loading, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
