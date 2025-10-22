# Plan de Migration Schedule - Version Finale avec Validation + Seat Override 2025

**Date**: 2025-10-09 (Version finale avec validation + seat override)
**Statut**: PRODUCTION READY
**Architecture**: Cache-First + Mobile-First + Client Validation + Seat Override
**Durée totale**: 38.5-54.5 heures (4 phases)

---

## 🎯 Principe Fondamental - Validation Proactive

> **Exigence Critique**: "Il faut une vérification AVANT afin que cela ne soit pas possible"

**Solution**: Validation **3 couches** (proactive → réactive → safeguard)

```
┌─────────────────────────────────────────────────┐
│  USER TAP CHECKBOX                              │
│         ↓                                       │
│  [1] PRESENTATION: Checkbox enabled?           │
│      → NO: Grayed, tooltip "Vehicle full"      │
│      → YES: Optimistic update + validate       │
│         ↓                                       │
│  [2] DOMAIN: ValidateChildAssignmentUseCase    │
│      → Check: assigned.length < vehicle.effectiveCapacity  ← UPDATED
│      → FAIL: Revert UI, show error             │
│      → PASS: Continue to sync                  │
│         ↓                                       │
│  [3] DATA: Repository pre-check                │
│      → Re-validate before API call             │
│      → Race condition? Show conflict dialog    │
│      → PASS: Send to server                    │
│         ↓                                       │
│  [4] SERVER: Final authority (400 if invalid)  │
└─────────────────────────────────────────────────┘
```

**Clé**: L'utilisateur **NE PEUT PAS** assigner si véhicule plein (pas juste warning)
**NOUVEAU**: Validation utilise `effectiveCapacity` (considère seat override)

---

## 📋 Client-Side Validation Architecture

### Règle #1: Checkbox Disabled (Proactive) ← UPDATED

**Où**: `ChildAssignmentSheet` Widget (Presentation Layer)

**Logique**:
```dart
bool _canAssignChild(Child child, VehicleAssignment vehicle, List<Child> assigned) {
  // 1. Si déjà assigné, toujours allow (pour toggle off)
  if (child.assignedVehicleId == vehicle.id) return true;
  
  // 2. Check capacity WITH OVERRIDE ← UPDATED
  final capacityUsed = assigned.where((c) => c.assignedVehicleId == vehicle.id).length;
  final capacityTotal = vehicle.effectiveCapacity;  // ← FIXED: Uses override if set
  
  // 3. Allow si encore de la place
  return capacityUsed < capacityTotal;
}

// Dans build()
Widget _buildChildRow(Child child) {
  final canAssign = _canAssignChild(child, widget.vehicle, _assignedChildren);
  
  return CheckboxListTile(
    value: child.isAssigned,
    enabled: canAssign,  // ← DISABLE si plein
    onChanged: canAssign ? (value) => _toggleAssignment(child) : null,
    title: Text(
      child.name,
      style: canAssign ? null : TextStyle(color: Colors.grey), // Grayed si disabled
    ),
    subtitle: canAssign 
      ? Text(child.school)
      : Row(
          children: [
            Icon(Icons.block, size: 16, color: Colors.orange),
            SizedBox(width: 4),
            Text('Vehicle full', style: TextStyle(color: Colors.orange)),
          ],
        ),
  );
}
```

**Visual States**:
- ✅ **Available**: Checkbox enabled, text black, school shown
- ✅ **Assigned**: Checkbox checked, cloud icon if pending sync
- ❌ **Vehicle Full**: Checkbox disabled (grayed), "Vehicle full" subtitle, orange block icon

---

### Règle #2: Capacity Bar (Real-Time) ← UPDATED

**Où**: `VehicleCard` + `ChildAssignmentSheet` Header

**Logique**:
```dart
Widget _buildCapacityBar(VehicleAssignment vehicle, List<Child> assigned) {
  final used = assigned.where((c) => c.assignedVehicleId == vehicle.id).length;
  final total = vehicle.effectiveCapacity;  // ← FIXED: Uses override if set
  final percentage = used / total;
  
  Color barColor;
  if (percentage < 0.8) {
    barColor = Colors.green;      // < 80%: Green
  } else if (percentage < 1.0) {
    barColor = Colors.orange;     // 80-99%: Orange
  } else {
    barColor = Colors.amber;      // 100%: Amber (full)
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
              color: vehicle.hasOverride ? Colors.orange : barColor,  // ← NEW: Orange when override
              minHeight: 8,
            ),
          ),
          SizedBox(width: 8),
          Text(
            '$used/$total seats',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: vehicle.hasOverride ? Colors.orange[700] : (percentage >= 1.0 ? Colors.amber[700] : Colors.grey[700]),
            ),
          ),
        ],
      ),
      // NEW: Override indicator
      if (vehicle.hasOverride)
        Padding(
          padding: EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(Icons.edit, size: 14, color: Colors.orange[700]),
              SizedBox(width: 4),
              Text(
                'Override: ${vehicle.seatOverride} seats (default: ${vehicle.capacity})',
                style: TextStyle(fontSize: 11, color: Colors.orange[700], fontStyle: FontStyle.italic),
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

**Visual Feedback**:
- **4/6 seats** (override 6, default 4): Orange bar, "4/6 seats", shows override indicator
- **6/6 seats** (override): Amber bar (100%), warning "Vehicle full"
- **Updates real-time**: On every checkbox toggle, bar animates

---

### Règle #3: Save Button Disabled

**Où**: `ChildAssignmentSheet` Footer

**Logique**:
```dart
bool _canSaveAssignments() {
  // Check si AUCUN véhicule n'est over-capacity
  for (final vehicle in _vehicles) {
    final assigned = _assignedChildren.where((c) => c.assignedVehicleId == vehicle.id).toList();
    if (assigned.length > vehicle.effectiveCapacity) {  // ← UPDATED: Use effectiveCapacity
      return false; // Over-capacity detected!
    }
  }
  return true;
}

