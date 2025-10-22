# Plan de Migration Schedule Management - Post Audit 2025

**Date**: 2025-10-09 (Après audit complet)
**Statut**: MIGRATION PLAN - Basé sur code existant
**Architecture**: Refactoring vers Cache-First + Mobile-First
**Durée estimée**: 25-36 heures (4 phases)

## 📊 État des Lieux - Audit Complet

### ✅ CE QUI EXISTE ET EST CONFORME (28 fichiers)

#### Domain Layer - CONFORME (13 fichiers)
```
lib/features/schedule/domain/
├── entities/ (13 fichiers) ✅
│   ├── schedule_slot.dart
│   ├── schedule_config.dart
│   ├── vehicle_assignment.dart
│   ├── time_slot.dart
│   ├── weekly_schedule.dart
│   ├── day_of_week.dart
│   ├── child_assignment.dart
│   ├── assignment_status.dart
│   ├── available_child.dart
│   ├── conflict.dart
│   ├── conflict_severity.dart
│   ├── schedule_statistics.dart
│   └── schedule_slot_status.dart
├── repositories/
│   └── schedule_repository.dart ✅ (interface propre)
└── usecases/ (6 fichiers) ✅
    ├── get_weekly_schedule.dart
    ├── assign_vehicle_to_slot.dart
    ├── upsert_schedule_slot.dart
    ├── get_available_children.dart
    ├── check_schedule_conflicts.dart
    └── copy_weekly_schedule.dart
```

**Raison**: Entities pures avec Equatable, pas de JSON. Use cases avec tests complets.

#### DTOs - CENTRALISÉS DANS CORE ✅ (29 fichiers)
```
lib/core/network/models/schedule/ (10 DTOs) ✅
├── schedule_slot_dto.dart + .freezed.dart + .g.dart
├── schedule_config_dto.dart + .freezed.dart + .g.dart
├── vehicle_assignment_dto.dart + .freezed.dart + .g.dart
├── child_assignment_dto.dart + .freezed.dart + .g.dart
├── available_children_dto.dart + .freezed.dart + .g.dart
├── conflict_dto.dart + .freezed.dart + .g.dart
├── schedule_conflicts_dto.dart + .freezed.dart + .g.dart
├── schedule_statistics_dto.dart + .freezed.dart + .g.dart
├── group_weekly_schedule_dto.dart + .freezed.dart + .g.dart
├── time_slot_config_dto.dart + .freezed.dart + .g.dart
└── index.dart
```

**Raison**: Freezed + JSON parfaitement implémenté, centralisé selon pattern du projet.

#### Presentation - PARTIELLEMENT CONFORME (8 fichiers)
```
lib/features/schedule/presentation/
├── widgets/ ✅
│   ├── schedule_slot_widget.dart (component works)
│   ├── vehicle_selection_modal.dart (bottom sheet)
│   ├── child_assignment_modal.dart (bottom sheet)
│   ├── schedule_config_widget.dart (has PageView)
│   └── time_picker.dart (48px touch targets)
├── pages/ ✅
│   ├── schedule_page.dart
│   ├── create_schedule_page.dart
│   └── schedule_configuration_page.dart
└── routing/
    └── schedule_route_factory.dart ✅
```

**Raison**: Structure présente, patterns mobiles partiels, besoin optimisation.

#### Tests - BONNE COUVERTURE DOMAIN (11 fichiers)
```
test/
├── unit/domain/schedule/
│   ├── entities/ (5 test files) ✅
│   └── usecases/ (6 test files) ✅ ~6,322 lignes
└── golden_tests/screens/
    └── schedule_screens_golden_test.dart ✅
```

**Raison**: Use cases bien testés, golden tests présents.

---

### ❌ CE QUI DOIT ÊTRE MODIFIÉ (12 fichiers)

#### 🔴 BLOCKER #1: LocalDataSource - IMPLÉMENTATION VIDE
**Fichier**: `lib/features/schedule/data/datasources/schedule_local_datasource.dart`

**Problème**:
- Interface existe (33 méthodes) ✅
- `ScheduleLocalDataSourceImpl` existe MAIS 100% VIDE ❌
- Tous les méthodes retournent `null`, `[]`, ou `{}` avec `// TODO`
- Lignes 197-437: Stubs complets

