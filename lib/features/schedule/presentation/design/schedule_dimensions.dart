import 'package:flutter/material.dart';
import '../../../../core/presentation/themes/app_spacing.dart';

/// Schedule-specific dimensions and constraints
///
/// Reuses AppSpacing where possible, adds Schedule-specific measurements.
class ScheduleDimensions {
  ScheduleDimensions._();

  // ============================================================================
  // SPACING (Reuse global AppSpacing)
  // ============================================================================

  static const double spacingXs = AppSpacing.xs; // 4.0
  static const double spacingSm = AppSpacing.sm; // 8.0
  static const double spacingMd = AppSpacing.md; // 16.0
  static const double spacingLg = AppSpacing.lg; // 24.0
  static const double spacingXl = AppSpacing.xl; // 32.0
  static const double spacingXxl = AppSpacing.xxl; // 48.0

  // ============================================================================
  // TOUCH TARGETS (Material Design AA Compliance)
  // ============================================================================

  /// Minimum touch target (Material Design AA)
  static const double touchTargetMinimum = 48.0;

  /// Recommended touch target (larger for better UX)
  static const double touchTargetRecommended = 56.0;

  /// Icon size (wrapped in 48dp touch area)
  static const double iconSize = 24.0;

  /// Small icon size
  static const double iconSizeSmall = 20.0;

  /// Constraints for minimum touch target
  static const BoxConstraints minimumTouchConstraints = BoxConstraints(
    minWidth: touchTargetMinimum,
    minHeight: touchTargetMinimum,
  );

  // ============================================================================
  // SCHEDULE-SPECIFIC SIZES
  // ============================================================================

  /// Schedule slot height (minimum for touch target compliance)
  static const double slotHeight = 120.0;

  /// Schedule slot width (for horizontal scroll)
  static const double slotWidth = 140.0;

  /// Day header height
  static const double dayHeaderHeight = 56.0;

  /// Time header height
  static const double timeHeaderHeight = 48.0;

  /// Drag handle dimensions
  static const double dragHandleWidth = 40.0;
  static const double dragHandleHeight = 4.0;

  /// Bottom sheet initial size (60% of screen)
  static const double bottomSheetInitialSize = 0.6;

  /// Bottom sheet max size (90% of screen)
  static const double bottomSheetMaxSize = 0.9;

  /// Capacity progress bar height
  static const double capacityBarHeight = 8.0;

  /// Vehicle card height
  static const double vehicleCardHeight = 88.0;

  /// Child row height (for checkboxes - Material Design)
  static const double childRowHeight = 72.0;

  // ============================================================================
  // BORDER RADIUS (Reuse global AppSpacing for consistency)
  // ============================================================================

  /// Reuse global radius values to maintain visual consistency across app
  static const double radiusSm = AppSpacing.radiusSm; // 4.0
  static const double radiusMd = AppSpacing.radiusMd; // 8.0
  static const double radiusLg = AppSpacing.radiusLg; // 12.0
  static const double radiusXl = AppSpacing.radiusXl; // 16.0

  /// Semantic radius configurations for Schedule components
  static const BorderRadius cardRadius =
      BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius modalRadius =
      BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius buttonRadius =
      BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius pillRadius =
      BorderRadius.all(Radius.circular(100.0));

  // ============================================================================
  // ELEVATION
  // ============================================================================

  static const double elevationNone = 0.0;
  static const double elevationCard = 1.0;
  static const double elevationCardHovered = 2.0;
  static const double elevationModal = 3.0;
  static const double elevationDropdown = 4.0;
}
