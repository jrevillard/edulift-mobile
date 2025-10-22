# Suggested Commands for EduLift Mobile Development

## Development Commands
```bash
# Install dependencies
flutter pub get

# Generate code (freezed, injectable, etc.)
dart run build_runner build --delete-conflicting-outputs

# Generate localization files
flutter gen-l10n

# Watch mode for continuous generation
dart run build_runner watch --delete-conflicting-outputs

# Run the application
flutter run -d linux --hot       # Linux
flutter run -d android --hot     # Android
flutter run -d ios --hot         # iOS (macOS only)
flutter run -d chrome --hot      # Web browser
```

## Testing Commands
```bash
# Core infrastructure tests
flutter test test/core/ --no-pub

# Feature-specific tests
flutter test test/features/family/data/ --no-pub

# Full test suite with coverage
flutter test --coverage --no-pub

# Widget tests
flutter test test/widget/ --no-pub

# Integration tests  
flutter test test/integration/ --no-pub
```

## Quality Assurance
```bash
# Analyze code quality
flutter analyze

# Check formatting
dart format --set-exit-if-changed .

# Run all quality checks
flutter analyze && dart format --set-exit-if-changed . && flutter test
```

## Platform Specific
```bash
# Build optimized release
flutter build apk --release    # Android
flutter build ios --release    # iOS
flutter build linux --release  # Linux
```