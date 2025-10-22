// EduLift Mobile - Family Invitation Page
// Unified family invitation handling with magic link authentication

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ARCHITECTURE FIX: Use composition root instead
import '../../providers.dart';
import '../providers/family_invitation_provider.dart'
    show FamilyInvitationState;
import 'package:edulift/core/services/providers/auth_provider.dart';
import 'package:edulift/core/domain/entities/family.dart';
import '../../../../core/network/models/family/family_invitation_validation_dto.dart'; // Added missing import
import 'package:edulift/core/presentation/widgets/invitation/invitation_error_display.dart';
import 'package:edulift/core/presentation/widgets/invitation/invitation_loading_state.dart';
import 'package:edulift/core/presentation/widgets/invitation/invitation_manual_code_input.dart'
    show InvitationManualCodeInput;
import 'package:edulift/core/presentation/widgets/invitation/invitation_manual_code_input.dart' as ui
    show InvitationType;
import 'package:edulift/core/presentation/widgets/accessibility/accessible_button.dart';
import '../../../auth/presentation/widgets/email_with_progressive_name.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/navigation/navigation_state.dart';
import '../../../../core/presentation/mixins/navigation_cleanup_mixin.dart';

/// Family invitation page handling invitation validation and acceptance
class FamilyInvitationPage extends ConsumerStatefulWidget {
  /// Invitation code from URL or manual input
  final String? inviteCode;

  const FamilyInvitationPage({super.key, this.inviteCode});

  @override
  ConsumerState<FamilyInvitationPage> createState() =>
      _FamilyInvitationPageState();
}

