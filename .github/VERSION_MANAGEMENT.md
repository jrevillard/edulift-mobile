# CI/CD Version Management

This directory contains centralized configuration for all CI/CD versions and build parameters.

## Overview

To avoid version inconsistencies across different CI/CD platforms (GitHub Actions, Codemagic), all versions are centralized in a single configuration file.

## Files

### `ci-versions.env`
Central configuration file containing all version numbers used across CI/CD pipelines:

```bash
# Flutter SDK Version
FLUTTER_VERSION=3.38.2
FLUTTER_CHANNEL=stable

# Java/Android
JAVA_VERSION=17

# iOS/Xcode
XCODE_VERSION=16.4

# Firebase App IDs (for reference - secrets still contain sensitive keys)
FIREBASE_ANDROID_STAGING_APP_ID=1:390712570284:android:c6b38aa4cf23bacd054a09
FIREBASE_ANDROID_PROD_APP_ID=1:928262951410:android:18b5cc75d10217bf779b6b
FIREBASE_IOS_STAGING_APP_ID=1:390712570284:ios:11ab124204e6c10c054a09
FIREBASE_IOS_PROD_APP_ID=1:928262951410:ios:139da35e9a165907779b6b
```

### `validate-ci-versions.sh`
Script that validates all CI/CD configurations use the correct centralized versions.

Usage:
```bash
./scripts/validate-ci-versions.sh
```

## How to Update Versions

1. Edit `.github/ci-versions.env` with the new version
2. Run the validation script to ensure consistency:
   ```bash
   ./scripts/validate-ci-versions.sh
   ```
3. Commit both files if validation passes

## Benefits

- ✅ **Single Source of Truth**: All versions defined in one place
- ✅ **Consistency**: Eliminates version drift between CI/CD platforms
- ✅ **Easy Updates**: Change versions in one file, automatically applied everywhere
- ✅ **Validation**: Built-in validation ensures configurations stay synchronized
- ✅ **Maintainability**: Clear documentation and validation scripts

## CI/CD Platforms

### GitHub Actions
- Uses `FLUTTER_VERSION`, `JAVA_VERSION`, `XCODE_VERSION` from workflow `env` section
- References central config file in comments for transparency
- All jobs use environment variables instead of hardcoded versions

### Codemagic
- Reads Flutter version from central config through workflow
- Uses `flutter: stable` channel (follows FLUTTER_CHANNEL)

### Validation
The `validate-ci-versions.sh` script checks:
- GitHub Actions workflow uses correct FLUTTER_VERSION
- Setup action requires flutter-version parameter (no hardcoded defaults)
- Codemagic configuration uses stable Flutter channel
- All version variables are properly defined

## Architecture

```
.github/
├── ci-versions.env          # Central version configuration
├── VERSION_MANAGEMENT.md    # This documentation
└── workflows/
    └── cd.yml              # Uses environment variables from ci-versions.env

scripts/
└── validate-ci-versions.sh # Validation script
```

This architecture ensures that updating Flutter, Java, or Xcode versions only requires editing one file and running the validation script.