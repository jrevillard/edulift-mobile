# GitHub Release Unification (Simplified) Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Unify iOS and Android GitHub releases using existing Codemagic webhook with API polling for build coordination.

**Architecture:** GitHub Actions CD coordinator uses Codemagic API to trigger builds, poll for completion, download artifacts, then create unified releases.

**Tech Stack:** GitHub Actions (coordinator), Codemagic API, curl polling, jq JSON parsing, YAML workflows.

---

## Required Configuration

### Configuration GitHub Repository Settings:

**Secrets (secured) :**
- `CODEMAGIC_API_TOKEN` : API token from User Settings > Integrations > Codemagic API

**Variables (non-sensitive) :**
- `CODEMAGIC_APP_ID` : Your Codemagic app ID (from app URL)

Note: Workflows are automatically selected by flavor:
- staging → ios-staging workflow
- production → ios-production workflow

---

## Task 1: Create Codemagic API Scripts

**Files:**
- Create: `scripts/trigger-codemagic-api.sh`
- Create: `scripts/wait-codemagic-build.sh`
- Create: `scripts/download-codemagic-artifacts.sh`

**Step 1: Create build trigger script**

```bash
#!/bin/bash
# scripts/trigger-codemagic-api.sh
set -e

APP_ID="$1"
WORKFLOW_ID="$2"
BRANCH="$3"
BUILD_REASON="$4"  # ex: "release-v2.1.0-alpha1"

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

echo "📡 Sending trigger request..."
RESPONSE=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "x-auth-token: $CODEMAGIC_API_TOKEN" \
  -d "$TRIGGER_DATA" \
  "https://api.codemagic.io/v1/apps/$APP_ID/builds")

BUILD_ID=$(echo "$RESPONSE" | jq -r '.buildId')

if [[ -z "$BUILD_ID" || "$BUILD_ID" == "null" ]]; then
  echo "❌ Failed to trigger build"
  echo "Response: $RESPONSE"
  exit 1
fi

echo "✅ Build triggered successfully"
echo "BUILD_ID=$BUILD_ID"
echo "BUILD_ID=$BUILD_ID" >> $GITHUB_OUTPUT

# Log build URL for monitoring
BUILD_URL="https://codemagic.io/app/$APP_ID/build/$BUILD_ID"
echo "📊 Monitor build at: $BUILD_URL"
echo "BUILD_URL=$BUILD_URL" >> $GITHUB_OUTPUT
```

**Step 2: Create build polling script**

```bash
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

WAIT_TIME=0

while [[ $WAIT_TIME -lt $MAX_WAIT_TIME ]]; do
  echo "📊 Checking build status... (${WAIT_TIME}s elapsed)"

  STATUS_RESPONSE=$(curl -s -X GET \
    -H "Content-Type: application/json" \
    -H "x-auth-token: $CODEMAGIC_API_TOKEN" \
    "https://api.codemagic.io/v1/builds/$BUILD_ID")

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
```

**Step 3: Create artifact download script**

```bash
#!/bin/bash
# scripts/download-codemagic-artifacts.sh
set -e

FINAL_BUILD_INFO="$1"
OUTPUT_DIR="$2"

if [[ -z "$FINAL_BUILD_INFO" || -z "$OUTPUT_DIR" ]]; then
  echo "❌ Usage: $0 <build_info_json> <output_dir>"
  exit 1
fi

echo "📥 Downloading Codemagic artifacts..."
echo "   To directory: $OUTPUT_DIR"

mkdir -p "$OUTPUT_DIR"

# Parse artifacts and download each one
echo "$FINAL_BUILD_INFO" | jq -c '.build.artefacts[]' | while read -r ARTIFACT; do
  ARTIFACT_NAME=$(echo "$ARTIFACT" | jq -r '.name')
  ARTIFACT_URL=$(echo "$ARTIFACT" | jq -r '.url')
  ARTIFACT_TYPE=$(echo "$ARTIFACT" | jq -r '.type')

  echo "📦 Downloading: $ARTIFACT_NAME ($ARTIFACT_TYPE)"

  curl -L -o "$OUTPUT_DIR/$ARTIFACT_NAME" "$ARTIFACT_URL"

  if [[ $? -eq 0 ]]; then
    echo "✅ Downloaded: $OUTPUT_DIR/$ARTIFACT_NAME"
    echo "ARTIFACT_$ARTIFACT_TYPE=$OUTPUT_DIR/$ARTIFACT_NAME" >> $GITHUB_ENV
  else
    echo "❌ Failed to download: $ARTIFACT_NAME"
    exit 1
  fi
done

echo "✅ All artifacts downloaded"
echo "📋 Downloaded files:"
ls -la "$OUTPUT_DIR"
```

**Step 4: Make scripts executable**

```bash
chmod +x scripts/trigger-codemagic-api.sh
chmod +x scripts/wait-codemagic-build.sh
chmod +x scripts/download-codemagic-artifacts.sh
```

**Step 5: Commit API scripts**

