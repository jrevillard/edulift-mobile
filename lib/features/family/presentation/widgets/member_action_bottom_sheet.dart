// EduLift Mobile - Member Action Bottom Sheet Widget
// Modal bottom sheet for displaying member-specific actions based on role permissions

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edulift/core/domain/entities/family.dart';
import '../../../../core/services/providers/auth_provider.dart';
import '../../../../generated/l10n/app_localizations.dart';

class MemberActionBottomSheet extends ConsumerWidget {
  final FamilyMember member;
  final VoidCallback? onViewDetails;
  final VoidCallback? onChangeRole;
  final VoidCallback? onRemoveMember;
  final VoidCallback? onLeaveFamily;
  final bool canManageRoles;

  const MemberActionBottomSheet({
    super.key,
    required this.member,
    this.onViewDetails,
    this.onChangeRole,
    this.onRemoveMember,
    this.onLeaveFamily,
    required this.canManageRoles,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final currentUser = ref.read(authStateProvider).user;
    final isCurrentUser = currentUser?.id == member.userId;

    // Debug logging
    debugPrint(
      '🔍 MemberActionBottomSheet: ${member.displayNameOrLoading} (${member.role.value})',
    );
    debugPrint('   canManageRoles=$canManageRoles (passed as parameter)');
    debugPrint(
      '   onChangeRole=${onChangeRole != null}, willShow=${canManageRoles && onChangeRole != null}',
    );

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
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: member.role == FamilyRole.admin
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.secondaryContainer,
                        child: member.role == FamilyRole.admin
                            ? Icon(
                                Icons.admin_panel_settings,
                                color: theme.colorScheme.onPrimaryContainer,
                                size: 20,
                              )
                            : Text(
                                member.displayNameOrLoading.isNotEmpty
                                    ? member.displayNameOrLoading[0]
                                        .toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  color: theme.colorScheme.onSecondaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.displayNameOrLoading,
                              style: theme.textTheme.titleLarge,
                            ),
                            Text(
                              member.role.value,
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

            const Divider(height: 1),

            // Actions List
            if (canManageRoles && onChangeRole != null) ...[
              ListTile(
                key: Key(
                  'member_role_action_${member.role.value.toLowerCase()}',
                ),
                leading: const Icon(Icons.admin_panel_settings),
                title: Text(
                  member.role == FamilyRole.admin
                      ? localizations.removeAdminRole
                      : localizations.makeAdmin,
                ),
                subtitle: Text(
                  member.role == FamilyRole.admin
                      ? localizations.demoteFromAdmin
                      : localizations.promoteToAdmin,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.of(context).pop();
                  onChangeRole?.call();
                },
              ),
            ],

            if (onViewDetails != null)
              ListTile(
                key: const Key('member_view_details_action'),
                leading: const Icon(Icons.person),
                title: Text(localizations.viewMemberDetails),
                subtitle: Text(localizations.seeMemberInformation),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.of(context).pop();
                  onViewDetails?.call();
                },
              ),

            // Dangerous actions section
            const Divider(),

            if (isCurrentUser && onLeaveFamily != null) ...[
              ListTile(
                key: const Key('member_leave_family_action'),
                leading: Icon(
                  Icons.exit_to_app,
                  color: theme.colorScheme.error,
                ),
                title: Text(
                  localizations.leaveFamily,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                subtitle: Text(localizations.removeYourselfFromFamily),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.of(context).pop();
                  onLeaveFamily?.call();
                },
              ),
            ] else if (!isCurrentUser && onRemoveMember != null) ...[
              ListTile(
                key: const Key('delete_member_action'),
                leading: Icon(
                  Icons.person_remove,
                  color: theme.colorScheme.error,
                ),
                title: Text(
                  localizations.removeMember,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                subtitle: Text(localizations.removeMemberFromFamily),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.of(context).pop();
                  onRemoveMember?.call();
                },
              ),
            ],

            // Bottom padding for safe area
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
