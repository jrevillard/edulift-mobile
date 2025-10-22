// EduLift Mobile - Family Conflict Resolution Dialog
// Handles family switching conflicts and admin role transitions

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/presentation/widgets/accessibility/accessible_button.dart';
import '../../../../core/presentation/themes/app_colors.dart';
import 'package:edulift/core/domain/entities/family.dart' as entity;

/// Dialog for resolving family conflicts when accepting invitations
class FamilyConflictResolutionDialog extends ConsumerStatefulWidget {
  final entity.Family currentFamily;
  final String newFamilyName;
  final String invitationId;
  final bool isLastAdmin;
  final int currentFamilyMemberCount;

  const FamilyConflictResolutionDialog({
    super.key,
    required this.currentFamily,
    required this.newFamilyName,
    required this.invitationId,
    required this.isLastAdmin,
    required this.currentFamilyMemberCount,
  });

  @override
  ConsumerState<FamilyConflictResolutionDialog> createState() =>
      _FamilyConflictResolutionDialogState();

  /// Show the conflict resolution dialog
  static Future<dynamic> show({
    required BuildContext context,
    required entity.Family currentFamily,
    required String newFamilyName,
    required String invitationId,
    required bool isLastAdmin,
    required int currentFamilyMemberCount,
  }) {
    return showDialog<dynamic>(
      context: context,
      barrierDismissible: false,
      builder: (context) => FamilyConflictResolutionDialog(
        currentFamily: currentFamily,
        newFamilyName: newFamilyName,
        invitationId: invitationId,
        isLastAdmin: isLastAdmin,
        currentFamilyMemberCount: currentFamilyMemberCount,
      ),
    );
  }
}

