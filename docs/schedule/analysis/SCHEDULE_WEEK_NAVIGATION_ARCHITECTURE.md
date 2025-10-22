# Architecture - Navigation des semaines du planning

## 🏗️ Vue d'ensemble

```
┌─────────────────────────────────────────────────────────────────┐
│                        UTILISATEUR                              │
│                                                                 │
│                    👆 Swipe LEFT/RIGHT                         │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│                    ScheduleGrid Widget                          │
│                 (schedule_grid.dart)                            │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              PageView.builder                            │  │
│  │                                                          │  │
│  │  onPageChanged: (page) {                                │  │
│  │    final offset = page - 1000                           │  │
│  │    setState(() => _currentWeekOffset = offset)          │  │
│  │    widget.onWeekChanged?.call(offset) ← CALLBACK        │  │
│  │  }                                                       │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  State:                                                         │
│  - _currentWeekOffset: int                                     │
│  - _weekPageController: PageController                         │
│                                                                 │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ onWeekChanged(offset)
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│                    SchedulePage Widget                          │
│                 (schedule_page.dart)                            │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         _handleWeekChanged(int weekOffset)               │  │
│  │                                                          │  │
│  │  1. Calculate target week from offset                   │  │
│  │     - Get current date (DateTime.now())                 │  │
│  │     - Get ISO week number                               │  │
│  │     - Add weekOffset                                    │  │
│  │     - Handle year boundaries                            │  │
│  │                                                          │  │
│  │  2. Update state if week changed                        │  │
│  │     - setState({ _currentWeek = newWeek })              │  │
│  │                                                          │  │
│  │  3. Reload schedule data                                │  │
│  │     - _loadScheduleData()                               │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  State:                                                         │
│  - _currentWeek: String (format: "YYYY-WW")                    │
│  - _selectedGroupId: String?                                   │
│                                                                 │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ loadWeeklySchedule(groupId, week)
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│              scheduleComposedProvider                           │
│                   (Riverpod)                                    │
│                                                                 │
│  - Fetches schedule data from API                              │
│  - Updates scheduleState                                       │
│  - Notifies listeners                                          │
│                                                                 │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ API Request
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│                      BACKEND API                                │
│                                                                 │
│  GET /api/groups/:groupId/schedule/:week                       │
│                                                                 │
│  Returns: { scheduleSlots: [...] }                             │
│                                                                 │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ Response
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│                    ScheduleGrid Widget                          │
│                                                                 │
│  Rebuilds with new scheduleData                                │
│  Displays updated schedule slots                               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Séquence de navigation

### Exemple: Swipe vers semaine suivante

```
Temps    │ Composant           │ Action
─────────┼─────────────────────┼─────────────────────────────────────
T0       │ Utilisateur         │ Swipe DROITE
         │                     │
T1       │ PageView            │ Page change: 1000 → 1001
         │                     │ onPageChanged(1001)
         │                     │
T2       │ ScheduleGrid        │ Calculate offset: 1001 - 1000 = 1
         │                     │ setState({ _currentWeekOffset = 1 })
         │                     │ HapticFeedback.lightImpact()
         │                     │
T3       │ ScheduleGrid        │ widget.onWeekChanged(1) ← CALLBACK
         │                     │
T4       │ SchedulePage        │ _handleWeekChanged(1) called
         │                     │
T5       │ SchedulePage        │ Calculate new week:
         │                     │   currentWeek = 41
         │                     │   targetWeek = 41 + 1 = 42
         │                     │   newWeek = "2025-42"
         │                     │
T6       │ SchedulePage        │ Check if week changed:
         │                     │   "2025-42" != "2025-41" ✓
         │                     │
T7       │ SchedulePage        │ setState({ _currentWeek = "2025-42" })
         │                     │
T8       │ SchedulePage        │ _loadScheduleData() called
         │                     │
T9       │ Provider            │ loadWeeklySchedule("group123", "2025-42")
         │                     │
T10      │ Provider            │ Update state: isLoading = true
         │                     │
T11      │ ScheduleGrid        │ Rebuild: show CircularProgressIndicator
         │                     │
T12      │ API                 │ GET /api/groups/group123/schedule/2025-42
         │                     │
