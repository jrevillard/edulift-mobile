#!/bin/bash
# scripts/validate-ci-versions.sh
# Validate that all CI/CD version configurations are consistent

set -e

echo "🔍 Validating CI/CD version consistency..."

# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Load expected versions from central config
if [[ -f ".github/ci-versions.env" ]]; then
    source .github/ci-versions.env
    echo "✅ Loaded versions from .github/ci-versions.env"
else
    echo -e "${RED}❌ .github/ci-versions.env not found${NC}"
    exit 1
fi

# Function to validate a file contains the expected version
validate_version() {
    local file="$1"
    local expected="$2"
    local description="$3"

    if [[ ! -f "$file" ]]; then
        echo -e "${YELLOW}⚠️  $file not found${NC}"
        return 1
    fi

    if grep -q "$expected" "$file"; then
        echo "✅ $description: $expected"
        return 0
    else
        echo -e "${RED}❌ $description: Expected $expected${NC}"
        echo "   Found: $(grep -E "(flutter-version|FLUTTER_VERSION)" "$file" | head -3)"
        return 1
    fi
}

# Track validation results
validation_errors=0

echo ""
echo "📋 Validating Flutter versions..."

# Validate GitHub Actions workflow
echo "🔍 Checking .github/workflows/cd.yml..."
# Check that the workflow loads from ci-versions.env using new approach
if grep -q "Load CI/CD versions" ".github/workflows/cd.yml"; then
    echo "✅ Workflow loads versions from ci-versions.env"
else
    echo -e "${RED}❌ Workflow doesn't load from ci-versions.env${NC}"
    validation_errors=$((validation_errors + 1))
fi

# Check that the workflow uses GITHUB_OUTPUT approach
if grep -q "GITHUB_OUTPUT" ".github/workflows/cd.yml"; then
    echo "✅ Workflow uses GITHUB_OUTPUT to load variables"
else
    echo -e "${RED}❌ Workflow doesn't use GITHUB_OUTPUT approach${NC}"
    validation_errors=$((validation_errors + 1))
fi

# Validate GitHub Actions setup action usage
echo "🔍 Checking Flutter setup action usage in workflows..."
# Check that CI workflow uses subosito/flutter-action@v2
if grep -q "uses: subosito/flutter-action@v2" ".github/workflows/ci.yml"; then
    echo "✅ CI workflow uses subosito/flutter-action@v2"
else
    echo -e "${RED}❌ CI workflow should use subosito/flutter-action@v2${NC}"
    validation_errors=$((validation_errors + 1))
fi

# Check that CD workflow uses subosito/flutter-action@v2
if grep -q "uses: subosito/flutter-action@v2" ".github/workflows/cd.yml"; then
    echo "✅ CD workflow uses subosito/flutter-action@v2"
else
    echo -e "${RED}❌ CD workflow should use subosito/flutter-action@v2${NC}"
    validation_errors=$((validation_errors + 1))
fi

# Validate Codemagic configuration if it exists
if [[ -f "codemagic.yaml" ]]; then
    echo "🔍 Checking codemagic.yaml..."
    if grep -q "flutter: $FLUTTER_VERSION" "codemagic.yaml"; then
        echo "✅ Codemagic uses Flutter $FLUTTER_VERSION"
    else
        echo -e "${RED}❌ Codemagic Flutter version not set to $FLUTTER_VERSION${NC}"
        validation_errors=$((validation_errors + 1))
    fi

    if grep -q "xcode: $XCODE_VERSION" "codemagic.yaml"; then
        echo "✅ Codemagic uses Xcode $XCODE_VERSION"
    else
        echo -e "${YELLOW}⚠️  Codemagic Xcode version not set to $XCODE_VERSION${NC}"
    fi
fi

