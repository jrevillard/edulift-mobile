# iOS Deep Link Configuration Setup

This document explains how to configure iOS deep links to read from the `config/*.json` files using a Run Script Phase in Xcode.

## Overview

The iOS project is now configured to read deep link URLs from `DEEP_LINK_BASE_URL` in the config files:
- `config/development.json` → `"edulift://"`
- `config/e2e.json` → `"edulift://"`
- `config/staging.json` → `"https://transport.tanjama.fr/"`
- `config/production.json` → `"https://transport.tanjama.fr/"`

## Files Created/Modified

1. **`Config.xcconfig`** - Includes generated configuration
2. **`scripts/parse_config.py`** - Python script to parse JSON and generate build settings
3. **`Runner/Info.plist`** - Updated to use `$(CUSTOM_URL_SCHEME)` variable
4. **`Runner/Runner.entitlements`** - Created to use `$(ASSOCIATED_DOMAIN)` variable

## Setup Instructions (in Xcode)

### Step 1: Add Config.xcconfig to Project

1. In Xcode, right-click on the project root in the Project Navigator
2. Select "Add Files to 'Runner'"
3. Choose `Config.xcconfig` from the `ios/` directory
4. **Important**: Uncheck "Copy items if needed" and ensure it's not added to any target

### Step 2: Configure Project Build Settings

1. Select your project in the Project Navigator (not the target)
2. Go to the "Info" tab
3. Under "Configurations", you'll see Debug, Release, etc.
4. For each configuration:
   - Click on the configuration
   - In the dropdown, select "Config.xcconfig"

### Step 3: Add Run Script Phase

1. Select the "Runner" target in the Project Navigator
2. Go to the "Build Phases" tab
3. Click the `+` button and select "New Run Script Phase"
4. Drag this new phase to the top (before "Compile Sources")
5. Rename it to "Parse Deep Link Config"
6. Replace the script content with:

```bash
# Parse deep link configuration from JSON files
set -e

# Map Xcode configuration to environment name
if [ "$CONFIGURATION" = "Debug" ]; then
    ENV_NAME="development"
elif [ "$CONFIGURATION" = "Release" ]; then
    ENV_NAME="production"
elif [ "$CONFIGURATION" = "Profile" ]; then
    ENV_NAME="production"
else
    ENV_NAME=$(echo "$CONFIGURATION" | tr '[:upper:]' '[:lower:]')
fi

CONFIG_FILE="${SRCROOT}/../config/${ENV_NAME}.json"
OUTPUT_FILE="${TARGET_TEMP_DIR}/generated_config.xcconfig"

# Use Python script to parse JSON and generate .xcconfig
"${SRCROOT}/scripts/parse_config.py" "$CONFIG_FILE" "$OUTPUT_FILE" "$ENV_NAME"
```

### Step 4: Enable Associated Domains Capability

1. Select the "Runner" target
2. Go to the "Signing & Capabilities" tab
3. Click `+` and add "Associated Domains"
4. This will automatically use the `Runner.entitlements` file

### Step 5: Build and Test

1. Build the app with different configurations:
   - **Debug** (development): Uses `edulift://` scheme, no associated domains
   - **Release** (production): Uses `edulift://` scheme + `applinks:transport.tanjama.fr`

2. Verify the generated values:
   - Check build log for "Environment: development" etc.
   - The generated .xcconfig file will be created in `DerivedData/.../Target/temp/`

## How It Works

1. **Build starts** → Run Script Phase executes first
2. Script determines environment from Xcode configuration name
3. Python script reads appropriate `config/{environment}.json`
4. Extracts `DEEP_LINK_BASE_URL` and generates:
   - `CUSTOM_URL_SCHEME` (e.g., "edulift")
   - `ASSOCIATED_DOMAIN` (e.g., "applinks:transport.tanjama.fr")
5. Xcode includes these variables via `Config.xcconfig`
6. `Info.plist` uses `$(CUSTOM_URL_SCHEME)` for custom URL schemes
7. `Runner.entitlements` uses `$(ASSOCIATED_DOMAIN)` for Universal Links

## Testing the Configuration

To test the script without building:

```bash
cd ios
python3 scripts/parse_config.py ../config/development.json /tmp/dev.xcconfig development
python3 scripts/parse_config.py ../config/staging.json /tmp/staging.xcconfig staging
```

## Troubleshooting

- **Build fails**: Check that `Config.xcconfig` is properly assigned to all configurations
- **Script fails**: Ensure Python script is executable and JSON files exist
- **No deep links**: Verify that `$(CUSTOM_URL_SCHEME)` is properly substituted in Info.plist
- **Associated domains empty**: Check that `$(ASSOCIATED_DOMAIN)` is set in entitlements for HTTPS configs