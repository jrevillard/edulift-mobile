# Décision Architecturale - Feature Schedule Séparée

**Date**: 2025-10-08
**Statut**: VALIDÉ et CONFIRMÉ
**Type**: Architecture Decision Record (ADR)

## Contexte

Question posée: "Faut-il une classe spécifique pour la persistence ou implémenter dans la feature group?"

### Analyse du Code Existant

**FACTS vérifiés:**
1. Feature `schedule` existe déjà: `lib/features/schedule/`
2. Schedule Config existe dans Groups: `group_schedule_config_provider.dart`
3. Duplication actuelle: Config dans groups, operations dans schedule
4. Box Hive: `Hive.openBox<Map>(HiveBoxNames.scheduleBox)` existe déjà

### Documentation Fonctionnelle (Vérifiée)

D'après `/workspace/docs/Functional-Documentation.md` (lignes 254-276):
- **Schedule Configuration** = Propriété du GROUP (time slots par groupe)
- **Weekly Planning** = Gestion des schedules hebdomadaires
- **Trip Assignment** = Assignation vehicles/children aux slots

## Décision: Feature Schedule SÉPARÉE

### Architecture Validée

```
lib/features/
├── groups/
│   ├── domain/entities/group.dart (avec scheduleConfig property)
│   └── presentation/providers/group_schedule_config_provider.dart
│       └── Gère UNIQUEMENT la configuration (time slots disponibles)
│
└── schedule/ (FEATURE SÉPARÉE)
    ├── domain/
    │   ├── entities/
    │   │   ├── schedule_slot.dart
    │   │   ├── weekly_schedule.dart
    │   │   ├── schedule_config.dart (local copy/cache)
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
    │   │   └── schedule_remote_datasource.dart
    │   ├── repositories/
    │   │   ├── schedule_repository_impl.dart
    │   │   └── handlers/ (operations handlers)
    │   ├── models/ (DTOs)
    │   │   ├── weekly_schedule_dto.dart
    │   │   ├── schedule_slot_dto.dart
    │   │   └── vehicle_assignment_dto.dart
    │   └── providers/
    │       └── schedule_datasource_providers.dart (DI)
    │
    └── presentation/
        ├── providers/
        │   ├── schedule_provider.dart (StateNotifier)
        │   └── schedule_providers.dart (granular providers)
        ├── pages/
        │   ├── weekly_schedule_planning_page.dart
        │   ├── schedule_slot_detail_page.dart
        │   └── schedule_configuration_page.dart
        └── widgets/
            ├── mobile/
            │   ├── schedule_week_view.dart
            │   ├── schedule_day_view.dart
            │   └── time_slot_card_mobile.dart
            └── common/
```

## Relation Groups ↔ Schedule

### Groups possède la Configuration
```dart
// Dans Group entity
class Group {
  final String id;
  final ScheduleConfig? scheduleConfig; // Time slots disponibles par jour
  // ...
}

class ScheduleConfig {
  final Map<DayOfWeek, List<String>> timeSlotsByDay;
  // Ex: { Monday: ["08:00", "09:00", "15:00"], Tuesday: ["08:00", "16:00"] }
}
```

### Schedule utilise la Configuration
```dart
// Dans Schedule repository
class ScheduleRepositoryImpl {
  final ScheduleRemoteDataSource _remoteDataSource;
  final ScheduleLocalDataSource _localDataSource; // ← NOUVELLE classe
  final NetworkInfo _networkInfo;
  
  Future<Result<WeeklySchedule, ScheduleFailure>> getWeeklySchedule({
    required String groupId,
    required DateTime weekStart,
  }) async {
    // 1. Cache-first pattern
    final cached = await _localDataSource.getCachedSchedule(
      groupId: groupId,
      weekStart: weekStart,
    );
    
    // 2. Network fetch avec validation contre group config
    if (await _networkInfo.isConnected) {
      try {
        final dto = await _remoteDataSource.getWeeklySchedule(
          groupId: groupId,
          weekStart: weekStart,
        );
        final schedule = dto.toDomain();
        
        // 3. Cache result
        await _localDataSource.cacheWeeklySchedule(schedule);
        return Result.ok(schedule);
      } catch (e) {
        // Fallback to cache
        if (cached != null) return Result.ok(cached);
        return Result.err(ScheduleFailure.loadFailed(e.toString()));
      }
    }
    
    // 4. Offline mode
    if (cached != null) return Result.ok(cached);
    return Result.err(ScheduleFailure.noConnection());
  }
}
```

