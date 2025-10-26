import 'package:flutter/material.dart';

/// Schedule animation configurations
///
/// Defines durations, curves, and common animation configurations
/// with support for reduced motion accessibility.
class ScheduleAnimations {
  ScheduleAnimations._();

  // ============================================================================
  // DURATIONS
  // ============================================================================

  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 400);

  // ============================================================================
  // CURVES
  // ============================================================================

  static const Curve entry = Curves.easeOut;
  static const Curve exit = Curves.easeIn;
  static const Curve spring = Curves.elasticOut;
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;
  static const Curve standard = Curves.easeInOut;

  // ============================================================================
  // COMPONENT-SPECIFIC ANIMATIONS
  // ============================================================================

  /// Capacity bar fill animation
  static const Duration capacityBarDuration = normal;
  static const Curve capacityBarCurve = emphasized;

  /// Card selection animation
  static const Duration cardSelectionDuration = fast;
  static const Curve cardSelectionCurve = entry;

  /// Checkbox toggle animation
  static const Duration checkboxDuration = fast;
  static const Curve checkboxCurve = spring;

  /// Bottom sheet animation
  static const Duration bottomSheetDuration = normal;
  static const Curve bottomSheetCurve = emphasized;

  /// Page transition animation
  static const Duration pageTransitionDuration = normal;
  static const Curve pageTransitionCurve = standard;

  // ============================================================================
  // ACCESSIBILITY
  // ============================================================================

  /// Get duration respecting reduced motion preference
  static Duration getDuration(BuildContext context, Duration normalDuration) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    return disableAnimations ? Duration.zero : normalDuration;
  }

  /// Get curve respecting reduced motion preference
  static Curve getCurve(BuildContext context, Curve normalCurve) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    return disableAnimations ? Curves.linear : normalCurve;
  }
}
