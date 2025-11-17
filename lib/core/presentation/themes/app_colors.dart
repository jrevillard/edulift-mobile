import 'package:flutter/material.dart';

/// Application color palette (Material 3)
///
/// This class provides semantic color tokens that adapt to light/dark mode.
/// All colors are built on Material 3 ColorScheme for guaranteed accessibility.
///
/// **IMPORTANT**: When to use AppColors vs Theme.of(context):
/// - USE AppColors: For semantic tokens with business logic (status, badges, days)
/// - USE Theme.of(context): For direct access to Material 3 colors (primary, surface, etc)
///
/// Includes semantic tokens for:
/// - Status states (available, partial, full, conflict)
/// - Component badges (driver, child)
/// - Calendar/scheduling (day colors and icons with i18n support)
/// - Capacity indicators (ok, warning, error)
/// - Status colors (success, error, warning, info)
///
/// Usage examples:
/// ```dart
/// // ✅ CORRECT: Use semantic tokens for business logic
/// Container(
///   color: AppColors.statusAvailable(context),
///   child: Row(
///     children: [
///       Icon(
///         AppColors.getDayIcon('monday', context),
///         color: AppColors.getDayColor('monday'),
///       ),
///       Text(
///         'Available',
///         style: TextStyle(color: AppColors.textPrimaryThemed(context)),
///       ),
///     ],
///   ),
/// )
///
/// // ✅ CORRECT: Use Theme.of for direct color access
/// Container(
///   color: Theme.of(context).colorScheme.primary, // NOT AppColors.primaryThemed()
/// )
/// ```
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // ============================================================================
  // PRIMARY COLORS (Theme aliases - kept for compatibility)
  // ============================================================================

  /// Primary brand color (theme-aware)
  /// NOTE: Consider using Theme.of(context).colorScheme.primary directly for new code
  static Color primaryThemed(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  /// Secondary accent color (theme-aware)
  /// NOTE: Consider using Theme.of(context).colorScheme.secondary directly for new code
  static Color secondary(BuildContext context) =>
      Theme.of(context).colorScheme.secondary;

  /// Tertiary accent color (theme-aware)
  /// NOTE: Consider using Theme.of(context).colorScheme.tertiary directly for new code
  static Color tertiary(BuildContext context) =>
      Theme.of(context).colorScheme.tertiary;

  // ============================================================================
  // TEXT COLORS (Thematic semantic tokens)
  // ============================================================================

  /// Primary text color (highest emphasis, theme-aware)
  /// Use for primary text content that needs to adapt to light/dark mode
  static Color textPrimaryThemed(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  /// Secondary text (medium emphasis, theme-aware)
  /// Use for secondary text content, subtitles, descriptions
  static Color textSecondaryThemed(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  /// Disabled text (low emphasis, theme-aware)
  /// Use for disabled text elements
  static Color textDisabled(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38);

  // ============================================================================
  // SURFACE COLORS (Thematic semantic tokens)
  // ============================================================================

  /// Surface variant (subtle elevation, alternate surface, theme-aware)
  /// Use for card backgrounds, subtle containers, and elevated surfaces
  static Color surfaceVariantThemed(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerHighest;

  // ============================================================================
  // STATUS COLORS (Semantic tokens - widely used in the app)
  // ============================================================================

  /// Success state (theme-aware - uses tertiary)
  /// Use for success indicators, positive feedback, completed actions
  static Color successThemed(BuildContext context) =>
      Theme.of(context).colorScheme.tertiary;

  /// Warning state (theme-aware - uses secondary)
  /// Use for warning indicators, caution messages, attention needed
  static Color warningThemed(BuildContext context) =>
      Theme.of(context).colorScheme.secondary;

  /// Error state (theme-aware - uses error)
  /// Use for error indicators, negative feedback, failed actions
  static Color errorThemed(BuildContext context) =>
      Theme.of(context).colorScheme.error;

  /// Info state (theme-aware - uses primary)
  /// Use for info indicators, neutral messages, informational content
  static Color infoThemed(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  // ============================================================================
  // STATUS SEMANTICS (Slot/Resource states)
  // ============================================================================

  /// Empty slot/resource background (nothing assigned)
  static Color statusEmpty(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerHighest;

  /// Available slot/resource (has capacity)
  /// Uses secondaryContainer for guaranteed ≥4.5:1 contrast in both modes
  static Color statusAvailable(BuildContext context) =>
      Theme.of(context).colorScheme.secondaryContainer;

  /// Partially filled slot/resource (some capacity remaining)
  /// Uses tertiaryContainer for guaranteed ≥4.5:1 contrast in both modes
  static Color statusPartial(BuildContext context) =>
      Theme.of(context).colorScheme.tertiaryContainer;

  /// Full slot/resource (at capacity)
  static Color statusFull(BuildContext context) =>
      Theme.of(context).colorScheme.errorContainer;

  /// Conflict state (over capacity - critical)
  static Color statusConflict(BuildContext context) =>
      Theme.of(context).colorScheme.error;

  // ============================================================================
  // COMPONENT COLORS (Badges, indicators)
  // ============================================================================

  /// Driver/vehicle badge color
  /// Use for driver identification badges, vehicle labels
  static Color driverBadge(BuildContext context) =>
      Theme.of(context).colorScheme.primaryContainer;

  /// Child/participant badge color
  /// Use for child identification badges, participant labels
  static Color childBadge(BuildContext context) =>
      Theme.of(context).colorScheme.secondaryContainer;

  /// Capacity indicator - OK state (brand color)
  static const Color capacityOk = Color(0xFF10B981);

  /// Capacity indicator - Warning state (near full)
  static const Color capacityWarning = Color(0xFFF59E0B);

  /// Capacity indicator - Error state (over capacity)
  static Color capacityError(BuildContext context) =>
      Theme.of(context).colorScheme.error;

  // ============================================================================
  // BORDER COLORS (Thematic semantic tokens)
  // ============================================================================

  /// Default border color (subtle, low emphasis, theme-aware)
  /// Use for subtle borders, dividers, and outlines
  static Color borderThemed(BuildContext context) =>
      Theme.of(context).colorScheme.outlineVariant;

  /// Strong/emphasized border color (high emphasis)
  /// Use for emphasized borders, focus states, important dividers
  static Color borderStrong(BuildContext context) =>
      Theme.of(context).colorScheme.outline;
}
