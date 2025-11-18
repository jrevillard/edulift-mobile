// EduLift Mobile - Group Invitation Page
// Unified group invitation handling with magic link authentication
// Follows the exact pattern from FamilyInvitationPage

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import '../../../../core/services/providers/auth_provider.dart';
import '../../../../core/presentation/widgets/invitation/invitation_error_display.dart';
import '../../../../core/presentation/widgets/invitation/invitation_loading_state.dart';
import '../../../../core/presentation/widgets/invitation/invitation_manual_code_input.dart'
    show InvitationManualCodeInput, InvitationType;
import '../../../../core/presentation/widgets/accessibility/accessible_button.dart';
import '../../../../core/presentation/utils/responsive_breakpoints.dart';
import '../../../../core/navigation/navigation_state.dart' as nav;
import '../providers/group_invitation_provider.dart';
import '../../../../core/network/group_api_client.dart'
    show GroupInvitationValidationData;
import '../../../auth/presentation/widgets/email_with_progressive_name.dart';
import '../../../../core/presentation/mixins/navigation_cleanup_mixin.dart';

/// Group invitation page handling invitation validation and acceptance
class GroupInvitationPage extends ConsumerStatefulWidget {
  /// Invitation code from URL or manual input
  final String? inviteCode;

  const GroupInvitationPage({super.key, this.inviteCode});

  @override
  ConsumerState<GroupInvitationPage> createState() =>
      _GroupInvitationPageState();
}

