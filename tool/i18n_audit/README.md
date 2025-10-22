# Internationalization Audit Toolchain

This toolchain provides comprehensive analysis capabilities for detecting and managing internationalization issues in Flutter/Dart applications.

## Components

### 1. Hardcoded String Detector
Detects hardcoded strings in UI widgets that should be internationalized.

### 2. ARB File Validator
Validates ARB files for structural integrity and ICU pluralization syntax.

### 3. Cross-Language Consistency Checker
Ensures consistency between different language translation files.

### 4. Git History Analyzer
Identifies when previously internationalized strings were reverted to hardcoded.

## Installation

```bash
cd tool/i18n_audit
dart pub get
```

## Usage

### Hardcoded String Detection

```bash
dart bin/clean_detector.dart --verbose --format json
```

Options:
- `-v, --verbose`: Enable verbose output
- `-e, --exclude`: Patterns to exclude (can be used multiple times)
- `-i, --include`: Patterns to include (can be used multiple times)
- `-f, --format`: Output format (console, json, csv)
- `-h, --help`: Show help

### ARB File Validation

```bash
dart bin/arb_validator.dart --verbose lib/l10n/app_en.arb lib/l10n/app_fr.arb
```

Options:
- `-v, --verbose`: Enable verbose output
- `-f, --format`: Output format (console, json, csv)
- `-h, --help`: Show help

### Cross-Language Consistency Check

```bash
dart bin/cross_language_checker.dart --verbose lib/l10n/app_en.arb lib/l10n/app_fr.arb
```

Options:
- `-v, --verbose`: Enable verbose output
- `-f, --format`: Output format (console, json, csv)
- `-h, --help`: Show help

### Git History Analysis

```bash
dart bin/git_history_analyzer.dart --verbose --depth 50
```

Options:
- `-v, --verbose`: Enable verbose output
- `-d, --depth`: History depth to analyze (default: 100)
- `-f, --format`: Output format (console, json, csv)
- `-h, --help`: Show help

## Integration with Project

To integrate these tools with your Flutter project:

1. Add the tool directory to your project
2. Run the tools as part of your CI/CD pipeline
3. Configure custom analyzer rules in your `analysis_options.yaml`

## Output Formats

All tools support multiple output formats:
- **Console**: Human-readable output for local development
- **JSON**: Structured output for automated processing
- **CSV**: Spreadsheet-friendly format for reporting

## Example Usage in CI/CD

```yaml
# GitHub Actions example
- name: Internationalization Audit
  run: |
    cd tool/i18n_audit
    dart bin/clean_detector.dart --format json > ../../reports/hardcoded_strings.json
    dart bin/arb_validator.dart --format json ../../lib/l10n/*.arb > ../../reports/arb_validation.json
    dart bin/cross_language_checker.dart --format json ../../lib/l10n/*.arb > ../../reports/translation_consistency.json
```