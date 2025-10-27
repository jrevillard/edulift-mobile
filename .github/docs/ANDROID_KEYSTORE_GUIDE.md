# Android Keystore Creation Guide

Complete guide for creating and managing the Android release keystore for EduLift Mobile.

## Table of Contents
- [Overview](#overview)
- [Creating the Keystore](#creating-the-keystore)
- [Encoding for GitHub](#encoding-for-github)
- [Extracting Information](#extracting-information)
- [Adding to GitHub Secrets](#adding-to-github-secrets)
- [Testing the Keystore](#testing-the-keystore)
- [Security and Backup](#security-and-backup)
- [Troubleshooting](#troubleshooting)

---

## Overview

### What is an Android Keystore?

An Android keystore is a **digital certificate** that signs your application. It is **mandatory** for:
- Publishing to Google Play Store
- Distributing release builds
- Updating your application (must always use the same keystore)

### ⚠️ CRITICAL WARNING

Once your app is published to production, you **must always use the same keystore**.

**If you lose the keystore:**
- ❌ You cannot update the app on Google Play Store
- ❌ You must publish as a completely new app
- ❌ Users must uninstall and reinstall

**Bottom line**: Backup your keystore securely!

---

## Creating the Keystore

### Prerequisites
- Java JDK installed (included with Android Studio)
- Terminal/Command Prompt access

### Key Size: 2048 vs 4096 bits

| Size | Security | Performance | Recommendation |
|------|----------|-------------|----------------|
| **2048 bits** | Adequate (secure until ~2030-2035) | Faster | OK for testing/development |
| **4096 bits** | Excellent (secure until 2050+) | Negligible difference | ⭐ **Recommended for production** |

**Verdict**: Use **4096 bits** for production - the keystore is valid for 27 years, so future-proof it.

### Step-by-Step Creation

#### Option 1: Interactive Mode (Recommended for First Time)

```bash
keytool -genkey -v -keystore ~/edulift-release.keystore \
  -alias edulift-release \
  -keyalg RSA \
  -keysize 4096 \
  -validity 10000
```

The command will prompt you for:
1. **Keystore password** (choose a strong password, min 12 characters)
2. **Key password** (can be the same as keystore password)
3. **Your name**: `EduLift Development Team`
4. **Organizational unit**: `Mobile Development`
5. **Organization**: `EduLift`
6. **City**: `Your City`
7. **State/Province**: `Your State`
8. **Country code**: `US` (or your country code)

#### Option 2: Non-Interactive Mode (Automated)

```bash
keytool -genkey -v -keystore ~/edulift-release.keystore \
  -alias edulift-release \
  -keyalg RSA \
  -keysize 4096 \
  -validity 10000 \
  -storepass YOUR_KEYSTORE_PASSWORD \
  -keypass YOUR_KEY_PASSWORD \
  -dname "CN=EduLift Development Team, OU=Mobile Development, O=EduLift, L=Your City, ST=Your State, C=US"
```

**Replace**:
- `YOUR_KEYSTORE_PASSWORD`: Your chosen keystore password
- `YOUR_KEY_PASSWORD`: Your chosen key password (can match keystore password)
- Location details as appropriate

### Parameters Explained

| Parameter | Description | Value |
|-----------|-------------|-------|
| `-keystore` | Output path | `~/edulift-release.keystore` |
| `-alias` | Key identifier | `edulift-release` (remember this!) |
| `-keyalg` | Algorithm | `RSA` (standard) |
| `-keysize` | Key length | `4096` (recommended) |
| `-validity` | Valid days | `10000` (~27 years) |
| `-storepass` | Keystore password | Strong password |
| `-keypass` | Key password | Strong password (can match storepass) |

### ✅ Success

After execution, you should have:
- File: `~/edulift-release.keystore`
- Keystore password (recorded securely)
- Key password (recorded securely)
- Key alias: `edulift-release`

---

## Encoding for GitHub

GitHub Secrets only accepts text, but the keystore is a binary file. We must encode it to base64.

### macOS / Linux

```bash
# Encode to base64
base64 -i ~/edulift-release.keystore -o ~/keystore.base64

# View the encoded content
cat ~/keystore.base64
```

### Windows (PowerShell)

```powershell
# Encode to base64
[Convert]::ToBase64String([IO.File]::ReadAllBytes("$HOME\edulift-release.keystore")) | Out-File keystore.base64

# View the encoded content
Get-Content keystore.base64
```

### Result

You'll have a `keystore.base64` file containing a long string like:
```
MIIKXAIBAzCCChoGCSqGSIb3DQEHAaCCCgsEggoHMIIKAzCCBW8GCSqGSIb...
```

This is what you'll paste into GitHub Secrets as `ANDROID_KEYSTORE`.

---

## Extracting Information

### Verify Keystore Contents

```bash
keytool -list -v -keystore ~/edulift-release.keystore
```

**Enter keystore password when prompted.**

You should see:
```
Keystore type: PKCS12
Keystore provider: SUN

Your keystore contains 1 entry

Alias name: edulift-release
Creation date: ...
Entry type: PrivateKeyEntry
Certificate chain length: 1
Certificate[1]:
Owner: CN=EduLift Development Team, OU=Mobile Development, O=EduLift, ...
Issuer: CN=EduLift Development Team, OU=Mobile Development, O=EduLift, ...
Serial number: ...
Valid from: ... until: ... (Valid for 10000 days)
Certificate fingerprints:
  SHA1: ...
  SHA256: ...
Signature algorithm name: SHA256withRSA
Subject Public Key Algorithm: 2048-bit RSA key
Version: 3
```

### Extract Information for GitHub

From the output above, note:

| GitHub Secret | Value | Where to Find |
|---------------|-------|---------------|
| `ANDROID_KEYSTORE` | Base64 content | `cat ~/keystore.base64` |
| `KEYSTORE_PASSWORD` | Your password | What you entered during creation |
| `KEY_PASSWORD` | Your password | What you entered during creation |
| `KEY_ALIAS` | `edulift-release` | "Alias name" in keystore listing |

---

## Adding to GitHub Secrets

### Step 1: Navigate to Repository Secrets

1. Go to your GitHub repository
2. Click **Settings**
3. Navigate to **Secrets and variables** → **Actions**

### Step 2: Add Each Secret

Click **New repository secret** and add:

#### Secret 1: ANDROID_KEYSTORE
```
Name: ANDROID_KEYSTORE
Value: [Paste ENTIRE content from keystore.base64]
```

#### Secret 2: KEYSTORE_PASSWORD
```
Name: KEYSTORE_PASSWORD
Value: [Your keystore password]
```

#### Secret 3: KEY_PASSWORD
```
Name: KEY_PASSWORD
Value: [Your key password]
```

#### Secret 4: KEY_ALIAS
```
Name: KEY_ALIAS
Value: edulift-release
```

### ✅ Verification

After adding all secrets, you should have 4 new repository secrets configured.

---

## Testing the Keystore

Before using in production, verify the keystore works correctly.

### Test 1: List Keystore

```bash
keytool -list -keystore ~/edulift-release.keystore -storepass YOUR_PASSWORD
```

**Expected**: Should list the keystore contents without error.

### Test 2: Manual APK Signing

```bash
# Build an APK
cd /workspace
flutter build apk --release \
  --flavor production \
  --dart-define-from-file=config/production.json

# Sign the APK
jarsigner -verbose \
  -sigalg SHA256withRSA \
  -digestalg SHA-256 \
  -keystore ~/edulift-release.keystore \
  -storepass YOUR_KEYSTORE_PASSWORD \
  -keypass YOUR_KEY_PASSWORD \
  build/app/outputs/flutter-apk/app-production-release.apk \
  edulift-release

# Verify signature
jarsigner -verify -verbose -certs \
  build/app/outputs/flutter-apk/app-production-release.apk
```

**Expected output**: `jar verified.`

### Test 3: CI/CD Build

Trigger a test build:
```bash
git tag v1.0.0-rc.1
git push origin v1.0.0-rc.1
```

Check GitHub Actions to ensure Android build succeeds.

---

## Security and Backup

### Password Security

✅ **DO**:
- Use strong passwords (12+ characters, mixed case, numbers, symbols)
- Store passwords in a team password manager (1Password, Bitwarden, etc.)
- Use different passwords for keystore and key (optional but recommended)

❌ **DON'T**:
- Use simple passwords (`password123`, `edulift`, etc.)
- Share passwords via email or chat
- Commit passwords to repository

### Keystore Backup Strategy

**Critical**: The keystore is irreplaceable. Implement a multi-tier backup strategy.

#### Tier 1: Encrypted Local Backup

```bash
# Create encrypted ZIP archive
zip -e -r edulift-keystore-backup-$(date +%Y%m%d).zip ~/edulift-release.keystore

# Use a DIFFERENT password than the keystore password
```

Store this encrypted archive in a secure location on your local machine.

#### Tier 2: Cloud Backup (Encrypted)

Upload the encrypted archive to:
- Google Drive (encrypted)
- Dropbox (encrypted)
- OneDrive (encrypted)

**Never upload the unencrypted keystore to cloud storage!**

#### Tier 3: Team Password Manager

Store in a team password manager entry:
- Keystore file location
- Keystore password
- Key password
- Key alias
- Creation date
- Expiration date (27 years from creation)

Recommended tools:
- 1Password Teams
- Bitwarden Organizations
- LastPass Enterprise

#### Tier 4: Enterprise Vault (Production Teams)

For production applications, consider:
- **AWS Secrets Manager**
- **Azure Key Vault**
- **Google Cloud Secret Manager**
- **HashiCorp Vault**

### Backup Verification

Test your backups regularly:
```bash
# Restore from backup
unzip edulift-keystore-backup-20250127.zip

# Verify it works
keytool -list -keystore edulift-release.keystore
```

---

## Troubleshooting

### Error: "keytool: command not found"

**Cause**: Java JDK not installed or not in PATH

**Solution (macOS/Linux)**:
```bash
# Install Java JDK
brew install openjdk@17

# Or download from: https://www.oracle.com/java/technologies/downloads/
```

**Solution (Windows)**:
1. Download JDK from Oracle website
2. Install JDK
3. Add to PATH: `C:\Program Files\Java\jdk-17\bin`

### Error: "Password verification failed"

**Cause**: Mismatched passwords or typo during creation

**Solution**: Recreate the keystore with correct passwords:
```bash
# Delete old keystore
rm ~/edulift-release.keystore

# Create new one (be careful with passwords this time!)
keytool -genkey -v -keystore ~/edulift-release.keystore ...
```

### Error: "Keystore was tampered with, or password was incorrect"

**Cause**: Wrong password when trying to use keystore

**Solution**:
1. Verify password in password manager
2. Test password: `keytool -list -keystore ~/edulift-release.keystore`
3. If forgotten, you must recreate the keystore (and republish app)

### Build Error: "Keystore not found"

**Cause**: GitHub Secret `ANDROID_KEYSTORE` not configured or invalid

**Solution**:
1. Verify secret exists in GitHub repository settings
2. Re-encode keystore: `base64 -i ~/edulift-release.keystore`
3. Update GitHub Secret with new base64 content

### Build Error: "Failed to sign APK"

**Possible causes**:
1. `KEY_ALIAS` doesn't match keystore
2. Passwords are incorrect
3. Keystore file corrupted

**Solutions**:
```bash
# Verify alias exists
keytool -list -keystore ~/edulift-release.keystore

# Check if alias matches
# Should see: "Alias name: edulift-release"

# If different, update KEY_ALIAS secret in GitHub
```

---

## Keystore Lifecycle

### Creation → Production

1. ✅ Create keystore (4096-bit, 27-year validity)
2. ✅ Encode to base64
3. ✅ Add to GitHub Secrets
4. ✅ Backup securely (encrypted, multiple locations)
5. ✅ Test with CI/CD pipeline
6. ✅ Publish first release to Google Play Store
7. ✅ **NEVER change this keystore for this app!**

### Renewal (NOT Recommended)

⚠️ **DO NOT renew the keystore for a published app!**

With 27-year validity (`-validity 10000`), you'll never need to renew.

If you *must* change it (e.g., compromised):
1. Create new keystore
2. Publish as a **completely new app** (different package name)
3. Users must uninstall old app and install new one
4. Lose all existing installs and reviews

---

## Summary

### Checklist

Before moving to production:

- [ ] Keystore created with 4096-bit key
- [ ] Keystore validity: 10000 days (~27 years)
- [ ] Passwords are strong (12+ characters)
- [ ] Passwords stored in team password manager
- [ ] Keystore encoded to base64
- [ ] All 4 GitHub Secrets configured
- [ ] Keystore backed up (encrypted, multiple locations)
- [ ] Test build succeeded in CI/CD
- [ ] Team knows where backups are stored
- [ ] Keystore never committed to repository

### Required Information Summary

| Item | Value | Location |
|------|-------|----------|
| Keystore file | `edulift-release.keystore` | Backed up securely |
| Keystore password | `***************` | Team password manager |
| Key password | `***************` | Team password manager |
| Key alias | `edulift-release` | GitHub Secret + docs |
| Base64 encoding | `MIIKXAIBAz...` | GitHub Secret |
| Validity | 27 years | Created 2025, expires ~2052 |

---

## Additional Resources

- [Android App Signing Documentation](https://developer.android.com/studio/publish/app-signing)
- [Google Play App Signing](https://support.google.com/googleplay/android-developer/answer/9842756)
- [Keytool Documentation](https://docs.oracle.com/javase/8/docs/technotes/tools/unix/keytool.html)
- [CI/CD Secrets Configuration](SECRETS_CONFIGURATION.md)

---

**Last updated**: Configured for 4096-bit RSA keystore with 27-year validity for production use.
