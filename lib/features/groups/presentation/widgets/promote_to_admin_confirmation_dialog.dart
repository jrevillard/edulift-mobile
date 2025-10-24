// EduLift Mobile - Promote to Admin Confirmation Dialog Widget
// Confirmation dialog for promoting a family to group admin role

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/entities/groups/group_family.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../pages/group_members_management_page.dart';

class PromoteToAdminConfirmationDialog extends ConsumerStatefulWidget {
  final GroupFamily family;
  final String groupId;
  final VoidCallback? onSuccess;

  const PromoteToAdminConfirmationDialog({
    super.key,
    required this.family,
    required this.groupId,
    this.onSuccess,
  });

  @override
  ConsumerState<PromoteToAdminConfirmationDialog> createState() =>
      _PromoteToAdminConfirmationDialogState();
}

class _PromoteToAdminConfirmationDialogState
    extends ConsumerState<PromoteToAdminConfirmationDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.admin_panel_settings,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              localizations.promoteToAdmin,
              style: theme.textTheme.titleLarge,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    radius: 20,
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: theme.colorScheme.onPrimaryContainer,
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
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                GroupFamilyRole.member.name.toUpperCase(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            Flexible(
                              child: Text(
                                GroupFamilyRole.admin.name.toUpperCase(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              localizations.promoteToAdminConfirmation(widget.family.name),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      localizations.adminCanManageGroupMembers,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
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
          key: const Key('promote_cancel_button'),
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(
            localizations.cancel,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        FilledButton(
          key: const Key('promote_confirm_button'),
          onPressed: _isLoading ? null : _handlePromote,
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(localizations.promoteToAdmin),
        ),
      ],
    );
  }

  Future<void> _handlePromote() async {
    setState(() => _isLoading = true);

    final success = await updateFamilyRole(
      context: context,
      ref: ref,
      groupId: widget.groupId,
      familyId: widget.family.id,
      newRole: 'admin',
      onError: (errorMessage) {
        AppLogger.error('Failed to promote family to admin', errorMessage);
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).failedToUpdateRole(errorMessage),
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