Widget _buildSaveButton() {
  final canSave = _canSaveAssignments();
  
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (!canSave)
        Container(
          padding: EdgeInsets.all(12),
          color: Colors.red[50],
          child: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cannot save: Some vehicles are over capacity. Remove children to continue.',
                  style: TextStyle(color: Colors.red[700], fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ElevatedButton(
        onPressed: canSave ? _saveAssignments : null,  // ← null = disabled
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 48),
          backgroundColor: canSave ? Colors.blue : Colors.grey,
        ),
        child: Text(
          canSave ? 'Save Changes' : 'Cannot Save - Over Capacity',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    ],
  );
}
```

**Visual States**:
- ✅ **Can Save**: Blue button, enabled, "Save Changes" text
- ❌ **Cannot Save**: Gray button, disabled, "Cannot Save - Over Capacity" + red banner above

---

### Règle #4: Domain Validation (Business Logic) ← UPDATED

**Où**: `ValidateChildAssignmentUseCase` (Domain Layer)

**Fichier**: `lib/features/schedule/domain/usecases/validate_child_assignment.dart` (À CRÉER)

```dart
class ValidateChildAssignmentUseCase {
  Future<Result<void, ScheduleFailure>> call({
    required VehicleAssignment vehicle,  // ← UPDATED: VehicleAssignment not Vehicle
    required Child child,
    required List<Child> currentlyAssigned,
  }) async {
    // 1. Check si child déjà assigné à ce véhicule (allow toggle off)
    if (currentlyAssigned.any((c) => c.id == child.id && c.assignedVehicleId == vehicle.id)) {
      return const Result.ok(null); // OK to unassign
    }
    
    // 2. Count current assignments pour ce véhicule
    final assignedToThisVehicle = currentlyAssigned
      .where((c) => c.assignedVehicleId == vehicle.id)
      .length;
    
    // 3. Check capacity ← UPDATED: Use effectiveCapacity
    if (assignedToThisVehicle >= vehicle.effectiveCapacity) {
      return Result.err(
        ScheduleFailure.capacityExceeded(
          capacity: vehicle.effectiveCapacity,  // ← UPDATED: Show effective capacity
          assigned: assignedToThisVehicle,
          details: vehicle.hasOverride 
            ? 'Cannot assign ${child.name} to ${vehicle.vehicleName}. Vehicle full: $assignedToThisVehicle/${vehicle.effectiveCapacity} seats (override active: ${vehicle.seatOverride})'
            : 'Cannot assign ${child.name} to ${vehicle.vehicleName}. Vehicle full: $assignedToThisVehicle/${vehicle.effectiveCapacity} seats',
        ),
      );
    }
    
    // 4. Check si child déjà assigné à AUTRE véhicule même slot
    final assignedToOtherVehicle = currentlyAssigned
      .where((c) => c.id == child.id && c.assignedVehicleId != vehicle.id)
      .isNotEmpty;
    
    if (assignedToOtherVehicle) {
      return Result.err(
        ScheduleFailure.childAlreadyAssigned(
          childName: child.name,
          details: '${child.name} is already assigned to another vehicle for this time slot.',
        ),
      );
    }
    
    // 5. All checks passed
    return const Result.ok(null);
  }
}
```

**Tests**: `test/unit/domain/usecases/validate_child_assignment_test.dart`
- ✅ Returns ok when under capacity
- ✅ Returns failure when at capacity
- ✅ Returns ok when unassigning (toggle off)
- ✅ Returns failure when child already assigned to other vehicle
- ✅ **NEW**: Returns ok when under override capacity
- ✅ **NEW**: Returns failure when at override capacity

---

### Règle #5: Repository Pre-Check (Safeguard)

**Où**: `ScheduleRepositoryImpl.assignChildToVehicle()` (Data Layer)

**Logique**:
```dart
@override
Future<Result<void, ApiFailure>> assignChildToVehicle({
  required String slotId,
  required String vehicleAssignmentId,
  required String childId,
}) async {
  // 1. Fetch current state from cache (fast)
  final slot = await _localDataSource.getCachedScheduleSlot(slotId);
  if (slot == null) {
    return const Result.err(ApiFailure(code: 'schedule.slot_not_found'));
  }
  
  // 2. Get vehicle assignment
  final vehicleAssignments = await _localDataSource.getCachedVehicleAssignments(slotId) ?? [];
  final vehicleAssignment = vehicleAssignments.firstWhere(
    (va) => va.id == vehicleAssignmentId,
    orElse: () => throw Exception('Vehicle assignment not found'),
  );
  
  // 3. PRE-VALIDATION: Check capacity BEFORE API call ← UPDATED
  final currentAssignments = vehicleAssignment.childAssignments ?? [];
  if (currentAssignments.length >= vehicleAssignment.effectiveCapacity) {  // ← UPDATED
    // Race condition detected! Someone else assigned while we were offline
    return Result.err(
      ApiFailure(
        code: 'schedule.capacity_exceeded_race',
        message: 'Vehicle capacity exceeded. Another parent assigned a child while you were editing.',
        details: {
          'capacity': vehicleAssignment.effectiveCapacity,  // ← UPDATED
          'assigned': currentAssignments.length,
          'hasOverride': vehicleAssignment.hasOverride,
        },
      ),
    );
  }
  
  // 4. Check network
  if (!await _networkInfo.isConnected) {
    // Store pending operation (will validate again before sending)
    await _localDataSource.storePendingOperation({
      'type': 'assign_child',
      'slotId': slotId,
      'vehicleAssignmentId': vehicleAssignmentId,
      'childId': childId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    return const Result.err(ApiFailure(code: 'network.offline'));
  }
  
  // 5. Call API
  final result = await _vehicleHandler.assignChildToVehicle(
    slotId: slotId,
    vehicleAssignmentId: vehicleAssignmentId,
    childId: childId,
  );
  
  // 6. Update cache on success
  await result.when(
    ok: (_) async {
      // Refresh slot from server to get latest state
      final freshSlot = await _remoteDataSource.getScheduleSlot(slotId);
      await _localDataSource.cacheScheduleSlot(freshSlot);
    },
    err: (_) => null,
  );
  
  return result;
}
```

**Cas Edge**: Si 409 Conflict du serveur → Show dialog "Someone else edited, refresh?"

---

## 🧪 Test Strategy - Validation

### Use Case Tests
**Fichier**: `test/unit/domain/usecases/validate_child_assignment_test.dart`

```dart
void main() {
  group('ValidateChildAssignmentUseCase', () {
    late ValidateChildAssignmentUseCase usecase;
    
    setUp(() {
      usecase = ValidateChildAssignmentUseCase();
    });
    
    test('returns ok when vehicle has available seats', () async {
      // Arrange
      final vehicle = VehicleAssignment(
        id: '1',
        vehicleName: 'Honda CR-V',
        capacity: 5,
        seatOverride: null,
      );
      final child = Child(id: 'c1', name: 'Emma');
      final currentlyAssigned = [
        Child(id: 'c2', name: 'Lucas', assignedVehicleId: '1'),
        Child(id: 'c3', name: 'Sophia', assignedVehicleId: '1'),
      ]; // 2 assigned, 5 capacity → 3 seats free
      
      // Act
      final result = await usecase(
        vehicle: vehicle,
        child: child,
        currentlyAssigned: currentlyAssigned,
      );
      
      // Assert
      expect(result.isOk, true);
    });
    
    test('returns failure when vehicle at full capacity', () async {
      // Arrange
      final vehicle = VehicleAssignment(
        id: '1',
        vehicleName: 'Honda CR-V',
        capacity: 5,
        seatOverride: null,
      );
      final child = Child(id: 'c1', name: 'Emma');
      final currentlyAssigned = List.generate(
        5,
        (i) => Child(id: 'c$i', name: 'Child $i', assignedVehicleId: '1'),
      ); // 5 assigned, 5 capacity → FULL
      
      // Act
      final result = await usecase(
        vehicle: vehicle,
        child: child,
        currentlyAssigned: currentlyAssigned,
      );
      
      // Assert
      expect(result.isErr, true);
      result.when(
        ok: (_) => fail('Should return error'),
        err: (failure) {
          expect(failure, isA<ScheduleFailure>());
          expect(failure.code, 'schedule.capacity_exceeded');
        },
      );
    });
    
    test('returns ok when child already assigned (allows toggle off)', () async {
      // Arrange
      final vehicle = VehicleAssignment(
        id: '1',
        vehicleName: 'Honda CR-V',
        capacity: 5,
        seatOverride: null,
      );
      final child = Child(id: 'c1', name: 'Emma', assignedVehicleId: '1');
      final currentlyAssigned = [child]; // Emma déjà assigné
      
      // Act
      final result = await usecase(
        vehicle: vehicle,
        child: child,
        currentlyAssigned: currentlyAssigned,
      );
      
      // Assert
      expect(result.isOk, true); // OK to unassign
    });
    
    test('returns failure when child assigned to another vehicle same slot', () async {
      // Arrange
      final vehicle1 = VehicleAssignment(id: '1', vehicleName: 'Honda CR-V', capacity: 5);
      final vehicle2 = VehicleAssignment(id: '2', vehicleName: 'Toyota Camry', capacity: 4);
      final child = Child(id: 'c1', name: 'Emma', assignedVehicleId: '2'); // Déjà dans vehicle 2
      final currentlyAssigned = [child];
      
      // Act - Try to assign to vehicle 1
      final result = await usecase(
        vehicle: vehicle1,
        child: child,
        currentlyAssigned: currentlyAssigned,
      );
      
      // Assert
      expect(result.isErr, true);
      result.when(
        ok: (_) => fail('Should return error'),
        err: (failure) {
          expect(failure.code, 'schedule.child_already_assigned');
        },
      );
    });
    
    // NEW: Seat override tests
    test('returns ok when under override capacity', () async {
      // Arrange
      final vehicle = VehicleAssignment(
        id: '1',
        vehicleName: 'Honda CR-V',
        capacity: 4,
        seatOverride: 6,  // Override to 6 seats
      );
      final child = Child(id: 'c1', name: 'Emma');
      final currentlyAssigned = List.generate(
        5,
        (i) => Child(id: 'c$i', name: 'Child $i', assignedVehicleId: '1'),
      ); // 5 assigned, 6 effective capacity → 1 seat free
      
      // Act
      final result = await usecase(
        vehicle: vehicle,
        child: child,
        currentlyAssigned: currentlyAssigned,
      );
      
      // Assert
      expect(result.isOk, true); // Should succeed (5 < 6)
    });
    
    test('returns failure when at override capacity', () async {
      // Arrange
      final vehicle = VehicleAssignment(
        id: '1',
        vehicleName: 'Honda CR-V',
        capacity: 8,
        seatOverride: 6,  // Override to 6 seats
      );
      final child = Child(id: 'c1', name: 'Emma');
      final currentlyAssigned = List.generate(
        6,
        (i) => Child(id: 'c$i', name: 'Child $i', assignedVehicleId: '1'),
      ); // 6 assigned, 6 effective capacity → FULL
      
      // Act
      final result = await usecase(
        vehicle: vehicle,
        child: child,
        currentlyAssigned: currentlyAssigned,
      );
      
      // Assert
      expect(result.isErr, true);
      result.when(
        ok: (_) => fail('Should return error'),
        err: (failure) {
          expect(failure.code, 'schedule.capacity_exceeded');
          expect(failure.details, contains('override active'));
        },
      );
    });
  });
}
```

### Widget Tests
**Fichier**: `test/presentation/widgets/child_assignment_sheet_test.dart`

```dart
void main() {
  group('ChildAssignmentSheet - Capacity Validation', () {
    testWidgets('disables checkbox when vehicle at capacity', (tester) async {
      // Arrange
      final vehicle = VehicleAssignment(
        id: '1',
        vehicleName: 'Honda CR-V',
        capacity: 5,
        seatOverride: null,
      );
      final assignedChildren = List.generate(
        5,
        (i) => Child(id: 'c$i', name: 'Child $i', assignedVehicleId: '1'),
      );
      final availableChild = Child(id: 'c6', name: 'New Child');
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChildAssignmentSheet(
            vehicle: vehicle,
            assignedChildren: assignedChildren,
            availableChildren: [availableChild],
          ),
        ),
      );
      
      // Act - Find checkbox for available child
      final checkbox = find.byKey(Key('checkbox_${availableChild.id}'));
      
      // Assert
      expect(checkbox, findsOneWidget);
      final checkboxWidget = tester.widget<CheckboxListTile>(checkbox);
      expect(checkboxWidget.enabled, false); // Should be disabled!
      
      // Assert - Tooltip shows "Vehicle full"
      expect(find.text('Vehicle full'), findsOneWidget);
    });
    
    testWidgets('enables checkbox when vehicle has available seats', (tester) async {
      // Arrange
      final vehicle = VehicleAssignment(
        id: '1',
        vehicleName: 'Honda CR-V',
        capacity: 5,
        seatOverride: null,
      );
      final assignedChildren = [
        Child(id: 'c1', name: 'Emma', assignedVehicleId: '1'),
      ]; // 1/5 → 4 seats free
      final availableChild = Child(id: 'c2', name: 'Lucas');
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChildAssignmentSheet(
            vehicle: vehicle,
            assignedChildren: assignedChildren,
            availableChildren: [availableChild],
          ),
        ),
      );
      
      // Act
      final checkbox = find.byKey(Key('checkbox_${availableChild.id}'));
      
      // Assert
      final checkboxWidget = tester.widget<CheckboxListTile>(checkbox);
      expect(checkboxWidget.enabled, true); // Should be enabled
      expect(find.text('Vehicle full'), findsNothing); // No warning
    });
    
    testWidgets('updates capacity bar in real-time on toggle', (tester) async {
      // Arrange
      final vehicle = VehicleAssignment(
        id: '1',
        vehicleName: 'Honda CR-V',
        capacity: 5,
        seatOverride: null,
      );
      final assignedChildren = [
        Child(id: 'c1', name: 'Emma', assignedVehicleId: '1'),
      ]; // 1/5
      final availableChild = Child(id: 'c2', name: 'Lucas');
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ChildAssignmentSheet(
              vehicle: vehicle,
              assignedChildren: assignedChildren,
              availableChildren: [availableChild],
            ),
          ),
        ),
      );
      
      // Initial state: 1/5 seats
      expect(find.text('1/5 seats'), findsOneWidget);
      
      // Act - Tap checkbox to assign Lucas
      final checkbox = find.byKey(Key('checkbox_${availableChild.id}'));
      await tester.tap(checkbox);
      await tester.pumpAndSettle();
      
      // Assert - Capacity updated to 2/5
      expect(find.text('2/5 seats'), findsOneWidget);
    });
    
    testWidgets('disables save button when over capacity', (tester) async {
      // This shouldn't happen with UI validation, but test safeguard
      final vehicle = VehicleAssignment(
        id: '1',
        vehicleName: 'Honda CR-V',
        capacity: 5,
        seatOverride: null,
      );
      final assignedChildren = List.generate(
        6, // 6 assigned, 5 capacity → OVER!
        (i) => Child(id: 'c$i', name: 'Child $i', assignedVehicleId: '1'),
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChildAssignmentSheet(
            vehicle: vehicle,
            assignedChildren: assignedChildren,
            availableChildren: [],
          ),
        ),
      );
      
      // Assert - Save button disabled
      final saveButton = find.byKey(Key('save_button'));
      final buttonWidget = tester.widget<ElevatedButton>(saveButton);
      expect(buttonWidget.onPressed, isNull); // null = disabled
      
      // Assert - Error banner shown
      expect(find.text('Cannot save: Some vehicles are over capacity'), findsOneWidget);
    });
    
    // NEW: Override tests
    testWidgets('shows override indicator in capacity bar', (tester) async {
      final vehicle = VehicleAssignment(
        id: '1',
        vehicleName: 'Honda CR-V',
        capacity: 4,
        seatOverride: 6,  // Override
      );
      final assignedChildren = [
        Child(id: 'c1', name: 'Emma', assignedVehicleId: '1'),
        Child(id: 'c2', name: 'Lucas', assignedVehicleId: '1'),
      ]; // 2/6
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChildAssignmentSheet(
            vehicle: vehicle,
            assignedChildren: assignedChildren,
            availableChildren: [],
          ),
        ),
      );
      
      // Assert - Shows effective capacity
      expect(find.text('2/6 seats'), findsOneWidget);
      
      // Assert - Shows override indicator
      expect(find.text('Override: 6 seats (default: 4)'), findsOneWidget);
    });
  });
}
```

### Repository Tests
**Fichier**: `test/unit/data/repositories/schedule_repository_validation_test.dart`

```dart
void main() {
  group('ScheduleRepositoryImpl - Pre-Validation', () {
    late ScheduleRepositoryImpl repository;
    late MockScheduleLocalDataSource mockLocalDataSource;
    late MockScheduleRemoteDataSource mockRemoteDataSource;
    late MockNetworkInfo mockNetworkInfo;
    
    setUp(() {
      mockLocalDataSource = MockScheduleLocalDataSource();
      mockRemoteDataSource = MockScheduleRemoteDataSource();
      mockNetworkInfo = MockNetworkInfo();
      repository = ScheduleRepositoryImpl(
        mockRemoteDataSource,
        mockLocalDataSource,
        mockNetworkInfo,
      );
    });
    
    test('rejects assignment when cache shows vehicle at capacity', () async {
      // Arrange
      final slot = ScheduleSlot(id: 'slot1', groupId: 'g1', day: 'Monday', time: 'Morning');
      final vehicleAssignment = VehicleAssignment(
        id: 'va1',
        slotId: 'slot1',
        capacity: 5,
        seatOverride: null,
        childAssignments: List.generate(5, (i) => ChildAssignment(id: 'ca$i', childId: 'c$i')), // FULL
      );
      
      when(mockLocalDataSource.getCachedScheduleSlot('slot1')).thenAnswer((_) async => slot);
      when(mockLocalDataSource.getCachedVehicleAssignments('slot1')).thenAnswer((_) async => [vehicleAssignment]);
      
      // Act
      final result = await repository.assignChildToVehicle(
        slotId: 'slot1',
        vehicleAssignmentId: 'va1',
        childId: 'c_new',
      );
      
      // Assert
      expect(result.isErr, true);
      result.when(
        ok: (_) => fail('Should return error'),
        err: (failure) {
          expect(failure.code, 'schedule.capacity_exceeded_race');
          expect(failure.message, contains('Another parent assigned'));
        },
      );
      
      // Verify API NOT called (blocked by pre-check)
      verifyNever(mockRemoteDataSource.assignChildToVehicle(any, any, any));
    });
    
    test('calls API when cache shows vehicle has available seats', () async {
      // Arrange
      final slot = ScheduleSlot(id: 'slot1', groupId: 'g1', day: 'Monday', time: 'Morning');
      final vehicleAssignment = VehicleAssignment(
        id: 'va1',
        slotId: 'slot1',
        capacity: 5,
        seatOverride: null,
        childAssignments: [ChildAssignment(id: 'ca1', childId: 'c1')], // 1/5 → 4 free
      );
      
      when(mockLocalDataSource.getCachedScheduleSlot('slot1')).thenAnswer((_) async => slot);
      when(mockLocalDataSource.getCachedVehicleAssignments('slot1')).thenAnswer((_) async => [vehicleAssignment]);
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.assignChildToVehicle('slot1', 'va1', 'c_new'))
        .thenAnswer((_) async => Result.ok(null));
      
      // Act
      final result = await repository.assignChildToVehicle(
        slotId: 'slot1',
        vehicleAssignmentId: 'va1',
        childId: 'c_new',
      );
      
      // Assert
      expect(result.isOk, true);
      
      // Verify API called (pre-check passed)
      verify(mockRemoteDataSource.assignChildToVehicle('slot1', 'va1', 'c_new')).called(1);
    });
    
    // NEW: Override tests
    test('allows assignment up to override capacity', () async {
      final slot = ScheduleSlot(id: 'slot1', groupId: 'g1');
      final vehicleAssignment = VehicleAssignment(
        id: 'va1',
        capacity: 4,
        seatOverride: 6,  // Override
        childAssignments: List.generate(5, (i) => ChildAssignment(id: 'ca$i', childId: 'c$i')), // 5/6
      );
      
      when(mockLocalDataSource.getCachedScheduleSlot('slot1')).thenAnswer((_) async => slot);
      when(mockLocalDataSource.getCachedVehicleAssignments('slot1')).thenAnswer((_) async => [vehicleAssignment]);
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.assignChildToVehicle('slot1', 'va1', 'c_new'))
        .thenAnswer((_) async => Result.ok(null));
      
      final result = await repository.assignChildToVehicle(
        slotId: 'slot1',
        vehicleAssignmentId: 'va1',
        childId: 'c_new',
      );
      
      // Should succeed (5 < 6)
      expect(result.isOk, true);
      verify(mockRemoteDataSource.assignChildToVehicle('slot1', 'va1', 'c_new')).called(1);
    });
  });
}
```

---

## 🔄 Edge Cases - Handling

### Edge Case #1: Concurrent Assignment (Race Condition)

**Scenario**: User A et User B assignent enfants au même véhicule simultanément

**Detection**: Repository pre-check trouve plus d'assignments que UI pense

**UI Flow**:
```dart
// Repository détecte race condition
return Result.err(
  ApiFailure(
    code: 'schedule.capacity_exceeded_race',
    message: 'Vehicle capacity exceeded. Another parent assigned while you were editing.',
  ),
);

