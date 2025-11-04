#!/bin/bash

# Automated iOS Configuration Script for CI/CD
# This script reads DEEP_LINK_BASE_URL from config JSON and updates iOS build files
# Usage: ./scripts/configure_ios.sh <environment> (development, staging, e2e, production)

set -e # Stop script if any command fails

# Validate arguments
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <environment>"
    echo "Environments: development, staging, e2e, production"
    exit 1
fi

ENVIRONMENT=$1
CONFIG_FILE="config/${ENVIRONMENT}.json"
PLIST_FILE="ios/Runner/Info.plist"
ENTITLEMENTS_FILE="ios/Runner/Runner.entitlements"

echo "🔧 Configuring iOS for environment: $ENVIRONMENT"
echo "📁 Using config file: $CONFIG_FILE"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Error: Config file '$CONFIG_FILE' not found."
    exit 1
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "❌ Error: jq is required but not installed. Please install jq."
    exit 1
fi

# Extract DEEP_LINK_BASE_URL from JSON
DEEP_LINK_BASE_URL=$(jq -r '.DEEP_LINK_BASE_URL' "$CONFIG_FILE")

if [ "$DEEP_LINK_BASE_URL" = "null" ] || [ -z "$DEEP_LINK_BASE_URL" ]; then
    echo "❌ Error: DEEP_LINK_BASE_URL not found in '$CONFIG_FILE'"
    exit 1
fi

echo "🔗 DEEP_LINK_BASE_URL: $DEEP_LINK_BASE_URL"

