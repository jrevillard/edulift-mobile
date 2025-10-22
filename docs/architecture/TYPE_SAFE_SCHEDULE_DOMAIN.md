# Type-Safe Schedule Domain Architecture

**Status**: Implementation In Progress (Phase 1 Complete)
**Date**: 2025-10-11
**Author**: System Architecture Designer

---

## Executive Summary

This document describes the redesign of EduLift's schedule domain from string-based to type-safe architecture. The goal is to eliminate runtime validation bugs by leveraging Dart's type system for compile-time guarantees.

### Problem Statement

The original schedule system used raw strings everywhere, causing multiple categories of bugs:

1. **Format Mismatches**: "TUESDAY" vs "Tuesday" vs "Lundi"
2. **Invalid Time Formats**: "Matin" sent where "07:30" expected
3. **Runtime Validation Failures**: No compile-time guarantees
4. **Scattered Validation Logic**: String checks duplicated across layers

### Solution Overview

Replace strings with **type-safe domain entities**:

- **`DayOfWeek` enum** → Replaces day strings
- **`TimeOfDayValue` value object** → Replaces time strings
- **`SchedulePeriod` sealed class** → Represents aggregate periods OR specific times

---

## Type-Safe Domain Model

### 1. DayOfWeek Enum

**Location**: `/lib/core/domain/entities/schedule/day_of_week.dart`

```dart
enum DayOfWeek {
  monday(1, 'Monday', 'Mon'),
  tuesday(2, 'Tuesday', 'Tue'),
  // ... etc

  const DayOfWeek(this.weekday, this.fullName, this.shortName);

  final int weekday;
  final String fullName;
  final String shortName;

  // Conversion methods
  static DayOfWeek fromString(String name);
  static DayOfWeek fromWeekday(int weekday);
  static DayOfWeek fromDateTime(DateTime dateTime);
}
```

**Benefits**:
- ✅ Compile-time validation
- ✅ No more "Invalid day: TUESDAY" errors
- ✅ Single source of truth for day names
- ✅ IDE autocomplete support

### 2. TimeOfDayValue Value Object

**Location**: `/lib/core/domain/entities/schedule/time_of_day.dart`

```dart
class TimeOfDayValue extends Equatable {
  final int hour;    // 0-23
  final int minute;  // 0-59

  const TimeOfDayValue(this.hour, this.minute)
      : assert(hour >= 0 && hour <= 23),
        assert(minute >= 0 && minute <= 59);

  // Factory constructors
  factory TimeOfDayValue.parse(String time);
  factory TimeOfDayValue.fromDateTime(DateTime dt);
  factory TimeOfDayValue.fromTimeOfDay(TimeOfDay tod);

  // Conversions
  String toApiFormat();           // "07:30"
  TimeOfDay toTimeOfDay();        // Flutter widget
  DateTime toDateTime(DateTime date);

  // Operations
  int compareTo(TimeOfDayValue other);
  bool isBefore(TimeOfDayValue other);
  bool isAfter(TimeOfDayValue other);
  Duration difference(TimeOfDayValue other);
  TimeOfDayValue add(Duration duration);
}
```

**Benefits**:
- ✅ Validated at construction time
- ✅ No more "Invalid time format: Matin" errors
- ✅ Rich comparison and arithmetic operations
- ✅ Type-safe conversions to/from Flutter/API formats

### 3. SchedulePeriod Sealed Class

**Location**: `/lib/core/domain/entities/schedule/schedule_period.dart`

```dart
sealed class SchedulePeriod extends Equatable {
  const SchedulePeriod();

  List<TimeOfDayValue> get allTimeSlots;
  String get displayString;
}

// Aggregate period (Morning/Afternoon)
class AggregatePeriod extends SchedulePeriod {
  final PeriodType type;             // morning, afternoon, evening
  final List<TimeOfDayValue> timeSlots;

  const AggregatePeriod({required this.type, required this.timeSlots});
}

// Specific time slot
class SpecificTimeSlot extends SchedulePeriod {
  final TimeOfDayValue timeSlot;

  const SpecificTimeSlot(this.timeSlot);
}
```

