// EduLift Mobile - Group Members Management Page
// Mobile-first responsive page for managing families within a group

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/presentation/utils/responsive_breakpoints.dart';
import '../../../../core/domain/entities/groups/group_family.dart';
import '../../../../core/domain/entities/groups/group.dart';
import '../../../../core/di/providers/providers.dart';
import '../providers/group_families_provider.dart';
import '../../providers.dart' as groups_providers;
import 'invite_family_page.dart';
import '../widgets/family_action_bottom_sheet.dart';
import '../widgets/promote_to_admin_confirmation_dialog.dart';
import '../widgets/demote_to_member_confirmation_dialog.dart';
import '../widgets/remove_family_confirmation_dialog.dart';
import '../widgets/cancel_invitation_confirmation_dialog.dart';
import 'package:intl/intl.dart';
import '../../../../core/presentation/mixins/navigation_cleanup_mixin.dart';

export 'group_members_management_page.dart'
    show updateFamilyRole, removeFamilyFromGroup, cancelInvitation;

/// Group Members Management Page
///
/// Displays and manages families (members) within a group with:
/// - Mobile-first responsive design (1/2/3 column grid)
/// - Role-based permissions (OWNER, ADMIN, MEMBER, PENDING)
/// - Family management actions (promote, demote, remove)
/// - Invitation management (cancel pending invitations)
/// - Pull-to-refresh support
/// - Real-time state updates
class GroupMembersManagementPage extends ConsumerStatefulWidget {
  final String groupId;
  final String groupName;

  const GroupMembersManagementPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  ConsumerState<GroupMembersManagementPage> createState() =>
      _GroupMembersManagementPageState();
}

