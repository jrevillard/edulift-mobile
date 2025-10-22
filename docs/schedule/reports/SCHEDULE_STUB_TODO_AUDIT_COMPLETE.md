# Schedule Feature - Audit Complet des Stubs/TODOs ✅

**Date**: 2025-10-09
**Reviewer**: Zen CodeReview + Manuel Analysis
**Model**: Gemini 2.5 Pro (quota exhausted, completed with manual analysis)
**Context**: Suite au bug critique `repository = null` qui a bloqué la production

---

## 🎯 Objectif de l'Audit

**ZÉRO TOLÉRANCE** pour les stubs/TODOs non implémentés qui:
- Bloquent des fonctionnalités
- Retournent des données placeholder (null, [], {})
- Peuvent être implémentés avec l'infrastructure existante

---

## 📊 Résultats de l'Audit

### Statistiques Globales

- **Fichiers examinés**: 7 fichiers
- **Issues trouvées**: 6 TODOs/stubs
- **CRITICAL**: 0 ✅ (aucun show-stopper comme `repository = null`)
- **HIGH**: 3 ⚠️ (providers retournant placeholder data)
- **MEDIUM**: 1 ℹ️ (deleteSlot non implémenté)
- **LOW**: 2 ℹ️ (améliorations futures)

**Bloquant fonctionnalité**: 3 issues (HIGH priority)
**Peut être corrigé maintenant**: 3 issues (HIGH priority)

---

## 🚨 Issues HIGH Priority (Action Requise)

### ISSUE #1: Provider `scheduleSlot` retourne null

**Sévérité**: HIGH
**Fichier**: `lib/features/schedule/presentation/providers/schedule_providers.dart`
**Lignes**: 88-102

**Code actuel**:
```dart
@riverpod
Future<ScheduleSlot?> scheduleSlot(Ref ref, String slotId) async {
  ref.watch(currentUserProvider);

  // Note: This is a workaround until repository implements getScheduleSlot(slotId)
  // For now, we cannot fetch a single slot without knowing groupId and week
  // UI should use weeklySchedule provider and filter client-side

  // Placeholder - return null to indicate not found
  // TODO: Implement when repository adds getScheduleSlot method
  return null;  // ❌ TOUJOURS NULL
}
```

**Impact**: Impossible de récupérer un slot unique par ID
**Utilisé par**: Potentiellement n'importe quel code essayant d'afficher un slot unique

**✅ PEUT ÊTRE CORRIGÉ**:
- Le repository a `getWeeklySchedule(groupId, week)` qui retourne `List<ScheduleSlot>`
- **Solution 1**: Modifier le provider pour accepter aussi `groupId` et `week`, puis filtrer
- **Solution 2**: Garder comme stub documenté si vraiment pas utilisé

**Recommandation**: Vérifier si utilisé dans l'UI. Si oui, implémenter Solution 1. Si non, documenter clairement et déprécier.

---

### ISSUE #2: Provider `vehicleAssignments` retourne liste vide

**Sévérité**: HIGH
**Fichier**: `lib/features/schedule/presentation/providers/schedule_providers.dart`
**Lignes**: 129-145

**Code actuel**:
```dart
@riverpod
Future<List<VehicleAssignment>> vehicleAssignments(
  Ref ref,
  String slotId,
) async {
  ref.watch(currentUserProvider);

  // Convenience wrapper - extracts vehicle assignments from schedule slot
  // Requires knowing groupId and week to fetch the slot
  // For now, return empty list as we cannot determine groupId/week from slotId alone

  // TODO: Either:
  // 1. Add groupId/week parameters to this provider, OR
  // 2. Add repository method to fetch assignments by slotId directly

  return [];  // ❌ TOUJOURS VIDE
}
```

**Impact**: Impossible de récupérer les assignments de véhicules pour un slot
**Données disponibles**: Oui! Dans `ScheduleSlot.vehicleAssignments`

