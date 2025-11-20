#!/bin/bash
# scripts/download-codemagic-artifacts.sh
set -e

FINAL_BUILD_INFO="$1"
OUTPUT_DIR="$2"

if [[ -z "$FINAL_BUILD_INFO" || -z "$OUTPUT_DIR" ]]; then
  echo "❌ Usage: $0 <build_info_json> <output_dir>"
  exit 1
fi

if [[ -z "$CODEMAGIC_API_TOKEN" ]]; then
  echo "❌ ERROR: CODEMAGIC_API_TOKEN environment variable is not set"
  echo "❌ Make sure the token is properly passed to this script"
  exit 1
fi

echo "📥 Downloading Codemagic artifacts..."
echo "   To directory: $OUTPUT_DIR"

mkdir -p "$OUTPUT_DIR"

# Count artifacts for progress tracking
ARTIFACT_COUNT=$(echo "$FINAL_BUILD_INFO" | jq '.build.artefacts | length')
echo "📊 Found $ARTIFACT_COUNT artifacts to download"

# Parse artifacts and download each one using process substitution to avoid subshell
INDEX=0
while [[ $INDEX -lt $ARTIFACT_COUNT ]]; do
  ARTIFACT=$(echo "$FINAL_BUILD_INFO" | jq -c ".build.artefacts[$INDEX]")

  ARTIFACT_NAME=$(echo "$ARTIFACT" | jq -r '.name')
  ARTIFACT_URL=$(echo "$ARTIFACT" | jq -r '.url')
  ARTIFACT_TYPE=$(echo "$ARTIFACT" | jq -r '.type')

  echo "📦 Downloading: $ARTIFACT_NAME ($ARTIFACT_TYPE)"

  curl -L -H "x-auth-token: $CODEMAGIC_API_TOKEN" -o "$OUTPUT_DIR/$ARTIFACT_NAME" "$ARTIFACT_URL"

  if [[ $? -eq 0 ]]; then
    echo "✅ Downloaded: $OUTPUT_DIR/$ARTIFACT_NAME"
    echo "ARTIFACT_$ARTIFACT_TYPE=$OUTPUT_DIR/$ARTIFACT_NAME" >> $GITHUB_OUTPUT
  else
    echo "❌ Failed to download: $ARTIFACT_NAME"
    exit 1
  fi

  INDEX=$((INDEX + 1))
done

echo "✅ All artifacts downloaded"
echo "📋 Downloaded files:"
ls -la "$OUTPUT_DIR"