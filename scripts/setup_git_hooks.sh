#!/bin/bash

# Setup Git Hooks for Production Validation Protocol
# Run this script once to install pre-commit validation

set -e

echo "🔧 Setting up Production Validation Git Hooks..."

# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

# Create pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

echo "🚨 Running Production Validation Pre-commit Checks..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Check if flutter is installed
if ! command -v flutter &> /dev/null; then
    print_status $RED "❌ Flutter is not installed or not in PATH"
    exit 1
fi

# Get list of staged Dart files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.dart$' || true)

if [ -z "$STAGED_FILES" ]; then
    print_status $GREEN "✅ No Dart files to check"
    exit 0
fi

print_status $YELLOW "📝 Checking staged Dart files..."

# 1. Format check
print_status $YELLOW "🔍 Checking code formatting..."
if ! flutter format --set-exit-if-changed $STAGED_FILES; then
    print_status $RED "❌ Code formatting failed"
    print_status $YELLOW "Run 'flutter format .' to fix formatting issues"
    exit 1
fi
print_status $GREEN "✅ Code formatting passed"

# 2. Analysis
print_status $YELLOW "🔍 Running static analysis..."
if ! flutter analyze --fatal-infos; then
    print_status $RED "❌ Static analysis failed"
    print_status $YELLOW "Fix the analysis issues above before committing"
    exit 1
fi
print_status $GREEN "✅ Static analysis passed"

# 3. Check for forbidden patterns in production code
print_status $YELLOW "🔍 Checking for forbidden patterns in production code..."

# Check for debug prints in lib/ directory
DEBUG_PRINTS=$(git diff --cached --name-only | grep '^lib/' | xargs grep -l 'print\|debugPrint' 2>/dev/null || true)
if [ ! -z "$DEBUG_PRINTS" ]; then
    print_status $RED "❌ Found debug print statements in production code:"
    echo "$DEBUG_PRINTS"
    exit 1
fi

# Check for TODO/FIXME in critical production code
CRITICAL_TODOS=$(git diff --cached --name-only | grep -E '^lib/(core|features)/' | xargs grep -l 'TODO\|FIXME' 2>/dev/null || true)
if [ ! -z "$CRITICAL_TODOS" ]; then
    print_status $YELLOW "⚠️  Found TODO/FIXME in critical production code:"
    echo "$CRITICAL_TODOS"
    print_status $YELLOW "Consider completing these before committing"
fi

# Check for hardcoded secrets/keys
SECRETS=$(git diff --cached --name-only | grep '^lib/' | xargs grep -l 'api[_-]key\|secret\|password.*=' 2>/dev/null || true)
if [ ! -z "$SECRETS" ]; then
    print_status $RED "❌ Found potential hardcoded secrets in production code:"
    echo "$SECRETS"
    exit 1
fi

print_status $GREEN "✅ No forbidden patterns found in production code"

# 4. Check for test anti-patterns (if test files are staged)
STAGED_TEST_FILES=$(echo "$STAGED_FILES" | grep 'test/' || true)
if [ ! -z "$STAGED_TEST_FILES" ]; then
    print_status $YELLOW "🔍 Checking for test anti-patterns..."
    
    # Check for commented assertions
    COMMENTED_ASSERTIONS=$(echo "$STAGED_TEST_FILES" | xargs grep -l '^\s*//.*expect\|^\s*//.*verify' 2>/dev/null || true)
    if [ ! -z "$COMMENTED_ASSERTIONS" ]; then
        print_status $RED "❌ Found commented assertions (potential workarounds):"
        echo "$COMMENTED_ASSERTIONS"
        exit 1
    fi
    
    # Check for overly permissive mocks
    PERMISSIVE_MOCKS=$(echo "$STAGED_TEST_FILES" | xargs grep -l '\.thenReturn(any())' 2>/dev/null || true)
    if [ ! -z "$PERMISSIVE_MOCKS" ]; then
        print_status $RED "❌ Found overly permissive mocks:"
        echo "$PERMISSIVE_MOCKS"
        print_status $YELLOW "Use specific return values instead of any()"
        exit 1
    fi
    
    print_status $GREEN "✅ No test anti-patterns found"
