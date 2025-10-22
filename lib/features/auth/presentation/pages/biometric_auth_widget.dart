import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edulift/core/presentation/widgets/accessibility/accessible_button.dart';

/// Widget for biometric authentication
class BiometricAuthWidget extends StatefulWidget {
  const BiometricAuthWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onAuthenticationSuccess,
    required this.onAuthenticationFailed,
  });

  final String title;
  final String subtitle;
  final VoidCallback onAuthenticationSuccess;
  final Function(String) onAuthenticationFailed;

  @override
  State<BiometricAuthWidget> createState() => _BiometricAuthWidgetState();
}

class _BiometricAuthWidgetState extends State<BiometricAuthWidget>
    with SingleTickerProviderStateMixin {
  bool _isAuthenticating = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          widget.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Subtitle
        Text(
          widget.subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Biometric button
        Center(
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isAuthenticating ? _pulseAnimation.value : 1.0,
                child: child,
              );
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primaryContainer,
                border: Border.all(color: colorScheme.primary, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(40),
                  onTap: _isAuthenticating ? null : _handleBiometricAuth,
                  child: Semantics(
                    label: 'Biometric authentication button',
                    hint: 'Tap to authenticate using biometric authentication',
                    button: true,
                    child: Icon(
                      _isAuthenticating
                          ? Icons.fingerprint
                          : Icons.fingerprint_outlined,
                      size: 40,
                      color: _isAuthenticating
                          ? colorScheme.primary
                          : colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Status text
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isAuthenticating
              ? Text(
                  'Authenticating...',
                  key: const ValueKey('authenticating'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : Text(
                  'Touch sensor or face ID',
                  key: const ValueKey('idle'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
        ),
        const SizedBox(height: 16),

        // Alternative authentication option
        AccessibleTextButton(
          onPressed: _handleSkipBiometric,
          semanticLabel: 'Skip biometric authentication',
          semanticHint: 'Tap to continue without biometric authentication',
          child: Text(
            'Use email instead',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleBiometricAuth() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    // Start pulse animation
    await _pulseController.repeat(reverse: true);

    try {
      // Simulate biometric authentication
      await Future.delayed(const Duration(seconds: 2));

      // Provide haptic feedback
      await HapticFeedback.lightImpact();

      // Stop animation
      _pulseController.stop();
      _pulseController.reset();

      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });

        // Simulate success (in real app, this would depend on actual authentication result)
        widget.onAuthenticationSuccess();
      }
    } catch (e) {
      // Stop animation
      _pulseController.stop();
      _pulseController.reset();

      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });

        // Provide error haptic feedback
        await HapticFeedback.mediumImpact();

        widget.onAuthenticationFailed(e.toString());
      }
    }
  }

  void _handleSkipBiometric() {
    // Close this widget and return to email/password authentication
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}