// Presentation layer catches
_syncService.onFailure.listen((error) {
  if (error.code == 'schedule.capacity_exceeded_race') {
    // Show dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('⚠️ Conflict Detected'),
        content: Text(
          'Someone else assigned a child to this vehicle while you were editing. '
          'The vehicle is now at full capacity.\n\n'
          'Would you like to refresh and see the latest assignments?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _refreshSlotData(); // Re-fetch from server
            },
            child: Text('Refresh'),
          ),
        ],
      ),
    );
  }
});
```

---

### Edge Case #2: Offline Queue Re-Validation

**Scenario**: User assigne offline → Vehicle capacity changée pendant offline

**Solution**: Re-validate AVANT d'envoyer pending operations

```dart
// OfflineSyncService.processPendingOperations()
Future<void> processPendingOperations() async {
  final pending = await _localDataSource.getPendingOperations();
  
  for (final op in pending) {
    if (op['type'] == 'assign_child') {
      // 1. RE-FETCH current state from server
      final freshSlot = await _remoteDataSource.getScheduleSlot(op['slotId']);
      
      // 2. RE-VALIDATE with fresh data
      final vehicleAssignments = freshSlot.vehicleAssignments ?? [];
      final vehicleAssignment = vehicleAssignments.firstWhere((va) => va.id == op['vehicleAssignmentId']);
      
      final currentAssignments = vehicleAssignment.childAssignments?.length ?? 0;
      if (currentAssignments >= vehicleAssignment.effectiveCapacity) {  // ← UPDATED
        // Capacity changed while offline! Reject operation
        await _localDataSource.markOperationAsFailed(
          op['id'],
          op['retryCount'] + 1,
          'Vehicle capacity exceeded. Cannot sync offline assignment.',
        );
        
        // Show notification to user
        _showNotification(
          'Assignment Failed',
          'Could not assign child - vehicle is now full. Please review assignments.',
        );
        continue; // Skip this operation
      }
      
      // 3. Validation passed, proceed with API call
      await _executeOperation(op);
    }
  }
}
```

---

### Edge Case #3: Vehicle Capacity Changed (WebSocket Event)

**Scenario**: Admin change vehicle capacity pendant que parent assigne enfants

**Solution**: WebSocket event → Force UI refresh

```dart
// RealtimeScheduleNotifier
void _initializeWebSocketListeners() {
  _webSocketService.on('vehicle.capacity_updated', (data) {
    final vehicleId = data['vehicleId'];
    final newCapacity = data['capacity'];
    
    // 1. Update local cache
    _localDataSource.updateVehicleCapacity(vehicleId, newCapacity);
    
    // 2. Check if current sheet is open for this vehicle
    if (_currentVehicleId == vehicleId) {
      // 3. Force re-validation of current assignments
      _revalidateCurrentAssignments(vehicleId, newCapacity);
      
      // 4. Show banner to user
      _showBanner(
        'Vehicle capacity changed to $newCapacity seats. Please review assignments.',
        type: BannerType.warning,
      );
    }
  });
}

