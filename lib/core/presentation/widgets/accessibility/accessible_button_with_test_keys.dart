// EduLift Mobile - Accessible Button with Test Keys
// Demonstrates proper Flutter Key usage for testing

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Accessible button component with proper test keys
/// ✅ Uses Flutter Key pattern: [ComponentName]-[ElementType]-[descriptiveName]
/// ✅ Stable selectors with Key widgets
/// ❌ Does NOT use regex or multiple selectors
/// ✅ Meaningful test identification
class AccessibleButtonWithTestKeys extends StatefulWidget {
  /// Button text label
  final String label;

  /// Callback function when button is pressed
  final VoidCallback? onPressed;

  /// Test ID for this button (follows pattern: [ComponentName]-[ElementType]-[descriptiveName])
  final String testId;

  /// Semantic hint for screen readers
  final String? semanticHint;

  /// Button style variant
  final AccessibleButtonStyle style;

  /// Icon to display alongside text (optional)
  final IconData? icon;

  /// Icon position relative to text
  final IconPosition iconPosition;

  /// Whether button should expand to fill available width
  final bool isFullWidth;

  /// Loading state
  final bool isLoading;

  const AccessibleButtonWithTestKeys({
    super.key,
    required this.label,
    required this.testId, // Required for testing
    this.onPressed,
    this.semanticHint,
    this.style = AccessibleButtonStyle.primary,
    this.icon,
    this.iconPosition = IconPosition.leading,
    this.isFullWidth = false,
    this.isLoading = false,
  });

  @override
  State<AccessibleButtonWithTestKeys> createState() =>
      _AccessibleButtonWithTestKeysState();
}

