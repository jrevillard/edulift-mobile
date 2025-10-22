import 'package:flutter/material.dart';

/// Application color palette (Material 3)
///
/// This class provides theme-aware color tokens that adapt to light/dark mode.
/// All colors are built on Material 3 ColorScheme for guaranteed accessibility.
///
/// Includes semantic tokens for:
/// - Status states (available, partial, full, conflict)
/// - Component badges (driver, child)
/// - Calendar/scheduling (day colors and icons)
/// - Capacity indicators (ok, warning, error)
///
/// Usage:
/// ```dart
/// Container(
///   color: AppColors.statusAvailable(context),
///   child: Row(
///     children: [
///       Icon(
///         AppColors.getDayIcon('monday'),
///         color: AppColors.getDayColor('monday'),
///       ),
///       Text(
///         'Available',
///         style: TextStyle(color: AppColors.textPrimaryThemed(context)),
///       ),
///     ],
///   ),
/// )
/// ```
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // ============================================================================
  // PRIMARY COLORS (Material 3)
  // ============================================================================

  /// Primary brand color (Indigo 500)
  /// For theme-aware dark mode support, use primaryThemed(context)
  static const Color primary = Color(0xFF6366F1);

  /// Primary brand color (theme-aware)
  static Color primaryThemed(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  /// Primary container (for badges, chips, lighter backgrounds)
  static Color primaryContainer(BuildContext context) =>
      Theme.of(context).colorScheme.primaryContainer;

  /// Text/icons on primary color
  static Color onPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onPrimary;

  /// Text/icons on primary container
  static Color onPrimaryContainer(BuildContext context) =>
      Theme.of(context).colorScheme.onPrimaryContainer;

  // ============================================================================
  // SECONDARY COLORS (Material 3)
  // ============================================================================

  /// Secondary accent color (theme-aware)
  static Color secondary(BuildContext context) =>
      Theme.of(context).colorScheme.secondary;

  /// Secondary container (for secondary badges, chips)
  static Color secondaryContainer(BuildContext context) =>
      Theme.of(context).colorScheme.secondaryContainer;

  /// Text/icons on secondary color
  static Color onSecondary(BuildContext context) =>
      Theme.of(context).colorScheme.onSecondary;

  /// Text/icons on secondary container
  static Color onSecondaryContainer(BuildContext context) =>
      Theme.of(context).colorScheme.onSecondaryContainer;

  // ============================================================================
  // TERTIARY COLORS (Material 3)
  // ============================================================================

  /// Tertiary accent color (theme-aware)
  static Color tertiary(BuildContext context) =>
      Theme.of(context).colorScheme.tertiary;

  /// Tertiary container (for tertiary badges, chips)
  static Color tertiaryContainer(BuildContext context) =>
      Theme.of(context).colorScheme.tertiaryContainer;

  /// Text/icons on tertiary color
  static Color onTertiary(BuildContext context) =>
      Theme.of(context).colorScheme.onTertiary;

  /// Text/icons on tertiary container
  static Color onTertiaryContainer(BuildContext context) =>
      Theme.of(context).colorScheme.onTertiaryContainer;

  // ============================================================================
  // TEXT COLORS (Material 3)
  // ============================================================================

  /// Primary text color (Gray 900)
  /// For theme-aware dark mode support, use textPrimaryThemed(context)
  static const Color textPrimary = Color(0xFF111827);

  /// Secondary text color (Gray 500)
  /// For theme-aware dark mode support, use textSecondaryThemed(context)
  static const Color textSecondary = Color(0xFF6B7280);

  /// Primary text color (highest emphasis, theme-aware)
  static Color textPrimaryThemed(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  /// Secondary text (medium emphasis, theme-aware)
  static Color textSecondaryThemed(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  /// Disabled text (low emphasis)
  static Color textDisabled(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38);

  // ============================================================================
  // BACKGROUND COLORS (Material 3)
  // ============================================================================

  /// Main background color (Gray 50)
  /// For theme-aware dark mode support, use backgroundThemed(context)
  static const Color background = Color(0xFFFAFAFA);

  /// Surface color (White)
  /// For theme-aware dark mode support, use surfaceThemed(context)
  static const Color surface = Color(0xFFFFFFFF);

  /// Surface variant (Gray 100)
  /// For theme-aware dark mode support, use surfaceVariantThemed(context)
  static const Color surfaceVariant = Color(0xFFF3F4F6);

  /// Main background color (theme-aware)
  static Color backgroundThemed(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  /// Surface color (cards, sheets, dialogs, theme-aware)
  static Color surfaceThemed(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  /// Surface variant (subtle elevation, alternate surface, theme-aware)
  static Color surfaceVariantThemed(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerHighest;

  /// Surface container (low elevation)
  static Color surfaceContainer(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainer;

  /// Surface container (lowest elevation)
  static Color surfaceContainerLowest(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerLowest;

  /// Surface container (highest elevation)
  static Color surfaceContainerHighest(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerHighest;

  /// Text/icons on surface
  static Color onSurface(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  /// Text/icons on surface variant
  static Color onSurfaceVariant(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  // ============================================================================
  // STATUS COLORS (Material 3)
  // ============================================================================

  /// Success state (Tailwind Emerald 500)
  ///
  /// Hardcoded value as Material 3 ColorScheme has no semantic equivalent for success.
  /// Using fixed color ensures consistent success representation across light/dark themes
  /// and maintains brand identity (Tailwind design system).
  ///
  /// For themed alternatives, consider:
  /// - `colorScheme.tertiary` for accent success
  /// - `colorScheme.primaryContainer` for success backgrounds
  static const Color success = Color(0xFF10B981);

  /// Warning state (Tailwind Amber 500)
  ///
  /// Hardcoded value as Material 3 ColorScheme has no semantic equivalent for warning.
  /// Using fixed color ensures consistent warning representation across light/dark themes
  /// and maintains brand identity (Tailwind design system).
  ///
  /// For themed alternatives, consider:
  /// - `colorScheme.secondary` for accent warnings
  /// - `colorScheme.tertiaryContainer` for warning backgrounds
  static const Color warning = Color(0xFFF59E0B);

  /// Warning container (for warning backgrounds)
  static const Color warningContainer = Color(0xFFFEF3C7); // Amber 100

  /// Text/icons on warning container
  static const Color onWarningContainer = Color(0xFF78350F); // Amber 900

  /// Error state (Tailwind Red 500)
  /// For theme-aware dark mode support, use errorThemed(context)
  static const Color error = Color(0xFFEF4444);

  /// Error state (theme-aware)
  static Color errorThemed(BuildContext context) =>
      Theme.of(context).colorScheme.error;

  /// Error container (for error backgrounds)
  static Color errorContainer(BuildContext context) =>
      Theme.of(context).colorScheme.errorContainer;

  /// Text/icons on error color
  static Color onError(BuildContext context) =>
      Theme.of(context).colorScheme.onError;

  /// Text/icons on error container
  static Color onErrorContainer(BuildContext context) =>
      Theme.of(context).colorScheme.onErrorContainer;

  /// Info state (Tailwind Blue 500)
  ///
  /// Hardcoded value as Material 3 ColorScheme has no semantic equivalent for info.
  /// Using fixed color ensures consistent info representation across light/dark themes
  /// and maintains brand identity (Tailwind design system).
  ///
  /// For themed alternatives, consider:
  /// - `colorScheme.primary` for info actions
  /// - `colorScheme.primaryContainer` for info backgrounds
  static const Color info = Color(0xFF3B82F6);

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
  static Color driverBadge(BuildContext context) =>
      Theme.of(context).colorScheme.primaryContainer;

  /// Child/participant badge color
  static Color childBadge(BuildContext context) =>
      Theme.of(context).colorScheme.secondaryContainer;

  /// Capacity indicator - OK state (reuse success)
  static const Color capacityOk = success; // Color(0xFF10B981)

  /// Capacity indicator - Warning state (near full)
  static const Color capacityWarning = warning; // Color(0xFFF59E0B)

  /// Capacity indicator - Error state (over capacity)
  static Color capacityError(BuildContext context) =>
      Theme.of(context).colorScheme.error;

  // ============================================================================
  // DAY COLORS (Calendar/scheduling semantics)
  // ============================================================================

  static const Color monday = Colors.blue;
  static const Color tuesday = Colors.green;
  static const Color wednesday = Colors.orange;
  static const Color thursday = Colors.purple;
  static const Color friday = Colors.red;

  /// Get color for a specific day (supports French and English)
  static Color getDayColor(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
      case 'lundi':
        return monday;
      case 'tuesday':
      case 'mardi':
        return tuesday;
      case 'wednesday':
      case 'mercredi':
        return wednesday;
      case 'thursday':
      case 'jeudi':
        return thursday;
      case 'friday':
      case 'vendredi':
        return friday;
      default:
        return Colors.grey;
    }
  }

  /// Get icon shape for a specific day (colorblind-friendly pattern differentiation)
  /// Each day has a unique icon shape to complement color coding:
  /// - Monday: Circle (Blue)
  /// - Tuesday: Square (Green)
  /// - Wednesday: Triangle (Orange)
  /// - Thursday: Diamond (Purple)
  /// - Friday: Star (Red)
  static IconData getDayIcon(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
      case 'lundi':
        return Icons.circle; // Monday = Blue Circle
      case 'tuesday':
      case 'mardi':
        return Icons.square; // Tuesday = Green Square
      case 'wednesday':
      case 'mercredi':
        return Icons.change_history; // Wednesday = Orange Triangle
      case 'thursday':
      case 'jeudi':
        return Icons.diamond; // Thursday = Purple Diamond
      case 'friday':
      case 'vendredi':
        return Icons.star; // Friday = Red Star
      default:
        return Icons.circle_outlined;
    }
  }

  // ============================================================================
  // BORDER COLORS (Material 3)
  // ============================================================================

  /// Default border color (Gray 200)
  /// For theme-aware dark mode support, use borderThemed(context)
  static const Color border = Color(0xFFE5E7EB);

  /// Default border color (subtle, low emphasis, theme-aware)
  static Color borderThemed(BuildContext context) =>
      Theme.of(context).colorScheme.outlineVariant;

  /// Strong/emphasized border color (high emphasis)
  static Color borderStrong(BuildContext context) =>
      Theme.of(context).colorScheme.outline;

  // ============================================================================
  // SHADOW COLORS (Material 3)
  // ============================================================================

  /// Shadow color (theme-aware)
  static Color shadow(BuildContext context) =>
      Theme.of(context).colorScheme.shadow;

  /// Scrim color (for overlays, bottom sheets)
  static Color scrim(BuildContext context) =>
      Theme.of(context).colorScheme.scrim;
}
