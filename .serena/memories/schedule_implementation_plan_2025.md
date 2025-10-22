# Plan d'Implémentation Schedule Management - Version Finale

**Date**: 2025-10-08 (Mise à jour finale)
**Statut**: VALIDÉ - Prêt pour exécution
**Architecture**: Feature Schedule SÉPARÉE avec persistance dédiée
**Durée**: 16-18 jours

## Décisions Architecturales Confirmées

### ADR-001: Feature Schedule Séparée
**Statut**: ACCEPTÉ
**Raison**: 
- Schedule = Domaine distinct (planning hebdomadaire)
- Groups = Configuration (time slots disponibles)
- Dépendance: Schedule → Groups (unidirectionnelle)

### ADR-002: Classe Persistance Dédiée
**Statut**: ACCEPTÉ
**Implémentation**:
- `ScheduleLocalDataSource` (interface)
- `ScheduleLocalDataSourceImpl` (implémentation Hive Box<Map>)
- DTOs pour conversion Domain ↔ JSON

### ADR-003: Pas de @HiveType
**Statut**: ACCEPTÉ
**Raison**: Projet n'utilise pas @HiveType, utilise `Box<Map>` avec JSON

### ADR-004: Skip Tests arch_unit
**Statut**: TEMPORAIRE
**Raison**: Tests arch_unit cassés, non-bloquant pour feature

## Architecture Complète

```
lib/features/schedule/
├── domain/
│   ├── entities/
│   │   ├── schedule_slot.dart
│   │   ├── weekly_schedule.dart
│   │   ├── schedule_config.dart
│   │   ├── day_of_week.dart
│   │   └── vehicle_assignment.dart
│   ├── repositories/
│   │   └── schedule_repository.dart (interface)
│   ├── usecases/
│   │   ├── get_weekly_schedule.dart
│   │   ├── create_schedule_slot.dart
│   │   ├── assign_vehicle_to_slot.dart
│   │   └── assign_children_to_vehicle.dart
│   └── failures/
│       └── schedule_failure.dart
│
├── data/
│   ├── datasources/
│   │   ├── schedule_local_datasource.dart (INTERFACE - À CRÉER)
│   │   ├── schedule_local_datasource_impl.dart (IMPL - À CRÉER)
│   │   ├── schedule_remote_datasource.dart
│   │   └── schedule_remote_datasource_impl.dart
│   ├── repositories/
│   │   ├── schedule_repository_impl.dart
│   │   └── handlers/
│   ├── models/ (DTOs avec Freezed)
│   │   ├── weekly_schedule_dto.dart (À CRÉER)
│   │   ├── schedule_slot_dto.dart (À CRÉER)
│   │   └── vehicle_assignment_dto.dart
│   └── providers/
│       └── schedule_datasource_providers.dart (DI - À CRÉER)
│
└── presentation/
    ├── providers/
    │   ├── schedule_notifier.dart (StateNotifier)
    │   └── schedule_providers.dart (granular providers)
    ├── pages/
    │   ├── weekly_schedule_planning_page.dart
    │   ├── schedule_slot_detail_page.dart
    │   └── schedule_configuration_page.dart
    └── widgets/
        ├── mobile/
        │   ├── schedule_week_view.dart
        │   ├── schedule_day_view.dart
        │   ├── time_slot_card_mobile.dart
        │   ├── vehicle_assignment_widget_mobile.dart
        │   └── child_assignment_list_mobile.dart
        └── common/
```

## Relation Groups ↔ Schedule

### Groups possède Configuration
```dart
class Group {
  final String id;
  final ScheduleConfig? scheduleConfig; // Time slots par jour
}
```

### Schedule utilise Configuration
```dart
class ScheduleRepositoryImpl {
  final ScheduleLocalDataSource _localDataSource; // ← Classe dédiée
  final ScheduleRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;
  
  Future<Result<WeeklySchedule, ScheduleFailure>> getWeeklySchedule({
    required String groupId,
    required DateTime weekStart,
  }) async {
    // Cache-first pattern avec datasource dédié
    final cached = await _localDataSource.getCachedSchedule(
      groupId: groupId,
      weekStart: weekStart,
    );
    // ... reste impl
  }
}
```

## Phase 1 Détaillée - Foundation [Jours 1-2]

### Jour 1: Infrastructure Persistance (6h)

**Étape 1**: Créer Interface LocalDataSource (30min)
```dart
// lib/features/schedule/data/datasources/schedule_local_datasource.dart
abstract class ScheduleLocalDataSource {
  Future<void> cacheWeeklySchedule(WeeklySchedule schedule);
  Future<WeeklySchedule?> getCachedSchedule({
    required String groupId,
    required DateTime weekStart,
  });
  Future<void> cacheScheduleSlot(ScheduleSlot slot);
  Future<ScheduleSlot?> getCachedSlot(String slotId);
  Future<void> removeCachedSlot(String slotId);
  Future<void> clearScheduleCache({String? groupId});
  Future<List<WeeklySchedule>> getCachedSchedulesForGroup(String groupId);
}
```

