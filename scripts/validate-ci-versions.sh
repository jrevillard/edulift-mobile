#!/bin/bash
# scripts/validate-ci-versions.sh
# Validate CI/CD configuration consistency (simplified version)

set -e

echo "🔍 Validating CI/CD configuration..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

errors=0

# =============================================================================
# 1. Check ci-versions.env exists and has required variables
# =============================================================================
echo ""
echo "📋 Checking ci-versions.env..."

if [[ ! -f ".github/ci-versions.env" ]]; then
    echo -e "${RED}❌ .github/ci-versions.env not found${NC}"
    exit 1
fi

source .github/ci-versions.env

required_vars=(
    "FLUTTER_VERSION"
    "FLUTTER_CHANNEL"
    "JAVA_VERSION"
    "XCODE_VERSION"
    "FIREBASE_ANDROID_STAGING_APP_ID"
    "FIREBASE_ANDROID_PROD_APP_ID"
    "FIREBASE_IOS_STAGING_APP_ID"
    "FIREBASE_IOS_PROD_APP_ID"
)

for var in "${required_vars[@]}"; do
    if [[ -z "${!var}" ]]; then
        echo -e "${RED}❌ Missing required variable: $var${NC}"
        errors=$((errors + 1))
    else
        echo "✅ $var=${!var}"
    fi
done

# =============================================================================
# 2. Check workflows load from ci-versions.env (no hardcoded versions)
# =============================================================================
echo ""
echo "📋 Checking workflows use centralized config..."

workflows=(".github/workflows/ci.yml" ".github/workflows/cd.yml")

for workflow in "${workflows[@]}"; do
    if [[ ! -f "$workflow" ]]; then
        echo -e "${YELLOW}⚠️  $workflow not found${NC}"
        continue
    fi

    # Check workflow loads from ci-versions.env
    if grep -q "ci-versions.env" "$workflow"; then
        echo "✅ $(basename "$workflow") loads from ci-versions.env"
    else
        echo -e "${RED}❌ $(basename "$workflow") doesn't load from ci-versions.env${NC}"
        errors=$((errors + 1))
    fi

    # Check for hardcoded Flutter versions (e.g., flutter-version: '3.24.0')
    if grep -E "flutter-version:\s*['\"]?[0-9]+\.[0-9]+" "$workflow" | grep -v '\${{' > /dev/null; then
        echo -e "${RED}❌ $(basename "$workflow") has hardcoded Flutter version${NC}"
        grep -E "flutter-version:\s*['\"]?[0-9]+\.[0-9]+" "$workflow" | grep -v '\${{' | head -2
        errors=$((errors + 1))
    fi

    # Check for hardcoded Java versions (e.g., java-version: '17')
    if grep -E "java-version:\s*['\"]?[0-9]+" "$workflow" | grep -v '\${{' > /dev/null; then
        echo -e "${RED}❌ $(basename "$workflow") has hardcoded Java version${NC}"
        grep -E "java-version:\s*['\"]?[0-9]+" "$workflow" | grep -v '\${{' | head -2
        errors=$((errors + 1))
    fi

    # Check for hardcoded Xcode versions (e.g., xcode-version: '16.4')
    if grep -E "xcode-version:\s*['\"]?[0-9]+\.[0-9]+" "$workflow" | grep -v '\${{' > /dev/null; then
        echo -e "${RED}❌ $(basename "$workflow") has hardcoded Xcode version${NC}"
        grep -E "xcode-version:\s*['\"]?[0-9]+\.[0-9]+" "$workflow" | grep -v '\${{' | head -2
        errors=$((errors + 1))
    fi
done

# =============================================================================
# 3. Check critical files exist and are not empty
# =============================================================================
echo ""
echo "📋 Checking critical files..."

critical_files=(
    ".github/workflows/cd.yml"
    ".github/workflows/ci.yml"
    ".github/ci-versions.env"
    "codemagic.yaml"
)

for file in "${critical_files[@]}"; do
    if [[ -f "$file" && -s "$file" ]]; then
        echo "✅ $file exists"
    elif [[ -f "$file" ]]; then
        echo -e "${RED}❌ $file is empty${NC}"
        errors=$((errors + 1))
    else
        echo -e "${RED}❌ $file not found${NC}"
        errors=$((errors + 1))
    fi
done

# =============================================================================
# 4. Check Codemagic uses centralized versions
# =============================================================================
echo ""
echo "📋 Checking Codemagic config..."

if [[ -f "codemagic.yaml" ]]; then
    # Flutter version
    if grep -q "flutter: $FLUTTER_VERSION" "codemagic.yaml"; then
        echo "✅ Codemagic uses Flutter $FLUTTER_VERSION"
    else
        echo -e "${RED}❌ Codemagic Flutter version mismatch (expected $FLUTTER_VERSION)${NC}"
        errors=$((errors + 1))
    fi

    # Xcode version
    if grep -q "xcode: $XCODE_VERSION" "codemagic.yaml"; then
        echo "✅ Codemagic uses Xcode $XCODE_VERSION"
    else
        echo -e "${RED}❌ Codemagic Xcode version mismatch (expected $XCODE_VERSION)${NC}"
        errors=$((errors + 1))
    fi
fi

# =============================================================================
# Summary
# =============================================================================
echo ""
echo "📋 Summary:"
echo "   Flutter: $FLUTTER_VERSION ($FLUTTER_CHANNEL)"
echo "   Java: $JAVA_VERSION"
echo "   Xcode: $XCODE_VERSION"

if [[ $errors -eq 0 ]]; then
    echo ""
    echo -e "${GREEN}🎉 All validations passed!${NC}"
    exit 0
else
    echo ""
    echo -e "${RED}❌ Found $errors error(s)${NC}"
    exit 1
fi
