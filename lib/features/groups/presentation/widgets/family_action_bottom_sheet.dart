// EduLift Mobile - Family Action Bottom Sheet Widget
// Modal bottom sheet for displaying group family-specific actions based on role permissions

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/entities/groups/group_family.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/presentation/utils/responsive_breakpoints.dart';

class FamilyActionBottomSheet extends ConsumerWidget {
  final GroupFamily family;
  final VoidCallback? onPromoteToAdmin;
  final VoidCallback? onDemoteToMember;
  final VoidCallback? onRemoveFamily;
  final VoidCallback? onCancelInvitation;
  final VoidCallback? onShowInvitationCode;

  const FamilyActionBottomSheet({
    super.key,
    required this.family,
    this.onPromoteToAdmin,
    this.onDemoteToMember,
    this.onRemoveFamily,
    this.onCancelInvitation,
    this.onShowInvitationCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    // Determine avatar icon based on role
    IconData roleIcon;
    Color iconColor;
    Color bgColor;

    if (family.isPending) {
      roleIcon = Icons.schedule;
      iconColor = theme.colorScheme.onSecondaryContainer;
      bgColor = theme.colorScheme.secondaryContainer;
    } else {
      switch (family.role) {
        case GroupFamilyRole.owner:
          roleIcon = Icons.star;
          iconColor = theme.colorScheme.onPrimaryContainer;
          bgColor = theme.colorScheme.primaryContainer;
          break;
        case GroupFamilyRole.admin:
          roleIcon = Icons.admin_panel_settings;
          iconColor = theme.colorScheme.onPrimaryContainer;
          bgColor = theme.colorScheme.primaryContainer;
          break;
        case GroupFamilyRole.member:
          roleIcon = Icons.person;
          iconColor = theme.colorScheme.onSecondaryContainer;
          bgColor = theme.colorScheme.secondaryContainer;
          break;
        default:
          roleIcon = Icons.person;
          iconColor = theme.colorScheme.onSecondaryContainer;
          bgColor = theme.colorScheme.secondaryContainer;
      }
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: context.getAdaptivePadding(
                mobileAll: 20,
                tabletAll: 24,
                desktopAll: 28,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: bgColor,
                        child: Icon(
                          roleIcon,
                          color: iconColor,
                          size: context.getAdaptiveIconSize(
                            mobile: 18,
                            tablet: 20,
                            desktop: 22,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: context.getAdaptiveSpacing(
                          mobile: 12,
                          tablet: 16,
                          desktop: 20,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              family.name,
                              style: theme.textTheme.titleLarge,
                            ),
                            Text(
                              family.isPending
                                  ? localizations.pendingInvitation
                                  : family.role.name.toUpperCase(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Divider(
              height: context.getAdaptiveSpacing(
                mobile: 0.5,
                tablet: 1,
                desktop: 1,
              ),
            ),

            // Actions List
            if (family.isPending) ...[
              // PENDING invitation: show invitation code and cancel actions
              if (onShowInvitationCode != null)
                ListTile(
                  key: Key('show_code_action_${family.name}'),
                  leading: Icon(
                    Icons.code,
                    size: context.getAdaptiveIconSize(
                      mobile: 18,
                      tablet: 20,
                      desktop: 22,
                    ),
                  ),
                  title: Text(localizations.showInvitationCode),
                  subtitle: Text(localizations.displayInvitationCode),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: context.getAdaptiveIconSize(
                      mobile: 14,
                      tablet: 16,
                      desktop: 18,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    onShowInvitationCode?.call();
                  },
                ),
              if (onCancelInvitation != null)
                ListTile(
                  key: Key('cancel_invitation_action_${family.name}'),
                  leading: Icon(
                    Icons.cancel,
                    color: theme.colorScheme.error,
                    size: context.getAdaptiveIconSize(
                      mobile: 18,
                      tablet: 20,
                      desktop: 22,
                    ),
                  ),
                  title: Text(
                    localizations.cancelInvitation,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  subtitle: Text(localizations.cancelInvitationDescription),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: context.getAdaptiveIconSize(
                      mobile: 14,
                      tablet: 16,
                      desktop: 18,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    onCancelInvitation?.call();
                  },
                ),
            ] else ...[
              // Active family: show role management actions
              if (onPromoteToAdmin != null)
                ListTile(
                  key: Key('promote_to_admin_action_${family.name}'),
                  leading: Icon(
                    Icons.arrow_upward,
                    size: context.getAdaptiveIconSize(
                      mobile: 18,
                      tablet: 20,
                      desktop: 22,
                    ),
                  ),
                  title: Text(localizations.promoteToAdmin),
                  subtitle: Text(localizations.promoteToAdminDescription),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: context.getAdaptiveIconSize(
                      mobile: 14,
                      tablet: 16,
                      desktop: 18,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    onPromoteToAdmin?.call();
                  },
                ),
              if (onDemoteToMember != null)
                ListTile(
                  key: Key('demote_to_member_action_${family.name}'),
                  leading: Icon(
                    Icons.arrow_downward,
                    size: context.getAdaptiveIconSize(
                      mobile: 18,
                      tablet: 20,
                      desktop: 22,
                    ),
                  ),
                  title: Text(localizations.demoteToMember),
                  subtitle: Text(localizations.demoteToMemberDescription),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: context.getAdaptiveIconSize(
                      mobile: 14,
                      tablet: 16,
                      desktop: 18,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    onDemoteToMember?.call();
                  },
                ),

              // Dangerous actions section
              Divider(
                height: context.getAdaptiveSpacing(
                  mobile: 0.5,
                  tablet: 1,
                  desktop: 1,
                ),
              ),

              if (onRemoveFamily != null)
                ListTile(
                  key: Key('remove_family_action_${family.name}'),
                  leading: Icon(
                    Icons.person_remove,
                    color: theme.colorScheme.error,
                    size: context.getAdaptiveIconSize(
                      mobile: 18,
                      tablet: 20,
                      desktop: 22,
                    ),
                  ),
                  title: Text(
                    localizations.removeFromGroup,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  subtitle: Text(
                    localizations.removeFamilyFromGroupDescription,
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: context.getAdaptiveIconSize(
                      mobile: 14,
                      tablet: 16,
                      desktop: 18,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    onRemoveFamily?.call();
                  },
                ),
            ],

            // Bottom padding for safe area
            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 12,
                tablet: 16,
                desktop: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
