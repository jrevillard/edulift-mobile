# Hardcoded String Detector Documentation

## Overview

The Hardcoded String Detector identifies hardcoded strings in UI widgets that should be internationalized using the application's localization system.

## Purpose

- Detect UI strings that bypass the internationalization system
- Identify potential accessibility and localization issues
- Ensure consistent use of localization patterns
- Prevent strings from being missed during translation efforts

## Detection Patterns

The tool identifies hardcoded strings in the following contexts:

### Text Widgets
```dart
// Detected
Text('Hello World')

// Properly internationalized
Text(AppLocalizations.of(context).helloWorld)
```

### Button Widgets
```dart
// Detected
ElevatedButton(
  child: Text('Click Me')
)

// Properly internationalized
ElevatedButton(
  child: Text(AppLocalizations.of(context).clickMe)
)
```

### Tooltip Properties
```dart
// Detected
IconButton(
  tooltip: 'Delete Item'
)

// Properly internationalized
IconButton(
  tooltip: AppLocalizations.of(context).deleteItem
)
```

## Exclusion Rules

The tool excludes strings that are legitimately not translatable:

1. **URLs** - Strings starting with "http" or containing "://"
2. **File paths** - Strings containing "/" or "\"
3. **Email addresses** - Strings containing "@" and "."
4. **Identifiers** - Strings matching patterns like "UPPER_CASE"
5. **Numbers** - Purely numeric strings
6. **Hex values** - Long hexadecimal strings
7. **Enum values** - CamelCase strings that look like enum values

## Usage

```bash
dart bin/hardcoded_string_detector.dart [options] [files]
```

### Options

- `-v, --verbose`: Enable verbose output
- `-e, --exclude`: Patterns to exclude (can be used multiple times)
- `-i, --include`: Patterns to include (can be used multiple times)
- `-f, --format`: Output format (console, json, csv)
- `-h, --help`: Show help

### Examples

```bash
# Analyze all Dart files with verbose output
dart bin/hardcoded_string_detector.dart --verbose

# Analyze specific files and output as JSON
dart bin/hardcoded_string_detector.dart --format json lib/main.dart lib/widgets/*.dart

# Exclude test files
dart bin/hardcoded_string_detector.dart --exclude test --exclude integration_test
```

## Output Formats

### Console (Default)
Human-readable format for local development and quick analysis.

### JSON
Structured output for automated processing and integration with other tools.

### CSV
Spreadsheet-friendly format for reporting and data analysis.

## Integration

Add to your development workflow:

1. **Pre-commit hooks** - Prevent commits with hardcoded strings
2. **CI/CD pipelines** - Fail builds when hardcoded strings are detected
3. **IDE integration** - Custom linter rules for real-time feedback