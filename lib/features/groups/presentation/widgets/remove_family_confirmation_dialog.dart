// EduLift Mobile - Remove Family Confirmation Dialog Widget
// Confirmation dialog for removing a family from a group

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/entities/groups/group_family.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../pages/group_members_management_page.dart' show removeFamilyFromGroup;

class RemoveFamilyConfirmationDialog extends ConsumerStatefulWidget {
  final GroupFamily family;
  final String groupId;
  final VoidCallback? onSuccess;

  const RemoveFamilyConfirmationDialog({
    super.key,
    required this.family,
    required this.groupId,
    this.onSuccess,
  });

  @override
  ConsumerState<RemoveFamilyConfirmationDialog> createState() =>
      _RemoveFamilyConfirmationDialogState();
}

class _RemoveFamilyConfirmationDialogState
    extends ConsumerState<RemoveFamilyConfirmationDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return AlertDialog(
      title: Semantics(
        label: localizations.removeFamilyDialogAccessibilityLabel,
        child: Row(
          children: [
            Icon(Icons.person_remove, color: theme.colorScheme.error, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                localizations.removeFromGroup,
                key: const Key('dialog_title'),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.errorContainer,
                    radius: 20,
                    child: widget.family.role == GroupFamilyRole.admin
                        ? Icon(
                            Icons.admin_panel_settings,
                            color: theme.colorScheme.onErrorContainer,
                            size: 20,
                          )
                        : Icon(
                            Icons.person,
                            color: theme.colorScheme.onErrorContainer,
                            size: 20,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.family.name,
                          key: const Key('family_name'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.family.role.name.toUpperCase(),
                          key: const Key('family_role'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (widget.family.admins.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.family.admins.first.name,
                            key: const Key('family_admin'),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber,
                    size: 20,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.actionCannotBeUndone,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          localizations.removeFamilyConfirmation(
                            widget.family.name,
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                        if (widget.family.role == GroupFamilyRole.admin) ...[
                          const SizedBox(height: 8),
                          Text(
                            localizations.removeAdminFamilyNote,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('remove_family_cancel_button'),
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(
            localizations.cancel,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        FilledButton(
          key: const Key('confirm_remove_family_button'),
          onPressed: _isLoading ? null : _handleRemoveFamily,
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  localizations.removeFromGroup,
                  style: const TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }

  Future<void> _handleRemoveFamily() async {
    setState(() => _isLoading = true);

    final success = await removeFamilyFromGroup(
      context: context,
      ref: ref,
      groupId: widget.groupId,
      familyId: widget.family.id,
      onError: (errorMessage) {
        AppLogger.error('Failed to remove family from group', errorMessage);
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).failedToRemoveFamily(errorMessage),
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
    );

    if (success && mounted) {
      // Call success callback BEFORE pop to ensure parent context is valid
      widget.onSuccess?.call();
      Navigator.of(context).pop(true);
    }
  }
}
