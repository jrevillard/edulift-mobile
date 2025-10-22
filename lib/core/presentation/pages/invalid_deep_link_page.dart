// EduLift Mobile - Invalid Deep Link Error Page
// Displayed when a malformed deep link is detected

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import '../../navigation/navigation_state.dart';

/// Error page for invalid or malformed deep links
///
/// Provides user-friendly error message and navigation options:
/// - Back button if navigation stack exists
/// - Dashboard button as fallback
class InvalidDeepLinkPage extends ConsumerWidget {
  /// The malformed deep link path that caused the error
  final String? invalidPath;

  const InvalidDeepLinkPage({
    super.key,
    this.invalidPath,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final canGoBack = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.link_off,
                  size: 80,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.invalidDeepLinkTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.invalidDeepLinkMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (invalidPath != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      invalidPath!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: theme.colorScheme.onErrorContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                // Primary action: Go back if possible, otherwise close (go to dashboard)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (canGoBack) {
                        Navigator.of(context).pop();
                      } else {
                        // No navigation history - go to dashboard
                        // Router will redirect to login/onboarding if needed
                        ref.read(navigationStateProvider.notifier).navigateTo(
                          route: '/dashboard',
                          trigger: NavigationTrigger.userNavigation,
                        );
                      }
                    },
                    icon: Icon(canGoBack ? Icons.arrow_back : Icons.close),
                    label: Text(canGoBack ? l10n.goBack : l10n.close),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
