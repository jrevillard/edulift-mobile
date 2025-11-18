#!/bin/bash
# scripts/build_unsigned_ios.sh
# Build iOS IPA without code signing

set -e

FLAVOR="${1:-staging}"
CONFIG_FILE="config/${FLAVOR}.json"

echo "🚀 Building unsigned iOS IPA for $FLAVOR"

# Verify configuration exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Configuration file $CONFIG_FILE not found"
    exit 1
fi
echo "✅ Configuration file found: $CONFIG_FILE"

# Get Flutter dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Install CocoaPods dependencies
echo "🍎 Installing CocoaPods dependencies..."
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..

# Update Flutter build configuration before code generation
echo "🔄 Updating Flutter build configuration..."
flutter build ios \
  --flavor "$FLAVOR" \
  --dart-define-from-file="$CONFIG_FILE" \
  --debug \
  --no-codesign \
  --verbose || echo "Debug build completed with expected code signing issues"

# Run code generation
echo "🔄 Running code generation..."
flutter pub run build_runner build --delete-conflicting-outputs

# Prepare Xcode project (disable code signing)
echo "⚙️  Configuring Xcode project for unsigned build..."
cd ios

# Backup original project
cp Runner.xcodeproj/project.pbxproj Runner.xcodeproj/project.pbxproj.backup

# Try to disable code signing (may not exist in Flutter projects)
echo "🔧 Attempting to disable code signing..."
code_signing_modified=false

# Check for existing patterns and modify them
if grep -q "CODE_SIGNING_REQUIRED = YES" Runner.xcodeproj/project.pbxproj; then
  sed -i.bak 's/CODE_SIGNING_REQUIRED = YES/CODE_SIGNING_REQUIRED = NO/g' Runner.xcodeproj/project.pbxproj
  code_signing_modified=true
  echo "✅ Found and disabled CODE_SIGNING_REQUIRED"
fi

if grep -q "CODE_SIGNING_ALLOWED = YES" Runner.xcodeproj/project.pbxproj; then
  sed -i.bak 's/CODE_SIGNING_ALLOWED = YES/CODE_SIGNING_ALLOWED = NO/g' Runner.xcodeproj/project.pbxproj
  code_signing_modified=true
  echo "✅ Found and disabled CODE_SIGNING_ALLOWED"
fi

if grep -q "DEVELOPMENT_TEAM = " Runner.xcodeproj/project.pbxproj; then
  sed -i.bak -e 's/DEVELOPMENT_TEAM = [^;]*/DEVELOPMENT_TEAM = ""/g' \
             -e 's/DEVELOPMENT_TEAM = "[^"]*"/DEVELOPMENT_TEAM = ""/g' \
             Runner.xcodeproj/project.pbxproj
  code_signing_modified=true
  echo "✅ Found and cleared DEVELOPMENT_TEAM"
fi

if grep -q "PROVISIONING_PROFILE_SPECIFIER = " Runner.xcodeproj/project.pbxproj; then
  sed -i.bak -e 's/PROVISIONING_PROFILE_SPECIFIER = [^;]*/PROVISIONING_PROFILE_SPECIFIER = ""/g' \
             -e 's/PROVISIONING_PROFILE_SPECIFIER = "[^"]*"/PROVISIONING_PROFILE_SPECIFIER = ""/g' \
             Runner.xcodeproj/project.pbxproj
  code_signing_modified=true
  echo "✅ Found and cleared PROVISIONING_PROFILE_SPECIFIER"
fi

# If no code signing settings were found, that's normal for Flutter projects
if [ "$code_signing_modified" = false ]; then
  echo "ℹ️  No code signing settings found (normal for Flutter project)"
fi

echo "✅ Xcode project preparation completed"

# Clean up temporary files
rm -f Runner.xcodeproj/project.pbxproj.backup
rm -f Runner.xcodeproj/project.pbxproj.bak

echo "✅ Xcode project configured for unsigned build"

# Build with xcodebuild
echo "🏗️  Building with xcodebuild..."

