#!/bin/bash

# Internationalization Audit Toolchain Runner
# Runs all i18n audit tools and generates consolidated reports

set -e

# Determine the script's directory (works from any location)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Change to script directory to ensure all relative paths work
cd "$SCRIPT_DIR"

echo "🌍 Starting Internationalization Audit..."
echo "📁 Script directory: $SCRIPT_DIR"

# Create reports directory if it doesn't exist
REPORTS_DIR="../reports"
mkdir -p "$REPORTS_DIR"

# Get current timestamp for report files
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Initialize counters
TOTAL_ISSUES=0
ERRORS=()

echo "🔍 Running Hardcoded String Detection..."
if dart run clean_detector.dart > "$REPORTS_DIR/hardcoded_strings_$TIMESTAMP.txt" 2>&1; then
  ISSUE_COUNT=$(grep -c "^  Line" "$REPORTS_DIR/hardcoded_strings_$TIMESTAMP.txt" || echo "0")
  echo "   Found $ISSUE_COUNT hardcoded strings"
  TOTAL_ISSUES=$((TOTAL_ISSUES + ISSUE_COUNT))
else
  echo "   ⚠️  Warning: Hardcoded string detection failed"
  ERRORS+=("Hardcoded string detection")
fi

echo "📋 Validating ARB Files..."
if dart run arb_validator.dart ../../../lib/l10n/*.arb > "$REPORTS_DIR/arb_validation_$TIMESTAMP.txt" 2>&1; then
  echo "   ARB files validated"
else
  echo "   ⚠️  Warning: ARB validation failed or not implemented"
  ERRORS+=("ARB validation")
fi

echo "🔄 Checking Cross-Language Consistency..."
if dart run cross_language_checker.dart ../../../lib/l10n/*.arb > "$REPORTS_DIR/translation_consistency_$TIMESTAMP.txt" 2>&1; then
  echo "   Cross-language consistency checked"
else
  echo "   ⚠️  Warning: Cross-language check failed or not implemented"
  ERRORS+=("Cross-language consistency")
fi

echo "🕒 Analyzing Git History for Reversions..."
if dart run git_history_analyzer.dart --depth 50 > "$REPORTS_DIR/git_history_analysis_$TIMESTAMP.txt" 2>&1; then
  echo "   Git history analyzed"
else
  echo "   ⚠️  Warning: Git history analysis failed or not implemented"
  ERRORS+=("Git history analysis")
fi

echo ""
echo "📊 Audit Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Total hardcoded strings found: $TOTAL_ISSUES"
echo "Reports saved to: $REPORTS_DIR/"
echo ""
echo "Generated reports:"
echo "  - hardcoded_strings_$TIMESTAMP.txt"
echo "  - arb_validation_$TIMESTAMP.txt"
echo "  - translation_consistency_$TIMESTAMP.txt"
echo "  - git_history_analysis_$TIMESTAMP.txt"

if [ ${#ERRORS[@]} -gt 0 ]; then
  echo ""
  echo "⚠️  Warnings:"
  for error in "${ERRORS[@]}"; do
    echo "  - $error"
  done
fi

echo ""
if [ $TOTAL_ISSUES -eq 0 ]; then
  echo "✅ Perfect! No hardcoded strings found!"
  exit 0
else
  echo "⚠️  Found $TOTAL_ISSUES strings that need internationalization"
  echo "   Review: $REPORTS_DIR/hardcoded_strings_$TIMESTAMP.txt"
  exit 1
fi