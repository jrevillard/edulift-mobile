# Schedule Design System Migration Guide

## Overview

This design system provides semantic tokens for the Schedule feature, built on top of the global design system (`AppColors`, `AppSpacing`, `AppTextStyles`).

## Why Schedule-specific?

Currently, only 2.5% of the codebase uses the global design system. This Schedule layer serves as a **prototype** for a future global refactor. Once Groups and Family features adopt design tokens, Schedule semantics will be promoted to the global level.

## Migration Examples

### Before (Hardcoded)
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.grey[50]!,  // ❌ Hardcoded, breaks dark mode
    border: Border.all(color: Colors.grey[300]!),
    borderRadius: BorderRadius.circular(12),
  ),
  padding: const EdgeInsets.all(8),  // ❌ Magic number
  child: ...
)
```

### After (Design Tokens)
```dart
import '../design/schedule_design.dart';

Container(
  decoration: BoxDecoration(
    color: ScheduleColors.slotEmpty(context),  // ✅ Theme-aware
    border: Border.all(color: ScheduleColors.border(context)),
    borderRadius: ScheduleDimensions.cardRadius,
  ),
  padding: EdgeInsets.all(ScheduleDimensions.spacingMd),
  constraints: ScheduleDimensions.minimumTouchConstraints,  // ✅ Accessibility
  child: ...
)
```

## Touch Target Compliance

**Material Design AA requires 48dp minimum touch targets.**

### Before (Non-compliant)
```dart
GestureDetector(
  onTap: () {},
  child: Icon(Icons.add, size: 24),  // ❌ 24dp touch area
)
```

### After (Compliant)
```dart
IconButton(
  constraints: ScheduleDimensions.minimumTouchConstraints,
  onPressed: () {},
  icon: Icon(Icons.add, size: ScheduleDimensions.iconSize),  // ✅ 48dp touch area
)
```

## Capacity Colors

```dart
// Before
final color = percentage > 1.0
  ? Colors.red
  : percentage > 0.8
    ? Colors.orange
    : Colors.green;

// After
final color = percentage > 1.0
  ? ScheduleColors.capacityError
  : percentage > 0.8
    ? ScheduleColors.capacityWarning
    : ScheduleColors.capacityOk;
```

## Animations

```dart
AnimatedContainer(
  duration: ScheduleAnimations.getDuration(context, ScheduleAnimations.normal),
  curve: ScheduleAnimations.getCurve(context, ScheduleAnimations.emphasized),
  // ...
)
```

## Roadmap

1. **Week 1**: Migrate Schedule widgets ✅
2. **Week 2**: Enrich `AppColors` with Schedule semantics
3. **Weeks 3-6**: Migrate Groups + Family to design tokens
4. **Week 7**: Promote Schedule tokens to global, remove this layer

## Files to Migrate

Priority order:
1. `schedule_slot_widget.dart` (44 color instances)
2. `child_assignment_sheet.dart` (15 color instances)
3. `vehicle_selection_modal.dart` (12 color instances)
4. `schedule_grid.dart` (8 color instances)
5. `time_picker.dart` (8 color instances)

## Common Patterns

### Slot Status Colors

```dart
// Determine slot color based on capacity
Color getSlotColor(BuildContext context, int assigned, int capacity) {
  if (capacity == 0) return ScheduleColors.slotEmpty(context);

  final percentage = assigned / capacity;
  if (percentage > 1.0) return ScheduleColors.slotConflict(context);
  if (percentage == 1.0) return ScheduleColors.slotFull(context);
  if (percentage > 0.5) return ScheduleColors.slotPartial;
  return ScheduleColors.slotAvailable;
}
```

### Touch Target Spacing

```dart
// Always wrap interactive elements with minimum touch constraints
Padding(
  padding: EdgeInsets.all(ScheduleDimensions.spacingMd),
  child: IconButton(
    constraints: ScheduleDimensions.minimumTouchConstraints,
    icon: Icon(Icons.edit, size: ScheduleDimensions.iconSize),
    onPressed: onEdit,
  ),
)
```

### Animated Components

```dart
// Use accessibility-aware animations
AnimatedOpacity(
  opacity: isVisible ? 1.0 : 0.0,
  duration: ScheduleAnimations.getDuration(context, ScheduleAnimations.fast),
  curve: ScheduleAnimations.getCurve(context, ScheduleAnimations.entry),
  child: widget,
)
```

### Border Radius Consistency

```dart
// Use semantic radius tokens
Card(
  shape: RoundedRectangleBorder(
    borderRadius: ScheduleDimensions.cardRadius,
  ),
  child: ...
)

// Modal sheets
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(ScheduleDimensions.radiusLg),
    ),
  ),
  child: ...
)
```

## Color Accessibility

All colors follow WCAG AA contrast guidelines:

- Text on surface: 4.5:1 minimum
- Large text on surface: 3:1 minimum
- Interactive elements: clear visual distinction

Example usage:
```dart
Text(
  'Schedule Details',
  style: TextStyle(
    color: ScheduleColors.textPrimary(context),  // AA compliant
  ),
)

Text(
  'Optional info',
  style: TextStyle(
    color: ScheduleColors.textSecondary(context),  // AA compliant for large text
  ),
)
```

## Migration Checklist

For each widget file:

- [ ] Replace hardcoded colors with `ScheduleColors.*`
- [ ] Replace magic numbers with `ScheduleDimensions.*`
- [ ] Add touch target constraints to interactive elements
- [ ] Use `ScheduleAnimations.*` for animations
- [ ] Test in light and dark mode
- [ ] Test with reduced motion enabled
- [ ] Verify AA touch target compliance (48dp minimum)
- [ ] Remove unused imports (`material.dart` colors)

## Testing

```bash
# Run tests
flutter test lib/features/schedule/

# Check accessibility
flutter analyze --no-pub

# Visual testing
flutter run --dart-define=SHOW_DEBUG_PAINT=true
```

## Future Enhancements

Once global adoption reaches 50%+:

1. Promote `slotAvailable`, `slotPartial`, `slotFull` to `AppColors` as generic status colors
2. Add semantic tokens to `app_spacing.dart` for common patterns
3. Create global animation configuration in `app_theme.dart`
4. Remove Schedule-specific layer, use global tokens directly
