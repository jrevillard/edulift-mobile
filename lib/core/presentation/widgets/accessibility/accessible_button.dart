import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';

enum _ButtonType { elevated, outlined }

/// Accessible button widget that meets AA accessibility standards
class AccessibleButton extends StatelessWidget {
  // Static methods for different button styles
  static AccessibleButton destructiveStyle({
    Key? key,
    required BuildContext context,
    required VoidCallback? onPressed,
    required Widget child,
    String? semanticLabel,
    String? semanticHint,
    String? tooltip,
    bool autofocus = false,
    FocusNode? focusNode,
  }) {
    return AccessibleButton(
      key: key,
      onPressed: onPressed,
      semanticLabel: semanticLabel,
      semanticHint: semanticHint,
      tooltip: tooltip,
      autofocus: autofocus,
      focusNode: focusNode,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.errorThemed(context),
        foregroundColor: Theme.of(context).colorScheme.onError,
      ),
      child: child,
    );
  }

  static AccessibleButton secondaryStyle({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    String? semanticLabel,
    String? semanticHint,
    String? tooltip,
    bool autofocus = false,
    FocusNode? focusNode,
  }) {
    return AccessibleButton.outlined(
      key: key,
      onPressed: onPressed,
      semanticLabel: semanticLabel,
      semanticHint: semanticHint,
      tooltip: tooltip,
      autofocus: autofocus,
      focusNode: focusNode,
      child: child,
    );
  }

  const AccessibleButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.semanticLabel,
    this.semanticHint,
    this.tooltip,
    this.style,
    this.autofocus = false,
    this.focusNode,
  }) : _buttonType = _ButtonType.elevated;

  const AccessibleButton.outlined({
    super.key,
    required this.onPressed,
    required this.child,
    this.semanticLabel,
    this.semanticHint,
    this.tooltip,
    this.style,
    this.autofocus = false,
    this.focusNode,
  }) : _buttonType = _ButtonType.outlined;

  final VoidCallback? onPressed;
  final Widget child;
  final String? semanticLabel;
  final String? semanticHint;
  final String? tooltip;
  final ButtonStyle? style;
  final bool autofocus;
  final FocusNode? focusNode;
  final _ButtonType _buttonType;

  @override
  Widget build(BuildContext context) {
    final Widget button;

    switch (_buttonType) {
      case _ButtonType.elevated:
        button = ElevatedButton(
          onPressed: onPressed,
          style: style ?? _defaultButtonStyle(context),
          autofocus: autofocus,
          focusNode: focusNode,
          child: child,
        );
        break;
      case _ButtonType.outlined:
        button = OutlinedButton(
          onPressed: onPressed,
          style: style ?? _defaultOutlinedButtonStyle(context),
          autofocus: autofocus,
          focusNode: focusNode,
          child: child,
        );
        break;
    }

    Widget semanticsButton = Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: true,
      enabled: onPressed != null,
      child: button,
    );

    if (tooltip != null) {
      semanticsButton = Tooltip(message: tooltip!, child: semanticsButton);
    }

    return semanticsButton;
  }

  ButtonStyle _defaultButtonStyle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ElevatedButton.styleFrom(
      minimumSize: const Size(88, 44), // AA accessibility requirement
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      elevation: 2,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
      disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  ButtonStyle _defaultOutlinedButtonStyle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return OutlinedButton.styleFrom(
      minimumSize: const Size(88, 44), // AA accessibility requirement
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      foregroundColor: colorScheme.primary,
      disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
      side: BorderSide(color: colorScheme.outline),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

/// Accessible icon button widget
class AccessibleIconButton extends StatelessWidget {
  const AccessibleIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.semanticLabel,
    this.semanticHint,
    this.tooltip,
    this.style,
    this.autofocus = false,
    this.focusNode,
  });

  final VoidCallback? onPressed;
  final Widget icon;
  final String? semanticLabel;
  final String? semanticHint;
  final String? tooltip;
  final ButtonStyle? style;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      onPressed: onPressed,
      icon: icon,
      style: style ?? _defaultIconButtonStyle(context),
      autofocus: autofocus,
      focusNode: focusNode,
      tooltip: tooltip,
    );

    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: true,
      enabled: onPressed != null,
      child: button,
    );
  }

  ButtonStyle _defaultIconButtonStyle(BuildContext context) {
    return IconButton.styleFrom(
      minimumSize: const Size(44, 44), // AA accessibility requirement
      iconSize: 24,
      tapTargetSize: MaterialTapTargetSize.padded,
    );
  }
}

/// Accessible text button widget
class AccessibleTextButton extends StatelessWidget {
  const AccessibleTextButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.semanticLabel,
    this.semanticHint,
    this.tooltip,
    this.style,
    this.autofocus = false,
    this.focusNode,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final String? semanticLabel;
  final String? semanticHint;
  final String? tooltip;
  final ButtonStyle? style;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final button = TextButton(
      onPressed: onPressed,
      style: style ?? _defaultTextButtonStyle(context),
      autofocus: autofocus,
      focusNode: focusNode,
      child: child,
    );

    Widget semanticsButton = Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: true,
      enabled: onPressed != null,
      child: button,
    );

    if (tooltip != null) {
      semanticsButton = Tooltip(message: tooltip!, child: semanticsButton);
    }

    return semanticsButton;
  }

  ButtonStyle _defaultTextButtonStyle(BuildContext context) {
    return TextButton.styleFrom(
      minimumSize: const Size(88, 44), // AA accessibility requirement
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      tapTargetSize: MaterialTapTargetSize.padded,
    );
  }
}

/// Accessible floating action button widget
class AccessibleFloatingActionButton extends StatelessWidget {
  const AccessibleFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.semanticLabel,
    this.semanticHint,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.focusElevation,
    this.hoverElevation,
    this.highlightElevation,
    this.autofocus = false,
    this.focusNode,
    this.heroTag,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final String? semanticLabel;
  final String? semanticHint;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final double? focusElevation;
  final double? hoverElevation;
  final double? highlightElevation;
  final bool autofocus;
  final FocusNode? focusNode;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final fab = FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      focusElevation: focusElevation,
      hoverElevation: hoverElevation,
      highlightElevation: highlightElevation,
      autofocus: autofocus,
      focusNode: focusNode,
      heroTag: heroTag,
      tooltip: tooltip,
      child: child,
    );

    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: true,
      enabled: onPressed != null,
      child: fab,
    );
  }
}
