# ✅ Checklist de test - Navigation des semaines du planning

## 📋 Tests manuels à effectuer

### ✅ Test 1: Swipe vers semaine suivante (DROITE)

**Étapes** :
1. Lancer l'application
2. Naviguer vers la page Schedule (Planning)
3. Vérifier que l'indicateur affiche "Semaine actuelle"
4. Noter les données affichées (véhicules, enfants, etc.)
5. **Swiper vers la DROITE** (geste de droite vers gauche sur l'écran)

**Résultats attendus** :
- ✅ Feedback haptique (vibration légère)
- ✅ L'indicateur change pour afficher "Semaine prochaine"
- ✅ Les données du planning changent (différentes de la semaine actuelle)
- ✅ Un indicateur de chargement apparaît brièvement
- ✅ Pas de crash ou d'erreur

**Status** : ⬜ À tester

---

### ✅ Test 2: Swipe vers semaine précédente (GAUCHE)

**Étapes** :
1. Depuis la semaine actuelle
2. **Swiper vers la GAUCHE** (geste de gauche vers droite sur l'écran)

**Résultats attendus** :
- ✅ Feedback haptique (vibration légère)
- ✅ L'indicateur change pour afficher "Semaine dernière"
- ✅ Les données du planning changent
- ✅ Un indicateur de chargement apparaît brièvement
- ✅ Pas de crash ou d'erreur

**Status** : ⬜ À tester

---

### ✅ Test 3: Swipe multiple vers le futur

**Étapes** :
1. Depuis la semaine actuelle
2. **Swiper 3 fois vers la DROITE** rapidement

**Résultats attendus** :
- ✅ Après 1 swipe : "Semaine prochaine"
- ✅ Après 2 swipes : "Dans 2 semaines"
- ✅ Après 3 swipes : "Dans 3 semaines"
- ✅ Les données sont cohérentes avec chaque semaine
- ✅ Pas de lag visible
- ✅ Pas de crash ou d'erreur

**Status** : ⬜ À tester

---

### ✅ Test 4: Swipe multiple vers le passé

**Étapes** :
1. Depuis la semaine actuelle
2. **Swiper 3 fois vers la GAUCHE** rapidement

**Résultats attendus** :
- ✅ Après 1 swipe : "Semaine dernière"
- ✅ Après 2 swipes : "Il y a 2 semaines"
- ✅ Après 3 swipes : "Il y a 3 semaines"
- ✅ Les données sont cohérentes avec chaque semaine
- ✅ Pas de lag visible
- ✅ Pas de crash ou d'erreur

**Status** : ⬜ À tester

---

### ✅ Test 5: Navigation aller-retour

**Étapes** :
1. Depuis la semaine actuelle
2. Swiper 2 fois vers la DROITE (→ "Dans 2 semaines")
3. Swiper 2 fois vers la GAUCHE (← retour à "Semaine actuelle")

**Résultats attendus** :
- ✅ L'indicateur revient à "Semaine actuelle"
- ✅ Les données affichées correspondent à la semaine actuelle
- ✅ Pas d'incohérence dans les données
- ✅ Pas de crash ou d'erreur

**Status** : ⬜ À tester

---

### ✅ Test 6: Swipe avec boutons de navigation

**Étapes** :
1. Depuis la semaine actuelle
2. Cliquer sur le bouton "→" (chevron droit) 2 fois
3. Vérifier l'indicateur et les données
4. Swiper vers la GAUCHE 1 fois
5. Vérifier la cohérence

**Résultats attendus** :
- ✅ Après 2 clics sur "→" : "Dans 2 semaines"
- ✅ Après 1 swipe ← : "Semaine prochaine"
- ✅ La navigation par boutons et par swipe est cohérente
- ✅ Pas de désynchronisation entre les deux modes

**Status** : ⬜ À tester

---

### ✅ Test 7: Transition d'année (si applicable)

**Note** : Ce test n'est applicable que si on est proche d'un changement d'année.

**Étapes** :
1. Si on est en semaine 52 (fin décembre)
2. Swiper vers la DROITE (semaine suivante)

**Résultats attendus** :
- ✅ L'indicateur affiche "Semaine prochaine"
- ✅ La semaine passe correctement de 2025-52 à 2026-01
- ✅ Les données sont chargées correctement
- ✅ Pas de crash lié au changement d'année

**Status** : ⬜ À tester (si applicable)

---

### ✅ Test 8: Performance avec swipe rapide

**Étapes** :
1. Depuis la semaine actuelle
2. **Swiper très rapidement** 10 fois vers la DROITE

**Résultats attendus** :
- ✅ L'application reste fluide
- ✅ Pas de lag ou de freeze
- ✅ L'indicateur se met à jour correctement
- ✅ Les données finales ("Dans 10 semaines") sont correctes
- ✅ Pas de requêtes API dupliquées (vérifier les logs)
- ✅ Pas de crash ou d'erreur

**Status** : ⬜ À tester

---

### ✅ Test 9: Vérification des données par créneau

**Étapes** :
1. Depuis la semaine actuelle
2. Noter les véhicules assignés sur un créneau spécifique (ex: Lundi matin)
3. Swiper vers la DROITE (semaine suivante)
4. Vérifier le même créneau (Lundi matin)

**Résultats attendus** :
- ✅ Les données du créneau sont différentes (ou vides si pas de planning)
- ✅ Les créneaux horaires restent les mêmes (ex: 08:00, 16:00)
- ✅ La structure du planning est cohérente
- ✅ Pas de données "fantômes" de la semaine précédente

**Status** : ⬜ À tester

---

### ✅ Test 10: Rechargement après modification

**Étapes** :
1. Depuis la semaine actuelle
2. Assigner un véhicule à un créneau
3. Swiper vers la DROITE (semaine suivante)
4. Swiper vers la GAUCHE (retour semaine actuelle)

**Résultats attendus** :
- ✅ Le véhicule assigné à l'étape 2 est toujours présent
- ✅ Les données sont à jour après le retour
- ✅ Pas de perte de données
- ✅ Pas de crash ou d'erreur

**Status** : ⬜ À tester

---

## 📊 Résumé des tests

**Total** : 10 tests
**Testés** : ⬜ 0 / 10
**Réussis** : ⬜ 0 / 10
**Échoués** : ⬜ 0 / 10

---

## 🐛 Bugs découverts

### Bug #1
**Description** : _À remplir si bug découvert_

**Étapes pour reproduire** :
1. ...
2. ...

**Résultat attendu** : ...
**Résultat observé** : ...

**Sévérité** : ⬜ Bloquant | ⬜ Majeur | ⬜ Mineur | ⬜ Cosmétique

**Status** : ⬜ À corriger | ⬜ En cours | ⬜ Corrigé

---

## 📝 Notes additionnelles

### Environnement de test
- **Appareil** : _À remplir (ex: iPhone 14, Pixel 7)_
- **OS** : _À remplir (ex: iOS 17.1, Android 14)_
- **Version Flutter** : _À remplir (ex: 3.24.0)_
- **Date du test** : _À remplir_

### Observations
_Espace pour notes générales sur les tests_

---

## ✅ Validation finale

Une fois tous les tests passés avec succès :

- ⬜ Tous les tests manuels réussis
- ⬜ Aucun bug bloquant découvert
- ⬜ Performance acceptable
- ⬜ UX fluide et intuitive
- ⬜ Pas de crash ou d'erreur

**Statut global** : ⬜ **VALIDÉ** | ⬜ **À RETRAVAILLER**

---

## 🚀 Prochaines étapes

Après validation :
1. ⬜ Merger la branche dans main
2. ⬜ Déployer en production
3. ⬜ Monitorer les retours utilisateurs
4. ⬜ Archiver cette checklist

---

**Testeur** : _À remplir_
**Date de validation** : _À remplir_
**Signature** : _À remplir_
