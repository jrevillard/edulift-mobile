# Git History Analyzer Documentation

## Overview

The Git History Analyzer detects when previously internationalized strings were reverted to hardcoded strings.

## Purpose

- Identify reversion of internationalized strings to hardcoded
- Track localization regression patterns
- Monitor internationalization quality over time
- Prevent accidental removal of localization

## Detection Patterns

### Internationalization Reversions

Detects when this pattern occurs:
```diff
- Text(AppLocalizations.of(context).welcomeMessage)
+ Text('Welcome')
```

### Import Statement Removal

Identifies when localization imports are removed:
```diff
- import 'package:flutter_gen/gen_l10n/app_localizations.dart';
```

### Structural Changes

Detects modifications that bypass internationalization:
```diff
- onPressed: () => _handleAction(S.of(context).save)
+ onPressed: () => _handleAction('Save')
```

## Usage

```bash
dart bin/git_history_analyzer.dart [options]
```

### Options

- `-v, --verbose`: Enable verbose output
- `-d, --depth`: History depth to analyze (default: 100)
- `-f, --format`: Output format (console, json, csv)
- `-h, --help`: Show help

### Examples

```bash
# Analyze last 50 commits
dart bin/git_history_analyzer.dart --depth 50

# Verbose analysis with JSON output
dart bin/git_history_analyzer.dart --verbose --format json
```

## Analysis Scope

### Commit Range
- Default: Last 100 commits
- Configurable: Any number of commits

### File Types
- Focuses on `.dart` files
- Ignores generated files and test files

### Change Types
- Line additions/removals
- File modifications
- Import statement changes

## Output Information

### Commit Details
- Commit hash
- Author information
- Commit message
- Timestamp

### Change Details
- Removed lines (internationalized strings)
- Added lines (hardcoded strings)
- File paths
- Line numbers

### Impact Assessment
- Severity level
- Reversion likelihood
- Affected components

## Output Formats

### Console (Default)
Human-readable format with clear commit and change information.

### JSON
Structured output for automated processing and integration.

### CSV
Spreadsheet-friendly format for reporting and analysis.

## Integration

### CI/CD Pipeline
```yaml
- name: Check for Localization Reversions
  run: |
    dart bin/git_history_analyzer.dart --format json --depth 25 > localization_reversions.json
    # Process results and alert on findings
```

### Scheduled Analysis
```bash
# Weekly analysis of localization quality
0 0 * * 1 dart bin/git_history_analyzer.dart --depth 500 --format json > weekly_analysis.json
```

## Best Practices

1. **Regular Analysis**: Run periodically to catch regressions
2. **Pre-Merge Checks**: Integrate into pull request validation
3. **Historical Monitoring**: Track trends over time
4. **Team Awareness**: Share findings to improve practices