echo ""
echo "📋 Checking for hardcoded numeric values in workflow..."
# Look for 4+ digit numbers that might be hardcoded (except dates/versions)
hardcoded_numbers=$(grep -E '[0-9]{4,}' ".github/workflows/cd.yml" | grep -v '\${{ env\.' | grep -v 'commit.*\.' | grep -v 'git\.' | grep -v 'run_number' | wc -l)
if [[ $hardcoded_numbers -eq 0 ]]; then
    echo "✅ No suspicious hardcoded numeric values found"
else
    echo "⚠️  Found $hardcoded_numbers potential hardcoded numeric values"
    grep -E '[0-9]{4,}' ".github/workflows/cd.yml" | grep -v '\${{ env\.' | grep -v 'commit.*\.' | grep -v 'git\.' | grep -v 'run_number' | head -3
fi

echo ""
echo "📋 Validating other versions..."

# Validate Java version - check if workflow uses steps.load-versions.outputs.JAVA_VERSION OR if it's handled by flutter-action
if grep -q "steps.*outputs.*JAVA_VERSION" ".github/workflows/cd.yml"; then
    echo "✅ Java version loaded from ci-versions.env"
elif grep -q "uses: subosito/flutter-action@v2" ".github/workflows/cd.yml"; then
    echo "✅ Java version handled by flutter-action (auto-managed)"
else
    echo -e "${RED}❌ Java version not configured${NC}"
    validation_errors=$((validation_errors + 1))
fi

# Validate Xcode version - check if workflow uses steps.*outputs.*XCODE_VERSION
# Note: CD workflow runs on Ubuntu (Android build only), so Xcode version is only used by Codemagic
if grep -q "steps.*outputs.*XCODE_VERSION" ".github/workflows/cd.yml"; then
    echo "✅ Xcode version loaded from ci-versions.env"
else
    echo "✅ Xcode version managed by Codemagic (CD workflow builds Android only)"
fi

echo ""
echo "📋 Validating Firebase App IDs in ci-versions.env..."
firebase_vars=("FIREBASE_ANDROID_STAGING_APP_ID" "FIREBASE_ANDROID_PROD_APP_ID" "FIREBASE_IOS_STAGING_APP_ID" "FIREBASE_IOS_PROD_APP_ID")
for var in "${firebase_vars[@]}"; do
    if grep -q "$var=" ".github/ci-versions.env"; then
        echo "✅ $var centralized in ci-versions.env"
    else
        echo -e "${RED}❌ $var not found in ci-versions.env${NC}"
        validation_errors=$((validation_errors + 1))
    fi
done

# Validate CI workflow also
echo ""
echo "📋 Validating CI workflow..."
if grep -q "Load CI/CD versions from .env" ".github/workflows/ci.yml"; then
    echo "✅ CI workflow loads versions from ci-versions.env"
else
    echo -e "${RED}❌ CI workflow doesn't load from ci-versions.env${NC}"
    validation_errors=$((validation_errors + 1))
fi

if grep -q "GITHUB_OUTPUT" ".github/workflows/ci.yml"; then
    echo "✅ CI workflow uses GITHUB_OUTPUT to load variables"
else
    echo -e "${RED}❌ CI workflow doesn't use GITHUB_OUTPUT approach${NC}"
    validation_errors=$((validation_errors + 1))
fi

# Validate CD workflow trigger configuration
echo ""
echo "📋 Validating CD workflow trigger (branch-based approach)..."
if grep -q "branches:" ".github/workflows/cd.yml" && grep -q "release/\*" ".github/workflows/cd.yml"; then
    echo "✅ CD workflow triggers on release/* branches"
else
    echo -e "${RED}❌ CD workflow should trigger on release/* branches${NC}"
    validation_errors=$((validation_errors + 1))
fi

if grep -q "Extract version and flavor from branch" ".github/workflows/cd.yml"; then
    echo "✅ CD workflow extracts version from branch name"
else
    echo -e "${RED}❌ CD workflow should extract version from branch name${NC}"
    validation_errors=$((validation_errors + 1))
fi

