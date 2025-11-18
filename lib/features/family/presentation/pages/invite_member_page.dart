import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/validators/family_form_validator.dart';
import '../utils/family_validation_localizer.dart';
import '../utils/family_invitation_validation_localizer.dart';

// COMPOSITION ROOT: Import ONLY from feature-level composition root
import '../../providers.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/presentation/themes/app_colors.dart';
import 'package:edulift/core/domain/entities/family.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/navigation/navigation_state.dart' as nav;
import '../../../../core/presentation/utils/responsive_breakpoints.dart';

/// Dedicated page for inviting family members
/// Provides proper UX with full-page form and error handling
class InviteMemberPage extends ConsumerStatefulWidget {
  const InviteMemberPage({super.key});

  @override
  ConsumerState<InviteMemberPage> createState() => _InviteMemberPageState();
}

class _InviteMemberPageState extends ConsumerState<InviteMemberPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  FamilyRole _selectedRole = FamilyRole.member;
  bool _isSubmitting = false;
  String? _errorMessage;

  // Available role options based on FamilyRole enum
  // Note: Labels are set dynamically in didChangeDependencies() using l10n
  List<Map<String, dynamic>>? _roleOptions;

  @override
  void initState() {
    super.initState();
    // CRITICAL FIX: Clear navigation state after page is displayed
    // Prevents "Navigation already processing" error on subsequent FAB clicks
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(nav.navigationStateProvider.notifier).clearNavigation();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize role options with localized labels (only once)
    if (_roleOptions == null) {
      final l10n = AppLocalizations.of(context);
      _roleOptions = [
        {'role': FamilyRole.member, 'label': l10n.member},
        {'role': FamilyRole.admin, 'label': l10n.administrator},
      ];
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Responsive design detection
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 768;
    final isSmallScreen = screenSize.width < 600;

    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.inviteFamilyMembers,
          key: const Key('invite_member_title'),
        ),
        actions: [
          if (_isSubmitting)
            Padding(
              padding: context.getAdaptivePadding(
                mobileAll: 12,
                tabletAll: 16,
                desktopAll: 20,
              ),
              child: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInstructionSection(
                      localizations,
                      theme,
                      isTablet,
                      isSmallScreen,
                    ),
                    SizedBox(height: isTablet ? 32 : 24),
                    _buildEmailField(localizations, isTablet, isSmallScreen),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    _buildRoleSelection(localizations, isTablet, isSmallScreen),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    _buildMessageField(localizations, isTablet, isSmallScreen),

                    // Error display section
                    if (_errorMessage != null) ...[
                      SizedBox(height: isTablet ? 32 : 24),
                      _buildErrorSection(
                        _errorMessage!,
                        isTablet,
                        isSmallScreen,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            _buildActionButtons(localizations, isTablet, isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionSection(
    AppLocalizations localizations,
    ThemeData theme,
    bool isTablet,
    bool isSmallScreen,
  ) {
    return Card(
      elevation: isTablet ? 4 : 2,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    localizations.inviteNewMember,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 18 : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
            Text(
              localizations.sendInvitationDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField(
    AppLocalizations localizations,
    bool isTablet,
    bool isSmallScreen,
  ) {
    return TextFormField(
      key: const Key('email_address_field'),
      controller: _emailController,
      decoration: InputDecoration(
        labelText: localizations.emailAddress,
        hintText: localizations.enterEmailAddress,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.email, size: 20),
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: (value) {
        final error = FamilyFormValidator.validateEmail(value);
        if (error != null) {
          final l10n = AppLocalizations.of(context);
          return error.toLocalizedMessage(l10n);
        }
        return null;
      },
    );
  }

  Widget _buildRoleSelection(
    AppLocalizations localizations,
    bool isTablet,
    bool isSmallScreen,
  ) {
    return DropdownButtonFormField<FamilyRole>(
      key: const Key('inviteRoleSelector'),
      initialValue: _selectedRole,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: localizations.role,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.admin_panel_settings, size: 20),
      ),
      items: (_roleOptions ?? []).map((option) {
        return DropdownMenuItem<FamilyRole>(
          key: Key('role_option_${option['role'].value}'),
          value: option['role'],
          child: Text(
            option['label'],
            key: Key('role_menu_text_${option['role'].value}'),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedRole = value;
          });
        }
      },
    );
  }

  Widget _buildMessageField(
    AppLocalizations localizations,
    bool isTablet,
    bool isSmallScreen,
  ) {
    return TextFormField(
      key: const Key('personal_message_field'),
      controller: _messageController,
      decoration: InputDecoration(
        labelText: localizations.personalMessageOptionalLabel,
        hintText: localizations.addPersonalMessageHint,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.message, size: 20),
        alignLabelWithHint: true,
      ),
      maxLines: 3,
      textInputAction: TextInputAction.done,
    );
  }

  Widget _buildErrorSection(
    String errorMessage,
    bool isTablet,
    bool isSmallScreen,
  ) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      elevation: isTablet ? 4 : 2,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).failed,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _translateErrorMessage(context, errorMessage),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _errorMessage = null),
              icon: Icon(
                Icons.close,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    AppLocalizations localizations,
    bool isTablet,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                key: const Key('invite_member_cancel_button'),
                onPressed: _isSubmitting ? null : () => context.pop(),
                child: Text(localizations.cancel),
              ),
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                key: const Key('send_invitation_button'),
                onPressed: _isSubmitting ? null : _submitInvitation,
                child: _isSubmitting
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              AppLocalizations.of(context).sendingButton,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.send, size: 16),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              AppLocalizations.of(context).sendInvitation,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitInvitation() async {
    if (!_formKey.currentState!.validate()) return;

    // Get l10n BEFORE any await to avoid async gap
    final l10n = AppLocalizations.of(context);

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      // Use FamilyProvider which delegates to actual API endpoint
      final familyId = ref.read(familyComposedProvider).family?.id;
      if (familyId == null) {
        throw Exception('No family ID available');
      }

      // PHASE2 FIX: Use Result pattern correctly - handle Result<Invitation, InvitationFailure>
      final result = await ref
          .read(familyComposedProvider.notifier)
          .sendFamilyInvitationToMember(
            familyId: familyId,
            email: _emailController.text.trim(),
            role: _selectedRole.value,
            personalMessage: _messageController.text.isNotEmpty
                ? _messageController.text.trim()
                : null,
          );

      if (result.isErr) {
        // Error occurred - display it and KEEP form open
        final failure = result.error!;
        setState(() {
          // Use PHASE2 localized error message
          _errorMessage = failure.error.toLocalizedMessage(l10n);
        });
        // DO NOT close form - let user retry
      } else {
        // Success - show confirmation and navigate back
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.invitationSentSuccessfully),
              backgroundColor: AppColors.successThemed(context),
            ),
          );
          context.pop(); // ONLY close on success
        }
      }
    } catch (error) {
      // Handle specific invitation errors with user-friendly messages
      String errorMessage;
      if (error is UserAlreadyMemberException) {
        errorMessage = l10n.errorAuthUserAlreadyInFamily;
      } else if (error is InvitationExpiredException) {
        errorMessage = l10n.errorInvitationExpired;
      } else if (error is InvalidInvitationException) {
        errorMessage = l10n.errorInvitationCodeInvalid;
      } else if (error is InvitationException) {
        errorMessage = error.message;
      } else {
        errorMessage = l10n.failedToSendInvitation;
      }

      setState(() {
        _errorMessage = errorMessage;
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  /// Translate error messages from localization keys to user-friendly text
  String _translateErrorMessage(BuildContext context, String message) {
    final l10n = AppLocalizations.of(context);
    // Map localization keys to their translated values
    switch (message) {
      case 'errorNetworkGeneral':
        return l10n.errorNetworkGeneral;
      case 'errorServerGeneral':
        return l10n.errorServerGeneral;
      case 'errorValidation':
        return l10n.errorValidation;
      case 'errorAuth':
        return l10n.errorAuth;
      case 'errorUnexpected':
        return l10n.errorUnexpected;
      case 'errorInvalidData':
        return l10n.errorValidation;
      case 'errorUnauthorized':
        return l10n.errorAuth;
      default:
        // If it's not a localization key, return the message as-is
        // This handles cases where the message is already translated
        return message;
    }
  }
}
