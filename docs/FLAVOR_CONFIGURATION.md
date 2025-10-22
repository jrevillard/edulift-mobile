# 🎯 Flutter Flavors Configuration Guide - Unified System

## Overview

EduLift Mobile uses a **unified Flutter Flavors system** with a single entry point that automatically detects the environment. This provides a **simple**, **maintainable** solution following the **KISS principle** (Keep It Simple, Stupid).

## 🏗️ Architecture

### System Components

1. **FlavorConfig** - Central configuration class (`lib/core/config/flavor_config.dart`)
2. **FeatureFlags** - Flavor-based feature management (`lib/core/config/feature_flags.dart`)
3. **Unified Entry Point** - Single main.dart for all flavors (`lib/main.dart`)
4. **Platform Configuration** - Cross-platform flavor detection
5. **Wrapper Scripts** - Simplified commands (`scripts/run_flavor.sh`)

### Supported Flavors

| Flavor | Purpose | API URL | App Name | Firebase |
|--------|---------|---------|----------|----------|
| `development` | Local development | http://localhost:3001/api/v1 | EduLift Dev | ❌ |
| `staging` | Pre-production testing | https://staging-api.edulift.com/api/v1 | EduLift Staging | ✅ |
| `e2e` | Automated E2E tests | http://10.0.2.2:8030/api/v1 | EduLift E2E | ❌ |
| `production` | Live application | https://api.edulift.com/api/v1 | EduLift | ✅ |

## 🚀 Usage

### Universal Commands (Works on All Platforms)

```bash
# Android (resValue automatic)
flutter run --flavor development
flutter build apk --flavor production

# iOS (xcconfig automatic) 
flutter run --flavor staging
flutter build ipa --flavor production

# Web/Linux (manual dart-define)
flutter run --dart-define=FLAVOR=development -d chrome
flutter build web --dart-define=FLAVOR=production

# Patrol E2E (automatic flavor detection)
patrol test --flavor e2e
```

### Key Advantage: Single Entry Point

**OLD System** (Removed):
- ❌ `lib/main_development.dart`
- ❌ `lib/main_staging.dart`  
- ❌ `lib/main_e2e.dart`
- ❌ `lib/main_production.dart`

**NEW System** (Current):
- ✅ **Single** `lib/main.dart` handles ALL flavors
- ✅ Automatic flavor detection via `String.fromEnvironment('FLAVOR')`
- ✅ Works with Patrol without `--target` parameter

## ⚙️ Platform Configuration

### Android Configuration

**File**: `android/app/build.gradle.kts`

```kotlin
productFlavors {
    create("development") {
        applicationIdSuffix = ".dev"
        versionNameSuffix = "-dev"
        resValue("string", "app_name", "EduLift Dev")
        resValue("string", "FLAVOR", "development")  // ← Automatic dart-define
    }
    create("e2e") {
        applicationIdSuffix = ".e2e"
        versionNameSuffix = "-e2e"  
        resValue("string", "app_name", "EduLift E2E")
        resValue("string", "FLAVOR", "e2e")  // ← Automatic dart-define
    }
    // ... other flavors
}
```

### iOS Configuration

**Files**: `ios/Flutter/*.xcconfig`

```bash
# ios/Flutter/Development.xcconfig
#include "Generated.xcconfig"
DART_DEFINES=RkxBVk9SPWRldmVsb3BtZW50  # base64("FLAVOR=development")

# ios/Flutter/E2e.xcconfig  
#include "Generated.xcconfig"
DART_DEFINES=RkxBVk9SPWUyZQ==  # base64("FLAVOR=e2e")
```

### Web/Linux Configuration

Use `--dart-define` parameter:

```bash
# Web
flutter build web --dart-define=FLAVOR=production

# Linux
flutter run --dart-define=FLAVOR=development -d linux
```

## 🎛️ FeatureFlags System

### Flavor-Based Features

```dart
// lib/core/config/feature_flags.dart
class FeatureFlags {
  static bool get debugMode => FlavorConfig.isDevelopment;
  static bool get analyticsEnabled => !FlavorConfig.isDevelopment;
  static bool get crashReporting => FlavorConfig.isProduction;
  static bool get firebaseEnabled => !FlavorConfig.isDevelopment && !FlavorConfig.isE2E;
  static bool get verboseLogging => FlavorConfig.isDevelopment || FlavorConfig.isE2E;
}
```

