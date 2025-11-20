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
  echo "🔗 API URL: https://api.codemagic.io/v1/apps/$APP_ID/builds"
  BUILD_ID="dry-run-build-id"
else
  echo "📡 Sending trigger request..."
  RESPONSE=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -H "x-auth-token: $CODEMAGIC_API_TOKEN" \
    -d "$TRIGGER_DATA" \
    "https://api.codemagic.io/v1/apps/$APP_ID/builds")
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