**Benefits**:
- ✅ Pattern matching support
- ✅ Exhaustive case handling
- ✅ Clear distinction between aggregate vs specific periods
- ✅ No string comparisons needed

---

## Updated Domain Entities

### PeriodSlotData (UPDATED)

**Before**:
```dart
class PeriodSlotData {
  final String day;              // ❌ Could be ANY string
  final String period;           // ❌ Could be ANY string
  final List<String> times;      // ❌ Validation required
  final List<ScheduleSlot> slots;
  final String week;
}
```

**After**:
```dart
class PeriodSlotData {
  final DayOfWeek dayOfWeek;           // ✅ Type-safe enum
  final SchedulePeriod period;         // ✅ Sealed class
  final List<TimeOfDayValue> times;    // ✅ Validated objects
  final List<ScheduleSlot> slots;
  final String week;

  // Legacy constructor for backward compatibility
  @Deprecated('Use typed constructor')
  factory PeriodSlotData.fromStrings({...});
}
```

### ScheduleSlot (UPDATED)

**Before**:
```dart
class ScheduleSlot {
  final String day;   // ❌ Could be ANY string
  final String time;  // ❌ Could be ANY string
  // ...
}
```

**After**:
```dart
class ScheduleSlot {
  final DayOfWeek dayOfWeek;      // ✅ Type-safe enum
  final TimeOfDayValue timeOfDay;  // ✅ Validated object
  // ...

  // Legacy getters for backward compatibility
  @Deprecated('Use dayOfWeek instead')
  String get day => dayOfWeek.fullName;

  @Deprecated('Use timeOfDay instead')
  String get time => timeOfDay.toApiFormat();
}
```

---

## API Boundary Pattern

**Core Principle**: Convert types → strings **ONLY** at the API boundary.

### Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                        │
│  Uses: DayOfWeek enum, TimeOfDayValue, SchedulePeriod          │
│  ✅ Type-safe, no validation needed                             │
└─────────────────────────────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────┐
│                         DOMAIN LAYER                             │
│  Uses: DayOfWeek enum, TimeOfDayValue, SchedulePeriod          │
│  ✅ Pure domain logic, compile-time guarantees                  │
└─────────────────────────────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────┐
│                      DATA LAYER (DTOs)                           │
│  Converts: Types ↔ Strings at API boundary                      │
│  ✅ Single conversion point, no validation scatter              │
└─────────────────────────────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────┐
│                         API / BACKEND                            │
│  Uses: Strings (JSON)                                            │
│  Backend validates its own format                                │
└─────────────────────────────────────────────────────────────────┘
```

### DTO Conversion Example

```dart
// ScheduleSlotDto.toDomain() - API strings → Domain types
@override
ScheduleSlot toDomain() {
  return ScheduleSlot(
    dayOfWeek: DayOfWeek.fromWeekday(datetime.weekday),  // ✅ Parse once
    timeOfDay: TimeOfDayValue.fromDateTime(datetime),     // ✅ Validate once
    // ...
  );
}