fi

# 5. Quick smoke test (if test directory exists)
if [ -d "test" ]; then
    print_status $YELLOW "🧪 Running quick smoke test..."
    if ! flutter test --reporter=compact --timeout=30s test/ 2>/dev/null; then
        print_status $RED "❌ Smoke test failed"
        print_status $YELLOW "Run 'flutter test' to see detailed results"
        exit 1
    fi
    print_status $GREEN "✅ Smoke test passed"
fi

print_status $GREEN "🎉 All pre-commit checks passed!"
print_status $YELLOW "💡 Remember: Tests must verify REAL FUNCTIONAL BEHAVIOR with ROOT CAUSE FIXES"

EOF

# Make the hook executable
chmod +x .git/hooks/pre-commit

# Create pre-push hook
cat > .git/hooks/pre-push << 'EOF'
#!/bin/bash

echo "🚀 Running Production Validation Pre-push Checks..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Run full test suite
print_status $YELLOW "🧪 Running full test suite..."
if ! flutter test --coverage; then
    print_status $RED "❌ Test suite failed"
    print_status $YELLOW "Fix failing tests before pushing"
    exit 1
fi

# Check coverage if lcov is available
if command -v lcov &> /dev/null; then
    print_status $YELLOW "📊 Checking test coverage..."
    
    # Extract coverage percentage
    COVERAGE=$(lcov --summary coverage/lcov.info 2>/dev/null | grep "lines......" | awk '{print $2}' | sed 's/%//' || echo "0")
    
    if [ ! -z "$COVERAGE" ] && [ "$COVERAGE" -lt 80 ]; then
        print_status $RED "❌ Coverage $COVERAGE% is below minimum threshold of 80%"
        exit 1
    fi
    
    print_status $GREEN "✅ Coverage: $COVERAGE%"
fi

# Build verification
print_status $YELLOW "🏗️  Verifying build..."
if ! flutter build apk --debug; then
    print_status $RED "❌ Build verification failed"
    exit 1
fi

print_status $GREEN "✅ All pre-push checks passed!"

EOF

# Make the pre-push hook executable
chmod +x .git/hooks/pre-push

# Create commit-msg hook for commit message validation
cat > .git/hooks/commit-msg << 'EOF'
#!/bin/bash

# Read the commit message
commit_regex='^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .{1,50}'

commit_message=$(cat "$1")

if ! echo "$commit_message" | grep -qE "$commit_regex"; then
    echo "❌ Invalid commit message format!"
    echo ""
    echo "Format: <type>[optional scope]: <description>"
    echo ""
    echo "Types:"
    echo "  feat:     New feature"
    echo "  fix:      Bug fix"
    echo "  docs:     Documentation changes"
    echo "  style:    Code style changes (formatting, etc.)"
    echo "  refactor: Code refactoring"
    echo "  test:     Adding or updating tests"
    echo "  chore:    Build process or auxiliary tool changes"
    echo ""
    echo "Examples:"
    echo "  feat(vehicles): add vehicle form validation"
    echo "  fix: resolve state update issue in vehicle provider"
    echo "  test: add integration tests for vehicle management"
    echo ""
    exit 1
fi

EOF

# Make the commit-msg hook executable
chmod +x .git/hooks/commit-msg

print_status $GREEN "✅ Git hooks installed successfully!"
echo ""
print_status $YELLOW "📋 Installed hooks:"
echo "  • pre-commit: Format, analysis, and anti-pattern checks"
echo "  • pre-push: Full test suite and build verification"
echo "  • commit-msg: Conventional commit format validation"
echo ""
print_status $YELLOW "💡 To test the hooks:"
echo "  git add . && git commit -m 'test: verify git hooks'"
echo ""
print_status $GREEN "🎉 Production Validation Protocol is now active!"