**Action Requise**:
```dart
class ScheduleLocalDataSourceImpl implements ScheduleLocalDataSource {
  final Box<Map> _scheduleBox;  // ← À injecter depuis HiveOrchestrator
  
  ScheduleLocalDataSourceImpl(this._scheduleBox);
  
  @override
  Future<void> cacheWeeklySchedule(
    String groupId, 
    String week, 
    List<ScheduleSlot> scheduleSlots,
  ) async {
    final key = 'weekly_${groupId}_$week';
    final dtos = scheduleSlots.map((slot) => 
      ScheduleSlotDto.fromDomain(slot).toJson()
    ).toList();
    await _scheduleBox.put(key, {'slots': dtos, 'timestamp': DateTime.now().millisecondsSinceEpoch});
  }
  
  @override
  Future<List<ScheduleSlot>?> getCachedWeeklySchedule(String groupId, String week) async {
    final key = 'weekly_${groupId}_$week';
    final json = _scheduleBox.get(key);
    if (json == null) return null;
    
    final slots = (json['slots'] as List)
      .map((e) => ScheduleSlotDto.fromJson(e).toDomain())
      .toList();
    return slots;
  }
  
  // + implémenter les 31 autres méthodes
}
```

**Effort**: 8-12 heures (implémentation + tests)

---

#### 🔴 BLOCKER #2: Repository - PAS D'UTILISATION DU CACHE
**Fichier**: `lib/features/schedule/data/repositories/schedule_repository_impl.dart`

**Problème**:
- Repository communique directement avec API via handlers ❌
- Aucune injection de `ScheduleLocalDataSource` ❌
- Architecture Server-Only au lieu de Cache-First ❌

**Action Requise**:
```dart
class ScheduleRepositoryImpl implements GroupScheduleRepository {
  final ScheduleApiClient _apiClient;
  final ScheduleLocalDataSource _localDataSource;  // ← À AJOUTER
  final NetworkInfo _networkInfo;  // ← À AJOUTER
  
  late final handlers.BasicSlotOperationsHandler _basicSlotHandler;
  // ... autres handlers
  
  ScheduleRepositoryImpl(
    this._apiClient, 
    this._localDataSource,  // ← NOUVEAU
    this._networkInfo,      // ← NOUVEAU
  ) {
    _basicSlotHandler = handlers.BasicSlotOperationsHandler(_apiClient);
    // ...
  }
  
  @override
  Future<Result<List<ScheduleSlot>, ApiFailure>> getWeeklySchedule(
    String groupId,
    String week,
  ) async {
    // 1. Cache-First READ pattern
    final cached = await _localDataSource.getCachedWeeklySchedule(groupId, week);
    if (cached != null && !_isCacheExpired(groupId, week)) {
      return Result.ok(cached);
    }
    
    // 2. Fetch from API if cache miss/expired
    if (!await _networkInfo.isConnected) {
      return const Result.err(ApiFailure(code: 'network.no_connection'));
    }
    
    final result = await _basicSlotHandler.getWeeklySchedule(groupId, week);
    
    // 3. Update cache on success
    await result.when(
      ok: (data) async => await _localDataSource.cacheWeeklySchedule(groupId, week, data),
      err: (_) => null,
    );
    
    return result;
  }
  
  @override
  Future<Result<ScheduleSlot, ApiFailure>> upsertScheduleSlot(...) async {
    // Server-First WRITE pattern
    if (!await _networkInfo.isConnected) {
      // Store pending operation
      await _localDataSource.storePendingOperation({
        'type': 'upsert_slot',
        'groupId': groupId,
        'day': day,
        'time': time,
        'week': week,
      });
      return const Result.err(ApiFailure(code: 'network.offline'));
    }
    
    final result = await _basicSlotHandler.upsertScheduleSlot(groupId, day, time, week);
    
    // Update cache after server confirms
    await result.when(
      ok: (slot) async => await _localDataSource.cacheScheduleSlot(slot),
      err: (_) => null,
    );
    
    return result;
  }
}
```

**Effort**: 6-8 heures (refactoring + tests)

---

#### 🟡 MEDIUM: Providers - Pas d'Auto-dispose
**Fichier**: `lib/features/schedule/data/providers/schedule_provider.dart`

**Problème**: `StateNotifierProvider` sans `.autoDispose`

