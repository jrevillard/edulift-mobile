// EduLift Mobile - Loading Indicator Widget
// Consistent loading states across the application

import 'package:flutter/material.dart';
import '../utils/responsive_breakpoints.dart';

/// A consistent loading indicator widget used throughout the app
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;
  final bool showMessage;

  const LoadingIndicator({
    super.key,
    this.message,
    this.size,
    this.color,
    this.showMessage = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Auto-size based on screen dimensions if size not provided
    final adaptiveSize = size ?? _getDefaultSize(context);
    final adaptiveSpacing = context.getAdaptiveSpacing(
      mobile: 16,
      tablet: 20,
      desktop: 24,
    );

    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.maxContentWidth,
            ),
            child: Padding(
              padding: context.getAdaptivePadding(
                mobileHorizontal: 24,
                tabletHorizontal: 32,
                desktopHorizontal: 48,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: adaptiveSize,
                    height: adaptiveSize,
                    child: CircularProgressIndicator(
                      strokeWidth: _getStrokeWidth(context, adaptiveSize),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        color ?? theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  if (showMessage && message != null) ...[
                    SizedBox(height: adaptiveSpacing),
                    Text(
                      message!,
                      style: _getAdaptiveTextStyle(context, theme),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Get default size based on screen dimensions
  double _getDefaultSize(BuildContext context) {
    return context.getAdaptiveIconSize(
      mobile: 40,
      tablet: 48,
      desktop: 56,
    );
  }

  /// Get adaptive stroke width based on size
  double _getStrokeWidth(BuildContext context, double size) {
    final baseStrokeWidth = size / 15; // Proportional to size
    return baseStrokeWidth.clamp(2.0, 4.0);
  }

  /// Get adaptive text style
  TextStyle? _getAdaptiveTextStyle(BuildContext context, ThemeData theme) {
    final baseStyle = context.isTablet
        ? theme.textTheme.bodyLarge
        : theme.textTheme.bodyMedium;

    return baseStyle?.copyWith(
      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
      fontSize: (baseStyle.fontSize ?? 14) * context.fontScale,
    );
  }
}

/// A smaller loading indicator for inline use
class InlineLoadingIndicator extends StatelessWidget {
  final double? size;
  final Color? color;

  const InlineLoadingIndicator({super.key, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    // Adaptive size for inline use
    final adaptiveSize = size ?? context.getAdaptiveIconSize(
      mobile: 16,
      tablet: 18,
      desktop: 20,
    );

    final strokeWidth = (adaptiveSize / 10).clamp(1.5, 3.0);

    return SizedBox(
      width: adaptiveSize,
      height: adaptiveSize,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

/// A loading overlay that can be used over other widgets
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;
  final Color? overlayColor;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingMessage,
    this.overlayColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: overlayColor ??
              Theme.of(context).colorScheme.scrim.withValues(alpha: 0.4),
            child: LoadingIndicator(
              message: loadingMessage ?? 'Loading...',
              // Use a smaller size for overlay to not overwhelm the UI
              size: context.getAdaptiveIconSize(
                mobile: 36,
                tablet: 42,
                desktop: 48,
              ),
            ),
          ),
      ],
    );
  }
}
