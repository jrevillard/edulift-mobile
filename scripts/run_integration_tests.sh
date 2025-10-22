#!/bin/bash

# Integration Test Runner Script
# Executes all integration tests with proper setup and reporting

set -e

echo "🚀 Starting Integration Test Suite"
echo "=================================="

# Set environment variable to prevent binding conflicts
export FLUTTER_TEST_MODE=integration

# Ensure we're in the right directory
cd "$(dirname "$0")/.."

# Clean and get dependencies
echo "📦 Setting up dependencies..."
flutter clean
flutter pub get

# Run static analysis first
echo "🔍 Running static analysis..."
flutter analyze integration_test/ || {
    echo "❌ Static analysis failed. Fix issues before running tests."
    exit 1
}

# Create reports directory
mkdir -p reports/integration

# Test suite configuration
INTEGRATION_TESTS=(
    "integration_test/authentication_flow_integration_test.dart"
    "integration_test/family_workflow_integration_test.dart" 
    "integration_test/vehicle_management_integration_test.dart"
    "integration_test/cross_feature_integration_test.dart"
    "integration_test/tab_navigation_integration_test.dart"
)

# Function to run a single integration test
run_test() {
    local test_file=$1
    local test_name=$(basename "$test_file" .dart)
    
    echo "🧪 Running: $test_name"
    echo "----------------------------------------"
    
    # Run the integration test
    if flutter test "$test_file" \
        --reporter=expanded \
        --coverage \
        --coverage-path=reports/integration/${test_name}_coverage.lcov; then
        echo "✅ $test_name PASSED"
        return 0
    else
        echo "❌ $test_name FAILED"
        return 1
    fi
}

# Run all integration tests
failed_tests=()
passed_tests=()

for test in "${INTEGRATION_TESTS[@]}"; do
    if [ -f "$test" ]; then
        if run_test "$test"; then
            passed_tests+=("$test")
        else
            failed_tests+=("$test")
        fi
    else
        echo "⚠️  Test file not found: $test"
        failed_tests+=("$test")
    fi
    echo
done

# Generate summary report
echo "📊 Integration Test Results"
echo "==========================="
echo "✅ Passed: ${#passed_tests[@]}"
echo "❌ Failed: ${#failed_tests[@]}"
echo "📈 Total:  ${#INTEGRATION_TESTS[@]}"

if [ ${#passed_tests[@]} -gt 0 ]; then
    echo
    echo "✅ Passed Tests:"
    for test in "${passed_tests[@]}"; do
        echo "   - $(basename "$test" .dart)"
    done
fi

if [ ${#failed_tests[@]} -gt 0 ]; then
    echo
    echo "❌ Failed Tests:"
    for test in "${failed_tests[@]}"; do
        echo "   - $(basename "$test" .dart)"
    done
    echo
    echo "💡 Tip: Run individual tests with:"
    echo "   flutter test <test_file>"
    exit 1
fi

# Merge coverage reports if all tests passed
if [ ${#failed_tests[@]} -eq 0 ] && [ -d "reports/integration" ]; then
    echo
    echo "📈 Generating coverage report..."
    
    # Combine all coverage files
    find reports/integration -name "*_coverage.lcov" -exec cat {} \; > reports/integration/combined_coverage.lcov
    
    # Generate HTML coverage report if genhtml is available
    if command -v genhtml &> /dev/null; then
        genhtml reports/integration/combined_coverage.lcov \
            --output-directory reports/integration/html \
            --title "Integration Test Coverage" \
            --show-details --legend
        echo "📄 Coverage report: reports/integration/html/index.html"
    fi
fi

echo
echo "🎉 Integration test suite completed successfully!"
echo "📁 Reports saved to: reports/integration/"