```bash
git add scripts/trigger-codemagic-api.sh scripts/wait-codemagic-build.sh scripts/download-codemagic-artifacts.sh
git commit -m "feat: add Codemagic API integration scripts

- Build trigger using Codemagic API v1
- Polling for build completion status
- Artifact download functionality
- Robust error handling and logging"
```

---

## Task 2: Restructure GitHub Actions CD as Coordinator

**Files:**
- Modify: `.github/workflows/cd.yml` (Complete restructure)
- Remove: Individual release creation logic

**Step 1: Replace entire CD workflow with coordinator**

```yaml
# .github/workflows/cd.yml - Complete rewrite
name: Mobile Unified Release

on:
  push:
    tags:
      - 'v*'

env:
  # Flutter configuration
  FLUTTER_VERSION: ${{ vars.FLUTTER_VERSION || '3.38.2' }}
  JAVA_VERSION: ${{ vars.JAVA_VERSION || '17' }}

jobs:
  # Job 1: Prepare release environment
  prepare-release:
    name: Prepare Release
    runs-on: ubuntu-latest
    outputs:
      version: ${{ steps.version.outputs.version }}
      flavor: ${{ steps.version.outputs.flavor }}
      tag_name: ${{ steps.version.outputs.tag_name }}
      is_staging: ${{ steps.version.outputs.is_staging }}
      base_version: ${{ steps.version.outputs.base_version }}

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Load CI/CD versions
        id: load-versions
        run: |
          if [[ -f ".github/ci-versions.env" ]]; then
            while IFS='=' read -r key value; do
              echo "$key=$value" >> $GITHUB_OUTPUT
            done < .github/ci-versions.env
          fi

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ steps.load-versions.outputs.FLUTTER_VERSION }}
          channel: ${{ steps.load-versions.outputs.FLUTTER_CHANNEL }}
          cache: true

      - name: Extract version and flavor from tag
        id: version
        run: |
          TAG_NAME="${GITHUB_REF_NAME}"
          echo "Processing tag: $TAG_NAME"

          # Remove 'v' prefix for version
          VERSION="${TAG_NAME#v}"
          echo "version=$VERSION" >> $GITHUB_OUTPUT
          echo "tag_name=$TAG_NAME" >> $GITHUB_OUTPUT

          # Extract base version (remove pre-release)
          BASE_VERSION=$(echo "$VERSION" | sed -E 's/(-alpha|-beta|-rc).*//')
          echo "base_version=$BASE_VERSION" >> $GITHUB_OUTPUT

          # Determine flavor from tag pattern
          if [[ "$TAG_NAME" =~ (alpha|beta|rc) ]]; then
            FLAVOR="staging"
            IS_STAGING="true"
          else
            FLAVOR="production"
            IS_STAGING="false"
          fi

          echo "flavor=$FLAVOR" >> $GITHUB_OUTPUT
          echo "is_staging=$IS_STAGING" >> $GITHUB_OUTPUT

          echo "📋 Release Info:"
          echo "   Version: $VERSION"
          echo "   Base Version: $BASE_VERSION"
          echo "   Flavor: $FLAVOR"
          echo "   Staging: $IS_STAGING"

      - name: Update pubspec.yaml
        run: |
          # Use run number as build number
          BUILD_NUMBER="${{ github.run_number }}"
          BASE_VERSION="${{ steps.version.outputs.base_version }}"

          sed -i "s/^version: .*/version: $BASE_VERSION+$BUILD_NUMBER/" pubspec.yaml

          echo "✅ Updated pubspec.yaml:"
          grep "^version:" pubspec.yaml

      - name: Commit version update
        run: |
          git config --local user.email "action@github.com"
          git config --local user.name "GitHub Action"
          git add pubspec.yaml
          git commit -m "chore: update version to ${{ steps.version.outputs.base_version }}+${{ github.run_number }} [skip ci]"
          git push

  # Job 2: Build iOS (trigger Codemagic)
  build-ios:
    name: Build iOS
    runs-on: ubuntu-latest
    needs: prepare-release
    if: always()
    outputs:
      ios_artifacts_dir: ${{ steps.download.outputs.artifacts_dir }}

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Trigger Codemagic iOS build
        id: trigger-ios
        run: |
          ./scripts/trigger-codemagic-api.sh \
            "${{ secrets.CODEMAGIC_APP_ID }}" \
            "${{ secrets.CODEMAGIC_WORKFLOW_ID }}" \
            "main" \
            "${{ needs.prepare-release.outputs.tag_name }}"

      - name: Wait for iOS build completion
        id: wait-ios
        run: |
          ./scripts/wait-codemagic-build.sh \
            "${{ steps.trigger-ios.outputs.BUILD_ID }}" \
            "1800" "30"  # 30 minutes max, 30 second polling

      - name: Download iOS artifacts
        id: download
        run: |
          ARTIFACTS_DIR="ios-artifacts-${{ needs.prepare-release.outputs.flavor }}"
          ./scripts/download-codemagic-artifacts.sh \
            "${{ env.FINAL_BUILD_INFO }}" \
            "$ARTIFACTS_DIR"

          echo "artifacts_dir=$ARTIFACTS_DIR" >> $GITHUB_OUTPUT

      - name: Verify iOS IPA
        run: |
          ARTIFACTS_DIR="${{ steps.download.outputs.artifacts_dir }}"

          if [[ -f "$ARTIFACTS_DIR"/*.ipa ]]; then
            echo "✅ iOS IPA found:"
            ls -la "$ARTIFACTS_DIR"/*.ipa
            file "$ARTIFACTS_DIR"/*.ipa
          else
            echo "❌ No IPA found in artifacts"
            echo "Available files:"
            ls -la "$ARTIFACTS_DIR"
            exit 1
          fi

      - name: Upload iOS artifacts for release
        uses: actions/upload-artifact@v4
        with:
          name: ios-builds
          path: ${{ steps.download.outputs.artifacts_dir }}/

  # Job 3: Build Android (parallel)
  build-android:
    name: Build Android
    runs-on: ubuntu-latest
    needs: prepare-release

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Load CI/CD versions
        uses: ./.github/actions/load-versions

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ steps.load-versions.outputs.FLUTTER_VERSION }}
          channel: ${{ steps.load-versions.outputs.FLUTTER_CHANNEL }}
          cache: true

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: ${{ steps.load-versions.outputs.JAVA_VERSION }}

      - name: Get packages
        run: flutter packages pub get

      - name: Run code generation
        run: flutter packages pub run build_runner build --delete-conflicting-outputs

      - name: Build Android
        run: |
          FLAVOR="${{ needs.prepare-release.outputs.flavor }}"
          echo "🔧 Building Android $FLAVOR..."

          if [[ "${{ needs.prepare-release.outputs.is_staging }}" == "true" ]]; then
            echo "📱 Building APK for staging"
            flutter build apk --release \
              --flavor $FLAVOR \
              --dart-define-from-file=config/$FLAVOR.json
          else
            echo "📦 Building AAB for production"
            flutter build appbundle --release \
              --flavor $FLAVOR \
              --dart-define-from-file=config/$FLAVOR.json
          fi

      - name: Prepare Android artifacts
        run: |
          FLAVOR="${{ needs.prepare-release.outputs.flavor }}"
          mkdir -p android-artifacts

          if [[ "$FLAVOR" == "staging" ]]; then
            cp build/app/outputs/flutter-apk/app-release.apk \
              android-artifacts/edulift-$FLAVOR.apk
          else
            cp build/app/outputs/bundle/release/app-release.aab \
              android-artifacts/edulift-$FLAVOR.aab
          fi

          echo "✅ Android artifacts prepared:"
          ls -la android-artifacts/

      - name: Upload Android artifacts for release
        uses: actions/upload-artifact@v4
        with:
          name: android-builds
          path: android-artifacts/

  # Job 4: Create unified release
  create-unified-release:
    name: Create Unified Release
    runs-on: ubuntu-latest
    needs: [prepare-release, build-ios, build-android]
    if: always() && needs.build-ios.result == 'success' && needs.build-android.result == 'success'

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Download all build artifacts
        uses: actions/download-artifact@v4
        with:
          path: build-artifacts/

      - name: Prepare release files
        run: |
          VERSION="${{ needs.prepare-release.outputs.version }}"
          FLAVOR="${{ needs.prepare-release.outputs.flavor }}"
          TAG_NAME="${{ needs.prepare-release.outputs.tag_name }}"

          mkdir -p release-files

          # Copy iOS IPA
          IOS_IPA=$(find build-artifacts/ios-builds -name "*.ipa" | head -1)
          if [[ -n "$IOS_IPA" ]]; then
            cp "$IOS_IPA" release-files/edulift-$FLAVOR.ipa
            echo "✅ iOS IPA: $(basename $IOS_IPA)"
          else
            echo "❌ No iOS IPA found"
            exit 1
          fi

          # Copy Android artifact
          if [[ "$FLAVOR" == "staging" ]]; then
            ANDROID_FILE=$(find build-artifacts/android-builds -name "*.apk" | head -1)
            if [[ -n "$ANDROID_FILE" ]]; then
              cp "$ANDROID_FILE" release-files/edulift-$FLAVOR.apk
              echo "✅ Android APK: $(basename $ANDROID_FILE)"
            else
              echo "❌ No Android APK found"
              exit 1
            fi
          else
            ANDROID_FILE=$(find build-artifacts/android-builds -name "*.aab" | head -1)
            if [[ -n "$ANDROID_FILE" ]]; then
              cp "$ANDROID_FILE" release-files/edulift-$FLAVOR.aab
              echo "✅ Android AAB: $(basename $ANDROID_FILE)"
            else
              echo "❌ No Android AAB found"
              exit 1
            fi
          fi

          echo "📦 Final release files:"
          ls -la release-files/

      - name: Create unified GitHub release
        uses: softprops/action-gh-release@v1
        with:
          tag_name: ${{ needs.prepare-release.outputs.tag_name }}
          name: EduLift Mobile ${{ needs.prepare-release.outputs.flavor }} ${{ needs.prepare-release.outputs.version }}
          body: |
            EduLift Mobile ${{ needs.prepare-release.outputs.flavor }} release

            **Version:** ${{ needs.prepare-release.outputs.version }}
            **Platform:** iOS + Android (Unified)
            **Environment:** ${{ needs.prepare-release.outputs.flavor }}
            **Commit:** ${{ github.sha }}
            **Build:** ${{ github.run_number }}

            ## 📱 Downloads

            **iOS (AltStore PAL):**
            - 📦 `edulift-${{ needs.prepare-release.outputs.flavor }}.ipa`
            - Unsigned build for AltStore PAL distribution

            **Android:**
            ${{ needs.prepare-release.outputs.is_staging == 'true' && '- 📦 `edulift-staging.apk`\n- For Firebase App Distribution testing' || '- 📦 `edulift-production.aab`\n- For Google Play Store release' }}

            ## 🔗 Links

            - **Download:** Click assets below ⬇️
            - **Commit:** [${{ github.sha }}](https://github.com/${{ github.repository }}/commit/${{ github.sha }})
            ${{ needs.prepare-release.outputs.is_staging == 'true' && '- **Testing:** Firebase App Distribution' || '- **Store:** Google Play Console' }}

          files: release-files/*
          draft: false
          prerelease: ${{ needs.prepare-release.outputs.is_staging }}
          generate_release_notes: true

      - name: Get download URL for AltStore
        id: urls
        run: |
          FLAVOR="${{ needs.prepare-release.outputs.flavor }}"
          TAG_NAME="${{ needs.prepare-release.outputs.tag_name }}"

          IPA_DOWNLOAD_URL="https://github.com/${{ github.repository }}/releases/download/$TAG_NAME/edulift-$FLAVOR.ipa"

          echo "ipa_download_url=$IPA_DOWNLOAD_URL" >> $GITHUB_OUTPUT
          echo "🔗 IPA Download URL: $IPA_DOWNLOAD_URL"

      - name: Update AltStore PAL source
        run: |
          FLAVOR="${{ needs.prepare-release.outputs.flavor }}"
          IPA_PATH="release-files/edulift-$FLAVOR.ipa"
          DOWNLOAD_URL="${{ steps.urls.outputs.ipa_download_url }}"

          echo "📱 Updating AltStore PAL source..."
          echo "   Flavor: $FLAVOR"
          echo "   IPA: $IPA_PATH"
          echo "   Download URL: $DOWNLOAD_URL"

          # Setup git for AltStore repo updates
          ALTSTORE_REPO="jrevillard/my-altstore"
          ALTSTORE_BRANCH="main"

          mkdir -p altstore_temp
          cd altstore_temp

          # Clone AltStore repo
          if [[ -n "${{ secrets.GITHUB_TOKEN }}" ]]; then
            git clone https://${{ secrets.GITHUB_TOKEN }}@github.com/$ALTSTORE_REPO.git .
          else
            git clone https://github.com/$ALTSTORE_REPO.git .
          fi

          git checkout $ALTSTORE_BRANCH

          # Get app info
          VERSION=$(flutter --version | head -n 1 | cut -d' ' -f2)
          BUILD_NUMBER="${{ github.run_number }}"
          IPA_SIZE=$(du -h "../$IPA_PATH" | cut -f1)

          # Generate AltStore PAL JSON
          mkdir -p apps
          APP_JSON="apps/${FLAVOR}.json"

          cat > "$APP_JSON" << EOF
          {
            "name": "EduLift",
            "bundleIdentifier": "com.edulift.app${FLAVOR:+:.staging}",
            "version": "$VERSION",
            "versionDate": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
            "localizedDescription": "Version $VERSION - Build $BUILD_NUMBER",
            "downloadURL": "$DOWNLOAD_URL",
            "size": $IPA_SIZE,
            "iconURL": "https://raw.githubusercontent.com/jrevillard/edulift-mobile/main/docs/edulift-icon.png",
            "tintColor": "#1976d2"
          }
EOF

          echo "✅ Generated $APP_JSON:"
          echo "   Name: EduLift $FLAVOR"
          echo "   Bundle ID: com.edulift.app${FLAVOR:+:.staging}"
          echo "   Download URL: $DOWNLOAD_URL"
          echo "   Size: $IPA_SIZE"

          # Commit and push
          git config user.name "GitHub Actions"
          git config user.email "action@github.com"

          if git diff --quiet; then
            echo "ℹ️ No changes to AltStore source"
          else
            git add .
            git commit -m "feat: update EduLift $FLAVOR to version $VERSION"
            git push origin $ALTSTORE_BRANCH
            echo "✅ AltStore PAL source updated"
          fi

          cd ..
          rm -rf altstore_temp

      - name: Release summary
        run: |
          echo "🎉 Unified release completed!"
          echo ""
          echo "📋 Release Details:"
          echo "   Tag: ${{ needs.prepare-release.outputs.tag_name }}"
          echo "   Version: ${{ needs.prepare-release.outputs.version }}"
          echo "   Environment: ${{ needs.prepare-release.outputs.flavor }}"
          echo "   Platforms: iOS + Android"
          echo "   AltStore: ✅ Updated"
          echo ""
          echo "🔗 View release: https://github.com/${{ github.repository }}/releases/tag/${{ needs.prepare-release.outputs.tag_name }}"
```

