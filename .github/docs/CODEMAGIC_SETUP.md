# Codemagic iOS Build Configuration

Complete guide for setting up iOS builds using Codemagic with automatic code signing (no Apple Developer account required).

## Table of Contents
- [Overview](#overview)
- [Build Strategy](#build-strategy)
- [Prerequisites](#prerequisites)
- [Configuration Steps](#configuration-steps)
- [Triggering Builds](#triggering-builds)
- [Build Workflows](#build-workflows)
- [Troubleshooting](#troubleshooting)
- [Cost Considerations](#cost-considerations)

---

## Overview

EduLift Mobile uses a hybrid CI/CD approach:
- **Android builds**: GitHub Actions (all environments)
- **iOS builds**: Codemagic (staging and production only)

### Key Features
✨ **No Apple Developer account required** - Codemagic handles automatic code signing
🚀 **Firebase App Distribution** - Direct distribution to testers
🔄 **Aligned with Android pipeline** - Same triggers, same Firebase groups
⚡ **Free tier available** - 500 build minutes per month

---

## Build Strategy

| Environment | Platform | CI/CD Tool | Trigger |
|-------------|----------|------------|---------|
| Development | Android | GitHub Actions | Push to `main` |
| Development | iOS | Local builds | N/A (manual) |
| Staging | Android | GitHub Actions | Tags: `v*-rc.*`, `v*-beta.*`, `v*-alpha.*` |
| Staging | iOS | Codemagic | Tags: `v*-rc.*`, `v*-beta.*`, `v*-alpha.*` |
| Production | Android | GitHub Actions | Tags: `v*.*.*` (no suffixes) |
| Production | iOS | Codemagic | Tags: `v*.*.*` (no suffixes) |

---

## Prerequisites

### 1. Codemagic Account
- Sign up at https://codemagic.io
- Connect your GitHub repository
- Free tier: 500 minutes/month

### 2. Firebase Projects
- **Staging Project**: `390712570284`
  - iOS App ID: `1:390712570284:ios:11ab124204e6c10c054a09`
  - Tester Group: `staging-team`

- **Production Project**: `928262951410`
  - iOS App ID: `1:928262951410:ios:139da35e9a165907779b6b`
  - Tester Group: `production-team`

### 3. Bundle Identifiers
- **Staging**: `com.edulift.app.staging`
- **Production**: `com.edulift.app`

### 4. No Apple Developer Account Needed!
Codemagic provides **automatic code signing**:
- ✅ Generates code signing certificates automatically
- ✅ Manages provisioning profiles
- ✅ Signs apps for ad-hoc distribution
- ✅ Perfect for Firebase App Distribution
- ✅ No $99/year Apple Developer Program fee

---

## Configuration Steps

### Step 1: Verify `codemagic.yaml` Configuration

The repository already contains a configured `codemagic.yaml` file with automatic code signing:

```yaml
environment:
  ios_signing:
    distribution_type: ad_hoc
    bundle_identifier: com.edulift.app.staging  # or com.edulift.app for production
```

**What Codemagic does automatically:**
1. Initializes keychain for code signing
2. Generates signing certificates
3. Creates provisioning profiles
4. Signs the iOS IPA
5. No manual certificate management needed!

### Step 2: Configure Firebase Service Accounts

**Important**: You must configure Firebase secrets in **two places**:
1. **GitHub Secrets** (for Android via GitHub Actions)
2. **Codemagic Environment Variables** (for iOS via Codemagic)

⚠️ **Codemagic cannot read GitHub Secrets** - manual copy is required.

#### Step 2.1: Download Firebase Service Account JSON

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your **staging** project
3. Navigate to **Project settings** → **Service accounts**
4. Click **Generate new private key** → Download JSON file
5. Repeat for **production** project

You will have two files:
- `edulift-staging-firebase-adminsdk-xxxxx.json`
- `edulift-production-firebase-adminsdk-xxxxx.json`

#### Step 2.2: Add to GitHub Secrets (for Android)

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add both secrets:

```
Name: FIREBASE_SERVICE_ACCOUNT_STAGING
Value: [Paste ENTIRE JSON content from staging file]

Name: FIREBASE_SERVICE_ACCOUNT_PROD
Value: [Paste ENTIRE JSON content from production file]
```

**Format**: Raw JSON (not base64), example:
```json
{
  "type": "service_account",
  "project_id": "edulift-staging",
  "private_key_id": "abc123...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...",
  ...
}
```

#### Step 2.3: Add to Codemagic (for iOS)

1. Go to [Codemagic](https://codemagic.io/apps)
2. Select your EduLift application
3. Navigate to **Application settings** → **Environment variables**
4. Click **Add variable group**
5. Group name: `firebase`
6. Add both variables:

```
Name: FIREBASE_SERVICE_ACCOUNT_STAGING
Value: [Paste ENTIRE JSON content - same as GitHub Secret]
Scope: Secure

Name: FIREBASE_SERVICE_ACCOUNT_PROD
Value: [Paste ENTIRE JSON content - same as GitHub Secret]
Scope: Secure
```

**💡 Centralized Approach**:
- **Source of truth**: JSON files from Firebase Console
- **Same values everywhere**: GitHub and Codemagic use identical credentials
- **Easy rotation**: Update in Firebase → Copy to GitHub and Codemagic

### Step 3: Update Email Notifications

In `codemagic.yaml`, replace the placeholder email:

```yaml
email:
  recipients:
    - build-notifications@example.com  # Replace with your email
```

### Step 4: Verify Bundle Identifiers

Ensure bundle IDs match across:
- `codemagic.yaml` (BUNDLE_ID vars)
- Xcode project settings
- Firebase console app configurations

**Staging**: `com.edulift.app.staging`
**Production**: `com.edulift.app`

---

## Triggering Builds

### Staging Build

Push a pre-release tag:
```bash
git tag v1.0.0-rc.1
git push origin v1.0.0-rc.1
```

**What happens:**
1. Codemagic detects the tag matching `v*-rc.*`, `v*-beta.*`, or `v*-alpha.*`
2. Builds iOS staging flavor with automatic code signing
3. Generates timestamp-based build number
4. Distributes signed IPA to Firebase App Distribution (`staging-team` group)
5. Sends email notification

### Production Build

Push a production tag:
```bash
git tag v1.0.0
git push origin v1.0.0
```

**What happens:**
1. Codemagic detects the tag matching `v*.*.*` (without suffixes)
2. Builds iOS production flavor with automatic code signing
3. Generates timestamp-based build number
4. Distributes signed IPA to Firebase App Distribution (`production-team` group)
5. Sends email notification

---

## Build Workflows

### iOS Staging Workflow (`v*-rc.*`, `v*-beta.*`, `v*-alpha.*`)

**Trigger**: Pre-release tags
**Instance**: Mac mini M2
**Max duration**: 60 minutes

**Steps:**
1. ✅ Get Flutter dependencies (`flutter pub get`)
2. ✅ Run code generation (`build_runner build`)
3. ✅ Initialize keychain for code signing
4. ✅ Install CocoaPods dependencies (`pod install`)
5. ✅ Set up automatic code signing (Codemagic managed)
6. ✅ Generate timestamp build number
7. ✅ Build signed IPA with staging flavor
8. ✅ Upload to Firebase App Distribution (`staging-team` group)
9. ✅ Send email notification

**Artifacts:**
- `build/ios/ipa/*.ipa` - Signed iOS application
- `$HOME/Library/Developer/Xcode/DerivedData/**/Build/**/*.dSYM` - Debug symbols

### iOS Production Workflow (`v*.*.*`)

**Trigger**: Production tags (no suffixes)
**Instance**: Mac mini M2
**Max duration**: 60 minutes
**Cancel previous builds**: No (ensures production builds complete)

**Steps:**
1. ✅ Get Flutter dependencies (`flutter pub get`)
2. ✅ Run code generation (`build_runner build`)
3. ✅ Initialize keychain for code signing
4. ✅ Install CocoaPods dependencies (`pod install`)
5. ✅ Set up automatic code signing (Codemagic managed)
6. ✅ Generate timestamp build number
7. ✅ Build signed IPA with production flavor
8. ✅ Upload to Firebase App Distribution (`production-team` group)
9. ✅ Send email notification

**Artifacts:**
- `build/ios/ipa/*.ipa` - Signed iOS application
- `$HOME/Library/Developer/Xcode/DerivedData/**/Build/**/*.dSYM` - Debug symbols

---

## Troubleshooting

### Build Fails: "Firebase authentication failed"

**Cause**: Invalid or missing Firebase service account credentials

**Solution:**
1. Verify `FIREBASE_SERVICE_ACCOUNT_STAGING` or `FIREBASE_SERVICE_ACCOUNT_PROD` in Codemagic
2. Ensure the JSON is complete and valid (no truncation)
3. Check the service account has "Firebase App Distribution Admin" role in Firebase Console
4. Regenerate service account if necessary

### Build Fails: "Code signing failed"

**Cause**: Automatic code signing configuration issue

**Solution:**
1. Verify `ios_signing` configuration in `codemagic.yaml`
2. Check bundle identifier matches exactly: `com.edulift.app.staging` or `com.edulift.app`
3. Review Codemagic build logs for detailed error messages
4. Contact Codemagic support if issue persists

### Distribution Fails: "No such group: staging-team"

**Cause**: Firebase App Distribution group doesn't exist

**Solution:**
1. Go to Firebase Console → App Distribution
2. Create group named `staging-team` (for staging) or `production-team` (for production)
3. Add at least one tester to the group
4. Retry the build

### Build Times Out

**Cause**: Build exceeded 60-minute limit

**Solution:**
1. Review build logs to identify slow steps
2. Increase `max_build_duration` if consistently timing out
3. Consider caching dependencies (CocoaPods, Flutter)
4. Upgrade to faster Codemagic instance if needed

---

## Cost Considerations

### Codemagic Pricing (2025)
- **Free tier**: 500 minutes/month (perfect for small teams)
- **Pro plan**: Starting at $99/month for 3 concurrent builds
- **Mac mini M2 instances**: Faster builds, higher minute cost

### Estimated Usage per Build
- **Staging build**: ~15-20 minutes
- **Production build**: ~15-20 minutes

### Monthly Estimate
Assuming 2-4 builds per month:
- **Total minutes**: 60-160 minutes
- **Recommendation**: Free tier is sufficient for most teams
- **Scale up**: Upgrade to Pro if you need more frequent builds or concurrent builds

### Cost Comparison
- **Codemagic Free**: $0/month (500 minutes)
- **GitHub Actions**: Free for public repos, included minutes for private repos
- **Apple Developer Program**: $99/year (not needed with Codemagic automatic signing!)

**Total savings**: $99/year by using Codemagic automatic code signing instead of Apple Developer Program

---

## Best Practices

### 1. Build Numbers
- ✅ Automatic timestamp-based: `$(date +%s)`
- ✅ Unique per build
- ✅ No manual management needed
- ❌ Don't manually set build numbers

### 2. Environment Separation
- ✅ Staging and production use separate Firebase projects
- ✅ Different bundle identifiers prevent conflicts
- ✅ Separate tester groups for controlled distribution

### 3. Security
- ✅ All credentials stored in Codemagic environment variables (scope: Secure)
- ✅ Firebase service accounts use least privilege (Firebase App Distribution Admin only)
- ✅ Never commit secrets to repository
- ✅ Rotate service accounts periodically

### 4. Testing Before Production
- ✅ Always test with staging builds first
- ✅ Use Firebase App Distribution for internal testing
- ✅ Verify builds install correctly before production release

---

## Monitoring

### Codemagic Dashboard
- View build status: https://codemagic.io/apps
- Check logs for detailed build information
- Monitor build duration and success rates
- Track monthly minute usage

### Email Notifications
- **Success**: Build completed, IPA distributed
- **Failure**: Error details and logs included

### Firebase App Distribution
- Track download and installation rates
- Collect feedback from testers
- Monitor crash reports

---

## Additional Resources

- [Codemagic Documentation](https://docs.codemagic.io/)
- [Flutter iOS Builds Guide](https://docs.codemagic.io/yaml-quick-start/building-a-flutter-app/)
- [Firebase App Distribution](https://firebase.google.com/docs/app-distribution)
- [Codemagic Automatic Code Signing](https://docs.codemagic.io/yaml-code-signing/signing-ios/)

---

## Support

For issues or questions:
1. Check Codemagic build logs (most detailed information)
2. Review this documentation
3. Check [Codemagic Community](https://community.codemagic.io/)
4. Contact Codemagic support (Pro plan only)

---

**Last updated**: Aligned with Android CD pipeline, using automatic code signing without Apple Developer account.
