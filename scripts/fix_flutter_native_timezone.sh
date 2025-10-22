#!/bin/bash
# Fix flutter_native_timezone compatibility with AGP 8.0+
#
# This script patches flutter_native_timezone 2.0.0 to work with modern Android Gradle Plugin
# by completely rewriting the build.gradle with proper AGP 8.0+ configuration.
#
# Issue: https://github.com/pinkfish/flutter_native_timezone/issues/XX
#
# Run this after: flutter pub get
# Run before: patrol test or flutter build apk

set -e

PACKAGE_DIR="$HOME/.pub-cache/hosted/pub.dev/flutter_native_timezone-2.0.0/android"
GRADLE_FILE="$PACKAGE_DIR/build.gradle"

if [ ! -f "$GRADLE_FILE" ]; then
    echo "❌ Error: flutter_native_timezone not found in pub cache"
    echo "   Run 'flutter pub get' first"
    exit 1
fi

echo "🔧 Fixing flutter_native_timezone compatibility..."

# Check if already patched
if grep -q "namespace = \"com.whelksoft.flutter_native_timezone\"" "$GRADLE_FILE"; then
    echo "✅ Package already patched"
    exit 0
fi

# Create backup
cp "$GRADLE_FILE" "$GRADLE_FILE.backup"
echo "📦 Backup created: $GRADLE_FILE.backup"

# Completely rewrite build.gradle with AGP 8.0+ compatible configuration
cat > "$GRADLE_FILE" << 'EOF'
group 'com.whelksoft.flutter_native_timezone'
version '1.0-SNAPSHOT'

buildscript {
    ext.kotlin_version = '1.9.0'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

rootProject.allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

apply plugin: 'com.android.library'
apply plugin: 'kotlin-android'

android {
    namespace = "com.whelksoft.flutter_native_timezone"
    compileSdkVersion 34

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
        testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
    }
    lintOptions {
        disable 'InvalidPackage'
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib:$kotlin_version"
}
EOF

echo "✅ Package patched successfully!"
echo ""
echo "Changes made:"
echo "  1. Added namespace declaration"
echo "  2. Updated AGP to 8.1.0"
echo "  3. Updated Kotlin to 1.9.0"
echo "  4. Updated compileSdk to 34"
echo "  5. Set proper Kotlin JVM target to 1.8"
echo ""
echo "You can now run: patrol test"