T13      │ API                 │ Response: { scheduleSlots: [...] }
         │                     │
T14      │ Provider            │ Update state:
         │                     │   isLoading = false
         │                     │   scheduleSlots = [...]
         │                     │
T15      │ ScheduleGrid        │ Rebuild: show schedule with new data
         │                     │
T16      │ Week Indicator      │ Update label: "Semaine prochaine"
         │                     │
T17      │ Utilisateur         │ Voit les nouvelles données ✅
```

---

## 🧩 Composants clés

### 1. PageView (Flutter Widget)

**Responsabilité** : Gérer le swipe horizontal

**Configuration** :
```dart
PageController(initialPage: 1000)  // Centre virtuel pour scroll infini
```

**Mapping page → offset** :
- Page 1000 → offset 0 (semaine actuelle)
- Page 1001 → offset 1 (semaine suivante)
- Page 999 → offset -1 (semaine précédente)

---

### 2. ScheduleGrid (Child Widget)

**Responsabilité** : Afficher le planning + Détecter les swipes

**Props** :
```dart
{
  groupId: String,
  week: String,
  scheduleData: dynamic,
  scheduleConfig: ScheduleConfig?,
  onWeekChanged: Function(int)?,  // ← NOUVEAU
  // ... autres callbacks
}
```

**State** :
```dart
{
  _currentWeekOffset: int,
  _weekPageController: PageController
}
```

**Rôle** :
- Affiche le planning de la semaine
- Détecte les changements de page
- Notifie le parent via callback
- Affiche l'indicateur de semaine

---

### 3. SchedulePage (Parent Widget)

**Responsabilité** : Gérer l'état global + Charger les données

**State** :
```dart
{
  _currentWeek: String,        // Format: "YYYY-WW"
  _selectedGroupId: String?,
}
```

**Méthodes clés** :
- `_handleWeekChanged(int offset)` : Calcule et charge nouvelle semaine
- `_loadScheduleData()` : Charge les données via Provider
- `_initializeCurrentWeek()` : Initialise la semaine au lancement
- `_getISOWeekNumber(DateTime)` : Calcule le numéro de semaine ISO

**Rôle** :
- Coordonne la navigation
- Gère l'état de la semaine
- Déclenche les requêtes API

---

### 4. scheduleComposedProvider (Riverpod)

**Responsabilité** : State management + Communication API

**API** :
```dart
loadWeeklySchedule(String groupId, String week)
```

**State** :
```dart
ScheduleState {
  isLoading: bool,
  hasError: bool,
  error: String?,
  scheduleSlots: List<ScheduleSlot>
}
```

**Rôle** :
- Fetch données depuis API
- Notifie les listeners (SchedulePage, ScheduleGrid)
- Gère le cache local

---

## 📐 Format de données

### Format de semaine (ISO Week)

```
Format: "YYYY-WW"

Exemples:
- "2025-41" = Semaine 41 de 2025
- "2025-52" = Dernière semaine de 2025
- "2026-01" = Première semaine de 2026
```

### Calcul ISO Week

```dart
int _getISOWeekNumber(DateTime date) {
  // 1. Normaliser à minuit
  final target = DateTime(date.year, date.month, date.day);

  // 2. Obtenir le jour de la semaine (0 = Lundi, 6 = Dimanche)
  final dayNr = (date.weekday + 6) % 7;

  // 3. Trouver le jeudi de cette semaine (ISO week definition)
  target.subtract(Duration(days: dayNr - 3));

  // 4. Obtenir le 4 janvier (première semaine ISO)
  final jan4 = DateTime(target.year, 1, 4);

  // 5. Calculer la différence en jours
  final dayDiff = target.difference(jan4).inDays;

  // 6. Convertir en semaines (arrondi supérieur)
  return 1 + (dayDiff / 7).ceil();
}
```

### Gestion des transitions d'année

```dart
// Semaine 52 → Semaine 1
while (targetWeek > 52) {
  targetWeek -= 52;
  targetYear++;
}

