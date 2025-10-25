// EduLift Mobile - Role Change Confirmation Dialog Widget
// Confirmation dialog for changing family member roles with admin permissions

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edulift/core/domain/entities/family.dart';
// ARCHITECTURE FIX: Use composition root instead
import '../../providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../generated/l10n/app_localizations.dart';

class RoleChangeConfirmationDialog extends ConsumerStatefulWidget {
  final FamilyMember member;
  final VoidCallback? onSuccess;

  const RoleChangeConfirmationDialog({
    super.key,
    required this.member,
    this.onSuccess,
  });

  @override
  ConsumerState<RoleChangeConfirmationDialog> createState() =>
      _RoleChangeConfirmationDialogState();
}

class _RoleChangeConfirmationDialogState
    extends ConsumerState<RoleChangeConfirmationDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final newRole = widget.member.role == FamilyRole.admin
        ? FamilyRole.member
        : FamilyRole.admin;

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
              widget.member.role == FamilyRole.admin
                  ? localizations.removeAdminRole
                  : localizations.grantAdminRole,
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
                color: widget.member.role == FamilyRole.admin
                    ? theme.colorScheme.errorContainer.withValues(alpha: 0.3)
                    : theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: widget.member.role == FamilyRole.admin
                        ? theme.colorScheme.errorContainer
                        : theme.colorScheme.primaryContainer,
                    radius: 20,
                    child: widget.member.role == FamilyRole.admin
                        ? Text(
                            widget.member.displayNameOrLoading.isNotEmpty
                                ? widget.member.displayNameOrLoading[0]
                                    .toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: theme.colorScheme.onErrorContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Icon(
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
                          widget.member.displayNameOrLoading,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.member.role.value,
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
                                newRole.value,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: newRole == FamilyRole.admin
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurfaceVariant,
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
              widget.member.role == FamilyRole.admin
                  ? localizations.removeAdminConfirmation(
                      widget.member.displayNameOrLoading,
                    )
                  : localizations.makeAdminConfirmation(
                      widget.member.displayNameOrLoading,
                    ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (widget.member.role == FamilyRole.member) ...[
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
                        localizations.adminCanManageMembers,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('role_change_cancel_button'),
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(
            localizations.cancel,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        FilledButton(
          key: Key('role_change_confirm_button_${widget.member.role.value}'),
          onPressed: _isLoading ? null : _handleRoleChange,
          style: FilledButton.styleFrom(
            backgroundColor: widget.member.role == FamilyRole.admin
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  widget.member.role == FamilyRole.admin
                      ? localizations.removeAdmin
                      : localizations.makeAdmin,
                ),
        ),
      ],
    );
  }

  Future<void> _handleRoleChange() async {
    setState(() => _isLoading = true);
    try {
      final newRole = widget.member.role == FamilyRole.admin
          ? FamilyRole.member
          : FamilyRole.admin;

      final familyNotifier = ref.read(familyComposedProvider.notifier);
      await familyNotifier.updateMemberRole(
        memberId: widget.member.id,
        role: newRole,
      );
      if (mounted) {
        // Call success callback BEFORE pop to ensure parent context is valid
        widget.onSuccess?.call();
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      AppLogger.error('Failed to update member role', e);
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).failedToUpdateRole(e.toString()),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