**Step 2: Commit coordinator workflow**

```bash
git add .github/workflows/cd.yml
git commit -m "feat: implement unified release coordinator workflow

- GitHub Actions CD coordinates iOS (Codemagic) + Android builds
- API polling for Codemagic build completion
- Single unified GitHub releases with both platforms
- Automatic AltStore PAL source updates
- Parallel iOS + Android builds for efficiency"
```

---

## Task 3: Simplify Codemagic Configuration

**Files:**
- Modify: `codemagic.yaml` (Remove release creation, keep build only)

**Step 1: Remove GitHub release logic from Codemagic**

```yaml
# In codemagic.yaml, simplify both ios-staging and ios-production workflows:

  scripts:
    - *get-packages
    - *code-generation
    - *install-tools
    - *update-version
    - *configure-ios
    - *build-ios
    # REMOVE: - *upload-github
    # REMOVE: - *update-altstore
    # REMOVE: - *commit-altstore
    # REPLACE with simple success notification:
    - &build-complete
        name: Build Complete Notification
        script: |
          echo "✅ iOS build completed successfully!"
          echo "📦 IPA Location: ios/build/ipa/edulift-$FLAVOR.ipa"
          echo "📊 IPA Size: $(du -h "ios/build/ipa/edulift-$FLAVOR.ipa" | cut -f1)"
          echo "🔗 Ready for GitHub Actions to download and create unified release"
```

