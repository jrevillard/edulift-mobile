# Cross-Language Consistency Checker Documentation

## Overview

The Cross-Language Consistency Checker ensures translation consistency across different language ARB files.

## Purpose

- Verify all keys exist in all language files
- Check placeholder consistency across translations
- Identify missing translations
- Ensure translation completeness

## Consistency Checks

### Key Completeness

Ensures every translatable key exists in all language files:

```
English:  "welcomeMessage": "Welcome!"
French:   "welcomeMessage": "Bienvenue!"
Spanish:  "welcomeMessage": "¡Bienvenido!"
```

### Placeholder Consistency

Verifies placeholders are consistent across translations:

```
English:  "itemCount": "{count} items found"
French:   "itemCount": "{count} éléments trouvés"
Spanish:  "itemCount": "{count} elementos encontrados"
```

### ICU Pluralization Consistency

Ensures pluralization patterns are consistent:

```
English:  "items": "{count, plural, =0{No items} =1{1 item} other{# items}}"
French:   "items": "{count, plural, =0{Aucun élément} =1{1 élément} other{# éléments}}"
```

## Usage

```bash
dart bin/cross_language_checker.dart [options] [files]
```

### Options

- `-v, --verbose`: Enable verbose output
- `-f, --format`: Output format (console, json, csv)
- `-h, --help`: Show help

### Examples

```bash
# Check consistency between English and French files
dart bin/cross_language_checker.dart lib/l10n/app_en.arb lib/l10n/app_fr.arb

# Check all language files with verbose output
dart bin/cross_language_checker.dart --verbose lib/l10n/*.arb
```

## Error Types

### Critical Errors

1. **Missing Keys**: Key exists in one language but not others
2. **Inconsistent Placeholders**: Different placeholders in translations

### Warnings

1. **Partial Translations**: Some languages have translations others don't

## Output Formats

### Console (Default)
Clear, human-readable format showing inconsistencies.

### JSON
Structured output for automated processing.

### CSV
Spreadsheet-friendly format for reporting and tracking.

## Integration

### CI/CD Pipeline
```yaml
- name: Check Translation Consistency
  run: |
    dart bin/cross_language_checker.dart --format json lib/l10n/*.arb > translation_consistency.json
    # Process results and fail build if critical issues found
```

### Pre-commit Hook
```bash
#!/bin/bash
# Pre-commit hook to check translation consistency
dart bin/cross_language_checker.dart lib/l10n/*.arb
```

## Best Practices

1. **Regular Validation**: Run consistency checks frequently
2. **Automated Testing**: Integrate with CI/CD pipelines
3. **Translation Workflows**: Use as part of translation review process
4. **Progress Tracking**: Monitor consistency improvements over time