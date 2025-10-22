# Seat Override - Corrections Requises pour Plan de Migration

**Date**: 2025-10-09
**Status**: CRITICAL FIXES REQUIRED
**Priority**: HIGH - Validation correctness

## 🚨 Problèmes Identifiés

### Problème #1: Validation Incorrecte (CRITIQUE)

**Localisation**: 
- Plan ligne 50-60: `_canAssignChild()` 
- Plan ligne 243-258: `ValidateChildAssignmentUseCase`

**Problème**: Utilise `vehicle.seatCapacity` au lieu de `vehicle.effectiveCapacity`

**Impact**: Validation échoue quand seat override actif
- Exemple: Véhicule capacité 4, override 6, 5 enfants assignés
- ❌ Actuel: Rejette (5 > 4)
- ✅ Correct: Accepte (5 < 6)

**Fix Requis**:
```dart
// AJOUTER à VehicleAssignment entity:
int get effectiveCapacity => seatOverride ?? capacity;

// MODIFIER ValidateChildAssignmentUseCase:
Future<Result<void, ScheduleFailure>> call({
  required VehicleAssignment vehicle,  // ← Changed from Vehicle
  required Child child,
  required List<Child> currentlyAssigned,
}) async {
  // ... existing checks
  
  final assignedToThisVehicle = currentlyAssigned
    .where((c) => c.assignedVehicleId == vehicle.id)
    .length;
  
  // FIX: Use effectiveCapacity
  if (assignedToThisVehicle >= vehicle.effectiveCapacity) {
    return Result.err(
      ScheduleFailure.capacityExceeded(
        capacity: vehicle.effectiveCapacity,  // Show effective capacity
        assigned: assignedToThisVehicle,
        details: vehicle.seatOverride != null 
          ? 'Vehicle full: $assignedToThisVehicle/${vehicle.effectiveCapacity} seats (override active)'
          : 'Vehicle full: $assignedToThisVehicle/${vehicle.effectiveCapacity} seats',
      ),
    );
  }
  
  return const Result.ok(null);
}
```

**Effort**: 1 heure (getter + validation + tests)

---

### Problème #2: Capacity Bar N'affiche Pas Override

**Localisation**: Plan ligne 130-165 (Phase 3.3)

**Problème**: UI montre `$used/$capacity` mais devrait indiquer override

**Fix Requis**:
```dart
Widget _buildCapacityBar(VehicleAssignment vehicle, List<Child> assigned) {
  final used = assigned.where((c) => c.assignedVehicleId == vehicle.id).length;
  final total = vehicle.effectiveCapacity;  // ← Use effective capacity
  final percentage = used / total;
  final hasOverride = vehicle.seatOverride != null;
  
  Color barColor;
  if (percentage < 0.8) {
    barColor = Colors.green;
  } else if (percentage < 1.0) {
    barColor = Colors.orange;
  } else {
    barColor = Colors.amber;
  }
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[200],
              color: hasOverride ? Colors.orange : barColor,  // ← Orange when override
              minHeight: 8,
            ),
          ),
          SizedBox(width: 8),
          Text(
            '$used/$total seats',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: hasOverride ? Colors.orange[700] : Colors.grey[700],
            ),
          ),
        ],
      ),
      // NEW: Override indicator
      if (hasOverride)
        Padding(
          padding: EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(Icons.edit, size: 14, color: Colors.orange[700]),
              SizedBox(width: 4),
              Text(
                'Override: ${vehicle.seatOverride} seats (default: ${vehicle.capacity})',
                style: TextStyle(fontSize: 11, color: Colors.orange[700]),
              ),
            ],
          ),
        ),
      if (percentage >= 1.0)
        Padding(
          padding: EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(Icons.warning_amber, size: 16, color: Colors.amber[700]),
              SizedBox(width: 4),
              Text(
                'Vehicle full - no more seats available',
                style: TextStyle(fontSize: 12, color: Colors.amber[700]),
              ),
            ],
          ),
        ),
    ],
  );
}
```

**Effort**: 1 heure

---

### Problème #3: Checkbox Disable Logic

**Localisation**: Plan ligne 43-73

**Problème**: `_canAssignChild()` utilise `vehicle.seatCapacity`

