# Migration Guide: ScheduleColors → AppColors

## Overview

The semantic color tokens from `ScheduleColors` have been promoted to `AppColors` for global reusability across Groups, Family, and Schedule modules.

## Migration Steps

### 1. Import Changes

**Before:**
```dart
import 'package:mobile_app/features/schedule/presentation/design/schedule_colors.dart';
```

**After:**
```dart
import 'package:mobile_app/core/presentation/themes/app_colors.dart';
```

### 2. Status Colors

**Before:**
```dart
// In schedule_colors.dart
color: ScheduleColors.emptySlot(context),
color: ScheduleColors.availableSlot(context),
color: ScheduleColors.partialSlot(context),
color: ScheduleColors.fullSlot(context),
color: ScheduleColors.conflictSlot(context),
```

**After:**
```dart
// In app_colors.dart
color: AppColors.statusEmpty(context),
color: AppColors.statusAvailable(context),
color: AppColors.statusPartial(context),
color: AppColors.statusFull(context),
color: AppColors.statusConflict(context),
```

### 3. Badge Colors

**Before:**
```dart
// In schedule_colors.dart
color: ScheduleColors.driverBadge(context),
color: ScheduleColors.childBadge(context),
```

**After:**
```dart
// In app_colors.dart
color: AppColors.driverBadge(context),
color: AppColors.childBadge(context),
```

### 4. Capacity Indicators

**Before:**
```dart
// In schedule_colors.dart
color: ScheduleColors.capacityOk,
color: ScheduleColors.capacityWarning,
color: ScheduleColors.capacityError(context),
```

**After:**
```dart
// In app_colors.dart
color: AppColors.capacityOk,
color: AppColors.capacityWarning,
color: AppColors.capacityError(context),
```

### 5. Day Colors and Icons

**Before:**
```dart
// In schedule_colors.dart
color: ScheduleColors.getDayColor('monday'),
icon: ScheduleColors.getDayIcon('lundi'),
```

**After:**
```dart
// In app_colors.dart
color: AppColors.getDayColor('monday'),
icon: AppColors.getDayIcon('lundi'),
```

## Example: Full Widget Migration

**Before:**
```dart
import 'package:mobile_app/features/schedule/presentation/design/schedule_colors.dart';

class ScheduleSlotWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: ScheduleColors.availableSlot(context),
      child: Row(
        children: [
          Icon(
            ScheduleColors.getDayIcon('monday'),
            color: ScheduleColors.getDayColor('monday'),
          ),
          Container(
            color: ScheduleColors.driverBadge(context),
            child: Text('Driver'),
          ),
        ],
      ),
    );
  }
}
```

**After:**
```dart
import 'package:mobile_app/core/presentation/themes/app_colors.dart';

class ScheduleSlotWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.statusAvailable(context),
      child: Row(
        children: [
          Icon(
            AppColors.getDayIcon('monday'),
            color: AppColors.getDayColor('monday'),
          ),
          Container(
            color: AppColors.driverBadge(context),
            child: Text('Driver'),
          ),
        ],
      ),
    );
  }
}
```

## Semantic Mapping Reference

| ScheduleColors Method | AppColors Method | Notes |
|----------------------|------------------|-------|
| `emptySlot(context)` | `statusEmpty(context)` | Renamed for broader use |
| `availableSlot(context)` | `statusAvailable(context)` | Renamed for broader use |
| `partialSlot(context)` | `statusPartial(context)` | Renamed for broader use |
| `fullSlot(context)` | `statusFull(context)` | Renamed for broader use |
| `conflictSlot(context)` | `statusConflict(context)` | Renamed for broader use |
| `driverBadge(context)` | `driverBadge(context)` | No change |
| `childBadge(context)` | `childBadge(context)` | No change |
| `capacityOk` | `capacityOk` | No change |
| `capacityWarning` | `capacityWarning` | No change |
| `capacityError(context)` | `capacityError(context)` | No change |
| `getDayColor(day)` | `getDayColor(day)` | No change |
| `getDayIcon(day)` | `getDayIcon(day)` | No change |

## Benefits of Migration

1. **Global Reusability**: Use semantic tokens across all modules (Schedule, Groups, Family)
2. **Single Source of Truth**: Centralized color definitions in `app_colors.dart`
3. **Consistency**: Uniform color semantics across the application
4. **Better Naming**: `status*` prefix clearly indicates slot/resource state semantics
5. **Material 3 Compliance**: All colors based on Material 3 ColorScheme tokens

## Timeline

- **Phase 1** (Current): AppColors enriched with schedule semantics
- **Phase 2** (Next): Migrate Schedule module widgets to use AppColors
- **Phase 3** (Future): Deprecate and remove ScheduleColors
- **Phase 4** (Future): Adopt AppColors in Groups and Family modules

## Testing Strategy

1. Update imports one widget at a time
2. Run visual regression tests after each migration
3. Verify dark mode behavior
4. Test colorblind accessibility with different icon shapes
5. Validate bilingual day support (French/English)

## Questions?

Refer to:
- `/workspace/mobile_app/lib/core/presentation/themes/app_colors.dart` - Full implementation
- `/workspace/mobile_app/lib/core/presentation/themes/app_colors_usage_example.dart` - Usage examples
