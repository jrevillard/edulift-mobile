# Plan d'Action - Correction NetworkErrorHandler & FamilyRepository

**Date**: 2025-10-16
**Priorité**: CRITIQUE
**Impact**: Violation du Principe 0 - L'utilisateur ne peut pas utiliser l'app en mode offline

---

## 🚨 Problème Principal

Lorsqu'une erreur réseau HTTP 0 (Connection failed) se produit :
1. ✅ NetworkErrorHandler détecte correctement l'erreur réseau
2. ✅ NetworkErrorHandler utilise le cache fallback
3. ✅ FamilyRepository retourne les données en cache
4. ❌ **MAIS** : UserFamilyService interprète parfois l'erreur comme auth error et throw exception
5. ❌ **RÉSULTAT** : Router redirige vers login au lieu d'utiliser les données en cache

---

## 🎯 Objectif

Garantir que l'utilisateur peut **TOUJOURS** utiliser l'application en mode offline si des données sont en cache, conformément au **Principe 0**.

---

## 📋 Actions Critiques (Phase 1)

### Action #1: Corriger UserFamilyService (CRITIQUE)

**Fichier**: `/workspace/mobile_app/lib/core/services/user_family_service.dart`

**Problème actuel**:
```dart
if (familyResult.isErr) {
  final error = familyResult.error!;
  if (error.code == 'family.auth_failed' ||
      (error.statusCode == 401 || error.statusCode == 403)) {
    // ❌ Throw même si c'est une erreur réseau!
    throw Exception('Authentication failed: ${error.code}');
  }
  return false;
}
```

**Correction à appliquer**:
```dart
if (familyResult.isErr) {
  final error = familyResult.error!;

  // ✅ FIXED: Vérifier que c'est une vraie erreur auth, pas une erreur réseau
  if ((error.code == 'family.auth_failed' ||
      (error.statusCode == 401 || error.statusCode == 403)) &&
      error.details?['is_network_error'] != true) {  // ✅ Nouvelle vérification
    // Vraie erreur auth - rediriger vers login
    throw Exception('Authentication failed: ${error.code}');
  }

  // Pour les erreurs réseau ou autres, retourner false (pas de throw)
  AppLogger.info(
    '[UserFamilyService] Error checking family: ${error.code} (network: ${error.details?['is_network_error']})',
  );
  return false;
}
```

**Temps estimé**: 30 minutes

---

### Action #2: Créer NetworkErrorClassifier (CRITIQUE)

**Fichier**: `/workspace/mobile_app/lib/core/network/network_error_classifier.dart` (nouveau)

**Objectif**: Centraliser TOUTE la logique de classification des erreurs réseau

