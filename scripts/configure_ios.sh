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

    if [[ "$url" == https://* ]]; then
        # HTTPS Universal Link - no custom URL scheme, only associated domain
        # Extract host and remove port for associated domains (iOS doesn't support ports)
        local host_with_port=$(echo "$url" | sed 's|https://||' | sed 's|/$||')
        local host=$(echo "$host_with_port" | cut -d':' -f1)

        # For HTTPS URLs, only use Universal Links (no custom scheme needed)
        URL_SCHEME=""
        ASSOCIATED_DOMAIN="applinks:$host"
    elif [[ "$url" == *"://"* ]]; then
        # Extract scheme from custom URL (like tanjama://, transport://, etc.)
        local extracted_scheme=$(echo "$url" | cut -d':' -f1)
        URL_SCHEME="$extracted_scheme"
        ASSOCIATED_DOMAIN=""
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

if [ -n "$URL_SCHEME" ]; then
    echo "ℹ️  Adding custom URL scheme: $URL_SCHEME"

    # Create backup
    cp "$PLIST_FILE" "$PLIST_FILE.backup"

    # Safer approach: use Python to properly handle XML structure
    python3 -c "
import re

with open('$PLIST_FILE', 'r') as f:
    content = f.read()

# Remove existing CFBundleURLTypes block safely
content = re.sub(r'\s*<!-- Deep linking support \(auto-generated for .+?\) -->.*?<\/array>\s*', '', content, flags=re.DOTALL)

with open('$PLIST_FILE', 'w') as f:
    f.write(content)
"

    # Insert new CFBundleURLTypes before CFBundleDisplayName
    sed -i.bak "/<key>CFBundleDisplayName<\/key>/i\\
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

    # Remove backup
    rm -f "$PLIST_FILE.bak"

    echo "✅ Info.plist updated with CFBundleURLTypes for $URL_SCHEME"
else
    echo "ℹ️  No custom URL scheme needed (using Universal Links only)"

    # Remove CFBundleURLTypes safely for Universal Links only
    python3 -c "
import re

with open('$PLIST_FILE', 'r') as f:
    content = f.read()

# Remove existing CFBundleURLTypes block safely
content = re.sub(r'\s*<key>CFBundleURLTypes<\/key>.*?<\/array>\s*', '', content, flags=re.DOTALL)

with open('$PLIST_FILE', 'w') as f:
    f.write(content)
"
    echo "✅ CFBundleURLTypes removed (Universal Links only)"
fi

# --- Validate Info.plist syntax ---
echo "🔍 Validating Info.plist syntax..."
python3 -c "
import xml.etree.ElementTree as ET
import sys

try:
    tree = ET.parse('$PLIST_FILE')
    root = tree.getroot()

    # Additional validation: check it's a proper plist
    if root.tag == 'plist' and root.get('version') == '1.0':
        dict_elem = root.find('dict')
        if dict_elem is not None:
            keys = [k.text for k in dict_elem.findall('key')]
            print(f'✅ Info.plist is valid ({len(keys)} keys found)')
        else:
            print('❌ Error: No dict element found in Info.plist')
            sys.exit(1)
    else:
        print('❌ Error: Invalid PList root structure')
        sys.exit(1)

except ET.ParseError as e:
    print(f'❌ XML ParseError in Info.plist: {e}')
    print(f'💡 Fix: Line {e.position[0]}, Column {e.position[1]}')
    sys.exit(1)
except Exception as e:
    print(f'❌ Error validating Info.plist: {e}')
    sys.exit(1)
"

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
