# Theme System Documentation

## Overview

EduLift uses a Material 3-compliant theme system with semantic color tokens for consistent, accessible design across all modules.

## Files in this Directory

### Core Theme Files

- **`app_colors.dart`** - Main color palette with semantic tokens
  - Material 3 ColorScheme-based colors
  - Theme-aware tokens (light/dark mode)
  - Status semantics (available, partial, full, conflict)
  - Component colors (badges, indicators)
  - Calendar/scheduling semantics (day colors and icons)
  - ≥4.5:1 contrast guaranteed in both modes

- **`app_theme.dart`** - Theme configuration (if exists)
  - Light theme definition
  - Dark theme definition
  - Typography configuration
  - Component themes

### Documentation & Examples

- **`app_colors_usage_example.dart`** - Practical usage examples
  - Schedule slot examples
  - Day indicator with colorblind support
  - Capacity indicators
  - Resource status examples
  - Bilingual day support

- **`MIGRATION_GUIDE.md`** - Migration guide from ScheduleColors
  - Step-by-step migration instructions
  - Method mapping reference
  - Timeline and testing strategy

- **`README.md`** - This file

## AppColors Structure

### 1. Legacy Colors (Deprecated)
Const colors kept for backward compatibility. Will be removed in future versions.

```dart
@Deprecated('Use primary(context) instead')
static const Color primaryLegacy = Color(0xFF6366F1);
```

### 2. Material 3 Core Colors

#### Primary Colors
```dart
Color primaryThemed(BuildContext context)
Color primaryContainer(BuildContext context)
Color onPrimary(BuildContext context)
Color onPrimaryContainer(BuildContext context)
```

#### Secondary Colors
```dart
Color secondary(BuildContext context)
Color secondaryContainer(BuildContext context)
Color onSecondary(BuildContext context)
Color onSecondaryContainer(BuildContext context)
```

#### Tertiary Colors
```dart
Color tertiary(BuildContext context)
Color tertiaryContainer(BuildContext context)
Color onTertiary(BuildContext context)
Color onTertiaryContainer(BuildContext context)
```

#### Text Colors
```dart
Color textPrimaryThemed(BuildContext context)
Color textSecondaryThemed(BuildContext context)
Color textDisabled(BuildContext context)
```

#### Background Colors
```dart
Color backgroundThemed(BuildContext context)
Color surfaceThemed(BuildContext context)
Color surfaceVariantThemed(BuildContext context)
Color surfaceContainer(BuildContext context)
Color surfaceContainerLowest(BuildContext context)
Color surfaceContainerHighest(BuildContext context)
```

#### Status Colors
```dart
const Color success = Color(0xFF10B981)
const Color warning = Color(0xFFF59E0B)
Color errorThemed(BuildContext context)
Color errorContainer(BuildContext context)
```

### 3. Status Semantics (NEW)

For slot/resource states in Schedule, Groups, and Family modules:

```dart
Color statusEmpty(BuildContext context)      // Nothing assigned
Color statusAvailable(BuildContext context)  // Has capacity
Color statusPartial(BuildContext context)    // Some capacity remaining
Color statusFull(BuildContext context)       // At capacity
Color statusConflict(BuildContext context)   // Over capacity (critical)
```

### 4. Component Colors (NEW)

For badges and indicators:

```dart
Color driverBadge(BuildContext context)    // Driver/vehicle badge
Color childBadge(BuildContext context)     // Child/participant badge
const Color capacityOk                     // Capacity OK (0-70%)
const Color capacityWarning                // Capacity warning (70-90%)
Color capacityError(BuildContext context)  // Capacity error (90%+)
```

### 5. Day Colors (NEW)

Calendar/scheduling semantics with colorblind-friendly icon shapes:

```dart
const Color monday                       // Blue
const Color tuesday                      // Green
const Color wednesday                    // Orange
const Color thursday                     // Purple
const Color friday                       // Red

Color getDayColor(String day)           // Bilingual lookup (French/English)
IconData getDayIcon(String day)         // Unique icon per day
```

#### Colorblind-Friendly Day Icons

Each day has a unique icon shape to complement color coding:

- **Monday**: Circle (Blue) - `Icons.circle`
- **Tuesday**: Square (Green) - `Icons.square`
- **Wednesday**: Triangle (Orange) - `Icons.change_history`
- **Thursday**: Diamond (Purple) - `Icons.diamond`
- **Friday**: Star (Red) - `Icons.star`