## Classe de Persistance - Spécification Complète

### Interface (Contrat)
```dart
// lib/features/schedule/data/datasources/schedule_local_datasource.dart
abstract class ScheduleLocalDataSource {
  /// Cache a weekly schedule
  Future<void> cacheWeeklySchedule(WeeklySchedule schedule);
  
  /// Retrieve cached weekly schedule
  Future<WeeklySchedule?> getCachedSchedule({
    required String groupId,
    required DateTime weekStart,
  });
  
  /// Cache a single schedule slot
  Future<void> cacheScheduleSlot(ScheduleSlot slot);
  
  /// Get a single cached slot
  Future<ScheduleSlot?> getCachedSlot(String slotId);
  
  /// Remove a cached slot
  Future<void> removeCachedSlot(String slotId);
  
  /// Clear all cached schedules for a group
  Future<void> clearScheduleCache({String? groupId});
  
  /// Get all cached schedules for a group
  Future<List<WeeklySchedule>> getCachedSchedulesForGroup(String groupId);
}
```

### Implémentation avec Hive Box<Map>
```dart
// lib/features/schedule/data/datasources/schedule_local_datasource_impl.dart
import 'package:hive/hive.dart';
import '../../domain/entities/schedule_slot.dart';
import '../../domain/entities/weekly_schedule.dart';
import '../models/weekly_schedule_dto.dart';
import '../models/schedule_slot_dto.dart';

class ScheduleLocalDataSourceImpl implements ScheduleLocalDataSource {
  final Box<Map> _scheduleBox;
  
  ScheduleLocalDataSourceImpl(this._scheduleBox);
  
  @override
  Future<void> cacheWeeklySchedule(WeeklySchedule schedule) async {
    try {
      final dto = WeeklyScheduleDto.fromDomain(schedule);
      final key = _buildWeeklyScheduleKey(
        schedule.groupId,
        schedule.weekStartDate,
      );
      
      await _scheduleBox.put(key, dto.toJson());
    } catch (e) {
      throw CacheException('Failed to cache weekly schedule: $e');
    }
  }
  
  @override
  Future<WeeklySchedule?> getCachedSchedule({
    required String groupId,
    required DateTime weekStart,
  }) async {
    try {
      final key = _buildWeeklyScheduleKey(groupId, weekStart);
      final json = _scheduleBox.get(key);
      
      if (json == null) return null;
      
      final dto = WeeklyScheduleDto.fromJson(
        Map<String, dynamic>.from(json as Map)
      );
      return dto.toDomain();
    } catch (e) {
      throw CacheException('Failed to get cached schedule: $e');
    }
  }
  
  @override
  Future<void> cacheScheduleSlot(ScheduleSlot slot) async {
    try {
      final dto = ScheduleSlotDto.fromDomain(slot);
      final key = _buildSlotKey(slot.id);
      
      await _scheduleBox.put(key, dto.toJson());
    } catch (e) {
      throw CacheException('Failed to cache schedule slot: $e');
    }
  }
  
  @override
  Future<ScheduleSlot?> getCachedSlot(String slotId) async {
    try {
      final key = _buildSlotKey(slotId);
      final json = _scheduleBox.get(key);
      
      if (json == null) return null;
      
      final dto = ScheduleSlotDto.fromJson(
        Map<String, dynamic>.from(json as Map)
      );
      return dto.toDomain();
    } catch (e) {
      throw CacheException('Failed to get cached slot: $e');
    }
  }
  
  @override
  Future<void> removeCachedSlot(String slotId) async {
    try {
      final key = _buildSlotKey(slotId);
      await _scheduleBox.delete(key);
    } catch (e) {
      throw CacheException('Failed to remove cached slot: $e');
    }
  }
  
  @override
  Future<void> clearScheduleCache({String? groupId}) async {
    try {
      if (groupId != null) {
        // Clear only schedules for specific group
        final keysToDelete = _scheduleBox.keys
            .where((key) => key.toString().startsWith('weekly_$groupId'))
            .toList();
        await _scheduleBox.deleteAll(keysToDelete);
      } else {
        // Clear all schedules
        await _scheduleBox.clear();
      }
    } catch (e) {
      throw CacheException('Failed to clear schedule cache: $e');
    }
  }
  
  @override
  Future<List<WeeklySchedule>> getCachedSchedulesForGroup(String groupId) async {
    try {
      final schedules = <WeeklySchedule>[];
      
      for (final key in _scheduleBox.keys) {
        if (key.toString().startsWith('weekly_$groupId')) {
          final json = _scheduleBox.get(key);
          if (json != null) {
            final dto = WeeklyScheduleDto.fromJson(
              Map<String, dynamic>.from(json as Map)
            );
            schedules.add(dto.toDomain());
          }
        }
      }
      
      return schedules;
    } catch (e) {
      throw CacheException('Failed to get cached schedules for group: $e');
    }
  }
  
  // Private helpers
  String _buildWeeklyScheduleKey(String groupId, DateTime weekStart) {
    final dateKey = weekStart.toIso8601String().split('T')[0];
    return 'weekly_${groupId}_$dateKey';
  }
  
  String _buildSlotKey(String slotId) {
    return 'slot_$slotId';
  }
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
  
  @override
  String toString() => 'CacheException: $message';
}
```