**Implémentation**:
```dart
/// Centralized network error classification
class NetworkErrorClassifier {
  /// Détermine si l'erreur est une erreur de connectivité réseau (vs erreur serveur)
  static bool isNetworkConnectivityError(dynamic error) {
    // SocketException, TimeoutException = erreurs réseau
    if (error is SocketException || error is TimeoutException) {
      return true;
    }

    // DioException - vérifier le type
    if (error is DioException) {
      // Types d'exception liés à la connexion
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.unknown) {
        return true;
      }

      // HTTP 0 ou null = erreur réseau
      final statusCode = error.response?.statusCode;
      if (statusCode == null || statusCode == 0) {
        return true;
      }

      return false;
    }

    // ApiException - vérifier statusCode
    if (error is ApiException) {
      if (error.statusCode == null || error.statusCode == 0) {
        return true;
      }
      // Vérifier message pour mots-clés réseau
      if (error.message.contains('SocketException') ||
          error.message.contains('Connection refused') ||
          error.message.contains('Network is unreachable') ||
          error.message.contains('Connection timeout') ||
          error.message.contains('TimeoutException')) {
        return true;
      }
      return false;
    }

    // NetworkException wrapper
    if (error is NetworkException) {
      return true;
    }

    // Vérifier message pour mots-clés
    final errorString = error.toString();
    if (errorString.contains('SocketException') ||
        errorString.contains('Connection refused') ||
        errorString.contains('Network is unreachable') ||
        errorString.contains('Connection timeout') ||
        errorString.contains('TimeoutException')) {
      return true;
    }

    return false;
  }

  /// Détermine si l'erreur doit être réessayée
  static bool isRetryable(
    dynamic error,
    RetryConfig config, {
    Set<int> nonErrorStatusCodes = const {},
  }) {
    // Les erreurs réseau sont toujours réessayables
    if (isNetworkConnectivityError(error)) {
      return true;
    }

    // Extraire status code
    int? statusCode;
    if (error is DioException) {
      statusCode = error.response?.statusCode;
    } else if (error is ApiException) {
      statusCode = error.statusCode;
    }

    // Vérifier si le status code est configuré comme non-erreur
    if (statusCode != null && nonErrorStatusCodes.contains(statusCode)) {
      return false;
    }

    // Vérifier les status codes réessayables de la config
    if (statusCode != null && config.retryableStatusCodes.contains(statusCode)) {
      return true;
    }

    // ApiException avec flag retryable
    if (error is ApiException && error.isRetryable) {
      return true;
    }

    return false;
  }

  /// Détermine si le cache fallback doit être utilisé
  ///
  /// Cache fallback UNIQUEMENT pour erreurs de connectivité réseau
  /// PAS pour erreurs serveur (4xx, 5xx)
  static bool shouldUseCacheFallback(dynamic error) {
    return isNetworkConnectivityError(error);
  }
}
```

**Temps estimé**: 1 heure

---

### Action #3: Mettre à jour NetworkErrorHandler pour utiliser NetworkErrorClassifier (CRITIQUE)

**Fichier**: `/workspace/mobile_app/lib/core/network/network_error_handler.dart`

**Changements à appliquer**:

1. **Importer NetworkErrorClassifier**:
```dart
import 'network_error_classifier.dart';
```

2. **Remplacer `_isNetworkErrorForCacheFallback` (ligne 616-697)**:
```dart
// AVANT (ligne 616-697)
bool _isNetworkErrorForCacheFallback(dynamic error) {
  // ... 80 lignes de logique complexe ...
}

// APRÈS
bool _isNetworkErrorForCacheFallback(dynamic error) {
  return NetworkErrorClassifier.shouldUseCacheFallback(error);
}
```

3. **Remplacer `_isRetryableError` (ligne 404-430)**:
```dart
// AVANT
bool _isRetryableError(dynamic error, RetryConfig config) {
  // ... logique de retry ...
}

// APRÈS
bool _isRetryableError(dynamic error, RetryConfig config) {
  return NetworkErrorClassifier.isRetryable(error, config);
}
```

4. **Remplacer `_isRetryableErrorForOperation` (ligne 900-943)**:
```dart
// AVANT
bool _isRetryableErrorForOperation(
  dynamic error,
  RetryConfig config,
  Set<int> nonErrorStatusCodes,
) {
  // ... logique de retry avec nonErrorStatusCodes ...
}

// APRÈS
bool _isRetryableErrorForOperation(
  dynamic error,
  RetryConfig config,
  Set<int> nonErrorStatusCodes,
) {
  return NetworkErrorClassifier.isRetryable(
    error,
    config,
    nonErrorStatusCodes: nonErrorStatusCodes,
  );
}
```

**Temps estimé**: 1 heure

---

### Action #4: Propager le flag `is_network_error` dans ApiFailure (CRITIQUE)

**Fichier**: `/workspace/mobile_app/lib/core/network/network_error_handler.dart`

**Fonction à modifier**: `_transformExceptionToApiFailure` (ligne 946-1047)

**Changements**:

```dart
ApiFailure _transformExceptionToApiFailure(dynamic error) {
  // ✅ Déterminer si c'est une erreur réseau
  final isNetworkError = NetworkErrorClassifier.isNetworkConnectivityError(error);

  if (error is ApiException) {
    final statusCode = error.statusCode;
    final errorCode = _determineErrorCode(statusCode);

    return ApiFailure(
      message: error.message,
      code: errorCode,
      statusCode: statusCode,
      details: {
        ...?error.details,
        'is_network_error': isNetworkError,  // ✅ Ajouter flag
      },
      requestUrl: error.endpoint,
      requestMethod: error.method,
    );
  }

  if (error is NetworkException) {
    return ApiFailure.network(
      message: error.message,
      details: {'is_network_error': true},  // ✅ Flag explicite
    );
  }

  if (error is SocketException) {
    return ApiFailure.network(
      message: error.message,
      details: {'is_network_error': true},  // ✅ Flag explicite
    );
  }

  if (error is TimeoutException) {
    return const ApiFailure(
      code: 'timeout',
      message: 'Request timed out',
      statusCode: 408,
      details: {'is_network_error': true},  // ✅ Flag explicite
    );
  }

  // Cas par défaut
  return ApiFailure(
    code: 'network.unknown_error',
    message: error.toString(),
    statusCode: 0,
    details: {
      'is_network_error': isNetworkError,  // ✅ Flag basé sur classification
      'original_error': error.toString(),
    },
  );
}
```

**Temps estimé**: 1 heure

---

### Action #5: Corriger FamilyRepository pour préserver le flag (CRITIQUE)

**Fichier**: `/workspace/mobile_app/lib/features/family/data/repositories/family_repository_impl.dart`

**Fonction à modifier**: `getCurrentFamily` (ligne 48-128)

**Changements**:

```dart
return result.when(
  ok: (data) async {
    // ... code existant ...
  },
  err: (failure) async {
    // 404 handling
    if (failure.statusCode == 404 || failure.code == 'api.not_found') {
      // ... code existant ...
    }

    // Auth error handling
    if (failure.statusCode == 401 || failure.statusCode == 403) {
      return Result.err(
        ApiFailure(
          code: 'family.auth_failed',
          details: {
            'error': failure.message,
            'statusCode': failure.statusCode,
            'isAuthError': true,
            'is_network_error': failure.details?['is_network_error'] ?? false,  // ✅ PRÉSERVER LE FLAG!
          },
          statusCode: failure.statusCode ?? 401,
        ),
      );
    }

    return Result.err(failure);
  },
);
```

**Temps estimé**: 30 minutes

---

### Action #6: Corriger le calcul de l'exponential backoff (CRITIQUE)

**Fichier**: `/workspace/mobile_app/lib/core/network/network_error_handler.dart`

**Fonction à modifier**: `_calculateRetryDelay` (ligne 382-402)

**Problème actuel**:
```dart
Duration _calculateRetryDelay(int attempt, RetryConfig config) {
  final exponentialDelay =
      config.initialDelay * (config.backoffMultiplier * (attempt - 1));  // ❌ BUG!

  // Résultat:
  // Attempt 1: initialDelay * (2.0 * 0) = 0ms ❌
  // Attempt 2: initialDelay * (2.0 * 1) = 2000ms
  // Attempt 3: initialDelay * (2.0 * 2) = 4000ms
}
```

**Correction**:
```dart
import 'dart:math';

Duration _calculateRetryDelay(int attempt, RetryConfig config) {
  // ✅ Proper exponential backoff: initialDelay * (multiplier ^ (attempt - 1))
  final exponentialMs = config.initialDelay.inMilliseconds *
      pow(config.backoffMultiplier, attempt - 1).toInt();

  // Cap to maxDelay
  final cappedMs = min(exponentialMs, config.maxDelay.inMilliseconds);

  // Add jitter (10% random variation to prevent thundering herd)
  final jitterMs = (cappedMs * 0.1 * Random().nextDouble()).toInt();

  return Duration(milliseconds: cappedMs + jitterMs);
}
```

**Temps estimé**: 30 minutes

---

## 🧪 Tests Critiques à Ajouter (Phase 1)

