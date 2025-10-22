# Schedule Design System - Usage Examples

Practical code examples showing how to use the Schedule design system.

## Basic Widget Styling

### Slot Container

```dart
import '../design/schedule_design.dart';

Container(
  height: ScheduleDimensions.slotHeight,
  width: ScheduleDimensions.slotWidth,
  decoration: BoxDecoration(
    color: _getSlotColor(context, assigned, capacity),
    border: Border.all(color: ScheduleColors.border(context)),
    borderRadius: ScheduleDimensions.cardRadius,
  ),
  padding: EdgeInsets.all(ScheduleDimensions.spacingMd),
  child: ...,
)

Color _getSlotColor(BuildContext context, int assigned, int capacity) {
  if (capacity == 0) return ScheduleColors.slotEmpty(context);

  final percentage = assigned / capacity;
  if (percentage > 1.0) return ScheduleColors.slotConflict(context);
  if (percentage == 1.0) return ScheduleColors.slotFull(context);
  if (percentage > 0.5) return ScheduleColors.slotPartial;
  return ScheduleColors.slotAvailable;
}
```

### Day Header

```dart
Container(
  height: ScheduleDimensions.dayHeaderHeight,
  padding: EdgeInsets.symmetric(
    horizontal: ScheduleDimensions.spacingLg,
    vertical: ScheduleDimensions.spacingMd,
  ),
  decoration: BoxDecoration(
    color: ScheduleColors.getDayColor(day),
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(ScheduleDimensions.radiusLg),
    ),
  ),
  child: Row(
    children: [
      Icon(Icons.calendar_today, size: ScheduleDimensions.iconSize),
      SizedBox(width: ScheduleDimensions.spacingSm),
      Text(
        day,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
)
```

## Touch Target Compliance

### Icon Button (AA Compliant)

```dart
// ❌ WRONG: Non-compliant 24dp touch area
GestureDetector(
  onTap: onEdit,
  child: Icon(Icons.edit, size: 24),
)

// ✅ CORRECT: Compliant 48dp touch area
IconButton(
  constraints: ScheduleDimensions.minimumTouchConstraints,
  icon: Icon(Icons.edit, size: ScheduleDimensions.iconSize),
  onPressed: onEdit,
  tooltip: 'Edit schedule',
)
```

### Custom Touch Target Wrapper

```dart
class TouchTargetWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const TouchTargetWrapper({
    required this.child,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: ScheduleDimensions.minimumTouchConstraints,
      child: InkWell(
        onTap: onTap,
        borderRadius: ScheduleDimensions.buttonRadius,
        child: Center(child: child),
      ),
    );
  }
}

// Usage
TouchTargetWrapper(
  onTap: onDelete,
  child: Icon(Icons.delete, size: ScheduleDimensions.iconSize),
)
```

## Capacity Indicators

### Animated Progress Bar

```dart
class CapacityProgressBar extends StatelessWidget {
  final int assigned;
  final int capacity;

  const CapacityProgressBar({
    required this.assigned,
    required this.capacity,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = capacity > 0 ? assigned / capacity : 0.0;
    final color = _getCapacityColor(percentage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Capacity',
              style: TextStyle(
                color: ScheduleColors.textSecondary(context),
              ),
            ),
            Text(
              '$assigned / $capacity',
              style: TextStyle(
                color: ScheduleColors.textPrimary(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: ScheduleDimensions.spacingSm),
        ClipRRect(
          borderRadius: ScheduleDimensions.pillRadius,
          child: LinearProgressIndicator(
            value: percentage.clamp(0.0, 1.0),
            backgroundColor: ScheduleColors.slotEmpty(context),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: ScheduleDimensions.capacityBarHeight,
          ),
        ),
      ],
    );
  }

  Color _getCapacityColor(double percentage) {
    if (percentage > 1.0) return ScheduleColors.capacityError;
    if (percentage > 0.8) return ScheduleColors.capacityWarning;
    return ScheduleColors.capacityOk;
  }
}
```

### Capacity Badge

```dart
class CapacityBadge extends StatelessWidget {
  final int assigned;
  final int capacity;

  const CapacityBadge({
    required this.assigned,
    required this.capacity,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = capacity > 0 ? assigned / capacity : 0.0;
    final color = percentage > 1.0
        ? ScheduleColors.capacityError
        : percentage > 0.8
            ? ScheduleColors.capacityWarning
            : ScheduleColors.capacityOk;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScheduleDimensions.spacingMd,
        vertical: ScheduleDimensions.spacingSm,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: ScheduleDimensions.pillRadius,
      ),
      child: Text(
        '$assigned/$capacity',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
```

