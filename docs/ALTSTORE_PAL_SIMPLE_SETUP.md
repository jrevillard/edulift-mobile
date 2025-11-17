# AltStore PAL Simple Setup (Unsigned IPA)

## 🎯 Current Configuration

This configuration allows building unsigned IPAs for AltStore PAL, without Apple notarization.

## ✅ What Works

### **Build Process**
- Build IPA with `--no-codesign`
- Upload to Firebase App Distribution
- Automatic creation of AltStore PAL JSON sources
- Update GitHub Pages repository

### **Distribution**
- IPAs available on Firebase
- AltStore PAL sources created automatically
- Multilingual catalog functional
- Automatic updates

## ⚠️ Current Limitations

### **Without Apple Developer Program**
- **No Apple notarization**
- **IPAs non-functional** on iOS 17+
- **Distribution limited** to demo purposes
- **Manual installation** required

### **Simplified Workflow**
1. Build unsigned IPA
2. Upload to Firebase
3. Create JSON sources
4. No Apple validation

## 🔧 Required Variables in Codemagic

### **Firebase**
```yaml
FIREBASE_SERVICE_ACCOUNT_STAGING: "..."
```

### **GitHub**
```yaml
GITHUB_TOKEN: "..."
ALTSTORE_REPO: "jrevillard/my-altstore"
ALTSTORE_BRANCH: "main"
```

## 📱 To Use with a Developer Account

When you have an Apple Developer Program account:

1. **Add Apple variables**:
   ```yaml
   APPLE_ID: "your-apple-id@example.com"
   APPLE_TEAM_ID: "YOUR_TEAM_ID"
   APPLE_PASSWORD: "app-specific-password"
   ```

2. **Modify the build**:
   ```yaml
   flutter build ipa --release \
     --flavor staging \
     --dart-define-from-file=config/staging.json
   ```

3. **Add notarization** (see separate documentation)

## 🚀 Current Usage

- **Demo/Presentation**: Yes
- **Technical testing**: Yes (with manual sideloading)
- **Public distribution**: No
- **Non-technical users**: No

---

**This configuration is ready when you have an Apple Developer Program account.**