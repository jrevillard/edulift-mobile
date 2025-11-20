// EduLift Mobile - Leave Family Confirmation Dialog Widget
// Confirmation dialog for members to leave the family

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edulift/core/domain/entities/family.dart';
// ARCHITECTURE FIX: Use composition root instead
import '../../providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../generated/l10n/app_localizations.dart';

class LeaveFamilyConfirmationDialog extends ConsumerStatefulWidget {
  final FamilyMember member;
  final VoidCallback? onSuccess;

  const LeaveFamilyConfirmationDialog({
    super.key,
    required this.member,
    this.onSuccess,
  });

  @override
  ConsumerState<LeaveFamilyConfirmationDialog> createState() =>
      _LeaveFamilyConfirmationDialogState();
}

class _LeaveFamilyConfirmationDialogState
    extends ConsumerState<LeaveFamilyConfirmationDialog> {
  bool _isLoading = false;
  final TextEditingController _confirmationController = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _confirmationController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  void _validateInput() {
    final familyState = ref.watch(familyComposedProvider);
    final familyName =
        familyState.family?.name ?? AppLocalizations.of(context).unknownFamily;
    setState(() {
      _isValid = _confirmationController.text.trim() == familyName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final familyState = ref.watch(familyComposedProvider);
    final familyName =
        familyState.family?.name ?? AppLocalizations.of(context).unknownFamily;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.exit_to_app, color: theme.colorScheme.error, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalizations.of(context).leaveFamilyTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.family_restroom,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          familyName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(
                      context,
                    ).youAreLeavingAs(widget.member.role.value),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber,
                        size: 20,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).actionCannotBeUndone,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).byLeavingFamilyYouWill,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).loseAccessSchedules,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context).noLongerSeeFamilyMembers,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context).loseAccessVehicles,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                        if (widget.member.role == FamilyRole.admin)
                          Text(
                            AppLocalizations.of(context).giveUpAdminPrivileges,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (widget.member.role == FamilyRole.admin) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        AppLocalizations.of(context).ensureOtherAdmins,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).typeNameToConfirm(familyName),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmationController,
              decoration: InputDecoration(
                hintText: familyName,
                border: const OutlineInputBorder(),
                errorText: _confirmationController.text.isNotEmpty && !_isValid
                    ? AppLocalizations.of(
                        context,
                      ).pleaseTypeNameExactly(familyName)
                    : null,
              ),
              onChanged: (value) => _validateInput(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(
            AppLocalizations.of(context).cancel,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        FilledButton(
          onPressed: _isLoading || !_isValid ? null : _handleLeaveFamily,
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            disabledBackgroundColor: theme.colorScheme.onSurface.withValues(
              alpha: 0.12,
            ),
          ),
          child: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.onError,
                    ),
                  ),
                )
              : Text(
                  AppLocalizations.of(context).leaveFamilyTitle,
                  style: TextStyle(color: theme.colorScheme.onError),
                ),
        ),
      ],
    );
  }

  Future<void> _handleLeaveFamily() async {
    setState(() => _isLoading = true);
    try {
      final familyNotifier = ref.read(familyComposedProvider.notifier);
      await familyNotifier.leaveFamily();

      if (mounted) {
        // Check if the operation actually succeeded by examining the state
        final familyState = ref.read(familyComposedProvider);

        // Check both error and errorInfo to detect failure
        final errorMessage = familyState.error ?? familyState.errorInfo;
        if (errorMessage?.isNotEmpty == true) {
          // Operation failed - show error message
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).failedToLeaveFamily(errorMessage!),
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          // Clear the error state for future attempts
          familyNotifier.clearError();
        } else {
          // Operation succeeded - call success callback and close dialog
          widget.onSuccess?.call();
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      AppLogger.error('Unexpected error leaving family', e);
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).failedToLeaveFamily(e.toString()),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
