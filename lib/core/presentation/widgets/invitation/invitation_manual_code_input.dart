// EduLift Mobile - Invitation Manual Code Input Widget
// Shared manual code entry component for invitations

import 'package:flutter/material.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../accessibility/accessible_button.dart';

/// Invitation type enum for type-specific behavior
enum InvitationType { family, group }

/// Reusable manual code input widget for invitations
///
/// Displays:
/// - Icon and title (type-specific, localized)
/// - Instruction text (type-specific, localized)
/// - Text input field for invitation code
/// - Validation button (localized)
///
/// Used by both family and group invitation pages when no code is provided in URL
class InvitationManualCodeInput extends StatelessWidget {
  /// Invitation type (family or group)
  final InvitationType invitationType;

  /// Icon to display (e.g., Icons.people for family, Icons.group for groups)
  final IconData icon;

  /// Text controller for the code input field
  final TextEditingController controller;

  /// Callback when validate button is pressed
  final VoidCallback onValidate;

  /// Optional callback when cancel button is pressed
  final VoidCallback? onCancel;

  /// Optional error message to display below the input field
  final String? errorMessage;

  /// Whether to use tablet-optimized layout
  final bool isTablet;

  const InvitationManualCodeInput({
    super.key,
    required this.invitationType,
    required this.icon,
    required this.controller,
    required this.onValidate,
    this.onCancel,
    this.errorMessage,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // Get type-specific strings
    final title = invitationType == InvitationType.family
        ? l10n.enterInvitationCodeTitle
        : l10n.enterGroupInvitationCodeTitle;

    final instruction = invitationType == InvitationType.family
        ? l10n.enterFamilyInvitationInstruction
        : l10n.enterGroupInvitationInstruction;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: isTablet ? 80 : 64,
          color: theme.colorScheme.primary,
        ),
        SizedBox(height: isTablet ? 32 : 24),
        Text(
          title, // ✅ Localized
          style: (isTablet
                  ? theme.textTheme.headlineMedium
                  : theme.textTheme.headlineSmall)
              ?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: isTablet ? 12 : 8),
        Text(
          instruction, // ✅ Localized
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isTablet ? 40 : 32),
        TextFormField(
          key: const Key('invitation_code_input_field'),
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.invitationCode, // ✅ Existing key
            hintText: l10n.enterInvitationCode, // ✅ Existing key
            prefixIcon: const Icon(Icons.vpn_key),
            errorText: errorMessage,
            errorMaxLines: 3,
          ),
          onFieldSubmitted: (_) => onValidate(),
        ),
        SizedBox(height: isTablet ? 32 : 24),
        // Show buttons in row if cancel callback provided, otherwise just validate button
        if (onCancel != null)
          Row(
            children: [
              Expanded(
                child: AccessibleButton.secondaryStyle(
                  key: const Key('cancel_invitation_code_button'),
                  onPressed: onCancel,
                  child: Text(l10n.cancel),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: AccessibleButton(
                  key: const Key('validate_invitation_code_button'),
                  onPressed: onValidate,
                  child: Text(l10n.validateCode), // ✅ Localized
                ),
              ),
            ],
          )
        else
          SizedBox(
            width: double.infinity,
            child: AccessibleButton(
              key: const Key('validate_invitation_code_button'),
              onPressed: onValidate,
              child: Text(l10n.validateCode), // ✅ Localized
            ),
          ),
      ],
    );
  }
}