**Fix Requis**:
```dart
bool _canAssignChild(Child child, VehicleAssignment vehicle, List<Child> assigned) {
  // 1. Si déjà assigné, allow toggle off
  if (child.assignedVehicleId == vehicle.id) return true;
  
  // 2. Check capacity avec override
  final capacityUsed = assigned.where((c) => c.assignedVehicleId == vehicle.id).length;
  final capacityTotal = vehicle.effectiveCapacity;  // ← FIX: Use effective capacity
  
  // 3. Allow si encore de la place
  return capacityUsed < capacityTotal;
}
```

**Effort**: 30 minutes

---

### Problème #4: Pas d'UI pour DÉFINIR Override (DÉCISION REQUISE)

**Contexte**:
- Web frontend: UI inline pour ajuster sièges ✅
- Mobile family: Widgets complets pour gérer overrides ✅
- Mobile schedule: AUCUNE UI pour définir override ❌

**Options**:

**Option A: Ajouter UI dans Schedule System** (Recommandé)
- Add TextField dans VehicleAssignmentSheet (Level 2)
- Pattern: Comme web frontend inline UI
- Effort: 3-4 heures

**Implémentation**:
```dart
// Dans VehicleAssignmentSheet (Level 2):
Widget _buildVehicleCard(VehicleAssignment vehicle) {
  return Column(
    children: [
      // Existing vehicle info
      ListTile(
        leading: Icon(Icons.directions_car),
        title: Text('${vehicle.vehicleName}'),
        subtitle: Text('${vehicle.driverName}'),
      ),
      
      // NEW: Seat override control
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Text('Seats for this trip:', style: TextStyle(fontSize: 12)),
            SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: TextField(
                keyboardType: TextInputType.number,
                controller: _seatOverrideController,
                decoration: InputDecoration(
                  hintText: '${vehicle.capacity}',
                  suffix: Text('/${vehicle.capacity}', style: TextStyle(fontSize: 10)),
                ),
                onChanged: (value) {
                  final override = int.tryParse(value);
                  setState(() => _seatOverride = override);
                },
              ),
            ),
            if (_seatOverride != null && _seatOverride != vehicle.capacity)
              IconButton(
                icon: Icon(Icons.refresh, size: 16),
                onPressed: () {
                  _seatOverrideController.clear();
                  setState(() => _seatOverride = null);
                },
              ),
          ],
        ),
      ),
      if (_seatOverride != null)
        Padding(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
          child: Text(
            '💡 Adjust if fewer seats due to cargo/equipment',
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ),
      
      // Existing capacity bar
      _buildCapacityBar(vehicle, _assignedChildren),
    ],
  );
}
```

**Option B: Web-Only pour Schedule** (Pas recommandé)
- Mobile users ne peuvent pas ajuster override
- Doivent utiliser web pour définir override
- Expérience incohérente
- Effort: 0 heures mais UX dégradée

**Recommandation**: **Option A** - Ajouter UI mobile pour cohérence

**Effort**: 3-4 heures

---

## 📊 Effort Total Requis

| Priorité | Item | Effort | Bloquant |
|----------|------|--------|----------|
| 🔴 HIGH | Ajouter `effectiveCapacity` getter | 30min | OUI |
| 🔴 HIGH | Fix validation use case | 1h | OUI |
| 🔴 HIGH | Fix checkbox disable logic | 30min | OUI |
| 🟡 MEDIUM | Fix capacity bar UI | 1h | NON |
| 🟡 MEDIUM | Ajouter UI pour SET override | 3-4h | NON |
| 🟢 LOW | Tests override scenarios | 1h | NON |

**Total Minimum** (fixes critiques): **3 heures**
**Total Recommandé** (avec UI): **6-8 heures**

---

## 🔄 Mise à Jour du Plan de Migration

### Phase 1: Core Architecture

**AJOUTER** (30 minutes):
```dart
// File: /workspace/mobile_app/lib/features/schedule/domain/entities/vehicle_assignment.dart
// ADD getter:
int get effectiveCapacity => seatOverride ?? capacity;
```

### Phase 2: State Management

**AJOUTER** (30 minutes):
- State pour seat override editing dans VehicleAssignmentSheet
- Controller pour TextField override

### Phase 3: Mobile UX + Validation

**MODIFIER Validation** (1.5 heures):
1. Update `_canAssignChild()` to use `vehicle.effectiveCapacity`
2. Update `ValidateChildAssignmentUseCase` to use `vehicle.effectiveCapacity`
3. Update error messages to show effective capacity