## Animations with Accessibility

### Animated Slot Selection

```dart
class AnimatedSlot extends StatefulWidget {
  final bool isSelected;
  final Widget child;

  const AnimatedSlot({
    required this.isSelected,
    required this.child,
    super.key,
  });

  @override
  State<AnimatedSlot> createState() => _AnimatedSlotState();
}

class _AnimatedSlotState extends State<AnimatedSlot> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: ScheduleAnimations.getDuration(
        context,
        ScheduleAnimations.cardSelectionDuration,
      ),
      curve: ScheduleAnimations.getCurve(
        context,
        ScheduleAnimations.cardSelectionCurve,
      ),
      decoration: BoxDecoration(
        color: widget.isSelected
            ? ScheduleColors.primary
            : ScheduleColors.slotEmpty(context),
        border: Border.all(
          color: widget.isSelected
              ? ScheduleColors.primary
              : ScheduleColors.border(context),
          width: widget.isSelected ? 2.0 : 1.0,
        ),
        borderRadius: ScheduleDimensions.cardRadius,
      ),
      child: widget.child,
    );
  }
}
```

### Slide-in Bottom Sheet

```dart
void showScheduleBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: ScheduleDimensions.bottomSheetInitialSize,
      maxChildSize: ScheduleDimensions.bottomSheetMaxSize,
      minChildSize: 0.3,
      builder: (context, scrollController) => AnimatedContainer(
        duration: ScheduleAnimations.getDuration(
          context,
          ScheduleAnimations.bottomSheetDuration,
        ),
        curve: ScheduleAnimations.getCurve(
          context,
          ScheduleAnimations.bottomSheetCurve,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(ScheduleDimensions.radiusLg),
          ),
        ),
        child: Column(
          children: [
            _buildDragHandle(context),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.all(ScheduleDimensions.spacingLg),
                children: [
                  // Sheet content
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildDragHandle(BuildContext context) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: ScheduleDimensions.spacingMd),
    width: ScheduleDimensions.dragHandleWidth,
    height: ScheduleDimensions.dragHandleHeight,
    decoration: BoxDecoration(
      color: ScheduleColors.dragHandle(context),
      borderRadius: ScheduleDimensions.pillRadius,
    ),
  );
}
```

## Vehicle and Child Badges

### Driver Badge

```dart
class DriverBadge extends StatelessWidget {
  final String driverName;
  final String vehicleModel;

  const DriverBadge({
    required this.driverName,
    required this.vehicleModel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScheduleDimensions.spacingMd,
        vertical: ScheduleDimensions.spacingSm,
      ),
      decoration: BoxDecoration(
        color: ScheduleColors.driverBadge(context),
        borderRadius: ScheduleDimensions.buttonRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.drive_eta,
            size: ScheduleDimensions.iconSizeSmall,
            color: ScheduleColors.textPrimary(context),
          ),
          SizedBox(width: ScheduleDimensions.spacingXs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                driverName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: ScheduleColors.textPrimary(context),
                ),
              ),
              Text(
                vehicleModel,
                style: TextStyle(
                  fontSize: 10,
                  color: ScheduleColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### Child Assignment List

```dart
class ChildAssignmentList extends StatelessWidget {
  final List<Child> children;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;

