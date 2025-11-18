// EduLift Mobile - Role Change Confirmation Dialog Widget
// Confirmation dialog for changing family member roles with admin permissions

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edulift/core/domain/entities/family.dart';
// ARCHITECTURE FIX: Use composition root instead
import '../../providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/presentation/utils/responsive_breakpoints.dart';

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
            size: context.getAdaptiveIconSize(
              mobile: 20,
              tablet: 22,
              desktop: 24,
            ),
          ),
          SizedBox(
            width: context.getAdaptiveSpacing(
              mobile: 8,
              tablet: 10,
              desktop: 12,
            ),
          ),
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
              padding: context.getAdaptivePadding(
                mobileAll: 12,
                tabletAll: 14,
                desktopAll: 16,
              ),
              decoration: BoxDecoration(
                color: widget.member.role == FamilyRole.admin
                    ? theme.colorScheme.errorContainer.withValues(alpha: 0.3)
                    : theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(
                  context.getAdaptiveBorderRadius(
                    mobile: 6,
                    tablet: 7,
                    desktop: 8,
                  ),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: widget.member.role == FamilyRole.admin
                        ? theme.colorScheme.errorContainer
                        : theme.colorScheme.primaryContainer,
                    radius: context.getAdaptiveIconSize(
                      mobile: 16,
                      tablet: 18,
                      desktop: 20,
                    ),
                    child: widget.member.role == FamilyRole.admin
                        ? Text(
                            widget.member.displayNameOrLoading.isNotEmpty
                                ? widget.member.displayNameOrLoading[0]
                                      .toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: theme.colorScheme.onErrorContainer,
                              fontWeight: FontWeight.bold,
                              fontSize: context.getAdaptiveFontSize(
                                mobile: 14,
                                tablet: 16,
                                desktop: 18,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.admin_panel_settings,
                            color: theme.colorScheme.onPrimaryContainer,
                            size: context.getAdaptiveIconSize(
                              mobile: 16,
                              tablet: 18,
                              desktop: 20,
                            ),
                          ),
                  ),
                  SizedBox(
                    width: context.getAdaptiveSpacing(
                      mobile: 10,
                      tablet: 11,
                      desktop: 12,
                    ),
                  ),
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
                        SizedBox(
                          height: context.getAdaptiveSpacing(
                            mobile: 1,
                            tablet: 1.5,
                            desktop: 2,
                          ),
                        ),
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
                              size: context.getAdaptiveIconSize(
                                mobile: 14,
                                tablet: 15,
                                desktop: 16,
                              ),
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
            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 12,
                tablet: 14,
                desktop: 16,
              ),
            ),
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
              SizedBox(
                height: context.getAdaptiveSpacing(
                  mobile: 10,
                  tablet: 11,
                  desktop: 12,
                ),
              ),
              Container(
                padding: context.getAdaptivePadding(
                  mobileAll: 10,
                  tabletAll: 11,
                  desktopAll: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(
                    context.getAdaptiveBorderRadius(
                      mobile: 6,
                      tablet: 7,
                      desktop: 8,
                    ),
                  ),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: context.getAdaptiveIconSize(
                        mobile: 14,
                        tablet: 15,
                        desktop: 16,
                      ),
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(
                      width: context.getAdaptiveSpacing(
                        mobile: 6,
                        tablet: 7,
                        desktop: 8,
                      ),
                    ),
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
              ? SizedBox(
                  width: context.getAdaptiveIconSize(
                    mobile: 14,
                    tablet: 15,
                    desktop: 16,
                  ),
                  height: context.getAdaptiveIconSize(
                    mobile: 14,
                    tablet: 15,
                    desktop: 16,
                  ),
                  child: CircularProgressIndicator(
                    strokeWidth: context.isMobile ? 1.5 : 2.0,
                  ),
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