void _revalidateCurrentAssignments(String vehicleId, int newCapacity) {
  final assigned = _assignedChildren.where((c) => c.assignedVehicleId == vehicleId).toList();
  
  if (assigned.length > newCapacity) {
    // NOW over-capacity due to capacity decrease!
    setState(() {
      _hasCapacityViolation = true; // Disable save button
      _violationMessage = 'Vehicle capacity reduced. Remove ${assigned.length - newCapacity} child(ren).';
    });
  }
}
```

---

### Edge Case #4: Corrupted State Detection

**Scenario**: Cache shows 6/5 assignments (shouldn't be possible but defensive)

**Detection**: On mount, check all vehicles for violations

```dart
class ChildAssignmentSheet extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    _detectCorruptedState();
  }
  
  void _detectCorruptedState() {
    final assigned = widget.assignedChildren.where((c) => c.assignedVehicleId == widget.vehicle.id).toList();
    
    if (assigned.length > widget.vehicle.effectiveCapacity) {  // ← UPDATED
      // CORRUPTED STATE DETECTED!
      ErrorLogger.logError(
        'ChildAssignmentSheet',
        'Corrupted state: Vehicle ${widget.vehicle.id} has ${assigned.length}/${widget.vehicle.effectiveCapacity} assignments',
        details: {
          'vehicleId': widget.vehicle.id,
          'capacity': widget.vehicle.capacity,
          'effectiveCapacity': widget.vehicle.effectiveCapacity,
          'seatOverride': widget.vehicle.seatOverride,
          'assigned': assigned.length,
          'children': assigned.map((c) => c.id).toList(),
        },
      );
      
      // Show error dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text('⚠️ Data Issue Detected'),
            content: Text(
              'This vehicle has more children assigned than its capacity allows. '
              'This may have occurred due to a sync error.\n\n'
              'Please refresh the data to fix this issue.'
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _forceRefreshFromServer(); // Clear cache, re-fetch
                },
                child: Text('Refresh Data'),
              ),
            ],
          ),
        );
      });
    }
  }
}
```

---

## 📊 Phase Breakdown (UPDATED)

### Phase 1: Core Architecture - 16.5-22.5h (UPDATED +30min)

**1.1: LocalDataSource Implementation (8-12h)** ✓ Unchanged

**1.2: Repository Cache-First (6-8h)** ✓ Unchanged

**1.3: Domain Validation Use Case (2h)** ← EXISTING
- Créer `ValidateChildAssignmentUseCase`
- Logic: Check capacity, check duplicate assignment
- Return `Result<void, ScheduleFailure>`
- Tests: 4 test cases (under, at, over, already assigned)

**1.4: Add Effective Capacity Getter (30min)** ← NEW

**Your Task**: Add computed property for effective capacity (considers seat override)

**CRITICAL**: Validation MUST use effective capacity, not default capacity

**Implementation**:
```dart
// File: /workspace/mobile_app/lib/features/schedule/domain/entities/vehicle_assignment.dart
// ADD after existing fields:

class VehicleAssignment extends Equatable {
  final int? seatOverride;
  final int capacity;
  // ... other fields
  
  /// Effective capacity considering seat override
  /// Business rule: Override takes precedence over default capacity
  /// Used for validation and UI display
  int get effectiveCapacity => seatOverride ?? capacity;
  
  /// Whether a seat override is currently active
  bool get hasOverride => seatOverride != null;
  
  /// Display string for capacity with override indicator
  String get capacityDisplay {
    if (hasOverride) {
      return '$effectiveCapacity seats (override from $capacity)';
    }
    return '$effectiveCapacity seats';
  }
}
```

**Tests Required**:
```dart
// In vehicle_assignment_test.dart:
test('effectiveCapacity returns override when set', () {
  final assignment = VehicleAssignment(
    capacity: 4,
    seatOverride: 6,
    // ...
  );
  expect(assignment.effectiveCapacity, 6);
  expect(assignment.hasOverride, true);
});

test('effectiveCapacity returns default when no override', () {
  final assignment = VehicleAssignment(
    capacity: 4,
    seatOverride: null,
    // ...
  );
  expect(assignment.effectiveCapacity, 4);
  expect(assignment.hasOverride, false);
});
```

**Validation Gate**: `flutter test test/unit/domain/entities/vehicle_assignment_test.dart`

**Effort**: Phase 1 total: **16.5-22.5h**

---

### Phase 2: State Management - 3-4h (UNCHANGED)

**2.1: Auto-dispose Providers (1-2h)** ✓ Unchanged

**2.2: Validation Provider (1h)** ← EXISTING
- Créer `validateChildAssignmentProvider`
- Inject `ValidateChildAssignmentUseCase`
- Use dans `ChildAssignmentSheet`

**2.3: Family Providers (1h)** ✓ Unchanged

**Validation Gate**:
```bash
flutter test test/presentation/providers/
flutter analyze lib/features/schedule/presentation/providers/
```

---

### Phase 3: Mobile UX + Validation - 11-16h (EXPANDED +3-4h)

**3.1: PageView Navigation (2-3h)** ← FROM UX DESIGN
- Implement `ScheduleWeekView` with PageView
- Horizontal swipe entre semaines
- Week indicator with date picker
- Pull-to-refresh sync

**3.2: Bottom Sheets (3-4h)** ← FROM UX DESIGN
- `VehicleAssignmentSheet` (Level 2) - DraggableScrollableSheet 60%
- `ChildAssignmentSheet` (Level 3) - Expand to 90%
- Back navigation Level 3 → Level 2 → Level 1
- Drag handle, swipe-to-dismiss

**3.3: Client-Side Validation UI (3-4h)** ← UPDATED
- Implement `_canAssignChild()` logic in ChildAssignmentSheet
- **UPDATED**: Use `vehicle.effectiveCapacity` not `vehicle.capacity`
- Disable checkbox when vehicle full
- Real-time capacity bar (green → orange → amber)
- **UPDATED**: Show override indicator in capacity bar
- Save button disabled on over-capacity
- Error banner on violations
- Tooltip "Vehicle full" on disabled rows

**Code Example - Updated Capacity Bar**: (See Règle #2 above)

**3.4: Touch Targets + Accessibility (2-3h)** ← FROM UX DESIGN
- All touch targets 48dp minimum
- Haptic feedback: light (swipe), medium (toggle), heavy (conflict)
- Semantic labels: VoiceOver/TalkBack
- High contrast mode support
- Screen reader announcements on capacity changes

**3.5: Seat Override Management UI (3-4h)** ← NEW

**Your Task**: Add mobile-first UI to SET seat override for vehicle assignments

**Pattern**: Follow web frontend inline adjustment (VehicleSelectionModal.tsx lines 348-381)

**Location**: VehicleAssignmentSheet (Level 2) - After vehicle selection

**Implementation**:

**Step 1**: Add state management (30min)
```dart
class _VehicleAssignmentSheetState extends State<VehicleAssignmentSheet> {
  final Map<String, int?> _seatOverrides = {};  // vehicleId → override value
  final Map<String, TextEditingController> _overrideControllers = {};
  