class _FamilyInvitationPageState extends ConsumerState<FamilyInvitationPage>
    with NavigationCleanupMixin {
  final _manualCodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController(); // Added missing email controller
  final _formKey = GlobalKey<FormState>();
  bool _showSignupForm = false;

  /// Convert string role to FamilyRole for UI display
  /// Updated to work with FamilyInvitationValidationDto.role which is String?
  FamilyRole? _convertStringToFamilyRole(String? role) {
    if (role == null) return null;
    switch (role.toLowerCase()) {
      case 'admin':
      case 'administrator':
        return FamilyRole.admin;
      case 'member':
      default:
        return FamilyRole.member;
    }
  }

  // _convertToFamilyRole removed as unused - only using _convertStringToFamilyRole now

  @override
  void initState() {
    super.initState();
    // NavigationCleanupMixin automatically clears navigation state

    // Auto-validate if invite code provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.inviteCode != null) {
        ref
            .read(familyInvitationComposedProvider.notifier)
            .validateInvitation(widget.inviteCode!);
      }
    });
  }

  @override
  void dispose() {
    _manualCodeController.dispose();
    _nameController.dispose();
    _emailController.dispose(); // CRITICAL FIX: Dispose email controller
    super.dispose();
  }

  /// Build full-width button with consistent styling
  Widget _buildFullWidthButton({
    required Widget child,
    required VoidCallback? onPressed,
    Key? key,
    bool isDestructive = false,
    bool isSecondary = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: isDestructive
          ? AccessibleButton.destructiveStyle(
              context: context,
              key: key,
              onPressed: onPressed,
              child: child,
            )
          : isSecondary
          ? AccessibleButton.secondaryStyle(
              key: key,
              onPressed: onPressed,
              child: child,
            )
          : AccessibleButton(key: key, onPressed: onPressed, child: child),
    );
  }

  void _handleManualCodeValidation() {
    final code = _manualCodeController.text.trim();
    if (code.isNotEmpty) {
      ref
          .read(familyInvitationComposedProvider.notifier)
          .validateInvitation(code);
    }
  }

  void _handleSignInExistingUser() async {
    if (widget.inviteCode != null) {
      // Get current user email - CRITICAL FIX: Use actual user email instead of hardcoded
      final currentUser = ref.read(currentUserProvider);
      final email = currentUser?.email ?? _emailController.text.trim(); // VALIDATION: Ensure we have a valid email - handled by form validation
      if (email.isEmpty) return;

      await ref
          .read(authStateProvider.notifier)
          .sendMagicLink(email, inviteCode: widget.inviteCode);
      // ARCHITECTURE FIX: Navigation handled by router redirect logic
      // No manual navigation needed - sendMagicLink already set the navigation intent
    }
  }

  void _handleSignupSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.inviteCode != null) {
      // Get email from form input - for new user signup
      final email = _emailController.text.trim(); // VALIDATION: Ensure we have a valid email - handled by form validation
      if (email.isEmpty) return;

      // Use progressive disclosure logic like Login page
      final authState = ref.read(authStateProvider);
      final nameToSend = authState.showNameField
          ? _nameController.text.trim()
          : null;

      await ref
          .read(authStateProvider.notifier)
          .sendMagicLink(
            email,
            name: nameToSend,
            inviteCode: widget.inviteCode,
          );
      // ARCHITECTURE FIX: Navigation handled by router redirect logic
      // No manual navigation needed - sendMagicLink already set the navigation intent
    }
  }

  void _handleJoinFamily() async {
    // Get invitation code from either widget (deeplink) or manual entry controller
    final inviteCode = widget.inviteCode ?? _manualCodeController.text.trim();

    if (inviteCode.isNotEmpty) {
      final result = await ref
          .read(familyInvitationComposedProvider.notifier)
          .acceptInvitation(inviteCode);

      if (result && mounted) {
        // EXPLICIT NAVIGATION: Navigate to dashboard after successful family join
        // Using the app's standard navigation pattern (like create_family_page.dart)
        // NOTE: acceptInvitation already calls clearNavigation(), but we call it again
        // to ensure clean state before navigating
        ref.read(navigationStateProvider.notifier).clearNavigation();
        ref.read(navigationStateProvider.notifier).navigateTo(
          route: '/dashboard',
          trigger: NavigationTrigger.userNavigation,
        );
      }
    }
  }

  void _handleLeaveAndJoin() {
    // Show confirmation dialog for leaving current family
  }

  // ignore: unused_element
  void _confirmLeaveAndJoin() async {
    // Method for handling leave/join confirmation
    // Proceed with leave and join confirmation

    if (widget.inviteCode != null) {
      final result = await ref
          .read(familyInvitationComposedProvider.notifier)
          .acceptInvitation(widget.inviteCode!, leaveCurrentFamily: true);
      if (result && mounted) {
        // ARCHITECTURE FIX: Navigation handled by router redirect logic
        // Auth state change will automatically trigger router navigation
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final state = ref.watch(familyInvitationComposedProvider);
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                    theme.colorScheme.surface,
                  ],
                ),
              ),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 32.0 : 16.0,
                          vertical: isTablet ? 24.0 : 16.0,
                        ),
                        child: Center(
                          child: Card(
                            elevation: isTablet ? 12 : 8,
                            child: Padding(
                              padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: isTablet ? 500 : 400,
                                ),
                                child: _buildContent(context, state, theme),
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
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    FamilyInvitationState state,
    ThemeData theme,
  ) {
    final isTablet = MediaQuery.of(context).size.width > 768;

    // Show loading during validation
    if (state.isValidating) {
      return _buildLoadingState(theme, isTablet);
    }

    // Show invitation content if valid
    if (state.validation != null && state.validation!.valid) {
      return _buildInvitationContent(state, theme, isTablet);
    }

    // For deeplink invitations (widget.inviteCode provided), show full error page
    // For manual code entry (widget.inviteCode null), show error inline in the form
    if (widget.inviteCode != null) {
      // CRITICAL FIX: Check for validation errors from provider state.error
      // This handles 400 API errors that don't create a validation object
      if (state.error != null) {
        return _buildErrorState(state, theme, isTablet);
      }

      // Show error if validation failed
      if (state.validation != null && !state.validation!.valid) {
        return _buildErrorState(state, theme, isTablet);
      }
    }

    // Show manual code input (with inline error if any)
    return _buildManualCodeInput(theme, isTablet, errorKey: state.error);
  }

  Widget _buildManualCodeInput(ThemeData theme, bool isTablet, {String? errorKey}) {
    // Get localized error message if error exists
    String? errorMessage;
    if (errorKey != null) {
      final l10n = AppLocalizations.of(context);
      errorMessage = _getLocalizedErrorMessage(l10n, errorKey);
    }

    return InvitationManualCodeInput(
      invitationType: ui.InvitationType.family, // ✅ Type-specific behavior
      icon: Icons.people,
      controller: _manualCodeController,
      onValidate: _handleManualCodeValidation,
      onCancel: _handleCancelInvitationCode,
      errorMessage: errorMessage,
      isTablet: isTablet,
    );
  }

  String _getLocalizedErrorMessage(AppLocalizations l10n, String errorKey) {
    switch (errorKey) {
      case 'errorInvitationCodeInvalid':
        return l10n.errorInvitationCodeInvalid;
      case 'errorInvitationNotFound':
        return l10n.errorInvitationNotFound;
      case 'errorInvitationExpired':
        return l10n.errorInvitationExpired;
      case 'errorInvitationCancelled':
        return l10n.errorInvitationCancelled;
      default:
        return l10n.errorUnexpected;
    }
  }

  void _handleCancelInvitationCode() {
    // Navigate back to onboarding wizard
    ref.read(navigationStateProvider.notifier).clearNavigation();
    ref.read(navigationStateProvider.notifier).navigateTo(
      route: '/onboarding/wizard',
      trigger: NavigationTrigger.userNavigation,
    );
  }

  Widget _buildLoadingState(ThemeData theme, bool isTablet) {
    return InvitationLoadingState(
      invitationType: ui.InvitationType.family, // ✅ Type-specific message
      isTablet: isTablet,
    );
  }

  Widget _buildErrorState(
    FamilyInvitationState state,
    ThemeData theme,
    bool isTablet,
  ) {
    final l10n = AppLocalizations.of(context);
    final canGoBack = Navigator.of(context).canPop();

    return InvitationErrorDisplay(
      errorKey: state.error ?? 'errorUnexpected',
      contextTitle: 'Family Management',
      isTablet: isTablet,
      actionButtonText: canGoBack ? l10n.goBack : l10n.cancel,
      onAction: () {
        if (canGoBack) {
          Navigator.of(context).pop();
        } else {
          ref.read(navigationStateProvider.notifier).navigateTo(
            route: '/dashboard',
            trigger: NavigationTrigger.userNavigation,
          );
        }
      },
    );
  }

  Widget _buildInvitationContent(
    FamilyInvitationState state,
    ThemeData theme,
    bool isTablet,
  ) {
    final invitation = state.validation!;
    final roleDisplay = invitation.role != null
        ? (_convertStringToFamilyRole(invitation.role) == FamilyRole.admin ? 'Administrator' : 'Member')
        : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.people,
          size: isTablet ? 56 : 48,
          color: theme.colorScheme.primary,
        ),
        SizedBox(height: isTablet ? 20 : 16),
        Text(
          'Family Invitation',
          style: (isTablet
              ? theme.textTheme.headlineSmall
              : theme.textTheme.titleLarge)
              ?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold),
        ),
        SizedBox(height: isTablet ? 16 : 12),

        // Compact info container with all details
        Container(
          key: const Key('invitation_family_info'),
          padding: EdgeInsets.all(isTablet ? 16 : 14),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Family name
              RichText(
                key: const Key('invitation_family_name'),
                text: TextSpan(
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer),
                  children: [
                    TextSpan(
                      text: '${AppLocalizations.of(context).youveBeenInvitedToJoin}\n',
                    ),
                    TextSpan(
                      text: invitation.familyName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),

              // Inviter + Role in one line if both present
              if (invitation.inviterName != null || roleDisplay != null) ...[
                SizedBox(height: isTablet ? 12 : 10),
                Divider(color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.2)),
                SizedBox(height: isTablet ? 12 : 10),
              ],

              if (invitation.inviterName != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(Icons.person_outline,
                        size: 16,
                        color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.9),
                            ),
                            children: [
                              TextSpan(
                                text: '${AppLocalizations.of(context).invitedBy} ',
                              ),
                              TextSpan(
                                text: invitation.inviterName!,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              if (roleDisplay != null)
                Row(
                  children: [
                    Icon(Icons.badge_outlined,
                      size: 16,
                      color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7)),
                    const SizedBox(width: 8),
                    Text(
                      'Role: $roleDisplay',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),

        SizedBox(height: isTablet ? 24 : 20),

        // Action buttons based on authentication state
        _buildActionButtons(state, theme, isTablet),
      ],
    );
  }

  Widget _buildActionButtons(
      FamilyInvitationState state, ThemeData theme, bool isTablet) {
    final invitation = state.validation!;
    final l10n = AppLocalizations.of(context);
    final canGoBack = Navigator.of(context).canPop();

    // Not authenticated - show sign in options + cancel
    if (!state.isAuthenticated) {
      return Column(
        children: [
          _buildUnauthenticatedActions(invitation, theme, isTablet),
          SizedBox(height: isTablet ? 16 : 12),
          _buildFullWidthButton(
            key: const Key('familyInvitation_unauthCancel_button'),
            onPressed: () {
              if (canGoBack) {
                Navigator.of(context).pop();
              } else {
                // No navigation history - go to dashboard
                ref.read(navigationStateProvider.notifier).navigateTo(
                  route: '/dashboard',
                  trigger: NavigationTrigger.userNavigation,
                );
              }
            },
            child: Text(canGoBack ? l10n.goBack : l10n.cancel),
            isSecondary: true,
          ),
        ],
      );
    }

    // Authenticated without family - show join button + cancel
    if (!state.hasFamily) {
      return Column(
        children: [
          _buildFullWidthButton(
            key: const Key('join_family_button'),
            onPressed: state.isLoading ? null : _handleJoinFamily,
            child: state.isLoading
                ? SizedBox(
                    height: isTablet ? 24 : 20,
                    width: isTablet ? 24 : 20,
                    child: const CircularProgressIndicator(strokeWidth: 2))
                : Text(l10n.joinFamilyName(invitation.familyName ?? l10n.unknownFamily)),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          _buildFullWidthButton(
            key: const Key('familyInvitation_noFamilyCancel_button'),
            onPressed: () {
              if (canGoBack) {
                Navigator.of(context).pop();
              } else {
                // No navigation history - go to dashboard
                ref.read(navigationStateProvider.notifier).navigateTo(
                  route: '/dashboard',
                  trigger: NavigationTrigger.userNavigation,
                );
              }
            },
            child: Text(canGoBack ? l10n.goBack : l10n.cancel),
            isSecondary: true,
          ),
        ],
      );
    }

    // Authenticated with family - show family conflict options (already has cancel in _buildFamilyConflictActions)
    return _buildFamilyConflictActions(invitation, theme, isTablet);
  }

  Widget _buildUnauthenticatedActions(
      FamilyInvitationValidationDto invitation,
      ThemeData theme,
      bool isTablet) {
    // FamilyInvitationValidationDto doesn't have existingUser field
    // Using requiresAuth as alternative logic - if requires auth, show sign in
    if (invitation.requiresAuth == true) {
      // User needs to authenticate - show magic link option
      return _buildFullWidthButton(
        key: const Key('familyInvitation_sendMagicLink_button'),
        onPressed: _handleSignInExistingUser,
        child: Text(AppLocalizations.of(context).sendMagicLink),
      );
    } else {
      // New user - show signup form or button
      if (!_showSignupForm) {
        return _buildFullWidthButton(
          key: const Key('invitation_signin_button'),
          onPressed: () => setState(() => _showSignupForm = true),
          child: Text(AppLocalizations.of(context).signInToJoinFamilyName(invitation.familyName ?? 'Family')),
        );
      } else {
        return _buildSignupForm(theme, isTablet);
      }
    }
  }

  Widget _buildSignupForm(ThemeData theme, bool isTablet) {
    final authState = ref.watch(authStateProvider);
    return Form(
      key: _formKey,
      child: EmailWithProgressiveName(
        emailController: _emailController,
        nameController: _nameController,
        onSubmit: _handleSignupSubmit,
        submitButtonText: 'Send Magic Link',
        isLoading: authState.isLoading,
      ),
    );
  }

  Widget _buildFamilyConflictActions(
      FamilyInvitationValidationDto invitation,
      ThemeData theme,
      bool isTablet) {
    // FamilyInvitationValidationDto doesn't have family conflict fields
    // Using alreadyMember as indication of conflict
    if (invitation.alreadyMember == true) {
      return Column(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(isTablet ? 16 : 12)),
            child: Row(
              children: [
                Icon(Icons.warning, color: theme.colorScheme.error),
                SizedBox(width: isTablet ? 16 : 12),
                Expanded(
                  child: Text(
                    'You are already a member of this family',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current family: Already a member', // userCurrentFamily doesn't exist in DTO
                style: theme.textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'New invitation: ${invitation.familyName ?? 'Unknown Family'}',
                style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(height: isTablet ? 20 : 16),
        _buildFullWidthButton(
          key: const Key('leave_and_join_family_button'),
          onPressed: _handleLeaveAndJoin,
          child: Text(AppLocalizations.of(context).leaveFamilyAndJoinFamilyName(invitation.familyName ?? 'this family')),
          isDestructive: true,
        ),
        SizedBox(height: isTablet ? 16 : 12),
        _buildFullWidthButton(
          key: const Key('cancel_invitation_button'),
          onPressed: () async {
            // ARCHITECTURE FIX: Direct navigation after logout since targetRoute doesn't work
            await ref.read(authStateProvider.notifier).logout();
            ref.read(navigationStateProvider.notifier).navigateTo(
              route: '/auth/login',
              trigger: NavigationTrigger.userNavigation,
            );
          },
          child: Text(AppLocalizations.of(context).cancel),
          isSecondary: true,
        ),
      ],
    );
  }
}
