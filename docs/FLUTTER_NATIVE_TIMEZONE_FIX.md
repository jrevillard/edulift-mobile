# Fix for flutter_native_timezone AGP Compatibility

## Problem

The `flutter_native_timezone` package (version 2.0.0) is not compatible with Android Gradle Plugin (AGP) 8.0+ due to:

1. **Missing namespace declaration** - AGP 8.0+ requires explicit namespace in `build.gradle`
2. **Kotlin JVM target mismatch** - Inconsistent JVM target between Java (1.8) and Kotlin (17)

## Error Messages

```
* What went wrong:
A problem occurred configuring project ':flutter_native_timezone'.
> Could not create an instance of type com.android.build.api.variant.impl.LibraryVariantBuilderImpl.
   > Namespace not specified. Specify a namespace in the module's build file
```

```
* What went wrong:
Execution failed for task ':flutter_native_timezone:compileDebugKotlin'.
> Inconsistent JVM-target compatibility detected for tasks 'compileDebugJavaWithJavac' (1.8) and 'compileDebugKotlin' (17).
```

## Solution

### Automatic Fix (Recommended)

Run the provided script after `flutter pub get`:

```bash
./scripts/fix_flutter_native_timezone.sh
```

This script:
- Adds `namespace = "com.whelksoft.flutter_native_timezone"` to the android block
- Configures Kotlin JVM toolchain to version 8
- Sets `kotlinOptions.jvmTarget = "1.8"`

### Manual Fix

If you prefer to fix manually:

1. Locate the package:
   ```bash
   ~/.pub-cache/hosted/pub.dev/flutter_native_timezone-2.0.0/android/build.gradle
   ```

2. Add namespace after `android {`:
   ```gradle
   android {
       namespace = "com.whelksoft.flutter_native_timezone"
       compileSdkVersion 30
       // ... rest of config
   }
   ```

3. Add at the end of the file:
   ```gradle
   kotlin {
       jvmToolchain(8)
   }

   tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile).configureEach {
       kotlinOptions {
           jvmTarget = "1.8"
       }
   }
   ```

## When to Apply This Fix

- **After every `flutter pub get`** that downloads a fresh package
- **After clearing pub cache** with `flutter pub cache clean`
- **On new developer machine setup**
- **In CI/CD pipeline** before building

## Alternative Solutions

### Option 1: Fork the Package

Create a fork with the fixes and reference it in `pubspec.yaml`:

```yaml
dependencies:
  flutter_native_timezone:
    git:
      url: https://github.com/YOUR_USERNAME/flutter_native_timezone.git
      ref: agp-8-compatibility
```

### Option 2: Replace with Alternative Package

Consider using Dart's built-in `DateTime.now().timeZoneName` or platform channels for timezone detection.

### Option 3: Wait for Official Fix

Monitor the official repository: https://github.com/pinkfish/flutter_native_timezone

## Package Usage in EduLift

The `flutter_native_timezone` package is used in:
- `lib/core/services/timezone_service.dart` - Device timezone detection

**Single usage**: Line 75 in `timezone_service.dart`
```dart
final timezone = await FlutterNativeTimezone.getLocalTimezone();
```

## Long-term Recommendation

Given the package's maintenance status and our minimal usage (one API call), consider:

1. **Creating a custom platform channel** for timezone detection
2. **Using `DateTime.now().timeZoneName`** as fallback
3. **Relying on user profile timezone** from backend instead of device timezone

## Related Issues

- Package issue: https://github.com/pinkfish/flutter_native_timezone/issues/XX
- AGP migration guide: https://developer.android.com/build/releases/past-releases/agp-8-0-0-release-notes

## Testing

After applying the fix, verify with:

```bash
# Clean build
flutter clean
flutter pub get
./scripts/fix_flutter_native_timezone.sh

# Test Patrol E2E tests
patrol test --target integration_test/family/family_vehicle_management_e2e_test.dart

# Regular flutter tests should work without fix
flutter test
```

---

**Last Updated**: October 19, 2025
**Package Version**: flutter_native_timezone 2.0.0
**AGP Version**: 8.0+
**Status**: Temporary workaround until official fix
