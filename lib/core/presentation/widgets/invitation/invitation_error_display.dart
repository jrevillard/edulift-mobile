// EduLift Mobile - Invitation Error Display Widget
// Shared error display component for both family and group invitations

import 'package:flutter/material.dart';
import '../../../navigation/navigation_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../accessibility/accessible_button.dart';

/// Reusable error display widget for invitation validation failures
///
/// Displays:
/// - Branded header (EduLift + context title)
/// - Error icon
/// - Error title (localized)
/// - Localized error message
/// - Back to login action button (localized)
///
/// Used by both family and group invitation pages
class InvitationErrorDisplay extends ConsumerWidget {
  /// Error localization key (e.g., 'errorInvitationExpired')
  final String errorKey;

  /// Context title (e.g., 'Family Management' or 'Group Management')
  final String contextTitle;

  /// Whether to use tablet-optimized layout
  final bool isTablet;

  /// Optional custom action button text (defaults to "Back to Login")
  final String? actionButtonText;

  /// Optional custom action callback (defaults to navigate to /auth/login)
  final VoidCallback? onAction;

  const InvitationErrorDisplay({
    super.key,
    required this.errorKey,
    required this.contextTitle,
    this.isTablet = false,
    this.actionButtonText,
    this.onAction,
  });

  /// Get localized error message directly using AppLocalizations
  String _getLocalizedErrorDirect(AppLocalizations l10n, String key) {
    // Direct property access for self-localization
    switch (key) {
      case 'errorUnexpected':
        return l10n.errorUnexpected;
      case 'errorNetworkGeneral':
        return l10n.errorNetworkGeneral;
      case 'errorServerGeneral':
        return l10n.errorServerGeneral;
      case 'errorAuth':
        return l10n.errorAuth;
      case 'errorInvitationEmailMismatch':
        return l10n.errorInvitationEmailMismatch;
      case 'errorInvitationExpired':
        return l10n.errorInvitationExpired;
      case 'errorInvitationCodeInvalid':
        return l10n.errorInvitationCodeInvalid;
      case 'errorInvitationNotFound':
        return l10n.errorInvitationNotFound;
      case 'errorInvitationCancelled':
        return l10n.errorInvitationCancelled;
      case 'errorInvalidData':
        return l10n.errorInvalidData;
      default:
        return l10n.errorUnexpected;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final canGoBack = Navigator.canPop(context);

    // Get localized error message
    final errorMessage = _getLocalizedErrorDirect(l10n, errorKey);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // EduLift branding section
        Text(
          'EduLift',
          style: theme.textTheme.headlineLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          contextTitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: isTablet ? 48 : 32),

        Icon(
          Icons.error_outline,
          size: isTablet ? 64 : 48,
          color: theme.colorScheme.error,
        ),
        SizedBox(height: isTablet ? 24 : 16),
        Text(
          l10n.invalidInvitationTitle, // ✅ Localized
          style:
              (isTablet
                      ? theme.textTheme.headlineSmall
                      : theme.textTheme.titleLarge)
                  ?.copyWith(color: theme.colorScheme.error),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isTablet ? 12 : 8),
        Text(
          errorMessage, // ✅ Localized via direct lookup
          // Use error-specific key for E2E testing (allows finding by error type)
          key: Key('invitation_error_$errorKey'),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isTablet ? 32 : 24),

        // Action button aligned with magic link style
        SizedBox(
          width: double.infinity,
          child: AccessibleButton(
            key: const Key('back-to-login-button'),
            onPressed:
                onAction ??
                () {
                  // Default: Go back if possible, otherwise navigate to dashboard
                  // Router will redirect to login/onboarding if needed
                  if (canGoBack) {
                    Navigator.of(context).pop();
                  } else {
                    ref
                        .read(navigationStateProvider.notifier)
                        .navigateTo(
                          route: '/dashboard',
                          trigger: NavigationTrigger.userNavigation,
                        );
                  }
                },
            child: Text(
              actionButtonText ?? (canGoBack ? l10n.goBack : l10n.close),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
