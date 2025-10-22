# Flutter EduLift Mobile - Quick Start Guide 🚀

## 📱 Running the Flutter App

This guide will help you quickly run the EduLift Flutter mobile app in development mode.

---

## 🔧 Prerequisites

### Required Software
- **Flutter SDK**: 3.24+ 
- **Dart SDK**: 3.5+ (included with Flutter)
- **Platform Development Tools**:
  - **Linux**: GTK development libraries (usually pre-installed)
  - **macOS**: Xcode Command Line Tools
  - **Windows**: Visual Studio or Visual Studio Build Tools
  - **Android**: Android Studio (for mobile development)
  - **iOS**: Xcode (macOS only, for iOS development)

### Verify Your Setup
```bash
# Check Flutter installation
flutter --version
flutter doctor

# Should show Flutter 3.24+, Dart 3.5+
# Address any issues shown in flutter doctor
```

---

## 🚀 Quick Start (3 Steps)

### 1. Install Dependencies
```bash
cd mobile_app
flutter pub get
```

### 2. Generate Code
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Run the Application
```bash
# For Linux development
flutter run -d linux --hot

# For macOS
flutter run -d macos --hot

# For Windows  
flutter run -d windows --hot

# For Android (device/emulator)
flutter run -d android --hot

# For iOS (device/simulator, macOS only)
flutter run -d ios --hot
```

---

## 🖥️ Platform-Specific Setup

### **Linux Development**
```bash
# Install required dependencies (if needed)
sudo apt-get update
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev

# Run the app
flutter run -d linux --hot
```

### **macOS Development** 
```bash
# Install Xcode Command Line Tools (if needed)
xcode-select --install

# Run the app
flutter run -d macos --hot
```

### **Windows Development**
```bash
# Ensure Visual Studio or Build Tools are installed
# Run the app
flutter run -d windows --hot
```

### **Android Development**
```bash
# Start Android emulator or connect device
flutter emulators --launch <emulator_id>
# OR connect physical device with USB debugging

# Run the app
flutter run -d android --hot
```

### **iOS Development** (macOS only)
```bash
# Start iOS simulator
open -a Simulator

# Run the app  
flutter run -d ios --hot
```

---

## 🔥 Development Commands

### **Hot Reload & Restart**
While the app is running:
- **`r`**: Hot reload (apply code changes instantly)
- **`R`**: Hot restart (full app restart)
- **`q`**: Quit the app
- **`h`**: Show all available commands

### **Development Workflow**
```bash
# 1. Make code changes
# 2. Press 'r' for hot reload
# 3. Test changes instantly
# 4. Continue development
```

---

## 🧪 Testing

### **Run Tests**
```bash
# Run all tests
flutter test

# Run specific test files
flutter test test/unit/core/services/
flutter test test/widget/features/auth/

# Run with coverage
flutter test --coverage
```

### **Integration Tests**
```bash
# Run integration tests
flutter test integration_test/
```

---

## 🔧 Code Generation

### **When to Regenerate Code**
Run code generation when you:
- Add new `@provider` services
- Modify API client interfaces
- Add new data models with `@freezed`
- Change any annotated classes

### **Generate Code**
```bash
# Generate all code
dart run build_runner build --delete-conflicting-outputs

# Watch for changes (development mode)
dart run build_runner watch

# Clean generated files
dart run build_runner clean
```

---

## 🐛 Troubleshooting

### **Common Issues**

**Build Runner Errors**
```bash
# Solution: Clean and regenerate
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

**Dependency Conflicts** 
```bash
# Solution: Clean and reinstall
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

**Platform-Specific Issues**
```bash
# Check platform support
flutter doctor
flutter config --enable-linux-desktop  # For Linux
flutter config --enable-macos-desktop  # For macOS  
flutter config --enable-windows-desktop # For Windows
```

**Hive Storage Issues** (Development)
```bash
# The app automatically handles storage fallbacks
# Check console logs for Hive initialization messages
```

**Keyring Warnings** (Linux Development)
```bash
# These warnings are expected in development environments
# They don't affect app functionality
# ** (mobile_app:xxxx): WARNING **: libsecret_error: Failed to unlock the keyring
```

---

## 📊 Development Features

### **Available Features**
- ✅ **Hot Reload**: Instant code changes
- ✅ **DevTools**: Debugging and profiling
- ✅ **State Management**: Riverpod providers
- ✅ **Dependency Injection**: Riverpod providers
- ✅ **Code Generation**: Build runner automation
- ✅ **Testing**: Unit, widget, integration tests
- ✅ **Security**: Encrypted storage, biometric auth
- ✅ **Offline Support**: Hive local database
- ✅ **Material 3**: Modern UI design system

### **Development Tools**
```bash
# Flutter DevTools (while app is running)
# Open the URL shown in console output
# Example: http://127.0.0.1:9102?uri=http://127.0.0.1:45033

# Code analysis
flutter analyze lib

# Code formatting
dart format lib test
```

---

## 🎯 Development Workflow

### **Typical Development Session**
1. **Start Development**: `flutter run -d linux --hot`
2. **Make Changes**: Edit code in your IDE
3. **Hot Reload**: Press `r` to see changes instantly
4. **Run Tests**: `flutter test` to verify changes
5. **Code Generation**: `dart run build_runner build` if needed
6. **Commit Changes**: Use Git for version control

### **Best Practices**
- **Use Hot Reload**: Speeds up development significantly
- **Write Tests**: Follow TDD practices
- **Run Analysis**: Regular `flutter analyze lib` checks
- **Code Generation**: Regenerate after API/model changes
- **Platform Testing**: Test on multiple platforms

---

## 🚀 Ready to Develop!

The Flutter EduLift mobile app is now **ready for development** with:

- ✅ **Clean Architecture** implemented
- ✅ **Development Environment** configured  
- ✅ **Build System** working correctly
- ✅ **Hot Reload** enabled for fast development
- ✅ **Testing Framework** comprehensive
- ✅ **Code Generation** automated
- ✅ **Cross-Platform** support enabled

**Start building amazing features!** 🎉

---

## 📚 Additional Resources

- **Architecture Guide**: [ARCHITECTURE.md](ARCHITECTURE.md)
- **Testing Guide**: [TESTING_GUIDE.md](TESTING_GUIDE.md)
- **API Documentation**: [API_DOCUMENTATION.md](API_DOCUMENTATION.md)
- **Flutter Documentation**: [https://docs.flutter.dev](https://docs.flutter.dev)