// ScheduleSlotDto.fromDomain() - Domain types → API strings
factory ScheduleSlotDto.fromDomain(ScheduleSlot slot) {
  return ScheduleSlotDto(
    datetime: _getDateTimeFromTypedComponents(
      slot.dayOfWeek,   // ✅ No string manipulation
      slot.timeOfDay,   // ✅ No format guessing
      slot.week,
    ),
    // ...
  );
}
```

---

## Pattern Matching Usage

### Before (String Comparisons)

```dart
// ❌ Error-prone, incomplete, no compile-time checking
if (period == "Morning" || period == "Matin" || period == "morning") {
  // Handle morning
} else if (period == "Afternoon" || period == "Après-midi") {
  // Handle afternoon
} else {
  // ??? What about other cases?
}
```

### After (Pattern Matching)

```dart
// ✅ Exhaustive, compile-time checked, type-safe
switch (period) {
  case AggregatePeriod(:final type, :final timeSlots):
    // Compiler forces us to handle this case
    return _buildMultiSlotView(type, timeSlots);

  case SpecificTimeSlot(:final timeSlot):
    // Compiler forces us to handle this case
    return _buildSingleSlotView(timeSlot);
}
// ✅ Compiler error if we miss a case!
```

---

## Migration Strategy

### Phase 1: Core Domain (✅ COMPLETE)

1. ✅ Created `TimeOfDayValue` value object
2. ✅ Created `SchedulePeriod` sealed class hierarchy
3. ✅ Updated `PeriodSlotData` with typed fields + backward-compatible constructor
4. ✅ Updated `ScheduleSlot` with typed fields + legacy getters
5. ✅ Updated `ScheduleSlotDto` for API boundary conversions

### Phase 2: Data Layer (✅ COMPLETE)

1. ✅ Updated `BasicSlotOperationsHandler` to accept typed parameters
2. ✅ Added legacy `upsertScheduleSlotFromStrings` for backward compatibility
3. ✅ Updated DTOs to convert at API boundary only

### Phase 3: Presentation Layer (✅ COMPLETE)

1. ✅ Updated `vehicle_selection_modal.dart` to use typed values
2. ✅ Replaced string validation with pattern matching
3. ✅ Simplified `_getTimeSlotsForPeriod` to use typed times directly

### Phase 4: Repository & Remaining Code (⏳ IN PROGRESS)

**Files needing updates**:
- `schedule_repository_impl.dart` - Update method signatures
- `schedule_grid.dart` - Update PeriodSlotData construction
- Test files - Update to use typed constructors

**Pattern to apply**:
```dart
// OLD
PeriodSlotData(
  day: "Monday",  // ❌ String
  period: "07:30",  // ❌ String
  times: ["07:30", "08:00"],  // ❌ List<String>
  //...
)

// NEW
PeriodSlotData(
  dayOfWeek: DayOfWeek.monday,  // ✅ Enum
  period: SpecificTimeSlot(TimeOfDayValue(7, 30)),  // ✅ Type
  times: [TimeOfDayValue(7, 30), TimeOfDayValue(8, 0)],  // ✅ List<TimeOfDayValue>
  //...
)

// OR use legacy constructor during migration
PeriodSlotData.fromStrings(
  day: "Monday",
  period: "07:30",
  times: ["07:30", "08:00"],
  //...
)
```

---

## Benefits Achieved

### Compile-Time Safety

| Before (Strings) | After (Types) |
|------------------|---------------|
| ❌ `day = "TUESDAY"` → Runtime error | ✅ `dayOfWeek = DayOfWeek.tuesday` → Compile-time checked |
| ❌ `time = "Matin"` → Runtime error | ✅ `timeOfDay = TimeOfDayValue(7, 30)` → Compile-time checked |
| ❌ No IDE support | ✅ Full IDE autocomplete |
| ❌ Validation scattered | ✅ Single validation point (DTO) |

### Code Quality

- **Less code**: Removed ~200 lines of string validation
- **Clearer intent**: `DayOfWeek.monday` vs `"Monday"`
- **Exhaustive patterns**: Compiler enforces all cases
- **Immutability**: Value objects prevent accidental modification

### Maintainability

- **Single source of truth**: Day names in `DayOfWeek` enum only
- **API boundary isolation**: String conversions in one place (DTOs)
- **Refactoring safety**: Change types, compiler finds all usage
- **Documentation**: Types document themselves

---

## Testing Strategy

### Unit Tests

```dart
// Test value object validation
test('TimeOfDayValue validates hour range', () {
  expect(() => TimeOfDayValue(24, 0), throwsAssertionError);
  expect(() => TimeOfDayValue(-1, 0), throwsAssertionError);
});

