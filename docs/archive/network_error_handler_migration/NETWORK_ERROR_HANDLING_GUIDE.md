# Guide de Gestion des Erreurs Réseau - EduLift Mobile

## 📋 Vue d'Ensemble

Ce guide présente l'architecture unifiée de gestion des erreurs réseau pour l'application mobile EduLift, conçue pour assurer la robustesse, la cohérence et une excellente expérience utilisateur.

## 🎯 Objectifs Principaux

1. **Robustesse** : Gérer gracieusement les erreurs réseau avec retry automatique
2. **Transparence** : Informer clairement l'utilisateur du statut des données (cache vs. frais)
3. **Cohérence** : Utiliser les mêmes patterns dans tous les repositories
4. **Maintenabilité** : Centraliser la logique de gestion d'erreurs
5. **Respect du Principe 0** : Ne jamais masquer les erreurs importantes

## 🏗️ Architecture Composants

### 1. NetworkErrorHandler (Nouveau)
**Fichier** : `/lib/core/network/network_error_handler.dart`

```dart
class NetworkErrorHandler {
  // Retry automatique avec backoff exponentiel
  Future<T> executeWithRetry<T>(Future<T> Function() operation, {
    required String operation,
    String? serviceName,
    RetryConfig config = const RetryConfig(),
    Map<String, dynamic>? context,
  });

  // Intégration avec ApiResponseHelper existant
  Future<ApiResponse<T>> executeApiCall<T>(Future<T> Function() apiCall, {
    required String operation,
    // ...
  });

  // Pattern pour repositories (cache fallback)
  Future<Result<T, ApiFailure>> executeRepositoryOperation<T>(
    Future<T> Function() operation, {
    required String operation,
    bool cacheFirst = false,
    bool fallbackToCache = false,
    Future<T> Function()? cacheOperation,
    // ...
  });
}
```

### 2. RetryConfig
Configurations prédéfinies pour différents types d'opérations :

```dart
// Opérations rapides (UI immédiate)
RetryConfig.quick

// Opérations critiques (création, mise à jour)
RetryConfig.critical

// Opérations en arrière-plan
RetryConfig.background
```

### 3. NetworkCircuitBreaker
Protection contre les erreurs en cascade avec pattern Circuit Breaker.

## 🔄 Patterns d'Utilisation

### Pattern 1: Repository avec Cache-First (Lectures)

```dart
@override
Future<Result<Family, ApiFailure>> getCurrentFamily() async {
  return await _networkErrorHandler.executeRepositoryOperation<Family>(
    () => _remoteDataSource.getCurrentFamily(),
    operation: 'family.get_current_family',
    serviceName: 'family_service',
    config: const RetryConfig.quick,
    cacheFirst: true,        // 1. Essayer le cache d'abord
    fallbackToCache: true,   // 2. Utiliser le cache en cas d'erreur réseau
    cacheOperation: () => _localDataSource.getCurrentFamily(),
    context: {
      'feature': 'family_management',
      'operation_type': 'read',
      'cache_strategy': 'cache_first',
    },
  ).then((result) {
    if (result.isOk) {
      _cacheFamilySafely(result.value!); // Mettre à jour le cache
    }
    return result;
  });
}
```

### Pattern 2: Repository Server-First (Écritures)

```dart
@override
Future<Result<Family, ApiFailure>> createFamily({required String name}) async {
  return await _networkErrorHandler.executeRepositoryOperation<Family>(
    () => _remoteDataSource.createFamily(name: name.trim()),
    operation: 'family.create_family',
    serviceName: 'family_service',
    config: const RetryConfig.critical, // Plus de retry pour les écritures
    // Pas de cache fallback pour les écritures
    context: {
      'feature': 'family_management',
      'operation_type': 'create',
    },
  ).then((result) {
    if (result.isOk) {
      _cacheFamilySafely(result.value!); // Mettre à jour le cache seulement après succès
    }
    return result;
  });
}
```

### Pattern 3: Opération API Directe

```dart
Future<AuthDto> verifyMagicLink(MagicLinkRequest request) async {
  final response = await _networkErrorHandler.executeApiCall<AuthDto>(
    () => _authApiClient.verifyMagicLink(request),
    operation: 'auth.verify_magic_link',
    serviceName: 'auth_service',
    config: const RetryConfig.critical,
    context: {'auth_flow': 'magic_link'},
  );

  return response.unwrap(); // Lance NetworkException avec message user-friendly
}
```

## 🚨 Gestion des Erreurs

### Classification des Erreurs

Le système transforme automatiquement les erreurs techniques en messages compréhensibles :

