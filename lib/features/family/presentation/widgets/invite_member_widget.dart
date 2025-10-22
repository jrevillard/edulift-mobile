// EduLift Mobile - Invite Member Widget
// Widget for admin-only family member invitation functionality

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';

import '../../domain/validators/family_form_validator.dart';
import '../utils/family_validation_localizer.dart';

// ARCHITECTURE FIX: Use composition root instead
import '../../providers.dart';
import '../../../../core/utils/app_logger.dart';
import 'package:edulift/core/domain/entities/family.dart';

class InviteMemberWidget extends ConsumerStatefulWidget {
  final VoidCallback? onInvitationSent;

  const InviteMemberWidget({super.key, this.onInvitationSent});

  @override
  ConsumerState<InviteMemberWidget> createState() => _InviteMemberWidgetState();
}

class _InviteMemberWidgetState extends ConsumerState<InviteMemberWidget> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  InvitationType _invitationType = InvitationType.family;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.person_add,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      localizations.inviteFamilyMember,
                      key: const Key('invite_member_title'),
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Email field
              TextFormField(
                key: const Key('email_address_field'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: localizations.emailAddress,
                  hintText: localizations.enterMemberEmail,
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  final error = FamilyFormValidator.validateEmail(value);
                  if (error != null) {
                    final l10n = AppLocalizations.of(context);
                    return error.toLocalizedMessage(l10n);
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Name field (optional)
              TextFormField(
                key: const Key('name_field'),
                controller: _nameController,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: localizations.nameOptional,
                  hintText: localizations.enterMemberName,
                  prefixIcon: const Icon(Icons.person_outline),
                  border: const OutlineInputBorder(),
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Invitation type
              Text(
                localizations.invitationType,
                key: const Key('invitation_type_label'),
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SegmentedButton<InvitationType>(
                key: const Key('invitation_type_selector'),
                segments: [
                  ButtonSegment(
                    value: InvitationType.family,
                    label: Text(localizations.familyMember),
                    icon: const Icon(Icons.family_restroom),
                  ),
                ],
                selected: {_invitationType},
                onSelectionChanged: _isLoading
                    ? null
                    : (Set<InvitationType> newSelection) {
                        setState(() {
                          _invitationType = newSelection.first;
                        });
                      },
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        localizations.familyMemberDescription,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: const Key('reset_button'),
                      onPressed: _isLoading ? null : _resetForm,
                      child: Text(localizations.reset),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      key: const Key('send_invitation_button'),
                      onPressed: _isLoading ? null : _sendInvitation,
                      child: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.send, size: 16),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    localizations.sendInvitation,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resetForm() {
    _emailController.clear();
    _nameController.clear();
    setState(() {
      _invitationType = InvitationType.family;
    });
  }

  Future<void> _sendInvitation() async {
    final localizations = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final familyState = ref.read(familyComposedProvider);
      final familyId = familyState.family?.id;
      if (familyId == null) {
        throw Exception(localizations.noFamilyIdAvailable);
      }

      final familyNotifier = ref.read(familyComposedProvider.notifier);

      // PHASE2 Pattern: Use Result returned by sendFamilyInvitationToMember()
      final result = await familyNotifier.sendFamilyInvitationToMember(
        familyId: familyId,
        email: _emailController.text.trim(),
        role: FamilyRole.member.value, // Default role for invitations
        personalMessage: _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : null,
      );

      AppLogger.debug('🔥 [InviteWidget] PHASE2 Result Pattern', {
        'isOk': result.isOk,
        'hasError': result.isErr,
        'errorType': result.isErr ? result.error.runtimeType.toString() : null,
      });

      if (result.isOk) {
        // PHASE2 SUCCESS: result.isOk = true
        AppLogger.debug('🔥 [InviteWidget] PHASE2 SUCCESS - result.isOk = true');
        // Success
        if (mounted) {
          // Store context before async operations
          final messenger = ScaffoldMessenger.of(context);
          final theme = Theme.of(context);
          final email = _emailController.text.trim();

          // Provide haptic feedback
          await HapticFeedback.lightImpact();

          // Reset form
          _resetForm();
          // Show success message
          messenger.showSnackBar(
            SnackBar(
              content: Text(localizations.invitationSentTo(email)),
              backgroundColor: theme.colorScheme.primary,
              action: SnackBarAction(
                label: localizations.view,
                onPressed: () {
                  // Could navigate to invitations tab
                },
              ),
            ),
          );
          // Notify parent widget
          widget.onInvitationSent?.call();
        }
      } else {
        // PHASE2 ERROR: result.isErr = true
        final error = result.error!;
        AppLogger.debug('🔥 [InviteWidget] PHASE2 ERROR - result.isErr = true', {
          'errorType': error.runtimeType.toString(),
          'localizationKey': error.localizationKey,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${localizations.failedToSendInvitation}: ${error.localizationKey}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.error('Failed to send invitation', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.failedToSendInvitation}: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
