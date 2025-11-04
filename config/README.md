# EduLift Configuration System

This directory contains environment-specific configuration files for the EduLift Flutter mobile application.

## Overview

The EduLift app uses Flutter's modern `--dart-define-from-file` feature to inject configuration at build time. This ensures:

- **Security**: Sensitive values are not hardcoded in source code
- **Flexibility**: Different configurations for different environments
- **Maintainability**: Single source of truth for each environment
- **Type Safety**: Dart compile-time constants with proper fallbacks

## Configuration Files

- `development.json` - Local development environment
- `staging.json` - Pre-production staging environment
- `e2e.json` - End-to-end testing environment
- `production.json` - Production environment

## Configuration Schema

### Core Schema (All Environments)

All configuration files include these core settings:

```json
{
  "APP_NAME": "string",
  "ENVIRONMENT_NAME": "string",
  "API_BASE_URL": "string (URL)",
  "WEBSOCKET_URL": "string (URL)",
  "CONNECT_TIMEOUT_SECONDS": "integer",
  "RECEIVE_TIMEOUT_SECONDS": "integer",
  "SEND_TIMEOUT_SECONDS": "integer",
  "LOG_LEVEL": "string",
  "FIREBASE_ENABLED": "boolean"
}
```

### Development & E2E Only

Development and E2E testing environments include additional email testing configuration:

```json
{
  "MAILPIT_WEB_URL": "string (URL)",
  "MAILPIT_API_URL": "string (URL)"
}
```

**Note**: Mailpit is an email testing tool only used in development and E2E testing. Staging and production environments do NOT include Mailpit configuration keys.

## Usage

### Development (with JSON config)

```bash
# Run with development config
flutter run --dart-define-from-file=config/development.json

# Run with staging config
flutter run --dart-define-from-file=config/staging.json
```

### Development (without JSON - uses fallback defaults)

```bash
# Run with hardcoded development defaults
flutter run
```

### Build for Production

```bash
# Build APK for production
flutter build apk --dart-define-from-file=config/production.json

# Build iOS for production
flutter build ios --dart-define-from-file=config/production.json
```

### Build for Staging

```bash
# Build APK for staging
flutter build apk --dart-define-from-file=config/staging.json
```

### E2E Testing

```bash
# Build for E2E tests
flutter build apk --dart-define-from-file=config/e2e.json
```

## Environment Details

### Development
- **Purpose**: Local development with localhost services
- **API**: `http://localhost:3001/api/v1`
- **WebSocket**: `ws://localhost:3001`
- **Mailpit**: `http://localhost:8025` (email testing)
- **Debug**: Enabled
- **Firebase**: Disabled

### Staging
- **Purpose**: Pre-production testing
- **API**: `https://staging-api.edulift.com/api/v1`
- **WebSocket**: `wss://staging-api.edulift.com`
- **Debug**: Enabled
- **Firebase**: Enabled
- **Mailpit**: Not configured (uses real email services)

### E2E
- **Purpose**: Automated integration testing with Docker services
- **API**: `http://10.0.2.2:8030/api/v1` (Android emulator host access)
- **WebSocket**: `ws://10.0.2.2:8030`
- **Mailpit**: `http://10.0.2.2:8031` (email testing)
- **Debug**: Enabled
- **Firebase**: Disabled
- **Note**: Uses shorter timeouts (5s connect, 8s receive) for faster test execution

### Production
- **Purpose**: Live production application
- **API**: `https://transport.tanjama.fr/api`
- **WebSocket**: `wss://transport.tanjama.fr/api`
- **Debug**: Disabled
- **Firebase**: Enabled
- **Mailpit**: Not configured (uses real email services)

## How It Works

1. **JSON Files** (this directory): Define environment-specific values
2. **Dart Config Classes** (`lib/core/config/app_config.dart`): Load values using `String.fromEnvironment()`, `bool.fromEnvironment()`, `int.fromEnvironment()`
3. **Build Time Injection**: Flutter passes JSON values to Dart constants during compilation
4. **Runtime Access**: App reads configuration through type-safe Dart classes

## Adding New Configuration Variables

To add a new configuration variable:

1. **Determine scope**: Is this for all environments or only specific ones (like Mailpit)?
2. **Add to appropriate JSON files**:
   - Core variables: Add to all 4 files (development, staging, e2e, production)
   - Environment-specific: Add only to relevant files (e.g., Mailpit only in development and e2e)
3. **Add to Dart config classes** in `lib/core/config/app_config.dart`:
   ```dart
   @override
   String get myNewConfig => const String.fromEnvironment(
     'MY_NEW_CONFIG',
     defaultValue: 'fallback-value', // Required for environments without this key
   );
   ```
4. **Add to BaseConfig interface** if it should be available across all environments
5. **Update this README** to document the new variable and which environments include it

## Important Notes

- **SCREAMING_SNAKE_CASE**: All JSON keys must use SCREAMING_SNAKE_CASE
- **Environment-Specific Keys**: Core keys (9 keys) are required in all environments. Development and E2E include 2 additional Mailpit keys (11 total)
- **Type Safety**: Use the correct `fromEnvironment()` method:
  - `String.fromEnvironment()` for strings
  - `bool.fromEnvironment()` for booleans
  - `int.fromEnvironment()` for integers
- **Fallback Defaults**: Always provide sensible defaults in Dart code (especially for optional keys like Mailpit)
- **Security**: Never commit sensitive production secrets to Git (use CI/CD secrets instead)
- **Validation**: Each config class has a `validate()` method to ensure URLs are properly formatted

## CI/CD Integration

The GitHub Actions workflows in `.github/workflows/cd.yml` automatically use the appropriate configuration file for each build:

- Development builds: `config/development.json`
- Staging builds: `config/staging.json`
- E2E test builds: `config/e2e.json`
- Production builds: `config/production.json`

## Troubleshooting

### Config values not being picked up
- Ensure you're using `--dart-define-from-file=config/yourenv.json`
- Check that JSON keys match exactly in both JSON and Dart code
- Verify JSON is valid (use `jq . config/yourenv.json` to validate)

### Wrong environment loaded
- Check which config file you passed to `--dart-define-from-file`
- Verify `ENVIRONMENT_NAME` in JSON matches expected environment

### Build errors
- Run `flutter analyze lib/core/config/` to check for syntax errors
- Ensure all JSON files have consistent schema

## Migration Notes

**2025-10-27**: Migrated from hardcoded Dart configurations to modern `--dart-define-from-file` approach. All environment configurations now support build-time injection while maintaining fallback defaults for development convenience.