**Action**:
```dart
// AVANT (❌)
final scheduleProvider = StateNotifierProvider<ScheduleNotifier, ScheduleState>(
  (ref) => ScheduleNotifier(ref.watch(scheduleRepositoryProvider)),
);

// APRÈS (✅)
final scheduleProvider = StateNotifierProvider.autoDispose
    .family<ScheduleNotifier, ScheduleState, String>(
  (ref, groupId) => ScheduleNotifier(
    ref.watch(scheduleRepositoryProvider),
    groupId,
  ),
);
```

**Effort**: 1-2 heures

---

#### 🟡 MEDIUM: PageView Swipe Navigation
**Fichier**: `lib/features/schedule/presentation/widgets/schedule_grid.dart`

**Problème**: Utilise `ListView.builder` (lignes 66-73) au lieu de `PageView`

**Action**:
```dart
// AVANT (ligne 66)
ListView.builder(
  itemCount: days.length,
  itemBuilder: (context, dayIndex) => _buildDayCard(context, day, timeSlots, isTablet),
)

// APRÈS
PageView.builder(
  controller: _pageController,
  itemCount: days.length,
  onPageChanged: (index) => _onDayChanged(days[index]),
  itemBuilder: (context, dayIndex) => _buildDayCard(
    context, 
    days[dayIndex], 
    timeSlots, 
    isTablet,
  ),
)
```

**Effort**: 2-3 heures

---

#### 🟢 LOW: Touch Targets 44px
**Fichier**: `lib/features/schedule/presentation/widgets/schedule_grid.dart`

**Problème**: Certains boutons < 44px

**Action**: Ajouter `constraints: BoxConstraints(minWidth: 44, minHeight: 44)`

**Effort**: 1 heure

---

#### 🟢 LOW: Handlers (4 fichiers)
**Fichiers**: `lib/features/schedule/data/repositories/handlers/*.dart`

**Problème**: Handlers communiquent directement avec API (pas grave mais redondant)

**Action**: Garder handlers mais déléguer cache au repository

**Effort**: 2 heures

---

### 🆕 CE QUI MANQUE (6 composants)

#### 1. Hive Box Registration
**Fichier**: Mise à jour dans `lib/core/storage/hive_orchestrator.dart`

**Actuellement**:
```dart
class HiveBoxNames {
  static const String familyBox = 'family_box';
  static const String childrenBox = 'children_box';
  static const String vehicleBox = 'vehicle_box';
  static const String scheduleBox = 'schedule_box';  // ← Déjà défini!
  // ...
}
```

**Action**: Vérifier si déjà ouvert, sinon ajouter:
```dart
Box<Map>? _scheduleBox;

Future<void> _openDomainBoxes(bool enableEncryption) async {
  // ...
  _scheduleBox = await Hive.openBox<Map>(
    HiveBoxNames.scheduleBox,
    encryptionCipher: encryptionKey != null ? HiveAesCipher(encryptionKey) : null,
  );
}

Box<Map> get scheduleBox {
  _ensureInitialized();
  return _scheduleBox!;
}
```

**Effort**: 30 minutes

---

#### 2. Cache Metadata Manager
**Fichier**: `lib/features/schedule/data/datasources/cache_metadata_manager.dart` (nouveau)

**Action**:
```dart
class CacheMetadataManager {
  final Box<Map> _scheduleBox;
  
  Future<bool> isCacheExpired(String groupId, String week) async {
    final metadata = await _scheduleBox.get('metadata_${groupId}_$week');
    if (metadata == null) return true;
    
    final timestamp = metadata['timestamp'] as int;
    final now = DateTime.now().millisecondsSinceEpoch;
    const maxAge = Duration(hours: 1).inMilliseconds;
    
    return (now - timestamp) > maxAge;
  }
}
```

**Effort**: 2 heures

---

#### 3. Offline Operations Queue Processor
**Fichier**: `lib/features/schedule/data/services/offline_sync_service.dart` (nouveau)

**Action**:
```dart
class OfflineSyncService {
  final ScheduleLocalDataSource _localDataSource;
  final ScheduleRemoteDataSource _remoteDataSource;
  
  Future<void> processPendingOperations() async {
    final pending = await _localDataSource.getPendingOperations();
    for (final op in pending) {
      try {
        await _executeOperation(op);
        await _localDataSource.removePendingOperation(op['id']);
      } catch (e) {
        await _localDataSource.markOperationAsFailed(op['id'], op['retryCount'] + 1, e.toString());
      }
    }
  }
}
```

