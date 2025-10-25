// EduLift Mobile - Remove Member Confirmation Dialog Widget
// Confirmation dialog for removing family members with admin permissions

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edulift/core/domain/entities/family.dart';
import '../../providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../generated/l10n/app_localizations.dart';

class RemoveMemberConfirmationDialog extends ConsumerStatefulWidget {
  final FamilyMember member;
  final VoidCallback? onSuccess;

  const RemoveMemberConfirmationDialog({
    super.key,
    required this.member,
    this.onSuccess,
  });

  @override
  ConsumerState<RemoveMemberConfirmationDialog> createState() =>
      _RemoveMemberConfirmationDialogState();
}

class _RemoveMemberConfirmationDialogState
    extends ConsumerState<RemoveMemberConfirmationDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    return AlertDialog(
      title: Semantics(
        label: localizations.removeMemberDialogAccessibilityLabel,
        child: Row(
          children: [
            Icon(Icons.person_remove, color: theme.colorScheme.error, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                localizations.removeMember,
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
                    child: widget.member.role == FamilyRole.admin
                        ? Icon(
                            Icons.admin_panel_settings,
                            color: theme.colorScheme.onErrorContainer,
                            size: 20,
                          )
                        : Text(
                            widget.member.displayNameOrLoading.isNotEmpty
                                ? widget.member.displayNameOrLoading[0]
                                      .toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: theme.colorScheme.onErrorContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.member.displayNameOrLoading,
                          key: const Key('member_name'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.member.role.value,
                          key: const Key('member_role'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (widget.member.userEmail != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.member.userEmail!,
                            key: const Key('member_email'),
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
                          localizations.removeMemberConfirmation(
                            widget.member.displayNameOrLoading,
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                        if (widget.member.role == FamilyRole.admin) ...[
                          const SizedBox(height: 8),
                          Text(
                            localizations.removeAdminNote,
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
          key: const Key('remove_member_cancel_button'),
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(
            localizations.cancel,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        FilledButton(
          key: const Key('confirm_delete_button'),
          onPressed: _isLoading ? null : _handleRemoveMember,
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
          ),
          child: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.onError,
                    ),
                  ),
                )
              : Text(
                  localizations.removeMember,
                  style: TextStyle(color: theme.colorScheme.onError),
                ),
        ),
      ],
    );
  }

  Future<void> _handleRemoveMember() async {
    setState(() => _isLoading = true);
    try {
      final familyState = ref.read(familyComposedProvider);
      final familyId = familyState.family?.id;
      if (familyId == null) {
        throw Exception(AppLocalizations.of(context).noFamilyIdAvailable);
      }

      final familyNotifier = ref.read(familyComposedProvider.notifier);
      await familyNotifier.removeMember(
        familyId: familyId,
        memberId: widget.member.id,
      );
      if (mounted) {
        // Call success callback BEFORE pop to ensure parent context is valid
        widget.onSuccess?.call();
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      AppLogger.error('Failed to remove family member', e);
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).failedToRemoveMember(e.toString()),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
