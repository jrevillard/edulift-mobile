#!/bin/bash
# Helper functions for EduLift development

# Helper function for opening edulift URLs
edulift() {
    if [ -z "$1" ]; then
        echo "Usage: edulift <url>"
        echo "Example: edulift 'edulift://auth/verify?token=abc123'"
        return 1
    fi
    
    # Check if Flutter app is running
    if ! pgrep -f "flutter_tester|mobile_app" > /dev/null; then
        echo "⚠️  Flutter app not running. Start it with:"
        echo "   cd /workspace/mobile_app && flutter run -d linux"
        return 1
    fi
    
    echo "🔗 Opening: $1"
    # Try xdg-open first, fallback to direct handler
    if ! xdg-open "$1" 2>/dev/null; then
        /workspace/.devcontainer/handle-edulift-url.sh "$1"
    fi
}

# Alias for convenience
alias edl='edulift'

# Function to test the deep link system
test-deeplink() {
    local token="${1:-test-token-123}"
    local url="edulift://auth/verify?token=$token"
    echo "🧪 Testing deep link: $url"
    edulift "$url"
}

echo "✅ EduLift helper functions loaded!"
echo "   - Use 'edulift <url>' to open deep links"
echo "   - Use 'edl <url>' as a shortcut"
echo "   - Use 'test-deeplink [token]' to test with a sample link"