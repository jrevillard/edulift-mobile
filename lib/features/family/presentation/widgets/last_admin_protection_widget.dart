// EduLift Mobile - Last Admin Protection Widget
// Prevents last admin from leaving or being removed without proper succession

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/presentation/widgets/accessibility/accessible_button.dart';
import '../../../../core/presentation/themes/app_colors.dart';
// unused import removed
import 'package:edulift/core/domain/entities/family.dart' as entity;
import 'package:edulift/core/domain/entities/family.dart';
// ARCHITECTURE FIX: Use composition root instead
import '../../providers.dart';

/// Widget for protecting last admin operations
class LastAdminProtectionWidget extends ConsumerWidget {
  final entity.Family family;
  final FamilyMember currentUser;
  final VoidCallback? onProtectionBypassed;

  const LastAdminProtectionWidget({
    super.key,
    required this.family,
    required this.currentUser,
    this.onProtectionBypassed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    // Check if user is the last admin
    final adminCount = family.members
        .where((m) => m.role == FamilyRole.admin)
        .length;
    final isLastAdmin = currentUser.role == FamilyRole.admin && adminCount == 1;

    if (!isLastAdmin) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.warningContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.warning, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.admin_panel_settings,
                color: theme.colorScheme.onWarningContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  localizations.lastAdminProtection,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onWarningContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            localizations.lastAdminWarning,
            style: TextStyle(color: theme.colorScheme.onWarningContainer),
          ),
          const SizedBox(height: 16),

          // Options
          _buildProtectionOptions(context, ref),
        ],
      ),
    );
  }

  Widget _buildProtectionOptions(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          localizations.availableOptions,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onWarningContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Option 1: Promote another member
        if (family.members.length > 1) ...[
          _ProtectionOptionCard(
            icon: Icons.person_add,
            title: localizations.promoteAnotherAdmin,
            description: localizations.promoteAnotherAdminDesc,
            onTap: () => _showPromoteMemberDialog(context, ref),
          ),
          const SizedBox(height: 8),
        ],

        // Option 2: Transfer ownership
        _ProtectionOptionCard(
          icon: Icons.swap_horiz,
          title: localizations.transferOwnership,
          description: localizations.transferOwnershipDesc,
          onTap: () => _showTransferOwnershipDialog(context, ref),
        ),
        const SizedBox(height: 8),

        // Option 3: Delete family (if only member)
        if (family.members.length == 1) ...[
          _ProtectionOptionCard(
            icon: Icons.delete_forever,
            title: localizations.deleteFamily,
            description: localizations.deleteFamilyLastMemberDesc,
            onTap: () => _showDeleteFamilyDialog(context, ref),
            isDangerous: true,
          ),
        ],
      ],
    );
  }

  Future<void> _showPromoteMemberDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await showDialog<FamilyMember>(
      context: context,
      builder: (context) =>
          _PromoteMemberDialog(family: family, currentUser: currentUser),
    );

    if (result != null) {
      await ref
          .read(familyComposedProvider.notifier)
          .promoteMemberToAdmin(result.id);
      onProtectionBypassed?.call();
    }
  }

  Future<void> _showTransferOwnershipDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await showDialog<FamilyMember>(
      context: context,
      builder: (context) =>
          _TransferOwnershipDialog(family: family, currentUser: currentUser),
    );

    if (result != null) {
      await ref
          .read(familyComposedProvider.notifier)
          .transferOwnership(result.id);
      onProtectionBypassed?.call();
    }
  }

  Future<void> _showDeleteFamilyDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) =>
          _DeleteFamilyConfirmationDialog(familyName: family.name),
    );

    if (confirmed == true) {
      // Note: deleteFamily() method was removed as it was misleading
      // It only called leaveFamily() but claimed to delete the entire family
      // Using leaveFamily() directly for proper clarity
      await ref.read(familyComposedProvider.notifier).leaveFamily();
      onProtectionBypassed?.call();
    }
  }
}

/// Card for protection options
class _ProtectionOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final bool isDangerous;

  const _ProtectionOptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.isDangerous = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDangerous
        ? theme.colorScheme.error
        : theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: color.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: color.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog for promoting a member to admin