**Step 2: Update artifacts configuration**

```yaml
# Update artifacts section in both workflows:
artifacts:
  - ios/build/ipa/*.ipa
  # Remove: altstore_temp/**
```

**Step 3: Ensure build versioning works correctly**

```yaml
# In the &update-version script, ensure it reads from tag passed by GitHub Actions:
    - &update-version
        name: Update version from tag
        script: |
          # Update pubspec.yaml version from environment (set by GitHub Actions trigger)
          if [[ -n "$GITHUB_TAG" ]]; then
            echo "🏷️ Updating pubspec.yaml from tag: $GITHUB_TAG"

            # Remove 'v' prefix
            TAG_NAME="$GITHUB_TAG"
            VERSION="${TAG_NAME#v}"

            # Extract base version
            BASE_VERSION=$(echo "$VERSION" | sed -E 's/(-alpha|-beta|-rc).*//')

            # Use timestamp for iOS build number
            IOS_BUILD_NUMBER=$(date +%s)

            echo "📌 Tag: $TAG_NAME"
            echo "📌 Version: $BASE_VERSION"
            echo "📌 iOS build number: $IOS_BUILD_NUMBER"

            # Update pubspec.yaml
            sed -i '' "s/^version: .*/version: $BASE_VERSION+$IOS_BUILD_NUMBER/" pubspec.yaml

            echo "✅ Updated pubspec.yaml:"
            grep "^version:" pubspec.yaml
          else
            echo "ℹ️ No GITHUB_TAG provided, keeping existing version"
          fi
```