class _GroupMembersManagementPageState
    extends ConsumerState<GroupMembersManagementPage>
    with NavigationCleanupMixin {
  // NavigationCleanupMixin automatically clears navigation state in initState

  Future<void> _handleRefresh() async {
    // Invalidate provider to trigger refresh
    ref.invalidate(groupFamiliesProvider(widget.groupId));
    // Wait for the new data to load
    await ref.read(groupFamiliesProvider(widget.groupId).future);
  }

  void _showFamilyActions(GroupFamily family) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FamilyActionBottomSheet(
        family: family,
        onPromoteToAdmin: family.canPromote
            ? () => _showPromoteToAdminConfirmation(family)
            : null,
        onDemoteToMember: family.canDemote
            ? () => _showDemoteToMemberConfirmation(family)
            : null,
        onRemoveFamily: family.canRemove
            ? () => _showRemoveFamilyConfirmation(family)
            : null,
        onShowInvitationCode: family.isPending && family.inviteCode != null
            ? () => _showInvitationCodeDialog(family)
            : null,
        onCancelInvitation: family.isPending
            ? () => _showCancelInvitationConfirmation(family)
            : null,
      ),
    );
  }

  void _showPromoteToAdminConfirmation(GroupFamily family) {
    showDialog(
      context: context,
      builder: (context) => PromoteToAdminConfirmationDialog(
        family: family,
        groupId: widget.groupId,
        onSuccess: () {
          if (mounted) {
            _showSuccessSnackBar(
              AppLocalizations.of(context).familyPromotedSuccess,
            );
            ref.invalidate(groupFamiliesProvider(widget.groupId));
          }
        },
      ),
    );
  }

  void _showDemoteToMemberConfirmation(GroupFamily family) {
    showDialog(
      context: context,
      builder: (context) => DemoteToMemberConfirmationDialog(
        family: family,
        groupId: widget.groupId,
        onSuccess: () {
          if (mounted) {
            _showSuccessSnackBar(
              AppLocalizations.of(context).familyDemotedSuccess,
            );
            ref.invalidate(groupFamiliesProvider(widget.groupId));
          }
        },
      ),
    );
  }

  void _showRemoveFamilyConfirmation(GroupFamily family) {
    showDialog(
      context: context,
      builder: (context) => RemoveFamilyConfirmationDialog(
        family: family,
        groupId: widget.groupId,
        onSuccess: () {
          if (mounted) {
            _showSuccessSnackBar(
              AppLocalizations.of(context).familyRemovedSuccess,
            );
            ref.invalidate(groupFamiliesProvider(widget.groupId));
          }
        },
      ),
    );
  }

  void _showCancelInvitationConfirmation(GroupFamily family) {
    showDialog(
      context: context,
      builder: (context) => CancelInvitationConfirmationDialog(
        family: family,
        groupId: widget.groupId,
        onSuccess: () {
          if (mounted) {
            _showSuccessSnackBar(
              AppLocalizations.of(context).invitationCanceledSuccess,
            );
            ref.invalidate(groupFamiliesProvider(widget.groupId));
          }
        },
      ),
    );
  }

  /// Show invitation code dialog
  Future<void> _showInvitationCodeDialog(GroupFamily family) async {
    final localizations = AppLocalizations.of(context);
    final invitationCode = family.inviteCode;

    if (invitationCode == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.invitationCodeNotAvailable),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return;
    }

    await showDialog(
      context: context,
      builder: (context) {
        final localizations = AppLocalizations.of(context);
        // Get first admin email for display
        final adminEmail = family.admins.isNotEmpty
            ? family.admins.first.email
            : localizations.noAdmins;

        return AlertDialog(
          title: Text(localizations.invitationCode),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.codeForEmail(adminEmail),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: SelectableText(
                  invitationCode,
                  key: Key('invitation_code_display_${family.id}'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              key: Key('close_invitation_code_dialog_${family.id}'),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.close),
            ),
            TextButton(
              key: Key('copy_invitation_code_${family.id}'),
              onPressed: () => _copyInvitationCode(invitationCode),
              child: Text(localizations.copyCode),
            ),
          ],
        );
      },
    );
  }

  /// Copy invitation code to clipboard
  Future<void> _copyInvitationCode(String code) async {
    final localizations = AppLocalizations.of(context);
    try {
      await Clipboard.setData(ClipboardData(text: code));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.invitationCodeCopied),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.failedToCopyCode(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToInviteFamily() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => InviteFamilyPage(groupId: widget.groupId),
          ),
        )
        .then((_) {
          // Refresh the families list after returning from invitation flow
          ref.invalidate(groupFamiliesProvider(widget.groupId));
        });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final familiesAsync = ref.watch(groupFamiliesProvider(widget.groupId));

    // SECURITY: Get isAdmin from provider (SINGLE SOURCE OF TRUTH)
    // Never trust URL query parameters for permissions!
    final groupsState = ref.watch(groups_providers.groupsComposedProvider);
    final isAdmin = () {
      try {
        final group = groupsState.groups.firstWhere(
          (g) => g.id == widget.groupId,
        );
        final userRole = group.userRole;
        return userRole == GroupMemberRole.admin ||
            userRole == GroupMemberRole.owner;
      } catch (e) {
        return false; // Default to non-admin if group not found
      }
    }();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.groupMembersPageTitle(widget.groupName)),
        elevation: 0,
      ),
      body: RefreshIndicator(
        key: const Key('groupMembers_refreshIndicator'),
        onRefresh: _handleRefresh,
        child: familiesAsync.when(
          data: (families) {
            if (families.isEmpty) {
              return _buildEmptyState();
            }

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.isTablet ? 24 : 16,
                    vertical:
                        context.isMobile &&
                            MediaQuery.of(context).size.width < 375
                        ? 3
                        : 4,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final family = families[index];
                      return _buildFamilyCard(family, theme, colorScheme);
                    }, childCount: families.length),
                  ),
                ),
              ],
            );
          },
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(error),
        ),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              key: const Key('invite_family_fab'),
              onPressed: _navigateToInviteFamily,
              icon: const Icon(Icons.person_add),
              label: Text(l10n.inviteFamily),
            )
          : null,
    );
  }

  Widget _buildFamilyCard(
    GroupFamily family,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final l10n = AppLocalizations.of(context);

    // Determine badge color and text based on role
    Color badgeColor;
    Color badgeTextColor;
    String badgeText;
    IconData roleIcon;

    switch (family.role) {
      case GroupFamilyRole.owner:
        badgeColor = colorScheme.error;
        badgeTextColor = colorScheme.onError;
        badgeText = l10n.roleOwner;
        roleIcon = Icons.shield;
        break;
      case GroupFamilyRole.admin:
        badgeColor = colorScheme.primary;
        badgeTextColor = colorScheme.onPrimary;
        badgeText = l10n.roleAdmin;
        roleIcon = Icons.shield;
        break;
      case GroupFamilyRole.member:
        badgeColor = colorScheme.secondaryContainer;
        badgeTextColor = colorScheme.onSecondaryContainer;
        badgeText = l10n.roleMember;
        roleIcon = Icons.person;
        break;
      case GroupFamilyRole.pending:
        badgeColor = Colors.orange.shade100;
        badgeTextColor = Colors.orange.shade900;
        badgeText = l10n.rolePending;
        roleIcon = Icons.mail_outline;
        break;
    }

    // Format admin names
    String adminText;
    if (family.admins.isEmpty) {
      adminText = l10n.noAdmins;
    } else if (family.admins.length == 1) {
      adminText = family.admins[0].name;
    } else {
      adminText = l10n.adminCountMore(
        family.admins[0].name,
        family.admins.length - 1,
      );
    }

    // Format expiration date for pending invitations
    String? expirationText;
    if (family.isPending && family.expiresAt != null) {
      final formatter = DateFormat('MMM d, yyyy');
      expirationText = l10n.expiresOn(formatter.format(family.expiresAt!));
    }

    // UNIFIED DESIGN: Using ListTile pattern consistent with Family Management
    return Card(
      key: Key('family_card_${family.id}'),
      elevation: 0,
      color: family.isMyFamily
          ? colorScheme.primaryContainer.withValues(alpha: 0.3)
          : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: family.isMyFamily
              ? colorScheme.primary.withValues(alpha: 0.5)
              : colorScheme.outline.withValues(alpha: 0.1),
          width: family.isMyFamily ? 1.5 : 1.0,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // Avatar (48x48 round, consistent with Family)
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: family.isPending
                ? Colors.orange.shade100
                : colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(24), // Round avatar
            border: family.isMyFamily
                ? Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.6),
                    width: 2.0,
                  )
                : null,
          ),
          child: Icon(
            roleIcon,
            size: 20,
            color: family.isPending
                ? Colors.orange.shade700
                : colorScheme.primary,
          ),
        ),
        // Title: Family name + "Your Family" badge
        title: Row(
          children: [
            Flexible(
              child: Text(
                family.name,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (family.isMyFamily) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.yourFamily,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        // Subtitle: Role badge + Admin info + Expiration
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            // Badges: Show both status and role for pending invitations
            if (family.isPending)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  // Pending status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      l10n.rolePending,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Role badge (ADMIN or MEMBER)
                  if (family.role != GroupFamilyRole.pending)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badgeText,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: badgeTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              )
            else
              // Single role badge for non-pending
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: badgeTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            // Admin info (not for pending)
            if (!family.isPending) ...[
              const SizedBox(height: 4),
              Text(
                adminText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
            // Expiration (for pending only)
            if (expirationText != null) ...[
              const SizedBox(height: 4),
              Text(
                expirationText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ],
        ),
        // Trailing: Actions menu (24px icon, consistent)
        trailing: family.canManage
            ? IconButton(
                key: Key('family_actions_${family.id}'),
                icon: const Icon(Icons.more_vert),
                iconSize: 24,
                onPressed: () => _showFamilyActions(family),
              )
            : null,
        // onTap: Show details only if can manage (like Family Management)
        onTap: family.canManage ? () => _showFamilyActions(family) : null,
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noFamiliesYet,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.inviteFamiliesToGetStarted,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            l10n.loadingFamilies,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.failedToLoadFamilies,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              key: const Key('groupMembers_retry_button'),
              onPressed: _handleRefresh,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

// Global helper functions for dialog actions
// These are called by the confirmation dialogs to perform API actions
// Returns true on success, false on failure (error message returned via out parameter)

Future<bool> updateFamilyRole({
  required BuildContext context,
  required WidgetRef ref,
  required String groupId,
  required String familyId,
  required String newRole,
  required void Function(String errorMessage) onError,
}) async {
  final repository = ref.read(groupRepositoryProvider);
  final result = await repository.updateFamilyRole(groupId, familyId, {
    'role': newRole.toUpperCase(),
  });

  return result.when(
    ok: (_) => true,
    err: (failure) {
      onError(failure.message ?? 'Failed to update role');
      return false;
    },
  );
}

Future<bool> removeFamilyFromGroup({
  required BuildContext context,
  required WidgetRef ref,
  required String groupId,
  required String familyId,
  required void Function(String errorMessage) onError,
}) async {
  final repository = ref.read(groupRepositoryProvider);
  final result = await repository.removeFamilyFromGroup(groupId, familyId);

  return result.when(
    ok: (_) => true,
    err: (failure) {
      onError(failure.message ?? 'Failed to remove family');
      return false;
    },
  );
}

Future<bool> cancelInvitation({
  required BuildContext context,
  required WidgetRef ref,
  required String groupId,
  required String invitationId,
  required void Function(String errorMessage) onError,
}) async {
  final repository = ref.read(groupRepositoryProvider);
  final result = await repository.cancelInvitation(groupId, invitationId);

  return result.when(
    ok: (_) => true,
    err: (failure) {
      onError(failure.message ?? 'Failed to cancel invitation');
      return false;
    },
  );
}