### Dependency Injection (Providers)
```dart
// lib/features/schedule/data/providers/schedule_datasource_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../../core/storage/hive_orchestrator.dart';
import '../datasources/schedule_local_datasource.dart';
import '../datasources/schedule_local_datasource_impl.dart';
import '../datasources/schedule_remote_datasource.dart';
import '../datasources/schedule_remote_datasource_impl.dart';

/// Hive box provider for schedules
final scheduleBoxProvider = Provider<Box<Map>>((ref) {
  return Hive.box<Map>(HiveBoxNames.scheduleBox);
});

/// Local datasource provider
final scheduleLocalDataSourceProvider = Provider<ScheduleLocalDataSource>((ref) {
  final box = ref.watch(scheduleBoxProvider);
  return ScheduleLocalDataSourceImpl(box);
});

/// Remote datasource provider
final scheduleRemoteDataSourceProvider = Provider<ScheduleRemoteDataSource>((ref) {
  // Inject API client
  return ScheduleRemoteDataSourceImpl(/* ... */);
});
```

## DTOs (Data Transfer Objects)

### WeeklyScheduleDto
```dart
// lib/features/schedule/data/models/weekly_schedule_dto.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/weekly_schedule.dart';
import 'schedule_slot_dto.dart';

part 'weekly_schedule_dto.freezed.dart';
part 'weekly_schedule_dto.g.dart';

@freezed
class WeeklyScheduleDto with _$WeeklyScheduleDto {
  const factory WeeklyScheduleDto({
    required String id,
    required String groupId,
    required String weekStartDate,
    required List<ScheduleSlotDto> slots,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _WeeklyScheduleDto;
  
  factory WeeklyScheduleDto.fromJson(Map<String, dynamic> json) =>
      _$WeeklyScheduleDtoFromJson(json);
  
  factory WeeklyScheduleDto.fromDomain(WeeklySchedule schedule) {
    return WeeklyScheduleDto(
      id: schedule.id,
      groupId: schedule.groupId,
      weekStartDate: schedule.weekStartDate.toIso8601String(),
      slots: schedule.slots.map((s) => ScheduleSlotDto.fromDomain(s)).toList(),
      createdAt: schedule.createdAt,
      updatedAt: schedule.updatedAt,
    );
  }
}

extension WeeklyScheduleDtoX on WeeklyScheduleDto {
  WeeklySchedule toDomain() {
    return WeeklySchedule(
      id: id,
      groupId: groupId,
      weekStartDate: DateTime.parse(weekStartDate),
      slots: slots.map((s) => s.toDomain()).toList(),
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
```