class _PromoteMemberDialog extends StatelessWidget {
  final entity.Family family;
  final FamilyMember currentUser;

  const _PromoteMemberDialog({required this.family, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    // Get eligible members (non-admin members)
    final eligibleMembers = family.members
        .where((m) => m.id != currentUser.id && m.role != FamilyRole.admin)
        .toList();

    return AlertDialog(
      title: Text(localizations.selectMemberToPromote),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: eligibleMembers.length,
          itemBuilder: (context, index) {
            final member = eligibleMembers[index];
            return ListTile(
              leading: CircleAvatar(
                child: Text(member.userId[0].toUpperCase()),
              ),
              title: Text(member.userId),
              subtitle: Text(localizations.roleLabel(member.roleDisplayName)),
              trailing: Chip(
                label: Text(member.role.displayName),
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
              onTap: () => Navigator.of(context).pop(member),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.cancel),
        ),
      ],
    );
  }
}

/// Dialog for transferring ownership
class _TransferOwnershipDialog extends StatelessWidget {
  final entity.Family family;
  final FamilyMember currentUser;

  const _TransferOwnershipDialog({
    required this.family,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    // Get all other members
    final otherMembers = family.members
        .where((m) => m.id != currentUser.id)
        .toList();

    return AlertDialog(
      title: Text(localizations.transferOwnership),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.warningContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: theme.colorScheme.onWarningContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    localizations.transferOwnershipWarning,
                    style: TextStyle(
                      color: theme.colorScheme.onWarningContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: otherMembers.length,
              itemBuilder: (context, index) {
                final member = otherMembers[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(member.userId[0].toUpperCase()),
                  ),
                  title: Text(member.userId),
                  subtitle: Text(
                    localizations.roleLabel(member.roleDisplayName),
                  ),
                  trailing: Chip(
                    label: Text(member.role.displayName),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                  onTap: () => Navigator.of(context).pop(member),
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.cancel),
        ),
      ],
    );
  }
}

/// Dialog for confirming family deletion
class _DeleteFamilyConfirmationDialog extends StatefulWidget {
  final String familyName;

  const _DeleteFamilyConfirmationDialog({required this.familyName});

  @override
  State<_DeleteFamilyConfirmationDialog> createState() =>
      _DeleteFamilyConfirmationDialogState();
}

class _DeleteFamilyConfirmationDialogState
    extends State<_DeleteFamilyConfirmationDialog> {
  final _confirmationController = TextEditingController();
  bool _isValid = false;

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final confirmationText = 'DELETE ${widget.familyName}'.toUpperCase();

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.delete_forever, color: theme.colorScheme.error),
          const SizedBox(width: 8),
          Text(localizations.deleteFamilyConfirmation),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.deleteFamilyWarning(widget.familyName),
            style: TextStyle(color: theme.colorScheme.error),
          ),
          const SizedBox(height: 16),
          Text(localizations.typeToConfirm(confirmationText)),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmationController,
            onChanged: (value) {
              setState(() {
                _isValid = value == confirmationText;
              });
            },
            decoration: InputDecoration(
              hintText: confirmationText,
              border: const OutlineInputBorder(),
              errorText: _confirmationController.text.isNotEmpty && !_isValid
                  ? localizations.incorrectConfirmation
                  : null,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(localizations.cancel),
        ),
        AccessibleButton(
          onPressed: _isValid ? () => Navigator.of(context).pop(true) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          child: Text(localizations.deleteFamily),
        ),
      ],
    );
  }
}

/// Extension to add warning colors to theme
extension ColorSchemeExtension on ColorScheme {
  Color get warning => AppColors.warning;
  Color get warningContainer => AppColors.warningContainer;
  Color get onWarningContainer => AppColors.onWarningContainer;
}

/// Extension for FamilyRole display names
extension FamilyRoleWidgetExtension on FamilyRole {
  String get displayName {
    switch (this) {
      case FamilyRole.admin:
        return 'Admin';
      case FamilyRole.member:
        return 'Member';
    }
  }
}