SCHEME="Runner"  # Use default scheme name instead of FLAVOR
CONFIGURATION="Release" # Use Release instead of Release-$FLAVOR
ARCHIVE_PATH="build/Runner.xcarchive"

# Clean previous builds
rm -rf build/

# Build archive
xcodebuild archive \
  -workspace Runner.xcworkspace \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -archivePath "$ARCHIVE_PATH" \
  -destination 'generic/platform=iOS' \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGN_ENTITLEMENTS="" \
  DEVELOPMENT_TEAM="" \
  PROVISIONING_PROFILE_SPECIFIER="" \
  | xcpretty || echo "xcodebuild completed with warnings"

# Check if archive was created
if [[ ! -d "$ARCHIVE_PATH" ]]; then
    echo "❌ Archive creation failed"
    # Restore backup if it exists
    if [[ -f "Runner.xcodeproj/project.pbxproj.backup" ]]; then
        mv Runner.xcodeproj/project.pbxproj.backup Runner.xcodeproj/project.pbxproj
        echo "✅ Restored original project file"
    fi
    exit 1
fi

echo "✅ Archive created successfully"

# 7. Create IPA manually from archive
echo "📦 Creating IPA from archive..."

IPA_DIR="build/ipa"
mkdir -p "$IPA_DIR"

# Extract app from archive
APP_PATH="$ARCHIVE_PATH/Products/Applications/Runner.app"

if [[ ! -d "$APP_PATH" ]]; then
    echo "❌ Runner.app not found in archive"
    echo "🔍 Archive contents:"
    find "$ARCHIVE_PATH" -name "*.app" -type d 2>/dev/null || echo "No .app found in archive"
    ls -la "$ARCHIVE_PATH/Products/" 2>/dev/null || echo "Products directory not found"
    # Restore backup if it exists
    if [[ -f "Runner.xcodeproj/project.pbxproj.backup" ]]; then
        mv Runner.xcodeproj/project.pbxproj.backup Runner.xcodeproj/project.pbxproj
        echo "✅ Restored original project file"
    fi
    exit 1
fi

# Create Payload structure
PAYLOAD_DIR="Payload"
rm -rf "$PAYLOAD_DIR"
mkdir -p "$PAYLOAD_DIR"

# Copy app to Payload
cp -R "$APP_PATH" "$PAYLOAD_DIR/"

# Create IPA
IPA_NAME="edulift-${FLAVOR}.ipa"
cd "$PAYLOAD_DIR"
zip -qr "../$IPA_NAME" .
cd ..

# Move IPA to output directory
mv "$IPA_NAME" "$IPA_DIR/"

# Cleanup
rm -rf "$PAYLOAD_DIR"

# Restore original project file if backup exists
if [[ -f "Runner.xcodeproj/project.pbxproj.backup" ]]; then
    mv Runner.xcodeproj/project.pbxproj.backup Runner.xcodeproj/project.pbxproj
    echo "✅ Restored original project file"
fi

# Back to root
cd ..

# 8. Verify IPA
IPA_FILE="ios/$IPA_DIR/$IPA_NAME"
if [[ -f "$IPA_FILE" ]]; then
    echo ""
    echo "✅ IPA created successfully!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📊 IPA Details:"
    ls -lh "$IPA_FILE"
    echo ""
    echo "📍 Location: $IPA_FILE"
    echo "📦 Size: $(du -h "$IPA_FILE" | cut -f1)"

    # Additional verification
    if unzip -t "$IPA_FILE" > /dev/null 2>&1; then
        echo "✅ IPA archive is valid"
    else
        echo "⚠️  Warning: IPA archive validation failed"
    fi
else
    echo "❌ Failed to create IPA"
    echo "📂 Available files:"
    find ios/build -name "*.ipa" 2>/dev/null || echo "No IPA files found"
    exit 1
fi

echo ""
echo "🎉 iOS IPA build completed successfully!"
echo "Ready for AltStore PAL distribution ✨"