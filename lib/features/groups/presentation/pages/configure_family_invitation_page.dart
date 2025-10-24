// EduLift Mobile - Configure Family Invitation Page
// Mobile-first page for configuring invitation role and optional message

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/domain/entities/groups/group_family.dart';
import '../../../../core/di/providers/repository_providers.dart';
import '../../../../core/presentation/utils/responsive_breakpoints.dart';
import '../../../../core/presentation/themes/app_colors.dart';

/// Configure Family Invitation Page
///
/// Allows user to select role (MEMBER/ADMIN) and add optional personal message
/// before sending the invitation.
class ConfigureFamilyInvitationPage extends ConsumerStatefulWidget {
  final String groupId;
  final String familyId;
  final String familyName;
  final int memberCount;

  const ConfigureFamilyInvitationPage({
    super.key,
    required this.groupId,
    required this.familyId,
    required this.familyName,
    required this.memberCount,
  });

  @override
  ConsumerState<ConfigureFamilyInvitationPage> createState() =>
      _ConfigureFamilyInvitationPageState();
}

class _ConfigureFamilyInvitationPageState
    extends ConsumerState<ConfigureFamilyInvitationPage> {
  final TextEditingController _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  GroupFamilyRole _selectedRole = GroupFamilyRole.member;
  bool _isInviting = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendInvitation() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isInviting) return;

    setState(() {
      _isInviting = true;
    });

    try {
      final repository = ref.read(groupRepositoryProvider);
      final message = _messageController.text.trim();

      final result = await repository.inviteFamilyToGroup(
        widget.groupId,
        widget.familyId,
        _selectedRole.name.toUpperCase(),
        message.isEmpty ? null : message,
      );

      if (!mounted) return;

      result.when(
        ok: (_) {
          // Show success message
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              key: const Key('family_invitation_sent_snackbar'),
              content: Text(l10n.invitationSent(widget.familyName)),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
            ),
          );

          // Navigate back to group members management
          Navigator.of(context).pop(); // Pop config page
          Navigator.of(context).pop(); // Pop search page
        },
        err: (failure) {
          setState(() {
            _isInviting = false;
          });

          // Show error message
          final l10n = AppLocalizations.of(context);
          final errorMessage = failure.message ?? l10n.errorUnexpected;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              key: const Key('family_invitation_error_snackbar'),
              content: Text(l10n.invitationFailed(errorMessage)),
              backgroundColor: AppColors.errorThemed(context),
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isInviting = false;
      });

      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          key: const Key('family_invitation_error_snackbar'),
          content: Text(l10n.invitationFailed(l10n.unexpectedError)),
          backgroundColor: AppColors.errorThemed(context),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isTablet = context.isTablet;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('configure_invitation_back_button'),
          icon: const Icon(Icons.arrow_back),
          onPressed: _isInviting ? null : () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.inviteAs,
          style: TextStyle(fontSize: (isTablet ? 22 : 20) * context.fontScale),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: context.getAdaptivePadding(
                    mobileAll: 16,
                    tabletAll: 24,
                    desktopAll: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Family Info Card
                      Card(
                        elevation: 1,
                        child: Padding(
                          padding: EdgeInsets.all(isTablet ? 20 : 16),
                          child: Row(
                            children: [
                              Container(
                                width: isTablet ? 56 : 48,
                                height: isTablet ? 56 : 48,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(
                                    isTablet ? 28 : 24,
                                  ),
                                ),
                                child: Icon(
                                  Icons.groups,
                                  color: theme.colorScheme.onPrimaryContainer,
                                  size: isTablet ? 28 : 24,
                                ),
                              ),
                              SizedBox(width: isTablet ? 16 : 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.familyName,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: isTablet ? 18 : 16,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      l10n.memberCount(widget.memberCount),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color:
                                                AppColors.textSecondaryThemed(
                                                  context,
                                                ),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(
                        height: context.getAdaptiveSpacing(
                          mobile: 24,
                          tablet: 32,
                          desktop: 40,
                        ),
                      ),

                      // Role Selection Section
                      Text(
                        l10n.inviteAs,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: context.getAdaptiveSpacing(
                          mobile: 8,
                          tablet: 12,
                          desktop: 16,
                        ),
                      ),

                      // Member Role Option
                      _RoleSelectionCard(
                        key: const Key('role_member_card'),
                        title: l10n.member,
                        description: l10n.roleMemberDescription,
                        icon: Icons.person,
                        isSelected: _selectedRole == GroupFamilyRole.member,
                        onTap: _isInviting
                            ? null
                            : () => setState(
                                () => _selectedRole = GroupFamilyRole.member,
                              ),
                        theme: theme,
                        isTablet: isTablet,
                      ),

                      SizedBox(
                        height: context.getAdaptiveSpacing(
                          mobile: 12,
                          tablet: 16,
                          desktop: 20,
                        ),
                      ),

                      // Admin Role Option
                      _RoleSelectionCard(
                        key: const Key('role_admin_card'),
                        title: l10n.administrator,
                        description: l10n.roleAdminDescription,
                        icon: Icons.admin_panel_settings,
                        isSelected: _selectedRole == GroupFamilyRole.admin,
                        onTap: _isInviting
                            ? null
                            : () => setState(
                                () => _selectedRole = GroupFamilyRole.admin,
                              ),
                        theme: theme,
                        isTablet: isTablet,
                      ),

                      SizedBox(
                        height: context.getAdaptiveSpacing(
                          mobile: 24,
                          tablet: 32,
                          desktop: 40,
                        ),
                      ),

                      // Personal Message Section
                      Text(
                        l10n.personalMessageOptional,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: context.getAdaptiveSpacing(
                          mobile: 8,
                          tablet: 12,
                          desktop: 16,
                        ),
                      ),

                      TextField(
                        key: const Key('invitation_message_field'),
                        controller: _messageController,
                        enabled: !_isInviting,
                        decoration: InputDecoration(
                          hintText: l10n.addPersonalMessageHint,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                        maxLength: 250,
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Action Bar
              Container(
                padding: context.getAdaptivePadding(
                  mobileAll: 16,
                  tabletAll: 24,
                  desktopAll: 32,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    height: isTablet ? 52 : 48,
                    child: ElevatedButton(
                      key: const Key('send_invitation_button'),
                      onPressed: _isInviting ? null : _sendInvitation,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isInviting
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.onPrimary,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.send, size: 20),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    l10n.sendInvitation,
                                    style: TextStyle(
                                      fontSize: isTablet ? 18 : 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Role Selection Card Widget
class _RoleSelectionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final ThemeData theme;
  final bool isTablet;

  const _RoleSelectionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.theme,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : AppColors.borderThemed(context),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Row(
            children: [
              // Icon
              Container(
                width: isTablet ? 48 : 40,
                height: isTablet ? 48 : 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primaryContainer
                      : AppColors.surfaceVariantThemed(context),
                  borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : AppColors.textSecondaryThemed(context),
                  size: isTablet ? 24 : 20,
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),

              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryThemed(context),
                      ),
                    ),
                  ],
                ),
              ),

              // Selection Indicator
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected
                    ? theme.colorScheme.primary
                    : AppColors.textSecondaryThemed(
                        context,
                      ).withValues(alpha: 0.6),
                size: isTablet ? 28 : 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
