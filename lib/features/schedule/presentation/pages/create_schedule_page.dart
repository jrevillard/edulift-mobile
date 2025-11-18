import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/presentation/utils/responsive_breakpoints.dart';

class CreateSchedulePage extends ConsumerWidget {
  const CreateSchedulePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).createTrip),
        actions: [
          TextButton(
            onPressed: () {
              // Save schedule logic
            },
            child: Text(AppLocalizations.of(context).save),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: context.getAdaptivePadding(
            mobileAll: 24,
            tabletAll: 32,
            desktopAll: 40,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle,
                size: context.getAdaptiveIconSize(
                  mobile: 56,
                  tablet: 64,
                  desktop: 72,
                ),
                color: Colors.grey,
              ),
              SizedBox(
                height: context.getAdaptiveSpacing(
                  mobile: 16,
                  tablet: 20,
                  desktop: 24,
                ),
              ),
              Text(
                AppLocalizations.of(context).createTrip,
                style: TextStyle(
                  fontSize: 24 * context.fontScale,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: context.getAdaptiveSpacing(
                  mobile: 8,
                  tablet: 12,
                  desktop: 16,
                ),
              ),
              Text(
                AppLocalizations.of(context).tripCreationFormToImplement,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
