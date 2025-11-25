# CI/CD Deep Link Configuration Instructions

This document provides complete instructions for automating iOS and Android deep link configuration in CI/CD pipelines using the `DEEP_LINK_BASE_URL` from config files.

## Overview

The deep link configuration is now completely automated and reads from `DEEP_LINK_BASE_URL` in your config files:

- **Development**: `edulift://` → Custom URL scheme only
- **E2E**: `edulift://` → Custom URL scheme only
- **Staging**: `https://transport.tanjama.fr:50443/` → Custom scheme + Universal Links
- **Production**: `https://transport.tanjama.fr/` → Custom scheme + Universal Links

## Android Configuration

Android is fully automated and requires no additional steps in CI/CD.

### How it works
- `android/app/build.gradle.kts` reads `DEEP_LINK_BASE_URL` from config files using Groovy JSON parser
- Automatically extracts scheme and host for manifest placeholders
- Updates `AndroidManifest.xml` with the correct deep link configuration

### CI/CD Usage
```bash
# Build Android for different environments
flutter build apk --flavor development --dart-define-from-file=config/development.json
flutter build apk --flavor staging --dart-define-from-file=config/staging.json
flutter build appbundle --flavor production --dart-define-from-file=config/production.json
```

## iOS Configuration

iOS uses an automated script that modifies the build files before building.

### The Automated Script
- **Script**: `scripts/configure_ios.sh`
- **Usage**: `./scripts/configure_ios.sh <environment>`
- **Dependencies**: `jq` (JSON parser)
- **Tested environments**: development, e2e, staging, production ✅

### What the script does:
1. Reads `DEEP_LINK_BASE_URL` from `config/{environment}.json`
2. Parses the URL to extract:
   - Custom URL scheme (`edulift`)
   - Associated domain for Universal Links (`applinks:domain.com`)
3. Updates `ios/Runner/Info.plist` with URL schemes
4. Creates/updates `ios/Runner/Runner.entitlements` with Associated Domains

### Verified Results ✅
- **Development**: `edulift://` → Custom scheme only, empty entitlements
- **E2E**: `edulift://` → Custom scheme only, empty entitlements
- **Staging**: `https://transport.tanjama.fr:50443/` → Custom scheme + `applinks:transport.tanjama.fr:50443`
- **Production**: `https://transport.tanjama.fr/` → Custom scheme + `applinks:transport.tanjama.fr`

### CI/CD Integration

#### GitHub Actions Example
```yaml
name: Build and Deploy

on:
  push:
    branches: [main, develop]

jobs:
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x.x'

      - name: Get dependencies
        run: flutter pub get

      - name: Build Android APK
        run: |
          flutter build apk --flavor development --dart-define-from-file=config/development.json

  build-ios:
    runs-on: macos-latest  # Required for iOS builds
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x.x'

      - name: Install dependencies
        run: |
          flutter pub get
          # Install jq for JSON parsing
          brew install jq

      - name: Configure iOS for Development
        if: github.ref == 'refs/heads/develop'
        run: ./scripts/configure_ios.sh development

      - name: Configure iOS for Production
        if: github.ref == 'refs/heads/main'
        run: ./scripts/configure_ios.sh production

      - name: Build iOS IPA
        run: |
          flutter build ipa --release \
            --flavor production \
            --dart-define-from-file=config/production.json
```

#### GitLab CI Example
```yaml
stages:
  - build

variables:
  FLUTTER_VERSION: "3.x.x"

build-android:
  stage: build
  image: cirrusci/flutter:$FLUTTER_VERSION
  script:
    - flutter pub get
    - flutter build apk --flavor staging --dart-define-from-file=config/staging.json
  artifacts:
    paths:
      - build/app/outputs/flutter-apk/app-staging-release.apk

build-ios:
  stage: build
  tags:
    - macos  # Required for iOS builds
  script:
    - flutter pub get
    - brew install jq  # Install jq
    - ./scripts/configure_ios.sh staging
    - flutter build ipa --release --flavor staging --dart-define-from-file=config/staging.json
  artifacts:
    paths:
      - build/ios/ipa/*.ipa
```

#### Jenkins Pipeline Example
```groovy
pipeline {
    agent any

    environment {
        FLUTTER_HOME = tool 'flutter'
        PATH = "${FLUTTER_HOME}/bin:${env.PATH}"
    }

    stages {
        stage('Build Android') {
            steps {
                sh 'flutter pub get'
                sh 'flutter build apk --flavor production --dart-define-from-file=config/production.json'
            }
        }

        stage('Build iOS') {
            agent {
                label 'macos'  // Required for iOS builds
            }
            steps {
                sh 'flutter pub get'
                sh 'brew install jq'  // Install jq if not available
                sh './scripts/configure_ios.sh production'
                sh 'flutter build ipa --release --flavor production --dart-define-from-file=config/production.json'
            }
        }
    }
}
```

## Manual Testing

You can test the configuration locally:

### Android
```bash
cd android
./gradlew assembleDevelopmentDebug
./gradlew assembleProductionRelease
```

### iOS
```bash
# Test configuration script locally (requires jq)
./scripts/configure_ios.sh development
./scripts/configure_ios.sh staging
./scripts/configure_ios.sh production

# Then build the app
flutter build ios --flavor development --dart-define-from-file=config/development.json
```

## Environment Variables

The script automatically determines the environment based on the parameter passed. You can also use environment variables in your CI:

```bash
# Using environment variable
ENVIRONMENT=${CI_ENVIRONMENT:-development}
./scripts/configure_ios.sh $ENVIRONMENT
```

## Troubleshooting

### Common Issues

1. **jq not found**: Install jq with package manager
   - macOS: `brew install jq`
   - Ubuntu: `sudo apt-get install jq`
   - CentOS: `sudo yum install jq`

2. **Config file not found**: Ensure you're running from the project root
   ```bash
   pwd  # Should be /workspace/your-project
   ls config/  # Should show your JSON files
   ```

3. **Permission denied**: Make script executable
   ```bash
   chmod +x scripts/configure_ios.sh
   ```

4. **iOS build fails**: Ensure Associated Domains capability is enabled in Xcode project settings

### Verification

After running the script, verify the files were updated correctly:

```bash
# Check Info.plist contains URL scheme
grep -A 5 "CFBundleURLTypes" ios/Runner/Info.plist

# Check entitlements contains associated domains (for HTTPS URLs)
grep -A 5 "associated-domains" ios/Runner/Runner.entitlements
```

## Important Notes ⚠️

- **Script modifies files**: The iOS script directly modifies `Info.plist` and creates `Runner.entitlements`
- **Clean state**: Always run from clean git state when testing locally
- **Backup files**: Script creates `.backup` files automatically
- **CI/CD only**: This approach is designed for automated builds, not local development
- **macOS tools**: On macOS, the script uses PlistBuddy; on CI/CD it falls back to sed

### Reset to Clean State
```bash
# Reset iOS files to original state
git checkout ios/Runner/Info.plist
rm -f ios/Runner/Runner.entitlements

# Remove all backup files
find . -name "*.backup" -delete
```

## Security Notes

- The script creates backup files (`.backup`) before modifying files
- All configuration is version-controlled in config files
- No secrets are hardcoded in build files
- The script validates inputs and fails gracefully on errors

## Summary

This automated solution provides:
- ✅ **Zero manual configuration** in CI/CD
- ✅ **Single source of truth** in config files
- ✅ **Environment-specific** deep link configuration
- ✅ **Both custom schemes** and **Universal Links** support
- ✅ **Cross-platform CI/CD** compatibility
- ✅ **Version-controlled** configuration