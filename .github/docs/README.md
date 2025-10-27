# EduLift CI/CD Documentation

Complete documentation for Android and iOS continuous integration and deployment pipelines.

## 📚 Documentation Index

### Getting Started

| Document | Description | Audience |
|----------|-------------|----------|
| [**Secrets Configuration**](SECRETS_CONFIGURATION.md) | Complete reference for all CI/CD secrets and variables | DevOps, Team Lead |
| [**Codemagic Setup**](CODEMAGIC_SETUP.md) | iOS build configuration with automatic code signing | iOS Developers, DevOps |
| [**Android Keystore Guide**](ANDROID_KEYSTORE_GUIDE.md) | Android keystore creation and management | Android Developers, DevOps |

---

## 🚀 Quick Start

### For New Team Members

1. **Understand the secrets**: Read [SECRETS_CONFIGURATION.md](SECRETS_CONFIGURATION.md)
2. **iOS builds**: Read [CODEMAGIC_SETUP.md](CODEMAGIC_SETUP.md)
3. **Android keystore**: Read [ANDROID_KEYSTORE_GUIDE.md](ANDROID_KEYSTORE_GUIDE.md) if you need to create/manage the keystore

### For DevOps/Release Managers

1. [SECRETS_CONFIGURATION.md](SECRETS_CONFIGURATION.md) - Configure all required secrets
2. [CODEMAGIC_SETUP.md](CODEMAGIC_SETUP.md) - Set up Codemagic for iOS
3. Test builds with staging tags

---

## 📋 CI/CD Overview

### Build Strategy

| Platform | Tool | Environments | Triggers |
|----------|------|--------------|----------|
| **Android** | GitHub Actions | Development, Staging, Production | Push to `main`, tags |
| **iOS** | Codemagic | Staging, Production | Tags only |

### Tag Conventions

| Tag Pattern | Environment | Builds |
|-------------|-------------|--------|
| `v*-rc.*`, `v*-beta.*`, `v*-alpha.*` | Staging | Android + iOS |
| `v*.*.*` (no suffix) | Production | Android + iOS |
| Push to `main` | Development | Android only |

---

## 🔐 Secrets Summary

### Required Secrets (8 total)

| Secret | Location | Format | Document |
|--------|----------|--------|----------|
| `ANDROID_KEYSTORE` | GitHub | Base64 | [Guide](ANDROID_KEYSTORE_GUIDE.md) |
| `KEYSTORE_PASSWORD` | GitHub | Plain text | [Guide](ANDROID_KEYSTORE_GUIDE.md) |
| `KEY_PASSWORD` | GitHub | Plain text | [Guide](ANDROID_KEYSTORE_GUIDE.md) |
| `KEY_ALIAS` | GitHub | Plain text | [Guide](ANDROID_KEYSTORE_GUIDE.md) |
| `FIREBASE_SERVICE_ACCOUNT_STAGING` | GitHub + Codemagic | Raw JSON | [Config](SECRETS_CONFIGURATION.md) |
| `FIREBASE_SERVICE_ACCOUNT_PROD` | GitHub + Codemagic | Raw JSON | [Config](SECRETS_CONFIGURATION.md) |
| `FIREBASE_GROUPS_STAGING` | GitHub (optional) | Plain text | [Config](SECRETS_CONFIGURATION.md) |
| `FIREBASE_GROUPS_PROD` | GitHub (optional) | Plain text | [Config](SECRETS_CONFIGURATION.md) |

---

## 🏗️ Architecture

### Android Pipeline (GitHub Actions)

```
Push/Tag → GitHub Actions
          ↓
     Build Android APK/AAB
          ↓
     Sign with keystore
          ↓
     Distribute to Firebase
```

**Configuration**: [`.github/workflows/cd.yml`](../workflows/cd.yml)

### iOS Pipeline (Codemagic)

```
Tag → Codemagic
      ↓
 Automatic Code Signing
      ↓
 Build iOS IPA
      ↓
 Distribute to Firebase
```

**Configuration**: [`codemagic.yaml`](../../codemagic.yaml)

---

## 🎯 Key Features

### Android (GitHub Actions)
- ✅ Automated builds for all environments
- ✅ Keystore-based code signing
- ✅ Firebase App Distribution
- ✅ GitHub Releases for tags
- ✅ Free (included in GitHub)

### iOS (Codemagic)
- ✨ **No Apple Developer account required**
- ✅ Automatic code signing
- ✅ Firebase App Distribution
- ✅ Free tier: 500 minutes/month
- ✅ Aligned with Android pipeline

---

## 📖 Detailed Documentation

### [Secrets Configuration](SECRETS_CONFIGURATION.md)

Complete reference for all secrets and environment variables.