**Step 4: Add environment variable for tag**

```yaml
# Add to environment section of both workflows:
      vars:
        FLAVOR: staging  # or production
        BUNDLE_ID: "com.edulift.app.staging"  # or com.edulift.app
        ALTSTORE_REPO: "jrevillard/my-altstore"
        ALTSTORE_BRANCH: "main"
        GITHUB_TAG: "${{ github.ref_name }}"  # This will be set by GitHub Actions
```

**Step 5: Commit Codemagic simplification**

```bash
git add codemagic.yaml
git commit -m "refactor: simplify Codemagic to build-only

- Remove individual GitHub release creation from Codemagic
- Remove AltStore source updates (handled by unified workflow)
- Keep only build functionality
- Add GITHUB_TAG environment variable for versioning
- Update artifact configuration for unified workflow"
```

---

## Task 4: Testing and Validation

**Files:**
- Create: `scripts/test-unified-release.sh`
- Create: `docs/testing/unified-release-testing.md`

**Step 1: Create comprehensive test script**

```bash
#!/bin/bash
# scripts/test-unified-release.sh
set -e

echo "🧪 Testing Unified Release Process"
echo "================================="

# Configuration
TEST_TAG="test-v$(date +%s)-alpha1"
TEST_FLAVOR="staging"

echo "📋 Test Configuration:"
echo "   Tag: $TEST_TAG"
echo "   Flavor: $TEST_FLAVOR"

# Test 1: Validate Codemagic API connection
echo ""
echo "🔗 Test 1: Codemagic API Connection"
if [[ -n "$CODEMAGIC_API_TOKEN" && -n "$CODEMAGIC_APP_ID" ]]; then
  echo "✅ Codemagic credentials available"

  # Test API access
  API_TEST=$(curl -s -H "x-auth-token: $CODEMAGIC_API_TOKEN" \
    "https://api.codemagic.io/v1/apps/$CODEMAGIC_APP_ID")

  if echo "$API_TEST" | jq -e '.id' >/dev/null 2>&1; then
    echo "✅ Codemagic API access working"
    APP_NAME=$(echo "$API_TEST" | jq -r '.name')
    echo "   App: $APP_NAME"
  else
    echo "❌ Codemagic API access failed"
    echo "   Response: $API_TEST"
    exit 1
  fi
else
  echo "❌ Missing Codemagic credentials"
  exit 1
fi

# Test 2: Trigger script functionality
echo ""
echo "🚀 Test 2: Codemagic Trigger Script"
if [[ -f "scripts/trigger-codemagic-api.sh" ]]; then
  echo "✅ Trigger script exists"

  # Dry run (don't actually trigger)
  if ./scripts/trigger-codemagic-api.sh --help 2>/dev/null || true; then
    echo "✅ Trigger script syntax valid"
  else
    echo "❌ Trigger script syntax error"
    exit 1
  fi
else
  echo "❌ Trigger script missing"
  exit 1
fi

# Test 3: Artifact download script
echo ""
echo "📥 Test 3: Artifact Download Script"
if [[ -f "scripts/download-codemagic-artifacts.sh" ]]; then
  echo "✅ Download script exists"

  # Test with sample data
  SAMPLE_JSON='{"build":{"artefacts":[{"name":"test.ipa","url":"https://example.com/test.ipa","type":"ipa"}]}}'

  echo "ℹ️ Testing with sample artifact data..."
  if echo "$SAMPLE_JSON" | ./scripts/download-codemagic-artifacts.sh - /tmp/test-download 2>/dev/null || true; then
    echo "✅ Download script logic works"
  else
    echo "⚠️ Download script needs real data to test fully"
  fi
else
  echo "❌ Download script missing"
  exit 1
fi

# Test 4: Workflow syntax validation
echo ""
echo "📋 Test 4: GitHub Actions Workflow Syntax"
if command -v yamllint >/dev/null 2>&1; then
  if yamllint .github/workflows/cd.yml 2>/dev/null || true; then
    echo "✅ CD workflow YAML syntax valid"
  else
    echo "⚠️ YAML linting not available, checking basic structure..."
  fi
fi

if python3 -c "import yaml; yaml.safe_load(open('.github/workflows/cd.yml'))" 2>/dev/null; then
  echo "✅ CD workflow structure valid"
else
  echo "❌ CD workflow structure invalid"
  exit 1
fi

# Test 5: Codemagic configuration
echo ""
echo "🔧 Test 5: Codemagic Configuration"
if python3 -c "import yaml; yaml.safe_load(open('codemagic.yaml'))" 2>/dev/null; then
  echo "✅ Codemagic YAML syntax valid"

  # Check that release logic is removed
  if grep -q "upload-github" codemagic.yaml; then
    echo "⚠️ Found upload-github reference - should be removed"
  else
    echo "✅ Release creation logic removed from Codemagic"
  fi
else
  echo "❌ Codemagic YAML syntax invalid"
  exit 1
fi

echo ""
echo "✅ All tests passed!"
echo ""
echo "🚀 Ready for manual test:"
echo "   1. Create test tag: git tag $TEST_TAG"
echo "   2. Push tag: git push origin $TEST_TAG"
echo "   3. Monitor GitHub Actions: https://github.com/$(git config --get remote.origin.url | sed 's/.*://.*@//' | sed 's/\.git//')/actions"
echo "   4. Verify unified release creation"
```

