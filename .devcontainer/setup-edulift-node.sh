#!/bin/bash

# EduLift DevContainer Setup Script
# Installs all E2E testing dependencies with node privileges

set -e

# Switch to node user for remaining operations
echo "👤 Switching to node user for application setup..."

# Navigate to workspace
cd /workspace

# Install Flutter if not already present
if [ ! -d "/workspace/.devcontainer/flutter" ]; then
    echo "📱 Installing Flutter..."
    cd /workspace/.devcontainer
    git clone https://github.com/flutter/flutter.git -b stable
    cd /workspace
    
    echo "🔍 Running Flutter doctor..."
    flutter doctor --android-licenses || true
    flutter doctor
else
    echo "📱 Flutter already installed"
    cd /workspace
    echo "🔍 Running Flutter doctor..."
    flutter doctor
fi

echo "📱 Adroid SDK: fetching emulator / image"
sdkmanager "system-images;android-33;google_apis;x86_64" "platforms;android-33"
echo "no" | avdmanager create avd -n flutter_emulator -k "system-images;android-33;google_apis;x86_64" --device "pixel_4"

# Setup EduLift protocol handler for deep links
echo "🔗 Setting up EduLift protocol handler..."
mkdir -p ~/.local/share/applications
cp /workspace/.devcontainer/edulift-handler.desktop ~/.local/share/applications/
update-desktop-database ~/.local/share/applications/ 2>/dev/null || true
xdg-mime default edulift-handler.desktop x-scheme-handler/edulift

# Load helper functions in shell profile
if ! grep -q "edulift-helper.sh" ~/.zshrc; then
    echo "# EduLift helper functions" >> ~/.zshrc
    echo "source /workspace/.devcontainer/edulift-helper.sh" >> ~/.zshrc
fi

echo "✅ EduLift protocol handler configured"

# Install Flutter dependencies for mobile_app
if [ -f "pubspec.yaml" ]; then
    echo "📱 Installing Flutter mobile app dependencies..."
    dart --disable-analytics
    dart pub global activate patrol_cli
    flutter pub get
    flutter pub run build_runner build --delete-conflicting-outputs
    
    cd ..
fi

# Install uvx
curl -LsSf https://astral.sh/uv/install.sh | sh

echo "✅ DevContainer setup completed successfully!"
echo ""
