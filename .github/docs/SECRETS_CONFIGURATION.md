# CI/CD Secrets and Variables Configuration

Complete reference for all secrets and environment variables required for EduLift's Android and iOS CI/CD pipelines.

## Table of Contents
- [Overview](#overview)
- [Secret Formats](#secret-formats)
- [GitHub Secrets](#github-secrets)
- [Codemagic Environment Variables](#codemagic-environment-variables)
- [Configuration Steps](#configuration-steps)
- [Secret Rotation](#secret-rotation)
- [Verification Checklist](#verification-checklist)
- [Troubleshooting](#troubleshooting)

---

## Overview

### Platform Strategy

| Platform | CI/CD Tool | Secrets Location |
|----------|------------|------------------|
| **Android** | GitHub Actions | GitHub Secrets only |
| **iOS** | Codemagic | Codemagic Environment Variables (copied from GitHub) |

### Key Principles
- **Centralization**: GitHub Secrets as source of truth for Firebase credentials
- **Consistency**: Same Firebase credentials used for both Android and iOS
- **Security**: All secrets marked as secure, never committed to repository
- **Manual Sync**: Codemagic cannot read GitHub Secrets automatically - manual copy required

---

## Secret Formats

Different secrets require different formats. Understanding this is critical for proper configuration.

| Secret | Format | Encoding | Example |
|--------|--------|----------|---------|
| `ANDROID_KEYSTORE` | Binary file → **Base64** | Required | `MIIKXAIBAz...` |
| `KEYSTORE_PASSWORD` | **Plain text** | None | `MySecurePassword123!` |
| `KEY_PASSWORD` | **Plain text** | None | `MyKeyPassword456!` |
| `KEY_ALIAS` | **Plain text** | None | `edulift-release` |
| `FIREBASE_SERVICE_ACCOUNT_STAGING` | **Raw JSON** | None | `{"type":"service_account",...}` |
| `FIREBASE_SERVICE_ACCOUNT_PROD` | **Raw JSON** | None | `{"type":"service_account",...}` |

### Important Distinctions

**Why Base64 for Android Keystore?**
- Keystore is a **binary file** (`.keystore`)
- GitHub Secrets only accepts text
- Must encode binary → base64 text

**Why Raw JSON for Firebase?**
- Service account is a **text file** (`.json`)
- Can be stored directly as-is
- No encoding needed

---

## GitHub Secrets

Configure at: **Repository → Settings → Secrets and variables → Actions**

### 1. Android Code Signing (4 required)

#### `ANDROID_KEYSTORE`
- **Description**: Android release keystore encoded in base64
- **Format**: Base64-encoded binary
- **Used by**: GitHub Actions (Android release builds)
- **How to obtain**: See [ANDROID_KEYSTORE_GUIDE.md](ANDROID_KEYSTORE_GUIDE.md)

```bash
# Generate keystore (if not exists)
keytool -genkey -v -keystore ~/edulift-release.keystore \
  -alias edulift-release \
  -keyalg RSA \
  -keysize 4096 \
  -validity 10000

# Encode to base64
base64 -i ~/edulift-release.keystore -o ~/keystore.base64

# Copy content of keystore.base64 to GitHub Secret
cat ~/keystore.base64
```

#### `KEYSTORE_PASSWORD`
- **Description**: Password for the Android keystore
- **Format**: Plain text
- **Used by**: GitHub Actions (Android release builds)
- **Security**: Use strong password (12+ characters, mixed case, numbers, symbols)

#### `KEY_PASSWORD`
- **Description**: Password for the key within the keystore
- **Format**: Plain text
- **Used by**: GitHub Actions (Android release builds)
- **Note**: Can be the same as `KEYSTORE_PASSWORD`

#### `KEY_ALIAS`
- **Description**: Alias of the key in the keystore
- **Format**: Plain text
- **Used by**: GitHub Actions (Android release builds)
- **Example**: `edulift-release`

### 2. Firebase App Distribution (2 required + 2 optional)

#### `FIREBASE_SERVICE_ACCOUNT_STAGING` (Required)
- **Description**: Firebase staging project service account JSON
- **Format**: Raw JSON (NOT base64)
- **Used by**: GitHub Actions (Android), Codemagic (iOS)
- **How to obtain**:
  1. Go to [Firebase Console](https://console.firebase.google.com)
  2. Select staging project (`390712570284`)
  3. Project settings → Service accounts
  4. Generate new private key
  5. Copy **entire JSON** content

**Example format**:
```json
{
  "type": "service_account",
  "project_id": "edulift-staging",
  "private_key_id": "abc123...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-xxxxx@edulift-staging.iam.gserviceaccount.com",
  "client_id": "123456789",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/..."
}
```

#### `FIREBASE_SERVICE_ACCOUNT_PROD` (Required)
- **Description**: Firebase production project service account JSON
- **Format**: Raw JSON (NOT base64)
- **Used by**: GitHub Actions (Android), Codemagic (iOS)
- **How to obtain**: Same as staging, but for production project (`928262951410`)

#### `FIREBASE_GROUPS_STAGING` (Optional)
- **Description**: Firebase App Distribution tester group for staging
- **Format**: Plain text
- **Default value**: `staging-team` (if not specified)
- **Used by**: GitHub Actions (Android)

#### `FIREBASE_GROUPS_PROD` (Optional)
- **Description**: Firebase App Distribution tester group for production
- **Format**: Plain text
- **Default value**: `production-team` (if not specified)
- **Used by**: GitHub Actions (Android)

### 3. iOS Code Signing (Not Required)

❌ **These secrets are NOT needed** - Codemagic handles automatic code signing

| Secret | Status |
|--------|--------|
| `IOS_CERTIFICATE` | Not used (automatic signing) |
| `IOS_CERTIFICATE_PASSWORD` | Not used (automatic signing) |
| `IOS_PROVISIONING_PROFILE` | Not used (automatic signing) |

---

## Codemagic Environment Variables

Configure at: **Codemagic → App → Application settings → Environment variables**

### Group: `firebase`

Create a variable group named `firebase` with these two variables:

#### `FIREBASE_SERVICE_ACCOUNT_STAGING`
- **Value**: **Exact same JSON** as GitHub Secret
- **Scope**: Secure
- **Used by**: iOS staging builds

#### `FIREBASE_SERVICE_ACCOUNT_PROD`
- **Value**: **Exact same JSON** as GitHub Secret
- **Scope**: Secure
- **Used by**: iOS production builds

**⚠️ Important**: Codemagic **cannot** automatically read GitHub Secrets. You must manually copy the values.

---

## Configuration Steps

### Initial Setup

#### Step 1: Create Android Keystore

If you don't have a keystore yet:

```bash
# Create keystore with 4096-bit key (recommended)
keytool -genkey -v -keystore ~/edulift-release.keystore \
  -alias edulift-release \
  -keyalg RSA \
  -keysize 4096 \
  -validity 10000 \
  -storepass YOUR_KEYSTORE_PASSWORD \
  -keypass YOUR_KEY_PASSWORD

# Encode to base64
base64 -i ~/edulift-release.keystore > ~/keystore.base64
```

**Record these values securely**:
- Keystore password
- Key password
- Key alias: `edulift-release`

#### Step 2: Obtain Firebase Service Accounts

For **both** staging and production projects:

```bash
# Download from Firebase Console
# Project settings → Service accounts → Generate new private key

# You'll have two files:
# - edulift-staging-firebase-adminsdk-xxxxx.json
# - edulift-production-firebase-adminsdk-xxxxx.json
```

#### Step 3: Add to GitHub Secrets

Go to **Repository → Settings → Secrets and variables → Actions**

Add these 6 secrets:

```
ANDROID_KEYSTORE = [base64 content from keystore.base64]
KEYSTORE_PASSWORD = [your keystore password]
KEY_PASSWORD = [your key password]
KEY_ALIAS = edulift-release

FIREBASE_SERVICE_ACCOUNT_STAGING = [entire JSON from staging file]
FIREBASE_SERVICE_ACCOUNT_PROD = [entire JSON from production file]
```

Optional (have default values):
```
FIREBASE_GROUPS_STAGING = staging-team
FIREBASE_GROUPS_PROD = production-team
```

#### Step 4: Add to Codemagic

Go to **Codemagic → App → Application settings → Environment variables**

1. Click **Add variable group**
2. Group name: `firebase`
3. Add two variables:

```
Name: FIREBASE_SERVICE_ACCOUNT_STAGING
Value: [Copy from GitHub Secret - exact same JSON]
Scope: Secure

Name: FIREBASE_SERVICE_ACCOUNT_PROD
Value: [Copy from GitHub Secret - exact same JSON]
Scope: Secure
```

---

## Secret Rotation

### Firebase Service Accounts

When to rotate:
- Regularly (e.g., every 90 days)
- If credentials are compromised
- When team members leave

How to rotate:

1. **Generate new service account** in Firebase Console
   - Project settings → Service accounts → Generate new private key

2. **Update GitHub Secrets**
   - Repository → Settings → Secrets and variables → Actions
   - Edit `FIREBASE_SERVICE_ACCOUNT_STAGING` or `FIREBASE_SERVICE_ACCOUNT_PROD`
   - Paste new JSON

3. **Update Codemagic**
   - App → Application settings → Environment variables
   - Edit `firebase` group
   - Update corresponding variable with new JSON

4. **Revoke old service account**
   - Firebase Console → Project settings → Service accounts
   - Delete old service account

5. **Test builds**
   - Trigger a test build to verify new credentials work

### Android Keystore

⚠️ **DO NOT rotate the Android keystore for a published app!**

**Why?**
- Apps signed with different keystores cannot update each other
- Rotating keystore requires users to uninstall and reinstall
- Google Play won't accept updates signed with different keystore

**If you must change it:**
1. Create new keystore (see Step 1 above)
2. Update GitHub Secrets
3. Publish as a NEW app (different package name)
4. Users must uninstall old app and install new one

---

## Verification Checklist

### Before Production Deployment

#### Android (GitHub Actions)
- [ ] `ANDROID_KEYSTORE` configured and base64-encoded correctly
- [ ] `KEYSTORE_PASSWORD` matches keystore
- [ ] `KEY_PASSWORD` matches key in keystore
- [ ] `KEY_ALIAS` matches alias in keystore
- [ ] `FIREBASE_SERVICE_ACCOUNT_STAGING` contains valid JSON
- [ ] `FIREBASE_SERVICE_ACCOUNT_PROD` contains valid JSON
- [ ] Test build succeeds with `git tag v1.0.0-rc.1`

#### iOS (Codemagic)
- [ ] `firebase` group exists in Codemagic
- [ ] `FIREBASE_SERVICE_ACCOUNT_STAGING` matches GitHub value
- [ ] `FIREBASE_SERVICE_ACCOUNT_PROD` matches GitHub value
- [ ] Both variables have `Scope: Secure`
- [ ] Email notification configured in `codemagic.yaml`
- [ ] Test build succeeds with `git tag v1.0.0-rc.1`

#### Firebase App Distribution
- [ ] `staging-team` group exists in staging project
- [ ] `production-team` group exists in production project
- [ ] At least one tester added to each group
- [ ] Service accounts have "Firebase App Distribution Admin" role

---

## Troubleshooting

### Error: "Android signing failed"

**Possible causes:**
1. Keystore not properly base64-encoded
2. Incorrect password
3. Alias doesn't exist in keystore

**Solutions:**
```bash
# Verify keystore content
keytool -list -v -keystore ~/edulift-release.keystore

# Re-encode to base64
base64 -i ~/edulift-release.keystore > ~/keystore.base64

# Verify password by trying to list keystore
keytool -list -keystore ~/edulift-release.keystore
```

### Error: "Firebase authentication failed"

**Possible causes:**
1. JSON is truncated or invalid
2. Service account lacks permissions
3. Service account was deleted

**Solutions:**
1. Verify JSON is complete (starts with `{` and ends with `}`)
2. Check service account has "Firebase App Distribution Admin" role
3. Generate new service account if needed

### Error: "No such group: staging-team"

**Solution:**
1. Go to Firebase Console → App Distribution
2. Click "Manage testers"
3. Create group named `staging-team` or `production-team`
4. Add at least one tester

### Error: "Keystore was tampered with, or password was incorrect"

**Cause**: Password in GitHub Secret doesn't match keystore

**Solution:**
1. Verify password in password manager
2. Test locally: `keytool -list -keystore keystore -storepass PASSWORD`
3. Update GitHub Secret with correct password

---

## Summary

### Required Secrets Count

| Location | Required | Optional | Total |
|----------|----------|----------|-------|
| **GitHub Secrets** | 6 | 2 | 8 |
| **Codemagic Variables** | 2 | 0 | 2 |
| **Grand Total** | 8 | 2 | **10** |

### Security Checklist

- [ ] All secrets stored securely (GitHub + Codemagic)
- [ ] No secrets committed to repository
- [ ] Keystore backed up in secure location
- [ ] Passwords stored in team password manager
- [ ] Firebase service accounts use least privilege
- [ ] Regular secret rotation schedule established

---

## Additional Resources

- [Android Keystore Guide](ANDROID_KEYSTORE_GUIDE.md) - Detailed keystore creation guide
- [Codemagic Setup](CODEMAGIC_SETUP.md) - iOS build configuration
- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Firebase Service Accounts](https://firebase.google.com/docs/admin/setup)

---

**Last updated**: Configuration aligned for Android (GitHub Actions) and iOS (Codemagic) with automatic code signing.
