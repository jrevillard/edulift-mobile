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
if grep -q "Load CI/CD versions from .env" ".github/workflows/cd.yml"; then
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
if grep -q "steps.*outputs.*XCODE_VERSION" ".github/workflows/cd.yml"; then
    echo "✅ Xcode version loaded from ci-versions.env"
else
    echo -e "${RED}❌ Xcode version not loaded from ci-versions.env${NC}"
    validation_errors=$((validation_errors + 1))
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

# Validate CI loads configuration JSON for flavors
if grep -q "dart-define-from-file=config/development.json" ".github/workflows/ci.yml"; then
    echo "✅ CI workflow loads configuration JSON for development flavor"
else
    echo -e "${RED}❌ CI workflow missing dart-define-from-file for development flavor${NC}"
    validation_errors=$((validation_errors + 1))
fi

# Validate Codemagic version update for iOS
echo ""
echo "📋 Validating Codemagic iOS version management..."
if grep -q "update-version" "codemagic.yaml"; then
    echo "✅ Codemagic has version update script for iOS"
else
    echo -e "${RED}❌ Codemagic missing version update script for iOS${NC}"
    validation_errors=$((validation_errors + 1))
fi

if grep -q "Update version from tag" "codemagic.yaml"; then
    echo "✅ Codemagic updates pubspec.yaml from tag"
else
    echo -e "${RED}❌ Codemagic missing pubspec.yaml update from tag${NC}"
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