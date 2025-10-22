# Integration Guide

## Project Integration

To integrate the Internationalization Audit Toolchain into your Flutter project:

### 1. Directory Structure

```
your_flutter_project/
├── lib/
│   ├── l10n/
│   │   ├── app_en.arb
│   │   └── app_fr.arb
│   └── ...
├── tool/
│   └── i18n_audit/
│       ├── bin/
│       ├── docs/
│       ├── templates/
│       ├── pubspec.yaml
│       └── README.md
└── reports/
```

### 2. Setup Steps

1. **Copy Toolchain**: Place the `i18n_audit` directory in your project's `tool` folder
2. **Install Dependencies**: Run `dart pub get` in the `tool/i18n_audit` directory
3. **Verify Installation**: Run `dart bin/hardcoded_string_detector.dart --help`

### 3. Running the Tools

#### Individual Tool Execution
```bash
# Hardcoded String Detection
dart bin/hardcoded_string_detector.dart --format json > ../../reports/hardcoded_strings.json

# ARB Validation
dart bin/arb_validator.dart --format json ../../lib/l10n/*.arb > ../../reports/arb_validation.json

# Cross-Language Consistency
dart bin/cross_language_checker.dart --format json ../../lib/l10n/*.arb > ../../reports/translation_consistency.json

# Git History Analysis
dart bin/git_history_analyzer.dart --format json > ../../reports/git_history_analysis.json
```

#### Batch Execution
```bash
# Run all tools
./bin/run_audit.sh
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Internationalization Audit

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  i18n-audit:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
      with:
        fetch-depth: 0 # Fetch all history for git analysis
    
    - name: Setup Dart
      uses: dart-lang/setup-dart@v1
      
    - name: Install dependencies
      run: |
        cd tool/i18n_audit
        dart pub get
    
    - name: Run Internationalization Audit
      run: |
        cd tool/i18n_audit
        ./bin/run_audit.sh
    
    - name: Upload Reports
      uses: actions/upload-artifact@v3
      with:
        name: i18n-audit-reports
        path: reports/
```

### GitLab CI Example

```yaml
i18n_audit:
  stage: test
  script:
    - cd tool/i18n_audit
    - dart pub get
    - ./bin/run_audit.sh
  artifacts:
    reports:
      - reports/*.json
  only:
    - merge_requests
    - main
```

## Pre-commit Hook Integration

### Installation

1. Create a pre-commit hook in `.git/hooks/pre-commit`:

```bash
#!/bin/bash
# Pre-commit hook for internationalization audit

echo "Running Internationalization Audit..."

# Run hardcoded string detection
cd tool/i18n_audit
dart bin/hardcoded_string_detector.dart --format json > ../../reports/pre_commit_hardcoded.json

# Check if any hardcoded strings were found
if [ -s ../../reports/pre_commit_hardcoded.json ]; then
  echo "❌ Hardcoded strings detected. Please internationalize them before committing."
  echo "See reports/pre_commit_hardcoded.json for details."
  exit 1
fi

echo "✅ No hardcoded strings found."
exit 0
```

2. Make it executable:
```bash
chmod +x .git/hooks/pre-commit
```

## IDE Integration

### VS Code Tasks

Add to `.vscode/tasks.json`:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "i18n-audit",
      "type": "shell",
      "command": "./tool/i18n_audit/bin/run_audit.sh",
      "group": "test",
      "presentation": {
        "echo": true,
        "reveal": "always"
      },
      "options": {
        "cwd": "${workspaceFolder}"
      }
    }
  ]
}
```

### Custom Lint Rules

Add to your `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - custom_lint

custom_lint:
  rules:
    - hardcoded_string_in_text_widget:
        severity: warning
    - hardcoded_string_in_button:
        severity: warning
```

## Monitoring and Reporting

### Dashboard Integration

Create a simple dashboard to track i18n quality metrics:

```dart
// dashboard/i18n_metrics.dart
class I18nMetricsDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('I18n Audit Dashboard')),
      body: FutureBuilder<List<I18nReport>>(
        future: _loadAuditReports(),
        builder: (context, snapshot) {
          // Display metrics and trends
        },
      ),
    );
  }
}
```

### Scheduled Reporting

Set up automated reporting:

```bash
# Weekly audit report
0 9 * * 1 cd /path/to/project && tool/i18n_audit/bin/run_audit.sh && mail -s "Weekly I18n Audit Report" team@example.com < reports/latest_summary.txt
```

## Best Practices

### Development Workflow

1. **Pre-Commit Checks**: Run string detection before every commit
2. **Pull Request Validation**: Validate ARB files and consistency in PRs
3. **Weekly Audits**: Run full audit weekly to track trends
4. **Release Checks**: Comprehensive audit before major releases

### Team Practices

1. **Training**: Educate team on internationalization importance
2. **Code Reviews**: Include i18n checks in code review process
3. **Documentation**: Maintain clear i18n guidelines
4. **Monitoring**: Track metrics and improvements over time

### Continuous Improvement

1. **Tool Updates**: Regularly update audit tools
2. **Rule Refinement**: Improve detection patterns based on findings
3. **Feedback Loop**: Incorporate team feedback into tooling
4. **Performance**: Optimize tools for faster execution