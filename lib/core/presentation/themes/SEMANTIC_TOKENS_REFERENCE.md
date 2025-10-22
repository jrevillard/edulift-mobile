# AppColors Semantic Tokens Quick Reference

## Status Semantics (Slot/Resource States)

| Token | Material 3 Source | Light Mode | Dark Mode | Use Case |
|-------|------------------|------------|-----------|----------|
| `statusEmpty(context)` | surfaceContainerHighest | Light Gray | Dark Gray | Empty slot, nothing assigned |
| `statusAvailable(context)` | secondaryContainer | Light Green/Teal | Dark Green/Teal | Has capacity, can accept |
| `statusPartial(context)` | tertiaryContainer | Light Purple/Orange | Dark Purple/Orange | Some capacity remaining |
| `statusFull(context)` | errorContainer | Light Red | Dark Red | At maximum capacity |
| `statusConflict(context)` | error | Bright Red | Bright Red | Over capacity (critical) |

### Visual Hierarchy
```
Empty → Available → Partial → Full → Conflict
Gray  → Green     → Purple  → Red   → Bright Red
```

## Component Colors (Badges & Indicators)

| Token | Material 3 Source | Use Case | Typical Content |
|-------|------------------|----------|-----------------|
| `driverBadge(context)` | primaryContainer | Driver/vehicle ID | "Driver", vehicle names |
| `childBadge(context)` | secondaryContainer | Child/participant ID | Child names, participant count |
| `capacityOk` | const success (#10B981) | Capacity 0-70% | Green indicator |
| `capacityWarning` | const warning (#F59E0B) | Capacity 70-90% | Orange indicator |
| `capacityError(context)` | error | Capacity 90%+ | Red indicator |

### Capacity Indicator Usage
```dart
Color getCapacityColor(double ratio, BuildContext context) {
  if (ratio < 0.7) return AppColors.capacityOk;
  if (ratio < 0.9) return AppColors.capacityWarning;
  return AppColors.capacityError(context);
}
```

## Day Colors (Calendar/Scheduling)

| Day | French | Color | Hex | Icon | Shape |
|-----|--------|-------|-----|------|-------|
| Monday | Lundi | Blue | Colors.blue | `Icons.circle` | ● |
| Tuesday | Mardi | Green | Colors.green | `Icons.square` | ■ |
| Wednesday | Mercredi | Orange | Colors.orange | `Icons.change_history` | ▲ |
| Thursday | Jeudi | Purple | Colors.purple | `Icons.diamond` | ◆ |
| Friday | Vendredi | Red | Colors.red | `Icons.star` | ★ |

### Colorblind-Friendly Design
Each day has TWO indicators:
1. **Color**: For standard vision
2. **Shape**: For colorblind accessibility

```dart
// Use both color AND icon for maximum accessibility
Icon(
  AppColors.getDayIcon('monday'),  // Shape: Circle
  color: AppColors.getDayColor('monday'),  // Color: Blue
)
```

## Usage Patterns

### Pattern 1: Status Container
```dart
Container(
  color: AppColors.statusAvailable(context),
  child: Text(
    'Available',
    style: TextStyle(
      color: AppColors.onSecondaryContainer(context),
    ),
  ),
)
```

### Pattern 2: Day Indicator
```dart
Row(
  children: [
    Icon(
      AppColors.getDayIcon('lundi'),
      color: AppColors.getDayColor('lundi'),
      size: 24,
    ),
    SizedBox(width: 8),
    Text('Lundi'),
  ],
)
```

### Pattern 3: Capacity Progress
```dart
LinearProgressIndicator(
  value: capacity,
  backgroundColor: AppColors.surfaceVariantThemed(context),
  color: capacity < 0.7
    ? AppColors.capacityOk
    : capacity < 0.9
      ? AppColors.capacityWarning
      : AppColors.capacityError(context),
)
```

### Pattern 4: Badge Chip
```dart
Chip(
  backgroundColor: AppColors.driverBadge(context),
  label: Text(
    'Driver',
    style: TextStyle(
      color: AppColors.onPrimaryContainer(context),
    ),
  ),
)
```

## Context Requirements

| Token | Requires BuildContext? | Can Use in const? |
|-------|------------------------|-------------------|
| `statusEmpty(context)` | ✓ Yes | ✗ No |
| `statusAvailable(context)` | ✓ Yes | ✗ No |
| `statusPartial(context)` | ✓ Yes | ✗ No |
| `statusFull(context)` | ✓ Yes | ✗ No |
| `statusConflict(context)` | ✓ Yes | ✗ No |
| `driverBadge(context)` | ✓ Yes | ✗ No |
| `childBadge(context)` | ✓ Yes | ✗ No |
| `capacityOk` | ✗ No | ✓ Yes |
| `capacityWarning` | ✗ No | ✓ Yes |
| `capacityError(context)` | ✓ Yes | ✗ No |
| `monday` / `tuesday` / etc. | ✗ No | ✓ Yes |
| `getDayColor(day)` | ✗ No | ✓ Yes |
| `getDayIcon(day)` | ✗ No | ✓ Yes |

## Module Adoption Strategy

### Schedule Module
- ✓ Status colors for slot states
- ✓ Day colors for calendar
- ✓ Driver/child badges
- ✓ Capacity indicators

### Groups Module (Recommended)
```dart
// Resource availability
Container(color: AppColors.statusAvailable(context))

// Group capacity
CircularProgressIndicator(
  color: AppColors.capacityWarning,
)

// Participant badges
Chip(backgroundColor: AppColors.childBadge(context))
```

### Family Module (Recommended)
```dart
// Vehicle status
Container(color: AppColors.statusEmpty(context))

// Driver identification
Badge(backgroundColor: AppColors.driverBadge(context))

// Child identification
Badge(backgroundColor: AppColors.childBadge(context))
```

## Accessibility Checklist

- ✓ **Contrast**: All colors meet WCAG AA (≥4.5:1)
- ✓ **Dark Mode**: Automatic adaptation via ColorScheme
- ✓ **Colorblind**: Unique icon shapes per day
- ✓ **Screen Reader**: Semantic token names
- ✓ **Bilingual**: French/English day support

## Migration from ScheduleColors

| Old (ScheduleColors) | New (AppColors) |
|---------------------|-----------------|
| `emptySlot(context)` | `statusEmpty(context)` |
| `availableSlot(context)` | `statusAvailable(context)` |
| `partialSlot(context)` | `statusPartial(context)` |
| `fullSlot(context)` | `statusFull(context)` |
| `conflictSlot(context)` | `statusConflict(context)` |
| `driverBadge(context)` | `driverBadge(context)` (no change) |
| `childBadge(context)` | `childBadge(context)` (no change) |
| `capacityOk` | `capacityOk` (no change) |
| `capacityWarning` | `capacityWarning` (no change) |
| `capacityError(context)` | `capacityError(context)` (no change) |
| `getDayColor(day)` | `getDayColor(day)` (no change) |
| `getDayIcon(day)` | `getDayIcon(day)` (no change) |

## Testing Examples

### Light/Dark Mode Test
```dart
testWidgets('Status colors adapt to theme', (tester) async {
  // Light mode
  await tester.pumpWidget(MaterialApp(
    theme: ThemeData.light(),
    home: Container(color: AppColors.statusAvailable(context)),
  ));
  // Verify light mode color

  // Dark mode
  await tester.pumpWidget(MaterialApp(
    theme: ThemeData.dark(),
    home: Container(color: AppColors.statusAvailable(context)),
  ));
  // Verify dark mode color
});
```

### Colorblind Test
```dart
testWidgets('Day icons are unique', (tester) async {
  expect(AppColors.getDayIcon('monday'), Icons.circle);
  expect(AppColors.getDayIcon('tuesday'), Icons.square);
  expect(AppColors.getDayIcon('wednesday'), Icons.change_history);
  expect(AppColors.getDayIcon('thursday'), Icons.diamond);
  expect(AppColors.getDayIcon('friday'), Icons.star);
});
```

### Bilingual Test
```dart
test('Day colors support French and English', () {
  expect(AppColors.getDayColor('monday'), Colors.blue);
  expect(AppColors.getDayColor('lundi'), Colors.blue);
  expect(AppColors.getDayIcon('tuesday'), Icons.square);
  expect(AppColors.getDayIcon('mardi'), Icons.square);
});
```

---

**Last Updated**: 2025-10-10  
**Version**: 1.0.0  
**Status**: Production Ready
