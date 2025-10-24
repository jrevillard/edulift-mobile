// EduLift Mobile - Demote to Member Confirmation Dialog Widget
// Confirmation dialog for demoting a family from group admin to member role

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/entities/groups/group_family.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../pages/group_members_management_page.dart' show updateFamilyRole;

class DemoteToMemberConfirmationDialog extends ConsumerStatefulWidget {
  final GroupFamily family;
  final String groupId;
  final VoidCallback? onSuccess;

  const DemoteToMemberConfirmationDialog({
    super.key,
    required this.family,
    required this.groupId,
    this.onSuccess,
  });

  @override
  ConsumerState<DemoteToMemberConfirmationDialog> createState() =>
      _DemoteToMemberConfirmationDialogState();
}

class _DemoteToMemberConfirmationDialogState
    extends ConsumerState<DemoteToMemberConfirmationDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.arrow_downward, color: theme.colorScheme.error, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              localizations.demoteToMember,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
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
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.errorContainer,
                    radius: 20,
                    child: Icon(
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
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                GroupFamilyRole.admin.name.toUpperCase(),
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
                                GroupFamilyRole.member.name.toUpperCase(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
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
              localizations.demoteToMemberConfirmation(widget.family.name),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
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
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      localizations.demoteToMemberNote,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
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
          key: const Key('demote_cancel_button'),
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(
            localizations.cancel,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        FilledButton(
          key: const Key('demote_confirm_button'),
          onPressed: _isLoading ? null : _handleDemote,
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(localizations.demoteToMember),
        ),
      ],
    );
  }

  Future<void> _handleDemote() async {
    setState(() => _isLoading = true);

    final success = await updateFamilyRole(
      context: context,
      ref: ref,
      groupId: widget.groupId,
      familyId: widget.family.id,
      newRole: 'member',
      onError: (errorMessage) {
        AppLogger.error('Failed to demote family to member', errorMessage);
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