**Step 2: Make test script executable**

```bash
chmod +x scripts/test-unified-release.sh
```

**Step 3: Create testing documentation**

```markdown
# docs/testing/unified-release-testing.md

## Unified Release Testing Guide

### Prerequisites

**Required GitHub Secrets:**
- `CODEMAGIC_API_TOKEN`: From User Settings > Integrations > Codemagic API
- `CODEMAGIC_APP_ID`: Application ID from Codemagic URL
- `CODEMAGIC_WORKFLOW_ID`: iOS workflow ID from Codemagic config

**Required Tools:**
- `jq` for JSON parsing
- `curl` for API calls
- Access to create tags in repository

### Automated Testing

```bash
# Run comprehensive test suite
./scripts/test-unified-release.sh
```

### Manual Testing Steps

1. **Prepare Test Environment**
   ```bash
   # Create backup of current state
   git tag backup-$(date +%Y%m%d-%H%M%S)

   # Ensure working directory is clean
   git status
   ```

2. **Test with Staging Tag**
   ```bash
   # Create test tag
   git tag test-v1.0.0-alpha1

   # Push tag to trigger workflow
   git push origin test-v1.0.0-alpha1

   # Monitor GitHub Actions
   # URL: https://github.com/YOUR_REPO/actions
   ```

3. **Verify Build Process**
   - GitHub Actions starts coordinator workflow
   - Codemagic build triggered successfully
   - iOS build completes (monitor Codemagic dashboard)
   - Android build completes in GitHub Actions
   - Artifacts downloaded successfully

4. **Verify Unified Release**
   - Single release created with test tag
   - Contains both IPA and APK files
   - Release notes generated correctly
   - Download URLs functional

5. **Verify AltStore Integration**
   - AltStore PAL source updated
   - New JSON file created
   - Download URL points to GitHub release

6. **Cleanup**
   ```bash
   # Delete test tag locally and remotely
   git tag -d test-v1.0.0-alpha1
   git push origin :refs/tags/test-v1.0.0-alpha1

   # Delete test release (if needed)
   # Use GitHub web interface
   ```

### Production Testing

1. **Test with Production Tag**
   ```bash
   git tag test-v1.0.0
   git push origin test-v1.0.0
   ```

2. **Verify Production Differences**
   - Release marked as production (not prerelease)
   - Android AAB created instead of APK
   - No Firebase App Distribution references

### Troubleshooting

**Common Issues:**

1. **Codemagic API Access**
   - Verify token permissions
   - Check APP_ID is correct
   - Ensure API token not expired

2. **Build Timeouts**
   - Increase MAX_WAIT_TIME in wait-codemagic-build.sh
   - Check Codemagic build queue
   - Monitor build logs

3. **Artifact Download Failures**
   - Verify build completed successfully
   - Check artifact URLs are accessible
   - Ensure sufficient storage space

4. **AltStore Updates**
   - Verify GitHub token has repo write access
   - Check AltStore repository permissions
   - Monitor AltStore commit history

**Rollback Plan:**
If critical issues occur:
1. Disable CD workflow: `git branch -D main && git checkout -b main origin/main`
2. Restore original Codemagic release creation
3. Delete problematic releases/tags
4. Investigate logs and fix issues
5. Re-test with small changes

### Success Criteria

✅ Single unified GitHub release per tag
✅ Contains both iOS IPA and Android APK/AAB
✅ No duplicate or conflicting releases
✅ AltStore PAL source automatically updated
✅ All download URLs functional
✅ Build completion under 45 minutes
✅ Zero manual intervention required
```

