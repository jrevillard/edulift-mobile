// EduLift Mobile - Family Invitation Management Widget
// Displays pending family invitations with admin actions
// Adapted to new architecture using FamilyInvitation entities

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_logger.dart';
import 'package:edulift/core/domain/entities/family.dart';
import '../../../../generated/l10n/app_localizations.dart';
// ARCHITECTURE FIX: Import through composition root
import '../../providers.dart';

/// Family Invitation Management Widget
/// Displays pending family invitations with admin actions
/// Uses FamilyProvider for invitation data
class FamilyInvitationManagementWidget extends ConsumerStatefulWidget {
  final bool isAdmin;
  final String familyId;

  const FamilyInvitationManagementWidget({
    super.key,
    required this.isAdmin,
    required this.familyId,
  });

  @override
  ConsumerState<FamilyInvitationManagementWidget> createState() =>
      _FamilyInvitationManagementWidgetState();
}

class _FamilyInvitationManagementWidgetState
    extends ConsumerState<FamilyInvitationManagementWidget> {
  // Admin permission getter - using provider for real-time permission checks
  bool get isAdmin {
    final admin = ref.watch(
      canPerformMemberActionsComposedProvider(widget.familyId),
    );
    return admin;
  }

  // Cache invitations to prevent unnecessary reloads
  List<FamilyInvitation>? _cachedInvitations;
  int? _lastFamilyStateHash;

  @override
  void initState() {
    super.initState();
    // Load initial family data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    // Force refresh family data and invitations
    ref.read(familyComposedProvider.notifier).loadFamily();
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to prevent rebuilds during resize
    return Consumer(
      builder: (context, ref, child) {
        // Only watch the specific provider we need, not the entire family state
        final familyState = ref.watch(familyComposedProvider);

        // Check if family state actually changed (not just resize)
        final currentFamilyStateHash = familyState.hashCode;
        final shouldReloadInvitations =
            _lastFamilyStateHash != currentFamilyStateHash;

        return FutureBuilder<List<FamilyInvitation>>(
          // Only refresh invitations when family state actually changes
          future: shouldReloadInvitations
              ? _loadAndCacheInvitations()
              : Future.value(_cachedInvitations ?? []),
          key: ValueKey(
            widget.familyId,
          ), // Use stable key instead of familyState.hashCode
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                shouldReloadInvitations) {
              return _buildLoadingState(context);
            }

            final invitations = snapshot.data ?? _cachedInvitations ?? [];
            final sortedInvitations = _getSortedInvitations(invitations);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                _buildHeader(context, sortedInvitations.length),

                const SizedBox(height: 16),

                // Invitations List
                if (sortedInvitations.isEmpty)
                  _buildEmptyState(context)
                else
                  _buildInvitationsList(context, sortedInvitations),

                // Extra space to avoid FAB overlap
                const SizedBox(height: 80),
              ],
            );
          },
        );
      },
    );
  }

  Future<List<FamilyInvitation>> _loadAndCacheInvitations() async {
    final familyState = ref.read(familyComposedProvider);
    _lastFamilyStateHash = familyState.hashCode;

    try {
      final invitations = await ref
          .read(familyComposedProvider.notifier)
          .getPendingInvitations();
      _cachedInvitations = invitations;
      return invitations;
    } catch (e) {
      AppLogger.error('Error loading invitations: $e');
      return _cachedInvitations ?? [];
    }
  }

  Widget _buildHeader(BuildContext context, int count) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Text(
      localizations.invitationsCount(count),
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.mail_outline,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                localizations.noInvitationsYet,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isAdmin
                    ? localizations.inviteMembersToStart
                    : localizations.checkBackLater,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvitationsList(
    BuildContext context,
    List<FamilyInvitation> invitations,
  ) {
    return Column(
      children: invitations
          .map((invitation) => _buildInvitationCard(context, invitation))
          .toList(),
    );
  }

  Widget _buildInvitationCard(
    BuildContext context,
    FamilyInvitation invitation,
  ) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final colorScheme = theme.colorScheme;
    final isExpired = invitation.isExpired;
    final daysUntilExpiration = invitation.expiresAt
        .difference(DateTime.now())
        .inDays;
    final isExpiringSoon = daysUntilExpiration <= 2 && daysUntilExpiration > 0;

    return Card(
      key: Key('invitation_card_${invitation.email}_${invitation.status.name}'),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),

        // Leading: Mail icon with status color (like member avatar)
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getStatusColor(
              invitation.status,
              isExpired,
              isExpiringSoon,
            ).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _getStatusColor(
                invitation.status,
                isExpired,
                isExpiringSoon,
              ).withValues(alpha: 0.3),
              width: 2.0,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.mail_outline,
              color: _getStatusColor(
                invitation.status,
                isExpired,
                isExpiringSoon,
              ),
              size: 20,
            ),
          ),
        ),

        // Title: Email address
        title: Text(
          invitation.email,
          key: Key('invitation_email_${invitation.email}'),
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),

        // Subtitle: Role + Status chip + Date (like member cards)
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),

            // Role and type info (like member email in member cards)
            Text(
              '${invitation.role.toUpperCase()} • FAMILY',
              key: Key(
                'invitation_role_${invitation.role.toUpperCase()}_${invitation.email}',
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 8),

            // Status chip and date row
            Row(
              children: [
                // Small status chip (like member role indicators)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      invitation.status,
                      isExpired,
                      isExpiringSoon,
                    ).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getStatusDisplayText(
                      invitation.status,
                      isExpired,
                      isExpiringSoon,
                    ),
                    key: Key(
                      'invitation_status_${invitation.status.name}_${invitation.email}',
                    ),
                    style: TextStyle(
                      color: _getStatusColor(
                        invitation.status,
                        isExpired,
                        isExpiringSoon,
                      ),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Date info
                Text(
                  _formatRelativeDate(context, invitation.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            // Additional message if present
            if (invitation.personalMessage != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '"${invitation.personalMessage}"',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),

        // Trailing: More actions button (admin only, like member cards)
        trailing: isAdmin
            ? IconButton(
                key: Key('invitation_more_vert_button_${invitation.email}'),
                onPressed: () => _showInvitationActions(invitation),
                icon: const Icon(Icons.more_vert),
                tooltip: localizations.invitationActionsTooltip(
                  invitation.email,
                ),
              )
            : null,

        // onTap: Make entire tile clickable (admin only, like member cards)
        onTap: isAdmin ? () => _showInvitationActions(invitation) : null,
      ),
    );
  }

  // Helper methods

  /// Show invitation actions in bottom sheet (like member actions)
  void _showInvitationActions(FamilyInvitation invitation) {
    AppLogger.debug(
      'FamilyInvitationManagementWidget: Showing invitation actions for ${invitation.id}',
    );

    final theme = Theme.of(context);
    final hasCode = _extractInvitationCode(invitation) != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final localizations = AppLocalizations.of(context);
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.invitationActions,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            invitation.email,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Actions
              if (hasCode) ...[
                ListTile(
                  key: Key('show_code_action_${invitation.email}'),
                  leading: const Icon(Icons.code),
                  title: Text(localizations.showInvitationCode),
                  subtitle: Text(localizations.displayInvitationCode),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showInvitationCodeDialog(invitation);
                  },
                ),
              ],

              ListTile(
                key: Key('cancel_invitation_action_${invitation.email}'),
                leading: Icon(Icons.close, color: theme.colorScheme.error),
                title: Text(
                  localizations.cancelInvitation,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                subtitle: Text(localizations.removeThisInvitation),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.of(context).pop();
                  _cancelInvitation(invitation.id);
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  List<FamilyInvitation> _getSortedInvitations(
    List<FamilyInvitation> invitations,
  ) {
    // Sort by creation date (newest first)
    final sorted = List<FamilyInvitation>.from(invitations);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  Future<void> _cancelInvitation(String invitationId) async {
    final localizations = AppLocalizations.of(context);
    try {
      await ref
          .read(familyComposedProvider.notifier)
          .cancelInvitation(invitationId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.invitationCancelledSuccessfully),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.failedToCancel(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Show invitation code in a dialog with copy/share functionality
  Future<void> _showInvitationCodeDialog(FamilyInvitation invitation) async {
    final localizations = AppLocalizations.of(context);
    // Extract the invitation code from the invitation link or ID
    final invitationCode = _extractInvitationCode(invitation);

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
        return AlertDialog(
          title: Text(localizations.invitationCode),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.codeForEmail(invitation.email),
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
                  key: Key('invitation_code_display_${invitation.email}'),
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
              key: Key('close_invitation_code_dialog_${invitation.email}'),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.close),
            ),
            TextButton(
              onPressed: () => _copyInvitationCode(invitationCode),
              child: Text(localizations.copyCode),
            ),
          ],
        );
      },
    );
  }

  /// Extract invitation code from invitation data
  String? _extractInvitationCode(FamilyInvitation invitation) {
    // Return the invitation code if available
    if (invitation.inviteCode.isNotEmpty) {
      return invitation.inviteCode.toUpperCase();
    }

    // Fallback to shortened invitation ID if no proper code is found
    return invitation.id.length > 8
        ? invitation.id.substring(0, 8).toUpperCase()
        : invitation.id.toUpperCase();
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

  Color _getStatusColor(
    InvitationStatus status,
    bool isExpired,
    bool isExpiringSoon,
  ) {
    if (isExpired) return Theme.of(context).colorScheme.error;
    if (isExpiringSoon) return Theme.of(context).colorScheme.secondary;

    switch (status) {
      case InvitationStatus.pending:
        return Theme.of(context).colorScheme.secondary;
      case InvitationStatus.accepted:
        return Theme.of(context).colorScheme.primary;
      case InvitationStatus.declined:
        return Theme.of(context).colorScheme.error;
      case InvitationStatus.expired:
        return Theme.of(context).colorScheme.error;
      case InvitationStatus.cancelled:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
      case InvitationStatus.revoked:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
      case InvitationStatus.failed:
        return Theme.of(context).colorScheme.error;
      case InvitationStatus.invalid:
        return Theme.of(context).colorScheme.error;
    }
  }

  String _getStatusDisplayText(
    InvitationStatus status,
    bool isExpired,
    bool isExpiringSoon,
  ) {
    final localizations = AppLocalizations.of(context);
    if (isExpired) return localizations.statusExpired;
    if (isExpiringSoon) return localizations.statusExpiringSoon;

    switch (status) {
      case InvitationStatus.pending:
        return localizations.statusPending;
      case InvitationStatus.accepted:
        return localizations.statusAccepted;
      case InvitationStatus.declined:
        return localizations.statusDeclined;
      case InvitationStatus.expired:
        return localizations.statusExpired;
      case InvitationStatus.cancelled:
        return localizations.statusCancelled;
      case InvitationStatus.revoked:
        return localizations.statusRevoked;
      case InvitationStatus.failed:
        return localizations.statusFailed;
      case InvitationStatus.invalid:
        return localizations.statusInvalid;
    }
  }

  String _formatRelativeDate(BuildContext context, DateTime date) {
    final localizations = AppLocalizations.of(context);
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return localizations.today;
    } else if (difference == 1) {
      return localizations.yesterday;
    } else if (difference < 7) {
      return localizations.daysAgo(difference);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