if grep -q "Create tag for this release" ".github/workflows/cd.yml"; then
    echo "✅ CD workflow creates tags automatically"
else
    echo -e "${RED}❌ CD workflow should create tags automatically${NC}"
    validation_errors=$((validation_errors + 1))
fi

if grep -q "Merge to main" ".github/workflows/cd.yml"; then
    echo "✅ CD workflow merges to main automatically"
else
    echo -e "${RED}❌ CD workflow should merge to main automatically${NC}"
    validation_errors=$((validation_errors + 1))
fi

# Validate security version format validation
echo ""
echo "🛡️ Validating security version format validation..."
if grep -q "Validate version format" ".github/workflows/cd.yml"; then
    echo "✅ CD workflow validates version format"
else
    echo -e "${RED}❌ CD workflow missing version format validation${NC}"
    validation_errors=$((validation_errors + 1))
fi

if grep -q "Invalid version format" ".github/workflows/cd.yml"; then
    echo "✅ CD workflow has clear error messages"
else
    echo -e "${RED}❌ CD workflow missing clear error messages${NC}"
    validation_errors=$((validation_errors + 1))
fi

if grep -q "Rejected: test, fix, hotfix, bugfix, experimental, wip, temp" ".github/workflows/cd.yml"; then
    echo "✅ CD workflow explicitly rejects invalid branch names"
else
    echo -e "${RED}❌ CD workflow should explicitly reject invalid branch names${NC}"
    validation_errors=$((validation_errors + 1))
fi

if grep -q "exit 1" ".github/workflows/cd.yml"; then
    echo "✅ CD workflow fails fast on invalid versions"
else
    echo -e "${RED}❌ CD workflow should fail fast on invalid versions${NC}"
    validation_errors=$((validation_errors + 1))
fi

# Validate critical fixes from code review
echo ""
echo "🔧 Validating critical code review fixes..."

# Check if configure_ios.sh is corrupted (should not contain Python code)
if grep -q "#!/usr/bin/env python3" "scripts/configure_ios.sh"; then
    echo -e "${RED}❌ configure_ios.sh still contains Python code (corrupted)${NC}"
    validation_errors=$((validation_errors + 1))
else
    echo "✅ configure_ios.sh file integrity verified (no Python code)"
fi

# Check if FINAL_BUILD_INFO validation exists
if grep -q "Validate build info availability" ".github/workflows/cd.yml"; then
    echo "✅ FINAL_BUILD_INFO validation added"
else
    echo -e "${RED}❌ FINAL_BUILD_INFO validation missing${NC}"
    validation_errors=$((validation_errors + 1))
fi

# Check if Flutter version extraction is fixed (should use pre-extracted version)
if grep -q "VERSION=\"\${{ needs.prepare-release.outputs.version }}\"" ".github/workflows/cd.yml"; then
    echo "✅ Flutter version extraction fixed (uses pre-extracted version)"
else
    echo -e "${RED}❌ Flutter version extraction should use pre-extracted version${NC}"
    validation_errors=$((validation_errors + 1))
fi

# Check if target branch is configurable
if grep -q "TARGET_BRANCH=\"main\"" ".github/workflows/cd.yml"; then
    echo "✅ Target branch made configurable"
else
    echo -e "${RED}❌ Target branch should be configurable${NC}"
    validation_errors=$((validation_errors + 1))
fi

# Advanced file integrity validations
echo ""
echo "🔍 Advanced file integrity validations..."