**Effort**: 3 heures

---

#### 4. Provider DI Updates
**Fichier**: `lib/features/schedule/data/providers/schedule_provider.dart`

**Action**: Ajouter providers pour nouvelles dépendances
```dart
final scheduleBoxProvider = Provider<Box<Map>>((ref) {
  return ref.watch(hiveOrchestratorProvider).scheduleBox;
});

final scheduleLocalDataSourceProvider = Provider<ScheduleLocalDataSource>((ref) {
  return ScheduleLocalDataSourceImpl(ref.watch(scheduleBoxProvider));
});

final scheduleRepositoryProvider = Provider<GroupScheduleRepository>((ref) {
  return ScheduleRepositoryImpl(
    ref.watch(scheduleApiClientProvider),
    ref.watch(scheduleLocalDataSourceProvider),
    ref.watch(networkInfoProvider),
  );
});
```

**Effort**: 1 heure

---

#### 5. PageController Management
**Fichier**: Mise à jour `lib/features/schedule/presentation/widgets/schedule_grid.dart`

**Action**:
```dart
class _ScheduleGridState extends State<ScheduleGrid> {
  late PageController _pageController;
  int _currentDayIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _currentDayIndex = _getTodayIndex();
    _pageController = PageController(initialPage: _currentDayIndex);
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
```

**Effort**: 30 minutes

---

#### 6. Integration Tests
**Fichier**: `test/integration/schedule/schedule_cache_integration_test.dart` (nouveau)

**Action**: Tester cache-first reads, server-first writes, offline queue

**Effort**: 4 heures

---

## 📋 Plan de Migration - 4 Phases

### Phase 1: Core Architecture - 14-20h (BLOQUANT)
**Priorité**: 🔴 CRITIQUE

1. ✅ Implémenter `ScheduleLocalDataSourceImpl` avec Hive Box<Map> (8-12h)
   - 33 méthodes à implémenter
   - Tests unitaires complets
   - Pattern: `box.put(key, dto.toJson())` + `dto.fromJson(box.get(key))`

2. ✅ Refactorer `ScheduleRepositoryImpl` pour Cache-First (6-8h)
   - Injecter `ScheduleLocalDataSource` + `NetworkInfo`
   - Pattern READ: cache → API → update cache
   - Pattern WRITE: API → update cache (+ queue si offline)
   - Tests repository avec cache mock

3. ✅ Enregistrer Hive box dans orchestrator (30min)
   - Vérifier si `scheduleBox` déjà ouvert
   - Ajouter getter `scheduleBox` si manquant

4. ✅ Tests intégration cache layer (4h)
   - Test cache hit/miss scenarios
   - Test offline queue
   - Test cache expiry

**Validation**:
```bash
flutter test test/unit/data/datasources/schedule_local_datasource_impl_test.dart
flutter test test/unit/data/repositories/schedule_repository_impl_test.dart
flutter test test/integration/schedule/
flutter analyze lib/features/schedule/data/
```

---

### Phase 2: State Management - 3-4h
**Priorité**: 🟡 HIGH

1. ✅ Ajouter `.autoDispose` à tous providers (1-2h)
2. ✅ Ajouter `.family` pour paramètres groupId (1h)
3. ✅ Créer providers DI pour nouvelles dépendances (1h)

**Validation**:
```bash
flutter test test/presentation/providers/
flutter analyze lib/features/schedule/presentation/
```

---

### Phase 3: Mobile UX - 4-6h
**Priorité**: 🟡 MEDIUM

1. ✅ Remplacer ListView par PageView + swipe (2-3h)
2. ✅ Audit touch targets → 44px minimum (1h)
3. ✅ Vérifier `vehicle_sidebar.dart` mobile (1h)
4. ✅ Tests widgets mise à jour (1-2h)

**Validation**:
```bash
flutter test test/presentation/widgets/
# Test manuel: Swipe entre jours fonctionne
```

---

### Phase 4: Testing & Polish - 4-6h
**Priorité**: 🟢 LOW