**Étape 2**: Implémenter avec Hive Box<Map> (2h)
```dart
// lib/features/schedule/data/datasources/schedule_local_datasource_impl.dart
class ScheduleLocalDataSourceImpl implements ScheduleLocalDataSource {
  final Box<Map> _scheduleBox;
  
  ScheduleLocalDataSourceImpl(this._scheduleBox);
  
  @override
  Future<void> cacheWeeklySchedule(WeeklySchedule schedule) async {
    final dto = WeeklyScheduleDto.fromDomain(schedule);
    final key = 'weekly_${schedule.groupId}_${schedule.weekStartDate.toIso8601String().split('T')[0]}';
    await _scheduleBox.put(key, dto.toJson());
  }
  
  @override
  Future<WeeklySchedule?> getCachedSchedule({
    required String groupId,
    required DateTime weekStart,
  }) async {
    final key = 'weekly_${groupId}_${weekStart.toIso8601String().split('T')[0]}';
    final json = _scheduleBox.get(key);
    if (json == null) return null;
    
    final dto = WeeklyScheduleDto.fromJson(Map<String, dynamic>.from(json as Map));
    return dto.toDomain();
  }
  
  // ... autres méthodes
}
```

**Étape 3**: Créer DTOs avec Freezed (1.5h)
```bash
# Créer fichiers DTO
touch lib/features/schedule/data/models/weekly_schedule_dto.dart
touch lib/features/schedule/data/models/schedule_slot_dto.dart

# Générer code Freezed + JSON
flutter pub run build_runner build --delete-conflicting-outputs
```

**Étape 4**: Créer Providers DI (30min)
```dart
// lib/features/schedule/data/providers/schedule_datasource_providers.dart
final scheduleBoxProvider = Provider<Box<Map>>((ref) {
  return Hive.box<Map>(HiveBoxNames.scheduleBox);
});

final scheduleLocalDataSourceProvider = Provider<ScheduleLocalDataSource>((ref) {
  return ScheduleLocalDataSourceImpl(ref.watch(scheduleBoxProvider));
});
```

**Étape 5**: Tests LocalDataSource (1.5h)
```bash
touch test/unit/data/datasources/schedule_local_datasource_impl_test.dart
flutter test test/unit/data/datasources/schedule_local_datasource_impl_test.dart
```

### Jour 2: i18n + ScheduleFailure (4h)

**Étape 6**: Ajouter 50 clés i18n (1.5h)
```bash
# Modifier app_en.arb et app_fr.arb
# Générer
flutter pub run intl_utils:generate
```

**Étape 7**: Créer ScheduleFailure (30min)
```dart
// lib/features/schedule/domain/failures/schedule_failure.dart
class ScheduleFailure extends Failure {
  const ScheduleFailure({required String code, String? message, Map<String, dynamic>? details})
    : super(code: code, message: message, details: details);
  
  factory ScheduleFailure.scheduleNotFound() => const ScheduleFailure(
    code: 'schedule.not_found',
    message: 'Schedule not found',
  );
  
  factory ScheduleFailure.scheduleConflict({String? details}) => ScheduleFailure(
    code: 'schedule.conflict',
    message: 'Schedule conflict detected',
    details: details != null ? {'conflict': details} : null,
  );
  
  factory ScheduleFailure.capacityExceeded({required int capacity, required int assigned}) =>
    ScheduleFailure(
      code: 'schedule.capacity_exceeded',
      message: 'Vehicle capacity exceeded',
      details: {'capacity': capacity, 'assigned': assigned},
    );
}
```

**Étape 8**: Validation Phase 1 (30min)
```bash
flutter pub run intl_utils:generate
flutter analyze
flutter test test/unit/data/datasources/
flutter test test/unit/domain/

git commit -m "feat(schedule): Phase 1 - Foundation complete

- Create ScheduleLocalDataSource with Hive Box<Map> persistence
- Add DTOs (WeeklyScheduleDto, ScheduleSlotDto) with Freezed
- Configure DI providers for datasources
- Add 50+ i18n keys for schedule feature
- Create ScheduleFailure hierarchy
- Tests: 90%+ coverage datasource layer

BREAKING CHANGE: None
TEST COVERAGE: 90%+ datasource"
```

## Phase 2-6 (Inchangées)

### Phase 2: Data Layer [Jours 3-6]
- Repository implementation avec LocalDataSource
- Remote datasource validation
- Tests repository (90%+ coverage)

### Phase 3: State Management [Jours 7-9]
- ScheduleNotifier avec StateNotifier pattern
- Providers granulaires
- Tests providers

### Phase 4: Mobile UI [Jours 10-14]
- Widgets mobile-first (PageView, 44px targets)
- Pages (WeeklySchedulePlanningPage, etc.)
- Tests widgets + accessibilité

### Phase 5: Real-time [Jours 15-16] (OPTIONNEL)
- Socket.IO integration
- Conflict detection

