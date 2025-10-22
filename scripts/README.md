# Mobile App Scripts

Utility scripts for EduLift mobile app development and testing.

## Available Scripts

### fix_flutter_native_timezone.sh

**Purpose**: Patches `flutter_native_timezone` package for compatibility with Android Gradle Plugin 8.0+

**When to run**:
- After `flutter pub get`
- Before running `patrol test`
- After clearing pub cache
- On new developer machine setup
- In CI/CD before building APK

**Usage**:
```bash
./scripts/fix_flutter_native_timezone.sh
```

**What it does**:
1. Adds required `namespace` declaration to package's `build.gradle`
2. Fixes Kotlin JVM target compatibility (sets to 1.8)
3. Creates backup of original file

**Documentation**: See `/docs/FLUTTER_NATIVE_TIMEZONE_FIX.md` for details

## CI/CD Integration

Add to your CI/CD pipeline:

```yaml
- name: Setup Flutter dependencies
  run: |
    cd mobile_app
    flutter pub get
    ./scripts/fix_flutter_native_timezone.sh

- name: Run Patrol E2E tests
  run: |
    cd mobile_app
    patrol test
```

## Development Workflow

```bash
# Initial setup
flutter pub get
./scripts/fix_flutter_native_timezone.sh

# Run unit tests (no fix needed)
flutter test

# Run Patrol E2E tests (requires fix)
patrol test

# Clean and rebuild
flutter clean
flutter pub get
./scripts/fix_flutter_native_timezone.sh
flutter build apk
```

## Troubleshooting

### "Namespace not specified" error

Run the fix script:
```bash
./scripts/fix_flutter_native_timezone.sh
```

### "Inconsistent JVM-target compatibility" error

The fix script handles this too. If problem persists:
1. Run `flutter clean`
2. Delete `~/.pub-cache/hosted/pub.dev/flutter_native_timezone-2.0.0`
3. Run `flutter pub get`
4. Run the fix script again

### "Package already patched" message

This is normal - the script detected the fix is already applied.

## Adding New Scripts

When adding scripts to this directory:

1. Make them executable: `chmod +x script_name.sh`
2. Add shebang: `#!/bin/bash`
3. Include help/usage information
4. Document in this README
5. Add error handling with `set -e`

---

**Last Updated**: October 19, 2025