### Usage in Code

```dart
// Firebase initialization (automatic)
if (FeatureFlags.firebaseEnabled) {
  await Firebase.initializeApp();
}

// Debug logging
if (FeatureFlags.verboseLogging) {
  FeatureFlags.logConfiguration();
}

// Analytics
if (FeatureFlags.analyticsEnabled) {
  Analytics.track('user_action');
}
```

## 🧪 E2E Testing with Patrol

### Unified Patrol Command

```bash
# Simplest - reads flavor from pubspec.yaml!
patrol test

# With additional options (flavor still from pubspec.yaml)
patrol test --verbose
patrol test --device emulator-5554

# Override flavor if needed
patrol test --flavor development
```

### How It Works

1. **Patrol** reads `pubspec.yaml` and automatically uses `flavor: e2e`
2. **Android Gradle** provides `resValue("string", "FLAVOR", "e2e")` for the e2e flavor
3. **Flutter** receives this as automatic dart-define
4. **main.dart** detects flavor via `String.fromEnvironment('FLAVOR')`
5. **FlavorConfig** initializes with E2E configuration
6. **App** runs with correct API URLs (10.0.2.2:8030)

### Pubspec.yaml Configuration

```yaml
# Patrol configuration for E2E testing
patrol:
  timeout: 300s
  retry: 1  
  screenshot_on_failure: true
  # Default flavor - no need to specify --flavor in commands!
  flavor: e2e
  app_name: EduLift E2E
  # Package names per platform
  android:
    package_name: com.edulift.app.e2e
  ios:
    bundle_id: com.edulift.app.e2e
```

### Automated Test Runner

```bash
# Run complete E2E pipeline
./integration_test/run_patrol_tests.sh

# This automatically:
# 1. Starts Docker services (backend + MailHog)
# 2. Runs: patrol test (reads flavor from pubspec.yaml)
# 3. Uses unified main.dart (no target or flavor flags needed)
# 4. Reports results with proper logging
```

## 🔧 Development Workflow

### Adding New Environment

1. **Add to FlavorConfig enum**:
```dart
enum Flavor {
  development,
  staging,
  e2e,
  production,
  newEnvironment, // ← Add here
}
```

2. **Update configuration methods**:
```dart
static String get apiBaseUrl {
  switch (appFlavor) {
    // ... existing cases
    case Flavor.newEnvironment:
      return 'https://new-api.edulift.com/api/v1';
  }
}
```

3. **Add Android flavor**:
```kotlin
create("newenvironment") {
    dimension = "environment"
    applicationIdSuffix = ".new"
    versionNameSuffix = "-new"
    resValue("string", "app_name", "EduLift New")
    resValue("string", "FLAVOR", "newenvironment")  // ← Key addition
}
```

4. **Create iOS xcconfig**:
```bash
# ios/Flutter/Newenvironment.xcconfig
#include "Generated.xcconfig"
DART_DEFINES=<base64_encoded_FLAVOR=newenvironment>
```

**No need** to create separate main_*.dart files anymore!

### Code Usage

```dart
// In your application code
import 'package:edulift/core/config/flavor_config.dart';
import 'package:edulift/core/config/feature_flags.dart';

class ApiService {
  String get baseUrl => FlavorConfig.apiBaseUrl;
  bool get isDebugMode => FeatureFlags.debugMode;
  Duration get timeout => FlavorConfig.connectTimeout;
}

// Feature-based logic
class AuthService {
  void initialize() {
    if (FeatureFlags.firebaseEnabled) {
      setupFirebaseAuth();
    } else {
      setupMockAuth();
    }
  }
}
```

## 🐛 Troubleshooting

### Common Issues

#### "Wrong flavor detected"
```dart
// Debug: Check environment detection
print('Detected FLAVOR: ${const String.fromEnvironment('FLAVOR')}');
print('Current flavor: ${FlavorConfig.flavorName}');
print('Is E2E: ${FlavorConfig.isE2E}');
```

#### "Patrol can't find entry point"
```bash
# OLD (Don't use): patrol test --flavor e2e --target lib/main_e2e.dart
# BETTER (Previous): patrol test --flavor e2e
# BEST (Current): patrol test

# The unified main.dart + pubspec.yaml handles everything automatically
```

