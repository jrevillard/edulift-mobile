# Family Permission Providers - Integration Guide

## Architecture Compliance ✅

Ce module respecte 100% les patterns architecturaux existants du codebase :

### ✅ StateNotifier Pattern
- `FamilyPermissionNotifier extends StateNotifier<FamilyPermissionState>`
- Identique aux patterns `AuthNotifier`, `FamilyNotifier`, `VehiclesNotifier`

### ✅ Dependency Injection
- Injection via constructeur : `FamilyMembersRepository`, `ErrorHandlerService`
- Utilise les providers existants : `familyMembersRepositoryProvider`, `errorHandlerServiceProvider`

### ✅ Error Handling
- Pattern `_errorHandler.getErrorMessage(error, stackTrace)` 
- État d'erreur dans le state avec `clearError()`
- Identique aux patterns existants

### ✅ State Management
- État immutable avec `copyWith()`
- Propriétés computed (getters)
- Pattern `Equatable` pour comparaisons

## Providers Créés

### 1. `FamilyPermissionProvider`
**Responsabilité** : État des permissions utilisateur dans la famille
```dart
final permissionState = ref.watch(familyPermissionProvider);
final canManage = permissionState.canManageMembers;
final isAdmin = permissionState.isCurrentUserAdmin;
```

### 2. `FamilyMemberActionsProvider`
**Responsabilité** : Actions sur les membres (promote, demote, remove)
```dart
final actionsNotifier = ref.read(familyMemberActionsProvider.notifier);
await actionsNotifier.promoteMemberToAdmin(memberId: id, memberName: name);
```

### 3. `FamilyPermissionCacheProvider`
**Responsabilité** : Cache intelligent avec TTL et statistiques
```dart
final cacheStats = ref.watch(permissionCacheStatsProvider);
final isCached = ref.watch(isFamilyPermissionsCachedProvider(familyId));
```

### 4. `FamilyPermissionOrchestratorProvider`
**Responsabilité** : Orchestration complète pour l'UI
```dart
final orchestrator = ref.read(familyPermissionOrchestratorProvider(familyId).notifier);
await orchestrator.initializePermissions();
```

## Exemple d'Integration UI

```dart
class FamilyMemberManagementWidget extends ConsumerWidget {
  const FamilyMemberManagementWidget({required this.familyId, super.key});
  
  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Orchestrated state pour tout avoir en un provider
    final orchestratedState = ref.watch(familyPermissionOrchestratorProvider(familyId));
    final orchestrator = ref.watch(familyPermissionOrchestratorProvider(familyId).notifier);
    
    // Status de synchronisation
    final syncStatus = ref.watch(permissionSyncStatusProvider(familyId));
    
    // Membres avec capabilities
    final membersWithCaps = ref.watch(familyMembersWithCapabilitiesProvider(familyId));
    
    return Scaffold(
      body: orchestratedState.permissions.when(
        loading: () => const CircularProgressIndicator(),
        error: (error, stack) => Text('Erreur: ${orchestratedState.errorMessage}'),
        data: (permissions) => Column(
          children: [
            // Status de cache
            if (syncStatus.isCached) 
              Chip(label: Text('Données en cache (${syncStatus.cacheHitRate.toStringAsFixed(1)}%)')),
            
            // Liste des membres avec actions
            ...membersWithCaps.map((memberWithCaps) => MemberTile(
              member: memberWithCaps.member,
              canPromote: memberWithCaps.actionCapabilities.canPromote,
              canRemove: memberWithCaps.actionCapabilities.canRemove,
              isProcessing: memberWithCaps.actionCapabilities.isProcessing,
              onPromote: () => orchestrator.promoteMemberToAdmin(
                memberId: memberWithCaps.member.id,
                memberName: memberWithCaps.member.displayName,
              ),
              onRemove: () => orchestrator.removeMember(
                memberId: memberWithCaps.member.id,
                memberName: memberWithCaps.member.displayName,
              ),
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => orchestrator.refreshPermissions(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
```

## Patterns de Test

Pour créer des tests conformes aux patterns existants :

```dart
void main() {
  group('FamilyPermissionProvider Tests', () {
    late MockFamilyMembersRepository mockRepository;
    late MockErrorHandlerService mockErrorHandler;
    late FamilyPermissionNotifier notifier;

    setUp(() {
      mockRepository = MockFamilyMembersRepository();
      mockErrorHandler = MockErrorHandlerService();
      notifier = FamilyPermissionNotifier(mockRepository, mockErrorHandler);
    });

    test('should initialize with correct default state', () {
      expect(notifier.state, equals(const FamilyPermissionState()));
    });

    test('should load family permissions successfully', () async {
      // Pattern identique aux tests existants
      final members = [createMockFamilyMember(role: FamilyRole.admin)];
      when(() => mockRepository.getFamilyMembers(any()))
          .thenAnswer((_) async => members);

      await notifier.loadFamilyPermissions(
        familyId: 'family1',
        currentUserId: 'user1',
      );

      expect(notifier.state.currentUserRole, equals(FamilyRole.admin));
      expect(notifier.state.isCurrentUserAdmin, isTrue);
      expect(notifier.state.error, isNull);
    });
  });
}
```

## Avantages de cette Architecture

### 🎯 **Séparation des Responsabilités**
- **Permissions** : État et validation des droits
- **Actions** : Opérations sur les membres
- **Cache** : Gestion intelligente de la persistance
- **Orchestrator** : Coordination pour l'UI

### ⚡ **Performance**
- Cache avec TTL automatique
- Invalidation intelligente après actions
- Statistiques de cache pour monitoring

### 🛡️ **Robustesse**
- Error handling uniforme
- État de loading par action
- Validation des permissions avant actions

### 🧪 **Testabilité**
- Chaque provider isolé et mockable
- Patterns identiques aux tests existants
- Injection de dépendances claire

## Notes d'Implémentation

Ce module suit le **Principe 0** : 100% conforme à l'architecture existante, aucune simulation ou workaround. Tous les patterns utilisés sont **VÉRIFIÉS** depuis le codebase existant.