// Test pattern matching exhaustiveness
test('SchedulePeriod pattern matching is exhaustive', () {
  final periods = <SchedulePeriod>[
    AggregatePeriod(type: PeriodType.morning, timeSlots: []),
    SpecificTimeSlot(TimeOfDayValue(7, 30)),
  ];

  for (final period in periods) {
    final result = switch (period) {
      AggregatePeriod() => 'aggregate',
      SpecificTimeSlot() => 'specific',
      // Compiler error if we miss a case!
    };
    expect(result, isNotEmpty);
  }
});
```

### Integration Tests

```dart
// Test DTO conversion roundtrip
test('ScheduleSlot converts to/from DTO without data loss', () {
  final slot = ScheduleSlot(
    dayOfWeek: DayOfWeek.monday,
    timeOfDay: TimeOfDayValue(7, 30),
    // ...
  );

  final dto = ScheduleSlotDto.fromDomain(slot);
  final reconverted = dto.toDomain();

  expect(reconverted.dayOfWeek, slot.dayOfWeek);
  expect(reconverted.timeOfDay, slot.timeOfDay);
});
```

---

## Future Enhancements

### 1. Remove Legacy Constructors

Once all code is migrated, remove deprecated constructors:

```dart
// Remove these after migration complete
@Deprecated('...')
factory PeriodSlotData.fromStrings({...});

@Deprecated('...')
String get day => dayOfWeek.fullName;
```

### 2. Add Duration Value Object

```dart
class ScheduleDuration extends Equatable {
  final Duration duration;

  const ScheduleDuration(this.duration);

  factory ScheduleDuration.fromTimeSlots(
    TimeOfDayValue start,
    TimeOfDayValue end,
  );
}
```

### 3. Add Week Value Object

```dart
class IsoWeek extends Equatable {
  final int year;
  final int weekNumber;

  const IsoWeek(this.year, this.weekNumber);

  factory IsoWeek.parse(String week);  // "2025-W41"
  String toApiFormat();
  DateTime get mondayDate;
}
```

---

## Decision Records

### ADR-001: Use Sealed Classes for Period Representation

**Context**: Need to represent both aggregate periods (Morning) and specific times (07:30).

**Decision**: Use sealed class `SchedulePeriod` with two implementations.

**Rationale**:
- Exhaustive pattern matching
- Compile-time guarantees
- Clear domain semantics

**Alternatives Considered**:
1. Union types - Not available in Dart
2. Nullable fields - Runtime null checks required
3. Separate classes - No common interface

### ADR-002: API Boundary Conversion Pattern

**Context**: Backend uses strings, domain uses types.

**Decision**: Convert types ↔ strings ONLY in DTOs.

**Rationale**:
- Single conversion point
- No validation scatter
- Clear layer boundaries
- Testable in isolation

**Alternatives Considered**:
1. Convert in use cases - Would duplicate logic
2. Convert in repositories - Would leak strings into domain
3. Use strings everywhere - No compile-time safety

---

## Conclusion

The type-safe schedule domain architecture eliminates an entire class of runtime errors by leveraging Dart's type system. The migration strategy provides backward compatibility while allowing incremental adoption. Once complete, the codebase will be more maintainable, safer, and easier to refactor.

**Key Takeaways**:
1. ✅ Types are better than strings for domain entities
2. ✅ Sealed classes enable exhaustive pattern matching
3. ✅ Value objects eliminate validation scatter
4. ✅ API boundary isolation prevents string contamination
5. ✅ Backward compatibility enables safe migration

---

## References

- Dart Language: [Pattern Matching](https://dart.dev/language/patterns)
- Domain-Driven Design: [Value Objects](https://martinfowler.com/bliki/ValueObject.html)
- Clean Architecture: [Boundaries](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