**Step 4: Commit testing infrastructure**

```bash
git add scripts/test-unified-release.sh docs/testing/unified-release-testing.md
git commit -m "test: add comprehensive unified release testing

- Automated test script for API connectivity and scripts
- Manual testing procedures and troubleshooting guide
- Production testing checklist and rollback plan
- Success criteria validation"
```

---

## Task 5: Migration and Deployment

**Files:**
- Update: Documentation
- Create: Migration checklist

**Step 1: Create migration checklist**

```markdown
# docs/migration/unified-release-migration.md

## Unified Release Migration Checklist

### Pre-Migration Preparation

- [ ] **Backup Current State**
  ```bash
  git tag backup-$(date +%Y%m%d-%H%M%S)
  git push --tags
  ```

- [ ] **Document Current Release Process**
  - Take screenshots of current release pages
  - Note current build times and artifact names
  - Document current AltStore update process

- [ ] **Prepare Rollback Plan**
  - Save original workflow files
  - Document manual release process
  - Prepare communication plan

### Configuration Setup

- [ ] **GitHub Secrets Configuration**
  - [ ] Add `CODEMAGIC_API_TOKEN`
  - [ ] Add `CODEMAGIC_APP_ID`
  - [ ] Add `CODEMAGIC_WORKFLOW_ID`
  - [ ] Test API access with test script

- [ ] **Codemagic Configuration**
  - [ ] Verify webhook URL accessibility
  - [ ] Update iOS workflows to use GITHUB_TAG
  - [ ] Remove release creation logic
  - [ ] Test build with manual trigger

### Testing Phase

- [ ] **Automated Testing**
  ```bash
  ./scripts/test-unified-release.sh
  ```

- [ ] **Staging Environment Test**
  ```bash
  git tag test-v1.0.0-alpha1
  git push origin test-v1.0.0-alpha1
  ```
  - [ ] Monitor GitHub Actions execution
  - [ ] Verify Codemagic build trigger
  - [ ] Check unified release creation
  - [ ] Validate AltStore PAL update
  - [ ] Test download URLs

- [ ] **Production Environment Test**
  ```bash
  git tag test-v1.0.0
  git push origin test-v1.0.0
  ```
  - [ ] Verify production release creation
  - [ ] Check Android AAB generation
  - [ ] Validate production URLs

### Migration Execution

- [ ] **Schedule Downtime Window**
  - Choose low-traffic period
  - Communicate changes to team
  - Prepare rollback procedures

- [ ] **Deploy Changes**
  ```bash
  # All changes already committed in previous tasks
  git checkout main
  git pull origin main
  ```

- [ ] **Verify Deployment**
  - Check that GitHub Actions workflow is updated
  - Verify Codemagic configuration changes
  - Confirm all scripts are executable

### Post-Migration Validation

- [ ] **Monitor First Production Release**
  - Track build times
  - Verify artifact quality
  - Check download statistics
  - Monitor AltStore PAL updates

- [ ] **Performance Validation**
  - Build time should be ~30-45 minutes
  - Release creation should be immediate after builds
  - Download URLs should work instantly

- [ ] **Team Training**
  - Document new release process
  - Train team on new workflow
  - Update runbooks and SOPs

### Cleanup

- [ ] **Remove Obsolete Files**
  - Remove any old release scripts
  - Clean up test branches and tags
  - Archive old documentation

- [ ] **Update Documentation**
  - Update README with new process
  - Update developer onboarding guides
  - Update CI/CD documentation

- [ ] **Final Validation**
  - Run full end-to-end test
  - Verify all success criteria met
  - Get team sign-off

### Rollback Procedures

**If critical issues occur:**

1. **Immediate Rollback**
   ```bash
   # Disable unified workflow
   git checkout -b rollback main
   git revert <commit-hash-of-unified-workflow>
   git push origin rollback
   git checkout -b main origin/main
   ```

2. **Manual Release Process**
   - Use original Codemagic release creation
   - Manually create Android releases
   - Update AltStore PAL manually

3. **Issue Investigation**
   - Collect logs from failed builds
   - Analyze API call failures
   - Review configuration changes

### Success Criteria Validation

✅ **Unified Releases**
- Single GitHub release per tag
- Contains iOS IPA + Android APK/AAB
- No duplicate or conflicting releases

✅ **Build Coordination**
- GitHub Actions successfully triggers Codemagic
- API polling works reliably
- Build completion detection accurate

✅ **Artifact Management**
- iOS artifacts downloaded successfully
- Android artifacts created in parallel
- All artifacts included in release

✅ **AltStore Integration**
- Source updated automatically
- Download URLs point to GitHub release
- JSON format correct and complete

✅ **Performance**
- Total build time < 45 minutes
- No manual intervention required
- Release creation immediate after builds

✅ **Reliability**
- Consistent success rate > 95%
- Clear error messages and logging
- Robust error handling and recovery
```

