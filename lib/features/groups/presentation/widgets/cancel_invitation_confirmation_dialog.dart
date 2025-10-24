// EduLift Mobile - Cancel Invitation Confirmation Dialog Widget
// Confirmation dialog for canceling a pending group invitation

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/entities/groups/group_family.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../pages/group_members_management_page.dart' show cancelInvitation;

class CancelInvitationConfirmationDialog extends ConsumerStatefulWidget {
  final GroupFamily family;
  final String groupId;
  final VoidCallback? onSuccess;

  const CancelInvitationConfirmationDialog({
    super.key,
    required this.family,
    required this.groupId,
    this.onSuccess,
  });

  @override
  ConsumerState<CancelInvitationConfirmationDialog> createState() =>
      _CancelInvitationConfirmationDialogState();
}

class _CancelInvitationConfirmationDialogState
    extends ConsumerState<CancelInvitationConfirmationDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.cancel, color: theme.colorScheme.error, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              localizations.cancelInvitation,
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
                border: Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.errorContainer,
                    radius: 20,
                    child: Icon(
                      Icons.schedule,
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
                        Text(
                          localizations.pendingInvitation,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (widget.family.invitedAt != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            localizations.invitedOn(
                              _formatDate(widget.family.invitedAt!),
                            ),
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
            Text(
              localizations.cancelInvitationConfirmation(widget.family.name),
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
                      localizations.cancelInvitationNote,
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
          key: const Key('cancel_invitation_keep_button'),
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(
            localizations.keepInvitation,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        FilledButton(
          key: const Key('confirm_cancel_invitation_button'),
          onPressed: _isLoading ? null : _handleCancelInvitation,
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
                  localizations.cancelInvitation,
                  style: const TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return AppLocalizations.of(context).today;
    } else if (difference.inDays == 1) {
      return AppLocalizations.of(context).yesterday;
    } else if (difference.inDays < 7) {
      return AppLocalizations.of(context).daysAgo(difference.inDays);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _handleCancelInvitation() async {
    setState(() => _isLoading = true);

    if (widget.family.invitationId == null) {
      AppLogger.error(
        'Failed to cancel invitation',
        'No invitation ID available',
      );
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              ).failedToCancelInvitation('No invitation ID available'),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return;
    }

    final success = await cancelInvitation(
      context: context,
      ref: ref,
      groupId: widget.groupId,
      invitationId: widget.family.invitationId!,
      onError: (errorMessage) {
        AppLogger.error('Failed to cancel invitation', errorMessage);
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(
                  context,
                ).failedToCancelInvitation(errorMessage),
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