  const ChildAssignmentList({
    required this.children,
    required this.selectedIds,
    required this.onToggle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: children.length,
      itemBuilder: (context, index) {
        final child = children[index];
        final isSelected = selectedIds.contains(child.id);

        return Container(
          height: ScheduleDimensions.childRowHeight,
          margin: EdgeInsets.only(bottom: ScheduleDimensions.spacingSm),
          decoration: BoxDecoration(
            color: isSelected
                ? ScheduleColors.childBadge(context)
                : Colors.transparent,
            borderRadius: ScheduleDimensions.cardRadius,
          ),
          child: CheckboxListTile(
            value: isSelected,
            onChanged: (_) => onToggle(child.id),
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              child.name,
              style: TextStyle(
                color: ScheduleColors.textPrimary(context),
              ),
            ),
            subtitle: Text(
              'Grade ${child.grade}',
              style: TextStyle(
                color: ScheduleColors.textSecondary(context),
              ),
            ),
          ),
        );
      },
    );
  }
}
```

## Complex Components

### Vehicle Selection Card

```dart
class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final bool isSelected;
  final VoidCallback onTap;

  const VehicleCard({
    required this.vehicle,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: ScheduleAnimations.getDuration(
        context,
        ScheduleAnimations.cardSelectionDuration,
      ),
      curve: ScheduleAnimations.getCurve(
        context,
        ScheduleAnimations.cardSelectionCurve,
      ),
      height: ScheduleDimensions.vehicleCardHeight,
      margin: EdgeInsets.only(bottom: ScheduleDimensions.spacingMd),
      child: Material(
        elevation: isSelected
            ? ScheduleDimensions.elevationCardHovered
            : ScheduleDimensions.elevationCard,
        borderRadius: ScheduleDimensions.cardRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: ScheduleDimensions.cardRadius,
          child: Container(
            padding: EdgeInsets.all(ScheduleDimensions.spacingMd),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? ScheduleColors.primary
                    : ScheduleColors.border(context),
                width: isSelected ? 2.0 : 1.0,
              ),
              borderRadius: ScheduleDimensions.cardRadius,
            ),
            child: Row(
              children: [
                _buildVehicleIcon(context),
                SizedBox(width: ScheduleDimensions.spacingMd),
                Expanded(child: _buildVehicleInfo(context)),
                _buildCapacityBadge(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleIcon(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: ScheduleColors.driverBadge(context),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.directions_car,
        size: ScheduleDimensions.iconSize,
      ),
    );
  }

  Widget _buildVehicleInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          vehicle.model,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: ScheduleColors.textPrimary(context),
          ),
        ),
        SizedBox(height: ScheduleDimensions.spacingXs),
        Text(
          vehicle.licensePlate,
          style: TextStyle(
            color: ScheduleColors.textSecondary(context),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCapacityBadge(BuildContext context) {
    return CapacityBadge(
      assigned: vehicle.assignedSeats,
      capacity: vehicle.totalSeats,
    );
  }
}
```

## Form Fields with Design Tokens

### Time Picker

```dart
class TimeSlotPicker extends StatelessWidget {
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onChanged;

  const TimeSlotPicker({
    required this.time,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _selectTime(context),
      borderRadius: ScheduleDimensions.buttonRadius,
      child: Container(
        height: ScheduleDimensions.timeHeaderHeight,
        padding: EdgeInsets.symmetric(
          horizontal: ScheduleDimensions.spacingLg,
          vertical: ScheduleDimensions.spacingMd,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: ScheduleColors.border(context)),
          borderRadius: ScheduleDimensions.buttonRadius,
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              size: ScheduleDimensions.iconSize,
              color: ScheduleColors.textSecondary(context),
            ),
            SizedBox(width: ScheduleDimensions.spacingMd),
            Text(
              time.format(context),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: ScheduleColors.textPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: time,
    );
    if (picked != null) {
      onChanged(picked);
    }
  }
}
```

## Accessibility Best Practices

### Semantic Labels

```dart
Semantics(
  label: 'Schedule slot for Monday morning',
  hint: 'Double tap to assign vehicle and children',
  child: GestureDetector(
    onTap: onTap,
    child: Container(
      // Use design tokens
    ),
  ),
)
```

### Focus Management

```dart
class AccessibleSlot extends StatelessWidget {
  final FocusNode focusNode;
  final VoidCallback onTap;

  const AccessibleSlot({
    required this.focusNode,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      child: Builder(
        builder: (context) {
          final isFocused = Focus.of(context).hasFocus;

          return AnimatedContainer(
            duration: ScheduleAnimations.fast,
            decoration: BoxDecoration(
              border: Border.all(
                color: isFocused
                    ? ScheduleColors.primary
                    : ScheduleColors.border(context),
                width: isFocused ? 2.0 : 1.0,
              ),
              borderRadius: ScheduleDimensions.cardRadius,
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: ScheduleDimensions.cardRadius,
              child: // content,
            ),
          );
        },
      ),
    );
  }
}
```

---

**Pro Tips:**

1. Always use `context`-aware colors for theme support
2. Wrap all interactive elements with `minimumTouchConstraints`
3. Use accessibility helpers (`getDuration`, `getCurve`) for animations
4. Prefer semantic tokens over hardcoded values
5. Test with both light and dark themes
6. Test with reduced motion enabled