### Test #1: NetworkErrorClassifier

**Fichier**: `/workspace/mobile_app/test/unit/core/network/network_error_classifier_test.dart` (nouveau)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:async';

import 'package:edulift/core/network/network_error_classifier.dart';
import 'package:edulift/core/errors/exceptions.dart';
import 'package:edulift/core/errors/api_exception.dart';

void main() {
  group('NetworkErrorClassifier', () {
    group('isNetworkConnectivityError', () {
      test('should return true for SocketException', () {
        final error = SocketException('Network is unreachable');
        expect(NetworkErrorClassifier.isNetworkConnectivityError(error), true);
      });

      test('should return true for TimeoutException', () {
        final error = TimeoutException('Connection timeout');
        expect(NetworkErrorClassifier.isNetworkConnectivityError(error), true);
      });

      test('should return true for DioException with HTTP 0', () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 0,
          ),
        );
        expect(NetworkErrorClassifier.isNetworkConnectivityError(error), true);
      });

      test('should return true for DioException with null statusCode', () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionError,
        );
        expect(NetworkErrorClassifier.isNetworkConnectivityError(error), true);
      });

      test('should return false for HTTP 401 (auth error)', () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 401,
          ),
        );
        expect(NetworkErrorClassifier.isNetworkConnectivityError(error), false);
      });

      test('should return false for HTTP 500 (server error)', () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 500,
          ),
        );
        expect(NetworkErrorClassifier.isNetworkConnectivityError(error), false);
      });

      test('should return true for ApiException with HTTP 0', () {
        final error = ApiException(
          message: 'Connection failed',
          statusCode: 0,
        );
        expect(NetworkErrorClassifier.isNetworkConnectivityError(error), true);
      });

      test('should return false for ApiException with HTTP 404', () {
        final error = ApiException(
          message: 'Not found',
          statusCode: 404,
        );
        expect(NetworkErrorClassifier.isNetworkConnectivityError(error), false);
      });

      test('should return true for NetworkException', () {
        final error = NetworkException('Network error');
        expect(NetworkErrorClassifier.isNetworkConnectivityError(error), true);
      });
    });

    group('shouldUseCacheFallback', () {
      test('should return true for network errors', () {
        final error = SocketException('Network is unreachable');
        expect(NetworkErrorClassifier.shouldUseCacheFallback(error), true);
      });

      test('should return false for server errors', () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 500,
          ),
        );
        expect(NetworkErrorClassifier.shouldUseCacheFallback(error), false);
      });

      test('should return false for auth errors', () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 401,
          ),
        );
        expect(NetworkErrorClassifier.shouldUseCacheFallback(error), false);
      });
    });
  });
}
```

**Temps estimé**: 2 heures

---

### Test #2: UserFamilyService avec network error flag

**Fichier**: `/workspace/mobile_app/test/unit/core/services/user_family_service_test.dart` (nouveau)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edulift/core/services/user_family_service.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/domain/entities/family.dart';

import '../../../test_mocks/test_mocks.dart';

void main() {
  group('UserFamilyService - Network Error Handling', () {
    late ProviderContainer container;
    late MockFamilyRepository mockFamilyRepo;

    setUp(() {
      mockFamilyRepo = MockFamilyRepository();
      container = ProviderContainer(
        overrides: [
          familyRepositoryProvider.overrideWithValue(mockFamilyRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('should return false when network error occurs (not throw)', () async {
      // Arrange - Network error with is_network_error flag
      when(mockFamilyRepo.getCurrentFamily()).thenAnswer((_) async {
        return Result.err(
          ApiFailure(
            code: 'network.connection_failed',
            statusCode: 0,
            details: {
              'is_network_error': true,  // ✅ Network error flag
            },
          ),
        );
      });

      // Act
      final service = container.read(userFamilyServiceProvider);
      final result = await service.hasFamily('test-user-id');

      // Assert - Should return false, NOT throw
      expect(result, false);
    });

    test('should throw when auth error occurs (401 without network flag)', () async {
      // Arrange - Auth error WITHOUT network flag
      when(mockFamilyRepo.getCurrentFamily()).thenAnswer((_) async {
        return Result.err(
          ApiFailure(
            code: 'family.auth_failed',
            statusCode: 401,
            details: {
              'isAuthError': true,
              'is_network_error': false,  // ✅ NOT a network error
            },
          ),
        );
      });

      // Act & Assert - Should throw
      final service = container.read(userFamilyServiceProvider);
      expect(
        () => service.hasFamily('test-user-id'),
        throwsA(isA<Exception>()),
      );
    });

    test('should return false when 401 is caused by network error (with network flag)', () async {
      // Arrange - 401 but WITH network error flag (token check failed due to network)
      when(mockFamilyRepo.getCurrentFamily()).thenAnswer((_) async {
        return Result.err(
          ApiFailure(
            code: 'family.auth_failed',
            statusCode: 401,
            details: {
              'isAuthError': true,
              'is_network_error': true,  // ✅ Network error caused 401
            },
          ),
        );
      });

      // Act
      final service = container.read(userFamilyServiceProvider);
      final result = await service.hasFamily('test-user-id');

      // Assert - Should return false, NOT throw (network error has priority)
      expect(result, false);
    });
  });
}
```

