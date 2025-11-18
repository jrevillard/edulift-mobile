import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Comprehensive screen reader support utilities for WCAG 2.1 AA compliance
class ScreenReaderSupport {
  ScreenReaderSupport._();

  /// Announces a message to screen readers
  static Future<void> announce(
    String message, {
    TextDirection? textDirection,
  }) async {
    try {
      // Try to use the new sendAnnouncement method with modern platformDispatcher
      final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
      if (platformDispatcher.views.isNotEmpty) {
        // Use the first available FlutterView
        await SemanticsService.sendAnnouncement(
          platformDispatcher.views.first,
          message,
          textDirection ?? TextDirection.ltr,
        );
        return;
      }
    } catch (e) {
      // If sendAnnouncement fails, we simply don't announce - better than using deprecated API
    }
  }

  /// Announces navigation changes
  static void announceNavigation(String destination) {
    announce('Navigated to $destination');
  }

  /// Announces state changes
  static void announceStateChange(String change) {
    announce(change);
  }

  /// Announces errors with appropriate urgency
  static void announceError(String error) {
    announce('Error: $error');
  }

  /// Announces success messages
  static void announceSuccess(String message) {
    announce('Success: $message');
  }

  /// Announces loading states
  static void announceLoading(String action) {
    announce('Loading $action, please wait');
  }

  /// Announces completion of loading
  static void announceLoadingComplete(String action) {
    announce('$action loaded');
  }

  /// Announces form validation errors
  static void announceFormError(String fieldName, String error) {
    announce('$fieldName: $error');
  }

  /// Announces when new content is available
  static void announceNewContent(String description) {
    announce('New content available: $description');
  }

  /// Announces conflict detection
  static void announceConflict(String conflictDescription) {
    announce(
      'Conflict detected: $conflictDescription. Options available to resolve.',
    );
  }

  /// Announces when conflicts are resolved
  static void announceConflictResolved(String resolution) {
    announce('Conflict resolved: $resolution');
  }
}

/// Widget that provides semantic enhancements for screen readers
class SemanticWrapper extends StatelessWidget {
  const SemanticWrapper({
    super.key,
    required this.child,
    this.label,
    this.hint,
    this.value,
    this.increasedValue,
    this.decreasedValue,
    this.onIncrease,
    this.onDecrease,
    this.onTap,
    this.onLongPress,
    this.button = false,
    this.link = false,
    this.header = false,
    this.textField = false,
    this.readOnly = false,
    this.focusable = false,
    this.focused = false,
    this.enabled = true,
    this.checked,
    this.selected = false,
    this.toggled,
    this.expanded,
    this.hidden = false,
    this.obscured = false,
    this.multiline = false,
    this.slider = false,
    this.keyboardKey = false,
    this.liveRegion = false,
    this.maxValueLength,
    this.currentValueLength,
    this.container = false,
    this.inMutuallyExclusiveGroup = false,
    this.image = false,
    this.customSemanticsActions,
  });

  final Widget child;
  final String? label;
  final String? hint;
  final String? value;
  final String? increasedValue;
  final String? decreasedValue;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool button;
  final bool link;
  final bool header;
  final bool textField;
  final bool readOnly;
  final bool focusable;
  final bool focused;
  final bool enabled;
  final bool? checked;
  final bool selected;
  final bool? toggled;
  final bool? expanded;
  final bool hidden;
  final bool obscured;
  final bool multiline;
  final bool slider;
  final bool keyboardKey;
  final bool liveRegion;
  final int? maxValueLength;
  final int? currentValueLength;
  final bool container;
  final bool inMutuallyExclusiveGroup;
  final bool image;
  final List<CustomSemanticsAction>? customSemanticsActions;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      increasedValue: increasedValue,
      decreasedValue: decreasedValue,
      onIncrease: onIncrease,
      onDecrease: onDecrease,
      onTap: onTap,
      onLongPress: onLongPress,
      button: button,
      link: link,
      header: header,
      textField: textField,
      readOnly: readOnly,
      focusable: focusable,
      focused: focused,
      enabled: enabled,
      checked: checked,
      selected: selected,
      toggled: toggled,
      expanded: expanded,
      hidden: hidden,
      obscured: obscured,
      multiline: multiline,
      slider: slider,
      keyboardKey: keyboardKey,
      liveRegion: liveRegion,
      maxValueLength: maxValueLength,
      currentValueLength: currentValueLength,
      container: container,
      inMutuallyExclusiveGroup: inMutuallyExclusiveGroup,
      image: image,
      customSemanticsActions: customSemanticsActions != null
          ? Map.fromEntries(
              customSemanticsActions!.map((action) => MapEntry(action, () {})),
            )
          : null,
      child: child,
    );
  }
}

/// Enhanced text widget with better screen reader support
class AccessibleText extends StatelessWidget {
  const AccessibleText(
    this.text, {
    super.key,
    this.style,
    this.semanticLabel,
    this.semanticHint,
    this.isHeader = false,
    this.isImportant = false,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  final String text;
  final TextStyle? style;
  final String? semanticLabel;
  final String? semanticHint;
  final bool isHeader;
  final bool isImportant;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return SemanticWrapper(
      label: semanticLabel ?? text,
      hint: semanticHint,
      header: isHeader,
      child: Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
        semanticsLabel: semanticLabel,
      ),
    );
  }
}