#### "Firebase not working in E2E"
```bash
# This is expected! E2E flavor disables Firebase for testing
# Check: FeatureFlags.firebaseEnabled should be false for E2E
```

#### "Platform differences"
```bash
# Android/iOS: Use --flavor only
flutter run --flavor development

# Web/Linux: Use --dart-define
flutter run --dart-define=FLAVOR=development -d linux
```

### Debug Commands

```dart
// Check current configuration
print(FlavorConfig.configSummary);

// Check feature flags
print(FeatureFlags.flagSummary);

// Validate setup
bool isValid = FlavorConfig.validateConfiguration();

// Log all configuration (development only)
FeatureFlags.logConfiguration();
```

### Verification Checklist

- [ ] `String.fromEnvironment('FLAVOR')` returns correct value
- [ ] FlavorConfig.appFlavor is set correctly
- [ ] API URL matches expected environment  
- [ ] FeatureFlags behave as expected
- [ ] Firebase enabled only for staging/production
- [ ] Patrol works with just `patrol test` command (no parameters needed)

## 📱 Platform Support Matrix

| Platform | Flavor Command | Dart Define | Status |
|----------|---------------|-------------|--------|
| **Android** | `--flavor development` | Automatic (resValue) | ✅ |
| **iOS** | `--flavor staging` | Automatic (xcconfig) | ✅ |
| **Web** | N/A | `--dart-define=FLAVOR=dev` | ✅ |
| **Linux** | N/A | `--dart-define=FLAVOR=dev` | ✅ |
| **Patrol** | `patrol test` | Automatic (pubspec.yaml) | ✅ |

## 📚 Best Practices

### Do's ✅

- **Use single main.dart** for all flavors
- **Trust automatic detection** (resValue/xcconfig)
- **Use FeatureFlags** for conditional logic
- **Test each platform** with its proper command
- **Follow naming conventions** for consistency
- **Use wrapper scripts** for complex builds

### Don'ts ❌

- **Don't create** multiple main_*.dart files
- **Don't hardcode** flavor detection logic
- **Don't mix** --flavor and --dart-define on Android/iOS
- **Don't skip** platform-specific configuration
- **Don't forget** base64 encoding for iOS xcconfig
- **Don't assume** Firebase is always available

### Security Considerations

- **Production secrets**: Never commit API keys or secrets
- **Development URLs**: Keep localhost for development only
- **Debug logging**: Controlled by FeatureFlags.debugMode
- **Firebase**: Automatically disabled in development/E2E

## 🔄 Migration Guide

### From Old Multi-Entry System

**Completed Migration** ✅:
1. ✅ **Removed** all `main_*.dart` files
2. ✅ **Created** unified `lib/main.dart`
3. ✅ **Added** resValue to Android flavors
4. ✅ **Created** iOS xcconfig files
5. ✅ **Implemented** FeatureFlags system
6. ✅ **Updated** Patrol scripts

### Verification Commands

```bash
# Test each platform
flutter run --flavor development           # Android
flutter run --dart-define=FLAVOR=dev -d linux    # Linux
patrol test                               # Patrol (reads pubspec.yaml)

# Check files exist
ls lib/main.dart                          # ✅ Should exist
ls lib/main_*.dart                        # ❌ Should not exist
ls ios/Flutter/*.xcconfig                 # ✅ Should have flavor configs
grep "flavor: e2e" pubspec.yaml          # ✅ Should have Patrol config
```

## 📞 Support

### Quick Diagnostics

1. **Check flavor detection**:
   ```dart
   debugPrint('FLAVOR env: ${const String.fromEnvironment('FLAVOR')}');
   debugPrint('FlavorConfig: ${FlavorConfig.flavorName}');
   ```

2. **Verify feature flags**:
   ```dart
   FeatureFlags.logConfiguration(); // Only in development
   ```

3. **Test builds**:
   ```bash
   flutter build apk --flavor e2e    # Should build successfully
   patrol test                       # Should run tests (reads pubspec.yaml)
   ```

4. **Check Docker setup** (E2E only):
   ```bash
   curl http://localhost:8030/health  # Backend
   curl http://localhost:8031         # MailHog
   ```

---

**🎯 This unified flavor system eliminates complexity while maintaining full functionality across all platforms. One main.dart to rule them all!**