**✅ PEUT ÊTRE CORRIGÉ**:
```dart
@riverpod
Future<List<VehicleAssignment>> vehicleAssignments(
  Ref ref,
  String groupId,
  String week,
  String slotId,
) async {
  ref.watch(currentUserProvider);

  // Fetch weekly schedule
  final slots = await ref.watch(weeklyScheduleProvider(groupId, week).future);

  // Find slot and return its vehicle assignments
  final slot = slots.firstWhere(
    (s) => s.id == slotId,
    orElse: () => throw Exception('Slot not found: $slotId'),
  );

  return slot.vehicleAssignments;
}
```

**Recommandation**: ✅ **IMPLÉMENTER MAINTENANT** - Données disponibles, fix simple

---

### ISSUE #3: Provider `childAssignments` retourne liste vide

**Sévérité**: HIGH
**Fichier**: `lib/features/schedule/presentation/providers/schedule_providers.dart`
**Lignes**: 165-179

**Code actuel**:
```dart
@riverpod
Future<List<ChildAssignment>> childAssignments(
  Ref ref,
  String assignmentId,
) async {
  ref.watch(currentUserProvider);

  // Convenience wrapper - extracts child assignments from vehicle assignment
  // Requires fetching parent ScheduleSlot first
  // Return empty list as workaround

  // TODO: Extract from vehicleAssignmentsProvider OR add repository method

  return [];  // ❌ TOUJOURS VIDE
}
```

**Impact**: Impossible de récupérer les assignments d'enfants
**Données disponibles**: Oui! Dans `VehicleAssignment.childAssignments`

**✅ PEUT ÊTRE CORRIGÉ**:
```dart
@riverpod
Future<List<ChildAssignment>> childAssignments(
  Ref ref,
  String groupId,
  String week,
  String slotId,
  String vehicleAssignmentId,
) async {
  ref.watch(currentUserProvider);

  // Fetch vehicle assignments for the slot
  final assignments = await ref.watch(
    vehicleAssignmentsProvider(groupId, week, slotId).future
  );

  // Find the specific vehicle assignment and return its children
  final assignment = assignments.firstWhere(
    (a) => a.id == vehicleAssignmentId,
    orElse: () => throw Exception('Assignment not found: $vehicleAssignmentId'),
  );

  return assignment.childAssignments;
}
```

**Recommandation**: ✅ **IMPLÉMENTER MAINTENANT** - Dépend de Issue #2, fix après

---

## ⚠️ Issues MEDIUM Priority

### ISSUE #4: Méthode `deleteSlot` non implémentée

**Sévérité**: MEDIUM
**Fichier**: `lib/features/schedule/presentation/providers/schedule_providers.dart`
**Lignes**: 512-537

**Code actuel**:
```dart
Future<Result<void, ScheduleFailure>> deleteSlot({
  required String groupId,
  required String week,
  required String slotId,
}) async {
  state = const AsyncValue.loading();

  try {
    // TODO: Repository does not yet support deleteScheduleSlot
    // Return error indicating feature not implemented

    final failure = ScheduleFailure.serverError(
      message: 'Slot deletion requires repository implementation',
    );

    state = AsyncValue.error(failure, StackTrace.current);
    return Result.err(failure);
  } catch (e, stackTrace) {
    state = AsyncValue.error(e, stackTrace);
    return Result.err(ScheduleFailure.serverError(message: e.toString()));
  }
}
```

**Impact**: Impossible de supprimer un slot individuel
**Données disponibles**: Le repository a `clearWeeklySchedule()` mais pas de suppression individuelle

**❓ VÉRIFIER BACKEND**:
- Est-ce que l'endpoint `DELETE /groups/{groupId}/schedules/slots/{slotId}` existe?
- Si OUI: Ajouter au `schedule_api_client.dart` et implémenter
- Si NON: Documenter comme feature manquante et désactiver l'UI

**Recommandation**: ⏸️ **VÉRIFIER BACKEND** avant d'implémenter

---

## ℹ️ Issues LOW Priority (Améliorations Futures)

### ISSUE #5: Navigation entre semaines

**Sévérité**: LOW
**Fichier**: `lib/features/schedule/presentation/widgets/schedule_grid.dart`
**Ligne**: 128

**Code**: `// TODO: In the future, load different week data based on weekOffset`