  @override
  void dispose() {
    for (final controller in _overrideControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
  
  void _updateOverride(String vehicleId, int? override) {
    setState(() {
      _seatOverrides[vehicleId] = override;
    });
  }
}
```

**Step 2**: Add override UI in VehicleCard (2h)
```dart
Widget _buildVehicleCard(VehicleAssignment vehicle) {
  final controller = _overrideControllers.putIfAbsent(
    vehicle.id,
    () => TextEditingController(text: vehicle.seatOverride?.toString()),
  );
  final currentOverride = _seatOverrides[vehicle.id] ?? vehicle.seatOverride;
  
  return Card(
    child: Column(
      children: [
        // Existing vehicle info
        ListTile(
          leading: Icon(Icons.directions_car, size: 32),
          title: Text(vehicle.vehicleName, style: TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(vehicle.driverName ?? 'No driver assigned'),
        ),
        
        // NEW: Seat override control (mobile-first)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Seats for this trip:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  // Number input
                  Container(
                    width: 80,
                    height: 48,  // ← 48dp touch target
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: '${vehicle.capacity}',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        suffixText: ' seats',
                        suffixStyle: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      onChanged: (value) {
                        final override = int.tryParse(value);
                        if (override != null && override >= 0 && override <= 50) {
                          _updateOverride(vehicle.id, override);
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '(default: ${vehicle.capacity})',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Spacer(),
                  // Reset button
                  if (currentOverride != null && currentOverride != vehicle.capacity)
                    IconButton(
                      icon: Icon(Icons.refresh, size: 20),
                      color: Colors.orange[700],
                      tooltip: 'Reset to default',
                      constraints: BoxConstraints(minWidth: 44, minHeight: 44),  // ← Touch target
                      onPressed: () {
                        controller.clear();
                        _updateOverride(vehicle.id, null);
                      },
                    ),
                ],
              ),
              SizedBox(height: 4),
              // Helper text
              Text(
                '💡 Adjust if fewer seats due to cargo, equipment, or child seats',
                style: TextStyle(fontSize: 11, color: Colors.grey[600], fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        
        // Existing capacity bar (now with override support)
        Padding(
          padding: EdgeInsets.all(16),
          child: _buildCapacityBar(
            vehicle.copyWith(seatOverride: currentOverride),  // Apply pending override
            _assignedChildren,
          ),
        ),
        
        // Action button
        Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: ElevatedButton(
            onPressed: () => _openChildAssignmentSheet(
              vehicle.copyWith(seatOverride: currentOverride),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 48),  // ← Touch target
            ),
            child: Text('Manage Children'),
          ),
        ),
      ],
    ),
  );
}
```

**Step 3**: Save override to backend (1h)
```dart
Future<void> _saveVehicleWithOverride(VehicleAssignment vehicle, int? override) async {
  setState(() => _isLoading = true);
  
  try {
    // Call API to update seat override
    final result = await ref.read(scheduleRepositoryProvider).updateSeatOverride(
      vehicleAssignmentId: vehicle.id,
      seatOverride: override,
    );
    
    result.when(
      ok: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(override != null 
              ? 'Seat override set to $override seats'
              : 'Seat override removed'),
            backgroundColor: Colors.green,
          ),
        );
      },
      err: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update seat override: ${failure.message}'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  } finally {
    setState(() => _isLoading = false);
  }
}
```

**Step 4**: Add validation (30min)
- Validate: 0 ≤ override ≤ 50 (VEHICLE_CONSTRAINTS.MAX_CAPACITY)
- Warning if override < current assignments
- Disable save if invalid

**Acceptance Criteria**:
- ✅ TextField for seat override (80dp width, 48dp height)
- ✅ Shows default capacity hint
- ✅ Reset button visible when override differs from default
- ✅ Helper text explains when to adjust
- ✅ Capacity bar updates in real-time with pending override
- ✅ Orange indicator when override active
- ✅ Saves to backend on apply
- ✅ Validation prevents invalid values

**Tests Required**:
- Widget test: TextField appears and is editable
- Widget test: Reset button appears when override set
- Widget test: Capacity bar updates with override
- Integration test: Save override to backend
- Integration test: Validation rejects override > 50

**Validation Gate**:
```bash
flutter test test/presentation/widgets/child_assignment_sheet_test.dart
flutter test test/presentation/widgets/vehicle_assignment_sheet_test.dart
flutter test test/presentation/pages/schedule_page_test.dart
flutter analyze lib/features/schedule/presentation/
```

**Effort**: Phase 3 total: **11-16h**

---

### Phase 4: Testing & Coverage - 8-12h (EXPANDED +1-2h)

**4.1: Use Case Validation Tests (2h)** ← EXISTING
- `validate_child_assignment_test.dart`
- Test all validation rules
- Test edge cases (concurrent, offline)
- **ADDED**: Test override scenarios

**4.2: Widget Validation Tests (2h)** ← EXISTING
- Checkbox disabled state
- Capacity bar updates
- Save button disabled
- Tooltip visibility
- **ADDED**: Override indicator tests

**4.3: Integration Validation Tests (2h)** ← EXISTING
- End-to-end assignment flow with capacity checks
- Race condition simulation
- Offline queue re-validation

**4.4: Coverage Report (1h)** ✓ Unchanged
- Generate coverage
- Ensure 90%+ (95% domain, 90% data, 90% presentation)

**4.5: Seat Override Test Coverage (1-2h)** ← NEW

**Your Task**: Comprehensive testing for seat override functionality

**Test Files**:

**1. Domain Tests** (`test/unit/domain/entities/vehicle_assignment_test.dart`):
```dart
group('Seat Override - Effective Capacity', () {
  test('effectiveCapacity uses override when set', () {
    final assignment = VehicleAssignment(capacity: 4, seatOverride: 6);
    expect(assignment.effectiveCapacity, 6);
  });
  
  test('effectiveCapacity uses default when no override', () {
    final assignment = VehicleAssignment(capacity: 4, seatOverride: null);
    expect(assignment.effectiveCapacity, 4);
  });
  
  test('hasOverride returns true when override set', () {
    final assignment = VehicleAssignment(capacity: 4, seatOverride: 6);
    expect(assignment.hasOverride, true);
  });
  
  test('hasOverride returns false when no override', () {
    final assignment = VehicleAssignment(capacity: 4, seatOverride: null);
    expect(assignment.hasOverride, false);
  });
});
```

**2. Validation Tests** (`test/unit/domain/usecases/validate_child_assignment_test.dart`):
```dart
group('Seat Override - Validation', () {
  test('allows assignment up to override capacity', () async {
    final vehicle = VehicleAssignment(capacity: 4, seatOverride: 6);
    final assigned = List.generate(5, (i) => Child(id: 'c$i', assignedVehicleId: vehicle.id));
    final newChild = Child(id: 'c6', name: 'New Child');
    
    final result = await usecase(
      ValidateChildAssignmentParams(
        vehicle: vehicle,
        child: newChild,
        currentlyAssigned: assigned,
      ),
    );
    
    expect(result.isOk, true);  // 5 < 6, should succeed
  });
  
  test('rejects assignment beyond override capacity', () async {
    final vehicle = VehicleAssignment(capacity: 8, seatOverride: 6);
    final assigned = List.generate(6, (i) => Child(id: 'c$i', assignedVehicleId: vehicle.id));
    final newChild = Child(id: 'c7', name: 'New Child');
    
    final result = await usecase(
      ValidateChildAssignmentParams(
        vehicle: vehicle,
        child: newChild,
        currentlyAssigned: assigned,
      ),
    );
    
    expect(result.isErr, true);  // 6 >= 6, should fail
    result.when(
      ok: (_) => fail('Should fail validation'),
      err: (failure) {
        expect(failure.code, 'schedule.capacity_exceeded');
        expect(failure.details!['capacity'], 6);  // Shows override capacity
      },
    );
  });
});
```

**3. Widget Tests** (`test/presentation/widgets/vehicle_assignment_sheet_test.dart`):
```dart
group('Seat Override UI', () {
  testWidgets('displays seat override input field', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: VehicleAssignmentSheet(vehicle: testVehicle),
    ));
    
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Seats for this trip:'), findsOneWidget);
  });
  
