# Week Navigation Flow - Visual Diagram

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    schedule_grid.dart                           │
│                                                                   │
│  State:                                                          │
│  • _currentDisplayedWeek: String  (e.g., "2025-W15")           │
│  • _weekPageController: PageController (center = 1000)         │
│                                                                   │
│  Props:                                                          │
│  • widget.week: String  (initial week from parent)             │
│  • widget.onWeekChanged: Function(int offset)                  │
└─────────────────────────────────────────────────────────────────┘
```

## Navigation Flow

### 1. Next/Previous Buttons

```
User clicks "Next Week" button
         ↓
PageController.nextPage()
         ↓
Page changes: 1000 → 1001
         ↓
onPageChanged(1001)
         ↓
┌────────────────────────────────────────┐
│ Calculate new week:                    │
│ pageOffset = 1001 - 1000 = 1          │
│ newWeek = addWeeksToISOWeek(          │
│   widget.week,  // "2025-W10"         │
│   1             // offset             │
│ )                                      │
│ → "2025-W11" ✓                        │
└────────────────────────────────────────┘
         ↓
setState(() => _currentDisplayedWeek = "2025-W11")
         ↓
widget.onWeekChanged(1)  // Tell parent to load data
```

### 2. Date Picker Navigation

```
User clicks week indicator
         ↓
_showDatePicker() opens
         ↓
initialDate = parseMondayFromISOWeek(_currentDisplayedWeek)
         ↓
User selects a date (e.g., April 28, 2025)
         ↓
Calculate selected week
         ↓
┌────────────────────────────────────────┐
│ selectedMonday = _getMondayOfWeek(    │
│   DateTime(2025, 4, 28)               │
│ )                                      │
│ → DateTime(2025, 4, 28)               │
│                                        │
│ selectedWeek = getISOWeekString(      │
│   selectedMonday                       │
│ )                                      │
│ → "2025-W17"                          │
└────────────────────────────────────────┘
         ↓
┌────────────────────────────────────────┐
│ Calculate page to jump to:             │
│ offset = weeksBetween(                │
│   widget.week,      // "2025-W10"     │
│   selectedWeek      // "2025-W17"     │
│ )                                      │
│ → 7                                    │
│                                        │
│ targetPage = 1000 + 7 = 1007          │
└────────────────────────────────────────┘
         ↓
_weekPageController.jumpToPage(1007)
         ↓
onPageChanged(1007) is called
         ↓
(Same flow as Next/Previous)
```

## Key Relationships

### Page Number ↔ Week String

```
Initial Setup:
┌──────────┬─────────────┬──────────────┐
│ Page     │ Offset      │ Week         │
├──────────┼─────────────┼──────────────┤
│ 998      │ -2          │ 2025-W08     │
│ 999      │ -1          │ 2025-W09     │
│ 1000     │  0          │ 2025-W10 ← initial (widget.week)
│ 1001     │ +1          │ 2025-W11     │
│ 1002     │ +2          │ 2025-W12     │
│ ...      │ ...         │ ...          │
│ 1007     │ +7          │ 2025-W17     │
└──────────┴─────────────┴──────────────┘

Formula:
  week = addWeeksToISOWeek(widget.week, page - 1000)
```

### Display Updates

```
_currentDisplayedWeek     Week Indicator        Week Data
       ↓                        ↓                    ↓
  "2025-W15"     →    "6 - 12 janv. 2025"  →  scheduleData
                           (formatted)         (from parent)
```

## State Synchronization

### Parent-Child Communication

```
┌─────────────────────────────────────────────────────────────┐
│                     schedule_page.dart                      │
│                         (Parent)                            │
│                                                             │
│  • Stores initial week: "2025-W10"                         │
│  • Loads schedule data based on week offset                │
│  • Passes data to schedule_grid                            │
└─────────────────────────────────────────────────────────────┘
                            ↕
           ┌────────────────┴────────────────┐
           ↓                                 ↓
    widget.week              widget.onWeekChanged(offset)
    (initial ref)            (callback to parent)
           ↓                                 ↓
┌─────────────────────────────────────────────────────────────┐
│                    schedule_grid.dart                       │
│                        (Child)                              │
│                                                             │
│  • Displays current week using _currentDisplayedWeek       │
│  • Calculates offsets from widget.week                     │
│  • Notifies parent when week changes                       │
└─────────────────────────────────────────────────────────────┘
```

## Before vs After Comparison

### BEFORE (Buggy)

```
State Confusion:
┌─────────────────────────────────────┐
│ _currentWeekOffset = 3              │  ← What does this mean?
│ widget.week = "2025-W10"            │  ← Initial week
│                                      │
│ What week is displayed?             │
│ → Unclear! Is it W13? Maybe?       │
└─────────────────────────────────────┘

Date Picker Calculation:
┌─────────────────────────────────────┐
│ currentDate = DateTime.now()        │  ← BUG! Time changes!
│   .add(Duration(days: offset * 7)) │
│                                      │
│ weeksDiff = selected - current      │
│ target = _currentWeekOffset + diff  │  ← BUG! Compound error!
└─────────────────────────────────────┘
```

### AFTER (Fixed)

```
Clear State:
┌─────────────────────────────────────┐
│ _currentDisplayedWeek = "2025-W13"  │  ← Exactly what it says!
│ widget.week = "2025-W10"            │  ← Initial reference
│                                      │
│ What week is displayed?             │
│ → Crystal clear: W13!               │
└─────────────────────────────────────┘

Date Picker Calculation:
┌─────────────────────────────────────┐
│ currentDate =                       │
│   parseMondayFromISOWeek(           │
│     _currentDisplayedWeek           │  ← Use displayed week
│   )                                 │
│                                      │
│ targetOffset =                      │
│   weeksBetween(                     │
│     widget.week,                    │  ← Always from initial
│     selectedWeek                    │
│   )                                 │
│                                      │
│ jumpToPage(1000 + targetOffset)    │  ← Simple!
└─────────────────────────────────────┘
```

## Error Prevention

### Old Approach: Compound Errors

```
Error Accumulation:
User at W12 (offset = 2)
         ↓
Opens date picker at different time
         ↓
DateTime.now() has changed
         ↓
calculates: offset 2 + diff 5 = 7
         ↓
Expected: W17, Got: W18 ❌
```

### New Approach: Single Source of Truth

```
No Error Accumulation:
User at any week
         ↓
Opens date picker
         ↓
Shows: _currentDisplayedWeek (always correct)
         ↓
Selects: target week
         ↓
Calculates: weeksBetween(initial, target)
         ↓
Result: Always correct ✓
```

## Testing Strategy

```
Test Coverage:
├── Basic Navigation
│   ├── Forward (next button × N)
│   ├── Backward (previous button × N)
│   └── Mixed patterns
│
├── Edge Cases
│   ├── Year boundaries (W52 → W01)
│   ├── Week 53 handling
│   └── DST transitions
│
└── Date Picker
    ├── From displayed week
    ├── Far from initial
    └── Backward jumps
```

## Conclusion

**Key Principle:** Keep it simple!
- ✅ Direct week string tracking
- ✅ Single source of truth (widget.week)
- ✅ No compound calculations
- ✅ Predictable behavior

**Result:** Boring, reliable navigation that just works.