### ScheduleSlotDto
```dart
// lib/features/schedule/data/models/schedule_slot_dto.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/schedule_slot.dart';

part 'schedule_slot_dto.freezed.dart';
part 'schedule_slot_dto.g.dart';

@freezed
class ScheduleSlotDto with _$ScheduleSlotDto {
  const factory ScheduleSlotDto({
    required String id,
    required String groupId,
    required int dayOfWeek, // 0-6 (Monday-Sunday)
    required String timeSlot, // "08:00"
    String? vehicleId,
    String? driverId,
    int? seatOverride,
    List<String>? assignedChildrenIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ScheduleSlotDto;
  
  factory ScheduleSlotDto.fromJson(Map<String, dynamic> json) =>
      _$ScheduleSlotDtoFromJson(json);
  
  factory ScheduleSlotDto.fromDomain(ScheduleSlot slot) {
    return ScheduleSlotDto(
      id: slot.id,
      groupId: slot.groupId,
      dayOfWeek: slot.dayOfWeek.index,
      timeSlot: slot.timeSlot,
      vehicleId: slot.vehicleId,
      driverId: slot.driverId,
      seatOverride: slot.seatOverride,
      assignedChildrenIds: slot.assignedChildrenIds,
      createdAt: slot.createdAt,
      updatedAt: slot.updatedAt,
    );
  }
}

extension ScheduleSlotDtoX on ScheduleSlotDto {
  ScheduleSlot toDomain() {
    return ScheduleSlot(
      id: id,
      groupId: groupId,
      dayOfWeek: DayOfWeek.values[dayOfWeek],
      timeSlot: timeSlot,
      vehicleId: vehicleId,
      driverId: driverId,
      seatOverride: seatOverride,
      assignedChildrenIds: assignedChildrenIds ?? [],
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
```

## Phase 1 Mise à Jour - Actions Concrètes

### Jour 1: Créer Infrastructure Persistance

**Étape 1**: Créer Interface LocalDataSource (30min)
```bash
# Créer fichier
touch lib/features/schedule/data/datasources/schedule_local_datasource.dart
```

**Étape 2**: Implémenter LocalDataSource (2h)
```bash
# Créer implémentation
touch lib/features/schedule/data/datasources/schedule_local_datasource_impl.dart
```

**Étape 3**: Créer DTOs (1.5h)
```bash
# Créer DTOs avec Freezed
touch lib/features/schedule/data/models/weekly_schedule_dto.dart
touch lib/features/schedule/data/models/schedule_slot_dto.dart

# Générer code Freezed
flutter pub run build_runner build --delete-conflicting-outputs
```

**Étape 4**: Créer Providers DI (30min)
```bash
touch lib/features/schedule/data/providers/schedule_datasource_providers.dart
```

**Étape 5**: Tests LocalDataSource (1.5h)
```bash
# Créer tests
touch test/unit/data/datasources/schedule_local_datasource_impl_test.dart
```

### Jour 2: i18n + ScheduleFailure

**Inchangé du plan original**

## Justification de la Décision

### Pourquoi Feature Séparée?

✅ **Single Responsibility Principle**
- Groups: Gestion des groupes et leur configuration
- Schedule: Gestion des plannings hebdomadaires

✅ **Clean Architecture**
- Séparation claire des domaines
- Dépendances unidirectionnelles (Schedule → Groups)
- Testabilité isolée

✅ **Maintenabilité**
- Code schedule indépendant de groups
- Plus facile à débugger
- Plus facile à étendre

✅ **Réutilisabilité**
- Schedule pourrait être utilisé par d'autres features
- Groups reste léger et focalisé

✅ **Performance**
- Cache schedule séparé du cache groups
- Invalidation ciblée
- Pas de sur-fetching

### Pourquoi Classe Persistance Dédiée?

✅ **Repository Pattern**
- Repository dépend de DataSource
- DataSource encapsule détails persistance

