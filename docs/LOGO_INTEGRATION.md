# Intégration du Logo Edulift - Flutter

Ce dossier contient tous les assets nécessaires pour intégrer le nouveau logo Edulift dans l'application Flutter.

## 🎯 Logo Design

Le logo Edulift représente :
- **Lettre E** pour "Edulift"  
- **Voiture intégrée** symbolisant le covoiturage
- **Silhouettes de personnes** pour la communauté
- **Points de connexion** montrant le réseau entre voisins
- **Couleur bleue professionnelle** (#2563eb) suivant les bonnes pratiques UX

## 📱 Intégration Automatique (Recommandé)

### Étape 1 : Ajouter la dépendance
Ajoutez à votre `pubspec.yaml` :
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
```

### Étape 2 : Configurer les icônes
Ajoutez la configuration à votre `pubspec.yaml` (voir `pubspec_launcher_config.yaml`)

### Étape 3 : Ajouter les assets
Copiez les assets et ajoutez la configuration (voir `pubspec_assets_config.yaml`)

### Étape 4 : Générer
```bash
chmod +x tools/generate_icons.sh
./tools/generate_icons.sh
```

## 🔧 Intégration Manuelle

Si vous préférez l'intégration manuelle, suivez les instructions dans `conversion_instructions.md`.

## 🎨 Assets Inclus

- `assets/icons/edulift-logo.svg` - Logo vectoriel de base (1024x1024)
- `edulift-logo-1024.png` - Version PNG haute résolution (généré)

## 📁 Structure des fichiers après génération

```
android/app/src/main/res/
├── mipmap-mdpi/ic_launcher.png (48x48)
├── mipmap-hdpi/ic_launcher.png (72x72)  
├── mipmap-xhdpi/ic_launcher.png (96x96)
├── mipmap-xxhdpi/ic_launcher.png (144x144)
└── mipmap-xxxhdpi/ic_launcher.png (192x192)

ios/Runner/Assets.xcassets/AppIcon.appiconset/
├── Icon-App-20x20@1x.png (20x20)
├── Icon-App-20x20@2x.png (40x40)
├── [... toutes les tailles iOS]
└── Icon-App-1024x1024@1x.png (1024x1024)

web/icons/
├── Icon-192.png (192x192)
└── Icon-512.png (512x512)

windows/runner/resources/app_icon.ico
linux/icons/ (différentes tailles)
macos/Runner/Assets.xcassets/AppIcon.appiconset/ (tailles macOS)
```

## ✅ Vérification

Après génération, vérifiez :
1. ✅ Les icônes apparaissent dans l'IDE
2. ✅ `flutter pub get` s'exécute sans erreur  
3. ✅ `flutter build` génère sans erreur
4. ✅ L'icône apparaît sur l'appareil/simulateur

## 🎨 Utilisation dans l'app

Pour utiliser le logo dans votre code Flutter :
```dart
// Logo SVG (recommandé)
SvgPicture.asset(
  'assets/icons/edulift-logo.svg',
  width: 100,
  height: 100,
)

// Logo PNG si nécessaire
Image.asset(
  'assets/icons/edulift-logo-1024.png',
  width: 100,
  height: 100,
)
```

---

**Note**: Cette intégration couvre toutes les plateformes Flutter : Android, iOS, Web, Windows, Linux, et macOS.