# Internationalization Audit Report

## Executive Summary

**Audit Date:** {{date}}
**Total Findings:** {{total_findings}}
**Critical Issues:** {{critical_issues}}
**Files Analyzed:** {{files_analyzed}}

## Findings by Severity

| Severity | Count |
|----------|-------|
| Critical | {{critical_count}} |
| High     | {{high_count}} |
| Medium   | {{medium_count}} |
| Low      | {{low_count}} |

## Detailed Findings

{{#findings}}
### {{title}}

- **File:** {{file_path}}
- **Line:** {{line_number}}
- **Type:** {{finding_type}}
- **Severity:** {{severity}}
- **Description:** {{description}}

**Recommendation:**
{{recommendation}}

**Code Snippet:**
```dart
{{code_snippet}}
```

---
{{/findings}}

## Statistics

### Findings by Type
{{#type_statistics}}
- {{type}}: {{count}}
{{/type_statistics}}

### Progress Tracking
- **Resolved:** {{resolved_count}}
- **In Progress:** {{in_progress_count}}
- **Unresolved:** {{unresolved_count}}

## Next Steps

1. Prioritize critical issues for immediate resolution
2. Address high-priority findings in the next sprint
3. Plan medium-priority items for future releases
4. Review low-priority items during routine maintenance