✅ **Testabilité**
- Mock facilement ScheduleLocalDataSource
- Tests repository sans toucher Hive

✅ **Flexibilité**
- Changer implémentation storage sans toucher repository
- Ajouter layer de cache additionnel si besoin

✅ **SOLID Principles**
- Interface Segregation: ScheduleLocalDataSource définit contrat clair
- Dependency Inversion: Repository dépend de l'interface, pas impl

## Tests Phase 1

### Test LocalDataSource Implementation
```dart
// test/unit/data/datasources/schedule_local_datasource_impl_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([Box])
void main() {
  group('ScheduleLocalDataSourceImpl', () {
    late ScheduleLocalDataSourceImpl dataSource;
    late MockBox<Map> mockBox;
    
    setUp(() {
      mockBox = MockBox<Map>();
      dataSource = ScheduleLocalDataSourceImpl(mockBox);
    });
    
    group('cacheWeeklySchedule', () {
      test('should cache weekly schedule with correct key', () async {
        // Arrange
        final schedule = WeeklySchedule(
          id: 'schedule123',
          groupId: 'group123',
          weekStartDate: DateTime(2025, 10, 6),
          slots: [],
        );
        
        when(mockBox.put(any, any)).thenAnswer((_) async => {});
        
        // Act
        await dataSource.cacheWeeklySchedule(schedule);
        
        // Assert
        verify(mockBox.put(
          'weekly_group123_2025-10-06',
          argThat(isA<Map<String, dynamic>>()),
        )).called(1);
      });
    });
    
    group('getCachedSchedule', () {
      test('should return null when schedule not cached', () async {
        // Arrange
        when(mockBox.get(any)).thenReturn(null);
        
        // Act
        final result = await dataSource.getCachedSchedule(
          groupId: 'group123',
          weekStart: DateTime(2025, 10, 6),
        );
        
        // Assert
        expect(result, isNull);
      });
      
      test('should return cached schedule when available', () async {
        // Arrange
        final json = {
          'id': 'schedule123',
          'groupId': 'group123',
          'weekStartDate': '2025-10-06',
          'slots': [],
        };
        when(mockBox.get('weekly_group123_2025-10-06')).thenReturn(json);
        
        // Act
        final result = await dataSource.getCachedSchedule(
          groupId: 'group123',
          weekStart: DateTime(2025, 10, 6),
        );
        
        // Assert
        expect(result, isNotNull);
        expect(result!.groupId, 'group123');
      });
    });
  });
}
```

## Validation Architecture

### Checklist Phase 1
- [ ] ScheduleLocalDataSource interface créée
- [ ] ScheduleLocalDataSourceImpl implémentée avec Box<Map>
- [ ] DTOs créés (WeeklyScheduleDto, ScheduleSlotDto)
- [ ] Providers DI configurés
- [ ] Tests unitaires datasource (90%+ coverage)
- [ ] 50 clés i18n ajoutées
- [ ] ScheduleFailure créé
- [ ] Zero flutter analyze issues

## Références Pattern

**Pour implementation LocalDataSource, référencer:**
- Pattern Box<Map>: `/workspace/mobile_app/lib/core/storage/hive_orchestrator.dart`
- Pattern DTO: Créer avec Freezed (voir family DTOs si existent)
- Pattern Provider DI: Voir `lib/features/family/data/providers/`
- Tests datasource: Voir `test/unit/data/datasources/` (si existent)

## Décision Finale

**CONFIRMÉ**: Feature Schedule séparée avec classe de persistance dédiée.

**Structure:**
- `ScheduleLocalDataSource` (interface)
- `ScheduleLocalDataSourceImpl` (implémentation avec Hive Box<Map>)
- DTOs pour conversion Domain ↔ JSON
- Providers pour DI
- Tests unitaires complets

**Relation:** Schedule UTILISE Groups (via groupId et scheduleConfig), Groups ne dépend PAS de Schedule.

---

**Validé par**: User (2025-10-08)
**Implémentation**: Phase 1 - Jours 1-2
**Prêt pour exécution**: OUI
