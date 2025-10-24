#!/bin/bash
# Handler script for edulift:// URLs

URL="$1"
echo "[$(date)] Handling EduLift URL: $URL" >> /tmp/edulift-handler.log

# Extract the Flutter app's PID if it's running
FLUTTER_PID=$(pgrep -f "/workspace/build/linux/x64/debug/bundle/edulift" | head -1)

if [ -n "$FLUTTER_PID" ]; then
    echo "[$(date)] Found Flutter app with PID: $FLUTTER_PID" >> /tmp/edulift-handler.log
    
    # Send the URL to the Flutter app via a temporary file
    # The Flutter app can watch this file for deep links in development
    echo "$URL" > /tmp/edulift-deeplink
    echo "[$(date)] Wrote URL to /tmp/edulift-deeplink" >> /tmp/edulift-handler.log
    
    # Try to bring the Flutter window to front using xdotool
    if command -v xdotool >/dev/null 2>&1; then
        FLUTTER_WINDOW=$(xdotool search --pid $FLUTTER_PID 2>/dev/null | head -1)
        if [ -n "$FLUTTER_WINDOW" ]; then
            xdotool windowactivate $FLUTTER_WINDOW 2>/dev/null || true
            echo "[$(date)] Activated Flutter window: $FLUTTER_WINDOW" >> /tmp/edulift-handler.log
        fi
    fi
    
    echo "✅ Deep link sent to Flutter app"
else
    echo "[$(date)] Flutter app not running!" >> /tmp/edulift-handler.log
    echo "❌ Flutter app not running. Start it with:"
    echo "   cd /workspace && flutter run -d linux"
    exit 1
fi