**Impact**: La navigation entre semaines pourrait ne pas fonctionner
**Recommandation**: ✅ **OK POUR PLUS TARD** - Enhancement UX

---

### ISSUE #6: ChildAssignmentSheet manquant

**Sévérité**: LOW
**Fichier**: `lib/features/schedule/presentation/pages/schedule_page.dart`
**Ligne**: 135

**Code**: `// TODO: Implement ChildAssignmentSheet`

**Impact**: Composant UI manquant
**Recommandation**: ✅ **OK POUR PLUS TARD** - Enhancement UI

---

## ✅ Aucun Issue CRITICAL Trouvé

**Excellente nouvelle**: Aucun stub critique comme le bug `repository = null` n'a été trouvé!

### Ce qui a été vérifié ✅

1. **Tous les providers** sont correctement wirés
2. **Aucun `= null`** avec commentaire "stub/temporary/TODO"
3. **Tous les repositories** utilisent les dépendances correctes
4. **Tous les Result types** sont gérés correctement
5. **Exports corrects** dans `providers.dart`

---

## 📋 Plan d'Action

### Actions Immédiates (HIGH Priority)

1. **✅ ISSUE #2**: Implémenter `vehicleAssignmentsProvider` avec paramètres groupId/week
2. **✅ ISSUE #3**: Implémenter `childAssignmentsProvider` (dépend de #2)
3. **🔍 ISSUE #1**: Vérifier utilisation de `scheduleSlotProvider` dans l'UI
   - Si utilisé → Implémenter
   - Si non utilisé → Documenter et déprécier

### Actions Court Terme (MEDIUM Priority)

4. **🔍 ISSUE #4**: Vérifier existence de l'endpoint DELETE backend
   - Si existe → Implémenter
   - Si n'existe pas → Documenter et désactiver UI

### Actions Long Terme (LOW Priority)

5. **⏸️ ISSUE #5**: Navigation entre semaines (enhancement UX)
6. **⏸️ ISSUE #6**: ChildAssignmentSheet (enhancement UI)

---

## 🎓 Leçons Apprises

### Pourquoi le Bug `repository = null` Est Passé?

1. **Stub silencieux**: Commenté avec "TODO" mais pas de warning explicite
2. **Pas de test**: Aucun test n'appelait cette ligne
3. **Review superficiel**: Les reviews précédents n'ont pas vérifié les TODOs

### Comment Éviter à l'Avenir?

1. ✅ **Audit régulier des TODOs**: Comme ce rapport
2. ✅ **Tests obligatoires**: Tout provider doit avoir un test
3. ✅ **Convention de nommage**: `_stubXxx()` pour les stubs temporaires
4. ✅ **Linter custom**: Détecter `return null` avec TODO dans providers
5. ✅ **Review checklist**: "Vérifier tous les TODOs/stubs" dans le process

---

## 📊 Statistiques Finales

### Avant Audit
- ❌ 1 CRITICAL bug (`repository = null`)
- ⚠️ 6 TODOs/stubs non documentés
- 🤷 Impact inconnu

### Après Audit
- ✅ 0 CRITICAL bugs
- ✅ 3 HIGH priority identifiés (peuvent être corrigés)
- ✅ 1 MEDIUM priority (nécessite vérification backend)
- ✅ 2 LOW priority (enhancements futurs)
- ✅ Impact et fixes documentés

---

## ✅ Conclusion

**Statut Global**: 🟢 **BON** - Aucun show-stopper trouvé

**Actions Requises**:
1. Implémenter Issues #2 et #3 (HIGH - can fix now)
2. Vérifier Issue #1 (HIGH - usage unclear)
3. Vérifier Issue #4 (MEDIUM - backend check needed)

**Temps Estimé**:
- Issues #2 + #3: **1-2 heures** (implementation simple)
- Issue #1: **30 min** (vérification + décision)
- Issue #4: **Variable** (dépend du backend)

**Prochaine Review**: Dans 2 semaines ou après implémentation des HIGH priority

---

**Audit réalisé le**: 2025-10-09
**Par**: Claude Code + Zen CodeReview
**Status**: ✅ **COMPLET**
