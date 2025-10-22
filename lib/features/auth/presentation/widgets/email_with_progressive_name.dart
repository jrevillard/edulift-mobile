import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/providers/auth_provider.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';

/// A reusable widget that implements Progressive Disclosure pattern:
/// 1. User enters email first
/// 2. If user doesn't exist, name field appears automatically
/// 3. If user exists, only email is needed
class EmailWithProgressiveName extends ConsumerStatefulWidget {
  final TextEditingController emailController;
  final TextEditingController nameController;
  final VoidCallback onSubmit;
  final String submitButtonText;
  final String? loadingText;
  final bool isLoading;
  final Widget? submitIcon;
  final bool enableBiometric;

  const EmailWithProgressiveName({
    super.key,
    required this.emailController,
    required this.nameController,
    required this.onSubmit,
    required this.submitButtonText,
    this.loadingText,
    this.isLoading = false,
    this.submitIcon,
    this.enableBiometric = false,
  });

  @override
  ConsumerState<EmailWithProgressiveName> createState() =>
      _EmailWithProgressiveNameState();
}

class _EmailWithProgressiveNameState
    extends ConsumerState<EmailWithProgressiveName> {
  void _onEmailChanged(String email) {
    // Clear any previous errors and user status when email changes
    if (email != ref.read(authStateProvider).pendingEmail) {
      ref.read(authStateProvider.notifier).clearUserStatus();
      ref.read(authStateProvider.notifier).clearError();
      // Clear the name field when email changes
      widget.nameController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final l10n = AppLocalizations.of(context);
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Column(
      children: [
        // Email Field
        TextFormField(
          key: const Key('emailField'),
          controller: widget.emailController,
          decoration: InputDecoration(
            labelText: l10n.email,
            hintText: 'Enter your email address',
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isTablet ? 12.0 : 8.0),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isTablet ? 20.0 : 16.0,
              vertical: isTablet ? 18.0 : 14.0,
            ),
            errorText: authState.error?.contains('email') == true
                ? authState.error
                : null,
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: authState.showNameField ? TextInputAction.next : TextInputAction.done,
          onChanged: _onEmailChanged,
          onFieldSubmitted: (_) {
            // If name field is visible, focus on it; otherwise submit form
            if (!authState.showNameField && !widget.isLoading) {
              widget.onSubmit();
            }
          },
          style: TextStyle(fontSize: isTablet ? 18.0 : 16.0),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.validation;
            }
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return l10n.invalidEmailFormat;
            }
            return null;
          },
        ),

        // Show name field if user doesn't exist
        if (authState.showNameField) ...[
          SizedBox(height: isTablet ? 20.0 : 16.0),

          // Welcome message for new users
          Container(
            key: const Key('auth_welcome_message'),
            padding: EdgeInsets.all(isTablet ? 16.0 : 12.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(isTablet ? 12.0 : 8.0),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person_add,
                  color: Theme.of(context).colorScheme.primary,
                  size: isTablet ? 24.0 : 20.0,
                ),
                SizedBox(width: isTablet ? 12.0 : 8.0),
                Expanded(
                  child: Text(
                    l10n.welcomeNewUser,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: isTablet ? 16.0 : 14.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isTablet ? 16.0 : 12.0),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: TextFormField(
              key: const Key('nameField'),
              controller: widget.nameController,
              decoration: InputDecoration(
                labelText: l10n.name,
                hintText: l10n.enterFullName,
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 12.0 : 8.0),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 20.0 : 16.0,
                  vertical: isTablet ? 18.0 : 14.0,
                ),
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) {
                // Submit form when user presses Enter on name field
                if (!widget.isLoading) {
                  widget.onSubmit();
                }
              },
              style: TextStyle(fontSize: isTablet ? 18.0 : 16.0),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context).nameRequired;
                }
                return null;
              },
            ),
          ),
        ],

        SizedBox(height: isTablet ? 32.0 : 24.0),

        // Submit Button
        ElevatedButton(
          key: const Key('login_auth_action_button'), // Restore E2E test key
          onPressed: widget.isLoading ? null : widget.onSubmit,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: isTablet ? 18.0 : 16.0),
            child: widget.isLoading
                ? SizedBox(
                    height: isTablet ? 28.0 : 24.0,
                    width: isTablet ? 28.0 : 24.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.submitIcon != null) ...[
                        widget.submitIcon!,
                        SizedBox(width: isTablet ? 12.0 : 8.0),
                      ],
                      Text(
                        widget.isLoading
                            ? (widget.loadingText ?? 'Loading...')
                            : widget.submitButtonText,
                        style: TextStyle(
                          fontSize: isTablet ? 18.0 : 16.0,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
