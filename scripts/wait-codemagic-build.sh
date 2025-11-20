#!/bin/bash
# scripts/wait-codemagic-build.sh
set -e

BUILD_ID="$1"
MAX_WAIT_TIME="${2:-1800}"  # 30 minutes default
POLL_INTERVAL="${3:-30}"     # 30 seconds default

echo "⏳ Waiting for Codemagic build completion..."
echo "   Build ID: $BUILD_ID"
echo "   Max wait: $MAX_WAIT_TIME seconds"
echo "   Poll interval: $POLL_INTERVAL seconds"

if [[ -z "$CODEMAGIC_API_TOKEN" ]]; then
  echo "❌ ERROR: CODEMAGIC_API_TOKEN environment variable is not set"
  echo "❌ Make sure the token is properly passed to this script"
  exit 1
fi

WAIT_TIME=0

while [[ $WAIT_TIME -lt $MAX_WAIT_TIME ]]; do
  echo "📊 Checking build status... (${WAIT_TIME}s elapsed)"

  STATUS_RESPONSE=$(curl -s -X GET \
    -H "Content-Type: application/json" \
    -H "x-auth-token: $CODEMAGIC_API_TOKEN" \
    "https://api.codemagic.io/builds/$BUILD_ID")

  BUILD_STATUS=$(echo "$STATUS_RESPONSE" | jq -r '.build.status')
  echo "📋 Current status: $BUILD_STATUS"

  case "$BUILD_STATUS" in
    "finished")
      echo "✅ Build completed successfully!"
      echo "FINAL_BUILD_INFO<<EOF" >> $GITHUB_ENV
      echo "$STATUS_RESPONSE" >> $GITHUB_ENV
      echo "EOF" >> $GITHUB_ENV
      exit 0
      ;;
    "failed")
      echo "❌ Build failed"
      echo "Final response: $STATUS_RESPONSE"
      exit 1
      ;;
    "canceled"|"timeout")
      echo "❌ Build was $BUILD_STATUS"
      exit 1
      ;;
    *)
      # Continue waiting for queued/preparing/building/finishing
      ;;
  esac

  sleep $POLL_INTERVAL
  WAIT_TIME=$((WAIT_TIME + POLL_INTERVAL))
done

echo "❌ Build timed out after $MAX_WAIT_TIME seconds"
exit 1