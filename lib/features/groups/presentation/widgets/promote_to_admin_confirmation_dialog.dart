// EduLift Mobile - Promote to Admin Confirmation Dialog Widget
// Confirmation dialog for promoting a family to group admin role

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/entities/groups/group_family.dart';
import '../../../../core/presentation/utils/responsive_breakpoints.dart';
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
            size: context.getAdaptiveIconSize(
              mobile: 22,
              tablet: 24,
              desktop: 26,
            ),
          ),
          SizedBox(
            width: context.getAdaptiveSpacing(
              mobile: 10,
              tablet: 12,
              desktop: 14,
            ),
          ),
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
              padding: context.getAdaptivePadding(
                mobileAll: 12,
                tabletAll: 16,
                desktopAll: 20,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(
                  context.getAdaptiveBorderRadius(
                    mobile: 6,
                    tablet: 8,
                    desktop: 10,
                  ),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    radius:
                        context.getAdaptiveIconSize(
                          mobile: 18,
                          tablet: 20,
                          desktop: 22,
                        ) *
                        0.9,
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: context.getAdaptiveIconSize(
                        mobile: 18,
                        tablet: 20,
                        desktop: 22,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: context.getAdaptiveSpacing(
                      mobile: 10,
                      tablet: 12,
                      desktop: 14,
                    ),
                  ),
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
                        SizedBox(
                          height: context.getAdaptiveSpacing(
                            mobile: 1,
                            tablet: 2,
                            desktop: 3,
                          ),
                        ),
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
                              size: context.getAdaptiveIconSize(
                                mobile: 14,
                                tablet: 16,
                                desktop: 18,
                              ),
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
            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 14,
                tablet: 16,
                desktop: 18,
              ),
            ),
            Text(
              localizations.promoteToAdminConfirmation(widget.family.name),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 10,
                tablet: 12,
                desktop: 14,
              ),
            ),
            Container(
              padding: context.getAdaptivePadding(
                mobileAll: 10,
                tabletAll: 12,
                desktopAll: 14,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(
                  context.getAdaptiveBorderRadius(
                    mobile: 6,
                    tablet: 8,
                    desktop: 10,
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
                      tablet: 16,
                      desktop: 18,
                    ),
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(
                    width: context.getAdaptiveSpacing(
                      mobile: 6,
                      tablet: 8,
                      desktop: 10,
                    ),
                  ),
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