**Temps estimé**: 1 heure

---

### Test #3: Integration E2E pour HTTP 0 → Cache Fallback → Dashboard

**Fichier**: `/workspace/mobile_app/test/integration/network_error_e2e_test.dart` (nouveau)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edulift/core/domain/entities/family.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/main.dart';
import 'package:edulift/core/presentation/pages/dashboard_page.dart';
import 'package:edulift/features/onboarding/presentation/pages/onboarding_wizard.dart';

import '../test_mocks/test_mocks.dart';

void main() {
  group('Network Error E2E Tests', () {
    testWidgets(
      'PRINCIPE 0: HTTP 0 with cache → Dashboard (NOT onboarding)',
      (tester) async {
        // Arrange
        final mockFamilyRepo = MockFamilyRepository();
        final cachedFamily = Family(
          id: 'cached-family-123',
          name: 'Cached Family',
          createdAt: DateTime.now().subtract(Duration(days: 1)),
          updatedAt: DateTime.now().subtract(Duration(days: 1)),
        );

        // Simulate: Network returns HTTP 0, cache fallback succeeds
        when(mockFamilyRepo.getCurrentFamily()).thenAnswer((_) async {
          // NetworkErrorHandler uses cache fallback
          return Result.ok(cachedFamily);
        });

        final container = ProviderContainer(
          overrides: [
            familyRepositoryProvider.overrideWithValue(mockFamilyRepo),
          ],
        );

        // Act - Start app
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const App(),
          ),
        );
        await tester.pumpAndSettle();

        // Assert - Should show Dashboard with cached data
        expect(
          find.byType(DashboardPage),
          findsOneWidget,
          reason: 'Should show Dashboard when cache is available (PRINCIPE 0)',
        );

        expect(
          find.byType(OnboardingWizard),
          findsNothing,
          reason: 'Should NOT redirect to onboarding when cache is available',
        );

        expect(
          find.text(cachedFamily.name),
          findsOneWidget,
          reason: 'Should display cached family data',
        );

        container.dispose();
      },
    );

    testWidgets(
      'Auth error (401) without network flag → Login redirect',
      (tester) async {
        // Arrange
        final mockFamilyRepo = MockFamilyRepository();

        // Simulate: Auth error (token expired) - NOT network error
        when(mockFamilyRepo.getCurrentFamily()).thenAnswer((_) async {
          return Result.err(
            ApiFailure(
              code: 'family.auth_failed',
              statusCode: 401,
              details: {
                'isAuthError': true,
                'is_network_error': false,
              },
            ),
          );
        });

        final container = ProviderContainer(
          overrides: [
            familyRepositoryProvider.overrideWithValue(mockFamilyRepo),
          ],
        );

        // Act - Start app
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const App(),
          ),
        );
        await tester.pumpAndSettle();

        // Assert - Should redirect to Login
        expect(
          find.byType(LoginPage),
          findsOneWidget,
          reason: 'Should redirect to login for genuine auth errors',
        );

        container.dispose();
      },
    );
  });
}
```

**Temps estimé**: 2 heures

---

## 📊 Résumé Phase 1

### Temps Total Estimé: 10 heures

| Action | Temps | Priorité |
|--------|-------|----------|
| Action #1: Corriger UserFamilyService | 30 min | CRITIQUE |
| Action #2: Créer NetworkErrorClassifier | 1h | CRITIQUE |
| Action #3: Mettre à jour NetworkErrorHandler | 1h | CRITIQUE |
| Action #4: Propager flag is_network_error | 1h | CRITIQUE |
| Action #5: Corriger FamilyRepository | 30 min | CRITIQUE |
| Action #6: Corriger exponential backoff | 30 min | CRITIQUE |
| Test #1: NetworkErrorClassifier | 2h | CRITIQUE |
| Test #2: UserFamilyService | 1h | CRITIQUE |
| Test #3: Integration E2E | 2h | CRITIQUE |

### Bénéfices Attendus

✅ **Conformité Principe 0**: Utilisateur peut toujours utiliser l'app avec cache
✅ **Classification cohérente**: Erreurs réseau vs erreurs serveur
✅ **Meilleure UX**: Pas de redirections inattendues
✅ **Code maintenable**: Logique centralisée et testée

---

## 🔄 Phase 2 (Optionnelle)

Voir le rapport complet pour les actions de Phase 2 :
- Stream-based cache-first
- Métriques de cache
- Tests d'intégration avancés
- Généralisation à tous les repositories

**Temps estimé Phase 2**: 20 heures

---

## ✅ Checklist de Validation

Avant de considérer la Phase 1 comme terminée, valider :

- [ ] NetworkErrorClassifier créé et testé
- [ ] NetworkErrorHandler utilise NetworkErrorClassifier
- [ ] Flag `is_network_error` propagé dans tous les ApiFailure
- [ ] UserFamilyService vérifie le flag avant de throw
- [ ] FamilyRepository préserve le flag dans les transformations
- [ ] Exponential backoff corrigé et testé
- [ ] Tests unitaires passent (NetworkErrorClassifier)
- [ ] Tests unitaires passent (UserFamilyService)
- [ ] Tests E2E passent (HTTP 0 → Dashboard)
- [ ] Tests E2E passent (Auth 401 → Login)
- [ ] Logs montrent classification correcte des erreurs
- [ ] App fonctionne en mode offline avec cache

---

## 📝 Notes d'Implémentation

### Important

1. **Ne pas casser les tests existants**: Les changements doivent être compatibles avec les tests actuels
2. **Logging exhaustif**: Ajouter des logs à chaque étape pour déboguer facilement
3. **Tester manuellement**: Vérifier en conditions réelles (avion mode, réseau lent, etc.)

### Ordre d'Implémentation Recommandé

1. Créer NetworkErrorClassifier (isolé, pas de dépendances)
2. Ajouter tests pour NetworkErrorClassifier
3. Mettre à jour NetworkErrorHandler pour l'utiliser
4. Corriger la propagation du flag is_network_error
5. Corriger UserFamilyService
6. Corriger FamilyRepository
7. Ajouter tests E2E
8. Valider manuellement

### Points de Vigilance

⚠️ **NetworkErrorClassifier doit être exhaustif** : Couvrir TOUS les cas d'erreur réseau
⚠️ **Flag is_network_error doit être préservé** : À travers toutes les transformations d'erreur
⚠️ **UserFamilyService doit vérifier le flag** : Avant de throw exception
⚠️ **Tests E2E doivent couvrir les scénarios réels** : HTTP 0, 401, 403, 404, 500

---

**FIN DU PLAN D'ACTION**
