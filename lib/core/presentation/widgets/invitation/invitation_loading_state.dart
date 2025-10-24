// EduLift Mobile - Invitation Loading State Widget
// Shared loading indicator for invitation validation

import 'package:flutter/material.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../loading_indicator.dart';
import 'invitation_manual_code_input.dart' show InvitationType;

/// Reusable loading state widget for invitation validation
///
/// Displays:
/// - Centered loading spinner
/// - Type-specific loading message (localized)
///
/// Used by both family and group invitation pages during validation
class InvitationLoadingState extends StatelessWidget {
  /// Invitation type (family or group)
  final InvitationType invitationType;

  /// Whether to use tablet-optimized layout
  final bool isTablet;

  const InvitationLoadingState({
    super.key,
    required this.invitationType,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // Get type-specific message
    final message = invitationType == InvitationType.family
        ? l10n
              .validatingInvitation // ✅ Existing key
        : l10n.validatingGroupInvitation; // ✅ New key

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const LoadingIndicator(),
        SizedBox(height: isTablet ? 32 : 24),
        Text(
          message, // ✅ Localized
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