# Parse deep link URL to extract scheme and associated domain
parse_deep_link_url() {
    local url="$1"

    if [[ "$url" == edulift://* ]]; then
        # Custom URL scheme
        URL_SCHEME="edulift"
        ASSOCIATED_DOMAIN=""
    elif [[ "$url" == https://* ]]; then
        # HTTPS Universal Link
        # Extract host (with port if present)
        local host=$(echo "$url" | sed 's|https://||' | sed 's|/$||')
        URL_SCHEME="edulift"
        ASSOCIATED_DOMAIN="applinks:$host"
    else
        echo "❌ Error: Unsupported deep link URL format: $url"
        exit 1
    fi
}

parse_deep_link_url "$DEEP_LINK_BASE_URL"

echo "📱 Custom URL Scheme: $URL_SCHEME"
echo "🌐 Associated Domain: $ASSOCIATED_DOMAIN"

# --- Update Info.plist for Custom URL Schemes ---

if [ ! -f "$PLIST_FILE" ]; then
    echo "❌ Error: Info.plist not found at '$PLIST_FILE'"
    exit 1
fi

echo "📝 Updating Info.plist..."

# Check if PlistBuddy is available (macOS tool)
if command -v /usr/libexec/PlistBuddy &> /dev/null; then
    # Use PlistBuddy on macOS
    # Remove existing URL types to avoid duplicates
    /usr/libexec/PlistBuddy -c "Delete :CFBundleURLTypes" "$PLIST_FILE" 2>/dev/null || true

    # Add new URL type configuration
    /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes array" "$PLIST_FILE"
    /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0 dict" "$PLIST_FILE"
    /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLName string edulift.app" "$PLIST_FILE"
    /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes array" "$PLIST_FILE"
    /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes:0 string $URL_SCHEME" "$PLIST_FILE"

    echo "✅ Info.plist updated using PlistBuddy"
elif command -v plutil &> /dev/null; then
    # Use plutil as fallback (available on macOS)
    # Create a temporary plist with the URL configuration
    cat > /tmp/url_types.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLName</key>
            <string>edulift.app</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>$URL_SCHEME</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
EOF

    # Merge with existing plist
    plutil -merge "$PLIST_FILE" /tmp/url_types.plist
    rm -f /tmp/url_types.plist

    echo "✅ Info.plist updated using plutil"
else
    # Fallback for non-macOS systems (CI environments)
    echo "⚠️  Warning: Neither PlistBuddy nor plutil available. Using sed-based fallback."

    # Create backup
    cp "$PLIST_FILE" "$PLIST_FILE.backup"

    # Remove existing URL types (basic sed approach)
    sed -i.tmp '/<key>CFBundleURLTypes<\/key>/,/<\/array>/d' "$PLIST_FILE"

    # Insert new URL types before the first dict key that's not CFBundleURLTypes
    sed -i.tmp "/<key>CFBundleDisplayName<\/key>/i\\
\\t<!-- Deep linking support (auto-generated for $ENVIRONMENT) -->\\
\\t<key>CFBundleURLTypes<\/key>\\
\\t<array>\\
\\t\t<dict>\\
\\t\t\t<key>CFBundleURLName<\/key>\\
\\t\t\t<string>edulift.app<\/string>\\
\\t\t\t<key>CFBundleURLSchemes<\/key>\\
\\t\t\t<array>\\
\\t\t\t\t<string>$URL_SCHEME<\/string>\\
\\t\t\t<\/array>\\
\\t\t<\/dict>\\
\\t<\/array>\\
" "$PLIST_FILE"

    rm -f "$PLIST_FILE.tmp"
    echo "✅ Info.plist updated using sed fallback"
fi

# --- Update Runner.entitlements for Universal Links ---

echo "📝 Updating entitlements file..."

# Create entitlements file if it doesn't exist
if [ ! -f "$ENTITLEMENTS_FILE" ]; then
    echo "ℹ️  Creating entitlements file..."
    mkdir -p "$(dirname "$ENTITLEMENTS_FILE")"
    cat > "$ENTITLEMENTS_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
</dict>
</plist>
EOF
fi

if command -v /usr/libexec/PlistBuddy &> /dev/null; then
    # Use PlistBuddy on macOS
    # Remove existing associated domains
    /usr/libexec/PlistBuddy -c "Delete :com.apple.developer.associated-domains" "$ENTITLEMENTS_FILE" 2>/dev/null || true

    # Add associated domains only if not empty
    if [ -n "$ASSOCIATED_DOMAIN" ]; then
        /usr/libexec/PlistBuddy -c "Add :com.apple.developer.associated-domains array" "$ENTITLEMENTS_FILE"
        /usr/libexec/PlistBuddy -c "Add :com.apple.developer.associated-domains:0 string $ASSOCIATED_DOMAIN" "$ENTITLEMENTS_FILE"
    fi

    echo "✅ Entitlements updated using PlistBuddy"
else
    # Fallback for non-macOS systems
    echo "⚠️  Warning: PlistBuddy not available. Using sed-based fallback for entitlements."

    # Create backup
    cp "$ENTITLEMENTS_FILE" "$ENTITLEMENTS_FILE.backup"

    # Remove existing associated domains
    sed -i.tmp '/<key>com.apple.developer.associated-domains<\/key>/,/<\/array>/d' "$ENTITLEMENTS_FILE"

    # Add new associated domains only if not empty
    if [ -n "$ASSOCIATED_DOMAIN" ]; then
        sed -i.tmp "/<\/dict>/i\\
\\t<!-- Associated Domains (auto-generated for $ENVIRONMENT) -->\\
\\t<key>com.apple.developer.associated-domains<\/key>\\
\\t<array>\\
\\t\t<string>$ASSOCIATED_DOMAIN<\/string>\\
\\t<\/array>\\
" "$ENTITLEMENTS_FILE"
    fi

    rm -f "$ENTITLEMENTS_FILE.tmp"
    echo "✅ Entitlements updated using sed fallback"
fi

echo ""
echo "🎉 iOS configuration completed successfully!"
echo "📱 Custom URL Scheme: $URL_SCHEME"
echo "🌐 Associated Domain: ${ASSOCIATED_DOMAIN:-'(none for custom scheme)'}"
echo ""
echo "📋 Configuration summary for $ENVIRONMENT:"
echo "   - Config file: $CONFIG_FILE"
echo "   - DEEP_LINK_BASE_URL: $DEEP_LINK_BASE_URL"
echo "   - Info.plist: Updated with URL scheme"
echo "   - Entitlements: ${ASSOCIATED_DOMAIN:+Updated with associated domain}${ASSOCIATED_DOMAIN:-No associated domain needed}"