class _FamilyConflictResolutionDialogState
    extends ConsumerState<FamilyConflictResolutionDialog> {
  FamilyConflictResolution _selectedResolution = FamilyConflictResolution.stay;
  String? _newAdminEmail;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: theme.colorScheme.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              localizations.familyConflictTitle,
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
            // Current situation explanation
            Card(
              color: theme.colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.currentSituation,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.family_restroom,
                      localizations.currentFamily(widget.currentFamily.name),
                    ),
                    _buildInfoRow(
                      Icons.group,
                      localizations.memberCount(
                        widget.currentFamilyMemberCount,
                      ),
                    ),
                    if (widget.isLastAdmin)
                      _buildInfoRow(
                        Icons.admin_panel_settings,
                        localizations.youAreLastAdmin,
                        isWarning: true,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // New family info
            Card(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.newFamilyInvitation,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.mail,
                      localizations.invitedToFamily(widget.newFamilyName),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Resolution options
            Text(
              localizations.chooseResolution,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            // Option 1: Stay in current family
            _buildResolutionOption(
              FamilyConflictResolution.stay,
              Icons.home,
              localizations.stayInCurrentFamily,
              localizations.stayInCurrentFamilyDesc,
            ),

            // Option 2: Switch to new family (if not last admin)
            if (!widget.isLastAdmin) ...[
              const SizedBox(height: 8),
              _buildResolutionOption(
                FamilyConflictResolution.switchFamily,
                Icons.swap_horiz,
                localizations.switchToNewFamily,
                localizations.switchToNewFamilyDesc,
              ),
            ],

            // Option 3: Assign new admin and switch (if last admin)
            if (widget.isLastAdmin && widget.currentFamilyMemberCount > 1) ...[
              const SizedBox(height: 8),
              _buildResolutionOption(
                FamilyConflictResolution.assignNewAdmin,
                Icons.person_add,
                localizations.assignNewAdminAndSwitch,
                localizations.assignNewAdminDesc,
              ),
              if (_selectedResolution ==
                  FamilyConflictResolution.assignNewAdmin) ...[
                const SizedBox(height: 12),
                _buildNewAdminInput(),
              ],
            ],

            // Option 4: Delete family and switch (if last admin and only member)
            if (widget.isLastAdmin && widget.currentFamilyMemberCount == 1) ...[
              const SizedBox(height: 8),
              _buildResolutionOption(
                FamilyConflictResolution.deleteAndSwitch,
                Icons.delete_forever,
                localizations.deleteFamilyAndSwitch,
                localizations.deleteFamilyDesc,
                isDangerous: true,
              ),
            ],

            // Error message
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.onErrorContainer,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: theme.colorScheme.onErrorContainer,
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
        // Cancel button
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
          child: Text(localizations.cancel),
        ),

        // Confirm button
        AccessibleButton(
          onPressed: _isProcessing ? null : _handleConfirm,
          child: _isProcessing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(localizations.confirm),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {bool isWarning = false}) {
    final theme = Theme.of(context);
    final color = isWarning ? theme.colorScheme.warning : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }

  Widget _buildResolutionOption(
    FamilyConflictResolution resolution,
    IconData icon,
    String title,
    String description, {
    bool isDangerous = false,
  }) {
    final theme = Theme.of(context);
    final isSelected = _selectedResolution == resolution;
    final color = isDangerous
        ? theme.colorScheme.error
        : isSelected
        ? theme.colorScheme.primary
        : null;

    return InkWell(
      onTap: _isProcessing
          ? null
          : () {
              setState(() {
                _selectedResolution = resolution;
                _errorMessage = null;
              });
            },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? color ?? theme.colorScheme.outline
                : theme.colorScheme.outline.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? (color ?? theme.colorScheme.primary).withValues(alpha: 0.1)
              : null,
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
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: color?.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: _isProcessing
                  ? null
                  : () {
                      setState(() {
                        _selectedResolution = resolution;
                        _errorMessage = null;
                      });
                    },
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color ?? theme.colorScheme.primary,
                        width: 2,
                      ),
                      color: _selectedResolution == resolution
                          ? (color ?? theme.colorScheme.primary)
                          : null,
                    ),
                    child: _selectedResolution == resolution
                        ? Icon(
                            Icons.circle,
                            size: 12,
                            color: theme.colorScheme.onPrimary,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewAdminInput() {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(localizations.selectNewAdmin, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: _newAdminEmail,
            onChanged: (value) {
              setState(() {
                _newAdminEmail = value;
                _errorMessage = null;
              });
            },
            decoration: InputDecoration(
              labelText: localizations.newAdminEmail,
              hintText: localizations.enterEmailOfFamilyMember,
              prefixIcon: const Icon(Icons.email),
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            enabled: !_isProcessing,
          ),
        ],
      ),
    );
  }

  Future<void> _handleConfirm() async {
    // Validate new admin email if needed
    if (_selectedResolution == FamilyConflictResolution.assignNewAdmin) {
      if (_newAdminEmail == null || _newAdminEmail!.isEmpty) {
        setState(() {
          _errorMessage = AppLocalizations.of(context).pleaseEnterNewAdminEmail;
        });
        return;
      }

      // Validate email format
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(_newAdminEmail!)) {
        setState(() {
          _errorMessage = AppLocalizations.of(context).invalidEmailFormat;
        });
        return;
      }
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // Return the resolution with necessary data
      if (_selectedResolution == FamilyConflictResolution.assignNewAdmin) {
        Navigator.of(context).pop(
          FamilyConflictResolution.assignNewAdmin.withData(_newAdminEmail!),
        );
      } else {
        Navigator.of(context).pop(_selectedResolution);
      }
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(context).errorProcessingRequest;
        _isProcessing = false;
      });
    }
  }
}

/// Resolution options for family conflicts
enum FamilyConflictResolution {
  stay,
  switchFamily,
  assignNewAdmin,
  deleteAndSwitch;

  /// Attach data to the resolution
  FamilyConflictResolutionWithData withData(String data) {
    return FamilyConflictResolutionWithData(this, data);
  }
}

/// Class to hold resolution with data
class FamilyConflictResolutionWithData {
  final FamilyConflictResolution resolution;
  final String data;

  const FamilyConflictResolutionWithData(this.resolution, this.data);
}

/// Extension to add warning color to theme
extension ThemeExtension on ColorScheme {
  Color get warning => AppColors.warning;
}