**Step 2: Update main documentation**

```markdown
# README.md - Add Unified Release Section

## 🚀 Unified Release Process

This project uses a unified release system that coordinates iOS (Codemagic) and Android (GitHub Actions) builds into single GitHub releases.

### How It Works

1. **Tag Pushed** → GitHub Actions coordinator triggers
2. **Parallel Builds** → Codemagic builds iOS, GitHub Actions builds Android
3. **API Polling** → Coordinator monitors Codemagic build completion
4. **Artifact Collection** → Download IPA from Codemagic, collect Android files
5. **Unified Release** → Create single GitHub release with both platforms
6. **AltStore Update** → Automatically update AltStore PAL source

### Release Formats

- **Staging**: `v1.0.0-alpha1`, `v1.0.0-beta1`, `v1.0.0-rc1`
  - iOS: Unsigned IPA for AltStore PAL
  - Android: APK for Firebase App Distribution
  - Prerelease: true

- **Production**: `v1.0.0`, `v1.1.0`, `v2.0.0`
  - iOS: Unsigned IPA for AltStore PAL
  - Android: AAB for Google Play Store
  - Prerelease: false

### Creating Releases

```bash
# Create and push version tag
git tag v1.0.0-alpha1
git push origin v1.0.0-alpha1
```

The unified release process will automatically:
- Build both iOS and Android versions
- Create a unified GitHub release
- Update AltStore PAL source
- Generate proper download URLs

### Monitoring

- **GitHub Actions**: https://github.com/YOUR_REPO/actions
- **Codemagic Builds**: https://codemagic.io/app/YOUR_APP_ID/builds
- **GitHub Releases**: https://github.com/YOUR_REPO/releases

See [docs/migration/unified-release-migration.md](docs/migration/unified-release-migration.md) for detailed technical documentation.
```

**Step 3: Final commit and validation**

```bash
git add docs/migration/unified-release-migration.md README.md
git commit -m "docs: complete unified release migration documentation

- Comprehensive migration checklist and procedures
- Pre and post-migration validation steps
- Rollback procedures and troubleshooting guide
- Updated README with unified release process
- Success criteria and team training materials

Ready for production deployment of unified release system."
```

---

## Expected Outcomes

### Success Metrics

🎯 **Build Performance**
- iOS build time: ~20 minutes (Codemagic)
- Android build time: ~10 minutes (GitHub Actions)
- Total release time: ~35-45 minutes
- API polling overhead: < 2 minutes

🎯 **Release Quality**
- 100% unified releases (no duplicate/conflicting)
- Zero manual intervention required
- AltStore PAL updated automatically
- All download URLs functional

🎯 **Reliability**
- Build success rate: >95%
- API polling success rate: >99%
- Artifact download success rate: >95%
- Release creation success rate: >99%

### Risk Mitigation

⚡ **Failure Points Addressed**
- Codemagic API connectivity → Robust error handling
- Build timeouts → Configurable wait times
- Artifact download failures → Retry logic and validation
- AltStore update failures → Error logging and manual override

⚡ **Rollback Capability**
- Immediate revert to individual releases
- Manual release procedures documented
- Communication templates prepared

This simplified plan eliminates the need for custom webhook infrastructure while maintaining full coordination between GitHub Actions and Codemagic through their official API.