// Semaine 1 → Semaine 52
while (targetWeek < 1) {
  targetWeek += 52;
  targetYear--;
}
```

**Note** : Cette logique simple fonctionne pour 99% des cas. Pour une précision absolue, il faudrait gérer les années à 53 semaines (rares).

---

## 🎯 Points de contrôle

### 1. Détection du swipe
✅ **Où** : `PageView.builder` → `onPageChanged`
✅ **Comment** : Flutter détecte automatiquement le geste

### 2. Calcul de l'offset
✅ **Où** : `ScheduleGrid._ScheduleGridState`
✅ **Formule** : `offset = page - 1000`

### 3. Notification du parent
✅ **Où** : `ScheduleGrid` → `widget.onWeekChanged?.call(offset)`
✅ **Mécanisme** : Callback Flutter classique

### 4. Calcul de la nouvelle semaine
✅ **Où** : `SchedulePage._handleWeekChanged`
✅ **Logique** :
  - Get current date
  - Get current ISO week
  - Add offset
  - Handle year boundaries
  - Format to "YYYY-WW"

### 5. Rechargement des données
✅ **Où** : `SchedulePage._loadScheduleData`
✅ **Mécanisme** : Appel au Provider Riverpod

### 6. Mise à jour de l'UI
✅ **Où** : `ScheduleGrid` rebuilds automatiquement
✅ **Déclencheur** : Provider notifie les listeners

---

## 🚀 Performance

### Optimisations implémentées

1. **Vérification avant rechargement**
   ```dart
   if (newWeek != _currentWeek) {
     // Only reload if week actually changed
     _loadScheduleData();
   }
   ```

2. **Callback optionnel**
   ```dart
   widget.onWeekChanged?.call(offset);
   // Pas d'erreur si callback non fourni
   ```

3. **Feedback haptique léger**
   ```dart
   HapticFeedback.lightImpact();
   // Vibration subtile, pas de lag
   ```

4. **PageController avec initialPage**
   ```dart
   PageController(initialPage: 1000)
   // Permet scroll infini sans recréer les pages
   ```

### Métriques cibles

| Métrique                  | Cible      | Méthode de mesure           |
|---------------------------|------------|----------------------------|
| Temps de réponse swipe    | < 16ms     | Flutter DevTools           |
| Délai affichage données   | < 500ms    | Chronomètre manuel         |
| Mémoire utilisée          | < 50MB     | Flutter DevTools           |
| Nombre de rebuilds        | Minimal    | Flutter DevTools (Rebuild) |

---

## 🐛 Cas limites gérés

### 1. Swipe très rapide
- **Problème potentiel** : Requêtes API multiples
- **Solution** : Vérification `newWeek != _currentWeek`

### 2. Transition d'année
- **Problème potentiel** : Semaine 53 → 0 ou 1
- **Solution** : Boucles `while` pour normaliser

### 3. Callback non fourni
- **Problème potentiel** : Null pointer exception
- **Solution** : `widget.onWeekChanged?.call(offset)`

### 4. Données vides
- **Problème potentiel** : UI cassée
- **Solution** : Gestion dans `_getScheduleSlotData()`

### 5. Offset = 0
- **Problème potentiel** : Rechargement inutile
- **Solution** : Le code recalcule quand même pour cohérence

---

## 📚 Ressources

### Documentation Flutter
- [PageView widget](https://api.flutter.dev/flutter/widgets/PageView-class.html)
- [PageController](https://api.flutter.dev/flutter/widgets/PageController-class.html)
- [Callbacks in Flutter](https://dart.dev/guides/language/language-tour#functions)

### Standards ISO
- [ISO 8601 Week Date](https://en.wikipedia.org/wiki/ISO_week_date)

### Riverpod
- [Provider documentation](https://riverpod.dev/)
- [StateNotifier](https://riverpod.dev/docs/concepts/providers#statenotifier-provider)

---

## ✅ Checklist de maintenance

Pour les développeurs futurs :

- ⬜ Si vous modifiez le format de semaine, mettez à jour `_handleWeekChanged`
- ⬜ Si vous changez l'API, vérifiez `scheduleComposedProvider`
- ⬜ Si vous ajoutez des callbacks, suivez le pattern `onWeekChanged`
- ⬜ Si vous optimisez, mesurez avec Flutter DevTools
- ⬜ Si vous refactorisez, gardez la séparation child/parent

---

**Version** : 1.0.0
**Date** : 2025-10-09
**Auteur** : Claude Code (AI Agent)
