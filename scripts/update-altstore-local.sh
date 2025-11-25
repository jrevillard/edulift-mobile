#!/bin/bash
# scripts/update-altstore-local.sh
# Test AltStore PAL update locally without running full CI

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🚀 AltStore PAL Local Update Script"
echo ""

# Check required env vars
if [[ -z "$GH_TOKEN" ]]; then
  echo -e "${RED}❌ ERROR: GH_TOKEN environment variable is not set${NC}"
  echo "   Export your GitHub token: export GH_TOKEN=ghp_xxx"
  exit 1
fi

# Get parameters
FLAVOR="${1:-staging}"
TAG_NAME="${2}"

if [[ -z "$TAG_NAME" ]]; then
  echo "Usage: $0 <flavor> <tag_name>"
  echo ""
  echo "Example:"
  echo "  export GH_TOKEN=ghp_xxx"
  echo "  $0 staging v0.1.0-alpha11"
  echo ""
  echo "The script will automatically extract version and build number from the GitHub release."
  exit 1
fi

# Extract version from tag (remove 'v' prefix)
VERSION="${TAG_NAME#v}"

# Get build number from GitHub release
echo "📊 Fetching release info from GitHub..."
RELEASE_INFO=$(gh release view "$TAG_NAME" --repo jrevillard/edulift-mobile --json body,tagName,createdAt)

if [[ -z "$RELEASE_INFO" ]]; then
  echo -e "${RED}❌ Failed to fetch release info for $TAG_NAME${NC}"
  echo "   Make sure the release exists on GitHub"
  exit 1
fi

# Extract build number from release body (looks for "**Build:** 181")
BUILD_NUMBER=$(echo "$RELEASE_INFO" | jq -r '.body' | grep -oP '\*\*Build:\*\*\s+\K\d+' || echo "unknown")
ALTSTORE_REPO="jrevillard/my-altstore"
ALTSTORE_BRANCH="main"

echo -e "${YELLOW}Configuration:${NC}"
echo "   Flavor: $FLAVOR"
echo "   Version: $VERSION"
echo "   Tag: $TAG_NAME"
echo "   Build: $BUILD_NUMBER"
echo ""

# Create temp directory
TEMP_DIR=$(mktemp -d)
echo "📁 Working directory: $TEMP_DIR"

# Get IPA from edulift-mobile release
IPA_FILENAME="edulift-${FLAVOR}.ipa"
IPA_PATH="$TEMP_DIR/$IPA_FILENAME"
SOURCE_REPO="jrevillard/edulift-mobile"

echo "📥 Downloading IPA from $SOURCE_REPO release..."
echo "   Tag: $TAG_NAME"
echo "   File: $IPA_FILENAME"

# Download from edulift-mobile repo (requires auth if private)
if ! gh release download "$TAG_NAME" \
     --repo "$SOURCE_REPO" \
     --pattern "$IPA_FILENAME" \
     --dir "$TEMP_DIR"; then
  echo -e "${RED}❌ Failed to download IPA${NC}"
  echo "   Make sure the release exists on $SOURCE_REPO and contains $IPA_FILENAME"
  rm -rf "$TEMP_DIR"
  exit 1
fi

# Verify IPA was downloaded
if [[ ! -f "$IPA_PATH" || ! -s "$IPA_PATH" ]]; then
  echo -e "${RED}❌ IPA file is empty or missing${NC}"
  rm -rf "$TEMP_DIR"
  exit 1
fi

IPA_SIZE=$(stat -c%s "$IPA_PATH" 2>/dev/null || stat -f%z "$IPA_PATH" 2>/dev/null)
echo -e "${GREEN}✅ IPA downloaded: $IPA_SIZE bytes${NC}"
echo ""

# Create release on my-altstore repo with IPA
echo "📦 Creating release on $ALTSTORE_REPO..."

# Delete existing release if present
if gh release view "$TAG_NAME" --repo "$ALTSTORE_REPO" >/dev/null 2>&1; then
  echo "🗑️  Deleting existing release..."
  gh release delete "$TAG_NAME" --repo "$ALTSTORE_REPO" --yes
fi

# Create release and upload IPA
gh release create "$TAG_NAME" \
  --repo "$ALTSTORE_REPO" \
  --title "EduLift $FLAVOR $VERSION" \
  --notes "EduLift Mobile $FLAVOR build

**Version:** $VERSION
**Build:** $BUILD_NUMBER

This release contains the IPA file for AltStore PAL distribution." \
  "$IPA_PATH"

if [[ $? -ne 0 ]]; then
  echo -e "${RED}❌ Failed to create release on $ALTSTORE_REPO${NC}"
  rm -rf "$TEMP_DIR"
  exit 1
fi

echo -e "${GREEN}✅ Release created on $ALTSTORE_REPO${NC}"

# Update download URL to point to my-altstore repo
DOWNLOAD_URL="https://github.com/$ALTSTORE_REPO/releases/download/$TAG_NAME/$IPA_FILENAME"
echo "   Download URL: $DOWNLOAD_URL"
echo ""

# Clone AltStore repo
ALTSTORE_DIR="$TEMP_DIR/altstore"
mkdir -p "$ALTSTORE_DIR"
cd "$ALTSTORE_DIR"

echo "📦 Cloning AltStore repository..."
if ! gh repo clone "$ALTSTORE_REPO" .; then
  echo -e "${RED}❌ Failed to clone AltStore repo${NC}"
  rm -rf "$TEMP_DIR"
  exit 1
fi

git checkout "$ALTSTORE_BRANCH"
git config user.name "$(git config --global user.name)"
git config user.email "$(git config --global user.email)"

echo -e "${GREEN}✅ Repository cloned${NC}"
echo ""

# Run the update script from my-altstore repo
echo "🚀 Running update-altstore.sh script..."
chmod +x scripts/update-altstore.sh

./scripts/update-altstore.sh \
  "edulift" \
  "$FLAVOR" \
  "$DOWNLOAD_URL" \
  "$VERSION" \
  "$IPA_SIZE"

echo -e "${GREEN}✅ Update script completed${NC}"
echo ""

# Commit and push
echo "📤 Committing and pushing to GitHub..."
if git diff --quiet && git diff --staged --quiet; then
  echo -e "${YELLOW}ℹ️  No changes to commit (version already up to date)${NC}"
else
  git add .
  git commit -m "feat: update EduLift $FLAVOR to version $VERSION

- Version: $VERSION
- Build: $BUILD_NUMBER
- IPA Size: $IPA_SIZE bytes
- Download URL: $DOWNLOAD_URL

🤖 Updated locally via update-altstore-local.sh"

  if git push origin "$ALTSTORE_BRANCH"; then
    echo -e "${GREEN}✅ Successfully pushed to AltStore repository${NC}"
  else
    echo -e "${RED}❌ Failed to push to GitHub${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
  fi
fi

# Cleanup
cd /
rm -rf "$TEMP_DIR"

echo ""
echo -e "${GREEN}🎉 AltStore PAL update completed successfully!${NC}"
echo ""
echo "🔗 Links:"
echo "   AltStore repo: https://github.com/$ALTSTORE_REPO"
echo "   JSON file: https://github.com/$ALTSTORE_REPO/blob/$ALTSTORE_BRANCH/$APP_JSON"
echo "   Download URL: $DOWNLOAD_URL"
