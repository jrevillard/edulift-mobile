// EduLift Mobile - Invitation Error Display Widget
// Shared error display component for both family and group invitations

import 'package:flutter/material.dart';
import '../../../navigation/navigation_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../accessibility/accessible_button.dart';
import '../../utils/responsive_breakpoints.dart';

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

  /// Optional custom action button text (defaults to "Back to Login")
  final String? actionButtonText;

  /// Optional custom action callback (defaults to navigate to /auth/login)
  final VoidCallback? onAction;

  const InvitationErrorDisplay({
    super.key,
    required this.errorKey,
    required this.contextTitle,
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

    // Responsive design system - Phase 3A patterns
    final adaptivePadding = context.getAdaptivePadding(
      mobileAll: 12.0,
      tabletAll: 20.0,
      desktopAll: 24.0,
    );

    final adaptiveSpacing = context.getAdaptiveSpacing(
      mobile: 8.0,
      tablet: 20.0,
      desktop: 24.0,
    );

    final adaptiveSmallSpacing = context.getAdaptiveSpacing(
      mobile: 4.0,
      tablet: 12.0,
      desktop: 16.0,
    );

    final adaptiveLargeSpacing = context.getAdaptiveSpacing(
      mobile: 8.0,
      tablet: 32.0,
      desktop: 40.0,
    );

    final adaptiveErrorIconSize = context.getAdaptiveIconSize(
      mobile: 48.0,
      tablet: 64.0,
      desktop: 80.0,
    );

    final adaptiveTitleFontSize = context.getAdaptiveFontSize(
      mobile: 22.0,
      tablet: 24.0,
      desktop: 28.0,
    );

    final adaptiveBodyFontSize = context.getAdaptiveFontSize(
      mobile: 16.0,
      tablet: 17.0,
      desktop: 18.0,
    );

    final adaptiveBorderRadius = context.getAdaptiveBorderRadius(
      mobile: 12.0,
      tablet: 16.0,
      desktop: 20.0,
    );

    final adaptiveButtonPadding = context.getAdaptivePadding(
      mobileHorizontal: 12.0,
      mobileVertical: 10.0,
      tabletHorizontal: 20.0,
      tabletVertical: 14.0,
      desktopHorizontal: 24.0,
      desktopVertical: 16.0,
    );

    return Padding(
      padding: adaptivePadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // EduLift branding section
          Text(
            'EduLift',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: context.isMobile
                  ? theme.textTheme.headlineLarge?.fontSize
                  : context.getAdaptiveFontSize(
                      mobile: 24.0,
                      tablet: 28.0,
                      desktop: 32.0,
                    ),
            ),
          ),
          SizedBox(height: adaptiveSmallSpacing),
          Text(
            contextTitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: adaptiveBodyFontSize,
            ),
          ),
          SizedBox(height: adaptiveLargeSpacing),

          // Error icon with responsive sizing
          Icon(
            Icons.error_outline,
            size: adaptiveErrorIconSize,
            color: theme.colorScheme.error,
          ),
          SizedBox(height: adaptiveSpacing),

          // Error title with responsive typography
          Text(
            l10n.invalidInvitationTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.error,
              fontSize: adaptiveTitleFontSize,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: adaptiveSmallSpacing),

          // Error message with responsive text sizing
          Text(
            errorMessage,
            key: Key('invitation_error_$errorKey'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: adaptiveBodyFontSize,
              height: context.isMobile ? 1.4 : 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: adaptiveSpacing),

          // Action button with responsive styling
          SizedBox(
            width: double.infinity,
            child: AccessibleButton(
              key: const Key('back-to-login-button'),
              style: ButtonStyle(
                padding: WidgetStateProperty.all(adaptiveButtonPadding),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(adaptiveBorderRadius),
                  ),
                ),
                textStyle: WidgetStateProperty.all(
                  TextStyle(
                    fontSize: context.getAdaptiveFontSize(
                      mobile: 16.0,
                      tablet: 17.0,
                      desktop: 18.0,
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
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
      ),
    );
  }
}
