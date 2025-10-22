// EduLift Mobile - Leave Group Confirmation Dialog Widget
// Confirmation dialog for members to leave the group

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/entities/groups/group.dart';
import '../../providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../generated/l10n/app_localizations.dart';

class LeaveGroupConfirmationDialog extends ConsumerStatefulWidget {
  final String groupId;
  final String groupName;
  final GroupMemberRole userRole;
  final VoidCallback? onSuccess;

  const LeaveGroupConfirmationDialog({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.userRole,
    this.onSuccess,
  });

  @override
  ConsumerState<LeaveGroupConfirmationDialog> createState() =>
      _LeaveGroupConfirmationDialogState();
}

class _LeaveGroupConfirmationDialogState
    extends ConsumerState<LeaveGroupConfirmationDialog> {
  bool _isLoading = false;
  final TextEditingController _confirmationController = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _confirmationController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  void _validateInput() {
    setState(() {
      _isValid = _confirmationController.text.trim() == widget.groupName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.exit_to_app, color: theme.colorScheme.error, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.leaveGroupTitle,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.groups,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.groupName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.youAreLeavingAs(_roleToString(widget.userRole)),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber,
                        size: 20,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.actionCannotBeUndone,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.byLeavingGroupYouWill,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.loseAccessGroupSchedules,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                        Text(
                          l10n.noLongerSeeGroupMembers,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                        if (widget.userRole == GroupMemberRole.admin)
                          Text(
                            l10n.giveUpGroupAdminPrivileges,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (widget.userRole == GroupMemberRole.owner) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        l10n.ownerFamilyCannotLeave,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.typeNameToConfirm(widget.groupName),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmationController,
              decoration: InputDecoration(
                hintText: widget.groupName,
                border: const OutlineInputBorder(),
                errorText: _confirmationController.text.isNotEmpty && !_isValid
                    ? l10n.pleaseTypeNameExactly(widget.groupName)
                    : null,
              ),
              onChanged: (value) => _validateInput(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(
            l10n.cancel,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        FilledButton(
          onPressed: _isLoading || !_isValid ? null : _handleLeaveGroup,
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            disabledBackgroundColor: theme.colorScheme.onSurface.withValues(
              alpha: 0.12,
            ),
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
                  l10n.leaveGroupTitle,
                  style: const TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }

  Future<void> _handleLeaveGroup() async {
    setState(() => _isLoading = true);
    try {
      final groupsNotifier = ref.read(groupsComposedProvider.notifier);
      final success = await groupsNotifier.leaveGroup(widget.groupId);

      if (mounted) {
        if (success) {
          // Call success callback BEFORE pop to ensure parent context is valid
          widget.onSuccess?.call();
          Navigator.of(context).pop(true);
        } else {
          // Error is stored in state, show it to user
          setState(() => _isLoading = false);
          final error =
              ref.read(groupsComposedProvider).error ?? 'Unknown error';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).failedToLeaveGroup(error),
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.error('Failed to leave group', e);
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).failedToLeaveGroup(e.toString()),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  String _roleToString(GroupMemberRole role) {
    switch (role) {
      case GroupMemberRole.owner:
        return 'Owner';
      case GroupMemberRole.admin:
        return 'Admin';
      case GroupMemberRole.member:
        return 'Member';
    }
  }
}