class _GroupInvitationPageState extends ConsumerState<GroupInvitationPage>
    with NavigationCleanupMixin {
  final _manualCodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController =
      TextEditingController(); // Added for progressive disclosure
  final _formKey = GlobalKey<FormState>();
  bool _showSignupForm = false;

  @override
  void initState() {
    super.initState();
    // NavigationCleanupMixin automatically clears navigation state

    // Auto-validate if invite code provided
    if (widget.inviteCode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(groupInvitationProvider.notifier)
            .validateInvitation(widget.inviteCode!);
      });
    }
  }

  @override
  void dispose() {
    _manualCodeController.dispose();
    _nameController.dispose();
    _emailController.dispose(); // CRITICAL FIX: Dispose email controller
    super.dispose();
  }

  void _handleManualCodeValidation() {
    final code = _manualCodeController.text.trim();
    if (code.isNotEmpty) {
      ref.read(groupInvitationProvider.notifier).validateInvitation(code);
    }
  }

  void _handleSignInExistingUser() async {
    if (widget.inviteCode != null) {
      // Get current user email OR fallback to form input (matches Family pattern)
      final currentUser = ref.read(currentUserProvider);
      final email = currentUser?.email ?? _emailController.text.trim();
      if (email.isEmpty) return;

      await ref
          .read(authStateProvider.notifier)
          .sendMagicLink(email, inviteCode: widget.inviteCode);

      // ARCHITECTURE: Navigation handled by router redirect logic
      // No manual navigation needed
    }
  }

  void _handleSignupSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.inviteCode != null) {
      // Get email from form input - for new user signup
      final email = _emailController.text.trim();
      if (email.isEmpty) return;

      // Use progressive disclosure logic like Family page
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

      // ARCHITECTURE: Navigation handled by router redirect logic
      // No manual navigation needed
    }
  }

  /// Navigate back to groups page with proper state cleanup
  void _navigateBackToGroups() {
    ref.read(nav.navigationStateProvider.notifier).clearNavigation();
    ref
        .read(nav.navigationStateProvider.notifier)
        .navigateTo(
          route: '/groups',
          trigger: nav.NavigationTrigger.userNavigation,
        );
  }

  void _handleJoinGroup() async {
    // Get invite code from widget (deep link) OR from validated state (manual entry)
    final state = ref.read(groupInvitationProvider);
    final inviteCode = widget.inviteCode ?? state.validatedCode;

    if (inviteCode != null) {
      final result = await ref
          .read(groupInvitationProvider.notifier)
          .acceptGroupInvitationByCode(inviteCode);
      if (result && mounted) {
        // EXPLICIT NAVIGATION: Navigate to groups page after successful group join
        ref.read(nav.navigationStateProvider.notifier).clearNavigation();
        ref
            .read(nav.navigationStateProvider.notifier)
            .navigateTo(
              route: '/groups',
              trigger: nav.NavigationTrigger.userNavigation,
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(groupInvitationProvider);
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Container(
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
          child: Center(
            child: SingleChildScrollView(
              padding: context.getAdaptivePadding(
                mobileAll: 16,
                tabletAll: 24,
                desktopAll: 32,
              ),
              child: Card(
                elevation: 8,
                child: Padding(
                  padding: context.getAdaptivePadding(
                    mobileAll: 20,
                    tabletAll: 24,
                    desktopAll: 32,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: context.getAdaptiveSpacing(
                        mobile: 380,
                        tablet: 420,
                        desktop: 480,
                      ),
                    ),
                    child: _buildContent(context, state, authState, theme),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    GroupInvitationState state,
    AuthState authState,
    ThemeData theme,
  ) {
    // Show loading during validation (highest priority)
    if (state.isValidating) {
      return _buildLoadingState(theme);
    }

    // Show invitation content if validation succeeded
    if (state.validation != null && state.validation!.valid == true) {
      return _buildInvitationContent(state, authState, theme);
    }

    // For MANUAL code entry: show input with inline error (allows user to retry)
    // For DEEP LINK: show full error screen (they came from email, can't retry inline)
    final isManualEntry = widget.inviteCode == null;

    if (state.error != null) {
      if (isManualEntry) {
        // Show manual input with error key inline (user can correct and retry)
        return _buildManualCodeInput(theme, errorKey: state.error);
      } else {
        // Show full error screen for deep link failures
        return _buildErrorState(state, theme);
      }
    }

    // Show validation failed error
    if (state.validation != null && state.validation!.valid == false) {
      if (isManualEntry) {
        // Show manual input with error key inline (user can correct and retry)
        return _buildManualCodeInput(
          theme,
          errorKey: state.error ?? 'errorInvitationCodeInvalid',
        );
      } else {
        // Show full error screen for deep link failures
        return _buildErrorState(state, theme);
      }
    }

    // Fallback: Show manual code input (no validation attempted yet)
    return _buildManualCodeInput(theme);
  }

  Widget _buildManualCodeInput(ThemeData theme, {String? errorKey}) {
    final isTablet = context.isTabletOrLarger;
    final l10n = AppLocalizations.of(context);

    // Translate error key to localized message if provided
    String? localizedError;
    if (errorKey != null) {
      localizedError = _getLocalizedError(l10n, errorKey);
    }

    return InvitationManualCodeInput(
      invitationType: InvitationType.group, // ✅ Type-specific behavior
      icon: Icons.group,
      controller: _manualCodeController,
      onValidate: _handleManualCodeValidation,
      onCancel: _navigateBackToGroups,
      errorMessage: localizedError,
      isTablet: isTablet,
    );
  }

  /// Helper to translate error keys to localized messages
  String _getLocalizedError(AppLocalizations l10n, String errorKey) {
    switch (errorKey) {
      case 'errorInvitationCodeInvalid':
        return l10n.errorInvitationCodeInvalid;
      case 'errorInvitationNotFound':
        return l10n.errorInvitationNotFound;
      case 'errorInvitationExpired':
        return l10n.errorInvitationExpired;
      default:
        return errorKey; // Fallback to error key itself
    }
  }

  Widget _buildLoadingState(ThemeData theme) {
    final isTablet = context.isTabletOrLarger;
    return InvitationLoadingState(
      invitationType: InvitationType.group, // ✅ Type-specific message
      isTablet: isTablet,
    );
  }

  Widget _buildErrorState(GroupInvitationState state, ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    final canGoBack = Navigator.of(context).canPop();

    return InvitationErrorDisplay(
      errorKey: state.error ?? 'errorInvitationCodeInvalid',
      contextTitle: l10n.groupManagement,
      actionButtonText: canGoBack ? l10n.goBack : l10n.cancel,
      onAction: () {
        if (canGoBack) {
          Navigator.of(context).pop();
        } else {
          ref
              .read(nav.navigationStateProvider.notifier)
              .navigateTo(
                route: '/dashboard',
                trigger: nav.NavigationTrigger.userNavigation,
              );
        }
      },
    );
  }

  Widget _buildInvitationContent(
    GroupInvitationState state,
    AuthState authState,
    ThemeData theme,
  ) {
    final validation = state.validation!;
    final l10n = AppLocalizations.of(context);
    final isTablet = context.isTabletOrLarger;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.group,
          size: isTablet ? 56 : 48,
          color: theme.colorScheme.primary,
        ),
        SizedBox(height: isTablet ? 20 : 16),
        Text(
          l10n.groupInvitation,
          style:
              (isTablet
                      ? theme.textTheme.headlineSmall
                      : theme.textTheme.titleLarge)
                  ?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
        ),
        SizedBox(height: isTablet ? 16 : 12),

        // Compact info container with all details
        Container(
          padding: EdgeInsets.all(isTablet ? 16 : 14),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group name
              RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  children: [
                    TextSpan(text: '${l10n.youveBeenInvitedToJoin}\n'),
                    TextSpan(
                      text: validation.groupName ?? l10n.aGroup,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // Inviter info with icon
              if (validation.inviterName != null) ...[
                SizedBox(height: isTablet ? 12 : 10),
                Divider(
                  color: theme.colorScheme.onPrimaryContainer.withValues(
                    alpha: 0.2,
                  ),
                ),
                SizedBox(height: isTablet ? 12 : 10),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: theme.colorScheme.onPrimaryContainer.withValues(
                        alpha: 0.7,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer
                                .withValues(alpha: 0.9),
                          ),
                          children: [
                            TextSpan(text: '${l10n.invitedBy} '),
                            TextSpan(
                              text: validation.inviterName!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        SizedBox(height: isTablet ? 24 : 20),

        // Action buttons based on authentication state
        _buildActionButtons(authState, validation, theme),
      ],
    );
  }

  Widget _buildActionButtons(
    AuthState authState,
    GroupInvitationValidationData validation,
    ThemeData theme,
  ) {
    final l10n = AppLocalizations.of(context);
    final canGoBack = Navigator.of(context).canPop();

    // Not authenticated - show sign in options + cancel
    if (!authState.isAuthenticated) {
      return Column(
        children: [
          _buildUnauthenticatedActions(validation, theme),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: AccessibleButton.secondaryStyle(
              key: const Key('groupInvitation_cancel_button'),
              onPressed: () {
                if (canGoBack) {
                  Navigator.of(context).pop();
                } else {
                  // No navigation history - go to dashboard
                  ref
                      .read(nav.navigationStateProvider.notifier)
                      .navigateTo(
                        route: '/dashboard',
                        trigger: nav.NavigationTrigger.userNavigation,
                      );
                }
              },
              child: Text(canGoBack ? l10n.goBack : l10n.cancel),
            ),
          ),
        ],
      );
    }

    // Authenticated - show join button + cancel
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: AccessibleButton(
            key: const Key('groupInvitation_joinGroup_button'),
            onPressed: _handleJoinGroup,
            child: Text(l10n.joinGroupName(validation.groupName ?? 'Group')),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: AccessibleButton.secondaryStyle(
            key: const Key('groupInvitation_cancel_button'),
            onPressed: () {
              if (canGoBack) {
                Navigator.of(context).pop();
              } else {
                _navigateBackToGroups();
              }
            },
            child: Text(canGoBack ? l10n.goBack : l10n.cancel),
          ),
        ),
      ],
    );
  }

  Widget _buildUnauthenticatedActions(
    GroupInvitationValidationData validation,
    ThemeData theme,
  ) {
    final l10n = AppLocalizations.of(context);
    // Check if user needs authentication (matches Family pattern using requiresAuth)
    if (validation.requiresAuth == true) {
      // EXISTING USER: Show magic link button immediately
      return SizedBox(
        width: double.infinity,
        child: AccessibleButton(
          key: const Key('groupInvitation_signIn_button'),
          onPressed: _handleSignInExistingUser,
          child: Text(l10n.sendMagicLink),
        ),
      );
    } else {
      // NEW USER: Show signup form toggle
      if (!_showSignupForm) {
        return SizedBox(
          width: double.infinity,
          child: AccessibleButton(
            key: const Key('groupInvitation_showSignup_button'),
            onPressed: () => setState(() => _showSignupForm = true),
            child: Text(
              l10n.signInToJoinGroupName(validation.groupName ?? 'Group'),
            ),
          ),
        );
      } else {
        return _buildSignupForm(theme);
      }
    }
  }

  Widget _buildSignupForm(ThemeData theme) {
    final authState = ref.watch(authStateProvider);
    final l10n = AppLocalizations.of(context);
    return Form(
      key: _formKey,
      child: EmailWithProgressiveName(
        emailController: _emailController,
        nameController: _nameController,
        onSubmit: _handleSignupSubmit,
        submitButtonText: l10n.sendMagicLink,
        isLoading: authState.isLoading,
      ),
    );
  }
}