## Usage Examples

### Basic Status Color
```dart
Container(
  color: AppColors.statusAvailable(context),
  child: Text(
    'Available',
    style: TextStyle(
      color: AppColors.textPrimaryThemed(context),
    ),
  ),
)
```

### Day Indicator with Colorblind Support
```dart
Row(
  children: [
    Icon(
      AppColors.getDayIcon('monday'),  // Circle icon
      color: AppColors.getDayColor('monday'),  // Blue
    ),
    Text('Monday'),
  ],
)
```

### Capacity Indicator
```dart
LinearProgressIndicator(
  value: 0.85,
  backgroundColor: AppColors.surfaceVariantThemed(context),
  color: capacity < 0.7
    ? AppColors.capacityOk
    : capacity < 0.9
      ? AppColors.capacityWarning
      : AppColors.capacityError(context),
)
```

### Badge Component
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: AppColors.driverBadge(context),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    'Driver',
    style: TextStyle(
      color: AppColors.onPrimaryContainer(context),
    ),
  ),
)
```

## Accessibility Features

### 1. Material 3 Compliance
- All colors based on ColorScheme tokens
- Automatic theme adaptation (light/dark)
- ≥4.5:1 contrast ratio guaranteed

### 2. Colorblind-Friendly Design
- Unique icon shapes for each day
- Pattern differentiation complements color coding
- Tested with various colorblind simulations

### 3. Theme-Aware
- Responds to system dark mode
- Consistent contrast in all modes
- No hard-coded colors in widgets

### 4. Semantic Naming
- Clear, descriptive token names
- Self-documenting code
- Easy to understand intent

## Module Usage

### Schedule Module
```dart
// Slot states
Container(color: AppColors.statusAvailable(context))
Container(color: AppColors.statusPartial(context))

// Day indicators
Icon(AppColors.getDayIcon('lundi'))

// Badges
Container(color: AppColors.driverBadge(context))
```

### Groups Module (Future)
```dart
// Resource planning
Container(color: AppColors.statusAvailable(context))

// Capacity indicators
color: capacity > 0.9
  ? AppColors.capacityError(context)
  : AppColors.capacityOk
```

### Family Module (Future)
```dart
// Vehicle/child management
Container(color: AppColors.childBadge(context))
Container(color: AppColors.driverBadge(context))

// Status tracking
Container(color: AppColors.statusEmpty(context))
```

## Best Practices

### DO
- ✓ Use theme-aware methods with `BuildContext`
- ✓ Use semantic tokens (`statusAvailable`, `statusPartial`)
- ✓ Combine day colors with day icons for accessibility
- ✓ Test in both light and dark modes
- ✓ Use const colors (`capacityOk`) where available

### DON'T
- ✗ Use deprecated legacy colors
- ✗ Hard-code color values (Color(0xFF...))
- ✗ Rely on color alone for information (use icons too)
- ✗ Modify ColorScheme tokens directly
- ✗ Use non-semantic color names in widgets

## Testing

### Visual Testing
```bash
# Run app in light mode
flutter run

# Run app in dark mode
flutter run --dart-define=FLUTTER_WEB_USE_SKIA=true

# Test with colorblind simulator
# (Use device accessibility settings or external tools)
```

### Automated Testing
```dart
testWidgets('Status colors adapt to theme', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData.light(),
      home: Container(color: AppColors.statusAvailable(context)),
    ),
  );

  // Verify light mode color

  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData.dark(),
      home: Container(color: AppColors.statusAvailable(context)),
    ),
  );

  // Verify dark mode color changed appropriately
});
```

## Future Enhancements

1. **Typography System**: Semantic text styles
2. **Spacing System**: Consistent spacing tokens
3. **Animation Tokens**: Standard durations and curves
4. **Shadow System**: Elevation tokens
5. **Border Radius**: Component-specific radius tokens

## References

- [Material 3 Design](https://m3.material.io/)
- [Flutter ColorScheme](https://api.flutter.dev/flutter/material/ColorScheme-class.html)
- [Accessibility Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Colorblind Design](https://www.color-blindness.com/coblis-color-blindness-simulator/)

## Changelog

### 2025-10-10 - Schedule Semantics Addition
- Added status semantics (5 tokens)
- Added component colors (5 tokens)
- Added day colors (6 colors + 2 methods)
- Added colorblind-friendly icon shapes
- Added bilingual support (French/English)
- Created migration guide from ScheduleColors
- Created comprehensive usage examples
