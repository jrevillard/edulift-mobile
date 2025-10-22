# ARB File Validator Documentation

## Overview

The ARB File Validator ensures ARB (Application Resource Bundle) files maintain proper structure and syntax for internationalization.

## Purpose

- Validate ARB file structure and required metadata
- Check key consistency between language files
- Verify ICU pluralization syntax
- Ensure translation file integrity

## ARB File Structure

ARB files follow this structure:

```json
{
  "@@locale": "en",
  "@@last_modified": "2023-01-01T00:00:00.000Z",
  "welcomeMessage": "Welcome to our app!",
  "@welcomeMessage": {
    "description": "Welcome message displayed on home screen"
  },
  "itemCount": "{count, plural, =0{No items} =1{1 item} other{# items}}",
  "@itemCount": {
    "description": "Pluralized item count message"
  }
}
```

## Validation Checks

### Structure Validation

1. **Required Fields**
   - `@@locale`: Language identifier
   - `@@last_modified`: Timestamp of last modification

2. **Key-Metadata Consistency**
   - Every translatable key should have corresponding metadata
   - Metadata keys should have corresponding translatable keys

### Key Validation

1. **Missing Metadata**
   - Detection of translatable keys without metadata

2. **Orphaned Metadata**
   - Detection of metadata without corresponding keys

### ICU Pluralization Validation

1. **Syntax Validation**
   - Proper ICU pluralization syntax
   - Valid plural categories (=0, =1, zero, one, two, few, many, other)

2. **Placeholder Consistency**
   - Consistent placeholder usage across translations

## Usage

```bash
dart bin/arb_validator.dart [options] [files]
```

### Options

- `-v, --verbose`: Enable verbose output
- `-f, --format`: Output format (console, json, csv)
- `-h, --help`: Show help

### Examples

```bash
# Validate English and French ARB files
dart bin/arb_validator.dart lib/l10n/app_en.arb lib/l10n/app_fr.arb

# Validate with verbose output and JSON format
dart bin/arb_validator.dart --verbose --format json lib/l10n/*.arb
```

## Error Types

### Critical Errors

1. **Invalid JSON**: Malformed JSON syntax
2. **Missing @@locale**: Required locale field missing

### Warnings

1. **Missing metadata**: Translatable key without metadata
2. **Orphaned metadata**: Metadata without corresponding key
3. **Invalid pluralization**: Incorrect ICU pluralization syntax

## Output Formats

### Console (Default)
Human-readable format with clear error descriptions.

### JSON
Structured output for automated processing.

### CSV
Spreadsheet-friendly format for reporting.

## Integration

### CI/CD Pipeline
```yaml
- name: Validate ARB Files
  run: |
    dart bin/arb_validator.dart --format json lib/l10n/*.arb > arb_validation.json
    # Process results and fail build if needed
```

### Pre-commit Hook
```bash
#!/bin/bash
# Pre-commit hook to validate ARB files
dart bin/arb_validator.dart lib/l10n/*.arb
```