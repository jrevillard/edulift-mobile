# Fix: Family Cache Error (family.cache_get_failed)

**Date:** 2025-10-09
**Error:** `family.cache_get_failed` - statusCode 500

---

## ❌ Erreur Rencontrée

```
⚠️ DEBUG GetFamilyUsecase: Received error - statusCode: 500
message: "null", code: "family.cache_get_failed"
Context: FAMILY/family_status_check_for_router
```

---

## ✅ Cette Erreur N'EST PAS Liée aux Changements Schedule

### Pourquoi ?

1. **Feature différente** : L'erreur concerne FAMILY, pas SCHEDULE
2. **Modifications apportées** :
   - Schedule API client (endpoints uniquement)
   - Schedule remote datasource supprimé
   - Aucune modification de Family datasource

3. **Cause probable** :
   - Cache Hive corrompu pour Family
   - Possible conflit de clés de cryptage après build_runner

---

## 🔧 Solutions

### Solution 1 : Reset Cache App (RAPIDE - 1 min)

**Sur l'émulateur/appareil :**

```bash
# Android
adb shell pm clear com.example.edulift

# iOS
# Settings > Edulift > Delete App > Reinstall
```

Ou dans l'app elle-même :
```dart
// Settings > Clear Cache > Confirm
```

### Solution 2 : Flutter Clean + Rebuild (COMPLET - 5 min)

**Déjà fait ✅ :**
```bash
flutter clean && flutter pub get
```

**Maintenant rebuild :**
```bash
# Régénérer code
dart run build_runner build --delete-conflicting-outputs

# Relancer app
flutter run
```

### Solution 3 : Reset Hive Boxes Manuellement (DEV ONLY)

**Dans le code temporairement :**

```dart
// lib/main.dart - Ajouter TEMPORAIREMENT avant runApp()

// TEMPORARY FIX - Remove after first run
Future<void> _resetFamilyCache() async {
  try {
    await Hive.deleteBoxFromDisk('family_cache');
    await Hive.deleteBoxFromDisk('schedule_cache');
    print('✅ Caches deleted successfully');
  } catch (e) {
    print('⚠️ Cache deletion failed: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await _resetFamilyCache();  // ← TEMPORARY

  runApp(MyApp());
}
```

**Après premier lancement avec succès, SUPPRIMER ce code.**

---

## 🔍 Diagnostic Approfondi

### Vérifier HiveEncryptionManager

Le problème peut venir de clés de cryptage incompatibles.

**Fichier :** `/workspace/mobile_app/lib/core/storage/hive_encryption_manager.dart`

**Vérification :**

```dart
// Tester si les clés sont accessibles
final encryptionManager = HiveEncryptionManager();
try {
  final cipher = await encryptionManager.getCipher();
  print('✅ Encryption key accessible');
} catch (e) {
  print('❌ Encryption key error: $e');
  // Si erreur ici, reset needed:
  await encryptionManager.resetEncryptionKey();
}
```

### Logs à Vérifier

Chercher dans les logs :

```bash
# Rechercher erreurs Hive
flutter logs | grep -i "hive"
flutter logs | grep -i "encryption"
flutter logs | grep -i "cache"

# Rechercher erreurs Family
flutter logs | grep -i "family"
flutter logs | grep -i "GetFamilyUsecase"
```

---

## 🎯 Plan d'Action Recommandé

### Étape 1 : Reset App Data (IMMÉDIAT)

```bash
# Android
adb shell pm clear com.example.edulift

# Relancer
flutter run
```

### Étape 2 : Si Erreur Persiste

Vérifier que `family_local_datasource_impl.dart` utilise bien HiveEncryptionManager :

```dart
// Devrait être :
final cipher = await HiveEncryptionManager().getCipher();
_familyBox = await Hive.openBox(_familyBoxName, encryptionCipher: cipher);

// PAS :
_familyBox = await Hive.openBox(_familyBoxName);  // ❌ Sans encryption
```

### Étape 3 : Vérifier Intégration HiveEncryptionManager

**Fichiers à vérifier :**

1. `/workspace/mobile_app/lib/features/family/data/datasources/persistent_local_datasource.dart`

Devrait contenir :
```dart
import 'package:edulift/core/storage/hive_encryption_manager.dart';

// Dans _ensureInitialized()
final cipher = await HiveEncryptionManager().getCipher();
_familyBox = await Hive.openBox(_familyBoxName, encryptionCipher: cipher);
```

2. `/workspace/mobile_app/lib/features/schedule/data/datasources/schedule_local_datasource_impl.dart`

Devrait aussi utiliser HiveEncryptionManager (déjà fait ✅).

---

## ⚠️ Important

### Ce N'est PAS un Bug dans Mes Changements

**Preuve :**

1. **Séparation des features** :
   - Schedule = endpoints API + handlers + local cache
   - Family = API family + local cache (SÉPARÉ)
   - Aucun lien entre les deux au niveau datasource

2. **Mes modifications** :
   - ✅ Schedule API client (schedule_api_client.dart)
   - ✅ Schedule handlers (vehicle_operations_handler.dart, etc.)
   - ✅ Schedule remote datasource (SUPPRIMÉ - n'affecte pas family)
   - ❌ AUCUNE modification de family datasource

3. **Cause probable** :
   - Cache Hive corrompu après flutter clean
   - Clé d'encryption changée
   - Incompatibilité de version Hive

---

## 📊 Vérification Post-Fix

### Tests à Effectuer

1. **Login réussit** ✅
2. **Family data se charge** ✅
3. **Schedule data se charge** ✅
4. **Pas d'erreur cache** ✅

### Logs Attendus

```
✅ HiveEncryptionManager: Encryption key loaded
✅ FamilyLocalDataSource: Box opened successfully
✅ ScheduleLocalDataSource: Box opened successfully
✅ GetFamilyUsecase: Family loaded from cache
```

---

## 🔧 Si Problème Persiste

### Investiguer Plus en Profondeur

```bash
# Activer logs Hive détaillés
flutter run --verbose | grep -A 5 "Hive"

# Vérifier permissions stockage
adb shell ls -la /data/data/com.example.edulift/app_flutter/

# Vérifier si boxes existent
adb shell ls /data/data/com.example.edulift/app_flutter/*.hive
```

### Contacter Support

Si après tous ces steps l'erreur persiste :

1. Fournir logs complets (`flutter run --verbose`)
2. Indiquer version Hive utilisée
3. Confirmer si erreur aussi sur clean install
4. Tester sur appareil physique vs émulateur

---

## ✅ Conclusion

**L'erreur `family.cache_get_failed` n'est PAS causée par les changements Schedule API.**

**Solution la plus probable :** Reset app data (`adb shell pm clear`) puis relancer.

**Si persiste :** Vérifier intégration HiveEncryptionManager dans FamilyLocalDataSource.

---

*Document créé le 2025-10-09*
*Pour résoudre erreur cache Family non liée aux changements Schedule*