1. ✅ Expand golden test coverage (2h)
2. ✅ Tests cache expiry scenarios (1h)
3. ✅ Performance testing (1h)
4. ✅ Coverage report 90%+ (1h)

**Validation Finale**:
```bash
flutter test --coverage
lcov --summary coverage/lcov.info | grep "lines......: 9[0-9]"
flutter analyze
# SUCCESS: 90%+ coverage, zero issues
```

---

## 🎯 Success Criteria

### Techniques
- ✅ 90%+ code coverage (95% domain ✓, 90% data, 90% presentation)
- ✅ Zero flutter analyze issues
- ✅ `ScheduleLocalDataSourceImpl` 100% implémenté avec tests
- ✅ Repository utilise Cache-First reads / Server-First writes
- ✅ DTOs centralisés dans `/lib/core/network/models/` ✓
- ✅ Auto-dispose providers
- ❌ Tests arch_unit (SKIP - cassés, non-bloquant)

### UX
- ✅ Schedule loads < 2s (cache-first)
- ✅ PageView swipe fluide
- ✅ Touch targets ≥ 44px
- ✅ Offline queue fonctionne

---

## 📊 Effort Total Estimé

| Phase | Heures | Priorité | Bloquant |
|-------|--------|----------|----------|
| Phase 1: Core Architecture | 14-20h | 🔴 Critique | OUI |
| Phase 2: State Management | 3-4h | 🟡 High | NON |
| Phase 3: Mobile UX | 4-6h | 🟡 Medium | NON |
| Phase 4: Testing & Polish | 4-6h | 🟢 Low | NON |
| **TOTAL** | **25-36h** | | |

---

## 🚨 Risques Identifiés

### Risque #1: Hive Box Migration
**Impact**: HIGH  
**Probabilité**: MEDIUM  
**Mitigation**: Vérifier que `scheduleBox` n'est pas déjà ouvert avec autre structure

### Risque #2: Breaking Repository Changes
**Impact**: HIGH  
**Probabilité**: LOW  
**Mitigation**: Tests complets avant/après, versionner API calls

### Risque #3: Performance Degradation
**Impact**: MEDIUM  
**Probabilité**: LOW  
**Mitigation**: Benchmarks avant/après, cache sizing

---

## 📁 Références Code Existant

### Pattern LocalDataSource (À SUIVRE)
- Interface: `/workspace/mobile_app/lib/features/schedule/data/datasources/schedule_local_datasource.dart:1-196` ✅
- Impl (vide): Lignes 197-437 (À REMPLIR)

### Pattern Repository Cache-First (EXEMPLES)
- Family: `/workspace/mobile_app/lib/features/family/data/repositories/family_repository_impl.dart`
- Pattern: Cache check → API fetch → Cache update

### Pattern Hive Orchestrator
- Box registration: `/workspace/mobile_app/lib/core/storage/hive_orchestrator.dart`
- Pattern: `Box<Map>` avec encryption, getters type-safe

### DTOs Centralisés
- Location: `/workspace/mobile_app/lib/core/network/models/schedule/` ✅
- Pattern: Freezed + JSON, `fromDomain()` / `toDomain()`

---

## 🎬 Actions Immédiates

### Jour 1 - Matin (4h)
1. Branch: `git checkout -b refactor/schedule-cache-layer`
2. Implémenter `ScheduleLocalDataSourceImpl`:
   - Injection `Box<Map> _scheduleBox`
   - Méthodes cache: `cacheWeeklySchedule()`, `getCachedWeeklySchedule()`
   - Méthodes pending ops: `storePendingOperation()`, `getPendingOperations()`
3. Tests unitaires LocalDataSource

### Jour 1 - Après-midi (4h)
4. Refactorer `ScheduleRepositoryImpl`:
   - Injection dependencies
   - Pattern Cache-First reads
   - Pattern Server-First writes
5. Tests repository

### Jour 2 - Matin (3h)
6. Provider updates: `.autoDispose`, `.family`
7. Tests providers

### Jour 2 - Après-midi (3h)
8. PageView migration
9. Touch targets audit
10. Tests widgets

---

**Plan validé par**: Audit complet + Principle 0
**Date**: 2025-10-09
**Statut**: PRÊT POUR MIGRATION
**Effort Total**: 25-36 heures (4 phases)