**MODIFIER Capacity Bar** (1 heure):
1. Use `vehicle.effectiveCapacity` for total
2. Add override indicator when `vehicle.seatOverride != null`
3. Orange color when override active
4. Show "Override: X seats (default: Y)"

**AJOUTER UI pour SET Override** (3-4 heures) - SI APPROUVÉ:
1. TextField dans VehicleAssignmentSheet
2. Validation: 0 ≤ override ≤ 50
3. Reset button
4. Helper text
5. Save to backend via API

### Phase 4: Testing

**AJOUTER Test Cases** (1 heure):
1. **Test: Validation with override**
   - Vehicle capacity 4, override 6, assign 5 children → Should succeed
   - Vehicle capacity 8, override 6, assign 7 children → Should fail
2. **Test: Checkbox disable with override**
   - Vehicle capacity 4, override 6, 5 assigned → 6th child checkbox enabled
   - Vehicle capacity 4, override 6, 6 assigned → 7th child checkbox disabled
3. **Test: Capacity bar with override**
   - Shows effective capacity (6 not 4)
   - Shows override indicator
   - Orange color when override active
4. **Test: UI set override** (si implémenté)
   - Can set override value
   - Can reset to default
   - Validates range 0-50

---

## 📝 Checklist Implémentation

**Phase 1** (HIGH PRIORITY):
- [ ] Add `effectiveCapacity` getter to VehicleAssignment
- [ ] Update `_canAssignChild()` to use `effectiveCapacity`
- [ ] Update `ValidateChildAssignmentUseCase` to use `effectiveCapacity`
- [ ] Update error messages to mention override if active

**Phase 2** (MEDIUM PRIORITY):
- [ ] Update capacity bar to use `effectiveCapacity`
- [ ] Add override indicator to capacity bar UI
- [ ] Orange color for progress bar when override active
- [ ] Show "Override: X seats (default: Y)" text

**Phase 3** (REQUIRES DECISION):
- [ ] **DECISION**: Product team approves mobile UI for SET override?
- [ ] If YES: Implement TextField in VehicleAssignmentSheet
- [ ] If YES: Add save logic to API
- [ ] If YES: Add validation and error handling
- [ ] If NO: Document that override is web-only for schedule

**Phase 4** (TESTING):
- [ ] Write tests for validation with override
- [ ] Write tests for checkbox disable with override
- [ ] Write tests for capacity bar with override
- [ ] Write tests for UI set override (if implemented)
- [ ] Update integration tests

---

## 🎯 Success Criteria (UPDATED)

### Validation
- ✅ Uses `vehicle.effectiveCapacity` not `vehicle.seatCapacity`
- ✅ Accepts assignments up to override capacity
- ✅ Rejects assignments beyond override capacity
- ✅ Error messages indicate override if active

### UI
- ✅ Capacity bar shows effective capacity
- ✅ Override indicator visible when active
- ✅ Orange/amber color when override set
- ✅ Shows "Override: X seats (default: Y)"
- ⚠️ UI to SET override (pending decision)

### Testing
- ✅ All override scenarios have test coverage
- ✅ 95%+ coverage for validation use case
- ✅ Widget tests for capacity bar with override

---

## 📚 Références Code

### Web Frontend Pattern
**File**: `/workspace/frontend/src/components/VehicleSelectionModal.tsx`
**Lines**: 348-381 (inline seat adjustment UI)

### Backend Validation Pattern
**File**: `/workspace/backend/src/services/ScheduleSlotValidationService.ts`
**Lines**: 8-12 (`getEffectiveCapacity()` helper)

### Mobile Family Pattern
**File**: `/workspace/mobile_app/lib/features/family/presentation/widgets/seat_override_widget.dart`
**Lines**: 251-451 (comprehensive override UI)

### Mobile Schedule Current State
**Files**:
- Entity: `/workspace/mobile_app/lib/core/domain/entities/schedule/vehicle_assignment.dart`
- DTO: `/workspace/mobile_app/lib/core/network/models/schedule/vehicle_assignment_dto.dart`
- API: `/workspace/mobile_app/lib/core/network/schedule_api_client.dart` (line 134)

---

**Document créé**: 2025-10-09
**Status**: CORRECTIONS REQUISES
**Priority**: HIGH - Validation correctness critical
**Effort**: 3-8 heures selon décision UI