class _AccessibleButtonWithTestKeysState
    extends State<AccessibleButtonWithTestKeys>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    // ✅ MAIN BUTTON WITH TEST KEY
    // Pattern: [ComponentName]-[ElementType]-[descriptiveName]
    return Semantics(
      label: widget.label,
      hint: widget.semanticHint,
      button: true,
      enabled: isEnabled,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildButton(context, theme, isEnabled),
          );
        },
      ),
    );
  }

  Widget _buildButton(BuildContext context, ThemeData theme, bool isEnabled) {
    final size = _getDefaultSize();
    const minSize = Size(44, 44);
    final effectiveSize = Size(
      size.width < minSize.width ? minSize.width : size.width,
      size.height < minSize.height ? minSize.height : size.height,
    );

    return SizedBox(
      width: widget.isFullWidth ? double.infinity : effectiveSize.width,
      height: effectiveSize.height,
      child: Material(
        // ✅ MAIN BUTTON KEY - Primary test identifier
        key: Key(widget.testId),
        color: _getBackgroundColor(theme, isEnabled),
        borderRadius: _getBorderRadius(),
        elevation: _getElevation(),
        child: InkWell(
          // ✅ INKWELL KEY - For interaction testing
          key: Key('${widget.testId}-InkWell'),
          onTap: isEnabled ? _handleTap : null,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          borderRadius: _getBorderRadius(),
          child: Container(
            padding: _getPadding(),
            child: _buildButtonContent(theme, isEnabled),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent(ThemeData theme, bool isEnabled) {
    if (widget.isLoading) {
      return _buildLoadingContent(theme, isEnabled);
    }

    final textColor = _getTextColor(theme, isEnabled);

    if (widget.icon == null) {
      return _buildTextOnly(textColor);
    }

    return _buildTextWithIcon(textColor);
  }

  Widget _buildLoadingContent(ThemeData theme, bool isEnabled) {
    final loadingColor = _getTextColor(theme, isEnabled);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ✅ LOADING INDICATOR KEY - For loading state testing
        SizedBox(
          key: Key('${widget.testId}-LoadingIndicator'),
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
          ),
        ),
        const SizedBox(width: 8),
        // ✅ LOADING TEXT KEY - For loading text testing
        Text(
          'Loading...',
          key: Key('${widget.testId}-LoadingText'),
          style: _getTextStyle().copyWith(color: loadingColor),
        ),
      ],
    );
  }

  Widget _buildTextOnly(Color textColor) {
    // ✅ BUTTON TEXT KEY - For text content testing
    return Text(
      widget.label,
      key: Key('${widget.testId}-Text'),
      style: _getTextStyle().copyWith(color: textColor),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildTextWithIcon(Color textColor) {
    // ✅ BUTTON ICON KEY - For icon testing
    final icon = Icon(
      widget.icon,
      key: Key('${widget.testId}-Icon'),
      color: textColor,
      size: 18,
    );

    // ✅ BUTTON TEXT KEY - For text content testing
    final text = Text(
      widget.label,
      key: Key('${widget.testId}-Text'),
      style: _getTextStyle().copyWith(color: textColor),
    );

    if (widget.iconPosition == IconPosition.leading) {
      return Row(
        key: Key('${widget.testId}-ContentRow'),
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 8),
          Flexible(child: text),
        ],
      );
    } else {
      return Row(
        key: Key('${widget.testId}-ContentRow'),
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(child: text),
          const SizedBox(width: 8),
          icon,
        ],
      );
    }
  }

  // Event handlers with haptic feedback
  void _handleTap() {
    _provideTactileFeedback();
    widget.onPressed?.call();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _provideTactileFeedback() {
    HapticFeedback.lightImpact();
  }

  // Style helper methods
  Color _getBackgroundColor(ThemeData theme, bool isEnabled) {
    switch (widget.style) {
      case AccessibleButtonStyle.primary:
        return isEnabled
            ? theme.colorScheme.primary
            : theme.colorScheme.primary.withValues(alpha: 0.12);
      case AccessibleButtonStyle.secondary:
        return isEnabled
            ? theme.colorScheme.secondary
            : theme.colorScheme.secondary.withValues(alpha: 0.12);
      case AccessibleButtonStyle.outline:
      case AccessibleButtonStyle.text:
        return Colors.transparent;
    }
  }

  Color _getTextColor(ThemeData theme, bool isEnabled) {
    switch (widget.style) {
      case AccessibleButtonStyle.primary:
        return isEnabled
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurface.withValues(alpha: 0.38);
      case AccessibleButtonStyle.secondary:
        return isEnabled
            ? theme.colorScheme.onSecondary
            : theme.colorScheme.onSurface.withValues(alpha: 0.38);
      case AccessibleButtonStyle.outline:
      case AccessibleButtonStyle.text:
        return isEnabled
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withValues(alpha: 0.38);
    }
  }

  Size _getDefaultSize() {
    switch (widget.style) {
      case AccessibleButtonStyle.primary:
      case AccessibleButtonStyle.secondary:
        return const Size(120, 48);
      case AccessibleButtonStyle.outline:
        return const Size(120, 44);
      case AccessibleButtonStyle.text:
        return const Size(88, 44);
    }
  }

  BorderRadius _getBorderRadius() {
    return BorderRadius.circular(8);
  }

  double _getElevation() {
    switch (widget.style) {
      case AccessibleButtonStyle.primary:
      case AccessibleButtonStyle.secondary:
        return _isPressed ? 1 : 2;
      case AccessibleButtonStyle.outline:
      case AccessibleButtonStyle.text:
        return 0;
    }
  }

  EdgeInsets _getPadding() {
    if (widget.icon != null) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    }
    return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
  }

  TextStyle _getTextStyle() {
    return const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.25,
    );
  }
}

/// Button style variants following Material 3 design
enum AccessibleButtonStyle { primary, secondary, outline, text }

/// Icon position relative to text
enum IconPosition { leading, trailing }

/// Example usage with proper test keys:
///
/// ```dart
/// AccessibleButtonWithTestKeys(
///   testId: 'Auth-Button-login',           // ✅ Proper test ID pattern
///   label: 'Sign In',
///   onPressed: () => _handleLogin(),
///   icon: Icons.login,
/// )
///
/// // In tests:
/// await tester.tap(find.byKey(Key('Auth-Button-login')));           // ✅ Main button
/// await tester.tap(find.byKey(Key('Auth-Button-login-InkWell')));   // ✅ Interaction area
/// expect(find.byKey(Key('Auth-Button-login-Text')), findsOneWidget); // ✅ Text content
/// expect(find.byKey(Key('Auth-Button-login-Icon')), findsOneWidget); // ✅ Icon
/// ```
