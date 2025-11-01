import 'package:edulift/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edulift/core/services/providers/auth_provider.dart';
import 'package:edulift/core/presentation/widgets/accessibility/accessible_button.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import '../widgets/email_with_progressive_name.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _canUseBiometric = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  Future<void> _checkBiometricAvailability() async {
    final authState = ref.read(authStateProvider);
    setState(() {
      _canUseBiometric = authState.canUseBiometric;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    // ARCHITECTURE FIX: Remove page-level auth navigation listener
    // Let router handle all auth-driven navigation through centralized redirect logic
    // This eliminates race conditions between multiple ref.listen callbacks

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 32.0 : 16.0,
                      vertical: isTablet ? 24.0 : 16.0,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: isTablet ? 40 : 24),

                          // App Logo with Material Design 3 styling - Mobile responsive
                          Container(
                            padding: EdgeInsets.all(isTablet ? 20 : 12),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(
                                isTablet ? 24 : 16,
                              ),
                            ),
                            child: Image.asset(
                              'assets/images/logos/edulift_logo_192.png',
                              width: isTablet ? 120 : 80,
                              height: isTablet ? 120 : 80,
                            ),
                          ),
                          SizedBox(height: isTablet ? 32 : 20),

                          // Welcome Text - Mobile responsive typography
                          Text(
                            l10n.welcomeToEduLiftLogin,
                            key: const Key('welcomeToEduLift'),
                            style:
                                (isTablet
                                        ? Theme.of(
                                            context,
                                          ).textTheme.displaySmall
                                        : Theme.of(
                                            context,
                                          ).textTheme.headlineMedium)
                                    ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: isTablet ? 8 : 6),
                          Text(
                            l10n.secureLogin,
                            style:
                                (isTablet
                                        ? Theme.of(context).textTheme.bodyLarge
                                        : Theme.of(
                                            context,
                                          ).textTheme.bodyMedium)
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: isTablet ? 48 : 32),

                          // Progressive Disclosure Email+Name Form
                          EmailWithProgressiveName(
                            emailController: _emailController,
                            nameController: _nameController,
                            onSubmit: _sendMagicLink,
                            submitButtonText: authState.showNameField
                                ? l10n.createAccount
                                : l10n.continueButton,
                            isLoading:
                                authState.isLoading ||
                                authState.isCheckingUserStatus,
                          ),

                          SizedBox(height: isTablet ? 16 : 12),

                          if (_canUseBiometric && !authState.showNameField)
                            AccessibleButton.outlined(
                              key: const Key('biometricButton'),
                              onPressed:
                                  (authState.isLoading ||
                                      authState.isCheckingUserStatus)
                                  ? null
                                  : _authenticateWithBiometric,
                              child: SizedBox(
                                height: isTablet
                                    ? 56
                                    : 48, // Consistent touch target
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.fingerprint,
                                      size: isTablet ? 24 : 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        l10n.biometricAuthentication,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // User Status Info
                          if (authState.isCheckingUserStatus) ...[
                            SizedBox(height: isTablet ? 16 : 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    l10n.checkingUser,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // Error Display
                          if (authState.error != null) ...[
                            SizedBox(height: isTablet ? 16 : 12),
                            Container(
                              key: const Key('errorMessage'),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                () {
                                  final errorKey =
                                      authState.error ?? 'errorGeneral';
                                  switch (errorKey) {
                                    case 'errorNetwork':
                                    case 'errorNetworkGeneral':
                                      return l10n.errorNetworkMessage;
                                    case 'errorServer':
                                    case 'errorServerGeneral':
                                      return l10n.errorServerMessage;
                                    case 'errorAuth':
                                      return l10n.errorAuthMessage;
                                    case 'errorValidation':
                                      return l10n.errorValidationMessage;
                                    default:
                                      return l10n.errorUnexpectedMessage;
                                  }
                                }(),
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onErrorContainer,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _sendMagicLink() async {
    if (!_formKey.currentState!.validate()) {
      // Set validation error in authState so errorMessage widget appears
      final email = _emailController.text.trim();
      final l10n = AppLocalizations.of(context);
      String errorMessage;

      if (email.isEmpty) {
        errorMessage = l10n.emailRequired;
      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
        errorMessage = l10n.invalidEmailFormat;
      } else {
        errorMessage = l10n.errorValidationMessage; // fallback
      }

      // Set validation error in auth state so errorMessage widget appears
      ref.read(authStateProvider.notifier).setError(errorMessage);
      return;
    }

    final email = _emailController.text.trim();
    final name = _nameController.text.trim();
    final authState = ref.read(authStateProvider);
    // Use error-based approach like frontend:
    // Try to send magic link, if error says "Name is required", show name field
    final nameToSend = authState.showNameField ? name : null;

    await ref
        .read(authStateProvider.notifier)
        .sendMagicLink(email, name: nameToSend);

    if (mounted && !ref.read(authStateProvider).isLoading) {
      AppLogger.info(
        '🔍 LOGIN_DEBUG: Magic link send completed - auth provider will handle navigation via state-driven intents',
      );
      // ARCHITECTURE FIX: Navigation is handled by router redirect logic
      // The sendMagicLink method updates auth state, router handles navigation automatically
      // This eliminates manual navigation calls and race conditions
    }
  }

  Future<void> _authenticateWithBiometric() async {
    await ref.read(authStateProvider.notifier).authenticateWithBiometric();
    // ARCHITECTURE FIX: Navigation is handled by router redirect logic
    // Biometric authentication success will trigger router redirect logic
    // No manual navigation needed - router handles auth state changes
    AppLogger.info(
      '🔐 LOGIN_DEBUG: Biometric authentication completed - router will handle navigation',
    );
  }
}
