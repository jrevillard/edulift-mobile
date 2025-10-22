# Prisma `include` vs `select` - What Gets Returned?

## The Key Question

When Prisma uses `include` with relations, does it return foreign key fields?

**Answer: NO** ❌

---

## Visual Explanation

### Database Schema

```
┌─────────────────────────────────┐
│  ScheduleSlotVehicle (Table)    │
├─────────────────────────────────┤
│ id: String (PK)                 │
│ scheduleSlotId: String (FK) ←───┼──┐
│ vehicleId: String (FK) ←────────┼──┼──┐
│ driverId: String? (FK)          │  │  │
│ seatOverride: Int?              │  │  │
│ createdAt: DateTime             │  │  │
└─────────────────────────────────┘  │  │
                                     │  │
┌────────────────────────────┐      │  │
│  ScheduleSlot (Table)      │◄─────┘  │
├────────────────────────────┤         │
│ id: String (PK)            │         │
│ groupId: String            │         │
│ datetime: DateTime         │         │
└────────────────────────────┘         │
                                       │
┌────────────────────────────┐         │
│  Vehicle (Table)           │◄────────┘
├────────────────────────────┤
│ id: String (PK)            │
│ name: String               │
│ capacity: Int              │
│ familyId: String           │
└────────────────────────────┘
```

---

## Backend Query Pattern

### What Backend Does

```typescript
prisma.scheduleSlot.findMany({
  include: {
    vehicleAssignments: {
      include: {
        vehicle: { select: { id: true, name: true, capacity: true } },
        driver: { select: { id: true, name: true } }
      }
    }
  }
})
```

### What Prisma Returns (Actual API Response)

```json
{
  "scheduleSlots": [{
    "id": "slot-123",
    "datetime": "2024-01-08T08:00:00.000Z",
    "vehicleAssignments": [
      {
        "id": "assignment-456",
        "seatOverride": null,
        "createdAt": "2024-01-01T00:00:00.000Z",
        "vehicle": {
          "id": "vehicle-789",
          "name": "Alfa",
          "capacity": 3
        },
        "driver": null
      }
    ]
  }]
}
```

**Missing Fields:**
- ❌ `vehicleId` (foreign key)
- ❌ `scheduleSlotId` (foreign key)
- ❌ `driverId` (foreign key)

---

## Why Foreign Keys Are NOT Included

### Prisma's Behavior with `include`

When you use `include`, Prisma:
1. ✅ Includes the **relation fields** (nested objects)
2. ❌ Omits the **foreign key fields** (primitive values)

**Reason:** Prisma assumes you don't need foreign keys when you have the full nested object.

### Example Comparison

```typescript
// Database row (raw SQL)
{
  id: 'assignment-456',
  scheduleSlotId: 'slot-123',      // ← Foreign key
  vehicleId: 'vehicle-789',        // ← Foreign key
  driverId: null,                  // ← Foreign key
  seatOverride: null,
  createdAt: '2024-01-01T00:00:00.000Z'
}

// Prisma with include (what API returns)
{
  id: 'assignment-456',
  // scheduleSlotId: OMITTED
  // vehicleId: OMITTED
  // driverId: OMITTED
  seatOverride: null,
  createdAt: '2024-01-01T00:00:00.000Z',
  vehicle: {                        // ← Nested object included
    id: 'vehicle-789',
    name: 'Alfa',
    capacity: 3
  },
  driver: null                      // ← Null driver
}
```

---

## How to Get Foreign Keys (If Needed)

### Option 1: Explicit `select` (Replaces `include`)

```typescript
vehicleAssignments: {
  select: {
    id: true,
    vehicleId: true,          // ← NOW included
    scheduleSlotId: true,     // ← NOW included
    driverId: true,           // ← NOW included
    seatOverride: true,
    vehicle: {
      select: { id: true, name: true, capacity: true }
    },
    driver: {
      select: { id: true, name: true }
    }
  }
}
```

**Response:**
```json
{
  "id": "assignment-456",
  "vehicleId": "vehicle-789",       // ✅ Now included
  "scheduleSlotId": "slot-123",     // ✅ Now included
  "driverId": null,                 // ✅ Now included
  "seatOverride": null,
  "vehicle": { "id": "vehicle-789", "name": "Alfa", "capacity": 3 },
  "driver": null
}
```

### Option 2: Client-Side Fallback (Current Mobile Approach)

```dart
// Mobile DTO - Accept reality
class ScheduleSlotVehicleDto {
  final String? vehicleId;       // Optional
  final String? scheduleSlotId;  // Optional
  final VehicleDto vehicle;      // Required nested object

  String getVehicleId() => vehicleId ?? vehicle.id;  // Fallback
}
```

---

## Why Mobile's Fix is Correct

### Problem

Mobile expected:
```dart
vehicleId: json['vehicleId'] as String,  // ❌ Null cast error
```

But API returned:
```json
{
  "vehicleId": null  // ← Not present in response
}
```

### Solution

```dart
vehicleId: json['vehicleId'] as String?,  // ✅ Nullable cast
```

Then fallback in domain entity:
```dart
vehicleId: dto.vehicleId ?? dto.vehicle.id,  // ✅ Use nested object
```

---

## Summary Table

| Field | Database | Backend Query | API Response | Mobile Should |
|-------|----------|---------------|--------------|---------------|
| `id` | ✅ Present | ✅ Included | ✅ Present | `String` |
| `vehicleId` | ✅ Present (FK) | ❌ Not selected | ❌ Not present | `String?` + fallback |
| `scheduleSlotId` | ✅ Present (FK) | ❌ Not selected | ❌ Not present | `String?` + fallback |
| `driverId` | ✅ Present (FK) | ❌ Not selected | ❌ Not present | Extract from `driver?.id` |
| `vehicle` | ❌ Not a column | ✅ Included | ✅ Present | `VehicleDto` |
| `driver` | ❌ Not a column | ✅ Included | ✅ Present | `UserDto?` |
| `seatOverride` | ✅ Present | ✅ Included | ✅ Present | `int?` |

---

## Key Takeaways

1. **Prisma `include`** returns nested objects, NOT foreign keys
2. **Foreign keys are omitted** unless explicitly selected
3. **Mobile DTO must match API response**, not database schema
4. **Fallback to nested objects** is the correct pattern
5. **Your fix is correct** - don't revert it

---

## References

- Prisma Docs: [Selecting Fields](https://www.prisma.io/docs/concepts/components/prisma-client/select-fields)
- Prisma Docs: [Relation Queries](https://www.prisma.io/docs/concepts/components/prisma-client/relation-queries)
- EduLift Backend: `/workspace/backend/src/repositories/ScheduleSlotRepository.ts`