### Phase 6: Testing [Jours 10-16] (PARALLÈLE)
- Tests unitaires (95% domain, 90% data)
- Tests widgets (90% presentation)
- Tests intégration

## Commandes Validation (Mises à Jour)

### Phase 1 Gate
```bash
flutter pub run intl_utils:generate
flutter analyze
flutter test test/unit/data/datasources/
flutter test test/unit/domain/
# SUCCESS: LocalDataSource + DTOs + i18n + Failures
```

### Phase 2 Gate
```bash
flutter test test/unit/data/repositories/
flutter analyze lib/features/schedule/data/
# SUCCESS: Repository avec LocalDataSource intégré
```

### Phase 3 Gate
```bash
flutter test test/presentation/providers/
# SUCCESS: State management
```

### Phase 4 Gate
```bash
flutter test test/presentation/widgets/
flutter test --coverage
# SUCCESS: 90%+ coverage
```

### Final Gate (SANS arch_unit)
```bash
flutter test --coverage
lcov --summary coverage/lcov.info | grep "lines......: 9[0-9]"
flutter analyze
# SUCCESS: 90%+ coverage, zero analyze
```

## Pattern LocalDataSource - Référence Complète

Voir mémoire `schedule_architecture_decision_final` pour:
- Interface complète ScheduleLocalDataSource
- Implémentation détaillée avec Hive Box<Map>
- DTOs (WeeklyScheduleDto, ScheduleSlotDto) avec Freezed
- Providers DI
- Tests unitaires complets
- Justification architecture

## Timeline Finale

| Phase | Jours | Risque | Validation |
|-------|-------|--------|-----------|
| Phase 1: Foundation | 1-2 | FAIBLE | flutter analyze + tests datasource |
| Phase 2: Data Layer | 3-6 | Moyen | tests repository |
| Phase 3: State Mgmt | 7-9 | Moyen | tests providers |
| Phase 4: Mobile UI | 10-14 | Moyen | tests widgets + coverage |
| Phase 5: Real-time | 15-16 | Élevé | tests manuels (OPTIONNEL) |
| Phase 6: Testing | 10-16 | Faible | 90%+ coverage (PARALLÈLE) |

**Total**: 16-18 jours (14 jours minimum + 2 jours optionnel real-time + 2 jours polish)

## Success Criteria Finaux

### Techniques
✅ 90%+ code coverage (95% domain, 90% data, 90% presentation)
✅ Zero flutter analyze issues
✅ ScheduleLocalDataSource avec tests complets
✅ DTOs avec Freezed + JSON serialization
✅ Pattern Server-First pour writes
✅ Pattern Cache-First pour reads
❌ Tests arch_unit (SKIP - cassés)

### UX
✅ Schedule loads < 2s (première charge)
✅ Swipe gestures fluides (PageView)
✅ Touch targets ≥ 44px
✅ Accessibilité WCAG 2.1 AA
✅ Offline mode graceful

## Références Pattern

**LocalDataSource Pattern**:
- Box<Map>: `/workspace/mobile_app/lib/core/storage/hive_orchestrator.dart`
- Interface/Impl: Voir `schedule_architecture_decision_final` memory

**DTOs avec Freezed**:
- Créer avec `@freezed` annotation
- Méthodes: `fromJson()`, `toJson()`, `fromDomain()`, `toDomain()`
- Générer: `flutter pub run build_runner build`

**Tests DataSource**:
- Mock Box<Map> avec Mockito
- Tester toutes méthodes CRUD
- Vérifier clés storage correctes
- 90%+ coverage

## Actions Immédiates Jour 1

1. **Setup branch** (15min)
```bash
git checkout -b feature/schedule-management-phase1
```

2. **Créer structure datasource** (30min)
```bash
mkdir -p lib/features/schedule/data/datasources
touch lib/features/schedule/data/datasources/schedule_local_datasource.dart
touch lib/features/schedule/data/datasources/schedule_local_datasource_impl.dart
```

3. **Créer structure DTOs** (15min)
```bash
mkdir -p lib/features/schedule/data/models
touch lib/features/schedule/data/models/weekly_schedule_dto.dart
touch lib/features/schedule/data/models/schedule_slot_dto.dart
```

4. **Implémenter** (4h)
- Interface LocalDataSource
- Implémentation avec Box<Map>
- DTOs avec Freezed

5. **Tests** (1.5h)
```bash
mkdir -p test/unit/data/datasources
touch test/unit/data/datasources/schedule_local_datasource_impl_test.dart
flutter test test/unit/data/datasources/
```

## Décision Finale Confirmée

**Architecture**: Feature Schedule SÉPARÉE
**Persistance**: Classe `ScheduleLocalDataSource` dédiée avec `Box<Map>`
**DTOs**: Freezed + JSON serialization (pas @HiveType)
**Tests arch_unit**: SKIP (cassés, non-bloquant)
**Timeline**: 16-18 jours
**Prêt**: OUI

---

**Plan validé par**: User + Gemini 2.5 Pro
**Date**: 2025-10-08
**Statut**: PRÊT POUR EXÉCUTION
