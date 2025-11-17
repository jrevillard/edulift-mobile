# Mocks Organization

This directory contains all generated mock files for the Flutter test suite.

## Organization

All `.mocks.dart` files are generated in this centralized location to follow Flutter testing standards:

- `/test/test_mocks/*.mocks.dart` - Generated mock files
- Mocks are excluded from version control via `.gitignore`
- Build runner is configured to generate all mocks here

## Import Patterns

When importing mocks in test files, use relative imports from the test file location:

```dart
// From test/unit/features/schedule/domain/usecases/
import '../../../../../test_mocks/your_test_file.mocks.dart';

// From test/integration/
import '../test_mocks/your_test_file.mocks.dart';

// From test/helpers/
import '../test_mocks/your_test_file.mocks.dart';
```

## Generation

To regenerate all mocks:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Configuration

The mock generation is configured in `build.yaml`:
- Includes all test files except those in `test/test_mocks/`
- Excludes the mock directory itself to prevent circular dependencies

## Standards Compliance

This organization follows Flutter testing best practices:
- ✅ Centralized mock location
- ✅ Proper separation from test logic
- ✅ Version control exclusion
- ✅ Consistent import patterns
- ✅ Build runner integration