| Type d'Erreur | Transformation | Message Utilisateur |
|---------------|----------------|-------------------|
| DioException (timeout) | NetworkException | "Request timeout. Please check your internet connection." |
| DioException (401) | AuthenticationException | "Your session has expired. Please sign in again." |
| DioException (403) | AuthorizationException | "You don't have permission to perform this action." |
| DioException (422) | ValidationException | Message de validation du backend |
| DioException (5xx) | ServerException | "The server is experiencing issues. Please try again later." |
| Network connectivity | NetworkException | "No internet connection. Please check your network settings." |

### Configuration des Retry

```dart
const RetryConfig({
  this.maxAttempts = 3,           // Nombre maximum de tentatives
  this.initialDelay = 1000ms,     // Délai initial
  this.backoffMultiplier = 2.0,   // Multiplicateur exponentiel
  this.maxDelay = 30s,            // Délai maximum
  this.retryableStatusCodes = {   // Codes HTTP réessayables
    408, // Request Timeout
    429, // Too Many Requests
    500, // Internal Server Error
    502, // Bad Gateway
    503, // Service Unavailable
    504, // Gateway Timeout
  },
});
```

## 🔧 Migration des Repositories Existants

### Étapes de Migration

1. **Ajouter NetworkErrorHandler au constructeur**
2. **Remplacer les patterns try/catch manuels**
3. **Utiliser executeRepositoryOperation**
4. **Configurer les stratégies de cache appropriées**
5. **Ajouter le contexte pour le monitoring**

### Avant vs Après

#### ❌ Avant (Code existant problématique)
```dart
@override
Future<Result<Family, ApiFailure>> getCurrentFamily() async {
  Family? localFamily;
  try {
    localFamily = await _localDataSource.getCurrentFamily();
  } catch (cacheError) {
    AppLogger.warning('Cache read failed', cacheError);
  }

  if (await _networkInfo.isConnected) {
    try {
      final response = await ApiResponseHelper.execute(
        () => _remoteDataSource.getCurrentFamily(),
      );
      final remoteFamilyDto = response.unwrap();
      final remoteFamily = remoteFamilyDto.toDomain();

      try {
        await _localDataSource.cacheCurrentFamily(remoteFamily);
      } catch (cacheError) {
        AppLogger.warning('Cache write failed', cacheError);
      }

      return Result.ok(remoteFamily);
    } catch (e) {
      // Gestion manuelle complexe des erreurs
      if (_isNetworkError(e) && localFamily != null) {
        return Result.ok(localFamily); // Masque l'erreur! ❌
      }
      return Result.err(ApiFailure(/* ... */));
    }
  } else {
    if (localFamily != null) {
      return Result.ok(localFamily);
    }
    return Result.err(ApiFailure.noConnection());
  }
}
```

#### ✅ Après (Pattern refactorisé)
```dart
@override
Future<Result<Family, ApiFailure>> getCurrentFamily() async {
  return await _networkErrorHandler.executeRepositoryOperation<Family>(
    () => _remoteDataSource.getCurrentFamily(),
    operation: 'family.get_current_family',
    serviceName: 'family_service',
    config: const RetryConfig.quick,
    cacheFirst: true,
    fallbackToCache: true,
    cacheOperation: () => _localDataSource.getCurrentFamily(),
    context: {
      'feature': 'family_management',
      'operation_type': 'read',
      'cache_strategy': 'cache_first',
    },
  ).then((result) {
    if (result.isOk) {
      _cacheFamilySafely(result.value!);
    }
    return result;
  });
}
```

## 📊 Monitoring et Debugging

### Logs Structurés

Le système génère des logs structurés pour chaque opération :

```dart
AppLogger.info('[NETWORK] Operation completed successfully: family.get_current_family', {
  'service': 'family_service',
  'attempt': 1,
  'context': {
    'feature': 'family_management',
    'operation_type': 'read',
  },
});
```

### Circuit Breaker Monitoring

```dart
// Obtenir le statut de tous les circuit breakers
final status = networkErrorHandler.getCircuitStatus();
print(status['circuitBreakers']['family_service']['isOpen']); // bool

// Réinitialiser manuellement un circuit breaker
networkErrorHandler.resetCircuitBreaker('family_service');
```

### Rapport d'Erreurs Critiques

Les erreurs critiques sont automatiquement rapportées à Firebase Crashlytics avec contexte complet.

## 🧪 Tests

### Tests Unitaires

