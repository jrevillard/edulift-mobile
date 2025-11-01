#!/bin/bash
# Script pour générer automatiquement toutes les icônes Flutter

echo "🎨 Génération des icônes Edulift pour Flutter..."

# Créer les dossiers nécessaires
mkdir -p assets/icons

# Copier le logo de base
cp assets/icons/edulift-logo.svg assets/icons/edulift-logo.svg

# Convertir en PNG 1024x1024 pour flutter_launcher_icons
if command -v inkscape &> /dev/null; then
    echo "📱 Conversion avec Inkscape..."
    inkscape assets/icons/edulift-logo.svg --export-png=assets/icons/edulift-logo-1024.png -w 1024 -h 1024
elif command -v convert &> /dev/null; then
    echo "📱 Conversion avec ImageMagick..."
    convert assets/icons/edulift-logo.svg -resize 1024x1024 assets/icons/edulift-logo-1024.png
else
    echo "⚠️  Inkscape ou ImageMagick requis pour la conversion SVG->PNG"
    echo "Installez l'un d'eux puis relancez le script"
    exit 1
fi

# Générer toutes les icônes avec flutter_launcher_icons
echo "🚀 Génération des icônes pour toutes les plateformes..."
flutter pub get
flutter pub run flutter_launcher_icons:main

echo "✅ Icônes générées avec succès !"
echo "📁 Vérifiez les dossiers :"
echo "   - android/app/src/main/res/mipmap-*/"
echo "   - ios/Runner/Assets.xcassets/AppIcon.appiconset/"
echo "   - web/icons/"
echo "   - windows/runner/resources/"
echo "   - linux/icons/"
echo "   - macos/Runner/Assets.xcassets/AppIcon.appiconset/"