/// Live region for announcing dynamic content changes
class LiveRegion extends StatefulWidget {
  const LiveRegion({
    super.key,
    required this.child,
    this.politeness = Politeness.polite,
    this.announceInitialValue = false,
  });

  final Widget child;
  final Politeness politeness;
  final bool announceInitialValue;

  @override
  State<LiveRegion> createState() => _LiveRegionState();
}

class _LiveRegionState extends State<LiveRegion> {
  String? _previousValue;

  @override
  void initState() {
    super.initState();
    if (widget.announceInitialValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _announceIfChanged();
      });
    }
  }

  @override
  void didUpdateWidget(LiveRegion oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _announceIfChanged();
    });
  }

  void _announceIfChanged() {
    final renderObject = context.findRenderObject();
    if (renderObject is RenderSemanticsGestureHandler) {
      // Get semantics information for accessibility analysis
      final semantics = renderObject.debugSemantics;
      final currentValue =
          semantics?.label ?? semantics?.value ?? semantics?.hint;

      if (currentValue != null && currentValue != _previousValue) {
        ScreenReaderSupport.announce(currentValue);
        _previousValue = currentValue;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SemanticWrapper(liveRegion: true, child: widget.child);
  }
}

enum Politeness { off, polite, assertive }

/// Widget for providing focus management
class FocusableWidget extends StatefulWidget {
  const FocusableWidget({
    super.key,
    required this.child,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.semanticLabel,
    this.semanticHint,
  });

  final Widget child;
  final FocusNode? focusNode;
  final bool autofocus;
  final ValueChanged<bool>? onFocusChange;
  final String? semanticLabel;
  final String? semanticHint;

  @override
  State<FocusableWidget> createState() => _FocusableWidgetState();
}

class _FocusableWidgetState extends State<FocusableWidget> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    _isFocused = _focusNode.hasFocus;
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    final hasFocus = _focusNode.hasFocus;
    if (hasFocus != _isFocused) {
      setState(() {
        _isFocused = hasFocus;
      });
      widget.onFocusChange?.call(hasFocus);

      if (hasFocus && widget.semanticLabel != null) {
        ScreenReaderSupport.announce('Focused on ${widget.semanticLabel}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      child: SemanticWrapper(
        label: widget.semanticLabel,
        hint: widget.semanticHint,
        focusable: true,
        focused: _isFocused,
        child: widget.child,
      ),
    );
  }
}

/// Provides high contrast support
class HighContrastSupport extends StatelessWidget {
  const HighContrastSupport({
    super.key,
    required this.child,
    this.highContrastChild,
  });

  final Widget child;
  final Widget? highContrastChild;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isHighContrast = mediaQuery.highContrast;

    if (isHighContrast && highContrastChild != null) {
      return highContrastChild!;
    }

    return child;
  }
}

/// Provides font scaling support
class FontScalingSupport extends StatelessWidget {
  const FontScalingSupport({
    super.key,
    required this.child,
    this.maxScaleFactor = 2.0,
    this.minScaleFactor = 0.8,
  });

  final Widget child;
  final double maxScaleFactor;
  final double minScaleFactor;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final textScaler = mediaQuery.textScaler;
    final currentScale = textScaler.scale(1.0);
    final clampedScale = currentScale.clamp(minScaleFactor, maxScaleFactor);

    return MediaQuery(
      data: mediaQuery.copyWith(textScaler: TextScaler.linear(clampedScale)),
      child: child,
    );
  }
}

/// Provides motion reduction support
class MotionSupport extends StatelessWidget {
  const MotionSupport({
    super.key,
    required this.child,
    this.reducedMotionChild,
  });

  final Widget child;
  final Widget? reducedMotionChild;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final disableAnimations = mediaQuery.disableAnimations;

    if (disableAnimations && reducedMotionChild != null) {
      return reducedMotionChild!;
    }

    return child;
  }
}

/// Comprehensive accessibility wrapper
class AccessibilityWrapper extends StatelessWidget {
  const AccessibilityWrapper({
    super.key,
    required this.child,
    this.supportHighContrast = true,
    this.supportFontScaling = true,
    this.supportMotionReduction = true,
    this.maxFontScale = 2.0,
    this.minFontScale = 0.8,
    this.highContrastChild,
    this.reducedMotionChild,
  });

  final Widget child;
  final bool supportHighContrast;
  final bool supportFontScaling;
  final bool supportMotionReduction;
  final double maxFontScale;
  final double minFontScale;
  final Widget? highContrastChild;
  final Widget? reducedMotionChild;

  @override
  Widget build(BuildContext context) {
    var result = child;

    if (supportMotionReduction) {
      result = MotionSupport(
        reducedMotionChild: reducedMotionChild,
        child: result,
      );
    }

    if (supportFontScaling) {
      result = FontScalingSupport(
        maxScaleFactor: maxFontScale,
        minScaleFactor: minFontScale,
        child: result,
      );
    }

    if (supportHighContrast) {
      result = HighContrastSupport(
        highContrastChild: highContrastChild,
        child: result,
      );
    }

    return result;
  }
}
