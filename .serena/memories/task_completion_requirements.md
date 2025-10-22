# Task Completion Requirements

## When a task is completed, ALWAYS run these commands in sequence:

### 1. Code Generation
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 2. Code Analysis
```bash
flutter analyze --no-fatal-infos
```

### 3. Code Formatting
```bash
dart format --set-exit-if-changed .
```

### 4. Test Execution
```bash
# Run core tests first (fastest validation)
flutter test test/core/ --no-pub

# Run specific feature tests if applicable
flutter test test/features/ --no-pub

# Run full test suite for comprehensive validation
flutter test --coverage --no-pub
```

### 5. Build Verification (if needed)
```bash
flutter build apk --debug  # Quick build validation
```

## Quality Gates
- All analysis issues must be resolved (no errors, warnings NOT acceptable)
- All tests must pass (green status)
- Code coverage should remain above 90%
- Build must complete successfully