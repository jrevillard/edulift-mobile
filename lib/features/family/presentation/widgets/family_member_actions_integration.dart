// EduLift Mobile - Family Member Actions Integration
// Comprehensive example showing how to integrate all member action widgets

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';

import 'package:edulift/core/domain/entities/family.dart';
import '../../providers.dart';
import '../../../../core/services/providers/auth_provider.dart';
import 'member_action_bottom_sheet.dart';
import 'role_change_confirmation_dialog.dart';
import 'remove_member_confirmation_dialog.dart';
import 'leave_family_confirmation_dialog.dart';
import 'invite_member_widget.dart';

/// Integration example showing how to use all family member action widgets
class FamilyMemberActionsIntegration extends ConsumerWidget {
  const FamilyMemberActionsIntegration({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyState = ref.watch(familyComposedProvider);
    final currentUser = ref.watch(authStateProvider).user;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).familyMemberActions)),
      body: familyState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : familyState.family == null
              ? Center(child: Text(AppLocalizations.of(context).noFamilyFound))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Invite Member Widget (Admin only)
                      if (_isCurrentUserAdmin(
                        familyState.family!.members,
                        currentUser?.id,
                      )) ...[
                        Text(
                          AppLocalizations.of(context).inviteNewMember,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        InviteMemberWidget(
                          onInvitationSent: () {
                            // Refresh family data after invitation
                            ref.read(familyComposedProvider.notifier).loadFamily();
                          },
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Family Members List
                      Text(
                        AppLocalizations.of(context).familyMembers,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),

                      ...familyState.family!.members.map(
                        (member) => _buildMemberCard(context, ref, member, currentUser?.id),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildMemberCard(
    BuildContext context,
    WidgetRef ref,
    FamilyMember member,
    String? currentUserId,
  ) {
    final theme = Theme.of(context);
    final isCurrentUser = currentUserId == member.userId;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
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
                      ? member.displayNameOrLoading[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                member.displayNameOrLoading,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isCurrentUser)
              Chip(
                label: Text(AppLocalizations.of(context).you),
                backgroundColor: theme.colorScheme.primaryContainer,
                labelStyle: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              member.role.value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (member.userEmail != null)
              Text(
                member.userEmail!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showMemberActions(context, ref, member),
        ),
      ),
    );
  }

  void _showMemberActions(
    BuildContext context,
    WidgetRef ref,
    FamilyMember member,
  ) {
    final currentUser = ref.read(authStateProvider).user;
    final isCurrentUser = currentUser?.id == member.userId;
    final permissionProvider = ref.read(familyPermissionComposedProvider);
    final canManageRoles = permissionProvider.canManageMembers && !isCurrentUser;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => MemberActionBottomSheet(
        member: member,
        canManageRoles: canManageRoles,
        onViewDetails: () => _showMemberDetails(context, member),
        onChangeRole: () => _showRoleChangeConfirmation(context, member),
        onRemoveMember: () => _showRemoveMemberConfirmation(context, member),
        onLeaveFamily: () => _showLeaveFamilyConfirmation(context, member),
      ),
    );
  }

  void _showMemberDetails(BuildContext context, FamilyMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).memberDetails),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(AppLocalizations.of(context).name, member.displayNameOrLoading),
            _buildDetailRow(AppLocalizations.of(context).role, member.role.value),
            if (member.userEmail != null)
              _buildDetailRow(AppLocalizations.of(context).email, member.userEmail!),
            _buildDetailRow(AppLocalizations.of(context).joined, _formatJoinDate(context, member.joinedAt)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).close),
          ),
        ],
      ),
    );
  }

  void _showRoleChangeConfirmation(BuildContext context, FamilyMember member) {
    showDialog(
      context: context,
      builder: (context) => RoleChangeConfirmationDialog(member: member),
    );
  }

  void _showRemoveMemberConfirmation(
    BuildContext context,
    FamilyMember member,
  ) {
    showDialog(
      context: context,
      builder: (context) => RemoveMemberConfirmationDialog(member: member),
    );
  }

  void _showLeaveFamilyConfirmation(BuildContext context, FamilyMember member) {
    showDialog(
      context: context,
      builder: (context) => LeaveFamilyConfirmationDialog(member: member),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatJoinDate(BuildContext context, DateTime joinedAt) {
    return '${joinedAt.day}/${joinedAt.month}/${joinedAt.year}';
  }

  bool _isCurrentUserAdmin(List<FamilyMember> members, String? currentUserId) {
    if (currentUserId == null) return false;

    final currentMember = members.where((m) => m.userId == currentUserId).firstOrNull;
    return currentMember?.role == FamilyRole.admin;
  }
}