```dart
test('should retry on network error and succeed', () async {
  // Arrange
  mockRemoteDataSource.getCurrentFamily()
      .thenThrow(NetworkException('Connection failed'))
      .thenAnswer((_) async => familyDto);

  // Act
  final result = await repository.getCurrentFamily();

  // Assert
  expect(result.isOk, true);
  verify(mockRemoteDataSource.getCurrentFamily()).called(2); // Retry
});

test('should fallback to cache on network error', () async {
  // Arrange
  mockRemoteDataSource.getCurrentFamily()
      .thenThrow(NetworkException('Connection failed'));
  mockLocalDataSource.getCurrentFamily()
      .thenAnswer((_) async => cachedFamily);

  // Act
  final result = await repository.getCurrentFamily();

  // Assert
  expect(result.isOk, true);
  expect(result.value, cachedFamily);
});
```

### Tests d'Integration

```dart
test('should handle real network failures gracefully', () async {
  // Test avec vrai réseau déconnecté
  // Vérifier que le fallback cache fonctionne
  // Vérifier que l'utilisateur est notifié
});
```

## 🚀 Bonnes Pratiques

### ✅ À Faire

1. **Toujours utiliser NetworkErrorHandler** pour les opérations réseau
2. **Configurer le retry approprié** selon le type d'opération
3. **Ajouter du contexte** pour le monitoring et le debugging
4. **Utiliser les stratégies de cache** cohérentes avec les besoins métier
5. **Logger les opérations de cache** séparément des opérations réseau
6. **Tester les scénarios d'erreur** dans les tests unitaires

### ❌ À Éviter

1. **Ne jamais masquer les erreurs réseau** sans informer l'utilisateur
2. **Ne pas utiliser try/catch manuel** pour les erreurs réseau
3. **Ne pas ignorer les erreurs de cache** (logger systématiquement)
4. **Ne pas utiliser de retry infini** (toujours configurer une limite)
5. **Ne pas oublier le contexte** pour les opérations critiques

## 📈 Performance

### Impact sur la Performance

- **Retry automatique** : Améliore le taux de succès sans impact UI
- **Circuit breaker** : Prévient les erreurs en cascade
- **Cache fallback** : Réduit la latence perçue
- **Logging structuré** : Impact minimal sur la performance

### Métriques à Surveiller

1. **Taux de succès des opérations réseau**
2. **Nombre moyen de retries par opération**
3. **Temps de réponse moyen (avec et sans cache)**
4. **Taux d'utilisation du circuit breaker**
5. **Fréquence des fallbacks cache**

## 🔄 Roadmap de Migration

### Phase 1: Core (1 semaine)
- [x] Implémenter NetworkErrorHandler
- [x] Créer les configurations RetryConfig
- [x] Ajouter les tests unitaires

### Phase 2: Repositories (2 semaines)
- [ ] Migrer FamilyRepositoryImpl
- [ ] Migrer ScheduleRepositoryImpl
- [ ] Migrer les autres repositories
- [ ] Ajouter les tests d'integration

### Phase 3: Monitoring (1 semaine)
- [ ] Configurer le monitoring des circuit breakers
- [ ] Ajouter les dashboards de surveillance
- [ ] Configurer les alertes pour erreurs critiques

### Phase 4: Documentation (1 jour)
- [x] Documenter les patterns d'utilisation
- [ ] Créer les guides de migration
- [ ] Former les développeurs

## 🆘 Support et Dépannage

### Problèmes Communs

**Q: Mon operation échoue immédiatement sans retry**
```dart
// Vérifier la configuration RetryConfig
config: const RetryConfig(maxAttempts: 1) // Changez à > 1 pour activer le retry
```

**Q: Le cache fallback ne fonctionne pas**
```dart
// Vérifier que fallbackToCache est true
fallbackToCache: true,
cacheOperation: () => _localDataSource.getData(),
```

**Q: Les erreurs ne sont pas rapportées à Crashlytics**
```dart
// Vérifier que vous êtes en mode release
bool.fromEnvironment('dart.vm.product') // doit être true
```

### Debug Mode

En mode debug, des informations supplémentaires sont ajoutées aux logs :

```dart
// Activer le debug mode pour voir les détails des retries
AppLogger.debug('[NETWORK] Attempt 1/3 for operation_name');
```

---

## 📝 Résumé

Cette architecture de gestion des erreurs réseau offre :

1. **Robustesse** : Retry automatique et circuit breaker
2. **Transparence** : Messages clairs et contexte complet
3. **Cohérence** : Patterns uniformes dans tous les repositories
4. **Maintenabilité** : Logique centralisée et testable
5. **Performance** : Cache intelligent et monitoring intégré

En suivant ces patterns, l'application EduLift offre une expérience utilisateur robuste même dans des conditions réseau difficiles, tout en maintenant un code propre et maintenable.