  testWidgets('capacity bar updates when override set', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: VehicleAssignmentSheet(vehicle: testVehicle),
    ));
    
    // Enter override
    await tester.enterText(find.byType(TextField), '6');
    await tester.pumpAndSettle();
    
    // Check capacity bar uses override
    expect(find.text('2/6 seats'), findsOneWidget);  // 2 assigned, 6 override
    expect(find.text('Override: 6 seats'), findsOneWidget);
  });
  
  testWidgets('reset button clears override', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: VehicleAssignmentSheet(vehicle: testVehicle),
    ));
    
    await tester.enterText(find.byType(TextField), '6');
    await tester.pumpAndSettle();
    
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();
    
    expect(find.text('2/4 seats'), findsOneWidget);  // Back to default
  });
});
```

**4. Integration Tests** (`test/integration/schedule/seat_override_integration_test.dart`):
```dart
testWidgets('end-to-end seat override flow', (tester) async {
  // 1. Open vehicle assignment sheet
  // 2. Set seat override to 6
  // 3. Verify capacity bar shows 6
  // 4. Open child assignment
  // 5. Assign 5 children (should succeed)
  // 6. Try to assign 6th child (checkbox enabled)
  // 7. Try to assign 7th child (checkbox disabled)
  // 8. Save changes
  // 9. Verify override saved to backend
});
```

**Validation Gate**:
```bash
flutter test test/unit/domain/entities/vehicle_assignment_test.dart
flutter test test/unit/domain/usecases/validate_child_assignment_test.dart
flutter test test/presentation/widgets/vehicle_assignment_sheet_test.dart
flutter test test/integration/schedule/
```

**4.6: Golden Tests (2-3h)** ✓ Unchanged

**Validation Finale**:
```bash
flutter test --coverage
lcov --summary coverage/lcov.info | grep "lines......: 9[0-9]"
flutter analyze
# SUCCESS: 90%+ coverage, zero issues
```

**Effort**: Phase 4 total: **8-12h**

---

## 📊 Updated Effort Summary

| Phase | Original | Added | New Total |
|-------|----------|-------|-----------|
| Phase 1: Core Architecture | 16-22h | +30min | **16.5-22.5h** |
| Phase 2: State Management | 3-4h | 0 | **3-4h** |
| Phase 3: Mobile UX + Validation | 8-12h | +3-4h | **11-16h** |
| Phase 4: Testing & Coverage | 7-10h | +1-2h | **8-12h** |
| **TOTAL** | **34-48h** | **+5-7h** | **38.5-54.5h** |

**New Estimate**: **39-55 hours** (~5-7 days full-time)

---

## 🎯 Success Criteria (UPDATED)

### Techniques
- ✅ 90%+ code coverage (95% domain, 90% data, 90% presentation)
- ✅ Zero flutter analyze issues
- ✅ `ScheduleLocalDataSourceImpl` 100% implémenté
- ✅ Repository Cache-First reads / Server-First writes
- ✅ DTOs centralisés `/lib/core/network/models/` ✓
- ✅ Auto-dispose providers
- ✅ **Client-side validation prevents over-capacity**
- ✅ **Checkbox disabled when vehicle full**
- ✅ **Real-time capacity bar updates**
- ✅ **Save button blocked on violations**
- ✅ **NEW**: VehicleAssignment has `effectiveCapacity` getter
- ✅ **NEW**: VehicleAssignment has `hasOverride` getter
- ✅ **NEW**: Validation uses `effectiveCapacity` not `capacity`
- ✅ **NEW**: Tests verify getter logic
- ❌ Tests arch_unit (SKIP - cassés)

### UX
- ✅ Schedule loads < 2s (cache-first)
- ✅ PageView swipe fluide entre semaines
- ✅ Bottom sheets Level 2/3 avec transitions smooth
- ✅ Touch targets ≥ 48dp (WCAG 2.2 AA)
- ✅ Haptic feedback (light/medium/heavy)
- ✅ Offline queue fonctionne
- ✅ **User CANNOT assign child when vehicle full**
- ✅ **Visual feedback clear (progress bar, tooltip)**
- ✅ **NEW**: Capacity bar shows `effectiveCapacity`
- ✅ **NEW**: Capacity bar shows override indicator (orange)
- ✅ **NEW**: UI to SET seat override in VehicleAssignmentSheet
- ✅ **NEW**: TextField 80dp × 48dp (touch target)
- ✅ **NEW**: Reset button appears when override differs
- ✅ **NEW**: Helper text explains when to adjust
- ✅ **NEW**: Real-time capacity bar update with override
- ✅ **NEW**: Backend save on apply

### Edge Cases
- ✅ **Race condition handled (conflict dialog)**
- ✅ **Offline queue re-validates before sync**
- ✅ **WebSocket capacity change triggers re-validation**
- ✅ **Corrupted state detected and recovered**

### Seat Override Specific
- ✅ **NEW**: Domain tests for effectiveCapacity getter
- ✅ **NEW**: Validation tests with override scenarios
- ✅ **NEW**: Widget tests for override UI
- ✅ **NEW**: Integration tests for end-to-end flow
- ✅ **NEW**: 95%+ coverage validation use case
- ✅ **NEW**: 90%+ coverage capacity bar widget

---

## 🚀 Actions Immédiates

### Jour 1 - Phase 1 Start (8h)
1. Branch: `git checkout -b refactor/schedule-cache-validation-override`
2. **Matin (4h)**:
   - Implémenter `ScheduleLocalDataSourceImpl` (méthodes cache)
   - **NEW**: Add `effectiveCapacity` getter to VehicleAssignment
   - Tests unitaires LocalDataSource + VehicleAssignment
3. **Après-midi (4h)**:
   - Créer `ValidateChildAssignmentUseCase`
   - **UPDATED**: Use `effectiveCapacity` in validation
   - Tests validation use case (6 cas including override)
   - Validation: `flutter test test/unit/domain/`

### Jour 2 - Phase 1 Finish (8h)
4. **Matin (4h)**:
   - Refactorer `ScheduleRepositoryImpl` (inject LocalDataSource)
   - Pattern Cache-First reads
5. **Après-midi (4h)**:
   - Pattern Server-First writes avec pre-validation
   - **UPDATED**: Pre-validation uses `effectiveCapacity`
   - Tests repository avec cache mock
   - Validation: `flutter test test/unit/data/`

### Jour 3 - Phase 2 + 3 Start (8h)
6. **Matin (2h)**: Phase 2
   - Auto-dispose providers
   - Validation provider
7. **Après-midi (6h)**: Phase 3.1-3.2
   - PageView navigation
   - Bottom Sheets Level 2/3
   - **NEW**: Add state for seat override editing

### Jour 4 - Phase 3 Continue (8h)
8. **Full Day**:
   - Client-side validation UI (checkbox disable, capacity bar)
   - **UPDATED**: Use `effectiveCapacity` in all validation
   - **UPDATED**: Show override indicator in capacity bar
   - Touch targets + accessibility
   - Haptic feedback
   - Validation: `flutter test test/presentation/widgets/`

### Jour 5 - Phase 3 Finish + 4 Start (8h)
9. **Matin (4h)**: Phase 3.5
   - **NEW**: Seat override UI in VehicleAssignmentSheet
   - TextField for override input
   - Reset button and helper text
   - Save to backend
10. **Après-midi (4h)**: Phase 4 Start
    - Tests validation (use case, widget)
    - **NEW**: Tests override scenarios

### Jour 6 - Phase 4 Finish (8h)
11. **Matin (4h)**:
    - **NEW**: Integration tests for seat override
    - Coverage report (90%+)
12. **Après-midi (4h)**:
    - Golden tests update
    - Final validation: `flutter test --coverage && flutter analyze`

---

## 📚 Références Code

### Pattern Validation (À SUIVRE)
- Use Case: `/workspace/mobile_app/lib/features/schedule/domain/usecases/validate_child_assignment.dart` (À CRÉER)
- Entity Getter: `/workspace/mobile_app/lib/features/schedule/domain/entities/vehicle_assignment.dart` (À MODIFIER)
- Checkbox Logic: Dans `ChildAssignmentSheet._buildChildRow()`
- Capacity Bar: Dans `VehicleCard._buildCapacityBar()`
- Save Button: Dans `ChildAssignmentSheet._buildSaveButton()`
- **NEW**: Override UI: Dans `VehicleAssignmentSheet._buildVehicleCard()`

### Pattern Cache-First (EXEMPLES EXISTANTS)
- Family: `/workspace/mobile_app/lib/features/family/data/repositories/family_repository_impl.dart`
- Pattern: Cache check → API fetch → Cache update

### Pattern Seat Override (EXEMPLES EXISTANTS)
- Web Frontend: `/workspace/frontend/src/components/VehicleSelectionModal.tsx` (lines 348-381)
- Backend Validation: `/workspace/backend/src/services/ScheduleSlotValidationService.ts` (lines 8-12)
- Mobile Family: `/workspace/mobile_app/lib/features/family/presentation/widgets/seat_override_widget.dart` (lines 251-451)
- Mobile Entity: `/workspace/mobile_app/lib/core/domain/entities/schedule/vehicle_assignment.dart` (HAS seatOverride field)
- Mobile DTO: `/workspace/mobile_app/lib/core/network/models/schedule/vehicle_assignment_dto.dart` (HAS seatOverride)

### Pattern UX Mobile-First (DESIGN VALIDÉ)
- Memory: `schedule_mobile_ux_design_2025`
- PageView navigation, Bottom Sheets, Touch targets 48dp

### Pattern Hive (EXISTANT)
- Orchestrator: `/workspace/mobile_app/lib/core/storage/hive_orchestrator.dart`
- Pattern: `Box<Map>` avec encryption

---

**Plan validé par**: Audit complet + UX research + User validation requirement + Seat override integration
**Date**: 2025-10-09
**Statut**: PRODUCTION READY
**Effort Total**: 38.5-54.5 heures (4 phases avec validation proactive + seat override)
**Principe Clé**: **L'utilisateur NE PEUT PAS assigner si véhicule plein** (validation avant, pas après)
**Nouveau**: **Validation utilise effectiveCapacity (considère seat override)**