**Contents:**
- Secret formats (Base64 vs JSON)
- GitHub Secrets setup
- Codemagic Environment Variables
- Configuration steps
- Secret rotation procedures
- Verification checklist
- Troubleshooting

**Read this first** if you're setting up CI/CD for the first time.

### [Codemagic Setup](CODEMAGIC_SETUP.md)

iOS build configuration with Codemagic.

**Contents:**
- Build strategy and triggers
- Prerequisites
- Step-by-step configuration
- Automatic code signing setup
- Firebase integration
- Cost considerations
- Troubleshooting

**Key benefit**: No $99/year Apple Developer Program needed!

### [Android Keystore Guide](ANDROID_KEYSTORE_GUIDE.md)

Android keystore creation and management.

**Contents:**
- What is a keystore?
- Creating the keystore (2048 vs 4096 bits)
- Encoding for GitHub
- Adding to GitHub Secrets
- Testing the keystore
- Security and backup strategies
- Troubleshooting

**Critical**: The keystore is irreplaceable - backup securely!

---

## 🔄 Common Workflows

### Triggering a Staging Build

```bash
# Create and push a pre-release tag
git tag v1.0.0-rc.1
git push origin v1.0.0-rc.1
```

**What happens:**
- ✅ Android build in GitHub Actions
- ✅ iOS build in Codemagic
- ✅ Both distributed to Firebase (`staging-team` group)

### Triggering a Production Build

```bash
# Create and push a production tag
git tag v1.0.0
git push origin v1.0.0
```

**What happens:**
- ✅ Android build in GitHub Actions
- ✅ iOS build in Codemagic
- ✅ Both distributed to Firebase (`production-team` group)
- ✅ GitHub Release created with artifacts

---

## 🆘 Getting Help

### Troubleshooting

Each document has a detailed troubleshooting section:

- **Build failures**: Check [CODEMAGIC_SETUP.md - Troubleshooting](CODEMAGIC_SETUP.md#troubleshooting)
- **Secret issues**: Check [SECRETS_CONFIGURATION.md - Troubleshooting](SECRETS_CONFIGURATION.md#troubleshooting)
- **Keystore issues**: Check [ANDROID_KEYSTORE_GUIDE.md - Troubleshooting](ANDROID_KEYSTORE_GUIDE.md#troubleshooting)

### Support Channels

1. **GitHub Actions**: Check workflow logs in Actions tab
2. **Codemagic**: Check build logs at https://codemagic.io/apps
3. **Team**: Contact DevOps team or release manager

---

## 🔄 Maintenance

### Regular Tasks

| Task | Frequency | Document |
|------|-----------|----------|
| Rotate Firebase service accounts | Every 90 days | [SECRETS_CONFIGURATION.md](SECRETS_CONFIGURATION.md#secret-rotation) |
| Verify keystore backups | Monthly | [ANDROID_KEYSTORE_GUIDE.md](ANDROID_KEYSTORE_GUIDE.md#security-and-backup) |
| Review Codemagic usage | Monthly | [CODEMAGIC_SETUP.md](CODEMAGIC_SETUP.md#cost-considerations) |
| Update documentation | As needed | All documents |

---

## 📊 Build Monitoring

### GitHub Actions
- View builds: Repository → Actions tab
- Download artifacts: Artifacts section in completed workflow
- Email notifications: Configured in workflow

### Codemagic
- View builds: https://codemagic.io/apps
- Download artifacts: Build details page
- Email notifications: Configured in `codemagic.yaml`

### Firebase App Distribution
- View distributions: Firebase Console → App Distribution
- Monitor downloads: Statistics section
- Manage testers: Groups section

---

## 🎓 Learning Resources

### External Documentation

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Codemagic Documentation](https://docs.codemagic.io/)
- [Firebase App Distribution](https://firebase.google.com/docs/app-distribution)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [Flutter CI/CD Best Practices](https://docs.flutter.dev/deployment/cd)

### Video Tutorials

- [GitHub Actions for Flutter](https://www.youtube.com/results?search_query=github+actions+flutter)
- [Codemagic Setup](https://www.youtube.com/results?search_query=codemagic+flutter)
- [Firebase App Distribution](https://www.youtube.com/results?search_query=firebase+app+distribution)

---

## 📝 Contributing

### Updating Documentation

When updating these docs:
1. Keep the table of contents up to date
2. Update the "Last updated" section at the bottom
3. Test all commands and procedures
4. Keep examples aligned with actual configuration

### Adding New Sections

Follow the existing structure:
- Clear headings with emoji icons
- Tables for comparisons
- Code blocks with syntax highlighting
- Cross-references to related documents
- Troubleshooting sections

---

**Last updated**: January 2025 - Documentation aligned for Android (GitHub Actions) and iOS (Codemagic) with automatic code signing.
