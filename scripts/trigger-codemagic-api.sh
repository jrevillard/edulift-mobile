#!/bin/bash
# scripts/trigger-codemagic-api.sh
set -e

# Parse arguments
APP_ID="$1"
WORKFLOW_ID="$2"
BRANCH="$3"
BUILD_REASON="$4"  # ex: "release-v2.1.0-alpha1"
DRY_RUN=""

if [[ "$5" == "--dry-run" ]]; then
  DRY_RUN="--dry-run"
fi

echo "🚀 Triggering Codemagic build..."
echo "   App ID: $APP_ID"
echo "   Workflow: $WORKFLOW_ID"
echo "   Branch: $BRANCH"
echo "   Reason: $BUILD_REASON"

TRIGGER_DATA=$(cat <<EOF
{
  "appId": "$APP_ID",
  "workflowId": "$WORKFLOW_ID",
  "branch": "$BRANCH",
  "environment": {
    "GITHUB_TAG": "$BUILD_REASON"
  }
}
EOF
)

if [[ "$DRY_RUN" == "--dry-run" ]]; then
  echo "🔍 DRY RUN: Would trigger build with data:"
  echo "$TRIGGER_DATA" | jq '.'
  echo "🔗 API URL: https://api.codemagic.io/builds"
  BUILD_ID="dry-run-build-id"
else
  echo "📡 Sending trigger request..."

  # Retry logic with exponential backoff
  MAX_RETRIES=3
  RETRY_DELAY=5
  RETRY_COUNT=0

  while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if [ $RETRY_COUNT -gt 0 ]; then
      echo "🔄 Retry attempt $RETRY_COUNT/$MAX_RETRIES (waiting ${RETRY_DELAY}s)..."
      sleep $RETRY_DELAY
      RETRY_DELAY=$((RETRY_DELAY * 2))  # Exponential backoff
    fi

    RESPONSE=$(curl -s -w "%{http_code}" -X POST \
      -H "Content-Type: application/json" \
      -H "x-auth-token: $CODEMAGIC_API_TOKEN" \
      -d "$TRIGGER_DATA" \
      "https://api.codemagic.io/builds")

    HTTP_CODE="${RESPONSE: -3}"
    RESPONSE_BODY="${RESPONSE%???}"

    if [ "$HTTP_CODE" = "200" ]; then
      echo "✅ API call successful"
      RESPONSE="$RESPONSE_BODY"
      break
    else
      echo "❌ API call failed (HTTP $HTTP_CODE)"
      if [ $RETRY_COUNT -eq $((MAX_RETRIES - 1)) ]; then
        echo "🚨 All retry attempts exhausted"
        echo "Last response: $RESPONSE_BODY"
        exit 1
      fi
    fi

    RETRY_COUNT=$((RETRY_COUNT + 1))
  done
fi

if [[ "$DRY_RUN" == "--dry-run" ]]; then
  echo "✅ DRY RUN: Build would be triggered successfully"
else
  BUILD_ID=$(echo "$RESPONSE" | jq -r '.buildId')

  if [[ -z "$BUILD_ID" || "$BUILD_ID" == "null" ]]; then
    echo "❌ Failed to trigger build"
    echo "Response: $RESPONSE"
    exit 1
  fi
fi

echo "✅ Build triggered successfully"
echo "BUILD_ID=$BUILD_ID"
echo "BUILD_ID=$BUILD_ID" >> $GITHUB_OUTPUT

# Log build URL for monitoring
BUILD_URL="https://codemagic.io/app/$APP_ID/build/$BUILD_ID"
echo "📊 Monitor build at: $BUILD_URL"
echo "BUILD_URL=$BUILD_URL" >> $GITHUB_OUTPUT