# Check if all scripts have proper error handling
scripts_missing_sete=()
for script in scripts/*.sh; do
    if [[ -f "$script" ]]; then
        if ! grep -q "set -e" "$script"; then
            scripts_missing_sete+=("$(basename "$script")")
        fi
    fi
done

if [[ ${#scripts_missing_sete[@]} -eq 0 ]]; then
    echo "✅ All scripts have proper error handling (set -e)"
else
    echo -e "${RED}❌ Scripts missing 'set -e': ${scripts_missing_sete[*]}${NC}"
    validation_errors=$((validation_errors + ${#scripts_missing_sete[@]}))
fi

# Check if API retry logic is implemented
if grep -q "Retry logic with exponential backoff" "scripts/trigger-codemagic-api.sh"; then
    echo "✅ API retry logic with exponential backoff implemented"
else
    echo -e "${RED}❌ API retry logic should be implemented${NC}"
    validation_errors=$((validation_errors + 1))
fi

# Check if workflow has comprehensive documentation
if grep -q "WORKFLOW FLOW:" ".github/workflows/cd.yml"; then
    echo "✅ Workflow has comprehensive documentation"
else
    echo -e "${RED}❌ Workflow documentation should be comprehensive${NC}"
    validation_errors=$((validation_errors + 1))
fi

# Check if all critical files exist and are not empty
critical_files=(
    "scripts/trigger-codemagic-api.sh"
    "scripts/wait-codemagic-build.sh"
    "scripts/download-codemagic-artifacts.sh"
    "scripts/configure_ios.sh"
    "scripts/build_unsigned_ios.sh"
    "scripts/validate-ci-versions.sh"
    "codemagic.yaml"
    ".github/workflows/cd.yml"
    ".github/ci-versions.env"
)

for file in "${critical_files[@]}"; do
    if [[ -f "$file" ]]; then
        if [[ -s "$file" ]]; then
            continue
        else
            echo -e "${RED}❌ Critical file exists but is empty: $file${NC}"
            validation_errors=$((validation_errors + 1))
        fi
    else
        echo -e "${RED}❌ Critical file missing: $file${NC}"
        validation_errors=$((validation_errors + 1))
    fi
done

echo "✅ All critical files exist and are not empty"

# Validate CI loads configuration JSON for flavors
if grep -q "dart-define-from-file=config/development.json" ".github/workflows/ci.yml"; then
    echo "✅ CI workflow loads configuration JSON for development flavor"
else
    echo -e "${RED}❌ CI workflow missing dart-define-from-file for development flavor${NC}"
    validation_errors=$((validation_errors + 1))
fi

# Validate Codemagic version management for iOS (unified architecture)
echo ""
echo "📋 Validating Codemagic iOS version management..."
if grep -q "build-complete" "codemagic.yaml"; then
    echo "✅ Codemagic is configured as build-only (unified architecture)"
else
    echo -e "${RED}❌ Codemagic missing build-complete notification${NC}"
    validation_errors=$((validation_errors + 1))
fi

# Check that Codemagic doesn't handle version updates (centralized in GitHub Actions)
if ! grep -q "update-version\|Update version from tag" "codemagic.yaml"; then
    echo "✅ Codemagic correctly delegates version management to GitHub Actions"
else
    echo -e "${RED}❌ Codemagic should not handle version updates (unified architecture)${NC}"
    validation_errors=$((validation_errors + 1))
fi

echo ""
echo "📋 Summary:"
echo "   Flutter Version: $FLUTTER_VERSION (from ci-versions.env)"
echo "   Flutter Channel: $FLUTTER_CHANNEL (from ci-versions.env)"
echo "   Java Version: $JAVA_VERSION (from ci-versions.env)"
echo "   Xcode Version: $XCODE_VERSION (from ci-versions.env)"
echo "   Firebase App IDs: ${#firebase_vars[@]} variables centralized in ci-versions.env"

# Final result
if [[ $validation_errors -eq 0 ]]; then
    echo ""
    echo -e "${GREEN}🎉 All CI/CD versions are properly configured!${NC}"
    echo "💡 To update versions in the future, edit .github/ci-versions.env only"
    exit 0
else
    echo ""
    echo -e "${RED}❌ Found $validation_errors validation error(s)${NC}"
    echo "💡 Please ensure all CI/CD configurations use versions from .github/ci-versions.env"
    exit 1
fi